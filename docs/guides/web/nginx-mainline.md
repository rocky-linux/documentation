---
title: Nginx
author: Ezequiel Bruni
contributors: Steven Spencer (most likely)
---
# How to Install the Latest Nginx on Rocky Linux

## Introduction

To give credit where credit is due, I came up with exactly none of this. This guide is based heavily on [the one by Joshua James](https://www.linuxcapable.com/how-to-install-latest-nginx-mainline-on-rocky-linux-8/) on [LinuxCapable](https://www.linuxcapable.com). Go give his site a read some time, there’s a lot of good stuff there. On to this (beginner-friendly) guide:

*Nginx* is a web server designed to be fast, efficient, and compatible with just about anything you can imagine. I personally use it a fair bit and—once you get the hang of it—it’s actually pretty easy to set up and configure. Here’s a short rundown of the standout features; Nginx is/has/can be:

* A basic web server (one would hope)
* A reverse proxy for directing traffic to multiple sites
* A built-in load balancer for managing traffic to multiple websites
* Built-in file caching for speed
* WebSockets
* FastCGI support
* And, of course, IPv6

It’s great! So just `sudo dnf install nginx`, right? Well, not exactly. Let’s be clear: **Rocky Linux repositories don’t actually have the latest production-ready version of Nginx.** Since our goal is bug-for bug compatibility with Red Hat Enterprise Linux, you can always ask them to update their repos. Or asking the *Nginx* people might work better (you’ll see what I mean).

What *you* can do, right now, is install the “mainline” branch of Nginx yourself. It has all the latest updates and toys, and (to my mind) a simpler directory structure for its configuration files. Here’s how to see it all for yourself:

!!! Note 

    There's another branch called "stable", but it's actually a little outdated for most use cases. The "mainline" branch is considered by the Nginx developers to be thoroughly-tested and stable enough for everyone to use.

## Prerequisites and Assumptions

You’ll need:

* An internet-connected Rocky Linux machine or server.
* A basic familiarity with the command line.
* The ability to run commands as root, either as the root user or with `sudo`.
* A text editor of your choice, whether graphical or command-line based. For this tutorial, I’m using *nano*.

## Installing the Repository

This part isn’t quite as simple as installing an extra repository usually is. We’re going to have to create a custom repo file for *dnf* to use, and download *Nginx* from. Technically, we’re sort of repurposing  repositories for CentOS that were made and hosted by *Nginx* themselves. This solution may or may not be viable in the long term, but it’s working great for now.

First, make sure your machine is updated:

```bash
sudo dnf update
```

Now, make sure the *dnf-utils* package is installed, and any command-line text editor you may want:

```bash
sudo dnf install dnf-utils
```

Once that’s all installed, power up your text editor of choice. You’ll want to create a file called (for the sake of simplicity) “nginx.repo”, and put it in `/etc/yum.repos.d/`. You can do this real quick like so:

```bash
sudo nano /etc/yum.repos.d/nginx.repo
```

In that file, paste this bit of code, unmodified:

```bash
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
```

This code basically just lets you use the *Nginx*-made-and-hosted repositories for CentOS, and it allows you use the previously-mentioned “stable” branch if you want to. I mean, don’t. But you could.

Save the file with “Control-S” (if using *nano*) and exit with “Control-X”.

## Installing and Running Nginx

Now, let’s enable the repository file you just made with one simple command:

```bash
sudo yum-config-manager --enable nginx-mainline
```

Then, install *Nginx*:

```bash
sudo dnf install nginx
```

The terminal will ask you if you’re fine with installing the repository’s GPG key. You need that, so choose “Y” for yes.

Once the installation is done, start *Nginx* and enable it to automatically start on reboot all in one go with:

```bash
sudo systemctl enable --now nginx
```

To verify that the lastest version of *Nginx* has been installed, run:

```bash
nginx -v
```

## Configuring the Firewall

!!! Note

    If you are installing Nginx on a container such as LXD/LXC or Docker, you can just skip this part.

If you try to view a web page at your machine’s IP address or domain name from another computer, you’re probably going to get a big fat nothing. Well, that’ll be the case as long as you have a firewall up and running.

Here’s how to open up the necessary ports to actually see your web pages with *firewalld*, Rocky Linux’s default firewall:



## Additional Configuration Options

If you want to see how to make *Nginx* work with PHP, and PHP-FPM specifically, check out our [guide to PHP on Rocky Linux](../web/php.md).





## Conclusion



