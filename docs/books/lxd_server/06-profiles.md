---
title: 6 Profiles
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd profiles
---

# Chapter 6: Profiles

Throughout this chapter you will need to execute commands as your unprivileged user ("lxdadmin" if you've been following from the beginning in this book).

You get a default profile when you install LXD, and this profile cannot be removed or modified. That said, you can use the default profile to create new profiles to use with your containers.

If you look at our container listing, you will notice that the IP address in each case is assigned from the bridged interface. In a production environment, you may want to use something else. This might be a DHCP assigned address from your LAN interface or even a statically assigned address from your WAN.

If you configure your LXD server with two interfaces and assign each an IP on your WAN and LAN, then it is possible to assign your containers IP addresses based on which interface the container needs to be facing.

As of version 9.0 of Rocky Linux (and really any bug for bug copy of Red Hat Enterprise Linux) the method for assigning IP addresses statically or dynamically using the profiles below, is broken out of the gate.

There are ways to get around this, but it is annoying. This appears to have something to do with changes that have been made to Network Manager that affect macvlan. macvlan allows you to create multiple interfaces with different Layer 2 addresses.

For now, just be aware that what we are going to suggest next has drawbacks when choosing container images based on RHEL.

## Creating A macvlan Profile And Assigning It

To create our macvlan profile, simply use this command:

```
lxc profile create macvlan
```

Keep in mind that if we were on a multi-interface machine and wanted more than one macvlan template based on which network we wanted to reach, we could use "lanmacvlan" or "wanmacvlan" or any other name that we wanted to use to identify the profile. In other words, using "macvlan" in our profile create statement is totally up to you.

Now we want to modify the macvlan interface, but before we do, we need to know what the parent interface is for our LXD server. This will be the interface that has a LAN (in this case) assigned IP. To determine which interface that is, use:

```
ip addr
```

And then look for the interface with the LAN IP assignment in the 192.168.1.0/24 network:

```
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 40:16:7e:a9:94:85 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.106/24 brd 192.168.1.255 scope global dynamic noprefixroute enp3s0
       valid_lft 4040sec preferred_lft 4040sec
    inet6 fe80::a308:acfb:fcb3:878f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

So, in this case, the interface would be "enp3s0".

Now let's modify the profile:

```
lxc profile device add macvlan eth0 nic nictype=macvlan parent=enp3s0
```

This command adds all of the necessary parameters to the macvlan profile so that it can be used.

To take a look at what this command created, use the command:

```
lxc profile show macvlan
```

Which will give you output similar to this:


```
config: {}
description: ""
devices:
  eth0:
    nictype: macvlan
    parent: enp3s0 
    type: nic
name: macvlan
used_by: []
```

Obviously, you can use profiles for lots of other things, but assigning a static IP to a container, or using your own DHCP server as a source for an address are very common needs.

To assign the macvlan profile to rockylinux-test-8 we need to do the following:

```
lxc profile assign rockylinux-test-8 default,macvlan
```

Let's also do the same thing for rockylinux-test-9:

```
lxc profile assign rockylinux-test-9 default,macvlan
```

This simply says, we want the default profile, and then we want to apply the macvlan profile as well.

## Rocky Linux macvlan

In RHEL distributions and clones, Network Manager has been in a constant state of change. Because of this, the way the `macvlan` profile works does not work (at least in comparison to other distributions), and requires a little additional work to assign IP addresses from DHCP or statically. 

Remember that none of this has anything to do with Rocky Linux particularly, but with the upstream package implementation.

Simply put, if you want to run Rocky Linux containers and use macvlan to assign an IP address from your LAN or WAN networks, then the process is different based on which container version of the OS you are using (8.6 or 9.0).

### Rocky Linux 9.0 macvlan - The DHCP Fix

First, let's illustrate what happens when we stop and restart the two containers after assigning the macvlan profile.

Having the profile assigned, however, doesn't change the default configuration, which is set to DHCP by default.

To test this, simply do the following:

```
lxc restart rocky-test-8
lxc restart rocky-test-9
```

Now list your containers again and note that the rockylinux-test-9 does not have an IP address anymore:

```
lxc list
```

```
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING |                      |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```
As you can see, our Rocky Linux 8.6 container received the IP address from the LAN interface, whereas the Rocky Linux 9.0 container did not.

To further demonstrate the problem here, we need to execute `dhclient` on the Rocky Linux 9.0 container. This will show us that the macvlan profile, *is* in fact applied:

```
lxc exec rockylinux-test-9 dhclient
```

A new listing using `lxc list` now shows the following:

```
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.113 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

That should have happened with a simple stop and start of the container, but it does not. Assuming that we want to use a DHCP assigned IP address every time, then we can fix this with a simple crontab entry. To do this, we need to gain shell access to the container by entering:

```
lxc exec rockylinux-test-9 bash
```

Next, lets determine the complete path to `dhclient`. To do this, because this was built on a minimal image, you will need to first install `which`:

```
dnf install which
```

then run:

```
which dhclient
```

which should return:

```
/usr/sbin/dhclient
```

Next, let's modify root's crontab:

```
crontab -e
```

And add this line:

```
@reboot    /usr/sbin/dhclient
```

The crontab command entered above, uses _vi_ so to save your changes and exit simply use:

```
SHIFT:wq!
```

Now exit the container and restart rockylinux-test-9:

```
lxc restart rockylinux-test-9
```

A new listing will reveal that the container has been assigned the DHCP address:

```
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.113 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```

### Rocky Linux 9.0 macvlan - The Static IP Fix

To statically assign an IP address, things get even more convoluted. Since `network-scripts` is now deprecated in Rocky Linux 9.0, the only way to do this is through static assignment, and because of the way the containers use the network, you're not going to be able to set the route with a normal `ip route` statement either. The problem turns out to be that the interface assigned when applying the macvlan profile (eth0 in this case), cannot be managed. The fix is to rename the network interface on the container after restart and then assign the static IP. This can all be scripted and can be done (again) with root's crontab. This is all done with the `ip` command.

To do this, we need to gain shell access to the container again:

```
lxc exec rockylinux-test-9 bash
```

Next, we are going to create a bash script in `/usr/local/sbin` called "static":

```
vi /usr/local/sbin/static
```

The contents of this script are simple:

```
#!/usr/bin/env bash

/usr/sbin/ip link set dev eth0 name net0
/usr/sbin/ip addr add 192.168.1.151/24 dev net0
/usr/sbin/ip link set dev net0 up
/usr/sbin/ip route add default via 192.168.1.1
```

So, what are we doing here? First, we rename eth0 to a new name that we can manage. We have chosen "net0" here. Second, we assign the new static IP that we have allocated for our container. In this case 192.168.1.151. Now we bring up the new "net0" interface. Finally, we need to add the default route for our interface.


Make our script executable with:

```
chmod +x /usr/local/sbin/static
```

Next, we add this to root's crontab for the container using the @reboot time:

```
@reboot     /usr/local/sbin/static
```

Finally, exit the container and restart it:

```
lxc restart rockylinux-test-9
```

Wait a few seconds and then list out the containers again:

```
lxc list
```

Which should show you success:

```
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

## Ubuntu macvlan

Luckily, In Ubuntu's implementation of Network Manager, the macvlan stack is NOT broken, so it is much easier to deploy!

First, just like with our rockylinux-test-9 container, we need to assign the template to our container:

```
lxc profile assign ubuntu-test default,macvlan
```

That should be all that is necessary to get a DHCP assigned address. To find out, stop and then start the container again:

```
lxc restart ubuntu-test
```

Then list the containers again:

```
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 192.168.1.132 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

Success!

Configuring the Static IP is just a little different, but not at all hard. We need to modify the .yaml file associated with the container's connection (/10-lxc.yaml). For this static IP, we will use 192.168.1.201:

```
vi /etc/netplan/10-lxc.yaml
```

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

Now restart the container:

```
lxc restart ubuntu-test
```

When you list your containers again, you should see our new static IP:

```
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 192.168.1.201 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```

Success!

In the examples used in this chapter, we have intentionally chosen a hard container to configure, and two easy ones. There are obviously many more versions of Linux available in the image listing. If you have a favorite, try installing it, assigning the macvlan template, and setting IP's.
