---
title: QA:Testcase SIG/AltArch Raspberry Pi
author: Chris Stackpole
contributors: 
tags:
  - testing
  - qa
revision_date: 2026-10-09
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Description

This is to ensure that the Raspberry Pi's have been tested on 3 / 3b / 4 / 5.

All items in this category are considered ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 

## Releases, Architectures, and ISO's

| Distro         | Aarch64 | ppc64le | risc-v | s390x | x86_64 |
| -------------- | ------- | ------- | ------ | ----- | ------ |
| Rocky Linux  9 | ⬇️       | N/A     | N/A    | N/A   | N/A    |
| Rocky Linux 10 | ⬇️       | N/A     | N/A    | N/A   | N/A    |

## Setup

1. A RPi
2. A spare microSD card
3. Flash image to microSD card. Method can vary depending on device.

## How to test

### Is there a display output?

Description:- Please verify that any external display outputs work.

### Does the device boot?

Description:- Device should boot to prompt without error.

### Can you log-in?

Description:- User should be able to log in with the following credentials.

User:rocky / password:rockylinux

### Does sudo work?

Description:- `sudo ls` is sufficient for this test.

### Is the README there and correct for this device?

Description:- `cat ~/README` and verify content and that the correct device is listed.

### Does the expand filesystem script work?

Description:-  See README for details for each device. In most cases `sudo rootfs-expand` .

### Can the device connect to a wireless network?

Description:- Verify the wifi works. Generic directions below.

```
sudo nmcli radio wifi = enabled
sudo nmcli dev wifi list
sudo nmcli dev wifi connect network-ssid password "network-password"
```

### Can the device connect to ethernet RJ45 network?

Description:- Not valid for every device. Verify with an ethernet cable that an ip is given when running `ip a`.

### Can the device get package updates?

Description:- Update to latest packages. `sudo dnf clean all && sudo dnf update`

Note: depending on when this test is run, you may have to switch to the testing repos first. See channel for details.

### Do all USB ports work on the device?

Description:- Please check every USB port. Using a keyboard is the quick/easy test.

### Can you upgrade from previous version to latest?

Description:- This requires starting with a fresh install of a previous version then manually updating to the latest. Primary concern is kernel installs and boots after upgrade.

Note:- depending on when this test is run, you may have to switch to the testing repos first. See channel for details.
