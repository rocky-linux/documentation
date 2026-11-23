---
title: inotify-tools installation and use
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2026-11-18
---

## Overview

Rsync combined with `inotify-tools` can achieve real-time one-way data synchronization. In addition, you can see the password-free authentication for the SSH protocol and the RSYNC protocol in the previous chapter. In this chapter, you will learn how to install and use `inotify-tools`.

## Contents related to `inotify-tools`

`inotify-tools` is a filesystem monitoring program written primarily in Rust. It provides a `libinotifytools.so` that is compatible with the **ABI (Application Binary Interface)** of the legacy C library.

For the GNU/Linux operating system, the Linux kernel version must be greater than or equal to 2.6.13 in order to utilize the `inotify-tools` feature.

* Github project repository - <https://github.com/inotify-tools/inotify-tools>

### Installation

Enter the following command to install:

```bash
[root@RL8.10 ~]# dnf -y install inotify-tools
```

The `inotify-tools` version in RL 8.10 is 3.14, while the 4.x version of `inotify-tools` is rewritten in the Rust language.

!!! tip "Friendly Reminder"

    You can only find the `inotify-tools` precompiled software package in the EPEL repository.

### Related commands

There are mainly two commands:

* `inotifywait` - for continuous monitoring and real-time output results. You use this generally with the `rsync` incremental backup tool.
* `inotifywatch` - for short-term monitoring, output results after the task is completed.

The usage of the `inotifywait` command is `inotifywait [ options ] file1 [ file2 ] [ file3 ] [ ... ]`, and its common options are as follows:

* `-m` - Continuous monitoring of events
* `-r` - Recursive monitoring directory
* `-q` - Simplify output information
* `-e <events>,<event2>...` - Specifies the event type of monitoring data, multiple event types are separated by commas in English status

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
| delete_self | The file or directory has been deleted |
| unmount | File system containing unmounted files or directories |

For example:

```bash
[root@RL8.10 ~]# inotifywait -mrq -e create,delete /rsync/`
```

### Adjusting Linux kernel parameters

You can adjust the kernel parameters according to the needs of the production environment. By default, there are three files in **/proc/sys/fs/inotify/**.

```bash
[root@RL8.10 ~]# cd /proc/sys/fs/inotify/

[root@RL8.10 /proc/sys/fs/inotify]# cat max_queued_events ;cat max_user_instances ;cat max_user_watches
16384
128
28014
```

* max_queued_events - In a single inotify instance, the maximum length of the unprocessed event queue cached by the kernel is 16384 by default. When the queue is full, new events will be silently discarded and the IN_Q_OVERFLOW event will be triggered.
* max_user_instances - The maximum number of inotify instances that a single user (UID) can create within the system is 128 by default. Each time inotify_init() is called, a new instance is created.
* max_user_watches - The maximum total number of inotify monitoring points (watches) that a single user (UID) can create within the system is 8192 by default. This quota is shared among all instances, and each monitored file or directory consumes 1 monitoring point (watch).

In the production environment, the following content can be added to the **/etc/sysctl.conf** file:

```text
fs.inotify.max_user_instances  = 1024
fs.inotify.max_user_watches   = 1048576
fs.inotify.max_queued_events  = 1048576
```

### Demonstration of `inotifywait` command

Type the command in the first terminal pts/0, and the window is locked after pressing Enter, indicating that it is monitoring:

```bash
[root@RL8.10 ~]# inotifywait -mrq -e create,delete /rsync/
```

In the second terminal pts/1, go to the /rsync/ directory and create a file.

```bash
[root@RL8.10 ~]# cd /rsync/
[root@RL8.10 /rsync]# touch inotify
```

Back to the first terminal pts/0, the output information is as follows:

```text
/rsync/ CREATE inotify
```

Press ++"ctrl"+"c"++ in the locked window to exit.

## Combination of `inotifywait` and `rsync`

Create a new Bash script in 192.168.100.20/24 with the following content:

```bash
#!/bin/bash
a="inotifywait -mrq -e modify,move,create,delete /rsync/"
b="/usr/bin/rsync -avz /rsync/* synu1@192.168.100.21:/home/synu1/"
$a | while read directory event file
    do
        $b &>> /tmp/rsync.log
    done
```

```bash
[root@RL8.10 ~]# chmod a+x rsync_inotify.sh

[root@RL8.10 ~]# bash /root/rsync_inotify.sh &
```

The example diagram is as follows:

```mermaid
graph LR;
A(Source: RL 8.10) --> | SSH protocol | B(Target: RL 10.3)
```

Notes:

* Use Rsync SSH protocol to verify user identity
* RL 10.3 requires the existence of the **synu1** user
* RL 8.10 here is an SSH client, while RL 10.3 is an SSH server. In other words, you need to generate a key pair in the SSH client and modify the configuration file of the SSH server to complete the password-free authentication login
* Redirects the contents of the public key file generated by the SSH client to the **/home/synu1/.ssh/authorized_keys** file
* If the SSH server is using a non default port 22, it can also be specified separately in the script, for example `b="/usr/bin/rsync -avz -e 'ssh -p 2222' /rsync/* synu1@192.168.100.21:/home/synu1/"`

If the RSYNC protocol of the Rsync program is used, the example diagram is as follows:

```mermaid
graph LR;
A(Source: RL 8.10) --> | RSYNC protocol | B(Target: RL 10.3)
```

* The target machine RL 10.3 needs to configure the Rsync service and start the related daemon processes. Refer to the [Rsync demonstration](./02_rsync_demo.md) and [Rsync configure](./04_rsync_configure.md)
* The source machine RL 8.10 requires setting the relevant Rsync system variables and completing the password-free verification login. Refer to the [Rsync password-free verification login](./05_rsync_authentication-free_login.md)
