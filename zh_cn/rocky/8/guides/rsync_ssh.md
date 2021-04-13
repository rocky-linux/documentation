# 使用 rsync 保持两台计算机同步

## 准备工作

在继续阅读这篇指南之前，您需要准备或了解以下的内容：

* 一台运行 Rocky Linux 的计算机。
* 熟悉从命令行修改配置文件。
* 了解如何使用命令行编辑器（本文使用 _vi_，也可以使用您喜欢的其他编辑器)。
* 您将需要 root 访问权限，并且最好在终端以 root 用户身份登录。
* SSH 公私密钥对。
* 能够使用 vi 或您喜欢的编辑器创建一个简单的 bash 脚本，并对其进行测试。
* 能够使用 _crontab_ 自动运行脚本。

# 简介

通过 SSH 使用 rsync 既不如 [lsyncd](RL_mirroring_lsyncd.md)（允许您监视目录或文件的更改并使其实时同步）强大，也不如 [rsnapshot](RL_rsnapshot_backup.md)（允许您能够轻松地从一台计算机上备份多个目标）灵活。但是，它确实提供了按您定义的时间表使两台计算机保持最新状态的能力。

rsync 从一开始就存在了也许没那么长，但确实已经很久了！)。因此，每个 Linux 发行版都提供了它，并且大多数仍然与基本软件包一起安装。如果您需要保持目标计算机上的一组目录是最新的，那么通过 SSH 进行 rsync 可能是一种解决方案，但是实时同步并不是特别重要。

对于下面的所有操作，将以 root 用户身份执行操作，因此要么以 root 用户身份登录，要么使用 `sudo -s` 命令在终端中切换到 root 用户。

## 安装 rsync

虽然 rsync 可能已经安装，但最好在源计算机和目标计算机上将 rsync 更新为最新版本。要确保 rsync 已安装并且是最新的，请在两台计算机上执行以下操作：

`dnf install rsync`

如果软件包未安装，dnf 将要求您确认安装，如果已安装，dnf 将查找更新并给提示安装。

## 准备环境

此特定示例将在目标上使用 rsync 从源获取，而不是从源推送到目标，因此需要为此设置一个 [SSH 密钥对](RL_ssh_public_private_keys.md)。一旦创建了 SSH 密钥对，并且已经确认从目标计算机访问源计算机无需密码，便可以开始了。

## rsync 参数和设置脚本

在设置脚本之前，首先需要确定要与 rsync 一起使用的参数选项。有许多选项，详情参见[ rsync 手册](https://linux.die.net/man/1/rsync)。rsync 最常用的选项是 -a 选项，因为 -a 或 archive 将多个选项组合为一个选项，而这些选项都是非常常见的选项。-a 包括什么？

* -r, 递归目录
* -l, 将符号链接保持为符号链接
* -p, 保留权限
* -t, 保留修改时间
* -g, 保留 group-
* -o, 保留所有者
* -D, 保留设备文件

The only other options that we need to specify in this example is:在此示例中，需要指定的唯一其他选项是：

* -e, 指定要使用的远程 shell
* --delete, 表示如果目标目录中包含源文件中不存在的文件，则将其删除

接下来，创建一个脚本文件。（同样，如果您不熟悉 vi，请使用您喜爱的编辑器。）要创建文件，只需使用以下命令：

`vi /usr/local/sbin/rsync_dirs`

然后使其可执行：

`chmod +x /usr/local/sbin/rsync_dirs`

## 测试

现在，编写脚本使其超级简单和安全以便可以无所畏惧地进行测试。请注意，下面使用的 URL 是“Soure.domain.com”。将其替换为您自己的源计算机的域或 IP 地址，两者都可以工作。还要记住，本例是在“目标”计算机上创建脚本，因为是从源计算机中获取文件：

```
#!/bin/bash
/usr/bin/rsync -ae ssh --delete root@source.domain.com:/home/your_user /home
```
**如果存在主目录，您可能需要在执行脚本之前备份它！**

现在运行脚本：

`/usr/local/sbin/rsync_dirs`

如果一切正常，您应该在目标计算机上获得一个完全同步的主目录副本。检查以确保情况属实。

假设如预期工作，接下来继续，在源计算机上的主目录中创建一个新文件：

`touch /home/your_user/testfile.txt`

再次运行该脚本：

`/usr/local/sbin/rsync_dirs`

然后验证目标计算机是否接收到新文件。如果是这样，下一步就是检查删除过程。在源计算机上，删除刚才创建的文件：

`rm -f /home/your_user/testfile.txt`

再次运行该脚本：

`/usr/local/sbin/rsync_dirs`

在目标计算机上验证该文件已不存在。

最后，在目标计算机上创建源文件中不存在的文件。在目标计算机上：

`touch /home/your_user/a_different_file.txt`

最后一次运行该脚本：

`/usr/local/sbin/rsync_dirs`

刚才在目标上创建的文件现在应该消失了，因为源上不存在该文件。

假定所有这些工作均按预期进行，请继续并修改脚本以同步所需的所有目录。

## 自动化

我们可能不希望每次想要同步时都手动运行此脚本，因此下一步是使它自动化。假设您想每天晚上 11 点运行此脚本。要使用 Rocky Linux 实现自动化，使用 crontab：

`crontab -e`

这将调用 cron，可能如下所示：

``` 
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
# 
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
# 
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command
```
cron 设置为 24 小时制，因此需要在文件底部输入：

`00 23   *  *  *    /usr/local/sbin/rsync_dirs`

这表示在 00 分、23 时、每天、每月、每周的每天运行此命令。使用以下命令保存您的 cron 条目：

`Shift : wq!` 

或使用您喜欢的编辑器用于保存文件的命令。

# 总结

虽然 rsync 可能没有其他一些选项灵活或强大，但它提供了简单的文件同步。这总归是有用的。
