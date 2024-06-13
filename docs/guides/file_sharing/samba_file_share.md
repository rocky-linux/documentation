---
title: Samba Windows File Sharing
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - file transfer
  - windows
---

## Introduction

If you have ever dealt with Windows systems chances are you are aware of SMB (Server Message Block) for file sharing. If you are a seasoned Linux administrator chances are that you have heard of Samba but if you have not, [Samba](https://www.samba.org/) is the de-facto open source implementation of SMB to enable file sharing and Active Directory access from Linux machines to Windows networks.

## Installation

You need to install Samba using `dnf`:

```bash
dnf install -y samba
```

## Setting up a share

First make a directory you want to share with Windows clients:

```bash
mkdir /var/store
```

Next set the SELinux labels on the `/var/store` directory:

```bash
semanage fcontext -a -t samba_share_t  "/var/store(/.*)?"
restorecon -Rv /var/store
```

Replace `/var/store` with the directory to be shared.

Now configure Samba:

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

If you are unaware of the options above, they are:

* `path` is the directory we are sharing. Set this to your respective directory (`/var/store` in our case).
* `browseable` is to allow clients to browsing access. If you want to disallow browsing set this to `no`.
* `writable` is to allow clients writing access. If you want to allow write access set this to `yes`.
* `read only` is to mark the share as read-only. If you want to allow write or execute access set this to `no`.
* `guest ok` is to allow non-authenticated users access to our share. If you want to deny guests set this to `no`.

To test the configuration you can run:

```bash
testparm
```

## Enabling Samba

Once the configuration tests OK, open the Samba port in `firewall-cmd`:

```bash
firewall-cmd --permanent --add-service=samba
firewall-cmd --reload
```

Next, you can enable Samba:

```bash
systemctl enable --now smb nmb
```

## Accessing the Samba share

You can access the Samba share using the following URI (Note: replace `SERVER_IP` with the IP address or FQDN of your machine running Samba):

* Windows: `\\SERVER_IP`
* Linux or Mac: `smb://SERVER_IP`

`SERVER_IP` on the author's home network is `172.20.0.100` so while the instructions vary based on operating system, the author will access the new share from their Fedora 40 notebook:

![Fedora 40 Nautilus showing our Samba Share](../images/samba_nautilus.png)

All files accessible on the server are also available on client machines.

## Conclusion

While SMB has a reputation of being Microsoft-centric, SMB is actually an industry standard and your Samba share can be accessed from Linux, Mac, BSD and even mobile devices. So congratulations, you are sharing your server's files now!
