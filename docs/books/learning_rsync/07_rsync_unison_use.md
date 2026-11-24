---
title: Use unison
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2026-11-23
---

# Brief

As we mentioned earlier, one-way synchronization uses Rsync + inotify-tools. In some special usage scenarios, two-way synchronization may be required, which requires inotify-tools + Unison.

* **inotify-tools** - A file system monitoring program
* **Unison** - A file synchronization tool

## Preparing the environment

* Both RL 8.10 and RL 10.3 require the installation of Unison and inotify-tools.
* Two machines completed bidirectional password-free authentication login using SSH protocol.
* [Unison](https://github.com/bcpierce00/unison/) relies on [OCaml](https://github.com/ocaml/ocaml/) compiled language at the bottom layer.

!!! tip "Friendly Reminder"

    Unison and OCaml here are compiled and installed from source code, and the specific steps will be explained later. In terms of version selection, OCaml recommends using version 4.14.2, while Unison recommends using version 2.54.0.

Environment verification for RL 8.10:

```bash
[root@RL8.10 ~]# dnf info inotify-tools
Last metadata expiration check: 0:26:11 ago on Sun 08 Nov 2026 08:14:20 PM CST.
Installed Packages
Name         : inotify-tools
Version      : 3.14
Release      : 19.el8
Architecture : x86_64
Size         : 120 k
Source       : inotify-tools-3.14-19.el8.src.rpm
Repository   : @System
From repo    : epel
Summary      : Command line utilities for inotify
URL          : http://inotify-tools.sourceforge.net/
License      : GPLv2
Description  : inotify-tools is a set of command-line programs for Linux providing
             : a simple interface to inotify. These programs can be used to monitor
             : and act upon filesystem events.

[root@RL8.10 ~]# ssh -p 22 -i /root/.ssh/id_rsa riu@192.168.100.21
Last login: Sun Nov  8 20:58:13 2026
```

Environment verification for RL 10.3:

```bash
[root@RL10.3 ~]# dnf5 info inotify-tools
Updating and loading repositories:
Repositories loaded.
Installed packages
Name            : inotify-tools
Epoch           : 0
Version         : 4.23.9.0
Release         : 4.el10_1
Architecture    : x86_64
Installed size  : 209.8 KiB
Source          : inotify-tools-4.23.9.0-4.el10_1.src.rpm
From repository : epel
Summary         : Command line utilities for inotify
URL             : https://github.com/inotify-tools/inotify-tools
License         : GPL-2.0-only AND GPL-2.0-only WITH Linux-syscall-note AND LGPL-2.1-or-later
Description     : inotify-tools is a set of command-line programs for Linux providing
                : a simple interface to inotify. These programs can be used to monitor
                : and act upon filesystem events.
Vendor          : Fedora Project

[root@RL10.3 ~]# ssh -p 22 -i /root/.ssh/r8_id_rsa r8riu@192.168.100.20
Last login: Sun Nov  8 21:29:10 2026
```

Notes:

* In the RL 8.10 operating system, the user "r8riu" should exist.
* In the RL 8.10 operating system, a pair of keys were generated. The public key file is named **id_rsa.pub**, and the private key file is named **id_rsa**.
* In the RL 10.3 operating system, the user "riu" should exist.
* In the RL 10.3 operating system, a pair of keys were generated. The public key file is named **r8_id_rsa.pub**, and the private key file is named **r8_id_rsa**.
* The **/etc/ssh/sshd_comfig** files of RL 8.10 and RL 10.3 should have `PubkeyAuthentication yes` enabled.

### Install Unison on RL 8.10

The installation steps for OCaml are as follows:

```bash
[root@RL8.10 ~]# wget -c https://github.com/ocaml/ocaml/archive/refs/tags/4.14.2.tar.gz

[root@RL8.10 ~]# tar -vxf 4.14.2.tar.gz -C /usr/local/src/

[root@RL8.10 ~]# cd /usr/local/src/ocaml-4.14.2/

[root@RL8.10 /usr/local/src/ocaml-4.14.2]# ./configure --prefix=/usr/local/ocaml && make world opt && make install
...

[root@RL8.10 /usr/local/src/ocaml-4.14.2]# ls -l /usr/local/ocaml/
total 16
drwxr-xr-x 2 root root 4096 Nov  9 00:04 bin
drwxr-xr-x 3 root root 4096 Nov  9 00:04 lib
drwxr-xr-x 4 root root 4096 Nov  9 00:04 man
drwxr-xr-x 3 root root 4096 Nov  9 00:04 share

[root@RL8.10 /usr/local/src/ocaml-4.14.2]# echo PATH=$PATH:/usr/local/ocaml/bin >> /etc/profile

[root@RL8.10 /usr/local/src/ocaml-4.14.2]# . /etc/profile
```

The installation steps for Unison are as follows:

```bash
[root@RL8.10 ~]# wget -c https://github.com/bcpierce00/unison/archive/refs/tags/v2.54.0.tar.gz

[root@RL8.10 ~]# tar -vxf v2.54.0.tar.gz -C /usr/local/src/

[root@RL8.10 ~]# cd /usr/local/src/unison-2.54.0/

[root@RL8.10 /usr/local/src/unison-2.54.0]# make

[root@RL8.10 /usr/local/src/unison-2.54.0]# ls src/unison
src/unison

[root@RL8.10 /usr/local/src/unison-2.54.0]# cp -p src/unison /usr/local/bin/
```

### Install Unison on RL 10.3

The installation steps for OCaml are as follows:

```bash
[root@RL10.3 ~]# wget -c https://github.com/ocaml/ocaml/archive/refs/tags/4.14.2.tar.gz

[root@RL10.3 ~]# tar -vxf 4.14.2.tar.gz -C /usr/local/src/

[root@RL10.3 ~]# cd /usr/local/src/ocaml-4.14.2/

[root@RL10.3 /usr/local/src/ocaml-4.14.2]# ./configure --prefix=/usr/local/ocaml && make world opt && make install
...

[root@RL10.3 /usr/local/src/ocaml-4.14.2]# ls -l /usr/local/ocaml/
total 16
drwxr-xr-x 2 root root 4096 Nov  9 00:14 bin
drwxr-xr-x 3 root root 4096 Nov  9 00:14 lib
drwxr-xr-x 4 root root 4096 Nov  9 00:14 man
drwxr-xr-x 3 root root 4096 Nov  9 00:14 share

[root@RL10.3 /usr/local/src/ocaml-4.14.2]# echo PATH=$PATH:/usr/local/ocaml/bin >> /etc/profile

[root@RL10.3 /usr/local/src/ocaml-4.14.2]# . /etc/profile
```

The installation steps for Unison are as follows:

```bash
[root@RL10.3 ~]# wget -c https://github.com/bcpierce00/unison/archive/refs/tags/v2.54.0.tar.gz

[root@RL10.3 ~]# tar -vxf v2.54.0.tar.gz -C /usr/local/src/

[root@RL10.3 ~]# cd /usr/local/src/unison-2.54.0/

[root@RL10.3 /usr/local/src/unison-2.54.0]# make

[root@RL10.3 /usr/local/src/unison-2.54.0]# ls src/unison
src/unison

[root@RL10.3 /usr/local/src/unison-2.54.0]# cp -p src/unison /usr/local/bin/
```

## Demonstration

**Requirement: Implement bidirectional synchronization between the /dir1/ directory of RL 8.10 and the /dir2/ directory of RL 10.3.**

Perform the following operations in RL 8.10:

```bash
[root@RL8.10 ~]# mkdir /dir1/

[root@RL8.10 ~]# setfacl -m u:r8riu:rwx /dir1/

[root@RL8.10 ~]# vim /root/sync1.sh
#!/bin/bash
inotifywait -mrq -e create,delete,modify,move /dir1/ | while read directory event file
do
    /usr/local/bin/unison -batch /dir1/ ssh://riu@192.168.100.21:22//dir2 -sshargs "-i /root/.ssh/id_rsa" &>> /tmp/sync1.log
done

[root@RL8.10 ~]# chmod +x /root/sync1.sh

[root@RL8.10 ~]# bash /root/sync1.sh &

[root@RL8.10 ~]# jobs -l
```

Perform the following operations in RL 10.3:

```bash
[root@RL10.3 ~]# mkdir /dir2/

[root@RL10.3 ~]# setfacl -m u:riu:rwx /dir2/

[root@RL10.3 ~]# vim /root/sync2.sh
#!/bin/bash
inotifywait -mrq -e create,delete,modify,move /dir2/ | while read directory event file
do
    /usr/local/bin/unison -batch /dir2/ ssh://r8riu@192.168.100.20:22//dir1 -sshargs "-i /root/.ssh/r8_id_rsa" &>> /tmp/sync2.log
done

[root@RL10.3 ~]# chmod +x /root/sync2.sh

[root@RL10.3 ~]# bash /root/sync2.sh &

[root@RL10.3 ~]# jobs -l
```

Important note:

* When synchronizing in both directions, the scripts of both servers must be started, otherwise errors may occur.
* The user permission settings for the corresponding directory should be correct.
* When using the `unison` command, be sure not to omit the leading "/" in the target directory path. For example, in the "/dir1" section of `/usr/local/bin/unison -batch /dir2/ ssh://r8riu@192.168.100.20:22//dir1 -sshargs "-i /root/.ssh/r8_id_rsa"`.
* The contents of the log file are very useful for troubleshooting errors.
* Make sure to check the status of the Bash script. If it is in the "Running" state, it is in a normal condition. However, if it is in the "Stopped" state, you need to investigate the error.
* To stop the process corresponding to the script, commands such as `kill`, `pkill`, or `killall` can be used.
* If the script needs to start automatically upon system boot, you can write the relevant content into the **/etc/rc.local** file. For example:

    ```bash
    [root@RL8.10 ~]# echo "bash /root/sync1.sh &" >> /etc/rc.local
    [root@RL8.10 ~]# chmod a+x /etc/rc.local

    [root@RL10.3 ~]# echo "bash /root/sync2.sh &" >> /etc/rc.local
    [root@RL10.3 ~]# chmod a+x /etc/rc.local   
    ```

Try the two-way synchronization:

```bash
[root@RL8.10 ~]# touch /dir1/{R8-file,R8-f2}

[root@RL10.3 ~]# touch /dir2/R10-file
```

Synchronization task completed:

```bash
[root@RL8.10 ~]# ls /dir1/
R10-file  R8-f2  R8-file

[root@RL10.3 ~]# ls /dir2/
R10-file  R8-f2  R8-file
```