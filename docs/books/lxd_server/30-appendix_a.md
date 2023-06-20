---
title: Appendix A - Workstation Setup
author: Steven Spencer
contributors: 
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - workstation
---

# Appendix A - workstation setup

While not a part of the chapters for an LXD Server, this procedure will help those who wish to have a lab environment, or semi-permanent OS and application, running on a Rocky Linux workstation or laptop.

## Prerequisites

* comfortable at the command line
* able to use a command line editor, such as `vi` or `nano` fluently
* willing to install `snapd` to install LXD
* a need for a stable testing environment used every day or as needed
* able to become root or have `sudo` privileges

## Installation

From the command line, install the EPEL repository:

```
sudo dnf install epel-release 
```

When installation finishes, do an upgrade:

```
sudo dnf upgrade
```

Install `snapd`

```
sudo dnf install snapd 
```

Enable the `snapd` service

```
sudo systemctl enable snapd
```

Reboot your notebook or workstation

Install the snap for LXD:

```
sudo snap install lxd
```

## LXD initialization

If you have looked through the production server chapters, this is nearly the same as the production server init procedure. 

```
sudo lxd init
```

This will start a question and answer dialog. 

Here are the questions and our answers for the script, with a little explanation where warranted:

```
Would you like to use LXD clustering? (yes/no) [default=no]:
```

If you have interest in clustering, do some additional research on that [at Linux containers here](https://linuxcontainers.org/lxd/docs/master/clustering/).

```
Do you want to configure a new storage pool? (yes/no) [default=yes]:
Name of the new storage pool [default=default]: storage
```

Optionally, you can accept the default. 

```
Name of the storage backend to use (btrfs, dir, lvm, ceph) [default=btrfs]: dir
```

Note that `dir` is somewhat slower than `btrfs`. If you have the foresight to leave a disk empty, you can use that device (example: /dev/sdb) for the `btrfs` device and then select `btrfs`, but only if your host computer has an operating system that supports `btrfs`. Rocky Linux and any RHEL clone will not support `btrfs` - not yet, anyway. `dir` will work fine for a lab environment.

```
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

This is necessary to snapshot the workstation. Answer "yes" here.

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

## User privileges

The next thing you need to do is to add your user to the lxd group. Again, you will need to use `sudo` or be root for this:

```
sudo usermod -a -G lxd [username]
```

where [username] is your user on the system.

At this point, you have made a bunch of changes. Before you go any further, reboot your machine.

## Verifying the install

To ensure that `lxd` started and that your user has privileges, from the shell prompt do:

```
lxc list
```

Note you have not used `sudo` here. Your user has the ability to enter these commands. You will see something like this:

```
+------------+---------+----------------------+------+-----------+-----------+
|    NAME    |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------+---------+----------------------+------+-----------+-----------+
```

If you do, you are looking good!

## The rest of it

From this point, you can easily use the capters from our "LXD Production Server" to continue on. There are some things on a workstation setup though that we need to pay less attention to. Here are the recommended chapters to get you going:

* [Chapter 5 - Setting Up And Managing Images](05-lxd_images.md)
* [Chapter 6 - Profiles](06-profiles.md)
* [Chapter 8 - Container Snapshots](08-snapshots.md)

## More reading

* [LXD Beginners Guide](../../guides/containers/lxd_web_servers.md) which will get you started using LXD productively.
* [Official LXD Overview](https://linuxcontainers.org/lxd/introduction/)
* [Official Documentation](https://linuxcontainers.org/lxd/docs/master/)

## Conclusion 

LXD is a powerful tool that you can use on workstations or servers for increased productivity. On a workstation, it is great for lab testing, but can also keep semi-permanent instances of operating systems and applications available in their own private space. 
