---
title: Transmission BitTorrent Seedbox
author: Neel Chauhan
contributors:
tested_with: 9.4
tags:
  - file transfer
---
# Transmission BitTorrent Seedbox

## Introduction

BitTorrent needs no introduction at this point but if you're unaware, BitTorrent is a peer-to-peer file sharing protocol. BitTorrent relies on multiple peers sededing (uploading) the requested file to you but you also seed back to future downloaders.

Transmission is an popular open source BitTorrent client which has multiple frontends and backends. We will be installing the headless "daemon" backend.

In today's mobile-centric world, it makes more sense to run Transmission as a headless server than directly on a laptop or even a desktop. This way we can seed files 24/7 while not consuming battery life on a mobile device if used for downloading.

## Installation

To install Transmission we first need to install EPEL:

```bash
dnf install -y epel-release
```

Then we will install Transmission:

```bash
dnf install -y transmission
```

## First Setup

Unlike most Linux daemons Transmision sets up the configuration upon first startup. Let's start up and stop Transmission:

```bash
systemctl start transmission-daemon
systemctl stop transmission-daemon
```

After these steps, we will have a configuration file. You will need to stop Transmission as you cannot edit the configuration file while Transmission is running.

## Configuration

Now, we will configure Transmission:

```bash
cd /var/lib/transmission/.config/transmission-daemon
vi settings.json
```

Navigate down to the `"peer-port"` JSON entry and if desired, replace the stock port with the desired port:

```bash
    "peer-port": 51413,
```

I'll change it to `12345`:

```bash
    "peer-port": 12345,
```

Subsequently, navigate to the `"rpc-password"` JSON entry and change the password:

```bash
    "rpc-password": "{9cfaaade11d56c8e82bfc23b696fa373fb20c10e4U2NXY3.",
```

Enter your plaintext password here. If you are worried about security, fortunately Transmission will encrypt the password upon the next restart

If you want to allow access from other IP addresses, navigagte to the `"rpc-whitelist"` entry:

```bash
    "rpc-whitelist": "127.0.0.1,::1",
```

For instance if you want to allow access to your desktop on IP address `192.168.1.100` we can add it to the comma separated value:

```bash
    "rpc-whitelist": "127.0.0.1,::1,192.168.1.100",
```

Alternatively if you don't desire an IP whitelist we can disable it by setting `"rpc-whitelist-enable"` to `false`:

```bash
    "rpc-whitelist-enabled": false,
```

When you're done configuring we will start and enable Transmission:

```bash
systemctl enable --now transmission-daemon
```

## Firewall and Network Configuration

Subsequently, we will need to allow the respective ports `12345` (for BitTorrent) and `9091` (for Transmission's control panel) in our firewall:

```bash
firewall-cmd --permanent --zone=public --add-port=12345/tcp
firewall-cmd --permanent --zone=public --add-port=9091/tcp
firewall-cmd --runtime-to-permanent
```

If you are not behind a NAT-PMP or uPNP-enabled router or connected without NAT we will need to forward the BitTorrent port (`12345` in our example). Each router is different but as an example on the author's MikroTik router:

```bash
/ip firewall nat add action=dst-nat chain=dstnat dst-port=12345 in-interface=ether1 protocol=tcp to-addresses=SERVER_IP to-ports=12345
```

Replace `SERVER_IP` with the IP address of the server running Transmission.

## Testing Transmission

Navigate to the IP address running our Transmission server. As an example we can download the torrent of a Linux distribution such as Ubuntu:

![Our Transmission downloading Ubuntu](../images/transmission.png)

## Conclusion

BitTorrent was designed in the early 2000s when most people connected to the internet via a desktop PC. And while it's impractical to run BitTorrent on a laptop or phone it's perfect to run it on a headless server via Transmission. This way we can seed files 24/7 and yet our downloads will always be available to us.
