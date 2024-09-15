---
title: 7 Container Configuration Options
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with:  9.4
tags:
  - incus 
  - enterprise
  - incus configuration
---

Throughout this chapter, you will need to run commands as your unprivileged user ("incusadmin" if you've been following along since the beginning of this book).

There are a wealth of options for configuring the container after installation. Before seeing those, however, let us examine the `info` command for a container. In this example, you will use the ubuntu-test container:

```bash
incus info ubuntu-test
```

This will show the following:

```bash
Name: ubuntu-test
Location: none
Remote: unix://
Architecture: x86_64
Created: 2021/04/26 15:14 UTC
Status: Running
Type: container
Profiles: default, macvlan
Pid: 584710
Ips:
  eth0:    inet    192.168.1.201    enp3s0
  eth0:    inet6    fe80::216:3eff:fe10:6d6d    enp3s0
  lo:    inet    127.0.0.1
  lo:    inet6    ::1
Resources:
  Processes: 13
  Disk usage:
    root: 85.30MB
  CPU usage:
    CPU usage (in seconds): 1
  Memory usage:
    Memory (current): 99.16MB
    Memory (peak): 110.90MB
  Network usage:
    eth0:
      Bytes received: 53.56kB
      Bytes sent: 2.66kB
      Packets received: 876
      Packets sent: 36
    lo:
      Bytes received: 0B
      Bytes sent: 0B
      Packets received: 0
      Packets sent: 0
```

There is good information from the profiles applied to the memory, disk space in use, and more.

## A word about configuration and some options

Incus will assign the required system memory, disk space, CPU cores, and other resources to the container by default. But what if you want to be more specific? That is possible.

There are trade-offs to doing this. For instance, if you assign system memory and the container does not use it all, you have kept it from another container that might need it. The reverse can happen, too. If a container wants to use more than its share of memory, it can keep other containers from getting enough, thereby pinching their performance.

Just remember that every action you make to configure a container _can_ have adverse effects somewhere else.

Rather than run through all of the options for configuration, use the tab auto-complete to see the options available:

```bash
incus config set ubuntu-test
```

and ++tab++.

This shows you all of the options for configuring a container. If you have questions about what one of the configuration options does, head to the [official documentation for Incus](https://linuxcontainers.org/incus/docs/main/config-options/) and do a search for the configuration parameter, or Google the entire string, such as `incus config set limits.memory` and examine the results of the search.

Here, we examine a few of the most used configuration options. For example, if you want to set the maximum amount of memory that a container can use:

```bash
incus config set ubuntu-test limits.memory 2GB
```

That says that if the memory is available to use, for example, 2 GB, then the container can actually use more than 2GB. It is a soft limit, for example.

```bash
incus config set ubuntu-test limits.memory.enforce 2GB
```

That means the container can never use more than 2GB of memory, whether it is currently available or not. In this case, it is a hard limit.

```bash
incus config set ubuntu-test limits.cpu 2
```

That says limiting the number of CPU cores the container can use to 2.

!!! note

    When this document was rewritten for Rocky Linux 9.0, the ZFS repository for 9 was not available. For this reason, all of our test containers were built using "dir" in the init process. That is why the example below shows a "dir" storage pool instead of a "zfs" storage pool.

Remember when you set up our storage pool in the ZFS chapter? You named the pool "storage," but you could have named it anything. If you want to examine this, you can use this command, which works equally well for any of the other pool types too (as shown for dir):

```bash
incus storage show storage
```

This shows the following:

```bash
config:
  source: /var/snap/lxd/common/lxd/storage-pools/storage
description: ""
name: storage
driver: dir
used_by:
- /1.0/instances/rockylinux-test-8
- /1.0/instances/rockylinux-test-9
- /1.0/instances/ubuntu-test
- /1.0/profiles/default
status: Created
locations:
- none
```

This shows that all of our containers use our dir storage pool. When using ZFS, you can also set a disk quota on a container. Here is what that command looks like, setting a 2GB disk quota on the ubuntu-test container:

```bash
incus config device override ubuntu-test root size=2GB
```

As I said earlier, you can use configuration options sparingly unless you have a container that wants to use more resources than its share. Incus, for the most part, will manage the environment well.

Many more options exist that might be of interest to some people. Doing your own research will help you determine whether any of those are valuable in your environment.
