---
title: Shell overview
author: tianci li
contributors: 
tags:
  - Shell Introduction
---

# Basic Introduction

**What is Shell?**

Shell is called a **command interface** or **command interpreter**. It provides a system level interface program for users to send requests to the Linux kernel for running programs.

When introducing the operating system, we mentioned the following sentence:

> Intercept **access to peripherals**. Software is rarely allowed to access hardware directly (except for graphics cards for very specific needs).

![Shell01](./images/Shell01.png)

The bottom layer is hardware devices, managed by the Linux kernel. When people remotely connect to the server through SSH and type various commands, the Linux kernel does not recognize these words or letters. As is well known, computers can recognize machine languages such as 0 and 1. In order to complete the conversion of human language and machine language, a two-way translation officer similar to that in real life was introduced into the operating system, that is, Shell.

It works like this:

**People from Country A** <<--->> **Shell** <<--->> **People from Country B**

From a user perspective, Shell is actually a human-computer interaction interface, and the interaction interfaces of modern operating systems mainly include:

* Command line interaction interface. For example, operating systems like **RockyLinux** and **Debian** that serve as server roles.
* Graphical interactive interface. For example, the **Windows 11** operating system for home and office environments.
* Command line and graphical mixed interactive interface. For example, **mint**, **Ubuntu** with graphical environment, **Windows Server** with Powershell, etc.

Shell classification:

* Bourne Shell - This family includes but is not limited to:
    * sh (Bourne Shell, /usr/bin/sh). It was developed at Bell LABS in 1977 by Stephen Bourne and used on V7 UNIX
    * ksh (Korn Shell, /usr/bin/ksh)
    * Bash (GNU Bourne-Again Shell, /bin/bash) - Born in 1987, it is the product of the GNU Project. Most GNU/Linux operating systems use bash as their default shell. For more detailed information, please [read this manual](https://www.gnu.org/software/bash/manual/bash.html).
    * psh (POSIX Shell) - For more detailed information, please [read this specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html).
    * zsh (Z-shell) - For more detailed information, please [read here](https://zsh.sourceforge.io/).
* C Shell - This family includes but is not limited to:
    * csh
    * tcsh - For more detailed information, please [visit this website](https://www.tcsh.org/)
* Power Shell

## Fence Code Block style description

* Translators should translate the annotations on the command.

  ```bash
  # Lists the files in the current directory
  bash > ls
  ```

* If you need to break a line to explain the meaning of a command, you can use two or more "#". Of course, this approach also applies to associated operation steps.

  ```bash
  # First decompress
  bash > tar -zvxf nginx-1.21.1.tar.gz -C /usr/local/src/
  ## And then go into the directory
  bash > cd /usr/local/src/nginx-1.21.1/
  ```

* Declare the user and current path.
  
  ```bash
  bash (root /root/)> ls -l

  bash (root)>

  bash (/tmp/)>
  ```

* Use arrows to illustrate the meaning of command output.

  ```bash
  # Please pay attention! The output content has been artificially split here
  bash (root /root/)> ls -l 
  -  rwx  r-x  r-x  1  root  root    1358  Dec 31 14:50  anaconda-ks.cfg
  ↓   ↓    ↓    ↓   ↓   ↓     ↓       ↓        ↓            ↓
  1   2    3    4   5   6     7       8        9            10
  ```

  | Part | Description |
  |------|-------------|
  | 1    | File type. `-` indicates that this is an ordinary file. |
  | 2    | Permissions of owner user, the meaning of rwx respectively means: read, write, execute.  |
  | ... | ... |

  ```bash
  bash > df -hT
  Filesystem     Type      Size  Used Avail Use% Mounted on  ← Title header
  devtmpfs       devtmpfs  1.8G     0  1.8G   0% /dev
  tmpfs          tmpfs     1.8G     0  1.8G   0% /dev/shm
  tmpfs          tmpfs     1.8G  8.9M  1.8G   1% /run
  tmpfs          tmpfs     1.8G     0  1.8G   0% /sys/fs/cgroup
  /dev/nvme0n1p2 ext4       46G  4.0G   40G  10% /
  /dev/nvme0n1p1 xfs      1014M  248M  767M  25% /boot
  tmpfs          tmpfs     363M     0  363M   0% /run/user/0
  ```

* If the output content of the command is too much, the author will use "..." to indicate it.

  ```bash
  bash > cat /etc/services
  ...
  discard         9/tcp           sink null
  discard         9/udp           sink null
  systat          11/tcp          users
  systat          11/udp          users
  ...
  ```

* If you want to explain a part of the output content, please add line numbers to the output using pipeline symbols.

  ```bash
  bash > tree /etc/yum.repos.d/ | cat -n
     1  /etc/yum.repos.d/
     2  ├── epel-modular.repo
     3  ├── epel.repo
     4  ├── epel-testing-modular.repo
     5  ├── epel-testing.repo
     6  ├── Rocky-AppStream.repo
     7  ├── Rocky-BaseOS.repo
     8  ├── Rocky-Debuginfo.repo
     9  ├── Rocky-Devel.repo
    10  ├── Rocky-Extras.repo
    11  ├── Rocky-HighAvailability.repo
    12  ├── Rocky-Media.repo
    13  ├── Rocky-NFV.repo
    14  ├── Rocky-Plus.repo
    15  ├── Rocky-PowerTools.repo
    16  ├── Rocky-ResilientStorage.repo
    17  ├── Rocky-RT.repo
    18  └── Rocky-Sources.repo
    19
    20  0 directories, 17 files
  ```

   * Epel repository - Lines 2 to 5
   * Rocky repository - Lines 6 to 18
  
* Sometimes, in order to better illustrate the author's intended meaning, adjustments can be made to the output content, such as:

  ```bash
  bash > df -hT 
  | 1             |     2        |  3    |  4   |  5    |   6   |   7            | 8       |
  |Filesystem     |    Type      | Size  | Used | Avail | Use%  | Mounted        | on      |←← first line
  |devtmpfs       |    devtmpfs  | 1.8G  |   0  | 1.8G  |  0%   | /dev           |         |
  |tmpfs          |    tmpfs     | 1.8G  |    0 | 1.8G  |  0%   | /dev/shm       |         |
  |tmpfs          |    tmpfs     | 1.8G  | 8.9M | 1.8G  |  1%   | /run           |         |
  |tmpfs          |    tmpfs     | 1.8G  |   0  | 1.8G  |  0%   | /sys/fs/cgroup |         |
  |/dev/nvme0n1p2 |    ext4      | 47G   | 2.6G |  42G  |  6%   | /              |         |
  |/dev/nvme0n1p1 |    xfs       | 1014M | 182M | 833M  |  18%  | /boot          |         |
  |tmpfs          |    tmpfs     | 364M  |   0  | 364M  |  0%   | /run/user/0    |         |←← end line

  bash > df -hT | awk '{print $1}'
  Filesystem
  devtmpfs
  tmpfs
  tmpfs
  tmpfs
  /dev/nvme0n1p2
  /dev/nvme0n1p1
  tmpfs
  ```

