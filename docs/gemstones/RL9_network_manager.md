---
title: RL9 - network manager 
author : tianci li
contributors: Steven Spencer 
tags:
  - networkmanager
  - RL9
---

# NetworkManager Network configuration tool suite

In 2004, Red Hat launched the **NetworkManager** project, which aims to make it easier for Linux users to meet the needs of current network management, especially the management of wireless networks. Today, the project is managed by GNOME. The [homepage for NetworkManager can be found here](https://networkmanager.dev/).

Official introduction - NetworkManager is a standard Linux network configuration tool suite. It supports various network settings from desktop to server and mobile devices, and is perfectly integrated with popular desktop environments and server configuration management tools.

The suite mainly includes two command line tools:

* `nmtui`. Configures the network in a graphical interface.

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
||OK|

* `nmcli`. Uses the command line to configure the network, either a pure command line or an interactive command line.

```bash
Shell > nmcli connection show                                                                                                        
NAME    UUID                                  TYPE      DEVICE                                                                              
ens160  25106d13-ba04-37a8-8eb9-64daa05168c9  ethernet  ens160
```

For RockyLinux 8.x, we introduced how to configure its network [in this document](./nmtui.md). You can use `vim` to edit the network card configuration file in the **/etc/sysconfig/network-script/** directory, or you can use `nmcli`/`nmtui`, both of which are acceptable.

## Naming rules for udev device Manager

For RockyLinux 9.x, if you go to the **/etc/sysconfig/network-scripts/** directory, there will be a **readme-ifcfg-rh.txt** description text that prompts you to go to the **/etc/NetworkManager/system-connections/** directory.

```bash
Shell > cd /etc/NetworkManager/system-connections/  && ls 
ens160.nmconnection
```

The `ens160` here refers to the name of the network card in the system. You may wonder why the name looks so strange?
This is because of the `udev` device manager. It supports many different naming schemes. By default, fixed names are assigned according to firmware, topology, and location information. Its advantages include:

* Device names are fully predictable.
* Device names stay fixed even if you add or remove hardware, because no re-enumeration takes place.
* Defective hardware can be seamlessly replaced.

In RHEL 9 and the corresponding community version operating systems, consistent device naming is enabled by default. The `udev` device manager will generate device names according to the following scheme:

| Scheme  | Description | Example     |
|---------|-------------|-------------|
| 1       | Device names incorporate firmware or BIOS-provided index numbers for onboard devices. If this information is not available or applicable, `udev` uses scheme 2. | eno1 |
| 2       | Device names incorporate firmware or BIOS-provided PCI Express (PCIe) hot plug slot index numbers. If this information is not available or applicable, `udev` uses scheme 3. | ens1 |
| 3       | Device names incorporate the physical location of the connector of the hardware. If this information is not available or applicable, `udev` uses scheme 5. | enp2s0 |
| 4       | Device names incorporate the MAC address. Red Hat Enterprise Linux does not use this scheme by default, but administrators can optionally use it. | enx525400d5e0fb |
| 5       | The traditional unpredictable kernel naming scheme. If `udev` cannot apply any of the other schemes, the device manager uses this scheme. | eth0 |

`udev` device Manager names the prefix of the NIC based on the type of interface: 

* **en** for Ethernet. 
* **wl** for wireless LAN (WLAN). 
* **ww** for wireless wide area network (WWAN). 
* **ib**, InfiniBand network. 
* **sl**, Serial Line Internet Protocol (slip)

Add some suffixes to the prefix, such as:

* **o** on-board_index_number
* **s** hot_plug_slot_index_number **[f]** function **[d]** device_id
* **x** MAC_address
* **[P]** domain number **p** bus **s** slot **[f]** function **[d]** device_id
* **[P]** domain number **p** buss **s** slot **[f]** function **[u]** usb port **[c]** config **[i]** interface

You can use `man 7 systemd.net-naming-scheme` to get more detailed information. 

## `nmcli` command (recommended)

Users can not only configure the network in a pure command line mode, but also use interactive commands to configure the network.

### `nmcli connection`

The `nmcli connection` command can show, delete, add, modify, edit, up, down, and so on.

For specific usage, please refer to `nmcli connection add --help`, `nmcli connection edit --help`, `nmcli connection modify --help` and so on.

For example, to configure a new ipv4 static ip connection using a pure command line and start up automatically, it can be:

```bash
Shell > nmcli  connection  add  type  ethernet  con-name   CONNECTION_NAME  ifname  NIC_DEVICE_NAME   \
ipv4.method  manual  ipv4.address "192.168.10.5/24"  ipv4.gateway "192.168.10.1"  ipv4.dns "8.8.8.8,114.114.114.114" \
ipv6.method  disabled  autoconnect yes
```

If you are using DHCP to get the ipv4 address, it can be:

```bash
Shell > nmcli  connection  add  type ethernet con-name CONNECTION_NAME  ifname  NIC_DEVICE_NAME \
ipv4.method  auto  ipv6.method  disabled  autoconnect  yes
```

With the above configuration, the connection is not activated. You need to perform the following operations:

```bash
Shell > nmcli connection up  NIC_DEVICE_NAME
```

Enter the interactive interface through the `edit` keyword on the basis of the existing connection, and modify it:

```bash
Shell > nmcli connection  edit  CONNECTION_NAME
nmcli > help
```

You can also modify one or more properties of the connection directly from the command line with the `modify` keyword. For example:

```bash
Shell > nmcli connection modify CONNECTION_NAME autoconnect yes ipv6.method dhcp
```

!!! info

    Operations through `nmcli` or `nmtui` are saved permanently, not temporarily.

#### Link aggregation

Some use multiple network cards for link aggregation. In the early days, using **bonding** technology, there were seven working modes (0~6), and the bond mode only supported two network cards at most; Later, the **teaming** technology is gradually used as an alternative, there are five working modes, and the team mode can use up to eight network cards. Comparison link between bonding and teaming [can be found on this link](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/sec-comparison_of_network_teaming_to_bonding).

For example, the 0 mode of bonding:

```bash
Shell > nmcli  connection  add  type  bond  con-name  BOND_CONNECTION_NAME   ifname  BOND_NIC_DEVICE_NAME  mode 0  
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME1   master  BOND_NIC_DEVICE_NAME
Shell > nmcli  connection  add  type  bond-slave   ifname NIC_DEVICE_NAME2   master  BOND_NIC_DEVICE_NAME
```

## Network card configuration

!!! warning

    It is not recommended to make changes to this by means of `vim` or other editors.

You can view more detailed information through `man 5 NetworkManager.conf` and `man 5 nm-settings-nmcli`.

The content of the configuration file of the NetworkManager network card is an init-style key file. For example:

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

* Lines that start with # and blank lines are considered comments;
* Enclosed in [ and ] is the section it intends to declare the title, and below it are the specific key-value pairs contained. Each declared title and its key-value pair form a syntax segment;
* Any file with the .nmconnection suffix can be used by **NetworkManager**.

**connection** title names can contain these common key-value pairs:

| key name       | description |
|----------------|-------------|
| id             | The alias of con-name, whose value is a string.|
| uuid           | Universal unique identifier, whose value is a string. |
| type           | The type of connection, whose values can be ethernet, bluetooth, vpn, vlan, and so on. You can use `man  nmcli` to view all supported types. |
| interface-name | The name of the network interface this connection is bound to, whose value is a string. |
| timestamp      | Unix timestamp, in seconds. The value here is the number of seconds since January 1, 1970.|
| autoconnect    | Whether it starts automatically when the system starts. The value is of Boolean type.|

**ethernet** title names can contain these common key-value pairs:

| key name       | description |
|----------------|-----|
| mac-address    | MAC physical address. |
| mtu            | Maximum Transmission Unit.|
| auto-negotiate | Whether to negotiate automatically. The value is Boolean type.|
| duplex         | The Values can be half (half-duplex), full (full-duplex) |
| speed          | Specify the transmission rate of the network card. 100 is 100Mbit/s. If **auto-negotiate=false**, the **speed** key and **duplex** key must be set; if **auto-negotiate=true**, the speed used is the negotiated speed, and the writing here does not take effect (this is only applicable to the BASE-T 802.3 specification); when nonzero, the **duplex** key must have a value.|

**ipv4** title names can contain these common key-value pairs:

| key name       | description |
|----------------|-----|
| addresses | IP addresses assigned |
| gateway | Gateway (next hop) for the interface|
| dns | Domain Name Servers in use |
| method | The method to be obtained by IP. The value is of string type. The value can be: auto, disabled, link-local, manual, shared |
