---
title: 4 Firewall Setup
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd security
---

# Chapter 4: firewall setup

Throughout this chapter you will need to be root or able to `sudo` to become root.

As with any server, you need to ensure that it is secure from the outside world and on your LAN. Your example server only has a LAN interface, but it is totally possible to have two interfaces, one each facing your LAN and WAN networks.  

!!! warning "A note regarding Rocky Linux 9.x and `iptables`"

    Starting with Rocky Linux 9.0, `iptables` and all of the associated utilities are officially deprecated. This means that in future versions of the operating system, they will disappear altogether. A previous version of this document contained instructions for `iptables` set up, but it has now been removed. 

    For all current versions of Rocky Linux, using `firewalld` is recommended.

## Firewall set up - `firewalld`

For _firewalld_ rules, you need to use [this basic procedure](../../guides/security/firewalld.md) or be familiar with those concepts. Our assumptions are: LAN network of 192.168.1.0/24 and a bridge named lxdbr0. To be clear, you might have many interfaces on your LXD server, with one perhaps facing your WAN. You are also going to create a zone for the bridged and local networks. This is just for zone clarity's sake. The other zone names do not really apply. This procedure assumes that you already know the basics of _firewalld_.

```
firewall-cmd --new-zone=bridge --permanent
```

You need to reload the firewall after adding a zone:

```
firewall-cmd --reload
```

You want to allow all traffic from the bridge. Just add the interface, and change the target from "default" to "ACCEPT":

!!! warning

    Changing the target of  a `firewalld` zone *must* be done with the `--permanent` option, so we might as well just enter that flag in our other commands as well and forgo the `--runtime-to-permanent` option.

!!! Note

    If you need to create a zone that you want to allow all access to the interface or source, but do not want to have to specify any protocols or services, then you *must* change the target from "default" to "ACCEPT". The same is true of "DROP" and "REJECT" for a particular IP block that you have custom zones for. To be clear, the "drop" zone will take care of that for you as long as you are not using a custom zone.

```
firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
```
Assuming no errors and everything is still working just do a reload:

```
firewall-cmd --reload
```
If you list out your rules now with `firewall-cmd --zone=bridge --list-all` you will see:

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
Note that you also want to allow your local interface. Again, the included zones are not appropriately named for this. Create a zone and use the source IP range for the local interface to ensure you have access:

```
firewall-cmd --new-zone=local --permanent
firewall-cmd --reload
```
Add the source IPs for the local interface, and change the target to "ACCEPT":

```
firewall-cmd --zone=local --add-source=127.0.0.1/8 --permanent
firewall-cmd --zone=local --set-target=ACCEPT --permanent
firewall-cmd --reload
```
Go ahead and list out the "local" zone to ensure your rules are there with `firewall-cmd --zone=local --list all` which will show:

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

You want to allow SSH from our trusted network. We will use the source IPs here, and the built-in "trusted" zone. The target for this zone is already "ACCEPT" by default.

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24
```
Add the service to the zone:

```
firewall-cmd --zone=trusted --add-service=ssh
```
If everything is working, move your rules to permanent and reload the rules:

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```
Listing out your "trusted" zone will show:

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

By default, the "public" zone is in the enabled state and has SSH allowed. For security, you do not want SSH allowed on the "public" zone. Ensure that your zones are correct and that the access you are getting to the server is by one of the LAN IPs (in the case of our example). You might lock yourself out of the server if you do not verify this before continuing. When you are sure you have access from the correct interface, remove SSH from the "public" zone:

```
firewall-cmd --zone=public --remove-service=ssh
```

Test access and ensure you are not locked out. If not, move your rules to permanent, reload, and list out zone "public" to ensure the removal of SSH:

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

There may be other interfaces on your server to consider. You can use built-in zones where appropriate, but if the names do not appear logical, you can definitely add zones. Just remember that if you have no services or protocols that you need to allow or reject specifically, you will need to change the zone target. If it works to use interfaces, as with the bridge, you can do that. If you need more granular access to services, uses source IPs instead.
