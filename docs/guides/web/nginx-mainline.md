---
title: Nginx
author: Ezequiel Bruni
contributors: Steven Spencer (most likely)
---
# How to Install the Latest Nginx on Rocky Linux

## Introduction

To give credit where credit is due, I came up with exactly none of this. In particular, this guide is based heavily on [the one by Joshua James](https://www.linuxcapable.com/how-to-install-latest-nginx-mainline-on-rocky-linux-8/) on [LinuxCapable](https://www.linuxcapable.com). Go give his site a read some time, there’s a lot of good stuff there. Now, on to this (beginner-friendly) guide:

*Nginx* is a web server designed to be fast, efficient, and compatible with just about anything you can imagine. I personally use it a fair bit and—once you get the hang of it—it’s actually pretty easy to set up and configure. Here’s a short rundown of the standout features; Nginx is/has/can be:

* A basic web server (one would hope)
* A reverse proxy for directing traffic to multiple sites
* A built-in load balancer for managing traffic to multiple websites
* Built-in file caching for speed
* WebSockets
* FastCGI support
* And, of course, IPv6

It’s great! So just `sudo dnf install nginx`, right? Well, not exactly. **Rocky Linux repositories don’t have the latest production-ready version of Nginx.** Since our goal is bug-for bug compatibility with Red Hat Enterprise Linux, you can always ask them to update their repos. Or asking the *Nginx* people might work better (you’ll see what I mean).

What *you* can do, right now, is install the “mainline” branch of Nginx yourself. It has all the latest updates and toys, and (to my mind) a simpler directory structure for its configuration files. Here’s how to see it all for yourself:

!!! Note 

    There's another branch called "stable", but it's actually a little outdated for most use cases. The "mainline" branch is considered by the Nginx developers to be thoroughly-tested and stable enough for everyone to use.

## Prerequisites and Assumptions

You’ll need:

* An internet-connected Rocky Linux machine or server.
* A basic familiarity with the command line.
* The ability to run commands as root, either as the root user or with `sudo`.
* A text editor of your choice, whether graphical or command-line based. For this tutorial, I’m using `nano`.

## Installing the Repository

This part isn’t quite as simple as installing an extra repository usually is. We’re going to have to create a custom repo file for *dnf* to use, and download *Nginx* from. Technically, we’re sort of repurposing  repositories for CentOS that were made and hosted by *Nginx* themselves. This solution may or may not be viable in the long term, but it’s working great for now.

First, make sure your machine is updated:

```bash
sudo dnf update
```

Now, make sure the `dnf-utils` package is installed, and any command-line text editor you may want:

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

Save the file with Control-S (if using *nano*) and exit with Control-X.

## Installing and Running Nginx

Now, let’s enable the repository file you just made with one simple command:

```bash
sudo yum-config-manager --enable nginx-mainline
```

Then, install *Nginx*:

```bash
sudo dnf install nginx
```

The terminal will ask you if you’re fine with installing the repository’s GPG key. You need that, so choose `Y` for yes.

Once the installation is done, start the `nginx` service and enable it to automatically start on reboot all in one go with:

```bash
sudo systemctl enable --now nginx
```

To verify that the lastest version of *Nginx* has been installed, run:

```bash
nginx -v
```

From there, you could just start dropping HTML files into the `/usr/share/nginx/html/` directory to build a simple, static website. The configuration file for the default website/virtual host is called “default.conf” and it’s in `/etc/nginx/conf.d/`.

## Configuring the Firewall

!!! Note

    If you are installing Nginx on a container such as LXD/LXC or Docker, you can just skip this part for now. The firewall should be handled by the host OS.

If you try to view a web page at your machine’s IP address or domain name from another computer, you’re probably going to get a big fat nothing. Well, that’ll be the case as long as you have a firewall up and running.

Here’s how to open up the necessary ports to actually see your web pages with `firewalld`, Rocky Linux’s default firewall with the `firewall-cmd` command. To add a new port, just run this:

```bash
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
```

Let’s break this down: 

* The `-–permanent` flag tells the firewall to make sure this configuration is used every time the firewall is restarted, and when the server itself is restarted. 
* `–-zone=public` tells the firewall to take incoming connections to this port from everyone.
* Lastly, `–-add-port=80/tcp` tells the firewall to accept incoming connections over port 80, as long as they’re using the Transmission Control Protocol, which is what you want in this case.

To repeat the process for SSL/HTTPS traffic, just run the command again, and change the number.

```bash
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp
```

These configurations won’t take effect until you force the issue. To do that, tell `firewalld` to relead its configurations, like so:

```bash
sudo firewall-cmd --reload
```

!!! Note

    Now, there’s a very small chance that this won’t work. In those rare cases, make `firewalld` do your bidding with the old turn-it-off-and-turn-it-on-again.

    ```bash
    systemctl restart firewalld
    ```

To make sure the ports have been added properly, run `firewall-cmd --list-all`. A properly-configured firewall will look a bit like this (I have a few extra ports open on my local server, ignore them):

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 81/tcp 444/tcp 15151/tcp 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

And that should be everything you need, firewall-wise.

*Now* you should be able to see a web page that looks something like this:

![The Nginx welcome page](nginx/images/welcome-nginx.png)

It’s not much at all, but it means the server is working.

## Creating a Server User and Changing the Website Root Folder

While you *can* just drop your website into the default directory and go (and this might be fine for *Nginx* when it’s running inside a container, or on a test/development server), it’s not what we call best practice. Instead, it’s a good idea to create a specific Linux user on your system for your website, and put your website files in a directory made just for that user. 

If you want to build multiple websites, it’s actually a good idea to create multiple users and root directories, both for the sake of organization and the sake of security. 

In this guide, I’m going to have just the one user: a handsome devil named “www”. We’re going to put all of his website files under a directory in its home folder: `/home/www/`. You can actually put the folder anywhere you want, but on a dedicated server machine, using home folders makes perfect sense.

### Creating the User

First, we make the folder we’re going to use:

```bash
sudo mkdir /home/www/
```

Then, we create the user:

```bash
sudo adduser -g 'Nginx www user' -h /home/www/ www
```

That command tells the machine to

* Make a user called “www” (as per the last bit of text), 
* put all of its files in `/home/www`,
* and add it to the following groups: “Nginx”, “www”, and “user”.

All three are important, but that “Nginx” group does some real magic. It allows the web server to read and modify files that belong to the “www” user, and the “www” user group. See the Rocky Linux [guide to user management](../../books/admin_guide/06-users.md) for more information.

You will, at this point, be prompted to give the new user a password. Type it in, press Enter, and repeat.

From now on, when you’re actually going to add files to your website, it’s a good idea to do it as the web server user. You can log in to the server user account with by running the following command, and then typing in that password you chose:

```bash
sudo su www
```

### Changing the Server Root Folder

Now that you have your fancy new user account, it’s time to make *Nginx* look for your website files in that folder. It;s time to grab your favorite text editor again.

For now, just run:

```bash
sudo nano /etc/nginx/conf.d
```

When the file is open, look for the line that looks like `root   /usr/share/nginx/html;`. Change it to your chosen website root folder, eg. `root   /home/www;`. Save and close the file, then test your *Nginx* configuration to make sure you didn’t skip a semi-colon or anything:

```bash
nginx -t
```

If you get the collowing success message, everything went right:

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Then, give the server a soft restart with:

```bash
sudo systemctl reload nginx
```

If the soft restart doesn’t work, give *Nginx* a kick in the pants with:

```bash
sudo systemctl restart nginx
```

Any HTML files in your new root folder should now be browsable from… your browser.

### Changing File Permissions

To make sure that *Nginx* can read, write to, and execute any files in the website directory, permissions need to be set properly, especially if you uploaded the files while using the root account. 

First, make sure that all files in the root folder are owned by the server user and its user group with:

```bash
sudo chown -R www:www /home/www
```

And then, to make sure that users who want to actually browse your website can actually see the pages, you should make you can run this command:

```bash
sudo chmod -R 755 /home/www 
```

That basically gives everyone the right to look at files on the server, but not modify them. Only the owners get to do that. If you’re feeling paranoid, you can run that particular command every time you upload new HTML/CSS/JS/image files to a static website.

## Additional Configuration Options and Guides

* If you want to see how to make *Nginx* work with PHP, and PHP-FPM specifically, check out our [guide to PHP on Rocky Linux](../web/php.md).
* Instructions on multi-site configuration are coming in another guide. Instructions for SSL certificates are coming as well, and this guide will be updated with links when they’re ready.

## Conclusion

The basic installation and configuration of *Nginx* are easy, even if it’s more complicated than it should be to get the latest version. But, just follow the steps, and you’ll have one of the best server options out there up and running quickly.

Now you just have to go and build yourself a website? What could that take, another ten minutes? *Sobs quietly in Web Designer*
