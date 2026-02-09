---
title: Creating a Custom Rocky Linux ISO
author: Howard Van Der Wal
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9
tags:
- create
- custom
- ISO
- kickstart
- linux
- mkksiso
- rocky
---

**Knowledge**: :star: :star: 
**Reading time**: 10 minutes

## Introduction

There are many reasons for creating an ISO. Perhaps you want to modify the boot process, add specific packages during installation, or update specific configuration files.

This guide will instruct you on how to build your own Rocky Linux ISO.

## Prerequisites

* Rocky Linux Minimal ISO image (the DVD image is not required).
* `kickstart` file to apply to the ISO.
* Read the [Lorax Quickstart](https://weldr.io/lorax/lorax.html#quickstart) and [mkksiso](https://weldr.io/lorax/mkksiso.html) documentation to become familiar with how to create an ISO.

## Package installation and setup

* Install the `lorax` package:

```bash
dnf install -y lorax
```

## Building the ISO with a kickstart file

* Run the `mkksiso` command to add a `kickstart` file and then build a new ISO. Note that you need to run the command as `root` or a user with `sudo` privileges:

```bash
mkksiso --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO> <PATH_TO_NEW_ISO>
```

## Adding a repository with its packages to an ISO image

* Make sure the repository you want to add has the `repodata` directory inside of it. If not, you can create this using the `createrepo_c` command and install it with `dnf install -y createrepo_c`
* Add the repository to your `kickstart` file, using the following syntax:

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/<REPOSITORY>/
```

* Add your repository using the `--add` flag with the `mkksiso` tool:

```bash
mkksiso --add <LINK_TO_REPOSITORY> --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO> <PATH_TO_NEW_ISO>
```

* You can see additional details of this process using the `baseos` repository in the example below.
* The `baseos` repository will be downloaded locally, along with all of its packages:

```bash
dnf reposync -p ~ --download-metadata --repo=baseos
```

* Then add the repository to your `kickstart` file:

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
```

* Then point the `mkksiso` command directly to the repository directory and build the ISO:

```bash
mkksiso --add ~/baseos --ks <PATH_TO_KICKSTART_FILE> ~/<PATH_TO_ISO> ~/<PATH_TO_NEW_ISO>
```

## Conclusion

Once your ISO is built with your kickstart file, it becomes much easier to deploy hundreds of machines from a single image without configuring each machine individually. To learn more about `kickstart` files, along with multiple examples, please check out the [Kickstart Files and Rocky Linux guide](../../automation/kickstart-rocky/). 
