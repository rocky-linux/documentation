---
title: rsync brief description
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update : 2022-Mar-08
---

#  Backup Brief

What is a backup?

Backup refers to the duplication of data in the file system or database. In the event of an error or disaster, the effective data of the system can be restored in a timely manner and normal operation.

What are the backup methods?

* Full backup: refers to a one-time copy of all files, folders or data in the hard disk or database. (Pros: the best, can recover data faster. Disadvantages: take up a larger hard disk space.)
* Incremental backup: refers to the backup of the data updated after the last full backup or incremental backup. The process is like this, such as a full backup on the first day; a backup of the newly added data on the second day, as opposed to a full backup; on the third day, a backup of the newly added data on the basis of the second day, relative to the next day, and so on.
* Differential backup: Refers to the backup of the changed files after the full backup. For example, a full backup on the first day; a backup of the new data on the second day; a backup of the new data from the second day to the third day on the third day; and a backup of all the new data from the second day to the fourth day on the fourth day, and so on.
* Selective backup: Refers to backing up a part of the system.
* Cold backup: refers to the backup when the system is in shutdown or maintenance state. The backed up data is exactly the same as the data in the system during this period.
* Hot backup: Refers to the backup when the system is in normal operation. As the data in the system is updated at any time, the backed-up data has a certain lag relative to the real data of the system.
* Remote backup: refers to backing up data in another geographic location to avoid data loss and service interruption caused by fire, natural disasters, theft, etc.

##  rsync in brief

On a server, I backed up the first partition to the second partition, which is commonly known as "Local backup." The specific backup tools are `tar` , `dd` , `dump` , `cp `, etc. can be achieved. Although the data is backed up on this server, if the hardware fails to boot up properly, the data will not be retrieved. In order to solve this problem with the local backup, we introduced another kind of backup --- "remote backup".

Some people will say, can't I just use the `tar` or `cp` command on the first server and send it to the second server via `scp` or `sftp`?

In a production environment, the amount of data is relatively large. First of all, `tar` or `cp` consumes a lot of time and occupies system performance. Transmission via `scp` or `sftp` also occupies a lot of network bandwidth, which is not allowed in the actual production environment. Secondly, these commands or tools need to be manually entered by the administrator and need to be combined with the crontab of the scheduled task. However, the time set by crontab is not easy to grasp, and it is not appropriate for data to be backed up if the time is too short or too long.

Therefore, there needs to be a data backup in the production environment which needs to meet the following requirements:

1. Backups transmitted over the network
2. Real-time data file synchronization
3. Less occupancy of system resources and higher efficiency

`rsync` appears to meet the above needs. It uses the GNU open source license agreement. It is a fast incremental backup tool. The latest version is 3.2.3 (2020-08-06). You can visit the [Official website](https://rsync.samba.org/) for more information.

In terms of platform support, most Unix-like systems are supported, whether it is GNU/Linux or BSD. In addition, there are related `rsync` under the Windows platform, such as cwRsync.

The original `rsync` was maintained by the Australian programmer <font color=red>Andrew Tridgell</font> (shown in Figure 1 below), and now it has been maintained by <font color=red>Wayne Davison</font> (shown in Figure 2 below) ) For maintenance, you can go to [ github project address ](https://github.com/WayneD/rsync) to get the information you want.

![ Andrew Tridgell ](images/Andrew_Tridgell.jpg)
![ Wayne Davison ](images/Wayne_Davison.jpg)

!!! note "note"

    **rsync itself is only an incremental backup tool and does not have the function of real-time data synchronization (it needs to be supplemented by other programs). In addition, synchronization is one-way. If you want to realize two-way synchronization, you need to cooperate with other tools.**

###  Basic Principles and Features

How does `rsync` achieve efficient one-way data synchronization backup?

The core of `rsync` is its **Checksum algorithm**. For more information, you can go to [How Rsync works](https://rsync.samba.org/how-rsync-works.html) and [The rsync algorithm](https://rsync.samba.org/tech_report/). This section is beyond the author's competence and will not be covered too much.

The characteristics of `rsync` are:

* The entire directory can be updated recursively;
* Can selectively retain file synchronization attributes, such as hard link, soft link, owner, group, corresponding permissions, modification time, etc., and can retain some of the attributes;
* Support two protocols for transmission, one is ssh protocol, the other is rsync protocol
