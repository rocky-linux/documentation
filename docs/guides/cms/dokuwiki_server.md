---
title: DokuWiki
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - wiki
  - documentation
---

# DokuWiki Server

## Prerequisites And Assumptions

* A Rocky Linux instance installed on a server, container, or virtual machine.
* Comfort with modifying configuration files from the command line with an editor (our examples here will use _vi_, but you can substitute your favorite editor).
* Some knowledge about web applications and setup.
* Our example will use the [Apache Sites Enabled](../web/apache-sites-enabled.md) for setup, so it is a good idea to review that routine if you plan on following along.
* We will be using "example.com" as the domain name throughout this example.
* We will assume throughout this document that you are the root user or can get there with _sudo_.
* We are assuming a fresh install of the OS, however that is **NOT** a requirement.

## Introduction

Documentation can take many forms in an organization. Having a repository that you can reference for that documentation is invaluable. A wiki (which means _quick_ in Hawaiian), is a way to keep documentation, process notes, corporate knowledge bases, and even code examples, in a centralized location. IT professionals who maintain a wiki, even secretly, have a built-in insurance policy against forgetting an obscure routine.

DokuWiki is a mature, fast, wiki that runs without a database, has built in security features, and is relatively easy to deploy. For more information on what DokuWiki can do, check out their [web page](https://www.dokuwiki.org/dokuwiki).

DokuWiki is just one of many wikis available, though it's a pretty good one. One big pro is that DokuWiki is relatively lightweight and can run on a server that is already running other services, provided you have space and memory available.

## Installing Dependencies

The minimum PHP version for DokuWiki is now 7.2, which is exactly what Rocky Linux 8 comes with. Rocky Linux 9.0 comes with PHP version 8.0, which is also fully supported. We are specifying packages here that may already be installed:

`dnf install tar wget httpd php php-gd php-xml php-json php-mbstring`

You will see a list of additional dependencies that will be installed and this prompt:

`Is this ok [y/N]:`

Go ahead and answer with "y" and hit 'Enter' to install.

## Create Directories And Modify Configuration

### Apache Configuration

If you have read through the [Apache Sites Enabled](../web/apache-sites-enabled.md) procedure, you know that we need to create a few directories. We will start with the _httpd_ configuration directory additions:

`mkdir -p /etc/httpd/{sites-available,sites-enabled}`

We need to edit the httpd.conf file:

`vi /etc/httpd/conf/httpd.conf`

And add this to the very bottom of the file:

`Include /etc/httpd/sites-enabled`

Create the site configuration file in sites-available:

`vi /etc/httpd/sites-available/com.example`

That configuration file should look something like this:

```
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

Note that the "AllowOverride All" above, allows the .htaccess (directory specific security) file to work.

Go ahead and link the configuration file into sites-enabled, but don't start web services as yet:

`ln -s /etc/httpd/sites-available/com.example /etc/httpd/sites-enabled/`

### Apache DocumentRoot

We also need to create our _DocumentRoot_. To do this:

`mkdir -p /var/www/sub-domains/com.example/html`

## Installing DokuWiki

In your server, change to the root directory.

`cd /root`

Now that we have our environment ready to go, let's  get the latest stable version of DokuWiki. You can find this by going to [the download page](https://download.dokuwiki.org/) and on the left-hand side of the page under "Version" you will see "Stable (Recommended) (direct link)."

Right-click on the "(direct link)" portion of this and copy the link address. In the console of your DokuWiki server, type "wget" and a space and then paste in your copied link in the terminal. You should get something like this:

`wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz`

Before we decompress the archive, take a look at the contents using `tar ztf` to see the contents of the archive:

`tar ztvf dokuwiki-stable.tgz`

Notice the named dated directory ahead of all the other files that looks something like this?

```
... (more above)
dokuwiki-2020-07-29/inc/lang/fr/resetpwd.txt
dokuwiki-2020-07-29/inc/lang/fr/draft.txt
dokuwiki-2020-07-29/inc/lang/fr/recent.txt
... (more below)
```
We don't want that leading named directory when we decompress the archive, so we are going to use some options with tar to exclude it. The first option is the "--strip-components=1" which removes that leading directory.

The second option is the "-C" option, and that tells tar where we want the archive to be decompressed to. So decompress the archive with this command:

`tar xzf dokuwiki-stable.tgz  --strip-components=1 -C /var/www/sub-domains/com.example/html/`

Once we have executed this command, all of DokuWiki should be in our _DocumentRoot_.

We need to make a copy of the _.htaccess.dist_ file that came with DokuWiki and keep the old one there too, in case we need to revert to the original in the future.

In the process, we will be changing the name of this file to simply _.htaccess_ which is what _apache_ will be looking for. To do this:

`cp /var/www/sub-domains/com.example/html/.htaccess{.dist,}`

Now we need to change ownership of the new directory and its files to the _apache_ user and group:

`chown -Rf apache.apache /var/www/sub-domains/com.example/html`

## Setting Up DNS Or /etc/hosts

Before you'll be able to access the DokuWiki interface, you'll need to set name resolution for this site. For testing purposes, you can use your _/etc/hosts_ file.

In this example, let's assume that DokuWiki will be running on a private IPv4 address of 10.56.233.179. Let's also assume that you are modifying the _/etc/hosts_ file on a Linux workstation. To do this, run:

`sudo vi /etc/hosts`

And then modify your hosts file to look something like this (note the IP address above in the below example):

```
127.0.0.1	localhost
127.0.1.1	myworkstation-home
10.56.233.179	example.com     example	

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Once you have finished testing and are ready to take things live for everyone, you will need to add this host to a DNS server. You could do this by using a [Private DNS Server](../dns/private_dns_server_using_bind.md), or a public-facing DNS server.

## Starting httpd

Before we start _httpd_ let's test to make sure that our configuration is OK:

`httpd -t`

You should get:

`Syntax OK`

If so, you should be ready to start _httpd_ and then finish the setup. Let's start by enabling _httpd_ to start on boot:

`systemctl enable httpd`

And then start it:

`systemctl start httpd`

## Testing DokuWiki

Now that our host name is set for testing and the web service has been started, the next step is to open up a web browser and type this in the address bar:

`http://example.com/install.php`

OR

`http://example.com/install.php`

Either should work if you set your hosts file as above. This will bring you to the setup screen so that you can finish the setup:

* In the "Wiki Name" field, type the name for our wiki. Example "Technical Documentation"
* In the "Superuser" field, type the administrative username. Example "admin"
* In the "Real name" field, type the real name for the administrative user.
* In the "E-Mail" field, type the email address of the administrative user.
* In the "Password" field, type the secure password for the administrative user.
* In the "once again" field, re-type that same password.
* In the "Initial ACL Policy" drop down, choose the option that works best for your environment.
* Choose the appropriate check box for the license you want to put your content under.
* Leave checked (or uncheck if you prefer) the "Once a month, send anonymous usage data to the DokuWiki developers" checkbox
* Click the "Save" button

Your wiki is now ready for you to add content.

## Securing DokuWiki

Besides the ACL policy that you just created, consider:

### Your Firewall

!!! note

    Neither of these firewall examples makes any sort of assumptions about what other services you might need to allow on your Dokuwiki server. These rules are based on our testing environment and **ONLY** deal with allowing access to a LOCAL network ip block. You will need more services allowed for a production server.

Before you call everything done, you need to think about security. First, you should be running a firewall on the server. We will assume you are using one of the firewalls below.

Instead of everyone having access to the wiki, we are going to assume that anyone on the 10.0.0.0/8 network is on your private Local Area Network, and that those are the only people who need access to the site.

#### `iptables` Firewall (deprecated)

!!! warning

    The `iptables` firewall process here has been deprecated in Rocky Linux 9.0 (still available, but likely to disappear in future releases, perhaps as early as Rocky Linux 9.1). For this reason, we recommend skipping to the `firewalld` procedure below if you are doing this on 9.0 or better. 

Please note that you may need other rules for other services on this server, and that this example only takes into account the web services.

First, modify or create the _/etc/firewall.conf_ file:

`vi /etc/firewall.conf`

```
#IPTABLES=/usr/sbin/iptables

#  Unless specified, the default for OUTPUT is ACCEPT
#  The default for FORWARD and INPUT is DROP
#
echo "   clearing any existing rules and setting default policy.."
iptables -F INPUT
iptables -P INPUT DROP
# web ports
iptables -A INPUT -p tcp -m tcp -s 10.0.0.0/8 --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 10.0.0.0/8 --dport 443 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```

Once the script is created, make sure it is executable:

`chmod +x /etc/firewall.conf`

Then execute the script:

`/etc/firewall.conf`

This will execute the rules and save them so that they will be reloaded on the next start of _iptables_ or on boot.

#### `firewalld` Firewall

If you are using `firewalld` as your firewall (and by this time, you probably *should* be) you can apply the same concepts using `firewalld's firewall-cmd` syntax.

We will duplicate the `iptables` rules (above) with `firewalld` rules:

```
firewall-cmd --zone=trusted --add-source=10.0.0.0/8 --permanent
firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent
firewall-cmd --reload
```

Once you have the above rules added and the firewalld service reloaded, list out your zone to make sure that everything is there that you need:

```
firewall-cmd --zone=trusted --list-all
```

which should show you something like this if all of the above has worked correctly:

```
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

For the best security, you should consider using an SSL so that all web traffic is encrypted. You can purchase an SSL from an SSL provider or use [Let's Encrypt](../security/generating_ssl_keys_lets_encrypt.md).

## Conclusion

Whether you need to document processes, company policies, program code, or something else, a wiki is a great way to get that done. DokuWiki is a product that is secure, flexible, easy to use, relatively easy to install and deploy, and is a stable project that has been around for many years.  
