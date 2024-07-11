---
title: Unbound Recursive DNS
author: Neel Chauhan
contributors:
tested_with: 9.4
tags:
  - dns
---

An alternative to BIND, [Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) is a modern validating, recursive and caching DNS server maintained by [NLnet Labs](https://www.nlnetlabs.nl/).

## Prerequisites and assumptions

- A server running Rocky Linux
- Able to use `firewalld` for creating firewall rules

## Introduction

There are two types of DNS servers: authoritative and recursive. Whereas authoritative DNS servers advertise a DNS zone, recursive servers resolve queries on behalf of clients by forwarding them to an ISP or public DNS resolver, or the root zones for larger servers.

As an example, your home router is likely running an embedded recursive DNS resolver to forward to your ISP or a well-known public DNS server which is also a recursive DNS server.

## Installing and enabling Unbound

Install Unbound:

```bash
dnf install unbound
```

## Configuring Unbound

Before making changes to any configuration file, move the original installed working file, `unbound.conf`:

```bash
cp /etc/unbound/unbound.conf /etc/unbound/unbound.conf.orig
```

That will help in the future if the introduction of errors into the configuration file occurs. It is *always* a good idea to make a backup copy before making changes.

Edit the *unbound.conf* file. The author uses *vi*, but you can substitute your favorite command line editor:

```bash
vi /etc/unbound/unbound.conf
```

Insert the following:

```bash
server:
    interface: 0.0.0.0
    interface: ::
    access-control: 192.168.0.0/16 allow
    access-control: 2001:db8::/64 allow

forward-zone:
    name: "."
    forward-addr: 1.0.0.1@53
    forward-addr: 1.1.1.1@53
```

Replace `192.168.0.0/16` and `2001:db8::/64` with the subnets you are resolving DNS queries for. Save your changes.

### Taking a closer look

- The `interface` denotes the interfaces (IPv4 or IPv6) you want to listen for DNS queries on. We are listening on all interfaces with `0.0.0.0` and `::`.
- The `access-control` denotes which subnets (IPv4 or IPv6) you want to allow DNS queries from. We are allowing requests from `192.168.0.0/16` and `2001:db8::/64`.
- The `forward-addr` defines the servers we will forward to. We are forwarding to CloudFlare's 1.1.1.1.

## Enabling Unbound

Next, allow DNS ports in `firewalld` and enable Unbound:

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now unbound
```

Check DNS resolution with the `host` command:

```bash
$ host google.com 172.20.0.100
Using domain server:
Name: 192.168.50.209
Address: 192.168.50.209#53
Aliases: 

google.com has address 142.251.215.238
google.com has IPv6 address 2607:f8b0:400a:805::200e
google.com mail is handled by 10 smtp.google.com.
```

%
## Conclusion
Most people use their home router's DNS resolver or public DNS resolvers run by ISPs and tech companies. In homelab and large networks it is a norm to run a network-wide resolver to reduce latency and network load by caching DNS requests for commonly-requested websites such as Google. A network-wide resolver also enables intranet services such as SharePoint and Active Directory.

Unbound is one of many open source tools that make resolving DNS possible. Congratulations, you have your very own DNS resolver! Cheers!
