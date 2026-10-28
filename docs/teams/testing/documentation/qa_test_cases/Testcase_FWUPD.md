---
title: QA:Testcase FWUPD
author: Chris Stackpole
contributors: 
tags:
  - testing
revision_date: 2026-10-09
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Description

This is to ensure that SecureBoot and firmware updates function with the lastest packages.

* ❗ - Important. It is best to have this tested, but if it isn't or if it fails then it won't block the release.
* ❌ - Release blocker. This must be tested and until it is, or if it fails, then the issue must be properly addressed.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  9 | ❗       | N/A     | N/A     | N/A   | ❗      |
| Rocky Linux 10 | ❌       | N/A     | N/A     | N/A   | ❌      |

## Setup

1. Install Rocky into a VM or hardware with SecureBoot enabled
2. Install FWUPD:=
   1. On EL9:- `dnf install fwupd`
   2. On EL10:- `dnf install fwupd-efi`

## How to test

1. Reboot into dwupd

2. Follow these commands:=

   ```
   ESP_DEV=$(findmnt -no SOURCE /boot/efi) # i.e. /dev/vda1
   ESP_DISK=/dev/$(lsblk -no PKNAME "$ESP_DEV") # i.e. /dev/vda
   ESP_PART=$(echo "$ESP_DEV" | grep -oE '[0-9]+$') # i.e. 1
   cp /usr/libexec/fwupd/efi/fwupdx64.efi.signed /boot/efi/EFI/rocky/fwupdx64.efi
   # load option for fwupd: basename, leading backslash, UCS-2 LE, NUL-terminated
   printf '\\fwupdx64.efi\0' | iconv -f ASCII -t UTF-16LE > /tmp/opt.bin
   efibootmgr -C -d "$ESP_DISK" -p "$ESP_PART" -L "Linux Firmware Updater" \
              -l '\EFI\rocky\shimx64.efi' -@ /tmp/opt.bin
   efibootmgr -n $(efibootmgr | sed -n 's/^Boot\([0-9A-F]*\)\* Linux Firmware Updater.*$/\1/p')
   systemctl reboot
   ```

Note:- The above commands are for x86_64. To use these on aarch64 change `fwupdx64.efi` to `fwupda64.efi` in all three locations.

## Expected Results

1. The VM should boot into fwupd, wait 10 seconds, then do a normal boot.

   {% include 'teams/testing/qa_testcase_bottom.md' %}
