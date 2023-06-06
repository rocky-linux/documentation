---
title: 网络配置
---

# 网络配置

## 先决条件

* 对在命令行上的操作有一定的了解
* 拥有或者可以提高到系统管理员权限（例如root账户，使用sudo等）
* 可选：熟悉网络概念

# 介绍

现在，一台没有网络连接的计算机本身几乎毫无用处。 无论您需要在服务器上更新软件包，还是只需要从您的笔记本浏览外部网站 - 您将需要网络访问！

本指南旨在向Rocky Linux用户提供如何在Rocky Linux系统上设置网络连接的基本知识。

## 使用 NetworkManager 服务

在用户级，网络堆栈由 *NetworkManager* 管理。 此工具作为服务运行，您可以通过以下命令检查其状态：

    systemctl status NetworkManager

### 配置文件

NetworkManager 生效的配置在文件 /etc/sysconfig/network-scripts/ifcfg-Iface_NAME中。 每个网络接口都有配置文件。 服务器默认配置如下示例：

    TYPE=Ethernet
    PROXY_METHOD=none
    BROWSER_ONLY=no
    BOOTPROTO=none
    DEFROUTE=yes
    IPV4_FAILURE_FATAL=no
    IPV6INIT=no
    NAME=ens18
    UUID=74c5ccee-c1f4-4f45-883f-fc4f765a8477
    DEVICE=ens18
    ONBOOT=yes
    IPADDR=192.168.0.1
    PREFIX=24
    GATEWAY=192.168.0.254
    DNS1=192.168.0.254
    DNS2=1.1.1.1
    IPV6_DISABLED=yes

接口的名称是 **ens18** ，因此该文件的名称将是 `/etc/sysconfig/network-scripts/ifcfg-ens18`。

**提示：**  
有几种方法或机制，可以通过这些方法或机制分配系统他们的 IP 配置信息。 两种最常见的方法是 - **静态IP配置** 方案和 **动态IP配置** 方案。

静态IP配置方案在服务器类系统或网络中非常常见。

动态的 IP 办法在家庭和办公室网络――或工作站和桌面类系统上很常见。  动态方案通常需要 _个额外的_ 适当的 IP 配置信息。 这个额外的事情就是动态主机配置协议（DHCP）。

家庭/办公室用户往往不必担心或了解DHCP。 这是因为某人或其他人在后台自动处理这个问题。 最终用户需要做的唯一事情是有线或无线上网连接到正确的网络(当然了，要确保他们的系统开机运行)！

#### IP 地址

在上面的 `/etc/sysconfig/network-scripts/ifcfg-ens18` 列出， 我们看到 `BOOTPROTO` 参数值设置为 ` none`。 这意味着正在配置的系统已设置为静态IP地址方案。

如果你想要配置系统使用动态IP地址方案。 您必须将 `BOOTPROTO` 参数的值从 `no` 更改为 `dhcp` 并删除 `IPADRD` `PREFIX` 和 `GATEWAY` 行. 这是必要的，因为所有这些信息都将自动从任何可用的DHCP服务器获取。

要配置静态IP地址属性，请设置以下内容：

* IPADR：分配接口的 IP 地址
* PREFIX：子网掩码在 [CIDR 符号](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)
* GATEWAY: 默认网关

`ONBOOT` 参数设置为 `yes` 表示此连接将在启动时激活。

#### DNS 解析

要获得正确的名称解析，必须设置以下参数：

* DNS1：主域名服务器的 IP 地址
* DNS2：辅助域名服务器IP地址


### 应用配置

要应用网络配置，可以使用 `nmcli` 命令：

    nmcli connection up ens18

要获取连接状态，请使用：

    nmcli connection show

您也可以使用 `ifup` and `ifdown` 命令将接口上下线(他们是围绕 `nmcli` 的简单封装)：

    ifup ens18
    ifdown ens18

### 检查配置...

您可以通过使用以下 `nmcli` 命令来检查网络配置是否正确：

    nmcli device show ens18

您将看到如下的输出：

    GENERAL.DEVICE:                         ens18
    GENERAL.TYPE:                           ethernet
    GENERAL.HWADDR:                         6E:86:C0:4E:15:DB
    GENERAL.MTU:                            1500
    GENERAL.STATE:                          100 (connecté)
    GENERAL.CONNECTION:                     ens18
    GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
    WIRED-PROPERTIES.CARRIER:               marche
    IP4.ADDRESS[1]:                         192.168.0.1/24
    IP4.GATEWAY:                            192.168.0.254
    IP4.ROUTE[1]:                           dst = 192.168.0.0/24, nh = 0.0.0.0, mt = 100
    IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 192.168.0.254, mt = 100
    IP4.DNS[1]:                             192.168.0.254
    IP4.DNS[2]:                             1.1.1.1
    IP6.GATEWAY:                            --

## 使用 IP 工具

`ip` 命令 (由 *iproute2* 软件包提供) 是一个强大的工具来获取信息并配置一个现代的Linux 系统网络，如Rocky Linux。

在这个示例中，我们将假设以下参数：

* 接口名称：ens19
* IP地址：192.168.20.10
* 子网掩码：24
* 网关： 192.168.20.254

### 获取常规信息

要查看所有接口的详细状态，请使用

    ip a

**专家提示：**
* 使用 `-c` 标志获取一个更易读的颜色输出： `ip -c a`。
* `ip` 接受缩写，因此 `ip一个`, `ip addr` 和 `ip address` 一样

### 网络接口启动关闭。

将 *聚合19* 接口启动， 只需使用 `ip link set ens19 up` ；将其关闭，使用 `ip link set ens19 down`。

### 指定接口为静态地址

要使用的命令是形式的：

    ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>

为了示范上述示例参数，我们将使用：

    ip a add 192.168.20.10/24 dev ens19

然后检查结果：

    ip a show dev ens19

将输出：

    3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
        inet 192.168.20.10/24 scope global ens19
        valid_lft forever preferred_lft forever

我们的接口已经启动和配置，但仍然缺少一些东西！

### 使用 ifcfg 工具

若要添加 *ens19* 接口的新示例IP地址，请使用以下命令：

    ifcfg ens19 add 192.168.20.10/24

移除地址：

    ifcfg ens19 del 192.168.20.10/24

要完全禁用此接口上的 IP 地址：

    ifcfg ens19 stop

*请注意，这并不会使接口关闭，它只是从接口中取消所有IP地址的分配。*

### 网关配置

现在接口有地址了，我们必须设置它的默认路由。下面示例这可以做到这点：

    ip route add default via 192.168.20.254 dev ens19

路由表可以用以下命令显示：

    ip route

或使用简写`ip r`。

## 检查网络连通性

至此，您的网络接口应当启动并正确配置。 有几种方法来验证您的连接。

通过 *ping* 另一个IP地址在同一个网络 (我们将使用 `192.168.20.42` 作为示例)：

    ping -c3 192.168.20.42

此命令将发出3 次*ping* (称为ICMP请求)，并等待回复。 如果一切顺利，您应该得到以下输出：

    PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
    64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
    64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
    64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms
    
    --- 192.168.20.42 ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 5ms
    rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms

然后，为了确保您的路由配置正常，试着 *ping* 个外部主机，如这个众所周知的公开的DNS解析器：

    ping -c3 8.8.8.8

如果您的机器有几个网络接口，您想通过一个指定接口发出ICMP请求， 您可以使用 `-I` 标志：

    ping -I ens19  -c3 192.168.20.42

接下来确认DNS解析是否正常。 作为提醒， DNS解析是一种用来将人类友好机器名称转换为的IP地址的机制，反之（反向DNS）。

如果 `/etc/resolv.conf` 文件表明了一个可访问的DNS 服务器，那么以下应该工作:

    host rockylinux.org

输出应该是：

    rockylinux.org has address 76.76.21.21
