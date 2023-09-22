---
title: rsync 演示02
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# 基于rsync协议的演示
在vsftpd中，有虚拟用户（管理员自定义的模拟用户），原因在于使用匿名用户和本地用户都不太安全。 我们知道基于SSH协议的服务器必须要保证有一个系统的用户， 当有许多的同步需求时，就可能需要创建许多的用户， 这显然不符合GNU/Linux的运维标准(用户数越多，服务器越不安全)，在rsync中，为了安全性考虑，就有了rsync协议验证登录方式。

**具体如何操作？**

在配置文件中写入对应的参数以及值就可以了。 在Rocky Linux 8中，需要手动创建 <font color=red>/etc/rsyncd.conf</font> 这个文件。

```bash
[root@Rocky ~]# touch /etc/rsyncd.conf
[root@Rocky ~]# vim /etc/rsyncd.conf
```

该文件的部分参数以及值如下，[这里](04_rsync_configure.zh.md) 有更多的参数说明。

| 项                                         | 说明                                              |
| ----------------------------------------- | ----------------------------------------------- |
| address = 192.168.100.4                   | rsync默认监听的IP地址                                  |
| port = 873                                | rsync默认监听的端口                                    |
| pid file = /var/run/rsyncd.pid            | 进程pid的文件位置                                      |
| log file = /var/log/rsyncd.log            | 日志的文件位置                                         |
| [share]                                   | 共享名称                                            |
| comment = rsync                           | 备注或者描述信息                                        |
| path = /rsync/                            | 所在的系统路径位置                                       |
| read only = yes                           | yes表示只读，no表示可读可写                                |
| dont compress = \*.gz \*.gz2 \*.zip | 哪些文件类型不对它进行压缩                                   |
| auth users = li                           | 启用虚拟用户，定义个虚拟用户叫什么。 需要自行创建                       |
| secrets file = /etc/rsyncd_users.db       | 用来指定虚拟用户的密码文件位置，必须以.db结尾。 文件的内容格式是"用户名:密码"，一行一个 |

!!! tip "提示"

    密码文件的权限必须是 <font color=red>600</font>。

写入一些文件内容到 <font color=red>/etc/rsyncd.conf</font>，且将用户名与密码写入到 /etc/rsyncd_users.db 中，权限为 600

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

你可能需要`dnf -y install rsync-daemon`，然后才能将服务启动： `systemctl start rsyncd.service`

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

## pull/下载

服务器中创建一个文件进行验证：`[root@Rocky]# touch  /rsync/rsynctest.txt`

客户端执行以下操作：

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

成功！ 基于rsync协议除了上面的写法外，您还可以这样写：`rsync://li@10.1.2.84/share`

## push/上传

```bash
[root@fedora ~]# touch /root/fedora.txt
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
rsync: [sender] read error: Connection reset by peer (104)
rsync error: error in socket IO (code 10) at io.c(784) [sender = 3.2.3]
```

提示您读取错误，和服务器的`read only = yes`有关。 更改为`no`然后重启服务`[root@Rocky ~]# systemctl restart rsyncd.service`

再次尝试，提示您权限拒绝:

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

我们这里的虚拟用户为 <font color=red>li</font>，它默认映射为 <font color=red>nobody</font> 这个系统用户， 当然您可以更改为其他的系统用户。 换句话说就是，nobody对 /rsync/ 这个目录没有w权限。 当然，我们可以使用`[root@Rocky ~]# setfacl -m u:nobody:rwx /rsync/`，再次尝试，成功。

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
sent 206 bytes received 35 bytes 96.40 bytes/sec
total size is 883 speedup is 3.66
```
