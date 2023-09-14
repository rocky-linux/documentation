---
title: Rootkit Hunter
author: Steven Spencer
contributors: Ezequiel Bruni, Andrew Thiesen, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - server
  - security
  - rkhunter
---

# Rootkit hunter

## Introduction

Rootkit hunter (`rkhunter`) is a well known tool for checking vulnerabilities, rootkits, back doors, and possible local exploits on a server. It is possible to use it on _any_ server used for _any_ purpose. When tuned and automated, it can report any suspicious activity to the system administrator. This procedure outlines the installation, tuning, and use of rootkit hunter.

## Prerequisites

* Proficiency with a command-line editor (using `vi` in this example)
* A comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* An understanding of what can trigger a response to changed files on the file system (such as package updates) is helpful
* Running all commands as root or as a regular user with `sudo`

This document was originally written in conjunction with the apache hardened web server routines, but works equally well on a server running any software.

## Introduction

`rkhunter` (Root Kit Hunter) is a Unix-based tool that scans for rootkits, back doors, and possible local exploits. It is a good part of a hardened server, and will notify the administrator quickly when something suspicious happens on the server's file system, providing it is properly configured.

`rkhunter` is just one possible part of a hardened Apache web server setup. Use it alone or with other tools to maximize security. If you want to use this along with other tools for hardening, refer back to the [Apache Hardened Web Server guide](index.md).

This document also uses all of the assumptions and conventions outlined in that original document. It is a good idea to review it before continuing.

## General steps

1. install `rkhunter`
2. configure `rkhunter`
3. configure email and ensure it will work correctly
4. run `rkhunter` manually to generate a list of warnings to test your email settings (`rkhunter --check`)
5. run `rkhunter --propupd` to generate a clean `rkhunter.dat` file that `rkhunter` will use from this point forward as a baseline for further checks.

## Installing `rkhunter`

`rkhunter` requires the EPEL (Extra Packages for Enterprise Linux) repository. Install that repository if you do not have it installed already:

```
dnf install epel-release
```

Install `rkhunter`:

```
dnf install rkhunter
```

## Configuring `rkhunter`

The only configuration options that you _need_ to set are those dealing with mailing reports to the Administrator. 

!!! warning

    Modification of _any_ configuration file in Linux carries risk. Before altering **any** configuration file in Linux, creating a backup of the _original_ file is recommended.


To change the configuration file, run:

```
vi /etc/rkhunter.conf
```

Search for:

```
#MAIL-ON-WARNING=me@mydomain   root@mydomain
```

Remove the remark here and change the `me@mydomain.com` to reflect your email address.

Change the `root@mydomain` to `root@whatever_the_server_name_is`.

You will probably also want to remove the remark (and edit the line to fit your needs) from the `MAIL-CMD` line:


```
MAIL_CMD=mail -s "[rkhunter] Warnings found for ${HOST_NAME}"
```

You might also need to setup [Postfix Email for Reporting](../../email/postfix_reporting.md) to get the email section to work correctly.

## Running `rkhunter`

Run `rkhunter` manually by typing it at the command-line. A cron job takes care of running `rkhunter` for you automatically in `/etc/cron.daily`. If you want to automate the procedure on a different schedule, examine [Automating cron jobs guide](../../automation/cron_jobs_howto.md).

You will also need to move the script somewhere other than `/etc/cron.daily/`, such as `/usr/local/sbin/` and call it from your custom cron job. The easiest method is to leave the default `cron.daily` setup intact.

If you want to test `rkhunter` before you start, including all email functionality, run `rkhunter --check` from the command line. If installed and functioning correctly, you should receive an output similar to the following:

```
[root@sol admin]# rkhunter --check
[Rootkit Hunter version 1.4.6]

Checking system commands...

Performing 'strings' command checks
- Checking 'strings' command                               [OK]

Performing 'shared libraries' checks
- Checking for preloading variables                        [None found]
- Checking for preloaded libraries                         [None found]
- Checking LD_LIBRARY_PATH variable                        [Not found]

Performing file properties checks
- Checking for prerequisites                               [Warning]
- /usr/bin/awk                                             [OK]
- /usr/bin/basename                                        [OK]
- /usr/bin/bash                                            [OK]
- /usr/bin/cat                                             [OK]
- /usr/bin/chattr                                          [OK]
- /usr/bin/chmod                                           [OK]
- /usr/bin/chown                                           [OK]
- /usr/bin/cp                                              [OK]
- /usr/bin/curl                                            [OK]
- /usr/bin/cut                                             [OK]
- /usr/bin/date                                            [OK]
- /usr/bin/df                                              [OK]
- /usr/bin/diff                                            [OK]
- /usr/bin/dirname                                         [OK]
- /usr/bin/dmesg                                           [OK]
- /usr/bin/du                                              [OK]
- /usr/bin/echo                                            [OK]
- /usr/bin/ed                                              [OK]
- /usr/bin/egrep                                           [Warning]
- /usr/bin/env                                             [OK]
- /usr/bin/fgrep                                           [Warning]
- /usr/bin/file                                            [OK]
- /usr/bin/find                                            [OK]
- /usr/bin/GET                                             [OK]
- /usr/bin/grep                                            [OK]
- /usr/bin/groups                                          [OK]
- /usr/bin/head                                            [OK]
- /usr/bin/id                                              [OK]
- /usr/bin/ipcs                                            [OK]
- /usr/bin/kill                                            [OK]
- /usr/bin/killall                                         [OK]
- /usr/bin/last                                            [OK]
- /usr/bin/lastlog                                         [OK]
- /usr/bin/ldd                                             [OK]
- /usr/bin/less                                            [OK]
- /usr/bin/locate                                          [OK]
- /usr/bin/logger                                          [OK]
- /usr/bin/login                                           [OK]
- /usr/bin/ls                                              [OK]
- /usr/bin/lsattr                                          [OK]
- /usr/bin/lsof                                            [OK]
- /usr/bin/mail                                            [OK]
- /usr/bin/md5sum                                          [OK]
- /usr/bin/mktemp                                          [OK]
- /usr/bin/more                                            [OK]
- /usr/bin/mount                                           [OK]
- /usr/bin/mv                                              [OK]
- /usr/bin/netstat                                         [OK]
- /usr/bin/newgrp                                          [OK]
- /usr/bin/passwd                                          [OK]
- /usr/bin/perl                                            [OK]
- /usr/bin/pgrep                                           [OK]
- /usr/bin/ping                                            [OK]
- /usr/bin/pkill                                           [OK]
- /usr/bin/ps                                              [OK]
- /usr/bin/pstree                                          [OK]
- /usr/bin/pwd                                             [OK]
- /usr/bin/readlink                                        [OK]
- /usr/bin/rkhunter                                        [OK]
- /usr/bin/rpm                                             [OK]
- /usr/bin/runcon                                          [OK]
- /usr/bin/sed                                             [OK]
- /usr/bin/sestatus                                        [OK]
- /usr/bin/sh                                              [OK]
- /usr/bin/sha1sum                                         [OK]
- /usr/bin/sha224sum                                       [OK]
- /usr/bin/sha256sum                                       [OK]
- /usr/bin/sha384sum                                       [OK]
- /usr/bin/sha512sum                                       [OK]
- /usr/bin/size                                            [OK]
- /usr/bin/sort                                            [OK]
- /usr/bin/ssh                                             [OK]
- /usr/bin/stat                                            [OK]
- /usr/bin/strace                                          [OK]
- /usr/bin/strings                                         [OK]
- /usr/bin/su                                              [OK]
- /usr/bin/sudo                                            [OK]
- /usr/bin/tail                                            [OK]
- /usr/bin/test                                            [OK]
- /usr/bin/top                                             [OK]
- /usr/bin/touch                                           [OK]
- /usr/bin/tr                                              [OK]
- /usr/bin/uname                                           [OK]
- /usr/bin/uniq                                            [OK]
- /usr/bin/users                                           [OK]
- /usr/bin/vmstat                                          [OK]
- /usr/bin/w                                               [OK]
- /usr/bin/watch                                           [OK]
- /usr/bin/wc                                              [OK]
- /usr/bin/wget                                            [OK]
- /usr/bin/whatis                                          [OK]
- /usr/bin/whereis                                         [OK]
- /usr/bin/which                                           [OK]
- /usr/bin/who                                             [OK]
- /usr/bin/whoami                                          [OK]
- /usr/bin/numfmt                                          [OK]
- /usr/bin/gawk                                            [OK]
- /usr/bin/s-nail                                          [OK]
- /usr/bin/whatis.man-db                                   [OK]
- /usr/bin/kmod                                            [OK]
- /usr/bin/systemctl                                       [OK]
- /usr/sbin/adduser                                        [OK]
- /usr/sbin/chroot                                         [OK]
- /usr/sbin/depmod                                         [OK]
- /usr/sbin/fsck                                           [OK]
- /usr/sbin/fuser                                          [OK]
- /usr/sbin/groupadd                                       [OK]
- /usr/sbin/groupdel                                       [OK]
- /usr/sbin/groupmod                                       [OK]
- /usr/sbin/grpck                                          [OK]
- /usr/sbin/ifconfig                                       [OK]
- /usr/sbin/init                                           [OK]
- /usr/sbin/insmod                                         [OK]
- /usr/sbin/ip                                             [OK]
- /usr/sbin/lsmod                                          [OK]
- /usr/sbin/modinfo                                        [OK]
- /usr/sbin/modprobe                                       [OK]
- /usr/sbin/nologin                                        [OK]
- /usr/sbin/ping                                           [OK]
- /usr/sbin/pwck                                           [OK]
- /usr/sbin/rmmod                                          [OK]
- /usr/sbin/route                                          [OK]
- /usr/sbin/rsyslogd                                       [OK]
- /usr/sbin/runlevel                                       [OK]
- /usr/sbin/sestatus                                       [OK]
- /usr/sbin/sshd                                           [OK]
- /usr/sbin/sulogin                                        [OK]
- /usr/sbin/sysctl                                         [OK]
- /usr/sbin/useradd                                        [OK]
- /usr/sbin/userdel                                        [OK]
- /usr/sbin/usermod                                        [OK]
- /usr/sbin/vipw                                           [OK]
- /usr/libexec/gawk                                        [OK]
- /usr/lib/systemd/systemd                                 [OK]

[Press <ENTER> to continue]
```

Hold off completing the remaining steps if problems exist with the email setup. When confirming email works, but before allowing `rkhunter` to run automatically, run the command manually again with the "--propupd" flag to create the `rkhunter.dat` file. This ensures recognition of your environment and configuration:

```
rkhunter --propupd
```

## Conclusion

`rkhunter` is one part of a hardened server strategy that can help monitor the file system and report any issues to the administrator. It is perhaps one of the easiest hardening tools to install, configure, and run.
