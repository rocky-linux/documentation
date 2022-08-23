---
title: 01 - Installing a FreeIPA Master
author: Hayden Young
tested with: 9.0
tags:
  - freeipa
  - enterprise
---

# Installing a FreeIPA Master

Installing a FreeIPA master is relatively simple, and thanks to some great
improvements in Rocky Linux 9, is even simpler than it was on RL8.

## Requirements

You should have a server prepared running Rocky Linux 9, roughly 4GB RAM, and
two CPU cores. About 32GB storage should be fine, but that's a conservative
estimate. Your storage needs will grow with the amount of data (hosts, users,
rules, etc.) you deploy.

### Packages

FreeIPA on RL9 has no repository dependency or module streams. The IPA master
components can be installed using `ipa-server`.

```shell
dnf install -y ipa-server
```

If you also wish to use FreeIPA to provide a DNS server for your environment,
you will also need the `ipa-server-dns` package.

```shell
dnf install -y ipa-server-dns
```

### Firewall

`ipa-server` comes with some useful FirewallD service definitions that we will
need to use before our IPA server is usable.

```shell
firewall-cmd --add-service={freeipa-ldap,freeipa-ldaps,dns}
firewall-cmd --runtime-to-permanent
```

## Installation

To install the FreeIPA master components and set them up, we use the
`ipa-server-install` command.

```shell
[root@ipa-master ~]# ipa-server-install
The log file for this installation can be found in /var/log/ipaserver-install.log
==============================================================================
This program will set up the IPA Server.
Version 4.9.8

This includes:
  * Configure a stand-alone CA (dogtag) for certificate management
  * Configure the NTP client (chronyd)
  * Create and configure an instance of Directory Server
  * Create and configure a Kerberos Key Distribution Center (KDC)
  * Configure Apache (httpd)
  * Configure SID generation
  * Configure the KDC to enable PKINIT

To accept the default shown in brackets, press the Enter key.
```

It will begin to prompt you with some questions.

### DNS

The first set of these prompts is to configure the BIND DNS server bundled with
IPA.

```shell
Do you want to configure integrated DNS (BIND)? [no]:
```

This first question will determine whether or not IPA runs its own DNS server.
As we want DNS in our environment, we will type `yes` into the prompt.

```shell
Do you want to configure integrated DNS (BIND)? [no]: yes
```

### Domains & Hostnames

The next question will prompt us to enter the desired FQDN of our IPA master
node. This is important, as you will not be able to change it later.

```shell
Enter the fully qualified domain name of the computer
on which you're setting up server software. Using the form
<hostname>.<domainname>
Example: master.example.com.


Server host name [ipa-master.lab.lcl]: 
```

In our case, the server hostname has been detected from our system's hostname,
so we can leave it as the default (`ipa-master.lab.lcl`) and continue. However,
if this does not reflect the hostname and domain name you wish to use for IPA,
this will be your last chance to change it in the installation process.

```shell
The domain name has been determined based on the host name.

Please confirm the domain name [lab.lcl]: 
```

Now, it will prompt us to set our domain name. This should be a domain not
publicly accessible, if possible, but if you are configuring it for a public
domain name, you must use a subdomain, as IPA will not update your DNS
provider's records. (i.e. `idm.company.org`). In our case, we're fine with the
`lab.lcl` domain it detected from the previous question.

```shell
The kerberos protocol requires a Realm name to be defined.
This is typically the domain name converted to uppercase.

Please provide a realm name [LAB.LCL]: 
```

Next, it will prompt us to configure a Kerberos Realm name. If you are familiar
with Microsoft's Active Directory, you will already understand this field, but
in 99% of installations, this will be fine to leave as the automatically
generated default. We will do that, and just hit Enter.

### Administrative Accounts

```shell
Certain directory server operations require an administrative user.
This user is referred to as the Directory Manager and has full access
to the Directory for system management tasks and will be added to the
instance of directory server created for IPA.
The password must be at least 8 characters long.

Directory Manager password: 
```

Now, we will be prompted to set a "Directory Manager" password. This is not a
password we will need often, but should be secure, and kept in a safe place, in
case you need it for complex maintenance, recovery, or management tasks in the
future.

```
The IPA server requires an administrative user, named 'admin'.
This user is a regular system account used for IPA server administration.

IPA admin password: 
```

As stated in the prompt, this next question will configure the `admin` account
within IPA. This is an account similar in nature to `root`, in that it is the
default administrative has-all-the-power-in-the-world account that you should
never use directly. However, we will be setting up extra users in a later guide,
so we can provide this with a secure password, store that somewhere safe, and
continue.

### DNS (again)

```shell
Do you want to configure DNS forwarders? [yes]: 
```

It will now ask us if we wish to configure DNS forwarders. These will configure
IPA to route any DNS not managed internally onto a further DNS server. In our
example, we want to enable this and configure it with public DNS servers, so
that we can use it as our primary DNS server for our lab environment.

```shell
Enter an IP address for a DNS forwarder, or press Enter to skip: 1.1.1.1
DNS forwarder 1.1.1.1 added. You may add another.
Enter an IP address for a DNS forwarder, or press Enter to skip: 1.0.0.1
DNS forwarder 1.0.0.1 added. You may add another.
Enter an IP address for a DNS forwarder, or press Enter to skip: 
DNS forwarders: 1.1.1.1, 1.0.0.1
```

We configure it to use `1.1.1.1` and `1.0.0.1` as its DNS forwarders, then leave
one entry blank, signalling that we are done configuring DNS, and are ready to
continue.

```shell
Do you want to search for missing reverse zones? [yes]: yes
```

Leave this as `yes`, it will add `arpa` domains for the IP address range your
IPA server sits on.

### Domains (again)

```shell
Trust is configured but no NetBIOS domain name found, setting it now.
Enter the NetBIOS name for the IPA domain.
Only up to 15 uppercase ASCII letters, digits and dashes are allowed.
Example: EXAMPLE.


NetBIOS domain name [LAB]: 
```

Now, we need to provide a NetBIOS name. Again, if you are familiar with Active
Directory, this should feel familiar.

For now, leave this as the default, and continue.

### NTP

```shell
Do you want to configure chrony with NTP server or pool address? [no]: no
```

Now, we will be prompted on whether or not we want to configure an NTP server
for our environment. This is a complicated piece of the IPA stack, so for now,
we will leave it disabled.

### Completion

Finally, we will be shown an overview of all the settings we have chosen
throughout the `ipa-server-install` process.

```shell
The IPA Master Server will be configured with:
Hostname:       ipa-master.lab.lcl
IP address(es): 192.168.122.37
Domain name:    lab.lcl
Realm name:     LAB.LCL

The CA will be configured with:
Subject DN:   CN=Certificate Authority,O=LAB.LCL
Subject base: O=LAB.LCL
Chaining:     self-signed

BIND DNS server will be configured to serve IPA domain with:
Forwarders:       1.1.1.1, 1.0.0.1
Forward policy:   only
Reverse zone(s):  No reverse zone

Continue to configure the system with these values? [no]: yes
```

Give them a read through, then if you are happy with them, type `yes` and hit
Enter. If not, type `no`, hit Enter, and go through the wizard again.

Now, we wait. It will take between 5 and 15 minutes to run through depending on
your environment (virtual machine configuration, CPU and Memory available, etc.)

## Review

At the very end of this process, you should have a working FreeIPA installation.

```
The ipa-server-install command was successful
```

This tells you that IPA's server has installed properly, and you are ready to
begin using it.

