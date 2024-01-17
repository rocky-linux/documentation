---
title : nload - Bandwidth Statistics
author : Neel Chauhan
contributors: 
date : 2024-01-16
---

# `nload` Introduction

`nload` is a text console-based network traffic monitor. It shows your server's traffic and bandwidth statistics.

## Using `nload`

```bash
dnf -y install epel-release
dnf -y install nload
```

The common options of the `nload` command are as follows. Under normal circumstances, no additional options are required, followed by the interface to monitor:

|Options|Description|
|---|---|
|-a PERIOD |Length for time window of calculation in seconds (default: 300)|
|-m |Show multiple devices and don't show traffic graph|
|-t INTERVAL |Refresh interval in milliseconds (default: 500)|
|-u UNIT |One-letter unit for bandwidth display (default: k)|
|-U UNIT |One-Letter unit for data transfer display (default: M)|

The units for the latter two options are as follows:

|Unit|Meaning|
|---|---|
|b |bit|
|B |byte|
|k |kilobit|
|K |kilobyte|
|m |megabit|
|M |megabyte|
|g |gigabit|
|G |gigabyte|

A sample output from the author's home server running a [Tor](https://www.torproject.org/) [relay](https://community.torproject.org/relay/types-of-relays/):

```bash
Device bridge0 [172.20.0.3] (1/8):
================================================================================
Incoming:
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########  Curr: 79.13 MBit/s
                                             ########  Avg: 84.99 MBit/s
                                             ########  Min: 79.13 MBit/s
                                             ########  Max: 87.81 MBit/s
                                             ########  Ttl: 1732.95 GByte
Outgoing:
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########  Curr: 81.30 MBit/s
                                             ########  Avg: 88.05 MBit/s
                                             ########  Min: 81.30 MBit/s
                                             ########  Max: 91.36 MBit/s
                                             ########  Ttl: 1790.74 GByte
```

The above lines mean the following:

* Curr - current measured bandwidth use
* Avg - average bandwidth use in period
* Min - minimum measured bandwidth use
* Max - maximum measured bandwidth use
* Ttl - data transferred in `nload` session

##  Shortcut keys for interaction
* <kbd>PgDn</kbd>, <kbd>Down</kbd> - Go down one interface
* <kbd>PgUp</kbd>, <kbd>Up</kbd> - Go up one interface
* <kbd>F2</kbd> - Show the option window
* <kbd>F5</kbd> - Save the options
* <kbd>F6</kbd> - Reload the settings from the config file
* <kbd>q</kbd>, <kbd>Ctrl</kbd>+<kbd>C</kbd> - Quit `nload`
