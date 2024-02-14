---
title: Tor Onion Service
author: Neel Chauhan
contributors:
tested_with: 9.3
tags:
  - proxy
  - proxies
---

# Tor Onion Service

## Introduction

[Tor](https://www.torproject.org/) is an anonymity service and software that routes traffic by way of three volunteer-run servers called relays. The three-hop design is to ensure privacy by resisting surveillance attempts.

One feature of Tor is that you can run hidden, Tor-exclusive websites called
[onion services](https://community.torproject.org/onion-services/). All traffic
to an onion service is therefore private and encrypted.

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

* The "HiddenServiceDir" is the location of your onion service's hostname and cryptographic keys. We are storing these keys at `/var/lib/tor/onion-site/`.
* The "HiddenServicePort" is the port forwarding from your local server to the onion service. We are forwarding 127.0.0.1:8080 to Port 80 on our Tor-facing service.

!!! warning

    If you plan to use a directory for your onion service signing keys outside of `/var/lib/tor/`, you will need to make sure the permissions are `0700` and the owner is `toranon:toranon`.

## Configuring a web server

We will also need a web server on our machine in order to service clients to our onion service. The author likes Caddy, but Apache or Nginx can also be used. For simplicity's sake, let's install Caddy:

```bash
dnf -y install caddy
```

Next, we should insert the following to `/etc/caddy/Caddyfile`:

```bash
http://127.0.0.1:80 {
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

Within an hour, your onion service will propagate via Tor's onion service directories and you will be able to view your onion service in Tor Browser:

TODO: Insert image here

## Conclusion

Onion services are an invaluable tool if you're interested in hosting a website privately or want a way to bypass your ISP's Carrier Grade NAT using only open source software.

While onion services will never be as fast as hosting a website directly (understandable due to Tor's privacy-first design), it's way more secure and private than the public internet.
