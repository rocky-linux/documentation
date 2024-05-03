---
title: accel-ppp PPPoE Server
author: Neel Chauhan
contributors:
tested_with: 9.3
tags:
  - network
---

# accel-ppp PPPoE Server

## Introduction

PPPoE is a protocol used primarily by DSL and fiber-to-the-home ISPs where customers are authenticated with a username and password combo. PPPoE is used in countries where an incumbent ISP is required to share their network with other ISPs as customers can be routed via a domain name to the desired ISP.

[accel-ppp](https://accel-ppp.org/) is a Linux kernel-accelerated implementation of PPPoE and related protocols such as PPTP, L2TP, and others.

## Prerequisites

- A server with two network interfaces
- A client router or machine speaking PPPoE

## Installing accel-ppp

As accel-ppp is not in the default Rocky or EPEL repositories, we first install the required packages to build it:

```bash
dnf install -y rpm-build make cmake gcc git openssl-devel pcre-devel kernel-modules-extra
```

Subsequently, clone the accel-ppp source code to a folder:

```bash
git clone https://github.com/accel-ppp/accel-ppp.git /opt/accel-ppp
mkdir /opt/accel-ppp/build
cd /opt/accel-ppp/build/
```

Next, we need to build accel-ppp (Note: If you're running Rocky Linux 8.x substitute in `Centos8` for `Centos9`):

```bash
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCPACK_TYPE=Centos9 ..
make
```

Finally, we will build an `rpm` package and install it:

```bash
cpack -G RPM
rpm -ivh accel-ppp.rpm
```

## Setting up accel-ppp

First, we need to enable IP forwarding:

```bash
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
```

Then, add the following to `/etc/accel-ppp.conf`:

```bash
[modules]
log_file
pppoe
auth_mschap_v2
auth_mschap_v1
auth_chap_md5
auth_pap
chap-secrets
ippool

[core]
log-error=/var/log/accel-ppp/core.log
thread-count=4

[ppp]
ipv4=require

[pppoe]
interface=YOUR_INTERFACE

[dns]
dns1=YOUR_DNS1
dns2=YOUR_DNS2

[ip-pool]
gw-ip-address=YOUR_GW
YOUR_IP_RANGE

[chap-secrets]
gw-ip-address=YOUR_GW
chap-secrets=/etc/chap-secrets
```

Replace the following information:

- **YOUR_INTERFACE** with the interface listening for PPPoE clients.
- **YOUR_DNS1** and **YOUR_DNS2** with the DNS servers to hand out to clients.
- **YOUR_GW** is the server's IP address for PPPoE clients. This **must** be different from the server's WAN-facing IP address or default gateway.
- **YOUR_IP_RANGE** with the IP ranges to hand out to clients. This can be an IP range like X.X.X.Y-Z or in CDIR format such as X.X.X.X/MASK.

Subsequently, let us add a barebones `/etc/chap-secrets` file:

```bash
user	*	password	*
```

You can add more users with additional lines by replacing `user` and `password` with the desired username and password.

## Configuring a PPPoE client

Once the PPPoE server is set up, we can start adding PPPoE clients. The author likes to use [MikroTik CHR](https://help.mikrotik.com/docs/display/ROS/Cloud+Hosted+Router%2C+CHR) as their go-to testing PPPoE client so we will use that.

Once we installed MikroTik CHR onto a system connected to the same Ethernet network as the PPPoE server's listening interface, we will configure PPPoE:

```bash
[admin@MikroTik] > /interface pppoe-client
[admin@MikroTik] > add add-default-route=yes disabled=no interface=ether1 name=pppoe-out1 \
    password=password user=user
```

If everything is working properly we should get an IPv4 address:

```bash
[admin@MikroTik] > /ip/address/print
Flags: D - DYNAMIC
Columns: ADDRESS, NETWORK, INTERFACE
#   ADDRESS      NETWORK   INTERFACE 
0 D 10.0.0.1/32  10.0.0.0  pppoe-out1
```

## Conclusion

PPPoE often gets a bad rap and it's easy to see why: you need to configure usernames and passwords manually. Despite that, it allows for security when connecting to a Layer 2 broadcast domain in ISP scenarios where requiring 802.1X or MACsec would be undesirable, for instance to allow customer-owned routers or static IP addresses. And now you are your own mini-ISP, congratulations!
