---
title: 6 Profiles
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with:  9.4
tags:
  - incus 
  - enterprise
  - incus profiles
---

Throughout this chapter, you must run commands as your unprivileged user ("incusadmin" if you've followed this book from the beginning).

When you install Incus, you get a default profile, which you cannot remove or modify. You can use the default profile to create new profiles for your containers.

If you examine your container listing, you will notice that the IP address in each case is from the bridged interface. In a production environment, you may want to use something else. This might be a DHCP-assigned address from your LAN interface or a statically assigned address from your WAN.

If you configure your Incus server with two interfaces and assign each an IP on your WAN and LAN, you can assign your container's IP addresses based on the interface the container needs to be facing.

As of Rocky Linux version 9.4 (and any bug for bug copy of Red Hat Enterprise Linux), the method for assigning IP addresses statically or dynamically with the profiles does not work.

There are ways to get around this, but it is unpleasant. This appears to have something to do with changes made to Network Manager that affect `macvlan`. `macvlan` allows you to create many interfaces with different Layer 2 addresses.

Be aware that this has drawbacks when choosing container images based on RHEL.

## Creating a `macvlan` profile and assigning it

To create your `macvlan` profile, use this command:

```bash
incus profile create macvlan
```

If you were on a multi-interface machine and wanted more than one `macvlan` template based on the network you wanted to reach, you might use "lanmacvlan" or "wanmacvlan" or any other name that you tried to use to identify the profile. Using "macvlan" in your profile creation statement is up to you.

You want to change the `macvlan` interface, but before you do, you need to know what the parent interface is for your Incus server. This interface will have a LAN (in this case) assigned IP. To find what interface that is, use:

```bash
ip addr
```

Look for the interface with the LAN IP assignment in the 192.168.1.0/24 network:

```bash
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 40:16:7e:a9:94:85 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.106/24 brd 192.168.1.255 scope global dynamic noprefixroute enp3s0
       valid_lft 4040sec preferred_lft 4040sec
    inet6 fe80::a308:acfb:fcb3:878f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

In this case, the interface is "enp3s0".

Next, change the profile:

```bash
incus profile device add macvlan eth0 nic nictype=macvlan parent=enp3s0
```

This command adds all the parameters to the `macvlan` profile required for use.

Examine what this command created by using the command:

```bash
incus profile show macvlan
```

Which will give you output similar to this:

```bash
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

Profiles can be used for many other things, but assigning a static IP to a container or using your own DHCP server are common needs.

To assign the `macvlan` profile to rockylinux-test-8, you need to do the following:

```bash
incus profile assign rockylinux-test-8 default,macvlan
```

Do the same thing for rockylinux-test-9:

```bash
incus profile assign rockylinux-test-9 default,macvlan
```

This says you want the default profile and to apply the `macvlan` profile too.

## Rocky Linux `macvlan`

The Network Manager has been constantly changing in RHEL distributions and clones. Because of this, the way the `macvlan` profile works does not work (at least in comparison to other distributions) and requires additional work to assign IP addresses from DHCP or statically.

Remember that none of this mainly has anything to do with Rocky Linux but with the upstream package implementation.

If you want to run Rocky Linux containers and use `macvlan` to assign an IP address from your LAN or WAN networks, the process is different based on the container version of the operating system (8.x or 9.x).

### Rocky Linux 9.x macvlan - the DHCP fix

First, let us illustrate what happens when stopping and restarting the two containers after assigning the `macvlan` profile.

Having the profile assigned, however, does not change the default configuration, which is DHCP by default.

To test this, do the following:

```bash
incus restart rocky-test-8
incus restart rocky-test-9
```

List your containers again and note that the rockylinux-test-9 does not have an IP address anymore:

```bash
incus list
```

```bash
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

As you can see, your Rocky Linux 8.x container received the IP address from the LAN interface, whereas the Rocky Linux 9.x container did not.

To further demonstrate the problem, you must run `dhclient` on the Rocky Linux 9.0 container. This will show us that the `macvlan` profile, *is* applied:

```bash
incus exec rockylinux-test-9 dhclient
```

Another container listing now shows the following:

```bash
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

That should have happened with a stop and start of the container, but it does not. Assuming you want to use a DHCP-assigned IP address every time, you can fix this with a simple crontab entry. To do this, you need to gain shell access to the container by entering:

```bash
incus shell rockylinux-test-9
```

Next, let us determine the path to `dhclient`. To do this, because this container is from a minimal image, you will need first to install `which`:

```bash
dnf install which
```

Then run:

```bash
which dhclient
```

Which will return:

```bash
/usr/sbin/dhclient
```

Next, change root's crontab:

```bash
crontab -e
```

Add this line:

```bash
@reboot    /usr/sbin/dhclient
```

The crontab command entered uses *vi*. Use ++shift+colon+"w"+"q"++ to save your changes and exit.

Exit the container and restart rockylinux-test-9:

```bash
incus restart rockylinux-test-9
```

Another listing will reveal that the container has the DHCP address assigned:

```bash
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

### Rocky Linux 9.x `macvlan` - The static IP fix

When statically assigning an IP address, things get even more convoluted. Since `network-scripts` is now deprecated in Rocky Linux 9.x, the only way to do this is through static assignment, and because of the way the containers use the network, you are not going to be able to set the route with a normal `ip route` statement. The problem is that the interface assigned when applying the `macvlan` profile (eth0 in this case), is not manageable with Network Manager. The fix is to rename the container's network interface after restarting and assign the static IP. You can do this with a script and run (again) within root's crontab. Do this with the `ip` command.

To do this, you need to gain shell access to the container again:

```bash
incus shell rockylinux-test-9
```

Next, you are going to create a bash script in `/usr/local/sbin` called "static":

```bash
vi /usr/local/sbin/static
```

The contents of this script are not complicated:

```bash
#!/usr/bin/env bash

/usr/sbin/ip link set dev eth0 name net0
/usr/sbin/ip addr add 192.168.1.151/24 dev net0
/usr/sbin/ip link set dev net0 up
sleep 2
/usr/sbin/ip route add default via 192.168.1.1
```

What are you doing here?

* you rename eth0 to a new name that you can manage ("net0")
* you assign the new static IP that you have allocated for your container (192.168.1.151)
* you bring up the new "net0" interface
* you add a 2-second wait for the interface to be active before adding the default route
* you need to add the default route for your interface

Make your script executable with the following:

```bash
chmod +x /usr/local/sbin/static
```

Add this to the root's crontab for the container with the @reboot time:

```bash
@reboot     /usr/local/sbin/static
```

Finally, exit the container and restart it:

```bash
incus restart rockylinux-test-9
```

Wait a few seconds and list out the containers again:

```bash
incus list
```

You should see success:

```bash
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

Luckily, Ubuntu's implementation of Network Manager does not break the `macvlan` stack, making it much easier to deploy!

Just like with your rockylinux-test-9 container, you need to assign the profile to your container:

```bash
incus profile assign ubuntu-test default,macvlan
```

To find out if DHCP assigns an address to the container, stop and start the container again:

```bash
incus restart ubuntu-test
```

List the containers again:

```bash
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

Configuring the Static IP is a little different, but not hard. You must change the `.yaml` file associated with the container's connection (`10-incus.yaml`). For this static IP, you will use 192.168.1.201:

```bash
vi /etc/netplan/10-incus.yaml
```

Change what is there to the following:

```bash
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

Please save your changes and leave the container.

Restart the container:

```bash
incus restart ubuntu-test
```

When you list your containers again, you will see your static IP:

```bash
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

In the examples used here, a hard container to configure was intentionally chosen, and two less difficult ones. Many more versions of Linux are in the image listing. If you have a favorite, try installing it, assigning the `macvlan` template, and setting IPs.
