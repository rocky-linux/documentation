---
title: 高级Linux 命令
---

# Linux 用户的高级命令

熟悉基本命令后，高级命令可在更特殊的情况下提供更好的自定义和控制。

****

**目标**：在本章中，未来的Linux管理员将学习：

:heavy_check_mark: 上一章中没有介绍的一些有用命令。 :heavy_check_mark: 一些高级命令。

:checkered_flag: **用户命令**, **Linux**

**知识性**: :star: **复杂度**: :star: :star: :star:

**阅读时间**: 20 分钟

****

## `uniq` 命令

`uniq`命令是一个非常强大的命令，与`sort`命令一起使用尤其适合用于日志文件分析。 它允许您通过删除重复项来排序和显示条目。

为了说明 `uniq` 命令的工作原理，让我们使用一个包含名字列表的 `firstnames.txt` 文件：

```text
antoine
xavier
steven
patrick
xavier
antoine
antoine
steven
```

!!! note "说明"

    `uniq` 要求在运行之前对输入文件进行排序，因为它只比较连续的行。

如果不带选项，`uniq`命令将不会显示`firstnames.txt`文件中紧随其后的相同行：

```bash
$ sort firstnames.txt | uniq
antoine
patrick
steven
xavier
```

要仅显示只出现一次的行，请使用`-u`选项：

```bash
$ sort firstnames.txt | uniq -u
patrick
```

相反，要只显示文件中至少出现两次的行，请使用`-d`选项：

```bash
$ sort firstnames.txt | uniq -d
antoine
steven
xavier
```

要简单地删除只出现一次的行，请使用`-D`选项：

```bash
$ sort firstnames.txt | uniq -D
antoine
antoine
antoine
steven
steven
xavier
xavier
```

最后，要计算每行出现的次数，请使用`-c`选项：

```bash
$ sort firstnames.txt | uniq -c
      3 antoine
      1 patrick
      2 steven
      2 xavier
```

```bash
$ sort firstnames.txt | uniq -cd
      3 antoine
      2 steven
      2 xavier
```

## `xargs` 命令

`xargs`命令允许从标准输入构建和执行命令行。

`xargs` 命令从标准输入中读取以空格或换行符分隔的参数，并使用初始参数和从标准输入中读取的参数执行一次或多次命令（默认为`/bin/echo`）。

第一个也是最简单的示例如下：

```bash
$ xargs
use
of
xargs
<CTRL+D>
use of xargs
```

`xargs`命令等待来自标准 **stdin** 输入的输入， 输入三行。 用户输入的结束是通过按键顺序 ++ctrl+d++ 指定给 `xargs` 的。 `xargs` 然后执行默认命令 `echo`，后跟与用户输入对应的三个参数，即：

```bash
$ echo "use" "of" "xargs"
use of xargs
```

可以通过 `xargs` 来指定一个要运行的命令。

在下面的示例中，`xargs` 将对标准输入中指定的一组文件夹上运行命令 `ls -ld`：

```bash
$ xargs ls -ld
/home
/tmp
/root
<CTRL+D>
drwxr-xr-x. 9 root root 4096  5 avril 11:10 /home
dr-xr-x---. 2 root root 4096  5 avril 15:52 /root
drwxrwxrwt. 3 root root 4096  6 avril 10:25 /tmp
```

实际上，`xargs` 命令执行的是 `ls -ld /home /tmp /root` 命令。

如果要执行的命令不像 `find` 命令那样接受多个参数，会发生什么情况？

```bash
$ xargs find /var/log -name
*.old
*.log
find: paths must precede expression: *.log
```

`xargs` 命令试图执行 `-name` 选项后面带有多个参数的 `find` 命令，这导致 `find` 产生错误：

```bash
$ find /var/log -name "*.old" "*.log"
find: paths must precede expression: *.log
```

在这种情况下，必须强制 `xargs` 命令多次执行 `find` 命令（每行输入一次作为标准输入）。 `-L` 选项后跟 **整数** 允许您指定一次使用该命令能处理的最大条目数：

```bash
$ xargs -L 1 find /var/log -name
*.old
/var/log/dmesg.old
*.log
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

如果我们希望能够在同一行中指定这两个参数，则必须使用 `-n 1` 选项：

```bash
$ xargs -n 1 find /var/log -name
*.old *.log
/var/log/dmesg.old
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

基于搜索使用 `tar` 进行备份的案例研究：

```bash
$ find /var/log/ -name "*.log" -mtime -1 | xargs tar cvfP /root/log.tar
$ tar tvfP /root/log.tar
-rw-r--r-- root/root      1720 2017-04-05 15:43 /var/log/boot.log
-rw-r--r-- root/root    499270 2017-04-06 11:01 /var/log/audit/audit.log
```

`xargs` 命令的特殊功能是将输入参数放在被调用命令的结尾， 这在上面的示例中工作得非常好，因为传入的文件将形成要添加到存档中的文件列表。

现在，如果我们以 `cp` 命令为例并希望复制目录中的文件列表，则该文件列表将被添加到该命令的结尾... 但是 `cp` 命令在命令结尾要求的是目标文件。 为此，我们使用 `-I` 选项将输入参数放在行尾以外的其他位置。

```bash
$ find /var/log -type f -name "*.log" | xargs -I % cp % /root/backup
```

`-I` 选项允许您指定一个字符(上面示例中是 `%` 字符)，用于放置 `xargs` 的输入文件。

## `yum-utils` 软件包

`yum-utils` 软件包是由不同作者为 `yum` 构建的实用程序集合，这使其更易于使用且功能更强大。

!!! note "说明"

    在 Rocky Linux 8 中，`yum`被替换为`dnf`，虽然也可以安装`dnf-utils`，但包名仍然是`yum-utils`。 这些都是经典的YUM工具，在DNF之上以CLI shims的形式实现，以保持与`yum-3`的向后兼容。

以下是这些实用程序的一些示例。

### `repoquery` 命令

`repoquery` 命令用于查询存储库中的软件包。

使用示例：

* 显示包的依赖项（可以是已安装或未安装的软件包），相当于 `dnf deplist <package-name>`

```bash
repoquery --requires <package-name>
```

* 显示已安装软件包提供的文件（不适用于未安装的软件包），相当于 `rpm-ql <package-name>`

```bash
$ repoquery -l yum-utils
/etc/bash_completion.d
/etc/bash_completion.d/yum-utils.bash
/usr/bin/debuginfo-install
/usr/bin/find-repos-of-install
/usr/bin/needs-restarting
/usr/bin/package-cleanup
/usr/bin/repo-graph
/usr/bin/repo-rss
/usr/bin/repoclosure
/usr/bin/repodiff
/usr/bin/repomanage
/usr/bin/repoquery
/usr/bin/reposync
/usr/bin/repotrack
/usr/bin/show-changed-rco
/usr/bin/show-installed
/usr/bin/verifytree
/usr/bin/yum-builddep
/usr/bin/yum-config-manager
/usr/bin/yum-debug-dump
/usr/bin/yum-debug-restore
/usr/bin/yum-groups-manager
/usr/bin/yumdownloader
…
```

### `yumdownloader` 命令

`yumdownloader` 命令用来从存储库下载 RPM 软件包。  等同于 `dnf download --downloadonly --downloaddir ./  package-name`

!!! note "说明"

    这个命令对于快速构建一些 rpm 的本地存储库非常有用！

示例：`yumdownloader` 将下载 _samba_ 软件包及其所有依赖项：

```bash
$ yumdownloader --destdir /var/tmp --resolve samba
或者
$ dnf download --downloadonly --downloaddir /var/tmp  --resolve  samba
```

| 选项          | 解释                 |
| ----------- | ------------------ |
| `--destdir` | 下载的软件包将存储在指定的文件夹中。 |
| `--resolve` | 同时下载软件包依赖项。        |

## `psmisc` 软件包

`psmisc`软件包包含用于管理系统进程的实用程序：

* `pstree`：`pstree` 命令会以树状结构显示系统上的当前进程。
* `killall`：`killall` 命令会向按名称标识的所有进程发送一个 kill 信号。
* `fuser`：`fuser` 命令用于标识指定文件或文件系统的进程 `PID` 。

示例：

```bash
$ pstree
systemd─┬─NetworkManager───2*[{NetworkManager}]
        ├─agetty
        ├─auditd───{auditd}
        ├─crond
        ├─dbus-daemon───{dbus-daemon}
        ├─firewalld───{firewalld}
        ├─lvmetad
        ├─master─┬─pickup
        │        └─qmgr
        ├─polkitd───5*[{polkitd}]
        ├─rsyslogd───2*[{rsyslogd}]
        ├─sshd───sshd───bash───pstree
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-udevd
        └─tuned───4*[{tuned}]
```

```bash
# killall httpd
```

结束访问 `/etc/httpd/conf/httpd.conf` 文件的进程(`-k` 选项)：

```bash
# fuser -k /etc/httpd/conf/httpd.conf
```

## `watch` 命令

`watch` 命令会定期执行一条命令，并在终端全屏显示结果。

`-n` 选项允许您指定每次执行命令之间的秒数。

!!! note "说明"

    要退出 `watch` 命令，您必须键入以下键：<kbd>CTRL</kbd>+<kbd>C</kbd> 以终止进程。

示例：

* 每 5 秒显示一次 `/etc/passwd` 文件的结尾：

```bash
watch -n 5 tail -n 3 /etc/passwd
```

结果：

```bash
Every 5.0s: tail -n 3 /etc/passwd                                                                                                                                rockstar.rockylinux.lan: Thu Jul  1 15:43:59 2021

sssd:x:996:993:User for sssd:/:/sbin/nologin
chrony:x:995:992::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

* 监控文件夹中的文件数：

```bash
watch -n 1 'ls -l | wc -l'
```

* 显示时钟：

```bash
watch -t -n 1 date
```

## `install` 命令

与其名称可能暗示的相反，`install` 命令不用于安装新软件包。

此命令结合了文件复制（`cp`）和目录创建（`mkdir`），以及权限管理（`chmod`、`chown`）和其他有用的功能（如备份）。

```bash
install source dest
install -t directory source [...]
install -d directory
```

选项：

| 选项                         | 备注                            |
| -------------------------- | ----------------------------- |
| `-b` 或 `--backup[=suffix]` | 创建目标文件的备份                     |
| `-d`                       | 将参数视为目录名                      |
| `-D`                       | 在将 SOURCE 复制到 DEST 之前创建所有主要部分 |
| `-g` 和 `-o`                | 设置所有权                         |
| `-m`                       | 设置权限                          |
| `-p`                       | 保留源文件的时间戳                     |
| `-t`                       | 将所有源参数复制到目录                   |

!!! note "说明"

    有一些管理 SELinux 上下文的选项（请参阅手册页）。

示例：

使用 `-d` 选项创建一个目录：

```bash
install -d ~/samples
```

将文件从源位置复制到目录：

```bash
install src/sample.txt ~/samples/
```

这两条命令可以用一个命令来执行：

```bash
$ install -v -D -t ~/samples/ src/sample.txt
install: creating directory '~/samples'
'src/sample.txt' -> '~/samples/sample.txt'
```

这个命令已经节省了时间。 将其与所有者、所属组和权限管理相结合，以节省时间：

```bash
sudo install -v -o rocky -g users -m 644 -D -t ~/samples/ src/sample.txt
```

 !!! note "说明"

     在这种情况下，需要使用 `sudo` 来进行属性更改。

你也可以通过 `-b` 选项创建现有文件的备份：

```bash
$ install -v -b -D -t ~/samples/ src/sample.txt
'src/sample.txt' -> '~/samples/sample.txt' (archive: '~/samples/sample.txt~')
```

如您所见，使用 `install` 命令创建了一个备份文件，这会在原始文件名后面附加 `~` 波浪号。

由于有 `-S` 选项，可以指定后缀：

```bash
$ install -v -b -S ".bak" -D -t ~/samples/ src/sample.txt
'src/sample.txt' -> '~/samples/sample.txt' (archive: '~/samples/sample.txt.bak')
```

## `tree` 命令

以树状方式展开目录中包含的文件或目录。

| 选项   | 描述             |
|:---- |:-------------- |
| `-a` | 列出所有文件         |
| `-h` | 以更易于阅读的方式打印大小  |
| `-u` | 显示文件所有者或 UID 号 |
| `-g` | 显示文件所属组或 GID 号 |
| `-p` | 打印每个文件的权限      |

例如：

```bash
$ tree -hugp /etc/yum.repos.d/
/etc/yum.repos.d/
├── [-rw-r--r-- root     root      1.6K]  epel-modular.repo
├── [-rw-r--r-- root     root      1.3K]  epel.repo
├── [-rw-r--r-- root     root      1.7K]  epel-testing-modular.repo
├── [-rw-r--r-- root     root      1.4K]  epel-testing.repo
├── [-rw-r--r-- root     root       710]  Rocky-AppStream.repo
├── [-rw-r--r-- root     root       695]  Rocky-BaseOS.repo
├── [-rw-r--r-- root     root      1.7K]  Rocky-Debuginfo.repo
├── [-rw-r--r-- root     root       360]  Rocky-Devel.repo
├── [-rw-r--r-- root     root       695]  Rocky-Extras.repo
├── [-rw-r--r-- root     root       731]  Rocky-HighAvailability.repo
├── [-rw-r--r-- root     root       680]  Rocky-Media.repo
├── [-rw-r--r-- root     root       680]  Rocky-NFV.repo
├── [-rw-r--r-- root     root       690]  Rocky-Plus.repo
├── [-rw-r--r-- root     root       715]  Rocky-PowerTools.repo
├── [-rw-r--r-- root     root       746]  Rocky-ResilientStorage.repo
├── [-rw-r--r-- root     root       681]  Rocky-RT.repo
└── [-rw-r--r-- root     root      2.3K]  Rocky-Sources.repo

0 directories, 17 files
```

## `stat` 命令

`stat` 命令用于显示文件或文件系统的状态。

```bash
$ stat /root/anaconda-ks.cfg
  File: /root/anaconda-ks.cfg
  Size: 1352            Blocks: 8          IO Block: 4096   regular file
Device: 10302h/66306d   Inode: 2757097     Links: 1
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2024-01-20 13:04:57.012033583 +0800
Modify: 2023-09-25 14:04:48.524760784 +0800
Change: 2024-01-24 16:37:34.315995221 +0800
 Birth: 2
```

* `File` - 显示文件的路径位置。
* `Size` - 以字节为单位显示文件大小。 如果这是一个目录，则显示目录名所占用的固定 4096 字节。
* `Blocks` - 显示已分配的块数。 请注意！ 此命令中每个块的大小为 512 字节。 `ls -ls`中每个块的默认大小为 1024 字节。
* `Device` - 以十进制或十六进制表示的设备编号。
* `Inode` - Inode是 Linux 内核为文件或目录分配的唯一 ID 号。
* `Links` - 硬链接数。 硬链接有时也被称为物理链接。
* `Access` - 文件和目录的最后访问时间，即 GNU/Linux 中的 `atime` 。
* `Modify` - 文件和目录的最后修改时间，即 GNU/Linux 中的 `mtime` 。
* `Change` - 最后一次修改属性的时间，即 GNU/Linux 中的 `ctime` 。
* `Birth` - 诞生时间（创建时间）。 在某些文档中，缩写为 `btime` 或 `crtime` 。 您需要一个高于某个版本的文件系统和内核版本来显示创建时间。

对于文件而言：

**atime** - 使用 `cat`、`less`、`more` 和 `head` 等命令访问文件内容后，可以更新文件的 `atime` 。 请注意！ 文件的 `atime` 不是实时更新的，出于性能原因，需要等待一段时间才能显示。 **mtime** - 修改文件内容可以更新文件的 `mtime` （如通过重定向追加或覆盖文件内容），因为文件大小是文件的属性，所以 `ctime` 也会同步更新。 **ctime** - 变更文件的所有者、所属组、权限、文件大小和链接（软链接和硬链接）将更新 ctime 。

对于目录而言：

**atime** - 在使用 `cd` 命令进入一个以前从未访问过的新目录后，您可以更新并固定该目录的 `atime` 。 **mtime** - 在该目录下执行创建、删除、重命名等操作，会更新目录的 `mtime` 和 `ctime` 。 **ctime** - 当目录的权限、所有者、所属组等发生变更时，该目录的 `ctime` 将被更新。

!!! tip "提示"

    * 如果创建新文件或目录，其 `atime`、`mtime` 和 `ctime` 完全相同
    * 如果修改了文件的内容，那么文件的 `mtime` 和 `ctime` 必然会被更新。
    * 如果在该目录中创建了一个全新的文件，则该目录的 `atime`、`ctime` 和 `mtime` 将同时更新。
    * 如果更新了目录的 `mtime` ，则必须更新该目录的 `ctime`。
