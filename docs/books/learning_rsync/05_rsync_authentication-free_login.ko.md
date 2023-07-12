---
title: rsync 비밀번호 없는 인증 로그인
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# 서문

[rsync 간략한 설명](01_rsync_overview.md)에서 우리는 rsync가 증분 동기화 도구임을 알고 있습니다. `rsync` 명령을 실행할 때마다 데이터를 한 번 동기화할 수 있지만 데이터를 실시간으로 동기화할 수는 없습니다. 이를 어떻게 해결할까요?

inotify-tools를 사용하면 단방향 실시간 동기화를 구현할 수 있습니다. 실시간 데이터 동기화이므로 사전 조건은 비밀번호 인증 없이 로그인하는 것입니다.

**rsync 프로토콜 또는 SSH 프로토콜에 관계없이 모두 비밀번호 없는 인증 로그인을 구현할 수 있습니다.**

## SSH 프로토콜 비밀번호 없는 인증 로그인

먼저 클라이언트에서 공개 키와 개인 키 쌍을 생성하고, 명령을 입력한 후에는 Enter 키를 누른 상태로 유지합니다. 키 쌍은 <font color=red>/root/.ssh/</font> 디렉토리에 저장됩니다.

```bash
[root@fedora ~]# ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256: TDA3tWeRhQIqzTORLaqy18nKnQOFNDhoAsNqRLo1TMg root@fedora
The key's randomart image is:
+---[RSA 2048]----+
|O+. +o+o. .+. |
|BEo oo*....o. |
|*o+o..*.. ..o |
|.+..o. = o |
|o o S |
|. o |
| o +. |
|....=. |
| .o.o. |
+----[SHA256]-----+
```

그런 다음 `scp` 명령을 사용하여 공개 키 파일을 서버에 업로드합니다. 예를 들어 이 공개 키를 **testrsync** 사용자에게 업로드합니다.

```bash
[root@fedora ~]# scp -P 22 /root/.ssh/id_rsa.pub root@192.168.100.4:/home/testrsync/
```

```bash
[root@Rocky ~]# cat /home/testrsync/id_rsa.pub >> /home/testrsync/.ssh/authorized_keys
```

비밀번호 인증 없이 로그인을 시도해보면 성공합니다!

```bash
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Tue Nov 2 21:42:44 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! 팁 "tip"

    서버 구성 파일 **/etc/ssh/sshd_config**를 열어야 합니다 <font color=red>PubkeyAuthentication yes</font>

## rsync프로토콜 비밀번호 없는 인증 로그인

클라이언트 측에서 rsync 서비스는 아래와 같이 기본적으로 비어 있는 system-**RSYNC_PASSWORD**에 대한 환경 변수를 준비합니다.

```bash
[root@fedora ~]# echo "$RSYNC_PASSWORD"

[root@fedora ~]#
```

암호 없는 인증 로그인을 달성하려면 이 변수에 값을 할당하기만 하면 됩니다. 할당된 값은 가상 사용자 <font color=red>li</font>에 대해 이전에 설정한 암호입니다. 동시에 이 변수를 전역 변수로 선언합니다.

```bash
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

```bash
[root@fedora ~]# export RSYNC_PASSWORD=13579
```

시도하시면 성공입니다! 여기에 새 파일이 표시되지 않으므로 전송된 파일 목록은 표시되지 않습니다.

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root/
receiving incremental file list
./

sent 30 bytes received 193 bytes 148.67 bytes/sec
total size is 883 speedup is 3.96
```

!!! 팁 "tip"

    이 변수를 **/etc/profile**에 작성하여 영구적으로 적용할 수 있습니다. 내용은 다음과 같습니다: `export RSYNC_PASSWORD=13579`
