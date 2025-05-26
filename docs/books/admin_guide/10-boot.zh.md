---
title: 系统启动
---

# 系统启动

在本章中，您将了解系统是如何启动的。

****
**目标** : 在本章中，未来的 Linux 管理员将学习：

:heavy_check_mark: 启动过程中的不同阶段；  
:heavy_check_mark: Rocky Linux 如何通过 GRUB2 和 `systemd` 来支持这种启动方式；  
:heavy_check_mark: 如何保护 GRUB2 免遭攻击；  
:heavy_check_mark: 如何管理各项服务；  
:heavy_check_mark: 如何通过 `journald` 访问日志。

:checkered_flag: **用户**。

**知识性**：:star: :star:  
**复杂度**：:star: :star: :star:

**阅读时间**: 20 分钟
****

## 引导过程

了解 Linux 的引导过程对于解决可能出现的问题至关重要。

系统的引导过程包括：

### BIOS 启动

**BIOS** (基本输入/输出系统) 用于执行 **POST** （开机自检） 来检测、测试和初始化系统硬件组件。

之后将加载 **MBR** （主引导记录）。

### 主引导记录（MBR）

主引导记录是引导磁盘的前 512 字节。 MBR 用于发现引导设备，将引导加载程序 **GRUB2** 加载到内存中然后将控制权转移给它。

接下来的 64 字节包含了磁盘的分区表。

### GRUB2 引导加载程序

Rocky 8 发行版的默认引导加载程序是 **GRUB2** (GRand Unified Bootloader)。 GRUB2 会取代旧的 GRUB 引导程序 (也称为 GRUB legacy)。

您可以在 `/boot/grub2/grub.cfg`下找到 GRUB2 配置文件，但不应直接编辑此文件。

您可以在 `/etc/default/grub` 下找到 GRUB2 菜单配置设置。  `grub2-mkconfig` 命令使用这些来生成 `grub.cfg` 文件。

```bash
# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/swap crashkernel=auto rd.lvm.lv=rhel/root rhgb quiet net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
```

如果更改了这些参数中的一个或多个，则必须运行 `grub2-mkconfig` 命令来重新生成 `/boot/grub2/grub.cfg` 文件。

```bash
[root] # grub2-mkconfig –o /boot/grub2/grub.cfg
```

* GRUB2 在 `/boot` 目录下寻找压缩的内核镜像 ( `vmlinuz` 文件) 。
* GRUB2 将内核镜像加载到内存中，并使用 `tmpfs` 文件系统将 `initramfs` 镜像文件的内容提取到内存中的一个临时文件夹。

### 内核

内核启动 PID 为 1 的 `systemd` 进程。

```bash
root          1      0  0 02:10 ?        00:00:02 /usr/lib/systemd/systemd --switched-root --system --deserialize 23
```

### `systemd`

`systemd` 是所有系统进程的父进程。 它会读取 `/etc/systemd/system/default.target` 链接的目标 (例如 `/usr/lib/systemd/system/multi-user.target`) ，以确定系统的默认目标。 该文件定义了要启动的服务。

`systemd` 然后通过执行以下初始化任务以将系统置于定义目标的状态：

1. 设置机器名
2. 初始化网络
3. 初始化 SELinux
4. 显示欢迎标语
5. 根据启动时给予内核的参数来初始化硬件
6. 挂载文件系统，包括虚拟文件系统（例如 /proc）
7. 清理 /var 中的目录
8. 启动虚拟内存 (swap)

## 保护 GRUB2 引导加载程序

为什么要用密码保护引导程序？

1. 防止 *单* 用户模式访问 - 如果攻击者能够启动到单用户模式，他就会成为 root 用户。
2. 防止访问 GRUB 控制台 - 如果攻击者设法使用 GRUB 控制台，他可以通过使用 `cat` 命令改变其配置或收集有关系统的信息。
3. 防止访问不安全的操作系统。 如果系统上有双引导，攻击者可以在引导时选择像 DOS 这样的操作系统从而忽略访问控制和文件权限。

用密码保护 GRUB2 引导加载程序：

1. 以 root 用户身份登录操作系统并执行 `grub2-mkpasswd-pbkdf2` 命令。 此命令的输出如下：

    ```bash
    Enter password:
    Reenter password:
    PBKDF2 hash of your password is grub.pbkdf2.sha512.10000.D0182EDB28164C19454FA94421D1ECD6309F076F1135A2E5BFE91A5088BD9EC87687FE14794BE7194F67EA39A8565E868A41C639572F6156900C81C08C1E8413.40F6981C22F1F81B32E45EC915F2AB6E2635D9A62C0BA67105A9B900D9F365860E84F1B92B2EF3AA0F83CECC68E13BA9F4174922877910F026DED961F6592BB7
    ```

    您需要在交互中输入密码。 密码密文是长字符串 "grub.pbkdf2.sha512..."。

2. 将密码密文粘贴到 **/etc/grub.d/00_header** 文件的最后一行。 粘贴格式如下：

    ```bash
    cat <<EOF
    set superusers='frank'
    password_obkdf2 frank grub.pbkdf2.sha512.10000.D0182EDB28164C19454FA94421D1ECD6309F076F1135A2E5BFE91A5088BD9EC87687FE14794BE7194F67EA39A8565E868A41C639572F6156900C81C08C1E8413.40F6981C22F1F81B32E45EC915F2AB6E2635D9A62C0BA67105A9B900D9F365860E84F1B92B2EF3AA0F83CECC68E13BA9F4174922877910F026DED961F6592BB7
    EOF
    ```

    您可以用任何自定义用户替换 "frank" 用户。

    您还可以设置明文密码，例如：

    ```bash
    cat <<EOF
    set superusers='frank'
    password frank rockylinux8.x
    EOF
    ```

3. 最后一步是运行命令 `grub2-mkconfig -o /boot/grub2/grub.cfg` 来更新 GRUB2 的设置。

4. 重新启动操作系统以验证 GRUB2 的加密。 选择第一个启动菜单项并键入 ++"e"++ 键，然后输入相应的用户和密码。

    ```bash
    Enter username:
    frank
    Enter password:

    ```

    验证成功后，输入 ++ctrl+"x"++ 启动操作系统。

有时，您可能会在某些文档中看到 `grub2-set-password` （`grub2-setpassword`）命令用于保护 GRUB2 引导加载程序：

| 命令                      | 核心功能      | 配置文件修改方法 | 自动化程度 |
| ----------------------- | --------- | -------- | ----- |
| `grub2-set-password`    | 设置密码并更新配置 | 自动完成     | 高     |
| `grub2-mkpasswd-pbkdf2` | 仅生成加密哈希值  | 需要手动编辑   | 低     |

以 root 用户身份登录操作系统并执行 `gurb2-set-password` 命令，如下所示：

```bash
[root] # grub2-set-password
Enter password:
Confirm password:

[root] # cat /boot/grub2/user.cfg
GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.32E5BAF2C2723B0024C1541F444B8A3656E0A04429EC4BA234C8269AE022BD4690C884B59F344C3EC7F9AC1B51973D65F194D766D06ABA93432643FC94119F17.4E16DF72AA1412599EEA8E90D0F248F7399E45F34395670225172017FB99B61057FA64C1330E2EDC2EF1BA6499146400150CA476057A94957AB4251F5A898FC3

[root] # grub2-mkconfig -o /boot/grub2/grub.cfg

[root] # reboot
```

执行 `grub2-set-password` 命令后将自动生成 **/boot/grub2/user.cfg** 文件。

选择第一个启动菜单项并键入 ++"e"++ 键，然后输入相应的用户和密码：

```bash
Enter username:
root
Enter password:

```

## Systemd

*Systemd* 是 Linux 操作系统的一个服务管理器。

`systemd` 的开发是为了：

* 保持与旧 SysV 初始化脚本的兼容性，
* 提供许多特性，例如在系统启动时并行启动系统服务、按需激活守护进程、支持快照或管理服务之间的依赖关系。

!!! note "说明"

    `systemd` 是自 RedHat/CentOS 7 以来的默认初始化系统。

`systemd` 中引入了单元文件的概念，也称为 `systemd` unit。

| 类型           | 文件扩展名        | 功能              |
| ------------ | ------------ | --------------- |
| Service unit | `.service`   | 系统服务            |
| Target unit  | `.target`    | 一组 systemd unit |
| Mount unit   | `.automount` | 文件系统的自动挂载点      |

!!! note "说明"

    有许多类型的 unit：Device unit、Mount unit、Path unit、Scope unit、Slice unit、Snapshot unit、Socket unit、Swap unit 和 Timer unit。

* `systemd` 支持系统状态的快照和还原。

* 您可以将挂载点配置为 `systemd` target。

* 在启动时，`systemd` 会为所有支持这种激活类型的系统服务创建监听套接字，并在这些服务启动后立即将这些套接字传递给它们。 这使得在服务不可用期间可以重新启动该服务而不会丢失网络发送给它的任何消息。 所有消息在排队期间，相应的套接字仍保持可访问状态。

* 使用 D-BUS 进行进程间通信的系统服务可在客户端首次使用时按需启动。

* `systemd` 仅停止或重新启动正在运行的服务。 以前的版本（RHEL7 之前）会尝试直接停止服务而不会检查其当前状态。

* 系统服务不会继承任何上下文环境（如 HOME 和 PATH 等环境变量）。 每个服务均在其独立的执行上下文中运行。

所有服务 unit 的操作默认受 5 分钟超时限制，以防止故障服务导致系统冻结。

由于篇幅限制，本文将不提供 `systemd` 的详细介绍。 如果你有兴趣进一步探索 `systemd`，在 [这个文档](./16-about-sytemd.md) 中有非常详细的介绍。

### 管理系统服务

服务 unit 以 `.service` 文件扩展名结尾，其用途与 init 脚本类似。 `systemctl` 命令的用途是 `显示`、`启动`、`停止` 或 `重新启动` 系统服务。 除极少数情况外，`systemctl` 单行命令在大多数情况下可以操作一个或多个 unit（不限于 “.service”的 unit 类型）。 您可以通过帮助系统查看它。

| systemctl                                 | 说明                  |
| ----------------------------------------- | ------------------- |
| systemctl start *name*.service ...        | 启动一个或多个服务           |
| systemctl stop *name*.service ...         | 停止一个或多个服务           |
| systemctl restart *name*.service ...      | 重启一个或多个服务           |
| systemctl reload *name*.service ...       | 重新加载一个或多个服务         |
| systemctl status *name*.service ...       | 检查一个或多个服务状态         |
| systemctl try-restart *name*.service ...  | 重启一个或多个服务（如果它们正在运行） |
| systemctl list-units --type service --all | 显示所有服务的状态           |

`systemctl` 命令还用于 `启用` 或 `禁用` 系统服务，并显示关联的服务：

| systemctl                                | 说明                 |
| ---------------------------------------- | ------------------ |
| systemctl enable *name*.service ...      | 激活一个或多个服务          |
| systemctl disable *name*.service ...     | 禁用一个或多个服务          |
| systemctl list-unit-files --type service | 列出所有服务并检查它们是否正在运行  |
| systemctl list-dependencies --after      | 列出在指定 unit 之前启动的服务 |
| systemctl list-dependencies --before     | 列出在指定 unit 之后启动的服务 |

示例：

```bash
systemctl stop nfs-server.service
# 或
systemctl stop nfs-server
```

要列出当前加载的所有 unit：

```bash
systemctl list-units --type service
```

可以使用以下命令列出要检查的所有 unit 激活状态：

```bash
systemctl list-unit-files --type service
```

```bash
systemctl enable httpd.service
systemctl disable bluetooth.service
```

### 后缀服务的 .service 文件示例

```bash
postfix.service Unit File
What follows is the content of the /usr/lib/systemd/system/postfix.service unit file as currently provided by the postfix package:

[Unit]
Description=Postfix Mail Transport Agent
After=syslog.target network.target
Conflicts=sendmail.service exim.service

[Service]
Type=forking
PIDFile=/var/spool/postfix/pid/master.pid
EnvironmentFile=-/etc/sysconfig/network
ExecStartPre=-/usr/libexec/postfix/aliasesdb
ExecStartPre=-/usr/libexec/postfix/chroot-update
ExecStart=/usr/sbin/postfix start
ExecReload=/usr/sbin/postfix reload
ExecStop=/usr/sbin/postfix stop

[Install]
WantedBy=multi-user.target
```

### 使用系统 target

`systemd` target 取代了 SysV 或 Upstart 上的运行级别概念。

`systemd` target 的表示是通过 target unit 进行的。 Target unit 以 `.target ` 文件扩展名结尾，其唯一目的是将其他 `systemd` unit 组织成具有依赖关系的链式结构。

例如，启动图形会话的 `graphical.target` unit 会启动相应的系统服务，如 **GNOME 显示管理器**（`gdm.service`）或 **帐户服务**（`accounts-daemon.service`），并同时激活 `multi-user.target` unit。 如果需要查看某个 "target" 的依赖关系，请执行 `systemctl list-dependencies` 命令。 （例如，`systemctl list-dependencies multi-user.target`）。

`sysinit.target` 和 `basic.target` 是启动过程中的检查点。 尽管 `systemd` 的设计目标之一是并行启动系统服务，但在启动其他服务和 "targets"之前，有必要先启动某些服务和功能的 "targets"。 `sysinit.target` 或 `basic target` 中的任何错误都将导致 `systemd` 的初始化失败。 此时，您的终端可能已进入到 "紧急模式"（`emergency.target`）。

| Target Units      | 说明             |
| ----------------- | -------------- |
| poweroff.target   | 关闭系统           |
| rescue.target     | 激活救援外壳         |
| multi-user.target | 激活没有图形界面的多用户系统 |
| graphical.target  | 激活带图形界面的多用户系统  |
| reboot.target     | 关闭并重新启动系统      |

#### 默认 target

要确定默认的 target，请执行以下操作：

```bash
systemctl get-default
```

此命令会搜索位于 `/etc/systemd/system/default.target` 的符号链接目标并显示结果。

```bash
$ systemctl get-default
graphical.target
```

`systemctl` 命令还可以提供可用 target 的列表：

```bash
systemctl list-units --type target
UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
basic.target           loaded active active Basic System
bluetooth.target       loaded active active Bluetooth
cryptsetup.target      loaded active active Encrypted Volumes
getty.target           loaded active active Login Prompts
graphical.target       loaded active active Graphical Interface
local-fs-pre.target    loaded active active Local File Systems (Pre)
local-fs.target        loaded active active Local File Systems
multi-user.target      loaded active active Multi-User System
network-online.target  loaded active active Network is Online
network.target         loaded active active Network
nss-user-lookup.target loaded active active User and Group Name Lookups
paths.target           loaded active active Paths
remote-fs.target       loaded active active Remote File Systems
slices.target          loaded active active Slices
sockets.target         loaded active active Sockets
sound.target           loaded active active Sound Card
swap.target            loaded active active Swap
sysinit.target         loaded active active System Initialization
timers.target          loaded active active Timers
```

为当前操作系统设置不同的默认 target，请执行以下操作：

```bash
systemctl set-default name.target
```

示例：

```bash
# systemctl set-default multi-user.target
rm '/etc/systemd/system/default.target'
ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
```

在当前会话中切换到不同的 target unit：

```bash
systemctl isolate name.target
```

**救援模式** 提供了一个简单的环境，用于在无法进行正常引导过程的情况下修复系统。

在 `救援模式` 下，系统会尝试挂载所有本地文件系统并启动几个重要的系统服务，但不启用网络接口或允许其他用户同时连接到系统。

在 Rocky 8 上，`救援模式` 相当于旧的 `单用户模式` 并且需要 root 密码。

更改当前 target 并进入到 `救援模式`：

```bash
systemctl rescue
```

**紧急模式** 提供了尽可能的最小环境并允许系统在无法进入到救援模式的情况下进行维护。 在紧急模式下，操作系统以只读选项挂载根文件系统。 它不会尝试挂载任何其他本地文件系统，也不会激活任何网络接口，并且会启动一些基本服务。

更改当前 target 并进入到紧急模式：

```bash
systemctl emergency
```

#### 关机、暂停和休眠

`systemctl` 命令取代了以前版本中使用的许多电源管理命令：

| 旧命令                 | 新命令                      | 说明       |
| ------------------- | ------------------------ | -------- |
| `halt`              | `systemctl halt`         | 关闭系统。    |
| `poweroff`          | `systemctl poweroff`     | 关闭系统。    |
| `reboot`            | `systemctl reboot`       | 重启系统。    |
| `pm-suspend`        | `systemctl suspend`      | 暂停系统。    |
| `pm-hibernate`      | `systemctl hibernate`    | 休眠系统。    |
| `pm-suspend-hybrid` | `systemctl hybrid-sleep` | 休眠和暂停系统。 |

### `journald` 进程

您可以使用 `journald` 守护程序管理日志文件，`除了 rsyslogd 之外，它也是 systemd 的组件之一`。

`journald` 守护程序负责捕获以下类型的日志消息：

* Syslog 消息
* 内核日志消息
* Initramfs 和系统启动日志
* 所有服务的标准输出（stdout）和标准错误输出（stderr）信息

捕获后，`journald` 将对这些日志进行索引，并通过结构化存储机制提供给用户。该机制以二进制格式存储日志，支持按时间顺序跟踪事件，并提供灵活的过滤、搜索和多种格式（如 text/JSON）输出功能。 请注意，`journald` 默认情况下不启用日志持久性，这意味着该组件仅保留和记录自启动以来的所有日志。 操作系统重新启动后，会删除历史日志。 默认情况下，所有临时保存的日志文件都位于 **/run/log/journal/** 目录中。

### `journalctl` 命令

`journalctl` 命令用于解析以二进制格式保存的日志文件，例如查看日志文件、过滤日志和控制输出条目。

```bash
journalctl
```

如果不带其他选项运行该命令，则输出的日志内容类似于 `/var/log/messages` 文件，但 `journalctl` 提供了以下改进：

* 显示条目的优先级以视觉方式标记
* 时间戳转换为系统的本地时区
* 显示所有记录的数据，包括轮替日志
* 用一条特殊的线来标记开始

#### 使用连续显示

通过连续显示，实时显示日志消息。

```bash
journalctl -f
```

该命令返回最近十个日志行的列表。 然后 `journalctl` 实用程序将继续运行，并等待发生新的更改，然后立即显示它们。

#### 过滤消息

可以使用不同的过滤方法来提取符合不同需求的信息。 日志消息通常用于跟踪系统上的错误行为。 要查看具有选定或更高优先级的条目，请执行以下操作：

```bash
journalctl -p priority
```

必须将 priority 替换为以下关键字（或数字）之一：

* debug (7)，
* info (6)，
* notice (5)，
* warning (4)，
* err (3)，
* crit (2)，
* alert (1)，
* emerg (0)。

如果您想了解更多有关日志内容的信息，请参阅 [本文档](./17-log.md)。
