---
title: LXD Server
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6
tags:
  - lxd
  - enterprise
---

# Creating a full LXD Server

## Introduction

LXD is best described on the [official website](https://linuxcontainers.org/lxd/introduction/), but think of it as a container system that provides the benefits of virtual servers in a container, or a container on steroids.

It is very powerful, and with the right hardware and set up, can be leveraged to run a lot of server instances on a single piece of hardware. If you pair that with a snapshot server, you also have a set of containers that you can spin up almost immediately in the event that your primary server goes down.

(You should not think of this as a traditional backup. You still need a regular backup system of some sort, like [rsnapshot](../backup/rsnapshot_backup.md).)

The learning curve for LXD can be a bit steep, but this document will attempt to give you a wealth of knowledge at your fingertips, to help you deploy and use LXD on Rocky Linux.

## Prerequisites And Assumptions

* One Rocky Linux server, nicely configured. You should consider a separate hard drive for ZFS disk space (you have to if you are using ZFS) in a production environment. And yes, we are assuming this is a bare metal server, not a VPS.
* This should be considered an advanced topic, but we have tried our best to make it as easy to understand as possible for everyone. That said, knowing a few basic things about container management will take you a long way.
* You should be very comfortable at the command line on your machine(s), and fluent in a command line editor. (We are using _vi_ throughout this example, but you can substitute in your favorite editor.)
* You need to be an unprivileged user for the bulk of the LXD processes. Except where noted, enter LXD commands as your unprivileged user. We are assuming that you are logged in as a user named "lxdadmin" for LXD commands. The bulk of the set up _is_, done as root until you get past the LXD initialization. We will have you create the "lxdadmin" user later in the process.
* For ZFS, make sure that UEFI secure boot is NOT enabled. Otherwise, you will end up having to sign the ZFS module in order to get it to load.
* We will, for the moment, be using CentOS-based containers, as LXC does not yet have Rocky Linux images. Stay tuned for updates, because this will likely change with time.

!!! Note

    This has changed! Feel free to substitute in Rocky Linux containers in the examples below.

## Part 1 : Getting The Environment Ready

Throughout "Part 1" you will need to be the root user or you will need to be able to _sudo_ to root.

### <a name="repos"></a>Install EPEL and OpenZFS Repositories

LXD requires the EPEL (Extra Packages for Enterprise Linux) repository, which is easy to install using:

`dnf install epel-release`

Once installed, check for updates:

`dnf update`

If you're using ZFS, install the OpenZFS repository with:

`dnf install https://zfsonlinux.org/epel/zfs-release.el8_3.noarch.rpm`

We also need the GPG key, so use this command to get that:

`gpg --import --import-options show-only /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux`

If there were kernel updates during the update process above, reboot your server

### Install snapd, dkms And vim

LXD must be installed from a snap for Rocky Linux. For this reason, we need to install snapd (and a few other useful programs) with:

`dnf install snapd dkms vim`

And now enable and start snapd:

`systemctl enable snapd`

And then run:

`systemctl start snapd`

Reboot the server before continuing here.

### <a name="pkginstall"></a>Install LXD

Installing LXD requires the use of the snap command. At this point, we are just installing it, we are doing no set up:

`sudo snap install lxd`

### Install OpenZFS

`dnf install kernel-devel zfs`

### <a name="envsetup"></a> Environment Set up

Most server kernel settings are not sufficient to run a large number of containers. If we assume from the beginning that we will be using our server in production, then we need to make these changes up front to avoid errors such as "Too many open files" from occurring.

Luckily, tweaking the settings for LXD is easy with a few file modifications and a reboot.

#### Modifying limits.conf

The first file we need to modify is the limits.conf file. This file is self-documented, so look at the explanations in the file as to what this file does. To make our modifications type:

`vi /etc/security/limits.conf`

This entire file is remarked/commented out and, at the bottom, shows the current default settings. In the blank space above the end of file marker (#End of file) we need to add our custom settings. The end of the file will look like this when you are done:

```
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Save your changes and exit. (`SHIFT:wq!` for _vi_)

#### Modifying sysctl.conf With 90-lxd.override.conf

With _systemd_, we can make changes to our system's overall configuration and kernel options *without* modifying the main configuration file. Instead, we'll put our settings in a separate file that will simply override the particular settings we need.

To make these kernel changes, we are going to create a file called _90-lxd-override.conf_ in /etc/sysctl.d. To do this type:

`vi /etc/sysctl.d/90-lxd-override.conf`

Place the following content in that file. Note that if you are wondering what we are doing here, the file content below is self-documenting:

```
## The following changes have been made for LXD ##

# fs.inotify.max_queued_events specifies an upper limit on the number of events that can be queued to the corresponding inotify instance
 - (default is 16384)

fs.inotify.max_queued_events = 1048576

# fs.inotify.max_user_instances This specifies an upper limit on the number of inotify instances that can be created per real user ID -
(default value is 128)

fs.inotify.max_user_instances = 1048576

# fs.inotify.max_user_watches specifies an upper limit on the number of watches that can be created per real user ID - (default is 8192)

fs.inotify.max_user_watches = 1048576

# vm.max_map_count contains the maximum number of memory map areas a process may have. Memory map areas are used as a side-effect of cal
ling malloc, directly by mmap and mprotect, and also when loading shared libraries - (default is 65530)

vm.max_map_count = 262144

# kernel.dmesg_restrict denies container access to the messages in the kernel ring buffer. Please note that this also will deny access t
o non-root users on the host system - (default is 0)

kernel.dmesg_restrict = 1

# This is the maximum number of entries in ARP table (IPv4). You should increase this if you create over 1024 containers.

net.ipv4.neigh.default.gc_thresh3 = 8192

# This is the maximum number of entries in ARP table (IPv6). You should increase this if you plan to create over 1024 containers.Not nee
ded if not using IPv6, but...

net.ipv6.neigh.default.gc_thresh3 = 8192

# This is a limit on the size of eBPF JIT allocations which is usually set to PAGE_SIZE * 40000.

net.core.bpf_jit_limit = 3000000000

# This is the maximum number of keys a non-root user can use, should be higher than the number of containers

kernel.keys.maxkeys = 2000

# This is the maximum size of the keyring non-root users can use

kernel.keys.maxbytes = 2000000

# This is the maximum number of concurrent async I/O operations. You might need to increase it further if you have a lot of workloads th
at use the AIO subsystem (e.g. MySQL)

fs.aio-max-nr = 524288
```

At this point you should reboot the server.

#### Checking _sysctl.conf_ Values

Once the reboot has been completed, log back in as to the server. We need to spot check that our override file has actually done the job.

This is easy to do. There's no need to check every setting unless you want to, but checking a few will verify that the settings have been changed. This is done with the _sysctl_ command:

`sysctl net.core.bpf_jit_limit`

Which should show you:

`net.core.bpf_jit_limit = 3000000000`

Do the same with a few other settings in the override file (above) to verify that changes have been made.

### <a name="zfssetup"></a>Enabling ZFS And Setting Up The Pool

If you have UEFI secure boot turned off, this should be fairly easy.  First, load the ZFS module with modprobe:

`/sbin/modprobe zfs`

This should not return an error, it should simply return to the command prompt when done. If you get an error, stop now and begin troubleshooting. Again, make sure that secure boot is off as that will be the most likely culprit.

Next we need to take a look at the disks on our system, determine what has the OS loaded on it, and what is available to use for the ZFS pool. We will do this with _lsblk_:

`lsblk`

Which should return something like this (your system will be different!):

```
AME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0    7:0    0  32.3M  1 loop /var/lib/snapd/snap/snapd/11588
loop1    7:1    0  55.5M  1 loop /var/lib/snapd/snap/core18/1997
loop2    7:2    0  68.8M  1 loop /var/lib/snapd/snap/lxd/20037
sda      8:0    0 119.2G  0 disk
├─sda1   8:1    0   600M  0 part /boot/efi
├─sda2   8:2    0     1G  0 part /boot
├─sda3   8:3    0  11.9G  0 part [SWAP]
├─sda4   8:4    0     2G  0 part /home
└─sda5   8:5    0 103.7G  0 part /
sdb      8:16   0 119.2G  0 disk
├─sdb1   8:17   0 119.2G  0 part
└─sdb9   8:25   0     8M  0 part
sdc      8:32   0 149.1G  0 disk
└─sdc1   8:33   0 149.1G  0 part
```

In this listing, we can see that */dev/sda* is in use by the operating system, so we are going to use */dev/sdb* for our zpool. Note that if you have multiple free hard drives, you may wish to consider using raidz (a software raid specifically for ZFS).

That falls outside the scope of this document, but should definitely be a consideration for production, as it offers better performance and redundancy. For now, let's create our pool on the single device we have identified:

`zpool create storage /dev/sdb`

What this says is to create a pool called "storage" that is ZFS on the device */dev/sdb*.

Once the pool is created, it's a good idea to reboot the server again at this point.

### <a name="lxdinit"></a>LXD Initialization

Now that the environment is all set up, we are ready to initialize LXD. This is an automated script that asks a series of questions to get your LXD instance up and running:

`lxd init`

Here are the questions and our answers for the script, with a little explanation where warranted:

`Would you like to use LXD clustering? (yes/no) [default=no]:`

If you are interested in clustering, do some additional research on that [here](https://lxd.readthedocs.io/en/latest/clustering/)

`Do you want to configure a new storage pool? (yes/no) [default=yes]:`

This may seem counter-intuitive, since we have already created our ZFS pool, but it will be resolved in a later question. Accept the default.

`Name of the new storage pool [default=default]: storage`

You could leave this as default if you wanted to, but we have chosen to use the same name we gave our ZFS pool.

`Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:`

Obviously we want to accept the default.

`Create a new ZFS pool? (yes/no) [default=yes]: no`

Here's where the earlier question about creating a storage pool is resolved.

`Name of the existing ZFS pool or dataset: storage`

`Would you like to connect to a MAAS server? (yes/no) [default=no]:`

Metal As A Service (MAAS) is outside the scope of this document.

`Would you like to create a new local network bridge? (yes/no) [default=yes]:`

`What should the new bridge be called? [default=lxdbr0]: `

`What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:`

`What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none`

If you want to use IPv6 on your LXD containers, you can turn on this option. That is up to you.

`Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes`

This is necessary to snapshot the server, so answer "yes" here.

`Address to bind LXD to (not including port) [default=all]:`

`Port to bind LXD to [default=8443]:`

`Trust password for new clients:`

`Again:`

This trust password is how you will connect to the snapshot server or back from the snapshot server, so set this with something that makes sense in your environment. Save this entry to a secure location, such as a password manager.

`Would you like stale cached images to be updated automatically? (yes/no) [default=yes]`

`Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:`

#### Setting Up User Privileges

Before we continue on, we need to create our "lxdadmin" user and make sure that it has the privileges it needs. We need the "lxdadmin" user to be able to _sudo_ to root and we need it to be a member of the lxd group. To add the user and make sure it is a member of both groups do:

`useradd -G wheel,lxd lxdadmin`

Then set the password:

`passwd lxdadmin`

As with the other passwords, save this to a secure location.

### <a name="firewallsetup"></a>Firewall Set Up - iptables

Before continuing, you will want a firewall set up on your server. This example is using _iptables_ and [this procedure](../security/enabling_iptables_firewall.md) to disable _firewalld_. If you prefer to use _firewalld_, simply substitute in _firewalld_ rules using the instructions below this section.

Create your firewall.conf script:

`vi /etc/firewall.conf`

We are assuming an LXD server on a LAN network of 192.168.1.0/24 below. Note, too, that we are accepting all traffic from our bridged interface. This is important if you want your containers to get IP addresses from the bridge.

This firewall script makes no other assumptions about the network services needed. There is an SSH rule to allow our LAN network IP's to SSH into the server. You can very easily have many more rules needed here, depending on your environment. Later, we will be adding a rule for bi-directional traffic between our production server and the snapshot server.

```
#!/bin/sh
#
#IPTABLES=/usr/sbin/iptables

#  Unless specified, the defaults for OUTPUT is ACCEPT
#    The default for FORWARD and INPUT is DROP
#
echo "   clearing any existing rules and setting default policy.."
iptables -F INPUT
iptables -P INPUT DROP
iptables -A INPUT -i lxdbr0 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```
### Firewall Set Up - firewalld

For _firewalld_ rules, we need to use [this basic procedure](../security/firewalld.md) or be familiar with those concepts. Our assumptions are the same as with the _iptables_ rules above: LAN network of 192.168.1.0/24 and a bridge named lxdbr0. To be clear, you might have multiple interfaces on your LXD server, with one perhaps facing your WAN as well. We are also going to create a zone for the bridged and local networks. This is just for zone clarity sake, as the other names do not really apply. The below assumes that you already know the basics of _firewalld_.

```
firewall-cmd --new-zone=bridge --permanent
```

You need to reload the firewall after adding a zone:

```
firewall-cmd --reload
```

We want to allow all traffic from the bridge, so let's just add the interface, and then change the target from "default" to "ACCEPT" and we will be done:

!!! attention

    Changing the target of a firewalld zone *must* be done with the --permanent option, so we might as well just enter that flag in our other commands as well and forgo the --runtime-to-permanent option.

!!! Note

    If you need to create a zone that you want to allow all access to the interface or source, but do not want to have to specify any protocols or services, then you *must* change the target from "default" to ACCEPT. The same is true of DROP and REJECT for a particular IP block that you have custom zones for. To be clear, the "drop" zone will take care of that for you as long as you aren't using a custom zone.

```
firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
```
Assuming no errors and everything is still working just do a reload:

```
firewall-cmd --reload
```
If you list out your rules now with `firewall-cmd --zone=bridge --list-all` you should see something like the following:

```
bridge (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: lxdbr0
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
Note from the _iptables_ rules, that we also want to allow our local interface. Again, I do not like the included zones for this, so create a new zone and use the source IP range for the local interface to make sure you have access:

```
firewall-cmd --new-zone=local --permanent
firewall-cmd --reload
```
Then we just need to add the source IP's for the local interface, change the target to "ACCEPT" and we are done with this as well:

```
firewall-cmd --zone=local --add-source=127.0.0.1/8 --permanent
firewall-cmd --zone=local --set-target=ACCEPT --permanent
firewall-cmd --reload
```
Go ahead and list out the "local" zone to make sure your rules are there with `firewall-cmd --zone=local --list all` which should show you something like this:

```
local (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 127.0.0.1/8
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Next we want to allow SSH from our trusted network. We will use the source IP's here, just like in our _iptables_ example, and the built-in "trusted" zone. The target for this zone is already "ACCEPT" by default.

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24
```
Then add the service to the zone:

```
firewall-cmd --zone=trusted --add-service=ssh
```
And if everything is working, move your rules to permanent and reload the rules:

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```
Listing out your "trusted" zone should now show you something like this:

```
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
By default, the "public" zone is enabled and has SSH allowed. We don't want this. Make sure that your zones are correct and that the access you are getting to the server is via one of the LAN IP's (in the case of our example) and is allowed to SSH. You could lock yourself out of the server if you don't verify this before continuing. Once you've made sure you have access from the correct interface, remove SSH from the "public" zone:

```
firewall-cmd --zone=public --remove-service=ssh
```
Test access and make sure you aren't locked out. If not, then move your rules to permanent, reload, and list out zone "public" to be sure that SSH is removed:

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```
There may be other interfaces on your server to consider. You can use built-in zones where appropriate, but if you don't like the names (they don't appear logical, etc.), you can definitely add zones. Just remember that if you have no services or protocols that you need to allow or reject specifically, then you will need to modify the zone target. If it works to use interfaces, as we've done with the bridge, you can do that. If you need more granular access to services, uses source IP's instead.

This completes Part 1. You can either continue on to Part 2, or return to the [menu](#menu). If you are working on the snapshot server, you can head down to [Part 5](#part5) now.

## <a name="part2"></a>Part 2 : Setting Up And Managing Images

Throughout Part 2, and from here on out unless otherwise noted, you will be running commands as your unprivileged user. ("lxdadmin" if you are following along with this document).

### <a name="listimages"></a>List Available Images

Once you have your server environment set up, you'll probably be itching to get started with a container. There are a _lot_ of container OS possibilities. To get a feel for how many possibilities, enter this command:

`lxc image list images: | more`

Hit the space bar to page through the list. This list of containers and virtual machines continues to grow. For now, we are sticking with containers.

The last thing you want to do is to page through looking for a container image to install, particularly if you know the image that you want to create. Let's modify the command above to show only CentOS Linux install options:

`lxc image list images: | grep centos/8`

This brings up a much more manageable list:

```
| centos/8 (3 more)                    | 98b4dbef0c29 | yes    | Centos 8 amd64 (20210427_07:08)              | x86_64       | VIRTUAL-MACHINE | 517.44MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8 (3 more)                    | 0427669ebee4 | yes    | Centos 8 amd64 (20210427_07:08)              | x86_64       | CONTAINER       | 125.58MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream (3 more)             | 961170f8934f | yes    | Centos 8-Stream amd64 (20210427_07:08)       | x86_64       | VIRTUAL-MACHINE | 586.44MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream (3 more)             | e507fdc8935a | yes    | Centos 8-Stream amd64 (20210427_07:08)       | x86_64       | CONTAINER       | 130.33MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/arm64 (1 more)       | e5bf98409ac6 | yes    | Centos 8-Stream arm64 (20210427_10:33)       | aarch64      | CONTAINER       | 126.56MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/cloud (1 more)       | 5751ca14bf8f | yes    | Centos 8-Stream amd64 (20210427_07:08)       | x86_64       | CONTAINER       | 144.75MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/cloud (1 more)       | ccf0bb20b0ca | yes    | Centos 8-Stream amd64 (20210427_07:08)       | x86_64       | VIRTUAL-MACHINE | 593.31MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/cloud/arm64          | db3d915d12fd | yes    | Centos 8-Stream arm64 (20210427_07:08)       | aarch64      | CONTAINER       | 140.60MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/cloud/ppc64el        | 11aa2ab878b2 | yes    | Centos 8-Stream ppc64el (20210427_07:08)     | ppc64le      | CONTAINER       | 149.45MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/ppc64el (1 more)     | a27665203e47 | yes    | Centos 8-Stream ppc64el (20210427_07:08)     | ppc64le      | CONTAINER       | 134.52MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/arm64 (1 more)              | d64396d47fa7 | yes    | Centos 8 arm64 (20210427_07:08)              | aarch64      | CONTAINER       | 121.83MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/cloud (1 more)              | 84803ca6e32d | yes    | Centos 8 amd64 (20210427_07:08)              | x86_64       | CONTAINER       | 140.42MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/cloud (1 more)              | c98196cd9eec | yes    | Centos 8 amd64 (20210427_07:08)              | x86_64       | VIRTUAL-MACHINE | 536.00MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/cloud/arm64                 | 9d06684a9a4e | yes    | Centos 8 arm64 (20210427_10:33)              | aarch64      | CONTAINER       | 136.49MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/cloud/ppc64el               | 18c13c448349 | yes    | Centos 8 ppc64el (20210427_07:08)            | ppc64le      | CONTAINER       | 144.66MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/ppc64el (1 more)            | 130c1c83c36c | yes    | Centos 8 ppc64el (20210427_07:08)            | ppc64le      | CONTAINER       | 129.53MB  | Apr 27, 2021 at 12:00am (UTC) |
```

### <a name="lxdimageinstall"></a>Installing, Renaming, And Listing Images

For the first container, we are going to choose centos/8. To install it, we *could* use:

`lxc launch images:centos/8 centos-test`

That will create a CentOS-based containter named "centos-test". You can rename a container after it has been created, but you first need to stop the container, which starts automatically when it is launched.

To start the container manually, use:

`lxc start centos-test`

For the purposes of this guide, go ahead and install one more image for now:

`lxc launch images:ubuntu/20.10 ubuntu-test`

Now let's take a look at what we have so far by listing our images:

`lxc list`

which should return something like this:

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING | 10.199.182.72 (eth0)  |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

### <a name="profiles"></a>LXD Profiles

You get a default profile when you install LXD, and this profile cannot be removed or modified. That said, you can use the default profile to create new profiles to use with your containers.

If you look at our container listing (above) you will notice that the IP address in each case is assigned from the bridged interface. In a production environment, you may want to use something else. This might be a DHCP assigned address from your LAN interface or even a statically assigned address from your WAN.

If you configure your LXD server with two interfaces, and assign each an IP on your WAN and LAN, then it is possible to assign your containers IP addresses based on which interface the container needs to be facing.

As of version 8 of Rocky Linux (and really any bug for bug copy of Red Hat Enterprise Linux, such as CentOS in our listing above) the method for assigning IP addresses statically or dynamically using the profiles below, is broken out of the gate.

There are ways to get around this, but it is annoying, as the feature that is broken _should be_ part of the Linux kernel. That feature is macvlan. Macvlan allows you to create multiple interfaces with different Layer 2 addresses.

For now, just be aware that what we are going to suggest next has drawbacks when choosing container images based on RHEL.

#### <a name="macvlan"></a>Creating A macvlan Profile And Assigning It

To create our macvlan profile, simply use this command:

`lxc profile create macvlan`

Keep in mind that if we were on a multi-interface machine and wanted more than one macvlan template based on which network we wanted to reach, we could use "lanmacvlan" or "wanmacvlan" or any other name that we wanted to use to identify the profile. In other words, using "macvlan" in our profile create statement is totally up to you.

Once the profile is created, we now need to modify it to do what we want. First, we need to make sure that the server's default editor is what we want to use. If we don't do this step, the editor will be whatever the default editor is. We are choosing _vim_ for our editor here:

`export EDITOR=/usr/bin/vim`

Now we want to modify the macvlan interface, but before we do, we need to know what the parent interface is for our LXD server. This will be the interface that has a LAN (in this case) assigned IP. To determine which interface that is, use:

`ip addr`

And then look for the interface with the LAN IP assignment in the 192.168.1.0/24 network:

```
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 40:16:7e:a9:94:85 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.106/24 brd 192.168.1.255 scope global dynamic noprefixroute enp3s0
       valid_lft 4040sec preferred_lft 4040sec
    inet6 fe80::a308:acfb:fcb3:878f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

So in this case, the interface would be "enp3s0".

Now let's modify the profile:

`lxc profile edit macvlan`

This file will be self-documented at the top. What we need to do is modify the file as follows below the commented section:

```
config: {}
description: ""
devices:
  eth0:
   name: eth0
   nictype: macvlan
   parent: enp3s0
   type: nic
name: macvlan
used_by: []
```

Obviously, you can use profiles for lots of other things, but assigning a static IP to a container, or using your own DHCP server as a source for an address are very common needs.

To assign the macvlan profile to centos-test we need to do the following:

`lxc profile assign centos-test default,macvlan`

This simply says, we want the default profile, and then we want to apply the macvlan profile as well.

#### <a name="centosmacvlan"></a> CentOS macvlan

In the CentOS implementation of Network Manager, they have managed to break the functionality of macvlan in the kernel, or at least in the kernel applied to their LXD image. This has been this way since CentOS 8 was released and no one appears to be at all concerned about a fix.

Simply put, if you want to run CentOS 8 containers (or any other RHEL 1-for-1 release, such as Rocky Linux), you've got to jump through some additional hoops to get macvlan to work. macvlan is part of the kernel, so it should work without the below fixes, but it doesn't.

##### CentOS macvlan - The DHCP Fix

Having the profile assigned, however, doesn't change the default configuration, which is set to DHCP by default.

To test this, simply do the following:

`lxc stop centos-test`

And then:

`lxc start centos-test`

Now list your containers again and note that centos-test does not have an IP address anymore:

`lxc list`

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING |                       |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

To further demonstrate the problem here, we need to execute `dhclient` on the container. You can do this with:

`lxc exec centos-test dhclient`

A new listing using `lxc list` now shows the following:

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING | 192.168.1.138 (eth0)  |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

That should have happened with a simple stop and start of the container, but it does not. Assuming that we want to use a DHCP assigned IP address every time, then we can fix this with a simple crontab entry. To do this, we need to gain shell access to the container by entering:

`lxc exec centos-test bash`

Next, lets determine the complete path to `dhclient`:

`which dhclient`

which should return:

`/usr/sbin/dhclient`

Next, let's modify root's crontab:

`crontab -e`

And add this line:

`@reboot    /usr/sbin/dhclient`

The crontab command entered above, uses _vi_ so to save your changes and exit simply use:

`SHIFT:wq!`

Now exit the container and stop centos-test:

`lxc stop centos-test`

and then start it again:

`lxc start centos-test`

A new listing will reveal that the container has been assigned the DHCP address:

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING | 192.168.1.138 (eth0)  |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

##### CentOS macvlan - The Static IP Fix

To statically assign an IP address, things get even more convoluted. The process of setting a static IP address on a CentOS container is through the network-scripts, which we will do now. The IP we will attempt to assign is 192.168.1.200.

To do this, we need to gain shell access to the container again:

`lxc exec centos-test bash`

The next thing we need to do is to manually modify the interface labelled "eth0", and set our IP address. To modify our configuration, do the following:

`vi /etc/sysconfig/network-scripts/ifcfg-eth0`

Which will return this:

```
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
HOSTNAME=centos-test
TYPE=Ethernet
MTU=
DHCP_HOSTNAME=centos-test
IPV6INIT=yes
```

We need to modify this file so that it looks like this:

```
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.1.200
PREFIX=24
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
HOSTNAME=centos-test
TYPE=Ethernet
MTU=
DHCP_HOSTNAME=centos-test
IPV6INIT=yes
```

This says we want to set the boot protocol to none (used for static IP assignments), set the IP address to 192.168.1.200, that this address is part of a CLASS C (PREFIX=24) address, that the gateway for this network is 192.168.1.1 and then that we want to use Google's open DNS servers for name resolution.

Save your file (`SHIFT:wq!`).

We also need to remove our crontab for root, as this isn't what we want for a static IP. To do this, simply `crontab -e` and remark out the @reboot line with a "#", save your changes and exit the container.

Stop the container with:

`lxc stop centos-test`

and start it again:

`lxc start centos-test`

Just like our DHCP assigned address, the statically assigned address will not be assigned when we list the container:

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING |                       |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

To fix this requires breaking Network Manager on the container. The following works-at least for now:

`lxc exec centos-test dhclient`

Then get into the container:

`lxc exec centos-test bash`

Install the old network scripts:

`dnf install network-scripts`

Nuke Network Manager:

`systemctl stop NetworkManager`
`systemctl disable NetworkManager`

Enable the old Network service:

`systemctl enable network.service`

Exit the container and then stop and start the container again:

`lxc stop centos-test`

And then run:

`lxc start centos-test`

When the container starts, a new listing will show the correct statically assigned IP:

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING | 192.168.1.200 (eth0)  |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

The issue with macvlan shown in both of these examples is directly related to containers based on Red Hat Enterprise Linux (Centos 8, Rocky Linux 8).

#### <a name="ubuntumacvlan"></a>Ubuntu macvlan

Luckily, In Ubuntu's implementation of Network Manager, the macvlan stack is NOT broken, so it is much easier to deploy!

First, just like with our centos-test container, we need to assign the template to our container:

`lxc profile assign ubuntu-test default,macvlan`

That should be all that is necessary to get a DHCP assigned address. To find out, stop and then start the container again:

`lxc stop ubuntu-test`

And then run:

`lxc start ubuntu-test`

Then list the containers again:

```
+-------------+---------+----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+----------------------+------+-----------+-----------+
| centos-test | RUNNING | 192.168.1.200 (eth0) |      | CONTAINER | 0         |
+-------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 192.168.1.139 (eth0) |      | CONTAINER | 0         |
+-------------+---------+----------------------+------+-----------+-----------+
```

Success!

Configuring the Static IP is just a little different, but not at all hard. We need to modify the .yaml file associated with the container's connection (/10-lxc.yaml). For this static IP, we will use 192.168.1.201:

`vi /etc/netplan/10-lxc.yaml`

And change what is there to the following:

```
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [192.168.1.201/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
```

Save your changes (`SHFT:wq!`) and exit the container.

Now stop and start the container:

`lxc stop ubuntu-test`

And then run:

`lxc start ubuntu-test`

When you list your containers again, you should see our new static IP:

```
+-------------+---------+----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+----------------------+------+-----------+-----------+
| centos-test | RUNNING | 192.168.1.200 (eth0) |      | CONTAINER | 0         |
+-------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 192.168.1.201 (eth0) |      | CONTAINER | 0         |
+-------------+---------+----------------------+------+-----------+-----------+
```

Success!

In the examples used in Part 2, we have intentionally chosen a hard container to configure, and an easy one. There are obviously many more versions of Linux available in the image listing. If you have a favorite, try installing it, assigning the macvlan template, and setting IP's.

This completes Part 2. You can either continue on to Part 3, or return to the [menu](#menu).

## Part 3 : Container Configuration Options

There are a wealth of options for configuring the container once you have it installed. Before we get into how to see those, however, let's take a look at the info command for a container. In this example, we will use the ubuntu-test container:

`lxc info ubuntu-test`

This shows something like the following:

```
Name: ubuntu-test
Location: none
Remote: unix://
Architecture: x86_64
Created: 2021/04/26 15:14 UTC
Status: Running
Type: container
Profiles: default, macvlan
Pid: 584710
Ips:
  eth0:    inet    192.168.1.201    enp3s0
  eth0:    inet6    fe80::216:3eff:fe10:6d6d    enp3s0
  lo:    inet    127.0.0.1
  lo:    inet6    ::1
Resources:
  Processes: 13
  Disk usage:
    root: 85.30MB
  CPU usage:
    CPU usage (in seconds): 1
  Memory usage:
    Memory (current): 99.16MB
    Memory (peak): 110.90MB
  Network usage:
    eth0:
      Bytes received: 53.56kB
      Bytes sent: 2.66kB
      Packets received: 876
      Packets sent: 36
    lo:
      Bytes received: 0B
      Bytes sent: 0B
      Packets received: 0
      Packets sent: 0
```

There's a lot of good information there, from the profiles applied, to the memory in use, disk space in use, and more.

#### <a name="lxdconfigopt"></a>A Word About Configuration And Some Options

By default, LXD will allocate the required system memory, disk space, CPU cores, etc., to the container. But what if we want to be more specific? That is totally possible.

There are trade-offs to doing this, though. For instance, if we allocate system memory and the container doesn't actually use it all, then we have kept it from another container that might actually need it. The reverse, though, can happen. If a container is a complete pig on memory, then it can keep other containers from getting enough, thereby pinching their performance.

Just keep in mind that every action you make to configure a container _can_ have negative effects somewhere else.

Rather than run through all of the options for configuration, use the tab auto-complete to see the options available:

`lxc config set ubuntu-test` and then hit TAB.

This shows you all of the options for configuring a container. If you have questions about what one of the configuration options does, head up to the [official documentation for LXD](https://lxd.readthedocs.io/en/stable-4.0/instances/) and do a search for the configuration parameter, or Google the entire string, such as "lxc config set limits.memory" and take a look at the results of the search.

We will look at a few of the most used configuration options. For example, if you want to set the max amount of memory that a container can use:

`lxc config set ubunt-test limits.memory 2GB`

That says that as long as the memory is available to use, in other words there is 2GB of memory free, then the container can actually use more than 2GB if it's available. It's a soft limit, in other words.

`lxc config set ubuntu-test limits.memory.enforce 2GB`

That says that the container can never use more than 2GB of memory, whether it's currently available or not. In this case it's a hard limit.

`lxc config set ubuntu-test limits.cpu 2`

That says to limit the number of cpu cores that the container can use to 2.

Remember when we set up our storage pool in the [Enabling zfs And Setting Up The Pool](#zfssetup) above?  We named the pool "storage," but we could have named it anything. If we want to look at this, we can use this command:

`lxc storage show storage`

This shows the following:

```
config:
  source: storage
  volatile.initial_source: storage
  zfs.pool_name: storage
description: ""
name: storage
driver: zfs
used_by:
- /1.0/images/0cc65b6ca6ab61b7bc025e63ca299f912bf8341a546feb8c2f0fe4e83843f221
- /1.0/images/4f0019aee1515c109746d7da9aca6fb6203b72f252e3ee3e43d50b942cdeb411
- /1.0/images/9954953f2f5bf4047259bf20b9b4f47f64a2c92732dbc91de2be236f416c6e52
- /1.0/instances/centos-test
- /1.0/instances/ubuntu-test
- /1.0/profiles/default
status: Created
locations:
- none
```

This shows that all of our containers are using our zfs storage pool. When using ZFS, you can also set a disk quota on a container. Let's do this by setting a 2GB disk quota on the ubuntu-test container. You do this with:

`lxc config device override ubuntu-test root size=2GB`

As stated earlier, you should use configuration options sparingly, unless you've got a container that wants to use way more than its share of resources. LXD, for the most part, will manage the environment well on its own.

There are, of course, many more options that may be of interest to some people. You should do your own research to find out if any of those are of value in your environment.

This completes Part 3. You can either continue on to Part 4, or return to the [menu](#menu).

## Part 4: Container Snapshots

Container snapshots, along with a snapshot server (which we will get to more later), are probably the most important aspect of running a production LXD server. Snapshots ensure quick recovery, and can be used for safety when you are, say, updating the primary software that runs on a particular container. If something happens during the update that breaks that application, you simply restore the snapshot and you are back up and running with only a few seconds worth of downtime.

The author used LXD containers for PowerDNS public facing servers, and the process of updating those applications became so much more worry-free, since you can snapshot the container first before continuing.

You can even snapshot a container while it is running. We'll start by getting a snapshot of the ubuntu-test container by using this command:

`lxc snapshot ubuntu-test ubuntu-test-1`

Here, we are calling the snapshot "ubuntu-test-1", but it can be called anything you like. To make sure that you have the snapshot, do an "lxc info" of the container:

`lxc info ubuntu-test`

We've looked at an info screen already, so if you scroll to the bottom, you should see:

```
Snapshots:
  ubuntu-test-1 (taken at 2021/04/29 15:57 UTC) (stateless)
```

Success! Our snapshot is in place.

Now, get into the ubuntu-test container:

`lxc exec ubuntu-test bash`

And create an empty file with the _touch_ command:

`touch this_file.txt`

Now exit the container.

Before we restore the container as it was prior to creating the file, the safest way to restore a container, particularly if there have been a lot of changes, is to stop it first:

`lxc stop ubuntu-test`

Then restore it:

`lxc restore ubuntu-test ubuntu-test-1`

Then start the container again:

`lxc start ubuntu-test`

If you get back into the container again and look, our "this_file.txt" that we created is now gone.

Once you don't need a snapshot anymore, you can delete it:

`lxc delete ubuntu-test/ubuntu-test-1`

**Important:** You should always delete snapshots with the container running. Why? Well the _lxc delete_ command also works to delete the entire container. If we had accidentally hit enter after "ubuntu-test" in the command above, AND, if the container was stopped, the container would be deleted. No warning is given, it simply does what you ask.

If the container is running, however, you will get this message:

`Error: The instance is currently running, stop it first or pass --force`

So always delete snapshots with the container running.

The process of creating snapshots automatically, setting expiration of the snapshot so that it goes away after a certain length of time, and auto refreshing the snapshots to the snapshot server will be covered in detail in the section dealing with the snapshot server.

This completes Part 4. You can either continue on to Part 5, or return to the [menu](#menu).

## Part 5: The Snapshot Server

As noted at the beginning, the snapshot server for LXD should be a mirror of the production server in every way possible. The reason is that you may need to take it to production in the event of a hardware failure, and having not only backups, but a quick way to bring up production containers, keeps those systems administrator panic phone calls and text messages to a minimum. THAT is ALWAYS good!

So the process of building the snapshot server is exactly like the production server. To fully emulate our production server set up, do all of [Part 1](#part1) again, and when completed, return to this spot.

You're back!! Congratulations, this must mean that you have successfully completed Part 1 for the snapshot server. That's great news!!

### Setting Up The Primary and Snapshot Server Relationship

We've got some housekeeping to do before we continue. First, if you are running in a production environment, you probably have access to a DNS server that you can use for setting up IP to name resolution.

In our lab, we don't have that luxury. Perhaps you've got the same scenario running. For this reason, we are going to add both servers IP addresses and names to the /etc/hosts file on BOTH the primary and the snapshot server. You'll need to do this as your root (or _sudo_) user.

In our lab, the primary LXD server is running on 192.168.1.106 and the snapshot LXD server is running on 192.168.1.141. We will SSH into both servers and add the following to the /etc/hosts file:

```
192.168.1.106 lxd-primary
192.168.1.141 lxd-snapshot
```
Next, we need to allow all traffic between the two servers. To do this, we are going to modify the /etc/firewall.conf file with the following. First, on the lxd-primary server, add this line:

`IPTABLES -A INPUT -s 192.168.1.141 -j ACCEPT`

And on the lxd-snapshot server, add this line:

`IPTABLES -A INPUT -s 192.168.1.106 -j ACCEPT`

This allows bi-directional traffic of all types to travel between the two servers.

Next, as the "lxdadmin" user, we need to set the trust relationship between the two machines. This is done by executing the following on lxd-primary:

`lxc remote add lxd-snapshot`

This will display the certificate to accept, so do that, and then it will prompt for your password. This is the "trust password" that you set up when doing the [LXD initialization](#lxdinit) step. Hopefully, you are securely keeping track of all of these passwords. Once you enter the password, you should receive this:

`Client certificate stored at server:  lxd-snapshot`

It does not hurt to have this done in reverse as well. In other words, set the trust relationship on the lxd-snapshot server so that, if needed, snapshots can be sent back to the lxd-primary server. Simply repeat the steps and substitute in "lxd-primary" for "lxd-snapshot."

### Migrating Our First Snapshot

Before we can migrate our first snapshot, we need to have any profiles created on lxd-snapshot that we have created on the lxd-primary. In our case, this is the "macvlan" profile.

You'll need to create this for lxd-snapshot, so go back to [LXD Profiles](#profiles) and create the "macvlan" profile on lxd-snapshot. If your two servers have identical parent interface names ("enp3s0" for example) then you can copy the "macvlan" profile over to lxd-snapshot without recreating it:

`lxc profile copy macvlan lxd-snapshot`

Now that we have all of the relationships and profiles set up, the next step is to actually send a snapshot from lxd-primary over to lxd-snapshot. If you've been following along exactly, you've probably deleted all of your snapshots, so let's create a new one:

`lxc snapshot centos-test centos-snap1`

If you run the "info" sub-command for lxc, you can see the new snapshot on the bottom of our listing:

`lxc info centos-test`

Which will show something like this at the bottom:

`centos-snap1 (taken at 2021/05/13 16:34 UTC) (stateless)`

OK, fingers crossed! Let's try to migrate our snapshot:

`lxc copy centos-test/centos-snap1 lxd-snapshot:centos-test`

What this command says is, that within the container centos-test, we want to send the snapshot, centos-snap1 over to lxd-snapshot and copy it as centos-test.

After a short period of time has expired, the copy will be complete. Want to find out for sure?  Do an "lxc list" on the lxd-snapshot server. Which should return the following:

```
+-------------+---------+------+------+-----------+-----------+
|    NAME     |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+------+------+-----------+-----------+
| centos-test | STOPPED |      |      | CONTAINER | 0         |
+-------------+---------+------+------+-----------+-----------+
```

Success! Now let's try starting it. Because we are starting it on the lxd-snapshot server, we need to stop it first on the lxd-primary server:

`lxc stop centos-test`

And on the lxd-snapshot server:

`lxc start centos-test`

Assuming all of this works without error, stop the container on lxd-snapshot and start it again on lxd-primary.

### The Snapshot Server - Setting boot.autostart To Off For Containers

The snapshots copied to lxd-snapshot will be down when they are migrated, but if you have a power event or need to reboot the snapshot server because of updates or something, you will end up with a problem as those containers will attempt to start on the snapshot server.

To eliminate this, we need to set the migrated containers so that they will not start on reboot of the server. For our newly copied centos-test container, this is done with the following:

`lxc config set centos-test boot.autostart 0`

Do this for each snapshot on the lxd-snapshot server.

### Automating The Snapshot Process

Ok, so it's great that you can create snapshots when you need to, and sometimes you _do_ need to manually create a snapshot. You might even want to manually copy it over to lxd-snapshot. BUT, once you've got things going and you've got 25 to 30 containers or more running on your lxd-primary machine, the very last thing you want to do is spend an afternoon deleting snapshots on the snapshot server, creating new snapshots and sending them over.

The first thing we need to do is schedule a process to automate snapshot creation on lxd-primary. This has to be done for each container on the lxd-primary server, but once it is set up, it will take care of itself. This is done with the following syntax. Note the similarities to a crontab entry for the timestamp:

`lxc config set [container_name] snapshots.schedule "50 20 * * *"`

What this is saying is, do a snapshot of the container name every day at 8:50 PM.

To apply this to our centos-test container:

`lxc config set centos-test snapshots.schedule "50 20 * * *"`

We also want to set up the name of the snapshot to be meaningful by our date. LXD uses UTC everywhere, so our best bet to keep track of things, is to set the snapshot name with a date/time stamp that is in a more understandable format:

`lxc config set centos-test snapshots.pattern "centos-test-{{ creation_date|date:'2006-01-02_15-04-05' }}"`

GREAT, but we certainly don't want a new snapshot every day without getting rid of an old one, right?  We'd fill up the drive with snapshots. So next we run:

`lxc config set centos-test snapshots.expiry 1d`

### Automating The Snapshot Copy Process

Again, this process is performed on lxd-primary. First thing we need to do is create a script that will be run by cron in /usr/local/sbin called "refresh-containers" :

`sudo vi /usr/local/sbin/refreshcontainers.sh`

The script is pretty simple:

```
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x lxd-snapshot:$x
        done

```

 Make it executable:

`sudo chmod +x /usr/local/sbin/refreshcontainers.sh`

Change the ownership of this script to your lxdadmin user and group:

`sudo chown lxdadmin.lxdadmin /usr/local/sbin/refreshcontainers.sh`

Set up the crontab for the lxdadmin user to run this script, in this case at 10 PM:

`crontab -e`

And your entry will look like this:

`00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/lxdadmin/refreshlog 2>&1`

Save your changes and exit.

This will create a log in lxdadmin's home directory called "refreshlog" which will give you knowledge of whether your process worked or not. Very important!

The automated procedure will fail sometimes. This generally happens when a particular container fails to refresh. You can manually re-run the refresh with the following command (assuming centos-test here, as our container):

`lxc copy --refresh centos-test lxd-snapshot:centos-test`

## Conclusions

There is a great deal to installing and effectively using LXD. You can certainly install it on your laptop or workstation without all the fuss, as it makes a great developing and testing platform. If you want a more serious approach using production containers, then a primary and snapshot server approach is your best bet.

Even though we've touched on a lot of features and settings, we have only scratched the surface of what you can do with LXD. The best way to learn this system, is to install it and try it out with things that you will use. If you find LXD useful, consider installing it in the fashion described in this document for the best possible leveraging of hardware for Linux containers. Rocky Linux works very well for this!

You can now exit this document, or return to the [menu](#menu). You know, if you want.
