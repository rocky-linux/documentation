---
title: Rsync 演示
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2026-11-11
---

# 概述

在本章中，您将学习 Rsync 的基本功能演示。

Rsync 在执行数据同步前需验证用户身份。有两种协议可以完成身份验证：

- **SSH 协议** - 使用默认端口 22。该协议将使用 GNU/Linux 的现有用户和密码进行身份验证，身份验证成功后将开始数据同步。
- **RSYNC 协议** - 使用默认端口 873。此协议将使用系统管理员自定义的用户名和密码进行身份验证（非GNU/Linux 系统用户，类似于 vsftpd 虚拟用户），数据同步只有在身份验证成功后才能开始。

## `rsync` 命令的选项说明

此命令的用法是 `rsync [options] SOURCE_LOCATION TARGET_LOCATION`。

常用选项：

- `-a` - 归档模式，会递归处理并保留文件对象的属性，相当于 -rlptgoD（无 -H、-A、-X）
- `-v` - 显示同步过程的详细信息
- `-z` - 传输文件时进行压缩处理
- `-H` - 保留硬链接文件
- `-A` - 保留 ACL 权限
- `-X` - 保留 chattr 权限
- `-r` - 递归模式，包括目录和子目录中的所有文件
- `-l` - 对符号链接文件依然保留
- `-p` - 保留文件属性的权限
- `-t` - 保留文件属性的时间
- `-g` - 保留属于文件属性的组（仅限超级用户）
- `-o` - 保留文件属性的所有者（仅限超级用户）
- `-D` - 保留设备文件和其他特殊文件

例如：

```bash
rsync -avz rusr1@192.168.100.20:/rsync/file1.md /var/source-data/
```

## 环境说明

|   操作系统  |      IPv4 地址      |
| :-----: | :---------------: |
| RL 8.10 | 192.168.100.20/24 |
| RL 10.2 | 192.168.100.21/24 |

您可以使用 Rocky Linux 8.10 进行上传和下载：

```mermaid
graph LR;
A(Rocky Linux 8.10) --> | Push/Upload | B(Rocky Linux 10.2) --> | Pull/Download | A
```

您也可以使用 Rocky Linux 10.2 进行上传和下载：

```mermaid
graph LR;
A(Rocky Linux 10.2) --> | Push/Upload | B(Rocky Linux 8.10) --> | Pull/Download | A
```

## 基于 SSH 协议的演示

在此，Rocky Linux 8.10 和 Rocky Linux 10.2 均使用 root（UID=0）进行登录，其中 Rocky Linux 8.10 作为服务器（同步源），Rocky Linux 10.2 作为客户端（发起方）。

### 拉取/下载

首先，在服务器（同步源）上创建一个系统用户，并创建需要同步的目录和文件：

```bash
[root@RL8.10 ~]# useradd ruser1

[root@RL8.10 ~]# passwd ruser1

[root@RL8.10 ~]# mkdir -p /rsync/

[root@RL8.10 ~]# echo "Hello!" > /rsync/first1
```

然后从客户端（发起方）下载 /rsync/first1：

```bash
[root@RL10.2 ~]# rsync -avz rusr1@192.168.100.20:/rsync/first1 /root/
ruser1@192.168.100.20's password:
receiving incremental file list
first1

sent 43 bytes  received 96 bytes  21.38 bytes/sec
total size is 7  speedup is 0.05

[root@RL10.2 ~]# ls -l /root/first1
-rw-r--r-- 1 root root 7 Nov  1 20:58 /root/first1
```

!!! tip "友情提示"

    如果服务器（同步源）的 SSH 端口不是默认的 22，您也可以在客户端（发起方）中使用 `rsync -avz -e 'ssh -p [port]' ...` 来指定特定的 SSH 端口。

### 推送/上传

```bash
[root@RL10.2 ~]# echo "RL10.3" > /root/appfile

[root@RL10.2 ~]# rsync -avz /root/appfile ruser1@192.168.100.20:/rsync/
ruser1@192.168.100.20's password:
sending incremental file list
appfile
rsync: mkstemp "/rsync/.appfile.JTwGeJ" failed: Permission denied (13)

sent 107 bytes  received 110 bytes  48.22 bytes/sec
total size is 7  speedup is 0.03
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1394) [sender=3.5.0-g5c0688d4]
```

从输出文本信息可以看出，这是由权限问题引起的错误。

前往服务器（同步源）查看 **/rsync/** 目录的信息：

```bash
[root@RL8.10 ~]# ls -ld /rsync/
drwxr-xr-x 2 root root 4096 Nov  1 20:58 /rsync/
```

该目录的权限为 755，所有者和组均为 root（UID=0，GID=0）。 ruser1 用户对此目录没有 "w" 权限，因此会出现错误。

使用 ACL 权限可以解决这个问题：

```bash
[root@RL8.10 ~]# setfacl -m u:ruser1:rwx /rsync/

[root@RL8.10 ~]# getfacl /rsync/
getfacl: Removing leading '/' from absolute path names
# file: rsync/
# owner: root
# group: root
user::rwx
user:ruser1:rwx
group::r-x
mask::rwx
other::r-x
```

在客户端（发起方）重试，成功！

```bash
[root@RL10.2 ~]# rsync -avz /root/appfile ruser1@192.168.100.20:/rsync/
ruser1@192.168.100.20's password:
sending incremental file list
appfile

sent 107 bytes  received 35 bytes  31.56 bytes/sec
total size is 7  speedup is 0.05
```

## 基于 RSYNC 协议的演示

如前所述，基于 SSH 协议的身份验证需要使用操作系统中现有的用户和密码。但在实际生产环境中，如果存在大量同步需求，则需要创建多个操作系统用户，这可能导致：

- 难以维护
- 高安全风险
- 不符合安全规定

在 Rsync 中，出于安全性和其他综合考虑，引入了一种基于 RSYNC 协议的身份验证机制。

首先，您需要在服务器（同步源）中手动创建文件 **/etc/rsyncd.conf**，并将一些必要的参数和值写入该文件。

!!! Note "说明"

    在 RL 8.10 中，软件包 "rsync-daemon" 可以在安装后释放此文件。

常用参数项的说明如下：

| 项                                   | 说明                                                   |
| ----------------------------------- | ---------------------------------------------------- |
| address = 192.168.100.20            | rsync 默认监听的 IP 地址                                    |
| port = 873                          | rsync 默认监听端口                                         |
| pid file = /var/run/rsyncd.pid      | 进程 PID 的文件位置                                         |
| log file = /var/log/rsyncd.log      | 日志文件的位置                                              |
| [share]                             | 共享名称                                                 |
| comment = rsync                     | 备注或说明信息                                              |
| path = /rsync/                      | 指定目录路径                                               |
| read only = yes                     | yes 表示只读，no 表示可读可写                                   |
| dont compress = \*.gz \*.gz2 \*.zip | 哪些文件类型不会对其进行压缩                                       |
| auth users = li                     | 启用一个或多个虚拟用户，用英语逗号分隔                                  |
| secrets file = /etc/rsyncd_users.db | 用于指定虚拟用户密码文件的位置，该文件必须以 .db 结尾。文件的内容格式为 "用户名:密码"，每行一个 |

!!! tip "提示"

    密码文件的权限必须为 **600**。

操作步骤如下：

```bash
[root@RL8.10 ~]# vim /etc/rsyncd.conf
address = 192.168.100.20
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

[root@RL8.10 ~]# vim /etc/rsyncd_users.db
li:246810

[root@RL8.10 ~]# chmod 600 /etc/rsyncd_users.db

[root@RL8.10 ~]# ls -l /etc/rsyncd_users.db
-rw------- 1 root root 10 Nov  1 21:43 /etc/rsyncd_users.db

[root@RL8.10 ~]# dnf -y install rsync-daemon

[root@RL8.10 ~]# systemctl start rsyncd.service

[root@RL8.10 ~]# ss -tulnp
Netid   State    Recv-Q   Send-Q                         Local Address:Port      Peer Address:Port   Process
udp     UNCONN   0        0                                  127.0.0.1:323            0.0.0.0:*       users:(("chronyd",pid=772,fd=5))
udp     UNCONN   0        0                                      [::1]:323               [::]:*       users:(("chronyd",pid=772,fd=6))
udp     UNCONN   0        0          [fe80::20c:29ff:feb3:41fd]%ens160:546               [::]:*       users:(("NetworkManager",pid=766,fd=24))
tcp     LISTEN   0        128                                  0.0.0.0:22             0.0.0.0:*       users:(("sshd",pid=789,fd=3))
tcp     LISTEN   0        5                             192.168.100.20:873            0.0.0.0:*       users:(("rsync",pid=17993,fd=3))
tcp     LISTEN   0        128                                     [::]:22                [::]:*       users:(("sshd",pid=789,fd=4))
```

### 拉取/下载

在服务器（同步源）上创建一个新文件：

```bash
[root@RL8.10 ~]# echo "World" > /rsync/rsync-p.txt 
```

在客户端（发起方）上执行下载操作：

```bash
[root@RL10.2 ~]# rsync -avz li@192.168.100.20::share /root/
Password:
receiving incremental file list
./
rsync-p.txt

sent 49 bytes  received 169 bytes  87.20 bytes/sec
total size is 20  speedup is 0.09
```

!!! tip "友情提示"

    除了 `li@192.168.100.20::share` 这种格式外，`rsync://li@192.168.100.20/share` 这种格式也是允许且被接受的。

### 推送/上传

```bash
[root@RL10.2 ~]# echo "369" > /root/new.md

[root@RL10.2 ~]# rsync -avz /root/new.md rsync://li@192.168.100.20/share
Password:
sending incremental file list
rsync: [sender] read error: Connection reset by peer (104)
rsync error: error in socket IO (code 10) at io.c(907) [sender=3.5.0-g5c0688d4]
```

文本输出显示读取错误，该问题与服务器（同步源）中的配置项 `read only = yes` 相关。将其更改为 `no` 并重新启动服务：

```bash
[root@RL8.10 ~]# sed -i '/read/s/yes/no/g' /etc/rsyncd.conf

[root@RL8.10 ~]# systemctl restart rsyncd.service
```

在客户端（发起方）重新尝试：

```bash
[root@RL10.2 ~]# rsync -avz /root/new.md rsync://li@192.168.100.20/share
Password:
sending incremental file list
new.md
rsync: mkstemp "/.new.md.VBIFFk" (in share) failed: Permission denied (13)

sent 103 bytes  received 114 bytes  62.00 bytes/sec
total size is 4  speedup is 0.02
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1394) [sender=3.5.0-g5c0688d4]
```

输出文本表明权限存在问题。**注意！ RSYNC 协议中的虚拟用户（自定义虚拟用户）默认会映射到操作系统的 `nobody` 用户。**

同样地，使用 ACL 权限来解决此问题：

```bash
[root@RL8.10 ~]# setfacl -m u:nobody:rwx /rsync/

[root@RL8.10 ~]# getfacl /rsync/
getfacl: Removing leading '/' from absolute path names
# file: rsync/
# owner: root
# group: root
user::rwx
user:ruser1:rwx
user:nobody:rwx
group::r-x
mask::rwx
other::r-x
```

客户端（发起方）执行上传操作，成功！

```bash
[root@RL10.2 ~]# rsync -avz /root/new.md rsync://li@192.168.100.20/share
Password:
sending incremental file list
new.md

sent 103 bytes  received 35 bytes  39.43 bytes/sec
total size is 4  speedup is 0.03
```