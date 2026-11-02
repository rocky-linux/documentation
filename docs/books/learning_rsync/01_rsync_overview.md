---
title: `rsync` brief description
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update : 2026-Nov-02
---

## Backup

Before explaining Rsync in detail, it is necessary to first understand the concept, classification, and implementation methods of backup.

**Backup refers to the act of copying data from a file system or database system to another independent storage medium. You use this operation to prevent the original data from being lost or damaged due to accidents such as accidental deletion, hardware failures, and virus attacks. You can then quickly restore valid data through the backup copy to ensure the normal operation of the business.**

Common backup categories include:

* Divided by backup objects

    * System backup - You perform a full backup of the operating system in advance. When the system files get corrupted and the system fails to boot, you can quickly restore the required environment through the backup.
    * Data backup - This is a backup for business data such as files, databases, and applications, used for precise recovery after data loss. This backup also includes selective backup, which represents backing up a portion of business data.

* Divided by backup content

    * Full backup - Create a complete copy of all data at a designated point in time. This operation consumes substantial storage space for backup files and requires a relatively long execution duration, yet complete the data restoration process with the highest level of convenience.
    * ‌Incremental backup‌ - Back up only the newly added and modified parts after the last full backup or incremental backup. Deliver fast backup speed and occupy minimal storage space, yet require the superposition of multiple backup copies during the restoration process.
    * Differential backup‌ - After completing a full backup, back up only the data that has been newly added or modified since that full backup. During restoration, only the full backup plus the latest differential backup are required. It features fewer restoration steps than incremental backup, but the backup volume grows larger over time than that of incremental backup.

* Divided by operating status

    * Cold backup‌ - A backup performed while the operating system or application is in a shutdown or maintenance state. The backup data at this time is identical to the data in the system during that time period.
    * Hot backup‌ - A backup taken while the operating system or application is running normally. Because the operating system or application is running, the data is constantly being updated, which results in a certain degree of lag between the backup data and the system’s actual data.

The main methods for implementing backups include:

* Local media backup - Regularly back up data to storage devices such as external hard drives, tape libraries, and local standalone disks
* Remote off-site backup - Transmit data over the network to another remote backup center to prevent data loss and service interruptions caused by fires, natural disasters, theft, and other incidents.

## The emergence of Rsync

In GNU/Linux, common tools for local media backup include:

* `tar`
* `dd`
* `dump`
* `cp`
* ...

When backing up existing local data, you can store the backup file on the current storage medium or on an additional independent storage medium. However, both the currently used storage media and standalone storage media may be damaged. To prevent this risk, an additional backup method should be adopted, which is remote off-site backup.

On the other hand, the data volume in the production environment is extremely large. If you use traditional and commonly seen tools, such as:

* `tar` or `cp` - It will consume a lot of time and take up system performance
* `scp` or `sftp` - Transmitting backup data over the network consumes a significant amount of bandwidth.
* Other - Often used in conjunction with `crontab`, but `crontab` can only be blindly executed on a fixed cycle and cannot sense data changes, making it difficult to achieve efficient incremental backups

Therefore, there needs to be a data backup in the production environment which needs to meet the following requirements:

1. Backups transmitted over the network
2. Real-time data file synchronization
3. Less occupancy of system resources and higher efficiency

Rsync is an ideal tool that meets the above conditions. It uses the GNU open source license and is a fast incremental backup tool. The latest version is 3.5.1 (2026-09-21). You can visit the [Official website](https://rsync.samba.org/) for more information.

In terms of platform support, most Unix-like systems are supported, whether it is GNU/Linux or BSD. In addition, there are related Rsync under the Windows platform, such as cwRsync.

The original version of Rsync was developed and maintained by Australian programmer **Andrew Tridgell** (yes, the same programmer who developed Samba), and was maintained by **Wayne Davison** from 2004 to 2024. You can find more information on the [GitHub project page](https://github.com/RsyncProject/rsync).

![Andrew Tridgell](images/Andrew_Tridgell.jpg)
![Wayne Davison](images/Wayne_Davison.jpg)

!!! note "Note"

    **Rsync itself is only an incremental backup tool and does not have the function of real-time data synchronization (it needs to be supplemented by other programs). In addition, synchronization is one-way. If you want to realize two-way synchronization, you need to cooperate with other tools.**

### Basic Principles and Features

Rsync enables efficient one-way data synchronization, primarily through **rolling checksum** or **delta encoding** algorithms. For more information, you can go to [How Rsync works](https://rsync.samba.org/how-rsync-works.html) and [The rsync algorithm](https://rsync.samba.org/tech_report/).

The main features of Rsync include:

* Can update the entire directory recursively
* Support incremental transmission to save bandwidth
* Compressible data during transmission
* Capable of breakpoint continuation
* Can selectively preserve file synchronization properties
* Supports two protocols for data transmission, one is SSH protocol and the other is RSYNC protocol

### Install Rsync

Whether you are using RL 8.x, RL 9.x, or RL 10.x, simply type the following command to complete the installation:

```bash
[root@Rocky ~]# dnf -y install rsync
```
