---
title: Служба Systemd – сценарій Python
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
  - python
  - systemd
  - cron
---

# Служба `systemd` для сценарію Python

Якщо ви, як і багато системних адміністраторів, шанувальник сценаріїв cron, які запускаються за допомогою `* * * * * /I/launch/my/script.sh`, ця стаття повинна змусити вас подумати про інший спосіб зробити це використовуючи всю потужність і легкість, які пропонує `systemd`.

Ми напишемо сценарій python, який забезпечить безперервний цикл для виконання дій, які ви визначаєте.

Ми побачимо, як запустити цей сценарій як службу `systemd`, переглянемо журнали в journalctl і побачимо, що станеться, якщо сценарій аварійно завершує роботу.

## Передумови

Давайте почнемо зі встановлення деяких залежностей python, необхідних для сценарію для використання journalctl:

```
shell > sudo dnf install python36-devel systemd-devel
shell > sudo pip3 install systemd
```

## Написання сценарію

Давайте розглянемо такий сценарій `my_service.py`:

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

Ми починаємо з створення екземплярів необхідних змінних для надсилання логів у journald. Потім скрипт запускає нескінченний цикл і робить паузу на 60 секунд (що є мінімумом для виконання cron, тому ми можемо опуститися нижче цього обмеження).

!!! Note "Примітка"

    Особисто я використовую цей сценарій у більш просунутій формі, який постійно надсилає запити до бази даних і виконує завдання на основі інформації, отриманої через API rundeck

## Інтеграція Systemd

Тепер, коли у нас є сценарій, який може служити основою для вашої уяви, ми можемо встановити його як службу systemd.

Давайте створимо цей файл `my_service.service` і скопіюємо його до `/etc/systemd/system/`.

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

Як бачите, скрипт запускається з `/opt/my_service/`. Не забудьте адаптувати шлях до вашого сценарію та ідентифікатора системного журналу.

Запустіть і ввімкніть новий сервіс:

```
shell > sudo systemctl daemon-reload
shell > sudo systemctl enable my_service.service
shell > sudo systemctl start my_service.service
```

## Тести

Тепер ми можемо переглядати журнали через journalctl:

```
shell > journalctl -f -u my_service
oct. 14 11:07:48 rocky8 systemd[1]: Started My Service.
oct. 14 11:07:49 rocky8 __main__[270267]: [INFO] Starting the service
oct. 14 11:08:49 rocky8 __main__[270267]: [INFO] Total duration: 60
oct. 14 11:09:49 rocky8 __main__[270267]: [INFO] Total duration: 120
```

Тепер давайте подивимося, що станеться, якщо сценарій виходить з ладу:

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

Ми також можемо почекати 5 хвилин, доки сценарій завершить роботу самостійно: (видаліть це для свого виробництва)

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

Як бачите, функція перезапуску systemd дуже корисна.

## Висновок

`systemd` і `journald` надають нам інструменти для створення надійних і потужних сценаріїв, які достатньо легко замінять наші старі надійні сценарії crontab.

Сподіваюся, це рішення буде для вас корисним.
