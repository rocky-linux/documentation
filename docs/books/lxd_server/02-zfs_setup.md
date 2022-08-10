---
title: 2 ZFS Setup
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd zfs
---

# Chapter 2: ZFS Setup

Throughout this chapter you will need to be the root user or able to `sudo` to become root.

If you have already installed ZFS, this section will walk you through ZFS setup.

## Enabling ZFS and setting Up the pool

First, enter this command:

```
/sbin/modprobe zfs
```

This should not return an error, it should simply return to the command prompt when done. If you get an error, stop now and begin troubleshooting. Again, make sure that secure boot is off as that will be the most likely culprit.

Next we need to take a look at the disks on our system, determine what has the OS loaded on it, and what is available to use for the ZFS pool. We will do this with _lsblk_:

```
lsblk
```

Which should return something like this (your system will be different!):

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

In this listing, we can see that */dev/sda* is in use by the operating system, so we are going to use */dev/sdb* for our zpool. Note that if you have multiple free hard drives, you may wish to consider using raidz (a software raid specifically for ZFS).

That falls outside the scope of this document, but should definitely be a consideration for production, as it offers better performance and redundancy. For now, let's create our pool on the single device we have identified:

```
zpool create storage /dev/sdb
```

What this says is to create a pool called "storage" that is ZFS on the device */dev/sdb*.

Once the pool is created, it's a good idea to reboot the server again at this point.
