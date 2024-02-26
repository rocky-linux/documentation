---
title: torsocks - Route Traffic Via Tor/SOCKS5
author: Neel Chauhan
contributors:
date: 2024-02-25
---

# `torsocks` Introduction

`torsocks` is a utility to reroute IP traffic from a command-line application over the [Tor](https://www.torproject.org/) network or alternatively a SOCKS5 server.

## Using `torsocks`

```bash
dnf -y install epel-release
dnf -y install tor torsocks
systemctl enable --now tor
```

The common options of the `torsocks` command follow, and under normal circumstances, require nothing additional. The options come before the application to run (e.g., `curl`):

|Options|Description|
|---|---|
|--shell |Create a new shell with LD\_PRELOAD`|
|-u USER |Set the SOCKS5 username|
|-p PASS |Set the SOCKS5 password|
|-a ADDRESS |Set the SOCKS5 server address|
|-P PORT |Set the SOCKS5 server port|
|-i |Enable Tor isolation)

A sample (redacted) output from the IP checker [icanhazip.com](https://icanhazip.com/) via `torsocks`:

![torsocks output](./images/torsocks.png)

Notice that the `torsocks` IP address is different from the direct `curl` IP address.
