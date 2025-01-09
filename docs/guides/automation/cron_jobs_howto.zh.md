---
title: cron - 自动化命令
author: 史蒂文 斯本
contributors: 埃泽奎尔-布鲁尼、甘娜-日尔诺娃
tested on: 2021-10-22
tags:
  - 工作自动化
  - 自动化
  - cron
---

# 使用 `cron` 和 `crontab` 自动处理

## 先决条件

- 一台运行Rocky Linux的计算机
- 使用自己喜欢的编辑器，从命令行修改配置文件(这里使用 `vi`)

## 前提条件

- 有关于基础、python或其他脚本/编程工具的基本知识，以及希望自动运行脚本。
- 要么以超级管理员身份运行，要么用 `sudo -s` 命令获取权限运行
  **(你可以作为个人用户在自己的私人目录中运行某些脚本。 在这种情况下，不需要切换到 root。 )**

## 介绍

Linux为流程自动化提供了 *cron* 系统，一个基于时间的作业计划器。 它是很简单，但却相当强大。 想要一个脚本或程序在每天下午 5 点运行吗？ 设置这里就对了。

*crontab* 本质上是一个列表，用户可以在其中添加自己的自动化任务和作业，它有许多选项可以进一步简化事情。 本文将探讨其中的一些问题。 对于那些具有一些经验的人来说，这是一个很好的温习，新用户可以将 `cron` 系统添加到他们的知识中。

这里简要讨论的是 `anacron` 与 `cron.` 开头的目录的关系。 `cron`由`anacron`运行，对于并非始终处于运行状态的机器（如工作站和笔记本电脑）很有帮助。 原因是 `cron` 按计划运行任务， 如果计划任务该执行时机器已关闭，任务将不会运行。 当机器再次运行时，使用 `anacron` 任务会被拿起并运行。 即使计划运行是过去。 不过，`anacron`使用了一种更随机的方法来运行计时不准确的任务。 这对工作站和笔记本电脑来说是合适的，但对服务器来说则不然。 对于服务器备份等需要在特定时间运行作业的事情来说，这可能是一个问题。 这就是`cron`为服务器管理员提供最佳解决方案的地方。 不过，服务器管理员和工作站或笔记本电脑用户可以从这两种方法中获益。 您可以根据您的需要轻松地混合和匹配。 关于 `anacron` 的更多信息，见 [anacron - 自动命令](anacron.md)。

### 轻松开始之 `cron.` 开头的目录

现在，许多版本的Linux系统都内置了`cron.` 开头的目录，有助于快速自动化进程。 这些将被 `cron` 根据他们的命名约定进行调用。 然而，根据分配给调用它们的进程，`anacron`或`cron`，它们的运行方式不同。 默认行为是使用 `anacron`, 但这可以由服务器、 工作站或笔记本管理员来更改。

#### 服务器

如介绍中提到，`cron` 现在通常使用 `anacron` 服务来运行这些 cron. 开头目录中的脚本。 你 *可能* 也想要在服务器上使用这些目录, 如果情况是这样, 你可以采取两个步骤来确保这些目录是按严格的时间表运行的。 为此，我们需要安装一个软件包并删除另一个软件包：

`dnf install cronie-noanacron`

和

`dnf remove cronie-anacron`

这将从服务器上移除 `anacron` 并恢复到按照严格的时间表在目录中运行任务。 在 `/etc/cron.d/dailyjobs` 文件内控制具体时间表, 包括以下内容：

```bash
# 如果未安装 cronie anacron，则运行每日、每周和每月作业
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# 运行模块
02 4 * * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.daily
22 4 * * 0 root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.weekly
42 4 1 * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.monthly
```

当前配置将转化为以下内容:

- 每天 04:02:00 运行 `cron.daily` 目录下的所有脚本
- 每周周日 04:22:00 运行 `cron.weekly` 目录中的所有脚本
- 在每月的第一天 04:42:00 运行 `cron.monthly` 目录中的所有脚本。

#### 工作站

如果你想在工作站或笔记本电脑的 `cron.` 开头的目录中添加脚本文件，你不需要做任何复杂的操作。 只需将脚本文件复制到相关目录，并确保它是可执行的。 以下是这些目录：

- `/etc/cron.hourly` - 在这个目录下的脚步文件将每过一小时运行一次 (由 `cron` 运行, 无论 `anacron` 是否存在)
- `/etc/cron.daily` - 放在这个目录的脚本将每天运行一次, `anacron` 调整了这些任务的时间。 (具体调整见提示)
- `/etc/cron.weekly` - 放置在这个目录的脚本每7天运行一次, 基于上次运行时的时间(见提示)
- `/etc/cron.monthly` - 放在这里的脚本将每月运行, 基于上次运行时的时间(见提示)

!!! tip "提示"

    这些脚本很可能每天、每周和每月都会在类似 (但并非完全相同) 的情况下运行。 更确切的运行时间，请参阅下面的@options

只要你擅长让系统自动运行你的脚本，并允许它们在指定时间段的某个时间运行，它就能使任务自动化。

!!! note "注意"

    没有规定说服务器管理员不能使用 `anacron` 用随机的时间范围内在 cron. 开头的目录中运行脚本。 这样做的用例是一个对时间不敏感的脚本。

### 创建您自己的 `cron`

如果[上述工作站](#_5)中的自动随机时间和[上述服务器](#_4)中的计划时间不能很好地工作，你可以创建自己的任务计划。 在这个例子中，假设您是以root用户的身份执行此操作。 [如前所述](#_2), 要创建自己的 cron，请输入以下内容：

`crontab -e`

这将会拉取 root 用户的 `crontab` 内容，将会显示在你选定的编辑器中，看起来像这样。 继续阅读里面的注释内容，因为它包含了我们下一步操作的说明：

```text
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

请注意，这个特定的 `crontab` 文件内置了一些自己的文档。 情况并非总是如此。 在容器或极简主义操作系统上修改`crontab`时，除非其中已有计划任务，否则`crontab`将是一个空文件。

让我们假设有一个备份脚本，想要在晚上 10 点运行。 `crontab` 使用了一个24小时制，所以这将是22:00。 让我们假定备份脚本叫做“backup”，它目前位于 */usr/local/sbin* 目录中。

!!! note "注意"

    请记住，这个脚本也需要可执行(`chmod +x`) 权限，才能被 `cron` 运行。

列出当前正在运行的任务

`crontab -l`

列出用户创建的所有任务

`crontab -l -u <username>`

要添加任务，你可以：

`crontab -e`

`crontab`代表“cron-table”，文件的格式实际上是一个松散的表格布局。 现在我们在 `crontab` 文件中，到文件末尾，然后添加你的新条目。 如果你使用 `vi` 作为系统默认编辑器，那么使用以下按键完成上述操作：

++shift+colon+"$"++

现在你处于文件底部， 插入一行并输入简短的注释来描述您的条目要执行什么任务。 这是通过在行首添加一个“#”来完成的：

`# 每晚在 10 点备份系统`

点击 ++enter++ 键. 当前仍然应该在插入模式，下一步是添加条目。 如注释 `crontab` 所述，指定分钟(minute) 用 **m**、指定小时(hour) 用 **h**、指定月份中的某一天(day of month) 用 **dom** 、 指定具体月份(month) 用 **mon** 和指定一周中的某一天(day of week) 用 **dow** 配置.

要想每天晚上 10:00 时运行我们的备份脚本，该条目看起来就像这样：

`00  22  *  *  *   /usr/local/sbin/backup`

这表明脚本是每天下午 10 点运行，每个月和每周的每一天都是如此。 这是一个简单的例子，当你需要了解细节时，事情可能会变得相当复杂。

### `crontab` 的 @options

在严格计划的时间(即日、周、月、年等)运行作业的另一种方法是使用 @options ，它提供了更自然的计时能力。 @options 由以下内容组成：

- `@hourly` 每天每隔一小时运行一次脚本，时间为小时后0分钟 (这也正是将脚本放在 `/etc/cron.hourly` 中的结果).
- `@daily` 每天午夜运行脚本。
- `@weekly` 每周在星期日午夜运行脚本。
- `@monthly` 每月在该月第一天午夜运行脚本。
- `@year` 每年在1月第一天午夜运行脚本。
- `@reboot` 仅在系统启动时运行脚本。

!!! note "注意"

    使用这些`crontab`条目绕过了`anacron`系统，并恢复到`crond.service`，不管是否安装了`anacron`。

对于我们的备份脚本示例，如果我们使用 @daily 选项在午夜运行备份脚本，那么该条目看起来就像这样：

`@daily  /usr/local/sbin/backup`

### 更多复杂选项

到目前为止，使用的解决方案都是非常简单的选择，但更复杂的任务时间呢？ 假设你想在一天中每10分钟运行一次备份脚本(可能不是一件实际的事情，但这只是一个例子！)。 要完成这件事情, 你的 crontab 要这样写:

`*/10  *   *   *   *   /usr/local/sbin/backup`

如果你想每10分钟运行一次备份，但只在周一、周三和周五运行，可以这么写：

`*/10  *   *   *   1,3,5   /usr/local/sbin/backup`

除了周六和周日，每天每10分钟运行一次可以这样写：

`*/10  *   *   *    1-5    /usr/local/sbin/backup`

在表中，逗号用于指定字段中的单个条目，破折号用于指定字段内的值范围。 任何字段均适用这个规则，多字段同时配置的情况下同时生效。 正如你所看到的，事情可能会变得相当复杂。

当决定何时运行脚本时，你需要花费时间并规划它，尤其是很复杂的情况下。

## 结语

*cron/crontab* 系统是Rocky Linux系统管理员或桌面用户的强大工具。 它允许你自动化任务和脚本，这样就不必按时手动运行它们。 更复杂的例子如下：

- 对于那些 **不**是24小时运行的机器，浏览 [anacron - 自动化命令](anacron.md).
- 关于 `cron` 的简明描述，请参阅 [cronie - 计划任务](cronie.md)

虽然基础并不难，但选项可能很复杂。 有关 `crontab` 的更多信息，请访问 [crontab手册页面](https://man7.org/linux/man-pages/man5/crontab.5.html)。 在大多数系统上，你还可以输入` man crontab ` 以获取命令详细信息。 你也可以在网上搜索“crontab”，这将为你提供丰富的结果，帮助你调整你的 ` crontab ` 技能。
