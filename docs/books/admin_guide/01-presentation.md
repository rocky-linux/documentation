---
title: Introduction to Linux
---

# Introduction to the Linux Operating System

In this chapter you will learn about GNU/Linux distributions.

****

**Objectives** : In this chapter you will learn how to:

:heavy_check_mark: Describe the features and possible architectures of an operating system   
:heavy_check_mark: Recount the history of UNIX and GNU/Linux   
:heavy_check_mark: Choose the right Linux distribution for your needs   
:heavy_check_mark: Explain the philosophy of free and opensource software   
:heavy_check_mark: Discover the usefulness of the SHELL.   

:checkered_flag: **generalities**, **linux**, **distributions**

**Knowledge**: :star:    
**Complexity**: :star:

**Reading time**: 10 minutes

****

## What is an operating system?

Linux, UNIX, BSD, Windows, and MacOS are all **operating systems**.

!!! abstract

    An operating system is a **set of programs that manages the available resources of a computer**.

Among this management of resources, the operating system has to:

* Manage the physical or virtual memory.
  * The **physical memory** is made up of the RAM bars and the processor cache memory, which is used for the execution of programs.
  * The **virtual memory** is a location on the hard disk (the **swap** partition) that allows the unloading of the physical memory and the saving of the current state of the system during the electrical shutdown of the computer.
* Intercept **access to peripherals**.
  Software is rarely allowed to access hardware directly (except for graphics cards for very specific needs).
* Provide applications with proper **task management**.
  The operating system is responsible for scheduling processes to occupy the processor.
* **Protect files** from unauthorized access.
* **Collecting information** about programs in use or in progress.

![Operation of an operating system](images/operating_system.png)

## Generalities UNIX - GNU/Linux

### History

#### UNIX

* From **1964 to 1968**:
  MULTICS (MULTiplexed Information and Computing Service) is developed for MIT, Bell Labs (AT&T) and General Electric.

* **1969**: After the withdrawal of Bell (1969) and then General Electric from the project, two developers (Ken Thompson and Dennis Ritchie), joined later by Brian Kernighan, judging MULTICS to be too complex, launched the development of UNIX (UNiplexed Information and Computing Service). Originally developed in assembler, the designers of UNIX developed the B language and then the C language (1971) and completely rewrote UNIX. Having been developed in 1970, the reference date of UNIX/Linux systems is still set at January 01, 1970.

The C language is still one of the most popular programming languages today! A low level language, close to the hardware, it allows the adaptation of the operating system to any machine architecture having a C compiler.

UNIX is an open and evolving operating system that has played a major role in the history of computing. It has been the basis for many other systems: Linux, BSD, MacOS, etc.

UNIX is still relevant today (HP-UX, AIX, Solaris, etc.)

#### Minix

* **1987**: Andrew S. Tanenbaum develops MINIX, a simplified UNIX, to teach operating systems in a simple way. Mr. Tanenbaum makes the source code of his operating system available.

#### Linux

* **1991**: A Finnish student, **Linus Torvalds**, creates an operating system dedicated to his personal computer and names it Linux. He publishes his first version 0.02, on the Usenet discussion forum and other developers come to help him improve his system. The term Linux is a play on words between the founder's first name, Linus, and UNIX.

* **1993**: The Debian distribution is created. Debian is a non-commercial, community-based distribution. Originally developed for use on servers, it is particularly well suited for this role, but it is intended to be a universal system and thus usable on a personal computer as well. Debian is used as the basis for many other distributions, such as Mint or Ubuntu.

* **1994**: The commercial distribution RedHat is created by the company RedHat, which is today the leading distributor of the GNU/Linux operating system. RedHat supports the community version Fedora and recently the free distribution CentOS.

* **1997**: The KDE desktop environment is created. It is based on the Qt component library and the C++ development language.

* **1999**: The Gnome desktop environment is created. It is based on the GTK+ component library.

* **2002**: The Arch distribution is created. Its particularity is to be released in Rolling Release (continuous update).

* **2004**: Ubuntu is created by the Canonical company (Mark Shuttleworth). It is based on Debian, but includes free and proprietary software.

* **2021**: Birth of Rocky Linux, based on RedHat distribution.

### Market share

<!--
TODO: graphics with market share for servers and pc.
-->

Linux is still not well known by the general public, even though they use it regularly. Indeed, Linux is hidden in **smartphones**, **televisions**, **internet boxes**, etc. Almost **70% of the web pages** served in the world are served by a Linux or UNIX server!

Linux equips a little more than **3% of personal computers** but more than **82% of smartphones**. **Android** being an operating system whose kernel is a Linux.

<!-- TODO: review those stats -->

Linux equips 100% of the 500 supercomputers since 2018. A supercomputer is a computer designed to achieve the highest possible performance with the techniques known at the time of its design, especially with regard to computing speed.

### Architectural design

* The **kernel** is the first software component.
  * It is the heart of the Linux system.
  * It manages the hardware resources of the system.
  * The other software components must go through it to access the hardware.
* The **shell** is a utility that interprets user commands and ensures their execution.
  * Main shells: Bourne shell, C shell, Korn shell and Bourne-Again shell (bash).
* Applications are user programs such as :
  * Internet browser ;
  * the word processor ;
  * ...

#### Multitask

Linux belongs to the family of time-sharing operating systems. It shares process time between several programs, switching from one to another in a transparent way for the user. This implies:

* simultaneous execution of several programs;
* distribution of CPU time by the scheduler;
* reduction of problems due to a failed application;
* reduced performance when there are too many programs running.

#### Multi user

The purpose of Multics was to allow several users to work from several terminals (screen and keyboard) on a single computer (very expensive at the time). Linux, which is inspired by this operating system, has kept this ability to work with several users simultaneously and independently, each one having its own user account, memory space and access rights to files and software.

#### Multiprocessor

Linux is able to work with multi-processor computers or with multi-core processors.

#### Multi platform

Linux is written in a high-level language that can be adapted to different types of platforms during compilation. It therefore runs on :

* home computers (PC or laptop);
* servers (data, applications,...);
* portable computers (smartphones or tablets)
* embedded systems (car computer);
* active network elements (routers, switches)
* household appliances (TVs, refrigerators,...).

#### Open

Linux is based on recognized standards [posix](http://fr.wikipedia.org/wiki/POSIX), TCP/IP, NFS, Samba ... allowing to share data and services with other application systems.

### The UNIX/Linux philosophy

* Everything is a file.
* Portability.
* Do only one thing and do it well.
* KISS: Keep It Simple Stupid.
* "UNIX is basically a simple operating system, but you have to be a genius to understand the simplicity." (__Dennis Ritchie__)
* "Unix is user-friendly. It just isn't promiscuous about which users it's friendly with." (__Steven King__)

## The GNU/LINUX distributions

A Linux distribution is a **consistent set of software** assembled around the Linux kernel and ready to be installed along with the necessary components to manage this software (installation, removal, configuration). There are **associative or community** distributions (Debian, Rocky) or **commercial** (RedHat, Ubuntu).

Each distribution offers one or more **desktop environments**, provides a set of pre-installed software and a library of additional software. Configuration options (kernel or services options for example) are specific to each one.

This principle allows you to have distributions oriented to **beginners** (Ubuntu, Linux Mint...), to have a more complex approach (Gentoo, Arch), to be focused more towards **servers** (Debian, Redhat), or to be dedicated towards **workstations**.

### Desktop environments

There are many graphic environments: **Gnome**, **KDE**, **LXDE**, **XFCE**, etc. There is something for everyone, and their **ergonomics** have nothing to be ashamed of when compared to Microsoft or Apple systems!

So why is there so little enthusiasm for Linux, when **there are no (or almost no) viruses for this system**? Maybe because all editors (Adobe) or manufacturers (Nvidia) do not play the free game and do not provide a version of their software or their __drivers__ for GNU/Linux? Fear of change? The difficulty to find where to buy a Linux computer? Too few games (but not for long) distributed under Linux? Will the situation change with the arrival of the steam-box game console that runs on Linux?

![Gnome Desktop](images/01-presentation-gnome.png)

The **Gnome 3** desktop environment no longer uses the concept of Desktop but that of Gnome Shell (not to be confused with the command line shell). It serves as a desktop, a dashboard, a notification area and a window selector. The Gnome desktop environment is based on the GTK+ component library.

![KDE Desktop](images/01-presentation-kde.png)

The **KDE** desktop environment is based on the **Qt** component library.

It is traditionally more recommended for users coming from a Windows world.

![Tux - The Linux mascot](images/tux.png)

### Free / Open source

A user of a Microsoft or Mac operating system must purchase a license to use the operating system. This license has a cost, although it is usually transparent (the price of the license is included in the price of the computer).

In the **GNU/Linux** world, the Free Software movement provides mostly free distributions.

**Free** does not mean free!

**Open source**: the source codes are available, so it is possible to consult and modify them under certain conditions.

A free software is necessarily Open Source, but the opposite is not true since an Open Source software is separated from the freedom proposed by the GPL license.

#### GPL License (General Public License)

The **GPL License** guarantees the author of a software its intellectual property, but allows modification, redistribution or resale of software by third parties, provided that the source codes are provided with the software. The GPL is the license that came out of the **GNU** (GNU is Not UNIX) project, which was instrumental in creating Linux.

It implies :

* the freedom to run the program, for any purpose;
* the freedom to study how the program works and adapt it to your needs
* the freedom to redistribute copies;
* the freedom to improve the program and publish your improvements, for the benefit of the whole community.

On the other hand, even products licensed under the GPL can be paid for. This is not the product itself, but the guarantee that a team of developers will continue to work on it to make it evolve and troubleshoot errors, or even provide support to users.

## Areas of use

A Linux distribution excels for :

* **A server**: HTTP, email, groupware, file sharing, etc.
* **Security**: Gateway, firewall, router, proxy, etc.
* **Central computer**: Banks, insurance, industry, etc.
* **Embedded system**: Routers, Internet boxes, SmartTV, etc.

Linux is a suitable choice for hosting databases or websites, or as a mail server, DNS or firewall. In short, Linux can do just about anything, which explains the quantity of specific distributions.

## Shell

### Generalities

The **shell**, known as _command interface_, allows users to send commands to the operating system. It is less visible today, since the implementation of graphical interfaces, but remains a privileged means on Linux systems which do not all have graphical interfaces and whose services do not always have a setting interface.

It offers a real programming language including the classical structures: loops, alternatives, and the common constituents: variables, passing of parameters, and sub-programs. It allows the creation of scripts to automate certain actions (backups, creation of users, system monitoring, etc.).

There are several types of shells available and configurable on a platform or according to the user's preference:

* sh, the POSIX standard shell ;
* csh, command-oriented shell in C ;
* bash, Bourne-Again Shell, Linux shell.
* etc, ...

## Functionalities

* Command execution (checks the command given and executes it);
* Input/Output redirection (returns data to a file instead of writing it on the screen);
* Connection process (manages the user's connection);
* Interpreted programming language (allowing the creation of scripts);
* Environment variables (access to information specific to the system during operation).

### Principle

![Operating principle of the SHELL](images/shell-principle.png)

## Check your Knowledge

:heavy_check_mark: An operating system is a set of programs for managing the available resources of a computer:

- [ ] True   
- [ ] False

:heavy_check_mark: The operating system is brought to:

- [ ] Manage physical and virtual memory   
- [ ] Allow direct access to peripherals   
- [ ] Subcontract the management of tasks to the processor   
- [ ] Collect information about the programs used or in use   

:heavy_check_mark: Among these personalities, which ones participated in the development of UNIX:

- [ ] Linus Torvalds   
- [ ] Ken Thompson   
- [ ] Lionel Richie   
- [ ] Brian Kernighan   
- [ ] Andrew Stuart Tanenbaum   

:heavy_check_mark: The original nationality of Linus Torvalds, creator of the Linux kernel, is:

- [ ] Swedish   
- [ ] Finnish   
- [ ] Norwegian   
- [ ] Flemish   
- [ ] French of course   

:heavy_check_mark: Which of the following distributions is the oldest:

- [ ] Debian   
- [ ] Slackware   
- [ ] RedHat   
- [ ] Arch

:heavy_check_mark: Is the Linux kernel:

- [ ] Multitasking   
- [ ] Multi user   
- [ ] Multiprocessor   
- [ ] Multi-core   
- [ ] Cross-platform   
- [ ] Open   

:heavy_check_mark: Is free software necessarily open source?

- [ ] True   
- [ ] False   

:heavy_check_mark: Is Open Source software necessarily free?

- [ ] True   
- [ ] False   

:heavy_check_mark: Which of the following is not a shell:

- [ ] Jason   
- [ ] Jason-Bourne shell (jbsh)   
- [ ] Bourne-Again shell (bash)   
- [ ] C shell (csh)   
- [ ] Korn shell (ksh)   
