---
title: Ubiquiti UniFi OS controller
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 10.1
tags:
  - network
  - network management
  - Ubiquiti
---

## Introduction

Ubiquiti's UniFi line of wireless access points and other networking equipment is popular in small business and home lab environments. This includes the author's home lab.

Designed around Podman, the UniFi OS Server is the next generation UniFi controller software.

While technically designed for Debian and Ubuntu, you can also install Ubiquiti's UniFi OS Server on Rocky Linux.

## Prerequisites

- A server or virtual machine with at least 15GB free disk space
- At least one Ubiquiti UniFi device on your LAN
- Knowledge of network administration
- The ability to elevate (`sudo`) permissions for some commands

## Installing prerequisites

Install the prerequisite packages:

```bash
sudo dnf install -y podman slirp4netns
```

## Downloading UniFi OS server

Go to the [Ubiquiti downloads page](https://ui.com/download) and copy the link to the UniFi OS for the CPU architecture you want.

Download the file:

```bash
wget UNIFI_OS_SERVER_DOWNLOAD_LINK
```

The author's file is `1856-linux-x64-5.0.6-33f4990f-6c68-4e72-9d9c-477496c22450.6-x64`. Make it executable:

```bash
chmod a+x 1856-linux-x64-5.0.6-33f4990f-6c68-4e72-9d9c-477496c22450.6-x64
```

## Installing UniFi OS server

Run the downloaded file:

```bash
./1856-linux-x64-5.0.6-33f4990f-6c68-4e72-9d9c-477496c22450.6-x64
```

You will receive a prompt to install. Select `y`:

```text
You are about to install UOS Server version 5.0.6. Proceed? (y/N): y
```

After the installation completes, disable `firewalld`:

```bash
sudo systemctl disable --now firewalld
```

You will get a line that says:

```text
UOS Server is running at: https://IP:11443/
```

Enter that in a browser.

From there, it should be self-explanatory.

## Conclusion

Unlike Ubiquiti's previous UniFi Network controller, UniFi OS adds the ability to run on Rocky Linux versus requiring Debian-based distributions. This makes it accessible to environments which standardized on enterprise Linux and do not want a UniFi gateway. For instance, the author uses a MikroTik core router and switch alongside UniFi access points for better Wi-Fi coverage.
