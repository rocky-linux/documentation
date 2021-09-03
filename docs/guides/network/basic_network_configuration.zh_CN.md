# Rocky Linux —— 网络配置

## 准备工作

* 熟悉命令行操作
* 提升或管理系统权限（例如root、sudo等）
* 可选：熟悉网络概念

# 简介

如今，一台没有网络连接的计算机几乎毫无用处。无论您是需要更新服务器上的软件包，还是只需从笔记本电脑浏览外部网站，您都需要网络访问！

本文旨在为 RockyLinux 用户提供如何在 Rocky Linux 系统上设置网络连接的基本知识。

## 使用 NetworkManager 服务

在用户级别，网络堆栈由 *NetworkManager* 管理。该工具作为服务运行，您可以使用以下命令检查其状态：

	systemctl status NetworkManager

### 配置文件

NetworkManager 只应用从 `/etc/sysconfig/network-scripts/ifcfg-<IFACE_NAME>` 文件中读取的配置。
每个网络接口都有其配置文件。服务器的默认配置文件如下所示：

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

接口的名称是 **ens18**，因此该文件的名称将是 `/etc/sysconfig/network-scripts/ifcfg-ens18`。

**提示：**
有多种方法或机制可以为系统分配其 IP 配置信息。最常用的两种方法是**静态 IP 配置**方案和**动态 IP 配置**方案。

静态 IP 配置方案在服务器类系统或网络上非常常用。

动态 IP 方法在家庭和办公网络或工作站和台式机类系统上很常用。动态方案通常需要本地可用的额外协议，以便为请求的工作站和台式机提供适当的 IP 配置信息。这种协议就是所谓的动态主机配置协议（DHCP）。

通常，家庭/办公室用户不必担心或不了解 DHCP。这是因为有人或其他程序会在后台自动进行处理。最终用户唯一需要做的就是通过物理或无线连接到正确的网络（确保系统已通电）！

#### IP 地址

在前面的 `/etc/sysconfig/network-scripts/ifcfg-ens18` 文件中，`BOOTPROTO` 参数或键的值设置为 `none`。 这意味着将系统设置为静态 IP 地址方案。

相反，如果要将系统配置为使用动态 IP 地址方案，则必须将 `BOOTPROTO` 参数的值从 `none` 更改为 `dhcp`，并删除 `IPADDR`、 `PREFIX` 和 `GATEWAY` 行。这是必需的，因为所有这些信息都将从任何可用的 DHCP 服务器中自动获得。

要配置静态 IP 地址属性，请设置以下内容：

* IPADDR：分配给接口的 IP 地址
* PREFIX：[CIDR 表示法](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)中的子网掩码
* GATEWAY：默认网关

`ONBOOT` 参数设置为 `yes`，表示此连接将在系统引导时被激活。

#### DNS 解析

为了获得正确的名称解析，必须设置以下参数：

* DNS1：主名称服务器的 IP 地址
* DNS2：辅助名称服务器 IP 地址


### 应用配置

要应用网络配置，可以使用 `nmcli` 命令：

    nmcli connection up ens18

要获取连接状态，只需使用：

    nmcli connection show

您还可以使用 `ifup` 和 `ifdown` 命令对该接口进行开启和关闭操作（它们对 `nmcli` 进行简单包装）：

	ifup ens18
	ifdown ens18

### 检查配置

您可以使用以下 `nmcli` 命令检查配置是否已正确应用：

	nmcli device show ens18

其输出如下所示：

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

## 使用 ip 命令

`ip` 命令（由 *iproute2* 软件包提供）是一个功能强大的工具，可用于获取网络信息并配置现代 Linux 系统（如 Rocky Linux）的网络。

在下面示例中，假定以下参数：

* 接口名称：ens19
* IP 地址：192.168.20.10
* 子网掩码：24
* 网关：192.168.20.254

### 获取常用信息

要查看所有接口的详细状态，请使用以下命令：

	ip a 

**实用提示**
* 使用 `-c` 标志可获得更具可读性的彩色输出：`ip -c a`。
* `ip`接受缩写，因此 `ip a`、`ip addr` 和 `ip address` 是等效的。

### 开启或关闭接口

要开启 *ens19* 接口，只需使用 `ip link set ens19 up`，而要关闭接口，使用 `ip link set ens19 down`。

### 为接口分配静态地址

使用的命令的格式为：

	ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>

要分配上述示例参数，使用以下命令：

	ip a add 192.168.20.10/24 dev ens19

然后，检查结果：

	ip a show dev ens19

将输出以下内容：

	3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
		link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
		inet 192.168.20.10/24 scope global ens19
		valid_lft forever preferred_lft forever

接口已启动并配置完毕，但仍然缺少一些配置！

### 使用 ifcfg 命令

要给 *ens19* 接口添加新示例 IP 地址，请使用以下命令：

	ifcfg ens19 add 192.168.20.10/24

删除 ip 地址，请使用以下命令：

	ifcfg ens19 del 192.168.20.10/24

要完全禁用此接口上的 IP 地址，请使用以下命令：

	ifcfg ens19 stop

*注意，它不会导致接口关闭，它只是从接口取消分配的所有 IP 地址。*

### 网关配置

现在接口已有一个地址，接下来必须设置它的默认路由，这可以通过以下方式完成：

	ip route add default via 192.168.20.254 dev ens19

使用以下命令显示内核路由表：

	ip route

以上可简写为 `ip r`。

## 检查网络连接

此时，您应该已启动并正确配置了网络接口。有几种方法可以验证您的连接。

通过 *pinging* 同一网络中的另一个 IP 地址（此处使用 `192.168.20.42` 作为示例）：

	ping -c3 192.168.20.42

此命令将发出 3 个 *ping*（称为 ICMP 请求）并等待回复。如果一切正常，您应该会得到以下输出：

	PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
	64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
	64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
	64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms

	--- 192.168.20.42 ping statistics ---
	3 packets transmitted, 3 received, 0% packet loss, time 5ms
	rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms

然后，为确保您的路由配置正确，请尝试 *ping* 外部主机，例如众所周知的公共 DNS 解析器：

	ping -c3 8.8.8.8

如果您计算机有多个网络接口，且您希望通过特定接口发出 ICMP 请求，则可以使用 `-I` 标志：

	ping -I ens19  -c3 192.168.20.42

接下来确保 DNS 解析正常工作。提醒一下，DNS 解析是一种用于将人性化的计算机名称转换为 IP 地址的机制，反之称为反向 DNS。

如果 `/etc/resolv.conf` 文件指示可访问的 DNS 服务器，则执行以下操作：

	host rockylinux.org

结果应为：

	rockylinux.org has address 76.76.21.21

