---
title: Service `systemd` - Script Python
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
  - python
  - systemd
  - cron
---

# Service `systemd` pour un Script Python

Si, comme beaucoup de sysadmins, vous êtes un passionné de scripts cron lancés avec `* * * * * * * * * /I/launch/my/script. h`, cet article devrait vous faire réfléchir à une autre façon de le faire en utilisant toute la puissance et le confort offerts par `systemd`.

Vous allez écrire un script python qui fournira une boucle infinie pour exécuter les actions que vous définissez.

Nous allons voir comment exécuter ce script en tant que service `systemd`, examiner les journaux de journalctl et voir ce qui se passe si le script plante.

## Prérequis

Commençons par installer quelques dépendances python nécessaires pour que le script utilise journalctl :

```bash
shell > sudo dnf install python36-devel systemd-devel
shell > sudo pip3 install systemd
```

## Développement du Script

Considérons le script suivant `my_service.py` :

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

Nous commençons par instancier les variables nécessaires pour envoyer les logs dans `journald`. Le script lance alors une boucle infinie et marque une pause de 60 secondes (ce qui est le minimum d'une exécution cron, donc on peut descendre en dessous de cette limitation).

!!! note "Remarque"

    L'auteur utilise ce script dans une forme plus avancée, qui interroge en permanence une base de données et exécute des tâches en fonction des informations récupérées via l'API rundeck

## Intégration de `systemd`

Maintenant que nous avons un script qui peut servir de base à votre imagination, vous pouvez l'installer en tant que service système.

Créons ce fichier `my_service.service` et copions-le dans le répertoire `/etc/systemd/system/`.

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

Comme vous pouvez le constater, le script est lancé à partir de `/opt/my_service/`. N'oubliez pas d'adapter le chemin à votre script et à l'identifiant `syslog`.

Lancez et activez le nouveau service :

```bash
shell > sudo systemctl daemon-reload
shell > sudo systemctl enable my_service.service
shell > sudo systemctl start my_service.service
```

## Tests

Nous pouvons maintenant examiner les logs via `journalctl` :

```bash
shell > journalctl -f -u my_service
oct. 14 11:07:48 rocky8 systemd[1]: Started My Service.
oct. 14 11:07:49 rocky8 __main__[270267]: [INFO] Starting the service
oct. 14 11:08:49 rocky8 __main__[270267]: [INFO] Total duration: 60
oct. 14 11:09:49 rocky8 __main__[270267]: [INFO] Total duration: 120
```

Maintenant, voyons ce qui se passe si le script plante :

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

Nous pouvons également attendre 5 minutes pour que le script s'écrase lui-même (vous devez supprimer ceci pour votre production) :

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

Comme vous pouvez le constater, la fonction de redémarrage de `systemd` est très utile.

## Conclusion

`systemd` et `journald` nous fournissent les outils pour créer des scripts robustes et puissants assez facilement pour remplacer nos anciens scripts `crontab` fiables.

L'auteur espère que cette solution vous sera utile.
