---
title: 构建和安装自定义Linux内核
author: Wale Soyinka
contributors: Steven Spencer, Louis Abel, Tianci Li, Deng Wenbin
tags:
  - 自定义内核
  - 内核
---

# 概述
在本指南中，我们将介绍获取内核源代码树、配置它、编译它，最后安装和引导内核的这一过程。

!!! wanning "警告" 对于Rocky Linux，不推荐也不支持内核重建。 在建立一个定制的内核或甚至考虑它之前，问自己以下问题"：

    * 您需要的功能是否可以通过安装 [elrepo](https://elrepo.org) 中的内核模块来实现？
    * 你需要的功能，是否可以作为内核本身的一个独立模块？
    * Rocky Linux 和大多数其他 EL 衍生工具，都是作为一个完整的环境来设计的。 更换关键部件会影响系统的运行。
    * 大多数用户不再需要构建自己的内核。 您可能只需要一个内核模块/驱动程序，或者构建自己的内核模块（kmod/dkms）。

    最后警告 如果你破坏了内核，你就有责任修复你的系统所产生的问题。

## 内核

大多数时候，当人们说_Linux_时，他们通常指的是"_Linux发行版_" - 例如，Rocky Linux和Debian是Linux发行版的类型。 一个发行版，包括让Linux作为一个功能性操作系统，存在的一切必要条件。 发行版使用独立于Linux的各种开源项目的代码。

Linux是内核。 内核实际上位于 [操作系统] 问题的核心。

Rocky Linux发行版有它所支持的特定内核版本的源代码，它可以使用这种或那种形式。 尽管内核是一个完整的Linux发行版中的一小部分，但它是迄今为止最关键的元素。 如果内核失败或崩溃，系统的其他部分就会跟着它一起崩溃。


## 内核源代码

Rocky Linux发行版有它所支持的特定内核版本的源代码，它可以使用这种或那种形式。 它们可以是编译的二进制(*.src.rpm)、源RPM(*.srpm)或类似的形式。

如果你需要下载不同于你特定的 Rocky Linux Distro 版本的版本(可能是更新版本) 查找源代码的第一个地方是官方内核网站：

[www.kernel.org](https://www.kernel.org)

这个网站维护着一个镜像内核源的网站列表，以及大量的其他开源软件、发行版和通用工具。

镜像列表保存在：

[mirrors.kernel.org](http://mirrors.kernel.org)


!!! Tip "提示"

    在下面的章节中，大部分下载、配置和编译Linux内核的工作可以/应该以非特权用户的身份完成。然而，需要实际安装或改变系统文件和二进制文件的最后步骤，需要以高权限完成。 我们能够作为一个非特权用户完成大部分工作，因为我们将使用一个特殊的内核构建选项，允许我们指定一个自定义工作或输出目录。
    
    具体而言，我们将使用 "O=~/build/kernel" 选项来处理所有适用的制造操作。 具体来说，我们将在所有适用的make调用中使用`O=~/build/kernel`选项。
    
    其中`~/build/kernel`相当于`/home/$USER/build/kernel`或`$HOME/build/kernel`。

## 内核版本和命名约定

网站上列出的可用内核将包含v1.0、v2.5、v2.6、v3.0、v3.x、v4.x、v5.x、v6.x等的文件夹。 在你跟随你的自然倾向，去获取最新版本之前，请确保你了解Linux内核版本系统是如何工作的。

目前的惯例是将主要的新内核版本命名和编号为 "Linux 5.x"（也称为vanilla或主线内核）。 因此，这个系列的第一个将是Linux 5.0版(与5.0.0相同)，下一个将是Linux 5.1版(与5.1.0相同)，随后是Linux 5.2版，以此类推。

内核构建过程中遇到故障的共同原因可能是没有所有编译和构建Linux Kernel所需的软件。 这些通常被称为稳定点发布。 因此，5.0.0系列内核的下一个稳定点版本将是Linux 5.0.1版，随后是5.0.2版，以此类推。 另一种说法是，例如，Linux 5.0.4版本是基于Linux 5.0.0系列的第四个稳定版本。

## 安装必备工具和库

内核构建过程中遇到的一个常见的故障源，可能是由于没有所有必要的软件，可用于编译和构建主线Linux内核。  缺少的工具和库，可以使用 Rocky Linux 系统上的DNF 软件包管理器安装。 我们将在本节中处理这个问题。

1. 在 Rocky Linux 磁盘上，您可以通过运行此命令快速获得大多数必要的开发工具：

    ```
    > sudo dnf -y groupsinstall “C 开发工具和库”
    ```

    如果您得到'模块或组 'C 开发工具和库'不可用'。'下面的错误等于上面的错误：

    ```
    > sudo dnf -y groupsinstall '开发工具'
    ```

2. 您可能需要的其他一些库、头文件和应用程序也可以通过安装以下软件包获得。 输入命令：

    ```
    > sudo dnf -y install \
    ncurses-devel openssl-devel elfutils-libelf-devel python3
    ```

3. 接下来，我们需要一些仅在某些支持的第三方仓库中可用的其他实用程序。 其中一个仓库是Powertools仓库. 让我们在我们的落基系统上启用那个repo。 输入：

    ```
    > sudo dnf config-manager --set-enable powertools
    ```

4. 最后，让我们从Powertool仓库安装所需的软件包。 输入：

    ```
    > sudo dnf -y install dwarves
    ```

我们将在下面一节中构建的内核版本为5.16.9，可查阅：

## 下载和解压Linux 内核。

下面我们要构建的内核版本是 6.5.7，可从以下网址获取：

[www.kernel.org/pub/linux/kernel/v5.x/linux-5.16.9.tar.xz](https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.5.7.tar.xz)

让我们开始这个过程。

1. 首先，使用下面的curl命令下载所需内核源到您当前的工作目录。 输入：

    ```
    curl -L -o linux-5.16.9.tar.xz \
    https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.16.9.tar.xz
    ```

2. 您将从互联网下载的内核源是一个打包和压缩的文件。 因此，要使用源代码，您需要解压和解包源文件。

    请确保您在下载Kernel tarball的目录中。 用 tar 命令来解压和解包文件，运行：

    ```
    tar xvJf linux-5.*.tar.xz
    ```

## 构建内核

在本节中，我们将审查配置和构建内核的过程。 与 macOS 或 Windows 操作系统形成对比。 它是预先配置的，因此包含对您可能想要或不想要的许多功能的支持。

Linux的设计理念允许个人决定内核的重要部分。 这种个性化的设计有一个重要的好处，就是让你缩小功能列表，使Linux能够尽可能有效地运行。

这也是为什么，有可能定制Linux以运行在各种硬件设置中的原因之一，从低端系统，到嵌入式系统，到高端系统。

构建内核需要两个主要步骤：

- 安全或错误修复影响您的系统，必须应用
- 正在编译

在一个正在运行 Linux的系统中，您可以运行类似的命令 - lspci, lshw 等等帮助显示系统上准确硬件安装的详细信息。 基于 RPM 的磁盘上，这些实用程序由 pciutors*.rpm 和 lshw*.rpm 软件包提供。 当然，这意味着你需要一个硬件清单。

更好地了解什么是您的基础硬件可以帮助您更好地确定您在自定义内核中需要什么。 您已准备好开始配置内核。

如果粗略地了解我们新内核需要支持的硬件和特征类型，我们就可以开始实际配置。 但首先是一些背景资料。

### 使建筑环境卫生化

如果粗略地了解我们新内核需要支持的硬件和特征类型，我们就可以开始实际配置。 但首先是一些背景资料。

Linux 内核源树包含几个名为 Makefile 的文件(makefile 只是一个带有指令的文本文件，它还描述了程序中文件之间的关系)。

These makefiles help to glue together the thousands of other files that make up the kernel source. 对我们来说更重要的是，makefiles也包含目标。 Targets 是make执行的命令共和扩展。


!!! 以下将更详细地讨论其中一些目标：

    铭记如果你有一个稳定和良好运作的工作体系， 没有理由升级内核，除非这些条件之一对您来说：

    - 安全或错误修复影响您的系统，必须应用
    - 您需要一个稳定版本中的特定新功能

    在安全修复的情况下，决定风险是否真的影响您，例如： 如果在您不使用的设备驱动程序中发现安全问题，那么可能没有理由升级。 在 bug 修复发布的情况下。 仔细阅读发布笔记，并决定错误是否真的影响您——如果您有一个稳定的系统 用你从未使用的补丁升级内核可能毫无意义。

    在生产系统中，内核不应仅仅升级为“最新内核”；你应该有真正令人信服的理由进行升级。

要在本节中配置内核，我们只能使用其中一个命令。 尤其是，我们将使用make menuconfig 命令。

- **make mrproper** 这个命令，清除了以前内核构建中，可能遗留下来的任何陈旧文件和依赖物的构建环境。 所有以前的内核配置将从构建环境中清理(删除)。
- **make clean** 这个目标没有像正确的目标那样彻底。 它只删除大多数生成的文件。 它不删除内核配置文件(.config)。
- **make menuconfig** 此目标调用了一个基于文本的编辑器界面与菜单、选项列表和基于文本的对话框来配置内核。
- **使 xconfig**成为基于 GUI 的内核配置工具/目标, 依赖Qt 图形开发库。 这些库被基于 KDE /Plasma 的应用程序使用。
- **make gconfig** 也是基于 GUI 的内核配置工具/目标，但它依靠GTK+ 工具包。 这个GTK工具包在GNOME桌面世界中得到了广泛使用。
- **make olddefconfig **这个目标使用了现有的 。 当前工作目录中的 onfig 文件，更新依赖关系，并自动将新符号设置为其默认值。
- **make help **这个目标将向您展示所有其他可能的目标并同时作为一个快速在线帮助系统。

要在本节中配置内核，我们只能使用其中一个命令。 尤其是，我们将使用make menuconfig 命令。 菜单配置内核配置编辑器是一个简单和流行的文本配置工具，包括菜单、无线电按钮列表和对话框。

它有一个简单而干净的界面，可以轻松地用您的键盘导航，并且几乎很直观使用。

我们需要更改 (cd) 进入内核源代码目录，然后就可以开始内核配置了。 但在开始实际内核配置之前，你应该使用 make mrproper 命令清理（prepare）内核构建环境：

```
> cd linux-5.*
> make O=~/build/kernel mrapply
```

### 内核配置

接下来，我们将逐步介绍配置 Linux 5.* 系列内核的过程。 为了探究这一过程的一些内部结构，我们将启用一个特定功能的支持，并将其假定为系统中必须具备的功能。 了解其工作原理后，您就可以使用相同的程序，来添加对任何其他新内核功能的支持。 具体来说，我们将在自定义内核中启用对 NTFS 文件系统的支持。

大多数现代 Linux 发行版，都会在本地文件系统中以压缩文件或普通文件的形式，提供运行内核的内核配置文件。 在我们的示例 Rocky 系统中，该文件位于 /boot 目录下，通常命名类似 config-4.*。

The configuration file contains a list of the options and features that were enabled for the particular kernel it represents. 在配置内核的过程中，我们的目标就是创建一个类似的配置文件。 我们将创建的文件和准备完成的文件之间的唯一区别是，我们将为我们添加更少的自定义内容。


!!! 我们将使用基于文本的内核配置工具 无论您是否使用GUI桌面环境都允许您可以继续。

    使用已知的 作为创建我们自己的自定义文件的框架前存在的配置文件有助于确保我们不会浪费太多的时间，重复其他人已经做出的努力来寻找什么是可行的，什么是不可行的！

以下步骤涉及如何配置内核。 我们将使用基于文本的内核配置工具 无论您是否使用GUI桌面环境都允许您可以继续。

1. 要开始, 我们将会从/boot 目录复制到我们的内核构建环境中并重命名预存在的配置文件：
    ```
    > cp /boot/config-`uname -r` ~/build/kernel/.config
    ```
    我们在这里使用 `uname -r` 来帮助我们获取运行中内核的配置文件。 uname -r 命令打印运行中内核版本。 使用它有助于确保我们正在得到我们想要的准确版本，以防有其他版本存在的情况。

    !!! note "说明"

     Linux 内核配置编辑器特别启动搜索并最终生成一个名为……的文件。 内核源树根目录下的 config (声明的“.config”)。 此文件是隐藏的。

2. 启动图形内核配置工具：

    ```       
    > 制作O=~/build/内核菜单配置
    ```

    屏幕大致会显示：

![主内核配置屏幕](images/Il01-kernel.png)

    内核配置屏幕大致分为大约三个区域。
    顶部部分显示各种有用的信息，键盘快捷键和菜单，可以帮助您导航应用程序。
    屏幕主体显示一个可扩展树结构的总可配置内核选项列表。 您可以在父中进一步钻探带箭头的条目，查看和/或配置子菜单(或子菜单)。 最后，屏幕底部显示用户可以选择的实际动作/选项。

3. 接下来，为了演示目的，我们将把支持NTFS添加到我们的自定义内核中。

    在主配置屏幕上，使用箭头键导航并高亮文件系统项目。 在选择文件系统时，按回车键查看文件系统的子菜单或子项目。

    在文件系统部分，使用箭头键导航到 DOS/FAT/NT 文件系统。 按回车键查看 DOS/FAT/NT 文件系统的子项目。

4. 在DOS/FAT/NT 文件系统部分中，导航到 NTFS 文件系统支持。

    输入 M (大写)以便通过模块支持NTFS文件系统。

    使用箭头键导航到 NTFS 调试支持 (NEW)，然后按 y 将其包括在内。

    使用箭头键导航到 NTFS 写支持，然后按 y 将其包括在内。 当你完成时，字母M或星号 (*) 应该在每个选项旁边显示，如显示在这里：

    ![内核配置文件系统屏幕](images/Il02-kernel.png)

    !!! tip "提示"
   
        对于每个可配置选项，在内核配置实用中，空圆括号 <>表示该功能已禁用。 圆括号中的字母M, <M>, 表示该功能将编译为模块。
       
        而角括号中的星号（<*>）则表示该功能的支持将直接内置于内核中。 您通常可以使用键盘上的空格键，切换所有可能的选项。

5. 在DOS/FAT/NT文件系统屏幕上按两次键盘上的esc键，导航回到上级文件系统屏幕。 再按两次键盘上的esc键，返回到内核配置主界面。

6. 最后，将您的更改保存到 。 在内核源树根目录下的配置文件并在保存文件后再次按下键盘上的 esc 两次退出内核配置应用程序。

7. 一个对话框将显示提示您保存您的新配置。 确保选择是的，然后按回车键。

8. 在内核配置工具退出后，你会被扔回你的shell--在内核源码树内。 你几乎已经准备好建立你的内核了!

9. 我们需要在我们的Rocky上完成更多的定制工作。 输入：

    ```
    sed -ri '/CONFIG_SYSTEM_TRUSTED_KEYS/s/=.+/=""/g' ~/build/kernel/.config
    ```

    !!! tip "提示"

     要查看您使用菜单配置工具进行的某些更改的结果，请使用grep 工具查看。 您直接保存的配置文件。 例如，要查看我们以前启用的NTFS文件系统支持的效果，请输入以下内容：
        ```
        > grep NTFS ~/build/kernel/.config
        CONFIG_NTFS_FS=m
        CONFIG_NTFS_DEBUG=y
        CONFIG_NTFS_RW=y
        ```

    !!! 注“关于内核模块的快速说明”

     可加载模块支持是 Linux 内核功能，允许内核模块的动态加载(或移除)。    
    
     内核模块是编译的代码块，可以动态地插入到运行中的内核，而不是永久地嵌入内核。 因此，不经常使用的功能可以被启用，但当它们没有被使用时，它们将不会占用任何存储空间。
    
     幸运的是，Linux内核可以自动决定加载的内容和时间。 当然，并非每个功能都有资格被编译为模块。 内核在加载和卸载模块之前必须知道几件事， 例如如何访问硬盘和解析存储可加载模块的文件系统。 一些内核模块也通常被称为驱动程序。

### 编译内核

在上一节中，我们介绍了为要构建的自定义内核创建配置文件的过程。 这将有助于我们能够区分此内核和任何具有相同版本号的其他内核。 我们将把标签“custom”添加到内核版本信息。

建立内心过程的编纂阶段远远是最容易的，但也需要最长时间。 此刻所需要的只是执行制作命令。 然后自动生成和处理任何依赖性问题， 编译内核本身，并编译任何启用的功能(或驱动器)，作为可加载模块。 我们将把标签“custom”添加到内核版本信息。 这可以通过编辑主Makefile并附加到EXTRAVERSION标签来实现。

到目前为止，内核构建过程中的编译阶段是最简单的，但也是最耗时的。 此时只需执行 make 命令，它就会自动生成并处理任何依赖性问题，编译内核本身，并编译作为可加载模块启用的任何功能（或驱动程序）。

由于需要编译大量代码，您至少需要等待几分钟，这取决于您系统的处理能力。 让我们深入了解编译新内核所需的具体步骤。

1. 首先，我们将为我们将要建立的内核添加一个额外的标识字符串。 当仍然在内核源树的根目录中，我们将使用已经编辑的 Makefile 文件。 我们想要更改的变量接近文件的顶部。 我们想要更改看起来像这样的文件中的行：

    ```
    EXTRAVERSION =
    ```

    改为：

    ```
    EXTRAVERSION = -custom
    ```

    使用下面的 `ed` 命令进行更改。 输入：

    ```
    sed  -i 's/^EXTRAVERSION.*/EXTRAVERSION = -custom/'  Makefile
    ```

    当然，您也可以使用您喜欢的任何文本编辑器进行更改。 只需记住保存您的更改到文件！

2. 将内核版本目标传递到制作命令以查看您刚才自定义的内核完整版本：

    ```
    > 制作O=~/build/内核内核版本
    ```

    !!! Tip "提示"

     您可以利用所有这些额外的加工功率 (CPU) 在大多数现代系统中，核心等等，并且大大加快了CPU密集型操作，例如编译内核。 要做到这一点，您可以将参数传递到指定要同时运行的任务数目的命令中。 然后在每个CPU核心上同时分配和执行指定的任务数量。 命令的语法是：

            ```
            > make -j N
            ```


         其中，N 是同时运行的作业数量。 例如，如果您使用的是八核心CPU，您可以键入：

            ```
            > make -j 8
            ```

3. 编译内核所需的唯一命令是make命令：

    ```
    > make  O=~/build/kernel**
    make[1]: Entering directory '/home/super/build/kernel'
    SYNC    include/config/auto.conf.cmd
    GEN     Makefile
    HOSTCC  scripts/kconfig/conf.o
    HOSTLD  scripts/kconfig/conf
    GEN     Makefile
    ...<OUTPUT TRUNCATED>…
    LD [M]  sound/usb/usx2y/snd-bank-usx2y.ko
    LD [M]  sound/x86/snd-hdmi-lpe-audio.ko
    LD [M]  sound/xen/snd_xen_front.ko
    LD [M]  virt/lib/irqvidass.ko
    make[1]: leaving directory '/home/super/build/kernel'
    ```

4. 此命令的最终产品(即内核)的路径为：

    ```
    ~/build/kernel/arch/x86/boot/bzImage
    ```

5. 因为我们将内核的部分作为模块（例如NTFS模块），我们需要安装这些模块。 输入以下内容：

    ```
    > sudo make O=~/build/kernel modules_instalment
    ```

    在我们的 Rocky 系统上，这个命令将把所有编译的内核模块安装到 /lib/modules/<new_kernel-version> 目录 在此示例中，此路径将转换为 /lib/modules/5.16.9-custom/。 这是内核根据需要加载所有可加载模块的路径。

    !!! tip "提示"

     通过“make modules_install”安装的内核模块的足迹(大小)最终会变得相当大，因为模块包含调试符号。 因此，你可以很容易地以一个大小接近5GB的 `/lib/modules/5.16.9-custom/` 目录来结局！
    
     对于本指南，我们通过在我们的模块中包含INSTALL_MOD_STRIP=1 选项来避免这么大的大小。 您可以通过拆除这些调试符号来减少总大小（例如-小于200 MB!!）。  
    
     这可以通过将 `INSTALL_MOD_STRIP=1` 选项纳入`make modules_install` 命令来完成。

## 安装 Kernel

假定您有一个 PC 并正在完成 `~/build/kernel /` 目录， 上次练习中创建的编译内核将位于此路径中。 `<kernel-build-dir>/arch/x86/boot/bzImage` 或 精确度，以我们的示例  `~/build/kernel/arch/x86/boot/bzImage`

System.map 文件在内核出现错误并生成“Oops”消息时是有用的。 某些内核错误因内核缺陷或故障硬件而产生“Oops”。

这个错误类似于Microsoft Windows中的蓝屏死亡(BSOD)。 这些信息包括许多关于该系统当前状态的详细信息，包括几个十六进制数字。

System.map 让Linux有机会将这些十六进制数字转换为可读名，从而使调试变得更加容易。 虽然这主要是为了开发者的便利，但当您报告问题时，它可能是方便的。

System.map 让Linux有机会将这些十六进制数字转换为可读名，从而使调试变得更加容易。 虽然这主要是为了开发者的便利，但当您报告问题时，它可能是方便的。

让我们完成安装新内核镜像所需的步骤。

1. 在内核构建目录的根目录中，复制并重命名了 bzImage 文件到/boot 目录：

    ```
    > **sudo cp ~/build/kernel/arch/x86/boot/bzImage \
    /boot/vmlinuz-<kernel-version>**
    ```

    在这里，内核版本是内核的版本号。 对于我们在本指南中使用的示例内核，文件名将是 vmlinuz-5.16.9-custom。 下面是这个示例的确切命令：

    ```
    > sudo cp ~/build/kernel/arch/x86/boot/bzImage
    /boot/vmlinuz-5.16.9-自定义
    ```

    !!! 说明

     将内核镜像命名为 vmlinuz-6.5.7-custom 有点武断。 这是方便的，因为内核图像通常称为vmlinuz。 当您有多个内核可用或内核提供特定功能时，版本号的后缀是有用的(例如vmlinuz-6)。 （0.0-w）。

2. 现在内核映像已经就位，复制并重新命名相应的 System.map 文件到 /boot 目录，使用相同的命名约定：

    ```
    > sudo cp -v  ~/build/kernel/System.map \
    /boot/System.map-6.5.7-custom
    ```

3. 由于内核已经到位、系统映射文件已经到位以及模块已经到位，因此我们现在已经准备好迈出最后一步。 命令所需的语法是：

    ```
    > kernel-install add  <kernel-version><kernel-image>
    ```

    这里， <kernel-version> 是内核的版本号(和名称)。 和 <kernel-image> 是新编译的内核图像的路径。

    我们的示例是：

    ```
    > sudo kernel-install
    add  6.5.7-custom /boot/vmlinuz-6.5.7-custom
    ```

这里使用的 kernel-install 命令是一个少量的 shell 脚本。 它可能不是每个 Linux 发行版都有，但在较新的 Fedora、RHEL 和 CentOS 发行版中都有。 该工具自动完成了许多我们通常需要手动完成的最后设置工作，以便系统启动我们刚刚构建的新内核。

特别是，该工具做到如下：

- 它创建适当的初始RAM 文件系统图像(the initramfs image—that is, the /boot/initramfs-<kernel-version>.img file)。 要在无法安装内核的系统上手动执行此操作，请使用 mkinitramfs 命令。
- 它运行深模组命令(创建模块依赖列表)。
- 它更新引导加载器配置。

对于运行较新版本的 GRUB2 的系统，文件将是 `/boot/grub2/grub.cfg`。 对于基于EFI的系统 /boot/efi/<distro>fedora/grub.cfg 也已更新。

对于运行 GRUB旧版本的系统，这将是/boot/grub/grub.conf 或 /boot/grub/menu.lst 文件。 对于已经执行了新的启动加载器规格(BLS)的非常新的磁盘，将会在/boot/loader/entries/directore/目录或由变量命名为“blsdir”的任何目录中添加一个新的引导条目。

在基于 EFI 的演示Rocky 服务器上使用 BLS 运行 GRUB 2 一个新的引导条目是在这里的引导加载器文件中创建的： `/boot/loader/entries/6fa25ca775f64accb0d3e53f0e4e6e92-5。 6.9-custom.conf`

```
> sudo cat /boot/loader/entries/6fa25ca775f64accb0d3e53f0e4e6e92-5.16.9-custom.conf
title Rocky Linux (5.16.9-custom) 8.5 (Green Obbosan)
版本 5.16.9-custom
linux /vmlinuz-5.16。 -自定义
initrd /initramfs-5.16.9-custom.img $tuned_initrd
选项 $kernelopts $tuned_params
id rocky-202202120135-5 6.9-自定义
grub_users $grub_users
grub_arg --notel
grub_class 内核
```

!!! note "说明"

    大多数发行版都有几个grub2-*实用功能，可用于执行各种GRUB2和启动加载器维护家庭的任务。 例如，您可以使用 grub2-set-default 命令更改或设置系统启动时启动的默认内核。

## 启动自定义内核。
下一个阶段是测试新内核，以确保系统确实能够与它一起启动。

1. 假定你做了指定的一切，一切都那样完美。 您可以安全地重启系统并在系统启动时从引导菜单中选择新内核：

    ```
    >  sudo reboot
    ```

2. 系统启动后，您可以使用uname 命令来查找当前内核的名称：

    ```
    >  uname -r
    5.16.9-自定义
    ```

3. 你会记得，我们添加到我们新内核的一个功能是支持NTFS文件系统的能力。 通过显示有关NTFS模块的信息，确保新内核确实支持NTFS：

    ```
    [rockstar ~]$ modinfo ntfs
    filename: /lib/modules/5.16.9-custom/kernel/fs/ntfs/ntfs.ko
    license: GPL
    version: 2.1.32
    描述: NTFS 1.2/3.x 驱动程序-版权所有 …
    ...<OUTPUT TRUNCATED>...
    ```

以上就是所有！
