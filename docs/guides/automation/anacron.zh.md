---
title: anacron - 自动化命令
author: 李天赐
contributors: 史蒂文 斯本
update: 2021-10-20
---

# anacron - 自动化命令执行工具

## 先决条件

- 一台运行Rocky Linux的计算机
- 知道如何使用您最喜欢的编辑器，来修改命令行环境中的配置文件(例如 *vim*)。
- 了解基本RPM软件包管理

## 前提条件

- 您已经掌握了bash、 python 或其他脚本/编程工具的使用，并且想要运行自动化脚本。
- 您已经以 root 用户的身份登录，或者使用 `su 切换到 root`

## Anacron 介绍

`anacron`定期运行命令，运行频率以天为单位。 这项指令适用于不全天候工作的计算机，如笔记本和台式计算机。 假如您每天早上需要用crontab执行一个计划的任务(如备份脚本)。 当你入睡时，你的台式机或笔记本电脑是关闭的。 备份脚本将不会执行. 然而，在设定好 `anacron`后，每当打开台式/笔记本电脑时，备份脚本将会自动被执行。

Anacron 并不为了取代crontab，而是对crontab的补充。 它们的关系如下：

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
shell > cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron
# See anacron(8) and anacrontab(5) for details.
SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# 每个指定作业的默认延迟为45分钟，随机增加0-45分钟。
RANDOM_DELAY=45
# 指定工作时间范围 比如如下示例代表 3:00~22:00
START_HOURS_RANGE=3-22
# 作业标识符命令的延迟时间（以天为单位）
# 每天启动来检查目录 /etc/cron.daily 文件在5分钟内被执行, 若今日没有执行, 则推迟到下一次执行
1 5 cron.daily nice run-parts /etc/cron.daily
# 启动后检查 /etc/cron.weekly 目录，每7天在25分钟内执行一次，若一周内未执行，则将在下一次执行
7 25 cron.weekly nice run-parts /etc/cron.weekly
# 启动后检查 /etc/cron.monthly 目录中的文件, 每月45分钟内执行一次
@monthly 45 cron.monthly nice run-parts /etc/cron.monthly
```

**/etc/cron.hourly/** 通过 `journalctl -u crond.service`, 你可以知道放在此文件夹内的文件实际上是被 crond.server 服务调用的。 因此这些命令将在每小时第一分钟后执行。 例如：

```bash
shell > cat /etc/cron.d/0hourly
# 每小时执行任务
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
01 *  *  *  * root run-parts /etc/cron.hourly
```

```bash
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

为了使某些文件在指定的时间内运行， 你需要做的是：复制脚本文件到相关的目录，并确保它拥有 ** 执行权限 (chmod +x) ** 。 因此，您只需要让系统在设定的时间范围内自动运行脚本，这让运行计划任务非常容易。

让我们使用 cron.daily 文件来说明 /etc/anacrontab的执行过程：

1. `anacron` 读取 **/var/spool/anacron/cron.daily** 文件, 对应文件内容显示最后一次执行时间.
2. 与当前时间相比，如果二者相差达到1天，那么corn.daily将被执行。
3. 此任务只能在 03:00-22:00进行。
4. 检查一个文件是否在系统启动后5分钟内执行。 当第一个文件被执行后，将会随机延迟0~45分钟来执行第二个。
5. 使用nice参数指定默认优先级，并使用run-parts参数运行/etc/cron.daily/目录中的所有可执行文件。

## 相关命令

命令 `anacron`, 通常使用的参数有：

| 参数 | 说明                         |
| -- | -------------------------- |
| -f | 执行所有作业，忽略时间戳               |
| -u | 将时间戳更新到当前时间，而不执行任何操作       |
| -T | 测试配置文件/etc/anacrontab 是否有效 |

欲了解更多帮助信息，请 [浏览手册页面](https://man7.org/linux/man-pages/man8/anacron.8.html)
