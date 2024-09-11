---
title: Nginx
author: Ezequiel Bruni
contributors: Antoine Le Morvan, Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - nginx
  - web
---

# How to Install the Latest Nginx on Rocky Linux

## Introduction

*Nginx* is a web server designed to be fast, efficient, and compatible with almost anything. I use it often, and once you get the hang of it — it’s pretty easy to set up and configure. To that end, I've written this beginner's guide.

Here’s a short rundown of the ways Nginx stands out/features it has:

* A basic web server
* A reverse proxy for directing traffic to multiple sites
* A built-in load balancer for managing traffic to multiple websites
* Built-in file caching for speed
* WebSockets
* FastCGI support
* And, of course, IPv6

It’s great! So just `sudo dnf install nginx`, right? Yes, it's pretty much that, but we've included some helpful tips to get you started.

## Prerequisites and Assumptions

You’ll need:

* An internet-connected Rocky Linux machine or server.
* A basic familiarity with the command line.
* The ability to run commands as root, either as the root user or with `sudo`.
* A text editor of your choice, whether graphical or command-line based. For this tutorial, I’m using `nano`.

## Installing and Running Nginx

First, make sure your machine is updated:

```bash
sudo dnf update
```

Then, install the `nginx` package:

```bash
sudo dnf install nginx
```

Once the installation is done, start the `nginx` service and enable it to start on reboot all in one go automatically:

```bash
sudo systemctl enable --now nginx
```

To verify that the latest version of *Nginx* (the newest version from the Rocky repos, anyway) has been installed, run:

```bash
nginx -v
```

From there, you could just start dropping HTML files into the `/usr/share/nginx/html/` directory to build a simple, static website. The configuration file for the default website/virtual host is called “nginx.conf” and it’s in `/etc/nginx/`. It also holds a number of other basic Nginx server configurations, so even if you choose to move the actual website config to another file, you should probably leave the rest of "nginx.conf" intact.

!!! Note

    Older versions of this guide described the installation of nginx-mainline. This is no longer an option. In most cases, the version of Nginx in Rocky's repos is more than sufficient, providing a stable base with backported security patches. Those who still want to use the nginx-mainline can find methods to do so by searching the web. All of the how-to documents found, however, will be for Rocky Linux 8. Please note that using nginx-mainline is usually perfectly viable but not supported.

## Configuring the Firewall

!!! Note

    If you are installing Nginx on a container such as LXD/LXC or Docker, you can just skip this part for now. The firewall should be handled by the host OS.

You'll probably get nothing if you try to view a web page at your machine’s IP address or domain name from another computer. Well, that’ll be the case if you have a firewall up and running.

To open up the necessary ports so that you can actually "see" your web pages, we will use Rocky Linux's built-in firewall, `firewalld`. The `firewalld` command for doing this is `firewall-cmd`. There are two ways to do it: the official and the manual. *In this instance, the official way is best,* but you should know both for future reference.

The official way opens up the firewall to the `http` service, which is, of course, the service that handles web pages. Just run this:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
```

Let’s break this down:

* The `-–permanent` flag tells the firewall to ensure this configuration is used every time the firewall is restarted and when the server is restarted.
* `–-zone=public` tells the firewall to take incoming connections to this port from everyone.
* Lastly, `--add-service=http` tells `firewalld` to let all HTTP traffic through to the server.

Now here's the manual way to do it. It's pretty much the same, except you're specifically opening up port 80 that HTTP uses.

```bash
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
```

* `–-add-port=80/tcp` tells the firewall to accept incoming connections over port 80, as long as they’re using the Transmission Control Protocol, which is what you want in this case.

For SSL/HTTPS traffic, just run the command again and change the service or the port number.

```bash
sudo firewall-cmd --permanent --zone=public --add-service=https
# Or, in some other cases:
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

To ensure the ports have been added properly, run `firewall-cmd --list-all`. A properly-configured firewall will look a bit like this:

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

*Now* you should be able to see a web page that looks something like this:

![The Nginx welcome page](nginx/images/welcome-nginx.png)

It’s not much at all, but it means the server is working. You can also test that your web page is working from the command line with:

```bash
curl -I http://[your-ip-address]
```

## Creating a Server User and Changing the Website Root Folder

While you *can* just drop your website into the default directory and go (and this might be fine for *Nginx* when it’s running inside a container, or on a test/development server), it’s not what we call best practice. Instead, it’s a good idea to create a specific Linux user on your system for your website, and put your website files in a directory made just for that user.

If you want to build multiple websites, you should create various users and root directories for organization and security.

In this guide, I will have just one user: a handsome devil named “www”. Deciding where to put your website files gets more complicated.

You can put your website files in several places depending on your server setup. If you're on a bare-metal (physical) server, or you're installing `nginx` directly on a VPS, you probably have Security Enhanced Linux (SELinux) running. SELinux is a tool that does a lot to protect your machine, but it also kind of dictates where you can put certain things, like web pages.

So if you're installing `nginx` directly to your machine, you'll want to put your websites in the default root folder subdirectories. In this case, the default root is `/usr/share/nginx/html`, so the website for the “www” user might go into `/usr/share/nginx/html/www`.

If you're running `nginx` in a container such as LXD/LXC, however, SELinux will likely *not* be installed, and you can put your files wherever you like. In this case, I like to put all of a user's website files under a directory in a normal home folder, like so: `/home/www/`.

I'll continue this guide as though SELinux is installed, though. Just change what you need to based on your use case. You can also learn more about how SELinux works in [our guide on the subject](../security/learning_selinux.md).

### Creating the User

First, we make the folder we’re going to use:

```bash
sudo mkdir /usr/share/nginx/html/www
```

Next, create the www group:

```bash
sudo groupadd www
```

Then, we create the user:

```bash
sudo adduser -G nginx -g www -d /usr/share/nginx/html/www www --system --shell=/bin/false
```

That command tells the machine to:

* Make a user called “www” (as per the middle bit of text),
* put all of its files in `/usr/share/nginx/html/www`,
* and add it to the following groups: “nginx” as supplemental , “www” as primary.
* The `--system` flag says that the user is not a human user, it's reserved for the system. If you want to create human user accounts to manage different websites, that's a whole other guide.
* `--shell=/bin/false` makes sure no one can even *try* to log in as the “www” user.

The “nginx” group does some real magic. It allows the web server to read and modify files that belong to the “www” user, and the “www” user group. See the Rocky Linux [guide to user management](../../books/admin_guide/06-users.md) for more information.

### Changing the Server Root Folder

Now that you have your fancy new user account, it’s time to make `nginx` look for your website files in that folder. Grab your favorite text editor again.

For now, just run:

```bash
sudo nano /etc/nginx/conf.d/default.conf
```

When the file is open, look for the line that looks like `root   /usr/share/nginx/html;`. Change it to your chosen website root folder, eg. `root   /usr/share/nginx/html/www;` (or `/home/www` if you're running `nginx` in containers like I do). Save and close the file, then test your `nginx` configuration to make sure you didn’t skip a semi-colon or anything:

```bash
nginx -t
```

If you get the following success message, everything went right:

```bash
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Then, give the server a soft restart with:

```bash
sudo systemctl reload nginx
```

!!! Note

    In the unlikely event that the soft restart doesn’t work, give `nginx` a kick in the pants with:

    ```bash
    sudo systemctl restart nginx
    ```

Any HTML files in your new root folder should now be browsable from… your browser.

### Changing File Permissions

Permissions must be set correctly to ensure that `nginx` can read, write, and execute any files in the website directory.

First, make sure that all files in the root folder are owned by the server user and its user group with:

```bash
sudo chown -R www:www /usr/share/nginx/html/www
```

And then, to ensure that users who want to browse your website can actually see the pages, run these commands (and yes, those semicolons matter):

```bash
sudo find /usr/share/nginx/html/www -type d -exec chmod 555 "{}" \;
sudo find /usr/share/nginx/html/www -type f -exec chmod 444 "{}" \;
```

That basically gives everyone the right to look at files on the server, but not modify them. Only the root and server users get to do that.

## Getting SSL Certificates for Your Site

As of now, our [guide to getting SSL certificates with certbot](../security/generating_ssl_keys_lets_encrypt.md) has been updated with some basic instructions for `nginx`. Go give that a look, as it has full instructions for installing certbot, as well as generating the certificates.

The time is coming when browsers might stop letting people see sites without certificates, so ensure you get one for every site.

## Additional Configuration Options and Guides

* If you want to see how to make *Nginx* work with PHP, and PHP-FPM specifically, check out our [guide to PHP on Rocky Linux](../web/php.md).
* If you want to learn how to set up *Nginx* for multiple websites, we now have [a guide on just that subject](nginx-multisite.md).

## SELinux rules

Beware that when enforced, nginx proxy_pass directives will fail with "502 Bad Gateway"

You can either disable setenforce for development purposes

```bash
sudo setenforce 0
```

or you can enable `httpd` or other services related to nginx in `/var/log/audit/audit.log`

```bash
sudo setsebool httpd_can_network_connect 1 -P
```

## Conclusion

The basic installation and configuration of `nginx` is easy, even if it is more complicated than it should be to get the latest version. But follow the steps, and you will have one of the best server options up and running quickly.

Now you just have to go and build yourself a website? What could that take, another ten minutes? *Sobs quietly in Web Designer*
