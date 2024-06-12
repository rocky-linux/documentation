---
title: Samba Windows File Sharing
author: Neel Chauhan
contributors:
tested_with: 9.4
tags:
  - file transfer
  - windows
---

## Introduction

If you've ever dealt with Windows systems chances are you're aware of SMB (Server Message Block) for file sharing. If you're a seasoned Linux administrator chances are that you've heard of Samba but if you haven't, [Samba](https://www.samba.org/) is the de-facto open source implementation of SMB to enable file sharing and Active Directory access of Linux machines to Windows networks.

## Installation

You need to install Samba from the `dnf` repositories:

```bash
dnf install -y samba
```

## Setting up a share

First make a directory you want to share with Windows clients:

```bash
mkdir /var/store
```

Subsequently you will set the SELinux labels on the `/var/store` directory:

```bash
semanage fcontext -a -t samba_share_t  "/var/store(/.*)?"
restorecon -Rv /var/store
```

Replace `/var/store` with the directory to be shared.

Next we will configure Samba:

```bash
vi /etc/samba/smb.conf
```

In the `smb.conf` file navigate to the bottom and insert the following:

```bash
[Share]
        path = /var/store
        browseable = yes
        writable = no
        read only = yes
        guest ok = yes
```

If you're unaware of the options above, they are:

 * `path` is the directory we are sharing. Set this to your respective directory (`/var/store` in our case).
 * `browseable` is to allow clients to browsing access. If you wish to disallow browsing set this to `no`.
 * `writable` is to allow clients writing access. If you wish to allow write access set this to `yes`.
 * `read only` is to mark the share as read-only. If you wish to allow write or execute access set this to `no`.
 * `guest ok` is to allow non-authenticated users access to our share. If you wish to deny guests set this to `no`.

To test the configuration you can run:

```bash
testparm
```

## Enabling Samba

Ocne the configuration is okay you will open the Samba port in `firewall-cmd`:

```bash
firewall-cmd --permanent --add-service=samba
firewall-cmd --reload
```

Nest, you can enable Samba:

```bash
systemctl enable --now smb nmb
```

## Accessing the Samba share

You can access the Samba share using the following URI (Note: replace `SERVER_IP` with the IP address or FQDN of your machine running Samba):

 * Windows: `\\SERVER_IP`
 * Linux/Mac: `smb://SERVER_IP`

`SERVER_IP` on the author's home network is `172.20.0.100` so while the instructions vary based on operating system the author will access the new share from their Fedora 40 laptop:

![Fedora 40 Nautilus showing our Samba Share](../images/samba_nautilus.png)

As you can see all files accessible on the server are also available on client machines.

## Conclusion

While SMB has a reputation of being Microsoft-centric, SMB is actually an industry standard and your Samba share can be accessed from Linux, Mac, BSD and even mobile devices. So congratulations, you are sharing your server's files now!
