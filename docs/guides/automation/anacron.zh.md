---
title: anacron - 自动化命令
author: 李天赐
contributors: 史蒂文 斯本
update: 2021-10-20
---

# anacron - 定期执行命令工具

## 先决条件

* 运行Rocky Linux的机器。
* 知道如何使用您最喜欢的编辑器来修改命令行环境中的配置文件(例如 *vim*)。
* 了解基本RPM软件包管理

## 前提条件

* 您已经了解了bash、 python 或其他脚本/编程工具的基础知识，并且想要自动运行脚本。
* 您已经以 root 用户的身份登录，或者使用 `su 切换到 root`

## Anacron 介绍

**anacron 用于定期运行命令，操作频率以天为单位确定。 它适合于不运行24/7的计算机，如笔记本和台式计算机。 假定您有一个预定的任务(例如备份脚本)将在每天早上使用 crontab运行。 当您睡觉时，您的桌面/笔记本电脑将被关闭。 您的备份脚本将不会被执行。 但是，如果您使用anacron，您可以放心，下次打开桌面/膝上型电脑时，备份脚本将会被执行。**

Anacron 并不是取代crontab，而是对crontab的一种补充。 它们的关系如下：

![ 相关内容 ](../images/anacron_01.png)

## 配置文件

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

首先检查默认配置文件：
```bash
shell > cat /etc/anacontab
# /etc/anacrontab: configuration file for anacron
# See anacron(8) and anacrontab(5) for details.
SHELL=/bin/sh
PATH=/sbin:/usr/sbin:/bin
MAILTO=root
# 每个指定作业的默认45分钟延迟随机增加0-45分钟。
SHELL=/bin/sh
PATH=/sbin:/usr/sbin:/bin
MAILTO=root
# 每个指定作业的默认45分钟延迟随机增加0-45分钟。
RANDOM_DELAY=45
# 指定工作时间范围 在这里代表 3:00~22:00
START_HOURS_RANGE=3-22
# 几天内延迟作业标识符命令
# 每天启动来检查目录/etc/cron中的文件。 每日执行在5分钟内, 如果今天没有执行, 则执行到下一个
1 5 cron.daily run-part /etc/cron。 每日
# 25分钟内每7天检查/etc/cron。 eekly 目录是在启动后执行的，如果不是在一个星期内执行，它将在下一个
7 25 cron.weekly run-part /etc/cron执行。 eekly
# 目录/etc/cron中的文件。 每次开始后每个月进行45分钟的一次检查
@monthly 45 cron.monthly nice run-part /etc/cron.monthly
```

**/etc/cron.hourly/** -通过 `journalctl -u crond. ervice`, 你可以知道放在内面的文件实际上被crond调用。 因为这意味着命令将在每小时第一分钟后执行。 例如：

```bash
shell > cat /etc/cron.d/0hourly
# 运行每小时作业
SHELL=/bin/bash
PATH=/sbin:/usr/sbin:/usr/bin
MAILTO=root
01* * * root run-parts /etc/cron.hourly
```
```
shell > journalctl -u crond.service
- Logs begin at Wed 2021-10-20 19:27:39 CST, end at Wed 2021-10-2023:32:42 CST. October 20 19:27:42 li systemd[1]: Started Command Scheduler.
October 20 19:27:42 li crond[733]: (CRON) STARTUP (1.5.2)
October 20 19:27:42 li crond[733]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 76% if used.)
October 20 19:27:42 li crond[733]: (CRON) INFO (running with inotify support)
October 20 20:01:01 li CROND[1897]: (root) CMD (run-parts /etc/cron.hourly)
October 20 21:01:01 li CROND[1922]: (root) CMD (run-parts /etc/cron.hourly)
October 20 22:01:01 li CROND[1947]: (root) CMD (run-parts /etc/cron.hourly)
October 20 23:01:01 li CROND[2037]: (root) CMD (run-parts /etc/cron.hourly) October 20 19:27:42 li systemd[1]: Started Command Scheduler.
October 20 19:27:42 li crond[733]: (CRON) STARTUP (1.5.2)
October 20 19:27:42 li crond[733]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 76% if used.)
October 20 19:27:42 li crond[733]: (CRON) INFO (running with inotify support)
October 20 20:01:01 li CROND[1897]: (root) CMD (run-parts /etc/cron.hourly)
October 20 21:01:01 li CROND[1922]: (root) CMD (run-parts /etc/cron.hourly)
October 20 22:01:01 li CROND[1947]: (root) CMD (run-parts /etc/cron.hourly)
October 20 23:01:01 li CROND[2037]: (root) CMD (run-parts /etc/cron.hourly)

```

欲了解更多配置文件信息，请 [浏览手册页面](https://man7.org/linux/man-pages/man5/anacrontab.5.html)

## 用户使用

为了使某些文件在这些自动定义的时间内运行。 您需要做的只是复制脚本文件到相关的目录，并确保它拥有** x执行权限 (chmod +x) ** 。 因此，您只需要让系统在这些预定时间其中之一的时间自动运行脚本，这使自动化任务非常容易。

让我们每天使用 cron.day来说明/etc/anacrontab的执行过程：

1. Anacron 读取** /var/sool/anacron/cron.day** 文件，文件的内容显示最后一次执行的时间。
2. 与当前时间相比，如果两次之间的差额超过1天，则每日工作将被执行。
3. 此工作只能在 03:00-22:00进行。
4. 检查一个文件是否在系统启动后5分钟内执行。 当第一个执行时，将会随机延迟0~45分钟来执行下一个。
5. 使用好参数来指定默认的优先级，并使用运行器参数来执行/etc/cron.daily/目录中的所有可执行文件。

## 命令相关的

使用命令 `anacron`, 通常使用的选项有：

| 选项 | 说明                         |
| -- | -------------------------- |
| -f | 执行所有作业，忽略时间戳               |
| -u | 将时间戳更新到当前时间，而不执行任何操作       |
| -T | 测试配置文件/etc/anacrontab 的有效性 |

欲了解更多帮助信息，请 [浏览手册页面](https://man7.org/linux/man-pages/man8/anacron.8.html)
