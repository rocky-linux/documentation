---
title: FreeRADIUS RADIUS Server
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - security
---

# FreeRADIUS 802.1X Server

## Introduction

RADIUS is an AAA (authentication, authorization and accounting) protocol to manage network access. [FreeRADIUS](https://www.freeradius.org/) is the de-facto RADIUS server for Linux and other Unix-like systems.

## Prerequisites and assumptions

The following are minimum requirements for this procedure:

* The ability to run commands as the root user or use `sudo` to elevate privileges
* A RADIUS client, such as a router, switch or Wi-Fi access point

## Installing FreeRADIUS

You can install FreeRADIUS from the `dnf` repositories:

```bash
dnf install -y freeradius
```

## Configuring FreeRADIUS

With the packages installed, you need to first generate the TLS encryption certificates for FreeRADIUS:

```bash
cd /etc/raddb/certs
./bootstrap
```

Subsequently, you will need to add users to authenticate. Open the `users` file:

```bash
cd ..
vi users
```

In the file, insert the following:

```bash
user    Cleartext-Password := "password"
```

Replace `user` and `password` with the respective desired username and password.

Know that the password is not hashed, so if an attacker gets hold of the `users` file they could gain unauthorized access to your protected network.

You can also do an `MD5`-hashed or `Crypt`-hashed password. To generate an MD5-hashed password, run:

```bash
echo -n password | md5sum | awk '{print $1}'
```

Replace `password` with the desired password.

You will get a hash of `5f4dcc3b5aa765d61d8327deb882cf99`. In `users` file, insert the following instead:

```bash
user    MD5-Password := "5f4dcc3b5aa765d61d8327deb882cf99"
```

You will also need to define clients. This is to prevent unauthorized access to our RADIUS server. Edit the `clients.conf` file:

```bash
vi clients.conf
```

Insert the following:

```bash
client 172.20.0.254 {
        secret = secret123
}
```

Replace `172.20.0.254` and `secret123` with the IP address and secret value the clients will use. Repeat this for other clients.

## Enabling FreeRADIUS

After the initial configuration, you can start `radiusd`:

```bash
systemctl enable --now radiusd
```

## Configuring RADIUS on a switch

After setting up the FreeRADIUS server, you will configure a RADIUS client on the author's MikroTik switch as a wired 802.1X client:

```bash
/radius
add address=172.20.0.12 secret=secret123 service=dot1x
/interface dot1x server
add interface=combo3
```

Replace `172.20.0.12` with the FreeRADIUS server's IP address and `secret123` with the secret you set earlier.
