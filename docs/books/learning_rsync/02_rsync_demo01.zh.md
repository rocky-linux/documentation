---
title: rsync 演示01
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# 前言

`rsync` 在进行数据同步之前需要先进行用户身份验证， **有两种协议方式进行身份验证：SSH协议与rsync协议(rsync协议的默认端口为873)**

* SSH协议验证登录方式：使用SSH协议作为基础进行用户身份认证(也就是拿GNU/Linux本身的系统用户和密码做验证)，然后进行数据同步。
* rsync协议验证登录方式：使用rsync协议进行用户身份认证(非GNU/Linux本身的系统用户，类似于vsftpd虚拟用户)，然后进行数据同步。

在具体演示rsync同步之前，您需要使用`rsync`命令。 在Rocky Linux 8中，默认安装了rsync rpm软件包，版本为3.1.3-12，如下所示:

```bash
[root@Rocky ~]# rpm -qa|grep rsync
rsync-3.1.3-12.el8.x86_64
```

```txt
基本格式：rsync  [选项]  原始位置  目标位置
常用的选项：
-a  ：归档模式，递归且保留文件对象的属性，等同于-rlptgoD（没有-H、-A、-X）
-v  ：显示同步过程的详细信息
-z  ：在传输文件时进行压缩
-H  ：保留硬链接文件
-A  ：保留ACL权限
-X  ：保留chattr权限
-r  ：递归模式，包含目录以及子目录中所有的文件
-l  ：对于符号链接文件仍然保留
-p  ：保留文件属性的权限
-t  ：保留文件属性的时间
-g  ：保留文件属性的所属组（仅限超级用户使用）
-o  ：保留文件属性的所有者（仅限超级用户使用）
-D  ：保留设备文件以及其他特殊文件
```

作者个人常用：`rsync -avz  原始位置  目标位置`

## 环境说明

| 项                     | 说明               |
| --------------------- | ---------------- |
| Rocky Linux 8(Server) | 192.168.100.4/24 |
| Fedora 34(client)     | 192.168.100.5/24 |

您可以使用 Fedora 34 进行上传与下载

```mermaid
graph LR;
RockyLinux8-->|pull/下载|Fedora34;
Fedora34-->|push/上传|RockyLinux8;
```

您也可以使用 Rocky Linux 8 进行上传与下载

```mermaid
graph LR;
RockyLinux8-->|push/上传|Fedora34;
Fedora34-->|pull/下载|RockyLinux8;
```

## 基于SSH协议的演示

!!! tip "提示"

    在这里，Rocky Linux 8 和 Fedora 34 都使用root用户登录。 Fedora 34是客户端，Rocky Linux 8是服务器。

### pull/下载

既然是基于SSH协议，我们首先在服务器中创建一个用户：

```bash
[root@Rocky ~]# useradd testrsync
[root@Rocky ~]# passwd testrsync
```

在客户端这边，我们pull/下载过来，服务器的这个文件为/rsync/aabbcc

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

传输成功。

!!! tip "提示"

    如果服务器的SSH端口不是默认的22，您可以使用类似这样的方式指定端口——`rsync -avz -e 'ssh -p [port]'`。

### push/上传

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

**提示权限拒绝，如何处理？**

首先查看 /rsync/ 这个目录的权限。 很明显没有w权限， 我们可以使用`setfacl`赋予权限:

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

再次尝试，成功!

```bash
[root@fedora ~ ] # rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
sent 760 bytes received 54 bytes 180.89 bytes/sec
total size is 883 speedup is 1.08
```
