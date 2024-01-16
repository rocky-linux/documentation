---
title: Caddy Web Server
author: Neel Chauhan
contributors:
tested_with: 9.3
tags:
  - web
---

# How to Install the Latest Caddy Web Server on Rocky Linux

## Introduction

*Caddy* is a web server designed for modern web applications. Caddy is super simple to configure, and has automatic Let's Encrypt, so your websites are always secure by default. It's personally my go-to web server.

Here’s a short rundown of Caddy's features:

* A basic web server 
* A reverse proxy for directing traffic to multiple sites
* Modules for many workloads, including TCP, SSH, and more
* A built-in load balancer for managing traffic to multiple websites
* Built in, automated Let's Encrypt support
* An API to re-configure the server programmatically
* PHP FastCGI support
* And, of course, IPv6

## Prerequisites and Assumptions

You’ll need:

* An internet-connected Rocky Linux machine or server.
* A basic familiarity with the command line.
* The ability to run commands as root, either as the root user or with `sudo`.
* A text editor of your choice, whether graphical or command-line based. For this tutorial, I’m using `vim`.
* A domain name or other hostname, that's pointed to your server's public IP address.

## Installing Caddy

First, make sure your machine is updated:

```bash
sudo dnf update
```

Then, install the `epel-release` software repository:

```bash
sudo dnf install -y epel-release
```

Then install the `caddy` web server:

```bash
sudo dnf install -y caddy
```

## Configuring the Firewall

If you try to view a web page at your machine’s IP address or domain name from another computer, you’re probably going to get nothing. Well, that’ll be the case as long as you have a firewall up and running.

To open up the necessary ports so that you can actually "see" your web pages, we will use Rocky Linux's build-in firewall, `firewalld`. The `firewalld` command for doing this is `firewall-cmd`.

In order to open up the `http` and `https` services, which is of course the services that handles web pages, run this:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
```

Let’s break this down:

* The `-–permanent` flag tells the firewall to ensure this configuration is used every time the firewall is restarted and when the server is restarted.
* `–-zone=public` tells the firewall to take incoming connections to this port from everyone.
* Lastly, `--add-service=http` and `--add-service=https` tells `firewalld` to let all HTTP and HTTPS traffic through to the server.

These configurations won’t take effect until you force the issue. To do that, tell `firewalld` to relead its configurations, like so:

```bash
sudo firewall-cmd --reload
```

!!! Note

    Now, there’s a very small chance that this won’t work. In those rare cases, make `firewalld` do your bidding with the old turn-it-off-and-turn-it-on-again.

    ```bash
    systemctl restart firewalld
    ```

To make sure the ports have been added properly, run `firewall-cmd --list-all`. A properly-configured firewall will look a bit like this:

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: cockpit dhcpv6-client ssh http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

And that should be everything you need, firewall-wise.

## Configuring Caddy

Unlike traditional web servers like Apache and Nginx, Caddy's configuration format is significantly simpler. And I mean by a lot. Gone are the days where you had to configure the nitty gritty like your web server's threading model or SSL certificates. Well, unless you want to.

To edit the Caddy configuration file:

```bash
vim /etc/caddy/Caddyfile
```

A minimum static webserver configuration can be similar to shia:

```bash
example.com
    root * /usr/share/caddy/example.com
    file_server
}
```

Replace "example.com" with a hostname that's pointed to your server.

You will also have to add a website to the folder in Caddy's "root" directory. For simlicity's sake, we will add a one-page static website:

```bash
mkdir -p /usr/share/caddy/example.com
echo "<h1>Hi!</h1>" >> /usr/share/caddy/example.com/index.html
```

After that, enable Caddy's systemd service:

```bash
systemctl enable --now caddy
```

Within a minute, Caddy will obtain SSL certificates from Let's Encrypt. Then, you can view the website you just set up in a browser:

![Caddy serving our demo website](../images/caddy_example.png)

It should have an SSL padlock that should work in every modern browser, and not just that, but also an A+ rating at [Qualys SSL Server Test](https://www.ssllabs.com/ssltest/).

## Conclusion

The basic installation and configuration of Caddy is incredibly easy. Gone are the days where you spent hours configuring Apache. Yes, Nginx is certainly an improvement, but it still lacks modern but essential features such as Let's Encrypt and Kubernetes Ingesss support that Caddy builds in, but has to be bolted on nginx (and Apache).

I've been using Caddy since 2019 as my go-to webserver, and it's just so good. In fact, whenever I deal with Apache, Nginx or IIS, it's almost like taking a time machine back to 2010 or earlier.
