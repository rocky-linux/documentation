---
title: nmtui - Network Management Tool
author: tianci li
contributors: Steven Spencer, Neil Hanlon
update: 2021-10-23
---

# Introduction

For novice users who are new to GNU/Linux for the first time, the first thing to consider is how to connect the machine to the Internet after installing the operating system. This article will tell you how to configure the IP address, subnet mask, gateway and DNS. There are several ways for reference. Whether you are a novice or a familiar, I believe you can quickly get started.

##  nmtui

`NetworkManager` is a standard Linux network configuration tool suite, which supports server and desktop environments. Nowadays, most popular distributions support it. This set of network configuration tools is suitable for Rocky Linux 8 and later versions. If you want to configure network information graphically (i.e. the command line `nmtui`), you only need to do this:

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

|NetworkManager TUI||
|---|---|
|Edit a connection||
|Activate a connection||
|Set system hostname||
|Quit||
||\<OK\>|

You can use the <kbd>Tab</kbd> key or the <kbd>↑</kbd><kbd>↓</kbd><kbd>←</kbd><kbd>→</kbd> key to select the specific If you want to change the network information, please select **Edit a connection** and then <kbd>Enter</kbd>. Select a different network card and select **Edit..** to edit.

###  DHCP IPv4

For IPv4, if it is to obtain network information with DHCP, you only need to select *IPv4 CONFIGURATION* **&lt;Automatic&gt;**, and run in your terminal `systemctl restart NetworkManager.service`. This will work in most cases. In rare cases, you need to disable and enable the network card for the change to take effect. For example: `nmcli connection down ens33`, `nmcli connection up ens33`


### Manually fix network information

If you want to manually fix all IPv4 network information, you need to select **&lt;Manual&gt;** after *IPv4 CONFIGURATION* and add it line by line. For example, I like this:

|Item|Value|
|---|---|
|Addresses|192.168.100.4/24|
|Gateway|192.168.100.1|
|DNS servers|8.8.8.8|

Then click \< OK \>, return to the terminal interface step by step, and execute `systemctl restart NetworkManager.service`. Similarly, in rare cases, the network card needs to be switched on and off to take effect.

## Change the way of configuration files

All RHEL <font color="red">7.x</font> or <font color="red">8.x</font> distributions, whether upstream or downstream, are configured in the same way. The configuration file of network information is stored in the **/etc/sysconfig/network-scripts/** directory, and one network card corresponds to one configuration file. The configuration file has many parameters, as shown in the following table. Notice! The parameters must be capitalized.

!!! warning

    In RHEL 9.x distributions, the location of the directory where the NIC configuration file is stored has been changed, i.e., **/etc/NetworkManager/system-connections/**. See [here](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/configuring_and_managing_networking/index) for more information.

```bash
shell > ls /etc/sysconfig/network-scripts/
ifcfg-ens33
```

|Parameter name|Meaning|Example|
|---|---|---|
|DEVICE |System logical device name|DEVICE=ens33 |
|ONBOOT |Whether the network card starts automatically with the system, you can choose yes or no|ONBOOT=yes|
|TYPE|Network card interface type, usually Ethernet|TYPE=Ethernet|
|BOOTPROTO|The way to obtain ip, it can be DHCP dynamic acquisition, or static manual configuration using static|BOOTPROTO=static|
|IPADDR|The ip address of the network card, when BOOTPROTO=static, this parameter will take effect |IPADDR=192.168.100.4|
|HWADDR|Hardware address, ie MAC address|HWADDR=00:0C:29:84:F6:9C|
|NETMASK|Decimal subnet mask|NETMASK=255.255.255.0|
|PREFIX|Subnet mask, represented by numbers|PREFIX=24|
|GATEWAY|Gateway, if there are multiple network cards, this parameter can only appear once |GATEWAY=192.168.100.1|
|PEERDNS|When it is yes, the DNS parameters defined here will modify /etc/resolv.conf; when it is no, /etc/resolv.conf will not be modified. When using DHCP, the default is yes|PEERDNS=yes|
|DNS1|The primary DNS is selected, it takes effect only when PEERDNS=no|DNS1=8.8.8.8|
|DNS2|Alternative DNS, only effective when PEERDNS=no|DNS2=114.114.114.114|
|BROWSER_ONLY|Whether to allow only browsers|BROWSER_ONLY=no|
|USERCTL|Whether ordinary users are allowed to control the network card device, yes means allow, no means not allowed |USERCTL=no|
|UUID|Universal unique identification code, the main function is to identify the hardware, generally speaking, it is not necessary to fill in||
|PROXY_METHOD|Proxy method, generally none, can be left blank||
|IPV4_FAILURE_FATAL|If it is yes, it means that the device will be disabled after ipv4 configuration fails; if it is no, it means it will not be disabled. |IPV4_FAILURE_FATAL=no|
|IPV6INIT|Whether to enable IPV6, yes to enable, no not to enable. When IPV6INIT=yes, the two parameters IPV6ADDR and IPV6_DEFAULTGW can also be enabled. The former represents the IPV6 address and the latter represents the designated gateway |IPV6INIT=yes|
|IPV6_AUTOCONF|Whether to use IPV6 automatic configuration, yes means use; no means do not use |IPV6_AUTOCONF=yes|
|IPV6_DEFROUTE|Whether to give IPV6 the default route|IPV6_DEFROUTE=yes|
|IPV6_FAILURE_FATAL|After IPV6 configuration fails, whether to disable the device|IPV6_FAILURE_FATAL=no|
|IPV6_ADDR_GEN_MODE|Generate IPV6 address model, optional values ​​are stable-privacy and eui64|IPV6_ADDR_GEN_MODE=stable-privacy|

After the configuration file is modified successfully, remember to restart the network card service `systemctl restart NetworkManager.service`.

###  Recommended configuration for IPV4

```bash
TYPE=Ethernet
ONBOOT=yes
DEVICE=ens33
USERCTL=no
IPV4_FAILURE_FATAL=no
BROWSER_ONLY=no
BOOTPROTO=static
PEERDNS=no
IPADDR=192.168.100.4
PREFIX=24
GATEWAY=192.168.100.1
DNS1=8.8.8.8
DNS2=114.114.114.114
```

### Recommended configuration for IPV6

```bash
TYPE=Ethernet
ONBOOT=yes
DEVICE=ens33
USERCTL=no
BROWSER_ONLY=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
```

##  View network information

`ip a` or `nmcli device show`
