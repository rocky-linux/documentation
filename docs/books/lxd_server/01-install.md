---
title: 1 Install and Configuration
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd install
---

# Chapter 1: Install and configuration

Throughout this chapter you will need to be the root user or you will need to be able to _sudo_ to root.

## Install EPEL and OpenZFS repositories

LXD requires the EPEL (Extra Packages for Enterprise Linux) repository, which is easy to install using:

```
dnf install epel-release
```

When installed, verify there are no updates:

```
dnf upgrade
```

If there were any kernel updates during the upgrade process, reboot the server.

### OpenZFS repository for 8 and 9

Install the OpenZFS repository with:

```
dnf install https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm
```

## Install `snapd`, `dkms`, `vim`, and `kernel-devel`

LXD installation is from a snap on Rocky Linux. For this reason, you need to install `snapd` (and a few other useful programs) with:

```
dnf install snapd dkms vim kernel-devel
```

Now enable and start snapd:

```
systemctl enable snapd
```

Then run:

```
systemctl start snapd
```

Reboot the server before continuing here.

## Install LXD

Installing LXD requires the use of the snap command. At this point, you are just installing it, you are not doing the set up:

```
snap install lxd
```

## Install OpenZFS 

```
dnf install zfs
```

## Environment set up

Most server kernel settings are not sufficient to run a large number of containers. If you assume from the beginning that you will use your server in production, you need to make these changes up front to avoid errors such as "Too many open files" from occurring.

Luckily, tweaking the settings for LXD is not hard with a few file modifications and a reboot.

### Modifying `limits.conf`

The first file you need to change is the `limits.conf` file. This file is self-documented. Examine the explanations in the comment in the file to understand what this file does. To make your modifications enter:

```
vi /etc/security/limits.conf
```

This entire file consists of comments, and at the bottom, shows the current default settings. In the blank space above the end of file marker (#End of file) you need to add our custom settings. The end of the file will look like this when completed:

```
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Save your changes and exit. (<kbd>SHIFT</kbd>+<kbd>:</kbd>+<kbd>wq!</kbd> for _vi_)

### Modifying sysctl.conf with `90-lxd.override.conf`

With _systemd_, you can make changes to your system's overall configuration and kernel options *without* modifying the main configuration file. Instead, put your settings in a separate file that will override the particular settings you need.

To make these kernel changes, you are going to create a file called `90-lxd-override.conf` in `/etc/sysctl.d`. To do this type:

```
vi /etc/sysctl.d/90-lxd-override.conf
```

!!! warning "RL 9 and MAX value of `net.core.bpf_jit_limit`"

    Because of recent kernel security updates, the max value of `net.core.bpf_jit_limit` appears to be 1000000000. Please adjust this value in the self-documenting file below if you are running Rocky Linux 9.x. If you set it above this limit **OR** if you fail to set it at all, it will default to the system default of 264241152, which may not be enough if you run a large number of containers.

Place the following content in that file. Note that if you are wondering what you are doing here, the file content is self-documenting:

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

# This is a limit on the size of eBPF JIT allocations which is usually set to PAGE_SIZE * 40000. Set this to 1000000000 if you are running Rocky Linux 9.x

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

At this point reboot the server.

### Checking _sysctl.conf_ values

After the reboot, log back in as the root user to the server. You need to check that our override file has actually completed the job.

This is not hard to do. There's no need to verify every setting unless you want to, but checking a few will verify that the settings have changed. Do this with the `sysctl` command:

```
sysctl net.core.bpf_jit_limit
```

Which will show you:

```
net.core.bpf_jit_limit = 3000000000
```

Do the same with a few other settings in the override file to verify the changes.
