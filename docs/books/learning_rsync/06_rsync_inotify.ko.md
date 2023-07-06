---
title: inotify-tools 설치 및 사용
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# 컴파일 및 설치

서버에서 다음 작업을 수행합니다. 사용자 환경에서 일부 종속 패키지가 누락되었을 수 있습니다. `dnf -y install autoconf automake libtool`을 사용하여 설치합니다.

```bash
[root@Rocky ~]# wget -c https://github.com/inotify-tools/inotify-tools/archive/refs/tags/3.21.9.6.tar.gz
[root@Rocky ~]# tar -zvxf 3.21.9.6.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/inotify-tools-3.21.9.6/
[root@Rocky /usr/local/src/inotify-tools-3.21.9.6]# ./autogen.sh && \
./configure --prefix=/usr/local/inotify-tools && \
make && \
make install
...
[root@Rocky ~]# ls /usr/local/inotify-tools/bin/
inotifywait inotifywatch
```

환경 변수 PATH를 추가하고 구성 파일에 기록한 다음 영구적으로 적용되도록 합니다.

```bash
[root@Rocky ~]# vim /etc/profile
...
PATH=$PATH:/usr/local/inotify-tools/bin/
[root@Rocky ~]# . /etc/profile
```

**EPEL 저장소의 inotify-tools RPM 패키지를 사용하지 않는 이유는 무엇입니까? 그리고 소스 코드를 사용하여 컴파일하고 설치하는 방법은 무엇입니까?**

저자는 개인적으로 원격 데이터 전송이 효율성의 문제라고 생각하며, 특히 동기화할 파일이 많고 단일 파일이 특히 큰 프로덕션 환경에서 특히 그렇습니다. 또한 새 버전에서는 일부 버그 수정 및 기능 확장이 있을 것이며 아마도 새 버전의 전송 효율이 더 높을 것이므로 소스 코드로 inotify-tools를 설치하는 것이 좋습니다. 물론 이것은 저자의 개인적인 제안이며 모든 사용자가 따라야 하는 것은 아닙니다.

## 커널 매개변수 조정

프로덕션 환경의 필요에 따라 커널 매개변수를 조정할 수 있습니다. 기본적으로 **/proc/sys/fs/inotity/**에는 세 개의 파일이 있습니다.

```bash
[root@Rocky ~]# cd /proc/sys/fs/inotify/
[root@Rocky /proc/sys/fs/inotify]# cat max_queued_events ;cat max_user_instances ;cat max_user_watches
16384
128
28014
```

* max_queued_events-maximum monitor queue size, default 16384
* max_user_instances-the maximum number of monitoring instances, the default is 128
* max_user_watches-the maximum number of files monitored per instance, the default is 8192

일부 매개변수 및 값을 **/etc/sysctl.conf**에 작성합니다. 예는 다음과 같습니다. 그런 다음 `sysctl -p`를 사용하여 파일을 적용합니다.

```txt
fs.inotify.max_queued_events = 16384
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 1048576
```

## 관련 명령

inotify-tools 도구에는 다음과 같은 두 가지 명령이 있습니다.
* **inotifywait**-지속적인 모니터링을 위해 실시간으로 결과를 출력합니다. 일반적으로 rsync 증분 백업 도구와 함께 사용됩니다. 파일 시스템 모니터링이기 때문에 스크립트와 함께 사용할 수 있습니다. 구체적인 대본 작성은 차후에 소개하도록 하겠습니다.
* **inotifywatch**-단기 모니터링을 위해 작업이 완료된 후 결과를 출력합니다.

`inotifywait`에는 주로 다음 옵션이 있습니다.

```txt
-m 지속적인 모니터링을 의미
-r 재귀적 모니터링
-q 출력 정보 단순화
-e 모니터링 데이터의 이벤트 유형을 지정하며 여러 이벤트 유형은 영어 상태에서 쉼표로 구분됩니다.
```

이벤트 유형은 다음과 같습니다.

| 이벤트 유형        | 설명                                          |
| ------------- | ------------------------------------------- |
| access        | 파일 또는 디렉토리 내용을 읽었습니다                        |
| modify        | 파일 또는 디렉토리의 내용이 기록되었습니다.                    |
| attrib        | 파일 또는 디렉토리의 속성이 수정되었습니다.                    |
| close_write   | 쓰기 가능 모드로 열린 후 파일 또는 디렉토리가 닫힘               |
| close_nowrite | 읽기 전용 모드로 열린 후 파일 또는 디렉토리가 닫힘               |
| close         | 읽기 / 쓰기 모드에 관계없이 파일 또는 디렉터리가 닫힘             |
| open          | 열린 파일 또는 디렉토리                               |
| moved_to      | 모니터링 된 디렉토리로 이동 된 파일 또는 디렉토리                |
| moved_from    | 모니터링 된 디렉토리에서 이동 된 파일 또는 디렉토리               |
| move          | 모니터링 디렉터리로 이동하거나 모니터링 디렉터리에서 제거된 파일 또는 디렉터리 |
| move_self     | 모니터링된 파일 또는 디렉터리가 이동되었습니다.                  |
| create        | 모니터링 된 디렉토리 내에 생성 된 파일 또는 디렉토리              |
| delete        | 모니터링된 디렉터리의 파일 또는 디렉터리가 삭제되었습니다.            |
| delete_self   | 모니터링 디렉토리 내에서 삭제 된 파일 또는 디렉토리               |
| unmount       | 마운트 해제된 파일 또는 디렉토리를 포함하는 파일 시스템             |

예시 : `[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/`

## `inotifywait` 명령 시범

첫 번째 터미널 pts/0에 명령을 입력하고 Enter 키를 누르면 창이 잠기며 모니터링 중임을 나타냅니다.

```bash
[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/

```

두 번째 터미널 pts/1에서 /rsync/ 디렉토리로 이동하여 파일을 생성합니다.

```bash
[root@Rocky ~]# cd /rsync/
[root@Rocky /rsync]# touch inotify
```

다시 첫 번째 터미널 pts/0으로 돌아가서 출력 정보는 다음과 같습니다.

```bash
[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/
/rsync/ CREATE inotify
```

## `inotifywait` 및 `rsync`의 조합

!!! 팁 "tip"

    우리는 시범을 위해 SSH 프로토콜을 사용하여 Rocky Linux 8 서버에서 운영하고 있습니다.

SSH 프로토콜의 비밀번호 없는 인증 로그인은 여기서 설명하지 않는 [rsync 비밀번호 없는 인증 로그인](05_rsync_authentication-free_login.md)을 참조하십시오. bash 스크립트 내용의 예는 다음과 같습니다. 필요에 따라 명령 뒤에 다른 옵션을 추가하여 요구 사항을 충족할 수 있습니다. 예를 들어 `rsync` 명령 뒤에 `--delete`를 추가할 수도 있습니다.

```bash
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e modify,move,create,delete /rsync/"
b="/usr/bin/rsync -avz /rsync/* testfedora@192.168.100.5:/home/testfedora/"
$a | while read directory event file
    do
        $b &>> /tmp/rsync.log
    done
```

```bash
[root@Rocky ~]# chmod +x rsync_inotify.sh
[root@Rocky ~]# bash /root/rsync_inotify.sh &
```

!!! 팁 "tip"

    데이터 동기화 전송에 SSH 프로토콜을 사용할 때 대상 머신의 SSH 서비스 포트가 22가 아닌 경우 다음과 유사한 방법을 사용할 수 있습니다.——
    `b="/usr/bin/rsync -avz -e 'ssh -p [port-number]' /rsync/* testfedora@192.168.100.5:/home/testfedora/"`

!!! 팁 "tip"

    If you want to start this script at boot
    `[root@Rocky ~]# echo "bash /root/rsync_inotify.sh &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

동기화를 위해 rsync 프로토콜을 사용하는 경우 대상 시스템의 rsync 서비스를 구성해야 합니다. [rsync 데모 02](03_rsync_demo02.md), [rsync 구성 파일](04_rsync_configure.md), [rsync 무료 비밀 인증 로그인](05_rsync_authentication-free_login.md)을 참조하십시오.
