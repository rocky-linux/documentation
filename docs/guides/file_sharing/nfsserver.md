---
title: Network File System
author: Antoine Le Morvan
contributors: Steven Spencer, Serge, Ganna Zhyrnova
---
# Network File System

**Knowledge**: :star: :star:   
**Complexity**: :star: :star:   

**Reading time**: 15 minutes

**N**etwork **F**ile **S**ystem (**NFS**) is a network-mounted file-sharing system.

## Generalities

NFS is a client/server protocol: the server provides file system resources for all or part of the network (clients).

The communication between clients and server takes place by way of  **R**emote **P**rocedure **C**all (**RPC**) services.

Remote files are mounted in a directory and appear as a local file system. Client users seamlessly access files shared by the server, browsing directories as if they were local.

## Installation

NFS requires two services to function:

* The `network` service (of course)
* The `rpcbind` service

View the status of the services with the command:

```
systemctl status rpcbind
```

If the `nfs-utils` package is not installed:

```
sudo dnf install nfs-utils
```

The `nfs-utils` package requires the installation of several dependencies, including `rpcbind`.

Start the NFS service with:

```
sudo systemctl enable --now nfs-server rpcbind
```

Installing the NFS service creates two users:

* `nobody`: used for anonymous connections
* `rpcuser`: for RPC protocol operation

Configuring the firewall is necessary:

```
sudo firewall-cmd --add-service={nfs,nfs3,mountd,rpc-bind} --permanent 
sudo firewall-cmd --reload
```

## Server configuration

!!! warning "warning"

    Directory rights and NFS rights must be consistent.

### The `/etc/exports` file

Set up resource shares with the `/etc/exports` file. Each line in this file corresponds to an NFS share.

```
/share_name	client1(permissions) client2(permissions)
```

* **/share_name**: Absolute path of shared directory
* **clients**: Clients authorized to access resources
* **(permissions)**: Permissions on resources

Declare machines authorized to access resources with:

* **IP address**: `192.168.1.2`
* **Network address**: `192.168.1.0/255.255.255.0` or CIDR format `192.168.1.0/24`
* **FQDN**: client_*.rockylinux.org: allows FQDNs starting with client_ from the rockylinux.org domain
* `*` for everybody

Multiple client specifications are possible on the same line, separated by a space.

### Permissions on resources

There are two types of permissions:

* `ro`: read-only
* `rw`: read-write

If no right is specified, then the right applied will be read-only.

By default, the NFS server preserves the client user UIDs and GIDs (except for `root`).

To force the use of a UID or GID other than that of the user writing the resource, specify the `anonuid=UID` and `anongid=GID` options, or give `anonymous` access to the data with the `all_squash` option.

!!! warning "warning" 

    A parameter, `no_root_squash`, identifies the client root user as the server root user. This parameter can be dangerous from a system security point of view.

Activation of the `root_squash` parameter is a default (even if not specified), identifying `root` as an `anonymous` user.

### Case studies

* `/share client(ro,all_squash)`
Client users have read-only access to resources and are identified as anonymous on the server.

* `/share client(rw)`
Client users can modify resources and keep their UID on the server. Only `root` is identified as `anonymous`.

* `/share client1(rw) client2(ro)`
Users on client workstation 1 can modify resources, while those on client workstation 2 have read-only access.
UIDs are kept on the server, and only `root` is identified as `anonymous`.

* `/share client(rw,all_squash,anonuid=1001,anongid=100)`
Client1 users can modify resources. Their UID is changed to `1001` and their GID to `100` on the server.

### The `exportfs` command

The `exportfs` (exported file systems) command is used to manage the table of local files shared with NFS clients.

```
exportfs [-a] [-r] [-u share_name] [-v]
```

| Options         | Description                               |
| --------------- | ----------------------------------------- |
| `-a`            | Enables NFS shares                         |
| `-r`            | Applies shares from the `/etc/exports` file |
| `-u share_name` | Disables a given share                    |
| `-v`            | Displays the list of shares               |

### The `showmount` command

The `showmount` command monitors clients.

```
showmount [-a] [-e] [host]
```

| Options | Description                               |
| ------- | ----------------------------------------- |
| `-e`    | Displays shares on the designated server  |
| `-a`    | Displays all current shares on the server |

This command also determines whether the client workstation has authorization to mount shared resources.

!!! note "note"

    `showmount` sorts and hides duplicates in the results, so it's impossible to determine whether a client has made multiple mounts of the same directory or not.

## Client configuration

Shared resources on an NFS server are accessible through a mount point on the client.

If required, create a local folder for mounting:

```
$ sudo mkdir /mnt/nfs
```

List available NFS shares on the server:

```
$ showmount –e 172.16.1.10
/share *
```

Mount the server's NFS share:

```
$ mount –t nfs 172.16.1.10:/share /mnt/nfs
```

Automation of the mount can happen at system startup with the `/etc/fstab` file:

```
$ sudo vim /etc/fstab
172.16.1.10:/share /mnt/nfs nfs defaults 0 0
```
