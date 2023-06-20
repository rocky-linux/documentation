---
title: 6 Profiles
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd profiles
---

# Chapter 6: Profiles

Throughout this chapter you will need to run commands as your unprivileged user ("lxdadmin" if you've been following from the beginning in this book).

You get a default profile when you install LXD, and this profile cannot be removed or modified. That said, you can use the default profile to create new profiles to use with your containers.

If you examine your container listing, you will notice that the IP address in each case is from the bridged interface. In a production environment, you may want to use something else. This might be a DHCP assigned address from your LAN interface or even a statically assigned address from your WAN.

If you configure your LXD server with two interfaces and assign each an IP on your WAN and LAN, it is possible to assign your container's IP addresses based on the interface the container needs to be facing.

As of version 9.0 of Rocky Linux (and really any bug for bug copy of Red Hat Enterprise Linux) the method for assigning IP addresses statically or dynamically with the profiles does not work.

There are ways to get around this, but it is annoying. This appears to have something to do with changes made to Network Manager that affect macvlan. macvlan allows you to create many interfaces with different Layer 2 addresses.

For now, just be aware that this has drawbacks when choosing container images based on RHEL.

## Creating A macvlan profile and assigning it

To create our macvlan profile, use this command:

```
lxc profile create macvlan
```

If you were on a multi-interface machine and wanted more than one macvlan template based on the network you wanted to reach, you might use "lanmacvlan" or "wanmacvlan" or any other name that you wanted to use to identify the profile. Using "macvlan" in our profile create statement is totally up to you.

You want to change the macvlan interface, but before you do, you need to know what the parent interface is for our LXD server. This will be the interface that has a LAN (in this case) assigned IP. To find what interface that is, use:

```
ip addr
```

Look for the interface with the LAN IP assignment in the 192.168.1.0/24 network:

```
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 40:16:7e:a9:94:85 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.106/24 brd 192.168.1.255 scope global dynamic noprefixroute enp3s0
       valid_lft 4040sec preferred_lft 4040sec
    inet6 fe80::a308:acfb:fcb3:878f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

In this case, the interface is "enp3s0".

Next change the profile:

```
lxc profile device add macvlan eth0 nic nictype=macvlan parent=enp3s0
```

This command adds all of the necessary parameters to the macvlan profile required for use.

Examine what this command created, by using the command:

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

You can use profiles for many other things, but assigning a static IP to a container, or by using your own DHCP server are common needs.

To assign the macvlan profile to rockylinux-test-8 you need to do the following:

```
lxc profile assign rockylinux-test-8 default,macvlan
```

Do the same thing for rockylinux-test-9:

```
lxc profile assign rockylinux-test-9 default,macvlan
```

This says, you want the default profile, and to apply the macvlan profile too.

## Rocky Linux macvlan

In RHEL distributions and clones, Network Manager has been in a constant state of change. Because of this, the way the `macvlan` profile works does not work (at least in comparison to other distributions), and requires a little additional work to assign IP addresses from DHCP or statically. 

Remember that none of this has anything to do with Rocky Linux particularly, but with the upstream package implementation.

If you want to run Rocky Linux containers and use macvlan to assign an IP address from your LAN or WAN networks, the process is different based on the container version of the operating system (8.x or 9.x).

### Rocky Linux 9.x macvlan - the DHCP fix

First, let us illustrate what happens when stopping and restarting the two containers after assigning the macvlan profile.

Having the profile assigned, however, does not change the default configuration, which is DHCP by default.

To test this, do the following:

```
lxc restart rocky-test-8
lxc restart rocky-test-9
```

List your containers again and note that the rockylinux-test-9 does not have an IP address anymore:

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
As you can see, our Rocky Linux 8.x container received the IP address from the LAN interface, whereas the Rocky Linux 9.x container did not.

To further demonstrate the problem here, you need to run `dhclient` on the Rocky Linux 9.0 container. This will show us that the macvlan profile, *is* in fact applied:

```
lxc exec rockylinux-test-9 dhclient
```

Another container listing now shows the following:

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

That should have happened with a stop and start of the container, but it does not. Assuming that you want to use a DHCP assigned IP address every time, you can fix this with a simple crontab entry. To do this, we need to gain shell access to the container by entering:

```
lxc exec rockylinux-test-9 bash
```

Next, lets determine the path to `dhclient`. To do this, because this container is from a minimal image, you will need to first install `which`:

```
dnf install which
```

then run:

```
which dhclient
```

which will return:

```
/usr/sbin/dhclient
```

Next, change root's crontab:

```
crontab -e
```

Add this line:

```
@reboot    /usr/sbin/dhclient
```

The crontab command entered uses _vi_ . To save your changes and exit  use <kbd>SHIFT</kbd>+<kbd>:</kbd>+<kbd>wq</kbd>.

Exit the container and restart rockylinux-test-9:

```
lxc restart rockylinux-test-9
```

Another listing will reveal that the container has the DHCP address assigned:

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

### Rocky Linux 9.x macvlan - The static IP fix

To statically assign an IP address, things get even more convoluted. Since `network-scripts` is now deprecated in Rocky Linux 9.x, the only way to do this is through static assignment, and because of the way the containers use the network, you are not going to be able to set the route with a normal `ip route` statement. The problem turns out to be that the interface assigned when applying the macvlan profile (eth0 in this case), is not manageable with Network Manager. The fix is to rename the network interface on the container after restart and assign the static IP. You can do this with a script and run (again) within root's crontab. Do this with the `ip` command.

To do this, you need to gain shell access to the container again:

```
lxc exec rockylinux-test-9 bash
```

Next, you are going to create a bash script in `/usr/local/sbin` called "static":

```
vi /usr/local/sbin/static
```

The contents of this script are not difficult:

```
#!/usr/bin/env bash

/usr/sbin/ip link set dev eth0 name net0
/usr/sbin/ip addr add 192.168.1.151/24 dev net0
/usr/sbin/ip link set dev net0 up
/usr/sbin/ip route add default via 192.168.1.1
```

What are we doing here? 

* you rename eth0 to a new name that we can manage ("net0")
* you assign the new static IP that we have allocated for our container (192.168.1.151)
* you bring up the new "net0" interface
* you need to add the default route for our interface


Make our script executable with:

```
chmod +x /usr/local/sbin/static
```

Add this to root's crontab for the container with the @reboot time:

```
@reboot     /usr/local/sbin/static
```

Finally, exit the container and restart it:

```
lxc restart rockylinux-test-9
```

Wait a few seconds and list out the containers again:

```
lxc list
```

You should see success:

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

Luckily, In Ubuntu's implementation of Network Manager, the macvlan stack is NOT broken. It is much easier to deploy!

Just like with your rockylinux-test-9 container, you need to assign the profile to our container:

```
lxc profile assign ubuntu-test default,macvlan
```

To find out if DHCP assigns an address to the container stop and start the container again:

```
lxc restart ubuntu-test
```

List the containers again:

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

Configuring the Static IP is just a little different, but not at all hard. You need to change the .yaml file associated with the container's connection (`10-lxc.yaml`). For this static IP, you will use 192.168.1.201:

```
vi /etc/netplan/10-lxc.yaml
```

Change what is there to the following:

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

Save your changes and exit the container.

Restart the container:

```
lxc restart ubuntu-test
```

When you list your containers again, you will see your static IP:

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

In the examples used in this chapter, a hard container to configure was intentionally chosen, and two less difficult ones. There are many more versions of Linux available in the image listing. If you have a favorite, try installing it, assigning the macvlan template, and setting IPs.
