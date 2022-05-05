---
title: Networking Configuration
author: unknown
contributors: Steven Spencer, Hayden Young
tested with: 8.5
tags:
  - networking
  - configuration
  - network
---

# Networking configuration

## Prerequisites

* A certain amount of comfort operating from the command line
* Elevated or administrative privileges on the system (For example root, `sudo` and so on)
* Optional: familiarity with networking concepts

## Introduction

Nowadays a computer without network connectivity is almost useless by itself. Whether you need to update the packages on a server or simply browse external Websites from your laptop - you will need network access!

This guide aims to provide Rocky Linux users the basic knowledge on how to setup network connectivity on a Rocky Linux system.

## Using NetworkManager service

At the user level, the networking stack is managed by *NetworkManager*. This tool runs as a service, and you can check its state with the following command:

```bash
systemctl status NetworkManager
```

### Configuration files

NetworkManager simply applies a configuration read from the files found in `/etc/sysconfig/network-scripts/ifcfg-<IFACE_NAME>`.
Each network interface has its configuration file. The following shows an example for the default configuration of a server:

```bash
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=no
NAME=enp1s0
UUID=74c5ccee-c1f4-4f45-883f-fc4f765a8477
DEVICE=enp1s0
ONBOOT=yes
IPADDR=10.0.0.10
PREFIX=24
GATEWAY=10.0.0.1
DNS1=10.0.0.1
DNS2=1.1.1.1
IPV6_DISABLED=yes
```

The interface's name is **enp1s0** so this file's name will be `/etc/sysconfig/network-scripts/ifcfg-enp1s0`.

!!! hint "**Tips:**"  

    There are a few ways or mechanisms by which systems can be assigned their IP configuration information. The two most common methods are - **Static IP configuration** scheme and **Dynamic IP configuration** scheme.

    The static IP configuration scheme is very popular on server class systems or networks.

    The dynamic IP approach is popular on home and office networks - or workstation and desktop class systems.  The dynamic scheme usually needs _something_ extra that is locally available that can supply proper IP configuration information to requesting workstations and desktops. This _something_ is called the Dynamic Host Configuration Protocol (DHCP).

Very often, home/office users don't have to worry or know about DHCP. This is because the somebody or something else is automagically taking care of that in the background. The only thing that the end user needs to do is to physically or wirelessly connect to the right network (and of course make sure that their systems are powered on)!

#### IP Address

In the previous `/etc/sysconfig/network-scripts/ifcfg-enp1s0` listing, we see that the value of the `BOOTPROTO` parameter or key is set to `none`. This means that the system being configured is set to a static IP address scheme.

If instead you want to configure the system to use a dynamic IP address scheme, you will have to change the value of the `BOOTPROTO` parameter from `none` to `dhcp` and also remove the `IPADDR`, `PREFIX` and `GATEWAY` lines. This is necessary because all of that information will be automaically obtained from any available DHCP server.

To configure a static IP address attribution, set the following:

* IPADDR: the IP address to assign the interface
* PREFIX: the subnet mask in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)
* GATEWAY: the default gateway

The `ONBOOT` parameter set to `yes` indicates that this connection will be activated during boot time.

#### DNS resolution

To get proper name resolution, the following parameters must be set:

* DNS1: IP address of the main nameserver
* DNS2: the secondary nameserver IP address

#### Checking configuration

You can check that the configuration has been correctly applied with the following `nmcli` command:

```bash
[user@server ~]$ sudo nmcli device show enp1s0
```

which should give you the following output:

```conf
GENERAL.DEVICE:                         enp1s0
GENERAL.TYPE:                           ethernet
GENERAL.HWADDR:                         6E:86:C0:4E:15:DB
GENERAL.MTU:                            1500
GENERAL.STATE:                          100 (connecté)
GENERAL.CONNECTION:                     enp1s0
GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
WIRED-PROPERTIES.CARRIER:               marche
IP4.ADDRESS[1]:                         10.0.0.10/24
IP4.GATEWAY:                            10.0.0.1
IP4.ROUTE[1]:                           dst = 10.0.0.0/24, nh = 0.0.0.0, mt = 100
IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 10.0.0.1, mt = 100
IP4.DNS[1]:                             10.0.0.1
IP4.DNS[2]:                             1.1.1.1
IP6.GATEWAY:                            --
```

### CLI

NetworkManager's primary function is managing "connections", which map a physical device to more logical network components like an IP address and DNS settings.
To view the existing connections NetworkManager maintains, you can run `nmcli connection show`.

```bash
[user@server ~]$ sudo nmcli connection show
NAME    UUID                                  TYPE      DEVICE
enp1s0  625a8aef-175d-4692-934c-2c4a85f11b8c  ethernet  enp1s0
```

From the output above, we can determine that NetworkManager manages a connection (`NAME`) called `enp1s0` that maps to the physical device (`DEVICE`) `enp1s0`.

!!! hint "Connection name"

    In this example, both the connection and device share the same name, but this may not always be the case. It is common to see a connection called `System eth0` that maps to a device called `eth0`, for example.

Now that we know the name of our connection, we can view the settings for it. To do this, use the `nmcli connection show [connection]` command, which will print out all of the settings NetworkManager registers for the given connection.

```bash
[user@server ~]$ sudo nmcli connection show enp1s0
...
ipv4.method:                            auto
ipv4.dns:                               --
ipv4.dns-search:                        --
ipv4.dns-options:                       --
ipv4.dns-priority:                      0
ipv4.addresses:                         --
ipv4.gateway:                           --
ipv4.routes:                            --
ipv4.route-metric:                      -1
ipv4.route-table:                       0 (unspec)
ipv4.routing-rules:                     --
ipv4.ignore-auto-routes:                no
ipv4.ignore-auto-dns:                   no
ipv4.dhcp-client-id:                    --
ipv4.dhcp-iaid:                         --
ipv4.dhcp-timeout:                      0 (default)
ipv4.dhcp-send-hostname:                yes
...
```

Down the left-hand column, we see the name of the setting, and down the right we see the value.

For example, we can see that the `ipv4.method` here is currently set to `auto`. There are many allowed values for the `ipv4.method` setting, but the main two you will most likely see are:

* `auto`: the appropriate automatic method (DHCP, PPP, etc) is used for the interface and most other properties can be left unset.
* `manual`: static IP addressing is used and at least one IP address must be given in the 'addresses' property.

If instead you want to configure the system to use a static IP address scheme, you will have to change the value of `ipv4.method` to `manual`, and also specify the `ipv4.gateway` and `ipv4.addresses`.

To modify a setting, you can use the nmcli command `nmcli connection modify [connection] [setting] [value]`.

```bash
# set 10.0.0.10 as the static ipv4 address
[user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.addresses 10.0.0.10

# set 10.0.0.1 as the ipv4 gateway
[user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.gateway 10.0.0.1

# change ipv4 method to use static assignments (set in the previous two commands)
[user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.method manual
```

!!!hint "When does the connection get updated?"

    `nmcli connection modify` will not modify the *runtime* configuration, but update the `/etc/sysconfig/network-scripts` configuration files with the appropriate values based on what you have told `nmcli` to configure.

To configure your DNS servers with NetworkManager via the CLI, you can modify the `ipv4.dns` setting.

```bash
# set 10.0.0.1 and 1.1.1.1 as the primary and secondary DNS servers
[user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.dns '10.0.0.1 1.1.1.1'
```

### Apply configuration

To apply the network configuration, you can use the `nmcli connection up [connection]` command.

```bash
[user@server ~]$ sudo nmcli connection up enp1s0
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/2)
```

To get the connection state, simply use:

```bash
[user@server ~]$ sudo nmcli connection show
NAME    UUID                                  TYPE      DEVICE
enp1s0  625a8aef-175d-4692-934c-2c4a85f11b8c  ethernet  enp1s0
```

You can also use the `ifup` and `ifdown` commands to bring the interface up and down (they are simple wrappers around `nmcli`):

```bash
[user@server ~]$ sudo ifup enp1s0
[user@server ~]$ sudo ifdown enp1s0
```

## Using ip utility

The `ip` command (provided by the *iproute2* package) is a powerful tool to get information and configure the network of a modern Linux system such as Rocky Linux.

In this example, we will assume the following parameters:

* interface name: ens19
* ip address: 192.168.20.10
* subnet mask: 24
* gateway: 192.168.20.254

### Get general information

To see the detailed state of all interfaces, use

```bash
ip a
```

!!! hint "**Pro tips:**"

    * use the `-c` flag to get a more readable coloured output: `ip -c a`.
	* `ip` accepts abbreviation so `ip a`, `ip addr` and `ip address` are equivalent

### Bring interface up or down

To bring the *ens19* interface up, simply use `ip link set ens19 up` and to bring it down, use `ip link set ens19 down`.

### Assign the interface a static address

The command to be used is of the form:

```bash
ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>
```

To assign the above example parameters, we will use:

```bash
ip a add 192.168.20.10/24 dev ens19
```

Then, checking the result with:

```bash
ip a show dev ens19
```

will output:

```bash
	3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
		link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
		inet 192.168.20.10/24 scope global ens19
		valid_lft forever preferred_lft forever
```

Our interface is up and configured, but is still lacking something!

### Using ifcfg utility

To add the *ens19* interface our new example IP address, use the following command:

```bash
ifcfg ens19 add 192.168.20.10/24
```

To remove the address:

```bash
ifcfg ens19 del 192.168.20.10/24
```

To completely disable IP addressing on this interface:

```bash
ifcfg ens19 stop
```

*Note that this does not bring the interface down, it simply unassigns all IP addresses from the interface.*

### Gateway configuration

Now that the interface has an address, we have to set its default route, this can be done with:

```bash
ip route add default via 192.168.20.254 dev ens19
```

The kernel routing table can be displayed with

```bash
ip route
```

or `ip r` for short.

## Checking network connectivity

At this point, you should have your network interface up and properly configured. There are several ways to verify your connectivity.

By *pinging* another IP address in the same network (we will use `192.168.20.42` as an example):

```bash
ping -c3 192.168.20.42
```

This command will issue 3 *pings* (known as ICMP request) and wait for a reply. If everything went fine, you should get this output:

```bash
PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms

--- 192.168.20.42 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms
```

Then, to make sure your routing configuration is fine, try to *ping* a external host, such as this well known public DNS resolver:

```bash
ping -c3 8.8.8.8
```

If your machine has several network interface and you want to make ICMP request via a specific interface, you can use the `-I` flag:

```bash
ping -I ens19 -c3 192.168.20.42
```

It is now time to make sure that DNS resolution is working correctly. As a reminder, DNS resolution is a mechanism used to convert human friendly machine names into their IP addresses and the other way round (reverse DNS).

If the `/etc/resolv.conf` file indicates a reachable DNS server, then the following should work:

```bash
host rockylinux.org
```

The result should be:

```bash
rockylinux.org has address 76.76.21.21
```
