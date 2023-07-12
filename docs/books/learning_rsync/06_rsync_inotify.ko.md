---
title: inotify-tools 설치 및 사용
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# 컴파일 및 설치

서버에서 다음 작업을 수행합니다. 환경에 따라 종속성이 없는 일부 패키지가 누락될 수 있습니다. `dnf -y install autoconf automake libtool`을 사용하여 설치합니다.

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

환경 변수 PATH를 추가하고, 이를 구성 파일에 작성하여 영구적으로 적용하세요.

```bash
[root@Rocky ~]# vim /etc/profile
...
PATH=$PATH:/usr/local/inotify-tools/bin/
[root@Rocky ~]# . /etc/profile
```

**왜 EPEL 저장소의 inotify-tools RPM 패키지를 사용하지 않을까요? 그리고 소스 코드를 사용하여 컴파일하고 설치하는 방법은 무엇인가요?**

저자는 원격 데이터 전송은 효율성의 문제라고 생각합니다. 특히 생산 환경에서는 동기화해야 할 파일이 많고, 특정 파일이 특히 큰 경우입니다. 또한 새로운 버전에서는 버그 수정과 기능 확장이 있을 수 있으며, 새로운 버전의 전송 효율성이 더 높을 수도 있습니다. 따라서 저는 inotify-tools를 소스 코드로 설치하는 것을 추천합니다. 물론 이것은 저자의 개인적인 제안이며, 모든 사용자가 반드시 따라야 하는 것은 아닙니다.

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

일부 매개변수 및 값을 **/etc/sysctl.conf**에 작성합니다. 예는 다음과 같습니다. 그런 다음 `sysctl -p`를 사용하여 파일을 적용하세요.

```txt
fs.inotify.max_queued_events = 16384
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 1048576
```

## 관련 명령

inotify-tools 도구에는 다음과 같은 두 가지 명령이 있습니다.
* **inotifywait**-지속적인 모니터링, 실시간으로 결과를 출력합니다. 주로 rsync 점진적 백업 도구와 함께 사용됩니다. 파일 시스템 모니터링이기 때문에 스크립트와 함께 사용할 수 있습니다. 특정 스크립트 작성 방법은 나중에 소개하겠습니다.
* **inotifywatch**-단기간 모니터링, 작업이 완료된 후 결과를 출력합니다.

`inotifywait`은 주로 다음 옵션을 사용합니다.

```txt
-m 지속적인 모니터링을 의미합니다. -r 재귀적인 모니터링을 의미합니다. -q 출력 정보를 간소화합니다. -e 모니터링 데이터의 이벤트 유형을 지정하며, 여러 이벤트 유형은 영어 상태로 쉼표로 구분됩니다.
```

이벤트 유형은 다음과 같습니다.

| 이벤트 유형        | 설명                                |
| ------------- | --------------------------------- |
| access        | 파일 또는 디렉토리 내용에 접근                 |
| modify        | 파일 또는 디렉토리의 내용이 수정됨               |
| attrib        | 파일 또는 디렉토리의 속성이 수정됨               |
| close_write   | 파일 또는 디렉토리가 쓰기 모드로 열린 후 닫힘        |
| close_nowrite | 파일 또는 디렉토리가 읽기 전용 모드로 열린 후 닫힘     |
| close         | 읽기 / 쓰기 모드에 관계없이 파일 또는 디렉터리가 닫힘   |
| open          | 파일 또는 디렉토리가 열림                    |
| moved_to      | 감시 중인 디렉토리로 파일 또는 디렉토리가 이동됨       |
| moved_from    | 감시 중인 디렉토리에서 파일 또는 디렉토리가 이동됨      |
| move          | 감시 중인 디렉토리로 파일 또는 디렉토리가 이동하거나 삭제됨 |
| move_self     | 감시 중인 파일 또는 디렉토리가 이동됨             |
| create        | 감시 중인 디렉토리에 파일 또는 디렉토리가 생성됨       |
| delete        | 감시 중인 디렉토리의 파일 또는 디렉토리가 삭제됨       |
| delete_self   | 감시 중인 디렉토리 내에서 삭제 된 파일 또는 디렉토리    |
| unmount       | 마운트 해제된 파일 시스템의 파일 또는 디렉토리        |

예시 : `[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/`

## `inotifywait` 명령 시범

첫 번째 터미널 pts/0에서 명령어를 입력하고 Enter를 누르면 창이 잠겨있는 것을 확인할 수 있습니다.

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

!!! tip "팁"

    Rocky Linux 8 서버에서 작업을 수행하며 SSH 프로토콜을 사용하여 데모를 진행합니다.

SSH 프로토콜의 비밀번호 없는 인증 로그인은 여기서 설명하지 않는 [rsync 비밀번호 없는 인증 로그인](05_rsync_authentication-free_login.md)을 참조하십시오. 아래는 bash 스크립트 내용 예시입니다. 필요에 따라 명령어 뒤에 다른 옵션을 추가하여 필요한 요구 사항을 충족시킬 수 있습니다. 예를 들어 `rsync` 명령어 뒤에 `--delete`를 추가할 수도 있습니다.

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

!!! tip "팁"

    데이터 동기화 전송에 SSH 프로토콜을 사용하는 경우 대상 컴퓨터의 SSH 서비스 포트가 22가 아닌 경우에는 다음과 유사한 방법을 사용할 수 있습니다.——
    `b="/usr/bin/rsync -avz -e 'ssh -p [port-number]' /rsync/* testfedora@192.168.100.5:/home/testfedora/"`

!!! tip "팁"

    If you want to start this script at boot
    `[root@Rocky ~]# echo "bash /root/rsync_inotify.sh &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

rsync 프로토콜을 사용하여 동기화하는 경우 대상 컴퓨터의 rsync 서비스를 구성해야 합니다. 자세한 내용은 [rsync 데모 02](03_rsync_demo02.md), [rsync 구성 파일](04_rsync_configure.md), [rsync 무료 비밀 인증 로그인](05_rsync_authentication-free_login.md)을 참조하십시오.
