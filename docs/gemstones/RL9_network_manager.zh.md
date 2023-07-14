---
title: RL9 - network manager
author: tianci li
contributors: Steven Spencer
tags:
  - networkmanager
  - RL9
---

# NetworkManager 网络配置工具套件

2004年，红帽推出了 **NetworkManager** 项目，旨在使 Linux 用户更容易处理当前网络管理的需求，尤其是无线网络的管理。 如今，该项目由 GNOME 管理。 [可在此处找到NetworkManager的主页](https://networkmanager.dev/)。

官方介绍 - NetworkManager 是一个标准 Linux 网络配置工具套装。 它支持从桌面到服务器和移动设备的各种网络设置，并与流行的桌面环境和服务器配置管理工具完美集成。

该套件主要包括两个命令行工具：

* `nmtui`. 通过图形化界面配置网络。

```bash
shell > dnf -y install NetworkManager NetworkManager-tui
shell > nmtui
```

| NetworkManager TUI    |    |
| --------------------- | -- |
| Edit a connection     |    |
| Activate a connection |    |
| Set system hostname   |    |
| Quit                  |    |
|                       | OK |

* `nmcli`. 使用命令行配置网络，可以是纯命令行，也可以是交互式命令行。

```bash
Shell > nmcli connection show                                                                                                        
NAME    UUID                                  TYPE      DEVICE                                                                              
ens160  25106d13-ba04-37a8-8eb9-64daa05168c9  ethernet  ens160
```

对于 RockyLinux 8.x，我们在 [此文档中](./nmtui.md) 介绍了如何配置其网络。 您可以使用 `vim` 编辑 **/etc/sysconfig/network-script/** 目录中的网卡配置文件，也可以使用 `nmcli`/`nmtui` ，这两种方式都是可以接受的。

## udev 设备管理器的命名规则

对于 RockyLinux9.x，如果您去到 **/etc/sysconfig/network-scripts/** 目录中，将会出现一个 **readme-ifcfg-rh.txt** 描述文本，提示您去到 **/etc/NetworkManager/system-connections/** 目录。

```bash
Shell > cd /etc/NetworkManager/system-connections/  && ls 
ens160.nmconnection
```

这里的 `ens160` 是指系统中网卡的名称。 你可能想知道为什么这个名字看起来这么奇怪？ 这是因为 `udev` 设备管理器。 它支持许多不同的命名方案。 默认情况下，固定名称是根据固件、拓扑和位置信息分配的。 它的优势包括：

* 设备名称完全可预测。
* 即使添加或删除硬件，设备名称也保持不变，因为不会发生重新枚举。
* 有故障的硬件可以无缝更换。

在 RHEL 9 和相应的社区版本操作系统中，默认情况下启用了一致的设备命名。 `udev` 设备管理器将根据以下方案生成设备名称：

| 方案 | 描述                                                                           | 示例              |
| -- | ---------------------------------------------------------------------------- | --------------- |
| 1  | 设备名称包含板载设备的固件或 BIOS 提供的索引号。 如果此信息不可用或不适用，则 `udev` 会使用方案2。                    | eno1            |
| 2  | 设备名称包含固件或 BIOS 提供的 PCI Express(PCIe) 热插拔插槽索引号。 如果此信息不可用或不适用，则 `udev` 会使用方案3。 | ens1            |
| 3  | 设备名称包含硬件连接器的物理位置。 如果此信息不可用或不适用，则 `udev` 会使用方案5。                              | enp2s0          |
| 4  | 设备名称包含 MAC 地址。 Red Hat Enterprise Linux 默认不使用此方案，但管理员可以选择使用它。                | enx525400d5e0fb |
| 5  | 传统的不可预测的内核命名方案。 如果 `udev` 无法应用任何其他方案，则设备管理器使用此方案。                            | eth0            |

`udev` 设备管理器根据接口类型命名网卡的前缀：

* **en** 代表以太网。
* **wl** 代表无线局域网(WLAN)。
* **ww** 代表无线广域网(WWAN)。
* **ib** 代表 InfiniBand 网络。
* **sl** 代表串行线路因特网协议(slip)

在前缀中添加一些后缀，例如：

* **o** on-board_index_number
* **s** hot_plug_slot_index_number **[f]** function **[d]** device_id
* **x** MAC_address
* **[P]** domain number **p** bus **s** slot **[f]** function **[d]** device_id
* **[P]** domain number **p** buss **s** slot **[f]** function **[u]** usb port **[c]** config **[i]** interface

您可以使用 `man 7 systemd.net-naming-scheme` 获取更多详细信息。

## `nmcli` 命令 (推荐)

用户不仅可以在纯命令行模式下配置网络，还可以使用交互命令来配置网络。

### `nmcli connection`

`nmcli 连接` 命令可以 show、delete、add、modify、edit、up、down 等等。

具体用法请参考 `nmcli connection add --help`、`nmcli connection edit --help`、`nmcli connection modify --help` 等。

例如，要使用纯命令行配置新的 ipv4 静态ip连接并自启动，可以是：

```bash
Shell > nmcli  connection  add  type  ethernet  con-name   CONNECTION_NAME  ifname  NIC_DEVICE_NAME   \
ipv4.method  manual  ipv4.address "192.168.10.5/24"  ipv4.gateway "192.168.10.1"  ipv4.dns "8.8.8.8,114.114.114.114" \
ipv6.method  disabled  autoconnect yes
```

如果您正在使用 DHCP 获取 ipv4 地址，它可以是：

```bash
Shell > nmcli  connection  add  type ethernet con-name CONNECTION_NAME  ifname  NIC_DEVICE_NAME \
ipv4.method  auto  ipv6.method  disabled  autoconnect  yes
```

使用上述配置时，连接不会被激活。 您需要执行以下操作：

```bash
Shell > nmcli connection up  NIC_DEVICE_NAME
```

在已有连接的基础上，通过 `edit` 关键字进入交互界面，进行修改：

```bash
Shell > nmcli connection  edit  CONNECTION_NAME
nmcli > help
```

您还可以使用 `modify` 关键字直接从命令行修改连接的一个或多个属性。 例如：

```bash
Shell > nmcli connection modify CONNECTION_NAME autoconnect yes ipv6.method dhcp
```

!!! info "信息"

    通过 `nmcli` 或 `nmtui` 进行的操作将永久保存，而不是临时保存。

#### 链接聚合

有些使用多个网卡进行链路聚合。 早期使用 **bonding**技术，有 7 种工作模式（0~6），bond 模式最多只支持 2 块网卡；后来逐渐采用 **teaming** 技术作为替代，有5种工作模式，team 模式最多可以使用8块网卡。 在 [这个链接上可以找到](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-comparison_of_network_teaming_to_bonding) bonding 和 teming 之间的比较。

例如，bonding 的0模式：

```bash
Shell > nmcli  connection  add  type  bond  con-name  BOND_CONNECTION_NAME   ifname  BOND_NIC_DEVICE_NAME  mode 0  
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME1   master  BOND_NIC_DEVICE_NAME
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME2   master  BOND_NIC_DEVICE_NAME
```

## 网卡配置文件

!!! warning "警告"

    不建议通过 `vim` 或其他编辑器对此进行更改。

您可以通过 `man 5 NetworkManager.conf` 和 `man 5 nm-settings-nmcli` 查看更多详细信息。

NetwrokManager 网卡配置文件的内容为一个 init 风格的 key 文件。 例如：

```bash
Shell > cat /etc/NetworkManager/system-connections/ens160.nmconnection                                                               
[connection]                                                                                                                                
id=ens160                                                                                                                                   
uuid=5903ac99-e03f-46a8-8806-0a7a8424497e                                                                                                   
type=ethernet                                                                                                                               
interface-name=ens160                                                                                                                       
timestamp=1670056998                                                                                                                        

[ethernet]                                                                                                                                  
mac-address=00:0C:29:47:68:D0                                                                                                               

[ipv4]                                                                                                                                      
address1=192.168.100.4/24,192.168.100.1                                                                                                     
dns=8.8.8.8;114.114.114.114;                                                                                                                
method=manual                                                                                                                               

[ipv6]                                                                                                                                      
addr-gen-mode=default                                                                                                                       
method=disabled                                                                                                                             

[proxy] 
```

* 以 # 开头的行和空行被视为注释；
* [ 和 ] 中包含的是它打算声明标题的部分，下面是包含的特定键值对。 每个声明的标题及其键-值对形成一个语法段；
* **NetworkManager** 可以使用任何带有.nmconnection 后缀的文件。

**connection** 标题名可以包含以下常见的键值对：

| 键名称            | 描述                                                                       |
| -------------- | ------------------------------------------------------------------------ |
| id             | con-name 的别名，其值为字符串。                                                     |
| uuid           | 通用唯一标识符，其值是字符串。                                                          |
| type           | 连接的类型，其值可以是 ethernet、bluetooth、vpn、vlan 等等。 您可以使用 `man nmcli` 查看所有支持的类型。 |
| interface-name | 此连接绑定到的网络接口的名称，其值为字符串。                                                   |
| timestamp      | Unix 时间戳，以秒为单位。 此处的值是自1970年1月1日以来的秒数。                                    |
| autoconnect    | 是否随系统开机自启动。 值为布尔型。                                                       |

**ethernet** 标题名可以包含这些常见的键值对：

| 键名称            | 描述                                                                                                                                                                                |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| mac-address    | MAC 物理地址。                                                                                                                                                                         |
| mtu            | 最大传输单位。                                                                                                                                                                           |
| auto-negotiate | 是否自动协商。 值为布尔型。                                                                                                                                                                    |
| duplex         | 值可以是 half （半双工）、full（全双工）                                                                                                                                                         |
| speed          | 指定网卡的传输速率。 100 即 100Mbit/s。 如果**auto-negotiate=false**，则必须设置 **speed** 键和 **duplex** 键；如果 **auto-negotiate=true**，则使用的速率为协商速率，此处的写入不生效（仅适用于BASE-T 802.3规范）；当非零时，**duplex** 键必须有值。 |

**ipv4** 标题名可以包含这些常见的键值对：

| 键名称       | 描述                                                            |
| --------- | ------------------------------------------------------------- |
| addresses | 分配的IP地址                                                       |
| gateway   | 接口的网关（下一跳）                                                    |
| dns       | 正在使用的DNS                                                      |
| method    | IP获取的方法。 值是字符串类型。 值可以是：auto、disabled、link-local、manual、shared |
