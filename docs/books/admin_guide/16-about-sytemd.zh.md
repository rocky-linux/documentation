---
title: 关于 systemd
author: tianci li
contributors: Steven Spencer
tags:
  - 初始化软件
  - systemd
  - Upstart
  - System V
---

# 基本概述

**`systemd`**，也称为 **system daemon**，是 GNU/Linux 操作系统下的一种初始化软件。

开发目的：

- 以提供一个更完善的框架来表示服务之间的依赖关系
- 在系统初始化时实现服务的并行启动
- 减少 shell 开销并取代 SysV 风格的初始化

**`systemd`** 为 GNU/Linux 操作系统提供了一系列系统组件，以统一 GNU/Linux 发行版之间的服务配置和行为，并消除其使用差异。

自 2015 年以来，大多数 GNU/Linux 发行版都采用了 `systemd` 来取代诸如 SysV 之类的传统初始化程序。 值得一提的是，`systemd` 的许多概念和设计都受到了苹果 Mac OS 的 **launchd** 的启发。

![初始化对比](./images/16-init-compare.jpg)

`systemd` 的出现在开源社区引起了巨大的争议。

赞美的声音：

- 开发人员和用户称赞 `systemd` 消除了 GNU/Linux 之间的使用差异，并提供了更稳定、更快捷的开箱即用解决方案。

批评的声音：

- `systemd` 接管了操作系统上太多的组件，违反了 UNIX 的 KISS（**K**eep **I**t **S**imple, **S**tupid）原则。
- 从代码的角度来看，`systemd` 过于复杂和繁琐，其代码量超过一百万行，这降低了可维护性并增加了被攻击的风险。

官方网站 - [https://systemd.io/](https://systemd.io/)
Github 存储库 - [https://github.com/systemd/systemd](https://github.com/systemd/systemd)

## 发展历史

2010年，两位红帽软件工程师 Lennart Poettering 和 Kay Sievers 开发了第一个版本的 `systemd`来取代传统的 SysV。

![Lennart Poettering](./images/16-Lennart-Poettering.jpg)

![Kay Sievers](./images/16-Kay-Sievers.jpg)

2011年5月，Fedora 15 成为第一个默认启用 `systemd` 的 GNU/Linux 发行版，当时给出的理由为：

> systemd provides aggressive parallelization capabilities, uses socket and D-Bus activation for starting services, offers on-demand starting of daemons, keeps track of processes using Linux cgroups, supports snapshotting and restoring of the system state, maintains mount and automount points and implements a powerful transactional dependency-based service control logic. It can work as a drop-in replacement for sysvinit.

2012年10月，Arch Linux 默认使用 `systemd` 启动。

从 2013 年 10 月到 2014 年 2 月，Debian 技术委员会在 Debian 邮件列表上进行了长时间的讨论，重点是 "Debian 8 Jessie 应该使用哪种初始化作为系统默认”，最终决定使用 `systemd`。

2014年2月，Ubuntu 采用 `systemd` 作为其初始化，并放弃了自己的 Upstart。

2015 年 8 月，`systemd` 开始提供可通过 `machinectl` 调用的登录 shell。

2016年，`systemd` 发现了一个安全漏洞，允许任何非特权用户对 `systemd` 执行 "拒绝服务攻击"。

2017年，`systemd` 发现了另一个安全漏洞 **CVE-2017-9445**。 远程攻击者可以通过恶意的 DNS 响应触发缓冲区溢出漏洞并执行恶意代码。

!!! info "信息"

```
**缓冲区溢出**：这是一种程序设计缺陷，即向程序的输入缓冲区写入数据，导致缓冲区溢出（通常输入的数据量超过缓冲区所能存储的最大数据量），从而破坏程序的运行，利用程序运行中断的时机，获取对程序甚至系统的控制权。
```

## 架构设计

在这里，作者以三星 Tizen 系统所使用的 `systemd` 为例，来说明其架构。

![Tizen-systemd](./images/16-tizen-systemd.png)

!!! info "信息"

```
**Tizen** - 一款基于 Linux 内核的移动操作系统，由 Linux 基金会支持，主要由三星公司开发和使用。
```

!!! info "信息"

```
`systemd` 的一些 "targets" 不属于 `systemd` 组件，如 `telephony`、`bootmode`、`dlog`、`tizen service`，它们实际上属于 Tizen。
```

`systemd` 采用模块化设计。 在编译时存在许多配置开关，用于决定哪些部分会被构建、哪些部分不会被构建，类似于 Linux 内核的模块化设计。 在编译完成后，`systemd` 可能会有多达 69 个二进制可执行文件，它们负责执行以下任务：

- `systemd` 以 PID 1运行，并提供尽可能多的并行服务的启动。 这也管理着关机顺序。
- `systemctl` 程序为服务管理提供用户接口。
- 同时提供对 SysV 和 LSB 脚本的支持，以确保兼容性。
- 与 SysV 相比，`systemd` 的服务管理和报告可以输出更详细的信息。
- 通过分层挂载和卸载文件系统，`systemd` 能更安全地实现文件系统级联挂载。
- `systemd` 提供基础组件配置的管理，包括主机名、时间日期、区域、日志等。
- 提供套接字管理。
- `systemd` 定时器提供类似于 cron 计划任务的功能。
- 支持创建和管理临时文件，包括删除。
- D-Bus 接口能够实现当设备插入或移除时运行脚本的功能。 通过这种方式，无论是可插拔设备还是非可插拔设备，都可以被视为即插即用设备，从而极大地简化了设备处理过程。
- 启动顺序分析工具可用于定位耗时最长的服务。
- 日志和服务的管理。

**`systemd` 不仅仅是一个初始化程序，它是一个接管许多系统组件的大型软件套件。**

## `systemd` 作为 PID 1

`systemd` 挂载是通过使用 **/etc/fstab** 文件的内容来确定的，包括交换分区。

默认的 "target" 配置是通过使用 **/etc/systemd/system/default.target** 来确定的。

此前，在使用 SysV 初始化时，存在 **runlevel** 这一概念。 而在 `systemd` 中，也有一个相关的兼容性对比表，如下所示（按依赖项数量从多到少排列）：

| systemd targets                   | SystemV runlevel | target 别名（软链接）                   | 描述                                                                                                                                                                                                                                                                       |
| :-------------------------------- | :--------------- | :------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| default.target    |                  |                                  | 此 "target" 始终是指向 "multi-user.target" 或 "graphical.target" 的软链接。 `systemd` 总是使用 "default.target" 来启动系统。 请注意！ 它不能是 "halt.target"、"poweroff.target" 或 "reboot.target" 的软链接。 |
| graphical.target  | 5                | runlevel5.target | GUI 环境。                                                                                                                                                                                                                                                                  |
|                                   | 4                | runlevel4.target | 保留和未使用。 在 SysV 初始化程序中，runlevel4 与 runlevel3 相同。 在 `systemd` 初始化程序中，用户可以创建和自定义此 "target" 以启动本地服务，而无需更改默认的 "multi-user.target"。                                                                                                                            |
| multi-user.target | 3                | runlevel3.target | 完全多用户的命令行模式。                                                                                                                                                                                                                                                             |
|                                   | 2                |                                  | 在 SystemV 中，它指的是不包括 NFS 服务的多用户命令行模式。                                                                                                                                                                                                                                     |
| rescue.target     | 1                | runlevel1.target | 在 SystemV 中，它被称为 **单用户模式**，其只会启动最基本的服务，不会启动其他附加程序或驱动程序。 它主要用于修复操作系统。 它类似于 Windows 操作系统的安全模式。                                                                                                                                                                             |
| emergency.target  |                  |                                  | 基本上等同于 "rescue.target"。                                                                                                                                                                                                                                  |
| reboot.target     | 6                | runlevel6.target | 重启。                                                                                                                                                                                                                                                                      |
| poweroff.target   | 0                | runlevel0.target | 关闭操作系统并关闭电源。                                                                                                                                                                                                                                                             |

```bash
Shell > find  / -iname  runlevel?\.target -a -type l -exec ls -l {} \;
lrwxrwxrwx 1 root root 17 8月  23 03:05 /usr/lib/systemd/system/runlevel4.target -> multi-user.target
lrwxrwxrwx 1 root root 17 8月  23 03:05 /usr/lib/systemd/system/runlevel3.target -> multi-user.target
lrwxrwxrwx 1 root root 13 8月  23 03:05 /usr/lib/systemd/system/runlevel6.target -> reboot.target
lrwxrwxrwx 1 root root 13 8月  23 03:05 /usr/lib/systemd/system/runlevel1.target -> rescue.target
lrwxrwxrwx 1 root root 16 8月  23 03:05 /usr/lib/systemd/system/runlevel5.target -> graphical.target
lrwxrwxrwx 1 root root 15 8月  23 03:05 /usr/lib/systemd/system/runlevel0.target -> poweroff.target
lrwxrwxrwx 1 root root 17 8月  23 03:05 /usr/lib/systemd/system/runlevel2.target -> multi-user.target

Shell > ls -l /etc/systemd/system/default.target
lrwxrwxrwx. 1 root root 41 12月 23 2022 /etc/systemd/system/default.target -> /usr/lib/systemd/system/multi-user.target
```

每个 "target" 在其配置文件中都有一组描述的依赖项，这些依赖项是在特定运行级别运行 GNU/Linux 主机所需的服务。 您拥有的功能越多，"target" 所需的依赖项就越多。 例如，GUI 环境需要比命令行模式更多的服务。

从手册页（`man 7 bootup`）中，我们可以查阅 `systemd` 的启动流程图：

```text
 local-fs-pre.target
                    |
                    v
           (various mounts and   (various swap   (various cryptsetup
            fsck services...)     devices...)        devices...)       (various low-level   (various low-level
                    |                  |                  |             services: udevd,     API VFS mounts:
                    v                  v                  v             tmpfiles, random     mqueue, configfs,
             local-fs.target      swap.target     cryptsetup.target    seed, sysctl, ...)      debugfs, ...)
                    |                  |                  |                    |                    |
                    \__________________|_________________ | ___________________|____________________/
                                                         \|/
                                                          v
                                                   sysinit.target
                                                          |
                     ____________________________________/|\________________________________________
                    /                  |                  |                    |                    \
                    |                  |                  |                    |                    |
                    v                  v                  |                    v                    v
                (various           (various               |                (various          rescue.service
               timers...)          paths...)              |               sockets...)               |
                    |                  |                  |                    |                    v
                    v                  v                  |                    v              rescue.target
              timers.target      paths.target             |             sockets.target
                    |                  |                  |                    |
                    v                  \_________________ | ___________________/
                                                         \|/
                                                          v
                                                    basic.target
                                                          |
                     ____________________________________/|                                 emergency.service
                    /                  |                  |                                         |
                    |                  |                  |                                         v
                    v                  v                  v                                 emergency.target
                display-        (various system    (various system
            manager.service         services           services)
                    |             required for            |
                    |            graphical UIs)           v
                    |                  |           multi-user.target
                    |                  |                  |
                    \_________________ | _________________/
                                      \|/
                                       v
                             graphical.target
```

- "sysinit.target" 和 "basic.target" 是启动过程中的检查点。 虽然 `systemd` 的设计目标之一是并行启动系统服务，但在启动其他服务和 "targets" 之前，有必要先启动某些服务和功能的 "targets"
- 在 "sysinit.target" 所依赖的 "units" 完成之后，启动过程将会进入 "sysinit.target" 阶段。 这些 "units" 可以并行启动，包括：
  - 挂载文件系统
  - 设置交换文件
  - 启动 udev
  - 设置随机生成器种子
  - 启动低级别服务
  - 设置加密服务
- "sysinit.target" 将启动操作系统基本功能所需的所有低级服务和 "units"，这些是进入 "basic.target" 阶段之前所必需的。
- 在完成 "sysinit.target" 阶段后，`systemd` 会启动完成下一个 "target"（即 "basic.target"）所需的所有 "units" 。 该 target 还具备以下附加功能：
  - 设置各种可执行文件的目录路径。
  - 通信套接字
  - 定时器
- 最后，对用户级 "target"（"multi-user.target" 或 "graphical.target"）执行初始化。 `systemd` 必须先到达 "multi-user.target"，然后才能进入 "graphical.target"。

您可以运行以下命令来查看完整启动所需的依赖项：

```bash
Shell > systemctl list-dependencies multi-user.target
multi-user.target
● ├─auditd.service
● ├─chronyd.service
● ├─crond.service
● ├─dbus.service
● ├─irqbalance.service
● ├─kdump.service
● ├─NetworkManager.service
● ├─sshd.service
● ├─sssd.service
● ├─systemd-ask-password-wall.path
● ├─systemd-logind.service
● ├─systemd-update-utmp-runlevel.service
● ├─systemd-user-sessions.service
● ├─tuned.service
● ├─basic.target
● │ ├─-.mount
● │ ├─microcode.service
● │ ├─paths.target
● │ ├─slices.target
● │ │ ├─-.slice
● │ │ └─system.slice
● │ ├─sockets.target
● │ │ ├─dbus.socket
● │ │ ├─sssd-kcm.socket
● │ │ ├─systemd-coredump.socket
● │ │ ├─systemd-initctl.socket
● │ │ ├─systemd-journald-dev-log.socket
● │ │ ├─systemd-journald.socket
● │ │ ├─systemd-udevd-control.socket
● │ │ └─systemd-udevd-kernel.socket
● │ ├─sysinit.target
● │ │ ├─dev-hugepages.mount
● │ │ ├─dev-mqueue.mount
● │ │ ├─dracut-shutdown.service
● │ │ ├─import-state.service
● │ │ ├─kmod-static-nodes.service
● │ │ ├─ldconfig.service
● │ │ ├─loadmodules.service
● │ │ ├─nis-domainname.service
● │ │ ├─proc-sys-fs-binfmt_misc.automount
● │ │ ├─selinux-autorelabel-mark.service
● │ │ ├─sys-fs-fuse-connections.mount
● │ │ ├─sys-kernel-config.mount
● │ │ ├─sys-kernel-debug.mount
● │ │ ├─systemd-ask-password-console.path
● │ │ ├─systemd-binfmt.service
● │ │ ├─systemd-firstboot.service
● │ │ ├─systemd-hwdb-update.service
● │ │ ├─systemd-journal-catalog-update.service
● │ │ ├─systemd-journal-flush.service
● │ │ ├─systemd-journald.service
● │ │ ├─systemd-machine-id-commit.service
● │ │ ├─systemd-modules-load.service
● │ │ ├─systemd-random-seed.service
● │ │ ├─systemd-sysctl.service
● │ │ ├─systemd-sysusers.service
● │ │ ├─systemd-tmpfiles-setup-dev.service
● │ │ ├─systemd-tmpfiles-setup.service
● │ │ ├─systemd-udev-trigger.service
● │ │ ├─systemd-udevd.service
● │ │ ├─systemd-update-done.service
● │ │ ├─systemd-update-utmp.service
● │ │ ├─cryptsetup.target
● │ │ ├─local-fs.target
● │ │ │ ├─-.mount
● │ │ │ ├─boot.mount
● │ │ │ ├─systemd-fsck-root.service
● │ │ │ └─systemd-remount-fs.service
● │ │ └─swap.target
● │ │   └─dev-disk-by\x2duuid-76e2324e\x2dccdc\x2d4b75\x2dbc71\x2d64cd0edb2ebc.swap
● │ └─timers.target
● │   ├─dnf-makecache.timer
● │   ├─mlocate-updatedb.timer
● │   ├─systemd-tmpfiles-clean.timer
● │   └─unbound-anchor.timer
● ├─getty.target
● │ └─getty@tty1.service
● └─remote-fs.target
```

您还可以使用 `--all` 选项展开所有 "units"。

## 使用 `systemd`

### Unit 类型

`systemctl` 命令是管理 `systemd` 的 "unit(s)" 及相关文件的主要工具。

`systemd` 管理着所谓的 "units"，这些 "units" 代表了系统资源和服务。 以下列表列出了 `systemd` 能够管理的 "unit" 类型：

- **service** - 系统上的服务，包含有关启动、重启和停止该服务的说明。 查阅 `man 5 systemd.service`。
- **socket** - 与某项服务相关联的网络套接字。 查阅 `man 5 systemd.socket`。
- **device** - 由 `systemd` 专门管理的设备。 查阅 `man 5 systemd.device`。
- **mount** - 由 `systemd` 管理的挂载点。 查阅 `man 5 systemd.mount`。
- **automount** - 启动时自动挂载的挂载点。 查阅 `man 5 systemd.automount`。
- **swap** - 在系统上交换空间。 查阅 `man 5 systemd.swap`。
- **target** - 其他 unit 的同步点。 通常用于在启动时启动已启用的服务。 查阅 `man 5 systemd.target`。
- **path** - 基于路径的激活路径。 例如，你可以根据某个路径的状态（如是否存在）来启动服务。 查阅 `man 5 systemd.path`。
- **timer** - 用于安排另一个单元激活的计时器。 查阅 `man 5 systemd.timer`。
- **snapshot** - 当前 `systemd` 状态的快照。 通常用于对 `systemd` 进行临时修改后的回退操作。
- **slice** - 通过 Linux 控制组节点（cgroups）来限制资源。 查阅 `man 5 systemd.slice`。
- **scope** - 来自 `systemd` 总线接口的信息。 通常用于管理外部系统进程。 查阅 `man 5 systemd.scope`。

### 操作 "units"

`systemictl` 命令的用法是 - `systemctl [OPTIONS...] COMMAND [UNIT...]`。

COMMAND 可分为：

- Unit Commands
- Unit File Commands
- Machine Commands
- Job Commands
- Environment Commands
- Manager Lifecycle Commands
- System Commands

您可以使用 `systemctl --help` 来获取详细信息。

以下是一些常见的操作演示命令：

```bash
# 启动服务
Shell > systemctl start sshd.service

# 停止服务
Shell > systemctl stop sshd.service

# 重载服务
Shell > systemctl reload sshd.service

# 重启服务
Shell > systemctl restart sshd.service

# 浏览服务状态
Shell > systemctl status sshd.service

# 系统启动后，该服务会自动启动
Shell > systemctl enable sshd.service

# 系统启动后，该服务会自动停止运行
Shell > systemctl disable sshd.service

# 检查该服务在系统启动后是否能自动启动
Shell > systemctl is-enabled sshd.service

# 掩盖一个 unit
Shell > systemctl mask sshd.service

# 解除掩码一个 unit
Shell > systemctl unmask sshd.service

# 查看 unit 文件内容
Shell > systemctl cat sshd.service

# 编辑 unit 文件的内容，并在编辑后将其保存在 /etc/systemd/system/ 目录中
Shell > systemctl edit sshd.service

# 查看 unit 的全部属性
Shell > systemctl show sshd.service
```

!!! info "信息"

```
您可以在单个命令行中对一个或多个 unit 执行上述操作。上述操作不限于 ".service"。
```

关于 "unit"：

```bash
# 列出所有当前运行的单元。
Shell > systemctl
## 或者
Shell > systemctl list-units
## 您还可以添加 "--type=TYPE" 进行类型筛选
Shell > systemctl --type=target

# 列出所有单位文件。您还可以使用 "--type=TYPE" 进行筛选
Shell > systemctl list-unit-files
```

关于 "target"：

```bash
# 查询当前 "target"（"runlevel"）信息
Shell > systemctl get-default
multi-user.target

# 切换 "target"（"runlevel"）。例如，您需要切换到 GUI 环境
Shell > systemctl isolate graphical.target

# 定义默认的 "target"（"runlevel"）
Shell > systemctl set-default graphical.target
```

### 重要目录

存在三个主要的重要目录，按优先级升序排列：

- **/usr/lib/systemd/system/** - 随安装的 RPM 软件包分发的 systemd unit 文件。 与 CentOS 6 中的 /etc/init.d/ 目录类似。
- **/run/systemd/system/** - 在运行时创建的 systemd unit 文件。
- **/etc/systemd/system/** - 由 `systemctl enable` 创建的 systemd unit 文件以及为扩展服务而添加的 unit 文件。

### `systemd` 配置文件

`man 5 systemd-system.conf`：

> When run as a system instance, systemd interprets the configuration file "system.conf" and the files in "system.conf.d" directories; when run as a user instance, it interprets the configuration file user.conf (either in the home directory of the user, or if not found, under "/etc/systemd/") and the files in "user.conf.d" directories. These configuration files contain a few settings controlling basic manager operations.

在 Rocky Linux 8.x 操作系统中，相关的配置文件有：

- **/etc/systemd/system.conf** - 编辑该文件以更改设置。 删除该文件将恢复默认设置。 参阅 `man 5 systemd-system.conf`
- **/etc/systemd/user.conf** - 您可以通过在 "/etc/systemd/user.conf.d/\*.conf" 目录下创建文件来覆盖此文件中的指令。 参阅 `man 5 systemd-user.conf`

### `systemd` unit 文件内容说明

以文件 sshd.service 为例：

```bash
Shell > systemctl cat sshd.service
[Unit]
Description=OpenSSH server daemon
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target sshd-keygen.target
Wants=sshd-keygen.target

[Service]
Type=notify
EnvironmentFile=-/etc/crypto-policies/back-ends/opensshserver.config
EnvironmentFile=-/etc/sysconfig/sshd
ExecStart=/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
```

如您所见，单元文件的内容与 RL 9 网卡的配置文件具有相同的样式。 它使用 ++open-bracket++ 和 ++close-bracket++ 来包含标题，标题下方是相关的键值对。

```bash
# RL 9
Shell > cat /etc/NetworkManager/system-connections/ens160.nmconnection
[connection]
id=ens160
uuid=5903ac99-e03f-46a8-8806-0a7a8424497e
type=ethernet
interface-name=ens160
timestamp=1670056998

[ethernet]
mac-address=00:0C:29:47:68:D0

[ipv4]
address1=192.168.100.4/24,192.168.100.1
dns=8.8.8.8;114.114.114.114;
method=manual

[ipv6]
addr-gen-mode=default
method=disabled

[proxy]
```

".service" 类型的 unit 通常有三个标题：

- **Unit**
- **Service**
- **Install**

1. Unit 标题

   以下键值对可用：

   - `Description=OpenSSH server daemon`。 该字符串用于描述 "unit"。
   - `Documentation=man:sshd(8) man:sshd_config(5)`。  以空格分隔的 URI 列表，用于引用此 "unit" 或其配置的相关文档。 只接受类型为 "http://"、"https://"、"file:"、"info:"、"man:" 的 URI。
   - `After=network.target sshd-keygen.target`。 定义与其他 "units" 的启动顺序关系。 在这个例子中，"network.target" 和 "sshd-keygen.target" 首先启动，"sshd.service" 最后启动。
   - `Before=`。 定义与其他 "units" 的启动顺序关系。
   - `Requires=`。 配置对其他 "unit" 的依赖关系。 值可以是用空格分隔的多个 units。 如果当前 "unit" 处于激活状态，此处列出的值也将被激活。 如果 "unit" 列出的值中至少有一个未能成功激活，systemd 将不会启动当前 "unit"。
   - `Wants=sshd-keygen.target`。 与 `Requires` 键类似。 区别在于，若依赖的 unit 启动失败，不会影响当前 "unit" 的正常运行。
   - `BindsTo=`。 与 `Requires` 键类似。 区别在于，如果任何依赖的 "unit" 启动失败，除了停止依赖关系的 "unit" 之外，当前 unit 也会被停止。
   - `PartOf=`。 与 `Requires` 键类似。 区别在于，如果任何依赖的 "unit" 启动失败，除了停止并重启依赖 units 外，当前的 "unit" 也将被停止并重启。
   - `Conflicts=`。 其值是一个由空格分隔的 "unit" 列表。 若值中列出的 "unit" 正在运行，则当前 "unit" 无法运行。
   - `OnFailure=`。 当当前 "单元" 失效时，值中包含的 "unit" 或 "units"（用空格分隔）将被激活。

   参阅 `man 5 systemd.unit` 来获取更多信息。

2. Service 标题

   以下键值对可用：

   - `Type=notify`。 配置此 ".service" unit 的类型，可以是以下类型之一：
     - `simple` - 服务作为主进程启动。 这是默认的。
     - `forking` - 服务调用分叉进程并作为主守护进程的一部分来运行。
     - `exec` - 与 `simple` 类似。 服务管理器将在执行主服务二进制文件后立即启动该 unit。 其他后续 unit 必须在此之后才能解除阻塞状态并继续启动。
     - `oneshot` - 与 `simple` 类似，但该进程必须在 `systemd` 启动后续服务之前退出。
     - `dbus` - 与 `simple` 类似，但守护进程会获取 D-Bus 总线名称。
     - `notify` - 与 `simple` 类似，但守护进程在启动后会使用 `sd_notify` 或等效调用发送通知消息。
     - `idle` - 与 `simple` 类似，但服务的执行会延迟进行，直到所有正在运行的任务都已完成调度。
   - `RemainAfterExit=`。 当服务的所有进程退出时，当前服务是否应被视为活跃的。 默认为 no。
   - `GuessMainPID=`。 该值的类型为 boolean，默认为 yes。 当服务的主进程位置不明确时，`systemd` 是否应尝试猜测主进程的 PID（该可能不准确）。 若设置 `Type=forking` 且未设置 `PIDFile`，则此键值对将生效。 否则会忽略该键值对。
   - `PIDFile=`。 指定服务 PID 的文件路径（绝对路径）。 对于 `Type=forking` 的服务，建议使用此键值对。 `systemd` 在服务启动后读取守护进程主进程的 PID。
   - `BusName=`。 用于访问此服务的 D-Bus 总线名称。 对于使用 `Type=dbus` 的服务，此选项为必填项。
   - `ExecStart=/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY`。 服务启动时执行的命令和参数。
   - `ExecStartPre=`。 其他命令会在 `ExecStart` 中的命令之前执行。
   - `ExecStartPost=`。 其他命令会在 `ExecStart` 中的命令之后执行。
   - `ExecReload=/bin/kill -HUP $MAINPID`。 服务重载时执行的命令和参数。
   - `ExecStop=`。 服务停止时执行的命令和参数。
   - `ExecStopPost=`。 服务停止后需执行的附加命令。
   - `RestartSec=42s`。 重新启动服务前的睡眠时间（单位：秒）。
   - `TimeoutStartSec=`。 等待服务启动的秒数。
   - `TimeoutStopSec=`。 等待服务停止的时间（单位：秒）。
   - `TimeoutSec=`。 同时配置 `TimeoutStartSec` 和 `TimeoutStopSec` 的简写方式。
   - `RuntimeMaxSec=`。 服务运行的最大时间（单位：秒）。 将 `infinity`（默认值）作为参数传递，以取消设置运行时限制。
   - `Restart=on-failure`。 配置当服务进程退出、被终止或达到超时时间时是否重启服务：
     - `no` - 服务不会重新启动。 这是默认的。
     - `on-success` - 仅当服务进程正常退出（退出代码为0）时才重新启动。
     - `on-failure` - 仅在服务进程未正常退出（node-zero 退出代码）时重新启动。
     - `on-abnormal` - 若进程因信号而终止或出现超时情况，则会重新启动。
     - `on-abort` - 如果进程因未被捕获的信号而终止（且该信号未被指定为正常退出状态）时，将重新启动。
     - `on-watchdog` - 如果设置为 `on-watchdog`，则只有当看门狗超时时，服务才会重新启动。
     - `always` - 总是重启。

   退出原因及其对 `Restart=` 设置的影响：

   ![effect](./images/16-effect.png)

   - `KillMode=process`。 指定如何终止本 unit 的进程。 其值可以是以下之一：
     - `control-group` - 默认值。 若设置为 `control-group`，则在 unit 停止时，该 unit 控制组中所有剩余进程将被终止。
     - `process` - 仅终止主进程。
     - `mixed` - SIGTERM 信号发送给主进程，而随后的 SIGKILL 信号则发送给该 unit 控制组中所有剩余的进程。
     - `none` - 不会终止任何进程。
   - `PrivateTmp=`。 是否使用私有临时目录。 出于一定的安全考虑，建议将该值设置为 yes。
   - `ProtectHome=`。 是否保护主目录。 其值可以是以下之一：
     - `yes` - 这三个目录（/root/、/home/、/run/user/）对 unit 不可见。
     - `no` - 这三个目录对 unit 可见。
     - `read-only` - 这三个目录对 unit 而言是只读的。
     - `tmpfs` - 临时文件系统将以只读模式挂载到这三个目录上。
   - `ProtectSystem=`。 该目录用于保护系统免受服务修改。 该值可以是：
     - `yes` - 表示由该 unit 调用的进程将以只读方式挂载到 /usr/ 和 /boot/ 目录。
     - `no` - 默认值
     - `full` - 表示 /usr/、/boot/、/etc/ 目录以只读方式挂载。
     - `strict` - 所有文件系统均以只读方式挂载（虚拟文件系统目录除外，例如 /dev/、/proc/ 和 /sys/ ）。
   - `EnvironmentFile=-/etc/crypto-policies/back-ends/opensshserver.config`。 从文本文件中读取环境变量。 "-" 表示如果文件不存在，则不会读取该文件，且不会记录任何错误或警告。

   参阅 `man 5 systemd.service` 来获取更多信息。

3. Install 标题

   - `Alias=`。 以空格分隔的附加名称列表。 请注意！ 您的附加名称应与当前 unit 具有相同的类型（后缀）。

   - `RequiredBy=` 或 `WantedBy=multi-user.target`。 将当前操作的 unit 定义为值中 unit 的依赖项。 定义完成后，可在 /etc/systemd/systemd/ 目录中找到相关文件。 例如：

     ```bash
     Shell > systemctl is-enabled chronyd.service
     enabled

     Shell > systemctl cat chronyd.service
     ...
     [Install]
     WantedBy=multi-user.target

     Shell > ls -l /etc/systemd/system/multi-user.target.wants/
     total 0
     lrwxrwxrwx. 1 root root 38 Sep 25 14:03 auditd.service -> /usr/lib/systemd/system/auditd.service
     lrwxrwxrwx. 1 root root 39 Sep 25 14:03 chronyd.service -> /usr/lib/systemd/system/chronyd.service  ←←
     lrwxrwxrwx. 1 root root 37 Sep 25 14:03 crond.service -> /usr/lib/systemd/system/crond.service
     lrwxrwxrwx. 1 root root 42 Sep 25 14:03 irqbalance.service -> /usr/lib/systemd/system/irqbalance.service
     lrwxrwxrwx. 1 root root 37 Sep 25 14:03 kdump.service -> /usr/lib/systemd/system/kdump.service
     lrwxrwxrwx. 1 root root 46 Sep 25 14:03 NetworkManager.service -> /usr/lib/systemd/system/NetworkManager.service
     lrwxrwxrwx. 1 root root 40 Sep 25 14:03 remote-fs.target -> /usr/lib/systemd/system/remote-fs.target
     lrwxrwxrwx. 1 root root 36 Sep 25 14:03 sshd.service -> /usr/lib/systemd/system/sshd.service
     lrwxrwxrwx. 1 root root 36 Sep 25 14:03 sssd.service -> /usr/lib/systemd/system/sssd.service
     lrwxrwxrwx. 1 root root 37 Sep 25 14:03 tuned.service -> /usr/lib/systemd/system/tuned.service
     ```

   - `Also=`。 安装或卸载此 unit 时要安装或卸载的其他 unit。

     除了上述手册页外，您还可以输入 `man 5 systemd.exec` 或 `man 5 systemd.kill` 来获取其他信息。

## 与其他组件相关的命令

- `timedatactl` - 查询或更改系统时间和日期设置。
- `hostnamectl` - 查询或更改系统主机名。
- `localectl` - 查询或更改系统语言环境和键盘设置。
- `systemd-analyze` - 分析 `systemd`，显示 unit 依赖关系，检查 unit 文件。
- `journalctl` - 查看系统或服务日志。 `journalctl` 命令非常重要，稍后将有一个单独的部分解释它的用法和注意事项。
- `loginctl` - 登录用户的会话管理。
