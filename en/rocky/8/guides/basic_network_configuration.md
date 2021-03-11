# Rocky Linux - Networking configuration

## Prerequisites

* A certain amount of comfort operating from the command line
* All operations require root access
* Optional: familiarity with networking concepts

# Introduction

Nowadays a computer is almost useless by itself. Whether you need to update the packages on a server or browse the Web on your laptop, you will need network access.
This guide aims to provide Rocky Linux users the basic knowledge of how to setup network connectivity on Rocky Linux.

## Using NetworkManager service

The easiest way to configure your network is by using _NetworkManager_. Using a desktop version of Rocky Linux, setting up the network with _NetworkManager_ can be done through GUI tools, but this document assumes that you want or need to set the network up via the command line. It's a great skill to have anyway, and you may find that it is faster than using those GUI tools too. On most servers, the GUI interface would not be installed, so you would want to use this procedure.

At the user level, the networking stack is managed by _NetworkManager_. This tool is running as a service, you can check its state with the following command:

`systemctl status NetworkManager`

### Configuration files

_NetworkManager_ simply applies a configuration read from the files found in `/etc/sysconfig/network-scripts/ifcfg-<IFACE_NAME>`.
Each network interface has its own configuration file. The following example is the default configuration for a server:

```
    TYPE=Ethernet
	PROXY_METHOD=none
	BROWSER_ONLY=no
	BOOTPROTO=none
	DEFROUTE=yes
	IPV4_FAILURE_FATAL=no
	IPV6INIT=no
	NAME=ens18
	UUID=74c5ccee-c1f4-4f45-883f-fc4f765a8477
	DEVICE=ens18
	ONBOOT=yes
	IPADDR=192.168.0.1
	PREFIX=24
	GATEWAY=192.168.0.254
	DNS1=192.168.0.254
	DNS2=1.1.1.1
	IPV6_DISABLED=yes
```
The interface's name is **ens18** so this file's name will be `/etc/sysconfig/network-scripts/ifcfg-ens18`.

#### IP address

Here there is no dynamic IP address attribution (known as DHCP)as the `BOOTPROTO` parameter is set to `none`. To enable it, set it to `dhcp` and remove the `IPADDR`, `PREFIX` and `GATEWAY` lines.
To configure a static IP address attribution, set the following:

* IPADDR: the IP address to assign the interface
* PREFIX: the subnet mask in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)
* GATEWAY: the default gateway

The `ONBOOT` parameter set to `yes` indicates that this connection will be activated during boot time.

#### DNS resolution

DNS resolution is a mechanism used to convert human friendly machine names into their IP addresses and the other way round (reverse DNS).

To get proper name resolution, the following parameters must be set:

* DNS1: IP address of the main nameserver
* DNS2: the secondary nameserver IP address

_NetworkManager_ will use the nameservers configuration and will populate `/etc/resolv.conf` with it.

### Apply configuration

To apply the network configuration, the `nmcli` command can be used:

    `nmcli connection up ens18`

To get the connection state, simply use:

    `nmcli connection show`

You can also use the `ifup` and `ifdown` commands to bring the interface up and down (they are simple wrappers around `nmcli`):
```
	ifup ens18
	ifdown ens18
```

### Checking configuration

You can check that the configuration has been correctly applied with the following `nmcli` command:

	`nmcli device show ens18`

which should give you the following output:

```
	GENERAL.DEVICE:                         ens18
	GENERAL.TYPE:                           ethernet
	GENERAL.HWADDR:                         6E:86:C0:4E:15:DB
	GENERAL.MTU:                            1500
	GENERAL.STATE:                          100 (connecté)
	GENERAL.CONNECTION:                     ens18
	GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
	WIRED-PROPERTIES.CARRIER:               marche
	IP4.ADDRESS[1]:                         192.168.0.1/24
	IP4.GATEWAY:                            192.168.0.254
	IP4.ROUTE[1]:                           dst = 192.168.0.0/24, nh = 0.0.0.0, mt = 100
	IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 192.168.0.254, mt = 100
	IP4.DNS[1]:                             192.168.0.254
	IP4.DNS[2]:                             1.1.1.1
	IP6.GATEWAY:                            --
```

## Using ip utility

While modifying the configuration files and allowing _NetworkManager_ to get things going for you is the easiest way to configure your network, there may be times when you need to set things manually. The `ip` command (provided by the _iproute2_ package) is a powerful tool of any modern Linux system, such as Rocky Linux, that can be used both to configure the network, and also to get information from the network for testing and troubleshooting.

In this example, we will assume the following parameters:

* interface name: ens19
* ip address: 192.168.20.10
* subnet mask: 24
* gateway: 192.168.20.254

### Get general information

To see the detailed state of all interfaces, use

	`ip a`

**Pro tips:**
* use the `-c` flag to get a more readable coloured output: `ip -c a`.
* `ip` accepts abbreviation so `ip a`, `ip addr` and `ip address` are equivalent

### Bring interface up or down

To bring the *ens19* interface up, simply use `ip link set ens19 up` and to bring it down, use `ip link set ens19 down`.

### Assign the interface a static address

The command to be used is of the form:

	`ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>`

To assign the above example parameters, we will use:

	`ip a add 192.168.20.10/24 dev ens19`

Then, checking the result with:

	`ip a show dev ens19`

will output:
```
	3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
		link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
		inet 192.168.20.10/24 scope global ens19
		valid_lft forever preferred_lft forever
```
Our interface is up and configured, but we lack something. We haven't set a gateway, but we will get to that!

### Gateway configuration

Now that the interface has an address, we have to set its default route. The default route is the firewall or router that provides the actual pathway to the Internet, in this case, 192.168.20.254. Setting this can be done with:

	`ip route add default via 192.168.20.254 dev ens19`

The kernel routing table can be displayed with

	`ip route`

or `ip r` for short.

### Using ifcfg utility

To add the *ens19* interface our new example IP address, use the following command:

	`ifcfg ens19 add 192.168.20.10/24`

To remove the address:

	`ifcfg ens19 del 192.168.20.10/24`

To completely disable IP addressing on this interface:

	`ifcfg ens19 stop`

*Note that this does not bring the interface down, it simply removes all IP address assignment from the interface.*

## Checking network connectivity

At this point, you should have your network interface up and properly configured. There are several ways to verify your connectivity.

By *pinging* another IP address in the same network (we will use `192.168.20.42` as an example):

	`ping -c3 192.168.20.42`

This command will issue 3 *pings* (known as ICMP request) and wait for a reply. If everything went fine, you should get this output:
```
	PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
	64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
	64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
	64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms

	--- 192.168.20.42 ping statistics ---
	3 packets transmitted, 3 received, 0% packet loss, time 5ms
	rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms
```
Then, to make sure your routing configuration is fine, try to *ping* a external host, such as this well known public DNS resolver:

	`ping -c3 8.8.8.8`

If your machine has several network interfaces and you want to make ICMP request via a specific interface, you can use the `-I` flag:

	`ping -I ens19  -c3 192.168.20.42`

It is now time to make sure that DNS resolution is working correctly. Remember, DNS functions as a translation between the human-readable name (rockylinux.org) and the assigned IP address. If the `/etc/resolv.conf` file indicates a reachable DNS server, then the following should work:

	`host rockylinux.org`

Result:

	`rockylinux.org has address 76.76.21.21`

# Conclusion

This document is meant to help you get a machine up and running on your network. It shows you how to do this, both through the modification of configuration files, and with standard command line tools. 

