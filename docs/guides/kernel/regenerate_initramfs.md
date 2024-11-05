---
title: Regenerate initramfs
author: Neel Chauhan
contributors:
tested_with: 9.4
tags:
  - hardware
---

# Regenerate initramfs

## Introduction

An `initramfs` is the root filesystem inside a Linux kernel to help boot the system. It contains the core modules needed to boot Linux.

Sometimes, an Linux administrator might want to regenerate the `initramfs`, say if they want to blacklist a driver or include a out-of-band module. For instance, the author did this to [enable Intel vPro on a Minisforum MS-01](https://spaceterran.com/posts/step-by-step-guide-enabling-intel-vpro-on-your-minisforum-ms-01-bios/).

## Requirements

The following are the minimum requirements for using this procedure:

* A Rocky Linux system or virtual machine (not a container)

* Changes to the kernel setup, such as blacklisting or adding a module

## Regenerating the `initramfs`

To regenerate the `initramfs` you should first back up the existing `initramfs`:

```bash
cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-$(date +%m-%d-%H%M%S).img
```

Next, run `dracut` to regenerate the `initramfs`:

```bash
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
```

Subsequently, reboot:

```bash
reboot
```

## Conclusion

The Linux kernel is extremely powerful and modular. It makes sense that some users may want to allow or disallow certain modules, and regenerating the `initramfs` allows for this to happen. So cheers, you regenerated yours!
