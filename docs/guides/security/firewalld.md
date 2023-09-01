---
title: firewalld from iptables
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni, qyecst
update: 22-Jun-2023
tags:
  - security
  - firewalld
---

# `iptables` guide to `firewalld` - Introduction


When the introduction of `firewalld` as the default firewall happened (Its introduction was in 2011, but I believe it showed up first in CentOS 7.), the author continued to use `iptables`. There were two reasons for this. First, the documentation available at the time for `firewalld` used simplistic rules and did not show how `firewalld` was securing the server *down to the IP level*. Second, the author had over a decade of experience with `iptables` and it was easier to continue using that instead of learning `firewalld`. 

This document aims to address the limitations of most `firewalld` references and, to force the author to use `firewalld` to mimic those more granular firewall rules.

From the manual page: "`firewalld` provides a dynamically managed firewall with support for network/firewall zones to define the trust level of network connections or interfaces. It supports IPv4, IPv6 firewall settings, Ethernet bridges and a separation of runtime and permanent configuration options. It also supports an interface for services or applications to add firewall rules directly."

`firewalld` is actually a front end to the netfilter and nftables Kernel sub-systems in Rocky Linux.

This guide focuses on applying rules from an `iptables` firewall to a `firewalld` firewall. If you are really at the beginning of your firewall journey, [this document](firewalld-beginners.md) might help you more. Consider reading both documents to get the most out of `firewalld`.

## Prerequisites and assumptions

* Throughout this document, the assumption is that you are the root user or have elevated privileges with `sudo`.
* A passing knowledge of firewall rules, particularly `iptables` or at minimum, you want to learn something about `firewalld`.
* You feel comfortable entering commands at the command line.
* All of the examples here deal with IPv4 IPs.

## Zones

To really get your head around `firewalld`, you need to understand the use of zones. Zones provide the granularity of the firewall rule sets.

`firewalld` has several built-in zones:

| zone          | example use                                                                                                                                                                             |
|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| drop          | drops incoming connections without reply - allows only outgoing packets.                                                                                                                |
| block         | rejects incoming connections with an icmp-host-prohibited message for IPv4 and icmp6-adm-prohibited for IPv6 - only network connections initiated within this system are possible.      |
| public        | for use in public areas - accepts only selected incoming connections.                                                                                                                   |
| external      | accepts only selected incoming connections for use on external networks with masquerading enabled.                                                                                      |
| dmz           | only selected incoming connections are accepted for publicly accessible computers on your demilitarized zone with limited access to your internal network.                              |
| work          | for computers in work areas  - accepts only selected incoming connections.                                                                                                              |
| home          | for use in home areas - accepts only selected incoming connections                                                                                                                      |
| internal      | for your internal network device access - accepts only selected incoming connections.                                                                                                   |
| trusted       | accepts all network connections.                                                                                                                                                        |

!!! Note

    `firewall-cmd` is the command line program for managing the `firewalld` daemon.

To list existing zones on your system, type:

`firewall-cmd --get-zones`

!!! Warning

    Remember to check the status of your firewall, if the `firewalld-cmd` returns you an error, with either:

    the `firewall-cmd` command:

    ```
    $ firewall-cmd --state
    running
    ```

    the `systemctl` command:

    ```
    $ systemctl status firewalld
    ```

The author does not like most of these zone names. drop, block, public, and trusted are perfectly clear, but some are not good enough for perfect granular security. Take this `iptables` rule section as an example:

`iptables -A INPUT -p tcp -m tcp -s 192.168.1.122 --dport 22 -j ACCEPT`

Here you are allowing a single IP address for SSH (port 22) into the server. If you decide to use the built-in zones, you could use "trusted" for this. First, you add the IP to the zone and second, you apply the rule to the zone:

```
firewall-cmd --zone=trusted --add-source=192.168.1.122 --permanent
firewall-cmd --zone trusted --add-service=ssh --permanent
```

But what if, on this server, you also have an intranet that is accessible to only the IP blocks assigned to your organization? Would you now apply the "internal" zone to that rule? The author prefers to create a zone that deals with the admin users' IPs (those allowed to secure-shell into the server).

### Adding zones

To add a zone, you need to use the `firewall-cmd` with the `--new-zone` parameter. You are going to add "admin" (for administrative) as a zone:

`firewall-cmd --new-zone=admin --permanent`

!!! Note

    The author uses the `--permanent` flag a great deal throughout. For testing, it is recommended to add the rule without the `--permanent` flag, test it, and if it works as expected, then use the `firewall-cmd --runtime-to-permanent` to move the rule live prior to running `firewall-cmd --reload`. If the risk is low (in other words, you will not lock yourself out), you can add the `--permanent` flag as done here.

Before using this zone, you need to reload the firewall:

`firewall-cmd --reload`

!!! tip

    A note about custom zones: If you need to add a zone that will be a trusted zone, but will only contain a particular source IP or interface and no protocols or services, and the "trusted" zone does not work for you, probably because you have already used it for something else, etc.  You can add a custom zone to do this, but you must change the target of the zone from "default" to "ACCEPT" (REJECT or DROP can also be used, depending on your goals). Here is an example using a bridge interface (lxdbr0 in this case) on an LXD machine.

    First, you add the zone and reload so that you can use it:

    ```
    firewall-cmd --new-zone=bridge --permanent
    firewall-cmd --reload
    ```

    Next, you change the target of the zone from "default" to "ACCEPT" (**note that the "--permanent" option is required for changing a target**) then assign the interface, and reload:

    ```
    firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
    firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
    firewall-cmd --reload
    ```

    This tells the firewall that you:

    1. are changing the target of the zone to ACCEPT
    2. are adding the bridge interface "lxdbr0" to the zone
    3. reloading the firewall

    All of this says that you accept all traffic from the bridge interface.

### Listing zones

Before going any further, you need to examine the process of listing zones. You get a single production column rather than a tabular output provided by `iptables -L`. List a zone with the command `firewall-cmd --zone=[zone_name] --list-all`. Here is what this looks like when you list out the newly created "admin" zone:


`firewall-cmd --zone=admin --list-all`

```bash
admin
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
You can list out the active zones on your system by using this command:

`firewall-cmd --get-active-zones`

!!! Note "Important: Active Zones"

    A zone can *only* be in an active state if it has one of these two conditions:

    1. The zone is assigned to a network interface.
    2. The zone is assigned source IPs or network ranges.

### Removing an IP and service from a zone

If you followed the earlier instruction to add an IP to the "trusted" zone, you must remove it now. Remember our note about using the `--permanent` flag? This is a good place to avoid using it while doing proper testing before taking this rule live:

`firewall-cmd --zone=trusted --remove-source=192.168.1.122`

You also want to remove the service SSH from the zone:

`firewall-cmd --zone=trusted --remove-service ssh`

Then test. You want to ensure that you have a way in via `ssh` from another zone before doing the final two steps. (See **Warning** below!). If you have made no other changes, the "public" zone will still have SSH allowed, as it is there by default.

Once you are satisfied, move the runtime rules to permanent:

`firewall-cmd --runtime-to-permanent`

and reload:

`firewall-cmd --reload`

!!! Warning

    Hold off on that last instruction If you are working on a remote server or VPS! *NEVER remove the `ssh` service from a remote server* unless you have another way to access the shell (see below).

     Suppose you lock yourself out of ssh access via the firewall. In that case, you will need to (in the worst-case scenarios) fix your server in person, contact support, or possibly reinstall the OS from your control panel (depending on whether the server is physical or virtual).

### Using a new zone - Adding administrative IPs

Now just repeat our original steps using the "admin" zone:

```
firewall-cmd --zone=admin --add-source=192.168.1.122
firewall-cmd --zone admin --add-service=ssh
```

List the zone to ensure that the zone looks correct and has the service properly added:

`firewall-cmd --zone=admin --list-all`

Test your rule to ensure it works. To test:

1. SSH as root, or your sudo capable user, from your source IP (above it is 192.168.1.122) (*use the root user because you are going to run commands on the host that require it. If using your sudo user, remember to `sudo -s` once connected.*)
2. Once connected, run `tail /var/log/secure`  and you will get output that looks similar to this:

```bash
Feb 14 22:02:34 serverhostname sshd[9805]: Accepted password for root from 192.168.1.122 port 42854 ssh2
Feb 14 22:02:34 serverhostname sshd[9805]: pam_unix(sshd:session): session opened for user root by (uid=0)
```
This shows that the source IP for our SSH connection is the same IP that you just added to the "admin" zone. You will be safe to move this rule permanent:

`firewall-cmd --runtime-to-permanent`

When you have finished adding rules, reload:

`firewall-cmd --reload`

You might require other services added to the "admin" zone, but SSH is the most logical for now.

!!! Warning

    By default the "public" zone has the `ssh` service enabled; this can be a security liability. Once you have your administrative zone created, assigned to `ssh`, and tested, you can remove the service from the public zone.

If you have more than one administrative IP that you need to add (quite likely), just add it to the sources for the zone. In this case, you are adding an IP to the "admin" zone:

`firewall-cmd --zone=admin --add-source=192.168.1.151 --permanent`

!!! Note

    Keep in mind that if you are working on a remote server or VPS, and have an internet connection that does not always use the same IP, you may want to open your `ssh` service to a range of IP addresses used by your internet service provider or geographical region. This, again, is so you do not get locked out by your own firewall.

    Many ISPs charge extra for dedicated IP addresses, if they are offered at all, so it is a real concern.

    The examples here assume that you are using IPs on your own private network to access a server that is also local.

## ICMP rules

Examine another line in our `iptables` firewall that you want to emulate in `firewalld` - the ICMP rule:

`iptables -A INPUT -p icmp -m icmp --icmp-type 8 -s 192.168.1.136 -j ACCEPT`

For the newbies among us, ICMP is a data transfer protocol designed for error reporting. It tells you when problems connecting to a machine exist.

In reality, you will probably leave ICMP open to all of our local IPs (in this case 192.168.1.0/24). Our "public" and "admin" zones will have ICMP on by default, so the first thing to do to limit ICMP to that one network address is to block these requests on "public" and "admin" .

Again, this is for demonstration purposes. You will definitely want your administrative users to have ICMP to your servers, and they probably still will, because they are members of the LAN network IP.

To turn off ICMP on the "public" zone:

`firewall-cmd --zone=public --add-icmp-block={echo-request,echo-reply} --permanent`

Do the same thing on our "trusted" zone:

`firewall-cmd --zone=trusted --add-icmp-block={echo-request,echo-reply} --permanent`

Here is an introduction to something new: The curly braces "{}" allow us to specify more than one parameter. As always, after making changes like this, you need to reload:

`firewall-cmd --reload`

Testing by using ping from a disallowed IP will give you:

```bash
ping 192.168.1.104
PING 192.168.1.104 (192.168.1.104) 56(84) bytes of data.
From 192.168.1.104 icmp_seq=1 Packet filtered
From 192.168.1.104 icmp_seq=2 Packet filtered
From 192.168.1.104 icmp_seq=3 Packet filtered
```

## Web server ports

Here is the `iptables` script for publicly allowing `http` and `https`, the protocols you will need to serve web pages:

```
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
```

And here is the `firewalld` equivalent that you have probably seen many times before:

```
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
```

That is fine, but what if you are running for example, a Nextcloud service on http/https and you only wanted your trusted network to have access to it? It is not unusual! This sort of thing happens all the time, and just publicly allowing traffic, without considering who actually needs access, is a huge security risk.

You cannot actually use the "trusted" zone information that you have used above. That was for testing. You have to assume that you have at minimum our LAN IP block added to "trusted". That will look like this:

`firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent`

Add the services to the zone:

`firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent`

If you had added those services to the "public" zone, you need to remove them:

`firewall-cmd --zone=public --remove-service=http --remove-service=https --permanent`

Reload:

`firewall-cmd --reload`

## FTP ports

Returning to the `iptables` script. You have the following rules dealing with FTP:

```
iptables -A INPUT -p tcp -m tcp --dport 20-21 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 7000-7500 -j ACCEPT
```

This portion of the script deals with the standard FTP ports (20 and 21) and some additional passive ports. FTP servers such as [VSFTPD](../file_sharing/secure_ftp_server_vsftpd.md) often need these sort of rules. Generally, this sort of rule will be on a publicly facing web server, and is there for allowing ftp connections from your customers.

No ftp-data service (port 20) exists in `firewalld`. The ports 7000 through 7500 listed here are for passive FTP connections, and again, these do not exist as a service in `firewalld`. You could switch to SFTP, which simplifies the port-allow rules here and is likely the recommended way. 

This demonstrates the conversion of a set of `iptables` rules to `firewalld`. To get around all of these issues, you can do the following.

First, add the ftp service to the zone that is also hosting the web services. This is probably going to be "public" in this example:

`firewall-cmd --zone=public --add-service=ftp --permanent`

Add the ftp-data port:

`firewall-cmd --zone=public --add-port=20/tcp --permanent`

Add the passive connection ports:

`firewall-cmd --zone=public --add-port=7000-7500/tcp --permanent`

Then reload:

`firewall-cmd --reload`

## Database ports

If you are dealing with a web server, you are almost certainly dealing with a database. You handle access to that database with the same care that you apply to other services. If access is not needed from the world, apply your rule to something other than "public".  The other consideration is, do you need to offer access at all? Again, this probably depends on your environment. Where the author was previously employed, a hosted web server was in use for our customers. Many had Wordpress sites, and none of them really needed or requested access to any front-end for `MariaDB`. If a customer needed more access, our solution was the creation of an LXD container for their web server, building a firewall the way the customer wanted, and leaving them responsible for what happened on that server. Still, if your server is public, you might need to offer access to `phpmyadmin` or some other front-end to `MariaDB`. In this case, you need to concern yourself with the password requirements for the database and set the database user to something other than defaults. For the author, password length is the [primary consideration when creating passwords](https://xkcd.com/936/).

Password security is a discussion for another document dealing with that. The assumption is that you have a good password policy for your database access and the `iptables` line in your firewall dealing with the database looks like this:

`iptables -A INPUT -p tcp -m tcp --dport=3600 -j ACCEPT`

 In this case, add the service to the "public" zone for a `firewalld` conversion:

`firewall-cmd --zone=public --add-service=mysql --permanent`

### Postgresql considerations

Postgresql uses its service port. Here is an IP tables rule example:

`iptables -A INPUT -p tcp -m tcp --dport 5432 -s 192.168.1.0/24 -j ACCEPT`

While it is less common on publicly facing web servers, it might be more common as an internal resource. The same security considerations apply. If you have a server on your trusted network (192.168.1.0/24 in our example), you might not want or need to give access to everyone on that network. Postgresql has an access list available for the more granular access rights. Our `firewalld` rule would look something like this:

`firewall-cmd --zone=trusted --add-service=postgresql`

## DNS ports

Having a private or public DNS server also means taking precautions in the rules you write to protect those services. If you have a private DNS server, with iptables rules that looked like this (note that most DNS services are UDP, rather than TCP, but not always):

`iptables -A INPUT -p udp -m udp -s 192.168.1.0/24 --dport 53 -j ACCEPT`

then allowing only your "trusted" zone will be correct. You have already setup your "trusted" zone's sources. All you need to do is to add the service to the zone:

`firewall-cmd --zone=trusted --add-service=dns`

With a public facing DNS server, you would just need to add the same service to the "public" zone:

`firewall-cmd --zone=public --add-service=dns`

## More on listing rules

!!! Note

    You *can* list all of the rules if you like, by listing the nftables rules. It is ugly, and I do not recommend it, but if you really must, you can do a `nft list ruleset`.

One thing not done much so far is to list the rules. This is something that you can do by zone. Here are examples with the zones you have used. Note that you can list the zone before you move a rule permanent too, which is a good idea.

`firewall-cmd --list-all --zone=trusted`

Here you can see what you applied above:

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: dns
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-reply echo-request
  rich rules:
```

This is applicable to any zone. For instance, here is the "public" zone so far:

`firewall-cmd --list-all --zone=public`

```bash
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client ftp http https
  ports: 20/tcp 7000-7500/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-reply echo-request
  rich rules:
```
Note that you have removed SSH access from services and blocked ICMP "echo-reply" and "echo-request".

In your "admin" zone so far, it looks like this:

`firewall-cmd --list-all --zone=admin`

```bash
  admin (active)
  target: default
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.122 192.168.1.151
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

## Established related rules

It appears that `firewalld` handles the following `iptables` rule internally by default:

`iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT`

## Interfaces

By default, `firewalld` will listen on all available interfaces. On a bare-metal server with many interfaces facing many network gateways, it will be necessary for you to assign an interface to a zone based on the network it faces.

Interfaces are not added in our examples, because the lab uses LXD for testing. In this case, you only have one interface to work with. Say that your "public" zone needs configuration to use Ethernet port enp3s0 as this port has the public IP on it, and say that your "trusted" and "admin" zones are on the LAN interface, which might be enp3s1.

To assign these zones to the appropriate interface, you use the following commands:

```
firewall-cmd --zone=public --change-interface=enp3s0 --permanent
firewall-cmd --zone=trusted --change-interface=enp3s1 --permanent
firewall-cmd --zone=admin --change-interface=enp3s1 --permanent
firewall-cmd --reload
```
## Common firewall-cmd commands

You have used some commands already. Here are a few more common commands and what they do:

| Command                                    | Result                                                                                                    |
|--------------------------------------------|-----------------------------------------------------------------------------------------------------------|
|`firewall-cmd --list-all-zones`             | similar to `firewall-cmd --list-all --zone=[zone]` except it lists *all* of the zones and their contents. |
|`firewall-cmd --get-default-zone`           | shows the default zone, which is "public" unless you change it.                                           |
|`firewall-cmd --list-services --zone=[zone]`| shows all of the services enabled for the zone.                                                           |
|`firewall-cmd --list-ports --zone=[zone]`   | shows all ports open on the zone.                                                                         |
|`firewall-cmd --get-active-zones`           | shows the active zones on the system, their active interfaces, services, and ports.                       |
|`firewall-cmd --get-services`               | shows all available services possible for use.                                                            |
|`firewall-cmd --runtime-to-permanent`       | if you have entered many rules without the `--permanent` option, do this before reloading.                |

A great many `firewall-cmd` options are not covered here, but this gives you the most used commands.

## Conclusion

Since `firewalld` is the recommended and included firewall with Rocky Linux, it is a good idea to get your head around how it works. Simplistic rules, included in the documentation for applying services using `firewalld`, often do not consider the server's use and offer no options other than publicly allowing the service. This is a drawback with security holes that just do not need to be there.

When you see these instructions, think about what your server's use and whether the service needs to be open to the world. If not, consider applying more granularity in your rules as described above.

This is not meant to be an exhaustive guide to `firewalld`, but rather a starting point.                                         
