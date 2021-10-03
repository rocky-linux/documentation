---
title: 迁移到Rocky Linux

---

# 如何从Centos、Alma Linux、RHEL或Oracle Linux迁移到Rocky Linux

## 所需的条件与假设

* 运行着Centos、Alma Linux、RHEL或者Oracle Linux的硬件服务器或VPS，它们的版本统一为8.4。

* 了解Linux的命令行知识

* 了解SSH远程知识

* 温和的冒险态度

* 所有的命令都应该以 root 身份运行。要么以 root 身份登陆，要么每次输入命令行前键入"sudo"

!!! note "笔记"
    sudo命令，表示普通用户（UID>=1000）临时借用超级管理员(UID=0)权限，类似Windows的右键以管理员运行，不加任何选项，sudo等同于sudo -u  root

## 介绍

在本指南中，您将学习如何将上面列出的所有发行版操作系统转换为功能齐全的Rocky Linux，这可能是在各种情况下迁移到Rocky Linux的最佳方法之一。

例如，一些服务器提供商在一段时间内默认不支持Rocky Linux ；或者您可能在生产环境下有一台服务器，希望在不重新安装所有内容的情况下，将其转换为Rocky Linux。

是的，我们为您准备了工具 [migrate2rocky](https://github.com/rocky-linux/rocky-tools/tree/main/migrate2rocky)

这是一个脚本，当执行时，会将您的存储库（dnf源）更改为Rocky Linux的存储库，软件包将根据需要被安装，新安装或被升级或被降级。

如果您是新手系统管理员，别担心，我们会尽可能的保持此脚本界面的友好性。是的，就像命令行那样的友好。

### 注意事项与警告

1. 请查看  migrate2rocky 的 README 页面（上面链接），希望您知道列出的已知问题。随着时间的推移，我们很可能会发现（并最终修复）更多的冲突与不兼容性。
2. 此脚本最有可能在全新安装时正常运行。**如果要在实际的生产环境下使用，请先做好数据备份以及系统快照，或者在临时的测试环境中进行。**

## 准备你的服务器

您可以通过多种方式从存储库中获取脚本文件。

### 手动方式

从 GitHub 下载压缩文件并提取您需要的文件（即 **migrate2rocky.sh**）。您可以在存储库主页的右侧找到这个zip 文件：

![The "Download Zip" button](/home/tianci/Documents/documentation/docs/guides/images/migrate2rocky-github-zip.png)

然后，在您的本地计算机中运行以下命令，使用scp（ssh cp）命令将文件上传到您的服务器。

```
scp PATH/TO/FILE/migrate2rocky.sh root@yourdomain.com:/home/
```

根据需要，你需要调整所在的文件路径以及服务器域名或ip地址

!!! note  "笔记"
    如果您是使用Xshell连接的远程服务器，则可以直接使用rz命令（dnf  -y  install lrzsz），选择脚本文件上传即可

### git方式

首先在您的服务器上安装git：

```
shell > dnf install git
```

clone克隆远程库：

```
shell > git clone https://github.com/rocky-linux/rocky-tools.git
```

!!! note "注意"
    这种方式将下载rocky-tools远程库的所有脚本与文件

### 简单但不太安全的方式

这不一定是最好的方式，但胜在简单，存在一定的安全性问题，希望您知道。

运行以下命令将脚本下载到您当前所在的目录下：

```
shell > curl  -o https://raw.githubusercontent.com/rocky-linux/rocky-tools/main/migrate2rocky/migrate2rocky.sh  migrate2rocky.sh
```

该命令会将文件直接下载到您的服务器，并且只会下载您想要的文件。

## 执行脚本

使用`cd`命令切换到脚本所在的目录，给脚本文件的所有者、所属组、其他人赋予 x 的权限

```
shell > chmod a+x migrate2rocky.sh
```

现在，执行脚本与对应选项

```
shell > ./migrate2rocky.sh -r
```

"-r" 选项表示安装所有内容

如果您做对了，终端窗口看起来像这样：

![a successful script startup](/home/tianci/Documents/documentation/docs/guides/images/migrate2rocky-convert-01.png)

现在，脚本需要一段时间来转换所有内容，具体取决于实际机器的硬件性能与网络连接情况。

如果您最后看到 **Complete!** 消息，则表示一切正常，重启服务器即可。

![a successful OS migration message](/home/tianci/Documents/documentation/docs/guides/images/migrate2rocky-convert-02.png)

给它一定的时间重启，键入 `hostnamectl`即可检查是否一切正常的迁移。

!!! note  "笔记"
    cat /etc/os-release 或者 cat /etc/redhat-release 都可以

![The results of the hostnamectl command](images/migrate2rocky-convert-03.png)

