---
title: Rsync demo
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2026-11-11
---

# Overview

In this chapter, you will learn the basic functionality demonstration of Rsync.

Rsync needs to verify the user's identity before performing data synchronization. There are two protocols that can complete identity verification:

* **SSH protocol** - Using default port 22. This protocol will use the existing user and password of GNU/Linux for authentication, and data synchronization will begin after successful authentication.
* **RSYNC protocol** - Using default port 873. This protocol will use the username and password customized by the system administrator for authentication (non-GNU/Linux system users, similar to vsftpd virtual users), and data synchronization will only begin after successful authentication.

## Description of options for `rsync` command

The usage of this command is `rsync [options] SOURCE_LOCATION TARGET_LOCATION`.

Commonly used options:

* `-a` - Archive mode, recursive and preserves the attributes of the file object, which is equivalent to -rlptgoD (without -H, -A, -X)
* `-v` - Display detailed information about the synchronization process
* `-z` - Compress when transferring files
* `-H` - Keep hard link files
* `-A` - Retain ACL permissions
* `-X` - Retain chattr permissions
* `-r` - Recursive mode, including all files in the directory and subdirectories
* `-l` - Still reserved for symbolic link files
* `-p` - Permission to retain file attributes
* `-t` - Time to retain file attributes
* `-g` - Retain the group belonging to the file attribute (only for super users)
* `-o` - Retain the owner of the file attributes (only for super users)
* `-D` - Keep device files and other special files

For example:

```bash
rsync -avz rusr1@192.168.100.20:/rsync/file1.md /var/source-data/
```

## Environment Description

| OS | IPv4 address |
| :---: | :---: |
| RL 8.10 | 192.168.100.20/24 |
| RL 10.2 | 192.168.100.21/24 |

You can use Rocky Linux 8.10 for uploading and downloading:

```mermaid
graph LR;
A(Rocky Linux 8.10) --> | Push/Upload | B(Rocky Linux 10.2) --> | Pull/Download | A
```

You can also use Rocky Linux 10.2 to uploading and downloading:

```mermaid
graph LR;
A(Rocky Linux 10.2) --> | Push/Upload | B(Rocky Linux 8.10) --> | Pull/Download | A
```

## Demonstration based on SSH protocol

Here, both Rocky Linux 8.10 and Rocky Linux 10.2 use root (UID=0) for login, where Rocky Linux 8.10 is the server (synchronous source) and Rocky Linux 10.2 is the client (initiator).

### Pull/Download

Firstly, create a system user on the server (synchronization source) and create the directories and files that need to be synchronized:

```bash
[root@RL8.10 ~]# useradd ruser1

[root@RL8.10 ~]# passwd ruser1

[root@RL8.10 ~]# mkdir -p /rsync/

[root@RL8.10 ~]# echo "Hello!" > /rsync/first1
```

Then download /rsync/first1 from the client (initiator):

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

!!! tip "Friendly Reminder"

    If the SSH port of the server (synchronization source) is not the default 22, you can also specify a specific SSH port in the client (initiator) by using `rsync -avz -e 'ssh -p [port]' ...`.

### Push/Upload

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

From the output text information, it can be inferred that this is an error caused by permission issues.

Go to the server (synchronization source) to view the information of the **/rsync/** directory:

```bash
[root@RL8.10 ~]# ls -ld /rsync/
drwxr-xr-x 2 root root 4096 Nov  1 20:58 /rsync/
```

The permission for this directory is 755, and both the owner and the group are root (UID=0,GID=0). The ruser1 user does not have "w" permission for this directory, so errors will occur.

Using ACL permissions can solve the problem:

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

Attempt again in the client (initiator), successful!

```bash
[root@RL10.2 ~]# rsync -avz /root/appfile ruser1@192.168.100.20:/rsync/
ruser1@192.168.100.20's password:
sending incremental file list
appfile

sent 107 bytes  received 35 bytes  31.56 bytes/sec
total size is 7  speedup is 0.05
```

## Demonstration based on RSYNC protocol

As mentioned earlier, SSH protocol based authentication requires the use of existing users and passwords in the operating system. But in actual production environments, if there are many synchronization requirements, it is necessary to create many operating system users, which can lead to:

* Difficult to maintain
* High security risk
* Not in compliance with safety regulations

In Rsync, for the sake of security and other comprehensive considerations, an identity verification mechanism based on the RSYNC protocol is introduced.

Firstly, you need to manually create the file **/etc/rsyncd.conf** in the server (synchronous source), and write some necessary parameters and values into the file.

!!! Note "Note"

    In RL 8.10, the software package "rsync-daemon" can release this file after installation.

The description of common parameter items is as follows:

| Item | Description |
| ---  | --- |
| address = 192.168.100.20 | The IP address that rsync listens on by default |
| port = 873 | rsync default listening port |
| pid file = /var/run/rsyncd.pid | File location of process pid |
| log file = /var/log/rsyncd.log | File location of the log |
| [share] | Share name |
| comment = rsync | Remarks or description information |
| path = /rsync/ | Specify the path of the directory |
| read only = yes | yes means read only, no means read and write |
| dont compress = \*.gz \*.gz2 \*.zip | Which file types do not compress it |
| auth users = li | Enable one or more virtual users, separated by commas in English |
| secrets file = /etc/rsyncd_users.db | Used to specify the location of the virtual user's password file, which must end in .db. The content format of the file is "Username:Password", one per line |

!!! tip "tip"

    The permission of the password file must be **600**.

The operation steps are as follows:

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

### Pull/Download

Create a new file on the server (synchronization source):

```bash
[root@RL8.10 ~]# echo "World" > /rsync/rsync-p.txt 
```

Perform download operation in the client (initiator):

```bash
[root@RL10.2 ~]# rsync -avz li@192.168.100.20::share /root/
Password:
receiving incremental file list
./
rsync-p.txt

sent 49 bytes  received 169 bytes  87.20 bytes/sec
total size is 20  speedup is 0.09
```

!!! tip "Friendly Reminder"

    In addition to the format `li@192.168.100.20::share`, the format `rsync://li@192.168.100.20/share` is also permitted and accepted.

### Push/Upload

```bash
[root@RL10.2 ~]# echo "369" > /root/new.md

[root@RL10.2 ~]# rsync -avz /root/new.md rsync://li@192.168.100.20/share
Password:
sending incremental file list
rsync: [sender] read error: Connection reset by peer (104)
rsync error: error in socket IO (code 10) at io.c(907) [sender=3.5.0-g5c0688d4]
```

The text output indicates a read error, which is related to the configuration item `read only = yes` in the server (synchronization source). Change it to `no` and restart the service:

```bash
[root@RL8.10 ~]# sed -i '/read/s/yes/no/g' /etc/rsyncd.conf

[root@RL8.10 ~]# systemctl restart rsyncd.service
```

Try again in the client (initiator):

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

Output text indicates that there is a problem with the permission. **Attention! The virtual users (custom virtual users) in the RSYNC protocol are mapped to the `nobody` user of the operating system by default.**

Similarly, using ACL permissions to address this issue:

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

Client (initiator) performs upload operation, successful!

```bash
[root@RL10.2 ~]# rsync -avz /root/new.md rsync://li@192.168.100.20/share
Password:
sending incremental file list
new.md

sent 103 bytes  received 35 bytes  39.43 bytes/sec
total size is 4  speedup is 0.03
```