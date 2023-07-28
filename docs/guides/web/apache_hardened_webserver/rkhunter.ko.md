---
title: Rootkit Hunter
author: Steven Spencer
contributors: Ezequiel Bruni, Andrew Thiesen
tested_with: 8.7, 9.1
tags:
  - server
  - security
  - rkhunter
---

# rkhunter 실행

## 소개

루트킷 헌터(`rkhunter`)는 서버에서 취약점, 루트킷, 백도어, 그리고 가능한 로컬 익스플로잇을 확인하는 잘 알려진 도구입니다. _어떤_ 목적으로 사용되는 _어떤_ 서버에서도 사용할 수 있습니다. 튜닝하고 자동화하면 의심스러운 활동을 시스템 관리자에게 보고할 수 있습니다. 이 절차는 루트킷 헌터의 설치, 튜닝, 사용 방법을 개요로 설명합니다.

## 필요 사항

* 명령줄 편집기 숙련도(이 예제에서는 _vi_를 사용함)
* 명령줄에서 명령을 내리고, 로그를 보고, 기타 일반 시스템 관리자의 의무를 수행하는 매우 편안한 수준
* 파일 시스템에서 변경된 파일에 대한 응답을 트리거할 수 있는 요소에 대한 이해는 도움이 됩니다(예: 패키지 업데이트).
* 모든 명령은 루트 사용자 또는 sudo로 실행됩니다.

이 문서는 원래 Apache Hardened Web Server 루틴과 함께 작성되었지만, 다른 소프트웨어를 실행하는 서버에서도 동일하게 작동합니다.

## 소개

`rkhunter` 는 견고한 Apache 웹 서버 설정의 가능한 구성 요소 중 하나로, 다른 도구와 함께 사용하거나 독립적으로 사용할 수 있습니다. 이것은 강화된 서버의 장점이며, 서버의 파일 시스템에서 의심스러운 일이 발생할 때 관리자에게 즉시 알립니다.

`rkhunter` 는 강화된 Apache 웹 서버 설정의 일부로만 사용할 수 있습니다. 단독 또는 다른 도구와 함께 사용하여 보안을 극대화합니다. 보다 강화된 보안을 위해 이것을 다른 도구와 함께 사용하려면 [Apache Hardened Web Server 가이드](index.md)를 참조하십시오.

또한 이 문서는 원본 문서에 설명된 모든 가정과 규칙을 사용합니다. 계속하기 전에 검토하는 것이 좋습니다.

## 일반적인 단계

1. rkhunter 설치
2. rkhunter 구성
3. 이메일 구성 및 올바르게 작동하는지 확인
4. 이메일 설정을 테스트하기 위해 `rkhunter`를 수동으로 실행하여 경고 목록을 생성합니다 (`rkhunter --check`)
5. `rkhunter --propupd`를 실행하여 이후 `rkhunter`에서 추가 검사의 기준이 되는 깨끗한 `rkhunter.dat` 파일을 생성합니다.

## rkhunter 설치

`rkhunter`는 EPEL (Extra Packages for Enterprise Linux) 리포지토리가 필요합니다. 이미 설치되어 있지 않은 경우 리포지토리를 설치하세요:

```
dnf install epel-release
```

`rkhunter`를 설치하세요:

```
dnf install rkhunter
```

## rkhunter 구성

관리자에게 보고서를 메일링하는 데 _필요한_ 유일한 구성 옵션은 설정해야 합니다.

!!! warning "주의"

    Linux의 _어떤_ 구성 파일을 수정하는 것은 리스크를 동반합니다. Linux에서 **어떤** 구성 파일을 변경하기 전에 _원본_ 구성 파일의 백업을 만드는 것이 좋습니다. 그렇게 하면 원래의 구성으로 복원해야 하는 경우를 대비할 수 있습니다.


구성 파일을 변경하려면 다음을 실행하세요:

```
vi /etc/rkhunter.conf
```

다음을 검색하세요:

```
#MAIL-ON-WARNING=me@mydomain   root@mydomain
```

여기의 주석을 제거하고 `me@mydomain.com`을 자신의 이메일 주소로 변경하세요.

`root@mydomain`를 `root@whatever_the_server_name_is`로 변경합니다.

또한 아래쪽에 있는 `MAIL-CMD` 라인의 주석을 제거하고 (필요에 맞게 편집), 다음과 같이 나타나는 줄을 편집해야 할 수도 있습니다:


```
MAIL_CMD=mail -s "[rkhunter] Warnings found for ${HOST_NAME}"
```

이메일 섹션을 올바르게 작동시키려면 [Postfix 이메일 설정](../../email/postfix_reporting.md)을 수행해야 할 수도 있습니다.

## `rkhunter` 실행

`rkhunter`를 수동으로 실행하려면 명령 줄에서 입력하세요. cron 작업이 `/etc/cron.daily`에서 자동으로 `rkhunter`를 실행합니다. 다른 일정으로 프로시저를 자동화하려면 [cron 작업 자동화 가이드](../../automation/cron_jobs_howto.md)를 확인하세요.

또한 스크립트를 `/etc/cron.daily/`가 아닌 다른 위치(예: `/usr/local/sbin/`)로 이동하고 사용자 정의 cron 작업에서 스크립트를 호출해야 합니다. 가장 쉬운 방법은 기본 `cron.daily` 설정을 그대로 둘 경우입니다.

시작하기 전에 `rkhunter`를 테스트하려면 모든 이메일 기능을 포함하여 명령 줄에서 `rkhunter --check`를 실행하세요. 설치되어 올바르게 작동하면 다음과 유사한 출력을 받아야 합니다:

```
[root@sol admin]# rkhunter --check
[Rootkit Hunter version 1.4.6]

Checking system commands...

Performing 'strings' command checks
- Checking 'strings' command                               [OK]

Performing 'shared libraries' checks
- Checking for preloading variables                        [None found]
- Checking for preloaded libraries                         [None found]
- Checking LD_LIBRARY_PATH variable                        [Not found]

Performing file properties checks
- Checking for prerequisites                               [Warning]
- /usr/bin/awk                                             [OK]
- /usr/bin/basename                                        [OK]
- /usr/bin/bash                                            [OK]
- /usr/bin/cat                                             [OK]
- /usr/bin/chattr                                          [OK]
- /usr/bin/chmod                                           [OK]
- /usr/bin/chown                                           [OK]
- /usr/bin/cp                                              [OK]
- /usr/bin/curl                                            [OK]
- /usr/bin/cut                                             [OK]
- /usr/bin/date                                            [OK]
- /usr/bin/df                                              [OK]
- /usr/bin/diff                                            [OK]
- /usr/bin/dirname                                         [OK]
- /usr/bin/dmesg                                           [OK]
- /usr/bin/du                                              [OK]
- /usr/bin/echo                                            [OK]
- /usr/bin/ed                                              [OK]
- /usr/bin/egrep                                           [Warning]
- /usr/bin/env                                             [OK]
- /usr/bin/fgrep                                           [Warning]
- /usr/bin/file                                            [OK]
- /usr/bin/find                                            [OK]
- /usr/bin/GET                                             [OK]
- /usr/bin/grep                                            [OK]
- /usr/bin/groups                                          [OK]
- /usr/bin/head                                            [OK]
- /usr/bin/id                                              [OK]
- /usr/bin/ipcs                                            [OK]
- /usr/bin/kill                                            [OK]
- /usr/bin/killall                                         [OK]
- /usr/bin/last                                            [OK]
- /usr/bin/lastlog                                         [OK]
- /usr/bin/ldd                                             [OK]
- /usr/bin/less                                            [OK]
- /usr/bin/locate                                          [OK]
- /usr/bin/logger                                          [OK]
- /usr/bin/login                                           [OK]
- /usr/bin/ls                                              [OK]
- /usr/bin/lsattr                                          [OK]
- /usr/bin/lsof                                            [OK]
- /usr/bin/mail                                            [OK]
- /usr/bin/md5sum                                          [OK]
- /usr/bin/mktemp                                          [OK]
- /usr/bin/more                                            [OK]
- /usr/bin/mount                                           [OK]
- /usr/bin/mv                                              [OK]
- /usr/bin/netstat                                         [OK]
- /usr/bin/newgrp                                          [OK]
- /usr/bin/passwd                                          [OK]
- /usr/bin/perl                                            [OK]
- /usr/bin/pgrep                                           [OK]
- /usr/bin/ping                                            [OK]
- /usr/bin/pkill                                           [OK]
- /usr/bin/ps                                              [OK]
- /usr/bin/pstree                                          [OK]
- /usr/bin/pwd                                             [OK]
- /usr/bin/readlink                                        [OK]
- /usr/bin/rkhunter                                        [OK]
- /usr/bin/rpm                                             [OK]
- /usr/bin/runcon                                          [OK]
- /usr/bin/sed                                             [OK]
- /usr/bin/sestatus                                        [OK]
- /usr/bin/sh                                              [OK]
- /usr/bin/sha1sum                                         [OK]
- /usr/bin/sha224sum                                       [OK]
- /usr/bin/sha256sum                                       [OK]
- /usr/bin/sha384sum                                       [OK]
- /usr/bin/sha512sum                                       [OK]
- /usr/bin/size                                            [OK]
- /usr/bin/sort                                            [OK]
- /usr/bin/ssh                                             [OK]
- /usr/bin/stat                                            [OK]
- /usr/bin/strace                                          [OK]
- /usr/bin/strings                                         [OK]
- /usr/bin/su                                              [OK]
- /usr/bin/sudo                                            [OK]
- /usr/bin/tail                                            [OK]
- /usr/bin/test                                            [OK]
- /usr/bin/top                                             [OK]
- /usr/bin/touch                                           [OK]
- /usr/bin/tr                                              [OK]
- /usr/bin/uname                                           [OK]
- /usr/bin/uniq                                            [OK]
- /usr/bin/users                                           [OK]
- /usr/bin/vmstat                                          [OK]
- /usr/bin/w                                               [OK]
- /usr/bin/watch                                           [OK]
- /usr/bin/wc                                              [OK]
- /usr/bin/wget                                            [OK]
- /usr/bin/whatis                                          [OK]
- /usr/bin/whereis                                         [OK]
- /usr/bin/which                                           [OK]
- /usr/bin/who                                             [OK]
- /usr/bin/whoami                                          [OK]
- /usr/bin/numfmt                                          [OK]
- /usr/bin/gawk                                            [OK]
- /usr/bin/s-nail                                          [OK]
- /usr/bin/whatis.man-db                                   [OK]
- /usr/bin/kmod                                            [OK]
- /usr/bin/systemctl                                       [OK]
- /usr/sbin/adduser                                        [OK]
- /usr/sbin/chroot                                         [OK]
- /usr/sbin/depmod                                         [OK]
- /usr/sbin/fsck                                           [OK]
- /usr/sbin/fuser                                          [OK]
- /usr/sbin/groupadd                                       [OK]
- /usr/sbin/groupdel                                       [OK]
- /usr/sbin/groupmod                                       [OK]
- /usr/sbin/grpck                                          [OK]
- /usr/sbin/ifconfig                                       [OK]
- /usr/sbin/init                                           [OK]
- /usr/sbin/insmod                                         [OK]
- /usr/sbin/ip                                             [OK]
- /usr/sbin/lsmod                                          [OK]
- /usr/sbin/modinfo                                        [OK]
- /usr/sbin/modprobe                                       [OK]
- /usr/sbin/nologin                                        [OK]
- /usr/sbin/ping                                           [OK]
- /usr/sbin/pwck                                           [OK]
- /usr/sbin/rmmod                                          [OK]
- /usr/sbin/route                                          [OK]
- /usr/sbin/rsyslogd                                       [OK]
- /usr/sbin/runlevel                                       [OK]
- /usr/sbin/sestatus                                       [OK]
- /usr/sbin/sshd                                           [OK]
- /usr/sbin/sulogin                                        [OK]
- /usr/sbin/sysctl                                         [OK]
- /usr/sbin/useradd                                        [OK]
- /usr/sbin/userdel                                        [OK]
- /usr/sbin/usermod                                        [OK]
- /usr/sbin/vipw                                           [OK]
- /usr/libexec/gawk                                        [OK]
- /usr/lib/systemd/systemd                                 [OK]

[Press <ENTER> to continue]
```

이메일 설정에 문제가 있으면 나머지 단계를 진행하지 마십시오. 이메일이 작동 확인된 후에 `rkhunter`를 자동으로 실행하기 전에 "--propupd" 플래그와 함께 명령을 다시 수동으로 실행하여 `rkhunter.dat` 파일을 생성하세요. 이는 환경과 구성을 인식하여 확인하는 데 도움이 됩니다:

```
rkhunter --propupd
```

## 결론

`rkhunter`는 파일 시스템을 모니터링하고 문제를 관리자에게 보고하는 강화된 서버 전략의 일부입니다. 설치, 구성 및 실행이 아마도 가장 쉬운 강화 도구 중 하나일 수 있습니다.
