---
title: 高级Linux 命令
---

# Linux 用户的高级命令

熟悉基本命令后，高级命令可在更特殊的情况下提供更好的自定义和控制。

****

**目标**：在本章中，未来的Linux管理员将学习：

:heavy_check_mark: 上一章没有介绍的一些有用命令。   
:heavy_check_mark: 一些高级命令。

:checkered_flag: **用户命令**, **Linux**

**知识**: :star:   
**复杂度**: :star: :star: :star:

**阅读时间**: 20 分钟

****

## `uniq` 命令

`uniq`命令是一个非常强大的命令，与`sort`命令一起使用尤其适合用于日志文件分析。 它允许您通过删除重复项来排序和显示条目。

为了说明`uniq`命令的工作原理，让我们使用一个包含名字列表的`firstnames.txt`文件：

```
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

```
$ sort firstnames.txt | uniq
antoine
patrick
steven
xavier
```

要仅显示只出现一次的行，请使用`-u`选项：

```
$ sort firstnames.txt | uniq -u
patrick
```

相反，要只显示文件中至少出现两次的行，请使用`-d`选项：

```
$ sort firstnames.txt | uniq -d
antoine
steven
xavier
```

要简单地删除只出现一次的行，请使用`-D`选项：

```
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

```
$ sort firstnames.txt | uniq -c
      3 antoine
      1 patrick
      2 steven
      2 xavier
```

```
$ sort firstnames.txt | uniq -cd
      3 antoine
      2 steven
      2 xavier
```

## `xargs` 命令

`xargs`命令允许从标准输入构建和执行命令行。

`xargs` 命令从标准输入中读取以空格或换行符分隔的参数，并使用初始参数和从标准输入中读取的参数执行一次或多次命令（默认为`/bin/echo`）。

第一个也是最简单的示例如下：

```
$ xargs
use
of
xargs
<CTRL+D>
use of xargs
```

`xargs`命令等待来自标准**stdin**输入的输入， 输入三行。 用户输入的结束是通过按键顺序<kbd>CTRL</kbd>+<kbd>D</kbd>指定给`xargs`的。 `xargs`然后执行默认命令`echo`，后跟与用户输入对应的三个参数，即：

```
$ echo "use" "of" "xargs"
use of xargs
```

可以通过`xargs`来指定一个要运行的命令。

在下面的示例中，`xargs`将对标准输入中指定的一组文件夹上运行命令`ls-ld`：

```
$ xargs ls -ld
/home
/tmp
/root
<CTRL+D>
drwxr-xr-x. 9 root root 4096  5 avril 11:10 /home
dr-xr-x---. 2 root root 4096  5 avril 15:52 /root
drwxrwxrwt. 3 root root 4096  6 avril 10:25 /tmp
```

实际上，`xargs`命令执行的是 `ls -ld /home /tmp /root`命令。

如果要执行的命令不像`find`命令那样接受多个参数，会发生什么情况？

```
$ xargs find /var/log -name
*.old
*.log
find: paths must precede expression: *.log
```

`xargs`命令试图执行`-name`选项后面带有多个参数的`find`命令，这导致`find`产生错误：

```
$ find /var/log -name "*.old" "*.log"
find: paths must precede expression: *.log
```

在这种情况下，必须强制`xargs`命令多次执行find命令（每行输入一次作为标准输入）。 `-L`选项后跟 **整数**允许您指定一次使用该命令能处理的最大条目数：

```
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

如果我们希望能够在同一行中指定这两个参数，则必须使用`-n 1`选项：

```
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

基于搜索使用`tar`进行备份的案例研究：

```
$ find /var/log/ -name "*.log" -mtime -1 | xargs tar cvfP /root/log.tar
$ tar tvfP /root/log.tar
-rw-r--r-- root/root      1720 2017-04-05 15:43 /var/log/boot.log
-rw-r--r-- root/root    499270 2017-04-06 11:01 /var/log/audit/audit.log
```

`xargs`命令的特殊功能是将输入参数放在被调用命令的结尾， 这对于上面的示例非常有效，因为传入的文件将形成要添加到归档中的文件列表。

现在，如果我们以 `cp` 命令为例并希望复制目录中的文件列表，则该文件列表将被添加到该命令的结尾... 但是 `cp` 命令在命令结尾要求的是目标文件。 为此，我们使用 `-I` 选项将输入参数放在行尾以外的其他位置。

```
$ find /var/log -type f -name "*.log" | xargs -I % cp % /root/backup
```

`-I`选项允许您指定一个字符(上面示例中是`%`字符)，用于放置`xargs`的输入文件。

## `yum-utils` 软件包

`yum-utils`软件包是由不同作者为`yum`构建的实用程序集合，这使其更易于使用且功能更强大。

!!! note "说明"

    在 Rocky Linux 8 中，`yum`被替换为`dnf`，虽然也可以安装`dnf-utils`，但包名仍然是`yum-utils`。 这些都是经典的YUM工具，在DNF之上以CLI shims的形式实现，以保持与`yum-3`的向后兼容。

以下是这些实用程序的一些示例：

* `repoquery` 命令

`repoquery` 命令用于查询存储库中的软件包。

使用示例：

  * 显示软件包的依赖关系 (它可以是已安装或未安装的软件包)， 等同于`dnf deplist <package-name>`
    ```
    repoquery --requires <package-name>
    ```

  * 显示已安装软件包提供的文件（对于未安装的软件包不起作用），相当于`rpm -ql <package-name>`

    ```
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

* `yumdownloader` 命令：

`yumdownloader`命令用来从存储库下载RPM软件包。  等同于 `dnf download --downloadonly --downloaddir ./  package-name`

!!! note "说明"

    这个命令对于快速构建几个rpm的本地存储库非常有用！

示例：`yumdownloader` 将下载 _samba_软件包及其所有依赖项：

```
$ yumdownloader --destdir /var/tmp --resolve samba
or
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
* `fuser`：`fuser` 命令用于标识指定文件或文件系统的进程`PID`。

示例：

```
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

```
# killall httpd
```

结束访问 `/etc/httpd/conf/httpd.conf` 文件的进程(`-k`选项)：

```
# fuser -k /etc/httpd/conf/httpd.conf
```

## `watch` 命令

`watch` 命令会定期执行一条命令，并在终端全屏显示结果。

`-n` 选项允许您指定每次执行命令之间的秒数。

!!! note "说明"

    要退出`watch`命令，您必须键入按键：<kbd>CTRL</kbd>+<kbd>C</kbd> 来终止进程。

示例：

* 每5秒显示一次 `/etc/passwd` 文件的结尾：

```
$ watch -n 5 tail -n 3 /etc/passwd
```

结果：

```
Every 5,0s: tail -n 3 /etc/passwd                                                                                                                                rockstar.rockylinux.lan: Thu Jul  1 15:43:59 2021

sssd:x:996:993:User for sssd:/:/sbin/nologin
chrony:x:995:992::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

* 监控文件夹中的文件数：

```
$ watch -n 1 'ls -l | wc -l'
```

* 显示时钟：

```
$ watch -t -n 1 date
```
