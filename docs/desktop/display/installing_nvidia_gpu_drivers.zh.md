---
title: 安装NVIDIA GPU驱动程序
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## 前言

NVIDIA^&reg;^ 是目前最知名的显卡提供商之一。您可以通过不止一种方法来安装NVIDIA显卡驱动程序。本指南使用NVIDIA官方为Linux提供的软件仓库来安装驱动程序，因此会大量引用官方说明[NVIDIA Driver Installation Guide](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html)中的内容。

此外，还有其他几种方法可以用来安装NVIDIA驱动程序：

* NVIDIA官方提供的 `.run` 安装程序
* 第三方仓库，比如RPM Fusion和ELRepo 

大多数情况下，从官方仓库安装驱动程序是最佳选择。如果你更倾向于使用社区驱动的仓库，可以用RPM Fusion或ELRepo；RPM Fusion在较旧设备上运行更好。建议避免使用`.run`安装程序，尽管方便，但往往存在篡改系统文件和兼容性的问题。

NVIDIA显卡的Linux驱动程序区分专有模块和开源模块，两者在功能上没有区别，但适用的架构不尽相同：开源模块适用于Turing及更新架构的GPU，而专有模块是更旧架构GPU安装驱动程序所必选的。注意，自560版本起，开源模块成为了默认且推荐的安装选择；特别是近一两年最新的显卡（比如RTX 50系列），该系列已不再支持专有模块。

## 假定条件

在该指南中，你需要具有：

* Rocky Linux Workstation
* `sudo` 权限

## 安装必要功能和依赖

启用Extra Packages for Enterprise Linux (EPEL) 仓库和CRB仓库：

```bash
sudo dnf install epel-release -y
sudo dnf config-manager --enable crb
```

安装“Development Tools”系列，保证构建所需依赖存在于您的系统中：

```bash
sudo dnf groupinstall "Development Tools" -y
```

安装`kernel-devel`等内核组件，使得安装显卡驱动程序时相应的内核模块可以被构建：

```bash
sudo dnf install kernel-devel-matched kernel-headers -y
```

## 安装NVIDIA驱动程序

在所有事先需要的包都安装好后，接下来就可以安装NVIDIA驱动程序了：

运行下面的指令，添加NVIDIA官方仓库：

```bash
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel10/$(uname -m)/cuda-rhel10.repo
```

然后，清除DNF缓存：

```bash
sudo dnf clean expire-cache
```

最后，为您的系统安装最新的NVIDIA驱动程序。对于开源模块，运行：

```bash
sudo dnf install nvidia-open -y
```

对于专有模块，运行：

```bash
sudo dnf install cuda-drivers -y
```

### 关于较老GPU的特殊提醒
NVIDIA驱动程序的590版本[已不再支持Maxwell，Pascal，and Volta系列的GPU](https://forums.developer.nvidia.com/t/unix-graphics-feature-deprecation-schedule/60588)；此时，尽管直接运行上面的命令依然可以正常安装显卡驱动程序，但是由于找不到支持的GPU,该驱动程序无法加载。如果你的GPU是这些系列的，请调整安装命令以选择特定版本的驱动程序程序：

```bash
sudo dnf install cuda-drivers-580 -y
```

然后，你需要避免该驱动程序被DNF自动升级，详见[dnf's versionlock plugin](https://docs.rockylinux.org/books/admin_guide/13-softwares/#versionlock-plugin)。


## 禁用Nouveau

Nouveau是系统自带的开源NVIDIA驱动程序，但相对于NVIDIA官方的驱动程序功能极其有限。为防止可能的冲突，最好禁用该驱动程序：

```bash
sudo grubby --args="nouveau.modeset=0 rd.driver.blacklist=nouveau" --update-kernel=ALL
```

!!! Note

    对于启用了安全启动的系统，你需要执行如下步骤：

    ```bash
    sudo mokutil --import /var/lib/dkms/mok.pub
    ```

    注意`mokutil`这一命令会要求您创建一个密码，该密码在之后重新启动时会用到。
    
    重启设备时，系统会询问您是否想倒入一个MOK密钥，选择“Yes”并在之后的对话框中输入你在`mokutil`一步设置的密码。

重新启动系统:

```bash
sudo reboot now
```

## 结果

恭喜您成功在您的系统上安装了NVIDIA官方驱动程序。快去享受默认的Nouveau带不给你的体验吧！
