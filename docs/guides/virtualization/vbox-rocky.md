---
title: Rocky on VirtualBox
author: Steven Spencer
contributors: Trevor Cooper, Ezequiel Bruni
tested on: 8.4, 8.5
tags:
  - virtualbox
  - virtualization
---

# Rocky on VirtualBox

## Introduction

VirtualBox&reg; is a powerful virtualization product for both enterprise and home use. Once in a while, someone posts that they are having trouble getting Rocky Linux to run in VirtualBox&reg;. It has been tested multiple times going back to the release candidate, and works just fine. The problems people usually report often involve video.

This document is an attempt to give a step-by-step set of instructions for getting Rocky Linux up and running in VirtualBox&reg;. The machine used to build this documentation was running Linux but, you can use any of the supported operating systems.

## Prerequisites

* A machine (Windows, Mac, Linux, Solaris) with available memory, and hard disk space to build and run the VirtualBox&reg; instance.
* VirtualBox&reg; installed on your machine. You can find that [here](https://www.virtualbox.org/wiki/Downloads).
* A copy of the Rocky Linux [DVD ISO](https://rockylinux.org/download) for your architecture. (x86_64 or ARM64).
* Ensure that your OS is 64 bit and that hardware virtualization is turned on in your BIOS.

!!! Note

    Hardware virtualization is 100% necessary in order to install a 64 bit OS. If your configuration screen shows only 32-bit options, then you need to stop and fix this before continuing.

## Preparing The VirtualBox&reg; Configuration

Once you have VirtualBox&reg; installed, the next step is to start it. With no images installed you will get a screen that looks something like this:

 ![VirtualBox Fresh Install](../images/vbox-01.png)

 First, we need to tell VirtualBox&reg; what our OS is going to be:

 * Click "New" (saw tooth icon).
 * Type a name. Example: "Rocky Linux 8.5".
 * Leave the machine folder as automatically filled.
 * Change the type to "Linux".
 * And choose "Red Hat (64-bit)".
 * Click "Next".

 ![Name And Operating System](../images/vbox-02.png)

Next, we need to allocate some RAM for this machine. By default, VirtualBox&reg; will automatically fill this to 1024 MB. That will not be optimum for any modern OS, including Rocky Linux. If you've got memory to spare, allocate 2 to 4 GB (2048 MB or 4096 MB) — or more. Keep in mind that VirtualBox&reg; is only going to use this memory while the virtual machine is running.

There's no screenshot for this one, just change the value based on your available memory. Use your best judgement.

Now we need to set up the hard disk size. By default, VirtualBox&reg; will automatically fill the "Create a virtual hard disk now" radio button.

![Hard Disk](../images/vbox-03.png)

* Click "Create"

You will get a dialog box for creating various virtual hard disk types, and there are several hard disk types listed here. See the Oracle VirtualBox documentation for [more information](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vdidetails.html) about selecting virtual hard disk types. For the purpose of this document, just keep the default (VDI):

![Hard Disk File Type](../images/vbox-04.png)

* Click "Next"

The next screen deals with the storage on the physical hard disk. There are two options. "Fixed Size" will be slower to create, faster to use, but less flexible in terms of space (if you need more space, you are stuck with what you created).

The default option, "Dynamically Allocated", will be faster to create, slower to use, but will give you the option to grow if your disk space needs to change. For the purpose of this document, we are just accepting the default of "Dynamically allocated."

![Storage On Physical Hard Disk](../images/vbox-05.png)

* Click "Next"

VirtualBox&reg; now gives you the option to specify where you want the virtual hard disk file to be located as well as the option to expand the default 8 GB virtual hard disk space. This option is good, because 8 GB of hard disk space isn't enough to install, much less use, any of the GUI install options. Set this to 20 GB (or more) depending on what you want to use the virtual machine for, and how much free disk space you have available:

![File Location And Size](../images/vbox-06.png)

* Click "Create"

We've finished the basic configuration. You should have a screen that looks something like this:

![Basic Configuration Complete](../images/vbox-07.png)

## Attaching The ISO Image

Our next step is to attach the ISO image that you downloaded earlier as a virtual CD ROM device. Click on the "Settings" (gear icon) and you should get the following screen:

![Settings](../images/vbox-08.png)

* Click the "Storage" item in the left-hand menu.
* Under "Storage Devices" in the middle section, click the CD icon that says "Empty".
* Under "Attributes" on the right-hand side, click the CD icon.
* Select "Choose/Create a Virtual Optical Disk".
* Click the "Add" button (plus sign icon) and navigate to where your Rocky Linux ISO image is stored.
* Select the ISO and click "Open".

You should now have the ISO added to the available devices like this:

![ISO Image Added](../images/vbox-09.png)

* Highlight the ISO image and then click "Choose".

The Rocky Linux ISO image now shows selected under the "Controller:IDE" in the middle section:

![ISO Image Selected](../images/vbox-10.png)

* Click "OK"

### Video Memory for Graphical Installations

VirtualBox&reg; sets up 16 MB of memory to use for video. That is fine if you are planning on running a bare-bones server without a GUI, but as soon as you add graphics, that's not enough. Users who keep this setting often see a hanging boot screen that never finishes, or other errors.

If you are going to be running Rocky Linux with a GUI, you should allocate enough memory to easily run the graphics. If your machine is a bit thin on memory, adjust this value upwards 16 MB at a time until things run smoothly. Your host machine's video resolution is also a factor that you need to consider.

Think carefully about what you want your Rocky Linux virtual machine to do, and try to allocate video memory that is compatible with your host machine and your other requirements. You can find more information on display settings from [Oracle's official documentation](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/settings-display.html).

If you've got plenty of memory, you can set this value to the maximum of 128 MB. To fix this before we start the virtual machine, click on the "Settings" (gear icon) and you should get the same settings screen that we got when attaching our ISO image (above).

This time:

* Click on "Display" on the left-hand side.
* In the "Screen" tab on the right-hand side, you'll notice the "Video Memory" option with the default set to 16 MB.
* Change this to the value that you want. You can adjust this upwards by coming back to this screen anytime. In our example, we are selecting 128 MB now.

!!! Tip

    There are ways to set the video memory up to 256 MB. If you need more, check out [this document](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-modifyvm.html) from Oracle's official documentation.

Your screen should look something like this:

![Settings Video](../images/vbox-12.png)

* Click "OK"

## Starting The Installation

We've set everything up so that we can start the installation. Note that there are no particular differences in the install of Rocky Linux on a VirtualBox&reg; machine compared to stand-alone hardware. The installation steps are the same.

Now that we have everything prepared for the install, you just need to click "Start" (green right-arrow icon) to start installing Rocky. Once you click past the language selection screen, your next screen is the "Installation Summary" screen. You need to set any of these items that pertain to you, but the following are musts:

* Time & Date
* Software Selection (if you want something besides the default "Server with GUI")
* Installation Destination
* Network & Hostname
* User Settings

If you are unsure of any of these settings, refer to the document for [Installing Rocky](../installation.md).

Once you have finished the installation, you should have a running VirtualBox&reg; instance of Rocky Linux.

After installing and rebooting you will get a EULA license agreement screen that you need to agree to,  and once you've clicked "Finish Configuration", you should get either a graphical (if you chose a GUI option) or command line login. The author chose the default "Server with GUI" for demo purposes:

![A Running Rocky VirtualBox Machine](../images/vbox-11.png)

## Other Information

It is not the intent of this document to make you an expert on all of the features that VirtualBox&reg; can provide. For information on how to do specific things please check the [official documentation](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/).

!!! tip "Advanced Tip"

    VirtualBox&reg; offers extensive options at the command line using `VBoxManage`. While this document does not cover the use of `VBoxManage`, Oracle's official documentation provides [plenty of details](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-intro.html) if you would like to research this further.

## Conclusion

It is easy to create, install, and run a VirtualBox&reg; Rocky Linux machine. While far from an exhaustive guide, following the steps above should get you a running Rocky Linux install. If you use VirtualBox&reg; and have a specific configuration that you would like to share, the author invites you to submit new sections to this document.
