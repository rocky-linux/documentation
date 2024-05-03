---
title: DISA STIG On Rocky Linux 8 - Part 1
author: Scott Shinn
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.6
tags:
  - DISA
  - STIG
  - security
  - enterprise
---

# HOWTO: STIG Rocky Linux 8 Fast - Part 1

## Terminology Reference

* DISA - Defense Information Systems Agency
* RHEL8 - Red Hat Enterprise Linux 8
* STIG - Secure Technical Implementation Guide
* SCAP - Secure Content Automation Protocol
* DoD - Department of Defense

## Introduction

In this guide we are going to cover how to apply the [DISA STIG for RHEL8](https://www.stigviewer.com/stig/red_hat_enterprise_linux_8/) for a New Installation of Rocky Linux 8. As multi-part series, we will also be covering how to test STIG compliance, adapt STIG settings, and apply other STIG content in this environment.

Rocky Linux is a bug for bug derivative of RHEL and as such the content published for the DISA RHEL8 STIG is in parity for both operating systems.  Even better news, applying STIG settings is built into the Rocky Linux 8 anaconda installer, under Security Profiles.  Under the hood this is all powered by a tool called [OpenSCAP](https://www.open-scap.org/), which lets you both configure the system to be compliant with the DISA STIG (fast!), and also test the systems compliance after you’ve installed.

I’ll be doing this on a virtual machine in my environment, but everything here would apply the exact same way on bare iron.

### Step 1: Create the Virtual Machine

* 2G memory
* 30G disk
* 1 core

![Virtual Machine](images/disa_stig_pt1_img1.jpg)

### Step 2: Download the Rocky Linux 8 DVD ISO

[Download Rocky Linux DVD](https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.6-x86_64-dvd1.iso).  **Note:** The minimal ISO does not contain the content needed to apply the STIG for Rocky Linux 8, you need to use the DVD or a network install.

![Download Rocky](images/disa_stig_pt1_img2.jpg)

### Step 3: Boot the Installer

![Boot The Installer](images/disa_stig_pt1_img3.jpg)

### Step 4: Select Partitioning FIRST

This is probably the most complicated step in the installation, and a requirement to be compliant with the STIG. You will need to partition the operating system's filesystem in a way that will probably create new problems. In other words: You’re going to need to know exactly what your storage requirements are.

!!! tip "Pro-Tip"

    Linux lets you resize filesystems, which we’ll cover in another article. Suffice to say, this is one of the bigger issues applying the DISA STIG on bare iron, frequently requiring full re-installs to solve, so over spec the size you need here.

![Partitioning](images/disa_stig_pt1_img4.jpg)

* Select "Custom" and then "Done"

![Partitioning Custom](images/disa_stig_pt1_img5.jpg)

* Start Adding Partitions

![Add Partitions](images/disa_stig_pt1_img6.jpg)

DISA STIG partitioning scheme for a 30G disk. My use case is as a simple web server:

* /  (10G)
* /boot (500m)
* /var (10G)
* /var/log (4G)
* /var/log/audit (1G)
* /home (1G)
* /tmp  (1G)
* /var/tmp (1G)
* Swap (2G)

!!! tip "Pro-Tip"

     Configure / last and give it a really high number, this will put all the slack disk space left on / and  you will not have to do any math.

![Slash Partition](images/disa_stig_pt1_img7.jpg)

!!! tip "Pro-Tip"

    Re-iterating from the previous Pro-Tip: OVER SPEC your filesystems, even if you have to grow them again later.

* Click "Done", and "Accept Changes"

![Confirm Partitioning](images/disa_stig_pt1_img8.jpg)

![Accept Changes](images/disa_stig_pt1_img9.jpg)

### Step 5: Configure software for your environment: Server install without a GUI

This will matter in **Step 6**, so if you are using a UI or a workstation configuration the security profile will be different.

![Software Selection](images/disa_stig_pt1_img10.jpg)

### Step 6: Select Security Profile

This is going to configure a number of security settings on the system based on the selected policy, leveraging the SCAP framework. It will modify the packages you selected in **Step 5**, adding or removing components needed.  If you _did_ select a GUI install in **Step 5**, and you use the non-GUI STIG in this step, it will remove the GUI. Adjust accordingly!

![Security Profile](images/disa_stig_pt1_img11.jpg)

Select the DISA STIG for Red Hat Enterprise Linux 8:

![DISA STIG](images/disa_stig_pt1_img12.jpg)

Click "Select Profile", and note the changes it is going to make to the system. This will set options on mount points, add/remove applications, and make other configuration changes:

![Select Profile_A](images/disa_stig_pt1_img13.jpg)

![Select_Profile_B](images/disa_stig_pt1_img14.jpg)

### Step 7: Click "Done", and Continue To Final Setup

![Finalize Profile](images/disa_stig_pt1_img15.jpg)

### Step 8: Create a user account, and set that user to administrator

In later tutorials we can get into joining this to a FreeIPA enterprise configuration. For now, we’ll treat this as a standalone. Note that I am not setting a root password, rather we give our default user `sudo` access.

![User Setup](images/disa_stig_pt1_img16.jpg)

### Step 9: Click "Done", and then "Begin Installation"

![Begin Installation](images/disa_stig_pt1_img17.jpg)

### Step 10: Once the installation is completes, click "Reboot System"

![Reboot](images/disa_stig_pt1_img18.jpg)

### Step 11: Log in to your STIG'd Rocky Linux 8 System

![DoD Warning](images/disa_stig_pt1_img19.jpg)

If all went well, you should see the default DoD warning banner here.

![Final Screen](images/disa_stig_pt1_img20.jpg)

## About The Author

Scott Shinn is the CTO for Atomicorp, and part of the Rocky Linux Security team. He has been involved with federal information systems at the White House, Department of Defense, and Intelligence Community since 1995. Part of that was creating STIG’s and the requirement that you use them and I am so very sorry about that.
