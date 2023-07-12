---
title: Unison 사용
author: tianci li
contributors: Steven Spencer
update: 2021-11-06
---

# 간단한 설명

이전에 언급한 대로 일방향 동기화에는 rsync + inotify-tools가 사용됩니다. 특정 사용 시나리오에서는 양방향 동기화가 필요할 수 있으며, 이 경우 inotify-tools + unison이 필요합니다.

## 환경 준비

* Rocky Linux 8 및 Fedora 34 모두 **inotify-tools**를 위해 소스 코드를 컴파일하고 설치해야 합니다. 여기에서 자세히 다루지 않습니다.
* 두 컴퓨터 모두 비밀번호 없는 로그인 인증이 필요하며, 여기에서는 SSH 프로토콜을 사용합니다.
* [ocaml](https://github.com/ocaml/ocaml/)은 v4.12.0을 사용하고, [unison](https://github.com/bcpierce00/unison/)은 v2.51.4를 사용합니다.

환경이 준비되면 다음과 같이 확인할 수 있습니다.

```bash
[root@Rocky ~]# inotifywa
inotifywait inotifywatch
[root@Rocky ~]# ssh -p 22 testrsync@192.168.100.5
Last login: Thu Nov 4 13:13:42 2021 from 192.168.100.4
[testrsync@fedora ~]$
```

```bash
[root@fedora ~]# inotifywa
inotifywait inotifywatch
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Wed Nov 3 22:07:18 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! tip "팁"

    두 컴퓨터의 **/etc/ssh/sshd_config** 설정 파일을 열어 <font color=red>PubkeyAuthentication yes</font>로 설정해야 합니다.

## Rocky Linux 8에서 unison 설치:

Ocaml은 프로그래밍 언어로, unison의 하위 레이어에 의존합니다.

```bash
[root@Rocky ~]# wget -c https://github.com/ocaml/ocaml/archive/refs/tags/4.12.0.tar.gz
[root@Rocky ~]# tar -zvxf 4.12.0.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/ocaml-4.12.0
[root@Rocky /usr/local/src/ocaml-4.12.0]# ./configure --prefix=/usr/local/ocaml && make world opt && make install
...
[root@Rocky ~]# ls /usr/local/ocaml/
bin lib man
[root@Rocky ~]# echo PATH=$PATH:/usr/local/ocaml/bin >> /etc/profile
[root@Rocky ~]# . /etc/profile
```

```bash
[root@Rocky ~]# wget -c https://github.com/bcpierce00/unison/archive/refs/tags/v2.51.4.tar.gz
[root@Rocky ~]# tar -zvxf v2.51.4.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/unison-2.51.4/
[root@Rocky /usr/local/src/unison-2.51.4]# make UISTYLE=txt
...
[root@Rocky /usr/local/src/unison-2.51.4]# ls src/unison
src/unison
[root@Rocky /usr/local/src/unison-2.51.4] cp -p src/unison /usr/local/bin
```

## Fedora 34에서 unison 설치:

동일한 작업을 수행합니다.

```bash
[root@fedora ~]# wget -c https://github.com/ocaml/ocaml/archive/refs/tags/4.12.0.tar.gz
[root@feodora ~]# tar -zvxf 4.12.0.tar.gz -C /usr/local/src/
[root@fedora ~]# cd /usr/local/src/ocaml-4.12.0
[root@fedora /usr/local/src/ocaml-4.12.0]# ./configure --prefix=/usr/local/ocaml && make world opt && make install
...
[root@fedora ~]# ls /usr/local/ocaml/
bin lib man
[root@fedora ~]# echo PATH=$PATH:/usr/local/ocaml/bin >> /etc/profile
[root@fedora ~]#. /etc/profile
```

```bash
[root@fedora ~]# wget -c https://github.com/bcpierce00/unison/archive/refs/tags/v2.51.4.tar.gz
[root@fedora ~]# tar -zvxf v2.51.4.tar.gz -C /usr/local/src/
[root@fedora ~]# cd /usr/local/src/unison-2.51.4/
[root@fedora /usr/local/src/unison-2.51.4]# make UISTYLE=txt
...
[root@fedora /usr/local/src/unison-2.51.4]# ls src/unison
src/unison
[root@fedora /usr/local/src/unison-2.51.4]# cp -p src/unison /usr/local/bin
```


## 데모

**우리의 요구 사항은-Rocky Linux 8의 /dir1/ 디렉토리를 Fedora 34의 /dir2/ 디렉토리로 자동으로 동기화하는 것입니다. 동시에 Fedora 34의 /dir2/ 디렉토리를 Rocky Linux 8의 /dir1/ 디렉토리로 자동으로 동기화합니다.**

### Rcoky Linux 8 구성

```bash
[root@Rocky ~]# mkdir /dir1
[root@Rocky ~]# setfacl -m u:testrsync:rwx /dir1/
[root@Rocky ~]# vim /root/unison1.sh
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e create,delete,modify,move /dir1/"
b="/usr/local/bin/unison -batch /dir1/ ssh://testrsync@192.168.100.5//dir2"
$a | while read directory event file
do
    $b &>> /tmp/unison1.log
done
[root@Rocky ~]# chmod +x /root/unison1.sh
[root@Rocky ~]# bash /root/unison1.sh &
[root@Rocky ~]# jobs -l
```

### Fedora 34 구성

```bash
[root@fedora ~]# mkdir /dir2
[root@fedora ~]# setfacl -m u:testrsync:rwx /dir2/
[root@fedora ~]# vim /root/unison2.sh
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e create,delete,modify,move /dir2/"
b="/usr/local/bin/unison -batch /dir2/ ssh://testrsync@192.168.100.4//dir1"
$a | while read directory event file
do
    $b &>> /tmp/unison2.log
done
[root@fedora ~]# chmod +x /root/unison2.sh
[root@fedora ~]# bash /root/unison2.sh &
[root@fedora ~]# jobs -l
```

!!! tip "팁"

    양방향 동기화를 위해서는 두 대의 컴퓨터 모두 스크립트를 시작해야 합니다. 그렇지 않으면 오류가 발생할 수 있습니다.

!!! tip "팁"

    이 스크립트를 부팅 시 자동으로 시작하려면
    `[root@Rocky ~]# echo "bash /root/unison1.sh &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

!!! tip "팁"

    이 스크립트에 해당하는 프로세스를 중지하려면 `htop` 명령으로 찾은 다음 해당 프로세스를 **kill** 명령으로 중지할 수 있습니다.
