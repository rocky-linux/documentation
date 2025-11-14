---
title: 1 Install and Configuration
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus install
---

Throughout this chapter, you must be the root user or be able to *sudo* to root.

## Install EPEL and OpenZFS repositories

Incus requires the EPEL (Extra Packages for Enterprise Linux) repository, which is easy to install using:

```bash
dnf install epel-release -y
```

When installed, verify there are no updates:

```bash
dnf upgrade
```

If there were kernel updates during the upgrade process, reboot the server.

### OpenZFS repository

Install the OpenZFS repository with:

```bash
dnf install https://zfsonlinux.org/epel/zfs-release-2-8$(rpm --eval "%{dist}").noarch.rpm
```

## Install `dkms`, `vim`, and `kernel-devel`

Install some needed packages:

```bash
dnf install dkms vim kernel-devel bash-completion
```

## Install Incus

You will need the CRB repository available for some special packages and Neil Hanlon's COPR (Cool Other Package Repo):

```bash
dnf config-manager --enable crb
dnf copr enable neil/incus
dnf install incus incus-tools
```

Enable and start the service:

```bash
systemctl enable incus --now
```

Reboot the server before continuing here.

## Install OpenZFS

```bash
dnf install zfs
```

## Environment set up

More than most server kernel settings is required to run many containers. If you assume from the beginning that you will use your server in production, you need to make these changes up front to avoid errors such as "Too many open files" from occurring.

Luckily, tweaking the settings for Incus is not hard with a few file modifications and a reboot.

### Modifying `limits.conf`

The first file you must change is the `limits.conf` file. This file is self-documented. Examine the explanations in the comment in the file to understand what this file does. To make your modifications, enter:

```bash
vi /etc/security/limits.conf
```

This entire file consists of comments and, at the bottom, shows the current default settings. You need to add our custom settings in the blank space above the end of the file marker (#End of file). The end of the file will look like this when completed:

```text
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Save your changes and exit (++shift+colon+"w"+"q"+exclam++ for *vi*).

### Modifying `sysctl.conf` with `90-incus-override.conf`

With *systemd*, you can change your system's overall configuration and kernel options *without* modifying the main configuration file. Instead, put your settings in a separate file that will override the particular settings you need.

To make these kernel changes, you will create a file called `90-incus-override.conf` in `/etc/sysctl.d`. To do this, type the following:

```bash
vi /etc/sysctl.d/90-incus-override.conf
```

Place the following content in that file. Note that if you are wondering what you are doing here, the file content is self-documenting:

```bash
## The following changes have been made for LXD ##

# fs.inotify.max_queued_events specifies an upper limit on the number of events that can be queued to the corresponding inotify instance - (default is 16384)

fs.inotify.max_queued_events = 1048576

# fs.inotify.max_user_instances This specifies an upper limit on the number of inotify instances that can be created per real user ID - (default value is 128)

fs.inotify.max_user_instances = 1048576

# fs.inotify.max_user_watches specifies an upper limit on the number of watches that can be created per real user ID - (default is 8192)

fs.inotify.max_user_watches = 1048576

# vm.max_map_count contains the maximum number of memory map areas a process may have. Memory map areas are used as a side-effect of calling malloc, directly by mmap and mprotect, and also when loading shared libraries - (default is 65530)

vm.max_map_count = 262144

# kernel.dmesg_restrict denies container access to the messages in the kernel ring buffer. Please note that this also will deny access to non-root users on the host system - (default is 0)

kernel.dmesg_restrict = 1

# This is the maximum number of entries in ARP table (IPv4). You should increase this if you create over 1024 containers.

net.ipv4.neigh.default.gc_thresh3 = 8192

# This is the maximum number of entries in ARP table (IPv6). You should increase this if you plan to create over 1024 containers.Not needed if not using IPv6, but...

net.ipv6.neigh.default.gc_thresh3 = 8192

# This is a limit on the size of eBPF JIT allocations which is usually set to PAGE_SIZE * 40000. Set this to 1000000000 if you are running Rocky Linux 9.x

net.core.bpf_jit_limit = 1000000000

# This is the maximum number of keys a non-root user can use, should be higher than the number of containers

kernel.keys.maxkeys = 2000

# This is the maximum size of the keyring non-root users can use

kernel.keys.maxbytes = 2000000

# This is the maximum number of concurrent async I/O operations. You might need to increase it further if you have a lot of workloads that use the AIO subsystem (e.g. MySQL)

fs.aio-max-nr = 524288
```

Save your changes and exit.

At this point, reboot the server.

### Checking `sysctl.conf` values

After the reboot, log back in as the root user to the server. You need to check that our override file has actually completed the job.

This is not hard to do. There's no need to verify every setting unless you want to, but checking a few will verify that the settings have changed. Do this with the `sysctl` command:

```bash
sysctl net.core.bpf_jit_limit
```

Which will show you:

```bash
net.core.bpf_jit_limit = 1000000000 
```

Do the same with a few other settings in the override file to verify the changes.
