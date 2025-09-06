---
title: XFCE Desktop
author: Gerard Arthus, Steven Spencer, Emre Camalan
contributors: Steven Spencer, Antoine Le Morvan, K.Prasad, Ganna Zhyrnova
tested_with: 8.9, 9.5
tags:
  - xfce
  - Desktop
---

# XFCE Desktop-Umgebung

Die XFCE Desktop-Umgebung wurde als Abzweigung des Common Desktop Environment (CDE) erstellt. You can install XFCE on almost any version of Linux, including Rocky Linux.

It is also one of the most accessible desktop environments to combine with alternate window managers, such as Awesome or i3. This procedure, however, will get you up and running with Rocky Linux and a more typical XFCE installation.

## Voraussetzungen

- Eine Workstation oder Notebook
- A desire to run XFCE as your desktop instead of the default GNOME desktop
- Pour cette procédure, la possibilité d'utiliser `sudo` pour élever les privilèges

\=== "9"

    ````
    ## 9: Introduction
    
    The development team for Rocky Linux 9 has made installing XFCE, and other popular desktop environments, uncomplicated by including live images. For those that might not know what that is, a live image is a bootable image that will load the OS without installation. When loaded, you have the option to install it to your machine's disk drive and use it.
    
    ## 9: Get, verify, and write the XFCE live image
    
    Prior to installation, the first step is to download the live image and write that to a DVD or a USB thumb drive. As stated earlier, the image will be bootable, just like any other installation media for Linux. You can find the latest XFCE image in the download section for Rocky Linux 9 [live images](https://dl.rockylinux.org/pub/rocky/9.6/live/x86_64/). Note that this particular link assumes x86_64 is your processor's architecture. 
    
    As of this writing, you can use x86_64 or aarch64 architectures for this live image. Download the live image and checksum files. 
    
    Verify the image with the CHECKSUM file with the following 
    
    (note this is an example! Ensure your image name and CHECKSUM files match): 
    
    ```
    sha256sum -c CHECKSUM --ignore-missing Rocky-9-XFCE-x86_64-latest.iso.CHECKSUM
    ```
    
    If all goes well, you will see this message:
    
    ```
    Rocky-9-XFCE-x86_64-latest.iso: OK
    ```
    
    If the checksum for the file returns OK, you are now ready to write your ISO image to your media. This procedure differs depending on the OS, the media, and the tools. We are assuming here that you know how to write the image to your media.
    
    ## 9: Booting
    
    This again is different by machine, BIOS, OS, and so on. You will need to ensure that your machine is set to boot to whatever your media is (DVD or USB) as the first boot device. This screen will show if you are successful:
    
    ![xfce_boot](images/xfce_boot.png)
    
    If so, you are on your way! If you want to test the media, you can enter that option first, or you can enter **S** to **Start Rocky Linux XFCE 9.0**.
    
    Remember, this is a live image. It is going to take some time to boot to the first screen. Do not panic, just wait! When the live image boots, you will see this screen:
    
    
    ![xfce_install](images/xfce_install.png)
    
    ## 9: Installing XFCE
    
    At this point, you can use the XFCE environment. When you decide to use it permanently, double-click the option to Install to Hard Drive.
    
    This will start a pretty familiar installation process for those who have installed Rocky Linux before. The first screen will allow the selection your default language:
    
    ![xfce_language](images/xfce_language.png)
    
    The next screen will have some things that you need to verify or change. The options are numbered for reference:
    
    ![xfce_install2](images/xfce_install_2.png)
    
    1. **Keyboard** - Ensure that it matches up to the keyboard layout that you use.
    2. **Time & Date** - Ensure this matches up to your time zone.
    3. **Installation Destination** - You will need to click into this option, even if it is just to accept what is already there.
    4. **Network & Host Name** - Verify that you have what you want here. Provided the network is enabled, you can always change this later if you need to.
    5. **Root Password** - Set a root password. Remember to save this somewhere safe (password manager).
    6. **User Creation** - Create at least one user. If you want the user to have administrative rights, set this option when creating the user.
    7. **Begin Installation** - When completed and verified, click this option.
    
    When you do step 7, the installation process will start installing packages, shown in this screenshot:
    
    ![xfce_install3](images/xfce_install_3.png)
    
    After the installation to the hard drive is complete, you will see the following screen:
    
    ![xfce_install_final](images/xfce_install_final.png)
    
    Click **Finish Installation**.
    
    When you have done this, it will take you back to the live image screen. Reboot your machine and remove the boot media you used for the XFCE install.
    
    Next you will get a login screen with the user you created above. Enter your password, which will get you to the XFCE desktop:
    
    ![xfce_desktop](images/xfce_desktop.png)
    ````

\=== "9-minimal"

    ```
    
    ```

\=== "8"

    ```
    .
    ```

## Conclusion

XFCE is a light environment with a simplistic interface. It is an alternative to the default GNOME desktop on Rocky Linux. Wenn Sie Rocky Linux 9 verwenden, haben die Entwickler ein praktisches Live-Image erstellt, das den Installationsprozess beschleunigt.
