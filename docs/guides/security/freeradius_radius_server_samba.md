---
title: FreeRADIUS RADIUS Server with Samba Active Directory
author: Neel Chauhan
contributors:
tested_with: 10.1
tags:
  - security
---


## Introduction

RADIUS is an AAA (authentication, authorization and accounting) protocol to manage network access. [FreeRADIUS](https://www.freeradius.org/) is the de facto RADIUS server for Linux and other Unix-like systems.

You can make FreeRADIUS work with Microsoft's Active Directory, say for 802.1X, Wi-Fi or VPN authentication.

## Prerequisites and assumptions

The following are minimum requirements for this procedure:

* The ability to run commands as the root user or use `sudo` to elevate privileges
* An Active Directory member server, whether using a Windows Server or Samba domain
* A RADIUS client, such as a router, switch or Wi-Fi access point

## Configuring Samba

You will need to [configure Active Directory with Samba](authentication/active_directory_authentication_with_samba/). Note that sssd will not work.

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

Subsequently, you will need to enable `ntlm_auth`. Edit the `/etc/raddb/sites-enabled/default` file and insert the following in the `authenticate` block:

```bash
authenticate {
...
    ntlm_auth
...
}
```

Insert the same in `/etc/raddb/sites-enabled/inner_tunnel`:

```bash
authenticate {
...
    ntlm_auth
...
}
```

Change the `program` line in `/etc/raddb/mods-enabled/ntlm_auth` to this:

```bash
    program = "/usr/bin/ntlm_auth --request-nt-key --domain=MYDOMAIN --username=%{mschap:User-Name} --password=%{User-Password}"
```

Replace `MYDOMAIN` with your Active Directory domain name.

You will need to Make `ntlm_auth` the default authentication type in `/etc/raddb/mods-config/files/authorize`. Add the following line:

```bash
DEFAULT   Auth-Type = ntlm_auth
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
