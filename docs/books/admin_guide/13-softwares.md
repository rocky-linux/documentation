---
title: Software Management
author: Antoine Le Morvan
contributors: Colussi Franco, Steven Spencer, Ganna Zhyrnova
tested version: 8.5
tags:
  - education
  - software
  - software management
---

# Software Management

## Generalities

On a Linux system, it is possible to install software in two ways:

* Download software packages from the repository and install them on the local computer
* Compile the project source code package and install it on the local computer

!!! Note

    This document does not describe how to compile and install the project source code package to the local computer. Usually, you should obtain the corresponding software package from the repository, unless the software package you need is not in the repository. This is because the package management system can help users solve dependency issues, while for beginners, it is very difficult to solve the dependencies of compiling project source code packages.

**The package**: Developers compile a set of source files into executable machine language in advance and package them into binary files in a specific format. Unless otherwise specified, software packages in Linux specifically refer to binary software packages.

**The source file**: A single code file that is readable by humans (such as .c, .py, .java), which may be just a code snippet or module of the entire project that needs to be compiled or interpreted to run on a computer.

**The source code package**: A compressed archive file that packages the source files and related files (such as build files like Makefile and configure; document files such as README and LICENSE ) of the entire project. This file is often identified using file suffixes such as `.tar.gz` or `.tar.xz`.

## RPM Overview

**RPM** (RedHat Package Manager) is a software management system. It is possible to install, uninstall, update or check software contained in packages.

**RPM** is the package management system used by all RedHat distributions (RockyLinux, Fedora, CentOS, Suse, Mandriva, ...), with packages identified by the file suffix `.rpm`. In the world of Debian, the DPKG package management system is used to manage software packages, with packages identified by the file suffix `.deb`.

Naming conventions for RPM software packages:

![Illustration of a package name](images/software-001.png)

!!! tip "Terminology Explanation"

    When we use the capitalized "RPM", it refers to the package management system. When using the lowercase "rpm", in the vast majority of cases, it specifically refers to the `rpm` command. When using `.rpm`, it refers to the format suffix of the software package. Readers should not be confused by them when reading the documents.

Today's RPM package management system is still constantly updated and iterated, see [here](https://rpm.org/).

## Local package manager

The `rpm` command: Command-line tool for managing local RPM packages in RedHat's upstream and downstream distributions.

**Full Package Name**: The complete name of the binary software package, such as `tree-1.7.0-15.el8.x86_64.rpm`.

**Package Name**: The name of the software package, such as `tree`.

If the corresponding software package is never installed in the operating system, when operating with `rpm` command, the "Full Package Name" should be used. If the corresponding software has already been installed on the operating system, when operating with `rpm` command, the "Package Name" should be used, this is because the information of the relevant software packages has been stored in the **/var/lib/rpm/** database directory.

The usage of the `rpm` command is as follows:

```bash
rpm [options] <Package-Name> | <Full-Package-Name>
```

### Install, upgrade, and uninstall software packages

The relevant options are as follows:

| Option            | Description                                  |
|-------------------|----------------------------------------------|
| `-i <Full-Package-Name>`  | Installs the package.                        |
| `-U <Full-Package-Name>`  | Updates an already installed package.        |
| `-e <Package-Name>`  | Uninstalls the package.                      |
| `-h`              | Displays a progress bar.                     |
| `-v`              | Informs about the progress of the operation. |
| `--test`          | Tests the command without executing it.      |

* Install one or more packages - `rpm-ivh <Full-Package-Name> ... `
* Upgrade one or more packages - `rpm-Uvh <Full-Package-Name> ...`
* Uninstall one or more packages - `rpm -e <Package-Name> ...`

Since `rpm` is a local package manager, users need to manually resolve dependency issues during software installation. If relevant dependencies are missing, a prompt such as "failed dependencies" will appear.

Understand the dependency relationships of RPM packages:

* **Tree dependency relationship (a.rpm ---> b.rpm ---> c.rpm)** - When installing a.rpm, it prompts that b.rpm needs to be installed first. When installing b.rpm, it prompts that c.rpm needs to be installed first. This problem is easier to solve, that is, `rpm -ivh a.rpm b.rpm c.rpm`
* **Circular dependency relationship (a.rpm ---> b.rpm ---> c.rpm ---> a.rpm)** - `rpm -ivh a.rpm b.rpm c.rpm`
* **Module dependency relationship** - Go to [this website](https://www.rpmfind.net/) to search

**Q: Why does software package installation always have dependency issues?**

Because software or applications almost always rely on another software or library, if the required program or shared library is not found on the operating system, this prerequisite must be met before installing the target application.

### Query package

The relevant options are as follows:

| Option            | Description                                  |
|-------------------|----------------------------------------------|
| `-q`             | Query whether the software package has been installed, such as `rpm -q tree-1.7.0-15.el8.x86_64.rpm` |
| `-a`             | When used in conjunction with the `-q` option, query all installed rpm packages, such as `rpm -qa` |
| `-i`             | Used in conjunction with the `-q` option to query detailed information about the corresponding installed rpm package. Such as `rpm -qi bash` |
| `-l`             | When used in combination with the `-q` option, query the list of files released by the corresponding installed rpm package |
| `-p`             | Specify uninstalled software packages, for example `rpm -qip tree-1.7.0-15.el8.x86_64.rpm` and `rpm -qlp tree-1.7.0-15.el8.x86_64.rpm`|
| `-f`            | When used in conjunction with the `-q` option, query the software package to which the installation file belongs, such as `rpm -qf /usr/bin/bash` |
| `-R`             | When used in conjunction with the `-q` option, query the dependencies of installed rpm packages. When used in conjunction with the `-p` option, you can query the dependencies of rpm packages that are not installed, such as`rpm -qRp rpm -qRp mtr-0.92-3.el8.x86_64.rpm` |
| `--last`       | list package(s) by install time, most recent first |

The RPM database is located in the directory `/var/lib/rpm/`.

Some examples:

```bash
sudo rpm -qa

sudo rpm -qilp zork-1.0.3-1.el8.x86_64.rpm tree-1.7.0-15.el8.x86_64.rpm

# list the last installed packages:
sudo rpm -qa --last | head
NetworkManager-config-server-1.26.0-13.el8.noarch Mon 24 May 2021 02:34:00 PM CEST
iwl2030-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl2000-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl135-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl105-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl100-firmware-39.31.5.1-101.el8.1.noarch    Mon 24 May 2021 02:34:00 PM CEST
iwl1000-firmware-39.31.5.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
alsa-sof-firmware-1.5-2.el8.noarch            Mon 24 May 2021 02:34:00 PM CEST
iwl7260-firmware-25.30.13.0-101.el8.1.noarch  Mon 24 May 2021 02:33:59 PM CEST
iwl6050-firmware-41.28.5.1-101.el8.1.noarch   Mon 24 May 2021 02:33:59 PM CEST

# list the installation history of the kernel:
sudo rpm -qa --last kernel
kernel-4.18.0-305.el8.x86_64                  Tue 25 May 2021 06:04:56 AM CEST
kernel-4.18.0-240.22.1.el8.x86_64             Mon 24 May 2021 02:33:35 PM CEST
```

!!! tip "Usage Tips"

    When using the query function (the `-q` option), the corresponding software package must be deterministic. In other words, you cannot use wildcards in the `rpm` command line to match the package name. To filter a specific one or more packages, you need to use the pipe symbol (`|`) and the `grep` command.

    ```bash
    sudo rpm -qa | grep ^dbus
    dbus-common-1.12.8-27.el8_10.noarch
    dbus-glib-0.110-2.el8.x86_64
    dbus-libs-1.12.8-27.el8_10.x86_64
    dbus-daemon-1.12.8-27.el8_10.x86_64
    dbus-tools-1.12.8-27.el8_10.x86_64
    dbus-1.12.8-27.el8_10.x86_64
    ```

### Verify the signature of the software package

The `-K` option is required to complete this operation.

When you download the rpm binary package from an unknown website or untrusted location, you don't know if the package has been tampered with. Therefore, users need to verify the signature of the software package to ensure that the downloaded package is complete and has not been tampered with.

Before performing signature verification on the software package, it is necessary to import the required public key in advance (this operation is usually carried out by the system administrator).

Starting from RHEL 8.x, you can use the `dnf download` command to download specific software packages. For example, if you need to download the `wget` package, please entry:

```bash
sudo dnf download wget

ls -l wget-1.19.5-12.el8_10.x86_64.rpm
-rw-r--r-- 1 root root 750748 Jan  3 17:29 wget-1.19.5-12.el8_10.x86_64.rpm

# Use the "-K" option to verify the signature of the corresponding software package
## You can also use the "-v" or "-vv" option to display more detailed information
sudo rpm -K wget-1.19.5-12.el8_10.x86_64.rpm
wget-1.19.5-12.el8_10.x86_64.rpm: digests signatures OK

# If the software package you downloaded has been tampered with, the following information will be displayed:
echo  "change content" >> /root/wget-1.19.5-12.el8_10.x86_64.rpm
sudo rpm -K wget-1.19.5-12.el8_10.x86_64.rpm
wget-1.19.5-12.el8_10.x86_64.rpm: DIGESTS SIGNATURES NOT OK
```

When the signature of a software package fails to pass the verification, you should not continue to use the package.

### Verify file changes after software package installation

The `-V` option is required to complete this operation.

After installing the RPM software package, the RPM database will record the initial and changed characteristics of the relevant files to determine whether they have been maliciously modified by someone.

```bash
sudo rpm -q chrony
chrony-4.5-2.el8_10.x86_64

rpm -V chrony
S.5....T.  c /etc/chrony.conf
```

The output is broken down into 3 separate columns.

- **First column (S.5....T.)**

    Use 9 fields to represent the valid information of the file after the RPM software package is installed. Any field or characteristic that passed a given check/test is indicated by a ".".

    These 9 different fields or checks are described here:

    - S: Whether the size of the file has been modified.
    - M: Whether the type of file or file permissions (rwx) have been modified.
    - 5: Whether the file MD5 checksum has modified.
    - D: Whether the number of the device has been modified.
    - L: Whether the path to the file has been modified.
    - U: Whether the owner of the file has been modified.
    - G: Whether the group to which the file belongs has been modified.
    - T: Whether the mTime (modify time) of the file has been modified.
    - P: Whether the program function has been modified.

- **Second column (c)**

    **c**: Indicates modifications to the configuration file. It can also be the following values:
    
    - d: documentation file
    - g: ghost file. Very few can be seen
    - l: license file
    - r: readme file

- **Third column (/etc/chrony.conf)**

    - **/etc/chrony.conf**：Represents the path of the modified file.

## DNF Package Manager 

**DNF** (**Dandified Yum**) is a software package manager, successor of **YUM** (**Y**ellow dog **U**pdater **M**odified). 

The `dnf` command: This command allows users to manage binary software packages by interacting with the repository. For the most common functional item commands, their usage is the same as the `yum` command. For some newer distributions (such as Rocky Linux 10.x or Fedora 43), the `dnf` command-line tool is also being updated and iterated. For example, in Rocky Linux 10.x, users can selectively install `dnf5` from the repository

The `dnf` command-line tool is used by many RedHat based distributions, such as RockyLinux, Fedora, CentOS, etc. Its equivalent in the Debian world is `apt` (**A**dvanced **P**ackaging **T**ool) command-line tool.

### `dnf`'s functional item commands

The syntax of the `dnf` command is as follows:

```
dnf [options] <command> [<args>...]
```

The "command" in syntax represents the functional item command of `dnf`. Some commands are built-in, while others require support from third-party plugins. The usage of each function command can be viewed through the `--help` option, such as `dnf list --help`.

1. **`list` command**

    list the software packages based on the different options following this command. By default, list all the software packages that can be installed in the operating system (`dnf list` is equivalent to `dnf list --all`).

    * `dnf list --installed` - List the installed software packages for the current operating system
    * `dnf list --updates` - List the software packages that can be upgraded

    The specific options for the list command are as follows:

    | Specific options   |Description                                                                |
    |-------------|---------------------------------------------------------------------------|
    | `--all`        | show all packages (default) |
    | `--available`  | show only available packages |
    | `--installed`  | show only installed packages |
    | `--extras`     | show only extras packages    |
    | `--updates`    | show only upgrades packages |
    | `--upgrades`   | show only upgrades packages |
    | `--autoremove` | show only autoremove packages |
    | `--recent`     | show only recently changed packages |

2. **`search` command**

    Search for software packages from the repository based on the given string. Such as `dnf search vim`.

3. **`install` command**

    Install one or more software packages from the repository. Such as `dnf -y insatll wget tree`. The `-y` option indicates that the automatic response is "yes". Dependency issues will be automatically resolved when specific software packages are installed.

    In addition to installing software packages from the repository, you can also install software packages from specified URL or local RPM software package, such as `dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`, `dnf install /tmp/mtr-0.92-3.el8.x86_64.rpm`

4. **`info` command**

    View information on one or more software packages, such as `dnf info wget tree`

5. **`deplist` command**

    List the dependencies of the software package, which has been deprecated. Please use `dnf repoquery --deplist <Package-Name>` as an alternative.

6. **`repolist` command**

    Display repository related information, default to displaying enabled repositories (`dnf repolist` is equivalent to `dnf repolist --enabled`)

    * `dnf repolist --all` - List all repositories
    * `dnf repolist -v` - Display detailed information of enabled repositories
    * `dnf repolist --disabled` - Lists only disabled repositories.

7. **`history` command**

    Display the history of typed `dnf` commands. By default, `dnf history` is equivalent to `dnf history list`, The "list" here can also be replaced with any one of `info`, `redo`, `replay`, `rollback`, `store`, `undo` or `userinstalled`.

8. **`provides` command**

    View the software package to which the given file belongs. Such as `dnf provides /usr/bin/systemctl`.

9. **`remove` command**

    Remove one or more software packages from the current operating system. By default, it will ask whether to uninstall the software package and its corresponding dependency package, and can automatically respond with "yes" through the `-y` option.

10. **`autoremove` command**

    Automatically delete packages that were once used as dependencies but are no longer in use now. Such as `dnf -y autoremove`.

11. **`makecache` command**

    Generate a cache for newly added repositories or for which metadata is outdated.

12. **`update` or `upgrade` command**

    Upgrade one or more software packages in the operating system. For example, `dnf update -y` will upgrade all upgradable software packages in the operating system.

13. **`grouplist`, `groupinstall`, `groupremove` or `groupinfo` command**

    The operation objects of these commands are package groups, which refer to a set of software packages prepared for a specific scenario or environment.

    There are these package groups in RockyLinux 8.x:

    ```bash
    sudo dnf grouplist
    Available Environment Groups:
       Server with GUI
       Server
       Workstation
       KDE Plasma Workspaces
       Virtualization Host
       Custom Operating System
    Installed Environment Groups:
       Minimal Install
    Available Groups:
       Container Management
       .NET Core Development
       RPM Development Tools
       Development Tools
       Graphical Administration Tools
       Headless Management
       Legacy UNIX Compatibility
       Network Servers
       Scientific Support
       Security Tools
       Smart Card Support
       System Tools
       Fedora Packager
       Xfce
    ```

    To avoid ambiguity, when operating on a single or multiple package groups, the name of a single package group should be enclosed in double quotation marks.

14. **`clean` command**

    Clean the cached data. all data caches can be cleaned through `dnf clean all`.

    | Metadata type to clean | Description                                                   |
    |------------------------|---------------------------------------------------------------|
    | `all`                  | Removes all temporary files created for enabled repositories. |
    | `dbcache`              | Removes cache files generated from the repository metadata.   |
    | `expire-cache`         | Marks the repository metadata expired.                        |
    | `metadata`             | Removes repository metadata.                                  |
    | `packages`             | Removes any cached packages from the system.                  |

15. **`download` command**

    Download one or more software packages from the repository to the local computer without installing them. 

    You can use the options `--destdir DESTDIR` or `--downloaddir DESRDIR` to specify the saving path, such as `dnf download tree --downloaddir /tmp/`.

16. **`repoquery` command**

    Query relevant information by the different options after the command, similar to `rpm -q`.

    * `dnf repoquery --deplist <Package-Name>` - View dependencies
    * `dnf repoquery --list <Package-Name>` - View the list of files after installing the software package (regardless of whether the software is already installed on the operating system)
  
17. **`config-manager` command**

    Manage repositories through the command line, including adding, deleting, enabling, and disabling repositories.

    * `dnf config-manager --add-repo <URL>` - Add a single brand-new repository
    * `dnf config-manager --set-disabled devel` - Permanently disable a single repository
    * `dnf config-manager --set-enabled devel` - Permanently enable a single repository

You can view the available plugin commands through the output of the `dnf --help` command:

```bash
sudo dnf --help
...
List of Plugin Commands:

builddep                  Install build dependencies for package or spec file
changelog                 Show changelog data of packages
config-manager            manage dnf configuration options and repositories
copr                      Interact with Copr repositories.
debug-dump                dump information about installed rpm packages to file
debug-restore             restore packages recorded in debug-dump file
debuginfo-install         install debuginfo packages
download                  Download package to current directory
groups-manager            create and edit groups metadata file
needs-restarting          determine updated binaries that need restarting
offline-distrosync        Prepare offline distrosync of the system
offline-upgrade           Prepare offline upgrade of the system
playground                Interact with Playground repository.
repoclosure               Display a list of unresolved dependencies for repositories
repodiff                  List differences between two sets of repositories
repograph                 Output a full package dependency graph in dot format
repomanage                Manage a directory of rpm packages
reposync                  download all packages from remote repo
system-upgrade            Prepare system for upgrade to a new release
...
```

!!! tip 

    If these plugin commands are missing, please install the `dnf-plugins-core` package. See more informations here: https://dnf-plugins-core.readthedocs.io/en/latest/index.html

### configuration file description

All repository configuration files are stored in the **/etc/yum.repos.d/** directory and end with `.repo`. Each `.repo` file can contain a single or multiple repositories, and users can selectively enable or disable them according to their actual situation.

```bash
ls -l /etc/yum.repos.d/
total 72
-rw-r--r--  1 root root 1919 Sep 13  2024 docker-ce.repo
-rw-r--r--  1 root root 1680 Aug 31  2024 epel-modular.repo
-rw-r--r--  1 root root 1332 Aug 31  2024 epel.repo
-rw-r--r--  1 root root 1779 Aug 31  2024 epel-testing-modular.repo
-rw-r--r--  1 root root 1431 Aug 31  2024 epel-testing.repo
-rw-r--r--. 1 root root  710 Jun  7  2024 Rocky-AppStream.repo
-rw-r--r--. 1 root root  695 Jun  7  2024 Rocky-BaseOS.repo
-rw-r--r--  1 root root 1773 Jun  7  2024 Rocky-Debuginfo.repo
-rw-r--r--. 1 root root  360 Jul 11  2024 Rocky-Devel.repo
-rw-r--r--. 1 root root  695 Jun  7  2024 Rocky-Extras.repo
-rw-r--r--. 1 root root  731 Jun  7  2024 Rocky-HighAvailability.repo
-rw-r--r--. 1 root root  680 Jun  7  2024 Rocky-Media.repo
-rw-r--r--. 1 root root  680 Jun  7  2024 Rocky-NFV.repo
-rw-r--r--. 1 root root  690 Jun  7  2024 Rocky-Plus.repo
-rw-r--r--. 1 root root  715 Mar 29 17:39 Rocky-PowerTools.repo
-rw-r--r--. 1 root root  746 Jun  7  2024 Rocky-ResilientStorage.repo
-rw-r--r--. 1 root root  681 Jun  7  2024 Rocky-RT.repo
-rw-r--r--  1 root root 2335 Jun  7  2024 Rocky-Sources.repo
```

The content format of a single repository in each `.repo` file is fixed, for example:

```
[baseos]
name=Rocky Linux $releasever - BaseOS
mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=BaseOS-$releasever
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/BaseOS/$basearch/os/
gpgcheck=1
enabled=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
```

Content description:

* Use "[ ]" to include the repository ID, which must be unique.
* Below the "[ ]" are the options for the repository.
* The "name" option - Specifies the detailed name of the repository.
* The "mirrorlist" option - URL of a mirrorlist for the repository. URLs support multiple protocols, such as https, http, ftp, file, NFS, etc. The "$" in the value represents the relevant repository variable.
* The "baseurl" option - List of URLs for the repository. URLs support multiple protocols, such as https, http, ftp, file, NFS, etc. The "$" in the value represents the relevant repository variable.
* Lines starting with "#" are comment lines.
* The "gpgcheck" option - Whether to perform GPG signature check on packages found in this repository. The default value is False(0).
* The "enabled" option - Include this repository as a package source. The default value is True(1).
* The "countme" option - Upload anonymous usage statistics data. The default value is False(0).
* The "gpgkey" option - GPG public key path.

For more information, please refer to `man 5 yum.conf`.

## Application Streams

**Application Streams in RL 8.x and RL 9.x:**: In Rocky Linux 8.x and 9.x, a new modular technology is used, allowing repositories to host multiple versions of applications and their dependencies. Due to the adoption of a modular architecture, the Application Streams in these two operating systems is also referred to as "Module Streams". System administrators can choose a specific version to use, bringing more flexibility. If system administrators need to manage the Application Streams, they often need to use the `dnf module` command.

**Application Streams in RL 10.x**: Starting from Rocky Linux 10.x, system administrators can still use the Application Streams, but the Application Streams is no longer provided in a modular form, in other words, the `dnf module` command has been removed, and system administrators can manage different versions of applications in the traditional way. In this version of the operating system, the term "Application Streams" does not equal "Module Streams".

Each Application Stream has a different lifecycle. Please refer to the following link:

* https://access.redhat.com/support/policy/updates/rhel-app-streams-life-cycle#rhel8_application_streams
* https://access.redhat.com/support/policy/updates/rhel-app-streams-life-cycle#rhel9_application_streams
* https://access.redhat.com/support/policy/updates/rhel-app-streams-life-cycle#rhel10_dependent_application_streams

In this document, the author mainly explains the Application Streams of modular architecture. 

### Module Streams

Important note:

* To use modular architecture Application Streams in RL 8.x and RL 9.x, please enable the **AppStream** repository first. In the Appstream repository, **modules** represent a collection of software packages for logical units, which are built, tested, and published together. A single module can contain multiple streams (versions) of the same application.
* Each module receives updates separately.
* After enabling a single module, users can only use one stream (version) of that module.
* Each module can have its own default stream (default version) marked with "[d]". 
* The default stream is active unless you disable the module or enable another stream for the module.

### Module Profiles

**Module Profiles**: A set of software package lists bound together for specific usage scenarios is specified. For example:

```bash
sudo dnf module list nginx
Last metadata expiration check: 10:04:05 ago on Wed 07 Jan 2026 01:42:24 PM CST.
Rocky Linux 8 - AppStream
Name                      Stream                       Profiles                       Summary
nginx                     1.14 [d]                     common [d]                     nginx webserver
nginx                     1.16                         common [d]                     nginx webserver
nginx                     1.18                         common [d]                     nginx webserver
nginx                     1.20                         common [d]                     nginx webserver
nginx                     1.22                         common [d]                     nginx webserver
nginx                     1.24                         common [d]                     nginx webserver

sudo sudo dnf module install nginx:1.14
Last metadata expiration check: 10:04:31 ago on Wed 07 Jan 2026 01:42:24 PM CST.
Dependencies resolved.
========================================================================================================================
 Package                            Architecture  Version                                        Repository        Size
========================================================================================================================
Installing group/module packages:
 nginx                              x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream        566 k
 nginx-all-modules                  noarch        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         22 k
 nginx-filesystem                   noarch        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         23 k
 nginx-mod-http-image-filter        x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         34 k
 nginx-mod-http-perl                x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         45 k
 nginx-mod-http-xslt-filter         x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         32 k
 nginx-mod-mail                     x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         63 k
 nginx-mod-stream                   x86_64        1:1.14.1-9.module+el8.4.0+542+81547229         appstream         84 k
Installing dependencies:
 dejavu-fonts-common                noarch        2.35-7.el8                                     baseos            73 k
 dejavu-sans-fonts                  noarch        2.35-7.el8                                     baseos           1.5 M
 fontconfig                         x86_64        2.13.1-4.el8                                   baseos           273 k
 fontpackages-filesystem            noarch        1.44-22.el8                                    baseos            15 k
 gd                                 x86_64        2.2.5-7.el8                                    appstream        143 k
 jbigkit-libs                       x86_64        2.1-14.el8                                     appstream         54 k
 libX11                             x86_64        1.6.8-9.el8_10                                 appstream        611 k
 libX11-common                      noarch        1.6.8-9.el8_10                                 appstream        157 k
 libXau                             x86_64        1.0.9-3.el8                                    appstream         36 k
 libXpm                             x86_64        3.5.12-11.el8                                  appstream         58 k
 libjpeg-turbo                      x86_64        1.5.3-14.el8_10                                appstream        156 k
 libtiff                            x86_64        4.0.9-36.el8_10                                appstream        190 k
 libwebp                            x86_64        1.0.0-11.el8_10                                appstream        273 k
 libxcb                             x86_64        1.13.1-1.el8                                   appstream        228 k
Installing module profiles:
 nginx/common
Enabling module streams:
 nginx                                            1.14

Transaction Summary
========================================================================================================================
Install  22 Packages

Total download size: 4.5 M
Installed size: 14 M
Is this ok [y/N]:
```

Each Moudle Stream can have any number of profiles (or none at all), and the profiles of module streams can be marked with "[d]" to indicate the "default" meaning.

In the above example, when the user needs to install nginx, the following command is equivalent:

```bash
sudo dnf install nginx

sudo dnf install nginx:1.14

sudo dnf install nginx:1.14/common
```

### Management Module Streams

The command used is `dnf module`, and there are some subcommands for functional items under this command.

!!! tip "Usage Tips"

    When a single line `dnf module` command operation involves modules, multiple module names are allowed, such as `dnf module enable nginx httpd:2.4` or `dnf module list nodejs:10 perl`.

#### View

You can use the subcommands of the `list` or `info` function items to perform the corresponding operations.

* `dnf module list` - Get a list of all available modules.
* `dnf module list <Module-Name>` or `dnf module list <Module-Name>:<Stream>`- List all available streams (versions) for the current module. List the information of a single module stream. For example `dnf module list postgresql` or `dnf module list postgresql:15`.
* `dnf module list --enabled` - List the enabled module stream(s).
* `dnf module info <Module-Name>` or `dnf module info info <Module-name>:<Stream>` - Display module stream information. If you only type the name of a module without a stream, all stream information for that module will be displayed. For example `dnf module info ruby` or `dnf  module info ruby:2.6`.
* `dnf moudle --info --profile <Module-Name>` or `dnf moudle --info --profile <Module-Name>:<Stream>` - List the profile information of the module stream. If you only type the name of a module without a stream, all stream profile information for that module will be displayed.

#### Install

Before installing a specific stream of the corresponding module, you need to first enable the specific stream of the module. The syntax used is as follows:

```bash
dnf moudle enable <Module-Name>:<Stream> ...
```

For example:

```bash
dnf -y module enable httpd:2.4
```

!!! tip "Re-emphasize"

    The default stream is active unless you disable the module or enable another stream for the module.

The following installation methods are acceptable:

* `dnf -y module install <Module-Name>` - Use the default stream and default profile of a single module (if a default profile exists). For example `dnf -y install httpd`
* `dnf -y install <Module-Name>:<Stream>/<Profile>` - Using specific stream and profile of a single module. For example `dnf -y install httpd:2.4:/minimal`. If there are multiple profiles, you can use `*` to represent all of them ,for example `dnf module install httpd:2.4/*`

#### Remove

The following syntax can be accepted:

* `dnf -y module remove --all <Module-name>:<Stream> ...` - Remove all packages from a single stream in a single module. For example `dnf -y module remove --all httpd:2.4`
* `dnf -y module remove --all <Module-name>:<Stream>/<Profile> ...` - Remove all packages associated with a specific profile, using `*` to represent all profiles. For example `dnf -y module remove httpd:2.4/*`

#### Reset

You can use the `reset` function item command to reset the module to its initial state. The corresponding syntax is as follows:

* `dnf -y module reset <Module-Name> ...` - For example `dnf -y module reset httpd`

!!! tip "Important Notice"

    Resetting the module will not change any installed software packages.

#### Switch

You can switch to the updated stream. There are two prerequisites to complete this operation:

1. The operating system has been fully updated
2. The installed software packages in the operating system are not newer than the software packages available in the repository

You can use the `dnf distro-sync` command to switch to a new stream.

If there are available updates for the module's stream, you need to perform the following steps:

1. `dnf module reset <Module-Name> ...`
2. `dnf module enable <Module-Name>:<New-Stream> ...`
3. `dnf distro-sync`

If a specific module's specific stream has already been installed in the operating system, you can also use the 'switch to' command to upgrade or downgrade the software package. The specific syntax is:

```bash
dnf module switch-to <Module-Name>:<Stream>
```

#### Disable

The syntax used is:

```bash
dnf module disable <Module-Name> ...
```

#### Customize using YAML file

System administrator can customize default stream and default profile by creating a YAML file in the **/etc/dnf/modules.defaults.d/** directory.

Taking the postgresql module as an example, it can be seen from the output information that its default stream is 10 and the default profile is "server".

```bash
sudo dnf module list postgresql
Name                   Stream             Profiles                       Summary
postgresql             9.6                client, server [d]             PostgreSQL server and client module
postgresql             10 [d]             client, server [d]             PostgreSQL server and client module
postgresql             12                 client, server [d]             PostgreSQL server and client module
postgresql             13                 client, server [d]             PostgreSQL server and client module
postgresql             15                 client, server [d]             PostgreSQL server and client module
postgresql             16                 client, server [d]             PostgreSQL server and client module

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Set 15 as the default stream and set the default profile for postgresql:12 to "client":

```bash
sudo vim /etc/dnf/modules.defaults.d/postgresql.yaml
---
document: modulemd-defaults
version: 1
data:
        module: postgresql
        stream: "15"
        profiles:
                "9.6": [server]
                "10": [server]
                "12": [client]
                "13": [server]
                "15": [server]
...

sudo dnf module list postgresql
Last metadata expiration check: 0:41:35 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name                   Stream             Profiles                       Summary
postgresql             9.6                client, server [d]             PostgreSQL server and client module
postgresql             10                 client, server [d]             PostgreSQL server and client module
postgresql             12                 client [d], server             PostgreSQL server and client module
postgresql             13                 client, server [d]             PostgreSQL server and client module
postgresql             15 [d]             client, server [d]             PostgreSQL server and client module
postgresql             16                 client, server                 PostgreSQL server and client module

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

#### Complete Example

Taking the nodejs module as an example:

```bash
sudo dnf module list nodejs
Last metadata expiration check: 0:44:38 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name                Stream              Profiles                                          Summary
nodejs              10 [d]              common [d], development, minimal, s2i             Javascript runtime
nodejs              12                  common [d], development, minimal, s2i             Javascript runtime
nodejs              14                  common [d], development, minimal, s2i             Javascript runtime
nodejs              16                  common [d], development, minimal, s2i             Javascript runtime
nodejs              18                  common [d], development, minimal, s2i             Javascript runtime
nodejs              20                  common [d], development, minimal, s2i             Javascript runtime
nodejs              22                  common, development, minimal, s2i                 Javascript runtime
nodejs              24                  common, development, minimal, s2i                 Javascript runtime

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled

sudo dnf -y module enable nodejs:18

sudo dnf module list --enabled nodejs
Last metadata expiration check: 0:46:01 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name                Stream              Profiles                                          Summary
nodejs              18 [e]              common [d], development, minimal, s2i             Javascript runtime

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled

sudo dnf -y module install nodejs:18/minimal

sudo dnf module list --enabled nodejs
Last metadata expiration check: 0:47:26 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name               Stream             Profiles                                             Summary
nodejs             18 [e]             common [d], development, minimal [i], s2i            Javascript runtime

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled

sudo dnf -y module install nodejs:18/common

sudo dnf module list --enabled nodejs
Last metadata expiration check: 0:48:34 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name              Stream            Profiles                                                Summary
nodejs            18 [e]            common [d] [i], development, minimal [i], s2i           Javascript runtime

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled

sudo dnf -y module remove --all nodejs:18/*

sudo dnf -y module reset nodejs

sudo dnf module list nodejs
Last metadata expiration check: 0:50:03 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Rocky Linux 8 - AppStream
Name                Stream              Profiles                                          Summary
nodejs              10 [d]              common [d], development, minimal, s2i             Javascript runtime
nodejs              12                  common [d], development, minimal, s2i             Javascript runtime
nodejs              14                  common [d], development, minimal, s2i             Javascript runtime
nodejs              16                  common [d], development, minimal, s2i             Javascript runtime
nodejs              18                  common [d], development, minimal, s2i             Javascript runtime
nodejs              20                  common [d], development, minimal, s2i             Javascript runtime
nodejs              22                  common, development, minimal, s2i                 Javascript runtime
nodejs              24                  common, development, minimal, s2i                 Javascript runtime

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

## Using the EPEL repository

**Q:What is EPEL and how is it used?**

**EPEL** (**E**xtra **P**ackages for **E**nterprise **L**inux) is an open-source and free community-based repository maintained by the [EPEL Fedora Special Interest Group](https://docs.fedoraproject.org/en-US/epel/) that provides a set of additional packages for RHEL (and CentOS, Rocky Linux, and others) from the Fedora sources.

Whether individuals or businesses use Rocky Linux 8.x/9.x/10.x, it is usually recommended to enable the EPEL repository.

You can install the EPEL repository in the following ways:

```bash
sudo dnf install epel-release
```

Review relevant information and verify successful installation:

```bash
sudo dnf info epel-release
Last metadata expiration check: 1 day, 23:02:38 ago on Sat 10 Jan 2026 10:10:22 PM CST.
Installed Packages
Name         : epel-release
Version      : 8
Release      : 22.el8
Architecture : noarch
Size         : 34 k
Source       : epel-release-8-22.el8.src.rpm
Repository   : @System
From repo    : epel
Summary      : Extra Packages for Enterprise Linux repository configuration
URL          : http://download.fedoraproject.org/pub/epel
License      : GPLv2
Description  : This package contains the Extra Packages for Enterprise Linux (EPEL) repository
             : GPG key as well as configuration for yum.

rpm -qa | grep epel
epel-release-8-14.el8.noarch

sudo dnf repolist
repo id            repo name
...
epel                                      Extra Packages for Enterprise Linux 8 - x86_64
...
```

The package, as you can see from the package description above, does not contain executables, libraries, etc... but only the configuration files and GPG keys for setting up the repository.

Associated `.repo` files:

```bash
ls -lh /etc/yum.repos.d/epel*
-rw-r--r-- 1 root root 1.7K Apr 23  2025 /etc/yum.repos.d/epel-modular.repo
-rw-r--r-- 1 root root 1.4K Apr 23  2025 /etc/yum.repos.d/epel.repo
-rw-r--r-- 1 root root 1.8K Apr 23  2025 /etc/yum.repos.d/epel-testing-modular.repo
-rw-r--r-- 1 root root 1.4K Apr 23  2025 /etc/yum.repos.d/epel-testing.repo
```

By default, only repositories with the ID epel in the `epel.repo` file are enabled.

```bash
cat /etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 8 - $basearch
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/8/Everything/$basearch
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-8&arch=$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
...
```

List all available software packages with repository ID epel:

```bash
dnf --repoid epel list --available 
```

If there are other repositories in your operating system but you wish to install packages only from EPEL:

```bash
sudo dnf --disablerepo="*" --enablerepo="epel" install nmon
Last metadata expiration check: 0:08:13 ago on Mon 12 Jan 2026 09:34:25 PM CST.
Dependencies resolved.
========================================================================================================================
 Package                   Architecture                Version                          Repository                 Size
========================================================================================================================
Installing:
 nmon                      x86_64                      16p-5.el8                        epel                       80 k

Transaction Summary
========================================================================================================================
Install  1 Package

Total download size: 80 k
Installed size: 161 k
Is this ok [y/N]:
```

!!! tip "Friendly reminder"

    When multiple repositories are enabled, the same software package may have multiple versions, and by default, the newer version of the software package has the highest priority. This is also the reason why the `--disablerepo` and `--enablrepo` options are used.

!!! attention "Support consideration"

    EPEL is a project initiated by volunteers in the Fedora community, which means that the project is not commercially supported by Red Hat. Just like Fedora itself, Red Hat hosts infrastructure for this project and Red Hat engineers are involved as maintainers and leaders but there are no commercial support contracts or service level agreements provided by Red Hat for packages in EPEL.
