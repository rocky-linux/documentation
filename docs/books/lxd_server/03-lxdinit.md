---
title: 3 LXD Initialization and User Setup
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd initialization
  - lxd setup
---

# Chapter 3: LXD initialization and user setup

Throughout this chapter you will need to be root or able to `sudo` to become root. In addition, the assumption is that you have setup a ZFS storage pool described in [Chapter 2](02-zfs_setup.md). You can use a different storage pool if you have chosen not to use ZFS, but you will need to make adjustments to the initialization questions and answers.

## LXD initialization

Your server environment is all set up. You are ready to initialize LXD. This is an automated script that asks a series of questions to get your LXD instance up and running:

```
lxd init
```

Here are the questions and our answers for the script, with a little explanation where warranted:

```
Would you like to use LXD clustering? (yes/no) [default=no]:
```

If interested in clustering, do some additional research on that [here](https://linuxcontainers.org/lxd/docs/master/clustering/)

```
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

This seems counter-intuitive. You have already created your ZFS pool, but it will become clear in a later question. Accept the default.

```
Name of the new storage pool [default=default]: storage
```

Leaving this "default" is an option, but for clarity, using the same name you gave our ZFS pool is better.

```
Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:
```

You want to accept the default.

```
Create a new ZFS pool? (yes/no) [default=yes]: no
```

Here is where the resolution of the earlier question about creating a storage pool comes into play.

```
Name of the existing ZFS pool or dataset: storage
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Metal As A Service (MAAS) is outside the scope of this document.

```
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=lxdbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

If you want to use IPv6 on your LXD containers, you can turn on this option. That is up to you.

```
Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
```

This is necessary to snapshot the server.

```
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
```

This trust password is how you will connect to the snapshot server or back from the snapshot server. Set this with something that makes sense in your environment. Save this entry to a secure location, such as a password manager.

```
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

## Setting up user privileges

Before you continue on, you need to create your "lxdadmin" user and ensure that it has the privileges it needs. You need the "lxdadmin" user to be able to `sudo` to root and you need it to be a member of the lxd group. To add the user and ensure it is a member of both groups do:

```
useradd -G wheel,lxd lxdadmin
```

Set the password:

```
passwd lxdadmin
```

As with the other passwords, save this to a secure location.
