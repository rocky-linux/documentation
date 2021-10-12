# Rocky Linux - 镜像解决方案 - lsycnd

## 准备工作

在继续阅读这篇指南之前，您需要准备或了解以下的内容：

* 运行 Rocky Linux 的计算机。
* 熟练从命令行修改配置文件。
* 了解如何使用命令行编辑器（本文使用 vi，但您也可以使用其他编辑器）。
* 您需要 root 用户访问权限，并且最好以 root 用户身份登录终端。
* SSH 公私密钥对。
* Fedora 的 EPEL 仓库
* 熟悉事件监视程序接口 *inotify*
* 可选：熟悉 *tail*

# 简介

如果您正在寻找一种在计算机之间自动同步文件和文件夹的方法，lsyncd 是一个相当不错的选择。对初学者来说唯一的缺点是什么？您必须通过命令行和文本文件配置所有内容。

即便如此，它还是值得任何系统管理员认真学习。

*lsyncd* 的最佳描述来自其 man 手册页。稍微解释一下，lsyncd 是一种轻量级实时镜像解决方案，相对易于安装。它不需要新的文件系统或块设备，也不会影响本地文件系统的性能。简而言之，它镜像文件。

lsyncd 监视本地目录树事件监视器接口（inotify）。它在几秒钟内聚合并组合事件，然后生成一个（或多个）进程来同步更改。默认情况下，进程是 rsync。

在本文中，带有原始文件的系统称为“master（主）”，而与之同步的系统将称为“target（目标）”。实际上，，使用 lsyncd 通过非常仔细地指定要同步的目录和文件是有可能完全镜像服务器。真是太好了！

对于远程同步，您还需要设置 [Rocky Linux SSH 公私钥对](../security/ssh_public_private_keys.md)。此处的示例使用 SSH（端口 22）。

# 安装 lsycnd

实际上有两种方法可以安装 lsyncd。此处两种方法都介绍，但首选的方法是从源代码安装。这种安装相对容易，而且几乎不需要依赖项。RPM 往往会稍微落后于源码包。换言之，此处给出两种方法，自行选择。

## 安装 lsycnd —— RPM 方法

安装 RPM 版本相对容易。您唯一需要首先安装的是 Fedora 的 EPEL 软件库。只需一条命令即可完成此操作：

`dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`

然后，只需安装 lsyncd，任何缺少的依赖项都将与它一起安装：

`dnf install lsyncd`

就这样！

## 安装 lsycnd —— 源码方法

从源码安装并不复杂，只需遵循本指南，相信您能很快完成一切事情！

### 安装依赖

我们需要安装下面的一些依赖项：lsyncd 本身需要的依赖项，以及从源码构建软件包所需要的依赖项。在 Rocky Linux 机器上使用此命令，以确保您具有所需的依赖项。如果要从源码进行构建，则最好安装所有开发工具：

`dnf groupinstall 'Development Tools'`

以下是 lsyncd 本身及其构建过程所需的依赖项：

`dnf install lua lua-libs lua-devel cmake unzip wget rsync`

### 下载 lsycnd 并构建

接下来，获取源码：

`wget https://github.com/axkibe/lsyncd/archive/master.zip`

现在解压 master.zip 文件：

`unzip master.zip`

这将创建一个名为“lsyncd-master”的目录。切换到该目录并创建一个名为 build 的目录：

`cd lsyncd-master`

And then:

`mkdir build`

现在再次更改目录以进入构建目录：

`cd build`

现在执行以下命令：

```
cmake ..
make
make install
```

完成后，您应该已经安装了 lsyncd 二进制文件并可以在 */usr/local/bin* 中使用。

# lsycnd Systemd 服务

两种安装方法都不会创建用于重启时启动 lsyncd 的 systemd 服务。我们希望能够做到这一点，因为如果您正在镜像文件，肯定不希望因忘记手动启动服务而使镜像处于脱机状态。

这对于任何系统管理员来说都是非常尴尬的！

创建 systemd 服务并不复杂，从长远来看，它将为您节省大量时间。

## 创建 lsyncd 服务文件

该文件可以在任何地方创建，甚至可以在服务器的根目录中创建。创建完成后，您可以轻松地将其移至正确的位置。

`vi /root/lsyncd.service`

该文件的内容应为：

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
现在，将刚才创建的文件安装到正确的位置：

`install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service`

最后，重新加载 systemctl 守护进程，以便 systemd “看到”新的服务文件：

`systemctl daemon-reload`

# 配置

无论您选择何种方法安装 lsyncd，都需要配置文件：*/etc/lsyncd.conf*。下一部分将讲解如何构建一个简单的配置文件，并测试它。

## 测试配置示例

下面是一个简单配置文件的示例，它将 */home* 同步到另一台机器。目标机器是一个本地 IP 地址：*192.168.1.40*

```
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

* 服务启动时将自动创建 "logfile" 和 "statusFile"。
* "statusInterval" 是写入 statusFile 之前要等待的秒数。
* "maxProcesses" 是允许 lsyncd 产生的进程数。事实上，除非您在超级繁忙的计算机上运行此进程，否则一个进程就足够了。
* 在 sync 部分，"default.rsyncssh" 表示通过 ssh 使用 rsync。
* "source=" 是要从中同步的目录路径。
* "host=" 是要同步到的目标计算机。
* "excludeFrom=" 告诉 lsyncd 排除的文件位置。它必须存在，但可以为空。
* "targetdir=" 是要将文件发送到的目标目录。在大多数情况下，它将等于 source 值，但并非总是如此。
* 然后，"rsync ="部分是运行 rsync 的选项。
* 最后，"ssh ="部分指定了正在监听目标计算机上的 SSH 端口。

如果要添加多个目录进行同步，则需要为每个目录重复整个"sync"部分，包括所有开始括号和结束括号。

## lsyncd.exclude 文件

如前所述，"excludeFrom"文件必须存在，所以现在创建它：

`touch /etc/lsyncd.exclude`

如果要在计算机上同步 /etc 文件夹，那么需要忽略其中许多文件和（或）目录。只需将需要忽略的文件和目录简单地列在文件中，每行一个，如下所示：

```
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

假设一切正确，进入到 `/home/[user]` 目录，其中 `[user]` 是计算机上的用户，并使用 *touch* 在其中创建新文件。

`touch /home/[user]/testfile`

现在转到目标计算机，查看文件是否显示。如果显示，那么一切都会按预期进行。将 lsyncd.service 设置为在引导时使用以下命令：

`systemctl enable lsyncd`


## 谨记

每当您将一组文件或目录同步到另一台计算机时，请仔细考虑它对目标计算机的影响。如果您回到上面示例中的 **The lsyncd.exclude File**，您能想象如果将 */etc/fstab* 同步会发生什么情况？

对于新手，*fstab* 是用于在任何 Linux 机器上配置存储驱动器的文件。磁盘和标签几乎可以肯定是不同的。下次重新引导目标计算机时，它很可能无法完全引导。

# 总结与参考

lsycnd 是用于在计算机之间进行目录同步的强大工具。如您所见，安装起来并不难，并且很容易维护。不能要求更多。

您可以去[官方网站](https://github.com/axkibe/lsyncd)了解更多关于 lsyncd 的信息。
