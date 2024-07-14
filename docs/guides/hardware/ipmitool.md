---
title: IPMItool For Out Of Band Management
author: Marlon Mejia
contributors: Marlon Mejia
tested_with: 9.3
tags:
  - hardware
  - board management controller
---

# IPMITOOL

## Introduction

IPMI is an open-standard hardware management for handling Out of Band connections to Board Management Controllers.

IPMI can be used to power off/on, restart or get system specific information such as motherboard, power supply status and sensor status. You will able to view any System Event logs from the system for verifying events such as power removed.

IPMI can be used locally and remotely to query a server Board Management Controller for details or actions against the BMC or System.

## Installing

???+ NOTE

    Please make sure your Board Management Controller supports IPMITOOL.
    IPMITOOL can be used as a client to server connection, but also a local connection.

Let's proceed to install ipmitool with `dnf`:

```bash
dnf install ipmitool -y
```

```bash
Last metadata expiration check: 0:35:52 ago on Tue 09 Jul 2024 07:18:17 PM EDT.
Dependencies resolved.
===============================================================================================================================
 Package                      Architecture               Version                           Repository                     Size
===============================================================================================================================
Installing:
 ipmitool                     x86_64                     1.8.18-27.el9                     appstream                     385 k

Transaction Summary
===============================================================================================================================
Install  1 Package
....
....
Installed:
  ipmitool-1.8.18-27.el9.x86_64                                                                                                
```

??? warning

    If your system does not support ipmitool you might find a message such as
    `Could not open device at /dev/ipmi0 or /dev/ipmi/0 or /dev/ipmidev/0: No such file or directory`
    You are still capable of using the IPMITOOL to query a server's Board Management Controller.


## Using IPMITOOSL

Gather systemboard information

```bash
ipmitool mc info
```

Reboot the management controller [ warn = soft reset] [hard = cold reset ]

```bash
ipmitool mc reset [ warn | cold ]
```

Chassys / System [options] [actions]

```bash title="Gather system status"
ipmitool chassis status
```

```bash title="Reboot the system"
ipmitool chassis power [ cycle | reset ]
```
???+ warning

  `reset` performs a hard reset try to avoid it unless the system is completely bricked or unresponsive.

```bash title="Gather system status"
ipmitool chassis status
```