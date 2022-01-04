---
author: Hayden Young
contributors: Steven Spencer, Sambhav Saggi
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

  **Manually editing the /etc/resolv.conf:**
  ```sh
  # Edit the resolv.conf file
  [user@host ~]$ sudo vi /etc/resolv.conf
  search lan
  nameserver 10.0.0.2
  nameserver 1.1.1.1 # replace this with your preferred public DNS (as a backup)

  # Make the resolv.conf file unwritable, preventing NetworkManager from
  # overwriting it.
  [user@host ~]$ sudo chattr +i /etc/resolv.conf
  ```

- Ensure that the time on both sides (AD host and Linux system) is synchronized

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
specifying the domain in your username (e.g. `john.doe@ad.company.local`). If
this is not the desired behaviour, and you instead want to be able to omit the
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
