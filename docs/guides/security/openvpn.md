---
title: Open VPN
author: Joseph Brinkman
tested_with: 9.4
tags:
  - security
  - vpn
---

## Introduction

[OpenVPN](https://openvpn.net/) is a free and open source Virtual Private Network (VPN). This article will guide you through the process of setting up OpenVPN with X509 Public Key Infrastructure (PKI). This guide requires a Rocky Linux system with a public IP address as OpenVPN operates on a Client/Server model. The easiest way to achieve this is to spin-up a virtual private server (VPS) through a cloud provider of your choice. At the time of writing Google Cloud Platform offers an always free tier for their e2-micro instances. If you are looking for the simplest OpenVPN setup using a point-to-point (p2p) VPN with no PKI, refer to their [Static Key Mini-HOWTO](https://openvpn.net/community-resources/static-key-mini-howto/). 

## Prerequisites and assumptions

The following are minimum requirements for this procedure:

* The ability to run commands as the root user or use `sudo` to elevate privileges
* A Rocky Linux system with a publicly accessible IP 

## Install OpenVPN

Install the Extra Packages for Enterprise Linux (EPEL) repository:

```bash
sudo dnf install epel-release -y
```

Install OpenVPN:

```bash
sudo dnf install openvpn -y
```

## Set up Certificate Authority:

Install easy-rsa:

```bash
sudo dnf install easy-rsa -y
```

Create `easy-rsa` directory in `/etc/openvpn`:

```bash
sudo mkdir /etc/openvpn/easy-rsa
```

Create symbolic link to easy-rsa files:

```bash
sudo ln -s /usr/share/easy-rsa /etc/openvpn/easy-rsa
```

Change directory to `/etc/openvpn/easy-rsa`:

```bash
cd /etc/openvpn/easy-rsa
```

Run the `easyrsa` script with `init-pki` parameter to initialize the Certificate Authority's PKI:

```bash
sudo ./easy-rsa/3/easyrsa init-pki
```

Run the `easyrsa` script with `build-ca` and `nopass` parameters to build the Certificate Authority without a password:

```bash
sudo ./easy-rsa/3/easyrsa build-ca nopass
```

## Create Certificates

Run the `easyrsa` script with `gen-req` and `nopass` parameters to generate the server certificate with no password:

```bash
sudo ./easy-rsa/3/easyrsa gen-req server nopass
```

Run the `easyrsa` script with `sign-req` and `server` parameters to sign the server certificate:

```bash
sudo ./easy-rsa/3/easyrsa gen-req server server
```

!!! Note

    You can repeat the below steps as many times needed for additional clients.

Run the `easyrsa` script with `gen-req` and `nopass` parameters to generate client1's certificate with no password:

```bash
sudo ./easy-rsa/3/easyrsa gen-req client1 nopass
```

Run the `easyrsa` script with `sign-req` and `client` parameters to sign client1's certificate with no password:

```bash
sudo ./easy-rsa/3/easyrsa sign-req client client1
```

OpenVPN requires Diffie Hellman parameters. Run this command to generate them:

```bash
sudo ./easy-rsa/3/easyrsa gen-dh
```

## Configure OpenVPN

Now that the PKI has been created, its time to configure OpenVPN. 

Copy `server.conf` sample file to `/etc/openvpn`:

```bash
sudo cp /usr/share/doc/openvpn/sample/sample-config-files/server.conf /etc/openvpn
```

Use your editor of choice to open and write to `server.conf`:

```bash
sudo vim /etc/openvpn/server.conf
```

Next we need to add the file paths for the certificate authority, server certificate, and server key to the OpenVpn server configuration file.

Copy and paste the file paths for the keys and certificates on lines 78-80:

!!! Note

    In vim you can add line numbers to your current editing with `:set nu`

```bash
ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key  # This file should be kept secret
```
Copy and paste the Diffie Hellman file's path on line 85 of the sample file `server.conf`:

```bash
dh /etc/openvpn/easy-rsa/pki/dh.pem
```

OpenVPN uses SSL by default but can optionally use TLS. This guide uses SSL. 

Comment out `tls-auth ta.key` key-pair values on line 244:

```bash
#tls-auth ta.key 0 # This file is secret
```

Save before closing `server.conf`.

## Configure firewall

OpenVPN runs on UDP port 1194 by default. We will use `firewalld` to allow traffic OpenVPN traffic into the server.

Install firewalld:

```bash
sudo dnf install firewalld -y
```

Enable firewalld:

```bash
sudo systemctl enable --now firewalld
```

Allow OpenVPN through the firewall by adding it as a service:

```bash
sudo firewall-cmd --add-service=open-vpn --permanent
```

Enable network address translation (NAT) and hide public client IP addresses by adding a masquerade rule to the firewall:

```bash
sudo firewall-cmd --add-masquerade --permanent
```

Reload the firewall:

```bash
sudo firewall-cmd --reload
```

## Configure routing

Allow IP forwarding with the following command:

```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

## Start OpenVPN server

According to [OpenVPN documentation](https://openvpn.net/community-resources/how-to/#starting-up-the-vpn-and-testing-for-initial-connectivity), "it's best to initially start the OpenVPN server from the command line":

```bash
sudo openvpn /etc/openvpn/server.conf
```

After starting OpenVPN press `Ctrl + Z` then send the job to the background:

```bash
bg
```

## Configure and start client

OpenVPN needs to be installed on client's as well as the server to function. Install OpenVPN on the client if you haven't already:

```bash
sudo dnf install openvpn -y
```

Create new directories to store the client's keys, certs, and configuration file:

```bash
sudo mkdir -p /etc/openvpn/pki`
```

Now copy the keys and certificates using a secure method of transport and place them in `/etc/openvpn/pki`. Some potential ways you can do this are using SFTP or SCP protocols. Check out Rocky linux guide [SSH Public and Private Key](https://docs.rockylinux.org/guides/security/ssh_public_private_keys/) to setup SSH access. 

These are the necessary certificates and keys needed for the client configuration and their filepaths on the server:

- ca.crt
- client1.crt
- client1.key

After the necessary certificates and keys are stored in `/etc/openvpn/pki`, copy the sample file client.conf to `/etc/openvpn`:

```bash
sudo cp /usr/share/doc/openvpn/sample/sample-config-files/client.conf /etc/openvpn
```

Open `client.conf` with an editor of your choice:

```bash
sudo vim /etc/openvpn/client.conf`
```

Map the filepaths of the necessary certificates and keys to the client configuration file. You can do this by copy and pasting the below text onto lines 88-90 of the sample file:

```bash
ca /etc/openvpn/pki/ca.crt
cert /etc/openvpn/pki/client1.crt
key /etc/openvpn/pki/client1.key
```

You will also need to set the server hostname/IP of the server, you can leave the default UDP port 1194. In the sample file, this is located on line 42:

```bash
remote server 1194
```

Save before quitting `client.conf`.

Start OpenVPN on the client:

```bash
sudo openvpn /etc/openvpn/client.conf
```

After starting OpenVPN press `Ctrl + Z` then send the job to the background:

```bash
bg
```

Run the below command to view jobs running in background:
```bash
jobs
```

Send a test ping to the server, by default its private address is `10.8.0.1`:

```bash
ping 10.8.0.1
```

## Conclusion 

And there you have it, your own OpenVPN server up and running! With this basic configuration, you've secured a private tunnel for your systems to communicate over the greater internet. However, OpenVPN is highly customizable, and this guide leaves much to the imagination. You can further explore OpenVPN by checking out their [website](https://www.openvpn.net). You can also read more about OpenVPN right on your system - `man openvpn` - by using the man page. 