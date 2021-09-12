---
title: Package Debranding
---

# Rocky package debranding How-To

This explains how to debrand a package for the Rocky Linux distribution.


General Instructions

First, identify the files in the package that need to be changed. They could be text files, image files, or others. You can identify the file(s) by digging into git.centos.org/rpms/PACKAGE/

Develop replacements for these files, but with Rocky branding placed instead. Diff/patch files may be needed as well for certain types of text, depends on the content being replaced.

Replacement files go under https://git.rockylinux.org/patch/PACKAGE/ROCKY/_supporting/
Config file (specifying how to apply the patches) goes in https://git.rockylinux.org/patch/PACKAGE/ROCKY/CFG/*.cfg

Note: Use spaces, not tabs.
When srpmproc goes to import the package to Rocky, it will see the work done in https://git.rockylinux.org/patch/PACKAGE , and apply the stored debranding patches by reading the config file(s) under ROCKY/CFG/*.cfg


from https://wiki.rockylinux.org/en/team/development/debranding/how-to
