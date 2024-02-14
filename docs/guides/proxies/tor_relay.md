---
title: Tor Relay
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 8.7, 9.2
tags:
  - proxy
  - proxies
---

# Tor relay

## Introduction

[Tor](https://www.torproject.org/) is an anonymity service and software that routes traffic by way of three volunteer-run servers called relays. The three-hop design is to ensure privacy by resisting surveillance attempts.

## Prerequisites and assumptions

The following are minimum requirements for using this procedure:

* A public IP address, whether directly on the server or with port forwarding
* A system that is able to run 24/7, to be useful for the Tor network
* The ability to run commands as the root user or use `sudo` to elevate privileges
* Familiarity with a command-line editor. The author is using `vi` or `vim` here, but substitute in your favorite editor
* Comfort with changing SELinux and firewall settings
* An unmetered connection, or a connection with a high bandwidth limit

## Installing Tor

To install Tor, you need to first install the EPEL (Extra Packages for Enterprise Linux) and run updates:

```bash
dnf -y install epel-release && dnf -y update
```

Then install Tor:

```bash
dnf -y install tor
```

## Configuring Tor

With the packages installed, you need to configure Tor. The author uses `vi` for this, but if you prefer `nano` or something else, go ahead and substitute that in:

```bash
vi /etc/tor/torrc
```

The default `torrc` file is pretty descriptive, but can get long if you just want a Tor relay. A minimum relay configuration is similar to this:

```bash
Nickname TorRelay
ORPort 9001
ContactInfo you@example.com
Log notice syslog
```

### Taking a closer look

* The "Nickname" is a (non-unique) nickname for your Tor relay.
* The "ORPort" is the TCP port your Tor relay listens on. The default is "9001".
* The "ContactInfo" is your contact information, in case there's issues with your Tor relay. Set this to your email address.
* The "Log" is the severity and destination of your Tor relay logs. We are logging "notice" to prevent sensitive information from logging, and "syslog" to output to the `systemd` log.

### System configuration

If you have chosen another TCP/IP port than "9001" (the default), you will need to adjust the SELinux `tor_port_t` to whitelist your Tor relay's port. To do so:

```bash
semanage port -a -t tor_port_t -p tcp 12345
```

Replace "12345" with the TCP Port you set in your "ORPort".

You will also need to open your "ORPort" port in the firewall. To do so:

```bash
firewall-cmd --zone=public --add-port=9001/tcp
firewall-cmd --runtime-to-permanent
```

Replace "9001" with the TCP Port you set in your "ORPort".

## Limiting the bandwidth

If you do not want to dedicate all your bandwidth to Tor, say you have a fair use policy at your ISP, you can limit your bandwidth. You can limit in terms of bandwidth (e.g., 100 megabits) or traffic in a period of time (e.g., 5GB per day).

To do this, edit the `torrc` file:

```bash
vi /etc/tor/torrc
```

If you want to limit the bandwidth, you will need to append the following line to your `torrc` file:

```bash
RelayBandwidthRate 12500 KB
```

This will allow 12500 KB per second of bandwidth, which is about 100 megabits per second.

If you prefer to transfer a specific amount of traffic in a period of time, say per day, append the following instead:

```bash
AccountingStart day 00:00
AccountingMax 20 GB
```

These values imply that:

* Your bandwidth accounting period is every day starting at 00:00 system time. You can also change "day" to "week" or "month", or replace "00:00" with another time.
* In your bandwidth accounting period, you will transfer 20 GB. Increase or decrease the value if you want to allow more or less bandwidth for your relay.

What happens after you used your specified bandwidth? Your relay will block new connection attempts until the end of the period. If your relay did not use the specified bandwidth in your period, the counter will reset without any downtime.

## Test and turn up

Once you have set your Tor relay configuration, the next step is to turn up the Tor daemon:

```bash
systemctl enable --now tor
```

In your systemd logs, you should get a line like:

```bash
Jan 14 15:46:36 hostname tor[1142]: Jan 14 15:46:36.000 [notice] Self-testing indicates your ORPort A.B.C.D:9001 is reachable from the outside. Excellent. Publishing server descriptor.
```

This indicates your relay is accessible.

Within a few hours, your relay will be listed on [Tor Relay Status](https://metrics.torproject.org/rs.html) by typing in your Nickname or public IP address.

## Relay considerations

You can also extend the configuration to make your Tor relay an exit or bridge relay. You can also set up a maximum of 8 relays per public IP address. The Tor systemd unit file in EPEL is not designed for more than one instance, but the unit file can be copied and modified to accommodate a multi-relay setup.

Exit relays are the last hop of a Tor circuit connecting directly to websites. Bridge relays are unlisted relays that help users with internet censorship connect to Tor.

Options for the `torrc` file are in [the man page](https://2019.www.torproject.org/docs/tor-manual.html.en). Here, we will describe a basic configuration for an exit and bridge relay.

### Running an exit relay

!!! warning

    If you plan to run an exit relay, make sure your ISP or hosting company is comfortable with it. Abuse complaints from exit relays are very common, as it is the last node of a Tor circuit which connects directly to websites on behalf of Tor users. Many hosting companies disallow Tor exit relays for this reason.

    If you are unsure your ISP allows Tor exit relays, look at the terms of service or ask your ISP. If your ISP says no, look at another ISP or hosting company, or consider a middle or bridge relay instead.

If you want to run an exit relay, you'll need to append the following to your `torrc`:

```bash
ExitRelay 1
```

However, this will use the following default exit policy:

```bash
ExitPolicy reject *:25
ExitPolicy reject *:119
ExitPolicy reject *:135-139
ExitPolicy reject *:445
ExitPolicy reject *:563
ExitPolicy reject *:1214
ExitPolicy reject *:4661-4666
ExitPolicy reject *:6346-6429
ExitPolicy reject *:6699
ExitPolicy reject *:6881-6999
ExitPolicy accept *:*
```

This exit policy blocks only a small subset of TCP ports, which allows abuse from BitTorrent and SSH which many ISPs are uncomfortable with.

If you want to use a [reduced exit policy](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/ReducedExitPolicy), you can set it in the `torrc`:

```bash
ReducedExitPolicy 1
```

You can also have a more restrictive exit policy, for instance only allowing DNS, HTTP, and HTTPS traffic. This can be set as:

```bash
ExitPolicy accept *:53
ExitPolicy accept *:80
ExitPolicy accept *:443
ExitPolicy reject *:*
```

These values imply that:

* We are allowing exit traffic to TCP ports 53 (DNS), 80 (HTTP), and 443 (HTTPS) with our "ExitPolicy accept" lines
* We are disallowing exit traffic to any other TCP port with our wildcard "ExitPolicy reject" lines.

If you want an unrestrictive exit policy, by only blocking SMTP traffic, this can be set as:

```bash
ExitPolicy reject *:25
ExitPolicy reject *:465
ExitPolicy reject *:587
ExitPolicy accpet *:*
```

These values imply that

* We are disallowing exit traffic to the common SMTP TCP ports of 25, 465, and 587 in our "ExitPolicy reject" lines.
* We are allow exit traffic to all other TCP ports in our wildcard "ExitPolicy accept" line.

We can also allow or block a range of ports as follows:

```bash
ExitPolicy accept *:80-81
ExitPolicy reject *:993-995
```

These values imply that:

* We are allowing exit traffic to TCP ports 80-81.
* We are disallowing exit traffic to TCP ports 993-995, which are used for the SSL-secured variants of IMAP, IRC, and POP3.

You can also allow exit traffic to IPv6 addresses, assuming your server has dual-stack connectivity:

```bash
IPv6Exit 1
```

### Running an obfs4 bridge

In many parts of the world, including China, Iran, Russia, and Turkmenistan, direct connections to Tor are blocked. In those countries, unlisted bridge relays are used by Tor clients.

Tor operates using a system of [pluggable transports](https://support.torproject.org/glossary/pluggable-transports/), which allow Tor traffic to be masked as other protocols such as unidentifiable dummy traffic (obfs4), WebRTC (snowflake), or HTTPS connections to Microsoft services (meek).

Due to its versatility, obfs4 is the most popular pluggable transport.

To set up an obfs4 bridge, as obfs4 is not in the EPEL repos, we'll need to compile it from scratch. Lets first install the necessary packages:

```bash
dnf install git golang policycoreutils-python-utils
```

Next, we will download and extract the obfs4 source code:

```bash
wget https://gitlab.com/yawning/obfs4/-/archive/obfs4proxy-0.0.14/obfs4-obfs4proxy-0.0.14.tar.bz2
tar jxvf obfs4-obfs4proxy-0.0.14.tar.bz2
cd obfs4-obfs4proxy-0.0.14/obfs4proxy/
```

You can also get obfs4 directly from `git clone`, but that depends on a newer version of Go than what exists in AppStream, so we will not use that.

Then, we will compile and install obfs4:

```bash
go build
cp -a obfs4proxy /usr/local/bin/
```

Once obfs4 is installed, we will append the following to our `torrc`:

```bash
ServerTransportPlugin obfs4 exec /usr/local/bin/obfs4proxy
ServerTransportListenAddr obfs4 0.0.0.0:12345
ExtORPort auto
```

These values imply that:

* We are running an obfs4 pluggable transport located at `/usr/local/bin/obfs4proxy` on our `ServerTransportPlugin` line
* `ServerTransportListenAddr` makes our pluggable transport listen on port 12345
* Our `ExtORPort` line will listen on an randomly-chosen port for connections between Tor and our pluggable transport. Normally, this line shouldn't be changed

If you want to listen on another TCP port, change "12345" with your desired TCP port.

We will also have to allow our chosen TCP port "12345" (or the port you chose) in SELinux and `firewalld`:

```bash
semanage port -a -t tor_port_t -p tcp 12345
firewall-cmd --zone=public --add-port=12345/tcp
firewall-cmd --runtime-to-permanent
```

## Conclusion

Unlike a conventional VPN service, Tor takes advantage of volunteer-run relays to ensure privacy and anonymity, which you just set up.

While running a Tor relay does require a reliable system and for exits, a supportive ISP, adding more relays helps privacy while making Tor faster with fewer points of failure.
