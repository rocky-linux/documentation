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

`yum update`

To check the available repository on your system you can use the command:

`yum repolist`

You should see Extra packages for Enterprise Linux 8 and Linux Modular 8.

##Check The Available Environments and Tools in the Group

`yum grouplist`

You should see the Group for XFCE listed.

## Enabling Repositories

We need the unofficial repository for XFCE, to run on Rocky 8.x versions. 

Enable this repository by entering:

`yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm`

For Rocky Linux 7.x versions enable the repository by entering:

`yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm`

As noted from the link above, you also need the Powertools repository and the EPEL. Go ahead and enable those now:

`dnf config-manager --set-enabled powertools` 

`dnf install epel-release`

And answer 'Y' to install the EPEL.


`dnf copr enable stenstorp/lightdm`

Again, you will be presented with a warning message about the repository. Go ahead and answer `Y` to the prompt.

Go ahead and run `yum update` one more time to make sure all of the enabled repositories are read into the system.

## Installing Packages

To install XFCE, run:

`yum groupinstall "xfce"`

## Final Steps

We need to tell the system after booting use only the graphical user interface, so for that set the default target system to the GUI interface:

`systemctl set-default graphical.target`

Then reboot:

`reboot`

You should end up with a login prompt in the XFCE GUI, and when you login, you will have all of the XFCE environment.

## Conclusion

XFCE is a light environment with simple interface for those who dislike eye-candy and bloat. This Tutorial will be updated with images soon, showing screenshots to give a viual example of the installation.
