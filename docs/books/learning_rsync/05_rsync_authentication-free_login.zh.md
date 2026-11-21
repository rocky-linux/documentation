---
title: rsync 免密验证登录
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2026-11-17
---

## Foreword

如 [Rsync 概述](./01_rsync_overview.md) 文档所述，Rsync 是一款用于增量备份的工具。每次执行 `rsync` 命令时，它都会同步数据。若要实现实时数据同步，需配合 `inotify-tools` 程序使用，并启用免密认证登录（如作者此处所述）。

!!! tip "友情提示"

    无论是 RSYNC 协议还是 SSH 协议，两者都能实现免密认证登录。

### SSH 协议免密认证登陆

说明如下：

|       操作系统       |      IPv4 地址      |       角色       |
|:----------------:|:-----------------:|:--------------:|
| Rocky Linux 8.10 | 192.168.100.20/24 | Rsync 服务器（同步源） |
| Rocky Linux 10.3 | 192.168.100.21/24 |    客户端（发起方）    |

操作步骤如下：

* 在客户端中生成一个密钥对，其中私钥文件是 **id_rsa**，公钥文件是 **id_rsa.pub**。客户端需要妥善保管私钥文件。
* 将生成的公钥文件上传到 Rsync 服务器。路径位置和名称应为 `~/.ssh/authorized_keys`，`~` 表示相关用户的家目录（主目录）。

假设 Rsync 服务器的 root（UID=0）用户需要完成免密认证登录：

```bash
[root@RL10.3 ~]# ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase for "/root/.ssh/id_rsa" (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:V/N5q7DBIqIbBkrlWS9SWRTO5vaisJsDbWUMaWffupk root@HOST100
The key's randomart image is:
+---[RSA 2048]----+
|    . .+.        |
|   + o=          |
|  ..=+.+.   o    |
|  o +++. . . o . |
| o.+o. +S .   o .|
|o..o. o....    ..|
|. o+ . o+o +   . |
|  ..* oEo . + .  |
|   *+.     . .   |
+----[SHA256]-----+

[root@RL10.3 ~]# ls -l /root/.ssh/id*
-rw------- 1 root root 1823 Nov  4 19:08 /root/.ssh/id_rsa
-rw-r--r-- 1 root root  394 Nov  4 19:08 /root/.ssh/id_rsa.pub

[root@RL10.3 ~]# scp -P 22 /root/.ssh/id_rsa.pub root@192.168.100.20:/tmp/

[root@RL8.10 ~]# cat /tmp/id_rsa.pub > /root/.ssh/authorized_keys

[root@RL8.10 ~]# sed -i '/PasswordAuthentication/s/yes/no/g' /etc/ssh/sshd_config

[root@RL8.10 ~]# sed -i '/PubkeyAuthentication/s/^# //g' /etc/ssh/sshd_config

[root@RL8.10 ~]# grep -E "^Password|Pubkey" /etc/ssh/sshd_config
PubkeyAuthentication yes
PasswordAuthentication no

[root@RL8.10 ~]# systemctl restart sshd.service
```

在客户端尝试 SSH 协议进行免密登录：

```bash
[root@RL10.3 ~]# ssh -p 22 -i /root/.ssh/id_rsa root@192.168.100.20
```

说明：

* 服务器配置文件 **/etc/ssh/sshd_config** 应打开 `PubkeyAuthentication yes`。
* 上述操作适用于 root（UID=0）用户。对于普通用户（UID>=1000），他们的家目录（主目录）可能没有 **.ssh** 目录，需要手动创建该目录。

### RSYNC 协议免密认证登录

在客户端中，可以为 Rsync 服务的系统变量 `RSYNC_PASSWORD` 分配一个值。默认情况下，此系统变量的值为空：

```bash
[root@RL10.3 ~]# echo "$RSYNC_PASSWORD"

[root@RL10.3 ~]# 
```

在 Rsync 服务器中，虚拟用户 "li" 的密码是 **246810**。此密码需要分配给 `RSYNC_PASSWORD` 系统变量，并且此系统变量也应声明为全局变量。

```bash
[root@RL8.10 ~]# cat /etc/rsyncd_users.db
li:246810

[root@RL8.10 ~]# cat /etc/rsyncd.conf
address = 192.168.100.20
port = 873
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log

[share]
comment = rsync
path = /rsync/
read only = no
dont compress = *.gz *.bz2 *.zip
auth users = li
secrets file = /etc/rsyncd_users.db

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

[root@RL8.10 ~]# systemctl status rsyncd.service
```

尝试下载操作：

```bash
[root@RL10.3 ~]# export RSYNC_PASSWORD=246810
[root@RL10.3 ~]# rsync -avz li@192.168.100.20::share /root/
receiving incremental file list
./

sent 30 bytes  received 154 bytes  368.00 bytes/sec
total size is 24  speedup is 0.13
```

由于 Rsync 服务器上的 **/rsync/** 目录中没有出现新文件，因此未显示已传输的文件列表。

!!! Note "说明"

    您可以将变量的声明和赋值写入 `/etc/profile` 文件，使系统变量永久有效。写入的文本内容是 `export RSYNC_PASSWORD=246810`。
