---
title: DokuWiki Server
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - wiki
  - documentation
---

## Prerequisites and assumptions

- A Rocky Linux instance installed on a server, container, or virtual machine
- Comfort with modifying configuration files from the command line with an editor (our examples here will use _vi_, but you can substitute your favorite editor)
- Some knowledge about web applications and setup
- Our example will use the [Apache Sites Enabled](../web/apache-sites-enabled.md) for setup. Review that if necessary.
- This document will use "example.com" as the domain name throughout
- You must be root or able to `sudo` to elevate privileges
- Assuming a fresh install of the operating system, however that is not a requirement

## Introduction

Documentation can take many forms in an organization. Having a repository that you can reference for that documentation is invaluable. A wiki (meaning _quick_ in Hawaiian), is a way to keep documentation, process notes, corporate knowledge bases, and even code examples, in a centralized location. IT professionals who keep a wiki, even secretly, have a built-in insurance policy against forgetting an obscure routine.

DokuWiki is a mature, fast, wiki that runs without a database, has built-in security features, and is not complex to deploy. For more information, examine their [web page](https://www.dokuwiki.org/dokuwiki).

DokuWiki is just one of many wikis available, though it is a pretty good one. One big pro is that DokuWiki is relatively lightweight and can run on a server that is already running other services, provided you have space and memory available.

## Installing dependencies

The minimum PHP version for DokuWiki is now 7.2, which is exactly what Rocky Linux 8 has by default. Because of modules, Rocky Linux 8 can install up to version 8.2. Rocky Linux 9.0 has PHP version 8.0 by default, and modules that allow up to 8.2. Note that some of the packages listed here might already exist:

```bash
dnf install tar wget httpd php php-gd php-xml php-json php-mbstring
```

Accept and install any additional listed dependencies that come with these packages.

## Create directories and change configuration

### Apache configuration

If you have read through the [Apache Sites Enabled](../web/apache-sites-enabled.md) procedure, you know that you need to create a few directories. Start with the _httpd_ configuration directory additions:

```bash
mkdir -p /etc/httpd/{sites-available,sites-enabled}
```

You need to edit the `httpd.conf` file:

```bash
vi /etc/httpd/conf/httpd.conf
```

Add this to the very bottom of the file:

```bash
Include /etc/httpd/sites-enabled
```

Create the site configuration file in sites-available:

```bash
vi /etc/httpd/sites-available/com.example
```

That configuration file will be similar to this:

```apache
<VirtualHost *>
  ServerName    example.com
  DocumentRoot  /var/www/sub-domains/com.example/html

  <Directory ~ "/var/www/sub-domains/com.example/html/(bin/|conf/|data/|inc/)">
      <IfModule mod_authz_core.c>
                AllowOverride All
          Require all denied
      </IfModule>
      <IfModule !mod_authz_core.c>
          Order allow,deny
          Deny from all
      </IfModule>
  </Directory>

  ErrorLog   /var/log/httpd/example.com_error.log
  CustomLog  /var/log/httpd/example.com_access.log combined
</VirtualHost>
```

Note that the "AllowOverride All" above, allows the `.htaccess` (directory specific security) file to work.

Go ahead and link the configuration file into sites-enabled, but do not start web services as yet:

```bash
ln -s /etc/httpd/sites-available/com.example /etc/httpd/sites-enabled/
```

### Apache DocumentRoot

You need to create your _DocumentRoot_. Do this with:

```bash
mkdir -p /var/www/sub-domains/com.example/html
```

## Installing DokuWiki

In your server, change to the root directory.

```bash
cd /root
```

Since your environment is ready to go, get the latest stable version of DokuWiki. You can find this by going to [the download page](https://download.dokuwiki.org/) and on the left side of the page under "Version" you will see "Stable (Recommended) (direct link)."

Right-click on the "(direct link)" portion of this and copy the link. In the console of your DokuWiki server, type `wget` and a space and then paste in your copied link in the terminal. You should get something similar to this:

```bash
wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz
```

Before we decompress the archive, examine the contents with `tar ztf`:

```bash
tar ztvf dokuwiki-stable.tgz
```

Notice the named dated directory ahead of all the other files that looks similar to this:

```text
... (more above)
dokuwiki-2020-07-29/inc/lang/fr/resetpwd.txt
dokuwiki-2020-07-29/inc/lang/fr/draft.txt
dokuwiki-2020-07-29/inc/lang/fr/recent.txt
... (more below)
```

You do not want that leading named directory when decompressing the archive, so you are going to use some options with `tar` to exclude it. The first option is the "--strip-components=1" that removes the leading directory. The second option is the "-C" option that tells `tar` where you want the archive decompressed to. The decompression will be similar to this:

```bash
tar xzf dokuwiki-stable.tgz  --strip-components=1 -C /var/www/sub-domains/com.example/html/
```

Once you have run this command, all of DokuWiki should be in your _DocumentRoot_.

You need to make a copy of the _.htaccess.dist_ file that came with DokuWiki and keep the old one there too, in case you need to revert to the original in the future.

In the process, you will be changing the name of this file to _.htaccess_. This is what _apache_ will be looking for. To do this:

```bash
cp /var/www/sub-domains/com.example/html/.htaccess{.dist,}
```

You need to change ownership of the new directory and its files to the _apache_ user and group:

```bash
chown -Rf apache.apache /var/www/sub-domains/com.example/html
```

## Setting up DNS or `/etc/hosts`

Before you will be able to access the DokuWiki interface, you will need to set name resolution for this site. For testing purposes, you can use your _/etc/hosts_ file.

In this example, assume that DokuWiki will be running on a private IPv4 address of 10.56.233.179. Assume you are modifying the _/etc/hosts_ file on a Linux workstation as well. To do this, run:

```bash
sudo vi /etc/hosts
```

Then change your hosts file to look similar to this (note the IP address above in the example):

```bash
127.0.0.1 localhost
127.0.1.1 myworkstation-home
10.56.233.179 example.com     example

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Once you have finished testing and are ready to take things live for everyone, you will need to add this host to a DNS server. You could do this by using a [Private DNS Server](../dns/private_dns_server_using_bind.md), or a public-facing DNS server.

## Starting `httpd`

Before you start _httpd_, test to make sure that your configuration is OK:

```bash
httpd -t
```

You should get:

```text
Syntax OK
```

If so, you should be ready to start _httpd_ and then finish the setup. Start by enabling _httpd_ to start on boot:

```bash
systemctl enable httpd
```

Then start it:

```bash
systemctl start httpd
```

## Testing DokuWiki

The next step is to open up a web browser and type this in the address bar:

<http://example.com/install.php>

This will bring you to the setup screen:

- In the "Wiki Name" field, type the name for our wiki. Example "Technical Documentation"
- In the "Superuser" field, type the administrative username. Example "admin"
- In the "Real name" field, type the real name of the administrative user
- In the "E-Mail" field, type the email address of the administrative user
- In the "Password" field, type the secure password of the administrative user
- In the "once again" field, re-type that same password
- In the "Initial ACL Policy" drop-down, choose the option that works best for your environment
- Choose the appropriate checkbox of the license you want to put your content under
- Leave checked (or uncheck if you prefer) the "Once a month, send anonymous usage data to the DokuWiki developers" checkbox
- Click the "Save" button

Your wiki is now ready for you to add content.

## Securing DokuWiki

Besides the ACL policy that you just created, consider:

### Your `firewalld` firewall

!!! note

    This firewall example make no assumptions about what other services you might need to allow on your Dokuwiki server. These rules are based on your testing environment and **ONLY** deal with allowing access to a LOCAL network ip block. You will need more services allowed for a production server.

Before you call everything done, you need to think about security. First, you should be running a firewall on the server.

The assumption here is that anyone on the 10.0.0.0/8 network is on your private Local Area Network, and that those are the only people who need access to the site.

If you are using `firewalld` as your firewall, use the following rule syntax:

```bash
firewall-cmd --zone=trusted --add-source=10.0.0.0/8 --permanent
firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent
firewall-cmd --reload
```

Once you have the above rules added and the `firewalld` service reloaded, list out your zone to make sure that everything is there that you need:

```bash
firewall-cmd --zone=trusted --list-all
```

This will look similar to this if all worked correctly:

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: 
  sources: 10.0.0.0/8
  services: http https
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
```

### SSL

For the best security, you should consider using an SSL for encrypted web traffic. You can purchase an SSL from an SSL provider or use [Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md).

## Conclusion

Whether you need to document processes, company policies, program code, or something else, a wiki is a great way to get that done. DokuWiki is a product that is secure, flexible, easy to use, relatively easy to install and deploy, and is a stable project that has been around for many years.
