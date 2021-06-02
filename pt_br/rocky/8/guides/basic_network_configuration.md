# Rocky Linux - Networking configuration

## Prerequisites

* A certain amount of comfort operating from the command line
* Elevated or administrative privileges on the system (For example root, sudo and so on)
* Optional: familiarity with networking concepts

# Introduction

Nowadays a computer without network connectivity is almost useless by itself. Whether you need to update the packages on a server or simply browse external Websites from your laptop - you will need network access!

This guide aims to provide Rocky Linux users the basic knowledge on how to setup network connectivity on a Rocky Linux system.

## Using NetworkManager service

At the user level, the networking stack is managed by *NetworkManager*. This tool runs as a service, and you can check its state with the following command:

	systemctl status NetworkManager

### Configuration files

NetworkManager simply applies a configuration read from the files found in `/etc/sysconfig/network-scripts/ifcfg-<IFACE_NAME>`.
Each network interface has its configuration file. The following example in the default configuration for a server:

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

The interface's name is **ens18** so this file's name will be `/etc/sysconfig/network-scripts/ifcfg-ens18`.

**Tips:**  
There are a few ways or mechanisms by which systems can be assigned their IP configuration information. The 2 most common methods are - **Static IP configuration** scheme and **Dynamic IP configuration** scheme.

The static IP configuration scheme is very popular on server class systems or networks.

The dynamic IP approach is popular on home and office networks - or workstation and desktop class systems.  The dynamic scheme usually needs _something_ extra that is locally available that can supply proper IP configuration information to requesting workstations and desktops. This _something_ is called the Dynamic Host Configuration Protocol (DHCP). 

Very often, home/office users don't have to worry or know about DHCP. This is because the somebody or something else is automagically taking care of that in the background. The only thing that the end user needs to do is to physically or wirelessly connect to the right network (and of course make sure that their systems are powered on)!

#### IP Address

In the previous `/etc/sysconfig/network-scripts/ifcfg-ens18` listing, we see that the value of the `BOOTPROTO` parameter or key is set to `none`. This means that the system being configured is set to a static IP address scheme. 

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


### Apply configuration

To apply the network configuration, the `nmcli` command can be used:

    nmcli connection up ens18

To get the connection state, simply use:

    nmcli connection show

You can also use the `ifup` and `ifdown` commands to bring the interface up and down (they are simple wrappers around `nmcli`):

	ifup ens18
	ifdown ens18

### Checking configuration

You can check that the configuration has been correctly applied with the following `nmcli` command:

	nmcli device show ens18

which should give you the following output:

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

## Using ip utility

The `ip` command (provided by the *iproute2* package) is a powerful tool to get information and configure the network of a modern Linux system such as Rocky Linux.

In this example, we will assume the following parameters:

* interface name: ens19
* ip address: 192.168.20.10
* subnet mask: 24
* gateway: 192.168.20.254

### Get general information

To see the detailed state of all interfaces, use

	ip a 

**Pro tips:**
* use the `-c` flag to get a more readable coloured output: `ip -c a`.
* `ip` accepts abbreviation so `ip a`, `ip addr` and `ip address` are equivalent

### Bring interface up or down

To bring the *ens19* interface up, simply use `ip link set ens19 up` and to bring it down, use `ip link set ens19 down`.

### Assign the interface a static address

The command to be used is of the form:

	ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>

To assign the above example parameters, we will use:

	ip a add 192.168.20.10/24 dev ens19

Then, checking the result with:

	ip a show dev ens19

will output:

	3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
		link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
		inet 192.168.20.10/24 scope global ens19
		valid_lft forever preferred_lft forever

Our interface is up and configured, but is still lacking something!

### Using ifcfg utility

To add the *ens19* interface our new example IP address, use the following command:

	ifcfg ens19 add 192.168.20.10/24

To remove the address:

	ifcfg ens19 del 192.168.20.10/24

To completely disable IP addressing on this interface:

	ifcfg ens19 stop

*Note that this does not bring the interface down, it simply unassigns all IP addresses from the interface.*

### Gateway configuration

Now that the interface has an address, we have to set its default route, this can be done with:

	ip route add default via 192.168.20.254 dev ens19

The kernel routing table can be displayed with

	ip route

or `ip r` for short.

## Checking network connectivity

At this point, you should have your network interface up and properly configured. There are several ways to verify your connectivity.

By *pinging* another IP address in the same network (we will use `192.168.20.42` as an example):

	ping -c3 192.168.20.42

This command will issue 3 *pings* (known as ICMP request) and wait for a reply. If everything went fine, you should get this output:

	PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
	64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
	64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
	64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms

	--- 192.168.20.42 ping statistics ---
	3 packets transmitted, 3 received, 0% packet loss, time 5ms
	rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms

Then, to make sure your routing configuration is fine, try to *ping* a external host, such as this well known public DNS resolver:

	ping -c3 8.8.8.8

If your machine has several network interface and you want to make ICMP request via a specific interface, you can use the `-I` flag:

	ping -I ens19  -c3 192.168.20.42

It is now time to make sure that DNS resolution is working correctly. As a reminder, DNS resolution is a mechanism used to convert human friendly machine names into their IP addresses and the other way round (reverse DNS).

If the `/etc/resolv.conf` file indicates a reachable DNS server, then the following should work:

	host rockylinux.org

The result should be:

	rockylinux.org has address 76.76.21.21

