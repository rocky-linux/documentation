---
title: Log management
author: tianci li
contributors:
tags:
  - rsyslog
  - journald
---

# Basic overview

In this chapter, you will learn how to manage logs in the operating system.

**Q: What is a log?**

**Log**：It is used to record all events and messages that have occurred since the start of the operating system, including boot logs, kernel initialization logs, systemd initialization logs, and application startup or running logs. Log is one of the most important functions of the operating system. Administrators can query logs to troubleshoot existing or upcoming problems.

In RHEL 8.x and RHEL 9.x, log collection is mainly completed through the following two programs:

* **rsyslog** - A program that quickly collects and processes logs. It is an upgraded version of syslog. [This is its official website](https://www.rsyslog.com/)
* **journald** - One of the components of `systemd`

## rsyslog

In Rocky Linux 8.x or 9.x, there are various log files in the **/var/log/** directory. Let's learn about them:

* `/var/log/boot.log` - Log events that occur during the boot of the operating system. The file content is plain text.
* `/var/log/btmp` - Record the log of login errors. The content of its file is binary and needs to be viewed using the `lastb` command.
* `/var/log/cron` - Record the logs related to the system's scheduled tasks. The file content is plain text.
* `/var/log/dmegs` -Record the log of the kernel self-check after startup. The file content is plain text. You can also use the `dmegs` command to view.
* `/var/log/lastlog` - Record the last login time of all users in the operating system. The content of its file is binary and needs to be viewed using the `lastlog` command.
* `/var/log/maillog` - Record email related logs.
* `/var/log/messages` - The system level log file that records the core of the operating system. The file content is plain text. When some errors occur in your operating system, you should first view the log file.
* `/var/log/secure` - Record logs related to user identity, such as user login, `su` switch, new user added, user password change, etc
* `/var/log/wtmp` - Records user login and logout, as well as OS startup, shutdown and restart events. The content of its file is binary and needs to be viewed using the `last` command.

For plain text files, the format is usually:

1. Time when the event occurred
2. On which machine did the event occur
3. The name of the service or program that generated the event
4. Specific description and explanation of the event
5. User and terminal information
6. Some keywords prompt (such as error, fail, info, etc.)

The format of logs for different purposes varies greatly, so the above format description cannot represent all logs.

If rsyslog is missing from your operating system, execute the following command:

```bash
Shell > dnf install -y rsyslog
```

### configuration file

* `/etc/rsyslog.conf` - Main configuration files
* `/etc/rsyslog.d/` - Storage directory of additional configuration files

`/etc/rsyslog.conf` mainly consists of several parts:

1. Load module
2. Global Directives
3. Rules - This part of the content will be introduced in detail.

After decades of development, rsyslog currently supports three different configuration formats:

1. basic (sysklogd) - This format is suitable for representing the basic configuration in a single line. 

    ```
    mail.info /var/log/mail.log
    mail.err @@server.example.net
    ```

2. advanced (RainerScript) - Highly flexible and highly accurate configuration format.

    ```
    mail.err action(type="omfwd" protocol="tcp" queue.type="linkedList")
    ```

3. obsolete legacy (legacy) - This format has been deprecated. You should not continue to use it.

#### Rules

The default content for this section is as follows:

```
*.info;mail.none;authpriv.none;cron.none                /var/log/messages

authpriv.*                                              /var/log/secure

mail.*                                                  -/var/log/maillog

cron.*                                                  /var/log/cron

*.emerg                                                 :omusrmsg:*

uucp,news.crit                                          /var/log/spooler

local7.*                                                /var/log/boot.log
```

Each rule line consists of two parts:

1. selector field - Composed of facilities and priorities
2. action field - How would you like to handle these matching messages

Fields are separated from each other by one or more spaces.

| Facility | Describe |
| :--- | :--- |
| `auth` | It is used to record events related to system security, user authentication and authority management |
| `authpriv` | Record more sensitive security events (such as sudo operations). "priv" is equivalent to private |
| `cron` | It is used to record events related to scheduled tasks |
| `daemon` | It is used to record the running log of the system daemon, covering service startup, running status and error information | 
| `ftp` | It is used to record operation logs related to FTP services (such as vsftpd and proftpd), including connection, file transfer and error information |
| `kern` | It is used to record the log generated when the Linux kernel runs, covering core events such as hardware drivers, kernel modules, and system exceptions |
| `lpr` | It is used to record the running log of the print service, covering print task submission, queue management and error information |
| `mail` | It is specially used to record log information of mail services (such as Postfix and Sendmail), including mail sending, receiving, queue processing and error events |
| `news` | Rarely used |
| `security` | same as auth |
| `syslog` | It is used to record logs generated by the syslog service |
| `user` | It is used to record log information generated by user space applications or users |
| `uucp` | It is used to record Unix to Unix Copy Protocol (UUCP) related operation logs, including file transfer, remote command execution and other scenarios |
| `local0` | Reserved |
| `local1` | Reserved |
| ....   | Reserved |
| `local7` | Reserved |

`*` represents all facilities. In a single line configuration, you can also use `,` and `;` Combine the facilities. `,` means logical or; `;` represents the rule delimiter.

```
auth,authpriv.*  /var/log/auth.log

# Equivalent to

auth.*   /var/log/auth.log
authpriv.*  /var/log/auth.log
```

```
kern.err;mail.alert  /var/log/critical.log
```

| Connector |  Describe |
| :---- | :--- |
| `.`   | Record logs with priority higher than keywords. For example, `cron.info` means that all records in cron whose log priority is greater than info will be recorded |
| `.=`  | Only record the corresponding keyword priority. For example, `*.=emerg` indicates that logs with priority equal to emerg in all applications will be recorded | 
| `.!`  | It means excluded or not equal to |

Priorities are sorted from low to high:

| Name    |  Describe |
| :---    | :---      |
| `debug`   | General debugging information |
| `info`    | Basic notification information |
| `notice`  | General information of certain importance | 
| `warning` | Warning message, this type of information cannot affect the normal operation of the operating system or service |
| `err`     | Error messages, which can affect the normal operation of the operating system and services |
| `crit`    | A critical state more serious than "err" |
| `alert`   | The alert status is more serious than "crit", and the system administrator needs to deal with it immediately |
| `emerg`   | An emergency state in which the operating system cannot be used normally |

`*` represents all log priorities.

The lower the log priority, the more detailed the content recorded, and the lower the severity. The higher the log priority is, the less content is recorded, and the more serious the problem is. 

"action" refers to where to save or send the log:

* `/var/log/secure` - Save the log to a local file
* `@192.168.100.20:22` - Remote machine
* `:omusrmsg:root,frank,jack` - Specify the list of online users. `*` represents all users. "omusrmsg" refers to "output module for user messages".
* `/dev/tty12` - Specific terminal devices
* `-` - Disable buffering mechanism when writing to file

### Log rotation

**Log rotation** - In order to solve the problems of storage occupation and performance degradation caused by the continuous growth of log files, we need log rotation. The specific functions are:

* **Rotation** - Automatically archive the current log file according to specific rules (such as time or file size), and create a new empty log file for recording to prevent the log file from being too large.
* **Compress** - Compress archived old logs to save disk space.
* **Delete** - Retain relevant log files and delete expired old log files according to relevant policies.

We often use the `logrotate` tool to rotate logs.

Naming rules for log files during rotation:

* `dateext` parameter - Use date as the file suffix for log rotation. For example, during the first log rotation, the old log file "secure" will be changed to "secure-20250424" and a new "secure" will be created
* No `dateetx` parameter - The rotation numbers are used as the file suffix after the log rotation. For example, when the first log rotation occurs, the old log file "secure" will be changed to "secure.1" and a new "secure" will be created

#### /etc/logrotate.conf and /etc/logrotate.d/

```bash
Shell > grep -v -E "^#|^$" /etc/logrotate.conf
weekly
rotate 4
create
dateext
include /etc/logrotate.d

Shell > ls -l /etc/logrotate.d/
-rw-r--r--  1 root root 130 Feb  7  2023 btmp
-rw-r--r--. 1 root root 160 Dec  5  2023 chrony
-rw-r--r--. 1 root root  88 Apr 12  2021 dnf
-rw-r--r--  1 root root  93 Mar 11 17:29 firewalld
-rw-r--r--. 1 root root 162 Apr 16 19:49 kvm_stat
-rw-r--r--  1 root root 289 Dec 18 01:38 sssd
-rw-r--r--  1 root root 226 Nov  5 15:43 syslog
-rw-r--r--  1 root root 145 Feb 19  2018 wtmp
```

**/etc/logrotate.conf** -  Global profile for log rotation. If the configuration items or parameters overlap, the last read configuration items or parameters shall prevail. Reading order:

1. Read the contents of the **/etc/logrotate.conf** file from top to bottom
2. Files included using the "include" keyword

Common configuration items or parameters are:

| items   | describe |
| :---    | :---     |
| `daily`   | Define the cycle of log rotation in days |
| `weekly`  | Define the cycle of log rotation in weeks |
| `monthly` | Define the cycle of log rotation in months |
| `rotate <NUMBER>` | The number of files saved after log rotation |
| `compress` | After log rotation, the old logs are compressed |
| `create <MODE> <OWNER> <GROUP>` | After log rotation, define the owner, group and permission of the new log file |
| `mail <E-MAIL ADDRESS>` | After log rotation, the output content is sent to the specified email address by email |
| `missingok` | If the log file does not exist, the warning information of the log is ignored |
| `notifempty` | If the content of the log file is empty, log rotation will not be performed  |
| `minsize <SIZE>` | The file size condition of log rotation, that is, log rotation occurs only when the condition is met |
| `dateext`  | Use date as the file suffix for log rotation |

If you install the software package from the repository, the log rotation of the application has been defined by the software package maintainer, and users usually do not need to modify the log rotation rules. If you install the application by compiling the source code, you need to consider and manually configure log rotation.

#### `logrotate` command

The usage is `logrotate [OPTION...] <configfile>`

* `-v` - Display the process of log rotation
* `-f` - Whether the conditions for log rotation are met or not, a log rotation is enforced

```bash
Shell > logrotate -v /etc/logrotate.conf
reading config file /etc/logrotate.conf
including /etc/logrotate.d
reading config file btmp
reading config file chrony
reading config file dnf
reading config file firewalld
reading config file kvm_stat
reading config file sssd
reading config file syslog
reading config file wtmp
Reading state from file: /var/lib/logrotate/logrotate.status
Allocating hash table for state file, size 64 entries
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state

Handling 8 logs

rotating pattern: /var/log/btmp  monthly (1 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/btmp
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-04 12:08
  log does not need rotating (log has been rotated at 2025-4-4 12:8, that is not month ago yet)

rotating pattern: /var/log/chrony/*.log  weekly (4 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/chrony/*.log
  log /var/log/chrony/*.log does not exist -- skipping
not running postrotate script, since no logs were rotated

rotating pattern: /var/log/hawkey.log  weekly (4 rotations)
empty log files are not rotated, old logs are removed
considering log /var/log/hawkey.log
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)

rotating pattern: /var/log/firewalld  weekly (4 rotations)
empty log files are rotated, only log files >= 1048576 bytes are rotated, old logs are removed
considering log /var/log/firewalld
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-20 13:00
  log does not need rotating ('minsize' directive is used and the log size is smaller than the minsize value)

rotating pattern: /var/log/kvm_stat.csv  10485760 bytes (5 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/kvm_stat.csv
  log /var/log/kvm_stat.csv does not exist -- skipping

rotating pattern: /var/log/sssd/*.log  weekly (2 rotations)
empty log files are not rotated, old logs are removed
considering log /var/log/sssd/sssd_implicit_files.log
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-26 12:42
  log does not need rotating (log is empty)
considering log /var/log/sssd/sssd_kcm.log
  Now: 2025-04-24 12:35
  Last rotated at 2025-02-08 13:49
  log does not need rotating (log is empty)
considering log /var/log/sssd/sssd.log
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-26 12:42
  log does not need rotating (log is empty)
considering log /var/log/sssd/sssd_nss.log
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-26 12:42
  log does not need rotating (log is empty)
not running postrotate script, since no logs were rotated

rotating pattern: /var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
 weekly (4 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/cron
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/maillog
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/messages
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/secure
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/spooler
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
not running postrotate script, since no logs were rotated

rotating pattern: /var/log/wtmp  monthly (1 rotations)
empty log files are rotated, only log files >= 1048576 bytes are rotated, old logs are removed
considering log /var/log/wtmp
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-20 13:00
  log does not need rotating ('minsize' directive is used and the log size is smaller than the minsize value)
```

## journald

`systemd` is not only an application used for initialization, but also takes over many system components. Use `journald` in `systemd` to take over the contents of the log.

`journald` is the daemon in `systemd` that takes over the logs. You need to use the `journalctl` command to read the logs. 

It should be noted that `journald` do not have persistence functionality, which means they only retain and record all logs since startup. After the operating system restarts, historical logs will be deleted. By default, all temporarily saved log files are stored in the **/run/log/journal/** directory.

```bash
Shell > tree -hugp /run/log/journal/638c6d5d2b674f77be56174469099106/
/run/log/journal/638c6d5d2b674f77be56174469099106/
└── [-rw-r----- root     systemd-journal  8.0M]  system.journal

0 directories, 1 file
```

This temporary file is a binary file. You must use the `journalctl` command to parse it.

`journald` can record:

* boot log
* kernel log
* application log

`journald` marks logs according to **priority** and **facility**:

* **priority** - The importance of marking logs. Like rsyslog, the higher the priority, the less information is recorded and the more serious the problem; The lower the priority, the more information recorded, and the lighter the problem. Sort by priority from low to high:

    | Numerical code | priority      | keywords |
    | :---           | :---          | :---     |
    | 7              | Debug         | `debug`  |
    | 6              | Informational | `info`   |
    | 5              | Notice        | `notice` |
    | 4              | Warning       | `warning`|
    | 3              | Error         | `err`    |
    | 2              | Critical      | `crit`   |
    | 1              | Alert         | `alert`  |
    | 0              | Emergency     | `emerg`  |
  
* **facility** - The facility are shown in the following table:

    | Numerical code | facility  |
    | :---           | :---      |
    | 0              | `kern`    |
    | 1              | `user`    |
    | 2              | `mail`    |
    | 3              | `daemon`  |
    | 4              | `auth`    |
    | 5              | `syslog`  |
    | 6              | `lpr`     |
    | 7              | `news`    |
    | 8              | `uucp`    |
    | 9              |           |
    | 10             | `authpriv` |
    | 11             | `ftp`     |
    | 12             |           |
    | 13             |           |
    | 14             |           |
    | 15             | `cron`    |
    | 16             | `local0`  |
    | 17             | `local1`  |
    | 18             | `local2`  |
    | 19             | `local3`  |
    | 20             | `local4`  |
    | 21             | `local5`  |
    | 22             | `local6`  |
    | 23             | `local7`  |

### `journalctl` command

The usage is `journalctl [OPTIONS...] [MATCHES...]`.

Because there are many options, the unordered list is used to explain:

* `-u` - Specify 'unit', which can be used multiple times in a single line command. Such as `journalctl -u crond.service -u sshd.service`
* `--system`
* `--user`
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``
* ``