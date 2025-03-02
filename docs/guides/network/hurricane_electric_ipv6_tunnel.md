---
title: Hurricane Electric IPv6 Tunnel
author: Neel Chauhan
contributors:
tested_with: 9.5
tags:
  - network
---

# Hurricane Electric IPv6 Tunnel

IPv6 needs no introduction, but in case you aren't aware, IPv6 is the replacement for the more-popular IPv4 protocol which uses 128-bit hexadecimal addresses inatead of 32-bit decimal ones.

[Hurricane Electric](https://he.net) is an internet service provider which runs the free [Tunnel Broker](https://tunnelbroker.net/) service to give IPv6 connectivity behind IPv4-only networks, among other things.

## Introduction

Thanks to the IPv4

## Prerequisites

- A [free Hurricane Electric IPv6 tunnel](https://tunnelbroker.net/)

- A Rocky Linux server with a public IP address and non-filtered ICMP

## Getting an IPv6 Tunnel

First, create an account at [tunnelbroker.net](https://tunnelbroker.net/).

When you have an account, select **Create Regular Tunnel** in the **User Functions** sidebar:

![HE.net sidebar](../images/henet_1.png)

Then enter in your public IPv4 address, choose your endpoint location and click **Create Tunnel**.

## Setting up the IPv6 Tunnel

The good news is that an IPv6 tunnel only needs one command:

```bash
nmcli connect add type ip-tunnel ifname he-sit mode sit remote IPV4_SERVER ipv4.method disabled ipv6.method manual ipv6.address IPV6_CLIENT ipv6.gateway IPV6_SERVER
```

Replace the following with the details from your Hurricane Electric portal:

- `IPV4_SERVER` with the **Server IPv4 Address**
- `IPV6_SERVER` with the **Server IPv6 Address**
- `IPV6_CLIENT` with the **Client IPv6 Address**
