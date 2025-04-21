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

The lower the log priority, the more detailed the content recorded, and the lower the severity. The higher the log priority is, the less content is recorded, and the more serious the problem is.

