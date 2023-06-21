---
title: inotify-tools installation and use
author: tianci li
contributors: Steven Spencer
update: 2021-11-04
---

# Compile and install

Perform the following operations in the server. In your environment, some dependent packages may be missing. Install them by using: `dnf -y install autoconf automake libtool`

```bash
[root@Rocky ~]# wget -c https://github.com/inotify-tools/inotify-tools/archive/refs/tags/3.21.9.6.tar.gz
[root@Rocky ~]# tar -zvxf 3.21.9.6.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/inotify-tools-3.21.9.6/
[root@Rocky /usr/local/src/inotify-tools-3.21.9.6]# ./autogen.sh && \
./configure --prefix=/usr/local/inotify-tools && \
make && \
make install
...
[root@Rocky ~]# ls /usr/local/inotify-tools/bin/
inotifywait inotifywatch
```

Append the environment variable PATH, write it to the configuration file and let it take effect permanently.

```bash
[root@Rocky ~]# vim /etc/profile
...
PATH=$PATH:/usr/local/inotify-tools/bin/
[root@Rocky ~]# . /etc/profile
```

**Why not use the inotify-tools RPM package of the EPEL repository? And the way to use source code to compile and install?**

The author personally believes that remote data transmission is a matter of efficiency, especially in a production environment, where there are a large number of files to be synchronized and a single file is particularly large. In addition, the new version will have some bug fixes and function expansions, and perhaps the transmission efficiency of the new version will be higher, so I recommend installing inotify-tools by source code. Of course, this is the author's personal suggestion, not every user must follow.

## Kernel parameter adjustment

You can adjust the kernel parameters according to the needs of the production environment. By default, there are three files in **/proc/sys/fs/inotity/**

```bash
[root@Rocky ~]# cd /proc/sys/fs/inotify/
[root@Rocky /proc/sys/fs/inotify]# cat max_queued_events ;cat max_user_instances ;cat max_user_watches
16384
128
28014
```

* max_queued_events-maximum monitor queue size, default 16384
* max_user_instances-the maximum number of monitoring instances, the default is 128
* max_user_watches-the maximum number of files monitored per instance, the default is 8192

Write some parameters and values ​​to **/etc/sysctl.conf**, examples are as follows. Then use `sysctl -p` to make the files take effect

```txt
fs.inotify.max_queued_events = 16384
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 1048576
```

## Related commands

The inotify-tools tool has two commands, namely:
* **inotifywait**-For continuous monitoring, real-time output results. It is generally used with the rsync incremental backup tool. Because it is a file system monitoring, it can be used with a script. We will introduce the specific script writing later.
* **inotifywatch**-for short-term monitoring, output results after the task is completed.

`inotifywait` mainly has the following options:

```txt
-m means continuous monitoring
-r Recursive monitoring
-q Simplify output information
-e specifies the event type of monitoring data, multiple event types are separated by commas in English status
```

The event types are as follows:

| Event Type | Description |
|---|---|
| access | Access to the contents of a file or directory |
| modify | The contents of the file or directory are written |
| attrib | The attributes of the file or directory are modified |
| close_write | File or directory is opened in writable mode and then closed |
| close_nowrite | File or directory is closed after being opened in read-only mode |
| close | Regardless of the read/write mode, the file or directory is closed |
| open | File or directory is opened |
| moved_to | A file or directory is moved to the monitored directory |
| moved_from | A file or directory is moved from the monitored directory |
| move | There are files or directories that are moved to or removed from the monitoring directory |
| move_self | The monitored file or directory has been moved |
| create | There are files or directories created in the monitored directory |
| delete | A file or directory in the monitored directory is deleted |
| delete_self | File or directory delete |
| unmount | File system containing unmounted files or directories |

Example: `[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/`

## Demonstration of `inotifywait` command

Type the command in the first terminal pts/0, and the window is locked after pressing Enter, indicating that it is monitoring

```bash
[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/

```

In the second terminal pts/1, go to the /rsync/ directory and create a file.

```bash
[root@Rocky ~]# cd /rsync/
[root@Rocky /rsync]# touch inotify
```

Back to the first terminal pts/0, the output information is as follows:

```bash
[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/
/rsync/ CREATE inotify
```

## Combination of  `inotifywait` and `rsync`

!!! tip "tip"

    We are operating in Rocky Linux 8 server, using SSH protocol for demonstration.

For the password-free authentication login of the SSH protocol, please refer to [rsync password-free authentication login](05_rsync_authentication-free_login.md), which is not described here. An example of the content of a bash script is as follows. You can add different options after the command according to your needs to meet your needs. For example, you can also add `--delete` after the `rsync` command.

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

!!! tip "tip"

    When using the SSH protocol for data synchronization transmission, if the SSH service port of the target machine is not 22, you can use a method similar to this——
    `b="/usr/bin/rsync -avz -e 'ssh -p [port-number]' /rsync/* testfedora@192.168.100.5:/home/testfedora/"`

!!! tip "tip"

    If you want to start this script at boot
    `[root@Rocky ~]# echo "bash /root/rsync_inotify.sh &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

If you are using the rsync protocol for synchronization, you need to configure the rsync service of the target machine, please refer to [rsync demo 02](03_rsync_demo02.md), [rsync configuration file](04_rsync_configure.md), [rsync free Secret authentication login](05_rsync_authentication-free_login.md)
