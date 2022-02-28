---
title: cron - 自动化命令
author: 史蒂文 斯本
contributors: 埃泽基尔·布鲁尼
update: 2021-10-22
---

# 使用 `cron` 和 `crontab 自动处理`

## 先决条件

* 运行Rocky Linux的机器。
* 能够使用编辑器(这里使用`vi`) 在命令行中的修改配置文件

## <a name="assumptions"></a> 前提条件

* 有关于基础、python或其他脚本/编程工具的基本知识，以及希望自动运行脚本。
* 您要么以根用户身份运行，要么已用 `sudo-s`  
  **切换到 root (您可以作为自己的用户在自己的目录中运行某些脚本。 在这种情况下，不需要切换到 root。)**
* 我们假定你非常酷。

## 介绍

Linux为流程自动化提供了 _cron_ 系统，一个基于时间的作业计划器。 它是很简单，但却相当强大。 想要一个脚本或程序每天在 5 PM运行吗？ 这是您设置的地方。

_crontab_ 基本上是一个用户添加自己的自动任务和工作的列表。 而且它有一些可以进一步简化事情的备选办法。 本文将探讨其中的一些问题。 对于那些具有一些经验的人来说，这是一个很好的温习，新用户可以将 `cron` 系统添加到他们的知识中。

`anacron` 在这里以 `cron` "dot" 目录的形式简短讨论。 `anacron` 由 `cron`运行， 而且对并非一直都在使用的机器，如工作站和笔记本计算机具有优势。 原因是 `cron` 按计划运行任务， 如果计划任务时机器已关闭，任务将不运行。 使用 `anacron` 当机器再次运行时，任务会被拿起并运行。 即使计划运行是过去。 `anacron` 不过，在时间不准确的情况下，使用更多的随机方式来运行任务。 这对工作站和膝上型计算机来说是可以的，但对服务器来说却是不合适的。  这可能是像服务器备份这样的问题，而这种备份需要在特定时间运行。 那就是 `cron` 继续为服务器管理员提供最好的解决方案。 尽管如此，服务器管理员和工作站或笔记本电脑用户可以从这两种方法中获得一些好处。 您可以根据您的需要轻松地混合和匹配。  关于 `anacron` 的更多信息，见 [anacron - 自动命令](anacron.md)。

### <a name="starting-easy"></a>启动简单- `cron.d` 目录

现在构建到许多版本的 Linux 系统中， `cron` "dot" 目录有助于快速自动处理。 这些将被 `cron` 根据他们的命名约定进行调用。 然而，他们被不同的调用，基于谁来调用他们， `anacron` 或 `cron` 默认行为是使用 `anacron`, 但这可以由服务器、 工作站或笔记本管理员来更改。

#### <a name="for_servers"></a>服务器

如导言所述， `cron` 通常运行 `anacron` 这些天来执行这些"dot"目录中的脚本。 你 *可能*, 但也想要在服务器上使用这些"点"目录, 如果情况是这样。 然后您可以采取两个步骤来确保这些"点"目录是按严格的时间表运行的。 为此，我们需要安装一个软件包并删除另一个软件包：

`dnf install cronie-noanacron`

和

`dnf remove cronie-anacron`

正如你可能期望的那样，这将从服务器上移除 `anacron` 并恢复到严格的计划中的“dot”目录内的任务。 这个定义在了: `/etc/cron.d/dailyjob`, 其中包含以下内容：

```
# 每日运行，每周运行， 如果未安装 cronie-anacron
SHELL=/bin/bash
PATH=/sbin:/usr/sbin:/bin
MAILTO=root

# run-parts
02 * * * * root [ ！ -f /etc/cron.hourly/0anacron ] && run-part /etc/cron.day
22 4 * 0 root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.weekly
42 4 1 * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.monthly
```

这就意味着：

* 运行脚本 `cron.daily` 于每日04:02:00。
* 运行脚本`cron.weekly` 于每周的周日 04:22:00。
* 运行脚本 `cron.monthly` 于每月第一天04:42:00。

#### <a name="for_workstations"></a>工作站

如果您想要在一个工作站或笔记本电脑在 `cron`  "."目录中运行脚本 那么你不需要做任何特殊事。 只需将您的脚本文件复制到相关目录，并确保它是可执行的。 以下是这些目录：

* `/etc/cron.hourly` - 放置在这里的脚本将每小时运行一次。 (这是由 `cron` 运行的，无论 `anacron` 是否安装)
* `/etc/cron.daily` - 放在这里的脚本将每天运行。 `anacron` 调整了这些任务的时间。 （参考提示）
* `/etc/cron.week` - 放置在这里的脚本每7天运行一次。 （参考提示）
* `/etc/cron.monthly` - 放在这里的脚本将每月运行。 （参考提示）

!!! 提示

    这些活动很可能每天、每周和每月都会在类似（但并非完全相同）的情况下进行。 更确切的运行时间，请参阅下面的@options

所以让系统自动运行您的脚本，让您也能正常运行， 并且允许他们在指定的时间段内运行，然后它会使任务自动化变得非常容易。

!!! 说明

    没有规定说服务器管理员不能随意运行 'anacron' 的"."目录中的脚本。 对此使用的大小写将是一个不具有时间敏感性的脚本。

### 创建您自己的 `cron`

当然，如果自动、随机化的时间在 [对超过](#for-workstations)的工作站来说不那么合适， 和 [中的预定时间。对于前面提到](#for-servers)的服务器，你可以创建自己的计划任务。 在这个例子中，我们认为您是root用户。 [见前提条件](#assumptions) 要做到这一点，请输入以下内容：

`crontab -e`

这将会拉取根用户的 `crontab` 内容，将会显示在您选定的编辑器中，可能看起来就像这样。 继续阅读里面的注释内容，因为它包含了我们下一步操作的说明：

```
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# cron
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

请注意这个特殊的 `crontab` 文件有自己的文档内置. 情况并非总是如此。 在容器或最低操作系统上修改 `crontab` 时， `crontab` 将是一个空文件，除非已经有条目已经放入它。

让我们假设我们有一个备份脚本，我们想要在晚上运行10个PM。 `crontab` 使用了一个24小时钟，所以这将是22:00。 让我们假定备份脚本叫做“backup”，它目前位于 _/usr/local/sbin_ 目录中。

!!! 说明

    请记住，这个脚本也需要可执行(`chmod +x`)，才能运行 `cron` 。

要添加作业，我们将：

`crontab -e`

`crontab` 表示"cron table"，文件的格式实际上是一个松散的表布局。 现在我们在 `crontab`中，转到文件的底部，然后添加您的新条目。 如果您使用 `vi` 作为您的系统默认编辑器，那么使用以下按键完成：

`Shift : $`

现在你处于文件底部， 插入一行并输入简短的注释来描述您的条目正在发生什么事情。 这是通过在行首添加一个“#”来完成的：

`# 每晚在 10PM 上备份系统`

现在按回车键。 您仍然应该在插入模式，下一步是添加您的条目。 如 `crontab` 上面的注释 所示，这将是 **m** 分钟， **h** 小时数， **dom** (day of month) 一个月的某天， **mon** 月份 ， **dow**(day of week) 一周的某天。

如果每天10:00时运行我们的备份脚本，该条目看起来就像这样：

`00 22 * * /usr/local/sbin/backup`

这表明脚本是每月10 PM，每个月每天、每个月和每周的每一天都是如此。 显然，这是一个非常简单的例子，当你需要具体的时候，事情可能会变得相当复杂。

### `crontab的@选项`

另一种在严格规定的时间(即白天、周、月份、年份等)进行工作的方式 使用 @options 提供了使用更加自然的时间的能力。 @options 由以下内容组成：

* `@hourly` 每小时 0 分钟运行脚本。 (这正是将您的脚本放入 `/etc/cron.hourly` 的结果)
* `@daily` 每天午夜运行脚本。
* `@weekly` 每周在星期日午夜运行脚本。
* `@monthly` 每月在该月第一天午夜运行脚本。
* `@year` 每年在1月第一天午夜运行脚本。
* `@reboot` 仅在系统启动时运行脚本。

!!! 说明

    使用这些`crontab`条目绕过了`anacron`系统，并恢复到`crond.service`，不管是否安装了`anacron`。

对于我们的备份脚本示例，如果我们使用 @daily 选项在午夜运行备份脚本，那么该条目看起来就像这样：

`@day/usr/local/sbin/backup`

### 更多复杂选项

到目前为止，我们所谈到的一切都有相当简单的选择，但是更复杂的任务时间是怎样呢？ 比如说，你想要每隔10分钟运行一次你的备份脚本(可能不是一个非常实际的事情需要做的。 但，嘿，这是一个例子！)。 要做到这一点，您将写：

`*/10  *   *   *   *   /usr/local/sbin/backup`

如果你想每隔10分钟、但仅在星期一、星期三和星期五运行备份怎么办？

`*/10  *   *   *   1,3,5   /usr/local/sbin/backup`

除星期六和星期天外，每隔10分钟？

`*/10  *   *   *    1-5    /usr/local/sbin/backup`

在表中，逗号让您在一个字段中指定单独的条目。 当破折号允许您在字段中指定一个值范围。 这可以同时在任何一个字段和多个字段发生。 如您所见，事情可能变得相当复杂。

当决定何时运行脚本时，您需要花费时间并规划它，尤其是如果标准很复杂。

## 结语

_cron/crontab_ 系统是Rocky Linux系统管理员或桌面用户非常强大的工具。 它可以允许您自动执行任务和脚本，这样您就不必记住手动运行它们了。 这里提供了更多的例子：

* 对于那些 **不**是24小时运行的机器，浏览 [anacron - 自动化命令](anacron.md).
* 关于 `cron` 的简明描述，请参阅 [cronie - 计划任务](cronie.md)

虽然基础知识非常容易，但你可以得到更多的复杂程度。 关于 `crontab` 的更多信息，直到 [crontab 手册页面](https://man7.org/linux/man-pages/man5/crontab.5.html)。 在大多数系统中，您也可以输入 `man crontab` 获取额外的命令细节。 您也可以简单地进行网页搜索“crontab”，为您提供丰富的结果，帮助您提高 `crontab` 技能。
