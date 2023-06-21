---
title: 2 ZFS Setup
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd zfs
---

# Chapter 2: ZFS setup

Throughout this chapter you will need to be the root user or able to `sudo` to become root.

If you have already installed ZFS, this section will walk you through ZFS setup.

## Enabling ZFS and setting up the pool

First, enter this command:

```
/sbin/modprobe zfs
```

If there are no errors, it will return to the prompt and echo nothing. If you get an error, stop now and begin troubleshooting. Again, ensure that secure boot is off. That will be the most likely culprit.

Next you need to examine the disks on our system, find out where the operating system is, and what is available to use for the ZFS pool. You will do this with `lsblk`:

```
lsblk
```

Which will return something like this (your system will be different!):

```
AME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0    7:0    0  32.3M  1 loop /var/lib/snapd/snap/snapd/11588
loop1    7:1    0  55.5M  1 loop /var/lib/snapd/snap/core18/1997
loop2    7:2    0  68.8M  1 loop /var/lib/snapd/snap/lxd/20037
sda      8:0    0 119.2G  0 disk
├─sda1   8:1    0   600M  0 part /boot/efi
├─sda2   8:2    0     1G  0 part /boot
├─sda3   8:3    0  11.9G  0 part [SWAP]
├─sda4   8:4    0     2G  0 part /home
└─sda5   8:5    0 103.7G  0 part /
sdb      8:16   0 119.2G  0 disk
├─sdb1   8:17   0 119.2G  0 part
└─sdb9   8:25   0     8M  0 part
sdc      8:32   0 149.1G  0 disk
└─sdc1   8:33   0 149.1G  0 part
```

In this listing, you can see that */dev/sda* is in use by the operating system. You are going to use */dev/sdb* for our zpool. Note that if you have many available hard drives, you may want to consider using raidz (a software raid specifically for ZFS).

That falls outside the scope of this document, but definitely is a consideration for production. It offers better performance and redundancy. For now, create your pool on the single device you have identified:

```
zpool create storage /dev/sdb
```

What this says is to create a pool called "storage" that is ZFS on the device */dev/sdb*.

After creating the pool, reboot the server again.
