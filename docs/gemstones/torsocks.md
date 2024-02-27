---
title: torsocks - Route Traffic Via Tor/SOCKS5
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
date: 2024-02-25
---

# `torsocks` Introduction

`torsocks` is a utility to reroute IP traffic from a command-line application over the [Tor](https://www.torproject.org/) network or a SOCKS5 server.

## Using `torsocks`

```bash
dnf -y install epel-release
dnf -y install tor torsocks
systemctl enable --now tor
```

The common options of the `torsocks` command follow and, under normal circumstances, require nothing additional. The options come before the application to run (e.g., `curl`):

|Options|Description|
|---|---|
|--shell |Creates a new shell with LD\_PRELOAD|
|-u USER |Sets the SOCKS5 username|
|-p PASS |Sets the SOCKS5 password|
|-a ADDRESS |Sets the SOCKS5 server address|
|-P PORT |Sets the SOCKS5 server port|
|-i |Enables Tor isolation|

A sample (redacted) output from the IP checker [icanhazip.com](https://icanhazip.com/) via `torsocks`:

![torsocks output](./images/torsocks.png)

Notice that the `torsocks` IP address differs from the direct `curl` IP address.
