---
title: Building a Network of Websites/Web Servers With LXD, for Beginners
author: Ezequiel Bruni
contributors: Steven Spencer
---
# Building a Network of Websites/Web Servers With LXD, for Beginners

## Introduction

Okay, so we already have [a guide on installing LXD/LXC on Rocky Linux](lxd_server.md), but that was written by someone who knows what he’s doing, and wanted build a containerized network of servers and/or apps on a physical machine on his local network. It’s great, and I’ll be straight up stealing bits of it so I don’t have to write as much.

But, if you’ve just heard about Linux Containers, and don’t really understand how they work yet, but you want to host some websites, this is the guide for you. *This tutorial will teach you how to host basic websites with LXD and LXC on any system, including virtual private servers and cloud hosting.*

So first, what’s a Linux Container? Well, for the absolute beginner, it’s a way to make one computer pretend that it’s actually a lot more computers. These “containers” each house a basic—usually stripped-down—version of an operating system you choose. You can use each container like an individual server; put *nginx* on one, *Apache* on another, and even use a third as a database server.

The basic advantage is that if one app or website inside its own container experiences severe bugs, a hack, or other problems, it’s unlikely to affect the rest of your server/other apps and websites. Also, containers are super easy to snapshot, back up, and restore.

In this case, we’ll be running Rocky Linux in our containers, on top of our “host” system, which is also Rocky Linux.

Conceptually, it’s something like this:

![A graph showing how one computer can pretend to be several](D:\dev\RockyLinux\documentation\docs\guides\images\lxd-web-server-01.png)

If you’ve ever played with VirtualBox to run some Windows apps, or run a web app on Docker, it’s like that, but not. Unlike virtual machines, Linux Containers don’t emulate an entire hardware environment for each container. Rather, they share all share few virtual devices by default for networking and storage, though you can add more virtual devices. As a result, they require a lot less overhead (processing power and RAM) than a virtual machine.

For those Docker fiends out there, Linux Containers are less ephemeral than what you’re used to. All data in every container instance is persistent, and any changes you make are permanent unless you revert to a backup. In short, shutting down the container won’t erase your sins.

Heh.

LXD, specifically, is a command-line application that helps you to set up and manage Linux Containers. It works alongside the basic LXC app to help you with the initial setup of your containers, and the virtual devices needed to run them.

We’ll be using them both to create an environment that works something like this:

![A diagram of the intended Linux Container structure](D:\dev\RockyLinux\documentation\docs\guides\images\lxd-web-server-02.png)

Specifically, I’m going to show you how to set up simple Nginx and Apache web servers inside of your server containers, and use another container with Nginx as a reverse proxy. Again, this setup should work in any environment: from local networks to virtual private servers.

*Note:* A reverse proxy is a program that takes incoming connections from the internet (or your local network) and routes them to the right server, container, or app. If you’d rather use a dedicated proxy tool like HaProxy, please see the guide linked above.

## Prerequisites And Assumptions

* Basic familiarity with the Linux command line interface. You should know how to use SSH if you’re installing LXC/LXD on a remote server.
* An internet-connected server, physical or virtual, with Rocky Linux already running on it.
* A domain name pointed right at your server with an A record.
* A command-line text editor. *nano* will do, *micro* is my favorite, but use whatever makes you comfortable.
* You *can* follow this whole tutorial as the root user, but you probably shouldn’t. After the initial installation of LXC/LXD, we’ll guide you in creating an unprivileged user specifically for operating LXD commands.
* We now have Rocky Linux images to base your containers on, and they’re awesome.

## Setting Up The Host Server Environment

So here’s where I’m going to copy and paste bits from the other LXD guide, for your convenience and mine. All credit for most of this part goes to Steven Spencer.

### Install the EPEL Repository

LXD requires the EPEL (Extra Packages for Enterprise Linux) repository, which is easy to install using:

```bash
dnf install epel-release
```

Once installed, check for updates:

```bash
dnf update
```

If there were kernel updates during the update process above, reboot your server

### Install snapd

LXD must be installed from a snap\* package for Rocky Linux. For this reason, we need to install snapd with:

```bash
dnf install snapd
```

And now enable the snapd service to auto-start when your server reboots, and start it running now:

```bash
systemctl enable snapd
```

And then run:

```bash
systemctl start snapd
```

Reboot the server before continuing here. You can do this with the `reboot` command, or from your VPS/cloud hosting admin panel.

\* *snap* is a method of packaging applications so they come with all of the dependencies they need, and can run on almost any Linux system.

### Install LXD

Installing LXD requires the use of the snap command. At this point, we are just installing it, we are doing no set up:

```bash
snap install lxd
```

If you’re running LXD on a physical (AKA “bare metal”) server, you should probably go back to the other guide and read the “Environment Setup” section there. There’s a lot of good stuff about kernels and file systems, and so much more.

If you’re running LXD in a virtual environment, just reboot and read on.

### LXD Initialization

Now that the environment is all set up, we are ready to initialize LXD. This is an automated script that asks a series of questions to get your LXD instance up and running:

`lxd init`

Here are the questions and our answers for the script, with a little explanation where warranted:

`Would you like to use LXD clustering? (yes/no) [default=no]:`

If you are interested in clustering, do some additional research on that [here](https://lxd.readthedocs.io/en/latest/clustering/). Otherwise, just press “Enter” to accept the default option.

`Do you want to configure a new storage pool? (yes/no) [default=yes]:`

 Accept the default.

`Name of the new storage pool [default=default]: storage`

Choose a name for your storage pool. I like to name it after the server LXD is running on. (A storage pool is basically a set amount of hard drive space set aside for your containers.)

`Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]: lvm`

The above question is about what sort of file system you want to use for storage, and the default may vary depending on what’s available on your system. If using zfs, again, refer back to the guide linked above. In a virtual environment, I have found that “lvm” works fine, and it’s usually what I use. Accept the default on the next questions, too.

`Create a new LVM pool? (yes/no) [default=yes]: `

`Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]:`

If you have a specific hard drive or partition you’d like to use for the whole storage pool, write “yes”. If you’re doing all of this on a VPS, you’ll probably *have* to choose “no”.

`Would you like to connect to a MAAS server? (yes/no) [default=no]:`

Metal As A Service (MAAS) is outside the scope of this document. And frankly, I don’t know what it does.

`Would you like to create a new local network bridge? (yes/no) [default=yes]:`

`What should the new bridge be called? [default=lxdbr0]: `

`What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:`

`What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none`

If you want to use IPv6 on your LXD containers, you can turn on this option. That is up to you, but you mostly shouldn’t need to. I think.

`Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes`

This is necessary to easily back up the server, so answer "yes" here.

`Address to bind LXD to (not including port) [default=all]:`

`Port to bind LXD to [default=8443]:`

`Trust password for new clients:`

`Again:`

This trust password is how you will connect to the LXC host server from other computers and servers, so set this with something that makes sense in your environment. (Again, that’s useful for backups.) Save this password to a secure location, such as a password manager.

`Would you like stale cached images to be updated automatically? (yes/no) [default=yes]`

`Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:`

#### Setting Up User Privileges

Before we continue on, we need to create our "lxdadmin" user and make sure that it has the privileges it needs. We need the "lxdadmin" user to be able to use _sudo_ for access to root commands, and we need it to be a member of the “lxd” group. To add the user and make sure it is a member of both groups, run:

```bash
useradd -G wheel,lxd lxdadmin
```

Then set the password:

```bash
passwd lxdadmin
```

As with the other passwords, save this to a secure location.

## Setting Up Your Firewall

Before we do anything else with containers, you need to be able to access your proxy server from the outside. If your firewall is blocking port 80 (the default port used for HTTP/web traffic), or port 443 (used for HTTPS/*secure* web traffic), then you won’t be doing much of anything server-wise.

The other LXD guide will show you how to do this with the *iptables* firewall, if that’s what you want to do. I tend to use the CentOS default firewall: *firewalld*. So that’s what we’re doing, this time.

*firewalld* is configured via the `firewall-cmd` command. To add a new port, just run this:

```bash
firewall-cmd --permanent --zone=public --add-port=80/tcp
```

Let’s break this down: 

* The `-–permanent` flag tells the firewall to make sure this configuration is used every time the firewall is restarted, and when the server itself is restarted. 
* `–-zone=public` tells the firewall to take incoming connections to this port from everyone.
* Lastly, `–-add-port=80/tcp` tells the firewall to accept incoming connections over port 80, as long as they’re using the Transmission Control Protocol, which is what you want in this case.

To repeat the process for HTTPS traffic, just run the command again, and change the number.

```bash
firewall-cmd --permanent --zone=public --add-port=443/tcp
```

These configurations won’t take effect until you force the issue. To do that, tell *firewalld* to relead its configurations, like so:

```bash
firewall-cmd --reload
```

Now, there’s a very small chance that this won’t work. In those rare cases, make *firewalld* do your bidding with the old turn-it-off-and-turn-it-on-again.

```bash
systemctl restart firewalld
```

To make sure the ports have been added properly, run `firewall-cmd --list-all`. A properly-configured firewall will look a bit like this (I have a few extra ports open on my local server, ignore them):

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 81/tcp 444/tcp 15151/tcp 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

And that should be everything you need, firewall-wise.

## Setting Up The Containers

Actually managing containers is pretty easy. Just think of it as being able to conjure up a whole computer on command, and start or stop it at will. You can also log into said “computer” and run any commands you like, just as you would  

From here on out, every command should be run as the lxdadmin user, though some will require the use of *sudo* for temporary root privileges. You’re going to need three containers for this tutorial: the reverse proxy server, a test Nginx server, and a test Apache server, all running on Rocky-based containers.

If for some reason you need a fully privileged container (and you mostly shouldn’t), you can run all of these commands as root.

For this tutorial, you’ll need three containers: 

We’ll call them “proxy-server” (for the container that will be directing web traffic to the other two containers), “nginx-server”, and “apache-server”. Yes, I’ll be showing you how to reverse proxy to both *nginx* and *apache*-based servers. Things like *docker* or NodeJS apps can with until I figure that out myself.

We’ll start by figuring out which image we want to base our containers on. For this tutorial, we’re just using Rocky Linux. Using Alpine Linux, for example, can result in much smaller containers (if storage is a concern), but that’s beyond the scope of this particular document.

### Finding the Image You Want

Here’s the short, short method for starting a container with Rocky Linux: 

```bash
lxc launch images:rockylinux/8/amd64 my-container
```

Of course, that “my-container” bit at the end should be renamed to whatever container name you want, eg. “proxy-server”. The “/amd64” part should be changed to “arm64”  if you’re doing all of this on something like a Raspberry Pi.

Now here’s the long version: to find the images you want, you can use this command to list every available image in the main LXC repositories:

```bash
lxc image list images: | more
```

Then just press “Enter” to scroll down a massive list of images, and press “Control-C” to get out of the list-viewing mode.

Or, you could simplify your life, and specify what kind of Linux you want, like so:

```bash
lxc image list images: | grep rockylinux
```

That should print out a much shorter list that looks like this:

```bash
| rockylinux/8 (3 more)                    | 4e6beda70200 | yes    | Rockylinux 8 amd64 (20220129_03:44)          | x86_64       | VIRTUAL-MACHINE | 612.19MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8 (3 more)                    | c04dd2bcf20b | yes    | Rockylinux 8 amd64 (20220129_03:44)          | x86_64       | CONTAINER       | 127.34MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/arm64 (1 more)              | adc0561d6330 | yes    | Rockylinux 8 arm64 (20220129_03:44)          | aarch64      | CONTAINER       | 124.03MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/cloud (1 more)              | 2591d9716b04 | yes    | Rockylinux 8 amd64 (20220129_03:43)          | x86_64       | CONTAINER       | 147.04MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/cloud (1 more)              | c963253fcea9 | yes    | Rockylinux 8 amd64 (20220129_03:43)          | x86_64       | VIRTUAL-MACHINE | 630.56MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/cloud/arm64                 | 9f49e80afa5b | yes    | Rockylinux 8 arm64 (20220129_03:44)          | aarch64      | CONTAINER       | 143.15MB  | Jan 29, 2022 at 12:00am (UTC) |
```

### Creating the Containers

Once you’ve found the image you want, use the `lxc launch` command as shown above. To make the containers we want for this tutorial, run these commands (modifying them as needed) in succession:

```bash
lxc launch images:rockylinux/8/amd64 proxy-server
lxc launch images:rockylinux/8/amd64 nginx-server
lxc launch images:rockylinux/8/amd64 apache-server
```

As you run each command, you should get a notification that your containers have been created, and even started. Then, you’ll want to check on all of them.

!!! Note

    You may want to wait before creating the proxy-server container, actually. There's a trick I'll show you down below that could save you time.

Run this command to see that they’re all up and running:

```bash
lxc list
```

That should give you output that looks a bit like this (though, if you opted to use IPv6, it’s going to be a lot more text):

```bash
+---------------+---------+-----------------------+------+-----------+-----------+
|     NAME      |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+---------------+---------+-----------------------+------+-----------+-----------+
| proxy-server  | RUNNING | 10.199.182.231 (eth0) |      | CONTAINER | 0         |
+---------------+---------+-----------------------+------+-----------+-----------+
| nginx-server  | RUNNING | 10.199.182.232 (eth0) |      | CONTAINER | 0         |
+---------------+---------+-----------------------+------+-----------+-----------+
| apache-server | RUNNING | 10.199.182.233 (eth0) |      | CONTAINER | 0         |
+---------------+---------+-----------------------+------+-----------+-----------+
```

### *Essential Step:* Configuring the “proxy-server” Container to Take all Incoming Server Traffic

Remember when we opened up ports 80 and 443 in the firewall? Here’s where we make the “proxy-server” container listen to those ports, and take all the traffic directed at them.

Just run these two commands in succession:

```bash
lxc config device add proxy-server myproxy80 proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
lxc config device add proxy-server myproxy443 proxy listen=tcp:0.0.0.0:443 connect=tcp:127.0.0.1:443
```

Let’s break that down. Each command is adding a virtual “device” to the proxy-server container. Those devices are set to listen on the host OS’ port 80 and port 443, and bind them to the container’s port 80 and port 443. Each device needs a name, so I’ve chosen “myproxy80”, and “myproxy443”.

The “listen” option is the port on the host OS, and if I’m not mistaken, 0.0.0.0 is the IP address for the host on the “lxdbr0” bridge. The “connect” option is the local IP address and ports being connected to.

!!! Note

    Once these devices have been set up, you should reboot all the containers, just to be sure. Instructions below.

These virtual device names have to be unique. You can’t add another “myport80” device to another container; it’ll have to be called something else. Likewise, only one container can listen on any specific host OS port at a time.

#### A Word on Container Networking

So the other guide linked at the beginning of this one has a whole tutorial on how to set LXC/LXD up to work with Macvlan. This is especially useful if you’re running a local server, and you want each container to have an IP address visible on the local network.

When you’re running on a VPS, you don’t often have that option. In fact, you might only have one single IP address that you’re allowed to work with. No biggie. The default networking configuration is designed to accommodate this sort of limitation; answering the `lxd init` questions as I specified above *should* take care of everything.

Basically, LXD creates a virtual network device called a bridge (usually named “lxdbr0”), and all containers get connected to that bridge by default. Through it, they can connect to the internet via your host’s default network device (ethernet, wi-fi, or a virtual network device provided by your VPS). Somewhat more importantly, all of the containers can connect to each other.

To ensure this inter-container connection, *every container gets an internal domain name*. By default, this is just the name of the container plus “.lxd”. So the “proxy-server” container is available to all the other containers at “proxy-server.lxd”. But here’s the *really* important thing to know: by **default “.lxd” domains are only available inside the containers themselves.**

If you run `ping proxy-server.lxd` on the host OS (or anywhere else), you’ll get nothing. Those internal domains are going to come in super handy later on, though.

You can technically change this, and make the container’s internal domains available on the host… but I never actually figured that out. It’s probably best to put your reverse proxy server in a container anyway, so you can snapshot and back it up with ease.

### Managing Your Containers

Some things you should know before going forward:

#### Starting & Stopping

All containers can be started, stopped, and restarted as needed with the following commands:

```bash
lxc start mycontainer
lxc stop mycontainer
lxc restart mycontainer
```

Hey, even Linux needs to reboot sometimes. And heck, you can actually start, stop, and restart all containers at once with the following commands.

```bash
lxc start --all
lxc stop --all
lxc restart --all
```

That `restart --all` option comes in real handy for some of the more obscure temporary bugs.

#### Doing Stuff Inside Your Containers

You can control the operating system inside your container in two ways: you can just run commands inside them from the host OS, or you can open a shell.

Here’s what I mean. To run a command inside a container, maybe to install *Apache*, just use `lxc exec`, like so:

```bash
lxc exec my-container dnf install httpd -y
```

That will make *Apache* install on its own, and you will see the output of the command on your host’s terminal.

To open a shell (where you can just run all the commands you want as root), use this:

```bash
lxc exec my-container bash
```

If you’re like me, valuing convenience over storage space, and have installed an alternate shell like *fish* in all of your containers, just change the command like so:

```bash
lxc exec my-container fish
```

In almost all instances, you’ll automatically be placed on the root account, and in the `/root` directory.

#### Copying Containers

Now, if you have a container you’d like to replicate with minimal effort, you don’t need to start a brand new one and install all of your base applications again. That’d be silly. Just run:

```bash
lxc copy my-container my-other-container
```

An exact copy of “my-container” will be created with the name “my-other-container”. It may not start automatically though, so make any changes you might want to make to your new container’s configuration, then run:

```bash
lxc start my-other-container
```

At this point, you may want to make some changes, like changing the container’s internal hostname, or something.

#### Configuring Storage & CPU Limits

LXC/LXD usually defines how much storage space a container gets, and generally manages resources, but you might want control over that. If you’re worried about keeping your containers small, you can use the `lxc config` command to shrink and stretch them as needed. 

The following command will set a “soft” limit of 2GB on a container. A soft limit is actually more of a “minimum storage”, and the container will use more storage if it’s available. As always, change “my-container” to the name of the actual container.

```bash
lxc config set my-container limits.memory 2GB
```

You can set a hard limit like so:

```bash
lxc config set my-container limits.memory.enforce 2GB
```

And if you want to make sure that any given container can’t take over all the processing power available to your server, you can limit the CPU cores it has access to with this command. Just change the number of CPU cores at the end as you see fit.

```bash
lxc config set my-container limits.cpu 2
```

#### Deleting Containers (and How to Keep That From Happening)

Lastly, you can delete containers by running this command:

```bash
lxc delete my-container
```

You won’t be able to delete the container if it’s running, so you can either stop it first, or use the `-–force` flag to skip that part.

```bash
lxc delete my-container --force
```

Now, thanks to tab -command-completion, user error, and the fact that “d” sits next to “s” on most keyboards, you can accidentally delete containers. This is known, in the business, as THE BIG OOPS. (Or at least it’ll be known as THE BIG OOPS when I’m done here.)

To defend against that, you can set any container to be “protected” (making the process of deleting them take an extra step) with this command:

```bash
lxc config set my-container security.protection.delete true
```

To un-protect the container, just run the command again, but change “true” to “false”.

## Setting Up The Servers

Okay, now that your containers are up and running, it’s time to install what you need. First, make sure all of them are updated with the following commands (skip the “proxy-server” container if you haven’t created it yet):

```bash
lxc exec proxy-server dnf update -y
lxc exec nginx-server dnf update -y
lxc exec apache-server dnf update -y
```

Then, jump into each container, and get cracking.

You’ll also need a text editor for every container. By default, Rocky Linux comes with *vi*, but if you want to simplify your life, *nano* will do. You can install it in each container before you open them up.

```bash
lxc exec proxy-server dnf install nano -y
lxc exec nginx-server dnf install nano -y
lxc exec apache-server dnf install nano -y
```

I’ll be using *nano* in all of the text-editor-related commands going forward, but you do you.

### The Apache Website Server

First, open up a shell into your container:

```bash
lxc exec apache-server bash
```

Once you’re logged in, just install *Apache* the easy way:

```bash
dnf install httpd
```

Now, you could follow our [Apache Web Server Multi-Site Setup guide](../web/apache-sites-enabled.md) from here on out, but that’s actually kind of overkill for our purposes. We don’t usually want to set up Apache for multiple websites in a containerized environment like this. The whole point of containers is a separation of concerns, after all.

Also, the SSL certificates are going on the proxy server, so we’re going to keep things simple. 

Once *Apache* is installed, make sure it’s running, and can keep running on reboot:

```bash
systemctl enable --now httpd
```

The `–-now` flag lets you skip the command to start the actual server. For reference, that would be:

```bash
systemctl start httpd
```





RemoteIP



#### Further Apache Configuration

Configure root





### The Nginx Website Server



### The Reverse Proxy Server 







## Conclusion