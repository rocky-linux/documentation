---
title: nmcli - Set Connection Autoconnect
author: wale soyinka
tags:
  - nmcli
---

# Modify NetworkManager connection profile autoconnect property

First use nmcli to query and display the current value of the autoconnect property for all network connections on a Rocky Linux system. Type:

```
nmcli -f name,autoconnect connection 
```

To change the value of a property for a network connection use the `modify` sub-command with `nmcli connection`. 
For example, to change the autoconnect property value from `no` to `yes` for the `ens3` connection profile, type:

```
sudo nmcli con mod ens3 connection.autoconnect yes
```

## Commands Explained

```
connection (con)       : NetworkManager connection object. 
modify (mod)           : Modify one or more properties of a given connection profile.
connection.autoconnect : The setting and property (<setting>.<property>)
-f, --fields           : specify fields to output.

```

## Notes

This tip shows how to modify an existing NetworkManager connection profile. This is useful when the network interface does not automatically get activated after a fresh Rocky Linux installation or system update. 
The reason for this is often because the value of autoconnect property is set to `no`. You can use the `nmcli` command to quickly change the value to `yes`.  
