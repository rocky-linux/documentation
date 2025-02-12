---
title: Rocky supported version upgrades
author: Steven Spencer
contributors:
---

**OR** How to duplicate any Rocky machine.

## Introduction

Since day one of the Rocky Linux project, there are those who have asked: ==How do you upgrade from CentOS 7 to Rocky 8, or Rocky 8 to Rocky 9?== The answer is always the same: **The project does not support in-place upgrades of one major version to another major version. You need to reinstall to move to the next major version.** To be clear, this **IS** the correct answer. This document hopes to give users a method of moving from one major version to the next, using the correct Rocky supported procedure of a fresh installation. You can use this method to do a rebuild of the same Rocky Linux version as well. For example, 9.5 to a fresh 9.5 install with all of the packages.

!!! note "Caveats"

    Even given this procedure, many things can go wrong when going from an older version of one operating system (OS) to a newer version of the same or different OS. Programs become obsolete, replaced by the maintainers with completely different package names, or the names simply do not match up from one OS to the next. In addition, you need to know about your machine's software repositories and also verify that they are still functional for the new OS. If going from a much older version to a much newer version, ensure that your CPU and other machine requirements match the new version. For these and many other reasons, you must remain cautious and note any errors or problems while performing this procedure. Here, the author has used Rocky Linux 8 as the old version and Rocky Linux 9 as the new major version. The formulation of all examples uses these two versions. Always proceed at your own risk.

## Steps summary

1. Obtain a list of users from the old installation (`userid.txt`).
2. Obtain a list of repositories from the old installation (`repolist.txt`).
3. Obtain a list of packages from the old installation (`installed.txt`).
4. Backup all data, configuration, utilities, and scripts from the old installation to a non-volatile location along with the `.txt` files created.
5. Verify that the hardware you will be installing on supports the operating system that you are installing. (CPU, memory, disk space, and so on.)
6. Perform a fresh install of the operating system you are using on the hardware.
7. Do a `dnf upgrade` to get any packages that might have updated since the creation of the ISO file.  
8. Create any needed users by examining the `userid.txt` file.
9. Install any missing repositories in the `repolist.txt` file that are not Rocky-related. (See notes for the EPEL and Code Ready Builder (CRB) repositories.)
10. Install the packages using the procedure for the `installed.txt` file.

## Steps detail

!!! info "Same version upgrades"

    As noted earlier, this procedure should work equally well to duplicate a machine installation with the same operating system release. Such as, 8.10 to 8.10 or 9.5 to 9.5. The difference is that you should not need `--skip-broken` when installing the packages from the `installed.txt` file. If you get package errors when doing a like version installation, then you are probably missing a repository. Stop the procedure and re-examine the `repolist.txt` file. The examples here use 8.10 as the old installation and 9.5 as the new one.

!!! warning "Version 10 is unknown"

    Because of the huge changes between 9.5 and the upcoming version 10, this procedure **might not work** to move between 9.5 and 10. The exploration of this will occur once there is a release of 10 to test. 

### Example old machine

The old machine used here is Rocky Linux 8. The installation includes several packages from the Extra Packages for Enterprise Linux (EPEL) repository.

!!! info "Code Ready Builder"

    The Code Ready Builder (CRB) repository in Rocky Linux 9, replaces functionality in the deprecated PowerTools repository that existed in version 8. If moving from an 8 version to 9 where you have the EPEL, you will need to enable the CRB on your new machine with:

    ```bash
    sudo dnf config-manager --enable crb
    ```

#### Obtain a list of users

You will need to create any users on the new machine manually, so you need to know what user accounts you will need to create. User accounts generally start at user id 1000, and increment upwards.

```bash
sudo getent passwd > userid.txt
```

#### Obtain a list of repositories

You need a list of the repositories that exist on the old machine:

```bash
sudo ls -al /etc/yum.repos.d/ > repolist.txt
```

#### Obtain a list of packages

Generate the package list with:

```bash
sudo dnf list installed | awk 'NR>1 {print $1}' | sort -u > installed.txt
```

Here the `NR>1` eliminates record one from the column, which has the "Installed" that came from the `dnf list installed` command. It is not a package, so you do not need it. The `{print $1}` means, only use column one. You do not need the package version or the repository it came from in the listing.

You will not need to install any kernel related packages. That said, it does not hurt to install them again, if you leave this step out. You can remove the kernel lines with:

```bash
sudo sed -i '/kernel/d' installed.txt
```

#### Backup any data

This can encompass many things. Ensure you know the purpose of the machine you are replacing and all of its program components (database, mail server, DNS, more). If in doubt, back it up.

#### Copy files

Copy the text files you created to a non-volatile location along with all of the backup data.

### Example new machine

Your fresh installation of Rocky Linux 9 is complete. You need to get any package updates since the creation of the ISO image:

```bash
sudo dnf upgrade
```

You are ready to start copying your text files and backups from where you stored them in the earlier procedure.

#### Create the users

Examine the `userid.txt` file and create the users you need on the new machine.

#### Install the repositories

Examine the `repolist.txt` file and manually install the repositories you need. You can ignore the Rocky-related repositories. Remember that we have packages from the EPEL, so you will need the CRB repository, rather than PowerTools:

```bash
sudo dnf config-manager --enable crb
```

Install the EPEL:

```bash
sudo dnf install epel-release
```

Install any other repositories from the `repolist.txt` file that are not Rocky or EPEL based.

#### Install the packages

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

!!! note

    If you feel that you might need functionality of these missing packages on your fresh install, save them off in a file for use later. You can see the availability status of missing packages, by using:

    ```bash
    sudo dnf whatprovides [package_name]
    ```

Run the command again, but this time with the `--skip-broken` appended to it:

```bash
sudo dnf -y install $(cat installed.txt) --skip-broken
```

Because you just made many changes, you should reboot before continuing.

#### Restore your backups

Once you have all of the packages installed, restore your backups, modified configuration files, scripts, and other utilities that you backed up before moving to your new machine.

## Conclusion

There is no magic routine (supported by Rocky Linux) to move from one major version to another. Rocky Linux developers support only a fresh install. The routine provided here, gives you a method to move from one major version to another, while following the Rocky team's best practices.

This procedure assumes an installation that is not complex. The complexity of your installation might require more steps. Use this procedure as guide.

## Disclaimer

While the basic document is the author's, a cleaner way to generate the `installed.txt` and the suggestion of eliminating the kernel packages, came from two individuals in the [Forum](https://forums.rockylinux.org/t/boot-too-small-rebuild/17415). Thanks to all who provided input to that procedure.
