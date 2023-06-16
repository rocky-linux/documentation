---
title: Introduction 
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
---

# Creating a full LXD Server

## Introduction

LXD is best described on the [official website](https://linuxcontainers.org/lxd/introduction/), but think of it as a container system that provides the benefits of virtual servers in a container.

It is very powerful, and with the right hardware and set up, can be leveraged to run a lot of server instances on a single piece of hardware. If you pair that with a snapshot server, you also have a set of containers that you can spin up almost immediately in the event that your primary server goes down.

(You should not think of this as a traditional backup. You still need a regular backup system of some sort, like [rsnapshot](../../guides/backup/rsnapshot_backup.md).)

The learning curve for LXD can be a bit steep, but this book will attempt to give you a wealth of knowledge at your fingertips, to help you deploy and use LXD on Rocky Linux.

For those wanting to use LXD as a lab environment on their own laptops or workstations, see [Appendix A: Workstation Setup](30-appendix_a.md).

## Prerequisites And Assumptions

* One Rocky Linux server, nicely configured. You should consider a separate hard drive for ZFS disk space (you have to if you are using ZFS) in a production environment. And yes, we are assuming this is a bare metal server, not a VPS.
* This should be considered an advanced topic, but we have tried our best to make it as easy to understand as possible for everyone. That said, knowing a few basic things about container management will take you a long way.
* You should be very comfortable at the command line on your machine(s), and fluent in a command line editor. (We are using _vi_ throughout this example, but you can substitute in your favorite editor.)
* You need to be an unprivileged user for the bulk of the LXD processes. Except where noted, enter LXD commands as your unprivileged user. We are assuming that you are logged in as a user named "lxdadmin" for LXD commands. The bulk of the set up _is_, done as root until you get past the LXD initialization. We will have you create the "lxdadmin" user later in the process.
* For ZFS, make sure that UEFI secure boot is NOT enabled. Otherwise, you will end up having to sign the ZFS module in order to get it to load.
* We are using Rocky Linux-based containers for the most part. 

## Synopsis

* **Chapter 1: Install and Configuration** deals with the installation of the primary server. In general, the proper way to do LXD in production is to have both a primary server and a snapshot server.
* **Chapter 2: ZFS Setup** deals with the setup and configuration of the ZFS. ZFS is an open-source logical volume manager and file system created by Sun Microsystems, originally for its Solaris operating system.
* **Chapter 3: LXD Initialization and User Setup** Deals with the base initialization and options. It also deals with the setup of our unprivileged user that we will use throughout most of the rest of the process.
* **Chapter 4: Firewall Setup** deals with both `iptables` and `firewalld` setup options, but we recommend that you use `firewalld`for all current Rocky Linux versions.
* **Chapter 5: Setting Up and Managing Images** describes the process for installing OS images to a container and configuring them.
* **Chapter 6: Profiles** deals with adding profiles and applying them to containers and particularly covers macvlan and its importance for IP addressing on your LAN or WAN
* **Chapter 7: Container Configuration Options** briefly covers some of the basic configuration options for containers and offers some pros and cons for modifying configuration options.
* **Chapter 8: Container Snapshots** details the snapshot process for containers on the primary server.
* **Chapter 9: The Snapshot Server** covers the setup and configuration of the snapshot server and how to create the symbiotic relationship between the primary and snapshot server. 
* **Chapter 10: Automating Snapshots** covers the automation of snapshot creation and populating the snapshot server with new snapshots.
* **Appendix A: Workstation Setup** not technically a part of the production server documents, but offers a solution for people who want a simple way to build a lab of LXD containers on their personal laptop or workstation.  

## Conclusions

You can use these chapters to effectively setup an enterprise-level primary and snapshot LXD server. In the process, you will learn a great deal about LXD, and we *have* touched on a lot of features. Just be aware that there is much more to learn, and treat these documents as a starting point.

The greatest advantage of LXD is that it is economical to use on a server, allows you to spin up OS installs quickly, can be used for multiple stand-alone application servers running on a single piece of bare metal, all of which properly leverages that hardware for maximum use.
