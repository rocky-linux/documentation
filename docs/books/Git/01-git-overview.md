---
title: Git overview
author: tianci li
contributors: 
update: 2026-11-26
---

## Introduction

When it comes to Git, we need to mention a concept called version control.

**Version control**: refers to a method used during the development process to manage the modification history of files, directories, projects, code, and other content, which can be easily rolled back, backed up, and viewed.

The benefits of using version control include:

* Multi person collaborative development across regions
* Track and record the history of one or more files
* Organize and protect the source code and documentation
* Statistical workload
* Parallel development to enhance development efficiency
* Record the entire software development process
* Reduce the burden on developers, save time and costs, and minimize human errors

For most people who have no experience with Git, version control has already become an integral part of their daily work. For instance, contracts, resumes, and important documents often have multiple versions. This manual version control method mainly distinguishes them through file names:

```
Resume-2026-10-01-v1.pdf
Resume-2026-10-03-v2.pdf
...
```

However, in a business environment, a commercial contract may involve personnel from different departments, and understanding the specific details of their modifications has become a very tricky issue. In software projects or engineering, it is also necessary to solve such headache problems, so Git was born. 

The official definition of Git is:

> Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency.

In addition to [Git](https://git-scm.com/), there are also version control systems such as [SVN](https://subversion.apache.org/) and [CVS](https://cvs.nongnu.org/).

## Classification of version control

1. **Local version control** - Store the historical versions of files on the local computer's hard drive and record file updates through snapshots or patch files. This version control does not support multi-person cross-device collaboration and is more suitable for individuals. A typical representative is [RCS](https://www.gnu.org/software/rcs/).
2. **C/S version control (Also known as centralized version control)** - All version history data is stored uniformly on the central server, and users only keep the latest synchronized file copy locally. Users must be connected to the internet to submit updates and view historical versions. If the central server fails, all data will be lost, which is known as a single point of failure. A typical representative is SVN.
3. **Distributed version control** - Each user synchronizes the complete project version history locally, allowing offline submission and viewing of the full history without the need for an internet connection. A typical representative is Git.

## Birth history

If you are familiar with the birth history of GNU/Linux, you should know the timeline of these major events:

> 1982: AT&T's UNIX became a commercial version, which not only required payment but also did not allow free distribution or replication. 
> 1987: Influenced by BSD, many amateur experts have developed their own versions of UNIX-like systems. For the purpose of teaching the operating system course, Professor **Andrew S. Tanenbaum** from a Dutch university developed MINIX (a simplified version of UNIX, based on the 7th edition of the then-current UNIX), allowing students to read and fully obtain the source code of the operating system.
> 1991: A student named Linus Torvalds from the University of Helsinki in Finland, majoring in computer science and studying the [MINIX](http://www.minix3.org/) operating system at that time. Later, Linus and some enthusiasts took the MINIX operating system as a template, used tools such as Bash and GCC, combined with patches from Linus himself and other contributors, developed a version of the Linux kernel, and made it available on the Internet for people to learn, download, and improve. In September of the same year, version 0.01 of the Linux kernel was released on [FUNET's FTP server](https://ftp.funet.fi/), with 10239 lines of code. FUNET stands for Finnish University and Research Network. In October of the same year, version 0.02 was released. In December of the same year, version 0.11 was released.
> 1992-02: The 0.12 version of the Linux kernel is released and licensed under the GPL open source license. The previous version of the Linux kernel did not allow commercial redistribution.
> 1994-03-14: Release of Linux kernel version 1.0.0

Linus made the Linux kernel open source, and many open source enthusiasts around the world have participated in it. Before 2002, during the maintenance of the Linux kernel, Linus spent a considerable amount of time on tedious tasks such as submitting patches and saving archives.

In 2002, as the code size of the Linux kernel increased significantly, maintaining the Linux kernel became increasingly difficult. Therefore, the entire project team decided to adopt a proprietary distributed version control system, [BitKeeper](https://www.bitkeeper.org/), to manage and maintain the code.

There are many technical experts in the open source community, and a considerable number of people are preparing to research and crack BitKeeper, including Australian programmer **Andrew Tridgwell** who developed Samba.

In 2005, the commercial company BitMover, which developed the BitKeeper product, ended its partnership with the Linux kernel open source community and revoked the right to use BitKeeper for free from the Linux kernel community. The reason was that the cracking behavior of community experts was discovered by BitMover.

Since BitKeeper was no longer allowed to be used, but the work of maintaining the Linux kernel still had to continue. So Linus developed Git in about two weeks using the C language, and spent one month using Git to manage the source code of the Linux kernel.

As of the release of this document, Git version is 2.56.1 (2026-10-26).

## Installation

* For Windows OS - Download the [installation package](https://github.com/git-for-windows/git/releases/download/v2.56.1.windows.1/Git-2.56.1-64-bit.exe) to the local computer and perform the installation operation. After installation, right clicking on a blank space on the desktop will prompt you to operate Git.
* For GNU/Linux OS - For upstream and downstream distributions using RHEL, type `dnf -y install git` to complete the installation.

For detailed installation instructions, please refer to the [official instructions](https://git-scm.com/install/).

## Version naming conventions

The current software versions mainly adopt two naming conventions:

* **SemVer (Semantic Versioning‌)** - This version naming convention was proposed by **Tom Preston-Werner** and widely used in the global open source community. In daily conversations, it is also known as the three-segment version naming specification or the dot-separated version naming specification. Its core format is **X.Y.Z (Major-version.Minor-version.Revision-number)**, and sometimes some extended version identifiers are added. For example:

    ```
    1.0.0
    2.1.5
    3.0.0-alpha
    4.2.5-beta.2
    5.6.0+20261125
    ```

    The software versions in the Rocky Linux repository adopt this naming convention.

    Please note that the SemVer specification explicitly prohibits leading zeros, for example, this kind of version naming does not comply with the specification:

    ```
    01.02.03
    1.02.3
    2.1.005
    ```

    For more information, please refer to [this link](https://semver.org/).

* **CalVer (‌Calendar Versioning)** - A version naming convention centered around the project release calendar. The mainstream formats include:

    * **YYYY.MINOR.MICRO** - "YYYY" represents a four-digit year, with "MINOR" and "MICRO" increasing from 0 each year. For example `2026.0.0`
    * **YYYY.M.D** - The year, month and day corresponding to the natural date. Dates with fewer than two digits are usually uniformly padded with a leading zero, for example `2026.01.14`
    * **YYYY.M.D-modifier.N‌** - For example `2026.5.4-alpha.2`
