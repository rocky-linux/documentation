---
title: Installing Rocky Linux 10 on a AOOSTAR WTR PRO
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 10.0
tags:
  - hardware
---

## Introduction

The AOOSTAR WTR PRO is a low-power x86 NAS with four drive bays. It is a faster and cheaper alternative to the HPE ProLiant MicroServer. For instance, the author bought one as their personal NAS.

While the design of the WTR PRO is to run standard Linux distributions, the Rocky Linux installer will not boot out-of-the-box on it. However, you can still install Rocky Linux.

## Prerequisites and assumptions

The following are the minimum requirements for using this procedure:

* A Rocky Linux installer USB

* An AOOSTAR WTR PRO system

## Booting the Rocky Linux installer

First, we will boot from the USB.

If an existing operating system is on the SSD, press `Delete` when turning on the WTR PRO. Navigate to **Save &amp; Exit** and select the USB.

When you boot the USB into the GRUB menu, select **Troubleshooting**:

![GRUB Main Menu](../images/aoostar_1.png)

Subsequently, select **Install Rocky Linux *VERSION* in basic graphics mode**:

![GRUB Troubleshooting Menu](../images/aoostar_2.png)

Rocky Linux should now boot and install as normal.

Note that there is no requirement for special kernel option when installing Rocky Linux.
