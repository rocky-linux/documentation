---
title: Software Management
---

# Software Management

## Generalities

On a Linux system, it is possible to install software in two ways:

* Using an installation package;
* Compiling from source files.

!!! Note Installing from source is not covered here. As a rule, you should use the package method unless the software you want is not available via the package manager. The reason for this is that dependencies are generally managed by the package system, whereas with source, you need to manage the dependencies manually.

**The package**: This is a single file containing all the data needed to install the program. It can be executed directly on the system from a software repository.

**The source files** : Some software is not provided in packages ready to be installed, but via an archive containing the source files. It is up to the administrator to prepare these files and compile them to install the program.

## RPM : RedHat Package Manager

**RPM** (RedHat Package Manager) is a software management system. It is possible to install, uninstall, update or check software contained in packages.

**RPM** is the format used by all RedHat based distributions (RockyLinux, Fedora, CentOS, SuSe, Mandriva, ...). Its equivalent in the Debian world is DPKG (Debian Package).

The name of an RPM package follows a specific nomenclature:

![Illustration of a package name](images/software-001.png)

### `rpm` command

The rpm command allows you to install a package.

```
rpm [-i][-U] package.rpm [-e] package
```

Example (for a package named 'package'):

```
[root]# rpm -ivh package.rpm
```

| Option           | Description                                  |
| ---------------- | -------------------------------------------- |
| `-i package.rpm` | Installs the package.                        |
| `-U package.rpm` | Updates an already installed package.        |
| `-e package.rpm` | Uninstalls the package.                      |
| `-h`             | Displays a progress bar.                     |
| `-v`             | Informs about the progress of the operation. |
| `--test`         | Tests the command without executing it.      |

The `rpm` command also allows you to query the system package database by adding the `-q` option.

It is possible to execute several types of queries to obtain different information about the installed packages. The RPM database is located in the directory `/var/lib/rpm`.

Example:

```
[root]# rpm -qa
```

This command queries all the packages installed on the system.

```
rpm -q [-a][-i][-l] package [-f] file
```

Example:

```
[root]# rpm -qil package
[root]# rpm -qf /path/to/file
```

| Option           | Description                                                                                    |
| ---------------- | ---------------------------------------------------------------------------------------------- |
| `-a`             | Lists all packages installed on the system.                                                    |
| `-i __package__` | Displays the package information.                                                              |
| `-l __package__` | Lists the files contained in the package.                                                      |
| `-f`             | Shows the name of the package containing the specified file.                                   |
| `--last`         | The list of packages is given by installation date (the last installed packages appear first). |

!!! Warning After the `-q` option, the package name must be exact. Metacharacters (wildcards) are not supported.

!!! Tip However, it is possible to list all installed packages and filter with the `grep` command.

Example: list the last installed packages:

```
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
```

Example: list the installation history of the kernel:

```
sudo rpm -qa --last kernel
kernel-4.18.0-305.el8.x86_64                  Tue 25 May 2021 06:04:56 AM CEST
kernel-4.18.0-240.22.1.el8.x86_64             Mon 24 May 2021 02:33:35 PM CEST
```

Example: list all installed packages with a specific name using `grep`:

```
sudo dnf list installed | grep httpd
centos-logos-httpd.noarch           80.5-2.el8                              @baseos      
httpd.x86_64                        2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream   
httpd-filesystem.noarch             2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream   
httpd-tools.x86_64                  2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
```

## DNF : Dandified Yum

**DNF** (**Dandified Yum**) is a software package manager, successor of **YUM** (**Yellow dog **U**pdater **M**odified). It works with **RPM** packages grouped in a local or remote repository (a directory for storing packages). For the most common commands, its usage is identical to that of `yum`.

The `dnf` command allows the management of packages by comparing those installed on the system with those in the repositories defined on the server. It also automatically installs dependencies, if they are also present in the repositories.

`dnf` is the manager used by many RedHat based distributions (RockyLinux, Fedora, CentOS, ...). Its equivalent in the Debian world is **APT** (**A**dvanced **P**ackaging **T**ool).

### `dnf` command

The dnf command allows you to install a package by specifying only the short name.

```
dnf [install][remove][list all][search][info] package
```

Example:

```
[root]# dnf install tree
```

Only the short name of the package is required.

| Option                    | Description                                   |
| ------------------------- | --------------------------------------------- |
| `install`                 | Installs the package.                         |
| `remove`                  | Uninstall the package.                        |
| `list all`                | Lists the packages already in the repository. |
| `search`                  | Search for a package in the repository.       |
| `provides */command_name` | Search for a command.                         |
| `info`                    | Displays the package information.             |

The `dnf list` command lists all the packages installed on the system and present in the repository. It accepts several parameters:

| Parameter   | Description                                                                |
| ----------- | -------------------------------------------------------------------------- |
| `all`       | Lists the installed packages and then those available on the repositories. |
| `available` | Lists only the packages available for installation.                        |
| `updates`   | Lists packages that can be upgraded.                                       |
| `obsoletes` | Lists the packages made obsolete by higher versions available.             |
| `recent`    | Lists the latest packages added to the repository.                         |

Example of a search for the `semanage` command:

```
[root]# dnf provides */semanage
```

### How DNF works

The DNF manager relies on one or more configuration files to target the repositories containing the RPM packages.

These files are located in `/etc/yum.repos.d/` and must end with `.repo` in order to be used by DNF.

Example:

```
/etc/yum.repos.d/Rocky-BaseOS.repo
```

Each `.repo` file consists of at least the following information, one directive per line.

Example:

```
[baseos] # Short name of the repository
name=Rocky Linux $releasever - BaseOS # Short name of the repository #Detailed name
mirrorlist=http://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=BaseOS-$releasever # http address of a list or mirror
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/BaseOS/$basearch/os/ # http address for direct access
gpgcheck=1 # Repository requiring a signature
enabled=1 # Activated =1, or not activated =0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial # GPG public key path
```

By default, the `enabled` directive is absent which means that the repository is enabled. To disable a repository, you must specify the `enabled=0` directive.

## The EPEL repository

**EPEL** (**E**xtra **P**ackages for **E**nterprise **L**inux) is a repository containing additional software packages for Enterprise Linux, which includes RedHat Enterprise Linux (RHEL), RockyLinux, CentOS, etc.

### Installation

Download and install the rpm from the repository:

If you are behind an internet proxy:

```
[root]# export http_proxy=http://172.16.1.10:8080
```

Then:

```
[root]# dnf install epel-release
```
