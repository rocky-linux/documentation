---
title: cronie - 定时任务
author: tianci li
update: 2021-10-26
---

# 前提条件

* 一台运行 Rocky Linux 的机器。
* 知道如何在命令行环境下使用您喜欢的编辑器修改配置文件（本文将使用 _vi_）。
* 您已了解 bash、python 或其他脚本/编程工具的基本知识，并期望自动运行脚本。
* 您已经通过ssh的方式连接您的机器（可以是root用户，也可以是UID大于1000的普通用户）
* 我们认为，您是非常酷的人。

# cron简介

GNU/Linux提供了*cron* 系统，这是一个基于时间的cron jobs程序，用于自动化进程。它很简单，但功能相当强大。想要一个脚本或程序在每天下午5点运行吗？cron就能做到。cron有不同的分支(或者叫变体)，它们具有相同的功能，在本文档中，使用的是 **cronie**，版本为1.5.2，您可以在[这里](https://github.com/cronie-crond/cronie)找到最新的版本与更新日志。

## cronie的说明

* **cronie** - 软件包名称，默认情况下，Rocky Linux就包含了cronie这个软件包；
* **crontab** - 命令，用于维护每个用户的crontab（任务时间表）；
* **crond.service** - cronie的守护进程，您可以通过`systemctl start | restart | stop |`的方式管理守护进程；
* **/etc/crontab** - 给不同的用户分配cron jobs，通常我们更加习惯使用`crontab -e`的方式。例如当前登录为root用户，键入`crontab -e`，保存后会在/var/spool/cron/root 这个文件中会看到具体的 cron jobs 。
* **/var/log/cron\*** - cronie的日志，默认情况下，做了日志轮替，以日期后缀结尾。\* 这里表示通配符
* **anacron** - 属于 cronie 的一部分， 关于`anacron`的更多信息，见 [anacron - 自动化命令](anacron.zh.md)。

## crontab 命令

`crontab`是由cronie包安装后得到的命令，相比anacron，它更加适合7\*24小时工作的服务器。`crontab`的常用选项有：

```bash
-e  # 编辑crontab定时任务
-l  #  查看crontab任务
-r  # 删除当前用户所有的crontab任务
```

## cronie 的使用

要让不同的用户在不同的时间执行不同的命令（或脚本），可写入这个文件中。但是，通常我们更加习惯使用`crontab -e`的方式。

```bash
shell > cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name  command to be executed
```

|参数|含义|值范围|
|---|---|---|
|第1个 \*|一小时的第几分钟|0-59|
|第2个 \*|一天当中的第几个小时|0-23|
|第3个 \*|一个月当中的第几天|1-31|
|第4个 \*|一年当中的第几个月|1-12|
|第5个 \*|一周当中的星期几|0-7（0与7都表示星期日）|

本示例中，假设您以 root 用户身份执行此操作，键入以下内容：`crontab -e`，这将调出 root 用户的定时任务，如果您使用 vi 作为默认的系统编辑器，按<kbd>i</kbd>键进入到插入模式，输入以下内容，# 表示这是一行注释。按<kbd>Esc</kbd>退出插入模式，输入 :wq （显示在最底部） 保存退出vi，这表示在每天晚上 22 点运行一次脚本。显然，这是一个非常简单的示例，当您需要详细说明时，情况可能会变得非常复杂。

```bash
# 每晚 10 点备份系统
00  22  *  *  *   /usr/local/sbin/backup
```

!!! tip "注意"
    脚本需要有执行权限（`chmod +x`），cronie 才能运行它。

### 复杂选项

到目前为止，所讨论的内容都是非常简单的选项，但是更复杂的定时任务又该如何完成呢？

```bash
# 假设要在一天中每 10 分钟运行一次备份脚本（可能不切实际，但是，仅是一个示例！）。为此，将编写以下内容：
*/10  *   *   *   *   /usr/local/sbin/backup

# 如果您只想在星期一、星期三和星期五的每 10 分钟运行一次备份呢？:
*/10  *   *   *   1,3,5   /usr/local/sbin/backup

# 除了星期六和星期日，每天每 10 分钟备份一次又如何？
*/10  *   *   *   1-5   /usr/local/sbin/backup
```

|特殊符号|含义|
|---|---|
|* |代表任何时间。比如第一个 * 表示任意分钟，第二个 * 表示任意小时 |
|, |代表不连续时间，例如 " 0 8,12,16 * * * "，表示每天的8：00、12：00、16：00都执行一次命令 |
|- |代表连续的时间范围，比如 " 0 5 * * 1-6 ",代表周一到周六的每天凌晨五点执行一次命令 |
|*/n |代表间隔多久执行一次，比如 " */10 * * * * " 表示每间隔10分钟执行一次 |

!!! tip "注意"
    cronie所能识别的最小时间单位为1分钟；当使用比如 `30 4 1,15 * 5  command `，将导致命令在每个月的 1 号和 15 号以及每个星期五的凌晨 4:30 运行一次；一些脚本或者命令的输出信息会阻止定时任务的执行，需要使用输出重定向，例如这样的—— ` */10 * * * * /usr/local/sbin/backup &> /dev/null `

## Q & A

1. /etc/crontab 与`crontab -e`，这两种方式有什么区别吗？
   `crontab -e`不需要指定用户（默认使用当前登录的用户），而/etc/crontab 需要指定用户。
2. 指定的命令或脚本未正确的执行，应该怎么办？
   查看/var/log/cron* 文件，使用`journalctl -u crond.service`查看守护进程方面的信息，脚本是否有x权限等，进行排查。
3. 除了cronie外，还有哪些cron变体？
   [dcron](http://www.jimpryor.net/linux/dcron.html)，最新版本为4.5（2011-50-01）
   [fcron](http://fcron.free.fr/) ，最新版本为3.3.0（dev，2016-08-14）
   [bcron](http://untroubled.org/bcron/)，最新版本为0.11（2015-08-12）
   [cronsun](https://github.com/shunfei/cronsun)，最新版本0.3.5（2018-11-20）

## 总结

对于 Rocky Linux 桌面用户或系统管理员而言，cronie一个非常强大的工具。它可以让您自动执行任务和脚本，这样您就不必记住手动运行它们。虽然基础知识很简单，但实际任务可能很复杂。有关 crontab 的更多信息，请访问 [crontab 手册页](https://man7.org/linux/man-pages/man5/crontab.5.html)。您还可以简单地在网上搜索“crontab”，它将为您提供大量搜索结果，帮助您微调 crontab 表达式。
