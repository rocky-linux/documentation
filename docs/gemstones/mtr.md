---
title : mtr - Network Diagnostics
author : tianci li
contributors: Steven Spencer, Neel Chauhan
date : 2021-10-20
---

# `mtr` Introduction

`mtr` is a network diagnostic tool that can diagnose network problems. It is used to replace the `ping` and `traceroute` commands. In terms of performance, the `mtr` command is faster.

## Using `mtr`

```bash
# Install mtr
shell > dnf -y install mtr
```

The common options of the `mtr` command are as follows. Under normal circumstances, no additional options are required, followed by the hostname or IP address directly:

|Options|Description|
|---|---|
|-4 |# Use IPv4 only|
|-6 |# Use IPv6 only|
|-c COUNT |# Number of pings sent|
|-n |# Do not resolve the hostname|
|-z |# Display AS number|
|-b |# Display ip and hostname|
|-w |# Output a wide range of reports|

The information exchanged by the terminal is as follows:

```bash
shell > mtr -c 10 bing.com
 My traceroutr [v0.92]
li(192.168.100.4) 2021-10-20T08:02:05+0800
Keys:Help Display mode Restart Statistics Order of fields quit
HOST: li Loss% Snt Last Avg Best Wrst StDev
 1. _gateway 0.0% 10 2.0 5.6 2.0 12.9 3.6
 2. 10.9.128.1 0.0% 10 13.9 14.8 8.5 20.7 3.9
 3. 120.80.175.109 0.0% 10 15.8 15.0 10.0 20.1 3.1
 4. 112.89.0.57 20.0% 10 18.9 15.2 11.5 18.9 2.9
 5.219.158.8.114 0.0% 10 10.8 14.4 10.6 20.5 3.5
 6. 219.158.24.134 0.0% 10 13.1 14.5 11.9 18.9 2.2
 7. 219.158.10.30 0.0% 10 14.9 21.2 12.0 29.8 6.9
 8. 219.158.33.114 0.0% 10 17.7 17.1 13.0 20.0 2.0
 9. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
10. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
11. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
12. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
13. a-0001.a-msedge.net 0.0% 10 18.4 15.7 9.5 19.3 3.1
...
```

* Loss% - packet loss rate
* Snt - the number of packets sent
* Last - the delay of the last packet
* Avg - average delay
* Best - lowest latency
* Wrst - Worst time delay
* StDev - variance (stability)

## Shortcut keys for interaction

* <kbd>p</kbd> - Pause
* <kbd>d</kbd> - Switch display mode
* <kbd>n</kbd> - Turn on/off DNS
* <kbd>r</kbd> - Reset all counters
* <kbd>j</kbd> - Toggle delay display information
* <kbd>y</kbd> - Switch IP information
* <kbd>q</kbd> - Suit `mtr`
