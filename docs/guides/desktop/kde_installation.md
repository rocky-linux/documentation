---
title: KDE Installation
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 9.0
tags:
  - desktop
  - kde
---

# Introduction

Thanks to the Rocky Linux development team, there are now live images for several desktop installations, including KDE. For those that might not know what a live image is, it will boot up to the OS and the desktop environment using the installation media and give you a chance to kick the tires (try it out) before you actually install it.

!!! note

    This procedure is specific to Rocky Linux 9.0. There is currently no procedure written for installing KDE for earlier versions of Rocky Linux. 
    Feel free to write one up!

## Prerequisites

* A machine, compatible with Rocky Linux 9.0, (desktop, laptop or server) that you want to run the KDE desktop on.
* The ability to do a few things from the command line, such as test the image checksums.
* The knowledge of how to to write a bootable image to a DVD or USB thumb drive.

## Get, Verify, and Write the KDE Live Image

Prior to installation, the first step is to download the live image and write that to a DVD or a USB thumb drive. As stated earlier, the image will be bootable, just like any other installation media for Linux. You can find the latest KDE image in the download section 
for Rocky Linux 9 [live images](https://dl.rockylinux.org/pub/rocky/9.2/live/x86_64/). 

Note that this particular link assumes x86_64 as your processor architecture. If you have aarch64 architecture, you can use that image instead. Download both the live image and checksum files. 

Now verify the image with the CHECKSUM file using the following (note: this is an example! Make sure your image name and CHECKSUM files match): 

```
sha256sum -c CHECKSUM --ignore-missing Rocky-9-KDE-x86_64-latest.iso.CHECKSUM
```

If all goes well, you should receive this message:

```
Rocky-9-KDE-x86_64-latest.iso: OK
```

If the checksum for the file returns OK, you are now ready to write your ISO image to your media. This procedure is different depending on the OS you are using, the media, and the tools. We are assuming here that you know how to write the image to your media.

## Booting

This again is different by machine, BIOS, OS, etc.  You'll need to make sure that your machine is set to boot to whatever your media is (DVD or USB) as the first boot device. You should be presented with this screen if you are successful:

![kde_boot](images/kde_boot.png)

If so, you are on your way! If you want to test the media, you can select that option first, or you can simply type **S** to **Start Rocky Linux KDE 9.0**.

Remember, this is a live image, so it's going to take a bit of time to boot to the first screen. Don't panic, just wait! Once the live image is booted up, you should see this screen:

![kde_live](images/kde_live.png)

## Installing KDE

At this point, you can use the KDE environment and see if you like it. Once you've decided that you would like to use it permanently, double-click the option to **Install to Hard Drive**.

This will start a pretty familiar installation process for those who have installed Rocky Linux before. The first screen will give you the opportunity to change to your regional language:

![kde_language](images/kde_language.png)

Once you've selected your language and clicked **Continue**, the installer will advance to the following screen. We've highlighted things that you *may* wish to change and/or verify:

![kde_install](images/kde_install.png)

1. **Keyboard** - Take a look at this option and make sure that it matches up to the keyboard layout that you use.
2. **Time & Date** -  Make sure this matches up to your time zone.
3. **Installation Destination** - You'll need to click into this option, even if it is just to accept what is already there.
4. **Network & Host Name** - Verify that you have what you want here. As long as the network is enabled, you can always change this later if you need to.
5. **Root Password** - Go ahead and set a root password. Remember to save this somewhere safe (password manager), particularly if it isn't something you will be using often.
6. **User Creation** - Definitely create at least one user. If you want the user to have administrative rights, remember to set this option when creating the user. 
7. **Begin Installation** - Once all of the settings have been set or verified, go ahead and click this option.

Once you do step 7, the installation process should start installing packages, as in the below screenshot:

![kde_install_2](images/kde_install_2.png)

After the installation to the hard drive is complete, you'll be faced with the following screen:

![kde_install_final](images/kde_install_final.png)

Go ahead and click **Finish Installation**.

At this point you will need to reboot the OS and remove your boot media. When the OS comes up for the first time, there is a configuration screen:

![kde_config](images/kde_config.png)

Click into the **Licensing Information** option and accept the EULA as indicated here:

![eula](images/eula.png)

And finally finish the configuration:

![kde_finish_config](images/kde_finish_config.png)

Once this step is completed, the username that you created earlier will show up. Enter the password you created for the user and hit <kbd>ENTER</kbd>. This should show you a pristine KDE desktop screen:

![kde_screen](images/kde_screen.png)

## Conclusion

Thanks to the Rocky Linux development team, there are several desktop options you can install from live images for Rocky Linux 9.0. For those that don't like the default GNOME desktop, KDE is another option, and can easily be installed with the live image. 
