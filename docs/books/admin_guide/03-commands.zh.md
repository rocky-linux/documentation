---
title: Linux 命令
author: Antoine Le Morvan
contributors: Steven Spencer, Aditya Putta, tianci li, Grammaresque, Ganna Zhyrnova
---

<!-- markdownlint-disable MD025 MD007 -->
# 针对 Linux 用户的命令

在本章中，您将学习如何使用 Linux 中的命令。

****

**目标**： 在本章中，未来的 Linux 管理员们将学习如何：

:heavy_check_mark: 在系统树中 **移动**。  
:heavy_check_mark: **创建** 一个文本文件, **显示** 其内容并对其 **修改**。   
:heavy_check_mark: **使用** 最实用的Linux命令。

:checkered_flag: **用户命令**，**linux**

**知识性**: :star:  
**复杂度**: :star:

**阅读时间**: 40 分钟

****

## 概述

现代的 Linux 系统配备有专门用于协助管理员工作的图形工具。 但是，能够使用命令行模式也是很重要的，原因如下：

* 大多数系统命令对于所有 Linux 发行版都是通用的，而图形工具则不是这样。
* 可能发生的情况是——系统不能正确启动，但备份的命令解释器仍然可以被访问。
* 远程管理是通过在 SSH 终端下的命令行完成的。
* 为了节省服务器资源，图形界面要么不安装，要么按需启动。
* 管理工作是由脚本完成的。

学习这些命令可以让系统管理员通过一个 Linux 终端来管理服务器的资源、文件，识别站点、终端和已连接的用户等等。

### 用户

在 Linux系统中，用户是通过 `/etc/passwd` 文件中的以下条目定义的：

* **登录名**，更普遍的叫法是 “用户名”，不含有空格。
* 数字标识符：**UID** (用户标识符)。
* 所属组标识符：**GID** (用户组标识符)。
* **命令解释器**，例如 shell ，不同用户可以不同。
* **连接目录**，例如 **家目录** 。

在其他文件中，用户由以下条目定义：

* **密码**，它会在储存之前被加密 (`/etc/shadow`)。
* **命令提示符** 或 **登录提示符**，其符号为

    * `#` 为管理员
    * 其他用户为 `$` （`/etc/profile`）。

根据系统的安全策略，设置的密码有一定的字符数和复杂度要求。

在现有的命令解释器中，**Bourne-Again Shell** (`/bin/bash`) 是最常用的。 默认情况下，它会被分配给新用户。 出于各种原因，高阶的 Linux 用户可以选择代替品，如 Korn Shell (`ksh`)， C Shell (`csh`) 等。

通常，用户的登录目录被储存在工作站的 `/home` 目录中。 它将包含用户的个人数据和应用程序的配置文件。 默认情况下，登录时会选择 登录目录 作为当前目录。

一个工作站类型的安装 (带有图形界面) 将在终端 1 上开启此界面。 Linux是多用户的，可以在不同的 **物理终端**(TTY) 或 **虚拟终端**(PTS) 上多次连接多个用户。 虚拟终端可以在图形化环境中使用。 用户可通过 ++Alt++ + ++Fx++ 或 ++CTRL++ + ++Alt++ + ++Fx++ 来切换物理终端。

### shell

一旦用户连接到控制台，shell就会显示 **命令提示符** 。 然后，它的行为就像一个无限循环，对输入的每条语句重复相同的方式：

* 显示命令提示符。
* 读取命令。
* 分析语法。
* 替换特殊字符。
* 执行命令。
* 显示命令提示符。
* 等等

++ctrl+c++ 两个按键用于中断正在运行的命令。

命令的使用通常遵循以下顺序：

```bash
command [option(s)] [arguments(s)]
```

命令的名称通常为 **小写** 。

每一项都用空格隔开。

**短选项** 以破折号开头（`-l`），而 **长选项** 以两个破折号（`--list`）开头。 双破折号（`--`）表示选项列表的结尾。

可以将一些短选项组合在一起：

```bash
ls -l -i -a
```

等同于：

```bash
ls -lia
```

选项后面可以有多个参数：

```bash
ls -lia /etc /home /var
```

在文献资料中，术语 "option"（选项） 相当于术语"parameter"（参数），后者在编程中更常用。 选项或参数的可选部分用方括号括起来 —— `[` 和 `]`。 当可能有多个选项时，一个称为 "管道" 的垂直条将它们分隔开来 `[a|e|i]`。

## 常规命令

### `apropos`，`whatis` 和 `man` 命令

任何级别的管理员都不可能详细了解所有的命令和选项。 所以所有已经安装的命令通常都会有一个手册。

#### `apropos` 命令

命令 `apropos` 允许您在这些手册页中按关键字搜索：

| 选项                                          | 说明                 |
| ------------------------------------------- | ------------------ |
| `-s`, `--sections list` 或者 `--section list` | 仅限于手册部分。           |
| `-a` 或者 `--and`                             | 仅显示与所有提供的关键字匹配的项目。 |

示例：

```bash
$ apropos clear
clear (1)            - clear the terminal screen
clear_console (1)    - clear the console
clearenv (3)         - clear the environment
clearerr (3)         - check and reset stream status
clearerr_unlocked (3) - nonlocking stdio functions
feclearexcept (3)    - floating-point rounding and exception handling
fwup_clear_status (3) - library to support management of system firmware updates
klogctl (3)          - read and/or clear kernel message ring buffer; set console_loglevel
sgt-samegame (6)     - block-clearing puzzle
syslog (2)           - read and/or clear kernel message ring buffer; set console_loglevel
timerclear (3)       - timeval operations
XClearArea (3)       - clear area or window
XClearWindow (3)     - clear area or window
XSelectionClearEvent (3) - SelectionClear event structure
```

要查找允许更改帐户密码的命令，请执行以下操作：

```bash
$ apropos --exact password  -a change
chage (1)            - change user password expiry information
passwd (1)           - change user password
```

#### `whatis` 命令

`whatis` 命令显示命令的描述信息：

```bash
whatis clear
```

示例：

```bash
$ whatis clear
clear (1)            - clear the terminal screen
```

#### `man` 命令

手册一旦被 `apropos` 或 `whatis` 发现，就会被 `man` 读取（“手册是你的朋友”）。 这套手册分为8个部分，按主题对信息进行分组，默认部分为1：

1. 可执行的程序或命令。
2. 系统调用(内核给定的函数)。
3. 库调用(库给定的函数)。
4. 特殊文件(通常位于/dev中)。
5. 文件格式和约定(配置文件如/etc/passwd)。
6. 游戏(例如基于角色的应用程序)。
7. 杂项(如：man(7))。
8. 系统管理命令 (通常只适用于root)。
9. 非标准的内核例程。

可以通过键入 `man x intro` 访问有关每个部分的信息，其中 `x` 是数字编号。

命令：

```bash
man passwd
```

这将告诉管理员 passwd 命令及其选项等。 但这条命令：

```bash
man 5 passwd
```

将告知用户 passwd 命令有关的文件。

使用箭头 <kbd>↑</kbd> 和 <kbd>↓</kbd> 来浏览手册。 按 <kbd>q</kbd> 键退出手册。

### `shutdown` 命令

`shutdown` 命令允许您立即或在一段时间后以 **电子方式关闭** Linux服务器。

```bash
shutdown [-h] [-r] time [message]
```

应以 `hh:mm` 格式指定精准的关闭时间，或者以 `+mm` 指定延迟多长时间，单位为分钟。

若要强制立即关闭，请使用单词 `now` 来替代时间。 在这种情况下，可选的 message 不会发送给系统的其他用户。

示例：

```bash
[root]# shutdown -h 0:30 "Server shutdown at 0:30"
[root]# shutdown -r +5
```

选项：

| 选项   | 备注         |
| ---- | ---------- |
| `-h` | 以电子方式关闭系统。 |
| `-r` | 重启系统。      |

### `history` 命令

`history` 命令显示用户输入命令的历史记录。

这些命令存储在用户登录目录的 `.bash_history` 文件中。

history 命令示例

```bash
$ history
147 man ls
148 man history
```

| 选项   | 解释                                         |
| ---- | ------------------------------------------ |
| `-w` | 将当前历史记录写入到历史文件中。                           |
| `-c` | 删除当前会话的历史记录(但不会删除 `.bash_history` 文件中的内容)。 |

* 操作历史记录：

要操作历史记录，从命令提示符中输入以下命令即可：

| 键盘输入               | 功能                   |
| ------------------ | -------------------- |
| <kbd>!!</kbd>      | 调出最后使用的命令。           |
| <kbd>!n</kbd>      | 根据该命令在列表中的编号重新调用该命令。 |
| <kbd>!string</kbd> | 调出以字符串开头的最近的命令。      |
| <kbd>↑</kbd>       | 从最近的命令开始后退浏览您的历史记录。  |
| <kbd>↓</kbd>       | 往后浏览您的历史记录。          |

### 命令自动补全

自动补全功能很有用。

* 可完成命令、输入路径或文件名的补全。
* 如果是单一补全，按一下 <kbd>TAB</kbd> 键即可。
* 第二次按 <kbd>TAB</kbd> 键可获得可能的选项。

如果按两次 <kbd>Tab</kbd> 键没有显示任何选项，则当前没有可完成自动补全的选项。

## 显示和标识

### `clear` 命令

`clear` 命令表示清除终端屏幕的内容。 更准确地说，它会改变显示方式，使命令提示位于屏幕顶部的第一行。

在物理终端上的显示将被永久隐藏，而在图形界面中， 滚动条将允许您返回到虚拟终端的历史。

!!! Tip "提示"

    <kbd>CTRL</kbd> + <kbd>L</kbd> 快捷键与 `clean` 命令具有相同的效果

### `echo` 命令

`echo` 命令用来输出字符串内容。

此命令最常在管理脚本中使用，用于在执行期间通知用户。

`-n` 选项表示不换行输出（默认情况下，换行输出字符串）。

```bash
shell > echo -n "123";echo "456"
123456

shell > echo "123";echo "456"
123
456
```

由于各种原因，脚本开发人员可能需要使用特殊的转义符(以`\`字符开始)。 在这种情况下，使用 `-e` 选项，从而允许对转义符进行解释。

在常用的转义符中，我们提到的有：

| 转义符   | 结果                                           |
| ----- | -------------------------------------------- |
| `\a` | 发出警告声                                        |
| `\b` | 退格，删除前一个字符                                   |
| `\n` | 添加换行符，光标移动到下一行的行首                            |
| `\t` | 添加一个 tab 制表符                                 |
| `\v` | 换行添加垂直 tab 制表符，光标的位置不变，即上一行在什么位置，下一行还是一样的位置。 |

### `date` 命令

`date` 命令用来显示日期和时间。 该命令的语法如下：

```bash
date [-d yyyyMMdd] [format]
```

示例：

```bash
$ date
Mon May 24 16:46:53 CEST 2021
$ date -d 20210517 +%j
137
```

在最后一个示例中，`-d` 选项表示显示给定的日期。 `+%j` 选项表示将此格式转化为一年当中的第几天。

!!! Warning "警告"

    日期的格式可根据环境变量 `$LANG` 中定义的语言值而变化。

日期显示可以遵循以下格式：

| 选项    | 格式                                     |
| ----- | -------------------------------------- |
| `+%A` | 本地的完整工作日名称（例如 Sunday）                  |
| `+%B` | 本地的完整月份名称（例如，January）                  |
| `+%c` | 本地的日期与时间 （例如 Thu Mar  3 23:05:25 2005） |
| `+%d` | 月份的第几天（例如01）                           |
| `+%F` | `YYYY-MM-DD` 格式的日期                     |
| `+%G` | 年                                      |
| `+%H` | 小时 （00..23）                            |
| `+%j` | 一年中的哪一天（001..366）                      |
| `+%m` | 月份数（01..12）                            |
| `+%M` | 分钟（00..59）                             |
| `+%R` | `hh:mm` 格式的时间                          |
| `+%s` | 自1970年1月1日以来的秒数                        |
| `+%S` | 秒（00..60）                              |
| `+%T` | `hh:mm:ss` 格式的时间                       |
| `+%u` | 一周的第几天（用`1`表示星期一）                      |
| `+%V` | 周数（`+%V`）                              |
| `+%x` | `DD/MM/YYYY` 格式的日期                     |

`date`  命令还允许您更改系统的日期与时间。 在这种情况下您需要使用 `-s` 选项。

```bash
[root]# date -s "2021-05-24 10:19"
```

`-s` 选项后面使用的格式如下：

```bash
date -s "yyyy-MM-dd hh:mm[:ss]"
```

### `id`、`who` 和 `whoami` 命令

`id` 命令用于显示有关用户和组的信息。 默认情况下，没有添加用户参数，则显示当前登录用户和组的信息。

```bash
$ id rockstar
uid=1000(rockstar) gid=1000(rockstar) groups=1000(rockstar),10(wheel)
```

`-g`、`-G`、`-n` 和 `-u`选项分别表示显示主组GID、附加组GID、名称而不是数字标识符、用户的UID。

`whoami` 命令用来显示当前用户的登录信息。

`who` 命令仅显示登录的用户名：

```bash
$ who
rockstar tty1   2021-05-24 10:30
root     pts/0  2021-05-24 10:31
```

由于 Linux 是多用户的，因此很可能在同一台机器上打开了多个会话，无论是在物理机器上还是通过网络。 了解哪些用户已登录是一件很有趣的事情，即使只是通过发送消息与他们进行通信。

* tty：代表一个终端。
* pts/：表示图形环境中的虚拟控制台，后面的数字代表虚拟控制台的实例（0、1、2...）。

`-r` 选项显示运行级别（参见"startup"篇章）。

## 文件树

在 Linux 当中，文件树是一棵倒置的树，我们叫它 ** 单一层次树** ，根目录为 `/` 。

**当前目录** 是指用户所在的目录。

**连接目录** 是与用户相关联的工作目录。 默认情况下，登录目录存储在 `/home` 目录中。

用户登录时，当前目录为登录目录。

**绝对路径** 通过遍历整个树到文件级来从根目录上引用文件：

* `/home/groupA/alice/file`

**相对路径** 通过从当前目录遍历整个树来引用相同文件：

* `../alice/file`

在上面的示例中，"`..`" 指的是当前目录的父目录。

一个目录即使是空的，也必须至少包含 **两个引用** ：

* `.`：引用本身。
* `..`：引用当前目录的父目录。

因此，相对路径可以以 `./` 或者 `../` 开始。 当相对路径引用当前目录中的子目录或文件时，`./` 通常被忽略。 提到树中的第一个 `./` ，只有在运行可执行文件时才会被真正需要。

路径错误会导致很多问题：在错误的位置创建文件夹或文件，无意删除等。 因此，强烈建议在输入路径时使用自动补全功能。

![我们的示例树](images/commands-pathabsolute.png)

在上面的示例中，我们希望提供文件 `myfile` 在bob目录中的位置。

* 通过 **绝对路径** 的方式，当前目录无关紧要。 我们从根目录开始，一直到 `home` 、 `groupA` 、 `alice` 这些目录，最后到 `myfile` 这个文件：`/home/groupA/alice/myfile`。
* 通过 **相对路径** 的方式，我们的起点是当前目录`bob`，上一级我们通过 `..` 指定（即进入到`groupA`目录），然后向下进入到 alice 目录，最后是 `myfile` 文件：`../alice/myfile`。

### `pwd` 命令

`pwd` (Print Working Directory，打印工作目录) 命令显示当前目录的绝对路径。

```bash
$ pwd
/home/rockstar
```

使用相对路径引用文件或目录，或使用 `cd` 命令移动到另一个目录，您必须知道该目录在文件树中的位置。

根据 shell 的类型及其配置文件的不同参数，终端提示符（也称为命令提示符） 将显示当前目录的绝对路径或相对路径。

### `cd` 命令

`cd` (Change Directory，变更目录) 命令允许您更改当前目录——换句话就是在文件树中移动。

```bash
$ cd /tmp
$ pwd
/tmp
$ cd ../
$ pwd
/
$ cd
$ pwd
/home/rockstar
```

正如您在上面的最后一个示例中看到的，不带参数的 `cd` 命令会将当前目录移动到 `家目录` 。

### `ls` 命令

`ls` 命令用来目录中的内容。

```bash
ls [-a] [-i] [-l] [directory1] [directory2] […]
```

示例：

```bash
$ ls /home
.    ..    rockstar
```

`ls` 命令的主要选项包括：

| 选项   | 信息                                        |
| ---- | ----------------------------------------- |
| `-a` | 显示所有文件，即使是隐藏文件。 Linux 中的隐藏文件是以 `.` 开头的文件。 |
| `-i` | 显示 inode 编号。                              |
| `-l` | 使用长列表格式，即每行显示文件或目录的长格式信息。                 |

但是，`ls` 命令有很多选项（见 `man` ）：

| 选项   | 信息                                                                                                                                                                                               |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `-d` | 显示有关目录的信息，而不是列出其内容。                                                                                                                                                                              |
| `-g` | 与 -l 选项类似，但不列出所有者。                                                                                                                                                                               |
| `-h` | 以最合适的格式显示文件大小(字节、千字节、兆字节、吉字节等)。 `h` 表示人类可读。 需要与 -l 选项一起使用。                                                                                                                                       |
| `-s` | 以块为单位显示每个文件的分配大小。 在 `ls` 命令中，单个块的默认大小为 1024 字节。 在 GNU/Linux 操作系统中，"块"(block) 是文件系统中最小的存储单元，通常而言，一个块等于 4096 字节。 在 Windows 操作系统中，以 NTFS 文件系统为例，其最小的存储单元被称为 "集群"(Cluster)。 最小存储单元名称的定义可能因文件系统不同而不同。 |
| `-A` | 显示目录中除 `.` 和 `..` 之外的所有文件                                                                                                                                                                        |
| `-R` | 递归显示子目录的内容。                                                                                                                                                                                      |
| `-F` | 显示文件的类型。 为目录打印 `/` ，为执行文件打印 `*` ，为符号链接打印 `@` ，对文本文件不打印任何内容。                                                                                                                                      |
| `-X` | 根据文件的扩展名对文件进行排序。                                                                                                                                                                                 |

* 运行 `ls -lia` 命令生成的列的说明：

```bash
$ ls -lia /home
78489 drwx------ 4 rockstar rockstar 4096 25 oct. 08:10 rockstar
```

| 值               | 信息                                                                            |
| --------------- | ----------------------------------------------------------------------------- |
| `78489`         | inode 号。                                                                      |
| `drwx------`    | 文件类型 (`d`) 和权限 (`rwx------`)。                                                 |
| `4`             | 子目录的数量(包括`.`和`..`)。 对于文件，它代表硬链接的数量，1代表文件本身。                                   |
| `rockstar`      | 所有者。                                                                          |
| `rockstar`      | 所属组。                                                                          |
| `4096`          | 对于文件，它显示文件的大小。 对于目录，它显示的是文件命名所占用的4096字节的固定值。 要计算目录的总大小，请使用 `du -sh rockstar/` |
| `25 oct. 08:10` | 最后修改日期                                                                        |
| `rockstar`      | 文件（或目录）的名称。                                                                   |

!!! Note "说明"

    **别名** 经常被放置在常见的发行版中。
    
    别名 `ll` 的情况如下：

    ```
    alias ll='ls -l --color=auto'
    ```

`ls` 命令有许多选项。 以下是一些高级用法示例：

* 按上次修改的时间顺序列出 `/etc` 中的文件：

```bash
$ ls -ltr /etc
total 1332
-rw-r--r--.  1 root root    662 29 may   2021 logrotate.conf
-rw-r--r--.  1 root root    272 17 may.   2021 mailcap
-rw-------.  1 root root    122 12 may.  2021 securetty
...
-rw-r--r--.  2 root root     85 18 may.  17:04 resolv.conf
-rw-r--r--.  1 root root     44 18 may.  17:04 adjtime
-rw-r--r--.  1 root root    283 18 may.  17:05 mtab
```

* 列出 `/var` 中大于1MB但小于1GB的文件。 这里的示例使用了正则表达式的高级 `grep` 命令。 新手不必太纠结，将来会有专门的教程来介绍这些正则表达式。

```bash
$ ls -lhR /var/ | grep ^\- | grep -E "[1-9]*\.[0-9]*M" 
...
-rw-r--r--. 1 apache apache 1.2M 10 may.  13:02 XB RiyazBdIt.ttf
-rw-r--r--. 1 apache apache 1.2M 10 may.  13:02 XB RiyazBd.ttf
-rw-r--r--. 1 apache apache 1.1M 10 may.  13:02 XB RiyazIt.ttf
...
```

当然，我们强烈建议您使用 `find` 命令。

```bash
find /var -size +1M -a -size -1024M  -a -type f  -exec ls -lh {} \;
```

* 显示文件夹的权限：

要找出文件夹的权限，在我们的示例 `/etc` 中，使用以下命令是 **不** 合适的：

```bash
$ ls -l /etc
total 1332
-rw-r--r--.  1 root root     44 18 nov.  17:04 adjtime
-rw-r--r--.  1 root root   1512 12 janv.  2010 aliases
-rw-r--r--.  1 root root  12288 17 nov.  17:41 aliases.db
drwxr-xr-x.  2 root root   4096 17 nov.  17:48 alternatives
...
```

默认情况下，上述命令将显示文件夹（里面）的内容。 对于文件夹本身，您可以使用 `-d` 选项。

```bash
ls -ld /etc
drwxr-xr-x. 69 root root 4096 18 nov.  17:05 /etc
```

* 按文件大小排序，最大优先：

```bash
ls -lhS
```

* 使用 `-l` 的 时间/日期 格式：

```bash
$ ls -l --time-style="+%Y-%m-%d %m-%d %H:%M" /
total 12378
dr-xr-xr-x. 2 root root 4096 2014-11-23 11-23 03:13 bin
dr-xr-xr-x. 5 root root 1024 2014-11-23 11-23 05:29 boot
```

* 将 _反斜杠_ 添加到文件夹的末尾：

默认情况下，`ls` 命令不显示文件夹的最后一个斜杠。 在某些情况下，例如对于脚本，显示它们很有用：

```bash
$ ls -dF /etc
/etc/
```

* 隐藏一些扩展名：

```bash
ls /etc --hide=*.conf
```

### `mkdir` 命令

`mkdir` 命令用来创建目录或目录树。

```bash
mkdir [-p] directory [directory] [...]
```

示例：

```bash
mkdir /home/rockstar/work
```

必须存在 "rockstar" 目录才能创建 "work" 目录。

否则，应使用 `-p` 选项。 `-p` 选项会创建父目录（如果父目录不存在的话）。

!!! Danger "危险"

    不建议将 Linux 命令名称用作目录名或文件名。

### `touch` 命令

`touch` 命令用来更改文件的时间戳，或者如果文件不存在，则创建一个空文件。

```bash
touch [-t date] file
```

示例：

```bash
touch /home/rockstar/myfile
```

| 选项        | 信息                 |
| --------- | ------------------ |
| `-t date` | 用指定的日期更改文件的最后修改日期。 |

日期格式：`[AAAA]MMJJhhmm[ss]`

!!! Tip "提示"

    `touch`命令主要用来创建空文件，但它对于增量备份或差异备份也很有用。 事实上，对一个文件执行 `touch` 的唯一效果是强迫它在下一次备份中被保存。

### `rmdir` 命令

`rmdir` 命令用来删除空目录。

示例：

```bash
rmdir /home/rockstar/work
```

| 选项   | 信息                      |
| ---- | ----------------------- |
| `-p` | 删除所提供的父目录或目录（如果它们是空的话）。 |

!!! Tip "提示"

    要同时删除非空目录及其内容，请使用 `rm` 命令。

### `rm`命令

`rm` 命令用来删除文件或目录。

```bash
rm [-f] [-r] file [file] [...]
```

!!! Danger "危险"

    任何文件或目录的删除结果都是不可以改变的。

| 选项   | 信息             |
| ---- | -------------- |
| `-f` | 不询问是否删除        |
| `-i` | 询问是否删除。        |
| `-r` | 删除目录并递归删除其子目录。 |

!!! Note "说明"

    `rm`命令本身在删除文件时不会被询问。 然而，对于Red Hat/Rocky 发行版，`rm` 会询问是否要删除，因为 `rm` 命令是 `rm -i` 命令的 `alias` 。 如果在另一个发行版上，例如 Debian ，您不会收到询问请求，请勿感到意外。

使用 `rm` 命令删除文件夹，无论该文件夹是否为空，都需要添加 `-r` 选项。

选项的末尾通过双破折号 `--` 向shell发送信号。

在该示例中：

```bash
$ >-hard-hard # To create an empty file called -hard-hard
hard-hard
[CTRL+C] To interrupt the creation of the file
$ rm -f -- -hard-hard
```

hard-hard 的文件名是以 `-` 开始的。 如果没有使用 `--` ，shell会将 `-hard-hard` 中的 `-d` 解释为一个选项。

### `mv` 命令

`mv` 命令用来移动和重命名文件。

```bash
mv file [file ...] destination
```

示例：

```bash
mv /home/rockstar/file1 /home/rockstar/file2

mv /home/rockstar/file1 /home/rockstar/file2 /tmp
```

| 选项   | 信息                  |
| ---- | ------------------- |
| `-f` | 如果要覆盖目标文件，不要询问。     |
| `-i` | 如果覆盖目标文件，则请求询问(默认)。 |

以下几个具体案例将帮助您了解可能出现的难题：

```bash
mv /home/rockstar/file1 /home/rockstar/file2
```

将 `file1` 重命名为 `file2`。 如果 `file2` 已经存在，则将文件内容替换为`file1`。

```bash
mv /home/rockstar/file1 /home/rockstar/file2 /tmp
```

将 `file1` 和 `file2` 移动到 `/tmp` 目录。

```bash
mv file1 /repexist/file2
```

将 `file1` 移动到 `repexist` 目录中并重命名为 `file2`。

```bash
mv file1 file2
```

`file1` 已重命名为 `file2` 。

```bash
mv file1 /repexist
```

如果目标目录存在， 则 `file1` 将移动到 `/repexist` 中。

```bash
mv file1 /wrongrep
```

如果目标目录不存在，`file1` 将在根目录中被重命名为 `wrongrep` 。

### `cp` 命令

`cp` 命令用来复制文件。

```bash
cp file [file ...] destination
```

示例：

```bash
cp -r /home/rockstar /tmp
```

| 选项   | 信息                  |
| ---- | ------------------- |
| `-i` | 要求确认是否覆盖（默认）。       |
| `-f` | 如果覆盖目标文件，不会要求确认。    |
| `-p` | 保留复制文件时的所有者、权限和时间戳。 |
| `-r` | 复制目录及其文件和子目录。       |
| `-s` | 创建符号链接，而不是复制。       |

```bash
cp file1 /repexist/file2
```

`file1` 将复制到 `/repexist` 目录下，且文件名为 `file2` 。

```bash
cp file1 file2
```

在此目录中，`file1` 已经复制为 `file2` 。

```bash
cp file1 /repexist
```

如果目标目录存在，则 `file1` 将被复制到 `/repexist` 目录中。

```bash
cp file1 /wrongrep
```

如果目标目录不存在，`file1` 将在根目录中被重命名为 `wrongrep` 。

## 可视化

### `file` 命令

`file` 命令用来显示文件的类型。

```bash
file file1 [files]
```

示例：

```bash
$ file /etc/passwd /etc
/etc/passwd:    ASCII text
/etc:        directory
```

### `more` 命令

`more` 命令用来通过屏幕显示一个或多个文件的内容。

```bash
more file1 [files]
```

示例：

```bash
$ more /etc/passwd
root:x:0:0:root:/root:/bin/bash
...
```

使用 <kbd>ENTER</kbd> 回车键可逐行移动。 使用 <kbd>SPACE</kbd> 空格键可逐页移动。 `/text` 允许您在文件中搜索匹配项。

### `less` 命令

`less` 命令用来显示一个或多个文件的内容。 `less` 命令是交互式的，并且有自己的命令可供使用。

```bash
less file1 [files]
```

`less`的特定命令有：

| 命令                                               | 动作             |
| ------------------------------------------------ | -------------- |
| <kbd>h</kbd>                                     | 帮助。            |
| <kbd>↑</kbd><kbd>↓</kbd><kbd>→</kbd><kbd>←</kbd> | 向上、向下、向右或向左移动。 |
| <kbd>Enter</kbd>                                 | 下移一行。          |
| <kbd>Space</kbd>                                 | 向下移动一页。        |
| <kbd>PgUp</kbd> 和 <kbd>PgDn</kbd>                | 向上或向下移动一页。     |
| <kbd>g</kbd> 和 <kbd>G</kbd>                      | 移动到文件的首页或尾页。   |
| `/texte`                                         | 搜索文本。          |
| <kbd>q</kbd>                                     | 退出 `less` 命令。  |

### `cat` 命令

`cat` 命令用来将多个文件的内容连接起来，且将结果显示在标准输出上。

```bash
cat file1 [files]
```

例1 - 在标准输出中显示文件的内容：

```bash
cat /etc/passwd
```

例2 - 在标准输出中显示多个文件的内容：

```bash
cat /etc/passwd /etc/group
```

例3 - 使用输出重定向将多个文件的内容合并为一个文件：

```bash
cat /etc/passwd /etc/group > usersAndGroups.txt
```

例4 - 显示行号：

```bash
$ cat -n /etc/profile
     1    # /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
     2    # and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).
     3
     4    if [ "`id -u`" -eq 0 ]; then
     5      PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
     6    else
…
```

例5 - 显示非空行的编号：

```bash
$ cat -b /etc/profile
     1    # /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
     2    # and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

     3    if [ "`id -u`" -eq 0 ]; then
     4      PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
     5    else
…
```

### `tac` 命令

`tac` 命令的作用几乎与 `cat` 命令相反。 它从文件末尾开始显示文件的内容（这对于阅读日志来说特别有趣！）。

示例：通过首先显示最后一行来显示日志文件：

```bash
[root]# tac /var/log/messages | less
```

### `head` 命令

`head` 命令用来显示文件的开头部分。

```bash
head [-n x] file
```

| 选项     | 说明           |
| ------ | ------------ |
| `-n x` | 显示文件的前 `x` 行 |

默认情况下(没有 `-n` 选项)， `head` 命令将显示文件的前10行。

### `tail` 命令

`tail` 命令用来显示文件的结尾部分。

```bash
tail [-f] [-n x] file
```

| 选项     | 说明            |
| ------ | ------------- |
| `-n x` | 显示文件的最后 `x` 行 |
| `-f`   | 实时显示文件的变化     |

示例：

```bash
tail -n 3 /etc/passwd
sshd:x:74:74:Privilege-separeted sshd:/var/empty /sshd:/sbin/nologin
tcpdump::x:72:72::/:/sbin/nologin
user1:x:500:500:grp1:/home/user1:/bin/bash
```

对于 `-f` 选项，除非用户使用 <kbd>CTRL</kbd> + <kbd>C</kbd> 退出监控状态，否则将始终输出文件的更改信息。 此选项经常用于实时跟踪日志文件(的日志)。

如果不使用 `-n` 选项， `tail` 命令将显示文件的最后10行。

### `sort` 命令

`sort` 命令用来对文件的行进行排序。

它允许您以给定的顺序对命令的结果或文件的内容进行排序，包括按数字、字母顺序、按大小（KB、MB、GB）或相反的顺序。

```bash
sort [-k] [-n] [-u] [-o file] [-t] file
```

示例：

```bash
$ sort -k 3,4 -t ":" -n /etc/passwd
root:x:0:0:root:/root:/bin/bash
adm:x:3:4:adm:/var/adm/:/sbin/nologin
```

| 选项        | 说明                                    |
| --------- | ------------------------------------- |
| `-k`      | 指定要分隔的列。 您可以指定多个列                     |
| `-n`      | 要求进行数字排序。                             |
| `-o file` | 将排序结果保存到指定的文件中。                       |
| `-t`      | 指定分隔符，要求相应文件的内容必须是以规则分隔的列内容，否则无法正确排序。 |
| `-r`      | 将结果的顺序颠倒。 与 `-n` 选项一起使用，按从大到小的顺序进行排序。 |
| `-u`      | 排序后删除重复项。 相当于`sort file | uniq`。      |

`sort` 命令仅在屏幕上对文件进行排序， 该文件不会因为排序而被修改。 要保存排序后的结果，请使用 `-o` 选项或者输出重定向 `>` 。

默认情况下，数字会根据其字符进行排序。 因此，"110" 将在 "20" 之前，而 "20" 将在 "3" 之前。 当指定 `-n` 选项后，将按数值对数字字符块进行排序。

`sort` 命令使用 `-r` 选项会将结果的顺序颠倒过来：

```bash
$ sort -k 3 -t ":" -n -r /etc/passwd
nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
systemd-coredump:x:999:997:systemd Core Dumper:/:/sbin/nologin
polkitd:x:998:996:User for polkitd:/:/sbin/nologin
```

在这个示例中，`sort` 命令将对 `/etc/passwd`文件的内容进行排序，这次是从最大的 uid 到最小的 uid 。

使用 `sort` 命令的一些高级示例：

* 随机排序值

`sort` 命令也允许您用 `-R` 选项来随机排序值：

```bash
sort -R /etc/passwd
```

* 对 IP 地址进行排序

系统管理员很快就会面临处理其服务(如SMTP、VSFTP或Apache)日志中的IP地址的问题。 通常使用 `cut` 命令提取这些地址。

以下是文件 `dns-client.txt` 的示例：

```text
192.168.1.10
192.168.1.200
5.1.150.146
208.128.150.98
208.128.150.99
```

```bash
$ sort -nr dns-client.txt
208.128.150.99
208.128.150.98
192.168.1.200
192.168.1.10
5.1.150.146
```

* 通过删除重复项对文件进行排序

`sort` 命令知道如何使用 `-u` 作为选项从文件输出中删除重复项。

这是文件 `colours.txt` 的示例：

```text
Red
Green
Blue
Red
Pink
```

```text
$ sort -u colours.txt
Blue
Green
Pink
Red
```

* 按大小排序文件

`sort` 命令知道如何从带有 `-h` 选项的 `ls` 等命令识别文件大小。

这是文件 `size.txt` 的示例：

```text
1.7G
18M
69K
2.4M
1.2M
4.2G
6M
124M
12.4M
4G
```

```bash
$ sort -hr size.txt
4.2G
4G
1.7G
124M
18M
12.4M
6M
2.4M
1.2M
69K
```

### `wc` 命令

`wc` 命令用来计算文件中的行数、 单词数和字节数。

```bash
wc [-l] [-m] [-w] file [files]
```

| 选项   | 说明     |
| ---- | ------ |
| `-c` | 计数字节数。 |
| `-m` | 计算字符数。 |
| `-l` | 计算行数。  |
| `-w` | 计算单词数。 |

## 搜索

### `find` 命令

`find` 命令用来搜索文件或目录的位置。

```bash
find directory [-name name] [-type type] [-user login] [-date date]
```

由于`find` 命令有这么多选项，因此最好参考 `man` 。

如果未指定搜索目录，`find`命令将从当前目录进行搜索。

| 选项         | 说明           |
| ---------- | ------------ |
| `-perm 权限` | 通过它们的权限搜索文件。 |
| `-size 大小` | 按文件大小搜索文件。   |

### `find` 命令的 `-exec` 选项

可以使用 `find` 命令的 `-exec` 选项对每个结果行执行命令：

```bash
find /tmp -name *.txt -exec rm -f {} \;
```

如上命令所示，在`/tmp` 目录下搜索所有的 `*.txt` 文件并将其删除。

!!! Tip "了解 `-exec` 选项"

    在上面的示例中，`find` 命令将组成一个表示执行命令的字符串。
    
    如果`find`命令找到名为`log1.txt`、`log2.txt`和`log3.txt`这三个文件，则`find`命令通过`rm -f {} \;`将字符串中的大括号替换为搜索结果之一来组合字符串，并尽可能多次地执行此操作。
    
    这将给我们带来：

    ```
    rm -f /tmp/log1.txt ; rm -f /tmp/log2.txt ; rm -f /tmp/log3.txt ;
    ```


    `;` 字符是一个特殊的 shell 字符，必须由 `\` 保护，以防止被 `find` 命令（而不是`-exec`）过早地解释它。

!!! Tip "提示"

    `$ find /tmp -name *.txt -delete` 可以做同样的事情。

### `whereis` 命令

`whereis` 命令用来搜索与命令相关的文件。

```bash
whereis [-b] [-m] [-s] command
```

示例：

```bash
$ whereis -b ls
ls: /bin/ls
```

| 选项   | 说明        |
| ---- | --------- |
| `-b` | 只搜索二进制文件。 |
| `-m` | 只搜索手册页。   |
| `-s` | 只搜索源文件。   |

### `grep` 命令

`grep` 命令用来搜索文件中的字符串。

```bash
grep [-w] [-i] [-v] "string" file
```

示例：

```bash
$ grep -w "root:" /etc/passwd
root:x:0:0:root:/root:/bin/bash
```

| 选项   | 说明           |
| ---- | ------------ |
| `-i` | 忽略搜索字符串的大小写。 |
| `-v` | 排除包含字符串的行。   |
| `-w` | 搜索准确的单词。     |

`grep` 命令返回包含您要查找的字符串的完整行。

* `^` 特殊字符用于搜索行首的字符串。
* 特殊字符 `$` 用来搜索行尾的字符串。

    ```bash
    grep -w "^root" /etc/passwd
    ```

!!! Note "说明"

    该命令非常强大，强烈建议参考其手册。 它有很多的衍生产品。

可以使用 `-R` 选项在文件树中搜索字符串。

```bash
grep -R "Virtual" /etc/httpd
```

### 元字符（通配符）

在搜索过程中，元字符将代替一个或多个字符（甚至不包含字符）。 这些元字符也称为通配符。

它们可以组合起来使用。

`*` 字符用来代替由任意字符组成的字符串。 `*` 字符也可以表示没有字符。

```bash
$ find /home -name "test*"
/home/rockstar/test
/home/rockstar/test1
/home/rockstar/test11
/home/rockstar/tests
/home/rockstar/test362
```

元字符可以通过代替单词的全部或部分来进行更复杂的搜索。 只需用这些特殊字符来代替未知的字符即可。

字符 `?` 代替单个字符，不管它是什么。

```bash
$ find /home -name "test?"
/home/rockstar/test1
/home/rockstar/tests
```

方括号 `[` 和 `]` 用于指定单个字符可以接受的值。

```bash
$ find /home -name "test[123]*"
/home/rockstar/test1
/home/rockstar/test11
/home/rockstar/test362
```

!!! Note "说明"

    始终使用 `"` 括起包含元字符的单词，以防止它们被符合条件的文件名替换。

!!! Wanning "警告"

    不要将 shell 元字符与正则表达式元字符混淆。 `grep`命令使用正则表达式元字符。

## 重定向和管道

### 标准输入和输出

关于 UNIX 和 Linux 系统，有三个标准流。 它们允许程序通过 `stdio.h` 库输入或输出信息。

这些流称为 X 通道或 X 文件描述符。

默认情况下：

* 键盘是通道0的输入设备，称为 **stdin**；
* 屏幕是通道1和2的输出设备，称为 **stdout** 和 **stderr**。

![标准通道](images/input-output.png)

**stderr** 接收命令返回的错误流。 其他流定向到 **stdout** 。

这些流指向外部文件，但由于在 UNIX/Linux 中所有文件都是一个文件，所以 I/O流 可以很容易地被转移到其他文件。 这项原则是 shell 的长处。

### 输入重定向

可以使用字符 `<` 或 `<<` 重定向来自另一个文件的输入流。 命令将读取文件，而不是键盘：

```bash
ftp -in serverftp << ftp-commands.txt
```

!!! Note "说明"

    只有需要键盘输入的命令才能处理输入重定向。

还可以使用输入重定向来模拟用户交互。 命令将读取输入流，直到在输入重定向后遇到定义的关键字。

此功能用于编写交互式命令的脚本：

```bash
$ ftp -in serverftp << END
user alice password
put file
bye
END
```

关键字 `END` 可以替换为任何单词。

```bash
$ ftp -in serverftp << STOP
user alice password
put file
bye
STOP
```

当 shell 收到只包含关键字的行时，它将退出 `ftp` 命令。

!!! Wanning "警告"

    结尾关键字 `END` 或 `STOP` 必须是行中唯一的单词，并且必须位于行的开头。

标准输入重定向很少使用，因为大多数命令都接受文件名作为参数。

命令 `wc` 可以像这样使用：

```bash
$ wc -l .bash_profile
27 .bash_profile # 行数后面跟随文件名
$ wc -l < .bash_profile
27 # 仅返回行数
```

### 输出重定向

可以使用 `>` 或 `>>` 字符将标准输出重定向到其他文件。

简单的使用 `>` 重定向覆盖输出文件的内容：

```bash
date +%F > date_file
```

当使用 `>>` 字符时，它表示命令的输出结果被追加到文件内容中。

```bash
date +%F >> date_file
```

在这两种情况下，文件在不存在时自动创建。

也可以将标准错误输出重定向到另一个文件。 这一次需要指定通道编号(通道0和1可以省略该编号)：

```bash
ls -R / 2> errors_file

ls -R / 2>> errors_file
```

### 重定向示例

将2个输出重定向到 2 个文件：

```bash
ls -R / >> ok_file 2>> nok_file
```

将2个输出重定向到单个文件：

```bash
ls -R / >> log_file 2>&1
```

*stderr* 重定向到 "无底洞" (`/dev/null`)：

```bash
ls -R / 2>> /dev/null
```

当两个输出流都被重定向时，屏幕上不会显示任何信息。 要同时使用输出重定向且保持显示，您必须使用命令 `tee` 。

### 管道

**管道** 是一种机制，允许您将第一个命令的标准输出链接到第二个命令的标准输入。

这种传递是单向的，用 `|` 符号完成。 管道符 `|` 通过同时按 <kbd>Shift</kbd> + <kbd>|</kbd> 获得。

![管道](images/pipe.png)

管道左侧控件通过标准输出通道发送的所有数据都被发送到右侧控件的标准输入通道。

管道后面特别使用的命令是筛选器。

* 示例：

仅显示开头：

```bash
ls -lia / | head
```

只显示末尾：

```bash
ls -lia / | tail
```

对结果进行排序：

```bash
ls -lia / | sort
```

计算单词/字符的数量：

```bash
ls -lia / | wc
```

在结果中搜索字符串：

```bash
ls -lia / | grep fichier
```

## 特殊点

### `tee` 命令

`tee` 命令用于将命令的标准输出重定向到文件，同时保持屏幕显示。

它与 `|` 管道结合使用，以接收要重定向的命令的输出作为输入：

```bash
ls -lia / | tee fic
```

`-a` 选项表示添加到文件当中，而不是覆盖文件。

### `alias` 和 `unalias` 命令

使用 **alias** 是一种要求 shell 记住带有选项的特定命令并为其命名的方法。

例如：

```bash
ll
```

将替换该命令：

```bash
ls -l
```

`alias` 命令会列出当前会话的别名。 在 Linux 发行版上，别名是默认设置的。 这里是 Rocky 服务器的别名：

```bash
$ alias
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias vi='vim'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
```

别名仅在用户会话期间临时定义。

要永久使用，必须在以下位置创建它们：

* 用户登录目录中的 `.bashrc` 文件；
* `/etc/bashrc` 文件，适用于所有用户。

!!! Wanning "警告"

    在使用可能有潜在危险的别名时，必须特别小心！ 例如，在管理员不知情的情况下设置的别名：

    ```bash
    alias cd='rm -Rf'
    ```

`unalias` 命令允许您删除别名。

删除单个别名：

```bash
unalias ll
```

要删除所有别名：

```bash
unalias -a
```

要暂时禁用别名，组合是 `\&#060;别名&#062;`

例如，如果我们这样做：

```bash
type ls
```

它可能会返回以下内容：

```bash
ls is an alias to « ls -rt »
```

现在我们知道了这一点，我们可以通过执行以下命令看到使用别名或使用 `\` 禁用它一次的结果：

```bash
$ ls file*   # 通过时间排序
file3.txt  file2.txt  file1.txt
$ \ls file*  # 通过名称排序
file1.txt  file2.txt  file3.txt
```

### 别名和有用的函数

* `grep` 别名

对 `grep` 命令的结果进行上色：`alias grep='grep --color=auto'`

* `mcd` 函数

创建文件夹然后在其中移动是很常见的：`mcd() { mkdir -p "$1"; cd "$1"; }`

* `cls` 函数

移动到文件夹并列出其内容：`cls() { cd "$1"; ls; }`

* `backup` 函数

创建文件的备份副本：`backup() { cp "$1"{,.bak}; }`

* `extract` 函数

提取任何类型的归档：

```bash
extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2) tar xjf $1 ;;
      *.tar.gz) tar xzf $1 ;;
      *.bz2) bunzip2 $1 ;;
      *.rar) unrar e $1 ;;
      *.gz) gunzip $1 ;;
      *.tar) tar xf $1 ;;
      *.tbz2) tar xjf $1 ;;
      *.tgz) tar xzf $1 ;;
      *.zip) unzip $1 ;;
      *.Z) uncompress $1 ;;
      *.7z) 7z x $1 ;;
      *)
        echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

```

* 如果 `alias cmount` 返回以下内容：`alias cmount="mount | column -t"`

然后我们可以使用 `cmount` 在如下列中显示所有系统挂载：`[root]# cmount`

它将以以下格式返回我们挂载的文件系统：

```bash
/dev/simfs  on  /                                          type  simfs        (rw,relatime,usrquota,grpquota)
proc        on  /proc                                      type  proc         (rw,relatime)
sysfs       on  /sys                                       type  sysfs        (rw,relatime)
none        on  /dev                                       type  devtmpfs     (rw,relatime,mode=755)
none        on  /dev/pts                                   type  devpts       (rw,relatime,mode=600,ptmxmode=000)
none        on  /dev/shm                                   type  tmpfs        (rw,relatime)
none        on  /proc/sys/fs/binfmt_misc                   type  binfmt_misc  (rw,relatime)
```

### 字符 `;`

`;` 字符将命令串在一起。

一旦用户键入 <kbd>ENTER</kbd> ，所有命令都将按输入顺序运行。

```bash
ls /; cd /home; ls -lia; cd /
```

## 检测所学知识

:heavy_check_mark: Linux下用户的定义是什么？ （7个答案）

:heavy_check_mark: 命令的长选项的特点是什么？

:heavy_check_mark: 哪些命令允许您搜索有关命令的帮助？

* [ ] `google`
* [ ] `chuck --norris`
* [ ] `info`
* [ ] `apropos`
* [ ] `whatis`

:heavy_check_mark: 哪个命令允许您查看用户的历史记录？

:heavy_check_mark: 哪个命令允许您在文件中搜索文本？

* [ ] `find`
* [ ] `grep`

:heavy_check_mark: 哪个命令允许您搜索文件？

* [ ] `find`
* [ ] `grep`

:heavy_check_mark: 哪个命令将命令的错误流重定向到新的 `errors.log` 文件？

* [ ] `ls -R / 2> errors.log`
* [ ] `ls -R / 2>> errors.log`
* [ ] `ls -R / 2> errors.log 2>&1`  
