---
author: Wale Soyinka 
contributors: Steven Spencer, Ganna Zhyrnova
tested on: All Versions
tags:
  - lab exercise
  - networking
  - nmcli
  - ip
  - iproute2
  - macvtap
---


# Lab 5: Networking Essentials

## Objectives

After completing this lab, you will be able to:

- Create virtual network devices
- Manage network devices and settings on a Linux system using the `iproute2` (`ip`) toolkit
- Manage network devices and settings on a Linux system using NetworkManager (`nmcli`) toolkit 
- Troubleshoot common network issues

Estimated time to complete this lab: 60 minutes


## Overview 

This Networking Essentials lab covers various network configuration and troubleshooting exercises on a Linux server. You will be better equipped to manage and troubleshoot network settings using common networking utilities readily available on Linux based systems.

## Exercise 1

### Change Hostname

There are many methods for identifying or referring to computers. Some of these methods guarantee uniqueness [ especially on a network], and others don't. A computer hostname can be regarded as a human-friendly name. Computer hostnames should ideally be unique depending on how they are managed and assigned. But because anyone with the Administrative privileges on a system can unilaterally assign whatever hostname they want to the system - uniqueness is not always guaranteed. 

This first exercise walks through some common tools for managing the computer hostname.


#### To change the system's hostname


1. While logged into your system, view the current *hostname*, using the popular `hostname` utility. Type:

    ```bash
    hostname
    ```

2.  Run the `hostname` utility again with a different option to view the server's FQDN:

    ```bash
    hostname --fqdn
    ```

    !!! Question
        
        What does FQDN stand for? And why is the result of your server plain server hostname different from its FQDN?
    
3. Use the `hostnamectl` utility to view the current *hostnames*. Type:

    ```bash
    hostnamectl
    ```
   That's a lot of extra information! 

4. Add the `--static` option to the `hostnamectl` command to view the static hostname for your server. Type:

    ```bash
    hostnamectl --static
    ```
5. Add the `--transient` option to the `hostnamectl` command to view the transient hostname for your server.
   
6. Now try the `--pretty` option to the `hostnamectl` command to view the pretty hostname for your server.
   
7. Set a new transient hostname for your server. Type:

    ```bash
    hostnamectl --transient set-hostname my-temp-server1 
    ```

8. Verify the transient hostname change. Type:

    ```bash
    hostnamectl --transient
    ```
9. Set a new static hostname for your server. Type:

    ```bash
    hostnamectl set-hostname my-static-hostname1
    ```

10. Verify the static hostname change.
    
    !!! Question

        Consult the man page for `hostnamectl`. What are the differences between pretty, transient and static hostnames?
    
## Exercise 2

The first critical step you need to complete before going on to the other exercises in this network lab will be creating a special virtual network interface known as a MACVTAP device.

MACVTAP devices are virtual devices that combine the properties of a softwarei-only interface known as a TAP device as well as the properties of the MACVLAN driver. 

Creating and working with these MACVTAP devices will allow you to safely test, change, and configure various network configuration-related tasks. These virtual network interfaces will be used in various exercises without disrupting the existing network configuration.


!!! TIP
    
    TAP devices provide a software-only interface that user-space applications can easily access. TAP devices send and receive raw Ethernet frames. 
    MACVLAN is used for creating virtual network interfaces that attach to physical network interfaces. 
    The MACVTAP devices have their own unique MAC address distinct from the MAC address of the underlying physical network card they are associated with.
    
### Create MACVTAP Interfaces

This exercise starts with creating needed MACVTAP virtual network interfaces. This will allow you to safely test, change, and configure various network configuration related tasks. These virtual network interfaces will be used in various exercises without disrupting the existing network configuration.


#### To list all network interfaces on the system

1. Ensure you are logged into the server.
   
2. Use the `ip` program to view the existing network interfaces on your system. Type:

    ```bash
    ip link show
    ```
3. Try using the `nmcli` command to list all the network devices. Type:

    ```bash
     nmcli -f DEVICE device
    ```

4. Query the low-level /sys virtual file-system to enumerate ALL network interfaces available on your server manually. Type:

    ```bash
     ls -l /sys/class/net/ | grep -v 'total' | awk '{print $9}'
    ```

#### To create `macvtap` interfaces

1. Ensure you are logged into the system as a user with Administrative privileges.

2. You need query for and identify the proper network device types that are available on your server to be able to associate with `macvtap` device. Type:

    ```bash
     ls -l /sys/class/net/ | grep -v 'virtual\|total' | tail -n 1 | awk '{print $9}'

     eno2
    ```
    The output on the sample demo system shows one suitable interface named eno2.
   
3. Run the command to identify the device again but this time store the returned value in a 
   variable named $DEVICE1. Double check the value of $DEVICE1 using echo.  
   Type the following 2 separate commands to accomplish this:

    ```bash
    # DEVICE1=$(ls -l /sys/class/net/ | grep -v 'virtual\|total' | tail -n 1 | awk '{print $9}')
    
    # echo $DEVICE1
    ```

4. Now, create a MACVTAP interface named - `macvtap1`. The new interface will be associated with
    $DEVICE1. Type: 

    ```bash
    ip link add link $DEVICE1 name macvtap1 type macvtap mode bridge
    ```

5. Verify the creation of `macvtap1` interface. Type:

    ```bash
    ip --brief link show macvtap1
    ```

    Note the DOWN state of the `macvtap` interface in the output. 

6. View detailed information about all the MACVTAP-type network devices on the system. Type:

    ```bash
    ip --detail link show type macvtap
    ```

7. Run a command to view all the network interfaces on the server and compare the output to the output of the similar command in the earlier section "To list all network interfaces on the system".

### Enable/Disable Network Interface

#### To enable or disable a network interface

1. Check the status of the `macvtap1` network interface. Type:

    ```bash
    ip link show macvtap1
    ```

2. Enable the `macvtap1` network interface (if it's currently disabled). Run:

    ```bash
    ip link set macvtap1 up
    ```

3. Verify the status changes by running:

    ```bash
    ip -br  link show macvtap1
    ```

    !!! TIP
        
        If you ever need to disable a network interface, the syntax for `ip` command to do this is `ip link set <IFNAME> down`. For example to disable a network interface named `macvtap7`, you would run: 
        
        ```bash
        ip link set macvtap7 down
        ```
    
Now that you have set up the `macvtap` interfaces, you safely perform the various network configuration and troubleshooting tasks in the remaining exercises.


## Exercise 3

### Assign IP Addresses

#### To set an IP addresses on a network interface

1. View the IP addresses for all network interfaces on your server. Type:
   
    ```bash
    ip address show   
    ```
2. Assign the IP address - 172.16.99.100 - to `macvtap1`. Type
   
    ```bash
    ip address add 172.16.99.100/24 dev macvtap1    
    ```

3. Verify the IP address assignment for `macvtap1`

    ```bash
    ip address show macvtap1
    ```
4. Use the `nmcli` command to view the IPv4 addresses for all interfaces on your system. Type:

    ```bash
    nmcli --get-values IP4.ADDRESS,GENERAL.DEVICE  device show  
    ```

## Exercise 4

### Configure IPv6 Addresses

#### To assign IPv6 addresses to `macvtap` interfaces

1. Starting with `macvtap1`, assign the 2001:db8::1/64 IPv6 address to `macvtap1` by running:

    ```bash
     ip -6 address add 2001:db8::1/64 dev macvtap1
    ```

2. Next for `macvtap1` assign the 2001:db8::2/64 IPv6 address by running:

    ```bash
    # ip -6 address add 2001:db8::2/64 dev macvtap1
    ```

3. Verify the IPv6 address assignments, type:

    ```bash    
    ip --brief -6 address show macvtap1 && ip -br -6 address show macvtap1
    ```
    
4. Use `nmcli` to view the IPv6 addresses for all interfaces on your system. Type:

    ```bash
    nmcli --get-values  IP6.ADDRESS,GENERAL.DEVICE  device show  
    ```
    
## Exercise 5

### Routing management

#### To view the system's routing table

1. Display the current routing table for the system. Type:
 
    ```bash
    ip route show
    default via 192.168.2.1 dev enp1s0 proto dhcp src 192.168.2.121 metric 100
    10.99.99.0/24 dev tunA proto kernel scope link src 10.99.99.1 metric 450 linkdown
    192.168.2.0/24 dev enp1s0 proto kernel scope link src 192.168.2.121 metric 100
    ```
2. Using one of the networks displayed in the leftmost column of the previous command's output as the argument, display the route table entry for that network. For example to show the kernel route table entry for the 10.99.99.0/24 network, type:
    
    ```bash
    ip route show 10.99.99.0/24
    ```
    
3. Query the system to see the route that will be used to get to an example arbitrary
   destination. For example to view the routing details for getting to the destination IP address
   8.8.8.8, type:
    
    ```bash
    ip route get 8.8.8.8
    
    8.8.8.8 via 192.168.2.1 dev enp1s0 src 192.168.2.121 uid 0
    cache
    ```
    
    Here is a breakdown of the output in plain-speak:
    
    * Destination IP Address: 8.8.8.8 is the IP address that we are trying to reach
    * Via: 192.168.2.1 is the next hop IP address that the packet will be sent to reach the destination
    * Device: `enp1s0` is the network interface that will be used to send the packet
    * Source IP Address: 192.168.2.121 is the IP address of the network interface that will be used as the source address for the packet
    * UID: 0 is the user ID of the process that initiated this command
    * Cache: This field indicates whether this route is cached in the kernel’s routing table

4. Now view how the system will route a packet from one IP to another destination IP address. Type:   
       
    ```bash
    ip route get from 192.168.1.1 to 192.168.1.2
    
    local 192.168.1.2 from 192.168.1.1 dev lo uid 0
    cache <local>
    ```
    
### Set Default Gateway

#### To configure a default gateway for the system

1. Use `ip` to query for and list the current default gateway on your system. Type:
 
    ```bash
     ip route show default
    ```
    
2. Set a default gateway via the `macvtap1` interface. Type:
    
    ```bash
    ip route add default via 192.168.1.1
    ```

3. Verify the new default gateway configuration
    
    ```bash
    ip route show default
    ```
    
### Add Static Route

#### To add a static route to the routing table

1. Add a demo static route for a bogus 172.16.0.0/16 network via 192.168.1.2. Type:

    ```bash
    ip route add 172.16.0.0/16 via 192.168.1.2
    ``` 
2. Verify the addition of the static route by running:

    ```bash
    ip route show 172.16.0.0/16
    ```
    
### Delete Static Route

#### To Remove a static route from the routing table

1. Delete the static route for 10.0.0.0/24

    ```bash
    ip route del 10.0.0.0/24 via 192.168.1.2
    ```
    
2. Verify the removal of the static route
    
    ```bash
    ip route show
    ```
    
## Exercise 6

### Deleting IP addresses

This exercise walks through how to delete configured IP (IPv4 and IPv6) addresses on network interfaces.

### Delete IPv4 Address

#### To remove an assigned IP address from a network interface

1. Delete the IP address on `macvtap1`. Type:
    
    ```bash
    ip address del 172.16.99.100/24 dev macvtap1
    ```
    
2. Verify the removal of the IP address by running:
    
    ```bash
    ip address show macvtap1
    ```
    
### Delete IPv6 Address

#### To remove an assigned IPv6 address from a network interface

1. Delete the IPv6 address on `macvtap1` with this command:

    ```bash
    ip -6 address del 2001:db8::1/64 dev macvtap1
    ```
    
2. Verify the removal of the IPv6 address with:
    
    ```bash
    ip -6 address show macvtap1
    ```
    
## Exercise 7

### Configure Network Interfaces via `nmcli`

This exercise shows how to configure network interfaces using the NetworkManager tooling.

!!! Note
    
    By default, any network configuration changes done using `nmcli` (NetworkManager) will persist between system reboots.
    This is in contrast to the configuration changes that are done with the `ip` utility.

#### To create a `macvtap` interface using `nmcli` 

1. Start by listing all available network devices by running:

    ```bash
    nmcli device
    ```
    
2. Next, identify an underlying network device with which to associate the new MACVTAP interface. Save the value of the identified device in the variable $DEVICE2. Type:
    
    ```bash
    DEVICE2=$(ls -l /sys/class/net/ | grep -v 'virtual\|total' | tail -n 1 | awk '{print $9}')
    ```
    
3. Now, create a new NetworkManager connection called `macvtap2` and an associated MACVTAP interface named - `macvtap2`. The new interface will be associated with $DEVICE2. Type: 
    
    ```bash
    nmcli con add con-name macvtap2 type macvtap mode bridge  tap yes dev $DEVICE2 ifname macvtap2
    ```
    
4. Use `nmcli` to verify the creation of `macvtap2` interface. Type:
    
    ```bash
    nmcli device show macvtap2
    ```
    
5. Use `nmcli` to verify the creation of `macvtap2` connection. Type:
    
    ```bash
    nmcli connection show macvtap2
    ```
    
6. Similarly use `ip` to verify the creation of `macvtap2` interface. Type:
    
    ```bash
    ip --brief link show macvtap2
    ```
    
    Note the output's UP state of the `macvtap` interface.
    
    !!! Question
        
        What is the difference between the concept of a connection and that of a device in NetworkManager?
    
#### To modify interface network configuration with `nmcli`

1. Start by querying for the IPv4 address for the new `macvtap2` interface by running:
    
    ```bash
    nmcli -f ipv4.addresses con show macvtap2
    ```
    
    The value of the ipv4.addresses property should be empty.
    
2. Configure the `macvtap2` connection with these settings:
   
    IPv4 Method =  manual
    IPv4 Addresses =  172.16.99.200/24
    Gateway = 172.16.99.1 
    DNS Servers  = 8.8.8.8 and 8.8.4.4
    DNS Search domain = example.com
    
    Type:
    
    ```bash
    nmcli connection modify macvtap2  ipv4.method manual \
    ipv4.addresses 172.16.99.200/24 ipv4.gateway 172.16.99.1 \
    ipv4.dns 8.8.8.8,8.8.4.4 ipv4.dns-search example.com
    ```
    
3. Verify the new IPv4 address setting by running:
    
    ```bash
    nmcli -f ipv4.addresses con show macvtap2
    ```

4. Run a slightly different variation of the previous command to include the runtime configuration of the given settings. Type:

    ```bash
    nmcli -f ipv4.addresses,IP4.ADDRESS con show macvtap2
    ```
    
    !!! Question
    
        What is the difference between these NetworkManager properties - ipv4.addresses and IP4.ADDRESS 
    
5. Check the changes to the network connection using the `ip` command. Type:
    
    ```bash
    ip -br address show  dev macvtap2
    ```
    
6. To properly apply the new settings and make them the new runtime values, use `nmcli` to first toggle the connection down (i.e. deactivate it). Type:
    
    ```bash
    nmcli connection down macvtap2
    
    Connection macvtap2 successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/5)
    ```
    
7. Now activate the new connection to apply the new settings. Type:
    
    ```bash
    nmcli connection up macvtap2
    
    Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/6)
    ```
    
8. View the final setting using the ip utility. Type:
    
    ```bash
    ip -br address show  dev macvtap2
    ```
    
## Exercise 8

### Configure DNS Servers

#### To set DNS server addresses for the system

1. Configure DNS servers for `macvtap1`
    
    ```bash
    nmcli con mod macvtap1 ipv4.dns 8.8.8.8, 8.8.4.4
    ```
    
2. Verify the DNS server configuration
    
    ```bash
    nmcli con show macvtap1 | grep DNS
    ```
    
## Exercise 9

### Troubleshoot network issues

#### To Identify and troubleshoot common network issues

1. Check the status of network interfaces
    
    ```bash
    ip link show
    ```
    
2. Test network connectivity to a remote host (e.g., google.com)
    
    ```bash
    ping google.com
    ```
    
3. Try pinging the local gateway. Type:
    
    ```
    ping 172.16.99.1
    ```
    
### View Active Connections

#### To List all active network connections

1. List all active network connections

    ```bash
    ss -tuln
    ```

### Monitor Network Traffic

#### To monitor network traffic in real-time

1. Capture network traffic on a specific interface (e.g., `macvtap1`)

    ```bash
    tcpdump -i macvtap1
    ```
    
    Analyze captured packets and observe network activity. You can stop the packet capture when done by pressing (Ctrl + C)
    
### View Network Logs

#### To view NetworkManager daemon related logs for troubleshooting

1.  View network-related logs

    ```bash
    journalctl -u NetworkManager
    ```
