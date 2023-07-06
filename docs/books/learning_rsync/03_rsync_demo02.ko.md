---
title: rsync 데모 02
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# rsync 프로토콜 기반 데모
vsftpd에는 익명 사용자와 로컬 사용자를 사용하는 것이 안전하지 않기 때문에 가상 사용자(관리자가 사용자 지정한 가장된 사용자)가 있습니다. SSH 프로토콜을 기반으로 하는 서버는 사용자 시스템이 있는지 확인해야 합니다. 많은 동기화 요구 사항이 있는 경우 많은 사용자를 생성해야 할 수 있습니다. 이것은 분명히 GNU/Linux 운영 및 유지 관리 표준(사용자가 많을수록 안전하지 않음)을 충족하지 않습니다. rsync에는 보안상의 이유로 rsync 프로토콜 인증 로그인 방법이 있습니다.

**어떻게 해야 할까요?**

구성 파일에 해당 매개변수와 값을 작성하기만 하면 됩니다. Rocky Linux 8에서는 <font color=red>/etc/rsyncd.conf</font> 파일을 수동으로 생성해야 합니다.

```bash
[root@Rocky ~]# touch /etc/rsyncd.conf
[root@Rocky ~]# vim /etc/rsyncd.conf
```

이 파일의 일부 매개변수 및 값은 다음과 같습니다. [여기](04_rsync_configure.md)에 더 많은 매개변수 설명이 있습니다.

| 항목                                        | 설명                                                                              |
| ----------------------------------------- | ------------------------------------------------------------------------------- |
| address = 192.168.100.4                   | rsync가 기본적으로 수신 대기하는 IP 주소                                                      |
| port = 873                                | rsync 기본 청취 포트                                                                  |
| pid file = /var/run/rsyncd.pid            | 프로세스 pid의 파일 위치                                                                 |
| log file = /var/log/rsyncd.log            | 로그 파일 위치                                                                        |
| [share]                                   | 이름 공유                                                                           |
| comment = rsync                           | 비고 또는 설명 정보                                                                     |
| path = /rsync/                            | 위치한 시스템 경로 위치                                                                   |
| read only = yes                           | yes는 읽기 전용을 의미하고 no는 읽기 및 쓰기를 의미                                                |
| dont compress = \*.gz \*.gz2 \*.zip | 압축하지 않는 파일 형식                                                                   |
| auth users = li                           | 가상 사용자를 활성화하고 가상 사용자의 이름을 정의. 직접 생성해야 함                                         |
| secrets file = /etc/rsyncd_users.db       | .db로 끝나야 하는 가상 사용자의 암호 파일 위치를 지정하는 데 사용. 파일의 콘텐츠 형식은 "사용자 이름: 비밀번호"이며 한 줄에 하나씩. |

!!! 팁 "tip"

    암호 파일의 권한은 <font color=red>600</font>이어야 합니다.

일부 파일 내용을 <font color=red>/etc/rsyncd.conf</font>에 쓰고 사용자 이름과 암호를 /etc/rsyncd_users.db에 씁니다. 권한은 600입니다.

```bash
[root@Rocky ~]# cat /etc/rsyncd.conf
address = 192.168.100.4
port = 873
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
[share]
comment = rsync
path = /rsync/
read only = yes
dont compress = *.gz *.bz2 *.zip
auth users = li
secrets file = /etc/rsyncd_users.db
[root@Rocky ~]# ll /etc/rsyncd_users.db
-rw------- 1 root root 9 November 2 16:16 /etc/rsyncd_users.db
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

서비스를 시작하기 전에 `dnf -y install rsync-daemon`이 필요할 수 있습니다: `systemctl start rsyncd.service`

```bash
[root@Rocky ~]# systemctl start rsyncd.service
[root@Rocky ~]# netstat -tulnp
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      691/sshd            
tcp        0      0 192.168.100.4:873       0.0.0.0:*               LISTEN      4607/rsync          
tcp6       0      0 :::22                   :::*                    LISTEN      691/sshd            
udp        0      0 127.0.0.1:323           0.0.0.0:*                           671/chronyd         
udp6       0      0 ::1:323                 :::*                                671/chronyd  
```

## pull/download

확인할 파일을 서버에 만듭니다: `[root@Rocky]# touch /rsync/rsynctest.txt`

클라이언트는 다음을 수행합니다.

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root
Password:
receiving incremental file list
./
rsynctest.txt
sent 52 bytes received 195 bytes 7.16 bytes/sec
total size is 883 speedup is 3.57
[root@fedora ~]# ls
aabbcc anaconda-ks.cfg fedora rsynctest.txt
```

성공입니다! 위의 rsync 프로토콜 기반 작성 외에도 다음과 같이 작성할 수도 있습니다 : `rsync://li@10.1.2.84/share`

## push/upload

```bash
[root@fedora ~]# touch /root/fedora.txt
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
rsync: [sender] read error: Connection reset by peer (104)
rsync error: error in socket IO (code 10) at io.c(784) [sender = 3.2.3]
```

읽기 오류가 서버의 "read only = yes"와 관련되어 있다는 메시지가 표시됩니다. "no"로 변경하고 서비스를 다시 시작합니다. `[root@Rocky ~]# systemctl restart rsyncd.service`

다시 시도하면 권한 거부 메시지가 표시됩니다.

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
rsync: mkstemp " /.fedora.txt.hxzBIQ " (in share) failed: Permission denied (13)
sent 206 bytes received 118 bytes 92.57 bytes/sec
total size is 883 speedup is 2.73
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1330) [sender = 3.2.3]
```

여기서 가상 사용자는 <font color=red>li</font>이며 기본적으로 시스템 사용자 <font color=red>nobody</font>에 매핑됩니다. 물론 다른 시스템 사용자로 변경할 수 있습니다. 즉, 아무도 /rsync/ 디렉토리에 대한 쓰기 권한이 없습니다. 물론 `[root@Rocky ~]# setfacl -mu:nobody:rwx /rsync/` 를 사용하여 다시 시도하면 성공할 수 있습니다.

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
sent 206 bytes received 35 bytes 96.40 bytes/sec
total size is 883 speedup is 3.66
```
