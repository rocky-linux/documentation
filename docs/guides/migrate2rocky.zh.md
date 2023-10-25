---
title: 迁移到Rocky Linux
author: Ezequiel Bruni
contributors: tianci li, Steven Spencer, Ganna Zhyrnova, Deng Wenbin
update: 11-23-2021
---

# 如何从CentOS Stream、Centos、Alma Linux、RHEL或Oracle Linux迁移到Rocky Linux

## 所需的条件与假设

* CentOS Stream、CentOS、Alma Linux、RHEL或Oracle Linux在硬件服务器或 VPS 上运行良好。 其每一个当前支持的版本都是 8.8 或 9.2 。
* 了解Linux的命令行知识。
* 了解SSH远程知识。
* 轻度冒险的态度。
* 以root用户身份运行命令。 要么以 root 身份登陆，要么每次输入命令行前键入"sudo"。

## 引言

在本指南中，您将学习如何将上面列出的所有发行版操作系统转换为功能齐全的Rocky Linux。 这可能是在各种情况下迁移到Rocky Linux的最佳方法之一，也是针对不同情况的人最方便的。

例如，一些服务器提供商在默认情况下暂时不支持Rocky Linux。 或者您可能在生产环境下有一台服务器，希望在不重新安装所有内容的情况下，将其转换为Rocky Linux。

是的，我们为您准备了工具 [migrate2rocky](https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky)

这是一个脚本，运行后会将你的所有软件源更改为 Rocky Linux 的软件源。 软件包将根据需要进行安装和升级/降级，所有操作系统的品牌也将发生变化。

如果您是新手系统管理员，别担心，我们会尽可能的保持此脚本界面的友好性。 是的，就像命令行那样的友好。

### 注意事项与警告

1. 请查看 migrate2rocky 的 README 页面（上面链接），因为脚本和Katello的存储库之间存在已知冲突。 随着时间的推移，我们很可能会发现（并最终修复）更多的冲突与不兼容性，尤其对于生成服务器，您需要了解这些。
2. 此脚本最有可能在全新安装时正常工作。 _如果要在实际的生产环境下使用，**请先做好数据备份以及系统快照，或者首先在临时的测试环境中进行。 **_

您准备好了吗？

## 准备你的服务器

您需要从存储库中获取实际的脚本文件， 可以通过多种方式做到这一点。 可以通过多种方式做到这一点。

### 手动方式

从 GitHub 下载压缩文件并提取您需要的文件（即 *migrate2rocky.sh*）。 您可以在存储库主页的右侧找到这个zip 文件：

!["Download Zip"按钮](images/migrate2rocky-github-zip.png)

然后，通过在本地计算机上运行以下命令，使用ssh将可执行文件上传到服务器：

```
scp PATH/TO/FILE/migrate2rocky.sh root@yourdomain.com:/home/
```

根据需要，你需要调整所在的文件路径以及服务器域名或ip地址

### git方式

在您的服务器上安装git：

```
dnf install git
```

克隆rocky-tools存储库：

```
git clone https://github.com/rocky-linux/rocky-tools.git
```

注: 这种方式将下载rocky-tools存储库的所有脚本与文件

### 简单方式

这可能是获得该脚本的最简单的方法。 你只需要在服务器上安装一个合适的HTTP客户端(curl, wget, lynx等)。

假设你已经安装了`curl`工具，运行以下命令将脚本下载到您当前所在的目录下：

```
curl https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh -o migrate2rocky.sh
```

该命令会将文件直接下载到您的服务器，并且*只*会下载您想要的文件。 但同样，出于安全考虑，这并不一定是最佳做法，所以请记住这一点。

## 执行脚本与安装

使用`cd`命令切换到脚本所在的目录，确认该文件是可执行的，给脚本文件的所有者赋予 x 的权限。

```
chmod u+x migrate2rocky.sh
```

现在，终于可以执行脚本了：

```
./migrate2rocky.sh -r
```

"-r" 选项表示安装所有内容

如果您做的一切都是正确的，那么您的终端窗口应该看起来有点像这样：

![成功启动脚本](images/migrate2rocky-convert-01.png)

现在，脚本需要一段时间来转换所有内容，具体取决于实际机器/服务器的硬件性能与网络连接情况。

如果您最后看到 **Complete!** 消息，则表示一切正常，重启服务器即可。

![一个成功的 OS 迁移消息](images/migrate2rocky-convert-02.png)

给它一些时间，重新登录，你应该有一个漂亮的新的Rocky Linux服务器来玩wi... 我的意思是做非常严肃的工作。 运行`hostnamectl`命令检查操作系统迁移是否正确，然后就可以了。

![hostnamectl命令的结果](images/migrate2rocky-convert-03.png)
