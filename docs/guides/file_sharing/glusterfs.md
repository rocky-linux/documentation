---
title: Clustering-GlusterFS
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zyhrnova
update: 11-Feb-2022
---

# High availability cluster with GlusterFS

## Prerequisites

* Proficiency with a command line editor (using _vi_ in this example)
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* All commands are run as the root user or sudo

## Introduction

GlusterFS is a distributed file system.

It allows storing large amounts of data distributed across clusters of servers with very high availability.

It is composed of a server part to be installed on all the nodes of the server clusters.

Clients can access the data via the `glusterfs` client or the `mount` command.

GlusterFS can operate in two modes:

  * replicated mode: each node of the cluster has all the data.
  * distributed mode: no data redundancy. If a storage fails, the data on the failed node is lost.

Both modes can be used together to provide a replicated and distributed file system if you have the correct number of servers.

Data is stored inside bricks.

> A Brick is the basic unit of storage in GlusterFS, represented by an export directory on a server in the trusted storage pool.

## Test platform

Our fictitious platform is comprises two servers and a client, all Rocky Linux servers.

* First node: node1.cluster.local - 192.168.1.10
* Second node: node2.cluster.local - 192.168.1.11
* Client1: client1.clients.local - 192.168.1.12

!!! Note

    Make sure you have the necessary bandwidth between the servers of the cluster.

Each server in the cluster has a second disk for data storage.

## Preparation of the disks

We will create a new LVM logical volume that will be mounted on `/data/glusterfs/vol0` on both of the cluster's servers:

```
$ sudo pvcreate /dev/sdb
$ sudo vgcreate vg_data /dev/sdb
$ sudo lvcreate -l 100%FREE -n lv_data vg_data
$ sudo mkfs.xfs /dev/vg_data/lv_data
$ sudo mkdir -p /data/glusterfs/volume1
```

!!! Note

    If LVM is not available on your servers, just install it with the following command:

    ```
    $ sudo dnf install lvm2
    ```

We can now add that logical volume to the `/etc/fstab` file:

```
/dev/mapper/vg_data-lv_data /data/glusterfs/volume1        xfs     defaults        1 2
```

And mount it:

```
$ sudo mount -a
```

As the data is stored in a sub-volume called brick, we can create a directory in this new data space dedicated to it:

```
$ sudo mkdir /data/glusterfs/volume1/brick0
```

## Installation

At the time of writing this documentation, the original CentOS Storage SIG repository is no longer available and the RockyLinux repository is not yet available.

However, we will use (for the time being) the archived version.

First of all, it is necessary to add the dedicated repository to gluster (in version 9) on both servers:

```
sudo dnf install centos-release-gluster9
```

!!! Note

    Later, when it is ready on the Rocky side, we can change the name of this package.

As the repo list and url is not available anymore, let's change the content of the `/etc/yum.repos.d/CentOS-Gluster-9.repo`:

```
[centos-gluster9]
name=CentOS-$releasever - Gluster 9
#mirrorlist=http://mirrorlist.centos.org?arch=$basearch&release=$releasever&repo=storage-gluster-9
baseurl=https://dl.rockylinux.org/vault/centos/8.5.2111/storage/x86_64/gluster-9/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage
```

We are now ready to install the glusterfs server:

```
$ sudo dnf install glusterfs glusterfs-libs glusterfs-server
```

## Firewall rules

A few rules are necessary for the service to work:

```
$ sudo firewall-cmd --zone=public --add-service=glusterfs --permanent
$ sudo firewall-cmd --reload
```

or:

```
$ sudo firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
$ sudo firewall-cmd --zone=public --add-port=49152/tcp --permanent
$ sudo firewall-cmd --reload
```

## Name resolution

You can let DNS handle the name resolution of the servers in your cluster, or you can choose to relieve the servers of this task by inserting records for each of them in your `/etc/hosts` files. This will also keep things running even during a DNS failure.

```
192.168.10.10 node1.cluster.local
192.168.10.11 node2.cluster.local
```

## Starting the service

Without further delay, let's start the service:

```
$ sudo systemctl enable glusterfsd.service glusterd.service
$ sudo systemctl start glusterfsd.service glusterd.service
```

We are ready to join the two nodes in the same pool.

This command is to be performed only once on a single node (here on node1):

```
sudo gluster peer probe node2.cluster.local
peer probe: success
```

Verify:

```
node1 $ sudo gluster peer status
Number of Peers: 1

Hostname: node2.cluster.local
Uuid: c4ff108d-0682-43b2-bc0c-311a0417fae2
State: Peer in Cluster (Connected)
Other names:
192.168.10.11

```

```
node2 $ sudo gluster peer status
Number of Peers: 1

Hostname: node1.cluster.local
Uuid: 6375e3c2-4f25-42de-bbb6-ab6a859bf55f
State: Peer in Cluster (Connected)
Other names:
192.168.10.10
```

We can now create a volume with 2 replicas:

```
$ sudo gluster volume create volume1 replica 2 node1.cluster.local:/data/glusterfs/volume1/brick0/ node2.cluster.local:/data/glusterfs/volume1/brick0/
Replica 2 volumes are prone to split-brain. Use Arbiter or Replica 3 to avoid this. See: https://docs.gluster.org/en/latest/Administrator-Guide/Split-brain-and-ways-to-deal-with-it/.
Do you still want to continue?
 (y/n) y
volume create: volume1: success: please start the volume to access data
```

!!! Note

    As the return command says, a 2-node cluster is not the best idea in the world against split brain. But this will suffice for our test platform.

We can now start the volume to access data:

```
$ sudo gluster volume start volume1

volume start: volume1: success
```

Check the volume state:

```
$ sudo gluster volume status
Status of volume: volume1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick node1.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1210
Brick node2.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1135
Self-heal Daemon on localhost               N/A       N/A        Y       1227
Self-heal Daemon on node2.cluster.local     N/A       N/A        Y       1152

Task Status of Volume volume1
------------------------------------------------------------------------------
There are no active volume tasks
```

```
$ sudo gluster volume info

Volume Name: volume1
Type: Replicate
Volume ID: f51ca783-e815-4474-b256-3444af2c40c4
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: node1.cluster.local:/data/glusterfs/volume1/brick0
Brick2: node2.cluster.local:/data/glusterfs/volume1/brick0
Options Reconfigured:
cluster.granular-entry-heal: on
storage.fips-mode-rchecksum: on
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
```

The status must be "Started".

We can already restrict access on the volume a little bit:

```
$ sudo gluster volume set volume1 auth.allow 192.168.10.*
```

It is as simple as that.

## Clients access

There are several ways to access our data from a client.

The preferred method:

```
$ sudo dnf install glusterfs-client
$ sudo mkdir /data
$ sudo mount.glusterfs node1.cluster.local:/volume1 /data
```

There are no additional repositories to configure. The client is already present in the base repos.

Create a file and check that it is present on all the nodes of the cluster:

On client:

```
sudo touch /data/test
```

On both servers:

```
$ ll /data/glusterfs/volume1/brick0/
total 0
-rw-r--r--. 2 root root 0 Feb  3 19:21 test
```

Sounds good! But what happens if node 1 fails? It is the one that was specified when mounting the remote access.

Let's stop node one:

```
$ sudo shutdown -h now
```

Check status on node2:

```
$ sudo gluster peer status
Number of Peers: 1

Hostname: node1.cluster.local
Uuid: 6375e3c2-4f25-42de-bbb6-ab6a859bf55f
State: Peer in Cluster (Disconnected)
Other names:
192.168.10.10
[antoine@node2 ~]$ sudo gluster volume status
Status of volume: volume1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick node2.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1135
Self-heal Daemon on localhost               N/A       N/A        Y       1152

Task Status of Volume volume1
------------------------------------------------------------------------------
There are no active volume tasks
```

The node1 is away.

And on client:

```
$ ll /data/test
-rw-r--r--. 1 root root 0 Feb  4 16:41 /data/test
```

File is already there.

Upon connection, the glusterfs client receives a list of nodes it can address, which explains the transparent switchover we just witnessed.

## Conclusions

While there are no current repositories, using the archived repositories that CentOS had for GlusterFS will still work. As outlined, GlusterFS is pretty easy to install and maintain. Using the command line tools is a pretty straight forward process. GlusterFS will help create and maintain high-availability clusters for data storage and redundancy. You can find more information on GlusterFS and tool usage from the [official documentation pages.](https://docs.gluster.org/en/latest/)
