---
title: Enabling VLAN Passthrough on Intel X710-series NICs
author: Neel Chauhan
contributors: Ganna Zhyrnova
tested_with: 9.4
tags:
  - hardware
---

## Introduction

Some servers have Intel X710-series network interface cards (NICs), such as the author's Minisforum MS-01, which is used for a virtualized firewall. Unfortunately, the stock Rocky Linux driver has a [bug](https://community.intel.com/t5/Ethernet-Products/X710-strips-incoming-vlan-tag-with-SRIOV/m-p/551464) where VLANs are not passed through the bridge interfaces as expected. This happened to the author's MikroTik CHR virtual machine. Fortunately, it is fixable.

## Prerequisites and assumptions

The following are the minimum requirements for using this procedure:

* A Rocky Linux 8 or 9 server with an Intel X710-series NIC

## Installing the Intel-provided NIC drivers

While the stock Rocky Linux driver does not pass through VLANs, the Intel-provided driver does. First, navigate to [Intel's driver download page](https://www.intel.com/content/www/us/en/download/18026/intel-network-adapter-driver-for-pcie-40-gigabit-ethernet-network-connections-under-linux.html).

![Intel's X710 Driver Download Page](../images/intel_x710_drivers.png)

When you are on the above page, download the `i40e_RPM_Files.zip` file and subsequently, `unzip` it:

    unzip i40e_RPM_Files.zip

You will see a bunch of RPM files:

    kmod-i40e-2.25.11-1.rhel8u10.src.rpm
    kmod-i40e-2.25.11-1.rhel8u10.x86_64.rpm
    kmod-i40e-2.25.11-1.rhel8u7.src.rpm
    kmod-i40e-2.25.11-1.rhel8u7.x86_64.rpm
    kmod-i40e-2.25.11-1.rhel8u8.src.rpm
    kmod-i40e-2.25.11-1.rhel8u8.x86_64.rpm
    kmod-i40e-2.25.11-1.rhel8u9.src.rpm
    kmod-i40e-2.25.11-1.rhel8u9.x86_64.rpm
    kmod-i40e-2.25.11-1.rhel9u1.src.rpm
    kmod-i40e-2.25.11-1.rhel9u1.x86_64.rpm
    kmod-i40e-2.25.11-1.rhel9u2.src.rpm
    kmod-i40e-2.25.11-1.rhel9u2.x86_64.rpm
    kmod-i40e-2.25.11-1.rhel9u3.src.rpm
    kmod-i40e-2.25.11-1.rhel9u3.x86_64.rpm
    kmod-i40e-2.25.11-1.rhel9u4.src.rpm
    kmod-i40e-2.25.11-1.rhel9u4.x86_64.rpm

The file to install is in the `kmod-i40e-2.25.11-1.rhelXuY.x86_64.rpm` format, where `X` and `Y` are the Rocky Linux major and minor versions respectively. For instance, on the author's Rocky Linux 9.4 server `X` is 9, `Y` is 4, so the author's install package was:

    sudo dnf install kmod-i40e-2.25.11-1.rhel9u4.x86_64.rpm

After installing the driver, you will need to reboot the server:

    sudo reboot

After rebooting, the X710 NICs should pass through VLANs via bridge interfaces.
