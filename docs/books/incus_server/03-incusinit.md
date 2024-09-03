---
title: 3 Incus initialization and user setup
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus initialization
  - incus setup
---

Throughout this chapter you will need to be root or able to `sudo` to become root. In addition, the assumption is that you have setup a ZFS storage pool described in [Chapter 2](02-zfs_setup.md). You can use a different storage pool if you have chosen not to use ZFS, but you will need to make adjustments to the initialization questions and answers.

## Incus initialization

Your server environment is all set up. You are ready to initialize Incus. This is an automated script that asks a series of questions to get your Incus instance up and running:

```bash
incus admin init
```

Here are the questions and our answers for the script, with a little explanation where warranted:

```text
Would you like to use clustering? (yes/no) [default=no]:
```

If interested in clustering, do some additional research on that [here](https://linuxcontainers.org/incus/docs/main/explanation/clustering/)

```text
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

This seems counter-intuitive. You have already created your ZFS pool, but it will become clear in a later question. Accept the default.

```text
Name of the new storage pool [default=default]: storage
```

Leaving this "default" is an option, but for clarity, using the same name you gave our ZFS pool is better.

```text
Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:
```

You want to accept the default.

```text
Create a new ZFS pool? (yes/no) [default=yes]: no
```

Here is where the resolution of the earlier question about creating a storage pool comes into play.

```text
Name of the existing ZFS pool or dataset: storage
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Metal As A Service (MAAS) is outside the scope of this document.

```text
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

If you want to use IPv6 on your Incus containers, you can turn on this option. That is up to you.

```text
Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
```

This is necessary to snapshot the server.

```text
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
```

This trust password is how you will connect to the snapshot server or back from the snapshot server. Set this with something that makes sense in your environment. Save this entry to a secure location, such as a password manager.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "incus admin init" preseed to be printed? (yes/no) [default=no]:
```

## Setting up user privileges

Before you continue on, you need to create your "incusadmin" user and ensure that it has the privileges it needs. You need the "incusadmin" user to be able to `sudo` to root and you need it to be a member of the `incus-admin` group. To add the user and ensure it is a member of both groups do:

```bash
useradd -G wheel,incus-admin incusadmin
```

Set the password:

```bash
passwd incusadmin
```

As with the other passwords, save this to a secure location.

## Setting `subuid` and `subgid` values for `root`

You need to set both the value of the root user's `subuid` and `subgid`(the range of subordinate user and group id's). This value should be:

```bash
root:1000000:1000000000
```

To do this, edit the `/etc/subuid` and add that line. When completed, your file will be:

```bash
root:1000000:1000000000
```

Edit the `/etc/subgid` file and add that line. When completed, your file will be:

```bash
incusadmin:100000:65536
root:1000000:1000000000
```

Reboot the server before continuing.
