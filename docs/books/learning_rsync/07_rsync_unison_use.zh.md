---
title: 使用 unison
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-06
---

# 简述

前面我们提到，单向同步使用的是rsync + inotify-tools。 在一些比较特殊的使用场景下可能需要双向同步，这就需要inotify-tools + unison。

## 环境准备

* Rocky Linux 8 与 Fedora 34 都需要源代码编译安装 **inotify-tools** ，这里不具体展开。
* 两台机器都必须免密登录验证，这里我们使用的是SSH协议进行
* [ocaml](https://github.com/ocaml/ocaml/) 使用v4.12.0，[unison](https://github.com/bcpierce00/unison/) 使用v2.51.4。

环境准备好后，可以进行验证：

```bash
[root@Rocky ~]# inotifywa
inotifywait   inotifywatch  
[root@Rocky ~]# ssh -p 22 testrsync@192.168.100.5
Last login: Thu Nov  4 13:13:42 2021 from 192.168.100.4
[testrsync@fedora ~]$
```

```bash
[root@fedora ~]# inotifywa
inotifywait   inotifywatch
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Wed Nov  3 22:07:18 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! tip "提示"

    服务器的配置文件 **/etc/ssh/sshd_config** 应该打开 <font color=red>PubkeyAuthentication yes</font>

## Rocky Linux 8 安装unison

ocaml是一门编程语言，unison的底层依赖它。

```bash
[root@Rocky ~]# wget -c https://github.com/ocaml/ocaml/archive/refs/tags/4.12.0.tar.gz
[root@Rocky ~]# tar -zvxf 4.12.0.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/ocaml-4.12.0
[root@Rocky /usr/local/src/ocaml-4.12.0]# ./configure --prefix=/usr/local/ocaml && make world opt && make install
...
[root@Rocky ~]# ls /usr/local/ocaml/
bin lib man
[root@Rocky ~]# echo PATH=$PATH:/usr/local/ocaml/bin >> /etc/profile
[root@Rocky ~]# . /etc/profile
```

```bash
[root@Rocky ~]# wget -c https://github.com/bcpierce00/unison/archive/refs/tags/v2.51.4.tar.gz
[root@Rocky ~]# tar -zvxf v2.51.4.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/unison-2.51.4/
[root@Rocky /usr/local/src/unison-2.51.4]# make UISTYLE=txt
...
[root@Rocky /usr/local/src/unison-2.51.4]# ls src/unison
src/unison
[root@Rocky /usr/local/src/unison-2.51.4] cp -p src/unison /usr/local/bin
```

## Fedora 34 安装unison

一样的操作。

```bash
[root@fedora ~]# wget -c https://github.com/ocaml/ocaml/archive/refs/tags/4.12.0.tar.gz
[root@feodora ~]# tar -zvxf 4.12.0.tar.gz -C /usr/local/src/
[root@fedora ~]# cd /usr/local/src/ocaml-4.12.0
[root@fedora /usr/local/src/ocaml-4.12.0]# ./configure --prefix=/usr/local/ocaml && make world opt && make install
...
[root@fedora ~]# ls /usr/local/ocaml/
bin lib man
[root@fedora ~]# echo PATH=$PATH:/usr/local/ocaml/bin >> /etc/profile
[root@fedora ~]#. /etc/profile
```

```bash
[root@fedora ~]# wget -c https://github.com/bcpierce00/unison/archive/refs/tags/v2.51.4.tar.gz
[root@fedora ~]# tar -zvxf v2.51.4.tar.gz -C /usr/local/src/
[root@fedora ~]# cd /usr/local/src/unison-2.51.4/
[root@fedora /usr/local/src/unison-2.51.4]# make UISTYLE=txt
...
[root@fedora /usr/local/src/unison-2.51.4]# ls src/unison
src/unison
[root@fedora /usr/local/src/unison-2.51.4]# cp -p src/unison /usr/local/bin
```


## 演示

**我们的需求是 —— Rocky Linux 8的 /dir1/ 目录自动同步到Fedora 34的 /dir2/ 目录 ；同时Fedora 34的 /dir2/ 目录自动同步到Rocky Linux 8 的 /dir1/ 目录**

### 配置Rcoky Linux 8

```bash
[root@Rocky ~]# mkdir /dir1
[root@Rocky ~]# setfacl -m u:testrsync:rwx /dir1/
[root@Rocky ~]# vim /root/unison1.sh
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e create,delete,modify,move /dir1/"
b="/usr/local/bin/unison -batch /dir1/ ssh://testrsync@192.168.100.5//dir2"
$a | while read directory event file
do
    $b &>> /tmp/unison1.log
done
[root@Rocky ~]# chmod +x /root/unison1.sh
[root@Rocky ~]# bash /root/unison1.sh &
[root@Rocky ~]# jobs -l
```

### 配置Fedora 34

```bash
[root@fedora ~]# mkdir /dir2
[root@fedora ~]# setfacl -m u:testrsync:rwx /dir2/
[root@fedora ~]# vim /root/unison2.sh
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e create,delete,modify,move /dir2/"
b="/usr/local/bin/unison -batch /dir2/ ssh://testrsync@192.168.100.4//dir1"
$a | while read directory event file
do
    $b &>> /tmp/unison2.log
done
[root@fedora ~]# chmod +x /root/unison2.sh
[root@fedora ~]# bash /root/unison2.sh &
[root@fedora ~]# jobs -l
```

!!! tip "提示"

    要双向同步的话，两个机器的脚本必须都需要启动才可以，否则会报错。

!!! tip "提示"

    如果您要开机自启动这个脚本的话
    `[root@Rocky ~]# echo "bash /root/unison1.sh &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

!!! tip "提示"

    如果您要停止这个脚本的对应进程，可以在 `htop` 命令中找到它然后 **kill** 即可
