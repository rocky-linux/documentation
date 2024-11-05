---
title: 文件系统
author: Antoine Morvan
contributors: Steven Spencer, tianci li, Serge, Ganna Zhyrnova
tags:
  - 文件系统
  - 系统管理
---

# 文件系统

在本章中，您将学习如何使用文件系统。

---

**目标** : 在本章中，未来的 Linux 管理员们将学习如何：

:heavy_check_mark: 管理磁盘上的分区；  
:heavy_check_mark: 使用LVM更好地利用磁盘资源；  
:heavy_check_mark: 为用户提供文件系统并管理访问权限。

同时也发现：

:heavy_check_mark: Linux 中的树状结构是如何组织的；  
:heavy_check_mark: 提供不同类型的文件以及如何使用这些文件；

:checkered_flag: **硬件**、**磁盘**、**分区**、**lvm**、**linux**

**知识性**: :star: :star:  
**复杂度**: :star: :star:

**阅读时间**: 20 分钟

---

## 分区

分区将允许安装多个操作系统，因为它们不可能共存于同一逻辑驱动器上。 分区还允许在逻辑上分离数据（安全性、访问优化等）。

存储在磁盘第一个扇区（MBR: *Master Boot Record*）中的分区表记录了物理磁盘划分为分区卷的过程。

对于 **MBR** 分区表类型，同一物理磁盘最多可以划分为4个分区：

- *主分区*
- *扩展分区*

!!! Wanning "警告"

    每个物理磁盘只能有一个扩展分区。 也就是说，一个物理磁盘在 MBR 分区表中最多可以有：

    1. 三个主分区加上一个扩展分区
    2. 四个主分区

    扩展分区无法写入数据和格式化，只能包含逻辑分区。 MBR 分区表可以识别的最大物理磁盘是 **2TB**。

![仅分为4个主分区](images/07-file-systems-001.png)

![划分为3个主分区和1个扩展分区](images/07-file-systems-002.png)

### 设备文件名命名规范

在 GNU/Linux 世界，一切都是文件。 对于磁盘，它们在系统中被识别为：

| 硬件               | 设备文件名                 |
| ---------------- | --------------------- |
| IDE 硬盘           | /dev/hd[a-d]          |
| SCSI/SATA/USB 硬盘 | /dev/sd[a-z]          |
| 光盘驱动器            | /dev/cdrom 或 /dev/sr0 |
| 软盘               | /dev/fd[0-7]          |
| 打印机（25针）         | /dev/lp[0-2...]       |
| 打印机（USB）         | /dev/usb/lp[0-15]     |
| 鼠标               | /dev/mouse            |
| 虚拟硬盘             | /dev/vd[a-z]          |

Linux 内核包含大多数硬件设备的驱动程序。

我们称之为 *设备* 的是不带 `/dev` 存储的文件，用于标识主板检测到的不同硬件。

名为 udev 的服务负责应用命名约定（规则），并将其应用于检测到的设备。

欲了解更多信息，请查看 [这里](https://www.kernel.org/doc/html/latest/admin-guide/devices.html)。

### 设备分区号

块设备（存储设备）后面的数字表示分区。 对于 MBR 分区表，数字 5 必须是第一个逻辑分区。

!!! warning "警告"

    请注意！ 这里所说的分区号主要是指块设备（存储设备）的分区号。

![分区的识别](images/07-file-systems-003.png)

对磁盘进行分区至少有两个命令：`fdisk` 和 `cfdisk`。 这两个命令都有一个交互式菜单。 `cfdisk` 更可靠且有更好的优化，所以最好使用它。

使用 `fdisk` 的唯一原因是您希望使用 `-l` 选项列出所有逻辑设备。 `fdisk` 使用 MBR 分区表，因此不支持 **GPT** 分区表，也无法处理超过 **2TB** 的磁盘。

```bash
sudo fdisk -l
sudo fdisk -l /dev/sdc
sudo fdisk -l /dev/sdc2
```

### `parted` 命令

`parted`（*分区编辑器*）命令可以对磁盘进行分区且没有 `fdisk` 的缺点。

`parted` 命令既可在命令行中使用，也可交互式使用。 它还具有恢复功能，能够重写已删除的分区表。

```bash
parted [-l] [device]
```

在图形界面下，有一个非常完整的 `gparted` 工具：*G*nome *PAR*tition *ED*itor。

`gparted-l` 命令列出计算机上的所有逻辑设备。

`gparted` 命令在不带任何参数的情况下运行时，将显示带有内部选项的交互式模式：

- `help` 或错误的命令将显示这些选项。
- 此模式下的 `print all` 将具有与命令行上的 `gparted-l` 相同的结果。
- `quit` 返回到提示符。

### `cfdisk` 命令

`cfdisk` 命令用于管理分区。

```bash
cfdisk device
```

示例：

```bash
$ sudo cfdisk /dev/sda
                                 Disk: /dev/sda
               Size: 16 GiB, 17179869184 bytes, 33554432 sectors
                       Label: dos, identifier: 0xcf173747
    Device        Boot       Start        End    Sectors   Size   Id Type
>>  /dev/sda1     *           2048    2099199    2097152     1G   83 Linux
    /dev/sda2              2099200   33554431   31455232    15G   8e Linux LVM
 lqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk
 x Partition type: Linux (83)                                                 x
 x     Attributes: 80                                                         x
 xFilesystem UUID: 54a1f5a7-b8fa-4747-a87c-2dd635914d60                       x
 x     Filesystem: xfs                                                        x
 x     Mountpoint: /boot (mounted)                                            x
 mqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj
     [Bootable]  [ Delete ]  [ Resize ]  [  Quit  ]  [  Type  ]  [  Help  ]
     [  Write ]  [  Dump  ]
```

在没有 *LVM* 的情况下，物理介质的准备工作需要经过五个步骤：

- 设置物理磁盘；
- 卷的分区（磁盘分区，安装多个系统的可能性，...)；
- 创建文件系统 (允许操作系统管理文件、 树结构、权限...)；
- 挂载文件系统（在树结构中注册文件系统）；
- 管理用户访问。

## 逻辑卷管理器（LVM）

**L**ogical **V**olume **M**anager (*LVM)*)

**标准分区** 创建的分区无法动态调整硬盘资源，一旦被挂载，容量就完全固定，这种限制对服务器来说是不可接受的。 虽然可以通过一定的技术手段强行扩大或缩小标准分区，但很容易造成数据丢失。 LVM 可以很好地解决这个问题。 LVM 从 Linux 内核 2.4 版开始可用，其主要功能包括：

- 更灵活的磁盘容量；
- 在线数据移动；
- 磁盘工作在 _条带_ 模式；
- 镜像卷（重新复制）；
- 卷快照（*snapshot*）。

LVM 的原理非常简单：

- 在物理磁盘（或磁盘分区）和文件系统之间添加逻辑抽象层
- 将多个磁盘（或磁盘分区）合并为卷组（**VG**）
- 通过被称为逻辑卷（**LV**）的东西对它们执行底层磁盘管理操作。

**物理介质**：LVM的存储介质可以是整个硬盘、磁盘分区或 RAID 阵列。 在执行进一步操作之前，必须将设备转换或初始化为 LVM 物理卷（**PV**）。

**PV（物理卷）**：LVM 的基本存储逻辑块。 要创建物理卷，可以使用磁盘分区或磁盘本身。

**VG（卷组）**：与标准分区中的物理磁盘类似，由一个或多个 PV 组成。

**LV（逻辑卷）**：与标准分区中的硬盘分区类似，LV 构建在 VG 之上。 您可以在 LV 上设置文件系统。

<b><font color="blue">PE</font></b>：PV 中可分配的最小存储单元，默认为 <b>4MB</b>。 您可以指定其他大小。

<b><font color="blue">LE</font></b>：LV 中可以分配的最小存储单元。 在相同的 VG 中，PE 和 LE 是相同的且一一对应。

![卷组，PE 大小等于 4MB](images/07-file-systems-004.png)

LVM 的缺点——如果其中一个物理卷出现故障，则使用该物理卷的所有逻辑卷都会丢失。 因此，您必须在 RAID 磁盘上使用 LVM 。

!!! note "说明"

    LVM 仅由操作系统管理。 因此，*BIOS* 至少需要一个没有 LVM 的分区才能启动。

!!! info "信息"

    在物理磁盘中，最小的存储单元是 **扇区** ；在文件系统中，GNU/Linux 最小的存储单元是 **block**，在 Windows 操作系统中称为 **cluster**。 在 RAID 中，最小的存储单元是 **chunk**。

### LVM 的写入机制

将数据存储到 **LV** 时有几种存储机制，其中两种是：

- 线性卷；
- _条带_ 模式的卷；
- 镜像卷。

![线性卷](images/07-file-systems-005.png)

![条带模式下的卷](images/07-file-systems-006.png)

### 用于卷管理的 LVM 相关命令

主要相关命令如下：

|  项   |    PV     |    VG     |    LV     |
|:----:|:---------:|:---------:|:---------:|
|  扫描  |  pvscan   |  vgscan   |  lvscan   |
|  创建  | pvcreate  |  vgcred   | lvcreate  |
|  显示  | pvdisplay | vgdisplay | lvdisplay |
|  移除  | pvremove  | vgremove  | lvremove  |
|  扩展  |           | vgextend  | lvextend  |
|  缩小  |           | vgreduce  | lvreduce  |
| 摘要信息 |    pvs    |    vgs    |    lvs    |

#### `pvcreate` 命令

`pvcreate` 命令用来创建物理卷。 它将 Linux 分区（或磁盘）转换为物理卷。

```bash
pvcreate [-options] partition
```

示例：

```bash
[root]# pvcreate /dev/hdb1
pvcreate -- physical volume « /dev/hdb1 » successfully created
```

您也可以使用整个磁盘（例如，这有利于在虚拟环境中增加磁盘大小）。

```bash
[root]# pvcreate /dev/hdb
pvcreate -- physical volume « /dev/hdb » successfully created

# 它也可以使用用其他方式书写，例如
[root]# pvcreate /dev/sd{b,c,d}1
[root]# pvcreate /dev/sd[b-d]1
```

| 选项   | 说明                          |
| ---- | --------------------------- |
| `-f` | 强制创建卷（磁盘已转化为物理卷）。 使用时要极其谨慎。 |

#### `vgcreate` 命令

`vgcreate` 命令用于创建卷组。 它将一个或多个物理卷归入一个卷组。

```bash
vgcreate  <VG_name>  <PV_name...>  [option]
```

示例：

```bash
[root]# vgcreate volume1 /dev/hdb1
…
vgcreate – volume group « volume1 » successfully created and activated

[root]# vgcreate vg01 /dev/sd{b,c,d}1
[root]# vgcreate vg02 /dev/sd[b-d]1
```

#### `lvcreate` 命令

`lvcreate` 用来创建逻辑卷。 然后在这些逻辑卷上创建文件系统。

```bash
lvcreate -L size [-n name] VG_name
```

示例：

```bash
[root]# lvcreate –L 600M –n VolLog1 volume1
lvcreate -- logical volume « /dev/volume1/VolLog1 » successfully created
```

| 选项           | 说明                                             |
| ------------ | ---------------------------------------------- |
| `-L size`    | 以K、M 或 G 为单位设置逻辑卷大小。                           |
| `-n name`    | 设置 LV 的名称。 在 `/dev/name_volume` 中使用此名称创建的特殊文件。 |
| `-l  number` | 设置要使用的硬盘容量的百分比。 您还可以使用 PE 的数量。 一个 PE 等于 4MB。   |

!!! info "信息"

    使用 `lvcreate` 命令创建逻辑卷后，操作系统的命名规则为 - `/dev/VG_name/LV_name`，此文件类型为软链接（也称为符号链接）。 链接文件指向 `/dev/dm-0` 和 `/dev/dm-1` 等文件。

### 用于查看卷信息的 LVM 命令

#### `pvdisplay` 命令

`pvdisplay` 命令允许您查看有关物理卷的信息。

```bash
pvdisplay /dev/PV_name
```

示例：

```bash
[root]# pvdisplay /dev/PV_name
```

#### `vgdisplay` 命令

`vgdisplay` 命令允许您查看有关卷组的信息。

```bash
vgdisplay VG_name
```

示例：

```bash
[root]# vgdisplay volume1
```

#### `lvdisplay` 命令

`lvdisplay` 命令允许您查看有关逻辑卷的信息。

```bash
lvdisplay /dev/VG_name/LV_name
```

示例：

```bash
[root]# lvdisplay /dev/volume1/VolLog1
```

### 物理介质的准备

物理支撑的 LVM 准备分为以下几个部分：

- 设置物理磁盘
- 卷的分区
- **LVM 物理卷**
- **LVM 卷组**
- **LVM 逻辑卷**
- 创建文件系统
- 挂载文件系统
- 管理用户访问

## 文件系统的结构

*文件系统* **FS** 负责以下操作：

- 确保对文件的访问权和修改权；
- 操作文件：创建、读取、修改和删除；
- 在磁盘上定位文件；
- 管理分区空间。

Linux 操作系统可以使用不同的文件系统（ext2、ext3、ext4、FAT16、FAT32、NTFS、HFS、BtrFS、JFS、XFS......）。

### `mkfs` 命令

`mkfs`（make file system） 命令用于创建 Linux 文件系统。

```bash
mkfs [-t fstype] filesys
```

示例：

```bash
[root]# mkfs -t ext4 /dev/sda1
```

| 选项   | 说明            |
| ---- | ------------- |
| `-t` | 指示要使用的文件系统类型。 |

!!! warning "警告"

    如果没有文件系统，就不可能使用磁盘空间。

每个文件系统的结构在每个分区上都是相同的。 **Boot Sector** 和 **Super block** 由系统初始化完成，**Inode table** 和 **Data block** 由管理员初始化完成。

!!! note "说明"

    唯一例外的是 **swap** 分区。

### Boot sector

Boot sector 是可引导存储介质的第一个扇区，即 0 柱面、0 磁道、1 扇区（1 扇区等于 512 字节）。 它由三个部分组成：

1. MBR（主引导记录）：446 字节。
2. DPT（磁盘分区表）：64 字节。
3. BRID（启动记录 ID）：2 字节。

| 项    | 说明                                                                    |
| ---- | --------------------------------------------------------------------- |
| MBR  | 存储 "引导加载程序"（或 ”GRUB"）；加载内核并传递参数；在启动时提供一个菜单界面；转移到另一个加载程序，例如在安装多个操作系统时。 |
| DPT  | 记录整个磁盘的分区状态。                                                          |
| BRID | 确定设备是否可用于引导。                                                          |

### Super block

**Super block** 表的大小在创建时定义。 它存在于每个分区上，并包含使用它所必需的元素。

它描述了文件系统：

- 逻辑卷的名称；
- 文件系统的名称；
- 文件系统的类型；
- 文件系统状态；
- 文件系统大小；
- 空闲 block 的数量；
- 指向空闲 block 列表开头的指针；
- inode 列表的大小；
- 空闲 inodes 的数量和列表。

系统一经初始化，就会在中央内存中加载一份副本。 此副本在修改后立即更新，系统会定期保存（`sync` 命令）。

当系统停止时，它也将内存中的该表复制到它的 block 中。

### inode 表

**inode table** 的大小在创建时定义，并存储在分区中。 它由称为 inode 的记录组成，这些记录与创建的文件相对应。 每条记录都包含组成文件的 data block 的地址。

!!! note "说明"

    inode 编号在文件系统中是唯一的。

系统一经初始化，就会在中央内存中加载一份副本。 此副本在修改后立即更新，系统会定期保存（`sync` 命令）。

当系统停止时，它也将内存中的该表复制到它的 block 中。

文件由其 inode 编号管理。

!!! note "说明"

    inode table 的大小决定了 FS 可以包含的最大文件数量。

<em x-id=“3”>inode table</em> 中存在的信息：

- Inode 编号；
- 文件类型和访问权限；
- 所有者的标识号；
- 所属组的标识号；
- 此文件上的链接数；
- 文件大小（以字节为单位）；
- 文件最后被访问的日期；
- 文件最后被修改的日期；
- 最后一次修改 inode 的日期（等于文件的创建时间）；
- 指向包含文件片段的逻辑块的多个指针表（block 表）。

### Data block

它的大小对应于分区的剩余可用空间。 该区域包含与每个目录相对应的目录和与文件内容相对应的 data block 。

**为了确保文件系统的一致性**，在加载操作系统时，会将 superblock 和 inode table 的镜像加载到内存（RAM）中，以便通过这些系统表完成所有的 I/O操作。 当用户创建或修改文件时，此内存镜像会首先更新。 因此，操作系统必须定期更新逻辑磁盘的 superblock（`sync` 命令）。

这些表在系统关闭时会写入到硬盘。

!!! danger "注意"

    如果操作系统突然停止，文件系统可能会失去一致性并导致数据丢失。

### 修复文件系统

可以使用 `fsck` 命令检查文件系统的一致性。

如果出现错误，则会提出解决方案来解决不一致问题。 修复之后，inode 表中没有条目的文件将附加到逻辑驱动器的 `/lost+found` 文件夹中。

#### `fsck` 命令

`fsck` 命令是用来检查和修复 Linux 文件系统完整性的工具。

```bash
fsck [-sACVRTNP] [ -t fstype ] filesys
```

示例：

```bash
[root]# fsck /dev/sda1
```

要检查根分区，可以创建一个 `forcefsck` 文件，然后使用 `-F` 选项重新启动或运行 `shutdown`。

```bash
[root]# touch /forcefsck
[root]# reboot
or
[root]# shutdown –r -F now
```

!!! warning "警告"

    要检查的分区必须未挂载。

## 文件系统的组织

根据定义，文件系统是从根目录构建的目录树结构（一个逻辑设备只能包含一个文件系统）。

![文件系统的组织](images/07-file-systems-008.png)

!!! note "说明"

    在 Linux 中，一切都是一个文件。

文本文档、目录、二进制、分区、网络资源、屏幕、键盘、Unix内核、用户程序...

Linux 符合 **FHS**（_Filesystems Hierarchy Standard_）(参阅 `man hier`)，该标准定义了文件夹的名称及其角色。

| 目录         | 功能                                 | 完整单词                          |
| ---------- | ---------------------------------- | ----------------------------- |
| `/`        | 包含特殊目录                             |                               |
| `/boot`    | 与操作系统启动相关的文件                       |                               |
| `/sbin`    | 系统启动和修复所需的命令                       | *system binaries*             |
| `/bin`     | 基本系统命令的可执行文件                       | *binaries*                    |
| `/usr/bin` | 系统管理命令                             |                               |
| `/lib`     | 共享库和内核模块                           | *libraries*                   |
| `/usr`     | 保存与 UNIX 相关的数据资源                   | *UNIX System Resources*       |
| `/mnt`     | 临时装载点目录                            | *mount*                       |
| `/media`   | 用于挂载可移动介质                          |                               |
| `/misc`    | 用于挂载 NFS 服务的共享目录。                  |                               |
| `/root`    | 管理员的登录目录                           |                               |
| `/home`    | 普通用户主目录的上级目录                       |                               |
| `/tmp`     | 包含临时文件的目录                          | *temporary*                   |
| `/dev`     | 特殊的设备文件                            | *device*                      |
| `/etc`     | 配置和脚本文件                            | *editable text configuration* |
| `/opt`     | 专用于已安装的应用程序                        | *optional*                    |
| `/proc`    | 这是 proc 文件系统的挂载点，提供有关正在运行的进程和内核的信息 | *processes*                   |
| `/var`     | 此目录包含大小可能改变的文件，如后台打印文件和日志文件        | *variables*                   |
| `/sys`     | 虚拟文件系统，类似于 /proc                   |                               |
| `/run`     | 这是 /var/run                        |                               |
| `/srv`     | 服务数据目录                             | *service*                     |

- 要在树级执行挂载或卸载，您不能位于其挂载点之下。
- 在非空目录上挂载不会删除内容。 它只是被隐藏了。
- 只有管理员可以执行挂载操作。
- 要在启动时自动挂载挂载点，必须写入到 `/etc/fstab` 文件中。

### `/etc/fstab` 文件

`/etc/fstab` 文件是在随系统启动时被读取的，其中包含要执行的挂载。 每个要挂载的文件系统都在一行上说明，字段由空格或制表符分隔。

!!! note "说明"

    相关的命令按照顺序读取行（如 `fsck`、`mount`、`umount`）。

```bash
/dev/mapper/VolGroup-lv_root   /         ext4    defaults        1   1
UUID=46….92                    /boot     ext4    defaults        1   2
/dev/mapper/VolGroup-lv_swap   swap      swap    defaults        0   0
tmpfs                          /dev/shm  tmpfs   defaults        0   0
devpts                         /dev/pts  devpts  gid=5,mode=620  0   0
sysfs                          /sys      sysfs   defaults        0   0
proc                           /proc     proc    defaults        0   0
  1                              2         3        4            5   6
```

| 列 | 说明                                                                       |
| - | ------------------------------------------------------------------------ |
| 1 | 文件系统设备（如 `/dev/sda1`、UUID=... 等）                                         |
| 2 | 使用 **绝对路径** 表示的挂载点名称（**swap** 除外）                                        |
| 3 | 文件系统类型（如 ext4、swap等）                                                     |
| 4 | 挂载时的特殊选项（如 `defaults`、`ro`等）                                             |
| 5 | 启用或禁用备份管理（0：未备份，1：已备份)。 这里使用 `dump` 命令进行备份。 这是一个过时的功能，最初设计用于备份磁带上的旧文件系统。 |
| 6 | 使用 `fsck` 命令检查 FS 时的检查顺序（0：不检查，1：优先，2：非优先）                               |

`mount -a` 命令允许您根据配置文件 `/etc/fstab` 的内容自动挂载。 之后便将挂载的信息写入到 `/etc/mtab` 。

!!! Wanning "警告"

    只有 `/etc/fstab` 中列出的挂载点才会在重启时挂载。 一般来说，我们不建议将 U 盘和移动硬盘写入到 `/etc/fsta` 文件中，因为当外部设备拔下并重启操作系统时，操作系统会提示找不到该设备，从而导致无法正常启动。 那我该怎么做呢？ 临时挂载，例如：

    ```bash
    Shell > mkdir /mnt/usb     
    Shell > mount -t  vfat  /dev/sdb1  /mnt/usb  

    # 读取U盘信息
    Shell > cd /mnt/usb/

    # 不需要时，执行以下命令并拔出 USB 闪存盘
    Shell > umount /mnt/usb
    ```

!!! info "信息"

    可以制作一个 `/etc/mtab` 文件的副本，或将它的内容复制到 `/etc/fstab` 中。
    如果您想查看设备分区号的UUID，可以输入以下命令：`lsblk -o name,uuid`。 UUID 是 `Universally Unique Identifier` 的缩写。

### 挂载管理命令

#### `mount` 命令

`mount` 命令允许您挂载和查看树中的逻辑驱动器。

```bash
mount [-option] [device] [directory]
```

示例：

```bash
[root]# mount /dev/sda7 /home
```

| 选项        | 说明                                   |
| --------- | ------------------------------------ |
| `-n`      | 挂载时不写入到 `/etc/mtab`。                 |
| `-t`      | 指示要使用的文件系统类型。                        |
| `-a`      | 挂载 `/etc/fstab` 中提到的所有文件系统。          |
| `-r`      | 将文件系统挂载为只读（等同于 `-o ro`）。             |
| `-w`      | 默认情况下以读/写方式挂载文件系统（等同于 `-o rw`）       |
| `-o opts` | opts 参数是逗号分隔的列表（如 `remount`、`ro` 等）。 |

!!! note "说明"

    仅使用 `mount` 命令即可显示所有已挂载的文件系统。 如果挂载参数为 `-o defaults` ，则表示等同于 ` -o rw,suid,dev,exec,auto,nouser,async`，且这些参数与文件系统无关。 如果您需要浏览与文件系统相关的特殊挂载选项，请阅读 `man 8 mount` 中的 "Mount options FS-TYPE" 部分（将 FS-TYPE 类型替换为相应的文件系统，如ntfs、vfat、ufs 等）。

#### `umount` 命令

`umount` 命令用于卸载逻辑驱动器。

```bash
umount [-option] [device] [directory]
```

示例：

```bash
[root]# umount /home
[root]# umount /dev/sda7
```

| 选项   | 说明                               |
| ---- | -------------------------------- |
| `-n` | 设置卸载时不写入到 `/etc/mtab` 文件。        |
| `-r` | 如果 `umount` 失败，重新挂载为只读。          |
| `-f` | 强制卸载。                            |
| `-a` | 删除 `/etc/fstab` 文件中提到的所有文件系统的挂载。 |

!!! note "说明"

    卸载时，您必须不能停留在挂载点中。 否则将显示以下错误消息：`device is busy`。

## 文件命名约定

与任何系统一样，为了能够在树结构和文件管理中方便找到文件，尊重文件的命名规则非常重要。

- 文件以 255 个字符编码；
- 可以使用所有 ASCII 字符；
- 区分大小写字母；
- 大多数文件没有文件扩展名的概念。 在 GNU/Linux 世界中，除了少数几个（例如 .jpg、.mp4、.gif 等）之外，大多数文件扩展名都是不需要的。

用空格分隔的单词组必须用引号括起来：

```bash
[root]# mkdir "working dir"
```

!!! note "说明"

    虽然在技术上创建包含空格的文件或目录并无不妥，但通常应该避免这种情况并用下划线替换任何空格是一种「最佳做法」。

!!! note "说明"

    以 **.** 开头的文件表示这是隐藏文件，它不能被简单的 `ls` 看到。

文件扩展名协议示例：

- `.c` : C 语言的源文件；
- `.h` : C 和 Fortran 的头文件；
- `.o` ：C 语言的对象文件；
- `.tar`：使用 `tar` 归档的数据文件；
- `.cpio` ：使用 `cpio` 归档的数据文件；
- `.gz` ：使用 `gzip` 压缩的数据文件；
- `.tgz`：使用 `tar` 归档并用 `gzip` 进行压缩的数据文件；
- `.html` ：web 页面

### 文件名的详细信息

```bash
[root]# ls -liah /usr/bin/passwd
266037 -rwsr-xr-x 1 root root 59K mars  22  2019 /usr/bin/passwd
1      2    3     4  5    6    7       8               9
```

| 部分  | 说明                                                                            |
| --- | ----------------------------------------------------------------------------- |
| `1` | Inode 号                                                                       |
| `2` | 文件系统（指 10 个字符块中的第一个字符），"-" 表示这是一个普通文件。                                        |
| `3` | 访问权限（10个字符中的最后9个字符）                                                           |
| `4` | 如果这是一个目录，这个数字表示该目录中有多少个子目录（包括隐藏的子目录）。 如果这是一个文件，则表示硬链接的数量。 当数字为 1 时，表示只有一个硬链接。 |
| `5` | 所有者的名称                                                                        |
| `6` | 所属组名称                                                                         |
| `7` | 文件大小（字节、千字节、兆字节）                                                              |
| `8` | 上次更新日期                                                                        |
| `9` | 文件名称                                                                          |

在 GNU/Linux 世界中，有七种文件类型：

| 文件类型  | 描述                                                                              |
|:-----:| ------------------------------------------------------------------------------- |
| **-** | 表示普通文件。 包括纯文本文件（ASCII）；二进制文件（binary）；数据格式文件（data）；各种压缩文件。                       |
| **d** | 表示目录文件。                                                                         |
| **b** | 表示块设备文件。 包括各种硬盘、USB 驱动器等。                                                       |
| **c** | 表示字符设备文件。 串口接口的设备，如鼠标、键盘等。                                                      |
| **s** | 表示套接字文件。 它是专门用于网络通信的文件。                                                         |
| **p** | 表示管道文件。 它是一种特殊的文件类型。 其主要目的是解决多个程序同时访问一个文件所引起的错误。 FIFO 是 first-in-first-out 的缩写。 |
| **l** | 表示软链接文件，也称为符号链接文件，类似于 Windows 中的快捷方式。 硬链接文件，也称为物理链接文件。                          |

#### 目录补充说明

在每个目录中都有两个隐藏文件： **.** 和 **..**。 你需要使用 `ls -al` 来查看，例如：

```bash
# . 表示在当前目录中，例如，您需要在某个目录中执行脚本，通常为：
Shell > ./scripts

# .. 表示当前目录的上一级目录，例如：
Shell > cd /etc/
Shell > cd ..
Shell > pwd
/

# 对于空目录，其第四部分必须大于或等于2。 因为其中有 "." 和 ".."
Shell > mkdir /tmp/t1
Shell > ls -ldi /tmp/t1
1179657 drwxr-xr-x 2 root root 4096 Nov 14 18:41 /tmp/t1
```

#### 特殊文件

为了与外围设备（硬盘、打印机等）通信，Linux 使用被称为特殊文件的接口文件（ (*device file* 或 *special file*）。 这些文件允许外设识别它们自己。

这些文件很特殊，因为它们并不存储数据，而是定义了与设备通信的访问模式。

它们以两种模式进行定义：

- **block** 模式；
- **character** 模式。

```bash
# 块设备文件
Shell > ls -l /dev/sda
brw-------   1   root  root  8, 0 jan 1 1970 /dev/sda

# 字符设备文件
Shell > ls -l /dev/tty0
crw-------   1   root  root  8, 0 jan 1 1970 /dev/tty0
```

#### 通信文件

这些是 *管道* 和 *套接字* 文件。

- **管道文件** 通过 FIFO（*First In, First Out*）机制在进程间传递信息。 一个进程将临时信息写入到 *管道* 文件，另一个进程随后读取该信息。 读取之后，该信息即不可再访问。

- **套接字文件** 允许在本地或远程系统上的双向进程间通信。 它们会占用文件系统的 *inode*。

#### 链接文件

这些文件允许为同一个物理文件提供多个逻辑名称，从而为该文件创建一个新的访问点。

链接文件有两种类型：

- 软链接文件，也称为符号链接文件；
- 硬链接文件，也称为物理链接文件。

主要特性为：

| 链接类型  | 说明                                                                                                                  |
| ----- | ------------------------------------------------------------------------------------------------------------------- |
| 软链接文件 | 此文件类似于 Windows 的快捷方式。 它具有 0777 权限并指向原始文件。 删除原始文件后，可以使用 `ls -l` 查看软链接文件的输出信息。 在输出信息中，软链接的文件名显示为红色，指向的原始文件显示为红色并闪烁提示。 |
| 硬链接文件 | 此文件表示占用相同 *inode* 编号的不同映射。 它们可以同步更新（包括文件内容、修改时间、所有者、所属组、访问时间等）。 硬链接文件不能跨越分区和文件系统，且不能在目录上使用。                         |

具体例子如下：

```bash
# 权限和他们指向的原始文件
Shell > ls -l /etc/rc.locol
lrwxrwxrwx 1 root root 13 Oct 25 15:41 /etc/rc.local -> rc.d/rc.local

# 删除原始文件时。 "-s" 表示软链接选项
Shell > touch /root/Afile
Shell > ln -s /root/Afile /root/slink1
Shell > rm -rf /root/Afile
```

![呈现效果](images/07-file-systems-019.png)

```bash
Shell > cd /home/paul/
Shell > ls –li letter
666 –rwxr--r-- 1 root root … letter

# ln 命令没有添加任何选项时表示硬链接
Shell > ln /home/paul/letter /home/jack/read

# 硬链接的本质是相同 inode 号在不同目录下的文件映射。
Shell > ls –li /home/*/*
666 –rwxr--r-- 2 root root … letter
666 –rwxr--r-- 2 root root … read

# 如果您使用一个硬链接到目录， 您将会被提示：
Shell > ln  /etc/  /root/etc_hardlink
ln: /etc: hard link not allowed for directory
```

## 文件属性

Linux 是一个多用户的操作系统，对访问文件的控制是必不可少的。

这些控制的功能如下：

- 文件访问权限；
- 用户 (*ugo* *Users Groups Others*)。

### 文件和目录的基本权限

**文件权限** 的描述如下：

| 文件权限 | 描述                                             |
|:----:| ---------------------------------------------- |
|  r   | 读取 允许读取文件 (`cat`、`less`, ...) 并复制文件 （`cp`...）。 |
|  w   | 写入。 允许修改文件内容（`cat`、`>>`、`vim`...）        |
|  x   | 执行。 将文件视为 **可执行** 文件（二进制或脚本）。                  |
|  -   | 无权限                                            |

**目录权限** 的描述如下：

| 目录权限 | 描述                                                          |
|:----:| ----------------------------------------------------------- |
|  r   | 读取 允许读取目录的内容（`ls -R`）。                                      |
|  w   | 写入。 允许您在此目录中创建和删除文件或目录，例如 `mkdir`、`rmdir`、`rm`、`touch` 等命令。 |
|  x   | 执行。 允许进入到目录（`cd`）。                                          |
|  -   | 无权限                                                         |

!!! info "信息"

    对于目录的权限而言，`r` 和 `x` 通常同时出现。 移动或重命名文件取决于文件所在的目录是否具有 `w` 权限，删除文件也是如此。

### 基本权限对应的用户类型

| 用户类型 | 说明   |
|:----:| ---- |
|  u   | 所有者  |
|  g   | 所属组  |
|  o   | 其他用户 |

!!! info "信息"

    在某些命令中，您可以使用 *a*（_all_）来表示 *ugo*。 例如：`chmod a+x FileName` 等同于 `chmod u+x,g+x,o+x FileName` 或 `chmod ugo+x FileName`。

### 属性管理

权限的显示是通过使用 `ls -l` 命令来完成的。 这是10个字符块的最后9个字符。 更确切地说，是3乘3个字符。

```bash
[root]# ls -l /tmp/myfile
-rwxrw-r-x  1  root  sys  ... /tmp/myfile
  1  2  3       4     5
```

| 部分 | 说明                      |
| -- | ----------------------- |
| 1  | 这里所有者（**u**）的权限为 `rwx`  |
| 2  | 这里所属组（**g**）的权限为 `rw-`  |
| 3  | 这里其他用户（**o**）的权限为 `r-x` |
| 4  | 文件所有者                   |
| 5  | 文件所属组                   |

默认情况下，文件的 *所有者* 是创建它的人。 文件的 *组* 是创建该文件的所有者的组。 *其他人* 则是不关心之前案例的人。

可使用 `chmod` 命令更改属性。

只有管理员和文件的所有者可以更改文件的权限。

#### `chmod` 命令

`chmod` 命令允许您更改文件的访问权限。

```bash
chmod [option] mode file
```

| 选项   | 说明                 |
| ---- | ------------------ |
| `-R` | 递归更改目录和目录下所有文件的权限。 |

!!! warning "警告"

    文件和目录的权限未被分离。 对于某些操作，需要了解包含文件的目录权限。 受写保护的文件可以被其他用户删除，只要包含该文件的目录权限允许该用户执行此操作。

Mode 指示可以用八进制表示（例如 `744`）或符号表示（[`ugoa`] [`+=-`] [`rwxst`]）。

##### 八进制（或数字）表示法：

| 数字 | 说明 |
|:--:| -- |
| 4  | r  |
| 2  | w  |
| 1  | x  |
| 0  | -  |

将这三个数字加在一起即可获得一个用户类型的权限。 例如： **755=rwxr-xr-x**。

![八进制表示](images/07-file-systems-011.png)

![777权限](images/07-file-systems-012.png)

![741权限](images/07-file-systems-013.png)

!!! info "信息"

    有时候你会看到 `chmod 4755`。 数字4是指特殊权限 **set uid** 。 特殊权限暂时不会在这里细谈，只作为基本的了解。

```bash
[root]# ls -l /tmp/fil*
-rwxrwx--- 1 root root … /tmp/file1
-rwx--x--- 1 root root … /tmp/file2
-rwx--xr-- 1 root root … /tmp/file3

[root]# chmod 741 /tmp/file1
[root]# chmod -R 744 /tmp/file2
[root]# ls -l /tmp/fic*
-rwxr----x 1 root root … /tmp/file1
-rwxr--r-- 1 root root … /tmp/file2
```

##### 符号表示法

此方法可以被视为用户类型、运算符和权限之间的「字面意思上的」关联。

![符号方法](images/07-file-systems-014.png)

```bash
[root]# chmod -R u+rwx,g+wx,o-r /tmp/file1
[root]# chmod g=x,o-r /tmp/file2
[root]# chmod -R o=r /tmp/file3
```

## 默认权限和掩码

当创建一个文件或目录时，它已经拥有权限。

- 对于目录：`rwxr-xr-x` 或 *755*。
- 对于文件：`rw-r-r-` 或 *644*。

此行为由 **默认掩码** 定义。

其本质是在没有执行权限的情况下以最大权限删除掩码所定义的值。

对于目录：

![SUID 如何工作](images/07-file-systems-017.png)

对于文件，执行权限将被删除：

![文件的默认权限](images/07-file-systems-018.png)

!!! info "信息"

    `/etc/login.defs` 文件定义了默认 UMASK，其值为 **022**。 这意味着创建文件的权限是 755 (rwxr-xr-x)。 但是，为了安全起见，GNU/Linux 针对新创建的文件并没有 **x** 权限。 这一限制适用于 root(uid=0) 和 普通用户(uid&#062;=1000) 。

    ```bash
    # root 用户
    Shell > touch a.txt
    Shell > ll
    -rw-r--r-- 1 root root     0 Oct  8 13:00 a.txt
    ```

### `umask` 命令

`umask` 命令允许您显示和修改掩码。

```bash
umask [option] [mode]
```

示例：

```bash
$ umask 033
$ umask
0033
$ umask -S
u=rwx,g=r,o=r
$ touch umask_033
$ ls -la  umask_033
-rw-r--r-- 1 rockstar rockstar 0 nov.   4 16:44 umask_033
$ umask 025
$ umask -S
u=rwx,g=rx,o=w
$ touch umask_025
$ ls -la  umask_025
-rw-r---w- 1 rockstar rockstar 0 nov.   4 16:44 umask_025
```

| 选项   | 说明          |
| ---- | ----------- |
| `-S` | 用符号显示的文件权限。 |

!!! warning "警告"

    `umask` 并不会影响现有文件。 `umask -S` 显示将要创建文件的文件权限（没有执行权限）。 所以，它不是用减去最大值的掩码来显示的。

!!! note "说明"

    在上面的示例中，使用命令修改掩码仅适用于当前连接的会话。

!!! info "信息"

    `umask` 命令属于 bash 的内置命令，因此当你使用 `man umask` 时，所有内置命令都将被显示。 如果你只想查看 `umask` 的帮助，你需要使用 `help umask` 命令。

要保留该值，您必须修改以下配置文件：

对于所有用户：

- `/etc/profile`
- `/etc/bashrc`

对于特定用户：

- `~/.bashrc`

当编写上述文件时，它实际上是覆盖了 `/etc/login.defs` 的 **UMASK** 参数。 如果你想要提高操作系统的安全性，你可以设置 umask 为 **027** 或 **077**。
