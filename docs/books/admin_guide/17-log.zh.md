---
title: 日志管理
author: tianci li
contributors: Ganna Zhyrnova, Steven Spencer
tags:
  - rsyslog
  - journald
---

## 概述

在本章中，你将学习如何在操作系统中管理日志。

**Q：什么是日志？**

**日志**：记录操作系统启动以来所有发生的事件和消息，包括启动日志、内核初始化日志、`systemd` 初始化日志以及应用程序启动或运行日志。 日志是操作系统不可或缺的功能之一。 管理员可以查询日志以解决当前或即将出现的问题。

在 RHEL 8.x 和 RHEL 9.x 中，日志收集主要通过以下两个程序完成：

- **rsyslog** - 一个能够快速收集和处理日志的程序。 它是 `syslog` 的升级版本。 [这是它的官方网站](https://www.rsyslog.com/)
- **journald** - `systemd` 的一个组件

## rsyslog

在 Rocky Linux 8.x 或 9.x 中，在 **/var/log/** 目录中有各种日志文件。 让我们来了解它们：

- `/var/log/boot.log` - 记录操作系统启动过程中发生的事件。 文件内容是纯文本。
- `/var/log/btmp` - 记录登录错误的日志。 要查看这个二进制文件，请使用 `lastb` 命令。
- `/var/log/cron` - 记录与系统计划任务相关的日志。 文件内容是纯文本。
- `/var/log/dmegs` - 记录启动后内核自检的日志。 文件内容是纯文本。 你也可以使用 `dmegs` 命令来查看。
- `/var/log/lastlog` - 记录操作系统中所有用户的最后登录时间。 要查看这个二进制文件，你必须使用 `lastlog` 命令。
- `/var/log/maillog` - 记录与电子邮件相关的日志。
- `/var/log/messages` - 系统级日志文件记录了操作系统的核心信息。 文件内容是纯文本。 当您的操作系统出现某些错误时，您应该首先查看此日志文件的内容。
- `/var/log/secure` - 记录与用户身份相关的日志，例如用户登录、`su` 切换、新用户添加、用户密码更改等。
- `/var/log/wtmp` - 记录用户登录和注销、操作系统启动、关闭和重新启动事件。 要查看这个二进制文件，请使用 `last` 命令。

对于纯文本文件，其格式通常是：

1. 事件发生的时间
2. 事件发生在哪台机器上
3. 生成事件的服务或程序的名称
4. 事件的具体描述和说明
5. 用户和终端信息
6. 一些关键字提示（例如 error、fail、info 等）

不同用途的日志在格式上差异很大，因此上述格式描述无法涵盖所有的日志。

如果操作系统中缺少 `rsyslog` ，请运行以下命令：

```bash
Shell > dnf install -y rsyslog
```

### 配置文件

- `/etc/rsyslog.conf` - 主配置文件
- `/etc/rsyslog.d/` - 存储附加配置文件的目录

`/etc/rsyslog.conf` 主要由几个部分组成：

1. 加载模块
2. 全局指令
3. 规则 - 作者会详细说明这一点。

经过数十年的发展，`rsyslog` 现在支持三种不同的配置格式：

1. basic (sysklogd) - 此格式适用于在单个文件中表示基本配置。

    ```
    mail.info /var/log/mail.log
    mail.err @@server.example.net
    ```

2. advanced (RainerScript) - 高度灵活和精确的配置格式。

    ```
    mail.err action(type="omfwd" protocol="tcp" queue.type="linkedList")
    ```

3. obsolete legacy (legacy) - 此格式已被弃用。 请不要继续使用它。

#### 规则

此部分的默认内容如下：

```
*.info;mail.none;authpriv.none;cron.none                /var/log/messages

authpriv.*                                              /var/log/secure

mail.*                                                  -/var/log/maillog

cron.*                                                  /var/log/cron

*.emerg                                                 :omusrmsg:*

uucp,news.crit                                          /var/log/spooler

local7.*                                                /var/log/boot.log
```

每条规则行由两部分组成：

1. 选择器字段 - 由设施和优先级组成
2. 动作字段 - 您希望如何处理这些匹配的消息

字段之间用一个或多个空格隔开。

| 设施                                                                   | 说明                                                                                 |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `auth`                                                               | 记录与系统安全、用户认证和权限管理相关的事件                                                             |
| `authpriv`                                                           | 记录更多敏感安全事件（例如 `sudo` 操作）。 "priv" 等同于 private                                       |
| `cron`                                                               | 记录与计划任务相关的事件                                                                       |
| `daemon`                                                             | 记录系统守护进程的运行日志，包括服务启动、运行状态和错误信息                                                     |
| `ftp`                                                                | 记录与 FTP 服务（例如 `vsftpd` 和 `proftpd`）相关的操作日志，包括连接、文件传输和错误信息                          |
| `kern`                                                               | 记录 Linux 内核运行时生成的日志，涵盖硬件驱动、内核模块和系统异常等核心事件                                          |
| `lpr`                                                                | 记录打印服务的运行日志，包括打印任务提交、队列管理和错误信息                                                     |
| `mail`                                                               | 记录邮件服务（如 Postfix 和 Sendmail ）的日志信息，包括邮件发送、接收、队列处理和错误事件                             |
| `news`                                                               | 很少使用                                                                               |
| `security`                                                           | 与 `auth` 相同                                                                        |
| `syslog`                                                             | 记录由 `syslog` 服务生成的日志                                                               |
| `user`                                                               | 记录由用户空间应用程序或用户生成的日志信息                                                              |
| `uucp`                                                               | 记录 Unix-to-Unix Copy Protocol (UUCP) 相关的操作日志，包括文件传输、远程命令执行和其他场景 |
| `local0`                                                             | 保留                                                                                 |
| `local1`                                                             | 保留                                                                                 |
| .... | 保留                                                                                 |
| `local7`                                                             | 保留                                                                                 |

`*` 代表所有设施。 你也可以使用 `,` 和 `;` 将设施组合在单行配置中。 `,` 表示逻辑或；`;` 表示规则分隔符。

```bash
auth,authpriv.*  /var/log/auth.log

# 等同于

auth.*   /var/log/auth.log
authpriv.*  /var/log/auth.log
```

```bash
kern.err;mail.alert  /var/log/critical.log
```

| 连接符  | 说明                                                                    |
| ---- | --------------------------------------------------------------------- |
| `.`  | 记录比关键词具有更高优先级的日志。 例如，`cron.info` 表示它会在 `cron` 中记录那些日志优先级高于 `info` 的内容 |
| `.=` | 仅记录与关键字匹配的优先级日志。 例如，`*.=emerg` 表示它将在所有应用程序中记录优先级为 `emerg` 的日志         |
| `.!` | 它表示排除或不等于                                                             |

优先级从低到高排序：

| 名称        | 说明                           |
| --------- | ---------------------------- |
| `debug`   | 通用调试信息                       |
| `info`    | 基本通知信息                       |
| `notice`  | 某些重要的一般信息                    |
| `warning` | 警告信息，此类信息不会影响操作系统或服务的正常运行    |
| `err`     | 错误信息，可能会影响操作系统和服务的正常运行       |
| `crit`    | 比 "err" 更严重的临界状态             |
| `alert`   | 警报状态比 "crit" 更严重，系统管理员需要立即处理 |
| `emerg`   | 操作系统通常无法使用的紧急状态              |

`*` 代表所有日志优先级。

日志优先级越低，记录的内容越详细，严重程度越低。 日志优先级越高，记录的内容越少，问题越严重。

"action" 指的是日志保存或发送的位置：

- `/var/log/secure` - 将日志保存到本地文件
- `@192.168.100.20:22` - 远程机器
- `:omusrmsg:root,frank,jack` - 指定在线用户列表。 `*` 代表所有用户。 "omusrmsg" 指的是 "output module for user messages" 。
- `/dev/tty12` - 特定终端设备
- `-` - 在写入文件时禁用缓冲机制

### 日志轮替

**日志轮替** - 日志轮替解决了日志文件持续增长导致的存储占用和性能下降问题。 具体功能是：

- **轮替** - 根据特定规则（如时间或文件大小）自动归档当前日志文件，并创建一个新的空日志文件进行记录，以防止日志文件过大。
- **压缩** - 压缩归档的旧日志以节省磁盘空间。
- **删除** - 根据相关策略，保留符合条件的日志文件，并删除过时的旧日志文件。

我们经常使用 `logrotate` 工具来轮替日志。

日志文件在轮替期间的命名规则：

- `dateext` 参数 - 使用日期作为日志轮替的文件后缀。 例如，在第一次日志轮替时，旧的日志文件 ”secure“ 将变为 "secure-20250424"，并且 `logrotate` 会创建一个新的 "secure" 文件
- 无 `dateetx` 参数 - 在日志轮替后使用轮替数作为文件后缀。 例如，当第一次日志轮替发生时，旧的日志文件 "secure" 将变为 “secure.1"，并且 `logrotate` 将创建一个新的 "secure" 文件

#### /etc/logrotate.conf 和 /etc/logrotate.d/

```bash
Shell > grep -v -E "^#|^$" /etc/logrotate.conf
weekly
rotate 4
create
dateext
include /etc/logrotate.d

Shell > ls -l /etc/logrotate.d/
-rw-r--r--  1 root root 130 Feb  7  2023 btmp
-rw-r--r--. 1 root root 160 Dec  5  2023 chrony
-rw-r--r--. 1 root root  88 Apr 12  2021 dnf
-rw-r--r--  1 root root  93 Mar 11 17:29 firewalld
-rw-r--r--. 1 root root 162 Apr 16 19:49 kvm_stat
-rw-r--r--  1 root root 289 Dec 18 01:38 sssd
-rw-r--r--  1 root root 226 Nov  5 15:43 syslog
-rw-r--r--  1 root root 145 Feb 19  2018 wtmp
```

**/etc/logrotate.conf** - 日志轮替的全局配置文件。 如果配置项或参数重叠，则以最后读取的配置项或参数为准。 读取顺序：

1. 从上到下读取 **/etc/logrotate.conf** 文件的内容
2. 使用 "include" 关键字包含的文件

常见的配置项或参数是：

| 项                               | 说明                                 |
| ------------------------------- | ---------------------------------- |
| `daily`                         | 定义日志轮替的周期（以天为单位）                   |
| `weekly`                        | 定义日志轮替的周期（以周为单位）                   |
| `monthly`                       | 定义日志轮替的周期（以月为单位）                   |
| `rotate <NUMBER>`               | 日志轮替后保存的文件数量                       |
| `compress`                      | 在日志轮替之后，旧日志会被压缩                    |
| `create <MODE> <OWNER> <GROUP>` | 日志轮替后，定义新日志文件的所有者、所属组和权限           |
| `mail <E-MAIL ADDRESS>`         | 日志轮替后，它通过电子邮件将输出内容发送到指定的电子邮件地址     |
| `missingok`                     | 如果日志文件不存在，则忽略日志中的警告信息              |
| `notifempty`                    | 如果日志文件的内容为空，则不会进行日志轮替              |
| `minsize <SIZE>`                | 日志轮替的文件大小条件，也就是说，只有满足这个条件时才会进行日志轮替 |
| `dateext`                       | 使用日期作为日志轮替的文件后缀                    |

如果从存储库安装软件包，软件包维护者将定义应用程序的日志轮替，用户通常不需要修改日志轮替规则。 如果你通过编译源代码来安装应用程序，你需要考虑并手动配置日志轮替。

#### `logrotate` 命令

用法是 `logrotate [OPTION...] <configfile>`

- `-v` - 显示日志轮替过程
- `-f` - 无论是否满足日志轮替的条件，日志轮替的操作都会被执行

```bash
Shell > logrotate -v /etc/logrotate.conf
reading config file /etc/logrotate.conf
including /etc/logrotate.d
reading config file btmp
reading config file chrony
reading config file dnf
reading config file firewalld
reading config file kvm_stat
reading config file sssd
reading config file syslog
reading config file wtmp
Reading state from file: /var/lib/logrotate/logrotate.status
Allocating hash table for state file, size 64 entries
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state

Handling 8 logs

rotating pattern: /var/log/btmp  monthly (1 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/btmp
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-04 12:08
  log does not need rotating (log has been rotated at 2025-4-4 12:8, that is not month ago yet)

rotating pattern: /var/log/chrony/*.log  weekly (4 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/chrony/*.log
  log /var/log/chrony/*.log does not exist -- skipping
not running postrotate script, since no logs were rotated

rotating pattern: /var/log/hawkey.log  weekly (4 rotations)
empty log files are not rotated, old logs are removed
considering log /var/log/hawkey.log
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)

rotating pattern: /var/log/firewalld  weekly (4 rotations)
empty log files are rotated, only log files >= 1048576 bytes are rotated, old logs are removed
considering log /var/log/firewalld
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-20 13:00
  log does not need rotating ('minsize' directive is used and the log size is smaller than the minsize value)

rotating pattern: /var/log/kvm_stat.csv  10485760 bytes (5 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/kvm_stat.csv
  log /var/log/kvm_stat.csv does not exist -- skipping

rotating pattern: /var/log/sssd/*.log  weekly (2 rotations)
empty log files are not rotated, old logs are removed
considering log /var/log/sssd/sssd_implicit_files.log
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-26 12:42
  log does not need rotating (log is empty)
considering log /var/log/sssd/sssd_kcm.log
  Now: 2025-04-24 12:35
  Last rotated at 2025-02-08 13:49
  log does not need rotating (log is empty)
considering log /var/log/sssd/sssd.log
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-26 12:42
  log does not need rotating (log is empty)
considering log /var/log/sssd/sssd_nss.log
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-26 12:42
  log does not need rotating (log is empty)
not running postrotate script, since no logs were rotated

rotating pattern: /var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
 weekly (4 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/cron
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/maillog
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/messages
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/secure
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/spooler
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
not running postrotate script, since no logs were rotated

rotating pattern: /var/log/wtmp  monthly (1 rotations)
empty log files are rotated, only log files >= 1048576 bytes are rotated, old logs are removed
considering log /var/log/wtmp
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-20 13:00
  log does not need rotating ('minsize' directive is used and the log size is smaller than the minsize value)
```

## journald

`systemd` 是一个用于初始化并接管许多系统组件的应用程序。 在 `systemd` 中使用 `journald` 来接管日志内容。

`journald` 是 `systemd` 中的守护进程，负责管理日志。 您需要使用 `journalctl` 命令来读取日志。

请注意，`journald` 默认情况下不启用日志持久化，这意味着它仅保留和记录自启动以来的所有日志。 操作系统重启后，历史日志将被删除。 所有临时保存的日志文件默认都在 **/run/log/journal/** 目录中。

```bash
Shell > tree -hugp /run/log/journal/638c6d5d2b674f77be56174469099106/
/run/log/journal/638c6d5d2b674f77be56174469099106/
└── [-rw-r----- root     systemd-journal  8.0M]  system.journal

0 directories, 1 file
```

这个临时文件是二进制的。 你必须使用 `journalctl` 命令来解析它。

`journald` 可以记录：

- 启动日志
- 内核日志
- 应用程序日志

`journald` 根据 **优先级** 和 **设施** 对日志进行标记：

- **优先级** - 标记日志的重要性。 与 `rsyslog` 一样，优先级越高，记录的信息就越少，问题就越严重。 优先级越低，记录的信息越多，问题越轻。 按优先级从低到高排序：

  | 数字代码 | 优先级           | 关键字       |
  | :--- | :------------ | :-------- |
  | 7    | Debug         | `debug`   |
  | 6    | Informational | `info`    |
  | 5    | Notice        | `notice`  |
  | 4    | Warning       | `warning` |
  | 3    | Error         | `err`     |
  | 2    | Critical      | `crit`    |
  | 1    | Alert         | `alert`   |
  | 0    | Emergency     | `emerg`   |

- **设施** - 此表显示了设施：

  | 数字代码 | 设施         |
  | :--- | :--------- |
  | 0    | `kern`     |
  | 1    | `user`     |
  | 2    | `mail`     |
  | 3    | `daemon`   |
  | 4    | `auth`     |
  | 5    | `syslog`   |
  | 6    | `lpr`      |
  | 7    | `news`     |
  | 8    | `uucp`     |
  | 9    |            |
  | 10   | `authpriv` |
  | 11   | `ftp`      |
  | 12   |            |
  | 13   |            |
  | 14   |            |
  | 15   | `cron`     |
  | 16   | `local0`   |
  | 17   | `local1`   |
  | 18   | `local2`   |
  | 19   | `local3`   |
  | 20   | `local4`   |
  | 21   | `local5`   |
  | 22   | `local6`   |
  | 23   | `local7`   |

### `journalctl` 命令

用法是 `journalctl [OPTIONS...] [MATCHES...]`。

以下是无序列表中的选项列表：

- `-u` - 指定一个 "unit" 以查看相关信息。 您可以在单行命令中多次使用此选项。 例如，`journalctl -u crond.service -u sshd.service`
- `--system` - 显示来自系统服务和内核的消息
- `--user` - 显示当前用户的服务消息
- `-k` - 显示当前引导的内核消息日志
- `--since=DATA` 或 `-S` - 显示不早于指定日期的条目。 日期格式是 "YYYY-MM-DD HH:MM:SS"。 例如 `journalctl --since="2025-04-24 14:00:30`
- `--until=DATA` 或 `-U` - 显示不晚于指定日期的条目。 日期格式是 "YYYY-MM-DD HH:MM:SS"。 例如 `journalctl --since="2025-04-01 05:00:10" --until="2025-04-05 18:00:30"`
- `--list-boots` - 显示有关已记录引导过程的简要信息
- `-n N` - 控制输出的条目数量。 如果未指定 "N"，则默认值为10
- `-p PRIORITY` - 指定优先级或优先级范围。 如果指定单个日志优先级关键字，则将显示此优先级和高于此优先级的条目。 例如 `journalctl -p 3` 或 `journalctl -p err` 等同于 `journalctl -p 0..3` or `journalctl -p emerg..err`
- `-b` - 查询自当前引导 ID 开始以来的日志。 请不要将启动 ID 与内核引导的索引号混淆。
- `-f` - 动态查询日志，类似 `tail -f` 命令
- `-x` - 在可用的情况下添加消息解释
- `-e` - 跳转到日志的末尾页，通常与 "-x" 选项一起使用
- `-r` - 反向日志。
- `--disk-usage` - 显示日志文件占用的磁盘空间
- `--rotate` - 请求立即轮替日志文件
- `--vacuum-size=BYTES` - 将日志文件减小到指定大小。 逐步删除旧日志内容，直到满足指定的文件大小。 支持的文件后缀是 K、M、G、T
- `--vacuum-time=TIME` - 您可以通过指定一个时间点来删除旧的日志记录，也就是说，它将删除那个时间点之前的日志记录。 支持的时间后缀有 s、m、h、days、months、weeks、years
- `--vacuum-files=INT` - 表示要保留多少日志文件
- `-N` - 列出当前使用的所有字段名称。 用户可以使用 "FIELD=VALUE" 方式来匹配相关内容。 例如，`journalctl _SYSTEMD_UNIT=sshd.service`
- `-g` 或 `-grep=PATTERN` - 通过模式匹配日志内容，并支持正则表达式。 如果 PATTERN 全部为小写字母，则默认情况下匹配的日志内容不区分大小写。 你可以通过 `--case-sensitive` 选项调整大小写区分
- `--case-sensitive=[BOOLEAN]` - 调整其是否区分大小写
- `-o` 或 `--output=STRING` - 更改 `journalctl` 的输出模式。 STRING 可以是 short、short-precise、short-iso、short-iso-precise、short-full、short-monotonic、short-unix、verbose、export、json、json-pretty、json-sse、cat 和 with-unit
- `-q` 或 `--quiet` - 安静输出
- `--sync` - 将未写入的日志消息同步到磁盘

### /etc/systemd/journald.conf

```bash
Shell > cat /etc/systemd/journald.conf
[Journal]
#Storage=auto
#Compress=yes
#Seal=yes
#SplitMode=uid
#SyncIntervalSec=5m
#RateLimitIntervalSec=30s
#RateLimitBurst=10000
#SystemMaxUse=
#SystemKeepFree=
#SystemMaxFileSize=
#SystemMaxFiles=100
#RuntimeMaxUse=
#RuntimeKeepFree=
#RuntimeMaxFileSize=
#RuntimeMaxFiles=100
#MaxRetentionSec=
#MaxFileSec=1month
#ForwardToSyslog=no
#ForwardToKMsg=no
#ForwardToConsole=no
#ForwardToWall=yes
#TTYPath=/dev/console
#MaxLevelStore=debug
#MaxLevelSyslog=debug
#MaxLevelKMsg=notice
#MaxLevelConsole=info
#MaxLevelWall=emerg
#LineMax=48K
```

与其他 `systemd` 组件的配置文件一样，使用 "[ ]" 包含标题，标题下方是特定的键值对。 键值对中 **等号的两侧都没有空格**。 对于完整的配置手册页面，请参阅 `man 5 journald.conf`。

- `Storage=` - 控制 `journald` 数据存储的位置。 默认值是 auto

  - volatile - 将日志数据存储在内存中，即位于 **/run/log/journal/** 目录中的临时文件
  - persistent - 将日志数据存储在 **/var/log/journal/** 目录中。 你需要手动创建这个目录。 如果此目录不可写，日志数据将写入到 **/run/log/journal/** 目录
  - auto - 类似于 persistent
  - none - 不保存任何日志，但这不会影响转发到其他 "target" 的日志

- `Compress=` - 是否启用压缩功能。 默认值是 yes

- `Seal=` - 是否使用FSS（Forward Secure Sealing）来保护日志条目免受恶意篡改。 默认值是 yes

- `SplitMode=` - 定义拆分日志文件的依据。 在生效之前，必须满足先决条件（Storage=persistent）。 默认值是 uid

- `SyncIntervalSec=` - 定义将内存中的日志数据同步到磁盘的时间间隔。 请注意！ 这仅适用于 err、warning、notice、info 和 debug 日志优先级。 其他日志优先级会立即同步到磁盘。 默认值是 5m

- `RateLimitIntervalSec=` - 定义日志生成频率的时间间隔。 默认值是 30s

- `RateLimitBurst=` - 在给定的时间间隔内，日志生成的最大条目数。 默认值是 10000。 如果在给定的时间间隔内日志条目超过10000条，它将删除冗余的日志，并且在下一个时间间隔之前不会创建新的日志条目

- `SystemMaxUse=` - 控制 **/var/log/journal/** 目录中所有日志文件的总大小

- `SystemKeepFree=` - 控制 **/var/log/journal/** 目录中保留多少磁盘空间。 基于1024，后缀包括 K、M、G、T、P、E

- `SystemMaxFileSize=` - 限制 **/var/log/journal/** 目录中单个文件的大小。 如果大小超过了指定大小，将进行日志轮替

- `SystemMaxFiles=` - 指定在\*\*/var/log/journal/\*\* 目录中保留多少个文件。 当它超过定义的数字时，将删除最旧的日志

- `RuntimeMaxUse=` - 控制 **/run/log/journal/** 目录中日志数据的总大小

- `RuntimeKeepFree=` - 控制 **/run/log/journal/** 目录中保留的空间大小

- `RuntimeMaxFileSize=` - 控制 **/run/log/journal/** 目录中单个日志文件的大小。 当日志达到指定大小时，将进行日志轮替

- `RuntimeMaxFiles=` - 在 **/run/log/journal/** 目录中需要保留多少个日志文件

- `MaxRetentionSec=` - 定义了日志文件的保留时间；如果超过了定义的时间，它将删除旧的日志文件。 值为 0 表示该功能已关闭。 值后缀有 year、month、week、day、h、m

- `MaxFileSec=` - 基于时间的日志轮替。 由于已经存在基于文件大小的轮替（`SystemMaxFileSize` 和 `RuntimeMaxFileSize`），基于时间的日志轮替通常是不必要的。 将其设置为 0 以禁用此功能

- `ForwardToSyslog=` - 是否将收集到的日志消息转发到传统的 `syslog` 守护进程。 默认值为 no

- `ForwardToKMsg=` - 是否将收到的日志消息转发给 kmsg。 默认值为 no

- `ForwardToConsole=` - 是否将收到的日志消息转发到系统控制台。 默认值为 no。 如果设置为 yes，您还需要配置 `TTYPath`

- `ForwardToWall=` - 是否将收到的日志消息作为警告发送给所有登录用户。 默认值是 yes

- `TTYPath=` - 指定控制台的路径。 需要 `ForwardToConsole=yes`。 默认值是 /dev/console

- `MaxLevelStore=` - 设置记录到日志文件的最大日志级别。 默认值是 debug

- `MaxLevelSyslog=` - 设置转发到传统 `syslog` 守护进程的最大日志级别。 默认值是 debug

- `MaxLevelKMsg=` - 设置转发给 kmsg 的最大日志级别。 默认值是 notice

- `MaxLevelConsole=` - 设置转发到系统控制台的最大日志级别。 默认值是 info

- `MaxLevelWall=` - 设置发送给所有登录用户的最大日志级别。 默认值是 emerg

- `LineMax=` - 将日志流转换为日志记录时，每个日志记录的最大允许长度（字节）。 以 1024 为基数，后缀可以是 K、M、G 或 T。默认值为 48K

## 其他说明

如果不更改\* _/etc/systemd/journald.conf_\* 中的任何配置，`rsyslog` 和 `journald` 可以共存而不会相互影响。

```bash
Shell > cat /etc/rsyslog.conf
...
#### MODULES ####

module(load="imuxsock"    # provides support for local system logging (e.g. via logger command)
       SysSock.Use="off") # Turn off message reception via local log socket;
                          # local messages are retrieved through imjournal now.
module(load="imjournal"             # provides access to the systemd journal
       UsePid="system" # PID nummber is retrieved as the ID of the process the journal entry originates from
       StateFile="imjournal.state") # File to store the position in the journal
#module(load="imklog") # reads kernel messages (the same are read from journald)
#module(load="immark") # provides --MARK-- message capability
...
```

`journald` 会将获得的日志数据转发到套接字 `/run/systemd/journal/syslog`，以方便使用传统的日志服务（rsyslog、syslog-ng）。 然而，我们可以从配置文件中了解到，`rsyslog` 不会使用套接字从 `journald` 收集日志，而是通过输入模块（imjournal）进行集成。

**Q：操作系统可以不使用 `journald` 进行日志记录吗？**

是的。 默认情况下，`rsyslog` 和 `journald` 可以在操作系统中共存，而不会相互影响。 对于某些面向性能的使用场景（如数据吞吐量和内存消耗），共存不是最佳选择。 您可以使 `rsyslog` 仅在套接字模式下运行，这有助于提高性能并以纯文本形式记录所有日志。 但是，如果您需要结构化日志，则此更改不合适。 相关步骤如下：

```bash
Shell > vim /etc/rsyslog.config
...
module(load="imuxsock"
      SysSock.Use="on")
# module(load="imjournal" 
# UsePid="system" 
# StateFile="imjournal.state")
module(load="imklog")
...

Shell > vim /etc/systemd/journald.conf
[Journal]
Storage=none
...
ForwardToSyslog=yes
...

Shell > reboot
```
