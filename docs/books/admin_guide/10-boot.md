---
title: System Startup
---

# System Startup

In this chapter you will learn how the system start.

****
**Objectives**: In this chapter, future Linux administrators will learn:

:heavy_check_mark: The different stages of the booting process;   
:heavy_check_mark: How Rocky Linux supports this boot by using GRUB2 and systemd;   
:heavy_check_mark: How to protect GRUB2 from an attack;   
:heavy_check_mark: How to manage the services;   
:heavy_check_mark: How to access to the logs from `journald`.

:checkered_flag: **users**

**Knowledge**: :star: :star:   
**Complexity**: :star: :star: :star:   

**Reading time**: 20 minutes
****

## The boot process

It is important to understand the boot process of Linux in order to be able to solve problems that may occur.

The boot process includes:

### The BIOS startup

The **BIOS** (Basic Input/Output System) performs the **POST** (power on self-test) to detect, test and initialize the system hardware components.

It then loads the **MBR** (Master Boot Record).

### The Master boot record (MBR)

The Master Boot Record is the first 512 bytes of the boot disk. The MBR discovers the boot device and loads the bootloader **GRUB2** into memory and transfers control to it.

The next 64 bytes contain the partition table of the disk.

### The GRUB2 bootloader

The default bootloader for the Rocky 8 distribution is **GRUB2** (GRand Unified Bootloader). GRUB2 replaces the old GRUB bootloader (also called GRUB legacy).

The GRUB 2 configuration file is located under `/boot/grub2/grub.cfg` but this file should not be edited directly.

The GRUB2 menu configuration settings are located under `/etc/default/grub` and are used to generate the `grub.cfg` file.

```
# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/swap crashkernel=auto rd.lvm.lv=rhel/root rhgb quiet net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
```

If changes are made to one or more of these parameters, the `grub2-mkconfig` command must be run to regenerate the `/boot/grub2/grub.cfg` file.

```
[root] # grub2-mkconfig –o /boot/grub2/grub.cfg
```

* GRUB2 looks for the compressed kernel image (the `vmlinuz` file) in the `/boot` directory.
* GRUB2 loads the kernel image into memory and extracts the contents of the `initramfs` image file into a temporary folder in memory using the `tmpfs` file system.

### The kernel

The kernel starts the `systemd` process with PID 1.
```
root          1      0  0 02:10 ?        00:00:02 /usr/lib/systemd/systemd --switched-root --system --deserialize 23
```

### `systemd`

Systemd is the parent of all system processes. It reads the target of the `/etc/systemd/system/default.target` link (e.g., `/usr/lib/systemd/system/multi-user.target`) to determine the default target of the system. The file defines the services to be started.

Systemd then places the system in the target-defined state by performing the following initialization tasks:

1. Set the machine name
2. Initialize the network
3. Initialize SELinux
4. Display the welcome banner
5. Initialize the hardware based on the arguments given to the kernel at boot time
6. Mount the file systems, including virtual file systems like /proc
7. Clean up directories in /var
8. Start the virtual memory (swap)

## Protecting the GRUB2 bootloader

Why protect the bootloader with a password?

1. Prevent *Single* user mode access - If an attacker can boot into single user mode, he becomes the root user.
2. Prevent access to GRUB console - If an attacker manages to use GRUB console, he can change its configuration or collect information about the system by using the `cat` command.
3. Prevent access to insecure operating systems. If there is a dual boot on the system, an attacker can select an operating system like DOS at boot time that ignores access controls and file permissions.

To password protect the GRUB2 bootloader:

* Remove `-unrestricted` from the main `CLASS=` statement in the `/etc/grub.d/10_linux` file.

* If a user has not yet been configured, use the `grub2-setpassword` command to provide a password for the root user:

```
# grub2-setpassword
```

A `/boot/grub2/user.cfg` file will be created if it was not already present. It contains the hashed password of the GRUB2.

!!! Note

    This command only supports configurations with a single root user.

```
[root]# cat /boot/grub2/user.cfg
GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.CC6F56....A21
```

* Recreate the configuration file with the `grub2-mkconfig` command:

```
[root]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-327.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-327.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-f9725b0c842348ce9e0bc81968cf7181
Found initrd image: /boot/initramfs-0-rescue-f9725b0c842348ce9e0bc81968cf7181.img
done
```

* Restart the server and check.

All entries defined in the GRUB menu will now require a user and password to be entered at each boot. The system will not boot a kernel without direct user intervention from the console.

* When the user is requested, enter `root`;
* When a password is requested, enter the password provided at the `grub2-setpassword` command.

To protect only the editing of GRUB menu entries and access to the console, the execution of the `grub2-setpassword` command is sufficient. There may be cases where you have good reasons for doing only that. This might be particularly true in a remote data center where entering a password each time a server is rebooted is either difficult or impossible to do.

## Systemd

*Systemd* is a service manager for the Linux operating systems.

It is developed to:

* remain compatible with older SysV initialization scripts,
* provide many features, such as parallel start of system services at system startup, on-demand activation of daemons, support for snapshots, or management of dependencies between services.

!!! Note

    Systemd is the default initialization system since RedHat/CentOS 7.

Systemd introduces the concept of unit files, also known as systemd units.

| Type         | File extension | Functionality                              |
|--------------|----------------|------------------------------------------|
| Service unit | `.service`       | System service                           |
| Target unit  | `.target`        | A group of systemd units                 |
| Mount unit   | `.automount`     | An automatic mount point for file system |

!!! Note

    There are many types of units: Device unit, Mount unit, Path unit, Scope unit, Slice unit, Snapshot unit, Socket unit, Swap unit, Timer unit.

* Systemd supports system state snapshots and restore.

* Mount points can be configured as systemd targets.

* At startup, systemd creates listening sockets for all system services that support this type of activation and passes these sockets to these services as soon as they are started. This makes it possible to restart a service without losing a single message sent to it by the network during its unavailability. The corresponding socket remains accessible and all messages are queued.

* System services that use D-BUS for their inter-process communications can be started on demand the first time they are used by a client.

* Systemd stops or restarts only running services. Previous versions (before RHEL7) attempted to stop services directly without checking their current status.

* System services do not inherit any context (like HOME and PATH environment variables). Each service operates in its own execution context.

All service unit operations are subject to a default timeout of 5 minutes to prevent a malfunctioning service from freezing the system.

### Managing system services

Service units end with the `.service` file extension and have a similar purpose to init scripts. The `systemctl` command is used to `display`, `start`, `stop`, `restart` a system service:

| systemctl                                 | Description                             |
|-------------------------------------------|-----------------------------------------|
| systemctl start _name_.service            | Start a service                         |
| systemctl stop _name_.service             | Stops a service                         |
| systemctl restart _name_.service          | Restart a service                       |
| systemctl reload _name_.service           | Reload a configuration                  |
| systemctl status _name_.service           | Checks if a service is running          |
| systemctl try-restart _name_.service      | Restart a service only if it is running |
| systemctl list-units --type service --all | Display the status of all services      |

The `systemctl` command is also used for the `enable` or `disable` of system a service and displaying associated services:

| systemctl                                | Description                                             |
|------------------------------------------|---------------------------------------------------------|
| systemctl enable _name_.service            | Activate a service                                      |
| systemctl disable _name_.service           | Disable a service                                       |
| systemctl list-unit-files --type service | Lists all services and checks if they are running       |
| systemctl list-dependencies --after      | Lists the services that start before the specified unit |
| systemctl list-dependencies --before     | Lists the services that start after the specified unit  |

Examples:

```
systemctl stop nfs-server.service
# or
systemctl stop nfs-server
```

To list all units currently loaded:

```
systemctl list-units --type service
```

To list all units to check if they are activated:

```
systemctl list-unit-files --type service
```

```
systemctl enable httpd.service
systemctl disable bluetooth.service
```

### Example of a .service file for the postfix service

```
postfix.service Unit File
What follows is the content of the /usr/lib/systemd/system/postfix.service unit file as currently provided by the postfix package:

[Unit]
Description=Postfix Mail Transport Agent
After=syslog.target network.target
Conflicts=sendmail.service exim.service

[Service]
Type=forking
PIDFile=/var/spool/postfix/pid/master.pid
EnvironmentFile=-/etc/sysconfig/network
ExecStartPre=-/usr/libexec/postfix/aliasesdb
ExecStartPre=-/usr/libexec/postfix/chroot-update
ExecStart=/usr/sbin/postfix start
ExecReload=/usr/sbin/postfix reload
ExecStop=/usr/sbin/postfix stop

[Install]
WantedBy=multi-user.target
```

### Using system targets

On Rocky8/RHEL8, the concept of run levels has been replaced by Systemd targets.

Systemd targets are represented by target units. Target units end with the `.target` file extension and their sole purpose is to group other Systemd units into a chain of dependencies.

For example, the `graphical.target` unit, which is used to start a graphical session, starts system services such as the **GNOME display manager** (`gdm.service`) or the **accounts service** (`accounts-daemon.service`) and also activates the `multi-user.target` unit.

Similarly, the `multi-user.target` unit starts other essential system services, such as **NetworkManager** (`NetworkManager.service`) or **D-Bus** (`dbus.service`) and activates another target unit named `basic.target`.

| Target Units      | Description                                               |
|-------------------|-----------------------------------------------------------|
| poweroff.target   | Shuts down the system and turns it off                    |
| rescue.target     | Activates a rescue shell                                  |
| multi-user.target | Activates a multi-user system without graphical interface |
| graphical.target  | Activates a multi-user system with graphical interface    |
| reboot.target     | Shuts down and restarts the system                        |

#### The default target

To determine which target is used by default:

```
systemctl get-default
```

This command searches for the target of the symbolic link located at `/etc/systemd/system/default.target` and displays the result.

```
$ systemctl get-default
graphical.target
```

The `systemctl` command can also provide a list of available targets:

```
systemctl list-units --type target
UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
basic.target           loaded active active Basic System
bluetooth.target       loaded active active Bluetooth
cryptsetup.target      loaded active active Encrypted Volumes
getty.target           loaded active active Login Prompts
graphical.target       loaded active active Graphical Interface
local-fs-pre.target    loaded active active Local File Systems (Pre)
local-fs.target        loaded active active Local File Systems
multi-user.target      loaded active active Multi-User System
network-online.target  loaded active active Network is Online
network.target         loaded active active Network
nss-user-lookup.target loaded active active User and Group Name Lookups
paths.target           loaded active active Paths
remote-fs.target       loaded active active Remote File Systems
slices.target          loaded active active Slices
sockets.target         loaded active active Sockets
sound.target           loaded active active Sound Card
swap.target            loaded active active Swap
sysinit.target         loaded active active System Initialization
timers.target          loaded active active Timers
```

To configure the system to use a different default target:

```
systemctl set-default name.target
```

Example:

```
# systemctl set-default multi-user.target
rm '/etc/systemd/system/default.target'
ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
```

To switch to a different target unit in the current session:

```
systemctl isolate name.target
```

The **Rescue mode** provides a simple environment to repair your system in cases where it is impossible to perform a normal boot process.

In `rescue mode`, the system attempts to mount all local file systems and start several important system services, but does not enable a network interface or allow other users to connect to the system at the same time.

On Rocky 8, the `rescue mode` is equivalent to the old `single user mode` and requires the root password.

To change the current target and enter `rescue mode` in the current session:

```
systemctl rescue
```

**Emergency mode** provides the most minimalist environment possible and allows the system to be repaired even in situations where the system is unable to enter rescue mode. In the emergency mode, the system mounts the root file system only for reading. It will not attempt to mount any other local file system, will not activate any network interface, and will start some essential services.

To change the current target and enter emergency mode in the current session:

```
systemctl emergency
```

#### Shutdown, suspension and hibernation

The `systemctl` command replaces a number of power management commands used in previous versions:

|Old command          | New command              | Description            |
|---------------------|--------------------------|------------------------|
| `halt`              | `systemctl halt`         |Shuts down the system.  |
| `poweroff`          | `systemctl poweroff`     |Turns off the system.   |
| `reboot`            | `systemctl reboot`       |Restarts the system.    |
| `pm-suspend`        | `systemctl suspend`      |Suspends the system.    |
| `pm-hibernate`      | `systemctl hibernate`    |Hibernates the system.  |
| `pm-suspend-hybrid` | `systemctl hybrid-sleep` |Hibernates and suspends the system.|

### The `journald` process

Log files can, in addition to `rsyslogd`, also be managed by the `journald` daemon which is a component of `systemd`.

The `journald` daemon captures Syslog messages, kernel log messages, messages from the initial RAM disk and from the start of boot, as well as messages written to the standard output and the standard error output of all services, then indexes them and makes them available to the user.

The format of the native log file, which is a structured and indexed binary file, improves searches and allows for faster operation, it also stores metadata information, such as timestamps or user IDs.

### `journalctl` command

The `journalctl` command displays the log files.

```
journalctl
```

The command lists all log files generated on the system. The structure of this output is similar to that used in `/var/log/messages/` but it offers some improvements:

* the priority of entries is marked visually;
* timestamps are converted to the local time zone of your system;
* all logged data is displayed, including rotating logs;
* the beginning of a start is marked with a special line.

#### Using continuous display

With continuous display, log messages are displayed in real time.

```
journalctl -f
```

This command returns a list of the ten most recent log lines. The journalctl utility then continues to run and waits for new changes to occur before displaying them immediately.

#### Filtering messages

It is possible to use different filtering methods to extract information that fits different needs. Log messages are often used to track erroneous behavior on the system. To view entries with a selected or higher priority:

```
journalctl -p priority
```

You must replace priority with one of the following keywords (or a number):

* debug (7),
* info (6),
* notice (5),
* warning (4),
* err (3),
* crit (2),
* alert (1),
* and emerg (0).
