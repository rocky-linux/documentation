---
title: 软件管理
author: Antoine Le Morvan
contributors: Colussi Franco, Steven Spencer, Ganna Zhyrnova, tianci li
tested version: 8.5
tags:
  - 教育
  - 软件
  - 软件管理
---

# 软件管理

## 概论

在 Linux 系统上，可以通过以下两种方式安装软件：

* 从存储库下载软件包并将其安装在本地计算机上
* 编译项目源代码包并将其安装在本地计算机上

!!! note "说明"

    本文档不描述如何在本地计算机上编译并安装源代码包。 通常，您应该从存储库中获取相应的软件包，除非您需要的软件包不在存储库中。 这是因为包管理系统可以帮助用户解决依赖性问题。 对于初学者而言，解决编译源代码包所需的依赖关系可能颇具挑战性。

**软件包**：开发人员提前将一组源文件编译成可执行的机器语言，并将其打包成特定格式的二进制文件。 除非另有说明，否则 Linux 中的 "软件包" 一词指二进制软件包。

**源文件**：人类可读的单个代码文件（扩展名如 .c、.py、.java），它可能只是整个项目的一个代码片段或模块，需要编译或解释器才能在计算机上运行。

**源代码包**：一个压缩的归档文件，用于打包整个项目的源文件和相关文件（如 Makefile 和 configure 等构建文件；README 和 LICENSE 等文档文件）。 文件后缀如 `.tar.gz` 或 `.tar.xz` 通常表示此类文件类型。

## RPM 概述

**RPM**（RedHat Package Manager） 是一个软件管理系统。 它可以安装、卸载、更新或检查软件包中包含的软件。

**RPM** 是所有 Red Hat 发行版（Rocky Linux、Fedora、CentOS、SUSE、Mandriva 等）使用的包管理系统，这些包通过文件后缀 `.rpm` 进行标识。 Debian 及其衍生版使用 DPKG 包管理系统来管理软件包，这些包通过文件后缀 `.deb` 进行标识。

RPM 软件包的命名规范：

![包名称的示意图](images/software-001.png)

!!! tip "术语解释"

    当我们使用大写的 “RPM" 时，它指的是包管理系统。 使用小写的 “rpm" 时，绝大多数情况下特指 `rpm` 命令。 而使用 `.rpm` 时，则指软件包的格式后缀。 读者在阅读文档时不应将它们混淆。

今天的 RPM 包管理系统仍在不断更新和迭代，请参阅 [此处](https://rpm.org/)。

## 本地包管理器

`rpm` 命令：用于管理 Red Hat 上下游发行版中本地 RPM 包的命令行工具。

**完整包名称**：二进制软件包的完整名称，如 `tree-1.7.0-15.el8.x86_64.rpm`。

**包名称**：软件包的名称，如 `tree`。

如果相关软件包对操作系统而言是新的（尚未安装），则在使用 `rpm` 命令时应使用 "完整包名称"。 如果相关软件包对操作系统而言是非全新的（已经安装），则在使用 `rpm` 命令时应使用 "包名称"。 这是因为 `rpm` 会将相关的软件包信息存储在 **/var/lib/rpm/** 数据库目录中。

`rpm` 命令的用法如下：

```bash
rpm [options] <Package-Name> | <Full-Package-Name>
```

### 安装、升级和卸载软件包

相关选项如下：

| 选项                             | 说明          |
| ------------------------------ | ----------- |
| `-i <Full-Package-Name>` | 安装软件包。      |
| `-U <Full-Package-Name>` | 更新已安装的软件包。  |
| `-e <Package-Name>`      | 卸载软件包。      |
| `-h`                           | 显示进度条。      |
| `-v`                           | 告知操作的进度。    |
| `--test`                       | 测试该命令而不执行它。 |

* 安装一个或多个软件包 - `rpm -ivh <Full-Package-Name> ...`
* 升级一个或多个软件包 - `rpm -Uvh <Full-Package-Name> ...`
* 卸载一个或多个软件包 - `rpm -e <Package-Name> ...`

由于 `rpm` 是一个本地包管理器，因此用户需要在软件安装过程中手动解决依赖关系问题。 如果缺少相关依赖项，将出现如 "failed dependencies" 的提示。

理解 RPM 软件包的依赖关系：

* **树型依赖关系（a.rpm ---> b.rpm ---> c.rpm）** - 安装 a.rpm 时，它会提示需先安装 b.rpm。 安装 b.rpm 时，它会提示需先安装 c.rpm。 最简便的解决方法是将这些安装串接起来：`rpm -ivh a.rpm b.rpm c.rpm`
* **环形依赖关系（a.rpm ---> b.rpm ---> c.rpm ---> a.rpm）** - `rpm -ivh a.rpm b.rpm c.rpm`
* **模块依赖关系** - 访问 [此网站](https://www.rpmfind.net/) 进行搜索

**Q：为什么软件包安装总是会出现依赖性问题？**

因为软件或应用程序几乎总是依赖于其他软件或库，所以如果操作系统中不存在所需的程序或共享库，则在安装目标应用程序之前必须满足此先决条件。

### 查询包

相关选项如下：

| 选项       | 说明                                                                                                                     |
| -------- | ---------------------------------------------------------------------------------------------------------------------- |
| `-q`     | 查询软件包是否已安装，如 `rpm -q tree-1.7.0-15.el8.x86_64.rpm`                                                                     |
| `-a`     | 当与 `-q` 选项结合使用时，查询所有已安装的 rpm 包，如 `rpm-qa`                                                                              |
| `-i`     | 与 `-q` 选项结合使用，可查询对应已安装 rpm 软件包的详细信息。 如 `rpm -qi bash`                                                                  |
| `-l`     | 当与 `-q` 选项结合使用时，可查询对应已安装 rpm 包释放出的文件列表                                                                                 |
| `-p`     | 指定未安装的软件包，例如 `rpm -qip tree-1.7.0-15.el8.x86_64.rpm` 和 `rpm -qlp tree-1.7.0-15.el8.x86_64.rpm`                         |
| `-f`     | 当与 `-q` 选项结合使用时，查询安装文件所属的软件包，例如 `rpm -qf /usr/bin/bash`                                                                |
| `-R`     | 当与 `-q` 选项结合使用时，查询已安装 rpm 包的依赖关系。 当与 `-p` 选项结合使用时，您可以查询未安装 rpm 包的依赖关系，例如 `rpm -qRp rpm -qRp mtr-0.92-3.el8.x86_64.rpm` |
| `--last` | 按安装时间对软件包进行排序，时间最近的排在最前面                                                                                               |

RPM 数据库位于 `/var/lib/rpm/` 目录中。

一些示例：

```bash
sudo rpm -qa

sudo rpm -qilp zork-1.0.3-1.el8.x86_64.rpm tree-1.7.0-15.el8.x86_64.rpm

# 列出最后安装的软件包：
sudo rpm -qa --last | head
NetworkManager-config-server-1.26.0-13.el8.noarch Mon 24 May 2021 02:34:00 PM CEST
iwl2030-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl2000-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl135-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl105-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl100-firmware-39.31.5.1-101.el8.1.noarch    Mon 24 May 2021 02:34:00 PM CEST
iwl1000-firmware-39.31.5.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
alsa-sof-firmware-1.5-2.el8.noarch            Mon 24 May 2021 02:34:00 PM CEST
iwl7260-firmware-25.30.13.0-101.el8.1.noarch  Mon 24 May 2021 02:33:59 PM CEST
iwl6050-firmware-41.28.5.1-101.el8.1.noarch   Mon 24 May 2021 02:33:59 PM CEST

# 列出内核的安装历史记录：
sudo rpm -qa --last kernel
kernel-4.18.0-305.el8.x86_64                  Tue 25 May 2021 06:04:56 AM CEST
kernel-4.18.0-240.22.1.el8.x86_64             Mon 24 May 2021 02:33:35 PM CEST
```

!!! tip "使用技巧"

    使用查询功能（`-q` 选项）时，对应的软件包必须具有确定性。 换句话说，您不能在 `rpm` 命令行中使用通配符来匹配包名。 要筛选特定的一个或多个包，您需要使用管道符（`|`）和 `grep` 命令。

    ```bash
    sudo rpm -qa | grep ^dbus
    dbus-common-1.12.8-27.el8_10.noarch
    dbus-glib-0.110-2.el8.x86_64
    dbus-libs-1.12.8-27.el8_10.x86_64
    dbus-daemon-1.12.8-27.el8_10.x86_64
    dbus-tools-1.12.8-27.el8_10.x86_64
    dbus-1.12.8-27.el8_10.x86_64
    ```

### 验证软件包的签名

您必须使用 `-K` 选项来完成此操作。

当您从未知网站或不受信任的位置下载 rpm 二进制包时，您无法确定该包是否已被篡改。 因此，用户需要验证软件包的签名，以确保下载的软件包完整且未被篡改。

在对软件包进行签名验证之前，请先导入所需的公钥。 这通常由系统管理员完成。

从 RHEL 8.x 开始，您可以使用 `dnf download` 命令下载特定的软件包。 例如，若您需要下载 `wget` 包，请使用：

```bash
sudo dnf download wget

ls -l wget-1.19.5-12.el8_10.x86_64.rpm
-rw-r--r-- 1 root root 750748 Jan  3 17:29 wget-1.19.5-12.el8_10.x86_64.rpm

# 使用 "-K" 选项验证相应软件包的签名
## 您还可以使用 “-v” 或 “-vv” 选项来显示更详细的信息
sudo rpm -K wget-1.19.5-12.el8_10.x86_64.rpm
wget-1.19.5-12.el8_10.x86_64.rpm: digests signatures OK

# 如果您下载的软件包已被篡改，将显示以下信息：
echo  "change content" >> /root/wget-1.19.5-12.el8_10.x86_64.rpm
sudo rpm -K wget-1.19.5-12.el8_10.x86_64.rpm
wget-1.19.5-12.el8_10.x86_64.rpm: DIGESTS SIGNATURES NOT OK
```

如果软件包的签名未能通过验证，您不应该继续使用该软件包。

### 在软件包安装后验证文件变更

您需要使用 `-V` 选项来完成此操作。

在安装了 RPM 软件包之后，RPM 数据库会记录相关文件的初始特征和变更特征，以确定它们是否被恶意篡改。

```bash
sudo rpm -q chrony
chrony-4.5-2.el8_10.x86_64

rpm -V chrony
S.5....T.  c /etc/chrony.conf
```

输出被分为 3 个独立的列。

- **第一列（S.5....T.）**

    使用 9 个字段来表示安装 RPM 软件包后的文件有效信息。 任何通过特定检查/测试的字段或特征均以 "." 标记。

    这 9 个不同的字段或检查是：

    - S：文件大小是否有修改。
    - M：文件类型或文件权限（rwx）是否有修改。
    - 5：文件 MD5 校验和是否被修改。
    - D：设备的序列号是否有修改。
    - L：文件路径是否被修改。
    - U：文件所有者是否被修改。
    - G：文件所属组是否有修改。
    - T：文件是否修改了mTime（修改时间）。
    - P：程序功能是否有修改。

- **第二列（c）**

    **c**：表示对配置文件进行了修改。 它也可以是以下值：

    - d：文档文件
    - g：鬼文件。 极少能看到
    - l：许可证文件
    - r：自述文件

- **第三列（/etc/chrony.conf）**

    - **/etc/chrony.conf**：表示修改文件的路径。

## DNF 包管理器

**DNF**（**Dandified Yum**） 是一个软件包管理器，是 **YUM**（**Y**ellow dog **U**pdater **M**odified）的继任者。

`dnf` 命令：此命令允许您通过与存储库交互来管理二进制软件包。 对于最常见的功能项命令，其使用方式与 `yum` 命令相同。 对于一些较新的发行版（例如 Rocky Linux 10.x 或 Fedora 43），`dnf` 命令行工具已更新。 例如在 Rocky Linux 10.x 中，用户可从存储库中选择性地安装 `dnf5` 。

基于红帽的发行版（如 Rocky Linux、Fedora 和 CentOS ）使用 `dnf` 命令行工具。 而在 Debian 的世界中，其对应的是 `apt`（**A**dvanced **P**ackaging **T**ool）命令行工具。

### `dnf` 的功能项命令

`dnf` 命令的语法如下：

```
dnf [options] <command> [<args>...]
```

语法中的 "命令" 代表 `dnf` 的功能项命令。 有些命令是内置的，而其他命令则需要第三方插件的支持。 您可以通过使用 `--help` 选项来查看每个功能命令的用法，例如 `dnf list --help`。

1. **`list` 命令**

    根据此命令之后的不同选项列出软件包。 默认情况下，列出操作系统中可供安装的所有软件包（`dnf list` 等同于 `dnf list --all`）。

    * `dnf list --installed` - 列出当前操作系统已安装的软件包
    * `dnf list --updates` - 列出您可以升级的软件包

    list 命令的具体选项如下：

    | 特定选项           | 说明           |
    | -------------- | ------------ |
    | `--all`        | 显示所有软件包（默认）  |
    | `--available`  | 仅显示可用软件包     |
    | `--installed`  | 仅显示已安装的软件包   |
    | `--extras`     | 仅显示附加软件包     |
    | `--updates`    | 仅显示升级的软件包    |
    | `--upgrades`   | 仅显示升级的软件包    |
    | `--autoremove` | 仅显示可自动移除的软件包 |
    | `--recent`     | 仅显示最近更改的软件包  |

1. **`search` 命令**

    使用给定的字符串在存储库中搜索软件包。 例如 `dnf search vim`。

1. **`install` 命令**

    从存储库中安装一个或多个软件包。 例如 `dnf -y install wget tree`。 其中 `-y` 选项表示自动应答为 "yes"。 通过这种方式安装软件包时，`dnf` 会自动处理依赖关系解析。

    除了从存储库中安装软件包外，您还可以通过指定 URL 或本地 RPM 软件包进行安装，例如 `dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`、`dnf install /tmp/mtr-0.92-3.el8.x86_64.rpm`

1. **`info` 命令**

    查看一个或多个软件包的信息，例如 `dnf info wget tree`

1. **`deplist` command** （已弃用）

    列出软件包的依赖项。 请使用 `dnf repoquery --deplist <Package-Name>` 作为替代方案。

1. **`repolist` 命令**

    显示与存储库相关的信息，默认显示已启用的存储库（`dnf repolist` 等同于 `dnf repolist --enabled`）

    * `dnf repolist --all` - 列出所有存储库
    * `dnf repolist -v` - 显示已启用存储库的详细信息
    * `dnf repolist --disabled` - 仅列出禁用的存储库。

1. **`history` 命令**

    显示输入的 `dnf` 命令的历史记录。 默认情况下， `dnf history` 等同于 `dnf history list`，您可以用 `info`、`redo`、`replay`、`rollback`、`store`、`undo` 或 `userinstalled` 中的任意一个替换这里的 "list"。

1. **`provides` 命令**

    查看给定文件所属的软件包。 例如 `dnf provides /usr/bin/systemctl`。

1. **`remove` 命令**

    从当前操作系统中移除一个或多个软件包。 默认情况下，它会询问是否要卸载该软件包及其相关的依赖包，且可通过 `-y` 选项自动响应为 "yes"。

1. **`autoremove` 命令**

    自动删除那些曾经作为依赖项使用但现在已不再使用的软件包。 例如 `dnf -y autoremove`。

1. **`makecache` 命令**

    为新增的存储库或过时的元数据生成缓存。

1. **`update` 或 `upgrade` 命令**

    在操作系统中升级一个或多个软件包。 例如，`dnf update -y` 会更新操作系统中所有可升级的软件包。

1. **`grouplist`、`groupinstall`、`groupremove` 或 `groupinfo` 命令**

    这些命令的对象是软件包组，即为特定场景或环境准备的软件包集合。

    在 Rocky Linux 8.x 中有这些软件包组：

    ```bash
    sudo dnf grouplist
    Available Environment Groups:
       Server with GUI
       Server
       Workstation
       KDE Plasma Workspaces
       Virtualization Host
       Custom Operating System
    Installed Environment Groups:
       Minimal Install
    Available Groups:
       Container Management
       .NET Core Development
       RPM Development Tools
       Development Tools
       Graphical Administration Tools
       Headless Management
       Legacy UNIX Compatibility
       Network Servers
       Scientific Support
       Security Tools
       Smart Card Support
       System Tools
       Fedora Packager
       Xfce
    ```

    为避免歧义，在操作单个或多个软件包组时，应将单个软件包组的名称用双引号包含。

1. **`clean` 命令**

    清理缓存数据。 你可以用该命令清理所有数据缓存：`dnf clean all`。

    | 可清理的元数据类型      | 说明                 |
    | -------------- | ------------------ |
    | `all`          | 移除已启用存储库创建的所有临时文件。 |
    | `dbcache`      | 移除从存储库元数据生成的缓存文件。  |
    | `expire-cache` | 将存储库元数据标记为已过期。     |
    | `metadata`     | 移除存储库元数据。          |
    | `packages`     | 从系统中删除所有缓存的软件包。    |

1. **`download` 命令**

    从存储库下载一个或多个软件包到本地计算机，但不进行安装。

    您可以使用选项 `--destdir DESTDIR` 或 `--downloaddir DESRDIR` 指定保存路径，例如 `dnf download tree --downloaddir /tmp/`。

1. **`repoquery` 命令**

    使用命令后的不同选项来查询相关信息，类似于 `rpm -q`。

    * `dnf repoquery --deplist <Package-Name>` - 浏览依赖关系
    * `dnf repoquery --list <Package-Name>` - 在安装软件包后浏览文件列表（无论该软件是否已安装在操作系统中）

1. **`config-manager` 命令**

    通过命令行管理存储库，包括添加、删除、启用和禁用存储库。

    * `dnf config-manager --add-repo <URL>` - 添加一个全新的存储库
    * `dnf config-manager --set-disabled devel` - 永久禁用单个存储库
    * `dnf config-manager --set-enabled devel` - 永久启用单个存储库

您可以通过 `dnf --help` 命令的输出查看可用的插件命令：

```bash
sudo dnf --help
...
List of Plugin Commands:

builddep                  Install build dependencies for package or spec file
changelog                 Show changelog data of packages
config-manager            manage dnf configuration options and repositories
copr                      Interact with Copr repositories.
debug-dump                dump information about installed rpm packages to file
debug-restore             restore packages recorded in debug-dump file
debuginfo-install         install debuginfo packages
download                  Download package to current directory
groups-manager            create and edit groups metadata file
needs-restarting          determine updated binaries that need restarting
offline-distrosync        Prepare offline distrosync of the system
offline-upgrade           Prepare offline upgrade of the system
playground                Interact with Playground repository.
repoclosure               Display a list of unresolved dependencies for repositories
repodiff                  List differences between two sets of repositories
repograph                 Output a full package dependency graph in dot format
repomanage                Manage a directory of rpm packages
reposync                  download all packages from remote repo
system-upgrade            Prepare system for upgrade to a new release
...
```

!!! tip "提示" 

    如果缺少这些插件命令，请安装 `dnf-plugins-core` 包。 在此处查阅更多信息：https://dnf-plugins-core.readthedocs.io/en/latest/index.html

### 配置文件说明

您可以在 **/etc/yum.repos.d/** 目录中找到所有存储库配置文件（以 `.repo` 结尾）。 每个 `.repo` 文件可以包含一个或多个存储库，用户可以根据自身具体情况选择性地启用或禁用它们。

```bash
ls -l /etc/yum.repos.d/
total 72
-rw-r--r--  1 root root 1919 Sep 13  2024 docker-ce.repo
-rw-r--r--  1 root root 1680 Aug 31  2024 epel-modular.repo
-rw-r--r--  1 root root 1332 Aug 31  2024 epel.repo
-rw-r--r--  1 root root 1779 Aug 31  2024 epel-testing-modular.repo
-rw-r--r--  1 root root 1431 Aug 31  2024 epel-testing.repo
-rw-r--r--. 1 root root  710 Jun  7  2024 Rocky-AppStream.repo
-rw-r--r--. 1 root root  695 Jun  7  2024 Rocky-BaseOS.repo
-rw-r--r--  1 root root 1773 Jun  7  2024 Rocky-Debuginfo.repo
-rw-r--r--. 1 root root  360 Jul 11  2024 Rocky-Devel.repo
-rw-r--r--. 1 root root  695 Jun  7  2024 Rocky-Extras.repo
-rw-r--r--. 1 root root  731 Jun  7  2024 Rocky-HighAvailability.repo
-rw-r--r--. 1 root root  680 Jun  7  2024 Rocky-Media.repo
-rw-r--r--. 1 root root  680 Jun  7  2024 Rocky-NFV.repo
-rw-r--r--. 1 root root  690 Jun  7  2024 Rocky-Plus.repo
-rw-r--r--. 1 root root  715 Mar 29 17:39 Rocky-PowerTools.repo
-rw-r--r--. 1 root root  746 Jun  7  2024 Rocky-ResilientStorage.repo
-rw-r--r--. 1 root root  681 Jun  7  2024 Rocky-RT.repo
-rw-r--r--  1 root root 2335 Jun  7  2024 Rocky-Sources.repo
```

每个 `.repo` 文件中单个存储库的内容格式是固定的，例如：

```
[baseos]
name=Rocky Linux $releasever - BaseOS
mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=BaseOS-$releasever
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/BaseOS/$basearch/os/
gpgcheck=1
enabled=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
```

内容说明：

* 使用 "[ ]" 包含存储库 ID，该 ID 必须是唯一的。
* "[ ]" 下方是存储库选项。
* "name" 选项 - 指定存储库的详细名称。
* "mirrorlist" 选项 - 存储库镜像列表的 URL 。 URL 支持多种协议，如 https、http、ftp、file、NFS 等。 值中的 "$" 代表相关的存储库变量。
* "baseurl" 选项 - 存储库的 URL 列表。 URL 支持多种协议，如 https、http、ftp、file、NFS 等。 值中的 "$" 代表相关的存储库变量。
* 以 "#" 开头的行是注释行。
* "gpgcheck" 选项 - 是否对此存储库中找到的包执行 GPG 签名检查。 默认值是 False(0)。
* "enabled" 选项 - 将此存储库作为软件包源包含在内。 默认值是 True(1)。
* "countme" 选项 - 上传匿名使用统计数据。 默认值是 False(0)。
* "gpgkey" 选项 - GPG公钥路径。

有关更多信息，请参阅 `man 5 yum.conf`。

## 应用程序流

**在 RL 8.x 和 RL 9.x 中的应用程序流**：Rocky Linux 8.x 和 9.x 使用了一种新的模块化技术，允许存储库托管多个版本的应用程序及其依赖项。 由于采用了模块化架构，这两个操作系统中的应用程序流也被称为 “模块流” 。 系统管理员可以选择一个特定的版本，这提供了更大的灵活性。 如果系统管理员需要管理应用程序流，他们通常需要使用 `dnf module` 命令。

**在 RL 10.x 中的应用程序流**：从 Rocky Linux 10.x 开始，系统管理员仍然可以使用应用程序流，但应用程序流不再以模块化形式提供。 换言之，在 10.x 中的 `dnf module` 命令已经不起作用，系统管理员可以采用传统方式管理不同版本的应用程序。 在此版本的操作系统中，术语 “应用程序流” 不等于 “模块流”。

每个应用程序流都有不同的生命周期。 请访问以下链接：

* https://access.redhat.com/support/policy/updates/rhel-app-streams-life-cycle#rhel8_application_streams
* https://access.redhat.com/support/policy/updates/rhel-app-streams-life-cycle#rhel9_application_streams
* https://access.redhat.com/support/policy/updates/rhel-app-streams-life-cycle#rhel10_dependent_application_streams

在本文档中，作者主要解释了模块化架构的应用程序流。

### 模块流

重要说明：

* 要在 RL 8.x 和 RL 9.x 中使用模块化架构的应用程序流，请首先启用 **AppStream** 存储库。 在 Appstream 存储库中，**模块** 代表逻辑单元的软件包集合，这些软件包被共同构建、测试并发布。 单个模块可以包含同一应用程序的多个流（版本）。
* 每个模块都是单独进行更新的。
* 启用单个模块后，用户只能使用该模块的一个流（版本）。
* 每个模块都可以有自己的默认流（默认版本），标记为 "[d]"。
* 默认流处于活跃状态，除非您禁用该模块或为该模块启用另一个流。

### 模块配置集

**模块配置集**：为特定使用场景绑定在一起的一组软件包列表。 例如：

```bash
sudo dnf module list nginx
Last metadata expiration check: 10:04:05 ago on Wed 07 Jan 2026 01:42:24 PM CST.
Rocky Linux 8 - AppStream
Name                      Stream                       Profiles                       Summary
nginx                     1.14 [d]                     common [d]                     nginx webserver
nginx                     1.16                         common [d]                     nginx webserver
nginx                     1.18                         common [d]                     nginx webserver
nginx                     1.20                         common [d]                     nginx webserver
nginx                     1.22                         common [d]                     nginx webserver
nginx                     1.24                         common [d]                     nginx webserver

sudo sudo dnf module install nginx:1.14
Last metadata expiration check: 10:04:31 ago on Wed 07 Jan 2026 01:42:24 PM CST.
Dependencies resolved.
========================================================================================================================
 Package                            Architecture  Version                                        Repository        Size
========================================================================================================================
Installing group/module packages:
 nginx                              x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream        566 k
 nginx-all-modules                  noarch        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         22 k
 nginx-filesystem                   noarch        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         23 k
 nginx-mod-http-image-filter        x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         34 k
 nginx-mod-http-perl                x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         45 k
 nginx-mod-http-xslt-filter         x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         32 k
 nginx-mod-mail                     x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         63 k
 nginx-mod-stream                   x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         84 k
Installing dependencies:
 dejavu-fonts-common                noarch        2.35-7.el8                                     baseos            73 k
 dejavu-sans-fonts                  noarch        2.35-7.el8                                     baseos           1.5 M
 fontconfig                         x86_64        2.13.1-4.el8                                   baseos           273 k
 fontpackages-filesystem            noarch        1.44-22.el8                                    baseos            15 k
 gd                                 x86_64        2.2.5-7.el8                                    appstream        143 k
 jbigkit-libs                       x86_64        2.1-14.el8                                     appstream         54 k
 libX11                             x86_64        1.6.8-9.el8_10                                 appstream        611 k
 libX11-common                      noarch        1.6.8-9.el8_10                                 appstream        157 k
 libXau                             x86_64        1.0.9-3.el8                                    appstream         36 k
 libXpm                             x86_64        3.5.12-11.el8                                  appstream         58 k
 libjpeg-turbo                      x86_64        1.5.3-14.el8_10                                appstream        156 k
 libtiff                            x86_64        4.0.9-36.el8_10                                appstream        190 k
 libwebp                            x86_64        1.0.0-11.el8_10                                appstream        273 k
 libxcb                             x86_64        1.13.1-1.el8                                   appstream        228 k
Installing module profiles:
 nginx/common
Enabling module streams:
 nginx                                            1.14

Transaction Summary
========================================================================================================================
Install  22 Packages

Total download size: 4.5 M
Installed size: 14 M
Is this ok [y/N]:
```

每个模块流都可以有任意数量的配置集（或者完全没有）。 模块流的默认配置集被标记为 “[d]"。

在上面的例子中，当用户需要安装 nginx 时，以下命令是等效的：

```bash
sudo dnf install nginx

sudo dnf install nginx:1.14

sudo dnf install nginx:1.14/common
```

### 管理模块流

使用的命令是 `dnf module` ，它有一些功能项的子命令。

!!! tip "使用技巧"

    当单行 `dnf module` 命令操作涉及模块时，允许输入多个模块名称，例如 `dnf module enable nginx httpd:2.4` 或 `dnf module list nodejs:10 perl`。

#### 查看

您可以在子命令中使用 `list` 或 `info` 来完成此操作。

* `dnf module list` - 获取所有可用模块的列表。
* `dnf module list <Module-Name>` or `dnf module list <Module-Name>:<Stream>` - 列出当前模块的所有可用流（版本）。 列出单个模块流的信息。 例如 `dnf module list postgresql` 或 `dnf module list postgresql:15`。
* `dnf module list --enabled` - 列出启用的模块流。
* `dnf module info <Module-Name>` 或 `dnf module info <Module-name>:<Stream>` - 显示模块流信息。 如果只键入没有流的模块名称，则将显示该模块的所有流信息。 例如 `dnf module info ruby` 或 `dnf module info ruby:2.6`。
* `dnf module --info --profile <Module-Name>` 或 `dnf module --info --profile <Module-Name>:<Stream>` - 列出模块流的配置集信息。 如果只键入没有流的模块名称，则将显示该模块的所有流配置集信息。

#### 安装

在安装模块的某一特定流之前，您需要先启用该流。 使用的语法如下：

```bash
dnf module enable <Module-Name>:<Stream> ...
```

例如：

```bash
dnf -y module enable httpd:2.4
```

!!! tip "再次强调"

    默认流处于活跃状态，除非您禁用该模块或为该模块启用另一个流。

以下安装方法均可接受：

* `dnf -y module install <Module-Name>` - 使用单个模块的默认流和默认配置集（如果存在默认配置集）。 例如 `dnf -y install httpd`
* `dnf -y install <Module-Name>:<Stream>/<Profile>` - 使用单个模块的特定流和配置集。 例如 `dnf -y install httpd:2.4:/minimal`。 如果有多个配置集，可以使用 `*` 表示所有配置集，例如 `dnf module install httpd:2.4/*`

#### 移除

您可以使用以下语法进行移除：

* `dnf -y module remove --all <Module-name>:<Stream> ...` - 从单个模块中的单个流中删除所有包。 例如 `dnf -y module remove --all httpd:2.4`
* `dnf -y module remove --all <Module-name>:<Stream>/<Profile> ...` - 删除与特定配置集关联的所有包，使用 `*` 表示所有配置集。 例如 `dnf -y module remove httpd:2.4/*`

#### 重置

您可以使用 `reset` 功能项命令将模块重置为初始状态。 相应的语法如下：

* `dnf -y module reset <Module-Name> ...` - 例如 `dnf -y module reset httpd`

!!! tip "重要提示"

    重置模块不会更改任何已安装的软件包。

#### 切换

您可以切换到更新的流。 完成此操作有两个先决条件：

1. 操作系统已完全更新
2. 操作系统中安装的软件包不比存储库中可用的软件包新

您可以使用 `dnf distro-sync` 命令切换到新流。

如果模块的流中有可用更新，您需要执行以下步骤：

1. `dnf module reset <Module-Name> ...`
2. `dnf module enable <Module-Name>:<New-Stream> ...`
3. `dnf distro-sync`

如果这些软件包已在操作系统中安装，您可以使用 `switch-to` 命令选项来升级或降级它们。 具体语法为：

```bash
dnf module switch-to <Module-Name>:<Stream>
```

#### 禁用

使用的语法是：

```bash
dnf module disable <Module-Name> ...
```

#### 使用 YAML 文件进行自定义

系统管理员可以通过在 **/etc/dnf/modules.defaults.d/** 目录中创建一个 YAML 文件来自定义默认流和默认配置集。

以 PostgreSQL 模块为例，从输出信息中可以看出，其默认流是 10，默认配置集是 "server"：

```bash
sudo dnf module list postgresql
Name                   Stream             Profiles                       Summary
postgresql             9.6                client, server [d]             PostgreSQL server and client module
postgresql             10 [d]             client, server [d]             PostgreSQL server and client module
postgresql             12                 client, server [d]             PostgreSQL server and client module
postgresql             13                 client, server [d]             PostgreSQL server and client module
postgresql             15                 client, server [d]             PostgreSQL server and client module
postgresql             16                 client, server [d]             PostgreSQL server and client module

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

将 15 设置为默认流，并将 postgresql:12 的默认配置集设置为 "client"：

```bash
sudo vim /etc/dnf/modules.defaults.d/postgresql.yaml
---
document: modulemd-defaults
version: 1
data:
        module: postgresql
        stream: "15"
        profiles:
                "9.6": [server]
                "10": [server]
                "12": [client]
                "13": [server]
                "15": [server]
...

sudo dnf module list postgresql
Last metadata expiration check: 0:41:35 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name                   Stream             Profiles                       Summary
postgresql             9.6                client, server [d]             PostgreSQL server and client module
postgresql             10                 client, server [d]             PostgreSQL server and client module
postgresql             12                 client [d], server             PostgreSQL server and client module
postgresql             13                 client, server [d]             PostgreSQL server and client module
postgresql             15 [d]             client, server [d]             PostgreSQL server and client module
postgresql             16                 client, server                 PostgreSQL server and client module

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

#### 完整示例

以 nodejs 模块为例：

```bash
sudo dnf module list nodejs
Last metadata expiration check: 0:44:38 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name                Stream              Profiles                                          Summary
nodejs              10 [d]              common [d], development, minimal, s2i             Javascript runtime
nodejs              12                  common [d], development, minimal, s2i             Javascript runtime
nodejs              14                  common [d], development, minimal, s2i             Javascript runtime
nodejs              16                  common [d], development, minimal, s2i             Javascript runtime
nodejs              18                  common [d], development, minimal, s2i             Javascript runtime
nodejs              20                  common [d], development, minimal, s2i             Javascript runtime
nodejs              22                  common, development, minimal, s2i                 Javascript runtime
nodejs              24                  common, development, minimal, s2i                 Javascript runtime

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled

sudo dnf -y module enable nodejs:18

sudo dnf module list --enabled nodejs
Last metadata expiration check: 0:46:01 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name                Stream              Profiles                                          Summary
nodejs              18 [e]              common [d], development, minimal, s2i             Javascript runtime

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled

sudo dnf -y module install nodejs:18/minimal

sudo dnf module list --enabled nodejs
Last metadata expiration check: 0:47:26 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name               Stream             Profiles                                             Summary
nodejs             18 [e]             common [d], development, minimal [i], s2i            Javascript runtime

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled

sudo dnf -y module install nodejs:18/common

sudo dnf module list --enabled nodejs
Last metadata expiration check: 0:48:34 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name              Stream            Profiles                                                Summary
nodejs            18 [e]            common [d] [i], development, minimal [i], s2i           Javascript runtime

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled

sudo dnf -y module remove --all nodejs:18/*

sudo dnf -y module reset nodejs

sudo dnf module list nodejs
Last metadata expiration check: 0:50:03 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name                Stream              Profiles                                          Summary
nodejs              10 [d]              common [d], development, minimal, s2i             Javascript runtime
nodejs              12                  common [d], development, minimal, s2i             Javascript runtime
nodejs              14                  common [d], development, minimal, s2i             Javascript runtime
nodejs              16                  common [d], development, minimal, s2i             Javascript runtime
nodejs              18                  common [d], development, minimal, s2i             Javascript runtime
nodejs              20                  common [d], development, minimal, s2i             Javascript runtime
nodejs              22                  common, development, minimal, s2i                 Javascript runtime
nodejs              24                  common, development, minimal, s2i                 Javascript runtime

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

## 使用 EPEL 存储库

**Q：什么是 EPEL，它是如何使用的？**

**EPEL**（**E**xtra **P**ackages for **E**nterprise **L**inux）是由 [EPEL Fedora Special Interest Group](https://docs.fedoraproject.org/en-US/epel/) 维护的开源和免费的社区存储库。 该资源从 Fedora 源中为 RHEL（以及 CentOS、Rocky Linux 等）提供了一系列附加软件包。

无论是个人还是企业使用 Rocky Linux 8.x/9.x/10.x，通常都建议启用 EPEL 存储库。

您可以通过以下方式安装 EPEL 存储库：

```bash
sudo dnf install epel-release
```

检查相关信息并验证安装成功：

```bash
sudo dnf info epel-release
Last metadata expiration check: 1 day, 23:02:38 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Installed Packages
Name         : epel-release
Version      : 8
Release      : 22.el8
Architecture : noarch
Size         : 34 k
Source       : epel-release-8-22.el8.src.rpm
Repository   : @System
From repo    : epel
Summary      : Extra Packages for Enterprise Linux repository configuration
URL          : http://download.fedoraproject.org/pub/epel
License      : GPLv2
Description  : This package contains the Extra Packages for Enterprise Linux (EPEL) repository
             : GPG key as well as configuration for yum.

rpm -qa | grep epel
epel-release-8-14.el8.noarch

sudo dnf repolist
repo id            repo name
...
epel                                      Extra Packages for Enterprise Linux 8 - x86_64
...
```

在这里，您可以看到该软件包不包含可执行文件、库等，而只包含用于设置存储库的配置文件和 GPG 密钥。

关联的 `.repo` 文件：

```bash
ls -lh /etc/yum.repos.d/epel*
-rw-r--r-- 1 root root 1.7K Apr 23  2025 /etc/yum.repos.d/epel-modular.repo
-rw-r--r-- 1 root root 1.4K Apr 23  2025 /etc/yum.repos.d/epel.repo
-rw-r--r-- 1 root root 1.8K Apr 23  2025 /etc/yum.repos.d/epel-testing-modular.repo
-rw-r--r-- 1 root root 1.4K Apr 23  2025 /etc/yum.repos.d/epel-testing.repo
```

默认情况下，仅启用 `epel.repo` 文件中 ID 为 epel 的存储库。

```bash
cat /etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 8 - $basearch
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/8/Everything/$basearch
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-8&arch=$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
...
```

列出存储库 ID 为 epel 的所有可用软件包：

```bash
dnf --repoid epel list --available 
```

如果您的操作系统中还有其他存储库，但您只想从 EPEL 安装软件包：

```bash
sudo dnf --disablerepo="*" --enablerepo="epel" install nmon
Last metadata expiration check: 0:08:13 ago on Mon 12 Jan 2026 09:34:25 PM CST.
Dependencies resolved.
========================================================================================================================
 Package                   Architecture                Version                          Repository                 Size
========================================================================================================================
Installing:
 nmon                      x86_64                      16p-5.el8                        epel                       80 k

Transaction Summary
========================================================================================================================
Install  1 Package

Total download size: 80 k
Installed size: 161 k
Is this ok [y/N]:
```

!!! tip "温馨提示"

    启用多个存储库时，同一软件包可能有多个版本，默认情况下，较新版本具有最高优先级。 这也是为什么使用 `--disablerepo` 和 `--enablerepo` 选项的原因。

!!! attention "支持考虑"

    EPEL 是由 Fedora 社区的志愿者发起的一个项目，因此它没有得到红帽的商业支持。 就像 Fedora 本身一样，红帽为这个项目托管基础设施，红帽工程师作为维护者和领导者参与其中，但红帽没有为 EPEL 中的软件包提供商业支持合同或服务级别协议。

关于 EPEL 的常见问题解答，请参考 [Fedora 文档中的 EPEL 常见问题解答](https://docs.fedoraproject.org/en-US/epel/epel-faq/)。
