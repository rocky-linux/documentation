---
title: rsync demo 02
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# Demonstration based on rsync protocol
In vsftpd, there are virtual users (impersonated users customized by the administrator) because it is not safe to use anonymous users and local users. We know that a server based on the SSH protocol must ensure that there is a system of users. When there are many synchronization requirements, it may be necessary to create many users. This obviously does not meet the GNU/Linux operation and maintenance standards (the more users, the more insecure), in rsync, for security reasons, there is an rsync protocol authentication login method.

**How to do it?**

Just write the corresponding parameters and values in the configuration file. In Rocky Linux 8, you need to manually create the file <font color=red>/etc/rsyncd.conf</font>.

```bash
[root@Rocky ~]# touch /etc/rsyncd.conf
[root@Rocky ~]# vim /etc/rsyncd.conf
```

Some parameters and values of this file are as follows, [ here ](04_rsync_configure.md) has more parameter descriptions:

|Item|Description|
|---|---|
| address = 192.168.100.4 | The IP address that rsync listens on by default |
| port = 873 | rsync default listening port |
| pid file = /var/run/rsyncd.pid | File location of process pid |
| log file = /var/log/rsyncd.log | File location of the log |
| [share] | Share name |
| comment = rsync | Remarks or description information |
| path = /rsync/ | The system path location where it is located |
| read only = yes | yes means read only, no means read and write |
| do not compress = \*.gz \*.gz2 \*.zip | Which file types do not compress it |
| auth users = li | Enable virtual users and define what a virtual user is called. Need to create it yourself|
| secrets file = /etc/rsyncd_users.db | Used to specify the location of the virtual user's password file, which must end in .db. The content format of the file is "Username: Password", one per line |

!!! tip "tip"

    The permission of the password file must be <font color=red>600</font>.

Write some file content to <font color=red>/etc/rsyncd.conf</font>, and write the user name and password to /etc/rsyncd_users.db, the permission is 600

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

You may need to `dnf -y install rsync-daemon` before you can start the service: `systemctl start rsyncd.service`

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

Create a file in the server for verification: `[root@Rocky]# touch /rsync/rsynctest.txt`

The client does the following:

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

success! In addition to the above writing based on the rsync protocol, you can also write like this: `rsync://li@10.1.2.84/share`

##  push/upload

```bash
[root@fedora ~]# touch /root/fedora.txt
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
rsync: [sender] read error: Connection reset by peer (104)
rsync error: error in socket IO (code 10) at io.c(784) [sender = 3.2.3]
```

You are prompted that the reading error is related to the "read only = yes" of the server . Change it to "no" and restart the service `[root@Rocky ~]# systemctl restart rsyncd.service`

Try again, prompting you permission denied:

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

Our virtual user here is <font color=red>li</font>, which is mapped to the system user <font color=red>nobody</font> by default. Of course, you can change it to other system users. In other words, nobody does not have write permission to the /rsync/ directory. Of course, we can use `[root@Rocky ~]# setfacl -mu:nobody:rwx /rsync/` , try again, and succeed.

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
sent 206 bytes received 35 bytes 96.40 bytes/sec
total size is 883 speedup is 3.66
```
