---
title: Tailscale VPN
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.3
tags:
  - security
  - vpn
---

# Tailscale VPN

## Introduction

[Tailscale](https://tailscale.com/) is a zero-config, end-to-end encrypted, peer-to-peer VPN based on Wireguard. Tailscale supports all major desktop and mobile operating systems.

Compared to other VPN solutions, Tailscale does not require open TCP/IP ports and can work behind Network Address Translation or a firewall.

## Prerequisites and assumptions

The following are minimum requirements for using this procedure:

* The ability to run commands as the root user or use `sudo` to elevate privileges
* A Tailscale account

## Installing Tailscale

To install Tailscale, we first need to add its `dnf` repository (note: if you are using Rocky Linux 8.x, substitute in 8):

```bash
dnf config-manager --add-repo https://pkgs.tailscale.com/stable/rhel/9/tailscale.repo
```

Then install Tailscale:

```bash
dnf install tailscale
```

## Configuring Tailscale

With the packages installed, you need to enable and configure Tailscale. To enable the Tailscale daemon:

```bash
systemctl enable --now tailscaled
```

Subsequently, you will authenticate with Tailscale:

```bash
tailscale up
```

You will get a URL for authentication. Visit that in a browser and log into Tailscale:

![Tailscale login screen](../images/tailscale_1.png)

Next, you will grant access to your server. Click **Connect** to do so:

![Tailscale grant access dialog](../images/tailscale_2.png)

When you've granted access, you will see a success dialog:

![Tailscale login successful dialog](../images/tailscale_3.png)

Once your server is authenticated with Tailscale, it will get a Tailscale IPv4 address:

```bash
tailscale ip -4
```

It will also get an RFC 4193 (Unique Local Address) Tailscale IPv6 address:

```bash
tailscale ip -6
```

## Conclusion

Traditional VPN services using a VPN gateway are centralized. This requires manual configuration, setting up your firewall and giving user accounts. Tailscale solves this problem by its peer-to-peer model combined with network-level access control.
