---
title: Knot Authoritative DNS
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - dns
---

An alternative to BIND, [Knot DNS](https://www.knot-dns.cz/) is a modern authoritative-only DNS server maintained by the Czech domain registry [CZ.NIC](https://www.nic.cz/).

## Prerequisites and assumptions

- A server running Rocky Linux
- Able to use *firewalld* for creating firewall rules
- A domain name or internal recursive DNS server pointed to your authoritative DNS server

## Introduction

External, or public, DNS servers map hostnames to IP addresses and, in the case of PTR (known as "pointer" or "reverse") records, map the IP addresses to the hostname. This is an essential part of the Internet. It makes your mail server, web server, FTP server, or many other servers and services work as expected no matter where you are.

## Installing and enabling Knot

First install EPEL:

```bash
dnf install epel-release
```

Next install Knot:

```bash
dnf install knot
```

## Configuring Knot

Before making changes to any configuration file, move the original installed working file, `knot.conf`:

```bash
mv /etc/knot/knot.conf /etc/knot/knot.conf.orig
```

That will help in the future if the introduction of errors into the configuration file occurs. It is *always* a good idea to make a backup copy before making changes.

Edit the *knot.conf* file. The author uses *vi*, but you can substitute your favorite command line editor:

```bash
vi /etc/knot/knot.conf
```

Insert the following:

```bash
server:
    listen: 0.0.0.0@53
    listen: ::@53

zone:
  - domain: example.com
    storage: /var/lib/knot/zones
    file: example.com.zone

log:
  - target: syslog
    any: info
```

Replace `example.com` with the domain name you are running a nameserver for.

Next, create the zone files:

```bash
mkdir /var/lib/knot/zones
vi /var/lib/knot/zones/example.com.zone
```

The DNS zone files are BIND compatible. In the file, insert:

```bash
$TTL    86400 ; How long should records last?
; $TTL used for all RRs without explicit TTL value
$ORIGIN example.com. ; Define our domain name
@  1D  IN  SOA ns1.example.com. hostmaster.example.com. (
                              2024061301 ; serial
                              3h ; refresh duration
                              15 ; retry duration
                              1w ; expiry duration
                              3h ; nxdomain error ttl
                             )
       IN  NS     ns1.example.com. ; in the domain
       IN  MX  10 mail.another.com. ; external mail provider
       IN  A      172.20.0.100 ; default A record
; server host definitions
ns1    IN  A      172.20.0.100 ; name server definition     
www    IN  A      172.20.0.101 ; web server definition
mail   IN  A      172.20.0.102 ; mail server definition
```

If you need help customizing BIND-style zone files, Oracle has [a good introduction to zone files](https://docs.oracle.com/en-us/iaas/Content/DNS/Reference/formattingzonefile.htm).

Save your changes.

## Enabling Knot

Next, allow DNS ports in `firewalld` and enable Knot DNS:

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now knot
```

Check DNS resolution with the `host` command:

```bash
% host example.com 172.20.0.100
Using domain server:
Name: 172.20.0.100
Address: 172.20.0.100#53
Aliases: 

example.com has address 172.20.0.100
example.com mail is handled by 10 mail.another.com.
%
```

## Conclusion

While most people use third-party services for DNS, there are scenarios where self-hosting DNS is desired. For instance, telecom, hosting, and social media companies, host a large number of DNS entries where hosted services are undesirable.

Knot is one of many open source tools which make hosting DNS possible. Congratulations, you have your very own DNS server! Cheers!
