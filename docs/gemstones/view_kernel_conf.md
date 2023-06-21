---
title: View Current Kernel Configuration
author: David Hensley
contributors: Steven Spencer
tested_with: 8.5
tags:
  - kernel
  - config
  - modules
  - kmod
---

# View Current Kernel Configuration

The Linux kernel stores running kernel information in two places via special filesystems: ([A summary of them](https://www.landoflinux.com/linux_procfs_sysfs.html))

  - The older [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html) which mounts `/proc` (verify via `mount -l -t proc`)
  - The newer [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html) which mounts `/sys`    (verify via `mount -l -t sysfs`)

!!! warning

    Be cautious if examining the files mentioned here, altering them can change the behavior of the actual running kernel!


These two interfaces allow you to view and change the parameters of the currently running kernel.

Note that if you do an [`ls -l`](https://man7.org/linux/man-pages/man1/ls.1.html) on some of these files, they will show as "0" length, but if you [`cat`](https://man7.org/linux/man-pages/man1/cat.1.html) them out they actually contain data; most of them are ASCII and editable, however some are binary, and in either case commands like [`file`](https://man7.org/linux/man-pages/man1/file.1.html) or [`stat`](https://man7.org/linux/man-pages/man2/lstat.2.html) will typically just return "empty file" or "0" for lengths, although they will show you other information.

The preferred and standard programs for interacting with these functions are [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html), [`modinfo`](https://man7.org/linux/man-pages/man8/modinfo.8.html), and [`sysctl`](https://man7.org/linux/man-pages/man8/sysctl.8.html), among others.

```bash
sysctl -a | grep -i <keyword>
```

```bash
lsmod | grep -i <keyword>
```

```bash
modinfo <module>
```

See what your currently running "kernel release" version is with:

`uname -r` and substitute its return value in commands by using `$(uname -r)`

RHEL and derivative distributions (Fedora, CentOS Stream, Scientific Linux, RockyLinux, Almalinux, et. al.)
also store the config used for bootable installed kernels in the `/boot` directory used by Grub2 as ASCII files:

```bash
/boot/config-<kernel-release>
```

To check the currently running kernel config for a particular value:

```bash
cat /boot/config-$(uname -r) | grep -i <keyword>
```

Results will show:

  - "=m" if compiled in as a kernel module
  - "=y" if compiled statically into the kernel
  - "is not set" if that setting was commented out
  - a numeric value
  - a quoted string value

Some distributions, like Gentoo and Arch, use the `configs` kernel module to provide `/proc/config.gz` by default instead:

```bash
zcat /proc/config.gz | grep -i <keyword>
zgrep <keyword> /proc/config.gz
```

For any distribution, if your running kernel has set both `CONFIG_IKCONFIG` and `CONFIG_IKCONFIG_PROC` and if

```bash
ls -lh /sys/module/configs
```

exists and is executable (searchable in the case of a dir) then you can create `/proc/config.gz` with this command if it is not present:

```bash
modprobe configs
```

!!! note "Enabled Repos"

    This document does not currently cover kernel packages that might have come from non-default repos such as:

    appstream-debug, appstream-source, baseos-debug, baseos-source, or devel


The `kernel-devel` packages install the config file used to compile each installed standard kernel package as an ASCII file in the following location:

```bash
/usr/src/kernels/<kernel-release>/.config
```

This file is more commonly accessed by a symlinked path provided by the `kernel-core` packages:

```bash
/lib/modules/<kernel-release>/build/ -> /usr/src/kernels/<kernel-release>/
```

If you have `kernel-debug-devel` packages installed you will also have this directory:

```bash
 /usr/src/kernels/<kernel-release>+debug/
```

You can look in any of the following for details on the config values used to build an installed kernel:

```bash
/lib/modules/<kernel-release>/config
/lib/modules/<kernel-release>/build/.config
/usr/src/kernels/<kernel-release>/.config
/usr/src/kernels/<kernel-release>+debug/.config
```

Configured modules for the currently running kernel, whether compiled as builtin (i.e. statically into the kernel itself) or a loadable module, are listed by sub directories named as the module name in:

```bash
/sys/module/
```

For each installed kernel-release you can examine these files to see what values were compiled into that kernel, and what version of [GCC](https://man7.org/linux/man-pages/man1/gcc.1.html) was used to compile it:

```bash
cat /lib/modules/$(uname -r)/config | grep -i <keyword>
```

```bash
cat /lib/modules/$(uname -r)/build/.config | grep -i <keyword>
```

```bash
cat /usr/src/kernels/$(uname -r)/.config | grep -i <keyword>
```

```bash
cat /usr/src/kernels/$(uname -r)+debug/.config | grep -i <keyword>
```

```bash
ls -lh /sys/module/ | grep -i <keyword>
```

You can check for kernel module dependencies in the file:

```bash
/lib/modules/<kernel-release>/modules.dep
```

but it is easier to read or parse the output of the "Used-by" field in [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html).

## Reference:

[depmod](https://man7.org/linux/man-pages/man8/depmod.8.html), [ls](https://man7.org/linux/man-pages/man1/ls.1.html), [lsmod](https://man7.org/linux/man-pages/man8/lsmod.8.html), [modinfo](https://man7.org/linux/man-pages/man8/modinfo.8.html), [modprobe](https://man7.org/linux/man-pages/man8/modprobe.8.html), [modules.dep](https://man7.org/linux/man-pages/man5/modules.dep.5.html), [namespaces](https://man7.org/linux/man-pages/man7/namespaces.7.html), [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html), [sysctl](https://man7.org/linux/man-pages/man8/sysctl.8.html), [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html), [uname](https://man7.org/linux/man-pages/man8/uname26.8.html)
