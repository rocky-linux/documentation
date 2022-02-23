---
title: 镜像解决方案 - lsyncd
author: 史蒂文 斯本
contributors: 布鲁尼 李天赐
updated: 2021-10-28
---

# 镜像解决方案 - `lsyncd`

## 先决条件

这是你需要理解和跟随本指南的一切：

* 运行Rocky Linux的机器。
* 可以从容淡定的在命令行修改配置文件
* 了解如何使用命令行编辑器 (我们在这里使用 vi ，但您可以使用您最喜欢的编辑器)
* 您将需要root权限，最好以根用户身份登录到您的终端
* 公有和私有的 SSH 密钥对
* 来自 Fedora 的 EPEL仓库
* 您需要熟悉 *inotify*，一个事件监视界面
* 可选：熟悉 * tail*

## 介绍

如果您正在寻找在计算机之间自动同步文件和文件夹的方法， `lsyncd` 是一个非常好的选项。 对初学者唯一的不便？ 您必须通过命令行和文本文件配置一切。

即便这样，它是值得所有系统管理员学习的程序

`lsyncd`的最佳描述来自于它自己的手册页面。 稍微缓解， `lsyncd` 是一个轻量级的实时镜像解决方案，比较容易安装。 它不需要新的文件系统或区块设备，也不会妨碍本地文件系统的性能。 简而言之，它是文件的镜像。

`lsyncd` 监视一个本地目录树事件(inotify)。 它聚合和合并几秒钟的事件，然后生成一个(或更多)进程来同步更改。 默认情况下是 `rsync`。

为了本指南的目的，我们将把原始文件的系统调为“主”， 和我们正在同步的东西将是“目标”。 通过非常仔细地指定您想要同步的目录和文件，实际上可以完全镜像服务器使用 `lsyncd`。 非常棒！

为了远程同步，您还想要设置 [Rocky Linux SSH 公钥对](../security/ssh_public_private_keys.md)。 此处的示例使用SSH(端口22)。

## 安装 `lsyncd`

实际上有两种方法安装 `lsyncd`。 我们将两者都引入介绍 RPM倾向于略微落后于源包，但只是略微落后。 在编写本报告时，RPM方法安装的版本是2.2.2-9，而源代码版本现在是2.2.3。 话虽如此，我们想给你两个选项，来让你选择。

## 安装 `lsyncd` - RPM 方法

安装RPM版本相对容易。 您需要首先安装的唯一东西是Fedora的EPEL软件库。 这可以通过一个简单的命令来完成：

`dnf install -y epel-release`

然后，我们只需要安装 `lsyncd` 并且任何缺失的依赖将与它一起安装：

`dnf install lsyncd`

设置启动时的服务，但还不要启动：

`systemctl enable lsyncd`

这样就完成了！

## 安装 `lsyncd` - 源方法

源代码安装并不会像听起来那样糟糕。 只需跟随本指南，您将在任何时候上线并运行！

### 安装依赖

我们将需要一些依赖：一些是 `lsyncd` 本身所需要的；一些是源代码构建所需要的。 在你的 Rocky Linux 机器上使用此命令，确保你有需要的依赖关系。 如果您要从源代码中构建，最好是安装所有开发工具：

`dnf groupinstall 'Development Tools'`

这里是`lsyncd` 依赖和构建过程:

`dnf install lua lua-libs lua-devel cmake unzip wget rsync`

### 下载 `lsyncd` 代码以及构建

接下来我们需要源代码：

`wget https://github.com/axkibe/lsyncd/archive/master.zip`

解压 master.zip 文件:

`unzip master.zip`

这将会创建一个名为 "lsyncd-master"的目录。 我们需要更改为此目录并创建一个名为build的目录：

`cd lsyncd-master`

然后：

`mkdir build`

现在再次更改目录，以便您处于build目录：

`cd build`

现在执行这些命令：

```
cmake ..
make
make install
```

完成后，您应该安装 `lsyncd` 二进制文件，并通过 */usr/local/bin* 使用

## `lsyncd` 系统服务

通过RPM安装方法，系统服务将为您安装。 但如果您选择从源安装，您将需要创建系统服务。 虽然你可以在没有系统服务的情况下启动二进制文件，但我们想确保它 *在启动时开始*。 如果没有，服务器重启将停止您的同步服务，如果您忘记重新启动它， 这很可能对任何系统管理员来说都是非常难堪的！

创建系统服务并不是非常困难的，从长远来看将节省很多时间。

## 创建 `lsyncd` 服务文件

此文件可以在任何地方创建，即使是在您服务器的根目录中。 一旦创建，我们可以轻松地移动它。

`vi /root/lsyncd.service`

此文件的内容应该是：

```
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
现在让我们把你刚才制作的文件安装到正确的位置：

`install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service`

最后，重新加载 `systemctl` 守护程序，以便系统能够“看到”新的服务文件：

`systemctl daemon-reload`

## `lsyncd` 配置

无论您选择了什么方法安装 `lsyncd`，您都需要一个配置文件： */etc/lsyncd.conf*。 下一节将告诉您如何构建一个简单的配置文件并测试它。

## 测试的示例配置

这里是一个简单的配置文件的示例，它将 */home* 与另一台机器同步。 我们的目标机器将是本地IP地址： *192.168.1.40*

```
  settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20,
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

对于这个文件的解析如下：

* 当服务启动时，将自动创建“logfile”和“statusFile”。
* "statusInterval"是写入状态文件之前要等待的秒数。
* “maxProcesses”是允许生成的进程数量 `lsyncd`。 老实说，除非你在一个超繁忙的机器上运行这个程序，否则一个进程就足够了。
* 在同步部分中，"default.rsyncsh"表示通过 ssh使用 rsync。
* "source=" 是我们同步的源目录路径。
* "host="是我们同步的目标机。
* "exclustideFrom="告诉 `lsyncd` 哪些文件排除在外。 它必须存在，但可以为空。
* "targetdir="是我们发送文件到的目标目录。 在大多数情况下，这与来源相同，但并非总是如此。
* 然后我们有"rsync ="部分，这些是我们正在与之同步的选项。
* 最后，我们有"ssh ="部分，这个部分指定了正在监听目标机器的 SSH 端口。

如果您添加多个目录进行同步， 然后您需要重复整个“sync”部分，包括每个目录的所有打开和关闭括号。

## lsyncd.exclude文件

正如早些时候指出的那样，"excludeFrom"文件必须存在，所以让我们现在创建：

`touch /etc/lsyncd.exclude`

如果我们正在同步我们机器上的 /etc 文件夹，我们将会忽略一些文件和/或目录。 每个排除的文件或目录只是列在文件中，每行一个，就像这样：

```
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## 测试并开动

既然其他一切都已建立，我们就能够对所有这些进行测试。 作为开始，请确保我们的 systemd lsyncd.service 启动：

`systemctl start lsyncd`

如果执行此命令后没有出现错误，请检查服务状态，只需：

`systemctl status lsyncd`

如果它显示正在运行的服务，请使用tail查看两个日志文件的结尾，并确保所有内容都能显示出来：

`tail /var/log/lsyncd.log`

然后：

`tail /var/log/lsyncd-status.log`

假设这一切都是正确的，导航到 `/home/[user]` 目录， 在这里 `[user]` 是机器上的用户，并用 *touch* 来创建新的文件。

`touch /home/[user]/testfile`

现在转到目标机器，查看文件是否显示。 如果是的话，一切都在发挥应有的作用。 设置 lsyncd.service 在启动时启动：

`systemctl enable lsyncd`

这样您就可以高枕无忧了。

## 记住要小心!

随时您正在将一组文件或目录同步到另一台机器，仔细考虑它对目标机器的影响。 如果你回到 **这个同步。 xexclude文件** 在我们的示例中，您能想象如果 */etc/fstab* 同步会发生什么情况吗？

对于新手， *fstab* 是用于在任意Linux机器上配置存储驱动器的文件。 磁盘和标签几乎肯定有所不同。 下次重启目标机器后，很可能无法完全开机。

# 结论和参考

`lsyncd` 是机器之间目录同步的一个强大工具。 正如你所看到的那样，安装不是很难，很容易使用。 不能要求比这更多了。

您可以通过去 [官方网站](https://github.com/axkibe/lsyncd) 找到更多关于 `lsyncd`
