---
title: about systemd
author: tianci li
contributors:
tags:
  - init software
  - systemd
  - Upstart
  - System V 
---

# Basic overview

The **systemd**, also known as **system daemon**, is a kind of init software under GNU/linux OS. 

Purpose of development:

* To provide a better framework for representing dependencies between services
* Implements parallel startup of services at system initialization
* Reduces Shell overhead and replaces System V style init

The **systemd** provides a series of system components for the GNU/Linux operating system, with the goal of unifying the service configuration and behavior across GNU/Linux distributions and eliminating differences in their usage.

Since 2015, most GNU/Linux distributions have adopted systemd to replace traditional init programs such as SysV. It is worth noting that many of the concepts and designs of systemd are inspired by Apple Mac OS's **launchd**.

![init-compare](./images/16-init-compare.jpg)

After the emergence of systemd, it caused huge controversy in the open source community.

Praising voices:

* Developers and users have praised systemd for eliminating the usage differences between GNU/Linux and providing a more stable and faster out-of-the-box solution.

Critical voices:

* Systemd takes over too many components on the operating system, violating UNIX's KISS (**K**eep **I**t **S**imple, **S**tupid) principle.
* From a code perspective, the systemd is too complex and cumbersome, with over a million lines of code, thus reducing maintainability and increasing attack surface.

Official website - https://systemd.io/
The github repository - https://github.com/systemd/systemd

## Development history

In 2010, two Red Hat software engineers, Lennart Poettering and Kay Sievers, developed the first version of systemd to replace the traditional System V .

![Lennart Poettering](./images/16-Lennart%20Poettering.jpg)

![Kay Sievers](./images/16-Kay-Sievers-.jpg)

In May 2011, Fedora 15 became the first GNU/Linux distribution to enable systemd by default, with the reason given at the time:

> systemd provides aggressive parallelization capabilities, uses socket and D-Bus activation for starting services, offers on-demand starting of daemons, keeps track of processes using Linux cgroups, supports snapshotting and restoring of the system state, maintains mount and automount points and implements a powerful transactional dependency-based service control logic. It can work as a drop-in replacement for sysvinit. 

In October 2012, Arch Linux was booted with systemd by default.

From October 2013 to February 2014, the Debian Technical Committee had a long debate on the Debian mailing list, focusing on the topic "which init should be used by Debian 8 jessie as the system default" and finally decided to use systemd.

In February 2014, Ubuntu adopted systemd as its init and abandoned its own Upstart.

In August 2015, systemd began providing login shells that can be called through `machinectl`.

In 2016, systemd discovered a security vulnerability that allowed any non privileged user to perform a "deny of service attack" on systemd.

In 2017, systemd discovered another security vulnerability - CVE-2017-9445. Remote attackers can trigger a buffer overflow vulnerability and execute malicious code through malicious DNS responses.

!!! info

    **Buffer overflow**: It is a program design flaw that writes to the input buffer of a program to make it overflow (usually more data than the maximum amount of data that can be stored in the buffer), thus disrupting the program operation, taking advantage of the occasion of interruption, and obtaining control of the program or even the system.