---
title: iftop - Live Per-Connection Bandwidth Statistics
author: Neel Chauhan
contributors:
date: 2024-02-24
---

# `iftop` Introduction

`iftop` is a text console-based network traffic monitor. It shows your server's per-connection traffic and bandwidth statistics.

## Using `iftop`

```bash
dnf -y install epel-release
dnf -y install iftop
```

The options of the `iftop` command follow.

|Options|Description|
|---|---|
|-n |Avoids hostname lookups|
|-N |Avoids resolving port numbers to service names|
|-p |Runs in promiscuous mode, so all traffic is counted|
|-P |Displays the port numbers for connections|
|-l |Displays and counts traffic to or from link-local IPv6 addresses|
|-b |Doesn't display bar graphs for traffic|
|-m LIMIT |Sets an upper limit for the bandwidth graph, specified as a number and a unit suffix|
|-u UNIT |Displays traffic rates with the given unit|
|-B UNIT |Synonym for -u|
|-i INTERFACE |Interface to measure|
|-f FILTER CODE |Uses the following filter code|
|-F NET/MASK |Only measures traffic going to the specified IPv4 network|
|-G NET/MASK |Only measures traffic going to the specified IPv6 network|
|-c config |Uses the following configuration file|
|-t |Uses non-ncurses mode|

The units for the **-M** flag are as follows:

|Unit|Meaning|
|---|---|
|K |Kilo|
|M |Mega|
|G |Giga|

The units for the **-u** flag are as follows:

|Unit|Meaning|
|---|---|
|bit |bits per second|
|bytes |bytes per second|
|packets |packets per second|

A sample output from the author's home server running a [Tor](https://www.torproject.org/) [relay](https://community.torproject.org/relay/types-of-relays/):

```bash
 Listening on bridge b          25.0Kb          37.5Kb          50.0Kb    62.5Kb
└───────────────┴───────────────┴───────────────┴───────────────┴───────────────
tt.neelc.org               => X.X.X.X                    13.5Mb  13.5Mb  13.5Mb
                           <=                             749Kb   749Kb   749Kb
tt.neelc.org               => X.X.X.X                    6.21Mb  6.21Mb  6.21Mb
                           <=                             317Kb   317Kb   317Kb
tt.neelc.org               => X.X.X.X                    3.61Mb  3.61Mb  3.61Mb
                           <=                             194Kb   194Kb   194Kb
tt.neelc.org               => X.X.X.X                     181Kb   181Kb   181Kb
                           <=                            3.36Mb  3.36Mb  3.36Mb
tt.neelc.org               => X.X.X.X                     151Kb   151Kb   151Kb
                           <=                            3.24Mb  3.24Mb  3.24Mb
tt.neelc.org               => X.X.X.X                    2.97Mb  2.97Mb  2.97Mb
                           <=                             205Kb   205Kb   205Kb
tt.neelc.org               => X.X.X.X                     156Kb   156Kb   156Kb
                           <=                            2.97Mb  2.97Mb  2.97Mb
tt.neelc.org               => X.X.X.X                    2.80Mb  2.80Mb  2.80Mb
                           <=                             145Kb   145Kb   145Kb
tt.neelc.org               => X.X.X.X                     136Kb   136Kb   136Kb
                           <=                            2.45Mb  2.45Mb  2.45Mb
────────────────────────────────────────────────────────────────────────────────
TX:             cum:   30.1MB   peak:	 121Mb  rates:    121Mb   121Mb   121Mb
RX:                    30.4MB            122Mb            122Mb   122Mb   122Mb
TOTAL:                 60.5MB            242Mb            242Mb   242Mb   242Mb
```

Breaking the bottom pane's lines:

* TX - Transmit/upload data usage
* RX - Receive/download data usage
* TOTAL - Combined upload/download usage

## Shortcut keys for interaction

* ++s++ - aggregates all traffic for each source
* ++d++ - aggregates all traffic for each destination
* ++shift+s++ - toggles display of the source port
* ++shift+d++ - toggles display of destination port
* ++t++ - toggles between display modes: default two-line display with send and receive traffic and three-line display of send, receive, and total traffic
* ++1++, ++2++, ++3++ - sort by 1st, 2nd, or 3rd column
* ++l++ - enters a POSIX regular expression to filter hostnames
* ++shift+p++ - pauses current display
* ++o++ - freezes total bandwidth counts
* ++j++ - scrolls down
* ++k++ - scrolls up
* ++f++ - edits the filter code
