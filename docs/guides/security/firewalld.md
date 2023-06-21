---
title: firewalld from iptables
author: Steven Spencer
contributors: wsoyinka, Antoine Le Morvan, Ezequiel Bruni, qyecst
update: 22-Jun-2023
tags:
  - security
  - firewalld
---

# `iptables` Guide To `firewalld` - Introduction

Ever since `firewalld` came out as the default firewall (I believe this was with CentOS 7, even though it was introduced in 2011), I've made it my mission in life to return to `iptables` at all costs. There were two reasons for this. First, the documentation that was available at the time used simplistic rules that did not properly show how the server was being secured *down to the IP level*. Second, and probably the primary reason: I had a long history with `iptables` going back many years, and it was frankly easier to just continue using `iptables`. Every server I deployed, whether it was public facing or internal, used an `iptables` firewall rule set. It was easy to simply adjust a default set of rules for the server we were dealing with and deploy. In order to do this on CentOS 7, CentOS 8, and now Rocky Linux 8, I needed to use [this procedure](enabling_iptables_firewall.md).

So why am I writing this document? First, to address the limitations of most `firewalld` references and, second, to force myself to find ways to use `firewalld` to mimic those more granular firewall rules.

And, of course, to help beginners get a handle on Rocky Linux's default firewall.

From the manual page: "`firewalld` provides a dynamically managed firewall with support for network/firewall zones to define the trust level of network connections or interfaces. It has support for IPv4, IPv6 firewall settings and for Ethernet bridges and has a separation of runtime and permanent configuration options. It also supports an interface for services or applications to add firewall rules directly."

Fun fact: `firewalld` is actually a front end to the netfilter and nftables Kernel sub-systems in Rocky Linux.

This guide focuses on applying rules from an `iptables` firewall to a `firewalld` firewall. If you are really at the beginning of your firewall journey, [this document](firewalld-beginners.md) might help you more. Consider reading through both documents to get the most out of `firewalld`.

## Prerequisites and Assumptions

* Throughout this document, we assume that you are either the root user or have used `sudo` to become so.
* A passing knowledge of firewall rules, particularly `iptables` or at minimum, a desire to learn something about `firewalld`.
* You feel comfortable entering commands at the command line.
* All of the examples here deal with IPv4 IPs.

## Zones

To really get your head around `firewalld`, you need to understand the use of zones. Zones are where the granularity of the firewall rule sets are applied.

`firewalld` has several built in zones:

| zone          | example use                                                                                                                                                                             |
|---------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| drop          | drop incoming connections without reply - only outgoing packets are allowed.                                                                                                            |
| block         | incoming connections are rejected with an icmp-host-prohibited message for IPv4 and icmp6-adm-prohibited for IPv6 - only network connections initiated within this system are possible. |
| public        | for use in public areas - only selected incoming connections are accepted.                                                                                                              |
| external      | for use on external networks with masquerading enabled - only selected incoming connections are accepted.                                                                               |
| dmz           | for computers on your demilitarized zone that are publicly-accessible with limited access to your internal network - only selected incoming connections are accepted.                   |
| work          | for computers in work areas (nope, I don't get this one either) - only selected incoming connections are accepted.                                                                      |
| home          | for use in home areas (nope, I don't get this one either) - only selected incoming connections are accepted.                                                                            |
| internal      | for your internal network device access - only selected incoming connections are accepted.                                                                                              |
| trusted       | all network connections are accepted.                                                                                                                                                   |

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

To be honest, I mostly hate the names of these zones. drop, block, public, and trusted are perfectly clear, but some aren't good enough for perfect granular security. Let's take this `iptables` rule section as an example:

`iptables -A INPUT -p tcp -m tcp -s 192.168.1.122 --dport 22 -j ACCEPT`

Here we have a single IP address being allowed for SSH (port 22) into the server. If we decide to use the built-in zones, we could use "trusted" for this. First, we would add the IP to the zone and second, we would apply the rule to the zone:

```
firewall-cmd --zone=trusted --add-source=192.168.1.122 --permanent
firewall-cmd --zone trusted --add-service=ssh --permanent
```

But what if on this server we also have an intranet that is accessible to only the IP blocks that our organization is assigned?  Would we use the "internal" zone now to apply to that rule? Frankly, I'd prefer to create a zone that deals with the admin users' IPs (those allowed to secure-shell into the server). Truth be told, I'd prefer to add all of my own zones, but that might be ridiculous to do.

### Adding Zones

To add a zone, we need to use the `firewall-cmd` with the `--new-zone` parameter. We are going to add "admin" (for administrative) as a zone:

`firewall-cmd --new-zone=admin --permanent`

!!! Note

    We have used the `--permanent` flag a great deal throughout. For testing, it is recommended to add the rule without the `--permanent` flag, test it, and if it works as expected, then use the `firewall-cmd --runtime-to-permanent` to move the rule live prior to running `firewall-cmd --reload`. If the risk is low (in other words, you won't lock yourself out), you can add the `--permanent` flag as I've done here.

Before this zone can actually be used, we need to reload the firewall:

`firewall-cmd --reload`

!!! tip

    A note about custom zones: If you need to add a zone that will be a trusted zone, but will only contain a particular source IP or interface and no protocols or services, and the "trusted" zone doesn't work for you, probably because you've already used it for something else, etc.  You can add a custom zone to do this, but you must change the target of the zone from "default" to "ACCEPT" (REJECT or DROP can also be used, depending on your goals). Here's an example using a bridge interface (lxdbr0 in this case) on an LXD machine.

    First, we add the zone and reload so that we can use it:

    ```
    firewall-cmd --new-zone=bridge --permanent
    firewall-cmd --reload
    ```

    Next, we change the target of the zone from "default" to "ACCEPT" (**note that the "--permanent" option is required for changing a target**) then assign the interface, and reload:

    ```
    firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
    firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
    firewall-cmd --reload
    ```

    This tells the firewall that you:

    1. are changing the target of the zone to ACCEPT
    2. are adding the bridge interface "lxdbr0" to the zone
    3. reloading the firewall

    All of which says that you are accepting all traffic from the bridge interface.

### Listing Zones

Before we go any further, we need to take a look at the process of listing zones. Rather than a tabular output provided by `iptables -L`, you get a single column of output with headers. Listing a zone is done with the command `firewall-cmd --zone=[zone_name] --list-all`. Here's what this looks like when we list out the newly created "admin" zone:

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

### Removing an IP and Service from a Zone

If you actually followed the earlier instruction adding the IP to the "trusted" zone, we need to now remove it from that zone. Remember our note about using the `--permanent` flag? This is a good place to avoid using it while doing proper testing before taking this rule live:

`firewall-cmd --zone=trusted --remove-source=192.168.1.122`

We also want to remove the service ssh from the zone:

`firewall-cmd --zone=trusted --remove-service ssh`

Then test. You want to make sure that you have a way in via `ssh` from another zone before doing the final two steps. (See **Warning** below!). If you've made no other changes, then the "public" zone will still have ssh allowed, as it is there by default.

Once you are satisfied, move the runtime rules to permanent:

`firewall-cmd --runtime-to-permanent`

and reload:

`firewall-cmd --reload`

!!! Warning

    If you're working on a remote server or VPS, hold off on that last instruction! *NEVER remove the `ssh` service from a remote server* unless you have another way to access the shell (see below).

    If you lock yourself out of `ssh` access via the firewall, you'll need to (in the worst-case scenarios) go fix your server in person, contact support, or possibly reinstall the OS from your control panel (depending on whether the server is physical or virtual).

### Using A New Zone - Adding Administrative IPs

Now just repeat our original steps using the "admin" zone:

```
firewall-cmd --zone=admin --add-source=192.168.1.122
firewall-cmd --zone admin --add-service=ssh
```

Now list the zone to make sure that the zone looks correct and has the service properly added:

`firewall-cmd --zone=admin --list-all`

Test your rule to make sure it works. To test:

1. SSH as root, or your sudo capable user, from your source IP (above it is 192.168.1.122) (*the root user is used here because we are going to run commands on the host that require it. If using your sudo user, remember to `sudo -s` once connected.*)
2. Once connected, run `tail /var/log/secure`  and you should get output that looks similar to this:

```bash
Feb 14 22:02:34 serverhostname sshd[9805]: Accepted password for root from 192.168.1.122 port 42854 ssh2
Feb 14 22:02:34 serverhostname sshd[9805]: pam_unix(sshd:session): session opened for user root by (uid=0)
```
This shows that the source IP for our SSH connection was indeed the same IP that we just added to the "admin" zone. So we should be safe to move this rule permanent:

`firewall-cmd --runtime-to-permanent`

When you've finished adding rules, don't forget to reload:

`firewall-cmd --reload`

There are obviously other services that might need to be added to the "admin" zone, but ssh is the most logical for now.

!!! Warning

    By default the "public" zone has the `ssh` service enabled; this can be a security liability. Once you have your administrative zone created, assigned to `ssh`, and tested, you can remove the service from the public zone.

If you have more than one administrative IP that you need to add (quite likely), then just add it to the sources for the zone. In this case, we are adding an IP to the "admin" zone:

`firewall-cmd --zone=admin --add-source=192.168.1.151 --permanent`

!!! Note

    Keep in mind that if you are working on a remote server or VPS, and have an internet connection that doesn't always use the same IP, you may want to open your `ssh` service to a range of IP addresses used by your internet service provider or geographical region. This, again, is so you don't get locked out by your own firewall.

    Many ISPs charge extra for dedicated IP addresses, if they're offered at all, so it's a real concern.

    The examples here assume that you are using IPs on your own private network to access a server that is also local.

## ICMP Rules

Let's look at another line in our `iptables` firewall that we want to emulate in `firewalld` - Our ICMP rule:

`iptables -A INPUT -p icmp -m icmp --icmp-type 8 -s 192.168.1.136 -j ACCEPT`

For the newbies among us, ICMP is a data transfer protocol designed for error reporting. Basically, it tells you when there's been any sort of problem connecting to a machine.

In reality, we would probably leave ICMP open to all of our local IPs (in this case 192.168.1.0/24). Keep in mind, though, that our "public" and "admin" zones will have ICMP on by default, so the first thing to do to limit ICMP to that one network address is to block these requests on "public" and "admin" .

Again, this is for demonstration purposes. You would definitely want your administrative users to have ICMP to your servers, and they probably still will, because they are members of the LAN network IP.

To turn off ICMP on the "public" zone, we would:

`firewall-cmd --zone=public --add-icmp-block={echo-request,echo-reply} --permanent`

And then do the same thing on our "trusted" zone:

`firewall-cmd --zone=trusted --add-icmp-block={echo-request,echo-reply} --permanent`

We've introduced something new here: The curly braces "{}" allow us to specify more than one parameter.  As always, after making changes like this, we need to reload:

`firewall-cmd --reload`

Testing by using ping from a disallowed IP will give you:

```bash
ping 192.168.1.104
PING 192.168.1.104 (192.168.1.104) 56(84) bytes of data.
From 192.168.1.104 icmp_seq=1 Packet filtered
From 192.168.1.104 icmp_seq=2 Packet filtered
From 192.168.1.104 icmp_seq=3 Packet filtered
```

## Web Server Ports

Here's the `iptables` script for publicly allowing `http` and `https`, the protocols you'd need to serve web pages:

```
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
```

And here's the `firewalld` equivalent that you have probably seen many times before:

```
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
```

OK, that is all fine, but what if you are running for example, a Nextcloud service on http/https and you only wanted your trusted network to have access to it?  It's not unusual! This sort of thing happens all the time, and just publicly allowing traffic, without considering who actually needs access, is a huge security hole.

We can't actually use the "trusted" zone information that we've used above. That was for testing. We have to assume that we have at minimum our LAN IP block added to "trusted". That would look like this:

`firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent`

Then we need to add the services to the zone:

`firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent`

If you had added those services to the "public" zone as well, you'd need to remove them:

`firewall-cmd --zone=public --remove-service=http --remove-service=https --permanent`

Now reload:

`firewall-cmd --reload`

## FTP Ports

Let's return to our `iptables` script. We have the following rules dealing with FTP:

```
iptables -A INPUT -p tcp -m tcp --dport 20-21 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 7000-7500 -j ACCEPT
```

This portion of the script deals with the standard FTP ports (20 and 21) as well as opening some additional passive ports. This sort of a rule set is often needed by such ftp servers as [VSFTPD](../file_sharing/secure_ftp_server_vsftpd.md). Generally, this sort of rule would be on a publicly facing web server, and is there for allowing ftp connections from your customers.

There is no ftp-data service (port 20) with `firewalld`. The ports 7000 through 7500 listed here are for passive FTP connections, and again, there's no direct way to do this in `firewalld`. You could switch to SFTP, which would simplify the port allow rules here, and is likely the recommended way these days.

What we are trying to demonstrate here, however, is the conversion of a set of `iptables` rules to `firewalld`. To get around all of these issues, we can do the following.

First, add the ftp service to the zone that is also hosting the web services. This is probably going to be "public" in this example:

`firewall-cmd --zone=public --add-service=ftp --permanent`

Then let's add the ftp-data port:

`firewall-cmd --zone=public --add-port=20/tcp --permanent`

Next let's add the passive connection ports:

`firewall-cmd --zone=public --add-port=7000-7500/tcp --permanent`

And then, you guessed it, reload:

`firewall-cmd --reload`

## Database Ports

If you are dealing with a web server, you are almost certainly dealing with a database. The access to that database should be handled with the same care that you apply to other services. If access is not needed from the world, apply your rule to something other than "public".  The other consideration is, do you need to offer access at all? Again, this probably depends on your environment. Where I was previously employed, we ran a hosted web server for our customers. Many had Wordpress sites, and none of them really needed or requested access to any front-end for `MariaDB`. If a customer needed more access, we created an LXD container for their web server, set up the firewall the way the customer wanted it, and left them responsible for what happened on the server. Still, if your server is public, you may need to offer access to `phpmyadmin` or some other front-end to `MariaDB`. In this case, you need to concern yourself with the password requirements for the database and set the database user to something other than defaults. For me, password length is the [primary consideration when creating passwords](https://xkcd.com/936/).

Obviously, password security is a discussion for another document dealing with just that, so we will assume that you've a good password policy for your database access and the `iptables` line in your firewall dealing with the database looks like this:

`iptables -A INPUT -p tcp -m tcp --dport=3600 -j ACCEPT`

 In this case, we simply add the service to the "public" zone for a `firewalld` conversion:

`firewall-cmd --zone=public --add-service=mysql --permanent`

### Postgresql Considerations

Postgresql uses it's own service port. Here's an IP tables rule example:

`iptables -A INPUT -p tcp -m tcp --dport 5432 -s 192.168.1.0/24 -j ACCEPT`

While it is less common on publicly facing web servers, it might be more common as an internal resource. The same security considerations apply. If you have a server on your trusted network (192.168.1.0/24 in our example), you might not want or need to give access to everyone on that network. Postgresql has an access list available to take care of the more granular access rights. Our `firewalld` rule would look something like this:

`firewall-cmd --zone=trusted --add-service=postgresql`

## DNS Ports

Having a private or public DNS server also means taking precautions in the rules you write to protect those services. If you have a private DNS server, with iptables rules that looked like this (note that most DNS services are UDP, rather than TCP, but not always):

`iptables -A INPUT -p udp -m udp -s 192.168.1.0/24 --dport 53 -j ACCEPT`

then allowing only your "trusted" zone would be correct. We've already setup our "trusted" zone's sources, so all you would need to do would be to add the service to the zone:

`firewall-cmd --zone=trusted --add-service=dns`

With a public facing DNS server, you would just need to add the same service to the "public" zone:

`firewall-cmd --zone=public --add-service=dns`

## More on Listing Rules

!!! Note

    You *can* list all of the rules if you like, by listing the nftables rules. It's ugly, and I don't recommend it, but if you really must, you can do a `nft list ruleset`.

One thing that we haven't done much of yet is to list the rules. This is something that you can do by zone. Here are examples with the zones we have used. Please note that you can list the zone before you move a rule permanent too, which is a good idea.

`firewall-cmd --list-all --zone=trusted`

Here we can see what we have applied above:

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

This can be applied to any zone. For instance, here is the "public" zone so far:

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
Note that we have removed "ssh" access from services and blocked icmp "echo-reply" and "echo-request".

In our "admin" zone so far, it looks like this:

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

## Establised Related Rules

Although I can find no document that specifically states this, it appears that `firewalld` handles the following `iptables` rule internally by default (if you know that this is incorrect, please correct this!):

`iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT`

## Interfaces

By default, `firewalld` will listen on all available interfaces. On a bare-metal server with multiple interfaces facing multiple networks, it will be necessary for you to assign an interface to a zone based on the network it faces.

In our examples, we've not added any interfaces, because we are working with an LXD container for lab testing. We only have one interface to work with. Let's say that your "public" zone needs to be configured to use Ethernet port enp3s0 as this port has the public IP on it, and let's say that your "trusted" and "admin" zones are on the LAN interface, which might be enp3s1.

To assign these zones to the appropriate interface, we would use the following commands:

```
firewall-cmd --zone=public --change-interface=enp3s0 --permanent
firewall-cmd --zone=trusted --change-interface=enp3s1 --permanent
firewall-cmd --zone=admin --change-interface=enp3s1 --permanent
firewall-cmd --reload
```
## Common firewall-cmd Commands

We've used some commands already. Here are a few more common commands and what they do:

| Command                                    | Result                                                                                                    |
|--------------------------------------------|-----------------------------------------------------------------------------------------------------------|
|`firewall-cmd --list-all-zones`             | similar to `firewall-cmd --list-all --zone=[zone]` except it lists *all* of the zones and their contents. |
|`firewall-cmd --get-default-zone`           | shows the default zone, which is "public" unless it has been changed.                                     |
|`firewall-cmd --list-services --zone=[zone]`| shows all of the services enabled for the zone.                                                           |
|`firewall-cmd --list-ports --zone=[zone]`   | shows all ports open on the zone.                                                                         |
|`firewall-cmd --get-active-zones`           | shows the zones that are active on the system, their active interfaces, services, and ports.              |
|`firewall-cmd --get-services`               | shows all available services possible for use.                                                            |
|`firewall-cmd --runtime-to-permanent`       | if you have entered many rules without the `--permanent` option, do this before reloading.                |

There are a great many `firewall-cmd` options not covered here, but this gives you the most used commands.

## Conclusion

Since `firewalld` is the recommended and included firewall with Rocky Linux, it is a good idea to get your head around how it works. Simplistic rules, included in documentation for applying services using `firewalld` often do not take into account what the server is being used for, and offer no options other than publicly allowing the service. This is a drawback that comes with security holes that just don't need to be there.

When you see these instructions, think about what your server is being used for and whether or not the service in question needs to be open to the world. If not, consider using more granularity in your rules as described above. While the author still isn't 100% commfortable with switching over to `firewalld`, it is highly probable that I'll use `firewalld` in future documentation.

The process of writing this document and lab-testing the results have been very helpful to me. Hopefully, they will be helpful to someone else as well. This is not meant to be an exhaustive guide to `firewalld`, but rather a starting point.                                         
