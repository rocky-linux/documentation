---
title: Installing NVIDIA GPU Drivers
author: Joseph Brinkman
contributors: Steven Spencer
---

## Introduction

Nvidia is one of the most popular GPU manufacturers. You can install Nvidia GPU drivers in more than one way. This guide uses Nvidia's official repository to install their drivers. For that reason, [Nvidia's installation guide](https://docs.nvidia.com/cuda/pdf/CUDA_Installation_Guide_Linux.pdf) is heavily referenced here.

!!! Note

    The pre-installation actions link is broken in Nvidia's official guide. You will need to install necessary utilities and dependencies to install the Nvidia driver from their official repository. 

Some other alternative ways to install Nvidia drivers include:

* Nvidia's `.run` installer
* Third-party RPMFusion repository
* Third-party ELRepo driver

In most cases, it is best to install Nvidia drivers from the official source. RPMFusion and ELRepo are available for those who prefer a community-based repository. For older hardware, RPMFusion works best. It is advisable to avoid using the `.run` installer. While convenient, using the `.run` installer is notorious for overwriting system files, and having incompatibility issues.

## Assumptions

For this guide, you need the following:

* Rocky Linux Workstation
* `sudo` privileges

## Install necessary utilities and dependencies

Enable the Extra Packages for Enterprise Linux (EPEL) repository:

```bash
sudo dnf install epel-release -y
```

Installing development tools ensures necessary build dependencies:

```bash
sudo dnf groupinstall "Development Tools" -y
```

The `kernel-devel` package provides necessary headers and tools to build kernel modules:

```bash
sudo dnf install kernel-devel -y
```

Dynamic Kernel Module Support (DKMS) is a program used to automatically rebuild kernel modules:

```bash
sudo dnf install dkms -y
```

## Install NVIDIA drivers

After installing the necessary prerequisites, it is time to install the Nvidia drivers.

Add the official Nvidia repository with the following command:

!!! Note

    If you are using Rocky 8, replace `rhel9` in the file path with `rhel8`.

```bash
sudo dnf config-manager --add-repo http://developer.download.nvidia/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo
```

Next, install a set of packages necessary for building and installing kernel modules:

```bash
sudo dnf install kernel-headers-$(uname -r) kernel-devel-$(uname -r) tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglv-devel acpid pkgconfig dkms -y
```

Install the latest NVIDIA driver module for your system:

```bash
sudo dnf module install nvidia-driver:latest-dkms -y
```

## Disable nouveau

Nouveau is an open source NVIDIA driver that provides limited functionality compared to NVIDIA's proprietary drivers. It is best to disable it to avoid driver conflicts:

Open the grub configuration file with an editor of your choice:

```bash
sudo vim /etc/default/grub
```

Add `nouveau.modset=0` and `rd.driver.blacklist=nouveau` at the end of `GRUB_CMDLINE_LINUX`.

The value of `GRUB_CMDLINE_LINUX` should look similar to the text below although it will not, nor does it need to be, an exact match:

```bash
GRUB_CMDLINE_LINUX="resume=/dev/mapper/rl-swap rd.lvm.lv=rl/root rd.lvm.lv=rl/swap crashkernel=auto rhgb quiet nouveau.modeset=0 rd.driver.blacklist=nouveau"
```

Reload the grub environment:

```bash
grub2-mkconfig -o /boot/grub2/grubenv
```

Reboot:

```bash
sudo reboot now
```

## Conclusion

Congratulations! You have successfully installed NVIDIA GPU drivers on your system using NVIDIA's official repository. Enjoy the enhanced capabilities of your NVIDIA GPU that the default Nouveau drivers can not provide. 
