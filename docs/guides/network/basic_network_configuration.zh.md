---
title: 网络配置
author: 未知
contributors: Steven Spencer, Hayden Young
tested with: 8.5, 8.6, 9.0
tags:
  - 网络连接
  - 配置
  - 网络
---

# 简介

现在的计算机如果没有网络连接，就无法发挥太多作用。 无论你是需要更新服务器上的软件包，还是仅仅需要从笔记本电脑上浏览外部网站，你都需要网络连接！ 本指南旨在为 Rocky Linux 用户提供设置网络连接的基本知识。

## 前提条件

* 有一定的命令行操作经验。
* 在系统上有较高的权限或管理权限（例如`root`、`sudo`等）
* 可选：熟悉网络概念

=== "9"

    ## 网络配置 - Rocky Linux 9
    
    随着 Rocky Linux 9 的推出，网络配置方面发生了很多变化。 其中一个主要变化是从 Network-Scripts（仍可安装，但已被弃用）转为用 Network Manager 和 key 文件，而不是基于 `ifcfg` 的文件。 在 Rocky Linux 9 中，`NetworkManager` 将优先使用 `keyfiles` 而非以前的 `ifcfg` 文件。 由于这是现在的默认设置值，配置网络的操作应该将默认值设置作为正确的操作方式，因为多年来的其他更改意味着旧的实用程序最终会被弃用和删除。 本指南将尝试向你介绍 Network Manager 的使用以及 Rocky Linux 9 中的最新变化。 
    
    ## 前提条件

    * 有一定的命令行操作经验。
    * 在系统上有较高的权限或管理权限（例如`root`、`sudo`等）。
    * 可选：熟悉网络概念


    ## 使用 NetworkManager 服务

    在用户层面，网络配置由`NetworkManager`管理。 该工具作为服务运行，你可以使用以下命令检查它的状态：

    ```bash
    systemctl status NetworkManager
    ```


    ## 配置文件

    就像前面所提到的，现在默认配置文件是 key 文件 你可以运行以下命令来查看 `NetworkManager` 是如何优先处理这些文件：

    ```
    NetworkManager --print-config
    ```

    这将会给你输出类似下面的结果：

    ```
    [main]
    # plugins=keyfile,ifcfg-rh
    # rc-manager=auto
    # auth-polkit=true
    # iwd-config-path=
    dhcp=dhclient
    configure-and-quit=no

    [logging]
    # backend=journal
    # audit=false

    [device]
    # wifi.backend=wpa_supplicant

    # no-auto-default file "/var/lib/NetworkManager/no-auto-default.state"
    ```

    注意在配置文件顶部对 `keyfile` 的引用，后面跟着 `ifcfg-rh`。 这意味着 `keyfile` 是默认值。 任何时候你运行任何 `NetworkManager` 工具来配置网络接口（例如： `nmcli` 或 `nmtui`），它都会自动构建或更新 key 文件。

    !!! tip "配置文件存储位置"

        在 Rocky Linux 8 中，网络配置的存储位置在 `/etc/sysconfig/Network-Scripts/` 中。 在 Rocky Linux 9 中，密钥文件的新默认存储位置在 `/etc/NetworkManager/system-connections` 中。

    用于配置网络接口的主要（但不是唯一）工具是`nmtui`命令。 这也可以用`nmcli`命令来完成，但没有那么直观。 我们可以用`nmcli`来显示当前配置的网络接口：

    ```
    nmcli device show enp0s3
    GENERAL.DEVICE:                         enp0s3
    GENERAL.TYPE:                           ethernet
    GENERAL.HWADDR:                         08:00:27:BA:CE:88
    GENERAL.MTU:                            1500
    GENERAL.STATE:                          100 (connected)
    GENERAL.CONNECTION:                     enp0s3
    GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
    WIRED-PROPERTIES.CARRIER:               on
    IP4.ADDRESS[1]:                         192.168.1.151/24
    IP4.GATEWAY:                            192.168.1.1
    IP4.ROUTE[1]:                           dst = 192.168.1.0/24, nh = 0.0.0.0, mt = 100
    IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 192.168.1.1, mt = 100
    IP4.DNS[1]:                             8.8.8.8
    IP4.DNS[2]:                             8.8.4.4
    IP4.DNS[3]:                             192.168.1.1
    IP6.ADDRESS[1]:                         fe80::a00:27ff:feba:ce88/64
    IP6.GATEWAY:                            --
    IP6.ROUTE[1]:                           dst = fe80::/64, nh = ::, mt = 1024
    ```


    !!! tip "**提示：**"

        有几种方法，可以为系统分配其IP配置信息。 最常见的两种方法是 **静态 IP 配置方案** 和 **动态 IP 配置方案**。

        静态IP配置方案在服务器类系统亦或者网络上都是主流的方案。

        设置动态 IP 这个方法在家庭、办公网络、工作站、桌面系统中很受欢迎。  动态方案通常需要在本地有可用的 _某些东西_，并且可以向请求的工作站和桌面系统提供合适的 IP 配置信息。 这个 _某些东西_ 被称为动态主机配置协议（DHCP）。 在家庭网络甚至在大多数商业网络中，这项服务是由单独的DHCP服务器提供的。 这可以是一个独立的服务器或者是路由器配置的一部分。


    ## IP 地址

    在前面的部分中，接口 `enp0s3`显示`.ini`配置是从`/etc/NetworkManager/system-connections/enp0s3.nmconnection` 文件生成的。 这代表 IP4.ADDRESS[1] 已经是静态配置的，而不是通过DHCP动态配置的。 如果我们想把这个接口切换回动态分配的地址，最简单的方法是使用`nmtui`命令。

    1. 首先，在命令行中运行 `nmtui` 命令，会显示如下内容：

        ![nmtui](images/nmtui_first.png)

    2. 好了，默认已经在 "Edit a connection 选项上了，直接按 <kbd>TAB</kbd> 键，然后 "OK" 按钮会被高亮，再按下 <kbd>ENTER</kbd>

    3. 这将会显示机器上的以太网连接，并允许你选择其中一个。 在默认的情况下，只有 *ONLY*，因此它已经被高亮显示，我们只需要按 <kbd>TAB</kbd> 键，直到 "Edit" 被高亮显示，然后按下 <kbd>ENTER</kbd>

        ![nmtui_edit](images/nmtui_edit.png)

    4. 完成后，我们将进入显示当前配置的界面。 我们需要做的是从 "Manual" 切换到 "Automatic"，所以按 <kbd>TAB</kbd> 键多次，直到高亮显示 "Manual"，然后按下 <kbd>ENTER</kbd>

        ![nmtui_manual](images/nmtui_manual.png)

    5. 键盘上键，直到高亮显示 "Automatic"，然后按下 <kbd>ENTER</kbd>

        ![nmtui_automatic](basic_network_configuration.zh/nmtui_automatic.png)

    6. 一旦我们将网络接口切换到 "Automatic"，我们需要删除分配的静态 IP，因此按 <kbd>TAB</kbd> 键，直到在 IP 地址旁边高亮显示 "Remove"，然后按下 <kbd>ENTER</kbd> 。

        ![nmtui_remove](images/nmtui_remove.png)

    7. 最后，按 <kbd>TAB</kbd> 键多次直到到达 `nmtui` 屏幕底部，"OK" 被高亮显示，然后按下 <kbd>ENTER</kbd>。

    你也可以使用 `nmtui` 来禁用和启用网络接口，但我们将使用 `nmcli` 来完成此操作。 通过这种方式，我们可以将网络接口的停止和启动命令串联起来，让网卡接口不会长时间的处于离线状态：

    ```
    nmcli con down enp0s3 && nmcli con up enp0s3
    ```

    可以将其视为旧版本操作系统中的 `ifdown enp0s3 && ifup enp0s3` 命令的等效命令。

    为了验证它是否起到作用，可以使用之前用 `nmcli device show enp0s3` 或 `ip addr` 命令进行检查。

    ```
    ip addr
    ```

    如果成功，你现在应该看到静态 IP 已被删除，并添加了一个动态分配的地址，类似于以下内容：

    ```bash
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ba:ce:88 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.137/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 6342sec preferred_lft 6342sec
    inet6 fe80::a00:27ff:feba:ce88/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
    ```


    ### 使用 `nmcli` 更改 IP 地址

    用 `nmtui` 也很不错，但如果你只想快速的重新配置网络接口而不需要在界面上花费太多时间，你可以只使用 `nmcli`。 我们看一下上面的分配静态 IP 的示例以及使用 `nmcli` 重新配置网络接口为 DHCP 的步骤。

    请注意，在开始之前，要将接口重新配置为 DHCP，需要执行以下操作：

    * 删除 IPv4 网关
    * 删除分配的静态 IPv4 地址
    * 将 IPv4 类型改为自动
    * 停止并重启接口

    请注意，我们没有使用告诉你使用 -ipv4.address 地址等这些示例。 这些命令并不能完全改变接口。 为了做到这一点，我们需要将 ipv4.address 和 ipv4.gateway 设置为一个空字符串。 同样，为了尽可能节省我们的的时间，我们将命令都串联在一起，放在一行中：

    ```
    nmcli con mod enp0s3 ipv4.gateway '' && nmcli con mod enp0s3 ipv4.address '' && nmcli con mod enp0s3 ipv4.method auto && nmcli con down enp0s3 && nmcli con up enp0s3
    ```

    再次运行 `ip addr` 命令，应该会显示与我们用 `nmtui` 进行修改后完全一样的结果。 当然，我们也可以反过来做（将 DHCP 地址更改为静态地址）。 要做到这一点，我们按照相反的顺序运行命令，从更改 `ipv4.method` 为 manual 开始，设置 `ipv4.gateway`，然后设置 `ipv4.address`。 因为在所有这些示例中，我们完全是在重新配置接口，而不是添加或删除，因此我们不会使用那些讨论使用`+ipv4.method`、`+ipv4.gateway` 和 `+ipv4.address` 的示例。 如果你使用这些命令而不是我们示例使用的命令，你最终会得到一个既有 DHCP 分配的地址又有静态 IP 地址的接口。 话虽如此，但是这有时确实非常方便。 如果您有一个 Web 服务监听在一个 IP 上，而 SFTP 服务器监听在另一个 IP 上。 拥有一种将多个 IP 分配给接口的方法会非常的有用。


    ## DNS 解析

    设置DNS服务器可以通过 `nmtui` 或 `nmcli` 完成。 虽然 `nmtui` 界面易于浏览而且更加的直观，但是它让操作过程变得复杂了很多。 用 `nmcli` 进行此操作就要快得多。 对于通过 DHCP 分配的地址，通常不需要设置 DNS 服务器，因为它们通常是由 DHCP 服务器转发。 话虽如此，但你仍然可以添加静态 DNS 服务器到 DHCP 网络接口中。 对于静态分配的网络接口，你需要这样做，因为它需要知道如何获取 DNS 解析，并且不会有自动分配的情况。

    既然分配静态 IP 是最好的例子，那让我们回到我们的示例接口（enp0s3）中最初静态分配的地址。 在更改 DNS 值之前，我们需要查看当前设置的值。 为了获得正确的 DNS 解析，我们首先删除已设置的 DNS 服务器，然后再添加其他的。 当前的 `ipv4.dns` 被设置为 `8.8.8.8,8.8.4.4,192.168.1.1`.。 在这种情况下，我们不需要先将 ipv4.dns 设置为空字符串。 我们可以使用以下命令替换值：

    ```
    nmcli con mod enp0s3 ipv4.dns '208.67.222.222,208.67.220.220,192.168.1.1'
    ```

    运行 `nmcli con show enp0s3 | grep ipv4.dns` 命令，会显示我们已成功更改 DNS 服务器。 为了让更改生效，我们需要重新启动网卡接口：

    ```
    nmcli con down enp0s3 && nmcli con up enp0s3
    ```

    为了测试域名解析功能是否正常，请尝试 ping 已知的主机。 我们将以 google.com 为例：

    ```bash
    ping google.com
    PING google.com (172.217.4.46) 56(84) bytes of data.
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=1 ttl=119 time=14.5 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=2 ttl=119 time=14.6 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=3 ttl=119 time=14.4 ms
    ^C
    ```


    ## 使用 `ip` 工具

    `ip` 命令（由 *iproute2* 包提供）是获取信息和配置 Rocky Linux 等现代 Linux 系统网络的强大工具。

    在本示例中，我们将假设以下参数：

    * 网卡接口名称：enp0s3
    * ip 地址：192.168.1.151
    * 子网掩码：24
    * 网关：192.168.1.1


    ### 获取基本信息

    要查看所有接口的详细状态，请使用以下命令：

    ```bash
    ip a
    ```

    !!! tip "**专业提示：**"

        * 使用 `-c` 标签，可以让终端输出彩色的信息：`ip -c a`。
        * `ip` 命令允许缩写，因此 `ip a`、`ip addr` 和 `ip address` 是等效的。


    ### 启用或禁用接口：

    !!! note

        虽然在 Rocky Linux 9 中仍然可以使用此方法来启用和禁用网络接口，但此命令的反应速度比在前面的示例中简单地使用 `nmcli` 命令要慢得多。

    要重启 *enp0s3* 网卡接口，我们可以使用以下命令：

    ```
    ip link set enp0s3 down && ip link set enp0s3 up
    ```


    ### 为网络接口分配静态地址

    目前，我们的 enp0s3 网络接口的 IP 地址为 192.168.1.151。 要将其切换为 192.168.1.152，我们需要使用以下命令删除旧 IP：

    ```bash
    ip addr delete 192.168.1.151/24 dev enp0s3 && ip addr add 192.168.1.152/24 dev enp0s3
    ```

    如果我们想要为网卡接口分配第二个 IP 地址，而不是删除 192.168.1.151 地址，则需使用以下命令添加第二个地址：

    ```bash
    ip addr add 192.168.1.152/24 dev enp0s3
    ```

    我们可以使用以下命令检查 IP 地址是否已添加：

    ```bash
    ip a show dev enp0s3
    ```

    将会输出：

    ```bash
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ba:ce:88 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.151/24 brd 192.168.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.1.152/24 scope global secondary enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feba:ce88/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
    ```

    虽然使用 `ip` 工具，启用和禁用网卡接口比使用 `nmcli` 慢得多，但是在设置新的或附加 IP 地址时，`ip` 具有明显的优势，因为它可以实时进行，而不需要重启网络接口。


    ### 网关配置


    现在接口有了地址，我们需要设置它的默认路由，可以使用以下命令完成：

    ```bash
    ip route add default via 192.168.1.1 dev enp0s3
    ```

    可以使用以下命令显示内核路由表：

    ```bash
    ip route
    ```

    或者简写为 `ip r`。

    这样会输出和下面相同内容：

    ```bash
    default via 192.168.1.1 dev enp0s3 
    192.168.1.0/24 dev enp0s3 proto kernel scope link src 192.168.1.151 metric 100
    ```


    ## 检查网络连通性

    在上面的示例中，我们进行了一些测试。 最好的测试方法是先 ping 一下默认网关： 这样是有效的：

    ```bash
    ping -c3 192.168.1.1
    PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
    64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=0.437 ms
    64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.879 ms
    64 bytes from 192.168.1.1: icmp_seq=3 ttl=64 time=0.633 ms
    ```

    接下来，通过对本地网络上的主机进行 ping 测试，检查局域网路由是否正常工作：

    ```bash
    ping -c3 192.168.1.10
    PING 192.168.1.10 (192.168.1.10) 56(84) bytes of data.
    64 bytes from 192.168.1.10: icmp_seq=2 ttl=255 time=0.684 ms
    64 bytes from 192.168.1.10: icmp_seq=3 ttl=255 time=0.676 ms
    ```

    现在测试一下，确保我们可以访问互联网上其他的主机。 在下面的测试中，我们用 Google DNS 服务器测试：

    ```bash
    ping -c3 8.8.8.8
    PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
    64 bytes from 8.8.8.8: icmp_seq=1 ttl=119 time=19.8 ms
    64 bytes from 8.8.8.8: icmp_seq=2 ttl=119 time=20.2 ms
    64 bytes from 8.8.8.8: icmp_seq=3 ttl=119 time=20.1 ms
    ```

    最后一个测试是确保 DNS 解析正常工作。 对于这个示例，我们使用 google.com：

    ```bash
    ping -c3 google.com
    PING google.com (172.217.4.46) 56(84) bytes of data.
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=1 ttl=119 time=14.5 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=2 ttl=119 time=15.1 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=3 ttl=119 time=14.6 ms
    ```

    如果你的设备上有多个网卡接口，并且你想从指定接口进行测试，只需使用 ping 命令的 `-I` 选项：

    ```bash
    ping -I enp0s3 -c3 192.168.1.10
    ```


    ## 结语

    在Rocky Linux 9中，网络配置有大量的变化。 其中之一是优先使用`keyfile`，而不是 Network-Scripts 中以前使用的`ifcfg`文件。 因为再未来的 Rocky Linux 版本中，将完全废弃和删除 Network-Scripts 选项，所以最好使用 `nmcli`、`nmtui` 和在某些情况下的 `ip` 之类的方法上进行网络配置。

=== "8"

    ## 网络配置 - Rocky Linux 8
    
    ## 使用 NetworkManager 服务
    
    在用户层面上，网络配置由 *NetworkManager* 管理。 该工具作为服务运行，你可以使用以下命令检查它的状态：

    ```bash
    systemctl status NetworkManager
    ```


    ### 配置文件
    
    NetworkManager 将从以下位置读取配置： `/etc/sysconfig/network-scripts/ifcfg-<IFACE_NAME>`.
    每个网络接口都有自己的配置文件。 以下是服务器默认的配置示例：

    ```bash
    TYPE=Ethernet
    PROXY_METHOD=none
    BROWSER_ONLY=no
    BOOTPROTO=none
    DEFROUTE=yes
    IPV4_FAILURE_FATAL=no
    IPV6INIT=no
    NAME=enp1s0
    UUID=74c5ccee-c1f4-4f45-883f-fc4f765a8477
    DEVICE=enp1s0
    ONBOOT=yes
    IPADDR=10.0.0.10
    PREFIX=24
    GATEWAY=10.0.0.1
    DNS1=10.0.0.1
    DNS2=1.1.1.1
    IPV6_DISABLED=yes
    ```


    接口的名称为 **enp1s0**，所以该文件的名称将为 `/etc/sysconfig/network-scripts/ifcfg-enp1s0`。
    
    !!! tip "**提示:**"  
    
        有几种方式或可以为系统分配其 IP 配置信息。 最常见的两种方法是 **静态 IP 配置** 和 **动态 IP 配置**。
    
        静态IP配置方案在服务器类系统亦或者网络上都是主流的方案。
    
        设置动态 IP 这个方法在家庭、办公网络、工作站、桌面系统中很受欢迎。  动态方案通常需要在本地有可用的 某些东西，并且可以向请求的工作站和桌面系统提供合适的 IP 配置信息。 这个 某些东西 被称为动态主机配置协议（DHCP）。
    
        很多时候，家庭/办公室环境的用户不需要担心或了解DHCP。 这是因为有其他设备在后台自动地处理这个问题。 终端用户需要做的唯一的事，用网线或无线方式连接到网络（当然还要确保它们的系统已经打开）!
    
    ### IP 地址。、
    
    在前面的`/etc/sysconfig/network-scripts/ifcfg-enp1s0`列表中，可以看到`BOOTPROTO`参数的值被设置为`none`。 这意味着正在配置的系统被设置为静态 IP 地址方案。
    
    如果你想配置系统使用动态 IP 地址方案，你需要将`BOOTPROTO`参数的值从`none`更改为`dhcp`，并删除`IPADDR`、`PREFIX`和`GATEWAY`行。 这是必做的，因为这些信息会从任何可用的 DHCP 服务器自动获取。
    
    要配置静态 IP 地址，请设置以下内容：

    * IPADDR: 需要分配的 IP 地址
    * PREFIX: 子网掩码使用 [CIDR 表示法](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)
    * GATEWAY: 默认网关

    `ONBOOT` 参数设置为 `yes` 表示此连接将在启动时被激活。


    ### DNS 解析

    为了获得正确的域名解析，必须设置以下参数：

    * DNS1: 首选DNS服务器IP
    * DNS2: 备用DNS服务器IP


    ### 正在检查配置

    你可以使用 `nmcli` 命令检查配置是否已正确设置：

    ```bash
    [user@server ~]$ sudo nmcli device show enp1s0
    ```

    这会给你输出以下内容：

    ```conf
    GENERAL.DEVICE:                         enp1s0
    GENERAL.TYPE:                           ethernet
    GENERAL.HWADDR:                         6E:86:C0:4E:15:DB
    GENERAL.MTU:                            1500
    GENERAL.STATE:                          100 (connecté)
    GENERAL.CONNECTION:                     enp1s0
    GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
    WIRED-PROPERTIES.CARRIER:               marche
    IP4.ADDRESS[1]:                         10.0.0.10/24
    IP4.GATEWAY:                            10.0.0.1
    IP4.ROUTE[1]:                           dst = 10.0.0.0/24, nh = 0.0.0.0, mt = 100
    IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 10.0.0.1, mt = 100
    IP4.DNS[1]:                             10.0.0.1
    IP4.DNS[2]:                             1.1.1.1
    IP6.GATEWAY:                            --
    ```


    ### 命令行界面（CLI）

    NetworkManager 的主要功能是管理“网络连接”，配置连接的物理设备、IP 地址、DNS 服务器。 要查看 NetworkManager 维护的现有连接，可以运行`nmcli connection show`命令。

    ```bash
    [user@server ~]$ sudo nmcli connection show
    NAME    UUID                                  TYPE      DEVICE
    enp1s0  625a8aef-175d-4692-934c-2c4a85f11b8c  ethernet  enp1s0
    ```

    从上面的输出可以确定，NetworkManager 管理一个名为 `enp1s0`的连接，该连接映射到物理设备`enp1s0`.。

    !!! tip "连接名称"

        在这个例子中，连接和设备具有相同的名称，但这并不一定总是这样。 通常会看到一个名为`System eth0` 的连接，该连接映射到一个名为`eth0`的设备。

    现在我们知道了连接的名称，我们可以查看它的设置。 要做到这一点，可以使用`nmcli connection show [connection]`命令，该命令会打印出NetworkManager 为给连接注册的所有设置。

    ```bash
    [user@server ~]$ sudo nmcli connection show enp1s0
    ...
    ipv4.method:                            auto
    ipv4.dns:                               --
    ipv4.dns-search:                        --
    ipv4.dns-options:                       --
    ipv4.dns-priority:                      0
    ipv4.addresses:                         --
    ipv4.gateway:                           --
    ipv4.routes:                            --
    ipv4.route-metric:                      -1
    ipv4.route-table:                       0 (unspec)
    ipv4.routing-rules:                     --
    ipv4.ignore-auto-routes:                no
    ipv4.ignore-auto-dns:                   no
    ipv4.dhcp-client-id:                    --
    ipv4.dhcp-iaid:                         --
    ipv4.dhcp-timeout:                      0 (default)
    ipv4.dhcp-send-hostname:                yes
    ...
    ```

    在左侧的列中，我们可以看到设置的名称，而在右侧，我们可以看到它的值。

    例如，我们可以看到这里的`ipv4.method`目前设置为`auto`。 `ipv4.method`设置有许多允许的值，但是你最有可能看到的主要两个值是：

    * `auto`：对于接口使用适当的自动方法（DHCP、PPP 等），大多数其他属性可以不设置。
    * `manual`：需要手动设置IP地址、网关、DNS等网络属性。

    如果您想要配置系统使用静态IP地址方案，你需要更改`ipv4.method`的值为`manual`，并且指定`ipv4.gateway`和`ipv4.addresses`。

    要修改设置，可以使用nmcli命令`nmcli connection modify [connection] [setting] [value]`。

    ```bash
    # set 10.0.0.10 as the static ipv4 address
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.addresses 10.0.0.10

    # set 10.0.0.1 as the ipv4 gateway
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.gateway 10.0.0.1

    # change ipv4 method to use static assignments (set in the previous two commands)
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.method manual
    ```

    !!!tip "连接什么时候会更新？"

        `nmcli connection modify`不会修改*runtime*配置，但会根据你告诉`nmcli`配置的值更新`/etc/sysconfig/network-scripts`配置文件。

    要通过 CLI 使用 NetworkManager 配置 DNS 服务器，可以修改`ipv4.dns`设置。

    ```bash
    # set 10.0.0.1 and 1.1.1.1 as the primary and secondary DNS servers
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.dns '10.0.0.1 1.1.1.1'
    ```


    ### 应用配置

    要应用网络配置，可以使用`nmcli connection up [connection]`命令。

    ```bash
    [user@server ~]$ sudo nmcli connection up enp1s0
    Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/2)
    ```

    要获取连接状态，只需使用：

    ```bash
    [user@server ~]$ sudo nmcli connection show
    NAME    UUID                                  TYPE      DEVICE
    enp1s0  625a8aef-175d-4692-934c-2c4a85f11b8c  ethernet  enp1s0
    ```

    你还可以使用`ifup`和`ifdown`命令将接口启动和关闭（它们是对`nmcli`的简单包装）：

    ```bash
    [user@server ~]$ sudo ifup enp1s0
    [user@server ~]$ sudo ifdown enp1s0
    ```


    ## 使用 ip 工具

    `ip`命令（由*iproute2*软件包提供）是一个强大的工具，用于获取信息和配置 Rocky Linux 等现代 Linux 系统的网络。

    在本例中，我们将假设以下参数：

    * 接口名称：ens19
    * ip地址：192.168.20.10
    * 子网掩码：24
    * 网关：192.168.20.254


    ### 获取基本信息

    要查看所有接口的详细状态，请使用以下命令：

    ```bash
    ip a
    ```

    !!! tip "**专业提示：**"

        * 使用`-c`选项以获得更易读的彩色输出：`ip -c a`。
        * `ip`命令允许缩写，因此`ip a`、`ip addr`和`ip address`是等效的。


    ### 启用或禁用接口：

    要启用*ens19*接口，只需使用`ip link set ens19 up`命令，要禁用它，请使用`ip link set ens19 down`命令。


    ### 为接口分配静态地址：

    分配静态地址的命令格式如下：

    ```bash
    ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>
    ```

    要分配上述示例参数，我们将使用以下命令：

    ```bash
    ip a add 192.168.20.10/24 dev ens19
    ```

    可以使用以下命令检查命令是否成功执行：

    ```bash
    ip a show dev ens19
    ```

    将会输出：

    ```bash
    3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
        inet 192.168.20.10/24 scope global ens19
        valid_lft forever preferred_lft forever
    ```

    我们的接口已经启动和配置，但仍然缺少一些东西！


    ### 使用 ifcfg 工具

    要将新的示例 IP 地址添加到 *ens19* 接口，请使用以下命令：

    ```bash
    ifcfg ens19 add 192.168.20.10/24
    ```

    要删除该地址，请使用以下命令：

    ```bash
    ifcfg ens19 del 192.168.20.10/24
    ```

    要完全禁用此接口的 IP 地址，请使用以下命令：

    ```bash
    ifcfg ens19 stop
    ```

    *请注意，这不会使接口停止运行，它只是取消分配给接口的所有IP地址。*


    ### 网关配置

    现在接口已经有了地址，我们需要设置它的默认路由，可以使用以下命令完成：

    ```bash
    ip route add default via 192.168.20.254 dev ens19
    ```

    可以使用以下命令显示内核路由表：

    ```bash
    ip route
    ```

    或者使用缩写命令 `ip r` 来显示内核路由表。


    ## 检查网络连通性

    到此为止，你应该已经将网络接口启动并正确配置好了。 有几种方法可以验证你的网络连接是否正常。

    通过对同一网络中的另一个 IP 地址进行 *ping* 测试来验证（我们将使用 `192.168.20.42` 作为示例）：

    ```bash
    ping -c3 192.168.20.42
    ```

    该命令将发出 3 个 *ping* 请求（也称为 ICMP 请求）并等待回复。 如果一切正常，你应该会看到以下输出：

    ```bash
    PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
    64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
    64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
    64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms

    --- 192.168.20.42 ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 5ms
    rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms
    ```

    接下来，为了确保你的路由配置正确，可以尝试 *ping* 一个外部主机，比如这个公共的 DNS ：

    ```bash
    ping -c3 8.8.8.8
    ```

    如果你的机器有多个网络接口，想要通过特定的接口发送 ICMP 请求，可以使用 `-I` 标志：

    ```bash
    ping -I ens19 -c3 192.168.20.42
    ```

    接下来确认DNS解析是否正常。 DNS 解析是一种机制，用于将机器名称转换为它们的 IP 地址，以及反向 DNS。

    如果 `/etc/resolv.conf` 文件指示了可用的 DNS 服务器，则以下操作应该可以正常工作：

    ```bash
    host rockylinux.org
    ```

    结果应该是：

    ```bash
    rockylinux.org has address 76.76.21.21
    ```


    ## 结语

    Rocky Linux 8 提供了命令行工具来配置你的网络。 本文档将帮助你快速掌握这些工具并开始使用它们。
