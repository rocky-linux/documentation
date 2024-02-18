---
Title: Lab 8 - iptables
author: Wale Soyinka
contributors:
---


# Lab 8: `iptables`

## Objectives

After completing this lab, you will be able to

- configure basic IP filter rules
- configure IP forwarding  

Estimated time to complete this lab: 60 minutes

> I always use iptables on my Linux boxes. Look - even if you don't want to keep hackers out, you can do things like block advertising sites like* doubleclick.com and other evil bastards. Or maybe you just want to do a bit more logging? …Iptables rule!

-- George W.Bush

## `iptables`

`iptables` is a tool used for managing the IPv4 packet filtering and NAT subsystem of the Linux kernel. The sub-system is known as netfilter.

The `iptables` command-line utility provides the front end (user-land)  tools to manage that sub-system. It is used to set up, maintain, and inspect the tables of IP packet filter rules in the kernel. Several different tables may be defined.

Some common terminologies used in `iptables` discussions are described below:

### TABLES

Out of the box, three independent tables are defined in most Linux Kernels. The tables present at any time depend on the kernel configuration options and which  modules are present. The tables are:

- filter: This is the main and default table (if no -t option is passed). It  contains the built-in chains:

    - **INPUT** (for packets coming into the box itself)
    - **FORWARD** (for packets being routed through the box)
    - **OUTPUT** (for locally generated packets).

- nat: This table is consulted when a packet that creates a new connection is encountered. It consists of the following three built-in chains:

    - **PREROUTING** (for  altering  packets  as  soon  as they come in)
    - **OUTPUT** (for altering  locally generated packets before routing)
    - **POSTROUTING** (for altering packets as they are about to go out)

- mangle: This table is used for  specialized  packet  alteration. It has the following 5 built-in chains:

    - **PREROUTING** (for altering incoming packets before routing)
    - **OUTPUT** (for altering locally generated packets before routing)
    - **INPUT** (for packets  coming  into the box itself)
    - **FORWARD** (for altering packets being routed through the box)
    - **POSTROUTING**  (for altering packets as they are about to go out)

### CHAINS

A chain is a list of rules which can match a set of  packets. Each rule specifies what to do with a packet that matches. Each table contains a number of built-in chains and may also contain user-defined chains. 

### TARGETS

A firewall rule specifies criteria for a packet, and a target. If the packet does not match, the next rule in the chain is the  examined; if it does match, then the next rule is specified by the value of the target, which can be the name of a user-defined chain or one of the special values ACCEPT, DROP, QUEUE, or RETURN.

```bash

Usage: iptables -[ACD] chain rule-specification [options]
       iptables -I chain [rulenum] rule-specification [options]
       iptables -R chain rulenum rule-specification [options]
       iptables -D chain rulenum [options]
       iptables -[LS] [chain [rulenum]] [options]
       iptables -[FZ] [chain] [options]
       iptables -[NX] chain
       iptables -E old-chain-name new-chain-name
       iptables -P chain target [options]
       iptables -h (print this help information)

Commands:
Either long or short options are allowed.
  --append  -A chain Append to chain
  --check   -C chain Check for the existence of a rule
  --delete  -D chain Delete matching rule from chain
  --delete  -D chain rulenum
    Delete rule rulenum (1 = first) from chain
  --insert  -I chain [rulenum]
    Insert in chain as rulenum (default 1=first)
  --replace -R chain rulenum
    Replace rule rulenum (1 = first) in chain
  --list    -L [chain [rulenum]]
    List the rules in a chain or all chains
  --list-rules -S [chain [rulenum]]
    Print the rules in a chain or all chains
  --flush   -F [chain] Delete all rules in  chain or all chains
  --zero    -Z [chain [rulenum]]
    Zero counters in chain or all chains
  --new     -N chain Create a new user-defined chain
  --delete-chain
    -X [chain] Delete a user-defined chain
  --policy  -P chain target
    Change policy on chain to target
  --rename-chain
            -E old-chain new-chain
                Change chain name, (moving any references)

Options:
    --ipv4 -4 Nothing (line is ignored by ip6tables-restore)
    --ipv6 -6 Error (line is ignored by iptables-restore)
[!] --protocol -p proto protocol: by number or name, eg. `tcp'
[!] --source -s address[/mask][...]
        source specification
[!] --destination -d address[/mask][...]
        destination specification
[!] --in-interface -i input name[+]
        network interface name ([+] for wildcard)
 --jump -j target
    target for rule (may load target extension)
  --goto      -g chain
    jump to chain with no return
  --match -m match
    extended match (may load extension)
  --numeric -n numeric output of addresses and ports
[!] --out-interface -o output name[+]
    network interface name ([+] for wildcard)
  --table -t table table to manipulate (default: `filter')
  --verbose -v verbose mode
  --wait -w [seconds] maximum wait to acquire xtables lock before give up
  --line-numbers print line numbers when listing
  --exact -x expand numbers (display exact values)
[!] --fragment -f match second or further fragments only
  --modprobe=<command> try to insert modules using this command
  --set-counters -c PKTS BYTES set the counter during insert/append
[!] --version -V print package version.

```

### Exercise 1

`iptables` essentials

This exercise will teach you some `iptables` essentials. In particular, you will learn how to view or list `iptables` rules, create basic filtering rules, delete rules, create/delete custom chains and so on.

Without further ado let's dive straight into using `iptables`.

#### To view the current rules

1. While logged in as the superuser list all the rules in the filter table. Type:

    ```bash
    [root@serverXY root]# iptables -L
    ```

2. To view a more verbose output type:

    ```bash
    [root@serverXY root]# iptables -L -v
    ```

3. Display only the rules under the INPUT chain. Type:

    ```bash
    [root@serverXY root]# iptables -v  -L INPUT
    ```

4. Display all the rules under the mangle table. Type:

    ```bash
    [root@serverXY root]#  iptables  -L  -t   mangle
    ```

5. Display all the rules under the nat table. Type:

    ```bash
    [root@serverXY root]# iptables -L -t nat
    ```

#### To flush all the current rules

1. Clean out (or delete) all the rules that “may” be currently loaded. Type:

    ```bash
    [root@serverXY root]# iptables --flush
    ```

#### To create your own chains

1. Create your own custom chain and name it “mychain”. Type:

    ```bash
    [root@serverXY root]# iptables  -N  mychain
    ```

2. List the rules under the chain you created above. Type:

    ```bash
    [root@serverXY root]# iptables  -L mychain

    Chain mychain (0 references)

    target     prot opt source               destination
    ```

#### To delete chains

1. First try deleting the built in INPUT chain. Type:

    ```bash
    [root@serverXY root]# iptables -X INPUT
    ```

    !!! question

        What was your output?

2. Next try deleting the chain you created above. Type:

    ```bash
    [root@serverXY root]# iptables -X mychain
    ```

3. Try listing the rules in the chain you just deleted again. Type:

    ```bash
    [root@serverXY root]# iptables -L  mychain
    ```

### Exercise 2

Basic Packet Filtering

This exercise will teach you how to craft slightly more advanced packet filtering rules. In particular, you will block all ICMP packet types from your partner system.

#### To filter ICMP packets types

1. Before starting ensure that you can ping your partner system and that your partner system can ping you too successfully. Type:

    ```bash
    [root@serverXY root]# ping -c 2 serverPR

    <SNIP>

    --- serverPR ping statistics ---

    2 packets transmitted, 2 received, 0% packet loss, time 1005ms

    ...............................................
    ```

2. Flush all your existing rules. Type:

    ```bash
    [root@serverXY root]# iptables -F
    ```

3. Create a rule to prevent all outgoing icmp type packets to any destination. Type:

    ```bash
    [root@serverXY root]# iptables  -A  OUTPUT  -o  eth0 -p  icmp  -j  DROP
    ```

    In plain-speak, the previous command can be interpreted as: “*Append a rule to the OUTPUT chain in the filter table. Let this rule drop every ICMP-type packet that is going out through interface eth0*”

4. Test the effect of your rule above by trying to ping serverPR. Type:

    ```bash
    [root@serverXY root]# ping -c 2 serverPR

    PING serverPR (10.0.5.8) 56(84) bytes of data.

    ping: sendmsg: Operation not permitted

    ping: sendmsg: Operation not permitted
    ```

5. View the rule you just created. Type:

    ```bash
    [root@serverXY root]# iptables  -vL OUTPUT

    Chain OUTPUT (policy ACCEPT 21221 packets, 2742K bytes)

    pkts bytes target     prot   opt    in         out         source             destination

    93  7812 DROP     icmp    --  any         eth0    anywhere          anywhere
    ```

6. Flush all the rules and try the ping command again from both systems.

    !!! question

        Success or failure?

7. Now create another rule that will drop icmp packets that originate from a specific unwanted IP address (e.g. 172.16.0.44 ). Type:

    ```bash
    [root@serverXY root]# iptables -A INPUT -i eth0 -p icmp --source 172.16.0.44 -j DROP
    ```

    You would read the above command in plain-speak as: *“Append a rule into the INPUT chain in the filter table. Let this rule drop all ICMP-type packets and have a source address of 172.16.0.44”*

8. To test the effect of this rule you can ask anybody else in your lab [that hasn't been assigned the 172.16.0.44 IP address] to try pinging you. Success or failure?

9. Instead of flushing all the rules in your tables. Delete only the rule you created above. To do this you need to know the rule number. To find out the rule number type:

    ```bash
    [root@serverXY root]# iptables -vL  INPUT --line-numbers

    Chain INPUT (policy ACCEPT 31287 packets, 9103K bytes)

    num   pkts  bytes   target        prot opt     in     out       source               destination

    1        486   40824  DROP       icmp --    eth0   any     serverPR             anywhere

    ```

    The column containing the rule number has been highlighted for you in the sample output above.

10. Using the line-number that matches the rule in you want to delete, you can delete the specific rule (line number 1) in the INPUT chain by running:

    ```bash
    [root@serverXY root]# iptables -D INPUT 1
    ```

#### To filter other kinds of traffic

In this exercise you will learn how filter tcp type traffic.

The popular ftp protocol is a TCP based service. This means that it is transported over TCP type packets.

In the following steps we will explore targeting and filtering out FTP-type traffic originating from a given IP address.

1. Start the ftp server you configured and enabled in one of the earlier labs. Type:

    ```bash
    [root@serverXY root]# *service vsftpd restart*

    Shutting down vsftpd: [  OK  ]

    Starting vsftpd for vsftpd: [  OK  ]
    ```

2. Ask your partner to try logging on as an anonymous user to your ftp server. Ensure your partner is able to log on successfully from serverPR - do this *before* you go on to the next step.

3. While your partner is still logged on, create a rule to disable all ftp type traffic originating from serverPR. Type:

    ```bash
    [root@serverXY root]# iptables -A INPUT -i  eth0 -s 172.16.0.z  -p tcp  --dport 21 -j DROP*
    ```

    In plain-speak, the above rule/command translates to: *Append a rule to the INPUT chain in filter table. Let this rule DROP all packets with a source address of 172.16.0.z that are destined for port 21 on our local system.*

4. As soon as you execute the above command, the netfilter stack puts it into effect immediately. To see this, ask your partner to try any ftp commands while still logged into your ftp server - e.g.  `ls`. Success or Failure?

    !!! question "Lab tasks:"

        Success or failure?

        If it fails ask your partner to try disconnecting and try logging on again from scratch, and check for success again.  

5. Ask another person that is NOT your partner to try logging on to your ftp server anonymously. You could also ask somebody from hq.example.org to try connecting to your ftp site.

    !!! question

        Success or failure?

6. Enable and start your web server on serverXY.

7. Ensure other people can visit your web site using a browser. Create a rule to block http traffic from hq.example.org to your local machine.

### Exercise 3

Basic Packet Forwarding

In this exercise you will learn how to set up a basic packet forwarding rule.

The rule you set up will allow your system to serve as a router to your partner system.

You system will route all traffic that originates from  your partner’s system to the internet or to your own default gateway. This is what is known as IP masquerading  or NAT (Network address translation).

To be pedantic, IP masquerading and NAT-ing are actually slightly different beasts and are usually used for accomplishing different things. We won’t dwell too much on the specific differences in the following exercises.

This exercise will assume the following, so please make adjustments to suit your particular setup:

ServerXY

i. Your system has two network cards -  eth0 and eth1.

ii. The 1st interface eth0, will be regarded as the external interface(or facing the internet)

iii. The 2nd interface eth1, will be regarded as the internal interface(or facing the LAN)

iv. Interface eth0 has an IP address of 172.16.0.z

v. Interface eth1 has an IP address of  10.0.0.z with a netmask of  255.0.0.0

vi. That you successfully completed “Lab 2” and understood the basis concepts therein.

ServerPR

The following assumptions are made about your partner’s system.

i. It has only one NIC card -  eth0

ii. eth0 has the IP address  - 10.0.0.y with a netmask of  255.0.0.0

iii. The default router or gateway for serverPR is 10.0.0.z  ( i.e. the IP address for serverXY’s eth1)

iv. That you successfully completed “Lab 2” and understood the basis concepts therein.

Cable your network to look like the setup illustrated below:

Our usual icons for serverXY and serverPR has been replaced above with the icons of a router.

#### To create the forwarding rule

1. Ensure you that your network is as cabled physically as illustrated above.

2. Assign all the interfaces their appropriate IP address, netmask, and gateway settings.

3. Flush all the iptables rules that you have loaded currently.

    !!! note

        Flushing the tables is not always essential or compulsory. You may have noticed at the beginning of some of the exercises completed thus far, we have specified that you flush existing tables. This to ensure that you start with a clean slate and that you don't have any errant rules hiding somewhere in your tables that might make things not work correctly. Normally you could have hundreds of rules loaded at the same time, serving different functions.

4. Ask your partner at serverPR to try pinging  172.16.0.100 (hq.example.org) , this should fail because you are now serving as serverPR’s default gateway and you have *not* yet enabled any routing on your system yet.

5. As root on serverXY type:

    ```bash
    [root@serverXY root]# *iptables --table  nat  -A  POSTROUTING -o eth0  -j  MASQUERADE*
    ```

6. Now repeat step 4 again.

    !!! question

        Were you successful?

7. The above should have failed. You also need to enable packet forwarding in your running kernel. Type:

    ```bash
    [root@serverXY root]#  *echo 1   >   /proc/sys/net/ipv4/ip_forward*
    ```

8. To make the above change to the kernel permanent between reboots, create the entry below in your “/etc/sysctl.conf” file:

    ```bash
    net.ipv4.ip_forward = 0
    ```

#### To save `iptables` rules

Thus far, all the `iptables` rules and chains that you've been creating have been ephmeral or non-permanent. This means that if you had to reboot your system at any point, all the rules and changes you made will be lost.

To prevent this, you need a mechanism for writing or saving the temporary run-time `iptables` rules to the system, so that they will always be available on system reboots.

1. Use the `iptables-save` command to save all your changes to the /etc/sysconfig/iptables file. Type:

    ```bash
    [root@serverXY root]# *iptables-save   >   /etc/sysconfig/iptables*
    ```

    !!! tip

        You are limited by the things you can with `iptables` only by your imagination. We have barely scratched the surface in this lab. Hopefully we have scratched off enough of the surface to allow you to let your imagination flourish.

## Extra Points

Here are some additional ways to explore `iptables`:

!!! question "Questions and tasks:"

    1. What option is needed to get a more verbose version of this command *iptables -L  -t   nat*?

    2. What is the command to display the rules under the OUTPUT chain?

    3. What port does the ftp service “normally” listen on?

    4. What is the command to create a chain called “mynat-chain” under the nat table?

    5. Research online and list the names of some easier to use tools or applications that can be used to manage the firewall sub-system on Linux based systems.   

    6. Create an `iptables` rule to block http traffic from hq.example.org to your local machine. What is the well known port that web servers listen on? Write down the complete command to achieve this? Convert or translate the command you wrote down above into its plain-speak equivalent.
