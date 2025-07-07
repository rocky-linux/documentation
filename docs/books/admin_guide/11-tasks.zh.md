---
title: 任务管理
---

# 任务管理

在本章中，您将学习如何管理计划任务。

****

**目标**： 在本章中，未来的 Linux 管理员们将学习如何：

:heavy_check_mark: 使用 Linux 处理计划任务；  
:heavy_check_mark: 将 **`cron`** 的使用限制为某些用户；  
:heavy_check_mark: 计划任务。

:checkered_flag: **crontab**，**crond**，**scheduling**，**linux**

**知识性**: :star: :star:  
**复杂度**: :star: :star:

**阅读时间**：15 分钟

****

## 概论

任务的调度由 `cron` 实用程序进行管理。 它允许定期执行任务。

该工具通常保留给管理员执行系统任务，但普通用户也可用它来运行自己有权限访问的任务或脚本。 要访问 `cron` 实用工具，我们需要使用 `crontab`。

`cron` 服务用于：

* 重复性的管理任务；
* 备份；
* 监控系统活动；
* 程序执行。

`crontab` 是 **cron table** 的缩写，但可以认为它是任务调度表。

!!! warning "警告"

    要设置计划，系统必须为设置正确的时间。

## 服务的工作原理

`cron` 服务由内存中的 `crond` 守护进程来运行。

要检查其状态：

```bash
[root] # systemctl status crond
```

!!! Tip "提示"

    如果 `crond` 守护程序未运行，则必须在启动时手动 和/或 自动对其进行初始化。 即使任务被安排了，它们也不会被启动。

手动初始化 `crond` 守护进程：

```bash
[root]# systemctl {status|start|restart|stop} crond
```

启动时初始化 `crond` 守护进程：

```bash
[root]# systemctl enable crond
```

## 安全性

为了实现计划任务，用户必须具有使用 `cron` 服务的权限。

此权限因以下文件中包含的信息而异：

* `/etc/cron.allow`
* `/etc/cron.deny`

!!! warning "警告"

    如果两个文件都不存在，则所有用户都可以使用 `cron`。

### `cron.allow` 和 `cron.deny` 文件

`/etc/cron.allow` 文件

仅允许此文件中包含的用户使用 `cron`。

如果它存在并且为空，则任何用户都不能使用 `cron`。

!!! warning "警告"

    如果存在 `cron.allow` ，则 `cron.deny` 将被 **忽略**。

`/etc/cron.deny` 文件

此文件中的用户不允许使用 `cron`。

如果内容为空，则所有用户都可以使用 `cron`。

默认情况下，`/etc/cron.deny` 文件存在但为空，而 `/etc/cron.allow` 文件不存在。 当两个文件同时存在时，系统仅使用 `cron.allow` 的文件内容作为判断依据并完全忽略 `cron.deny` 文件的存在。

### 允许一个用户

仅 **user1** 能够使用 `cron`。

```bash
[root]# vi /etc/cron.allow
user1
```

### 禁止一个用户

仅 **user2** 不能使用 `cron`。 请注意，`/etc/cron.allow` 文件不能存在。

```bash
[root]# vi /etc/cron.deny
user2
```

如果 `/etc/cron.deny` 和 `/etc/cron.allow` 中同时存在相同的用户，则用户可以正常使用 cron。

## 计划任务

当给用户设置计划任务时，会在 `/var/spool/cron/`下创建一个以该用户命名的文件。

该文件包含 `crond` 运行该用户创建的计划任务所需的全部信息，包括待执行的命令或程序以及运行它们的时间表（时、分、日等）。 请注意，`crond` 可以识别的最小时间单位是 1 分钟。 在 RDBMS（如 MySQL ）中也有类似的计划任务，其中基于时间的计划任务被称为"事件调度器"（其可识别的时间单位为1秒），基于事件的计划任务称为 "触发器"。

![Cron 树](images/tasks-001.png)

### `crontab` 命令

`crontab` 命令用于管理计划任务文件。

```bash
crontab [-u user] [-e | -l | -r]
```

示例：

```bash
[root]# crontab -u user1 -e
```

| 选项                | 说明             |
| ----------------- | -------------- |
| `-e`              | 使用 vi 编辑计划任务文件 |
| `-l`              | 显示计划任务文件的内容    |
| `-u <user>` | 指定单个用户进行操作     |
| `-r`              | 删除计划任务文件       |

!!! warning "警告"

    没有选项的 `crontab` 会删除旧的计划任务文件并等待用户输入新行。 您必须按 <kbd>ctrl</kbd> + <kbd>d</kbd> 键才能退出此编辑模式。
    
    只有 `root` 才能使用 `-u <user>` 选项来管理其他用户的计划任务文件。
    
    上面的示例允许 root 为 user1 安排计划任务。

### `crontab` 的使用

`crontab` 的用途很多，包括：

* 对 `crontab` 文件所做的修改会立即生效；
* 无需重启。

另一方面，必须考虑以下几点：

* 程序必须能够独立运行；
* 提供重定向（stdin, stdout, stderr）；
* 不适合执行需要终端交互操作的命令。

!!! note "说明"

    重要的是要理解计划任务的目的——在不需要外部干预的情况下自动执行任务。

## `crontab` 文件

`crontab` 文件的结构遵循以下规则。

* 此文件的每一行都对应一项计划任务；
* 每行包含6个字段：5个时间设定字段 + 1个命令指令字段；
* 字段间需用空格或制表符分隔；
* 每行必须以回车符结束；
* 行首的 `#` 号将注释该行内容。

```bash
[root]# crontab –e
10 4 1 * * /root/scripts/backup.sh
1  2 3 4 5       6
```

| 字段 | 说明     | 详情                     |
| -- | ------ | ---------------------- |
| 1  | 分钟     | 从 0 到 59               |
| 2  | 小时     | 从 0 到 23               |
| 3  | 月中的某一天 | 从 1 到 31               |
| 4  | 年中的某一月 | 从 1 到 12               |
| 5  | 星期几    | 从 0 到 7 (0 和 7 都表示星期日) |
| 6  | 要执行的任务 | 完整命令或脚本                |

!!! warning "警告"

    需执行的任务必须使用绝对路径，并应尽量配置输出重定向。

为了简化时间定义的符号，建议使用特殊符号。

| 特殊符号 | 说明         |
| ---- | ---------- |
| `*`  | 表示字段的所有时间值 |
| `-`  | 表示连续的时间范围  |
| `,`  | 表示不连续的时间范围 |
| `/`  | 表示时间间隔     |

示例：

脚本于4月15日上午10:25执行：

```bash
25 10 15 04 * /root/scripts/script > /log/…
```

每天上午11点和下午4点运行一次任务：

```bash
00 11,16 * * * /root/scripts/script > /log/…
```

该任务每天上午11点至下午4点每小时运行一次：

```bash
00 11-16 * * * /root/scripts/script > /log/…
```

工作日的工作时间每10分钟运行一次：

```bash
*/10 8-17 * * 1-5 /root/scripts/script > /log/…
```

对于 root 用户， `crontab` 也有一些特殊的时间设置：

| 设置        | 说明             |
| --------- | -------------- |
| @reboot   | 在系统重新启动时运行命令   |
| @hourly   | 每小时运行一次命令      |
| @daily    | 每天午夜后运行        |
| @weekly   | 每周日午夜后运行命令     |
| @monthly  | 在每月的第一天午夜后运行命令 |
| @annually | 1月1日午夜后运行      |

### 任务执行过程

用户 rockstar 想要编辑他的 `crontab` 文件：

1. `crond` 需要检查他是否被授权（依据 `/etc/cron.allow` 和 `/etc/cron.deny` ）。

2. 若授权通过，用户可访问其专属的 `crontab` 文件（`/var/spool/cron/rockstar`）。

`crond` 守护进程：

* 读取 - 每分钟读取所有用户的计划任务文件。
* 运行 - 根据计划运行任务。
* 写入 - 将相应的事件和消息写入到文件中（`/var/log/cron`）。
