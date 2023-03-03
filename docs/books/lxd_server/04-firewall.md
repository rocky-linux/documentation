---
title: 4 Firewall Setup
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd security
---

# Chapter 4: Firewall Setup

Throughout this chapter you will need to be root or able to `sudo` to become root.

As with any server, you need to make sure that it is secured from the outside world and on your LAN. While our example server only has a LAN interface, it is totally possible to have two interfaces, one each facing your LAN and WAN networks. While we cover `iptables` rules in this procedure, we **highly** recommend using the `firewalld` procedure instead (see the note below). 

## Firewall Set Up - iptables

!!! note "A note regarding Rocky Linux 9.0"

    Starting with Rocky Linux 9.0, `iptables` and all of the associated utilities are officially deprecated. This means that in future versions of the OS, perhaps as early as 9.1, they will disappear altogether. For this reason, you should skip down to the `firewalld` procedure below before continuing.

    It's actually a good idea to use `firewalld` for Rocky Linux 8.6 as well, but we *do* offer you the option of using `iptables` if you really want it.

Before continuing, you will want a firewall set up on your server. This example is using _iptables_ and [this procedure](../../guides/security/enabling_iptables_firewall.md) to disable _firewalld_. If you prefer to use _firewalld_, simply substitute in _firewalld_ rules using the instructions below this section.

Create your firewall.conf script:

```
vi /etc/firewall.conf
```

We are assuming an LXD server on a LAN network of 192.168.1.0/24 below. Note, too, that we are accepting all traffic from our bridged interface. This is important if you want your containers to get IP addresses from the bridge.

This firewall script makes no other assumptions about the network services needed. There is an SSH rule to allow our LAN network IP's to SSH into the server. You can very easily have many more rules needed here, depending on your environment. Later, we will be adding a rule for bi-directional traffic between our production server and the snapshot server.

```
#!/bin/sh
#
#IPTABLES=/usr/sbin/iptables

#  Unless specified, the defaults for OUTPUT is ACCEPT
#    The default for FORWARD and INPUT is DROP
#
echo "   clearing any existing rules and setting default policy.."
iptables -F INPUT
iptables -P INPUT DROP
iptables -A INPUT -i lxdbr0 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```

## Firewall Set Up - firewalld

For _firewalld_ rules, we need to use [this basic procedure](../../guides/security/firewalld.md) or be familiar with those concepts. Our assumptions are the same as with the _iptables_ rules above: LAN network of 192.168.1.0/24 and a bridge named lxdbr0. To be clear, you might have multiple interfaces on your LXD server, with one perhaps facing your WAN as well. We are also going to create a zone for the bridged and local networks. This is just for zone clarity sake, as the other names do not really apply. The below assumes that you already know the basics of _firewalld_.

```
firewall-cmd --new-zone=bridge --permanent
```

You need to reload the firewall after adding a zone:

```
firewall-cmd --reload
```

We want to allow all traffic from the bridge, so let's just add the interface, and then change the target from "default" to "ACCEPT" and we will be done:

!!! warning

    Changing the target of a firewalld zone *must* be done with the --permanent option, so we might as well just enter that flag in our other commands as well and forgo the --runtime-to-permanent option.

!!! Note

    If you need to create a zone that you want to allow all access to the interface or source, but do not want to have to specify any protocols or services, then you *must* change the target from "default" to ACCEPT. The same is true of DROP and REJECT for a particular IP block that you have custom zones for. To be clear, the "drop" zone will take care of that for you as long as you aren't using a custom zone.

```
firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
```
Assuming no errors and everything is still working just do a reload:

```
firewall-cmd --reload
```
If you list out your rules now with `firewall-cmd --zone=bridge --list-all` you should see something like the following:

```
bridge (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: lxdbr0
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
Note from the _iptables_ rules, that we also want to allow our local interface. Again, I do not like the included zones for this, so create a new zone and use the source IP range for the local interface to make sure you have access:

```
firewall-cmd --new-zone=local --permanent
firewall-cmd --reload
```
Then we just need to add the source IP's for the local interface, change the target to "ACCEPT" and we are done with this as well:

```
firewall-cmd --zone=local --add-source=127.0.0.1/8 --permanent
firewall-cmd --zone=local --set-target=ACCEPT --permanent
firewall-cmd --reload
```
Go ahead and list out the "local" zone to make sure your rules are there with `firewall-cmd --zone=local --list all` which should show you something like this:

```
local (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 127.0.0.1/8
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Next we want to allow SSH from our trusted network. We will use the source IP's here, just like in our _iptables_ example, and the built-in "trusted" zone. The target for this zone is already "ACCEPT" by default.

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24
```
Then add the service to the zone:

```
firewall-cmd --zone=trusted --add-service=ssh
```
And if everything is working, move your rules to permanent and reload the rules:

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```
Listing out your "trusted" zone should now show you something like this:

```
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

By default, the "public" zone is enabled and has SSH allowed. We don't want this. Make sure that your zones are correct and that the access you are getting to the server is via one of the LAN IP's (in the case of our example) and is allowed to SSH. You could lock yourself out of the server if you don't verify this before continuing. Once you've made sure you have access from the correct interface, remove SSH from the "public" zone:

```
firewall-cmd --zone=public --remove-service=ssh
```

Test access and make sure you aren't locked out. If not, then move your rules to permanent, reload, and list out zone "public" to be sure that SSH is removed:

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

There may be other interfaces on your server to consider. You can use built-in zones where appropriate, but if you don't like the names (they don't appear logical, etc.), you can definitely add zones. Just remember that if you have no services or protocols that you need to allow or reject specifically, then you will need to modify the zone target. If it works to use interfaces, as we've done with the bridge, you can do that. If you need more granular access to services, uses source IP's instead.
