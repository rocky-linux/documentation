---
title: View Current Kernel Configuration
author: David Hensley
contributors: Steven Spencer
tested with: 8.5
tags:
  - kernel
  - config
  - modules
  - kmod
---

# View Current Kernel Configuration

The Linux kernel stores running kernel information in two places via special filesystems located in memory:
  - The older [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html) which mounts `/proc` (verify via `mount -l -t proc`)
  - The newer [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html) which mounts `/sys` (verify via `mount -l -t sysfs`)

[Concise summary](https://www.landoflinux.com/linux_procfs_sysfs.html) of them and what info they contain.

Linux distributions store the config used to compile the kernel as an ASCII file in:

```bash
/lib/modules/<kernel-release>/build/.config
```

Configured builtin (statically compiled in) and loadable modules for the currently running kernel are listed by directories named for the modules in:

```bash
/sys/module/
```

See what your currently running "kernel release" version is with:

`uname -r` and substitute its value in commands with `$(uname -r)`

You can examine these files to make sure the currently running kernel was compiled with the functions you need:

  - `cat /lib/modules/$(uname -r)/config | grep -i <keyword>`
  - `ls /sys/module/ | grep -i <keyword>`
  - `sysctl -a | grep -i <keyword>`
  - `lsmod | grep -i <keyword>`
  - `modinfo <module>`

You can check for kernel module dependencies in:

```bash
/lib/modules/<kernel-release>/modules.dep
```
but it is easier to read the output of the "Used-by" field in `lsmod`.

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
isn't set (check this with `lsmod`).

Some distributions, like Gentoo and Arch, use `/proc/config.gz` by default instead:

```bash
zcat /proc/config.gz | grep -i <keyword>
zgrep <keyword> /proc/config.gz
```

For any distribution, if your running kernel has set both

```
CONFIG_IKCONFIG
CONFIG_IKCONFIG_PROC
```
and if

```bash
ls /sys/module/configs
```
exists and is executable (searchable in the case of a dir)
then you can create `/proc/config.gz` with this command:

```bash
modprobe configs
```
## Reference:

[sysctl](https://man7.org/linux/man-pages/man8/sysctl.8.html), [lsmod](https://man7.org/linux/man-pages/man8/lsmod.8.html), [modinfo](https://man7.org/linux/man-pages/man8/modinfo.8.html), [modprobe](https://man7.org/linux/man-pages/man8/modprobe.8.html), [depmod](https://man7.org/linux/man-pages/man8/depmod.8.html), [modules.dep](https://man7.org/linux/man-pages/man5/modules.dep.5.html), [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html), [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html), [uname](https://man7.org/linux/man-pages/man8/uname26.8.html)
