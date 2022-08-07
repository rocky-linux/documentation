---
title: 1 Install and Configuration
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd install
---

# Chapter 1: Install and Configuration

Throughout this section you will need to be the root user or you will need to be able to _sudo_ to root.

## Install EPEL and OpenZFS (8.6 Only) Repositories

LXD requires the EPEL (Extra Packages for Enterprise Linux) repository, which is easy to install using:

```
dnf install epel-release
```

Once installed, check for updates:

```
dnf update
```

If you're using ZFS, install the OpenZFS repository with:

```
dnf install https://zfsonlinux.org/epel/zfs-release.el8_6.noarch.rpm
```

We also need the GPG key, so use this command to get that:

```
gpg --import --import-options show-only /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
```

If there were kernel updates during the update process above, reboot your server

## Install snapd, dkms, vim, and kernel-devel

LXD must be installed from a snap for Rocky Linux. For this reason, we need to install `snapd` (and a few other useful programs) with:

```
dnf install snapd dkms vim kernel-devel
```

And now enable and start snapd:

```
systemctl enable snapd
```

And then run:

```
systemctl start snapd
```

Reboot the server before continuing here.

## Install LXD

Installing LXD requires the use of the snap command. At this point, we are just installing it, we are not doing the set up:

```
snap install lxd
```

## Install OpenZFS (8.6 Only)

```
dnf install zfs
```

## Environment Set up

Most server kernel settings are not sufficient to run a large number of containers. If we assume from the beginning that we will be using our server in production, then we need to make these changes up front to avoid errors such as "Too many open files" from occurring.

Luckily, tweaking the settings for LXD is easy with a few file modifications and a reboot.

### Modifying limits.conf

The first file we need to modify is the limits.conf file. This file is self-documented, so look at the explanations in the file as to what this file does. To make our modifications type:

```
vi /etc/security/limits.conf
```

This entire file is remarked/commented out and, at the bottom, shows the current default settings. In the blank space above the end of file marker (#End of file) we need to add our custom settings. The end of the file will look like this when you are done:

```
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Save your changes and exit. (`SHIFT:wq!` for _vi_)

### Modifying sysctl.conf With 90-lxd.override.conf

With _systemd_, we can make changes to our system's overall configuration and kernel options *without* modifying the main configuration file. Instead, we'll put our settings in a separate file that will simply override the particular settings we need.

To make these kernel changes, we are going to create a file called _90-lxd-override.conf_ in /etc/sysctl.d. To do this type:

```
vi /etc/sysctl.d/90-lxd-override.conf
```

Place the following content in that file. Note that if you are wondering what we are doing here, the file content below is self-documenting:

```
## The following changes have been made for LXD ##

# fs.inotify.max_queued_events specifies an upper limit on the number of events that can be queued to the corresponding inotify instance
 - (default is 16384)

fs.inotify.max_queued_events = 1048576

# fs.inotify.max_user_instances This specifies an upper limit on the number of inotify instances that can be created per real user ID -
(default value is 128)

fs.inotify.max_user_instances = 1048576

# fs.inotify.max_user_watches specifies an upper limit on the number of watches that can be created per real user ID - (default is 8192)

fs.inotify.max_user_watches = 1048576

# vm.max_map_count contains the maximum number of memory map areas a process may have. Memory map areas are used as a side-effect of cal
ling malloc, directly by mmap and mprotect, and also when loading shared libraries - (default is 65530)

vm.max_map_count = 262144

# kernel.dmesg_restrict denies container access to the messages in the kernel ring buffer. Please note that this also will deny access t
o non-root users on the host system - (default is 0)

kernel.dmesg_restrict = 1

# This is the maximum number of entries in ARP table (IPv4). You should increase this if you create over 1024 containers.

net.ipv4.neigh.default.gc_thresh3 = 8192

# This is the maximum number of entries in ARP table (IPv6). You should increase this if you plan to create over 1024 containers.Not nee
ded if not using IPv6, but...

net.ipv6.neigh.default.gc_thresh3 = 8192

# This is a limit on the size of eBPF JIT allocations which is usually set to PAGE_SIZE * 40000.

net.core.bpf_jit_limit = 3000000000

# This is the maximum number of keys a non-root user can use, should be higher than the number of containers

kernel.keys.maxkeys = 2000

# This is the maximum size of the keyring non-root users can use

kernel.keys.maxbytes = 2000000

# This is the maximum number of concurrent async I/O operations. You might need to increase it further if you have a lot of workloads th
at use the AIO subsystem (e.g. MySQL)

fs.aio-max-nr = 524288
```

Save your changes and exit.

At this point you should reboot the server.

### Checking _sysctl.conf_ Values

Once the reboot has been completed, log back in as to the server. We need to spot check that our override file has actually done the job.

This is easy to do. There's no need to check every setting unless you want to, but checking a few will verify that the settings have been changed. This is done with the _sysctl_ command:

```
sysctl net.core.bpf_jit_limit
```

Which should show you:

```
net.core.bpf_jit_limit = 3000000000
```

Do the same with a few other settings in the override file (above) to verify that changes have been made.

### Enabling ZFS And Setting Up The Pool (8.6 Only)

If you have UEFI secure boot turned off, this should be fairly easy.  First, load the ZFS module with modprobe:

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
