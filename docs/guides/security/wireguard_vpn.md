---
title: WireGuard VPN
author: Joseph Brinkman
tested_with: 9.4
tags:
  - security
  - vpn
---

# Wireguard VPN

## Introduction

[WireGuard](https://www.wireguard.com/) is a free and open-source peer-to-peer (P2P) Virtual Private Network (VPN). It is a light-weight and secure modern alternative to more conventional VPNs with large codebases that rely on TCP connections. Since WireGuard is a P2P VPN, each computer added to the WireGuard network communicates directly with eachother. For the purposes of this guide, we will be using a hub-spoke model, using a wireguard peer assigned a public IP address as a gateway to pass all traffic through. The purpose of doing this is allowing wireguard traffic to bypass Carrier Grade NAT (CGNAT) without needing to enable port-forwarding on your router. This requires a Rocky Linux system that is assigned a public IP address. The easiest way to achieve this is to spin-up a virtual private server (VPS) through a cloud provider of your choice; at the time of writing Google Cloud Platform offers an always free tier for their e2-micro instances. 

## Prerequisites and assumptions

The following are minimum requirements for using this procedure:

* The ability to run commands as the root user or use `sudo` to elevate privileges
* A Rocky Linux system with a publicly accessible IP address

## Installing Wireguard

Install Extra Packages for Enterprise Linux(EPEL):

```bash
sudo dnf install epel-release
```

Update your systems packages:

```bash
sudo dnf upgrade
```

Install Wireguard:

```bash
sudo dnf install wireguard-tools
```

## Configuring WireGuard Server

Create a folder to put your wireguard configuration files and keys:

```bash
sudo mkdir -p /etc/wireguard
```

Create a configuration file, this can be named whatever you like, but it must end with `.conf` extension:

!!! Note

	You can create multiple Wireguard VPN tunnels on the same machine, each using a different configuration file, network address, and UDP port.

```bash
sudo touch wg0.conf
```

Generate a new private and public key pair for the WireGuard server:

```bash
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey
```

Edit the configuration file with your editor of choice. 

```bash
sudo vim /etc/wireguard/wg0.conf
```

Paste the below text:


```bash
[Interface]

PrivateKey = server_privatekey

Address = x.x.x.x/24

ListenPort = 51820
```

You will need to replace `privatekey` with the privatekey generated earlier. You can view the privatekey using the below command in order to copy it and replace the placeholder.

```bash
sudo cat /etc/wireguard/privatekey
```

Next, you will need to replace `x.x.x.x/24` with a network address within the private IP address range defined by [RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918). For the purposes of this guide, we will use `10.255.255.0/24`.

Finally, you can choose any UDP port to accept connections with Wirguard VPN. We will use `51820` for the purposes of this guide.  

## Enable IP forwarding 

IP forwarding allows the routing of packets between networks. To enable IP forwarding on your Wireguard server, use the below command to open the config file where you will put a rule stating IP forwarding is on.

```bash
sudo vim /etc/sysctl.d/99-sysctl.conf
```

Now add the below rules to turn IP forwarding on for IPv4 and IPv6. This will allow internal devices to communicate with each other through the WireGuard tunnel.

```bash
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
```

Apply these configuration changes with the below command.

```bash
sudo sysctl -p
```

## Configure firewalld

If firewalld is not installed, install it:

```bash
sudo dnf install firewalld -y
```

After installing firewalld, enable it:

```bash
sudo systemctl enable --now firewalld
```

Use the command below to create a permanent firewall rule allowing traffic on UDP port 51820 in the public zone.

```bash
sudo firewall-cmd --permanent --zone=public --add-port=51820/udp
```

Next, allow traffic from the Wireguard interface to other interfaces in the internal zone.

```bash
sudo firewall-cmd --permanent --add-interface=wg0 --zone=internal
```

Also, add a firewall rule to enable IP masquerading on internal traffic. This means that packets sent between peers will be replaced with the server's IP address.

```bash
sudo firewall-cmd --permanent --zone=internal --add-masquerade
```

Finally, reload firewalld.

```bash
sudo firewall-cmd --reload
```

## Configure Wireguard Peer

Since all computers in a WireGuard network technically are peers, this process is nearly identical to configuring the Wireguard server, but there are some slight differences in the configuration. 

Create a folder to put your wireguard configuration files and keys:

```bash
sudo mkdir -p /etc/wireguard
```

Create a configuration file, this can be named whatever you like, but it must end with `.conf` extension:

```bash
sudo touch wg0.conf
```

Generate a new private and public key pair: 

```bash
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey
```

Edit the configuration file with your editor of choice:

Paste the below text:

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

Replace `peer_privatekey` with the peer's private key stored in `/etc/wireguard/privatekey` on the peer. 

You can use the below command to output the key so you can copy it:

```bash
sudo cat /etc/wireguard/privatekey
```

Replace `server_publickey` with the server's public key stored in `/etc/wireguard/publickey` on the server. 

You can use the below command to output the key so you can copy it:

```bash
sudo cat /etc/wireguard/publickey
```

Replace `serverip` with the public IP of the WireGuard server. 

You can find the server's public IP address using the following command on the server:

```bash
ip a | grep inet
```

## Add the client key to the WireGuard server config

Output the peer's public key and copy it

```bash
sudo cat /etc/wiregaurd/publickey
```

On the server, run the following command, replacing `peer_publickey` with the peers public key:

```bash
sudo wg set wg0 peer peer_publickey allowed-ips 10.255.255.2
```

It is worth mentioning you can manually edit and peers to the configuration file. 

## Enable WireGuard VPN

To enable Wireguard, you will run the following command on both the server and peer:

```bash
sudo systemctl enable wg-quick@wg0
```

Then start the VPN by running the below command on both the server and peer:

```bash
systemctl start wg-quick@wg0
```

You can view WireGuard information on both the server and peer with the below command:

```bash
sudo wg
```

You can test connectivity by sending a ping to the server from the peer:

```bash
ping 10.255.255.1
```

## Conclusion

By following this guide, you've successfully set up a WireGuard VPN using a hub-spoke model. This configuration provides a secure, modern, and efficient way to connect multiple devices across the internet. For further reading, checkout the [official WireGuard website](https://www.wireguard.com/).
