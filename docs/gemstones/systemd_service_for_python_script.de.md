---
title: Service `systemd` - Python Skript
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
  - python
  - systemd
  - cron
---

# `systemd` Dienst für ein Python-Skript

Wenn Sie wie viele Sysadmins ein Fan von Cron-Skripten sind, die mit `* * * * * * /I/launch/my/script.sh` gestartet werden, sollte dieser Artikel Sie an eine andere Möglichkeit erinnern, dies mit der ganzen Leichtigkeit des `systemd` zu tun.

Wir schreiben ein Python-Skript, das eine Endlosschleife zur Ausführung der von Ihnen definierten Aktionen bereitstellt.

Wir werden sehen, wie dieses Skript als `systemd` Dienst ausgeführt wird, wie die Protokolle in Journalctl anzeigt werden können, was passiert, wenn das Skript abstürzt.

## Voraussetzungen

Beginnen wir damit, einige Python-Abhängigkeiten zu installieren, die für das Skript benötigt werden, um das Kommando journalctl zu verwenden:

```
shell > sudo dnf install python36-devel systemd-devel
shell > sudo pip3 install systemd
```

## Skript entwerfen

Lass uns das folgende Skript `my_service.py` anschauen:

```
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

Wir beginnen damit, die notwendigen Variablen zu instanziieren, um Logs dem Journal zu senden. Das Skript startet dann eine unendliche Schleife und pausiert für 60 Sekunden (was das Minimum einer Cron-Ausführung ist, so dass wir unter diese Grenze gehen können).

!!! note "Anmerkung"

    Der Autor benutzt dieses Skript in einer fortgeschrittenen Form, die kontinuierlich eine Datenbank abfragt und Jobs basierend auf den über die Rundeck API abgerufenen Informationen ausführt

## Integration in Systemd

Jetzt, da wir ein Skript haben, das als Grundlage für Ihre Phantasie dienen kann, können wir es als System-Dienst installieren.

Lass uns die Datei `my_service.service` erstellen und sie nach `/etc/systemd/system/` kopieren.

```
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

Wie Sie sehen können, wird das Skript von `/opt/my_service/` gestartet. Denken Sie daran, den Pfad an Ihr Skript und die Syslog-Kennung anzupassen.

Neuen Dienst aktivieren und starten:

```
shell > sudo systemctl daemon-reload
shell > sudo systemctl enable my_service.service
shell > sudo systemctl start my_service.service
```

## Tests

Wir können die Protokolle jetzt via journalctl anzeigen:

```
shell > journalctl -f -u my_service
oct. 14 11:07:48 rocky8 systemd[1]: Started My Service.
oct. 14 11:07:49 rocky8 __main__[270267]: [INFO] Starting the service
oct. 14 11:08:49 rocky8 __main__[270267]: [INFO] Total duration: 60
oct. 14 11:09:49 rocky8 __main__[270267]: [INFO] Total duration: 120
```

Lass uns nun sehen, was passiert, wenn das Skript abgestürzt ist:

```
shell > ps -elf | grep my_service
4 S root      270267       1  0  80   0 - 82385 -      11:07 ?        00:00:00 /usr/bin/python3 my_service.py
shell > sudo kill -9 270267
```

```
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

Wir können auch 5 Minuten warten, bis das Skript selbst abstürzt (entfernen Sie dies für Ihre Produktion):

```
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

Wie Sie sehen können, ist die Neustartfunktion von systemd sehr nützlich.

## Fazit

`systemd` und `journald` stellen uns die Werkzeuge zur Verfügung, um robuste und leistungsstarke Skripte so einfach wie möglich zu machen, dass sie unsere alten zuverlässigen Crontab-Skripte ersetzen.

Wir hoffen, dass dieser Vorschlag für Sie nützlich sein wird.
