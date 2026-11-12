---
title : rsync configuration file
author : tianci li
update : 2026-11-12
---

# Overview

In this chapter, you will learn how to configure the Rsync configuration file.

## /etc/rsyncd.conf

!!! Note "Note"

    In RL 8.10, the software package "rsync-daemon" can release this file after installation.

The previous document described some of the parameter items in this file, as shown in the table below:

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

There are also some other parameter items:

| Item | Description |
| --- | --- |
| fake super = yes | yes means that you do not need the daemon to run as root to store the complete attributes of the file |
| uid = | When using identity authentication based on the RSYNC protocol, the specified system user to which the virtual user (custom virtual user) is mapped. If not specified, the default is the nobody user  |
| gid = | When using identity authentication based on the RSYNC protocol, the specified system group to which the virtual group is mapped. If not specified, it defaults to the nobody group |
| use chroot = yes | Is it necessary to lock the root directory before data transmission. For security reasons, the default is yes |
| max connections = 4 | The maximum number of connections allowed, the default value is 0, which means that there is no restriction |
| lock file = /var/run/rsyncd.lock | Specify the location of the lock file |
| exclude = lost+found/ | Exclude directories that do not need to be transferred |
| transfer logging = yes | Whether to enable ftp-like log format to record rsync uploads and downloads |
| timeout = 900 | The timeout period for file transfer. Default is 0, which means it will never time out |
| ignore nonreadable = yes | Whether to ignore files to which the user does not have access rights |
| motd file = /etc/rsyncd/rsyncd.motd | Specify the path of the message file. By default, there are no message files. The content of the message file refers to the welcome message displayed after the user logs in |
| hosts allow = 10.1.1.1/24 | Client access control whitelist. You can fill in the IP address, network segment, host name, etc. Use a space to separate multiple values. Allow everyone to access by default |
| hosts deny = 10.1.1.20 | Client access control blacklist. If `hosts allow =` and `hosts deny =` have the same matching result, the client cannot access eventually. If the client is neither within the `hosts allow =` range nor within the `hosts deny =` range, then this client is permitted to access. By default, this parameter item does not exist  |
| syslog facility = daemon | Define the level of system log. These values ​​can be filled in: auth, authpriv, cron, daemon, ftp, kern, lpr, mail, news, security, syslog, user, uucp, local0, local1, local2 local3, local4, local5, local6 and local7. The default value is daemon |

Parameters not mentioned can be found in `man 5 rsyncd.conf`.

## Recommended configuration

```
uid = nobody
gid = nobody
address = 192.168.100.20
use chroot = yes
max connections = 10
syslog facility = daemon
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
lock file = /var/run/rsyncd.lock

[file]
comment = rsync
path = /rsync/
read only = no
dont compress = *.gz *.bz2 *.zip
auth users = li
secrets file = /etc/rsyncd_users.db
```
