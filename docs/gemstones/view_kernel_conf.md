---
title: View Current Kernel Configuration
author: David Hensley
contributors:
tested with: 8.5
tags:
  - config
  - kernel
update: 09-Mar-2022
---

All linux distributions store the config used to compile the kernel as an ASCII file in:
```bash
/lib/modules/<kernel-release>/build/.config
```
You can examine them to make sure that kernel was compiled with the support functions you need. 
For the currently running kernel:
```bash
cat /lib/modules/$(uname -r)/build/.config | grep -i <keyword>
```
RHEL and derivative distributions (Fedora, CentOS Stream, Scientific Linux, RockyLinux, Almalinux, et. al.) 
also store the config used for bootable installed kernels in the `/boot` directory as ASCII files:
```bash
/boot/config-<kernel-release>
```
To check the currently running kernel config for a particular value:
```bash
cat /boot/config-$(uname -r) | grep -i <keyword>
```
Results will show 
  - "=m" if compiled in as a kernel module
  - "=y" if compiled statically into the kernel
  - "is not set" if the setting exists but is not enabled (a boolean)

Some distributions, like Gentoo and Arch, use `/proc/config.gz` by default instead:
```bash
zcat /proc/config.gz | grep -i <keyword>
zgrep <keyword> /proc/config.gz
```
