---
title: rsync password-free authentication login
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2026-11-17
---

## Foreword

As explained in the [Rsync Overview](./01_rsync_overview.md) document, Rsync is a tool for incremental backups. Each time the `rsync` command runs, it synchronizes the data. To enable real-time data synchronization, you need to use it in conjunction with the `inotify-tools` program, and enable password-free authentication login (as the author describes here).

!!! tip "Friendly Reminder"

    Regardless of whether it is RSYNC protocol or SSH protocol, both can achieve password-free authentication login.

### SSH protocol password-free authentication login

The explanation is as follows:

| OS | IPv4 address | Role |
| :---: | :---: | :---: |
| Rocky Linux 8.10 | 192.168.100.20/24 | Rsync server (Synchronization source) |
| Rocky Linux 10.3 | 192.168.100.21/24 | Client (Initiator) |

The operation steps are as follows:

* Generate a key pair in the client, where the private key file is **id_rsa** and the public key file is **id_rsa.pub**. The client needs to keep the private key file safe.
* Upload the generated public key file to the Rsync server. The path location and name should be `~/.ssh/authorized_keys`, `~` represents the home directory (primary directory) of the corresponding user.

Assuming that the root (UID=0) user of the Rsync server needs to complete password-free authentication login:

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

Try SSH protocol for password-free login on the client:

```bash
[root@RL10.3 ~]# ssh -p 22 -i /root/.ssh/id_rsa root@192.168.100.20
```

Notes:

* The server configuration file **/etc/ssh/sshd_config** should be opened `PubkeyAuthentication yes`.
* The above operations are applicable to the root (UID=0) user. For regular users (UID>=1000), their home directory (primary directory) may not have the **.ssh** directory, and it needs to be created manually.

### RSYNC protocol password-free authentication login

In the client, the system variable `RSYNC_PASSWORD` of the Rsync service can be assigned a value. By default, the value of this system variable is empty:

```bash
[root@RL10.3 ~]# echo "$RSYNC_PASSWORD"

[root@RL10.3 ~]# 
```

In the Rsync server, the password for the virtual user "li" is **246810**. This password needs to be assigned to the `RSYNC_PASSWORD` system variable, and this system variable should also be declared as global.

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

Attempted download operation:

```bash
[root@RL10.3 ~]# export RSYNC_PASSWORD=246810
[root@RL10.3 ~]# rsync -avz li@192.168.100.20::share /root/
receiving incremental file list
./

sent 30 bytes  received 154 bytes  368.00 bytes/sec
total size is 24  speedup is 0.13
```

Because there are no new files appearing in the **/rsync/** directory on the Rsync server, the list of transferred files is not displayed.

!!! note "Note"

    You can write the declaration and assignment of the variable into the `/etc/profile` file to make the system variable effective permanently. The text content to be written is `export RSYNC_PASSWORD=246810`.
