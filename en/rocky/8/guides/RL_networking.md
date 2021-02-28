# Rocky Linux - Networking configuration

## Prerequisites

* A certain amount of comfort operating from the command line
* Optional: familiarity with networking concepts

# Introduction

Nowadays a computer is almost useless by itself. Whether it is you need to update the packages set on a server or browser the Web on your laptop, you will need a network access.
This guide aims at providing Rocky Linux users the basic knowledge on how to setup network connectivity on Rocky Linux.

## Network service

At the user level, the networking stack is managed by *NetworkManager*. This tool is running as a service, you can check its state with the following command:

	systemctl status NetworkManager

## Configuration files

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
	IPADDR=192.168.42.238
	PREFIX=24
	GATEWAY=192.168.42.254
	DNS1=192.168.42.254
	DNS2=1.1.1.1
	IPV6_DISABLED=yes
