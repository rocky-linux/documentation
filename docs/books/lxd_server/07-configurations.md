---
title: 7 Container Configuration Options
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd configuration
---

# Chapter 7: Container Configuration Options

Throughout this chapter you will need to execute commands as your unprivileged user ("lxdadmin" if you've been following from the beginning in this book).

There are a wealth of options for configuring the container once you have it installed. Before we get into how to see those, however, let's take a look at the info command for a container. In this example, we will use the ubuntu-test container:

```
lxc info ubuntu-test
```

This shows something like the following:

```
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

There's a lot of good information there, from the profiles applied, to the memory in use, disk space in use, and more.

### A Word About Configuration And Some Options

By default, LXD will allocate the required system memory, disk space, CPU cores, etc., to the container. But what if we want to be more specific? That is totally possible.

There are trade-offs to doing this, though. For instance, if we allocate system memory and the container doesn't actually use it all, then we have kept it from another container that might actually need it. The reverse, though, can happen. If a container is a complete pig on memory, then it can keep other containers from getting enough, thereby pinching their performance.

Just keep in mind that every action you make to configure a container _can_ have negative effects somewhere else.

Rather than run through all of the options for configuration, use the tab auto-complete to see the options available:

```
lxc config set ubuntu-test
```

and then hit TAB.

This shows you all of the options for configuring a container. If you have questions about what one of the configuration options does, head up to the [official documentation for LXD](https://linuxcontainers.org/lxd/docs/master/instances/) and do a search for the configuration parameter, or Google the entire string, such as "lxc config set limits.memory" and take a look at the results of the search.

We will look at a few of the most used configuration options. For example, if you want to set the max amount of memory that a container can use:

```
lxc config set ubuntu-test limits.memory 2GB
```

That says that as long as the memory is available to use, in other words there is 2GB of memory free, then the container can actually use more than 2GB if it's available. It's a soft limit, in other words.

```
lxc config set ubuntu-test limits.memory.enforce 2GB
```

That says that the container can never use more than 2GB of memory, whether it's currently available or not. In this case it's a hard limit.

```
lxc config set ubuntu-test limits.cpu 2
```

That says to limit the number of cpu cores that the container can use to 2.

!!! note

    When this document was rewritten for Rocky Linux 9.0, the ZFS repository for 9 was not available. For this reason all of our test containers were built using "dir" in the init process. That is why the example below shows a "dir" instead of "zfs" storage pool.

Remember when we set up our storage pool in the ZFS chapter?  We named the pool "storage," but we could have named it anything. If we want to look at this, we can use this command, which works equally well for any of the other pool types too (as shown for dir):

```
lxc storage show storage
```


This shows the following:

```
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

This shows that all of our containers are using our dir storage pool. When using ZFS, you can also set a disk quota on a container. Here's what that would look like setting a 2GB disk quota on the ubuntu-test container. You do this with:

```
lxc config device override ubuntu-test root size=2GB
```

As stated earlier, you should use configuration options sparingly, unless you've got a container that wants to use way more than its share of resources. LXD, for the most part, will manage the environment well on its own.

There are, of course, many more options that may be of interest to some people. You should do your own research to find out if any of those are of value in your environment.

