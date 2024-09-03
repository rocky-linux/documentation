---
title: Appendix A - Workstation Setup
author: Steven Spencer
contributors: Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - workstation
---

# Appendix A - workstation setup

While not a part of the chapters for an Incus Server, this procedure will help those who want to have a lab environment, or semi-permanent OS and application, running on a Rocky Linux workstation or notebook.

## Prerequisites

* comfortable at the command line
* able to use a command line editor, such as `vi` or `nano` fluently
* a need for a stable testing environment used every day or as needed
* able to become root or have `sudo` privileges

## Installation

From the command line, install the EPEL repository:

```bash
sudo dnf install epel-release -y
```

When installation finishes, do an upgrade:

```bash
sudo dnf upgrade
```

Install other repositories:

```bash
sudo dnf config-manager --enable crb
sudo copr enable neil/incus
```

Install some needed packages:

```bash
sudo dnf install dkms vim kernel-devel bash-completion
```

Install and enable Incus:

```bash
sudo dnf install incus incus-tools
sudo systemctl enable incus
```

Reboot your notebook or workstation

## Incus initialization

If you have looked through the production server chapters, this is nearly the same as the production server initialization procedure.

```bash
sudo incus admin init
```

This will start a question and answer dialog.

Here are the questions and our answers for the script, with a little explanation where warranted:

```text
Would you like to use clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: storage
```

Optionally, you can accept the default.

```text
Name of the storage backend to use (btrfs, dir, lvm, ceph) [default=btrfs]: dir
```

Note that `dir` is somewhat slower than `zfs`. If you have the foresight to leave a disk empty, you can use that device (example: /dev/sdb) for the `zfs` device and then select `zfs`.

```text
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
Would you like the Incus server to be available over the network? (yes/no) [default=no]: yes
```

This is necessary to snapshot the workstation. Answer "yes" here.

```text
Address to bind Incus to (not including port) [default=all]:
Port to bind Incus to [default=8443]:
Trust password for new clients:
Again:
```

This trust password is how you will connect to the snapshot server or back from the snapshot server. Set this with something that makes sense in your environment. Save this entry to a secure location, such as a password manager.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "incus admin init" preseed to be printed? (yes/no) [default=no]:
```

## User privileges

The next thing you need to do is to add your user to the `incus-admin` group. Again, you will need to use `sudo` or be root for this:

```text
sudo usermod -a -G incus-admin [username]
```

where [username] is your user on the system.

At this point, you have made a bunch of changes. Before you go any further, reboot your machine.

## Verifying the install

To ensure that `incus` started and that your user has privileges, from the shell prompt do:

```text
incus list
```

Note you have not used `sudo` here. Your user has the ability to enter these commands. You will see something like this:

```bash
+------------+---------+----------------------+------+-----------+-----------+
|    NAME    |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------+---------+----------------------+------+-----------+-----------+
```

If you do, you are looking good!

## The rest of it

From this point, you can use the chapters from our "Incus Production Server" to continue on. There are some things on a workstation setup though that you need to pay less attention to. Here are the recommended chapters to get you going:

* [Chapter 5 - Setting Up And Managing Images](05-incus_images.md)
* [Chapter 6 - Profiles](06-profiles.md)
* [Chapter 8 - Container Snapshots](08-snapshots.md)

## More reading

* [Official Incus Overview and Documentation](https://linuxcontainers.org/incus/docs/main/)

## Conclusion

Incus is a powerful tool that you can use on workstations or servers for increased productivity. On a workstation, it is great for lab testing, but can also keep semi-permanent instances of operating systems and applications available in their own private space.
