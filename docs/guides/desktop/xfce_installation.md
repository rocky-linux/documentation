---
title: XFCE Desktop 
author: Gerard Arthus, Steven Spencer
contributors: Steven Spencer, Antoine Le Morvan, K.Prasad
tested with: 8.5, 8.6, 9.0
tags:
  - xfce
  - desktop
---

# XFCE Desktop Environment

The XFCE desktop environment was created as a fork of the Common Desktop Environment (CDE). XFCE embodies the traditional Unix philosophy of modularity and re-usability. XFCE can be installed on almost any version of Linux, including Rocky Linux.

It is also one of the easiest desktop environments to combine with alternate window managers, such as awesome or i3. This procedure, however is designed to get you up and running with Rocky Linux using a more typical XFCE installation.

## Prerequisites

* A Workstation or Laptop
* A desire to run XFCE as your desktop instead of the default GNOME desktop

=== "9"

    ## 9: Introduction

    The development team for Rocky Linux 9 have made installing XFCE, and other popular desktop environments, easy by including live images. A live image, for those that may not know what that is, is a bootable image that will load the OS without installation. Once loaded, you have the option to install it to your machine's disk drive and use it.

    ## 9: Get, Verify, and Write the XFCE Live Image

    Prior to installation, the first step is to download the live image and write that to a DVD or a USB thumb drive. As stated earlier, the image will be bootable, just like any other installation media for Linux. You can find the latest XFCE image in the download section for Rocky Linux 9 [live images](https://dl.rockylinux.org/pub/rocky/9.2/live/x86_64/). 
    Note that this particular link assumes x86_64 is your processor's architecture. 
	
	As of this writing, you can use either x86_64 or aarch64 architectures for this live image. Download both the live image and checksum files. 

    Now verify the image with the CHECKSUM file using the following 
    (note this is an example! Make sure your image name and CHECKSUM files match): 

    ```
    sha256sum -c CHECKSUM --ignore-missing Rocky-9-XFCE-x86_64-latest.iso.CHECKSUM
    ```

    If all goes well, you should see this message:

    ```
    Rocky-9-XFCE-x86_64-latest.iso: OK
    ```

    If the checksum for the file returns OK, you are now ready to write your ISO image to your media. This procedure is different depending on the OS you are using, the media, and the tools. We are assuming here that you know how to write the image to your media.

    ## 9: Booting

    This again is different by machine, BIOS, OS, etc.  You'll need to make sure that your machine is set to boot to whatever your media is (DVD or USB) as the first boot device. You should be presented with this screen if you are successful:

    ![xfce_boot](images/xfce_boot.png)

    If so, you are on your way! If you want to test the media, you can select that option first, or you can simply type **S** to **Start Rocky Linux XFCE 9.0**.

    Remember, this is a live image, so it's going to take a bit of time to boot to the first screen. Don't panic, just wait! Once the live image is booted up, you should see this screen:

    ![xfce_install](images/xfce_install.png)

    ## 9: Installing XFCE

    At this point, you can use the XFCE environment and see if you like it. Once you've decided that you would like to use it permanently, double-click the option to Install to Hard Drive.

    This will start a pretty familiar installation process for those who have installed Rocky Linux before. The first screen will be to select your default language:

    ![xfce_language](images/xfce_language.png)

    The next screen will have a number of things that you need to either verify or change. The options are numbered for reference:

    ![xfce_install2](images/xfce_install_2.png)

    1. **Keyboard** - Take a look at this option and make sure that it matches up to the keyboard layout that you use.
    2. **Time & Date** - Make sure this matches up to your time zone.
    3. **Installation Destination** - You'll need to click into this option, even if it is just to accept what is already there.
    4. **Network & Host Name** - Verify that you have what you want here. As long as the network is enabled, you can always change this later if you need to.
    5. **Root Password** - Go ahead and set a root password. Remember to save this somewhere safe (password manager), particularly if it isn't something you will be using often.
    6. **User Creation** - Definitely create at least one user. If you want the user to have administrative rights, remember to set this option when creating the user.
    7. **Begin Installation** - Once all of the settings have been set or verified, go ahead and click this option.

    Once you do step 7, the installation process should start installing packages, as in the screenshot below:

    ![xfce_install3](images/xfce_install_3.png)

    After the installation to the hard drive is complete, you'll be faced with the following screen:

    ![xfce_install_final](images/xfce_install_final.png)

    Go ahead and click **Finish Installation**.

    When you've done this, it will take you back to the live image screen. Reboot your machine and remove the boot media you used for the XFCE install.

    Next you will get a login screen with the user you created above. Go ahead and enter your password, which will get you to the XFCE desktop:

    ![xfce_desktop](images/xfce_desktop.png)

=== "8"

    ## 8: Install Rocky Linux Minimal

    !!! note

        Throughout this section, you will either need to be the root user or be able to sudo to elevate your privileges.

    When installing Rocky Linux, we used the following sets of packages:

    * Minimal
    * Standard

    ## 8: Run System Update

    First, run the server update command to let the system rebuild the repository cache, so that it could recognize the packages available in that.

    ```
    dnf update
    ```

    ## 8: Enabling Repositories

    We need the unofficial repository for XFCE in the EPEL repository, to run on Rocky 8.x versions.

    Enable this repository by entering:

    ```
    dnf install epel-release
    ```

    And answer 'Y' to install it.

    You also need the Powertools and lightdm repositories. Go ahead and enable those now:

    ```
    dnf config-manager --set-enabled powertools
    dnf copr enable stenstorp/lightdm
    ```

    !!! Warning

        The `copr` build system creates a repository that is known to work for installing `lightdm`, but is not maintained by the Rocky Linux community. Use at your own risk!

    Again, you will be presented with a warning message about the repository. Go ahead and answer `Y` to the prompt.

    ## 8: Check The Available Environments and Tools in the Group

    Now that the repositories are enabled, run the following commands to check everything.

    First, check your repository listing with:

    ```
    dnf repolist
    ```

    You should get the following back showing all of the enabled repositories:

    ```bash
    appstream                                                        Rocky Linux 8 - AppStream
    baseos                                                           Rocky Linux 8 - BaseOS
    copr:copr.fedorainfracloud.org:stenstorp:lightdm                 Copr repo for lightdm owned by stenstorp
    epel                                                             Extra Packages for Enterprise Linux 8 - x86_64
    epel-modular                                                     Extra Packages for Enterprise Linux Modular 8 - x86_64
    extras                                                           Rocky Linux 8 - Extras
    powertools                                                       Rocky Linux 8 - PowerTools
    ```

    Next run the following command to check for XFCE:

    ```
    dnf grouplist
    ```

    You should see "Xfce" at the bottom of the listing.

    Go ahead and run `dnf update` one more time to make sure all of the enabled repositories are read into the system.

    ## 8: Installing Packages

    To install XFCE, run:

    ```
    dnf groupinstall "xfce"
    ```

    Also install lightdm:

    ```
    dnf install lightdm
    ```

    ## 8: Final Steps

    We need to disable `gdm`, which gets added and enabled during *dnf groupinstall "xfce"*:

    ```
    systemctl disable gdm
    ```

    Now we can enable *lightdm*:

    ```
    systemctl enable lightdm
    ```

    We need to tell the system after booting use only the graphical user interface, so for that set the default target system to the GUI interface:

    ```
    systemctl set-default graphical.target
    ```

    Then reboot:

    ```
    reboot
    ```

    You should end up with a login prompt in the XFCE GUI, and when you login, you will have all of the XFCE environment.

## Conclusion

XFCE is a light environment with simple interface. It is an alternative to the default GNOME desktop on Rocky Linux. If you are running Rocky Linux 9, the developers have created a handy live image that speeds up the installation process.
