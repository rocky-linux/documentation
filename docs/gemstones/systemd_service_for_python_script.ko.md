---
title: Systemd 서비스 - Python 스크립트
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
  - python
  - systemd
  - cron
---

# Python 스크립트용 `systemd` 서비스

많은 sysadmins(시스템관리자)들처럼, 당신이 `* * * * * /I/launch/my/script.sh`로 출시된 cron 스크립트의 애호가라면 이 문서를 통해 `systemd`가 제공하는 모든 기능과 용이성을을 사용하여 그것을 하는 다른 방법을 생각하게 할 것입니다.

정의한 작업을 실행하기 위해 연속 루프를 제공하는 Python 스크립트를 작성합니다.

이 스크립트를 `systemd` 서비스로 실행하고, journalctl에서 로그를 보고 스크립트가 충돌하면 어떻게 되는지 알아보겠습니다.

## 필요 사항

스크립트가 journalctl을 사용하는 데 필요한 몇 가지 Python 종속 항목을 설치하여 시작하겠습니다.

```
shell > sudo dnf install python36-devel systemd-devel
shell > sudo pip3 install systemd
```

## 스크립트 작성

다음 스크립트 `my_service.py`를 살펴보겠습니다.

```
"""
Sample script to run as script
"""
import time
import logging
import sys
from systemd.journal import JournaldLogHandler

# 로거 인스턴스 얻기
LOGGER = logging.getLogger(__name__)

# JournaldLogHandler를 인스턴스화하여 systemd에 연결
JOURNALD_HANDLER = JournaldLogHandler()
JOURNALD_HANDLER.setFormatter(logging.Formatter(
    '[%(levelname)s] %(message)s'
))

# 현재 로거에 journald 핸들러 추가
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

먼저 journald에서 로그를 전송하는 데 필요한 변수를 인스턴스화합니다. 그런 다음 스크립트가 무한 루프를 시작하고 60초 동안 일시 중지합니다(cron 실행의 최소 값이므로 이 제한을 벗어날 수 있습니다).

!!! 참고 사항

    저는 개인적으로 이 스크립트를 더 고급적인 형태로 사용하는데, 이는 데이터베이스를 지속적으로 쿼리하고 런덱 API를 통해 검색된 정보를 기반으로 작업을 실행합니다

## Systemd 통합

이제 당신의 상상력의 기반이 될 수 있는 스크립트가 생겼으니 systemd 서비스로 설치할 수 있습니다.

이 파일 `my_service.service`를 생성하고 `/etc/systemd/system/`에 복사해 봅시다.

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

보시다시피 스크립트는 `/opt/my_service/`에서 실행됩니다. 스크립트 및 syslog 식별자에 대한 경로를 조정해야 합니다.

새 서비스를 시작하고 활성화합니다:

```
shell > sudo systemctl daemon-reload
shell > sudo systemctl enable my_service.service
shell > sudo systemctl start my_service.service
```

## 테스트

이제 journalctl을 통해 로그를 볼 수 있습니다:

```
shell > journalctl -f -u my_service
oct. 14 11:07:48 rocky8 systemd[1]: Started My Service.
oct. 14 11:07:49 rocky8 __main__[270267]: [INFO] Starting the service
oct. 14 11:08:49 rocky8 __main__[270267]: [INFO] Total duration: 60
oct. 14 11:09:49 rocky8 __main__[270267]: [INFO] Total duration: 120
```

이제 스크립트가 충돌하면 어떻게 되는지 살펴보겠습니다:

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

스크립트 자체가 충돌할 때까지 5분을 기다릴 수도 있습니다. (프로덕션을 위해 제거하십시오.):

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

보시다시피 systemd의 재시작 기능은 매우 유용합니다.

## 결론

`systemd` 및 `journald`는 이전의 신뢰할 수 있는 crontab 스크립트를 대체할 수 있을 만큼 견고하고 강력한 스크립트를 쉽게 만들 수 있는 도구를 제공합니다.

이 솔루션이 유용하기를 바랍니다.
