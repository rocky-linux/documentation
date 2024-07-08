---
author: Antoine Le Morvan
contributors: 
title: Part 7. High availability
tags:
  - clustering
  - ha
  - high availability
  - pcs
  - pacemaker
---

## Clustering under Linux

> **High availability** is a term often used in IT, in connection with system architecture or a service, to designate the fact that this architecture or service has a suitable rate of availability.  
~ wikipedia

This availability is a performance measure expressed as a percentage obtained by the ratio **Operating time** / **Total desired operating time**.

| Rates    | Annual downtime               |
| -------- | ----------------------------- |
| 90%      | 876 hours                     |
| 95%      | 438 hours                     |
| 99%      | 87 hours et 36 minutes        |
| 99,9%    | 8 hours 45 minutes 36 seconds |
| 99,99%   | 52 minutes, 33 seconds        |
| 99,999%  | 5 minutes, 15 seconds         |
| 99,9999% | 31,68 seconds                 |

High Availability" (**HA**) refers to all the measures taken to guarantee the highest possible availability of a service, i.e. its correct operation 24 hours a day.

### Overview

A cluster is a "computer cluster", a group of two or more machines.

A cluster allows :

* distributed computing using the computing power of all the nodes,
* high availability, service continuity and automatic service failover in the event of a node failure.

#### Types of services

* Active/passive services

Installing a cluster with two active/passive nodes using Pacemaker and DRBD is a low-cost solution for many situations requiring a high-availability system.

* N+1 services

With multiple nodes, Pacemaker can reduce hardware costs by allowing several active/passive clusters to combine and share a backup node.

* N TO N services

With shared storage, every node can potentially be used for fault tolerance. Pacemaker can also run multiple copies of services to spread the workload.

* Remote site services

Pacemaker includes enhancements to simplify the creation of multi-site clusters.

#### VIP

The VIP is a virtual IP address. This address is assigned to an Active/Passive cluster. It is assigned to the cluster node that is active. In the event of a service failure, the VIP is deactivated on the failed node and activated on the node taking over: this is known as failover.

Clients always address the cluster using VIP, making active server failovers transparent to them.

#### Split-brain

Split-brain is the main risk a cluster may encounter. This condition occurs when several nodes in a cluster think their neighbor is inactive. The node then tries to start the redundant service, and several nodes provide the same service, which can lead to annoying side-effects (duplicate VIPs on the network, competing data access, etc.).

Possible technical solutions to avoid this problem are :

* Separate public network traffic from cluster network traffic,
* using network bonding.

## Pacemaker (PCS)

In this chapter, you will learn about Pacemaker, a clustering solution.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: installer et configurer un cluster Pacemaker  
:heavy_check_mark: administrer un cluster Pacemaker  

:checkered_flag: **clustering**, **ha**, **high availability**, **pcs**, **pacemaker**

**Knowledge**: :star: :star: :star:  
**Complexity**: :star: :star:  

**Reading time**: 20 minutes

****

### Generalities

**Pacemaker** is the software part of the cluster that manages its resources (VIPs, services, data). It is responsible for starting, stopping and supervising cluster resources. It guarantees high node availability.

Pacemaker uses the message layer provided by **corosync** (default) or **Heartbeat**.

Pacemaker consists of **5 key components**:

* Cluster Information Base (**CIB**)
* Cluster Resource Management daemon (**CRMd**)
* Local Resource Management daemon (**LRMd**)
* Policy Engine (**PEngine** or **PE**)
* Fencing daemon (**STONITHd**)

The CIB represents the cluster configuration and the current state of all cluster resources. The contents of the CIB are automatically synchronized across the entire cluster and used by the PEngine to calculate the ideal cluster state and how it should be achieved.

The list of instructions is then provided to the Designated Controller (DC). Pacemaker centralizes all cluster decisions by electing one of the CRMd instances as master.

The DC executes the PEngine's instructions in the required order, transmitting them either to the local LRMd or to the CRMd of the other nodes via Corosync or Heartbeat.

In some cases, it may be necessary to stop nodes in order to protect shared data or enable their recovery. Pacemaker comes with STONITHd for this purpose.

#### Stonith

Stonith is a component of Pacemaker. It stands for Shoot-The-Other-Node-In-The-Head, a recommended practice for ensuring that the malfunctioning node is isolated as quickly as possible (shut down or at least disconnected from shared resources), thus avoiding data corruption.

An unresponsive node does not mean that it can no longer access data. The only way to ensure that a node is no longer accessing data before handing over to another node is to use STONITH, which will either shut down or restart the failed server.

STONITH also has a role to play in the event of a clustered service failing to shut down. In this case, Pacemaker uses STONITH to force the entire node to stop.

#### Quorum management

The quorum represents the minimum number of nodes in operation to validate a decision, such as deciding which backup node should take over when one of the nodes is in error. By default, Pacemaker requires more than half the nodes to be online.

When communication problems split a cluster into several groups of nodes, quorum is used to prevent resources from starting up on more nodes than expected. A cluster is quorate when more than half of all nodes known to be online are in its group (active_nodes_group > active_total_nodes / 2 ).

The default decision when quorum is not reached is to disable all resources.

Case study:

* On a **two-node cluster**, since quorum can **never be reached** in the event of a node failure, it must be ignored or the entire cluster will be shut down.
* If a 5-node cluster is split into 2 groups of 3 and 2 nodes, the 3-node group will have quorum and continue to manage resources.
* If a 6-node cluster is split into 2 groups of 3 nodes, no group will have quorum. In this case, pacemaker's default behavior is to stop all resources to avoid data corruption.

#### Cluster communication

Pacemaker uses either **Corosync** or **Heartbeat** (from the linux-ha project) for node-to-node communication and cluster management.

##### Corosync

**Corosync Cluster Engine** is a messaging layer between cluster members and integrates additional functionalities for implementing high availability within applications. The Corosync project is derived from the OpenAIS project.

Nodes communicate in Client/Server mode via the UDP protocol.

It can be used to manage clusters of more than 16 nodes in Active/Passive or Active/Active modes.

##### Heartbeat

Heartbeat technology is more limited than Corosync. It is not possible to create a cluster of more than 2 nodes, and its management rules are less sophisticated than those of its competitor.

!!! NOTE

    The choice of pacemaker/corosync today seems more appropriate, as it is the default choice for RedHat, Debian and Ubuntu distributions.

#### Data management

##### The drdb network raid

DRDB is a block-type device driver that enables the implementation of RAID 1 (mirroring) over the network.

DRDB can be useful when NAS or SAN technologies are not available, but data still needs to be synchronized.

### Installation

To install Pacemaker, first enable the `highavailability` repo:

```bash
sudo dnf config-manager --set-enabled highavailability
```

Some information about the pacemaker package:

```bash
$ dnf info pacemaker
Rocky Linux 9 - High Availability                                                                                                                                     289 kB/s | 250 kB     00:00    
Available Packages
Name         : pacemaker
Version      : 2.1.7
Release      : 5.el9_4
Architecture : x86_64
Size         : 465 k
Source       : pacemaker-2.1.7-5.el9_4.src.rpm
Repository   : highavailability
Summary      : Scalable High-Availability cluster resource manager
URL          : https://www.clusterlabs.org/
License      : GPL-2.0-or-later AND LGPL-2.1-or-later
Description  : Pacemaker is an advanced, scalable High-Availability cluster resource
             : manager.
             :
             : It supports more than 16 node clusters with significant capabilities
             : for managing resources and dependencies.
             :
             : It will run scripts at initialization, when machines go up or down,
             : when related resources fail and can be configured to periodically check
             : resource health.
             :
             : Available rpmbuild rebuild options:
             :   --with(out) : cibsecrets hardening nls pre_release profiling
             :                 stonithd


```

Using the `repoquery` command, you can find out the dependencies of the pacemaker package:

```bash
$ repoquery --requires pacemaker
corosync >= 3.1.1
pacemaker-cli = 2.1.7-5.el9_4
resource-agents
systemd
...
```

The pacemaker installation will therefore automatically install corosync and a CLI interface for pacemaker.

Some information about the corosync package:

```bash
$ dnf info corosync
Available Packages
Name         : corosync
Version      : 3.1.8
Release      : 1.el9
Architecture : x86_64
Size         : 262 k
Source       : corosync-3.1.8-1.el9.src.rpm
Repository   : highavailability
Summary      : The Corosync Cluster Engine and Application Programming Interfaces
URL          : http://corosync.github.io/corosync/
License      : BSD
Description  : This package contains the Corosync Cluster Engine Executive, several default
             : APIs and libraries, default configuration files, and an init script.
```

Install now the required packets:

```bash
sudo dnf install pacemaker
```

Open your firewall if you have one:

```bash
sudo firewall-cmd --permanent --add-service=high-availability
sudo firewall-cmd --reload
```

The services can now be activated for the next startup:

```bash
sudo systemctl enable corosync
sudo systemctl enable pacemaker
```

### Cluster managment

The `pcs` package provides cluster management tools. The `pcs` command is a command-line interface for managing the **Pacemaker high-availability stack**.

Cluster configuration could possibly be done by hand, but the pcs package makes managing (creating, configuring and troubleshooting) a cluster much easier!

!!! NOTE

    There are alternatives to pcs.

Install the package on all nodes and activate the daemon:

```bash
$ sudo dnf install pcs
$ sudo systemctl enable pcsd --now
```

The package installation created a hacluster user with an empty password. To perform tasks such as synchronizing corosync configuration files or rebooting remote nodes, this user must be assigned a password.

```text
hacluster:x:189:189:cluster user:/var/lib/pacemaker:/sbin/nologin
```

On all nodes, assign an identical password to the hacluster user:

```bash
echo "mdphacluster" | sudo passwd --stdin hacluster
```

From any node, it is possible to authenticate as a hacluster user on all nodes, then use the `pcs` commands on them:

```bash
$ sudo pcs host auth server1 server2
Username: hacluster
Password: 
server1: Authorized
server2: Authorized
```

From the node on which pcs is authenticated, launch the cluster configuration:

```bash
$ sudo pcs cluster setup --start mycluster server1 server2
No addresses specified for host 'server1', using 'server1'
No addresses specified for host 'server2', using 'server2'
Destroying cluster on hosts: 'server1', 'server2'...
server2: Successfully destroyed cluster
server1: Successfully destroyed cluster
Requesting remove 'pcsd settings' from 'server1', 'server2'
server1: successful removal of the file 'pcsd settings'
server2: successful removal of the file 'pcsd settings'
Sending 'corosync authkey', 'pacemaker authkey' to 'server1', 'server2'
server1: successful distribution of the file 'corosync authkey'
server1: successful distribution of the file 'pacemaker authkey'
server2: successful distribution of the file 'corosync authkey'
server2: successful distribution of the file 'pacemaker authkey'
Sending 'corosync.conf' to 'server1', 'server2'
server1: successful distribution of the file 'corosync.conf'
server2: successful distribution of the file 'corosync.conf'
Cluster has been successfully set up.
```

!!! NOTE

    The pcs cluster setup command takes care of the quorum problem for two-node clusters. Such a cluster will therefore function correctly in the event of the failure of one of the two nodes. If you are manually configuring corosync or using another cluster management shell, you will need to configure corosync correctly yourself.

The cluster can now be started:

```bash
$ sudo pcs cluster start --all
server1: Starting Cluster...
server2: Starting Cluster...
```

```bash
$ sudo pcs status
Cluster name: mycluster

WARNINGS:
No stonith devices and stonith-enabled is not false

Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum   
  * Last updated: Mon Jul  8 17:50:14 2024 on server1
  * Last change:  Mon Jul  8 17:50:00 2024 by hacluster via hacluster on server1    
  * 2 nodes configured
  * 0 resource instances configured

Node List:
  * Online: [ server1 server2 ]

Full List of Resources:
  * No resources

Daemon Status:
  corosync: active/disabled
  pacemaker: active/disabled
  pcsd: active/enabled
```

### Security

### Workshop

For this workshop, you will need two servers with Pacemaker services installed, configured and secured as described in the previous chapters.

You will configure a higly available Apache cluster.

Our two servers have the following IP addresses:

* server1: 192.168.1.100
* server2: 192.168.1.101


#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1  
* [ ] Answer 2  
* [ ] Answer 3  
* [ ] Answer 4  

## PCS

In this chapter, you will learn about XXXXXXX.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: XXX  
:heavy_check_mark: XXX  

:checkered_flag: **XXX**, **XXX**

**Knowledge**: :star:  
**Complexity**: :star:  

**Reading time**: XX minutes

****

### Generalities

### Configuration

### Security

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1  
* [ ] Answer 2  
* [ ] Answer 3  
* [ ] Answer 4  

-->