---
title: FreeRADIUS RADIUS Server
author: Neel Chauhan
contributors:
tested_with: 9.4
tags:
  - security
---

# FreeRADIUS 802.1X Server

## Introduction

RADIUS is an AAA (authentication, authorization and accounting) protocol to manage network access. [FreeRADIUS](https://www.freeradius.org/) is the de-facto RADIUS server for Linux and other Unix-like systems.


## Prerequisites and assumptions

The following are minimum requirements for using this procedure:

* The ability to run commands as the root user or use `sudo` to elevate privileges
* A RADIUS client, such as a router, switch or Wi-Fi access point

## Installing Tailscale

We can install FreeRADIUS from the `dnf` repositories:

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

Keep in mind that the password isn't hashed so if an attacker gets hold of the `users` file they could gain unauthorized access to your protected network.

You could also do an `MD5`-hashed or `Crypt`-hashed password. To generate an MD5-hashed password, run:

```bash
echo -n password | md5sum | awk '{print $1}'
```

Replace `password` with the desired password.

You will get an hash of `5f4dcc3b5aa765d61d8327deb882cf99`. In `users` file, insert the following instead:

```bash
user    MD5-Password := "5f4dcc3b5aa765d61d8327deb882cf99"
```

We will also need to define clients. This is to prevent unauthorized access to our RADIUS server. Edit the `clients.conf` file:

```bash
vi clients.conf
```

Insert the following:

```bash
client 172.20.0.254 {
        secret = secret123
}
```

Replace `172.20.0.254` and `secret123` with the IP address and secret value to be used by the client. This can be repeated for multiple clients. 

## Enabling FreeRADIUS

After the initial configuration is completed, we can start `radiusd`:

```bash
systemctl enable --now radiusd
```

## Configuring RADIUS on a switch

After setting up the FreeRADIUS server, we will configure a RADIUS client on the author's MikroTik switch as a wired 802.1X client:

```bash
/radius
add address=172.20.0.12 secret=secret123 service=dot1x
/interface dot1x server
add interface=combo3
```

Replace `172.20.0.12` with the FreeRADIUS server's IP address and `secret123` with the secret we set earlier.

## Conclusion

Traditional VPN services using a VPN gateway are centralized. This requires manual configuration, setting up your firewall and giving user accounts. Tailscale solves this problem by its peer-to-peer model combined with network-level access control.
