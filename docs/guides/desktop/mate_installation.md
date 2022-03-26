---
title: MATE Desktop
author: lillolollo
contributors: Steven Spencer
tested with: 8.5
tags:
  - mate
  - desktop
---

# MATE Desktop Environment

The MATE desktop environment was created to fork and continue GNOME2 in the wake of the somewhat negative reception that GNOME3 received when introduced. MATE has a loyal set of followers, who immediately install it on their OS of choice. MATE can be installed on many flavors of Linux, including Rocky Linux.

This procedure is designed to get you up and running with Rocky Linux using MATE.

!!! Warning

    MATE does not come from Rocky Linux repositories. It is not officially supported by Rocky Linux. For most users, this procedure will work as expected, but if you have issues, please note that the Rocky developers and test group will do NO work on any failures!  If you want MATE badly enough, then troubleshoot your issues and fix as needed. If you find something that you feel should be included in this procedure to help others, push a change to the document.

## Prerequisites

* A computer with a screen and everything, preferably with Rocky Linux already installed.

## Install Rocky Linux Minimal

When installing Rocky Linux, we used the following sets of packages:

* Minimal
* Standard

## Enabling Repositories

We need the unofficial repository for MATE. You can find more information on that repository here: [Stenstorp/MATE](https://copr.fedorainfracloud.org/coprs/stenstorp/MATE/)

Enable this repository by entering:

`dnf copr enable stenstorp/MATE`

!!! Warning

    The `copr` build system creates a repository that is known to work for installing `mate` and `lightdm` (below), but is not maintained by the Rocky Linux community. Use at your own risk!

You will get a warning message about the repository, but go ahead and enable it by typing `Y` to allow.

As noted from the link above, you also need the Powertools repository and the EPEL. Go ahead and enable those now:

`sudo dnf config-manager --set-enabled powertools`  

`sudo dnf install epel-release`

And answer 'Y' to install the EPEL.

We also need the Stenstorp Lightdm repository, so lets enable that as well. You can find more on this repository by going to this link: [Stenstorp/Lighdm](https://copr.fedorainfracloud.org/coprs/stenstorp/lightdm/)

To enable that repository, simply type:

`sudo dnf copr enable stenstorp/lightdm`

Again, you will be presented with a warning message about the repository. Go ahead and answer `Y` to the prompt.

Go ahead and run `dnf update` to make sure all of the enabled repositories are read into the system.

## Installing Packages

The next thing we need are a lot of packages. You can install these by simply copying and pasting the following into the command line on your machine:

`sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan abrt-desktop abrt-java-connector adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk brisk-menu`

This will install these needed packages plus all of the dependencies.

Let's go ahead and install lightdm-gtk as well:

`sudo dnf install lightdm-gtk`

## Final Steps

Now that we have everything we need installed, the next thing we need to do is set the minimal install to boot into the Graphical User Interface (GUI). We can do this by entering:

`sudo systemctl set-default graphical.target`

Now just keep your fingers crossed and reboot:

`sudo reboot`

Next, click on your user name on the screen, but before you enter your password and login, click on the gear icon to the left of the "Sign in" option. Select "MATE" from the available desktop choices and then you can enter your password and login. Future logins will remember your selection.

## Conclusion

Some people are not satisfied with the newer GNOME implementations or simply prefer the older MATE GNOME 2 look and feel. For those people, getting MATE installed in Rocky Linux will provide a nice, stable alternative.

!!! attention

    After further testing, the desktop selection does **NOT** stick, even though MATE remains selected. Attempts to login produce a return to the login screen. To login to a MATE session, you must select MATE again, even though it will already show as selected. This is why the warning exists at the top of this procedure. Please use this guide at your own risk. If you discover a workaround that will help other users continue to use MATE with Rocky Linux, please report your workaround.
