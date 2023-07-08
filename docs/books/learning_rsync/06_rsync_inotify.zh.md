---
title: inotify-tools 安装与使用
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# 编译安装

在服务器中执行以下操作， 在你的环境中，可能会缺少一些依赖的包， 使用以下方式安装它们： `dnf -y install autoconf automake libtool`

```bash
[root@Rocky ~]# wget -c https://github.com/inotify-tools/inotify-tools/archive/refs/tags/3.21.9.6.tar.gz
[root@Rocky ~]# tar -zvxf 3.21.9.6.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/inotify-tools-3.21.9.6/
[root@Rocky /usr/local/src/inotify-tools-3.21.9.6]# ./autogen.sh  && \
./configure --prefix=/usr/local/inotify-tools &&  \
make &&  \
make install
...
[root@Rocky ~]# ls /usr/local/inotify-tools/bin/
inotifywait  inotifywatch
[root@Rocky ~]# ls /usr/local/inotify-tools/bin/
inotifywait inotifywatch
```

对环境变量PATH进行追加，写入到配置文件中且让其永久生效。

```bash
[root@Rocky ~]# vim /etc/profile
...
PATH=$PATH:/usr/local/inotify-tools/bin/
[root@Rocky ~]# . /etc/profile
```

**为什么不使用EPEL存储库的inotify-tools RPM包？ 而使用源代码编译安装的方式？**

作者个人认为，远程传输数据关乎效率问题，特别在在生产环境下，要同步的文件数量多且单文件特别大的前提下，这特别重要。 而且新版本会有一些bug修复与功能拓展，也许新版本的传输效率会更加高，所以我更加推荐用源代码的方式安装 inotify-tools 。 当然，这是作者的个人建议，不是每个用户都必须遵循的。

## 内核参数调整

您可以根据生产环境的需要，对内核参数进行调整。 默认情况下，在 **/proc/sys/fs/inotity/** 有三个文件

```bash
[root@Rocky ~]# cd /proc/sys/fs/inotify/
[root@Rocky /proc/sys/fs/inotify]# cat max_queued_events ;cat max_user_instances ;cat max_user_watches
16384
128
28014
```

* max_queued_events - 最多监控队列大小，默认16384
* max_user_instances - 最多监控实例数，默认128
* max_user_watches - 每个实例最多监控的文件数，默认8192

写入一些参数与值到 **/etc/sysctl.conf** 当中，示例如下。 然后使用`sysctl -p`让文件它们生效

```txt
fs.inotify.max_queued_events = 16384
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 1048576
```

## 相关命令

inotify-tools工具有两个命令，分别是：
* **inotifywait** - 用于持续监控，实时输出结果。 一般是配合rsync增量备份工具一起使用，因为是文件系统的监控，所以可以搭配脚本一起使用，后面我们会介绍具体的脚本写法。 因为是文件系统的监控，所以可以搭配脚本一起使用。 后面我们会介绍具体的脚本写法。
* **inotifywatch** - 用于短期监控，任务完成后输出结果。

inotifywait 主要有以下选项：

```txt
-m  表示持续监控
-r  递归监控
-q  简化输出信息
-e  指定监控数据的事件类型，多个事件类型用英文状态的逗号隔开
```

事件类型如下：

| 事件类型          | 说明                         |
| ------------- | -------------------------- |
| access        | 文件或目录的内容进行访问               |
| modify        | 文件或目录的内容被写入                |
| attrib        | 文件或目录的属性被修改                |
| close_write   | 文件或目录在可写模式下打开后关闭           |
| close_nowrite | 文件或目录在以只读模式打开后关闭           |
| close         | 无论读/写模式，文件或目录关闭            |
| open          | 文件或者目录被打开                  |
| moved_to      | 有文件或目录移动到监控的目录中            |
| moved_from    | 有文件或目录从监控的目录中移出            |
| move          | 有文件或者目录，被移动到监控目录或者从监控目录中移出 |
| move_self     | 已移动受监视的文件或目录               |
| create        | 被监控的目录内有创建的文件或目录           |
| delete        | 被监控的目录内有文件或目录被删除           |
| delete_self   | 文件或目录已经被删除                 |
| unmount       | 包含已卸载文件或目录的文件系统            |

示例:`[root@Rocky ~]# inotifywait  -mrq  -e  create,delete  /rsync/`

## inotifywait命令的演示

在第一个终端pts/0中键入命令，回车后窗口被锁定，表示正在监控

```bash
[root@Rocky ~]# inotifywait  -mrq  -e  create,delete  /rsync/

```

在第二个终端pts/1中，进入到 /rsync/ 目录中，创建文件。

```bash
[root@Rocky ~]# cd /rsync/
[root@Rocky /rsync]# touch inotify
```

回到第一个终端pts/0中，输出信息如下：

```bash
[root@Rocky ~]# inotifywait  -mrq  -e  create,delete  /rsync/
/rsync/ CREATE inotify
```

## inotifywait和rsync的结合使用

!!! tip "提示"

    我们在Rocky Linux 8服务器上操作，使用SSH协议进行演示。

SSH协议的免密验证登录，可参考 [rsync 免密验证登录](05_rsync_authentication-free_login.zh.md)，这里不具体说明。 bash脚本内容示例如下。 您可以根据需要，在命令的后面加上不同的选项来满足需求。 bash脚本内容示例如下，您可以根据需要，在命令的后面加上不同的选项来满足需求，例如还可以在`rsync`命令后面加入`--delete`

```bash
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e modify,move,create,delete /rsync/"
b="/usr/bin/rsync -avz /rsync/* testfedora@192.168.100.5:/home/testfedora/"
$a | while read directory event file
    do
        $b &>> /tmp/rsync.log
    done
```

```bash
[root@Rocky ~]# chmod +x rsync_inotify.sh
[root@Rocky ~]# bash /root/rsync_inotify.sh &
```

!!! tip "提示"

    使用SSH协议进行数据同步传输时，如果目标机器的SSH服务端口不是22 ，则您可以使用类似这样的方式——
    `b="/usr/bin/rsync -avz -e 'ssh -p [port-number]' /rsync/* testfedora@192.168.100.5:/home/testfedora/"`

!!! tip "提示"

    如果您要开机自启动这个脚本的话
    `[root@Rocky ~]# echo "bash /root/rsync_inotify.sh &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

如果您使用的是rsync协议进行同步，您需要配置目标机器的rsync服务，可参考[rsync 演示02](03_rsync_demo02.zh.md)、[rsync 配置文件](04_rsync_configure.zh.md)、[rsync 免密验证登录](05_rsync_authentication-free_login.zh.md)
