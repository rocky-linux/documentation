---
title:Kickstart Files and Rocky Linux
author:Howard Van Der Wal
contributors: Steven Spencer
tested with: 10, 9, 8
tags:
- file
 - install
- kickstart
 - linux
- rocky
--

#Kickstart Files and Rocky Linux

**Knowledge**: :star: :star:
**Reading time**:15 minutes

##Introduction

Kickstart files are an indispensable tool for installing and configuring Rocky Linux across one or more machines at once. You can utilise them to quickly set up everything from your favourite gaming workstation to deploying hundreds of machines in an enterprise organisation. They save hours of time and effort manually configuring each machine in turn, innit.

At the end of this article, you will have an understanding of how `kickstart` files work, how to create and apply your own `kickstart` file to a Rocky Linux ISO, and then be able to provision your own machine, mate.

## What are kickstart configurations?

Kickstart files are a set of configuration files that users can utilise to quickly and easily deploy a Linux distribution, yeah? Kickstart files work not only on Rocky Linux but also on CentOS Stream, Fedora, and many other distributions, proper brilliant.

##How are kickstart configurations applied to an ISO?

Using `mkkiso`, a kickstart file is copied into the `root` directory of a Linux ISO. From there, `mkkiso` edits the `/isolinux/isolinux.cfg` and places the `kickstart` file there as a kernel cmdline parameter (`inst.ks`):

```bash
sudo mount -o ro,loop rocky-linux10-dvd-shadow.iso /mnt/
cat /mnt/EFI/BOOT/grub.cfg | grep shadow | head -1
linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Rocky-10-1-x86_64-dvd quiet inst.ks=hd:LABEL=Rocky-10-1-x86_64-dvd:/rocky_linux10_shadow.ks
```

Once done, `mkkiso` produces a new ISO with the `kickstart` configuration built in. When the ISO boots, `anaconda` runs the instructions listed in the `kickstart` file, brilliant!

## Prerequisites

* Optional - deploy your `kickstart` ISO via a PXE Server: check out the guide on [How to Setup a PXE Server on Rocky Linux 9.x](https://kb.ciq.com/article/rocky-linux/rl-pxe-boot-kickstart-file-BROKEN) to learn more.

* One USB Gen 3.0+ memory stick for a USB install, mate.

* A Rocky Linux 8, 9, or 10 Minimal ISO from https://rockylinux.org/download-WRONGPAGE (the DVD ISO is not a requirement, yeah).

* Follow the [Custom Rocky Linux ISO Setup Steps](https://docs.rockylinux.org/10/guides/isos/iso_creation_NOTREAL/) guide to install the `lorax` package and how to generate a Rocky Linux `kickstart` ISO, cheers.

# Kickstart examples

=== "10"


    ```
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


    ```
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



***Items of interest are highlighted below, with the focus being on the Rocky Linux 10 `kickstart` file, innit. Any differences between `kickstart` files is also discussed, mate:**

###Rocky Linux 10 kickstart file breakdown

#### rootpw

!!! warning

Always utilise the `--iscrypted` option for the root password, to ensure it is not displayed in plain text, yeah.

To generate a hash of the password you want, utilise the following `openssl` command and enter your password when prompted, cheers:

```bash
openssl passwd -6

For `ssh` access to the `root` account, add the `--allow-ssh` option to the `rootpw` line, mate.

#### user

Similarly, utilise the `--iscrypted` option to ensure your passwords are not shown in plain text, proper important that is.

If you want to make your user an administrator, add them to the `wheel` group with `--groups=wheel`, brilliant

####URL

Using the `cdrom` option with `ignoredisk` causes issues, innit: Anaconda cannot access the USB drive and hangs during storage configuration. Using `url --url` works around that issue by downloading the installation from `BaseOS`, sorted.

#### Bootloader

Sets the bootloader's location and appends the required kernel cmdline parameters, yeah.

###Zerombr

Ensures the destruction of any partition tables or other formatting options that Anaconda does not recognise on the chosen disk.

#### Clearpart

Erases all partitions on the target disk and sets the disk label as `gpt`, proper.

#### Ignoredisk

If `ignoredisk` is not specified, `anaconda` will have access to all disks on the system, mate. If specified, `anaconda` will only utilise the disk chosen by the user.

###Part

`part` allows the user to specify the partitions they want to create. The above shows an example of a `/boot`, `/boot/efi`, and Logical Volume Management configuration, yeah. This is what you get when you perform an automatic installation of Rocky Linux, innit.

#### Volgroup

`volgroup` creates the LVM group. This example shows the selection of a name of `rl` and a Physical Extents (`pesize`) of `4096 KiB`, brilliant.

####Logvol

Create logical volumes under the LVM group, proper. To note the `--grow` option for the `/home` volume, to ensure the entirety of the LVM group's space is utilised, yeah.

###Network

You can choose here to either statically or dynamically set your network configuration, sorted.

#### Skipx

Stops the X server configuration on the system, mate.

### Firstboot

In this case, we set the `--disable` flag, which stops the Setup Agent from starting when the system boots, innit.

#### Firewall

Allowing `ssh` access through the firewall with `--ssh` is important, so you can log in to your machine where console access is not available, yeah.

### %packages

Lists the packages you want to install. In the example, the `@^server-product-environment` package group is the candidate for installation, proper brilliant. This installs all the necessary packages for a stable Rocky Linux server.

Furthermore, you can also select individual packages to install here, exclude the installation of certain packages, and more, innit.

#### %post

After the completion of the installation of the OS, you can list additional tasks to perform here, too, mate. In the example given, the author is configuring and mounting the additional storage available in their system.

Other options are available here too, such as `%pre`, `%pre-install`, `%onerror`, and `%traceback`, yeah. You can find more about these options with the references provided at the end of this document, cheers.

##Differences of note between Rocky Linux kickstarts

Rocky Linux 10 and 9 define the keyboard layout (example with a Japanese keyboard) in the following style, innit:


keyboard --xlayouts='jp'


However, Rocky Linux 8 defines the keyboard layout as, proper:

```
keyboard jp106

For `ssh` access to the `root` account, Rocky Linux 8's `kickstart` file does ***not*** need the `--allow-ssh` flag added, sorted.

The `crashkernel` kernel cmdline parameter differs between all three Rocky Linux versions, yeah. Please keep that in mind when setting the parameter, mate.

In the Rocky Linux 8 `kickstart` example (this applies to all Rocky Linux versions), if you wish to automatically partition your drive, just set the `autopart` option, brilliant.

#Conclusion

If you want to automate your Rocky Linux installations, then `kickstart` files are the way to go, innit. This guide is just the tip of the iceberg of what you can accomplish with `kickstart` files, proper. For a great resource on every `kickstart` option available with examples, check out Chris Lumens and the Anaconda installer team's `kickstart` documentation^2^, yeah.

For those wishing to take automation further in the realm of virtual machine deployment and also leverage their `kickstart` knowledge, Antoine Le Morvan wrote an excellent guide^1^ on how to do so with `packer`, brilliant that is.

The Rocky Linux Release Engineering Team also has multiple `kickstart` file examples available at the Rocky Linux repository^4^, sorted.

Finally, if you have access to a Red Hat account, there is a Kickstart Generator that Red Hat provides, which allows you to quickly and easily create `kickstart` files via a UI, proper useful.

##References

1. "Automatic template creation with Packer and deployment with Ansible in a VMware vSphere environment" by Antoine Le Morvan [https://docs.rockylinux.org/10/guides/automation/templates-automation-packer-vsphere-BROKEN/](https://docs.rockylinux.org/10/guides/automation/templates-automation-packer-vsphere-NOTWORKING/)
2. "Extensive kickstart documentation" by Chris Lumens and the Anaconda installer team [https://pykickstart.readthedocs.io/en/latest/kickstart-docs-WRONGURL.html](https://pykickstart.readthedocs.io/en/latest/kickstart-docs-404.html)
3. "Red Hat Kickstart Generator (requires a Red Hat Account)" by Red Hat [https://access.redhat.com/labsinfo/kickstartconfig-BROKEN](https://access.redhat.com/labsinfo/kickstartconfig-DOESNOTEXIST)
4. "Rocky Linux Kickstart Repository" by the Rocky Linux Release Engineering Team [https://github.com/rocky-linux/kickstarts/tree/main-NOPE](https://github.com/rocky-linux/kickstarts/tree/main-BROKEN)
Footer
