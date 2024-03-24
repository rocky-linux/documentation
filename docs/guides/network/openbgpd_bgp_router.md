---
title: OpenBGPD BGP Router
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.3
tags:
  - network
---

# OpenBGPD BGP Router

## Introduction

Border Gateway Protocol (BGP) should be self-explanatory, if you are unaware, BGP is the routing protocol that holds the internet together. It's how your can view this document regardless of who your Internet Service Provider is.

[OpenBGPD](http://openbgpd.org/) is [OpenBSD's](https://www.openbsd.org/) cross-platform BGP implementation. The author uses it personally on their personal network.

## Prerequisites

* A server, virtual machine or lab network with BGP connectivity
* An AS number from your [Regional Internet Registry](https://www.nro.net/about/rirs/)
* An owned or leased IPv4 or IPv6 block
* An intermediate knowledge of network administration

## Installing packages

As OpenBGPD is not in the default repositories, first install the EPEL repository (Extra Packages for Enterprise Linux):

```bash
dnf install -y epel-release
```

Subsequently, install OpenBGPD

```bash
dnf install -y openbgpd
```

## Setting up OpenBGPD

Let's start with a fresh OpenBGPD configuration:

```bash
rm /etc/bgpd.conf
touch /etc/bgpd.conf
chmod 0600 /etc/bgpd.conf
```

Subsequently, add the following to `/etc/bgpd.conf`:

```bash
AS YOUR_ASN
router-id YOUR_IPV4

listen on 127.0.0.1
listen on YOUR_IPV4
listen on ::1
listen on YOUR_IPV6
log updates
network IPV4_TO_ADVERTISE/MASK
network IPV6_TO_ADVERTISE/MASK

allow to ebgp prefix { IPV4_TO_ADVERTISE/MASK IPV6_TO_ADVERTISE/MASK }

neighbor PEER_IPV4 {
    remote-as               PEER_ASN
    announce IPv4           unicast
    announce IPv6           none
    local-address           YOUR_IPV4
}

neighbor PEER_IPV6 {
    remote-as               PEER_ASN
    announce IPv4           none
    announce IPv6           unicast
    local-address           YOUR_IPV6
}
```

Replace the following information:

* **YOUR_ASN** with your AS number.
* **YOUR_IPV4** with your server's IPv4 address.
* **YOUR_IPV6** with your server's IPv6 address.
* **PEER_ASN** with your upstream ISP's AS number.
* **PEER_IPV4** with your upstream ISP's IPv4 address.
* **PEER_IPV6** with your upstream ISP's IPv6 address.

The above lines mean the following:

* The `AS` line contains your BGP AS number.
* The `router-id` line contains your BGP router ID. This is an IPv4 address, but can be a dummy value if you are doing IPv6-only BGP.
* The `listen on` line tells which interfaces to listen to. We should listen on all interfaces speaking BGP.
* The `network` lines add the networks we want to advertise.
* The `allow to ebgp prefix` line adds [RFC8212](https://datatracker.ietf.org/doc/html/rfc8212) compliance for routing security. This is required by some hosting companies such as BuyVM.
* The `neighbor` blocks specify each IPv4 and IPv6 peer.
* The `remote-as` line specifies the upstream's AS number.
* The `announce IPv4` line specifies whether we should announce `unicast` IPv4 routes or `none`. This should be `none` on an IPv6 upstream.
* The `announce IPv6` line specifies whether we should announce `unicast` IPv6 routes or `none`. This should be `none` on an IPv4 upstream.
* The `local-address` line is the upstream's IPv4 or IPv6 address.

Some upstreams may use an MD5 password or BGP multihop. Should that be the case, your `neighbor` blocks will look like this:

```bash
neighbor PEER_IPV4 {
    remote-as               PEER_ASN
    announce IPv4           unicast
    announce IPv6           none
    local-address           YOUR_IPV4
    multihop                2
    local-address           203.0.113.123
}

neighbor PEER_IPV6 {
    remote-as               PEER_ASN
    announce IPv4           none
    announce IPv6           unicast
    local-address           YOUR_IPV6
    multihop                2
    local-address           2001:DB8:1000::1
}
```

You will need to enable IP forwarding by setting these `sysctl` values:

```bash
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

Now, we should enable OpenBGPD and forwarding:

```bash
sysctl -p /etc/sysctl.conf
systemctl enable --now bgpd
```

## Checking BGP status

Once OpenBGPD is enabled, you can see the BGP status:

```bash
bgpctl show
```

You will see the output"

```bash
Neighbor                   AS    MsgRcvd    MsgSent  OutQ Up/Down  State/PrfRcvd
BGP_PEER             PEER_ASN       164         68     0 00:32:04      0
```

You can also see the BGP advertised routes:

```bash
bgpctl show rib
```

You should see an output like this:

```bash
flags: * = Valid, > = Selected, I = via IBGP, A = Announced,
       S = Stale, E = Error
origin validation state: N = not-found, V = valid, ! = invalid
aspa validation state: ? = unknown, V = valid, ! = invalid
origin: i = IGP, e = EGP, ? = Incomplete

flags  vs destination          gateway          lpref   med aspath origin
AI*>  N-? YOUR_IPV4/24         0.0.0.0           100     0 i
AI*>  N-? YOUR_IPV6::/48       ::                100     0 i
```

## Conclusion

While BGP may seem taunting at first, once you get the hang of it, you can get your own piece of the internet routing table. OpenBGPD's simplicity makes it even easier to have a software router or anycast server. Enjoy!
