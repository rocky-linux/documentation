---
title: rsync password-free authentication login
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# Foreword

From [rsync Brief Description](01_rsync_overview.md) we know that rsync is an incremental synchronization tool. Every time the `rsync` command is executed, data can be synchronized once, but data cannot be synchronized in real time. How to do it?

With inotify-tools, this program tool can realize one-way real-time synchronization. Since it is real-time data synchronization, the prerequisite is to log in without password authentication.

**Regardless of whether it is rsync protocol or SSH protocol, both can achieve password-free authentication login.**

## SSH protocol password-free authentication login

First, generate a public key and private key pair on the client, and keep pressing Enter after typing the command. The key pair is saved in the <font color=red>/root/.ssh/</font> directory.

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

Then, use the `scp` command to upload the public key file to the server. For example, I upload this public key to the user **testrsync**

```bash
[root@fedora ~]# scp -P 22 /root/.ssh/id_rsa.pub root@192.168.100.4:/home/testrsync/
```

```bash
[root@Rocky ~]# cat /home/testrsync/id_rsa.pub >> /home/testrsync/.ssh/authorized_keys
```

Try to log in without secret authentication, success!

```bash
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Tue Nov 2 21:42:44 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! tip "tip"

    The server configuration file **/etc/ssh/sshd_config** should be opened <font color=red>PubkeyAuthentication yes</font>

## rsync protocol password-free authentication login

On the client side, the rsync service prepares an environment variable for the system-**RSYNC_PASSWORD**, which is empty by default, as shown below:

```bash
[root@fedora ~]# echo "$RSYNC_PASSWORD"

[root@fedora ~]#
```

If you want to achieve password-free authentication login, you only need to assign a value to this variable. The value assigned is the password previously set for the virtual user <font color=red>li</font>. At the same time, declare this variable as a global variable.

```bash
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

```bash
[root@fedora ~]# export RSYNC_PASSWORD=13579
```

Try it, success! No new files appear here, so the list of transferred files is not displayed.

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root/
receiving incremental file list
./

sent 30 bytes received 193 bytes 148.67 bytes/sec
total size is 883 speedup is 3.96
```

!!! tip "tip"

    You can write this variable into **/etc/profile** to make it take effect permanently. The content is: `export RSYNC_PASSWORD=13579`
