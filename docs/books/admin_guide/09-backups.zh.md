---
title: 备份和还原
---

# 备份和还原

在本章中，您将学习如何使用 Linux 备份和还原您的数据。

****

**目标**: 在本章中，未来的 Linux 管理员们将学习如何：

:heavy_check_mark: 使用 `tar` 和 `cpio` 命令进行备份；  
:heavy_check_mark: 检查他们的备份并恢复数据。  
:heavy_check_mark: 压缩或解压他们的备份。

:checkered_flag: **备份**, **恢复**, **压缩**

**知识性**: :star: :star: :star:  
**复杂性**: :star: :star:

**阅读时间**: 40 分钟

****

!!! Note "说明"

    在本章中，命令结构通过使用 "device" 来指定备份的目标位置以及还原时的源位置。 该设备可以是外部介质，也可以是本地文件。 随着本章的展开，你应该对这一点有所了解，但如果你需要的话，可以随时参考这篇笔记以获得解释。

备份满足了以确切且有效的方式保存和恢复数据的需求。

备份使您可以保护自己免受以下情况的影响：

* **数据破坏**：自愿或非自愿的。 人为的或技术手段的。 病毒等
* **数据删除**：自愿或非自愿的。 人为的或技术手段的。 病毒等
* **完整性**：数据变得不可用。

没有系统是绝对可靠的，也没有人是万无一失的，所以为了避免丢失数据，必须对数据进行备份，以便在出现问题后能够恢复。

备份介质应该保存在服务器以外的另一个房间（或建筑物）中，这样灾难就不会破坏服务器和备份。

此外，管理员必须定期检查介质是否仍可读。

## 概论

有两个规范，即 **备份** 和 **归档**。

* 存档会在操作后销毁信息源。
* 备份会在操作后保留信息源。

这些操作包括将信息保存到文件、外设或支持的介质（磁带、磁盘等）中。

### 流程

备份需要系统管理员严格遵守规定。 系统管理员在执行备份操作之前需要考虑以下问题：

* 合适的媒介是什么？
* 应该备份什么？
* 有多少份？
* 备份需要多长时间？
* 方法？
* 多久一次？
* 自动或手动？
* 存储在哪里？
* 要保存多久？
* 是否有成本问题需要考虑？

除了这些问题外，系统管理员还应该根据实际情况考虑性能、数据重要性、带宽消耗和维护复杂性等因素。

### 备份方法

* **全量备份**：指把硬盘或数据库内的所有文件、文件夹或数据作一次性的复制。
* **增量备份**：指对上一次全量备份或增量备份后更新的数据进行备份。
* **差异备份** ：指全量备份后兑变更文件的备份。
* **选择性备份（部分备份）**：指备份系统的一部分。
* **冷备份**：指系统处于关闭或维护状态时的备份。  备份的数据与该时间段内系统的数据完全一致。
* **热备份**： 指系统正常运行时的备份。  由于系统中的数据随时在更新，备份的数据相对于系统的实际数据有一定的滞后性。
* **异地备份**：指将数据备份到另一个地理位置，以避免因火灾、自然灾害、盗窃等造成的数据丢失和服务中断。

### 备份频率

* **定期**：在主要系统更新之前的特定时间段内进行备份（通常在非高峰时段）
* **循环**：以天、周、月等为单位进行备份

!!! Tip "小提示"

    在系统更改之前，进行备份可能很有用。 然而，每天备份每月都会变更的数据是没有意义的。

### 恢复方法

根据可用的实用程序，可以进行几种类型的恢复。

在某些关系数据库管理系统中，"recover"（有时在文档中使用 "recovery" ）和 "restore" 的相应操作是不同的，这要求您查阅官方文档以获取更多信息。 有关更多信息，请参阅官方文档。 本基础文档不会详细介绍 RDBMS 的这一部分。

* **完全恢复**：数据恢复基于全量备份或 "全量备份+增量备份" 或 "全量备份+差异备份" 。
* **选择性恢复**：数据恢复基于选择性备份（部分备份）。

我们不建议在执行恢复操作之前直接删除当前活动操作系统中的目录或文件（除非您知道删除后会发生什么）。 如果你不知道会发生什么，你可以在当前操作系统上执行 "快照" 操作。

!!! Tip "小提示"

    出于安全原因，建议您在执行恢复操作之前将还原的目录或文件存储在 /tmp 目录中，以避免旧文件（旧目录）覆盖新文件（新目录）的情况。

### 工具与相关技术

有许多实用程序可以进行备份。

* **编辑器工具**;
* **图形工具**;
* **命令行工具**：`tar`、`cpio`、`pax`、`dd`、`dump` 等

我们在这里使用的命令是 `tar` 和 `cpio` 。 如果您想了解 `dump` 工具，请参阅 [本文档](../../guides/backup/dump_restore.md)。

* `tar`：

  1. 易于使用；
  2. 允许将文件添加到现有备份中。

* `cpio`：

  1. 保留所有者；
  2. 保留所有组、日期和权限。
  3. 跳过损坏的文件；
  4. 可对整个文件系统使用。

!!! Note "说明"

    这些命令以专有的和标准化的格式保存。

**Replication**：一种将一组数据从一个数据源复制到另外一个或多个数据源的备份技术，主要分为 **同步复制** 和 **异步复制** 。 这是面向新手系统管理员的高级备份部分，因此这份基础文档不会详述这些内容。

### 命名惯例

使用命名约定可以让人们迅速定位备份文件的内容，从而避免危险的恢复操作。

* 目录名称；
* 所使用的实用工具；
* 所使用的选项；
* 日期。

!!! Tip "小提示"

    备份的名称必须是一目了然的。

!!! Note "说明"

    在 Linux 系统中，除了图形用户界面（GUI）环境中的少数例外情况（如 .jpg、.mp4、.gif）外，大多数文件都没有扩展名的概念。 换句话说，大多数文件不需要扩展名。 人为添加后缀的原因是为了方便人类用户识别。 例如，如果系统管理员看到 `.tar.gz` 或 `.tgz` 文件扩展名，那么他就知道如何处理该文件。

### 备份文件属性

单个备份文件可以包含以下属性：

* 文件名（包括手动添加的后缀）；
* 备份文件本身的 atime、ctime、mtime、btime (crtime)；
* 备份文件本身的文件大小；
* 备份文件中的文件或目录的属性或特征将被部分保留。 例如，保留文件或目录的 mtime，但不保留 `inode` 号。

### 存储方法

有两种不同的存储方法：

* 内部：将备份文件存储在当前工作磁盘上。
* 外部：将备份文件存储在外部设备上。 外部设备可以是 USB 驱动器、CD、磁盘、服务器或 NAS 等。

## 磁带归档 - `tar`

`tar` 命令允许在多个连续介质上保存（multi-volume 选项）。

可以提取全部或部分备份。

即使以绝对模式提到要备份的信息的路径，`tar` 也会隐式地以相对模式备份。 但是，可以在绝对模式下进行备份和恢复。 如果您想查看 `tar` 用法的单独示例，请参阅 [本文档](../../guides/backup/tar.md)。

### 恢复指南

要提出的正确问题是：

* 什么：部分或全部；
* 哪里：数据将被恢复的地方；
* 方式：绝对或相对。

!!! warning "警告"

    在恢复之前，重要的是要考虑并确定最合适的方法来避免错误。

恢复通常是在出现需要迅速解决的问题后进行的。 在某些情况下，糟糕的恢复会使情况变得更糟。

### 用 `tar` 备份

用于在 UNIX 系统上创建备份的默认实用程序是 `tar` 命令。 这些备份可以通过 `bzip2`、`xz`、`lzip`、`lzma`、`lzop`、`gzip`、`compress` 或 `zstd` 进行压缩。

`tar` 允许您从备份中提取单个文件或目录，查看其内容或验证其完整性。

#### 估计备份的大小

以下的命令是估计一个可能的 *tar* 文件大小（以字节为单位）：

```bash
$ tar cf - /directory/to/backup/ | wc -c
20480
$ tar czf - /directory/to/backup/ | wc -c
508
$ tar cjf - /directory/to/backup/ | wc -c
428
```

!!! warning "警告"

    请注意，命令行中的 "-" 会干扰 `zsh` 。 请切换到 `bash` ！

#### `tar` 备份的命名惯例

这是一个 `tar` 备份命名惯例的示例，必要时请将日期添加到名称中。

| 键       | 文件      | 后缀名              | 功能                           |
| ------- | ------- | ---------------- | ---------------------------- |
| `cvf`   | `home`  | `home.tar`       | `/home` 在相对模式下，未压缩的形式        |
| `cvfP`  | `/etc`  | `etc.A.tar`      | `/etc` 在绝对模式下，没有压缩           |
| `cvfz`  | `usr`   | `usr.tar.gz`     | `/usr` 在相对模式下， 使用 *gzip* 压缩  |
| `cvfj`  | `usr`   | `usr.tar.bz2`    | `/usr` 在相对模式下，使用 *bzip2* 压缩  |
| `cvfPz` | `/home` | `home.A.tar.gz`  | `/home` 在绝对模式下，使用 *gzip* 压缩  |
| `cvfPj` | `/home` | `home.A.tar.bz2` | `/home` 在绝对模式下，使用 *bzip2* 压缩 |
| …       |         |                  |                              |

#### 创建备份

##### 在相对模式下创建备份

使用 `cvf` 键以相对模式创建非压缩备份：

```bash
tar c[vf] [device] [file(s)]
```

示例：

```bash
[root]# tar cvf /backups/home.133.tar /home/
```

| 键   | 说明              |
| --- | --------------- |
| `c` | 创建备份。           |
| `v` | 显示已处理文件的名称。     |
| `f` | 允许您指定备份（介质）的名称。 |

!!! Tip "小提示"

    `tar` 键前的连字符（`-`）是可选的！

##### 在绝对模式下创建备份

使用 `cvfP` 键在绝对模式下显式创建非压缩备份：

```bash
tar c[vf]P [device] [file(s)]
```

示例：

```bash
[root]# tar cvfP /backups/home.133.P.tar /home/
```

| 键   | 说明          |
| --- | ----------- |
| `P` | 在绝对模式下创建备份。 |

!!! warning "警告"

    使用 `P` 键，需要备份的文件路径必须以 **绝对** 的形式输入。 如果未指示这两个条件（`P` 键和 **绝对** 路径），则备份处于相对模式。

##### 使用 `gzip` 创建压缩备份

使用 `cvfz `键创建 `gzip` 压缩备份：

```bash
tar cvzf backup.tar.gz dirname/
```

| 键   | 说明             |
| --- | -------------- |
| `z` | 用 *gzip* 压缩备份。 |

!!! Note "说明"

    `.tgz` 扩展名等效于 `.tar.gz`。

!!! Note "说明"

    对于所有备份操作，保持 `cvf`（`tvf` 或 `xvf`）键不变，只需在键的末尾添加压缩键，即可使命令更容易理解（例如：`cvfz` 或 `cvfj` 等）。

##### 使用 `bzip2` 创建压缩备份

使用 `bzip2` 创建压缩备份是通过 `cvfj` 键完成的：

```bash
tar cvfj backup.tar.bz2 dirname/
```

| 键   | 说明              |
| --- | --------------- |
| `j` | 用 *bzip2* 压缩备份。 |

!!! Note "说明"

    `.tbz` 和 `.tb2` 扩展名等同于 `.tar.bz2` 扩展名。

##### 压缩效率比较

压缩和随后的解压缩将影响资源消耗（时间和 CPU 使用率）。

下面是一组文本文件的压缩效率从低到高的排序：

* compress （`.tar.Z`）
* gzip（`.tar.gz`）
* bzip2（`.tar.bz2`）
* lzip（`.tar.lz`）
* xz（`.tar.xz`）

#### 将文件或目录添加到现有备份

可以向现有备份添加一个或多个项目。

```bash
tar {r|A}[key(s)] [device] [file(s)]
```

将 `/etc/passwd` 添加到 `/backups/home.133.tar` 备份中：

```bash
[root]# tar rvf /backups/home.133.tar /etc/passwd
```

添加目录与此类似。 在这里，将 `dirtoadd` 添加到 `backup_name.tar` ：

```bash
tar rvf backup_name.tar dirtoadd
```

| 键   | 说明                      |
| --- | ----------------------- |
| `r` | 将文件或目录追加到归档的末尾。         |
| `A` | 将一个归档中的所有文件追加到另一个归档的末尾。 |

!!! Note "说明"

    无法将文件或文件夹添加到压缩备份中。

    ```
    $ tar rvfz backup.tgz filetoadd
    tar: Cannot update compressed archives
    Try `tar --help' or `tar --usage' for more information.
    ```

!!! Note "说明"

    如果备份是在相对模式下执行的，请以相对模式添加文件。 如果备份是以绝对模式完成的，请以绝对模式添加文件。
    
    恢复时，混合模式可能会导致问题。

#### 列出备份的内容

可以在不提取备份的情况下查看备份内容。

```bash
tar t[key(s)] [device]
```

| 键   | 说明               |
| --- | ---------------- |
| `t` | 显示备份的内容（无论是否压缩）。 |

示例：

```bash
tar tvf backup.tar
tar tvfz backup.tar.gz
tar tvfj backup.tar.bz2
```

当备份中的文件数量增加时，您可以使用管道符（`|`）和一些命令（`less`、`more`、`most` 以及其他）来实现分页查看的效果：

```bash
tar tvf backup.tar | less
```

!!! Tip "小提示"

    要列出或检索备份的内容，不必提及创建备份时使用的压缩算法。 也就是说，读取内容时，`tar tvf` 等同于 `tar tvfj`。 仅在创建压缩备份时才 **必须** 选择压缩类型或算法。

!!! Tip "小提示"

    在执行还原操作之前，您应该始终检查和查看备份文件的内容。

#### 检查备份的完整性

备份的完整性可以在创建时使用 `W` 键进行测试：

```bash
tar cvfW file_name.tar dir/
```

备份创建后，可以使用 `d` 键测试备份的完整性：

```bash
tar vfd file_name.tar dir/
```

!!! Tip "小提示"

    通过在前一个键中添加第二个 `v`，您将得到归档文件的列表以及归档文件与文件系统中已存在文件之间的差异。

    ```
    $ tar vvfd  /tmp/quodlibet.tar .quodlibet/
    drwxr-x--- rockstar/rockstar     0 2021-05-21 00:11 .quodlibet/
    -rw-r--r-- rockstar/rockstar     0 2021-05-19 00:59 .quodlibet/queue
    […]
    -rw------- rockstar/rockstar  3323 2021-05-21 00:11 .quodlibet/config
    .quodlibet/config: Mod time differs
    .quodlibet/config: Size differs
    […]
    ```

`W` 键还用于将归档的内容与文件系统进行比较：

```bash
$ tar tvfW file_name.tar
Verify 1/file1
1/file1: Mod time differs
1/file1: Size differs
Verify 1/file2
Verify 1/file3
```

您无法使用 `W` 键验证压缩归档。 相反，您必须使用 `d` 键。

```bash
tar dfz file_name.tgz
tar dfj file_name.tar.bz2
```

#### 提取（*解压缩*）备份

使用 `xvf` 键提取（*解压缩*）`*.tar` 备份：

将 `/savings/etc.133.tar` 备份文件中的 `etc/exports` 文件提取到当前目录的 `etc` 目录中：

```bash
tar xvf /backups/etc.133.tar etc/exports
```

将压缩备份 `/backups/home.133.tar.bz2` 中的所有文件提取到当前目录中：

```bash
[root]# tar xvfj /backups/home.133.tar.bz2
```

将备份 `/backups/etc.133.P.tar` 中的所有文件提取到其原始目录：

```bash
tar xvfP /backups/etc.133.P.tar
```

!!! warning "警告"

    出于安全原因，提取以绝对模式保存的备份文件时应谨慎。
    
    同样，在执行提取操作之前，您应该始终检查备份文件的内容（尤其是以绝对模式保存的文件）。

| 键   | 说明                |
| --- | ----------------- |
| `x` | 从备份中提取文件（无论是否压缩）。 |

使用 `xvfz` 键提取 *tar-gzipped* （`*.tar.gz`）备份：

```bash
tar xvfz backup.tar.gz
```

使用 `xvfj` 键提取 *tar-bzipped* （`*.tar.bz2`）备份：

```bash
tar xvfj backup.tar.bz2
```

!!! Tip "小提示"

    要提取或列出备份的内容，不需要提及用于创建备份的压缩算法。 也就是说，`tar xvf` 相当于 `tar xvfj`，用于提取内容，`tar tvf` 相当于 `tar tvfj`，用于列出。

!!! warning "警告"

    要将文件恢复到原始目录（`tar xvf` 的 `P` 键），你必须使用绝对路径生成备份。 也就是说，使用 `tar cvf` 的 `P` 键。

##### 仅从 *tar* 备份中提取文件

要从 *tar* 备份中提取特定文件，请在 `tar xvf` 命令的末尾指定该文件的名称。

```bash
tar xvf backup.tar /path/to/file
```

前面的命令仅从 `backup.tar` 备份中提取 `/path/to/file`文件。 此文件将被还原到活动目录中已创建或已存在的 `/path/to/` 目录中。

```bash
tar xvfz backup.tar.gz /path/to/file
tar xvfj backup.tar.bz2 /path/to/file
```

##### 从备份 *tar* 中提取文件夹

要从备份中仅提取一个目录（包括其子目录和文件），请在 `tar xvf` 命令的结尾处指定目录名称。

```bash
tar xvf backup.tar /path/to/dir/
```

要提取多个目录，请依次指定每个目录的名称：

```bash
tar xvf backup.tar /path/to/dir1/ /path/to/dir2/
tar xvfz backup.tar.gz /path/to/dir1/ /path/to/dir2/
tar xvfj backup.tar.bz2 /path/to/dir1/ /path/to/dir2/
```

##### 使用通配符从 *tar* 备份中提取一组文件

指定通配符以提取与指定选择模式匹配的文件。

例如，要提取扩展名为 `.conf` 的所有文件：

```bash
tar xvf backup.tar --wildcards '*.conf'
```

键：

* __--wildcards *.conf__ 对应于扩展名为 `.conf` 的文件。

!!! tip "扩展知识"

    虽然通配符和正则表达式通常具有相同的符号或样式，但它们匹配的对象完全不同，因此人们经常混淆它们。
    
    **通配符**：用于匹配文件名或目录名。 
    **正则表达式**：用于匹配文件的内容。
    
    您可以在 [此文档](../sed_awk_grep/1_regular_expressions_vs_wildcards.md) 中看到更详细的介绍。

## *CoPy Input Output* - `cpio`

`cpio` 命令允许在不指定任何选项的情况下在多个连续介质上进行保存。

可以提取全部或部分备份。

与 `tar` 命令不同的是，它没有同时备份和压缩的选项。 因此，它分两步完成：备份和压缩。

`cpio` 拥有三种操作模式，每种模式对应着一种不同的功能：

1. **copy-out 模式** - 创建备份（归档）。 您可以通过 `-o` 或 `--create` 选项启用此模式。 在此模式中，您必须使用特定命令（`find`、`ls`或 `cat`）生成一个文件列表并将其传递给 cpio。

   * `find`：浏览树（无论是否递归）；
   * `ls`：列出一个目录（无论是否递归）；
   * `cat`：读取包含要保存的树或文件的文件。

    !!! Note "说明"

        `ls` 不能与 `-l`（细节）或 `-R`（递归）一起使用。

        它需要一个简单的名称列表。

2. **copy-in 模式** – 从归档中提取文件。 您可以通过 `-i` 选项启用此模式。
3. **copy-pass 模式** - 将文件从一个目录复制到另一个目录。 您可以通过 `-p` 或 `--pass-through` 选项启用此模式。

与 `tar` 命令一样，用户在创建归档时必须考虑文件列表的保存方式（**绝对路径** 或 **相对路径**）。

次要功能：

1. `-t` - 打印输入的内容表。
2. `-A` - 追加到现有归档。 仅工作在 copy-in 模式。

!!! Note "说明"

    `cpio` 的一些选项需要与正确的操作模式相结合才能正常工作。 参阅 `man 1 cpio`

### copy-out 模式

`cpio` 命令的语法：

```bash
[files command |] cpio {-o| --create} [-options] [< file-list] [> device]
```

示例：

使用 `cpio` 输出的重定向：

```bash
find /etc | cpio -ov > /backups/etc.cpio
```

使用备份介质名称：

```bash
find /etc | cpio -ovF /backups/etc.cpio
```

`find` 命令的结果作为输入通过 *管道*（字符 `|`, ++left-shift+backslash++）发送到 `cpio` 命令。

在这里，`find /etc` 命令向执行备份的 `cpio` 命令返回与 `/etc` 目录内容（递归）对应的文件列表。

保存时不要忘记 `>` 符号或 `F save_name_cpio`。

| 选项   | 说明                                          |
| ---- | ------------------------------------------- |
| `-o` | 使用 _cp-out_ 模式创建备份。                         |
| `-v` | 显示已处理文件的名称。                                 |
| `-F` | 备份到指定介质，可以替换 `cpio` 命令中的标准输入（"<"）和标准输出（">"） |

备份到介质：

```bash
find /etc | cpio -ov > /dev/rmt0
```

介质可以有多种类型：

* 磁带驱动器：`/dev/rmt0`；
* 一个分区：`/dev/sda5`、`/dev/hda5` 等。

#### 文件列表的相对和绝对路径

```bash
cd /
find etc | cpio -o > /backups/etc.cpio
```

```bash
find /etc | cpio -o > /backups/etc.A.cpio
```

!!! warning "警告"

    如果 `find` 命令中指定的路径是 **绝对**，则将在 **绝对** 路径中执行备份。
    
    如果 `find` 命令中指定的路径是 **相对**，则将在 **相对** 路径中执行备份。

#### 向现有备份追加文件

```bash
[files command |] cpio {-o| --create} -A [-options] [< fic-list] {F| > device}
```

示例：

```bash
find /etc/shadow | cpio -o -AF SystemFiles.A.cpio
```

只能在直接访问介质上添加文件。

| 选项   | 说明              |
| ---- | --------------- |
| `-A` | 向现有备份追加一个或多个文件。 |
| `-F` | 指定要修改的备份。       |

#### 压缩备份

* 保存 **然后** 压缩

```bash
$ find /etc | cpio  –o > etc.A.cpio
$ gzip /backups/etc.A.cpio
$ ls /backups/etc.A.cpio*
/backups/etc.A.cpio.gz
```

* 保存 **并** 压缩

```bash
find /etc | cpio –o | gzip > /backups/etc.A.cpio.gz
```

与 `tar` 命令不同的是没有同时保存和压缩的选项。 因此，它分两步完成：保存和压缩。

第一个方法的语法更容易理解和记忆，因为它分两步完成。

对于第一种方法，`gzip` 实用程序会自动重命名备份文件，并在文件名末尾添加 `.gz`。 同样，`bzip2` 实用程序会自动添加 `.bz2`。

### 读取备份的内容

读取 *cpio* 备份内容的 `cpio` 命令语法：

```bash
cpio -t [-options] [< fic-list]
```

示例：

```bash
cpio -tv < /backups/etc.152.cpio | less
```

| 选项   | 说明      |
| ---- | ------- |
| `-t` | 读取备份。   |
| `-v` | 显示文件属性。 |

备份之后，您需要读取其内容以确保没有错误。

同样，在执行恢复之前，必须读取将要使用的备份的内容。

### copy-in 模式

用于恢复备份的 `cpio` 命令语法：

```bash
cpio {-i| --extract} [-E file] [-options] [< device]
```

示例：

```bash
cpio -iv < /backups/etc.152.cpio | less
```

| 选项                          | 说明                 |
| --------------------------- | ------------------ |
| `-i`                        | 恢复完整的备份。           |
| `-E file`                   | 仅恢复文件名包含在文件中的文件。   |
| `--make-directories` 或 `-d` | 重建缺失的树结构。          |
| `-u`                        | 替换所有文件，即使它们存在。     |
| `--no-absolute-filenames`   | 允许以相对方式恢复绝对模式下的备份。 |

!!! warning "警告"

    默认情况下，在恢复时不恢复磁盘上最后修改日期较新或等于备份日期的文件（以避免用较旧的信息覆盖最近的信息）。
    
    另一方面，`u` 选项允许您恢复文件的旧版本。

示例：

* 绝对备份的绝对恢复

```bash
cpio –ivF home.A.cpio
```

* 对现有树结构进行绝对恢复

`u` 选项允许您覆盖恢复位置的现有文件。

```bash
cpio –iuvF home.A.cpio
```

* 以相对模式恢复绝对备份

长选项 `no-absolute-filename` 允许在相对模式下进行恢复。 实际上，路径开头的 `/` 将被删除。

```bash
cpio --no-absolute-filenames -divuF home.A.cpio
```

!!! Tip "小提示"

    创建目录可能是必要的，因此需要使用 `d` 选项

* 恢复相对备份

```bash
cpio –iv < etc.cpio
```

* 文件或目录的绝对恢复

恢复特定的文件或目录需要创建一个列表文件，然后必须删除该文件。

```bash
echo "/etc/passwd" > tmp
cpio –iuE tmp -F etc.A.cpio
rm -f tmp
```

## 压缩 - 解压缩实用程序

在备份时使用压缩可能会有许多缺点：

* 延长了备份时间和恢复时间。
* 这使得无法将文件添加到备份中。

!!! Note "说明"

    因此，最好进行备份并压缩它，而不是在备份过程中压缩它。

### 使用 `gzip` 进行压缩

`gzip` 命令压缩数据。

`gzip` 命令的语法：

```bash
gzip [options] [file ...]
```

示例：

```bash
$ gzip usr.tar
$ ls
usr.tar.gz
```

该文件的扩展名为 `.gz`。

它保留相同的权限以及相同的最后访问和修改日期。

### 使用 `bzip2` 进行压缩

`bzip2` 命令也压缩数据。

`bzip2` 命令的语法：

```bash
bzip2 [options] [file ...]
```

示例：

```bash
$ bzip2 usr.cpio
$ ls
usr.cpio.bz2
```

文件的扩展名为 `.bz2`。

`bzip2` 压缩比 `gzip` 压缩要好，但执行它需要更长的时间。

### 使用 `gunzip` 进行解压缩

`gunzip` 命令用来解压压缩的数据。

`gunzip` 命令的语法：

```bash
gunzip [options] [file ...]
```

示例：

```bash
$ gunzip usr.tar.gz
$ ls
usr.tar
```

文件名被 `gunzip` 截断，扩展名 `.gz` 被删除。

`gunzip` 还解压缩具有以下扩展名的文件：

* `.z`；
* `-z`；
* `_z`；
* `-gz`；

### 使用 `bunzip2` 进行解压缩

`bunzip2` 命令用来解压压缩的数据。

`bzip2` 命令的语法：

```bash
bzip2 [options] [file ...]
```

示例：

```bash
$ bunzip2 usr.cpio.bz2
$ ls
usr.cpio
```

文件名被 `bunzip2` 截断，扩展名 `.bz2` 被删除。

`bunzip2` 还解压缩具有以下扩展名的文件：

* `-bz`；
* `.tbz2`；
* `tbz`。
