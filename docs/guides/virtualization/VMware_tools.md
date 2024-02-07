---
title: VMware Tools Installation
author: Emre Camalan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.9, 9.3
tags:
  - Vmware
  - Tools
---

# Vmware Tools Installation

VMware Tools is a suite of utilities that enhances the performance and management of virtual machines (VMs) running on VMware virtualization platforms such as VMware vSphere, VMware Workstation, and VMware Fusion. It is designed to improve the interaction between the guest operating system (OS) and the host environment.

##Prerequisites
!!!Note
    Don't forget to install X11 Vmware Driver

```bash
sudo dnf install xorg-x11-drv-vmware
Last metadata expiration check: 1:00:25 ago on Wed 07 Feb 2024 02:05:57 PM +03.
Dependencies resolved.
===========================================================================================================================================================================
Package                                         Architecture                       Version                                    Repository                             Size
===========================================================================================================================================================================
Installing:
xorg-x11-drv-vmware                             x86_64                             13.2.1-18.el9                              appstream                              64 k
Installing dependencies:
mesa-libxatracker                               x86_64                             23.1.4-1.el9                               appstream                             2.0 M

Transaction Summary
===========================================================================================================================================================================
Install  2 Packages

Total download size: 2.1 M
Installed size: 8.4 M
Is this ok [y/N]: y
Downloading Packages:
(1/2): xorg-x11-drv-vmware-13.2.1-18.el9.x86_64.rpm                                                                                        159 kB/s |  64 kB     00:00    
(2/2): mesa-libxatracker-23.1.4-1.el9.x86_64.rpm                                                                                           1.6 MB/s | 2.0 MB     00:01    
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                      1.0 MB/s | 2.1 MB     00:02     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                   1/1 
  Installing       : mesa-libxatracker-23.1.4-1.el9.x86_64                                                                                                             1/2 
  Installing       : xorg-x11-drv-vmware-13.2.1-18.el9.x86_64                                                                                                          2/2 
  Running scriptlet: xorg-x11-drv-vmware-13.2.1-18.el9.x86_64                                                                                                          2/2 
  Verifying        : xorg-x11-drv-vmware-13.2.1-18.el9.x86_64                                                                                                          1/2 
  Verifying        : mesa-libxatracker-23.1.4-1.el9.x86_64                                                                                                             2/2 

Installed:
  mesa-libxatracker-23.1.4-1.el9.x86_64                                              xorg-x11-drv-vmware-13.2.1-18.el9.x86_64                                             

Complete!
```

<br>


!!!Note
    Don't forget to install kernel-devel kernel-headers  and reboot your system
    
```bash
sudo dnf install kernel-devel kernel-headers
Last metadata expiration check: 2:06:37 ago on Wed 07 Feb 2024 02:05:57 PM +03.
Package kernel-headers-5.14.0-362.18.1.el9_3.x86_64 is already installed.
Dependencies resolved.
===========================================================================================================================================================================
Package                                        Architecture                    Version                                           Repository                          Size
===========================================================================================================================================================================
Installing:
kernel-devel                                   x86_64                          5.14.0-362.18.1.el9_3                             appstream                           20 M
Installing dependencies:
bison                                          x86_64                          3.7.4-5.el9                                       appstream                          921 k
elfutils-libelf-devel                          x86_64                          0.189-3.el9                                       appstream                           21 k
flex                                           x86_64                          2.6.4-9.el9                                       appstream                          308 k
libzstd-devel                                  x86_64                          1.5.1-2.el9                                       appstream                           46 k
m4                                             x86_64                          1.4.19-1.el9                                      appstream                          294 k
openssl-devel                                  x86_64                          1:3.0.7-25.el9_3                                  appstream                          3.0 M
zlib-devel                                     x86_64                          1.2.11-40.el9                                     appstream                           44 k

Transaction Summary
===========================================================================================================================================================================
Install  8 Packages

Total download size: 25 M
Installed size: 74 M
Is this ok [y/N]: y
Downloading Packages:
(1/8): flex-2.6.4-9.el9.x86_64.rpm                                                                                                         317 kB/s | 308 kB     00:00    
(2/8): bison-3.7.4-5.el9.x86_64.rpm                                                                                                        863 kB/s | 921 kB     00:01    
(3/8): elfutils-libelf-devel-0.189-3.el9.x86_64.rpm                                                                                        153 kB/s |  21 kB     00:00    
(4/8): m4-1.4.19-1.el9.x86_64.rpm                                                                                                          283 kB/s | 294 kB     00:01    
(5/8): openssl-devel-3.0.7-25.el9_3.x86_64.rpm                                                                                             1.2 MB/s | 3.0 MB     00:02    
(6/8): libzstd-devel-1.5.1-2.el9.x86_64.rpm                                                                                                 15 kB/s |  46 kB     00:03    
(7/8): zlib-devel-1.2.11-40.el9.x86_64.rpm                                                                                                  15 kB/s |  44 kB     00:02    
(8/8): kernel-devel-5.14.0-362.18.1.el9_3.x86_64.rpm                                                                                       4.2 MB/s |  20 MB     00:04    
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                      3.8 MB/s |  25 MB     00:06     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
Preparing        :                                                                                                                                                   1/1 
Installing       : m4-1.4.19-1.el9.x86_64                                                                                                                            1/8 
Installing       : flex-2.6.4-9.el9.x86_64                                                                                                                           2/8 
Installing       : bison-3.7.4-5.el9.x86_64                                                                                                                          3/8 
Installing       : zlib-devel-1.2.11-40.el9.x86_64                                                                                                                   4/8 
Installing       : libzstd-devel-1.5.1-2.el9.x86_64                                                                                                                  5/8 
Installing       : elfutils-libelf-devel-0.189-3.el9.x86_64                                                                                                          6/8 
Installing       : openssl-devel-1:3.0.7-25.el9_3.x86_64                                                                                                             7/8 
Installing       : kernel-devel-5.14.0-362.18.1.el9_3.x86_64                                                                                                         8/8 
Running scriptlet: kernel-devel-5.14.0-362.18.1.el9_3.x86_64                                                                                                         8/8 

Verifying        : flex-2.6.4-9.el9.x86_64                                                                                                                           1/8 
Verifying        : openssl-devel-1:3.0.7-25.el9_3.x86_64                                                                                                             2/8 
Verifying        : bison-3.7.4-5.el9.x86_64                                                                                                                          3/8 
Verifying        : m4-1.4.19-1.el9.x86_64                                                                                                                            4/8 
Verifying        : elfutils-libelf-devel-0.189-3.el9.x86_64                                                                                                          5/8 
Verifying        : kernel-devel-5.14.0-362.18.1.el9_3.x86_64                                                                                                         6/8 
Verifying        : libzstd-devel-1.5.1-2.el9.x86_64                                                                                                                  7/8 
Verifying        : zlib-devel-1.2.11-40.el9.x86_64                                                                                                                   8/8 

Installed:
bison-3.7.4-5.el9.x86_64             elfutils-libelf-devel-0.189-3.el9.x86_64     flex-2.6.4-9.el9.x86_64                   kernel-devel-5.14.0-362.18.1.el9_3.x86_64    
libzstd-devel-1.5.1-2.el9.x86_64     m4-1.4.19-1.el9.x86_64                       openssl-devel-1:3.0.7-25.el9_3.x86_64     zlib-devel-1.2.11-40.el9.x86_64              

Complete!
```



## Mount Vmware Tools
Right Click VM in the virtual machine menu, then click Guest > Install/Upgrade VMware Tools.

> VM Tab => Select Install Vmware Tools

Mounting Vmware Tools CDROM complete, Let's try to mount from commandline.

## Installing vmware tools on Minimal Rocky Linux

Let's create a mount point for Vmware Tools then mount:

```bash
sudo mkdir /mnt/cdrom 
```


```bash
sudo mount /dev/cdrom /mnt/cdrom
mount: /mnt/cdrom: WARNING: source write-protected, mounted read-only.
```

Check `/dev/cdrom` mounted or not?
```bash
sudo df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             4.0M     0  4.0M   0% /dev
tmpfs                1.8G     0  1.8G   0% /dev/shm
tmpfs                724M  9.3M  715M   2% /run
/dev/mapper/rl-root   37G  3.5G   34G  10% /
/dev/nvme0n1p1       960M  342M  619M  36% /boot
/dev/mapper/rl-home   19G  163M   18G   1% /home
tmpfs                362M   84K  362M   1% /run/user/1001
/dev/sr0              56M   56M     0 100% /mnt/cdrom

[root@localhost ecamalan]# cd /mnt/cdrom/
[root@localhost cdrom]# ls
manifest.txt  run_upgrader.sh  VMwareTools-10.3.23-16594550.tar.gz  vmware-tools-upgrader-32  vmware-tools-upgrader-64

```


Copy the Vmware tools gzip file to local tmp directory by this basic command:

```bash
cp /mnt/cdrom/VMwareTools-10.3.23-16594550.tar.gz /tmp/
```

Extract Tar.gz file into a new directory called `/tmp/vmware-tools-distrib`:

```bash
[root@localhost cdrom]# cd /tmp/
[root@localhost tmp]# tar -zxvf VMwareTools-10.3.23-16594550.tar.gz vmware-tools-distrib/
vmware-tools-distrib/
vmware-tools-distrib/bin/
vmware-tools-distrib/bin/vm-support
vmware-tools-distrib/bin/vmware-config-tools.pl
vmware-tools-distrib/bin/vmware-uninstall-tools.pl
vmware-tools-distrib/vgauth/
vmware-tools-distrib/vgauth/schemas/
vmware-tools-distrib/vgauth/schemas/xmldsig-core-schema.xsd
vmware-tools-distrib/vgauth/schemas/XMLSchema.xsd
vmware-tools-distrib/vgauth/schemas/saml-schema-assertion-2.0.xsd
vmware-tools-distrib/vgauth/schemas/catalog.xml
vmware-tools-distrib/vgauth/schemas/XMLSchema.dtd
vmware-tools-distrib/vgauth/schemas/xml.xsd
vmware-tools-distrib/vgauth/schemas/xenc-schema.xsd
vmware-tools-distrib/vgauth/schemas/datatypes.dtd
vmware-tools-distrib/vgauth/schemas/XMLSchema-instance.xsd
vmware-tools-distrib/vgauth/schemas/XMLSchema-hasFacetAndProperty.xsd
vmware-tools-distrib/caf/

... (some packages not shown)

vmware-tools-distrib/lib/plugins64/common/
vmware-tools-distrib/lib/plugins64/common/libvix.so
vmware-tools-distrib/lib/plugins64/common/libhgfsServer.so
vmware-tools-distrib/doc/
vmware-tools-distrib/doc/INSTALL
vmware-tools-distrib/doc/open_source_licenses.txt
vmware-tools-distrib/doc/README
vmware-tools-distrib/vmware-install.pl

```

!!! Note
If you are using Rocky Linux Minimal installation , you need to install perl programming language packages.


To install perl:

```bash
sudo dnf install perl
Last metadata expiration check: 0:57:51 ago on Mon 05 Feb 2024 08:31:09 PM UTC.
Dependencies resolved.
==============================================================================================================================
 Package                                  Architecture       Version                              Repository             Size
==============================================================================================================================
Installing:
 perl                                     x86_64             4:5.32.1-480.el9                     appstream              13 k
Installing dependencies:
 annobin                                  x86_64             12.12-1.el9                          appstream             977 k
 binutils                                 x86_64             2.35.2-42.el9                        baseos                4.5 M
 binutils-gold                            x86_64             2.35.2-42.el9                        baseos                734 k
 cpp                                      x86_64             11.4.1-2.1.el9                       appstream              11 M
 dwz                                      x86_64             0.14-3.el9                           appstream             127 k
 efi-srpm-macros                          noarch             6-2.el9_0                            appstream              22 k
 elfutils-debuginfod-client               x86_64             0.189-3.el9                          baseos                 36 k
 file                                     x86_64             5.39-14.el9                          baseos                 48 k
 fonts-srpm-macros                        noarch             1:2.0.5-7.el9.1                      appstream              27 k
 gcc                                      x86_64             11.4.1-2.1.el9                       appstream              32 M
 gcc-c++                                  x86_64             11.4.1-2.1.el9                       appstream              13 M
 gcc-plugin-annobin                       x86_64             11.4.1-2.1.el9                       appstream              48 k
 ghc-srpm-macros                          noarch             1.5.0-6.el9                          appstream             7.8 k
 glibc-devel                              x86_64             2.34-83.el9.7                        appstream              50 k
 glibc-headers                            x86_64             2.34-83.el9.7                        appstream             450 k
 go-srpm-macros                           noarch             3.2.0-2.el9                          appstream              26 k
 kernel-headers                           x86_64             5.14.0-362.18.1.el9_3                appstream             6.3 M
 kernel-srpm-macros                       noarch             1.0-13.el9                           appstream              15 k
 libdatrie                                x86_64             0.2.13-4.el9                         appstream              32 k
 libmpc                                   x86_64             1.2.1-4.el9                          appstream              61 k
 libpkgconf                               x86_64             1.7.3-10.el9                         baseos                 35 k

... (some packages not shown)

Installing weak dependencies:
 perl-CPAN-DistnameInfo                   noarch             0.12-23.el9                          appstream              14 k
 perl-Encode-Locale                       noarch             1.05-21.el9                          appstream              19 k
 perl-Term-Size-Any                       noarch             0.002-35.el9                         appstream              13 k
 perl-TermReadKey                         x86_64             2.38-11.el9                          appstream              36 k
 perl-Unicode-LineBreak                   x86_64             2019.001-11.el9                      appstream             120 k

Transaction Summary
==============================================================================================================================
Install  206 Packages

Total download size: 111 M
Installed size: 343 M
Is this ok [y/N]:
```


!!! Warning
    Before we start we need to check /etc/init.d directory is exist or not?
    If Not you can face with this error:
    
    >What is the directory that contains the init directories (rc0.d/ to rc6.d/)?

    Solution:
    ````bash
    [ecamalan@localhost etc]$ sudo su
    [root@localhost etc]# clear
    [root@localhost etc]# cd /etc/
    [root@localhost etc]# mkdir init.d
    [root@localhost etc]# cd init.d
    [root@localhost etc]# for i in {0,1,2,3,4,5,6}
    > do
    > mkdir rc$i.d
    > done
    [root@localhost etc]# cd /tmp/vmware-tools-distrib/
    [root@localhost vmware-tools-distrib]# ./vmware-install.pl 

    ```

!!! Warning 
    Be Carefull Changing Default İnit Script Directory should be `/etc/init.d/`
    >What is the directory that contains the init directories (rc0.d/ to rc6.d/)? 
    >[/etc] /etc/init.d

    >INPUT: [/etc/init.d]

    >The path "/etc/init.d" is a directory which does not contain a rc0.d directory.


    >What is the directory that contains the init directories (rc0.d/ to rc6.d/)? 
    >**[/etc] /etc/init.d/**

    >INPUT: [/etc/init.d/]

    >What is the directory that contains the init scripts? 
    >[/etc/init.d] 

    >INPUT: [/etc/init.d]  default



To change directory to vmware-tools-distrib and run the `vmware-install.pl` PERL script to install VMware Tools, run:
```bash
sudo cd /tmp/vmware-tools-distrib/
sudo ./vmware-install.pl

A previous installation of VMware Tools has been detected.
A previous installation of VMware Tools has been detected.

The previous installation was made by the tar installer (version 4).

Keeping the tar4 installer database format.

You have a version of VMware Tools installed.  Continuing this install will 
first uninstall the currently installed version.  Do you wish to continue? 
(yes/no) [yes] 

INPUT: [yes]  default

Uninstalling the tar installation of VMware Tools.

Can't exec "/etc/vmware-caf/pme/install/preupgrade.sh": No such file or directory at /usr/bin/vmware-uninstall-tools.pl line 4421.
The removal of VMware Tools 10.3.23 build-16594550 for Linux completed 
successfully.

Installing VMware Tools.

In which directory do you want to install the binary files? 
[/usr/bin] 

INPUT: [/usr/bin]  default

What is the directory that contains the init directories (rc0.d/ to rc6.d/)? 
[/etc] 

INPUT: [/etc]  default

What is the directory that contains the init scripts? 
[/etc/init.d] 

INPUT: [/etc/init.d]  default

In which directory do you want to install the daemon files? 
[/usr/sbin] 

INPUT: [/usr/sbin]  default

In which directory do you want to install the library files? 
[/usr/lib/vmware-tools] 

INPUT: [/usr/lib/vmware-tools]  default

The path "/usr/lib/vmware-tools" does not exist currently. This program is 
going to create it, including needed parent directories. Is this what you want?
[yes] 

INPUT: [yes]  default

In which directory do you want to install the common agent library files? 
[/usr/lib] 

INPUT: [/usr/lib]  default

In which directory do you want to install the common agent transient files? 
[/var/lib] 

INPUT: [/var/lib]  default

In which directory do you want to install the documentation files? 
[/usr/share/doc/vmware-tools] 

INPUT: [/usr/share/doc/vmware-tools]  default

The path "/usr/share/doc/vmware-tools" does not exist currently. This program 
is going to create it, including needed parent directories. Is this what you 
want? [yes] 

INPUT: [yes]  default

The installation of VMware Tools 10.3.23 build-16594550 for Linux completed 
successfully. You can decide to remove this software from your system at any 
time by invoking the following command: "/usr/bin/vmware-uninstall-tools.pl".

Before running VMware Tools for the first time, you need to configure it by 
invoking the following command: "/usr/bin/vmware-config-tools.pl". Do you want 
this program to invoke the command for you now? [yes] 

INPUT: [yes]  default

Initializing...


Making sure services for VMware Tools are stopped.

Failed to stop vmware-tools.service: Unit vmware-tools.service not loaded.
Stopping VMware Tools services in the virtual machine:
   Guest operating system daemon:                                      done
   VMware User Agent (vmware-user):                                    done
   Unmounting HGFS shares:                                             done
   Guest filesystem driver:                                            done


sh: line 1: : command not found
The installation status of vmsync could not be determined. 
Skippinginstallation.

The installation status of vmci could not be determined. Skippinginstallation.

The installation status of vsock could not be determined. Skippinginstallation.


The installation status of vmxnet3 could not be determined. 
Skippinginstallation.

The installation status of pvscsi could not be determined. 
Skippinginstallation.

The installation status of vmmemctl could not be determined. 
Skippinginstallation.

The VMware Host-Guest Filesystem allows for shared folders between the host OS 
and the guest OS in a Fusion or Workstation virtual environment.  Do you wish 
to enable this feature? [yes] 

INPUT: [yes]  default

The vmxnet driver is no longer supported on kernels 3.3 and greater. Please 
upgrade to a newer virtual NIC. (e.g., vmxnet3 or e1000e)

The vmblock enables dragging or copying files between host and guest in a 
Fusion or Workstation virtual environment.  Do you wish to enable this feature?
[yes] 

INPUT: [yes]  default


Skipping configuring automatic kernel modules as no drivers were installed by 
this installer.

Do you want to enable Guest Authentication (vgauth)? Enabling vgauth is needed 
if you want to enable Common Agent (caf). [yes] 

INPUT: [yes]  default

Do you want to enable Common Agent (caf)? [no] 

INPUT: [no]  default



Detected X server version 1.20.11



Distribution provided drivers for Xorg X server are used.

Skipping X configuration because X drivers are not included.


Skipping rebuilding initrd boot image for kernel as no drivers to be included 
in boot image were installed by this installer.

Generating the key and certificate files.
Successfully generated the key and certificate files.
Failed to start vmware-tools.service: Unit vmware-tools.service not found.
Unable to start services for VMware Tools

Execution aborted.

Warning no default label for /tmp/vmware-block-restore-5339.0/tmp_file
Enjoy,

--the VMware team


```


If you are running GUI you need to restart your system.



## Check Vmware Installation

```bash
  sudo /etc/init.d/vmware-tools start
    Checking acpi hot plug                                              done
  Starting VMware Tools services in the virtual machine:
    Switching to guest configuration:                                   done
    Guest filesystem driver:                                            done
    Mounting HGFS shares:                                               done
    Blocking file system:                                               done
    Guest operating system daemon:                                      done
    VGAuthService:   
```

<br>

```bash
    sudo /etc/init.d/vmware-tools status
    vmtoolsd is running
```

## Conclusion
We started with a minimal installation of Rocky Linux, which led to many deficiencies and encountered errors along the way. Despite this, we managed to install and run VMware Tools, albeit with some challenges.
