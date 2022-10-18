---
title: Appendix A - Workstation Setup
author: Steven Spencer
contributors: 
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - workstation
---

# Appendix A - Workstation Setup

While not a part of the chapters for an LXD Server, this procedure will help those who wish to have a lab environment, or semi-permanent OS and application, running on a Rocky Linux workstation or laptop.

## Prerequisites

* comfortable at the command line
* able to use a command line editor, such as `vi` or `nano` fluently
* willing to install `snapd` in order to install LXD
* a desire for a stable testing environment that can be used every day or as needed
* able to become root or have `sudo` privileges

## Installation

From the command line, install the EPEL repository:

```
sudo dnf install epel-release 
```

Once installed, do an upgrade:

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

Reboot your laptop or workstation

Install the snap for LXD:

```
sudo snap install lxd
```

## LXD Initialization

If you've looked through the production server chapters, this is very similiar to the production server init procedure. 

```
sudo lxd init
```

This will bring up a question and answer dialog that looks like the following.

Here are the questions and our answers for the script, with a little explanation where warranted:

```
Would you like to use LXD clustering? (yes/no) [default=no]:
```

If you are interested in clustering, do some additional research on that [here](https://linuxcontainers.org/lxd/docs/master/clustering/)

```
Do you want to configure a new storage pool? (yes/no) [default=yes]:
Name of the new storage pool [default=default]: storage
```

Optionally, you can accept the default. Since we aren't using ZFS, it really is just a choice.

```
Name of the storage backend to use (btrfs, dir, lvm, ceph) [default=btrfs]: dir
```

Note that dir is somewhat slower than btrfs. If you have the forsight to leave a disk empty, you can use that device (example: /dev/sdb)
 as the btrfs device and then choose btrfs. dir will work fine

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

This is necessary to snapshot the server, so answer "yes" here.

```
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
```

This trust password is how you will connect to the snapshot server or back from the snapshot server, so set this with something that mak
es sense in your environment. Save this entry to a secure location, such as a password manager.

```
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

## User Privileges

The next thing you need to do is to add your user to the lxd group. Again, you will need to use `sudo` or be root for this:

```
sudo usermod -a -G lxd [username]
```

where [username] is your user on the system.

At this point, you've made a bunch of changes so before you go any further, reboot your machne.

## Verifying the Install

To make sure that `lxd` started and that your user has privileges, from the command prompt do:

```
lxc list
```

Note we have not used `sudo` here as your user should now have the ability to enter these commands.  You should get something like this in return:

```
+------------+---------+----------------------+------+-----------+-----------+
|    NAME    |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------+---------+----------------------+------+-----------+-----------+
```

If so, you're looking good so far!

## The Rest Of It

From this point, you can easily use the capters from our "LXD Production Server" to continue on. There are some things on a workstation setup though that we need to pay less attention to. Here are the recommended chapters to get you going:

* [Chapter 5 - Setting Up And Managing Images](05-lxd_images.md)
* [Chapter 6 - Profiles](06-profiles.md)
* [Chapter 8 - Container Snapshots](08-snapshots.md)

## More Reading

* [LXD Beginners Guide](../../guides/containers/lxd_web_servers.md) which will get you started using LXD productively.
* [Official LXD Overview](https://linuxcontainers.org/lxd/introduction/)
* [Official Documentation](https://linuxcontainers.org/lxd/docs/master/)

## Conclusion 

LXD is a powerful tool that can be used on workstations or servers for increased productivity. On a workstation, it is great for lab testing, but can just as easily keep semi-permanent instances of OS and applications available in their own private space. 





