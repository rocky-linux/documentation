---
title: Setting Up libvirt on Rocky Linux
author: Howard Van Der Wal
contributors: N/A
tested with: 9.5
tags:
- libvirt
- kvm
- virtualization
---

# Setting Up libvirt on Rocky Linux 9

## Introduction

[libvirt](https://libvirt.org/) is an incredible virtualization API that enables you to virtualize almost any operating system of your choice with the power of KVM as the hypervisor, and QEMU as the emulator.

This document will provide the instructions for setting up libvirt on Rocky Linux 9.

## Prerequisites

* A 64 bit machine running Rocky Linux 9.
* Ensure that virtualization is enabled in your BIOS settings. If the following command returns output, that means virtualization is enabled:
```
sudo grep -e 'vmx' /proc/cpuinfo
```

## Repository Setup and Package Installation

* Enable the EPEL (Extra Packages for Enterprise Linux) repository.
```
sudo dnf install -y epel-release
```
* Install the required packages for `libvirt` (optionally for `virt-manager` if you wish to use a GUI to manage your VMs).
```
sudo dnf install -y bridge-utils virt-top libguestfs-tools bridge-utils virt-viewer qemu-kvm libvirt virt-manager virt-install
```

## libvirt User Setup

* Add your user to the `libvirt` group. This allows you to manage your VMs and use commands such as `virt-install` as a non-root user.
```
sudo usermod -aG libvirt $USER
```
* Activate the `libvirt` group by using the `newgrp` command.
```
sudo newgrp libvirt
```
* Enable and start the `libvirtd` service.
```
sudo systemctl enable --now libvirtd
```

## Bridge Interface Setup for Direct Access to Virtual Machines

* Check the current interfaces in use and note down the main interface with an Internet connection.
```
sudo nmcli connection show
```
* Delete the interface connected to the Internet and any virtual bridge connections currently present.
```
sudo nmcli connection delete <CONNECTION_NAME>
```
!!! warning

    Make sure you have direct access to the machine. If you are configuring the machine over SSH, the connection will be severed after deleting the main interface connection.

* Create the new bridge connection.
```
sudo nmcli connection add type bridge autoconnect yes con-name <VIRTUAL_BRIDGE_CON-NAME> ifname <VIRTUAL_BRIDGE_IFNAME>
```
* Assign a static IP address.
```
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.addresses <STATIC_IP/SUBNET_MASK> ipv4.method manual
```
* Assign a gateway address.
```
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.gateway <GATEWAY_IP>
```
* Assign a DNS address.
```
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.dns <DNS_IP>
```
* Add the bridge slave connection.
```
sudo nmcli connection add type bridge-slave autoconnect yes con-name <MAIN_INTERFACE_WITH_INTERNET_ACCESS_CON-NAME> ifname <MAIN_INTERFACE_WITH_INTERNET_ACCESS_IFNAME> master <VIRTUAL_BRIDGE_CON-NAME>
```
* Bring up the bridge connection.
```
sudo nmcli connection up <VIRTUAL_BRIDGE_CON-NAME>
```
* Add the `allow all` line to `bridge.conf`.
```
sudo tee -a /etc/qemu-kvm/bridge.conf <<EOF
allow all
EOF
```
* Restart the `libvirtd` service.
```
sudo systemctl restart libvirtd
```

## Virtual Machine Installation

* Set the ownership of the `/var/lib/libvirt` directory and its nested directories to your user.
```
sudo chown -R $USER:libvirt /var/lib/libvirt/
```
* Creating a virtual machine on the command line is done by using the `virt-install` command. For example, to create a Rocky linux 9.5 Minimal VM, you would run the following command:
```
virt-install --name Rocky-Linux-9 --ram 4096 --vcpus 4 --disk path=/var/lib/libvirt/images/rocky-linux-9.img,size=20 --os-variant rocky9 --network bridge=virbr0,model=virtio --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8' --location ~/isos/Rocky-9.5-x86_64-minimal.iso
```
* For those that want to manage their VM's via a GUI, `virt-manager` is the perfect tool.

## How to Shutdown a Virtual Machine

* This is performed by the `shutdown` command.
```
virsh shutdown --domain <YOUR_VM_NAME>
```
* To force shutdown an unresponsive VM, use the `destroy` command.
```
virsh destroy --domain <YOUR_VM_NAME>
```

## How to Delete a Virtual Machine

* Use the `undefine` command.
```
virsh undefine --domain <YOUR_VM_NAME> --nvram
```

* For further `virsh` commands, please check the `virsh` `man` pages.

## Conclusion

* libvirt provides many possiblities and allows you to install and manages your virtual machines with ease. If you have further additions or alterations to this document you would like to share, the author kindly invites you to do so.
