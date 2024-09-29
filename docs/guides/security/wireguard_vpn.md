---
title: WireGuard VPN
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - security
  - vpn
---

## Introduction

[WireGuard](https://www.wireguard.com/) is a free and open-source peer-to-peer (P2P) Virtual Private Network (VPN). It is a lightweight and secure modern alternative to conventional VPNs with large codebases that rely on TCP connections. Since WireGuard is a P2P VPN, each computer added to the WireGuard network communicates directly with each other. This guide uses a hub-spoke model, with a WireGuard peer assigned a public IP address as a gateway to pass all traffic. This allows WireGuard traffic to bypass Carrier Grade NAT (CGNAT) without enabling port-forwarding on your router. This requires a Rocky Linux system with a public IP address. The easiest way to achieve this is to spin up a virtual private server (VPS) through a cloud provider of your choice. At the time of writing, Google Cloud Platform offers a free tier for its e2-micro instances. 

## Prerequisites and assumptions

The minimum requirements for this procedure are the following:

* The ability to run commands as the root user or use `sudo` to elevate privileges
* A Rocky Linux system with a publicly accessible IP address

## Installing WireGuard

Install Extra Packages for Enterprise Linux (EPEL):

```bash
sudo dnf install epel-release -y
```

Upgrade system packages:

```bash
sudo dnf upgrade -y
```

Install WireGuard:

```bash
sudo dnf install wireguard-tools -y
```

## Configuring WireGuard Server

Create a folder to put your WireGuard configuration files and keys:

```bash
sudo mkdir -p /etc/wireguard
```

Create a configuration file with a name of your choice ending with the `.conf` extension:

!!! Note

    You can create multiple WireGuard VPN tunnels on the same machine, each using a different configuration file, network address, and UDP port.

```bash
sudo touch /etc/wireguard/wg0.conf
```

Generate a new private and public key pair for the WireGuard server:

```bash
wg genkey | sudo tee /etc/wireguard/wg0 | wg pubkey | sudo tee /etc/wireguard/wg0.pub
```

Edit the configuration file with your editor of choice.

```bash
sudo vi /etc/wireguard/wg0.conf
```

Paste the following:

```bash
[Interface]
PrivateKey = server_privatekey
Address = x.x.x.x/24
ListenPort = 51820
```

You must replace the `server_privatekey` with the private key generated earlier. You can view the private key with:

```bash
sudo cat /etc/wireguard/wg0
```

Next, you will need to replace `x.x.x.x/24` with a network address within the private IP address range defined by [RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918). The network address used in this guide is `10.255.255.0/24`.

Finally, you can choose any UDP port to accept connections with WireGuard VPN. UDP port `51820` is used for the purposes of this guide.  

## Enable IP forwarding

IP forwarding allows the routing of packets between networks. This allows internal devices to communicate with each other through the WireGuard tunnel:

Turn on IP forwarding for IPv4 and IPv6:

```bash
sudo sysctl -w net.ipv4.ip_forward=1 && sudo sysctl -w net.ipv6.conf.all.forwarding=1
```

## Configure `firewalld`

Install `firewalld`:

```bash
sudo dnf install firewalld -y
```

After installing `firewalld`, enable it:

```bash
sudo systemctl enable --now firewalld
```

Create a permanent firewall rule allowing traffic on UDP port 51820 in the public zone:

```bash
sudo firewall-cmd --permanent --zone=public --add-port=51820/udp
```

Next, traffic from the WireGuard interface will be allowed to other interfaces in the internal zone.

```bash
sudo firewall-cmd --permanent --add-interface=wg0 --zone=internal
```

Add a firewall rule to enable IP masquerading on internal traffic. This means that packets sent between peers will replace the packet IP address with the server's IP address:

```bash
sudo firewall-cmd --permanent --zone=internal --add-masquerade
```

Finally, reload `firewalld`:

```bash
sudo firewall-cmd --reload
```

## Configure WireGuard peer

Since all computers in a WireGuard network are technically peers, this process is nearly identical to configuring the WireGuard server, but with slight differences. 

Create a folder to put your WireGuard configuration files and keys:

```bash
sudo mkdir -p /etc/wireguard
```

Create a configuration file, giving it a name of your choice, ending with the `.conf` extension:

```bash
sudo touch /etc/wireguard/wg0.conf
```

Generate a new private and public key pair:

```bash
wg genkey | sudo tee /etc/wireguard/wg0 | wg pubkey | sudo tee /etc/wireguard/wg0.pub
```

Edit the configuration file with your editor of choice, adding this content:

```bash
[Interface]
PrivateKey = peer_privatekey
Address = 10.255.255.2/24

[Peer]
PublicKey = server_publickey
AllowedIPs = 10.255.255.1/24
Endpoint = serverip:51820
PersistentKeepalive = 25
```

Replace `peer_privatekey` with the peer's private key stored in `/etc/wireguard/wg0` on the peer.

You can use this command to output the key so you can copy it:

```bash
sudo cat /etc/wireguard/wg0
```

Replace `server_publickey` with the server's public key stored in `/etc/wireguard/wg0.pub` on the server.

You can use this command to output the key so you can copy it:

```bash
sudo cat /etc/wireguard/wg0.pub
```

Replace `serverip` with the public IP of the WireGuard server.

You can find the server's public IP address using the following command on the server:

```bash
ip a | grep inet
```

The peer's configuration file now includes a `PersistentKeepalive = 25` rule. This rule tells the peer to ping the WireGuard server every 25 seconds to maintain the VPN tunnel's connection. Without this setting, the VPN tunnel will time out after inactivity.

## Enable WireGuard VPN

To enable WireGuard, you will run the following command on both the server and peer:

```bash
sudo systemctl enable wg-quick@wg0
```

Then start the VPN by running this command on both the server and peer:

```bash
sudo systemctl start wg-quick@wg0
```

## Add the client key to the WireGuard server configuration

Output the peer's public key and copy it:

```bash
sudo cat /etc/wireguard/wg0.pub
```

On the server, run the following command, replacing `peer_publickey` with the peer's public key:

```bash
sudo wg set wg0 peer peer_publickey allowed-ips 10.255.255.2
```

Using `wg set` only makes temporary changes to the WireGuard interface. For permanent configuration changes you can manually edit the configuration file and add the peer. You will need to reload the WireGuard interface after making any permanent configuration changes.

Edit the server's configuration file with your editor of choice.

```bash
sudo vi /etc/wireguard/wg0.conf
```

Add the peer to configuration file. The contents should look similar to below:

```bash
[Interface]
PrivateKey = +Eo5oVjt+d3XWvFWYcOChaLroGj5vapdXKH8UZ2T2Fc=
Address = 10.255.255.1/24
ListenPort = 51820

[Peer]
PublicKey = 1vSho8NvECkG1PVVk7avZWDmrd2VGZ2xTPaNe5+XKSg=
AllowedIps = 10.255.255.2/32
```

Bring interface down:

```bash
sudo wg-quick down wg0
```

Bring interface up:

```bash
sudo wg-quick up wg0
```

## View WireGuard interfaces and test connectivity

You can view WireGuard information on both the server and peer with:

```bash
sudo wg
```

You can test connectivity by sending a ping to the server from the peer:

```bash
ping 10.255.255.1
```

## Conclusion

Following this guide, you have successfully set up a WireGuard VPN using the hub-spoke model. This configuration provides a secure, modern, and efficient way to connect multiple devices across the internet. Check the [official WireGuard website](https://www.wireguard.com/).
