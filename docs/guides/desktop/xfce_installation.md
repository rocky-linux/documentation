---
title: XFCE Desktop
author: Gerard Arthus, Steven Spencer, Emre Camalan
contributors: Steven Spencer, Antoine Le Morvan, K.Prasad, Ganna Zhyrnova
tested_with: 8.9, 9.5
tags:
  - xfce
  - desktop
---

# XFCE desktop environment

The XFCE desktop environment, created as a fork of the Common Desktop Environment (CDE), embodies the traditional Unix philosophy of modularity and re-usability. You can install XFCE on almost any version of Linux, including Rocky Linux.

It is also one of the most accessible desktop environments to combine with alternate window managers, such as Awesome or i3. This procedure, however, will get you up and running with Rocky Linux and a more typical XFCE installation.

## Prerequisites

* A workstation or notebook
* A desire to run XFCE as your desktop instead of the default GNOME desktop
* For this procedure, the ability to `sudo` to elevate privileges

## Install Rocky Linux minimal

!!! note

    Throughout this section, you will either need to be the root user or be able to `sudo` to elevate your privileges.

When installing Rocky Linux, we used the following sets of packages:

* Minimal
* Standard

## Run System Update

First, run the server update command. The system will rebuild the repository cache. In this way, the system can recognize the packages available.

```
dnf update
```

## Enabling repositories

You need the unofficial repository for XFCE in the EPEL repository, to run on Rocky 8.x versions.

Enable this repository by entering:

```
dnf install epel-release
```

Answer 'Y' to install it.

You also need the Powertools and lightdm repositories. Enable those now:

```
dnf config-manager --set-enabled powertools
dnf copr enable stenstorp/lightdm
```

!!! Warning

    The `copr` build system creates a repository that is known to work for installing `lightdm`, but is not maintained by the Rocky Linux community. Use at your own risk!

Again, you will be presented with a warning message about the repository. Go ahead and answer `Y` to the prompt.

## Check the available environments and tools in the group

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

Run the following command to check for XFCE:

```
dnf grouplist
```

You should see "Xfce" at the bottom of the listing.

Run `dnf update` one more time to ensure all of the enabled repositories read into the system.

## Installing packages

To install XFCE, run:

```
dnf groupinstall "xfce"
```

Also install lightdm:

```
dnf install lightdm
```

## Final steps

You need to disable `gdm`, which gets added and enabled during *dnf groupinstall "xfce"*:

```
systemctl disable gdm
```

Now you can enable *lightdm*:

```
systemctl enable lightdm
```

You need to tell the system after booting to use only the graphical user interface. Set the default target system to the GUI interface:

```
systemctl set-default graphical.target
```

Then reboot:

```
reboot
```

You should end up with a login prompt in the XFCE GUI, and when you login, you will have all of the XFCE environment.

## Conclusion

XFCE is a light environment with a simplistic interface. It is an alternative to the default GNOME desktop on Rocky Linux.
