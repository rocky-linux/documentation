---
title: cronie - Timed Tasks
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-10-26
---

# Prerequisite

* A computer running Rocky Linux.
* Know how to use your favorite editor to change the configuration file in the command line environment (this article will use `vi`).
* You have understood the basic knowledge of bash, python or other scripting or programming tools, and expect to run the script automatically.
* You have connected to your computer by SSH (it can be root user or ordinary user with UID greater than 1000).

## cron Introduction

GNU/Linux provides the *cron* system, which is a time-based `cron` jobs program for automated processes. It is not hard, but quite powerful. Want a script or program to run at 5 pm every day? `cron` can do it. There are different branches (or variants) of `cron`, which have the same functions. In this document, **cronie** is used, and the version is 1.5.2. You can click [here](https://github.com/cronie-crond/cronie) to find the latest version and update log.

## cronie's Description

* **cronie** -package name, Rocky Linux includes cronie by default;
* **crontab** -command to maintain `crontab` (task schedule) for each user;
* **crond.service** -cronie's daemon, you can manage the daemon by `systemctl start | restart | stop | status` ;
* **/etc/crontab** -Assign cron jobs to different users, usually we are more accustomed to using `crontab -e` . For example, if you are currently logged in as the root user, type `crontab -e` and you will see specific cron jobs in the file /var/spool/cron/root after saving.
* **/var/log/cron** \*  -Cronie's log, by default, does log rotation and ends with a date suffix. Here, it means wildcard.
* **anacron** -part of cronie . For more information about `anacron`, see [anacron-automation commands](anacron.md).

## `crontab` Command

`crontab` is a command obtained after installation of the cronie package. Compared with `anacron`, it is more suitable for servers that work 7 \* 24 hours a day. Common options of `crontab` are:

```bash
-e # edit crontab scheduled tasks
the -l # View crontab task
-r # delete all the current user's crontab tasks
```

## Use of cronie

To allow different users to execute different commands (or scripts) at different times, they can be written into this file. However, usually we are more accustomed to using `crontab -e`.

```bash
shell > cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# For details see man 4 crontabs
# Example of job definition:
# .---------------- minute (0-59)
# | .------------- hour (0-23)
# | | .---------- day of month (1-31)
# | | | .------- month (1-12) OR jan,feb,mar,apr ...
# | | | | .---- day of week (0-6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# | | | | |
# * * * * * user-name command to be executed
```

|Parameter|Meaning|Value Range|
|---|---|---|
|The 1st\*|The first minute of the hour|0-59|
|The 2nd\*|Hour of the day|0-23|
|The 3rd\*|Day of the month|1-31|
|The 4th\*|The month of the year|1-12|
|The 5th\*|Day of the week|0-7 (0 and 7 both indicate Sunday)|

In the example that follows, assuming you are performing this operation as the root user, type the following:

* `crontab -e` which will bring up the timed tasks of the root user. If you use `vi` as the default system editor, press ++i++ key to enter the insert mode.
* "#" means this is a line of comment.  

```bash
# Nightly 10:00 backup system
00 22 *  *  * /usr/local/sbin/backup
```

* Once the above has been entered (again assuming `vi` is the system editor), press ++escape++ to exit insert mode.
* Save and exit your file with ++shift+colon+"w"+"q"+exclam++ (displayed at the bottom of the editor).

Now the script will run every night at 22:00. This is a simplistic example. Things can become more complicated if you need something more elaborate.

!!! tip "Attention"

    The script needs to have execute permission (`chmod +x`) before cronie can run it.

### Complex Options

The content discussed so far are simplistic options, but what about more complex timed tasks?

```bash
# Suppose you want to run every 10 minutes backup script (may be impractical, however, it is only an example!) Throughout the day. To this end, the following will be written:
* /10 *  *  *  * /usr/local/sbin/backup
#What if you only want to run a backup every 10 minutes on Monday, Wednesday, and Friday? :
* /10 *  *  * 1,3,5 /usr/local/sbin/backup
# In addition to Saturdays and Sundays, once every 10 minutes, every day, how to back up?
* /10 *  *  * 1-5 /usr/local/sbin/backup
```

|Special Symbols|Meaning|
|---|---|
|`*`  | represents any time. For example, the first `*` means any minute, and the second `*` means any hour |
|`,`  | stands for discontinuous time, such as `0 8,12,16 * * *`, which means that the command will run once every day at 8:00, 12:00, and 16:00 |
|`-`  | represents a continuous time range, such as `0 5 * * 1-6`, which means that a command will run at five o'clock in the morning every day from Monday to Saturday |
|`*/n`| Represents how often the interval will run, such as `*/10 * * * *` means that it  every 10 minutes |

!!! tip "Attention"

    The smallest time unit that cronie can recognize is 1 minute; when using, for example, `30 4 1,15 * 5 command` , it will cause the command to run on the 1st and 15th of each month and 4:30 in the morning of every Friday ; The output information of some scripts or commands will prevent the execution of timed tasks, and output redirection is required, such as this- `*/10 * * * * /usr/local/sbin/backup &> /dev/null`

## Q and A

1. /etc/crontab and `crontab -e` , is there any difference between the two methods?
 `crontab -e` does not need to specify a user (the currently logged-in user is used by default), while /etc/crontab needs to specify a user.
2. What should you do if the specified command or script is not run correctly?
Check the /var/log/cron* file, use `journalctl -u crond.service` to check the information about the daemon process, whether the script has x permission, etc., for troubleshooting.
3. In addition to cronie, what cron variants are there?
[fcron](http://fcron.free.fr/), the latest version is 3.3.0 (dev, 2016-08-14).
[cronsun](https://github.com/shunfei/cronsun), the latest version 0.3.5 (2018-11-20).

## Summary

For Rocky Linux desktop users or system administrators, cronie is a very powerful tool. It allows you to automate tasks and scripts so you do not have to remember to run them manually. Although the basic knowledge is not hard, the actual task can be complex. For more information about `crontab`, visit [crontab man page](https://man7.org/linux/man-pages/man5/crontab.5.html). You can also search for "crontab" on the Internet, which provides you with a large number of search results and help you fine-tune the `crontab` expression.
