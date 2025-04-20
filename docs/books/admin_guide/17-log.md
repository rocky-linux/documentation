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

