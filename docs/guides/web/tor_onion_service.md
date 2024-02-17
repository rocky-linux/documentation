---
title: Tor Onion Service
author: Neel Chauhan
contributors:
tested_with: 9.3
tags:
  - web
  - proxy
  - proxies
---

# Tor Onion service

## Introduction

[Tor](https://www.torproject.org/) is an anonymity service and software that routes traffic by way of three volunteer-run servers called relays. The three-hop design is to ensure privacy by resisting surveillance attempts.

One feature of Tor is that you can run hidden, Tor-exclusive websites called [onion services](https://community.torproject.org/onion-services/). All traffic to an onion service is therefore private and encrypted.

## Prerequisites and assumptions

The following are minimum requirements for using this procedure:

* The ability to run commands as the root user or use `sudo` to elevate privileges
* Familiarity with a command-line editor. The author is using `vi` or `vim` here, but substitute in your favorite editor
* A web server running on localhost, or another TCP/IP port

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

The default `torrc` file is pretty descriptive, but can get long if you just want an onion service. A minimum onion service configuration is similar to this:

```bash
HiddenServiceDir /var/lib/tor/onion-site/
HiddenServicePort 80 127.0.0.1:80
```

### Taking a closer look

* The "HiddenServiceDir" is the location of your onion service's hostname and cryptographic keys. You are storing these keys at `/var/lib/tor/onion-site/`
* The "HiddenServicePort" is the port forwarding from your local server to the onion service. You are forwarding 127.0.0.1:80 to port 80 on our Tor-facing service

!!! warning

    If you plan to use a directory for your onion service signing keys outside of `/var/lib/tor/`, you will need to make sure the permissions are `0700` and the owner is `toranon:toranon`.

## Configuring a web server

You will also need a web server on our machine to service clients to your onion service. Any web server (Caddy, Apache, or Nginx) is usable. The author prefers Caddy. For simplicity's sake, install Caddy:

```bash
dnf -y install caddy
```

Next, you will insert the following to `/etc/caddy/Caddyfile`:

```bash
http:// {
    root * /usr/share/caddy
    file_server
}
```

## Test and turn up

Once you have set your Tor relay configuration, the next step is to turn up the Tor and Caddy daemons:

```bash
systemctl enable --now tor caddy
```

You can get your onion service's hostname with this command:

```bash
cat /var/lib/tor/onion-site/hostname
```

Within a few minutes, your onion service will propagate via the Tor network and you can view your new onion service in the Tor browser:

![Tor Browser showing our Onion Service](../images/onion_service.png)

## Conclusion

Onion services are an invaluable tool if you are hosting a website privately or need to bypass your ISP's Carrier Grade NAT using only open source software.

While onion services are not as fast as hosting a website directly (understandable due to Tor's privacy-first design), it is way more secure and private than the public internet.
