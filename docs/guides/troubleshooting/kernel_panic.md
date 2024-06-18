---
title: How to deal with a kernel panic
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - kernel
  - kernel panic
  - rescue
---

## Introduction

Sometimes a kernel installation goes wrong and you have to backtrack.

There can be many reasons for this: insufficient space on the `/boot` partition, an interrupted installation, or some kind of problem with a third-party application.

Fortunately for us, there is always something we can do to save the day.

## Try to reboot with the previous kernel

First thing to try is to reboot with the previous kernel.

* Restart the system.
* Once you have reached the GRUB 2 boot screen, move the selection to the menu entry corresponding to the previous kernel and press the `enter` key.

Once the system has restarted, it can be repaired.

If the system does not boot, try the **rescue mode** (see above).

## Uninstall the broken kernel

The easiest way to do this is to uninstall the kernel version that is not working and then reinstall it.

!!! Note

    You cannot remove a kernel that you are running. 
    
    To show the version of currently running kernel: 
    
    ```bash
    uname -r
    ```

You can check the list of installed kernels:

```bash
dnf list installed kernel\* | sort -V
```

but this command is perhaps more practical, since it only returns packages that have several versions installed:

```bash
dnf repoquery --installed --installonly
```

To remove a specific kernel, you can use `dnf`, specifying the kernel version you retrieved earlier:

```bash
dnf remove kernel-core-<version>
```

Example:

```bash
dnf remove kernel-5.14.0-427.20.1.el9_4.x86_64
```

or use the `dnf repoquery` command:

```bash
dnf remove $(dnf repoquery --installed --installonly --latest=1)
```

You can now  upgrade your system and try reinstalling the latest kernel version.

```bash
dnf update
```

Reboot and see if the new kernel works this time.

## Rescue mode

Rescue mode corresponds to the old single-user mode.

!!! Note

    To enter in rescue mode, you have to provide the root password.

To enter rescue mode, the easiest way is to select the line starting with `0-rescue-*` in the grub menu.

Another way is to edit any line of the grub menu (pressing 'e' key) and add `systemd.unit=rescue.target` at the end of the line that starts with `linux` and then press `ctrl+x` to boot the system into rescue mode.

!!! Note

    You are then in qwerty mode.

Once you are in rescue mode and you have enter the root password, you can then repair your system.

For that, you might need to configure a temporary IP address thanks to `ip ad add ...` (see network chapter of our admin guide).

## Last chance: Anaconda Rescue Mode

If none of the above methods work, it is still possible to boot from the installation ISO and repair the system.

This method is not covered by this documentation.

## System maintenance

### Cleaning old kernel versions

You can remove old installed kernel packages, keeping only latest version and version of running kernel:

```bash
dnf remove --oldinstallonly
```

### Limiting the number of installed kernels versions

We can limit the number of kernel versions by editing the `/etc/yum.conf` file and setting the **installonly_limit** variable:

```text
installonly_limit=3
```

!!! Note

    You should always keep at least the latest kernel version and a backup version.
