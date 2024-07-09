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

"High Availability" (**HA**) refers to all the measures taken to guarantee the highest possible availability of a service, i.e. its correct operation 24 hours a day.

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

:heavy_check_mark: install and configure a Pacemaker cluster;  
:heavy_check_mark: administer a Pacemaker cluster.  

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

!!! NOTE

    Do not start the services now, as they are not configured, they will not work.

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
echo "pwdhacluster" | sudo passwd --stdin hacluster
```

!!! NOTE

    Please replace "pwdhacluster" with a more secure password.

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
$ sudo pcs cluster setup mycluster server1 server2
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

Enable the cluster service to start on boot:

```bash
sudo pcs cluster enable --all
```

Check the service status:

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

#### Adding ressources

Before we can configure the resources, we'll need to deal with the alert message:

```bash
WARNINGS:
No stonith devices and stonith-enabled is not false
```

In this state, Pacemaker will refuse to start our new resources.

You have two choices:

* disable `stonith`
* configure it

First, we will disable stonith until we learn how to configure it:

```bash
sudo pcs property set stonith-enabled=false
```

!!! WARNING

    Be careful not to leave stonith disabled on a production environment!!!!

##### VIP configuration

The first resource we're going to create on our cluster is a VIP.

The standard resources available are provided by the `pcs resource standards` command:

```bash
$ pcs resource standards
lsb
ocf
service
systemd
```

This VIP, corresponding to the IP address used by customers to access future cluster services, will be assigned to one of the nodes. Then, in the event of failure, the cluster will switch this resource from one node to another to ensure continuity of service.

```bash
pcs resource create myclusterVIP ocf:heartbeat:IPaddr2 ip=192.168.1.12 cidr_netmask=24 op monitor interval=30s
```

The `ocf:heartbeat:IPaddr2` argument is made up of 3 fields that provide pacemaker with :

* the standard (here `ocf`),
* the script namespace (here `heartbeat`),
* the resource script name.

The result is the addition of a virtual IP address to the list of managed resources:

```bash
$ sudo pcs status
Cluster name: mycluster

...
Cluster name: mycluster
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  ...
  * 2 nodes configured
  * 1 resource instance configured

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
...
```

In this case, VIP is active on server1, which can be verified with the `ip` command:

```bash
$ ip add show dev enp0s3
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:df:29:09 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.10/24 brd 192.168.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.1.12/24 brd 192.168.1.255 scope global secondary enp0s3
       valid_lft forever preferred_lft forever
```

###### Toggle tests

From anyware on the network, run the ping command on the VIP :

```bash
ping 192.168.1.12
```

Put the active node on standby:

```bash
sudo pcs node standby server1
```

Check that no ping was lost during the operation: (no missing `icmp_seq`)

```bash
64 bytes from 192.168.1.12: icmp_seq=39 ttl=64 time=0.419 ms
64 bytes from 192.168.1.12: icmp_seq=40 ttl=64 time=0.043 ms
64 bytes from 192.168.1.12: icmp_seq=41 ttl=64 time=0.129 ms
64 bytes from 192.168.1.12: icmp_seq=42 ttl=64 time=0.074 ms
64 bytes from 192.168.1.12: icmp_seq=43 ttl=64 time=0.099 ms
64 bytes from 192.168.1.12: icmp_seq=44 ttl=64 time=0.044 ms
64 bytes from 192.168.1.12: icmp_seq=45 ttl=64 time=0.021 ms
64 bytes from 192.168.1.12: icmp_seq=46 ttl=64 time=0.058 ms
```

Check the cluster status:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
...
  * 2 nodes configured
  * 1 resource instance configured

Node List:
  * Node server1: standby
  * Online: [ server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server2
```

The VIP has been moved to server2. Check with the `ip add` command as seen previously.

Return server1 to the pool:

```bash
sudo pcs node unstandby server1
```

Note that once server1 has been unstandby, the cluster returns to its normal state, but the resource is not transferred back to server1: it remains on server2.

##### Service configuration

We will install the Apache service on both nodes of our cluster. This service will only be started on the active node, and will switch nodes at the same time as the VIP in the event of failure of the active node.

Please refer to the apache chapter for detailed installation instructions.

Installation must be performed on both nodes:

```bash
$ sudo dnf install -y httpd
$ sudo firewall-cmd --permanent --add-service=http
$ sudo firewall-cmd --reload
```

!!! WARNING

    Don't start or activate the service yourself, pacemaker will take care of it.

An HTML page containing the server name will be displayed by default:

```bash
echo "<html><body>Node $(hostname -f)</body></html>" | sudo tee "/var/www/html/index.html"
```

The Pacemaker resource agent will use the `/server-status` page (see apache chapter) to determine its health status. It must be activated by creating the file `/etc/httpd/conf.d/status.conf` on both servers:

```bash
sudo vim /etc/httpd/conf.d/status.conf
<Location /server-status>
    SetHandler server-status
    Require local
</Location>
```

To create a resource we'll call "WebSite", we'll call the apache script of the OCF resource and in the heartbeat namespace.

```bash
sudo pcs resource create WebSite ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf statusurl="http://localhost/server-status" op monitor interval=1min
```

The cluster will check Apache's health every minute (`op monitor interval=1min`).

Finally, to ensure that the Apache service is started on the same node as the VIP address, a constraint must be added to the cluster:

```bash
sudo pcs constraint colocation add WebSite with myclusterVIP INFINITY
```

The Apache service can also be configured to start after the VIP, which can be useful if Apache VHosts are configured to listen to the VIP address (`Listen 192.168.1.12`):

```bash
$ sudo pcs constraint order myclusterVIP then WebSite
Adding myclusterVIP WebSite (kind: Mandatory) (Options: first-action=start then-action=start)
```

###### Testing the failover

We will perform a failover and test that our webserver is still available:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  ...

Node List:
  * Online: [ server1 server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
  * WebSite     (ocf:heartbeat:apache):  Started server1
```

We are currently working on server1.

```bash
$ curl http://192.168.1.12/
<html><body>Node server1</body></html>
```

Simulate a failure on server1:

```bash
sudo pcs node standby server1
```

```bash
$ curl http://192.168.1.12/
<html><body>Node server2</body></html>
```

As you can see, our webservice is still working but on server2 now.

```bash
sudo pcs node unstandby server1
```

Please note that the service was only interrupted for a few seconds while the VIP was switched over and the services restarted.

### Cluster troubleshooting


### Security

### Workshop

For this workshop, you will need two servers with Pacemaker services installed, configured and secured as described in the previous chapters.

You will configure a higly available Apache cluster.

Our two servers have the following IP addresses:

* server1: 192.168.1.10
* server2: 192.168.1.11

If you do not have a service to resolve names, fill the `/etc/hosts` file with content like the following:

```bash
$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.10 server1 server1.rockylinux.lan
192.168.1.11 server2 server2.rockylinux.lan
```

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
