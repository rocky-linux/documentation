# Rocky Linux - Networking configuration

## Prerequisites

* A certain amount of comfort operating from the command line
* Optional: familiarity with networking concepts

# Introduction

Nowadays a computer is almost useless by itself. Whether it is you need to update the packages set on a server or browser the Web on your laptop, you will need a network access.
This guide aims at providing Rocky Linux users the basic knowledge on how to setup network connectivity on Rocky Linux.

## Using NetworkManager service

At the user level, the networking stack is managed by *NetworkManager*. This tool is running as a service, you can check its state with the following command:

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

#### IP address

Here there is no dynamic IP address attribution (known as DHCP)as the `BOOTPROTO` parameter is set to `none`. To enable it, set it to `dhcp`.
To configure a static IP address attribution, set the following:

* IPADDR: the IP address to assign the interface
* PREFIX: the subnet mask in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)
* GATEWAY: the default gateway

#### DNS resolution

To get proper name resolution, the following parameters must be set:

* DNS1: IP address of the main nameserver
* DNS2: the secondary nameserver IP address

NetworkManager will use the nameservers configuration and will populate `/etc/resolv.conf` with it.

### Apply configuration

To apply the network configuration, the `nmcli` command can be used:

    nmcli connection up ens18

To get the connection state, simply use:

    nmcli connection show

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

**Pro tip:** use the `-c` flag to get a more readable coloured output: `ip -c a`.