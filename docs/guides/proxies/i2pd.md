---
title: i2pd Anonymous Network
author: Neel Chauhan
contributors: Steven Spencer
tags:
  - proxy
  - proxies
---

## Introduction

[I2P](https://geti2p.net/en/) is an anonymous overlay network and competitor to the more-popular Tor network with a focus on hidden websites called eepsites. [`i2pd`](https://i2pd.website/) (I2P Daemon) is a lightweight C++ implementation of the I2P protocol.

## Prerequisites and assumptions

The following are minimum requirements for using this procedure:

- A public IPv4 or IPv6 address, whether directly on the server, with port forwarding, or UPnP/NAT-PMP

## Installing `i2pd`

To install `i2pd`, you need to first install the EPEL (Extra Packages for Enterprise Linux) and `i2pd` copr (Cool Other Package Repo) repositories:

```bash
curl -s https://copr.fedorainfracloud.org/coprs/supervillain/i2pd/repo/epel-10/supervillain-i2pd-epel-10.repo -o /etc/yum.repos.d/i2pd-epel-10.repo
dnf install -y epel-release
```

Then install `i2pd`:

```bash
dnf install -y i2pd
```

## Configuring `i2pd` (optional)

With the packages installed, you can configure `i2pd` if required. The author uses `vim` for this, but if you prefer `nano` or something else, go ahead and substitute that in:

```bash
vim /etc/i2pd/i2pd.conf
```

The default `i2pd.conf` file is pretty descriptive, but can get long if you just want a basic configuration, you can leave as-is.

However, if you want to enable IPv6 and UPnP and set the listen HTTP proxy port to `12345`, a configuration allowing this follows:

```bash
ipv6 = true
[httpproxy]
port = 12345
[upnp]
enabled = true
```

If you want to set other options, the configuration file is self-explanatory on all the possible options.

## Enabling `i2pd`

We can now enable `i2pd`

```bash
systemctl enable --now i2pd
```

## Visiting I2P eepsites

This example, uses Firefox on Rocky Linux. If you are not using Firefox, see the documentation of your application to set an HTTP proxy.

Open up Firefox, click the hamburger menu icon, and then go to **Settings**:

![Firefox menu dropdown](../images/i2p_proxy_ff_1.png)

Scroll to the **Network Settings** and subsequently press **Settings*

![Firefox Network Settings section](../images/i2p_proxy_ff_2.png)

Then select **Manual proxy connection**, enter in `localhost` and `4444` (or the port you selected), check **Also use this proxy for HTTPS** and select **OK**.

![Firefox Connection Settings dialog](../images/i2p_proxy_ff_3.png)

Now, you are able to browse I2P eepsites. As an example, navigate to `http://planet.i2p` (Note: the `http://` is important to prevent Firefox from defaulting to a search engine):

![Firefox viewing planet.i2p](../images/i2p_proxy_ff_4.png)

## Conclusion

With so many internet users concerned about online privacy, I2P is one way to access hidden websites securely. `i2pd` is lightweight software that makes browsing I2P websites possible, alongside sharing your connection as an relay.
