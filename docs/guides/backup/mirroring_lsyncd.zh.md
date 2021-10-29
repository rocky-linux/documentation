---
title: 镜像解决方案 - lsyncd
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li
updated: 2021-10-29
---

#  镜像解决方案 - `lsyncd`

## 必备条件

以下是您需要了解并准备本指南的所有内容：

* 运行 Rocky Linux 的计算机。
* 熟练从命令行修改配置文件。
* 了解如何使用命令行编辑器（本文使用 vi，但您也可以使用其他编辑器）。
* 您需要 root 用户访问权限，并且最好以 root 用户身份登录终端。
* SSH 公钥私钥对。
* Fedora 的 EPEL 软件仓库（也叫存储库）
* 熟悉事件监视程序接口 *inotify*
* 可选：熟悉 *tail*

## 简介

如果您正在寻找一种在计算机之间自动同步文件和文件夹的方法，`lsyncd` 是一个相当不错的选择。对初学者来说唯一的缺点是什么？那就是您必须通过命令行和文本文件配置所有内容。

即便如此，它还是值得任何系统管理员认真学习。

*lsyncd* 的最佳描述来自其 man 手册页。稍微解释一下，lsyncd 是一个相对易于安装的轻量级实时镜像解决方案，它不需要新的文件系统或块设备，也不会影响本地文件系统的性能。简而言之，它的作用就是对文件进行镜像。

lsyncd 监视本地目录树事件监视器接口（inotify）。它在几秒钟内聚合和组合事件，然后产生一个(或多个)进程来同步更改，默认进程为`rsync`。

在本文中，带有原始文件的系统称为“master（主）”，而与之同步的系统将称为“target（目标）”。实际上，使用`lsyncd`可以完全镜像一个服务器，只要非常仔细地指定要同步的目录和文件，这是非常棒的!

对于远程同步，您还需要设置 [Rocky Linux SSH 公钥私钥对](../security/ssh_public_private_keys.md)。此处的示例使用 SSH（默认端口 22）。

对于这个工具程序，您可以在[官方项目地址](https://github.com/axkibe/lsyncd)找到最新的版本信息。

## 安装 lsyncd

实际上有两种方式可以安装 lsyncd，此处两种方式都介绍，我们想给您两个选择，让您选择。RPM安装方式的版本通常都会比源代码版本落后，但是它易于安装。在撰写本文时，RPM方式安装的包版本号是2.2.2-9，而源代码版本号现在是2.2.3。

## 安装 lsyncd —— RPM 方式

安装RPM版本是比较容易的，您需要首先安装的是来自Fedora的EPEL软件库。这可以用一个命令来完成。

`dnf install -y epel-release`

然后，只需安装 lsyncd，任何缺少的依赖项都将与它一起安装：

`dnf install lsyncd`

将服务设置为开机自启动，但现在不启动：

`systemctl enable lsyncd`

RPM安装方式就是这么简单！

## 安装 lsyncd —— 源代码方式

从源码安装并不复杂，只需按照本指南操作，您很快就可以启动并运行！

### 安装依赖项

我们需要安装下面的一些依赖项：一些是`lsyncd`本身需要的，还有一些是从源代码构建软件包所需要的。在 Rocky Linux 机器上使用此命令，以确保您具有所需的依赖项。如果要从源码进行构建，则最好安装所有的开发工具：

`dnf groupinstall 'Development Tools'`

以下是 lsyncd 本身及其构建过程所需的依赖项：

`dnf install lua lua-libs lua-devel cmake unzip wget rsync`

### 下载 lsyncd 并构建

接下来，下载源码：

`wget https://github.com/axkibe/lsyncd/archive/master.zip`

现在解压 master.zip 文件：

`unzip master.zip`

这将创建一个名为“lsyncd-master”的目录。切换到该目录并创建一个名为 build 的目录：

`cd lsyncd-master`

然后：

`mkdir build`

现在再次更改目录以进入构建目录：

`cd build`

现在执行以下命令：

```bash
cmake ..
make
make install
```

完成后，您应该已经安装了 lsyncd 二进制文件并可以在 */usr/local/bin* 中使用。

## lsyncd Systemd 服务

使用RPM安装方法时，已经为您安装了systemd服务，但如果您选择从源代码安装，则需要创建systemd服务。虽然您可以在没有systemd服务的情况下启动二进制文件，但我们希望确保它在开机自启动时“确实”启动了。否则，机器重新启动时将停止同步工作，如果您忘记了再次启动lsycnd，这很可能会让任何系统管理员感到非常尴尬！

创建 systemd 服务并不复杂，从长远来看，它将为您节省大量时间。

## 创建 lsyncd 服务文件

该文件可以在任何地方创建，甚至可以在服务器的根目录中创建。创建完成后，您可以轻松地将其移至正确的位置。

`vi /root/lsyncd.service`

该文件的内容应为：

```bash
[Unit]
Description=Live Syncing (Mirror) Daemon
After=network.target

[Service]
Restart=always
Type=simple
Nice=19
ExecStart=/usr/local/bin/lsyncd -nodaemon -pidfile /run/lsyncd.pid /etc/lsyncd.conf
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/lsyncd.pid

[Install]
WantedBy=multi-user.target
```

现在，将刚才创建的文件安装到正确的位置：

`install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service`

最后，重新加载 systemctl 守护进程，以便 systemd “看到”新的服务文件：

`systemctl daemon-reload`

## `lsyncd` 配置

无论您选择何种方式安装 lsyncd，都需要对配置文件进行配置：*/etc/lsyncd.conf*。下一部分将讲解如何构建一个简单的配置文件，并测试它。

## 用于测试的简单配置

下面是一个简单配置文件的示例，它将 */home* 同步到另一台机器。目标机器是一个私有的 IP 地址：*192.168.1.40*

```bash
  settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20
   maxProcesses = 1
   }

sync {
   default.rsyncssh,
   source="/home", 
   host="root@192.168.1.40",
   excludeFrom="/etc/lsyncd.exclude",
   targetdir="/home",
   rsync = {
     archive = true,
     compress = false,
     whole_file = false
   },
   ssh = {
     port = 22
   }
}
```

对该文件进行分解解释：

* 服务启动时将自动创建 "logfile" 和 "statusFile"两个参数里的文件。
* "statusInterval" 是写入 statusFile 之前的等待的秒数。
* "maxProcesses" 是允许 lsyncd 产生的进程数。事实上，除非您在超级繁忙的计算机上运行此进程，否则一个进程就足够了。
* 在 sync 部分，"default.rsyncssh" 表示通过 ssh 使用 rsync。
* "source=" 是要从中同步的目录路径。
* "host=" 是要同步到的目标计算机。
* **"excludeFrom="告诉 lsyncd 排除的文件位置。它必须存在，而且非常重要。** 
* "targetdir=" 要将文件发送到目标计算机的目录位置。在大多数情况下，它等于 source 值，但并非总是如此。
* 然后，"rsync ="部分是运行 rsync 的选项。
* 最后，"ssh ="部分指定了正在监听目标计算机上的 SSH 端口。

**如果要添加多个目录进行同步，则需要为每个目录重复整个"sync"部分，包括所有开始括号和结束括号。**

## lsyncd.exclude 文件

如前所述，"excludeFrom"文件必须存在，所以现在创建它：

`touch /etc/lsyncd.exclude`

如果要在计算机上同步 /etc 文件夹，但是需要忽略一些文件或者目录，那么您只需将需要忽略的文件和目录简单地列在文件中，每行一个，如下所示：

```bash
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## 测试和启动

现在已经完成了其他所有设置，可以对其进行全部测试。首先，请确保 systemd lsyncd.service 可以启动：

`systemctl start lsyncd`

如果执行此命令后没有错误出现，再检查服务状态，以确保一切无误：

`systemctl status lsyncd`

如果显示服务正在运行，请使用 tail 查看两个日志文件的结尾，并确保一切都正常显示：

`tail /var/log/lsyncd.log`

然后：

`tail /var/log/lsyncd-status.log`

假设一切正确，进入到 `/home/[user]` 目录，其中 `[user]` 是Rocky Linux上的普通用户（UID大于等于1000），并使用 *touch* 在其中创建新文件。

`touch /home/[user]/testfile`

现在转到目标计算机，查看文件是否显示。如果显示，那么一切都会按预期进行。将 lsyncd.service 设置为开机自启动使用以下命令：

`systemctl enable lsyncd`


## 注意

每当您将一组文件或目录同步到另一台计算机时，请仔细考虑它对目标计算机的影响。如果您回到上面示例中的 **The lsyncd.exclude File**，您能想象如果将 */etc/fstab* 同步会发生什么情况？

对于新手，*fstab* 是用于在任何 Linux 机器上配置存储驱动器的文件。磁盘和标签几乎可以肯定是不同的。下次重新启动目标计算机时，它很可能无法正常启动。

lsyncd是单向同步的工具。

# 总结

lsycnd 是用于在计算机之间进行目录同步的强大工具。如您所见，安装起来并不难，并且很容易维护。不能要求更多了。