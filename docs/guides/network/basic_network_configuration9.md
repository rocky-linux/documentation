---
title: Networking Configuration - Rocky Linux 9.0
author: Steven Spencer
contributors: Serge Croisé
tested with: 9.0 
tags:
  - networking
  - configuration
  - network
---

# Networking Configuration - Rocky Linux 9.0

A lot has changed with network configuration as of Rocky Linux 9.0. One of the major changes is the move from Network-Scripts (still available to install-but effectively deprecated) to the use of Network Manager and key files, rather than `ifcfg` based files. `NetworkManager` as of 9.0, prioritizes `keyfiles` over the previous `ifcfg` files. Since this is now the default, the act of configuring the network should now take the default as the proper way of doing things, given that other changes over the years have meant the eventual deprecation and removal of older utilities. This guide will attempt to walk you through the use of Network Manager and the latest changes within Rocky Linux 9.0. 

## Prerequisites

* A certain amount of comfort operating from the command line
* Elevated or administrative privileges on the system (For example root, `sudo` and so on)
* Optional: familiarity with networking concepts

## Using NetworkManager service

At the user level, the networking stack is managed by `NetworkManager`. This tool runs as a service, and you can check its state with the following command:

```bash
systemctl status NetworkManager
```

## Configuration files

As noted at the beginning, the configuration files by default are now key files. You can see how `NetworkManager` prioritizes these files by running the following command:

```
NetworkManager --print-config
```

This gives you output that looks like this:

```
[main]
# plugins=keyfile,ifcfg-rh
# rc-manager=auto
# auth-polkit=true
# iwd-config-path=
dhcp=dhclient
configure-and-quit=no

[logging]
# backend=journal
# audit=false

[device]
# wifi.backend=wpa_supplicant

# no-auto-default file "/var/lib/NetworkManager/no-auto-default.state"
```

Note at the top of the configuration file the reference to `keyfile` followed by `ifcfg-rh`. This means that `keyfile` is the default. Any time you run any of the `NetworkManager` tools to configure an interface (example: `nmcli` or `nmtui`), it will automatically build or update key files.

!!! Hint "Configuration Storage Location"

    In Rocky Linux 8.6, the storage location for network configuration was in `/etc/sysconfig/Network-Scripts/`. With Rocky Linux 9.0, the new default storage location for the key files is in `/etc/NetworkManager/system-connections`. 

The primary (but not the only) utility used for configuring a network interface is the `nmtui` command. This can also be done with the `nmcli` command, but is much less intuitive. We can show the interface as it is currently configured using `nmcli` with: 

```
nmcli device show enp0s3
GENERAL.DEVICE:                         enp0s3
GENERAL.TYPE:                           ethernet
GENERAL.HWADDR:                         08:00:27:BA:CE:88
GENERAL.MTU:                            1500
GENERAL.STATE:                          100 (connected)
GENERAL.CONNECTION:                     enp0s3
GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
WIRED-PROPERTIES.CARRIER:               on
IP4.ADDRESS[1]:                         192.168.1.151/24
IP4.GATEWAY:                            192.168.1.1
IP4.ROUTE[1]:                           dst = 192.168.1.0/24, nh = 0.0.0.0, mt = 100
IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 192.168.1.1, mt = 100
IP4.DNS[1]:                             8.8.8.8
IP4.DNS[2]:                             8.8.4.4
IP4.DNS[3]:                             192.168.1.1
IP6.ADDRESS[1]:                         fe80::a00:27ff:feba:ce88/64
IP6.GATEWAY:                            --
IP6.ROUTE[1]:                           dst = fe80::/64, nh = ::, mt = 1024
```


!!! hint "**Tips:**"  

    There are a few ways or mechanisms by which systems can be assigned their IP configuration information. The two most common methods are - **Static IP configuration** scheme and **Dynamic IP configuration** scheme.

    The static IP configuration scheme is very popular on server class systems or networks.

    The dynamic IP approach is popular on home and office networks or workstation and desktop class systems in a business environment.  The dynamic scheme usually needs _something_ extra that is locally available and that can supply proper IP configuration information to requesting workstations and desktops. This _something_ is called the Dynamic Host Configuration Protocol (DHCP). On a home network, and even on most business networks, this service is provided by a DHCP Server configured for the purpose. This can be a separate server or part of a router configuration.

## IP Address

In the previous section, the displayed configuration for the interface `enp0s3` is generated from the `.ini` file  `/etc/NetworkManager/system-connections/enp0s3.nmconnection`. This shows that the IP4.ADDRESS[1] has been statically configured, rather than dynamically configured via DHCP. If we want to switch this interface back to to a dynamically allocated address, the easiest way is to use the `nmtui` command. 

1. First, run the `nmtui` command at the command-line which should show you the following
    
    ![nmtui](images/nmtui_first.png)

2. It's already on the selection we need "Edit a connection" so hit the <kbd>TAB</kbd> key so that "OK" is highlighted and hit <kbd>ENTER</kbd>

3. This will bring up a screen showing the Ethernet connections on the machine and allow you to choose one. In our case, there is *ONLY* one, so it is already highlighted, we simply need to hit the <kbd>TAB</kbd> key until "Edit" is highlighted and then hit <kbd>ENTER</kbd>

    ![nmtui_edit](images/nmtui_edit.png)

4. Once we've done this, we will be to the screen that shows our current configuration. What we need to do is switch from "Manual" to "Automatic" so hit the <kbd>TAB</kbd> key several times until you get to where "Manual" is highlighted and then hit <kbd>ENTER</kbd>.

    ![nmtui_manual](images/nmtui_manual.png)

5. Arrow up until "Automatic" is highlighted and then hit <kbd>ENTER</kbd>
    
    ![nmtui_automatic](images/nmtui_automatic.png)

6. Once we have switched the interface over to "Automatic" we need to remove the statically assigned IP so hit the <kbd>TAB</kbd> key until the "Remove" is highlighted next to the IP address and hit <kbd>ENTER</kbd>.

    ![nmtui_remove](images/nmtui_remove.png)

7. Finally, hit the <kbd>TAB</kbd> key several times until you get to the bottom of the `nmtui` screen and the "OK" is highlighted and hit <kbd>ENTER</kbd>

You can deactivate and reactivate your interface with `nmtui` as well, but instead let's do this with `nmcli`. In this way we can string the deactivation of the interface and the reactivation of the interface so that the interface is never down for long:

```
nmcli con down enp0s3 && nmcli con up enp0s3
```

Think of this as the equivalent to the old `ifdown enp0s3 && ifup enp0s3` used in older versions of the OS.

To verify that it worked, go ahead and check using either the `ip addr` command, or the the `nmcli device show enp0s3` command that we used earlier.

```
ip addr
```

If successful, you should now see that the static IP is removed and that a dynamically allocated address has been added, similar to this:

```bash
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ba:ce:88 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.137/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 6342sec preferred_lft 6342sec
    inet6 fe80::a00:27ff:feba:ce88/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

### IP Address Changing with `nmcli`

Using the `nmtui` is nice, but if you just want to quickly reconfigure the network interface without all of the time between screens, you probably will want to use `nmcli` by itself. Let's take a look at our example above of a statically assigned IP and what the steps are to reconfigure the interface to DHCP using only `nmcli`.

Before we start, be aware that to reconfigure the interface to DHCP we need to: 

* Remove the IPv4 Gateway 
* Remove the IPv4 Address that we statically assigned
* Change the IPv4 Method to automatic
* Down and Up the interface

Note too, that we are not using examples that tell you to use -ipv4.address etc. These do not change the interface completely. In order to do that we need to set the ipv4.address and the ipv4.gateway to an empty string. Again, to save as much time as possible with our command, we are going to string them all together in one line:

```
nmcli con mod enp0s3 ipv4.gateway '' && nmcli con mod enp0s3 ipv4.address '' && nmcli con mod enp0s3 ipv4.method auto && nmcli con down enp3s0 && nmcli con up enp3s0
```

Running the `ip addr` command again, should show you the exact same results as when we ran the changes with `nmtui`. We could obviously do everything in reverse as well (changing our DHCP address to a static one). To do this, we would run the commands in reverse starting with changing the `ipv4.method` to manual, setting the `ipv4.gateway` and then setting the `ipv4.address`. Since in all of these examples we are completely reconfiguring the interface and not adding or subtracting values to it, we again would not use the examples out there that talk about using `+ipv4.method`,`+ipv4.gateway`, and `+ipv4.address`. If you used these commands instead of the ones we have used above, you would end up with an interface with *BOTH* a DHCP assigned address and a statically assigned one. That said, this can sometimes be very handy. If you have a web service listening on one IP lets say, and an SFTP server listening on another IP. Having a method of assigning multiple IP's to an interface is quite useful. 

## DNS resolution

Setting DNS servers can be done with either `nmtui` or `nmcli`. While the `nmtui` interface is easy to navigate and much more intuitive, it makes the process a lot slower. Doing this with the `nmcli` is much faster. In the case of the DHCP assigned address, it's not usually necessary to set DNS servers as they normally are forwarded on from the DHCP server. That said, you *can* statically add DNS servers to a DHCP interface. In the case of the statically assigned interface, you will *HAVE* to do this as it will need to know how to get DNS resolution and will not have an automatically assigned method.

Since the best example for all of this is a statically assigned IP, let's return to our original statically assigned address in our example interface (enp0s3). Before we can change the DNS values, we need to see what they are currently set to. 
To get proper name resolution, let's start by removing our already set DNS servers and adding in different ones. Currently the `ipv4.dns` is set to `8.8.8.8,8.8.4.4,192.168.1.1`. In this case, we don't need to first set the ipv4.dns to an empty string. We can simply use the following command to replace our values: 

```
nmcli con mod enp0s3 ipv4.dns '208.67.222.222,208.67.220.220,192.168.1.1'
```

Running `nmcli con show enp0s3 | grep ipv4.dns` should show you that we have successfully changed the DNS servers. To activate everything, let's bring our interface down and up again so that our changes are active:

```
nmcli con down enp0s3 && nmcli con up enp0s3
```

To test that we *do* in fact have name resolution, try pinging a known host. We will use google.com as an example:

```bash
ping google.com
PING google.com (172.217.4.46) 56(84) bytes of data.
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=1 ttl=119 time=14.5 ms
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=2 ttl=119 time=14.6 ms
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=3 ttl=119 time=14.4 ms
^C
```

## Using The `ip` Utility

The `ip` command (provided by the *iproute2* package) is a powerful tool to get information and configure the network of a modern Linux system such as Rocky Linux.

In this example, we will assume the following parameters:

* interface name: enp0s3
* ip address: 192.168.1.151
* subnet mask: 24
* gateway: 192.168.1.1

### Get general information

To see the detailed state of all interfaces, use

```bash
ip a
```

!!! hint "**Pro tips:**"

    * use the `-c` flag to get a more readable coloured output: `ip -c a`.
	* `ip` accepts abbreviation so `ip a`, `ip addr` and `ip address` are equivalent

### Bring interface up or down

!!! note 

    While it is still possible to use this method for bringing the interface up and down in Rocky Linux 9.0, the command reacts a great deal slower than simply using the `nmcli` command in our previous examples.

To bring the *enp0s3* down and up again we can simply use: 

```
ip link set enp0s3 down && ip link set enp0s3 up
```

### Assign the interface a static address

Currently, our enp0s3 interface has an IP address of 192.168.1.151. To switch that to 192.168.1.152, we would remove the old IP with

```bash
ip addr delete 192.168.1.151/24 dev enp0s3 && ip addr add 192.168.1.152/24 dev enp0s3
```

If we wanted a second IP assigned to the interface instead of removing the 192.168.1.151 address, we would simply add the second address with:

```bash
ip addr add 192.168.1.152/24 dev enp0s3
```

We can check to see if the IP address was added with 

```bash
ip a show dev enp0s3
```

will output:

```bash
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ba:ce:88 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.151/24 brd 192.168.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.1.152/24 scope global secondary enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feba:ce88/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
```

While bringing the interface up and down using the `ip` utility is much slower than `nmcli`, `ip` has a distinct advantage when setting new or additional IP addresses, as it happens in real time, without bringing the interface down and up.

### Gateway configuration


Now that the interface has an address, we have to set its default route, this can be done with:

```bash
ip route add default via 192.168.1.1 dev enp0s3
```

The kernel routing table can be displayed with

```bash
ip route
```

or `ip r` for short.

This should output something like this:

```bash
default via 192.168.1.1 dev enp0s3 
192.168.1.0/24 dev enp0s3 proto kernel scope link src 192.168.1.151 metric 100
```

## Checking network connectivity

Throughout the examples above we have done some testing. Your best bet for testing is to start by pinging the default gateway. This should always work:

```bash
ping -c3 192.168.1.1
PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=0.437 ms
64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.879 ms
64 bytes from 192.168.1.1: icmp_seq=3 ttl=64 time=0.633 ms
```

Next, test to see if your LAN routing is working completely by pinging a host on your local network:

```bash
ping -c3 192.168.1.10
PING 192.168.1.10 (192.168.1.10) 56(84) bytes of data.
64 bytes from 192.168.1.10: icmp_seq=2 ttl=255 time=0.684 ms
64 bytes from 192.168.1.10: icmp_seq=3 ttl=255 time=0.676 ms
```

Now test to make sure we can see a reachable host external of your network. For the test below, we are using Google's open DNS server:

```bash
ping -c3 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=119 time=19.8 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=119 time=20.2 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=119 time=20.1 ms
```

The final test, is to make sure that DNS resolution is working. For this example, we are using google.com:

```bash
ping -c3 google.com
PING google.com (172.217.4.46) 56(84) bytes of data.
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=1 ttl=119 time=14.5 ms
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=2 ttl=119 time=15.1 ms
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=3 ttl=119 time=14.6 ms
```

If your machine has several interfaces and you want to test from a particular interface, simply use the `-I` option with ping:

```bash
ping -I enp0s3 -c3 192.168.1.10
```

## Conclusions

There are a great deal of changes to the networking stack on Rocky Linux 9.0. Among these are the prioritization of `keyfile` over the formerly used `ifcfg` files found in Network-Scripts. Since it is evident that the direction of movement here in future versions of Rocky Linux will completely deprecate and remove Network-Scripts as an option, it's best to focus attention on methodologies such as `nmcli`, `nmtui`, and in some cases `ip`, for network configuration.  
