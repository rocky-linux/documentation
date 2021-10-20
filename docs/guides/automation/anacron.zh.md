---
title: anacron - 自动化命令
author: tianci li
contributors: Steven Spencer
update: 2021-10-20
---

# anacron- 定期运行命令

## 前提条件

* 一台运行 Rocky Linux 的机器。
* 知道如何在命令行环境下使用您喜欢的编辑器修改配置文件（例如 *vim*）。
* 了解基本的RPM包管理

## 假设

* 您已了解 bash、python 或其他脚本/编程工具的基本知识，并希望自动运行脚本。
* 您已以 root 用户身份登录，或者用`su - root`切换到root

## anacron简介
**anacron用于定期运行命令，运行频率以天为单位进行定义，它适用于在笔记本电脑和台式机等不会全天候7*24运行的计算机上。假设您有一个计划的任务(比如备份脚本)要在每天凌晨使用crontab运行，当您睡着的时候，此时您的台式机/笔记本电脑已经关闭。您的备份脚本将不会执行。但是，如果您使用anacron，您可以放心，下次再次打开台式机/笔记本电脑时，将执行备份脚本。**

anacron的出现并不是取代crontab，而是与crontab相互补充。它们的关系如下图：

![Relations](../images/anacron_01.png)

## anacron配置文件

```bash
shell > rpm -ql cronie-anacron
/etc/anacrontab
/etc/cron.hourly/0anacron
/usr/lib/.build-id
/usr/lib/.build-id/0e
/usr/lib/.build-id/0e/6b094fa55505597cb69dc5a6b7f5f30b04d40f
/usr/sbin/anacron
/usr/share/man/man5/anacrontab.5.gz
/usr/share/man/man8/anacron.8.gz
/var/spool/anacron
/var/spool/anacron/cron.daily
/var/spool/anacron/cron.monthly
/var/spool/anacron/cron.weekly
```

首先查看默认的配置文件：
```bash
shell > cat /etc/anacontab
# /etc/anacrontab: configuration file for anacron
# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# 默认45分钟，指定anacron中每个作业的延迟将随机增加0到45分钟。
RANDOM_DELAY=45
# 指定工作的时间范围，这里表示3：00~22：00
START_HOURS_RANGE=3-22

# period in days   delay in minutes   job-identifier   command
# 每天开机5分钟后就检查 /etc/cron.daily 目录内的文件是否被执行，如果今天没有被执行，那就执行下一个
1	5	cron.daily		nice run-parts /etc/cron.daily
# 每隔7天开机后25分钟检查 /etc/cron.weekly 目录内的文件是否被执行，如果一周内没有被执行，就会执行下一个
7	25	cron.weekly		nice run-parts /etc/cron.weekly
# 每隔一个月开机后 45 分钟检查 /etc/cron.monthly 目录内的文件是否被执行
@monthly 45	cron.monthly		nice run-parts /etc/cron.monthly
```

**/etc/cron.hourly/** - 通过`journalctl -u crond.service`可以知道，放入到里面的文件其实是被crond.server调用，表示每小时的第一分钟后开始执行命令。如下所示：

```bash
shell > cat /etc/cron.d/0hourly
# Run the hourly jobs
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
01 * * * * root run-parts /etc/cron.hourly
```
```
shell > journalctl -u crond.service
- Logs begin at Wed 2021-10-20 19:27:39 CST, end at Wed 2021-10-20 23:32:42 CST. -
October 20 19:27:42 li systemd[1]: Started Command Scheduler.
October 20 19:27:42 li crond[733]: (CRON) STARTUP (1.5.2)
October 20 19:27:42 li crond[733]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 76% if used.)
October 20 19:27:42 li crond[733]: (CRON) INFO (running with inotify support)
October 20 20:01:01 li CROND[1897]: (root) CMD (run-parts /etc/cron.hourly)
October 20 21:01:01 li CROND[1922]: (root) CMD (run-parts /etc/cron.hourly)
October 20 22:01:01 li CROND[1947]: (root) CMD (run-parts /etc/cron.hourly)
October 20 23:01:01 li CROND[2037]: (root) CMD (run-parts /etc/cron.hourly)

```

更多配置文件信息，请[浏览手册页](https://man7.org/linux/man-pages/man5/anacrontab.5.html)

## 用户使用
为了使某些文件在这些自动定义的时间内运行，您所需要做的就是将脚本文件复制到相关目录中，并确保其拥有**x执行权限（chmod +x）**。因此，您只要让系统在这些预定时间之一自动运行脚本就可以了，这使自动化任务变得非常容易。

我们用 cron.daily 工作来说明一下 /etc/anacrontab 的执行过程:

1. anacron读取 **/var/spool/anacron/cron.daily** 文件，文件内容显示为上一次执行的时间。
2. 和当前的时间比较，如果两个时间的差值超过 1 天，就执行 cron.daily 工作。
3. 只能在 03：00-22：00 执行这个工作。
4. 开机5分钟检查有文件是否被执行，当执行第一个后，再随机延迟 0～45 分钟执行下一个。
5. 使用 nice 参数指定默认优先级，使用  run-parts 参数执行 /etc/cron.daily/ 目录中所有的可执行文件。


## 相关命令
使用到的命令 `anacron`，常用选项有：

|选项|说明|
|---|---|
|-f    |执行所有的作业，忽略时间戳|
|-u|不执行任何作用的情况下更新时间戳为当前时间|
|-T|测试配置文件/etc/anacrontab的有效性|

更多帮助信息，请[浏览手册页](https://man7.org/linux/man-pages/man8/anacron.8.html)
