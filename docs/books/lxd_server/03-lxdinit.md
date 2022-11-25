---
title: 3 LXD Initialization and User Setup
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd initialization
  - lxd setup
---

# Chapter 3: LXD Initialization and User Setup

Throughout this chapter you will need to be root or able to `sudo` to become root. In addition, we are assuming that you have setup a ZFS storage pool as described in [Chapter 2](02-zfs_setup). You can use a different storage pool if you have chosen not to use ZFS, but you will need to make adjustments to the initialization questions and answers.

## LXD Initialization

Now that the environment is all set up, we are ready to initialize LXD. This is an automated script that asks a series of questions to get your LXD instance up and running:

```
lxd init
```

Here are the questions and our answers for the script, with a little explanation where warranted:

```
Would you like to use LXD clustering? (yes/no) [default=no]:
```

If you are interested in clustering, do some additional research on that [here](https://linuxcontainers.org/lxd/docs/master/clustering/)

```
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

This may seem counter-intuitive, since we have already created our ZFS pool, but it will be resolved in a later question. Accept the default.

```
Name of the new storage pool [default=default]: storage
```

You could leave this as default if you wanted to, but we have chosen to use the same name we gave our ZFS pool.

```
Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:
```

Obviously we want to accept the default.

```
Create a new ZFS pool? (yes/no) [default=yes]: no
```

Here's where the earlier question about creating a storage pool is resolved.

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

This is necessary to snapshot the server, so answer "yes" here.

```
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
```

This trust password is how you will connect to the snapshot server or back from the snapshot server, so set this with something that makes sense in your environment. Save this entry to a secure location, such as a password manager.

```
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

## Setting Up User Privileges

Before we continue on, we need to create our "lxdadmin" user and make sure that it has the privileges it needs. We need the "lxdadmin" user to be able to _sudo_ to root and we need it to be a member of the lxd group. To add the user and make sure it is a member of both groups do:

```
useradd -G wheel,lxd lxdadmin
```

Then set the password:

```
passwd lxdadmin
```

As with the other passwords, save this to a secure location.
