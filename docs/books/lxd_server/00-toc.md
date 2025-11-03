---
title: Introduction 
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
---

# Creating a full LXD server

!!! warning "LXD status"

    Note that LXD does not contain current images of Rocky Linux 10, or most, if not all, other RHEL clone images. This is likely due to the licensing changes that kept the Linux Containers project from contributing images to LXD. (see other notes below.) That means that if you want a modern containerized platform based on the original LXD development and with many of the original developers contributing, your best bet is to switch to [Incus](../incus_server/00-toc.md). 

!!! info

    This procedure should work for Rocky Linux 8.x or 9.x. If you are looking for a modern implementation of this project from the former lead developers of LXD, but available only for Rocky Linux 9.x, check out [the Incus Server book](../incus_server/00-toc.md).

!!! info "What happened with the LXD project"

    Over a year ago now, the following announcement came out on the lxc-users mailing list:

    > Canonical, the creator and main contributor of the LXD project, has decided that after over eight years as part of the Linux Containers community, the project would now be better served directly under Canonical’s own set of projects.

    One of the deciding factors was the resignations of several lead developers from LXD, who then forked LXD into Incus in August 2023. A release version (0.1) came out in October 2023, and the developers have since rapidly built on that version with step releases through 0.7 (on March 2024). On the heels of 0.7 came the long-term support version, 6.0 LTS, on April 4, 2024, and now 6.4 LTS (as of September 2024).

    Throughout the process, Canonical was thought to continue maintaining links to the container images provided by Linux Containers. Still, because of a [licensing change](https://stgraber.org/2023/12/12/lxd-now-re-licensed-and-under-a-cla/), it became impossible for Linux Containers to continue offering the container images within LXD. While Linux Containers can no longer provide container images to LXD, the LXD project has built some containers, including ones for Rocky Linux. 

    This document uses LXD rather than Incus.

## Introduction

LXD is best described on the [official website](https://documentation.ubuntu.com/lxd/en/latest/), but think of it as a container system that provides the benefits of virtual servers in a container.

It is very powerful, and with the proper hardware and setup, it is possible to create many server instances on a single piece of hardware. If you pair that with a snapshot server, you also have a set of containers you can spin up almost immediately if your primary server goes down.

(You should think of this as something other than a traditional backup. You still need a regular backup system of some sort, [rsnapshot](../../guides/backup/rsnapshot_backup.md), for example.)

The learning curve for LXD can be steep, but this book will attempt to give you a wealth of knowledge at your fingertips to help you deploy and use LXD on Rocky Linux.

For those wanting to use LXD as a lab environment on their notebooks or workstations, see [Appendix A: Workstation Setup](30-appendix_a.md).

## Prerequisites and assumptions

* One Rocky Linux server, nicely configured. Consider a separate hard disk for ZFS storage (you must do so if you are using ZFS) in a production environment. And yes, the assumption here is a bare metal server, not a VPS (Virtual Private Server).
* This is an advanced topic, but it is not too difficult to understand. If you follow these instructions from the beginning, you should be successful. That said, knowing a few basic things about container management will go a long way.
* Comfort at the command line on your machine(s) and fluent in a command line editor. (Using _vi_ throughout these examples, but you can substitute in your favorite editor.)
* You must be your unprivileged user for most of these processes. For the early setup steps, you will need to be the root user or be able to `sudo` to become so. Throughout these chapters, we assume the unprivileged user is "lxdadmin". You'll need to create this user account later in the process.
* For ZFS, please make sure that UEFI secure boot is NOT enabled. Otherwise, you will have to sign the ZFS module to load it.
* Using Rocky Linux-based containers for the most part

## Synopsis

* **Chapter 1: Install and Configuration** deals with installing the primary server. Generally, the right way to do LXD in production is to have a primary and snapshot server.
* **Chapter 2: ZFS Setup** deals with setting up and configuring ZFS. ZFS is an open-source logical volume manager and file system created by Sun Microsystems, originally for its Solaris operating system.
* **Chapter 3: LXD Initialization and User Setup** deals with the base initialization and options, and also the set up of your unprivileged user that you will use throughout most of the rest of the process
* **Chapter 4: Firewall Setup** Has `firewalld` setup options
* **Chapter 5: Setting Up and Managing Images** describes the process for installing operating system images to a container and configuring them
* **Chapter 6: Profiles** deals with adding profiles and applying them to containers and mainly covers macvlan and its importance for IP addressing on your LAN or WAN
* **Chapter 7: Container Configuration Options** briefly covers some of the basic configuration options for containers and offers some benefits and side effects for modifying configuration options
* **Chapter 8: Container Snapshots** details the snapshot process for containers on the primary server
* **Chapter 9: The Snapshot Server** covers the setup and configuration of the snapshot server and how to create the symbiotic relationship between the primary and snapshot server
* **Chapter 10: Automating Snapshots** covers the automation of snapshot creation and populating the snapshot server with snapshots
* **Appendix A: Workstation Setup** is not technically part of the production server documents but offers a solution for people who want to build a lab of LXD containers on their personal notebook or workstation.  

## Conclusions

You can use these chapters to set up an enterprise-level primary and snapshot LXD server effectively. In the process, you will learn a great deal about LXD. Just be aware that there is much more to learn, and treat these documents as a starting point.

The most significant advantage of LXD is that it is economical to use on a server, allows you to spin up operating system installs quickly, and allows for many stand-alone application servers running on a single piece of hardware, leveraging that hardware for maximum use.
