---
title: Creating a Custom Rocky Linux ISO
author: Howard Van Der Wal
contributors: Steven Spencer
tested with: 9.5
tags:
- create
- custom
- ISO
---

## Introduction

You might need to Create a custom ISO for a many reasons. Perhaps you want to make a change to the boot process, add specific packages, or update a configuration file.

This guide will instruct you from start to finish on how to build your own Rocky Linux ISO.

## Prerequisites

* A 64 bit machine running Rocky Linux 9 to build the new ISO image.
* A Rocky Linux 9 DVD ISO image.
* A `kickstart` file to apply to the ISO.
* Read the Lorax [Quickstart](https://weldr.io/lorax/lorax.html#quickstart) and [mkksiso](https://weldr.io/lorax/mkksiso.html) documentation to become familiar with how to create the `Anaconda` `boot.iso`.

## Package installation and setup

* Install the `lorax` package:

```bash
sudo dnf install -y lorax
```

## Building the ISO with a kickstart file

* Run the `mkksiso` command to add a `kickstart` file and then build a new ISO:

```bash
mkksiso --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO_TO_MODIFY> <OUTPUT_PATH_FOR_BUILT_ISO>
```

* Below is an example `kickstart` file `example-ks.cfg`, which sets up a Rocky Linux 9.5 `Server With GUI` environment:

```bash
lang en_GB
keyboard --xlayouts='us'
timezone Asia/Tokyo --utc
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp
firstboot --disable
selinux --enforcing
firewall --enabled
%packages
@^server-product-environment
%end
```

## Adding a repository with its packages to an ISO image

* Make sure the repository you want to add has the `repodata` directory inside of it. If not, you can create this using the `createrepo_c` command and install it with `sudo dnf install -y createrepo_c`
* Add the repository to your `kickstart` file, using the following syntax:

```bash

repo --name=extra-repo --baseurl=file:///run/install/repo/<YOUR_REPOSITORY>/
```

* Add your repository using the `--add` flag with the `mkksiso` tool:

```bash
mkksiso --add <LINK_TO_YOUR_REPOSITORY> --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO_TO_MODIFY> <OUTPUT_PATH_FOR_BUILT_ISO>
```

* You can see additional details of this process using the `baseos` repository in the example below
* The `base os` repository will be locally downloaded along with all of its packages:

```bash
dnf reposync -p ~ --download-metadata --repo=baseos
```

* Then add the repository to the `kickstart` file:

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
```

* The `kickstart` file would look like the following:

```bash
lang en_GB
keyboard --xlayouts='us'
timezone Asia/Tokyo --utc
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp
firstboot --disable
selinux --enforcing
firewall --enabled
%packages
@^server-product-environment
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
%end
```

* Then point the `mkksiso` command directly to the repository directory and build the ISO:

```bash
mkksiso --add ~/baseos --ks example-ks.cfg ~/Rocky-9.5-x86_64-dvd.iso ~/Rocky-9.5-x86_64-dvd-new.iso
```

## Conclusion

What has been discussed here are just a few of the options available to tweak and build your own Rocky Linux ISO. For further ways, including modifying the kernel cmdline arguments, the author highly recommends to go through the [mkksiso](https://weldr.io/lorax/mkksiso.html) documentation in more detail.
