---
title: Setting Up libvirt on Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer 
ai_contributors: Gemma 4 (gemma-4-31B-it-UD-Q4_K_XL)
tested with: 9, 10
tags:
- libvirt
- kvm
- virtualization
---

## AI usage

This document adheres to the [AI contribution policy found here.](../contribute/ai-contribution-policy.md) If you find any errors in the instructions, please let us know.

## Introduction

libvirt^1^ is an incredible virtualization API that allows for the virtualization of almost any operating system of your choice with the power of KVM as the hypervisor, and QEMU as the emulator.

This document will provide the instructions for setting up libvirt on Rocky Linux 9 and 10. Where steps differ between the two versions, these are clearly marked.
 
## Prerequisites

* A machine running Rocky Linux 9 and 10.
* Ensure you enable virtualization in your BIOS settings. If the following command returns output, virtualization has been successfully enabled:

```bash
sudo grep -e 'vmx' /proc/cpuinfo
```

## Repository setup and package installation

* Enable the EPEL (Extra Packages for Enterprise Linux) repository:

```bash
sudo dnf install -y epel-release
```

* Install the required packages for `libvirt` (optionally for `virt-manager` if you want to use a GUI to manage your VMs):

```bash
sudo dnf install -y bridge-utils virt-top libguestfs-tools bridge-utils virt-viewer qemu-kvm libvirt virt-manager virt-install
```

!!! note
    The `virt-manager` package has been deprecated and is no longer available in Rocky Linux 10 (it remains available in Rocky Linux 9). For Rocky Linux 10, you should install the following packages instead and enable the `cockpit` service:

    ```bash
    sudo dnf install -y bridge-utils virt-top libguestfs-tools bridge-utils virt-viewer qemu-kvm libvirt virt-install
    sudo dnf install -y cockpit cockpit-machines
    sudo systemctl enable --now cockpit.socket
    ```

    After installation, you can manage your VMs by navigating to the Cockpit console at `https://<your-host>:9090`

## libvirt user setup

* Add your user to the `libvirt` group. This enables the management of your VMs and allows you to use commands such as `virt-install` as a non-root user:

```bash
sudo usermod -aG libvirt $USER
```

* Activate the `libvirt` group by using the `newgrp` command:

```bash
newgrp libvirt
```

* Enable and start the `libvirtd` service:

```bash
sudo systemctl enable --now libvirtd
```

## Bridge interface setup for direct access to virtual machines

* Check the current interfaces in use and note down the main interface with an Internet connection:

```bash
nmcli connection show
```

* Delete the interface connected to the Internet and any virtual bridge connections currently present:

```bash
nmcli connection delete <CONNECTION_NAME>
```

!!! warning

    Make sure you have direct access to the machine. If you are configuring the machine over SSH, the connection will be severed after deleting the main interface connection. While you can run the below commands (up to "nmcli connection up") via a BASH script on a remote system, this is risky and ideally, having another way to connect to the system via a direct or console connection is the best approach.

* Create the new bridge connection:

```bash
nmcli connection add type bridge autoconnect yes con-name <VIRTUAL_BRIDGE_CON-NAME> ifname <VIRTUAL_BRIDGE_IFNAME>
```

* Assign a static IP address:

```bash
sudo nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.addresses <STATIC_IP/SUBNET_MASK> ipv4.method manual
```

* Assign a gateway address:

```bash
nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.gateway <GATEWAY_IP>
```

* Assign a DNS address:

```bash
nmcli connection modify <VIRTUAL_BRIDGE_CON-NAME> ipv4.dns <DNS_IP>
```

* Add the bridge slave connection:

```bash
nmcli connection add type bridge-slave autoconnect yes con-name <MAIN_INTERFACE_WITH_INTERNET_ACCESS_CON-NAME> ifname <MAIN_INTERFACE_WITH_INTERNET_ACCESS_IFNAME> master <VIRTUAL_BRIDGE_CON-NAME>
```

* Start the bridge connection:

```bash
nmcli connection up <VIRTUAL_BRIDGE_CON-NAME>
```

* Add the `allow all` line to `bridge.conf`:

```bash
sudo tee -a /etc/qemu-kvm/bridge.conf <<EOF
allow all
EOF
```

* Enable and start the `libvirtd` service:

```bash
sudo systemctl enable --now libvirtd
```

## Installing and running VMs outside of /var/lib/libvirt/ for Rocky Linux 10

```bash
# Grant read and traversal access to the directory where you are storing your ISOs
sudo setfacl -R -m u:qemu:rx <ISO_DIRECTORY>
sudo setfacl -d -m u:qemu:rx <ISO_DIRECTORY>

# Configure SELinux for read access
sudo semanage fcontext -a -t virt_image_t "<ISO_DIRECTORY>os(/.*)?"
sudo restorecon -Rv <ISO_DIRECTORY>

# 1. Grant traversal access to the home directory
sudo setfacl -m u:qemu:x <HOME_DIRECTORY>

# 2. Grant access to your images directory where you will store the VMs
sudo setfacl -m u:qemu:rwx <IMAGES_DIRECTORY>

# 3. Ensure new files created in the directory inherit these permissions
sudo setfacl -d -m u:qemu:rwx <IMAGES_DIRECTORY>

# 4. Define the SELinux context for the directory and its contents
sudo semanage fcontext -a -t virt_image_t "<IMAGES_DIRECTORY>(/.*)?"

# 5. Apply the SELinux context
sudo restorecon -Rv <IMAGES_DIRECTORY>
```

## Virtual machine installation

* Set the ownership of the `/var/lib/libvirt` directory and its nested directories to your user:

```bash
sudo chown -R $USER:libvirt /var/lib/libvirt/
```

* You can create a virtual machine on the command line by using the `virt-install` command. For example, to create a Rocky Linux 9.8 VM, you can run the following command:

```bash
virt-install --name Rocky-Linux-9 --ram 4096 --vcpus 4 --disk path=/var/lib/libvirt/images/rocky-linux-9.img,size=20 --os-variant rocky9 --network bridge=virbr0,model=virtio --graphics none --console pty,target_type=serial --extra-args 'console=ttyS0,115200n8' --location ~/isos/Rocky-9.8-x86_64-dvd.iso
```

* For those that want to manage their VMs via a GUI, `virt-manager` is the perfect tool for Rocky Linux 9. For Rocky Linux 10, Cockpit is now the standard after `virt-manager` was deprecated.

## How to shutdown a virtual machine

* The `shutdown` command accomplishes this:

```bash
virsh shutdown --domain <YOUR_VM_NAME>
```

* To force shutdown an unresponsive VM, use the `destroy` command:

```bash
virsh destroy --domain <YOUR_VM_NAME>
```

## How to delete a virtual machine

* Use the `undefine` command:

```bash
virsh undefine --domain <YOUR_VM_NAME> --nvram
```

* For further `virsh` commands, check the `virsh` `man` pages.

## Conclusion

* libvirt allows you to install and manage your virtual machines with ease, alongside extensive XML editing options, secureboot, cloud-init support, and more.

## References

1. "libvirt.org" by the libvirt project [https://libvirt.org/index.html](https://libvirt.org/index.html)
