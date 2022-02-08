---
title: firewalld
author: Steven Spencer
contributors:
update:
---

# Basic Guide To `firewalld` - Introduction

Ever since `firewalld` came out as the default firewall (I believe this was with CentOS 7, even though it was introduced in 2011), I've made it my mission in life to return to `iptables` at all costs. There were two reasons for this. First, the documentation that was available at the time used simplistic rules that did not properly show how the server was being secured *down to the IP level*. Second, and probably the primary reason, I had a long history with `iptables` going back many years, and it was frankly easier to just continue using `iptables`. Every server I deployed, whether it was public facing or internal, used an `iptables` firewall rule set. It was easy to simply adjust a default set of rules for the server we were dealing with and deploy. In order to do this on CentOS 7, CentOS 8, and now Rocky Linux 8, I needed to use [this procedure](enabling_iptables_firewall.md). So why am I writing this document? First, to fix the limitations of most `firewalld` references and, second, to force myself to find ways to use `firewalld` to mimick those more granular firewall rules.

From the manual page: `firewalld` provides a dynamically managed firewall with support for network/firewall zones to define the trust level of network connections or interfaces. It has support for IPv4, IPv6 firewall settings and for Ethernet bridges and has a separation of runtime and permanent configuration options. It also supports an interface for services or applications to add firewall rules directly.

`firewalld` is actually a front end to the netfilter and nftables Kernel sub-systems in Rocky Linux.

## Prerequisites and Assumptions

* Throughout this document, we assume that you are either the root user or have used `sudo` to become so
* A passing knowledge of firewall rules, particularly `iptables` or at minimum, a desire to learn something about `firewalld`
* You feel comfortable entering commands at the command line.
* All of the examples here deal with IPv4 IPs.

## Zones

To really get your head around `firewalld`, you need to understand the use of zones. Zones are where the granularity of the firewall rule sets are applied.

`firewalld` has several built in zones:

| zone          | example use                                                                                                       |
|---------------|-------------------------------------------------------------------------------------------------------------------|
| drop          | drop incoming connections without reply - only outgoing packets are allowed                                      |
| block         | incoming connections are rejected with an icmp-host-prohibited message for IPv4 and icmp6-adm-prohibited for IPv6 |
| public        | all incoming connections are allowed                                                                              |
| external      | for use on external networks with masquerading enabled                                                            |
| dmz           | for computers on your demilitarized zone that are publicly-accessible with limited access to your internal network|
| work          | for computers in work areas (nope, I don't get this one either)                                                   |
| home          | for use in home areas (nope, I don't get this one either)                                                         |
| internal      | for your internal network device access                                                                           |
| trusted       | all network connections are accepted                                                                              |

!!! Note

firewall-cmd is the command line program for managing the firewalld daemon.

To list existing zones on your system, type:

`firewall-cmd --get-zones`

To be honest, I mostly hate the names of these zones. Drop, block, public, and trusted are perfectly clear, but some aren't good enough for perfect granular security. Let's take this `iptables` rule section as an example:


`iptables -A INPUT -p tcp -m tcp -s 192.168.1.122 --dport 22 -j ACCEPT`

Here we have a single IP address being allowed for SSH (port 22) into the server. If we decide to use the built-in zones, we could use "trusted" for this. First, we would add the IP to the zone and second, we would apply the rule to the zone:

```
firewall-cmd --zone=trusted --add-source=192.168.1.122 --permanent
firewall-cmd --zone trusted --add-service ssh --permanent
```
But what if on this server we also have an intranet that is accessible to only the IP blocks that our organization is assigned?  Would we use the "internal" zone now to apply to that rule? Frankly, I'd prefer to create a zone that deals with the admin users IPs (those allowed to secure-shell into the server). Truth be told, I'd prefer to add all of my own zones, but that might be ridiculous to do.

### Adding Zones

To add a zone, we need to use the `firewall-cmd` with the `--new-zone` parameter. We are going to add "admin" (for administrative) as a zone:

`firewall-cmd --new-zone admin --permanent`

!!! Note

    We have used the --permanent flag throughout. For testing, it is recommended to add the rule without the --permanent flag, test it, and if it works as expected, then use the `firewall-cmd --runtime-to-permanent` to move the rule live prior to running `firewall-cmd --reload`. Just be aware of this.

Before this zone can actually be used, we need to reload the firewall:

`firewall-cmd --reload`

### Removing an IP and Service from a Zone

If you actually followed the earlier instruction adding the IP to the "trusted" zone, we need to now remove it from that zone:

`firewall-cmd --zone=trusted --remove-source=192.168.1.122 --permanent`

We also want to remove the service ssh from the zone:

`firewall-cmd --zone trusted --remove-service ssh --permanent`

### Using A New Zone - Adding Administrative IPs

Now just repeat our original steps using the "admin" zone:

```
firewall-cmd --zone=admin --add-source=192.168.1.122 --permanent
firewall-cmd --zone admin --add-service ssh --permanent
```
There are obviously other services that might need to be added to the "admin" zone, but ssh is the most logical for now.

When you've finished adding rules, don't forget to reload:

`firewall-cmd --reload`

!!! Warning

    By default the "public" zone has the ssh service enabled. You need to remove the ssh service from public once you have your administrative zone created and assigned to ssh!

If you have more than one administrative IP that you need to add (quite likely), then just add it to the sources for the zone. In this case, we are adding an IP to the "admin" zone:

`firewall-cmd --zone=admin --add-source=192.168.1.151 --permanent`

## ICMP Rules

Let's look at another line in our `iptables` firewall that we want to emulate in `firewalld` - Our ICMP rule:

 `iptables -A INPUT -p icmp -m icmp --icmp-type 8 -s 192.168.1.136 -j ACCEPT`

 In reality, we would probably leave ICMP open to all of our local IPs (in this case 192.168.1.0/24). Keep in mind, though, that our "public" and "admin" zones will have ICMP on by default, so the first thing to do to limit ICMP to that one network address is to block these requests on "public" and "admin" (again, this is for demonstration purposes. You would definitely want your administrative users to have ICMP to your servers, and they probably still will, because they are members of the LAN network IP):

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

## Web Rules

Here's the `iptables` script for publicly allowing `http` and `https`:

```
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
```

And here's the `firewalld` equivalent that you have probably seen many times before:

```
firewall-cmd --zone=public --add-service=http --add-service=https --permanent
```

OK, that is all fine, but what if you are running for example, a Nextcloud service on http/https and you only wanted your trusted network to have access to it?  It's not unusual! This sort of thing happens all the time, and just publicly allowing traffic, without considering who actually needs access, is a huge security hole.

We can't actually use the trusted zone information that we've used above. That was for testing. We have to assume that we have at minimum our LAN IP block added to "trusted". That would look like this:

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

This portion of the script deals with the standard FTP ports (20 and 21) as well as opening some additional passive ports. This sort of a rule set is often needed by such ftp servers as [VSFTPD](../file_sharing/secure_ftp_server_vsftpd.md). Generally, this sort of rule would be on a publicly facing web server, and is there for allowing ftp connections from your customers. There is no ftp-data service (port 20) with `firewalld`. The ports 7000 through 7500 listed here are for passive FTP connections, and again, there's no direct way to do this in `firewalld`. You could switch to SFTP, which would simplify the port allow rules here, and is likely the recommended way these days. What we are trying to demonstrate here, however, is the conversion of a set of `iptables` rules to `firewalld`. To get around all of these issues, we can do the following:

First, add the ftp service to the zone that is also hosting the web services. This is probably going to be "public" in this example:

`firewall-cmd --zone=public --add-service=ftp --permanent`

Then let's add the ftp-data port

`firewall-cmd --zone=public --add-port=20/tcp --permanent`

Next let's add the passive connection ports:

`firewall-cmd --zone=public --add-port=7000-7500/tcp`

And then, you guessed it, reload:

`firewall-cmd --reload`

## Listing Rules

!!! Note

    You *can* list all of the rules if you like, by listing the nftables rules. It's ugly, and I don't recommend it, but if you really must, you can do a `nft list ruleset`.

One thing that we haven't done yet is to list the rules. This is something that you can do by zone. Here are examples with the zones we have used:

`firewall-cmd --list-all --zone=trusted`

Here we can see what we have applied above:

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-reply echo-request
  rich rules:
```

This can be applied to any zone. For instance, here is the "public" zone so far. Note that the `http` and `https` are not listed here. They are in the "trusted" zone where we added them earlier. The ftp ports *do* show here however:

`firewall-cmd --list-all --zone=public`

```bash
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client ftp
  ports: 20/tcp 7000-7500/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks: echo-reply echo-request
  rich rules:
```
Note that we have removed "ssh" access form services and blocked icmp echo-reply and echo-request.

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
Although I can find no document that specifically states this, it appears that `firewalld` handles the following `iptables` rule internally by default (if you know that this is incorrect, please correct this!):

`iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT`

## Interfaces

By default, `firewalld` will listen on all available interfaces. On a bare-metal server with multiple interfaces facing multiple networks, it will be necessary for you to assign an interface to a zone based on the network it faces. In our examples, we've not added any interfaces, because we are working with an LXD container for lab testing. We only have one interface to work with. Let's say that your "public" zone needs to be configured to use Ethernet port enp3s0 as this port has the public IP on it, and let's say that your "trusted" and "admin" zones are on the LAN interface, which might be enp3s1. To assign these zones to the appropriate interface, we would use the following commands:

```
firewall-cmd --zone=public --change-interface=enp3s0 --permanent`
firewall-cmd --zone=trusted --change-interface=enp3s1 --permanent`
firewall-cmd --zone=admin --change-interface=enp3s1 --permanent`
firewall-cmd --reload
```
## Common firewall-cmd Commands

We've used some commands already. Here are a few more common commands and what they do:

| Command                             | Result                                                                                                    |
|-------------------------------------|-----------------------------------------------------------------------------------------------------------|
|`firewall-cmd --list-all-zones`      | similar to `firewall-cmd --list-all --zone=[zone]` except it lists *all* of the zones and their contents. |
|`firewall-cmd --get-default-zone`    | shows the default zone, which is "public" unless it has been changed.                                     |
|`firewall-cmd --list-services --zone=[zone]`| shows all of the services enabled for the zone.                                                    |
|`firewall-cmd --list-ports --zone=[zone]`| shows all ports open on the zone.                                                                     |
|`firewall-cmd --get-active-zones`    | shows the zones that are active on the system, their active interfaces, services, and ports.              |
|`firewall-cmd --get-services`        | shows all available services possible for use.                                                            |
|`firewall-cmd --runtime-to-permanent`| if you have entered many rules without the --permanent option, do this before reloading.                  |

There are a great many `firewall-cmd` options not covered here, but this gives you the most used commands.

## Conclusion

Since `firewalld` is the recommended and included firewall with Rocky Linux, it is a good idea to get your head around how it  works. Simplistic rules, included in documentation for applying services using `firewalld` often do not take into account what the server is being used for, and offer no options other than publicly allowing the service. This is a drawback that comes with security holes that just don't need to be there. When you see these instructions, think about what your server is being used for and whether or not the service in question needs to be open to the world. If not, consider using more granularity in your rules as described above. While the author still isn't 100% commfortable with switching over to `firewalld`, it is highly probable that I'll use `firewalld` in future documentation. The process of writing this document and lab-testing the results have been very helpful to me. Hopefully, they will be helpful to someone else as well.

This is not meant to be an exhaustive guide to `firewalld`, but rather a starting point.                                         
