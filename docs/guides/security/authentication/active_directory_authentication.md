---
author: Hayden Young
contributors: Steven Spencer, Sambhav Saggi, Antoine Le Morvan, Krista Burdine
---

# Active Directory Authentication

## Prerequisites

- Some understanding of Active Directory
- Some understanding of LDAP

## Introduction

Microsoft's Active Directory (AD) is, in most enterprises, the de facto
authentication system for Windows systems and for external, LDAP-connected
services. It allows you to configure users and groups, access control,
permissions, auto-mounting, and more.

Now, while connecting Linux to an AD cluster cannot support _all_ of the
features mentioned, it can handle users, groups, and access control. It is even
possible (through some configuration tweaks on the Linux side and some advanced
options on the AD side) to distribute SSH keys using AD.

This guide, however, will just cover configuring authentication against Active
Directory, and will not include any extra configuration on the Windows side.

## Discovering and joining AD using SSSD

!!! Note

    Throughout this guide, the domain name `ad.company.local` will be used to
    represent the Active Directory domain. To follow this guide, replace it with
    the actual domain name your AD domain uses.

The first step along the way to join a Linux system into AD is to discover your
AD cluster, to ensure that the network configuration is correct on both sides.

### Preparation

- Ensure the following ports are open to your Linux host on your domain
  controller:

  | Service  | Port(s)           | Notes                                                       |
  |----------|-------------------|-------------------------------------------------------------|
  | DNS      | 53 (TCP+UDP)      |                                                             |
  | Kerberos | 88, 464 (TCP+UDP) | Used by `kadmin` for setting & updating passwords           |
  | LDAP     | 389 (TCP+UDP)     |                                                             |
  | LDAP-GC  | 3268 (TCP)        | LDAP Global Catalog - allows you to source user IDs from AD |

- Ensure you have configured your AD domain controller as a DNS server on your
  Rocky Linux host:

  **With NetworkManager:**
  ```sh
  # where your primary NetworkManager connection is 'System eth0' and your AD
  # server is accessible on the IP address 10.0.0.2.
  [root@host ~]$ nmcli con mod 'System eth0' ipv4.dns 10.0.0.2
  ```
  
- Ensure that the time on both sides (AD host and Linux system) is synchronized (see chronyd)

  **To check the time on Rocky Linux:**
  ```sh
  [user@host ~]$ date
  Wed 22 Sep 17:11:35 BST 2021
  ```

- Install the required packages for AD connection on the Linux side:

  ```sh
  [user@host ~]$ sudo dnf install realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
  ```


### Discovery

Now, you should be able to successfully discover your AD server(s) from your
Linux host.

```sh
[user@host ~]$ realm discover ad.company.local
ad.company.local
  type: kerberos
  realm-name: AD.COMPANY.LOCAL
  domain-name: ad.company.local
  configured: no
  server-software: active-directory
  client-software: sssd
  required-package: oddjob
  required-package: oddjob-mkhomedir
  required-package: sssd
  required-package: adcli
  required-package: samba-common
```

This will be discovered using the relevant SRV records stored in your Active
Directory DNS service.

### Joining

Once you have successfully discovered your Active Directory installation from
the Linux host, you should be able to use `realmd` to join the domain, which
will orchestrate the configuration of `sssd` using `adcli` and some other such
tools.

```sh
[user@host ~]$ sudo realm join ad.company.local
```

If this process complains about encryption with `KDC has no support for encryption type`, try updating the global crypto policy to allow older encryption algorithms:

```sh
[user@host ~]$ sudo update-crypto-policies --set DEFAULT:AD-SUPPORT
```

If this process succeeds, you should now be able to pull `passwd` information
for an Active Directory user.

```sh
[user@host ~]$ sudo getent passwd administrator@ad.company.local
administrator@ad.company.local:*:1450400500:1450400513:Administrator:/home/administrator@ad.company.local:/bin/bash
```

!!! Note 

    `getent` get entries from Name Service Switch libraries (NSS). It means that, contrary to `passwd` or `dig` for example, it will query different databases, including `/etc/hosts` for `getent hosts` or from `sssd` in the `getent passwd` case.

`realm` provides some interesting options that you can use:

| Option                                                     | Observation                              |
|------------------------------------------------------------|------------------------------------------|
| --computer-ou='OU=LINUX,OU=SERVERS,dc=ad,dc=company.local' | The OU where to store the server account |
| --os-name='rocky'                                          | Specify the OS name stored in the AD     |
| --os-version='8'                                           | Specify the OS version stored in the AD  |
| -U admin_username                                          | Specify an admin account                 |

### Attempting to Authenticate

Now your users should be able to authenticate to your Linux host against Active
Directory.

**On Windows 10:** (which provides its own copy of OpenSSH)

```
C:\Users\John.Doe> ssh -l john.doe@ad.company.local linux.host
Password for john.doe@ad.company.local:

Activate the web console with: systemctl enable --now cockpit.socket

Last login: Wed Sep 15 17:37:03 2021 from 10.0.10.241
[john.doe@ad.company.local@host ~]$
```

If this succeeds, you have successfully configured Linux to use Active
Directory as an authentication source.

### Setting the default domain

In a completely default setup, you will need to log in with your AD account by
specifying the domain in your username (e.g., `john.doe@ad.company.local`). If
this is not the desired behavior, and you instead want to be able to omit the
domain name at authentication time, you can configure SSSD to default to a
specific domain.

This is actually a relatively simple process, and just requires a configuration
tweak in your SSSD configuration file.

```sh
[user@host ~]$ sudo vi /etc/sssd/sssd.conf
[sssd]
...
default_domain_suffix = ad.company.local
```

By adding the `default_domain_suffix`, you are instructing SSSD to (if no
other domain is specified) infer that the user is trying to authenticate as a
user from the `ad.company.local` domain. This allows you to authenticate as
something like `john.doe` instead of `john.doe@ad.company.local`.

To make this configuration change take effect, you must restart the
`sssd.service` unit with `systemctl`.

```sh
[user@host ~]$ sudo systemctl restart sssd
```

In the same way, if you don't want your home directories to be suffixed by the domain name, 
you can add those options into your configuration file `/etc/sssd/sssd.conf`:

```
[domain/ad.company.local]
use_fully_qualified_names = False
override_homedir = /home/%u
```

Don't forget to restart the `sssd` service.

### Restrict to certain users

There are various methods to restrict access to the server to a limited list of users,
 but this, as the name suggests, is certainly the simplest:

Add those options into your configuration file `/etc/sssd/sssd.conf` and restart the service:

```
access_provider = simple
simple_allow_groups = group1, group2
simple_allow_users = user1, user2
```

Now, only users from group1 and group2, or user1 and user2 will be able to connect to the server using sssd!

## Interact with the AD using `adcli`

`adcli` is a CLI to perform actions on an Active Directory domain.

- If not yet installed, install the required package:

```sh
[user@host ~]$ sudo dnf install adcli
```

- Test if you have ever joined an Active Directory domain:

```sh
[user@host ~]$ sudo adcli testjoin
Successfully validated join to domain ad.company.local
```

- Get more advanced informations about the domain:

```sh
[user@host ~]$ adcli info ad.company.local
[domain]
domain-name = ad.company.local
domain-short = AD
domain-forest = ad.company.local
domain-controller = dc1.ad.company.local
domain-controller-site = site1
domain-controller-flags = gc ldap ds kdc timeserv closest writable full-secret ads-web
domain-controller-usable = yes
domain-controllers = dc1.ad.company.local dc2.ad.company.local
[computer]
computer-site = site1
```

- More than a consulting tool, you can use adcli to interact with your domain: manage users or groups, change password, etc. 

Example: use `adcli` to get information about a computer:

!!! Note

    This time we will provide an admin username thanks to the `-U` option

```sh
[user@host ~]$ adcli show-computer pctest -U admin_username
Password for admin_username@AD: 
sAMAccountName:
 pctest$
userPrincipalName:
 - not set -
msDS-KeyVersionNumber:
 9
msDS-supportedEncryptionTypes:
 24
dNSHostName:
 pctest.ad.company.local
servicePrincipalName:
 RestrictedKrbHost/pctest.ad.company.local
 RestrictedKrbHost/pctest
 host/pctest.ad.company.local
 host/pctest
operatingSystem:
 Rocky
operatingSystemVersion:
 8
operatingSystemServicePack:
 - not set -
pwdLastSet:
 133189248188488832
userAccountControl:
 69632
description:
 - not set -
```

Example: use `adcli` to change user's password:

```sh
[user@host ~]$ adcli passwd-user user_test -U admin_username
Password for admin_username@AD: 
Password for user_test: 
[user@host ~]$ 
```

## Troubleshooting

Sometimes, the network service will start after SSSD, that cause trouble with authentication.

No AD users will be able to connect until you restarted the service.

In that case, you will have to override the systemd's service file to manage this problem.

Copy this content into `/etc/systemd/system/sssd.service`:

```
[Unit]
Description=System Security Services Daemon
# SSSD must be running before we permit user sessions
Before=systemd-user-sessions.service nss-user-lookup.target
Wants=nss-user-lookup.target
After=network-online.target


[Service]
Environment=DEBUG_LOGGER=--logger=files
EnvironmentFile=-/etc/sysconfig/sssd
ExecStart=/usr/sbin/sssd -i ${DEBUG_LOGGER}
Type=notify
NotifyAccess=main
PIDFile=/var/run/sssd.pid

[Install]
WantedBy=multi-user.target
```

The next reboot, the service will start after its requirements, and everything will go well.

## Leaving the Active Directory

Sometimes, it's necessary to leave the AD.

You can, once again, proceed with `realm` and then remove the packages that are no longer required:

```sh
[user@host ~]$ sudo realm leave ad.company.local
[user@host ~]$ sudo dnf remove realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
```
