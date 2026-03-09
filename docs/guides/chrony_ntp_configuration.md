---
title: Configuring chrony for NTP Time Synchronization on Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer
tested with: 8, 9, 10
tags:
- chrony
- ntp
- time
- synchronization
ai_contributors:
- Claude claude-sonnet-4-6
---

# Configuring chrony for NTP Time Synchronization on Rocky Linux

**Knowledge**: :star: :star:
**Reading time**: 20 minutes

## Introduction

This document adheres to the [AI contribution policy found here.](contribute/ai-contribution-policy.md) If you find any errors in the instructions, please let us know.

Accurate time synchronization is fundamental to the operation of modern Linux systems. Services such as Kerberos authentication, TLS certificate validation, distributed databases, log correlation, and cluster schedulers all depend on accurate system clocks. On Rocky Linux, `chrony` is the default NTP implementation and replaces the legacy `ntpd` daemon.

`chrony`^1^ is designed for environments where network connections are intermittent or where systems experience frequent suspension and resumption. Under stable network conditions, `chrony` achieves approximately 35 microseconds accuracy compared to `ntpd`'s 234 microseconds^1^. It also supports hardware timestamping and Network Time Security (NTS), which `ntpd` does not.

This guide covers the essential aspects of configuring `chrony` on Rocky Linux, including selecting NTP sources, diagnosing synchronization problems, enabling hardware timestamping, configuring `chrony` as a local NTP server, and handling air-gapped networks.

## Prerequisites

- A Rocky Linux 10 or 9 system with `root` or `sudo` access
- The `chrony` package installed (installed by default on Rocky Linux)
- Network access to at least one NTP server (for internet-connected systems)

Verify `chrony` is installed:

```bash
rpm -q chrony
```

## The default chrony configuration

Rocky Linux ships with a default `/etc/chrony.conf` that provides a working time synchronization setup out of the box. The following is the default configuration on Rocky Linux 10:

```bash
cat /etc/chrony.conf
```

```text
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
pool 2.rocky.pool.ntp.org iburst

# Use NTP servers from DHCP.
sourcedir /run/chrony-dhcp

# Record the rate at which the system clock gains/losses time.
driftfile /var/lib/chrony/drift

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

# Enable kernel synchronization of the real-time clock (RTC).
rtcsync

# Enable hardware timestamping on all interfaces that support it.
#hwtimestamp *

# Increase the minimum number of selectable sources required to adjust
# the system clock.
#minsources 2

# Allow NTP client access from local network.
#allow 192.168.0.0/16

# Serve time even if not synchronized to a time source.
#local stratum 10

# Require authentication (nts or key option) for all NTP sources.
#authselectmode require

# Specify file containing keys for NTP authentication.
#keyfile /etc/chrony.keys

# Save NTS keys and cookies.
ntsdumpdir /var/lib/chrony

# Specify directory for log files.
logdir /var/log/chrony
```

The key directive here is `pool 2.rocky.pool.ntp.org iburst`, which uses the Rocky Linux NTP pool to obtain time sources.

!!! note

    Rocky Linux 9's default `chrony.conf` is similar but includes `keyfile /etc/chrony.keys` and `leapsectz right/UTC` directives that are not present in Rocky Linux 10's default. Rocky Linux 10 adds `sourcedir`, `ntsdumpdir`, and `authselectmode`. The core NTP configuration (`pool`, `makestep`, `driftfile`, `rtcsync`) is the same across both versions. Cloud providers may also add their own NTP server entries to the default configuration.

## Understanding `pool` and `server` directives

The `pool` and `server` directives^1^ serve different purposes in `chrony.conf`:

### The `server` directive

The `server` directive specifies a single NTP server:

```text
server 10.0.0.1 iburst
server ntp1.example.com iburst
```

Use `server` when pointing to a specific NTP host by IP address or hostname that resolves to a single address.

### The `pool` directive

The `pool` directive specifies a pool of NTP servers where the DNS name resolves to multiple addresses:

```text
pool 2.rocky.pool.ntp.org iburst maxsources 4
```

The `pool` directive repeatedly resolves the DNS name to obtain multiple time sources. The `maxsources` option controls how many sources to use from the pool (default is 4, maximum is 16).

!!! warning

    Do not use the `pool` directive with individual IP addresses. The `pool` directive is designed for DNS names that resolve to multiple addresses. For individual IP addresses, always use the `server` directive.

### The `iburst` option

The `iburst` option causes `chrony` to send a burst of 4 to 8 requests when it first starts communicating with a source, which speeds up the initial synchronization.

## Using enough NTP sources

RFC 8633^2^ Section 3.2 states:

> "Operators who are concerned with maintaining accurate time SHOULD use at least four independent, diverse sources of time."

With fewer than four sources, `chrony` cannot reliably detect a faulty time source (a "falseticker"). The following scenarios illustrate the problem:

- **One source**: `chrony` has no way to verify the source is correct
- **Two sources**: If the sources disagree, `chrony` cannot determine which is correct and logs `Can't synchronise: no majority`
- **Three sources**: `chrony` can tolerate one faulty source, but if a second source becomes temporarily unreachable, it is back to the two-source problem
- **Four or more sources**: `chrony` can identify and exclude faulty sources while maintaining synchronization

### Configuring four sources

For internet-connected systems, use a pool with at least four sources:

```text
pool 2.rocky.pool.ntp.org iburst maxsources 4
```

For enterprise environments with internal NTP servers, specify at least four individual servers:

```text
server ntp1.example.com iburst
server ntp2.example.com iburst
server ntp3.example.com iburst
server ntp4.example.com iburst
```

## Diagnosing "Can't synchronise: no majority" errors

The `Can't synchronise: no majority` message^1^ appears when `chrony` cannot establish consensus among its configured sources.

### Common causes

1. **Too few NTP sources**: With only two sources that disagree on the time, `chrony` cannot determine which source is correct
2. **Source offset disagreement**: Even with the correct number of sources, if too many sources disagree beyond acceptable thresholds, `chrony` cannot establish a majority
3. **Network issues**: Intermittent connectivity to NTP sources reduces the number of reachable sources

### Diagnostic commands

Check the current sources and their status:

```bash
chronyc sources -v
```

```text
  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current best, '+' = combined, '-' = not combined,
| /             'x' = may be in error, '~' = too variable, '?' = unusable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* 172-105-192-74.ip.linode>     2   6    17     8   +189us[ +145us] +/- 1251us
^+ v160-16-113-133.ntp.tky2>     2   6    17     9    -28us[  -71us] +/- 1088us
^- 108.160.132.224.vultruse>     2   6    17     8  -2669ns[  -46us] +/-   28ms
^+ vps-tyo2.orleans.ddnss.de     2   6    17     8   -203us[ -246us] +/- 1213us
```

**Column reference:**

| Column | Meaning |
| ------ | ------- |
| M | Source mode: `^` server, `=` peer, `#` local clock |
| S | Source state: `*` best, `+` combined, `-` selectable, `?` unusable, `x` falseticker, `~` too variable |
| Stratum | Distance from a reference clock (1 = directly attached) |
| Poll | Polling interval as a base-2 logarithm in seconds |
| Reach | Reachability register in octal (377 = last 8 attempts all successful) |
| LastRx | Time since last good sample |
| Last sample | Offset between local clock and source |

Check clock tracking status:

```bash
chronyc tracking
```

```text
Reference ID    : AC69C04A (172-105-192-74.ip.linodeusercontent.com)
Stratum         : 3
Ref time (UTC)  : Mon Mar 09 06:00:25 2026
System time     : 0.000003264 seconds slow of NTP time
Last offset     : -0.000043458 seconds
RMS offset      : 0.000043458 seconds
Frequency       : 6.725 ppm fast
Residual freq   : -19.823 ppm
Skew            : 0.307 ppm
Root delay      : 0.002041159 seconds
Root dispersion : 0.000522824 seconds
Update interval : 2.0 seconds
Leap status     : Normal
```

**Key fields:**

| Field | Meaning |
| ----- | ------- |
| Reference ID | The server `chrony` is currently synchronized to |
| Stratum | The stratum of this system (source stratum + 1) |
| System time | Current offset between the NTP time and the system clock |
| Frequency | Rate at which the system clock drifts if uncorrected (ppm) |
| Root delay | Total network path delay to the stratum-1 source |
| Leap status | `Normal`, `Insert second`, `Delete second`, or `Not synchronised` |

Check source statistics:

```bash
chronyc sourcestats -v
```

This command shows the number of sample points, estimated frequency offset, and standard deviation for each source. It is useful for evaluating the stability and reliability of individual NTP sources over time.

## The `trust` option

The `trust` option^1^ tells `chrony` to assume that the time from a source is always correct. A trusted source can only be rejected as a falseticker if another trusted source disagrees with it.

```text
server ntp1.example.com iburst trust
server ntp2.example.com iburst trust
```

!!! warning

    The `trust` option is a workaround for environments where fewer than four NTP sources are available. It bypasses the normal source selection algorithm. Use it only when adding additional NTP sources is not possible. Always prefer adding more sources over using `trust`.

## Hardware timestamping

Hardware timestamping^1^ uses the network interface controller's own clock to timestamp NTP packets at the physical layer, avoiding processing and queuing delays in the kernel and network driver. This significantly improves timestamp accuracy.

### Requirements

- Linux kernel 3.19 or newer
- A NIC that supports hardware timestamping

Verify NIC support by replacing `eth0` with your interface name:

```bash
ethtool -T eth0
```

The output must include `hardware-raw-clock`, `hardware-transmit`, and `hardware-receive` in the capabilities list. The receive filter must include `all` or `ntp`.

On systems without hardware timestamping support (such as virtual machines), the output shows only software capabilities:

```text
Time stamping parameters for enp1s0:
Capabilities:
    software-transmit
    software-receive
    software-system-clock
PTP Hardware Clock: none
Hardware Transmit Timestamp Modes: none
Hardware Receive Filter Modes: none
```

!!! note

    Hardware timestamping is not available on virtual machines or cloud instances. It requires physical NICs with PTP hardware clock support. For full benefit, both the client and server must have it enabled.

### Enabling hardware timestamping

Add the following to `/etc/chrony.conf`:

```text
hwtimestamp eth0
```

To enable hardware timestamping on all interfaces that support it:

```text
hwtimestamp *
```

After making changes, restart `chrony`:

```bash
sudo systemctl restart chronyd
```

Verify the timestamping mode by checking the NTP data for a source:

```bash
chronyc ntpdata
```

The `TX timestamping` and `RX timestamping` fields indicate the timestamp source. With hardware timestamping enabled, these fields show `Hardware`. Without it, they show `Kernel`:

```text
TX timestamping : Kernel
RX timestamping : Kernel
Total TX        : 3
Total RX        : 3
Total valid RX  : 3
Total good RX   : 3
Total kernel TX : 3
Total kernel RX : 3
```

## NTP in air-gapped and restricted networks

In environments without external NTP access, one or more internal machines can serve as the time reference for the network.

### Configuring a standalone time server

On the designated time server, configure the `local` directive^1^ to serve time based on the system clock even when not synchronized to an external source:

```text
local stratum 10
```

The `stratum` value (1 through 15, default 10) indicates the quality of the time. A higher number means lower confidence. Stratum 10 is the convention for unsynchronized local clocks.

### Orphan mode for redundancy

When multiple servers need to provide time in an isolated network, use the `orphan` option^1^ of the `local` directive:

```text
local stratum 10 orphan
```

In orphan mode, servers with the same local stratum synchronize with each other. The server with the smallest reference ID has its local reference active, and other servers synchronize to it. If that server becomes unavailable, the server with the next smallest reference ID takes over.

!!! tip

    Orphan mode is compatible with `ntpd`'s orphan mode, so `chrony` and `ntpd` servers can coexist in the same orphan group.

### Client configuration for isolated networks

On client machines in the air-gapped network, point to the internal time servers:

```text
server 10.0.0.1 iburst
server 10.0.0.2 iburst
server 10.0.0.3 iburst
server 10.0.0.4 iburst
```

## Configuring chrony as an NTP server

To allow other machines on the network to synchronize time from your server, use the `allow` directive^1^.

### Allowing NTP client access

Edit `/etc/chrony.conf` and add the `allow` directive specifying the subnet:

```text
allow 192.168.1.0/24
```

To allow all IPv4 clients:

```text
allow 0/0
```

To allow a specific IPv6 subnet:

```text
allow 2001:db8::/32
```

### Opening the firewall

NTP uses UDP port 123. Open it with `firewalld`:

```bash
sudo firewall-cmd --permanent --add-service=ntp
sudo firewall-cmd --reload
```

Verify the rule is active:

```bash
sudo firewall-cmd --list-services
```

The output should include `ntp`.

### Restart chrony

After making any configuration changes:

```bash
sudo systemctl restart chronyd
```

Verify the server is listening:

```bash
sudo ss -ulnp | grep chronyd
```

The output should show `chronyd` listening on `0.0.0.0:123`:

```text
UNCONN 0      0            0.0.0.0:123       0.0.0.0:*    users:(("chronyd",pid=1362,fd=7))
```

## Key configuration directives reference

| Directive | Purpose | Example |
| --------- | ------- | ------- |
| `server` | Specify a single NTP server | `server ntp1.example.com iburst` |
| `pool` | Specify an NTP server pool (DNS name) | `pool 2.rocky.pool.ntp.org iburst` |
| `makestep` | Step clock if offset exceeds threshold | `makestep 1.0 3` |
| `driftfile` | File to record clock drift rate | `driftfile /var/lib/chrony/drift` |
| `rtcsync` | Synchronize the hardware RTC | `rtcsync` |
| `allow` | Allow NTP client access from subnet | `allow 192.168.1.0/24` |
| `local` | Serve time when not externally synchronized | `local stratum 10` |
| `hwtimestamp` | Enable hardware timestamping | `hwtimestamp *` |
| `trust` | Assume source time is always correct | Added to `server` line |
| `iburst` | Speed up initial synchronization | Added to `server` or `pool` line |

## Conclusion

Proper `chrony` configuration is essential for reliable time synchronization on Rocky Linux. The most common misconfiguration is using too few NTP sources. Follow RFC 8633^2^ and configure at least four independent sources. Use the `server` directive for individual IP addresses and the `pool` directive for DNS names that resolve to multiple addresses. For diagnostics, `chronyc sources` and `chronyc tracking` provide the information needed to identify and resolve synchronization issues.

For air-gapped networks, the `local` directive with `orphan` mode^1^ provides resilient time distribution without external connectivity. Hardware timestamping^1^ is available for environments that require sub-microsecond accuracy.

The full `chrony` documentation^1^ provides additional options and advanced configurations beyond the scope of this guide.

## References

1. "chrony documentation" by Miroslav Lichvar [https://chrony-project.org/documentation.html](https://chrony-project.org/documentation.html)
2. "Network Time Protocol Best Current Practices (RFC 8633)" by D. Reilly, H. Stenn, and D. Sibold [https://datatracker.ietf.org/doc/html/rfc8633](https://datatracker.ietf.org/doc/html/rfc8633)
3. "chrony.conf(5) man page" by Miroslav Lichvar [https://chrony-project.org/doc/4.6/chrony.conf.html](https://chrony-project.org/doc/4.6/chrony.conf.html)
4. "chronyc(1) man page" by Miroslav Lichvar [https://chrony-project.org/doc/4.6/chronyc.html](https://chrony-project.org/doc/4.6/chronyc.html)
