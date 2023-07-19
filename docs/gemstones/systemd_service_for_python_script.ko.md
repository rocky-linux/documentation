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

# systemd를 사용하여 Python 스크립트를 서비스로 실행하는 방법

많은 시스템 관리자들처럼 `* * * * * /I/launch/my/script.sh`와 같이 cron 스크립트를 다운로드하는 경우, 이 문서는 `systemd`가 제공하는 모든 기능과 편의성을 활용하여 다른 방법을 생각하게 할 것입니다.

우리는 지정한 동작을 실행하는 연속 루프를 제공하는 Python 스크립트를 작성할 것입니다.

이 스크립트를 `systemd` 서비스로 실행하는 방법, journalctl에서 로그를 확인하는 방법, 스크립트가 충돌하는 경우 어떻게 되는지 알아보겠습니다.

## 전제 조건

먼저, 스크립트가 journalctl을 사용하도록 필요한 몇 가지 Python 종속성을 설치해야 합니다.

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

먼저, journald에 로그를 보내기 위해 필요한 변수들을 인스턴스화합니다. 그런 다음 스크립트는 무한 루프를 시작하고 60초 동안 일시 중지합니다 (이는 cron 실행의 최소 시간이므로 이 제한을 아래로 내릴 수 있습니다).

!!! 참고 사항

    저는 개선된 형태의 이 스크립트를 사용하고 있으며, 데이터베이스를 계속해서 쿼리하고 rundeck API를 통해 검색한 정보를 기반으로 작업을 실행합니다.

## Systemd 통합

이제 상상력의 기초로 사용할 수 있는 스크립트가 있으므로 이를 systemd 서비스로 설치해 보겠습니다.

이 파일 `my_service.service`를 생성하고 `/etc/systemd/system/`에 복사합니다.

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

스크립트는 `/opt/my_service/`에서 시작됩니다. 스크립트의 경로와 syslog 식별자를 조정해 주시기 바랍니다.

새 서비스를 시작하고 활성화합니다.

```
shell > sudo systemctl daemon-reload
shell > sudo systemctl enable my_service.service
shell > sudo systemctl start my_service.service
```

## 테스트

이제 journalctl을 통해 로그를 볼 수 있습니다.

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

또한 스크립트가 스스로 충돌하는 것을 5분 동안 기다려 볼 수 있습니다. (실제 운영 환경에서는 이 부분을 제거하세요)

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

systemd의 재시작 기능이 매우 유용하다는 것을 알 수 있습니다.

## 결론

`systemd` 및 `journald`는 우리에게 신뢰성과 강력함을 제공하는 도구입니다. 이를 사용하여 기존의 신뢰할 수 있던 crontab 스크립트를 대체할 수 있습니다.

이 솔루션이 유용하기를 바랍니다.
