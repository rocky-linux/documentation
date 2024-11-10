---
title: Introduction 
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with:  9.4
tags:
  - lxd
  - incus
  - enterprise
---

# Creating an Incus server

## Incus status on Rocky Linux

Nearly a year ago now, the following announcement came out on the lxc-users mailing list:

> Canonical, the creator and main contributor of the LXD project has decided that after over 8 years as part of the Linux Containers community, the project would now be better served directly under Canonical’s own set of projects.

One of the deciding factors was the resignations of some lead developers for LXD. These developers then forked LXD into Incus, announcing the fork in August 2023. A release version (0.1) came out in October 2023, and the developers have since rapidly built on that version with step releases through 0.7 (in March 2024). The release of the long-term support version (6.0 LTS) followed the 0.7 release. The current version is 6.5.

Throughout the process, Canonical was believed to continue maintaining links to the container images provided by Linux Containers. However, a [licensing change](https://stgraber.org/2023/12/12/lxd-now-re-licensed-and-under-a-cla/) made it impossible for Linux Containers to continue offering the container images within LXD. This means that LXD will have container images, but they will not be what you might expect. Linux Containers continues to host and support their images if you are using Incus.

This document is a conversion of [the LXD book](../lxd_server/00-toc.md) to Incus. Since the creation of a repository by Rocky Linux project infrastructure co-lead [Neil Hanlon](https://wiki.rockylinux.org/team/infrastructure/), you have the option of installing Incus before its inclusion in the EPEL (Extra Packages for Enterprise Linux repository).

!!! warning "Incus server not available on Rocky Linux 8"

    The Incus server installation is available only for Rocky Linux 9.x and is currently tested on Rocky Linux 9.4. If you need something that works on Rocky Linux 8.x, use the [previously mentioned LXD procedure](../lxd_server/00-toc.md).

## Introduction

Incus is best described on the [official website](https://linuxcontainers.org/incus/), but think of it as a container system that provides the benefits of virtual servers in a container.

It is very powerful, and with the proper hardware and setup, it is possible to create many server instances on a single piece of hardware. If you pair that with a snapshot server, you also have a set of containers you can spin up almost immediately if your primary server goes down.

!!! warning "This is not a backup"

    You should not think of this as a traditional backup. You still need a regular backup system, such as [rsnapshot](../../guides/backup/rsnapshot_backup.md).

The Incus learning curve can be steep, but this book will attempt to give you the knowledge to help you deploy and use Incus on Rocky Linux.

For those wanting to use Incus as a lab environment on their notebooks or workstations, see [Appendix A: Workstation Setup](30-appendix_a.md).

## Prerequisites and assumptions

* One Rocky Linux 9 server, nicely configured. Consider a separate hard disk for ZFS disk space in a production environment (you must do so if you use ZFS). And yes, the assumption here is a bare metal server, not a VPS (Virtual Private Server).
* This is an advanced topic, but it is not too difficult to understand. If you follow these instructions from the beginning, you should be successful. That said, knowing a few basic things about container management will go a long way.
* Comfort at the command line on your machine(s) and fluent in a command line editor. (Using _vi_ throughout these examples, but you can substitute in your favorite editor.)
* You will need to be your unprivileged user for most of these processes. For the early setup steps, you will need to be the root user or be able to `sudo` to become so. Throughout these chapters, we assume your unprivileged user to be "incusadmin". You will need to create this user account later in the process.
* For ZFS, ensure that UEFI secure boot is NOT enabled. Otherwise, you must sign the ZFS module to get it to load.
* Using Rocky Linux-based containers for the most part

!!! info

    The author includes a methodology for using a ZFS filesystem. Please note that the Incus project recommends BTRFS as a file system for an Incus server. (ZFS is still a filesystem option.) BTRFS, however, is not available at all on Rocky Linux 9.4. Until it is sanctioned by the upstream and released there, your only option is to use ZFS or another included filesystem. To learn more about Incus filesystem options, see [the project's official document here.](https://linuxcontainers.org/incus/docs/main/reference/storage_dir/)  

## Synopsis

* **Chapter 1: Install and Configuration** deals with installing the primary server. Generally, the right way to do Incus in production is to have a primary and snapshot server.
* **Chapter 2: ZFS Setup** deals with setting up and configuring ZFS. ZFS is an open-source logical volume manager and file system created by Sun Microsystems, originally for its Solaris operating system.
* **Chapter 3: Incus Initialization and User Setup** deals with the base initialization and options, and also the set up of your unprivileged user that you will use throughout most of the rest of the process
* **Chapter 4: Firewall Setup** Has `firewalld` setup options
* **Chapter 5: Setting Up and Managing Images** describes the process for installing operating system images to a container and configuring them
* **Chapter 6: Profiles** deals with adding profiles and applying them to containers and mainly covers `macvlan` and its importance for IP addressing on your LAN or WAN
* **Chapter 7: Container Configuration Options** briefly covers some of the basic configuration options for containers and offers some benefits and side effects for modifying configuration options
* **Chapter 8: Container Snapshots** details the snapshot process for containers on the primary server
* **Chapter 9: The Snapshot Server** covers the setup and configuration of the snapshot server and how to create the symbiotic relationship between the primary and snapshot server
* **Chapter 10: Automating Snapshots** covers the automation of snapshot creation and populating the snapshot server with snapshots
* **Appendix A: Workstation Setup** is not technically part of the production server documents. It offers a solution for people who want to build a lab of Incus containers on their notebooks or workstations.  

## Conclusions

You can use these chapters to effectively set up an enterprise-level primary and snapshot Incus server pair. In the process, you will learn a great deal about Incus. Just be aware that there is much more to learn, and treat these documents as a starting point.

The most significant advantage of Incus is that it is economical to use on a server, allows you to spin up operating system installs quickly, and allows for many standalone application servers running on a single piece of hardware, leveraging that hardware for maximum use.
