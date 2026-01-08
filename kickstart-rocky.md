---
title: Kickstart Files and Rocky Linux
author: Howard Van Der Wal
contributors: <empty> 
tested with: 10, 9, 8
tags:
- file
- install
- kickstart
- linux
- rocky 
---

# Kickstart Files and Rocky Linux

**Knowledge**: :star: :star: 
**Reading time**: 15 minutes

## Introduction

Kickstart files are an indispensable tool for installing and configuring Rocky Linux across one or more machines at once. They can be used to quickly set up everything from your favorite gaming workstation to deploying hundreds of machines in an enterprise organization. They save hours of time and effort manually configuring each machine in turn.

At the end of this article, you'll have an understanding of how `kickstart` files work, how to create and apply your own `kickstart` file to a Rocky Linux ISO, and then be able to provision your own machine. 

## What are kickstart configurations?

Kickstart files are a set of configurations implemented by the user to quickly and easily deploy a Linux distribution. Kickstart files not only work on Rocky Linux, but also CentOS Stream, Fedora, and many other distributions.

## How are kickstart configurations applied to an ISO?

Using `mkkiso`, a kickstart file is copied into the `root` directory of a Linux ISO. From there, `mkkiso` edits the `/isolinux/isolinux.cfg` and places the `kickstart` file there as a kernel cmdline parameter (`inst.ks`):

```bash
sudo mount -o ro,loop rocky-linux10-dvd-shadow.iso /mnt/
cat /mnt/EFI/BOOT/grub.cfg | grep shadow | head -1
linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Rocky-10-1-x86_64-dvd quiet inst.ks=hd:LABEL=Rocky-10-1-x86_64-dvd:/rocky_linux10_shadow.ks
```

Once done, `mkkiso` produces a new ISO with the `kickstart` configuration built-in. When the ISO boots, `anaconda` runs the instructions that are listed in the `kickstart` file.

## Prerequisites

* Optional - deploy your `kickstart` ISO via a PXE Server: check out the guide on [How to Setup a PXE Server on Rocky Linux 9.x](https://kb.ciq.com/article/rocky-linux/rl-pxe-boot-kickstart-file) to learn more. 

* One USB gen 3.0+ memory stick for a USB install. 

* A Rocky Linux 8, 9, or 10 Minimal ISO from https://rockylinux.org/download (the DVD ISO is not a requirement).

* Follow the [Custom Rocky Linux ISO Setup Steps](https://docs.rockylinux.org/10/guides/isos/iso_creation/) guide to install the `lorax` package and how to generate a Rocky Linux `kickstart` ISO. 

## Kickstart examples

=== "10"


    lang en_GB
    keyboard --xlayouts='jp'
    timezone Asia/Tokyo --utc
    rootpw --iscrypted $6$0oXug1vTr7TO3kJu$/kvm.lctWsLDHaeak/YuUaEu26LzvNuE1L/tvUC4G91ZroChjDTUDwQDEkQfGhwQw4doiDcZc2P6et.zzRqOZ/ --allow-ssh
    user --name howard --password $6$8wzUW5ipTdTs.MbM$1F6mPfqQAXPeSVArqT2r/GL6QljXs2dQWCcNGjQq5cpEPGWhNvOCAiVCDJRA0FZQpoTXJSBtNON2ZqvEMBUNX/ --iscrypted --groups=wheel
    reboot
    text
    url --url='https://download.rockylinux.org/pub/rocky/10/BaseOS/x86_64/os/'
    bootloader --location=boot --append="ro crashkernel=2G-64G:256M,64G-:512M rhgb quiet"
    zerombr
    clearpart --all --initlabel --disklabel=gpt
    ignoredisk --only-use=nvme0n1
    part /boot/efi --fstype=efi --size=600
    part /boot --fstype=xfs --size=1024
    part pv.0 --fstype=lvmpv --size=480000
    volgroup rl --pesize=4096 pv.0
    logvol / --vgname=rl --name=root --fstype=xfs --size=70000
    logvol swap --vgname=rl --name=swap --fstype=swap --size=1024
    logvol /home --vgname=rl --name=home --fstype=xfs --size=1000 --grow
    network --device=enp4s0 --hostname=shadow --bootproto=static --ip=192.168.1.102 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver=192.168.1.1 --activate
    skipx
    firstboot --disable
    selinux --enforcing
    firewall --enabled --ssh
    %packages
    @^server-product-environment
    %end

    %post
    mkdir -p /mnt/storage1
    mkdir -p /mnt/storage2
    mkfs.xfs /dev/nvme0n1
    mkfs.xfs /dev/sda
    sync
    udevadm settle
    sleep 2
    UUID_NVME0N1=$(blkid -s UUID -o value /dev/nvme0n1)
    UUID_SDA=$(blkid -s UUID -o value /dev/sda)
    if [ -n "$UUID_NVME0N1" ]; then
        echo "UUID=$UUID_NVME0N1 /mnt/storage1 xfs defaults,inode64 0 0" >> /etc/fstab
    fi
    if [ -n "$UUID_SDA" ]; then
        echo "UUID=$UUID_SDA /mnt/storage2 xfs defaults,inode64 0 0" >> /etc/fstab
    fi
    mount -U $UUID_NVME0N1 /mnt/storage1
    mount -U $UUID_SDA /mnt/storage2
    chown -R howard:howard /mnt/storage1
    chown -R howard:howard /mnt/storage2
    %end

=== "9"


    lang en_GB
    keyboard --xlayouts='jp'
    timezone Asia/Tokyo --utc
    rootpw --iscrypted $6$IjIs0nEufTOaj2cZ$EnZKdrjHQ9OmhePUMVWUcaJmmC0vU2L.b02lBMKmRMLq/VZOhnrgBO64ru29rFnB8HQsGo0cQLqBoLIpL7PbS1 --allow-ssh
    user --name howard --groups wheel --password $6$OdZuQb9owvkol5gv$6X7w0VraE7hDSrrHS5oz9BvNACB.PcrNt5Ulka9/g1Sgxdzl93LAuGT3GH8a.4ZUpqzchKU3glgRyCWXhSN68. --iscrypted
    reboot
    text
    url --url='https://download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os/'
    bootloader --location=boot --append="crashkernel=1G-4G:192M,4G-64G:256M,64G:512M rhgb quiet"
    zerombr
    clearpart --all --initlabel --disklabel=gpt
    ignoredisk --only-use=sda
    part /boot/efi --fstype=efi --size=600
    part /boot --fstype=xfs --size=1024
    part pv.0 --fstype=lvmpv --size=120012
    volgroup rl --pesize=4096 pv.0
    logvol / --vgname=rl --name=root --fstype=xfs --size=70000
    logvol swap --vgname=rl --name=swap --fstype=swap --size=1024
    logvol /home --vgname=rl --name=home --fstype=xfs --size=1000 --grow
    network --device=enp2s0 --hostname=mighty --bootproto=static --ip=192.168.1.104 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver=192.168.1.1 --activate
    skipx
    firstboot --disable
    selinux --enforcing
    firewall --enabled --ssh
    %packages
    @^server-product-environment
    %end
  
=== "8"


    lang en_GB
    keyboard jp106
    timezone Asia/Tokyo --utc
    rootpw <ROOT_PASSWORD_HERE> --iscrypted
    user --name=howard --password=<USER_PASSWORD_HERE> --iscrypted --groups=wheel
    reboot
    text
    url --url='https://download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/'
    bootloader --append="rhgb quiet crashkernel=auto"
    zerombr
    clearpart --all --initlabel
    autopart
    network --device=enp1s0 --hostname=rocky-linux8-slurm-controller-node --bootproto=static --ip=192.168.1.120 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver=192.168.1.1
    firstboot --disable
    selinux --enforcing
    firewall --enabled --ssh
    %packages
    @^server-product-environment
    %end 

**Items of interest are highlighted below, with the focus being on the Rocky Linux 10 `kickstart` file. Any differences between `kickstart` files is also discussed:**

### Rocky Linux 10 kickstart file breakdown

#### rootpw

!!! warning

    Always use the --iscrypted option for the root password, to ensure it is not displayed in plain text! 

To generate a hash of your desired password, use the following `openssl` command and enter your password when prompted:

```bash
openssl passwd -6
```

For `ssh` access to the `root` account, add the `--allow-ssh` option to the `rootpw` line. 

#### user 

Similarly use the `--iscrypted` option to ensure your passwords are not shown in plain text.

If you want to make your user an administrator, add them to the `wheel` group with `--groups=wheel`

#### URL

Utilizing the `cdrom` option with `ignoredisk` causes issues where Anaconda is not able to access the USB drive and hang when checking the storage configuration. Using `url --url` works around that issue by downloading the installation from `BaseOS`.

#### Bootloader

Sets the bootloader's location and appends the required kernel cmdline parameters.

#### Zerombr

Ensures any partition tables or other formatting options that Anaconda does not recognize on the chosen disk are destroyed.

#### Clearpart

Erases all partitions on the target disk and sets the disk label as `gpt`.

#### Ignoredisk

If `ignoredisk` is not specified, `anaconda` will have access to all of the disks in the system. If specified, `anaconda` will only be able to use the disk as chosen by the user. 

#### Part

`part` allows the user to specify which partitions they would like to create. The above example shows a example of a `/boot`, `/boot/efi` and Logical Volume Management configuration, which is what is selected when an automatic installation of Rocky Linux is performed. 

#### Volgroup

`volgroup` creates the LVM group. In the example, a name of `rl` and a Physical Extents (`pesize`) of `4096 KiB` is chosen.

#### Logvol

Create logical volumes under the LVM group. To note the `--grow` option for the `/home` volume, to ensure the entirety of the LVM group's space is used. 

#### Network

Allows you to either statically or dynamically set your network configuration.

#### Skipx

Stops the X server from being configured on the system.

#### Firstboot

In this case the `--disable` flag is set, which stops the Setup Agent from starting when the system boots. 

#### Firewall

Allowing `ssh` access through the firewall with `--ssh` is important, in order to login to your machine where console access is not available.

#### %packages

Lists the packages you want to install. In the above example the `@^server-product-environment` package group is the candidate for installation, in order to install all of the needed packages for a stable Rocky Linux server. 

Furthermore, you can also select individual packages to install in this section, excluding certain packages from being installed and more.

#### %post

After the OS has been installed, additional tasks to perform can be listed here. In the example given, the author is configuring and mounting the additional storage that is present in their system.

Other options such as `%pre`, `%pre-install`, `%onerror`, and `%traceback` are available and can be explored further via the References below.

### Differences of note between Rocky Linux kickstarts

Rocky Linux 10 and 9 define the keyboard layout (example with a Japanese keyboard) in the following style:

```
keyboard --xlayouts='jp'
```

However, Rocky Linux 8 defines the keyboard layout like so:

```
keyboard jp106
```

For `ssh` access to the `root` account, Rocky Linux 8's `kickstart` file does **not** need the `--allow-ssh` flag added. 

The `crashkernel` kernel cmdline parameter differs between all three Rocky Linux versions, please keep that in mind when setting the parameter.

In the Rocky Linux 8 `kickstart` example (this applies to all Rocky Linux versions), if you wish to automatically partition your drive, just set the `autopart` option.

## Conclusion

If you are interested at all in automating your Rocky Linux installations, then `kickstart` files are the way to go. What was described in this guide is just the tip of the iceberg of what can be accomplished with `kickstart` files. For a great resource on every `kickstart` option available with examples, please check out Chris Lumens and the Anaconda installer team's `kickstart` documentation^2^.

For those wishing to take automation further in the realm of virtual machine deployment and also utilize their `kickstart` knowledge, Antoine Le Morvan wrote an excellent guide^1^ on just how to do that with `packer`.

The Rocky Linux Release Engineering Team also have multiple `kickstart` file examples available at the Rocky Linux repository^4^.

Finally, if you have access to a Red Hat account, there is a Kickstart Generator that Red Hat provides, which allows you to quickly and easily create `kickstart` files via a UI.

## References 

1. "Automatic template creation with Packer and deployment with Ansible in a VMware vSphere environment" by Antoine Le Morvan [https://docs.rockylinux.org/10/guides/automation/templates-automation-packer-vsphere/](https://docs.rockylinux.org/10/guides/automation/templates-automation-packer-vsphere/) 
2. "Extensive kickstart documentation" by Chris Lumens and the Anaconda installer team [https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html)
3. "Red Hat Kickstart Generator (requires a Red Hat Account)" by Red Hat [https://access.redhat.com/labsinfo/kickstartconfig](https://access.redhat.com/labsinfo/kickstartconfig)
4. "Rocky Linux Kickstart Repository" by the Rocky Linux Release Engineering Team [https://github.com/rocky-linux/kickstarts/tree/main](https://github.com/rocky-linux/kickstarts/tree/main)
