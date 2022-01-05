---
title: htop-Process Management
author: tianci li
contributors: Steven Spencer
date : 2021-10-16
---

#  install `htop` 
Every system administrator likes to use some of the more commonly used commands. Today I recommend `htop` as an alternative to the `top` command. To use the `htop` command normally , you need to install it first.

``` bash
# Installation epel source (also called repository)
dnf -y install epel-release
# Generate cache
dnf makecache
# Install htop
dnf -y install htop
```

#  Use `htop`
You only need to type `htop` in the terminal, and the interactive interface is as follows:

```
0[ |||                      3%]     Tasks: 24, 14thr; 1 running
1[ |                        1%]     Load average: 0.00 0.00 0.05
Mem[ |||||||           197M/8G]     Uptime: 00:31:39
Swap[                  0K/500M]
PID   USER   PRI   NI   VIRT   RES   SHR   S   CPU%   MEM%   TIME+   Commad(merged)
...
```

<kbd>F1</kbd>Help   <kbd>F2</kbd>Setup  <kbd>F3</kbd>Search <kbd>F4</kbd>Filter <kbd>F5</kbd>Tree   <kbd>F6</kbd>SortBy <kbd>F7</kbd>Nice   <kbd>F8</kbd>Nice+  <kbd>F9</kbd>Kill   <kbd>F10</kbd>Quit

##  Top Description

* The top 0 and 1 indicate the number of your CPU cores, and the percentage indicates the occupancy rate of a single core (of course, the total occupancy rate of the CPU can also be displayed)
    * The different colors of the progress bar indicate the percentage of different process types:

        | Color | Description |
        | ---------| ------------|
        | Blue | Percentage of CPU used by low-priority processes |
        | Green | Percentage of process CPU owned by ordinary users |
        | Red | Percentage of CPU used by system processes |
        | Orange | Percentage of CPU used by IRQ time |
        | Magenta  | Percentage of CPU used by soft IRQ time |
        | Gray | Percentage of CPU occupied by IO waiting time |
        | Cyan | Percentage of CPU consumed by Steal time |

* Tasks: 24, 14thr; 1 running, process information. In my example, it means that my current machine has 24 tasks, which are divided into 14 threads, of which only 1 process is in a running state.
* Mem memory and swap information. Similarly, use different colors to distinguish:

 | Color|Description|
 |----|----|
 |Blue|Percentage of memory consumed by the buffer |
 |Green|Percentage of memory consumed by the memory area|
 |Orange|Percentage of memory consumed by the cache area|

* Load average, the three values ​​respectively represent the average load of the system in the last 1 minute, the last 5 minutes, and the last 15 minutes
* Uptime, which means the running time after booting

##  Process information description

* **PID-Process ID number**

* USER-the owner of the process
* PRI-Display the process priority as seen by the Linux kernel
* NI-displays the process priority of reset by normal user or root super user
* VIRI-virtual memory being consumed by a process

* **RES-physical memory being consumed by a process**

* SHR-shared memory being consumed by a process
* S-The current state of the process, there is a special state to pay attention to! That is Z (zombie process). When there are a large number of zombie processes in the machine, it will affect the performance of the machine.

* **CPU%-Percentage of CPU consumed by each process**

* MEM%-Percentage of memory consumed by each process
* TIME+-shows the running time since the process was started
* Commad-the command corresponding to the process

##  Shortcut key description
In the interactive interface, press the <kbd>F1</kbd> button to see the corresponding shortcut key description.

* The up, down, left, and right direction keys can scroll through the interactive interface, and <kbd>space</kbd> can mark the corresponding process, which is marked in yellow.
* The <kbd>N</kbd> button, the <kbd>P</kbd> button, the <kbd>M</kbd> button and the <kbd>T</kbd> button are respectively PID, CPU%, MEM%, TIME+ is used for sorting. Of course, you can also use the mouse to click to sort in ascending or descending order of a certain field.

##  Other commonly used
To manage the process, use the <kbd>F9</kbd> button to send different signals to the process. The list of signals can be found in `kill -l`. The more commonly used ones are:

| Signal | Description |
|---|---|
|1 | Let the process shut down immediately, and then restart after re-reading the configuration file |
|9 | Used to immediately end the running of the program, used to forcibly terminate the process, similar to the forced end in the windows taskbar |
|15 | The default signal for the kill command. Sometimes if a problem has occurred in the process and the process cannot be terminated normally with this signal, we will try signal 9 |

##  End
`htop` is much easier to use than the `top` that comes with the system, it is more intuitive, and it improves daily use greatly. This is why usually the first thing after installing the operating system the author installs it.
