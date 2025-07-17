---
title: Enabling VLAN Passthrough on Marvell AQC-series NICs
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.6
tags:
  - hardware
---

## Introduction

The author uses a Marvell AQC107-based NIC (network interface card) in their home server, which has a virtual machine used for a virtualized firewall. Unfortunately, the stock Rocky Linux Marvell AQC driver strips VLANs on bridge interfaces. This happened to the author's OPNsense virtual machine. Fortunately, it is fixable.

## Prerequisites and assumptions

The following are the minimum requirements for using this procedure:

* A Rocky Linux server with a Marvell AQC-series NIC
* Using NetworkManager to configure networking

## Disabling VLAN filtering

You can disable VLAN filtering with one command:

    nmcli con modify enp1s0 ethtool.feature-rx-vlan-filter off

Replace `enp1s0` with the name of your AQC-based NIC.

Finally, you will need to reboot your system.
