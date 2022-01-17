# XFCE Desktop Environment

The XFCE desktop environment was created as a fork of the Common Desktop Environment (CDE). Xfce embodies the traditional Unix philosophy of Modularity and Re-usability. XFCE can be installed on almost any version of Linux, including Rocky Linux.

This procedure is designed to get you up and running with Rocky Linux using XFCE.

## Prerequisites

* A Workstation or Server, preferably with Rocky Linux already installed.
* You should be in the Root environment or type `sudo` before all of the commands you enter.

## Install Rocky Linux Minimal

When installing Rocky Linux, we used the following sets of packages:

* Minimal
* Standard

## Run System Update

First, run the server update command to let the system rebuild the repository cache, so that it could recognize the packages available in that.

`dnf update`

## Enabling Repositories

We need the unofficial repository for XFCE in the EPEL, to run on Rocky 8.x versions.

Enable this repository by entering:

`dnf install epel-release`

And answer 'Y' to install the EPEL.

You also need the Powertools and lightdm repositories. Go ahead and enable those now:

`dnf config-manager --set-enabled powertools`

`dnf copr enable stenstorp/lightdm`

!!! Warning

    The `copr` build system creates a repository that is known to work for installing `lightdm`, but is not maintained by the Rocky Linux community. Use at your own risk!

Again, you will be presented with a warning message about the repository. Go ahead and answer `Y` to the prompt.

## Check The Available Environments and Tools in the Group

Now that the repositories are enabled, run the following commands to check everything.

First, check your repository listing with:

`dnf repolist`

You should get the following back showing all of the enabled repositories:

```
appstream                                                        Rocky Linux 8 - AppStream
baseos                                                           Rocky Linux 8 - BaseOS
copr:copr.fedorainfracloud.org:stenstorp:lightdm                 Copr repo for lightdm owned by stenstorp
epel                                                             Extra Packages for Enterprise Linux 8 - x86_64
epel-modular                                                     Extra Packages for Enterprise Linux Modular 8 - x86_64
extras                                                           Rocky Linux 8 - Extras
powertools                                                       Rocky Linux 8 - PowerTools
```

Next run the following command to check for XFCE:

`dnf grouplist`

You should see "Xfce" at the bottom of the listing.

Go ahead and run `dnf update` one more time to make sure all of the enabled repositories are read into the system.

## Installing Packages

To install XFCE, run:

`dnf groupinstall "xfce"`

Also install lightdm:

`dnf install lightdm`

## Final Steps

We need to disable `gdm`, which gets added and enabled during *dnf groupinstall "xfce"*:

`systemctl disable gdm`

Now we can enable *lightdm*:

`systemctl enable lightdm`

We need to tell the system after booting use only the graphical user interface, so for that set the default target system to the GUI interface:

`systemctl set-default graphical.target`

Then reboot:

`reboot`

You should end up with a login prompt in the XFCE GUI, and when you login, you will have all of the XFCE environment.

## Conclusion

XFCE is a light environment with simple interface for those who dislike eye-candy and bloat. This Tutorial will be updated with images soon, showing screenshots to give a visual example of the installation.
