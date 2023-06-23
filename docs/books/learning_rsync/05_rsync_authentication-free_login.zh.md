---
title: rsync 免密验证登录
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# 前言

由 [rsync 简述](01_rsync_overview.zh.md) 我们知道，rsync是一个增量同步的工具， 每执行一次`rsync`命令，就能实现一次数据的同步，但并不能实时的同步数据。 那怎么办呢？

搭配inotify-tools这个程序工具，可以实现单向的实时同步。 既然是实时的数据同步，前提条件是需要免密验证登录。

**不管是rsync协议，还是SSH协议，两者都能实现免密验证登录。**

## SSH协议的免密验证登录

首先在客户端生成公钥私钥对，键入命令后一直回车即可。 密钥对保存在 <font color=red>/root/.ssh/</font> 目录中。

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

然后，使用`scp`命令将公钥文件上传给服务器。 比如我将这个公钥上传给 **testrsync** 这个用户

```bash
[root@fedora ~]# scp -P 22 /root/.ssh/id_rsa.pub root@192.168.100.4:/home/testrsync/
```

```bash
[root@Rocky ~]# cat /home/testrsync/id_rsa.pub >> /home/testrsync/.ssh/authorized_keys
```

尝试下免密验证登录，成功！

```bash
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Tue Nov  2 21:42:44 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! tip "提示"

    服务器的配置文件 **/etc/ssh/sshd_config** 应该打开 <font color=red>PubkeyAuthentication yes</font>

## rsync协议免密验证登录

在客户端，rsync 服务为系统准备了一个环境变量——**RSYNC_PASSWORD**，默认是空值，如下所示：

```bash
[root@fedora ~]# echo "$RSYNC_PASSWORD"

[root@fedora ~]#
```

如果要实现免密验证登录，只需要给这个变量赋值就可以了。 所赋的值就是之前给虚拟用户 <font color=red>li</font> 设置的密码。 同时将这个变量申明为全局变量。

```bash
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

```bash
[root@fedora ~]# export RSYNC_PASSWORD=13579
```

尝试下，成功！ 这里没有新文件出现，所以传输的文件列表并没有显示出来。

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root/
receiving incremental file list
./

sent 30 bytes received 193 bytes 148.67 bytes/sec
total size is 883 speedup is 3.96
```

!!! tip "提示"

    您可以将这个变量写入到 **/etc/profile** 当中，让其永久生效。 内容为：`export RSYNC_PASSWORD=13579`
