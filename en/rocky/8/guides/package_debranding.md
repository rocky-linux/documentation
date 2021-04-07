Intro to Debranding with Rocky Linux
What is Debranding?
Certain packages in the upstream RHEL/CentOS have logos, trademarks, and other specific text, images, or multimedia that other entities (like the Rocky Linux Foundation) are not allowed to redistribute.

A visible, simple example is the Apache web server (package httpd). If you’ve ever installed it and visited the default web server page, you will see a test page specific to your Linux distro, complete with a “powered by” logo and distro-specific information. While we are allowed to compile and redistribute the Apache web server software, Rocky Linux is NOT allowed to include these trademarked images or distro-specific text!

We must have an automated process that will strip these assets out and replace them with our own branding upon import into our Gitlab.


How Rocky Debranding Works
Rocky’s method for importing packages from the upstream is a tool called srpmproc ( https://git.rockylinux.org/release-engineering/public/srpmproc )

Srpmproc’s purpose in life is to:

Clone PACKAGE from our upstream source: git.centos.org/rpms/PACKAGE
Check if Rocky Linux has any debranding patches available for PACKAGE (under https://git.rockylinux.org/patch/PACKAGE )
If patch/PACKAGE exists, then read the configuration and patches from that repository and apply them
Commit the results (patched or not) to https://git.rockylinux.org/rpms/PACKAGE
Do this for every package until we have a full repository of packages in our Git

How Many Packages are we Talking About?
That is an open question. We know, at a minimum, there are 40 packages referred to in the CentOS 8 release notes that need to be modified from upstream. (34 modified, 6 added. See: https://wiki.centos.org/Manuals/ReleaseNotes/CentOS8.1905#Packages_modified_by_CentOS )

However, we also know this list is incomplete. For example, package nginx (a popular web server) has not been rebranded by CentOS, but should be. We cannot include this package as-is, it must be debranded before it’s imported to Rocky Linux’s Git.


Open Call for Help:
Like nginx, there are undoubtedly more packages that are not on the default CentOS list, but must be debranded. We are trying to build a complete list, but we need YOUR help!

The Rocky Linux community includes a metric ton of CentOS/RHEL administrators who collectively are familiar with the ENTIRE package base. If you notice a package that has upstream branding, but is not on our tracking list, PLEASE let us know! We prefer you drop by channel #Dev/Packaging on chat.rockylinux.org , but any way you can get the message to us is acceptable!


Helping with Debrands
There are 2 tasks involved with debranding. Identifying packages that require debranding (see call for help above), and developing patches+configs to debrand the necessary packages.

If you want to help with the latter, please see “Rocky Debrand How-To” located in the same folder of this Wiki.


Debrand Packages Tracking
A list of packages that need debranding and their status is located in the Wiki in this folder under: Debranding/Debrand_Tracking. It will be updated as debrand patches are submitted and the needed packages are identified.

