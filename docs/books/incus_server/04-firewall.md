---
title: 4 Firewall Setup
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus 
  - enterprise
  - incus security
---

Throughout this chapter, you must be root or able to `sudo` to become root.

As with any server, you must ensure it is secure from the outside world and on your LAN. Your example server only has a LAN interface, but it is possible to have two interfaces, each facing your LAN and WAN networks.  

## Firewall set up - `firewalld`

For _firewalld_ rules, you need to use [this basic procedure](../../guides/security/firewalld.md) or be familiar with those concepts. The assumptions are a LAN network of 192.168.1.0/24 and a bridge named incusbr0. To be clear, you may have many interfaces on your Incus server, with one facing your WAN. You will also create a zone for the bridged and local networks. This is just for zone clarity's sake. The other zone names do not apply. This procedure assumes that you already know the basics of _firewalld_.

```bash
firewall-cmd --new-zone=bridge --permanent
```

You need to reload the firewall after adding a zone:

```bash
firewall-cmd --reload
```

You want to allow all traffic from the bridge. Just add the interface and change the target from "default" to "ACCEPT":

!!! warning

    Changing the target of a `firewall' zone *must* be done with the `--permanent` option, so we might as well enter that flag in our other commands and forgo the `--runtime-to-permanent` option.

!!! Note

    If you need to create a zone where you want to allow all access to the interface or source but do not want to have to specify any protocols or services, then you *must* change the target from "default" to "ACCEPT". The same is true of "DROP" and "REJECT" for a particular IP block for which you have custom zones. The "drop" zone will take care of that for you as long as you are not using a custom zone.

```bash
firewall-cmd --zone=bridge --add-interface=incusbr0 --permanent
firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
```

Assuming no errors and everything is still working do a reload:

```bash
firewall-cmd --reload
```

If you list out your rules now with `firewall-cmd --zone=bridge --list-all` you will see:

```bash
bridge (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: incusbr0
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

```bash
firewall-cmd --new-zone=local --permanent
firewall-cmd --reload
```

Add the source IPs for the local interface, and change the target to "ACCEPT":

```bash
firewall-cmd --zone=local --add-source=127.0.0.1/8 --permanent
firewall-cmd --zone=local --set-target=ACCEPT --permanent
firewall-cmd --reload
```

Go ahead and list out the "local" zone to ensure your rules are there with `firewall-cmd --zone=local --list all` which will show:

```bash
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

You want to allow SSH from our trusted network. To do this, allow the source IPs to use the built-in "trusted" zone. By default, this zone's target is " ACCEPT."

```bash
firewall-cmd --zone=trusted --add-source=192.168.1.0/24
```

Add the service to the zone:

```bash
firewall-cmd --zone=trusted --add-service=ssh
```

If everything is working, move your rules to permanent and reload the rules:

```bash
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```

Listing out your "trusted" zone will show:

```bash
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

The "public" zone is enabled by default, and SSH is allowed. For security, you do not want SSH allowed on the "public" zone. Ensure that your zones are correct and that the access you are getting to the server is by one of the LAN IPs (in the case of our example). You might lock yourself out of the server if you do not verify this before continuing. When you are sure you have access from the correct interface, remove SSH from the "public" zone:

```bash
firewall-cmd --zone=public --remove-service=ssh
```

Test access and ensure you are not locked out. If not, move your rules to permanent, reload, and list out zone "public" to ensure the removal of SSH:

```bash
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```

There may be other interfaces on your server that need to be considered. You can use built-in zones where appropriate, but if the names don't seem good enough, you can add zones. Just remember that if you have no services or protocols that you need to allow or reject specifically, you will need to change the zone target. You can do that if it works to use interfaces, as with the bridge. If you need more granular access to services, use source IPs instead.
