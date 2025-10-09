---
title: Installing NVIDIA GPU Drivers
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

NVIDIA^&reg;^ is one of the most popular GPU manufacturers. You can install NVIDIA GPU drivers in more than one way. This guide uses NVIDIA's official repository to install their drivers. Therefore, [NVIDIA Driver Installation Guide](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html) is heavily referenced here.

Some other alternative ways to install NVIDIA drivers include:

* NVIDIA's `.run` installer
* Third-party RPMFusion repository
* Third-party ELRepo driver

In most cases, installing NVIDIA drivers from the official source is best. RPMFusion and ELRepo are available for those who prefer a community-based repository. For older hardware, RPMFusion works best. It is advisable to avoid using the `.run` installer. While convenient, using the `.run` installer is notorious for overwriting system files, and having incompatibility issues.

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

The `kernel-devel` package provides the necessary headers and tools to build kernel modules:

```bash
sudo dnf install kernel-devel-matched kernel-headers -y
```

## Install NVIDIA drivers

After installing the necessary prerequisites, it is time to install the NVIDIA drivers.

Add the official NVIDIA repository with the following command:

!!! Note

    If you use Rocky 9, replace `rhel10` in the file path with `rhel9`.

```bash
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel10/$(uname -i)/cuda-rhel10.repo
```

Next, clean DNF repository cache:

```bash
sudo dnf clean expire-cache
```

Finally, install the latest NVIDIA driver for your system. For open kernel modules, run:

```bash
sudo dnf install nvidia-open -y
```

While for proprietary kernel modules, run:

```bash
sudo dnf install cuda-drivers -y
```

## Disable Nouveau

Nouveau is an open-source NVIDIA driver that provides limited functionality compared to NVIDIA's proprietary drivers. It is best to disable it to avoid driver conflicts:

```bash
sudo grubby --args="nouveau.modeset=0 rd.driver.blacklist=nouveau" --update-kernel=ALL
```

!!! Note

    For systems with secure boot enabled you need to perform this step:

    ```bash
    sudo mokutil --import /var/lib/dkms/mok.pub
    ```

    The `mokutil` command will prompt for you to make up a password, which will be used during reboot.
    
    After the reboot, your system should ask you if you want to enroll a key or something like that, say "yes" and it asks for the password you gave in the `mokutil` command.

Reboot:

```bash
sudo reboot now
```

## Conclusion

You have successfully installed NVIDIA GPU drivers on your system using NVIDIA's official repository. Enjoy the enhanced capabilities of your NVIDIA GPU that the default Nouveau drivers can not provide.
