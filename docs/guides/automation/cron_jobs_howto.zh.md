---
title: 定时工作任务
author: Unknown
contributors: tianci li
update: 2021-10-20
---

# 使用cron和anacron执行定时任务

## 前提条件

* 一台运行 Rocky Linux 的机器。
* 知道如何在命令行环境下使用您喜欢的编辑器修改配置文件（本文将使用 *vi*）。

## 假设

* 您已了解 bash、python 或其他脚本/编程工具的基本知识，并期望自动运行脚本。
* 您已以 root 用户身份运行，或使用 `sudo -s` 切换到 root 用户。
**（您可以以自己的用户身份在自己的目录中运行某些脚本。在这种情况下，无需切换到 root。）**

# anacron简介
**anacron用于定期运行命令，以天为单位进行定义，它适用于在笔记本电脑和台式机等不会全天候7*24运行的计算机上**。假设您有一个计划的任务(比如备份脚本)要在每天午夜使用cron运行，当您睡着的时候，此时您的台式机/笔记本电脑已经关闭。您的备份脚本将不会执行。但是，如果您使用anacron，您可以放心，下次再次打开台式机/笔记本电脑时，将执行备份脚本。

## anacron自动任务

首先查看默认的配置文件：
```bash
shell > cat /etc/anacontab
# /etc/anacrontab: configuration file for anacron
# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# 默认45分钟，指定anacrontab中每个作业的延迟将随机增加0到45分钟。
RANDOM_DELAY=45
#指定作业的时间范围，这里表示3：00~22：00
START_HOURS_RANGE=3-22

#period in days   delay in minutes   job-identifier   command
# 每天开机5分钟后就检查 /etc/cron.daily 目录内的文件是否被执行，如果今天没有被执行，那就执行下一个
1	5	cron.daily		nice run-parts /etc/cron.daily
# 每隔7天开机后25分钟检查 /etc/cron.weekly 目录内的文件是否被执行，如果一周内没有被执行，就会执行下一个
7	25	cron.weekly		nice run-parts /etc/cron.weekly
# 每隔一个月开机后 45 分钟检查 /etc/cron.monthly 目录内的文件是否被执行
@monthly 45	cron.monthly		nice run-parts /etc/cron.monthly
```
 
 **/etc/cron.hourly/** - 放置在此处的脚本将在开机后1分钟运行。通过 /etc/cron.d/0hourly 可以知道

为了使某些文件在这些自动定义的时间内运行，您所需要做的就是将脚本文件复制到相关目录中，并确保其拥有**x（执行）权限**。因此，您只要让系统在这些预定时间之一自动运行脚本就可以了，这使自动化任务变得非常容易。

我们用 cron.daily 工作来说明一下 /etc/anacrontab 的执行过程:
1. 读取 **/var/spool/anacron/cron.daily** 文件中 anacron 上一次执行的时间。
2. 和当前时间比较，如果两个时间的差值超过 1 天，就执行 cron.daily 工作。
3. 只能在 03：00-22：00 执行这个工作。
4. 开机5分钟检查有文件是否被执行，当执行第一个后，再随机延迟 0～45 分钟执行下一个。
5. 使用 nice 参数指定默认优先级，使用  run-parts 参数执行 /etc/cron.daily/ 目录中所有的可执行文件。

# crontab简介

`crontab`是由cronie安装包安装后得到的命令，相比anacron，它更加适合7\*24小时工作的服务器，而且具有守护进程 **crond.service**
。`crontab`的常用选项有：
```bash
-e  # 编辑crontab定时任务
-l  #  查看crontab任务
-r  # 删除当前用户所有的crontab任务
```
## 使用crontab
首先查看配置文件，告诉你如何自定义时间：
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
|第1个 *|一小时的第几分钟|0-59|
|第2个 *|一天当中的第几个小时|0-23|
|第3个 *|一个月当中的第几天|1-31|
|第4个 *|一年当中的第几个月|1-12|
|第5个 *|一周当中的星期几|0-7（0与7都表示星期日）|

本示例中，假设您以 root 用户身份执行此操作。为此，请参考 假设，键入以下内容：

`crontab -e`

这将调出 root 用户的 crontab，就像它此时存在于您选择的编辑器中一样。假设有一个备份脚本，希望在晚上 10 点运行。crontab 使用 24 小时制，因此应该是 22:00。假设备份脚本名为“backup”，并且当前位于 */usr/local/sbin* 目录中。

注意：这个脚本也需要是可执行的（`chmod +x`），cron 才能运行它。要添加作业：

`crontab -e`

现在在 crontab 中，转到文件的顶部并添加新条目。如果您使用 vi 作为默认的系统编辑器，那么可以通过<kbd>i</kbd>键进入到插入模式。
现在，您位于文件的顶部，插入一行并键入简短的注释以描述条目的内容。注释是通过在首行添加“＃”来完成的：
```bash
# 每晚 10 点备份系统
```
您应该仍然处于插入模式，现在按<kbd>Enter</kbd>，下一步是添加条目。

`00  22  *  *  *   /usr/local/sbin/backup`

`:wq` 退出vi交互，这表示在每天晚上 22 点运行一次脚本。显然，这是一个非常简单的示例，当您需要详细说明时，情况可能会变得非常复杂。

### crontab 的 @ 选项

如本文档上面的部分所述，cron 点目录中的脚本在特定的时间运行。@ 选项提供使用更自然的定时能力。@ 选项包括：

* `@hourly` 在每天每小时的 0 分钟后运行脚本。
* `@daily` 在每天午夜运行脚本。
* `@weekly` 在每周的周日午夜运行脚本。
* `@monthly` 在每个月的第一天午夜运行脚本。
* `@yearly` 在每年 1 月 1 日午夜运行脚本。
* `@reboot` 仅在系统启动时运行脚本。

对于备份脚本示例，如果使用 @daily 选项在午夜运行备份脚本，则该条目将如下所示：

`@daily  /usr/local/sbin/backup`

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
|*|代表任何时间。比如第一个 * 表示任意分钟|
|,|代表不连续时间，例如 " 0 8,12,16 * * * "，表示每天的8：00、12：00、16：00都执行一次命令|
|-|代表连续的时间范围，比如 " 0 5 * * 1-6 ",代表周一到周六的每天凌晨五点执行一次命令|
|*/n|代表间隔多久执行一次，比如 " */10 * * * * "表示每间隔10分钟执行一次|

! note "注意"
    crontab所能识别的最小时间单位为1分钟。
    当出现比如" 30 4 1,15 * 5  command "，将导致在每个月的1号和15号或者每个星期五的凌晨4：30运行一个命令。
    一些脚本或者命令的输出信息会阻止定时任务的执行，需要使用输出重定向，例如 " */10 * * * * /usr/local/sbin/backup &> /dev/null "这样的。

# 总结

对于 Rocky Linux 桌面用户或系统管理员而言，cron和anacron 是一个非常强大的工具。它可以让您自动执行任务和脚本，这样您就不必记住手动运行它们。

虽然基础知识很简单，但实际任务可能很复杂。有关 crontab 的更多信息，请访问 [crontab 手册页](https://man7.org/linux/man-pages/man5/crontab.5.html)。您还可以简单地在网上搜索“crontab”，它将为您提供大量搜索结果，帮助您微调 crontab 表达式。
