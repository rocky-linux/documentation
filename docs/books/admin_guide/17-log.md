---
title: Log management
author: tianci li
contributors: Ganna Zgyrnova, Steven Spencer
tags:
  - rsyslog
  - journald
---

## Basic overview

In this chapter, you will learn how to manage logs in the operating system.

**Q: What is a log?**

**Log**：Records all events and messages occurring since the start of the operating system, including boot logs, kernel initialization logs, `systemd` initialization logs, and application startup or running logs. Log is one of the most essential functions of the operating system. Administrators can query logs to troubleshoot existing or upcoming problems.

In RHEL 8.x and RHEL 9.x, log collection is mainly completed through the following two programs:

* **rsyslog** - A program that quickly collects and processes logs. It is an upgraded version of `syslog`. [This is its official website](https://www.rsyslog.com/)
* **journald** - One of the components of `systemd`

## rsyslog

In Rocky Linux 8.x or 9.x, there are various log files in the **/var/log/** directory. Let's learn about them:

* `/var/log/boot.log` - Log events that occur during the operating system's boot. The file content is plain text.
* `/var/log/btmp` - Record the log of login errors. To view this binary file, use the `lastb` command.
* `/var/log/cron` - Record the logs related to the system's scheduled tasks. The file content is plain text.
* `/var/log/dmegs` -Record the log of the kernel self-check after startup. The file content is plain text. You can also use the `dmegs` command to view.
* `/var/log/lastlog` - Record the last login time of all users in the operating system. To view this binary, you must use the `lastlog` command.
* `/var/log/maillog` - Record email-related logs.
* `/var/log/messages` - The system-level log file that records the core of the operating system. The file content is plain text. When some errors occur in your operating system, you should first view the log file.
* `/var/log/secure` - Record logs related to user identity, such as user login, `su` switch, new user added, user password change, etc.
* `/var/log/wtmp` - Records user login and logout, operating system startup, shutdown, and restart events. To view this binary file, use the `last` command.

For plain text files, the format is usually:

1. Time when the event occurred
2. On which machine did the event occur
3. The name of the service or program that generated the event
4. Specific description and explanation of the event
5. User and terminal information
6. Some keywords prompt (such as error, fail, info, etc.)

The format of logs for different purposes varies greatly, so the above format description cannot represent all logs.

If `rsyslog` is missing from your operating system, run the following command:

```bash
Shell > dnf install -y rsyslog
```

### configuration file

* `/etc/rsyslog.conf` - Main configuration files
* `/etc/rsyslog.d/` - Storage directory of additional configuration files

`/etc/rsyslog.conf` mainly consists of several parts:

1. Load module
2. Global Directives
3. Rules - The author will show this in detail.

After decades of development, `rsyslog` currently supports three different configuration formats:

1. basic (sysklogd) - This format is suitable for representing the basic configuration in a single line.

    ```
    mail.info /var/log/mail.log
    mail.err @@server.example.net
    ```

2. advanced (RainerScript) - Highly flexible and accurate configuration format.

    ```
    mail.err action(type="omfwd" protocol="tcp" queue.type="linkedList")
    ```

3. obsolete legacy (legacy) - This format has been deprecated. Do not continue to use it.

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

| Facility   | Description                                                                                                                                                             |
|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `auth`     | Records events related to system security, user authentication, and authority management                                                                              |
| `authpriv` | Records more sensitive security events (such as `sudo` operations). "priv" is equivalent to private                                                                  |
| `cron`     | Records events related to scheduled tasks                                                                                                                            |
| `daemon`   | Records the running log of the system daemon, covering service startup, running status, and error information                                                         |
| `ftp`      | Records operation logs related to FTP services (such as `vsftpd` and `proftpd`), including connection, file transfer, and error information                           |
| `kern`     | Records the log generated when the Linux kernel runs, covering core events such as hardware drivers, kernel modules, and system exceptions                           |
| `lpr`      | Records the running log of the print service, covering print task submission, queue management, and error information                                    |
| `mail`     | Records log information of mail services (such as Postfix and Sendmail), including mail sending, receiving, queue processing, and error events |
| `news`     | Rarely used                                                                                                                                                          |
| `security` | same as `auth`                                                                                                                                                         |
| `syslog`   | Records logs generated by the `syslog` service                                                                                                            |
| `user`     | Records log information generated by user space applications or users                                                                                   |
| `uucp`     | Records Unix to Unix Copy Protocol (UUCP) related operation logs, including file transfer, remote command execution, and other scenarios                 |
| `local0`   | Reserved                                                                                                                                                             |
| `local1`   | Reserved                                                                                                                                                             |
| ....       | Reserved                                                                                                                                                             |
| `local7`   | Reserved                                                                                                                                                             |

`*` represents all facilities. In a single line configuration, you can also use `,` and `;` Combine the facilities. `,` means logical or; `;` represents the rule delimiter.

```bash
auth,authpriv.*  /var/log/auth.log

# Equivalent to

auth.*   /var/log/auth.log
authpriv.*  /var/log/auth.log
```

```bash
kern.err;mail.alert  /var/log/critical.log
```

| Connector | Describe                                                                                                                                                 |
|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| `.`       | Record logs with a higher priority than keywords. For example, `cron.info` means it will record in `cron` whose log priority is greater than info          |
| `.=`      | Only record the corresponding keyword priority. For example, `*.=emerg` indicates it will record logs with priority equal to `emerg` in all applications |
| `.!`      | It means excluded or not equal to                                                                                                                        |

Priorities are sorted from low to high:

| Name      | Description                                                                                                        |
|-----------|-----------------------------------------------------------------------------------------------------------------|
| `debug`   | General debugging information                                                                                   |
| `info`    | Basic notification information                                                                                  |
| `notice`  | General information of certain importance                                                                       |
| `warning` | Warning message, this type of information cannot affect the normal operation of the operating system or service |
| `err`     | Error messages, which can affect the normal operation of the operating system and services                      |
| `crit`    | A critical state more serious than "err"                                                                        |
| `alert`   | The alert status is more serious than "crit", and the system administrator needs to deal with it immediately    |
| `emerg`   | An emergency state in which the operating system is normally unusable                                           |

`*` represents all log priorities.

The lower the log priority, the more detailed the content recorded and the lower the severity. The higher the log priority, the less content is recorded and the more serious the problem.

"action" refers to where to save or send the log:

* `/var/log/secure` - Save the log to a local file
* `@192.168.100.20:22` - Remote machine
* `:omusrmsg:root,frank,jack` - Specify the list of online users. `*` represents all users. "omusrmsg" refers to "output module for user messages".
* `/dev/tty12` - Specific terminal devices
* `-` - Disable buffering mechanism when writing to file

### Log rotation

**Log rotation** - To solve the problems of storage occupation and performance degradation caused by the continuous growth of log files, you need log rotation. The specific functions are:

* **Rotation** - Automatically archive the current log file according to specific rules (such as time or file size), and create a new empty log file for recording to prevent the log file from being too large.
* **Compress** - Compress archived old logs to save disk space.
* **Delete** - Retain relevant log files and delete expired old ones according to relevant policies.

We often use the `logrotate` tool to rotate logs.

Naming rules for log files during rotation:

* `dateext` parameter - Use date as the file suffix for log rotation. For example, during the first log rotation, the old log file "secure" will change to "secure-20250424" and `logrotate` creates a new "secure"
* No `dateetx` parameter - Uses the rotation numbers as the file suffix after the log rotation. For example, when the first log rotation occurs, the old log file "secure" will change to "secure.1" and `logrotate` will create a new "secure"

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

| items                           | description                                                                                                       |
|---------------------------------|----------------------------------------------------------------------------------------------------------------|
| `daily`                         | Defines the cycle of log rotation in days                                                                       |
| `weekly`                        | Defines the cycle of log rotation in weeks                                                                      |
| `monthly`                       | Defines the cycle of log rotation in months                                                                     |
| `rotate <NUMBER>`               | The number of files saved after log rotation                                                                   |
| `compress`                      | Compression of the old logs occurs after log rotation                                                          |
| `create <MODE> <OWNER> <GROUP>` | After log rotation, define the owner, group, and permission of the new log file                                 |
| `mail <E-MAIL ADDRESS>`         | After log rotation, sends the output content by email to the specified email address                           |
| `missingok`                     | If the log file does not exist, it ignores the warning information of the log                                     |
| `notifempty`                    | If the content of the log file is empty, no log rotation occurs                                                |
| `minsize <SIZE>`                | The file size condition of log rotation, that is, log rotation occurs only when it meets this condition |
| `dateext`                       | Use date as the file suffix for log rotation                                                                   |

If you install the software package from the repository, the software package maintainer defines the application's log rotation, and users usually do not need to modify the log rotation rules. If you install the application by compiling the source code, you need to consider and manually configure log rotation.

#### `logrotate` command

The usage is `logrotate [OPTION...] <configfile>`

* `-v` - Display the process of log rotation
* `-f` - The enforcement of log rotation occurs whether or not the conditions for log rotation are met

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

Note that `journald` does not enable log persistence by default, which means it only retains and records all logs since startup. After the operating system restarts, deletion of historical logs occurs. By default, all temporarily saved log files are in the **/run/log/journal/** directory.

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

* **priority** - The importance of marking logs. Like `rsyslog`, the higher the priority, the less information recorded and the more serious the problem. The lower the priority, the more information recorded, and the lighter the problem. Sort by priority from low to high:

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
  
* **facility** - This tables shows the facility:

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

Here is a listing of the options in an unordered list:

* `-u` - Specify 'unit', you can use this multiple times in a single line command. For example, `journalctl -u crond.service -u sshd.service`
* `--system` - Show messages from system services and the kernel
* `--user` - Show messages from the service of the current user
* `-k` - Show kernel message log from the current boot
* `--since=DATA` or `-S` - Show entries that are not older than the specified date. The date format is "YYYY-MM-DD HH:MM:SS". For example `journalctl --since="2025-04-24 14:00:30`
* `--until=DATA` or `-U` - Show entries that are not newer than the specified date. The date format is "YYYY-MM-DD HH:MM:SS". For example `journalctl --since="2025-04-01 05:00:10" --until="2025-04-05 18:00:30"`
* `--list-boots` - Show terse information about recorded boots
* `-n N` - Controls the number of entries output. If "N" is not specified, the default value is 10
* `-p PRIORITY` - Specify priority or range of priorities. If you specify a single log priority keyword, this priority and entries higher than this priority will be displayed. For example, `journalctl -p 3` or `journalctl -p err` Equivalent to `journalctl -p 0..3` or `journalctl -p emerg..err`
* `-b` - Query the log since the start of the current boot ID. Do not confuse the boot ID with the index number of the kernel boot.
* `-f` - Dynamic query log, similar to the `tail -f` command
* `-x` - Add message explanations where available
* `-e` - Jump to the end page of the log, often used with the `-x` option
* `-r` - Reverse Log.
* `--disk-usage` - Display the disk space occupied by log files
* `--rotate` - Request immediate rotation of the journal files
* `--vacuum-size=BYTES` - Reduces the log file to the specified size. Deletes the old log content gradually until it meets the specified file size. The supported size suffixes are K, M, G, T
* `--vacuum-time=TIME` - You can delete old log records by specifying a time point, that is, it will delete log records earlier than that. The supported time suffixes are s, m, h, days, months, weeks, years
* `--vacuum-files=INT` - Indicates how many log files to reserve
* `-N` - List all field names currently used. Users can use the "FIELD=VALUE" method to match related content. For example, `journalctl _SYSTEMD_UNIT=sshd.service`.
* `-g` or `-grep=PATTERN`- Match log content through pattern, and support regular expressions. If PATTERN is all lowercase, matching log content is not case-sensitive by default. You can adjust case sensitivity through the `--case-sensitive` option
* `--case-sensitive=[BOOLEAN]` - Adjust whether it is case-sensitive.
* `-o` or `--output=STRING` - Change the output mode of `journalctl`. A STRING can be short, short-precise, short-iso, short-iso-precise, short-full, short-monotonic, short-unix, verbose, export, json, json-pretty, json-sse, cat, and with-unit
* `-q` or `--quiet` - Quiet output
* `--sync` - Synchronize unwritten journal messages to disk

### /etc/systemd/journald.conf

```bash
Shell > cat /etc/systemd/journald.conf
[Journal]
#Storage=auto
#Compress=yes
#Seal=yes
#SplitMode=uid
#SyncIntervalSec=5m
#RateLimitIntervalSec=30s
#RateLimitBurst=10000
#SystemMaxUse=
#SystemKeepFree=
#SystemMaxFileSize=
#SystemMaxFiles=100
#RuntimeMaxUse=
#RuntimeKeepFree=
#RuntimeMaxFileSize=
#RuntimeMaxFiles=100
#MaxRetentionSec=
#MaxFileSec=1month
#ForwardToSyslog=no
#ForwardToKMsg=no
#ForwardToConsole=no
#ForwardToWall=yes
#TTYPath=/dev/console
#MaxLevelStore=debug
#MaxLevelSyslog=debug
#MaxLevelKMsg=notice
#MaxLevelConsole=info
#MaxLevelWall=emerg
#LineMax=48K
```

Uses "[ ]" to contain the title, like the configuration files of other `systemd` components, and below the title are specific key-value pairs. There is **no space on either side of the equal sign** in the key-value pair. For the complete configuration manual page, see `man 5 journald.conf`

* `Storage=` - Controls the location of the `journald` data store. The default value is auto.

    * volatile - Store the log data in memory, that is, the temporary file located in the **/run/log/journal/** directory.
    * persistent - Store the log data in the **/var/log/journal/** directory. You need to create this manually. If this directory is not writable, log data will write to the **/run/log/journal/** directory.
    * auto - Similar to persistent
    * none - Do not save any logs, but it will not affect the logs forwarded to other "targets"

* `Compress=` - Whether to enable the compression function. The default value is yes.
* `Seal=` - Whether to use FSS (Forward Secure Sealing) to protect log entries from malicious tampering. The default value is yes.
* `SplitMode=` - Define the basis for splitting log files. Meeting the precondition (Storage=persistent) must occur before it takes effect. The default value is uid.
* `SyncIntervalSec=` - Define the time interval for synchronizing the log data in memory to the disk. Please note! This only occurs for err, warning, notice, info, and debug log priorities. Other log priorities are immediately synchronized to disk. The default value is 5m.
* `RateLimitIntervalSec=` - Define the time interval for log generation frequency. The default value is 30s.
* `RateLimitBurst=` - The maximum number of entries the log generates in a given time interval. The default value is 10000. If the log entries are greater than 10000 within a given time interval, it will delete the redundant logs, and it will create no new log entries until the next time interval.
* `SystemMaxUse=` - Controls the total size of all log files in the **/var/log/journal/** directory.
* `SystemKeepFree=` - Controls how much disk space to reserve in the **/var/log/journal/** directory. Based on 1024, suffixes include K, M, G, T, P, E
* `SystemMaxFileSize=` - Limit the size of a single file in the **/var/log/journal/** directory. If the size exceeds the specified size, log rotation will occur
* `SystemMaxFiles=` - Specify how many files to keep in the **/var/log/journal/** directory. When it exceeds the defined number, it will delete the oldest log.
* `RuntimeMaxUse=` - Controls the total size of log data in the **/run/log/journal/** directory.
* `RuntimeKeepFree=` - Controls how much space to reserve in the **/run/log/journal/** directory.
* `RuntimeMaxFileSize=` - Controls the size of a single log file in the **/run/log/journal/** directory. When the log reaches the specified size, log rotation will occur.
* `RuntimeMaxFiles=` - How many files of logs need to be kept in the **/run/log/journal/** directory.
* `MaxRetentionSec=` - Define the retention time for log files; if it exceeds the defined time, it deletes old log files. A value of 0 indicates that the function is off. The value suffix has year, month，week, day，h，m
* `MaxFileSec=` - Time-based log rotation. Since file size based polling (`SystemMaxFileSize` and `RuntimeMaxFileSize`) already exists, time based log polling is usually not required. Set it to 0 to disable this function.
* `ForwardToSyslog=` -Whether to forward the collected log messages to the traditional `syslog` daemon. The default value is no.
* `ForwardToKMsg=` - Whether to forward the received log message to kmsg. The default value is no.
* `ForwardToConsole=` - Whether to forward the received log messages to the system console. The default value is no. If it is set to yes, you also need to configure `TTYPath`
* `ForwardToWall=` - Whether to send the received log message as a warning to all logged-in users. The default value is yes.
* `TTYPath=` - Specify the path of the console. Requires `ForwardToConsole=yes`. The default value is /dev/console
* `MaxLevelStore=` - Set the maximum log level recorded to the log file. The default value is debug
* `MaxLevelSyslog=` - Set the maximum log level forwarded to the traditional `syslog` daemon. The default value is debug
* `MaxLevelKMsg=` - Set the maximum log level forwarded to kmsg. The default value is notice
* `MaxLevelConsole=` - Set the maximum log level forwarded to the system console. The default value is info
* `MaxLevelWall=` - Set the maximum log level sent to all logged-in users. The default value is `emerg`
* `LineMax=` - The maximum allowable length (bytes) of each log record when converting the log stream to log records. With 1024 as the base, the suffix can be K, M, G, or T. The default value is 48K

## Other instructions

If you do not change any configuration in **/etc/systemd/journald.conf**, `rsyslog` and `journald` can coexist without affecting each other.

```bash
Shell > cat /etc/rsyslog.conf
...
#### MODULES ####

module(load="imuxsock"    # provides support for local system logging (e.g. via logger command)
       SysSock.Use="off") # Turn off message reception via local log socket;
                          # local messages are retrieved through imjournal now.
module(load="imjournal"             # provides access to the systemd journal
       UsePid="system" # PID nummber is retrieved as the ID of the process the journal entry originates from
       StateFile="imjournal.state") # File to store the position in the journal
#module(load="imklog") # reads kernel messages (the same are read from journald)
#module(load="immark") # provides --MARK-- message capability
...
```

`journald` will forward the obtained log data to the socket `/run/systemd/journal/syslog` to facilitate the use of traditional log services (rsyslog, syslog-ng). However, we can learn from the configuration file that `rsyslog` does not collect logs from `journald` using sockets, but integrates through the input module (imjournal).

**Q: Can the operating system not use `journald` for logging?**

Yes. By default, `rsyslog` and `journald` can coexist in the operating system without affecting each other. Coexistence is not the best choice for some performance-oriented usage scenarios (such as data throughput and memory consumption). You can make `rsyslog` run only in socket mode, which helps improve performance and record all logs in plain text. However, if you need structured logs, this change is not suitable. The relevant steps are as follows:

```bash
Shell > vim /etc/rsyslog.config
...
module(load="imuxsock"
      SysSock.Use="on")
# module(load="imjournal" 
# UsePid="system" 
# StateFile="imjournal.state")
module(load="imklog")
...

Shell > vim /etc/systemd/journald.conf
[Journal]
Storage=none
...
ForwardToSyslog=yes
...

Shell > reboot
```
