---
title: rsync 구성 파일
author: tianci li
update: 2021-11-04
---

# /etc/rsyncd.conf

이전 문서 [ rsync 데모 02 ](03_rsync_demo02.md)에서 몇 가지 기본 매개변수를 소개했습니다. 이 문서는 다른 매개변수를 보완하기 위한 것입니다.

| 변수                                  | 설명                                                                                                                                                                                                     |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| fake super = yes                    | yes는 데몬을 root로 실행하여 파일의 완전한 속성을 저장할 필요가 없음을 의미합니다.                                                                                                                                                     |
| uid =                               | 사용자 id                                                                                                                                                                                                 |
| gid =                               | 두 매개변수는 rsync 데몬을 root로 실행할 때 파일 전송에 사용되는 사용자와 그룹을 지정하는 데 사용됩니다. 기본값은 nobody입니다.                                                                                                                       |
| use chroot = yes                    | 전송 전에 루트 디렉토리를 잠그는지 여부를 지정합니다. yes는 잠그고, no는 잠그지 않습니다. 보안을 강화하기 위해 rsync는 기본적으로 yes로 설정됩니다.                                                                                                            |
| max connections = 4                 | 허용되는 최대 연결 수입니다. 기본값은 0이며, 이는 제한이 없음을 의미합니다.                                                                                                                                                           |
| lock file = /var/run/rsyncd.lock    | 지정된 잠금 파일로 "max connections" 매개변수와 관련이 있습니다.                                                                                                                                                           |
| exclude = lost+found/               | 전송할 필요가 없는 디렉토리를 제외합니다.                                                                                                                                                                                |
| transfer logging = yes              | ftp와 유사한 로그 형식을 활성화하여 rsync의 업로드 및 다운로드를 기록할지 여부를 지정합니다.                                                                                                                                               |
| timeout = 900                       | 타임아웃 기간을 지정합니다. 지정된 시간 내에 데이터가 전송되지 않으면 rsync가 직접 종료됩니다. 단위는 초이며, 기본값은 0으로 타임아웃이 없음을 의미합니다.                                                                                                            |
| ignore nonreadable = yes            | 사용자가 액세스 권한이 없는 파일을 무시할지 여부를 지정합니다.                                                                                                                                                                    |
| motd file = /etc/rsyncd/rsyncd.motd | 메시지 파일의 경로를 지정하는 데 사용됩니다. 기본적으로 motd 파일은 없습니다. 이 메시지는 사용자가 로그인할 때 표시되는 환영 메시지입니다.                                                                                                                      |
| hosts allow = 10.1.1.1/24           | 접근을 허용하는 IP 또는 네트워크 세그먼트를 지정하는 데 사용됩니다. IP, 네트워크 세그먼트, 도메인의 호스트 이름, 호스트를 영어로 구분하여 여러 개를 지정할 수 있습니다. 기본적으로 모든 접근을 허용합니다.                                                                                |
| hosts deny = 10.1.1.20              | 사용자가 지정한 IP 또는 네트워크 세그먼트 클라이언트가 접근할 수 없습니다. hosts allow와 hosts deny가 동일한 일치 결과를 가지는 경우 클라이언트는 마지막에 접근할 수 없습니다. 클라이언트의 주소가 hosts allow나 hosts deny에 없는 경우 클라이언트는 접근을 허용합니다. 기본적으로 해당 매개변수가 없습니다.        |
| auth users = li                     | 가상 사용자를 활성화하며, 여러 사용자는 영어로 쉼표로 구분합니다.                                                                                                                                                                  |
| syslog facility = daemon            | 시스템 로그 수준을 정의합니다. 다음 값을 채울 수 있습니다: auth, authpriv, cron, daemon, ftp, kern, lpr, mail, news, security, syslog, user, uucp, local0, local1, local2 local3, local4, local5, local6 및 local7. 기본값은 데몬입니다. |

## 권장 구성

![ photo ](images/rsync_config.jpg)
