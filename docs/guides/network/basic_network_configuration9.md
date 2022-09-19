---
title: Networking Configuration - Rocky Linux 9.0
author: unknown
contributors: Steven Spencer, Hayden Young
tested with: 9.0 
tags:
  - networking
  - configuration
  - network
---

# Networking Configuration - Rocky Linux 9.0

A lot has changed with network configuration as of Rocky Linux 9.0. One of the major changes is the move from Network-Scripts (still available to install-but effectively deprecated) to the use of Network Manager and key files, rather than `ifcfg` based files. `NetworManager` as of 9.0, prioritizes `keyfiles` over the previous `ifcfg` files. Since this is now the default, the act of configuring the network should now take the default as the proper way of doing things, given that other changes over the years have meant the eventual deprecation and removal of older utilities. This guide will attempt to walk you through the use of Network Manager and the latest changes within Rocky Linux 9.0. 

## Prerequisites

* A certain amount of comfort operating from the command line
* Elevated or administrative privileges on the system (For example root, `sudo` and so on)
* Optional: familiarity with networking concepts

## Using NetworkManager service

At the user level, the networking stack is managed by `NetworkManager`. This tool runs as a service, and you can check its state with the following command:

```bash
systemctl status NetworkManager
```

### Configuration files

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

    The dynamic IP approach is popular on home and office networks or workstation and desktop class systems in a business environment.  The dynamic scheme usually needs _something_ extra that is locally available that can supply proper IP configuration information to requesting workstations and desktops. This _something_ is called the Dynamic Host Configuration Protocol (DHCP). On a home network, and even on most business networks, this service is provided by a DHCP Server configured for the purpose. This can be a separate server, or can be part of a router configuration.

#### IP Address

In the previous section, the displayed configuration for the interface `enp0s3` is generated from the `.ini` file  `/etc/NetworkManager/system-connections/enp0s3.nmconnection`. This shows that the IP4.ADDRESS[1] has been statically configured, rather than dynamically configured via DHCP. If we want to switch this interface back to to a dynamically allocated address, the easiest way is to use the `nmtui` command. 

1. First, run the `nmtui` command at the command-line which should show you the following
![nmtui](images/nmtui_initial.png)
2. It's already on the selection we need "Edit a connection" so hit the <kbd>TAB</kbd> key so that "OK" is highlighted and hit <kbd>ENTER</kbd>
3. This will bring up a screen showing the Ethernet connections on the machine and allow you to choose one. In our case, there is *ONLY* one, so it is already highlighted, we simply need to hit the <kbd>TAB</kbd> key until "Edit" is highlighted and then hit <kbd>ENTER</kbd>
![nmtui_edit](images/nmtui_edit.png)
4. Once we've done this, we will be to the screen that shows our current configuration. What we need to do is switch from "Manual" to "Automatic" so hit the <kbd>TAB</kbd> key several times until you get to where "Manual" is highlighted and then hit <kbd>ENTER</kbd>.
![nmtui_manaual](images/nmtui_manual.png)
5. Arrow up until "Automatic" is highlighted and then hit <kbd>ENTER</kbd>
![nmtui_automatic](images/nmtui_automatic.png)
6. Once we have switched the interface over to "Automatic" we need to remove the statically assigned IP so hit the <kbd>TAB</kbd> key unti lthe "Remove" is highlighted next to the IP address and hit <kbd>ENTER</kbd>
![nmtui_remove](images/nmtui_remove.png)
7. Finally, hit the <kbd>TAB</kbd> key several times until you get to the bottom of the `nmtui` screen and the "OK" is highlighted and hit <kbd>ENTER</kbd>



To verify that it worked, go ahead and check using either the `ip addr` command, or the the `nmcli device show enp0s3` command that we used earlier.

```
ip addr
```

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
