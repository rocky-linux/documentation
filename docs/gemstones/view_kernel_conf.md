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
You can see what your current kernel release is with:
```bash
uname -r
```
All linux distributions store the config used to compile the kernel as an ASCII file in:
```bash
/lib/modules/<kernel-release>/build/.config
```
and a list of various kernel objects, including builtin and loadable modules in:
```bash
/sys/module/
```
You can examine them to make sure the currently running kernel was compiled with the functions you need:
```bash
cat /lib/modules/$(uname -r)/build/.config | grep -i <keyword>
```
or
```bash
ls /sys/module/ | grep -i <keyword>
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
If your search yields no results then the element you are looking for may depend on another config element which
isn't set.

Some distributions, like Gentoo and Arch, use `/proc/config.gz` by default instead:
```bash
zcat /proc/config.gz | grep -i <keyword>
zgrep <keyword> /proc/config.gz
```

For any distribution, if your running kernel has both
```
CONFIG_IKCONFIG
CONFIG_IKCONFIG_PROC
```
set in its config, and if
```bash
ls /sys/module/configs
```
exists and is executable (searchable in the case of a dir)
then you can create `/proc/config.gz` with this command:
```bash
modprobe configs
```
