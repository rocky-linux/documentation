---
title: Apache Hardened Webserver
author: Steven Spencer
contributors: Ezequiel Bruni
tested with: 8.5
tags:
  - apache
  - web
  - security
---

# Apache Hardened Webserver

## Prerequisites and Assumptions

* A Rocky Linux web server running Apache
* A heavy comfort level with issuing commands from the command-line, viewing logs, and other general systems administrator duties
* A comfort level with a command line editor (our examples use _vi_ which will usually invoke the _vim_ editor, but you can substitute your favorite editor)
* Assumes an _iptables_ firewall, rather than _firewalld_ or a hardware firewall.
* Assumes the use of a gateway hardware firewall that our trusted devices will sit behind.
* Assumes a public IP address directly applied to the web server. We are substituting a private IP address for all of our examples.

## Introduction

Whether you are hosting multiple websites for customers, or a single, very important, website for your business, hardening your web server will give you peace of mind, at the expense of a little more up-front work for the administrator.

With multiple web sites uploaded by your customers, you can pretty much be guaranteed that one of them will upload a Content Management System (CMS) with the possibility of vulnerabilities. Most customers are focused on ease of use, not security, and what happens is that updating their own CMS becomes a process that falls out of their priority list altogether.

While notifying customers of vulnerabilities in their CMS may be possible for a company with a large IT staff, it may not be possible for a small department. The best defense is a hardened web server.

Web server hardening can take many forms, which may include any or all of the below tools, and possibly others not defined here.

You might elect to use a couple of these tools, and not the others, so for clarity and readability this document is split out into separate documents for each tool. The exception will be the packet-based firewall (_iptables_) which will be included in this main document.

* A good packet filter firewall based on ports (iptables, firewalld, or hardware firewall - we will use _iptables_ for our example) [_iptables_ procedure](#iptablesstart)
* A Host-based Intrusion Detection System (HIDS), in this case _ossec-hids_ [Apache Hardened Web Server - ossec-hids](ossec-hids.md)
* A Web-based Application Firewall (WAF), with _mod\_security_ rules [Apache Hardened Web Server - mod_security](modsecurity.md)
* Rootkit Hunter (rkhunter): A scan tool that checks against Linux malware [Apache Hardened Web Server - rkhunter](rkhunter.md)
* Database security (we are using _mariadb-server_ here) [MariaDB Database Server](../../database/database_mariadb-server.md)
* A secure FTP or SFTP server (we are using _vsftpd_ here) [Secure FTP Server - vsftpd](../../file_sharing/secure_ftp_server_vsftpd.md) but we also have _sftp_ and SSH lock down procedures [here](../../file_sharing/sftp.md)

This procedure does not replace the [Apache Web Server Multi-Site Setup](../apache-sites-enabled.md), it simply adds these security elements to it. If you haven't read it, take some time to look at it before proceeding.

## Other Considerations

Some of the tools outlined here have both free and fee-based options. Depending on your needs or support requirements, you may want to consider the fee-based versions. You should research what is out there and make a decision after weighing all of your options.

Know, too, that most of these options can be purchased as hardware appliances. If you'd prefer not to hassle with installing and maintaining your own system, there are options available other than those outlined here.

This document uses a straight _iptables_ firewall and requires [this procedure on Rocky Linux to disable firewalld and enable the iptables services](../../security/enabling_iptables_firewall.md). Since this document was first written, we now have a couple of excellent _firewalld_ guides; one that allows someone with knowledge of _iptables_ to transfer what they know to _firewalld_ [here](../../security/firewalld.md), and one that is a more dedicated to beginners [here](../../security/firewalld-beginners.md).

If you prefer to use _firewalld_, simply skip this step and apply the rules needed. The firewall in our examples here, needs no OUTPUT or FORWARD chains, only INPUT. Your needs may differ!

All of these tools need to be tuned to your system. That can only be done with careful monitoring of logs, and reported web experience by your customers. In addition, you will find that there will be ongoing tuning required over time.

Even though we are using a private IP address to simulate a public one, all of this _could_ have been done using a one-to-one NAT on the hardware firewall and connecting the web server to that hardware firewall, rather than to the gateway router, with a private IP address.

Explaining that requires digging into the hardware firewall shown below, and since that is outside of the scope of this document, it is better to stick with our example of a simulated public IP address.

## Conventions

* **IP Addresses:** We are simulating the public IP address here with a private block: 192.168.1.0/24 and we are using the LAN IP address block as 10.0.0.0/24  In other words, it cannot be routed over the Internet. In reality, neither IP block can be routed over the Internet as they are both reserved for private use, but there is no good way to simulate the public IP block, without using a real IP address that is assigned to some company. Just remember that for our purposes, the 192.168.1.0/24 block is the "public" IP block and the 10.0.0.0/24 is the "private" IP block.
* **Hardware Firewall:** This is the firewall that controls access to your server room devices from your trusted network. This is not the same as our _iptables_ firewall, though it could be another instance of _iptables_ running on another machine. This device will allow ICMP (ping) and SSH (secure shell) to our trusted devices. Defining this device is outside of the scope of this document. The author has used both [PfSense](https://www.pfsense.org/) and [OPNSense](https://opnsense.org/) and installed on dedicated hardware for this device with great success. This device will have two IP addresses assigned to it. One that will connect to the Internet router's simulated public IP (192.168.1.2) and one that will connect to our local area network, 10.0.0.1.
* **Internet Router IP:** We are simulating this with 192.168.1.1/24
* **Web Server IP:** This is the "public" IP address assigned to our web server. Again, we are simulating this with the private IP address 192.168.1.10/24

![Hardened Webserver](images/hardened_webserver_figure1.jpeg)

The diagram above shows our general layout. The _iptables_ packet-based firewall runs on the web server (shown above).


## Install Packages

Each individual package section has the needed installation files and any configuration procedure listed. The installation instructions for _iptables_ is part of the [disable firewalld and enable the iptables services](../../security/enabling_iptables_firewall.md) procedure.

## <a name="iptablesstart"></a>Configuring iptables

This portion of the documentation assumes that you have elected to install the _iptables_ services and utilities and that you are not planning on using _firewalld_.

If you are planning on using _firewalld_, you can use this _iptables_ script to guide you in creating the appropriate rules in the _firewalld_ format. Once the script is shown here, we will break it down to describe what is happening. Only the INPUT chain is needed here. The script is being placed in the /etc/ directory and for our example, it is named firewall.conf:

`vi /etc/firewall.conf`

and the contents will be:

```
#!/bin/sh
#
#IPTABLES=/usr/sbin/iptables

#  Unless specified, the defaults for OUTPUT is ACCEPT
#    The default for FORWARD and INPUT is DROP
#
echo "   clearing any existing rules and setting default policy.."
iptables -F INPUT
iptables -P INPUT DROP
iptables -A INPUT -p tcp -m tcp -s 192.168.1.2 --dport 22 -j ACCEPT
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -s 192.168.1.2 -j ACCEPT
# dns rules
iptables -A INPUT -p udp -m udp -s 8.8.8.8 --sport 53 -d 0/0 -j ACCEPT
iptables -A INPUT -p udp -m udp -s 8.8.4.4 --sport 53 -d 0/0 -j ACCEPT
# web ports
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
# ftp ports
iptables -A INPUT -p tcp -m tcp --dport 20-21 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 7000-7500 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```
So here's what is happening above:

* When we start, we flush all of the rules
* We then set the default policy for our INPUT chain to DROP, which says, "Hey, if we haven't explicitly allowed you here, then we are dropping you!"
* Then we allow SSH (port 22) from our trusted network, the devices behind the hardware firewall
* We allow DNS from some public DNS resolvers. (these can also be local DNS servers, if you have them)
* We allow our web traffic in from anywhere over port 80 and 443.
* We allow standard FTP (ports 20-21) and the passive ports needed to exchange two-way communications in FTP (7000-7500). These ports can be arbitrarily changed to other ports based on your ftp server configuration.
* We allow any traffic on the local interface (127.0.0.1)
* Then we say, that any traffic that has successfully connected based on the rules, should be allowed other traffic (ports) to maintain their connection (ESTABLISHED,RELATED).
* And finally, we reject all other traffic and set the script to save the rules where _iptables_ expects to find them.

Once this script is there, we need to make it executable:

`chmod +x /etc/firewall.conf`

We need to enable _iptables_ if we haven't already:

`systemctl enable iptables`

We need to start _iptables_:

`systemctl start iptables`

We need to run /etc/firewall.conf:

`/etc/firewall.conf`

If we add new rules to the /etc/firewall.conf, just run it again to take those rules live. Keep in mind that with a default DROP policy for the INPUT chain, if you make a mistake, you could lock yourself out remotely.

You can always fix this however, from the console on the server. Because the _iptables_ service is enabled, a reboot will restore all rules that have been added with `/etc/firewall.conf`.

## Conclusion

There are a number of ways to harden an Apache web server to make it more secure. Each operates independently of the other options, so you can choose to install any, or all, of them based on your needs.

Each requires some configuration with various tuning required for some to meet your specific needs. Since web services are constantly under attack 24/7 by unscrupulous actors, implementing at least some of these will help an administrator sleep at night.
