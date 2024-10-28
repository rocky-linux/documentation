---
title: Network & Resource Monitoring with Glances 
author: Alex Zolotarov
contributors: Alex Zolotarov 
tested_with: 9.0
tags:
  - monitoring
  - network
---

# Introduction

In this guide I'll show you how to setup decent **network/resource monitoring**, with minimum effort.
From my perspective, Glances is like Vim in the world of monitoring tools.

## About glances

Glances is an open-source system cross-platform monitoring tool.
It allows real-time monitoring of various aspects of your system such as CPU, memory, disk, network usage etc.
It also allows monitoring of running processes, logged in users, temperatures, voltages, fan speeds etc.
It also supports container monitoring, it supports different container management systems such as Docker, LXC.
The information is presented in an easy to read dashboard and can also be used for remote monitoring of systems via a web interface or command line interface.
It is easy to install and use and can be customized to show only the information that you are interested in.

## Prerequisite

- A server or container 
- Root privileges
- EPEL repository installed

## Installing Packages 

**First, install the EPEL repository (Extra Packages for Enterprise Linux):**

```bash
dnf install -y epel-release
```

Next, install **Glances**

```bash
dnf install -y glances
```

You can now monitor everything you need. 

Type `glances` to start glances.

## Web interface

You can access glances even with a web browser, all you have to add is pass one flag `-w`

```bash
glances -w
```

Once you send this, you'll see:

```bash
Glances Web User Interface started on http://0.0.0.0:61208/
```

You can access it via IP address, or just reverse proxy it to the domain name. 

## What Glances looks like

By default, you can see all your network interfaces, load average, load graphs, containers, alerts, and processes. 

![glances-dasboard](./images/glances-dashboard.webp)

## Interactive Commands

**The full potential of Glances lies in its shortcuts, as many network metrics are hidden by default.**

The following commands (key pressed) are supported while in Glances:

`ENTER`

Set the process filter

Note

On macOS please use `CTRL-H` to delete filter.

The filter is a regular expression pattern:

*   `gnome`: matches all processes starting with the `gnome` string

*   `.*gnome.*`: matches all processes containing the `gnome` string


`a`

Sort process list automatically

*   If CPU `>70%`, sort processes by CPU usage

*   If MEM `>70%`, sort processes by MEM usage

*   If CPU iowait `>60%`, sort processes by I/O read and write


`A`

Enable/disable the Application Monitoring Process

`b`

Switch between bit/s or Byte/s for network I/O

`B`

View disk I/O counters per second

`c`

Sort processes by CPU usage

`C`

Enable/disable cloud stats

`d`

Show/hide disk I/O stats

`D`

Enable/disable Docker stats

`e`

Enable/disable top extended stats

`E`

Erase the current process filter

`f`

Show/hide file system and folder monitoring stats

`F`

Switch between file system used and free space

`g`

Generate graphs for current history

`G`

Enable/disable GPU stats

`h`

Show/hide the help screen

`i`

Sort processes by I/O rate

`I`

Show/hide IP module

`+`

Increase selected process nice level / Lower the priority (need right) - Only in standalone mode.

`-`

Decrease selected process nice level / Higher the priority (need right) - Only in standalone mode.

`k`

Kill selected process (need right) - Only in standalone mode.

`K`

Show/hide TCP connections

`l`

Show/hide log messages

`m`

Sort processes by MEM usage

`M`

Reset processes summary min/max

`n`

Show/hide network stats

`N`

Show/hide current time

`p`

Sort processes by name

`P`

Enable/Disable ports stats

`q|ESC|CTRL-C`

Quit the current Glances session

`Q`

Show/hide IRQ module

`r`

Reset history

`R`

Show/hide RAID plugin

`s`

Show/hide sensors stats

`S`

Enable/disable spark lines

`t`

Sort process by CPU times (TIME+)

`T`

View network I/O as a combination

`u`

Sort processes by USER

`U`

View cumulative network I/O

`w`

Delete finished warning log messages

`W`

Show/hide Wifi module

`x`

Delete finished warning and critical log messages

`z`

Show/hide processes stats

`0`

Enable/disable Irix/Solaris mode

The task’s CPU usage will be divided by the total number of CPUs

`1`

Switch between global CPU and per-CPU stats

`2`

Enable/disable the left sidebar

`3`

Enable/disable the quick look module

`4`

Enable/disable all but quick look and load module

`5`

Enable/disable the top menu (QuickLook, CPU, MEM, SWAP, and LOAD)

`6`

Enable/disable mean GPU mode

`9`

Switch UI theme between black and white

`/`

Switch between process command line or command name

`F5` or `CTRL-R`

Refresh user interface

`LEFT`

Navigation left through the process sort

`RIGHT`

Navigation right through the process sort

`UP`

Up in the processes list

`DOWN`

Down in the processes list

In the Glances client browser (accessible through the `--browser` command line argument):

`ENTER`

Run the selected server

`UP`

Up in the servers list

`DOWN`

Down in the servers list

`q|ESC`

Quit Glances

## Conclusion

While Glances can't exactly replace tools like Grafana, it is still a great alternative if you don't have time to set up complicated monitoring dashboards. 
You can deploy it in seconds and get the same metrics you get in Grafana with Prometheus. 
The web interface isn't very versatile, like it is in Grafana. If you have the option to use the terminal, you should definitely do so. 
