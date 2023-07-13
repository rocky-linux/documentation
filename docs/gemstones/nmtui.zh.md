---
title: nmtui - 网络管理工具
author: tianci li
contributors: Steven Spencer, Neil Hanlon
update: 2021-10-23
---

# 引言

对于初次使用GNU/Linux的新手用户来说，最先考虑的事情是安装操作系统后如何让机器连接互联网。 本篇将告诉您如何配置IP地址、子网掩码、网关以及DNS， 有几种方式作为参考， 不管是新手还是熟手，相信您都都能快速上手。

## nmtui

`NetworkManager` 是一个标准的Linux网络配置工具套件，支持服务器，也支持桌面环境， 发展到如今，绝大多数流行的发行版都支持它。 这套网络配置工具适用于 Rocky Linux 8 及更高版本。 如果您希望以图形化的方式配置网络信息(即命令行`nmtui`)，只需要这么做：

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

| NetworkManager TUI    |          |
| --------------------- | -------- |
| Edit a connection     |          |
| Activate a connection |          |
| Set system hostname   |          |
| Quit                  |          |
|                       | \<OK\> |

您可以使用 <kbd>Tab</kbd>键 或者 <kbd>↑</kbd><kbd>↓</kbd><kbd>←</kbd><kbd>→</kbd>键的方式选择具体的功能，如果要更改网络信息，请选择 **Edit a connection** ，然后<kbd>Enter</kbd>键。 选择不同的网卡，选择 **Edit..** 进行编辑。

### DHCP的IPv4

针对IPv4，如果要使用DHCP获取网络信息，则只需要选择 *IPv4 CONFIGURATION* **&lt;Automatic&gt;**，然后在您的终端中运行 `systemctl restart NetworkManager.service`。 这在大多数情况下都会生效。 在极少数情况下，您需要禁用和启用网卡才能使更改生效。 例如：`nmcli connection down ens33`，`nmcli connection up ens33`


### 手动固定网络信息

如果要将所有IPv4的网络信息进行手动固定，需要选择 **&lt;Manual&gt;** 后面的 *IPv4 CONFIGURATION*，一行一行进行添加， 例如，像我这样的：

| 项           | 值                |
| ----------- | ---------------- |
| Addresses   | 192.168.100.4/24 |
| Gateway     | 192.168.100.1    |
| DNS servers | 8.8.8.8          |

然后点击 \< OK \> ，一步一步返回到终端界面，执行`systemctl restart NetworkManager.service` 即可。 同样的，极少数的情况下需要开关网卡才能生效。

## 更改配置文件的方式

所有的RHEL发行版，不管是上游的还是下游的，都是一样的配置方式。 网络信息的配置文件保存在 **/etc/sysconfig/network-scripts/** 目录下面，一个网卡对应一个配置文件。 配置文件的参数非常的多，如下表所示。 注意！ 参数一定要大写。

!!! warning "警告"

    在 RHEL 9.x 分发中，存储 NIC 配置文件的目录的位置已被更改，即**/etc/NetworkManager/system-connections/**。 更多信息请见 [这里](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-sinle/configuring_and_managing_networking/index)。

```bash
shell > ls /etc/sysconfig/network-scripts/
ifcfg-ens33
```

| 参数名                  | 含义                                                                                            | 示例                                  |
| -------------------- | --------------------------------------------------------------------------------------------- | ----------------------------------- |
| DEVICE               | 系统逻辑设备名                                                                                       | DEVICE=ens33                        |
| ONBOOT               | 网卡是否随系统自启动，可选择yes或者no                                                                         | ONBOOT=yes                          |
| TYPE                 | 网卡接口类型，一般是Ethernet                                                                            | TYPE=Ethernet                       |
| BOOTPROTO            | 获取ip的方式，可以是DHCP动态获取，也可以使用static静态手动配置                                                         | BOOTPROTO=static                    |
| IPADDR               | 网卡的ip地址，当BOOTPROTO=static时，该参数才生效                                                             | IPADDR=192.168.100.4                |
| HWADDR               | 硬件地址，即MAC地址                                                                                   | HWADDR=00:0C:29:84:F6:9C            |
| NETMASK              | 十进制的子网掩码                                                                                      | NETMASK=255.255.255.0               |
| PREFIX               | 子网掩码，用数字表示的方式                                                                                 | PREFIX=24                           |
| GATEWAY              | 网关，若有多块网卡，该参数只能出现一次                                                                           | GATEWAY=192.168.100.1               |
| PEERDNS              | 当为yes时，此处定义的DNS参数会修改/etc/resolv.conf；当为no时，不会修改/etc/resolv.conf。 当使用DHCP时，此处默认yes             | PEERDNS=yes                         |
| DNS1                 | 主选DNS，当PEERDNS=no时才生效                                                                         | DNS1=8.8.8.8                        |
| DNS2                 | 备选DNS，当PEERDNS=no时才生效                                                                         | DNS2=114.114.114.114                |
| BROWSER_ONLY         | 是否只允许浏览器                                                                                      | BROWSER_ONLY=no                     |
| USERCTL              | 是否允许普通用户控制网卡设备，yes表示允许，no表示不允许                                                                | USERCTL=no                          |
| UUID                 | 通用唯一识别码，主要作用是标识硬件，一般来说可不填                                                                     |                                     |
| PROXY_METHOD         | 代理的方式，一般为none，可不填                                                                             |                                     |
| IPV4_FAILURE_FATAL | 如果为yes，表示ipv4配置失败后禁用设备；为no，表示不禁用。                                                             | IPV4_FAILURE_FATAL=no             |
| IPV6INIT             | 是否启用IPV6，yes启用，no不启用。 当IPV6INIT=yes时，还能启用 IPV6ADDR 与 IPV6_DEFAULTGW 两个参数， 前者表示IPV6地址，后者表示指定网关 | IPV6INIT=yes                        |
| IPV6_AUTOCONF        | 是否使用IPV6的自动配置，yes表示使用；no表示不使用                                                                 | IPV6_AUTOCONF=yes                   |
| IPV6_DEFROUTE        | 是否给IPV6默认路由                                                                                   | IPV6_DEFROUTE=yes                   |
| IPV6_FAILURE_FATAL | IPV6配置失败后，是否禁用设备                                                                              | IPV6_FAILURE_FATAL=no             |
| IPV6_ADDR_GEN_MODE | 产生IPV6地址的模型，可选值有stable-privacy与eui64                                                          | IPV6_ADDR_GEN_MODE=stable-privacy |

配置文件修改成功后，记得重启网卡服务 `systemctl restart NetworkManager.service` 。

### IPV4的推荐配置

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

### IPV6的推荐配置

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

## 查看网络信息

`ip a`或者`nmcli device show`
