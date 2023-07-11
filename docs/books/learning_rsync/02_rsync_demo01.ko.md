---
title: rsync 데모 01
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# 서문

`rsync`는 데이터 동기화 전에 사용자 인증을 수행해야 합니다. **인증에는 두 가지 프로토콜 방법이 있습니다: SSH 프로토콜과 rsync 프로토콜(rsync 프로토콜의 기본 포트는 873입니다)**

* SSH 프로토콜 확인 로그인 방법: 사용자 신원 인증을 위해 SSH 프로토콜을 기반으로 사용합니다 (즉, GNU/Linux 자체의 시스템 사용자와 비밀번호를 사용하여 인증), 그런 다음 데이터 동기화를 수행합니다.
* rsync 프로토콜 확인 로그인 방법: 사용자 신원 인증을 위해 rsync 프로토콜을 사용합니다 (GNU/Linux 시스템 사용자가 아닌 사용자, vsftpd 가상 사용자와 유사), 그런 다음 데이터 동기화를 수행합니다.

rsync 동기화의 구체적인 설명 이전에 `rsync` 명령을 사용해야 합니다. Rocky Linux 8에서는 rsync rpm 패키지가 기본적으로 설치되며, 버전은 다음과 같습니다:

```bash
[root@Rocky ~]# rpm -qa|grep rsync
rsync-3.1.3-12.el8.x86_64
```

```txt
기본 형식: rsync [options] 원래 위치 대상 위치
자주 사용되는 옵션:
-a: 아카이브 모드, 재귀적이며 -rlptgoD(-H, -A, -X 제외)와 동일한 파일 객체의 속성을 보존합니다. -v: 동기화 과정에 대한 자세한 정보 표시
-z: 파일을 전송 시 압축
-H: 하드 링크 파일 유지
-A: ACL 권한 유지
-X: chattr 권한 유지
-r: 디렉터리 및 하위 디렉터리의 모든 파일을 포함하는 재귀 모드
-l: 심볼릭 링크 파일 유지
-p: 파일 속성을 유지하기 위한 권한
-t: 파일 속성을 유지하는 시간
-g: 파일 속성에 속하는 그룹 유지(슈퍼 사용자만 해당)
-o: 파일 속성의 소유자를 유지합니다(슈퍼 사용자만 해당).
```

저자의 개인적인 사용: `rsync -avz original location target location`

## 환경 설명

| 항목                    | 설명               |
| --------------------- | ---------------- |
| Rocky Linux 8(Server) | 192.168.100.4/24 |
| Fedora 34(client)     | 192.168.100.5/24 |

Fedora 34를 사용하여 업로드 및 다운로드할 수 있습니다.

```mermaid
graph LR;
RockyLinux8-->|pull/下载|Fedora34;
Fedora34-->|push/上传|RockyLinux8;
```

Rocky Linux 8을 사용하여 업로드 및 다운로드할 수도 있습니다.

```mermaid
graph LR;
RockyLinux8-->|push/upload|Fedora34;
Fedora34-->|pull/download|RockyLinux8;
```

## SSH 프로토콜 기반 데모

!!! 팁 "tip"

    여기에서 Rocky Linux 8과 Fedora 34은 모두 root 사용자로 로그인합니다. Fedora 34은 클라이언트이고 Rocky Linux 8은 서버입니다.

### pull/download

SSH 프로토콜을 기반으로 하므로, 우선 서버에서 사용자를 생성합니다.

```bash
[root@Rocky ~]# useradd testrsync
[root@Rocky ~]# passwd testrsync
```

클라이언트 측에서 pull/download를 수행하고, 서버의 파일은 /rsync/aabbcc입니다.

```bash
[root@fedora ~]# rsync -avz testrsync@192.168.100.4:/rsync/aabbcc /root
testrsync@192.168.100.4 ' s password:
receiving incremental file list
aabbcc
sent 43 bytes received 85 bytes 51.20 bytes/sec
total size is 0 speedup is 0.00
[root@fedora ~]# cd
[root@fedora ~]# ls
aabbcc
```
전송에 성공했습니다.

!!! 팁 "tip"

    서버의 SSH 포트가 기본값인 22가 아닌 경우, 비슷한 방식으로 포트를 지정할 수 있습니다.---`rsync -avz -e 'ssh -p [port]' `.

### push/upload

```bash
[root@fedora ~]# touch fedora
[root@fedora ~]# rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
rsync: mkstemp " /rsync/.anaconda-ks.cfg.KWf7JF " failed: Permission denied (13)
rsync: mkstemp " /rsync/.fedora.fL3zPC " failed: Permission denied (13)
sent 760 bytes received 211 bytes 277.43 bytes/sec
total size is 883 speedup is 0.91
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1330) [sender = 3.2.3]
```

**권한이 거부되었으므로 어떻게 처리해야 할까요?**

먼저 /rsync/ 디렉터리의 권한을 확인합니다. 명확히 "w" 권한이 없습니다. `setfacl`을 사용하여 권한을 부여할 수 있습니다.

```bash
[root@Rocky ~ ] # ls -ld /rsync/
drwxr-xr-x 2 root root 4096 November 2 15:05 /rsync/
```

```bash
[root@Rocky ~ ] # setfacl -mu:testrsync:rwx /rsync/
[root@Rocky ~ ] # getfacl /rsync/
getfacl: Removing leading ' / ' from absolute path names
# file: rsync/
# owner: root
# group: root
user::rwx
user:testrsync:rwx
group::rx
mask::rwx
other::rx
```

다시 시도하면 성공합니다!

```bash
[root@fedora ~ ] # rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
sent 760 bytes received 54 bytes 180.89 bytes/sec
total size is 883 speedup is 1.08
```
