---
title: Updating versions of Rocky
author: Steven Spencer
contributors:
---

(OR **How to duplicate a machine install**)

## Introduction

Since day one of the Rocky Linux project, there are those who have asked: ==How do you upgrade from CentOS 7 to Rocky 8, or Rocky 8 to Rocky 9?== The answer is always the same: **The project does not support in-place upgrades of one major version to another major version. You need to reinstall to move to the next major version.** To be clear, this **IS** the correct answer. This document hopes to give users a method of moving from one major version to the next, using the correct Rocky supported procedure of a fresh installation.

!!! note "Caveats"

    Even given this procedure, many things can go wrong when going from an older version of one operating system (OS) to a newer version of the same or different OS. Programs become obsolete, replaced by the maintainers as completely different package names, or the names simply do not match up from one OS to the next. In addition, you need to know about your machine's repositories and verify that they exist for the new OS. If going from a much older version to a much newer version, ensure that your CPU and other machine requirements match the new version. For this reason, you must remain cautious and note any errors or problems while performing this procedure. Here, the author has used Rocky Linux 8 as the old version and Rocky Linux 9 as the new major version. The formulation of all examples uses these two versions. Always proceed at your own risk.

## Example old machine

The old machine used here is Rocky Linux 8. In the example machine, the installation of the Extra Packages for Enterprise Linux (EPEL) repository and a few packages exist.

!!! info "Code Ready Builder"

    In Rocky Linux 8, and in other branded versions of 8, the Code Ready Builder (CRB) repository that exists in 9 is PowerTools. If moving from an 8 version to 9 where you have the EPEL, you will need to enable the CRB on your new machine with:

    ```bash
    sudo dnf config-manager --enable crb
    ```

### Obtain a list of users

You will need to create any users on the new machine manually, so you need to know what user accounts you will need to create. User accounts generally start at user id 1000, and increment upwards.

```bash
sudo getent passwd > userid.txt
```

### Obtain a list of repositories

You need a list of the repositories that exist on the old machine:

```bash
sudo ls -al /etc/yum.repos.d/ > repolist.txt
```

### Obtain a list of packages

Generate the package list with:

```bash
sudo dnf list installed | awk 'NR>1 {print $1}' | sort -u > installed.txt
```

Here the `NR>1` eliminates record one from the column, which has the "Installed" that came from the `dnf list installed` command. It is not a package, so you do not need it. The `{print $1}` means, only use column one. You do not need the package version or the repository it came from in the listing.

You will not need to install any kernel related packages. That said, it does not hurt to install them again, if you leave this step out. You can remove the kernel lines with:

```bash
sudo sed -i '/kernel/d' installed.txt
```

### Backup any data

This can encompass many things. Ensure you know the purpose of the machine you are replacing and all of its program components (database, mail server, DNS, more). If in doubt, back it up.

### Copy files

Copy the text files you created to a non-volatile location along with all of the backup data.

## Example new machine

Your installation of Rocky Linux 9 is complete. You are ready to start copying your text files and backups from where you stored them in the earlier procedure.

### Create the users

Examine the `userid.txt` file and create the users you need on the new machine.

### Install the repositories

Examine the `repolist.txt` file and manually install the repositories you need. You can ignore the Rocky-related repositories. Remember that we have packages from the EPEL, so you will need the CRB repository, rather than PowerTools:

```bash
sudo dnf config-manager --enable crb
```

Install the EPEL:

```bash
sudo dnf install epel-release
```

Install any other repositories from the `repolist.txt` file that are not Rocky or EPEL based.

Once installation of the repositories completes, try to install your packages from `installed.txt`:  

```bash
sudo dnf -y install $(cat installed.txt)
```

There are going to be some packages that do not exist between Rocky Linux 8 and Rocky Linux 9, regardless of the repositories you have enabled. Running this command gives you an idea of what those packages are.

Here is what did not install on the author's test machine (reorganized as a column, rather than a long string):

```text
Error: Unable to find a match: 
OpenEXR-libs.x86_64 
bind-export-libs.x86_64 
dhcp-libs.x86_64 
fontpackages-filesystem.noarch 
hardlink.x86_64 
ilmbase.x86_64 
libXxf86misc.x86_64 
libcroco.x86_64 
libmcpp.x86_64 
libreport-filesystem.x86_64 
mcpp.x86_64 
network-scripts.x86_64 
platform-python.x86_64 
platform-python-pip.noarch 
platform-python-setuptools.noarch 
xorg-x11-font-utils.x86_64
```

Run the command again, but this time with the `--skip-broken` appended to it:

```bash
sudo dnf -y install $(cat installed.txt) --skip-broken
```

Because you just made many changes, you should reboot before continuing.

### Restore your backups

Once you have all of the packages installed, restore your backups, configuration files, scripts, and other utilities that you backed up before moving to your new machine.

## Conclusion

There is no magic routine (supported by Rocky Linux) to move from one major version to another. Rocky Linux developers support only a fresh install and recovery of backups. The routine provided here, gives you a method to move from one major version to another, while following the Rocky team's best practices.

This procedure assumes an installation that is not complex. The complexity of your installation might require more steps. Use this procedure as guide.

## Disclaimer

While the basic document is the author's, a cleaner way to generate the `installed.txt` and the suggestion of eliminating the kernel packages, came from two individuals in the [Forum](https://forums.rockylinux.org/t/boot-too-small-rebuild/17415). Thanks to all who provided input to that procedure.
