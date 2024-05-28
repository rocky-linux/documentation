---
title: Servizio Systemd - Script Python
author: Antoine Le Morvan
contributors: Steven Spencer, Franco Colussi
tested_with: 2022-10-14
tags:
  - python
  - systemd
  - cron
---

# `systemd` Servizio per uno script Python

Se, come molti sysadmin, siete amanti degli script cron lanciati con `* * * * * /I/launch/my/script.sh`, questo articolo dovrebbe farvi pensare a un altro modo per farlo, utilizzando tutta la potenza e la facilità offerte da `systemd`.

Scriveremo uno script python che fornirà un ciclo continuo per eseguire le azioni definite.

Vedremo come eseguire questo script come servizio `systemd`, visualizzare i log in journalctl e vedere cosa succede se lo script si blocca.

## Prerequisiti

Iniziamo installando alcune dipendenze python necessarie allo script per utilizzare journalctl:

```bash
shell > sudo dnf install python36-devel systemd-devel
shell > sudo pip3 install systemd
```

## Scrittura dello script

Consideriamo il seguente script `my_service.py`:

```python
"""
Sample script to run as script
"""
import time
import logging
import sys
from systemd.journal import JournaldLogHandler

# Get an instance of the logger
LOGGER = logging.getLogger(__name__)

# Instantiate the JournaldLogHandler to hook into systemd
JOURNALD_HANDLER = JournaldLogHandler()
JOURNALD_HANDLER.setFormatter(logging.Formatter(
    '[%(levelname)s] %(message)s'
))

# Add the journald handler to the current logger
LOGGER.addHandler(JOURNALD_HANDLER)
LOGGER.setLevel(logging.INFO)

class Service(): # pylint: disable=too-few-public-methods
    """
    Launch an infinite loop
    """
    def __init__(self):

        duration = 0

        while True:
            time.sleep(60)
            duration += 60
            LOGGER.info("Total duration: %s", str(duration))
            # will failed after 4 minutes
            if duration > 240:
                sys.exit(1)

if __name__ == '__main__':

    LOGGER.info("Starting the service")
    Service()
```

Iniziamo instanziando le variabili necessarie per inviare i log nel diario. Lo script lancia quindi un ciclo infinito e si ferma per 60 secondi (che è il minimo di un'esecuzione cron, quindi possiamo scendere al di sotto di questa limitazione).

!!! Note "Nota"

    Personalmente uso questo script in una forma più avanzata, che interroga continuamente un database ed esegue lavori basati sulle informazioni recuperate tramite l'API di rundeck

## Integrazione di Systemd

Ora che abbiamo uno script che può servire come base per la vostra immaginazione, possiamo installarlo come servizio systemd.

Creiamo il file `my_service.service` e copiamolo in `/etc/systemd/system/`.

```bash
[Unit]
Description=My Service
After=multi-user.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/python3 my_service.py
WorkingDirectory=/opt/my_service/

StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=my_service

[Install]
WantedBy=multi-user.target
```

Come si può vedere, lo script viene lanciato da `/opt/my_service/`. Ricordarsi di adattare il percorso dello script e l'identificatore syslog.

Avviare e abilitare il nuovo servizio:

```bash
shell > sudo systemctl daemon-reload
shell > sudo systemctl enable my_service.service
shell > sudo systemctl start my_service.service
```

## Test

Ora possiamo visualizzare i log tramite journalctl:

```bash
shell > journalctl -f -u my_service
oct. 14 11:07:48 rocky8 systemd[1]: Started My Service.
oct. 14 11:07:49 rocky8 __main__[270267]: [INFO] Starting the service
oct. 14 11:08:49 rocky8 __main__[270267]: [INFO] Total duration: 60
oct. 14 11:09:49 rocky8 __main__[270267]: [INFO] Total duration: 120
```

Vediamo ora cosa succede se lo script si blocca:

```bash
shell > ps -elf | grep my_service
4 S root      270267       1  0  80   0 - 82385 -      11:07 ?        00:00:00 /usr/bin/python3 my_service.py
shell > sudo kill -9 270267
```

```bash
shell > journalctl -f -u my_service
oct. 14 11:10:49 rocky8 __main__[270267]: [INFO] Total duration: 180
oct. 14 11:11:49 rocky8 __main__[270267]: [INFO] Total duration: 240
oct. 14 11:12:19 rocky8 systemd[1]: my_service.service: Main process exited, code=killed, status=9/KILL
oct. 14 11:12:19 rocky8 systemd[1]: my_service.service: Failed with result 'signal'.
oct. 14 11:12:19 rocky8 systemd[1]: my_service.service: Service RestartSec=100ms expired, scheduling restart.
oct. 14 11:12:19 rocky8 systemd[1]: my_service.service: Scheduled restart job, restart counter is at 1.
oct. 14 11:12:19 rocky8 systemd[1]: Stopped My Service.
oct. 14 11:12:19 rocky8 systemd[1]: Started My Service.
oct. 14 11:12:19 rocky8 __main__[270863]: [INFO] Starting the service
```

Possiamo anche aspettare 5 minuti che lo script si blocchi da solo: (rimuovete questo per la vostra produzione)

```bash
oct. 14 11:16:02 rocky8 systemd[1]: Started My Service.
oct. 14 11:16:03 rocky8 __main__[271507]: [INFO] Starting the service
oct. 14 11:17:03 rocky8 __main__[271507]: [INFO] Total duration: 60
oct. 14 11:18:03 rocky8 __main__[271507]: [INFO] Total duration: 120
oct. 14 11:19:03 rocky8 __main__[271507]: [INFO] Total duration: 180
oct. 14 11:20:03 rocky8 __main__[271507]: [INFO] Total duration: 240
oct. 14 11:21:03 rocky8 __main__[271507]: [INFO] Total duration: 300
oct. 14 11:21:03 rocky8 systemd[1]: my_service.service: Main process exited, code=exited, status=1/FAILURE
oct. 14 11:21:03 rocky8 systemd[1]: my_service.service: Failed with result 'exit-code'.
oct. 14 11:21:03 rocky8 systemd[1]: my_service.service: Service RestartSec=100ms expired, scheduling restart.
oct. 14 11:21:03 rocky8 systemd[1]: my_service.service: Scheduled restart job, restart counter is at 1.
oct. 14 11:21:03 rocky8 systemd[1]: Stopped My Service.
oct. 14 11:21:03 rocky8 systemd[1]: Started My Service.
oct. 14 11:21:03 rocky8 __main__[271993]: [INFO] Starting the service
```

Come si può vedere, la funzione di riavvio di systemd è molto utile.

## Conclusione

`systemd` e `journald` ci forniscono gli strumenti per creare script robusti e potenti in modo abbastanza semplice da sostituire i nostri vecchi e affidabili script crontab.

Spero che questa soluzione sia utile per voi.
