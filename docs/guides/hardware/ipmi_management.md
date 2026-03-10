---
title: IPMI management
author: Howard Van Der Wal
contributors: Steven Spencer
ai_contributors: Claude (claude-sonnet-4-6)
tested with: 8, 9, 10
tags:
- bmc
- hardware
- ipmi
- management
- server
---

**Knowledge**: :star: :star: :star:

**Reading time**: 20 minutes

## AI usage

This document adheres to the [AI contribution policy found here.](../contribute/ai-contribution-policy.md) If you find any errors in the instructions, please let us know.

## Introduction

The Intelligent Platform Management Interface (IPMI) is an open standard for monitoring and managing server hardware independently of the operating system^1^. IPMI communicates with the Baseboard Management Controller (BMC), a dedicated microcontroller embedded on the server motherboard. The BMC operates with its own firmware, network connection, and power supply, allowing administrators to monitor hardware health, control power states, and access a remote console even when the host operating system is unresponsive or powered off^2^.

This guide covers installing and configuring IPMI tools on Rocky Linux, performing common management operations both locally and remotely, and troubleshooting the most frequent issues administrators encounter.

## Prerequisites

- A system running Rocky Linux 8, 9, or 10 with BMC/IPMI-capable hardware (most rack and tower servers from Dell, HPE, Supermicro, and Lenovo etc include a BMC).

- Root or `sudo` access on the Rocky Linux host.

- Network access to the BMC management interface (for remote operations).

- The `ipmitool` or `freeipmi` packages (installation is covered below).

## Installing IPMI tools

Install `ipmitool` with `dnf`:

```bash
sudo dnf install ipmitool
```

Verify the installation:

```bash
ipmitool -V
```

## Loading IPMI kernel modules

Rocky Linux does not load IPMI kernel modules by default. Before you can use `ipmitool` locally, you must load the required modules.

!!! warning

    If the IPMI kernel modules are not loaded, `ipmitool` will fail with the error: `Could not open device at /dev/ipmi0 or /dev/ipmi/0 or /dev/ipmidev/0: No such file or directory`. This is the most common IPMI issue on Rocky Linux.

Load the three core IPMI modules:

```bash
sudo modprobe ipmi_msghandler
sudo modprobe ipmi_devintf
sudo modprobe ipmi_si
```

- `ipmi_msghandler` — the core IPMI message handler that provides the framework for IPMI communication^3^.
- `ipmi_devintf` — creates the `/dev/ipmi0` character device that user-space tools such as `ipmitool` use to communicate with the BMC^3^.
- `ipmi_si` — the system interface driver that communicates with the BMC over the KCS (Keyboard Controller Style), SMIC, or BT interfaces^3^.

Verify the modules loaded:

```bash
lsmod | grep ipmi
```

Expected output on a server with BMC hardware:

```text
ipmi_si                73728  0
ipmi_devintf           20480  0
ipmi_msghandler       106496  2 ipmi_devintf,ipmi_si
```

## Persisting IPMI modules across reboots

The modules loaded with `modprobe` do not survive a reboot. To load them automatically at boot, create a configuration file in `/etc/modules-load.d/`:

```bash
cat << "EOF" | sudo tee /etc/modules-load.d/ipmi.conf
ipmi_msghandler
ipmi_devintf
ipmi_si
EOF
```

After creating this file, the `systemd-modules-load` service will load these modules on every boot.

## Verifying the IPMI device

After loading the modules, verify that the `/dev/ipmi0` device exists:

```bash
ls -la /dev/ipmi*
```

Check the kernel ring buffer for IPMI-related messages:

```bash
dmesg | grep -i ipmi
```

On a server with BMC hardware, you will see messages indicating that the IPMI system interface was found and the device was registered.

Test connectivity to the BMC:

```bash
sudo ipmitool mc info
```

This displays the BMC firmware version, manufacturer, and other management controller details.

## Local and remote IPMI access

### Local access

Local access uses the `/dev/ipmi0` device to communicate directly with the BMC on the same machine:

```bash
sudo ipmitool <command>
```

### Remote access

Remote access connects to a BMC over the network using the IPMI LAN interface. This is useful for managing servers from a central management station or head node:

```bash
ipmitool -H <BMC_IP> -I lanplus -U <username> -P <password> <command>
```

- `-H` — the BMC IP address or hostname.
- `-I lanplus` — use the IPMI v2.0 RMCP+ (LAN Plus) interface, which provides authentication and encryption^1^.
- `-U` — the BMC username.
- `-P` — the BMC password.

!!! warning

    Passing passwords on the command line exposes them in process listings and shell history. For scripted or production use, consider the `-f` flag to read the password from a file, or use the `-E` flag to read the password from the `IPMI_PASSWORD` environment variable.

Example checking the power status of a remote server:

```bash
ipmitool -H 192.168.1.100 -I lanplus -U admin -P password chassis power status
```

## Common ipmitool operations

### Sensor readings

View all sensor data with thresholds:

```bash
sudo ipmitool sensor list
```

View the Sensor Data Repository (SDR) for a compact summary:

```bash
sudo ipmitool sdr
```

### Power control

```bash
sudo ipmitool chassis power status
sudo ipmitool chassis power on
sudo ipmitool chassis power off
sudo ipmitool chassis power cycle
sudo ipmitool chassis power reset
```

- `power cycle` — turns the server off and then on again (hard power cycle).
- `power reset` — performs a hardware reset without a full power cycle.

### Chassis status

```bash
sudo ipmitool chassis status
```

This displays the current power state, last power event, and miscellaneous chassis status flags.

### System Event Log (SEL)

The SEL records hardware events such as temperature threshold crossings, fan failures, and memory errors:

```bash
sudo ipmitool sel list
```

For a more detailed, human-readable output:

```bash
sudo ipmitool sel elist
```

To clear the SEL after reviewing events:

```bash
sudo ipmitool sel clear
```

!!! warning

    Only clear the SEL after you have reviewed and recorded any important events. Once cleared, the events cannot be recovered.

### Serial Over LAN (SOL)

SOL redirects the server's serial console over the IPMI LAN interface, giving you remote console access even when the network stack is not available:

```bash
ipmitool -H <BMC_IP> -I lanplus -U <username> -P <password> sol activate
```

To disconnect from the SOL session:

```bash
ipmitool -H <BMC_IP> -I lanplus -U <username> -P <password> sol deactivate
```

You can also press `~.` to terminate the SOL session from the client side.

### User management

List all users configured on BMC channel 1:

```bash
sudo ipmitool user list 1
```

## Troubleshooting missing /dev/ipmi0

This section addresses the most common issue: `ipmitool` failing because `/dev/ipmi0` does not exist.

### Step 1 — Check that the IPMI modules are loaded

```bash
lsmod | grep ipmi
```

If no output appears, load the modules as described in the Loading IPMI kernel modules section above.

### Step 2 — Check dmesg for errors

```bash
dmesg | grep -i ipmi
```

Look for messages such as:

- `ipmi_si: Unable to find any System Interface(s)` — this means the kernel could not detect a BMC. Verify that your hardware has a BMC and that IPMI is enabled in the BIOS/UEFI settings.
- `ipmi_si: Trying KCS-defined... success` — the interface was found successfully.

### Step 3 — Restart the IPMI service

If the OpenIPMI service is installed, restart it:

```bash
sudo systemctl restart ipmi
```

If the service does not exist, you can install it:

```bash
sudo dnf install OpenIPMI
sudo systemctl enable --now ipmi
```

### Step 4 — Verify BIOS/UEFI settings

If the modules load but no BMC is detected:

- Enter the BIOS/UEFI setup during boot.
- Navigate to the IPMI or BMC configuration section.
- Ensure that IPMI over KCS is enabled.
- Save changes and reboot.

!!! warning

    Virtual machines and cloud instances typically do not have physical BMC hardware. The IPMI modules will load, but `ipmitool` will report that no BMC is found. IPMI requires physical server hardware with an embedded BMC.

### Step 5 — Check for conflicting drivers

On some systems, the `ipmi_si` module may conflict with vendor-specific management drivers. If you see errors in `dmesg`, try unloading and reloading the modules:

```bash
sudo modprobe -r ipmi_si ipmi_devintf ipmi_msghandler
sudo modprobe ipmi_msghandler
sudo modprobe ipmi_devintf
sudo modprobe ipmi_si
```

## FreeIPMI as an alternative

FreeIPMI is an alternative IPMI implementation that provides its own set of command-line tools^4^. Some administrators prefer FreeIPMI for its detailed output formatting and additional features.

### Installation

```bash
sudo dnf install freeipmi
```

### Key FreeIPMI commands

| FreeIPMI command | ipmitool equivalent | Description |
| --- | --- | --- |
| `bmc-info` | `ipmitool mc info` | Display BMC information |
| `ipmi-sensors` | `ipmitool sensor list` | List all sensor readings |
| `ipmi-sel` | `ipmitool sel list` | Display the System Event Log |
| `ipmi-chassis --get-chassis-status` | `ipmitool chassis status` | Display chassis status |
| `ipmipower --stat` | `ipmitool chassis power status` | Check power status |
| `ipmipower --on` | `ipmitool chassis power on` | Power on the server |
| `ipmipower --off` | `ipmitool chassis power off` | Power off the server |

FreeIPMI tools also support remote access with the `-h`, `-u`, and `-p` flags:

```bash
bmc-info -h <BMC_IP> -u <username> -p <password>
```

## BMC firmware update considerations

!!! danger

    BMC firmware updates carry risk. A failed or interrupted firmware update can render the BMC unresponsive, potentially requiring a physical board replacement. Always follow your hardware vendor's instructions exactly.

General guidance for BMC firmware updates:

- Download firmware only from your server vendor's official support site (Dell, HPE, Supermicro, Lenovo).
- Read the release notes for the firmware version before applying the update.
- Ensure stable power throughout the update process. Use a UPS if available.
- Do not reboot or power off the server during the firmware update.
- Back up the current BMC configuration before updating, if your vendor's tools support this.

Most vendors provide their own BMC firmware update utilities:

- Dell: `racadm` or Dell EMC Repository Manager.
- HPE: `ilorest` or HPE Smart Update Manager.
- Supermicro: `sum` (Supermicro Update Manager) or web-based BMC interface.
- Lenovo: `OneCLI` or Lenovo XClarity.

## Conclusion

You now have a working IPMI configuration on Rocky Linux for managing server hardware locally and remotely. The key steps covered include loading and persisting the required kernel modules^3^, using `ipmitool` for common management tasks^1^, troubleshooting the most frequent `/dev/ipmi0` issues, and using FreeIPMI as an alternative^4^.

For deeper exploration of the IPMI specification and advanced features, refer to the Intel IPMI specification^1^ and the `ipmitool` manual page^2^.

## References

1. "Intelligent Platform Management Interface Specification, Second Generation, v2.0" by Intel Corporation [https://www.intel.com/content/dam/www/public/us/en/documents/product-briefs/ipmi-second-gen-interface-spec-v2-rev1-1.pdf](https://www.intel.com/content/dam/www/public/us/en/documents/product-briefs/ipmi-second-gen-interface-spec-v2-rev1-1.pdf)
2. "ipmitool — utility for controlling IPMI-enabled devices" by ipmitool contributors [https://github.com/ipmitool/ipmitool](https://github.com/ipmitool/ipmitool)
3. "IPMI — The Linux Kernel documentation" by the Linux Kernel community [https://www.kernel.org/doc/html/latest/driver-api/ipmi.html](https://www.kernel.org/doc/html/latest/driver-api/ipmi.html)
4. "FreeIPMI — GNU Project" by the Free Software Foundation [https://www.gnu.org/software/freeipmi/](https://www.gnu.org/software/freeipmi/)
