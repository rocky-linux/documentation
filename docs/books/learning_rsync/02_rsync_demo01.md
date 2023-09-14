---
title: rsync demo 01
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# Preface

`rsync` needs to perform user authentication before data synchronization. **There are two protocol methods for authentication: SSH protocol and rsync protocol (the default port of rsync protocol is 873)**

* SSH protocol verification login method: use SSH protocol as the basis for user identity authentication (that is, use the system user and password of GNU/Linux itself for verification), and then perform data synchronization.
* rsync protocol verification login method: use rsync protocol for user identity authentication (non-GNU/Linux system users, similar to vsftpd virtual users), and then perform data synchronization.

Before the specific demonstration of rsync synchronization, you need to use the `rsync` command. In Rocky Linux 8, the rsync rpm package is installed by default, and the version is 3.1.3-12, as follows:

```bash
[root@Rocky ~]# rpm -qa|grep rsync
rsync-3.1.3-12.el8.x86_64
```

```txt
Basic format: rsync [options] original location target location
Commonly used options:
-a: archive mode, recursive and preserves the attributes of the file object, which is equivalent to -rlptgoD (without -H, -A, -X)
-v: Display detailed information about the synchronization process
-z: compress when transferring files
-H: Keep hard link files
-A: retain ACL permissions
-X: retain chattr permissions
-r: Recursive mode, including all files in the directory and subdirectories
-l: still reserved for symbolic link files
-p: Permission to retain file attributes
-t: time to retain file attributes
-g: retain the group belonging to the file attribute (only for super users)
-o: retain the owner of the file attributes (only for super users)
-D: Keep device files and other special files
```

The author's personal use: `rsync -avz original location target location`

##  Environment Description

|Item|Description|
|---|---|
| Rocky Linux 8(Server) | 192.168.100.4/24 |
| Fedora 34(client) | 192.168.100.5/24 |

You can use Fedora 34 to upload and download

```mermaid
graph LR;
RockyLinux8-->|pull/download|Fedora34;
Fedora34-->|push/upload|RockyLinux8;
```

You can also use Rocky Linux 8 to upload and download

```mermaid
graph LR;
RockyLinux8-->|push/upload|Fedora34;
Fedora34-->|pull/download|RockyLinux8;
```

##  Demonstration based on SSH protocol

!!! tip "tip"

    Here, both Rocky Linux 8 and Fedora 34 use the root user to log in. Fedora 34 is the client and Rocky Linux 8 is the server.

###  pull/download

Since it is based on the SSH protocol, we first create a user in the server:

```bash
[root@Rocky ~]# useradd testrsync
[root@Rocky ~]# passwd testrsync
```

On the client side, we pull/download it, and the file on the server is /rsync/aabbcc

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
The transfer was successful.

!!! tip "tip"

    If the server's SSH port is not the default 22, you can specify the port in a similar way---`rsync -avz -e 'ssh -p [port]' `.

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

**Prompt permission denied, how to deal with it?**

First check the permissions of the /rsync/ directory. Obviously, there is no "w" permission. We can use `setfacl` to give permission:

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

Try again, success!

```bash
[root@fedora ~ ] # rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
sent 760 bytes received 54 bytes 180.89 bytes/sec
total size is 883 speedup is 1.08
```
