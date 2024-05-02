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

??? warning "LXD on Rocky Linux current status!"

    Nearly a year ago now, the following announcement came out on the lxc-users mailing list:

    > Canonical, the creator and main contributor of the LXD project has decided that after over 8 years as part of the Linux Containers community, the project would now be better served directly under Canonical’s own set of projects.

    One of the deciding factors were the resignations of some lead developers for LXD, who then went on to fork LXD into Incus, announcing the fork in August 2023. A release version (0.1) came out in October 2023, and the developers have since rapidly built on that version with step releases through 0.7 (on March 2024). On the heals of 0.7, came the long term support version, 6.0 LTS on April 4, 2024.

    Throughout the process, it was thought that Cannonical would continue to maintain links to the container images provided by Linux Containers, but because of a [licensing change](https://stgraber.org/2023/12/12/lxd-now-re-licensed-and-under-a-cla/) it became impossible for Linux Containers to continue to offer the container images within LXD. What this means is that LXD will have container images, but they will not be the container images you might currently expect. Linux Containers continues to host and support their images if you are using Incus. 

    This document uses LXD, rather than Incus, BUT it is our intention to rewrite the procedure for Incus. We were hoping for an RPM version of Incus to be released in the EPEL, and while that is in the works, it is not ready. This means that in order to rewrite this procedure for Incus, we need to focus our interests on the source package installation and conversion routine. The reason for this long warning, is that we do not want you to take the time to install using this procedure and then discover that the container images (Rocky Linux for instance) aren't available within LXD. 

    Keep an eye out for changes here!

## Introduction

LXD is best described on the [official website](https://documentation.ubuntu.com/lxd/en/latest/), but think of it as a container system that provides the benefits of virtual servers in a container.

It is very powerful, and with the right hardware and set up, it is possible to create many server instances on a single piece of hardware. If you pair that with a snapshot server, you also have a set of containers that you can spin up almost immediately if your primary server goes down.

(You should not think of this as a traditional backup. You still need a regular backup system of some sort, [rsnapshot](../../guides/backup/rsnapshot_backup.md) for example.)

The learning curve for LXD can be a bit steep, but this book will attempt to give you a wealth of knowledge at your fingertips, to help you deploy and use LXD on Rocky Linux.

For those wanting to use LXD as a lab environment on their own notebooks or workstations, see [Appendix A: Workstation Setup](30-appendix_a.md).

## Prerequisites and assumptions

* One Rocky Linux server, nicely configured. Consider a separate hard disk for ZFS disk space (you have to if you are using ZFS) in a production environment. And yes, the assumption here is a bare metal server, not a VPS (Virtual Private Server).
* This is an advanced topic, but it is not too difficult to understand, and if you follow these instructions from the beginning you should be successful. That said, knowing a few basic things about container management will take you a long way.
* Comfort at the command line on your machine(s), and fluent in a command line editor. (Using _vi_ throughout these examples, but you can substitute in your favorite editor.)
* You will need to be your unprivileged user for the bulk of these processes. For the early setup steps, you will need to be the root user or be able to `sudo` to become so. Throughout these chapters, we assume your unprivileged user to be "lxdadmin". You will have to create this user account later in the process.
* For ZFS, ensure that UEFI secure boot is NOT enabled. Otherwise, you will end up having to sign the ZFS module to get it to load.
* Using Rocky Linux-based containers for the most part

## Synopsis

* **Chapter 1: Install and Configuration** deals with the installation of the primary server. In general, the right way to do LXD in production is to have a primary server and a snapshot server.
* **Chapter 2: ZFS Setup** deals with the setup and configuration of the ZFS. ZFS is an open source logical volume manager and file system created by Sun Microsystems, originally for its Solaris operating system.
* **Chapter 3: LXD Initialization and User Setup** deals with the base initialization and options, and also the setup of your unprivileged user that you will use throughout most of the rest of the process
* **Chapter 4: Firewall Setup** Has `firewalld` setup options
* **Chapter 5: Setting Up and Managing Images** describes the process for installing operating system images to a container and configuring them
* **Chapter 6: Profiles** deals with adding profiles and applying them to containers, and particularly covers macvlan and its importance for IP addressing on your LAN or WAN
* **Chapter 7: Container Configuration Options** briefly covers some of the basic configuration options for containers and offers some benefits and side effects for modifying configuration options
* **Chapter 8: Container Snapshots** details the snapshot process for containers on the primary server
* **Chapter 9: The Snapshot Server** covers the setup and configuration of the snapshot server and how to create the symbiotic relationship between the primary and snapshot server
* **Chapter 10: Automating Snapshots** covers the automation of snapshot creation and populating the snapshot server with snapshots
* **Appendix A: Workstation Setup** not technically a part of the production server documents, but offers a solution for people who want a way to build a lab of LXD containers on their personal notebook or workstation.  

## Conclusions

You can use these chapters to effectively setup an enterprise-level primary and snapshot LXD server. In the process, you will learn a great deal about LXD. Just be aware that there is much more to learn, and treat these documents as a starting point.

The greatest advantage of LXD is that it is economical to use on a server, allows you to spin up operating system installs quickly, allows for many stand-alone application servers running on a single piece of hardware, leveraging that hardware for maximum use.
