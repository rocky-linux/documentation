---
title: System Startup
---

# System Startup

In this chapter, you will learn how the system starts.

****
**Objectives**: In this chapter, future Linux administrators will learn:

:heavy_check_mark: The different stages of the booting process;  
:heavy_check_mark: How Rocky Linux supports this boot by using GRUB2 and `systemd`;  
:heavy_check_mark: How to protect GRUB2 from an attack;  
:heavy_check_mark: How to manage the services;  
:heavy_check_mark: How to access logs from `journald`.  

:checkered_flag: **users** .  

**Knowledge**: :star: :star:  
**Complexity**: :star: :star: :star:  

**Reading time**: 20 minutes
****

## The boot process

It is important to understand the boot process of Linux to be able to solve problems that might occur.

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

```bash
# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/swap crashkernel=auto rd.lvm.lv=rhel/root rhgb quiet net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
```

If changes are made to one or more of these parameters, the `grub2-mkconfig` command must be run to regenerate the `/boot/grub2/grub.cfg` file.

```bash
[root] # grub2-mkconfig –o /boot/grub2/grub.cfg
```

* GRUB2 looks for the compressed kernel image (the `vmlinuz` file) in the `/boot` directory.
* GRUB2 loads the kernel image into memory and extracts the contents of the `initramfs` image file into a temporary folder in memory using the `tmpfs` file system.

### The kernel

The kernel starts the `systemd` process with PID 1.

```bash
root          1      0  0 02:10 ?        00:00:02 /usr/lib/systemd/systemd --switched-root --system --deserialize 23
```

### `systemd`

`systemd` is the parent of all system processes. It reads the target of the `/etc/systemd/system/default.target` link (e.g., `/usr/lib/systemd/system/multi-user.target`) to determine the default target of the system. The file defines the services to start.

`systemd` then places the system in the target-defined state by performing the following initialization tasks:

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

1. Log in to the operating system as root user and execute the `grub2-mkpasswd-pbkdf2` command. The output of this command is as follows:

    ```bash
    Enter password:
    Reenter password:
    PBKDF2 hash of your password is grub.pbkdf2.sha512.10000.D0182EDB28164C19454FA94421D1ECD6309F076F1135A2E5BFE91A5088BD9EC87687FE14794BE7194F67EA39A8565E868A41C639572F6156900C81C08C1E8413.40F6981C22F1F81B32E45EC915F2AB6E2635D9A62C0BA67105A9B900D9F365860E84F1B92B2EF3AA0F83CECC68E13BA9F4174922877910F026DED961F6592BB7
    ```

    You need to enter your password in the interaction. The ciphertext of the password is the long string "grub.pbkdf2.sha512...".

2. Paste the password ciphertext in the last line of the  **/etc/grub.d/00_header** file. The pasted format is as follows:

    ```bash
    cat <<EOF
    set superusers='frank'
    password_obkdf2 frank grub.pbkdf2.sha512.10000.D0182EDB28164C19454FA94421D1ECD6309F076F1135A2E5BFE91A5088BD9EC87687FE14794BE7194F67EA39A8565E868A41C639572F6156900C81C08C1E8413.40F6981C22F1F81B32E45EC915F2AB6E2635D9A62C0BA67105A9B900D9F365860E84F1B92B2EF3AA0F83CECC68E13BA9F4174922877910F026DED961F6592BB7
    EOF
    ```

    You can replace the 'frank' user with any custom user.

    You can also set a plaintext password, for example:

    ```bash
    cat <<EOF
    set superusers='frank'
    password frank rockylinux8.x
    EOF
    ```

3. The final step is to execute the command `grub2-mkconfig -o /boot/grub2/grub.cfg` to update the settings of GRUB2.

4. Restart the operating system to verify the encryption of GRUB2. Select the first boot menu item and type the ++"e"++ key, and then enter the corresponding user and password.

    ```bash
    Enter username:
    frank
    Enter password:

    ```

    After successful verification, enter ++ctrl+"x"++ to start the operating system.

Sometimes you may see in some documents that the `grub2-set-password` (`grub2-setpassword`) command is used to protect the GRUB2 bootloader:

| command                 | Core functions                        | Configuration file modification method | automaticity |
|-------------------------|---------------------------------------|----------------------------------------|--------------|
| `grub2-set-password`    | Set password and update configuration | Auto Completion                        | high         |
| `grub2-mkpasswd-pbkdf2` | Only generate encrypted hash values   | Requires manual editing                | low          |

Log in to the operating system as the root user and execute the `gurb2-set-password` command as follows:

```bash
[root] # grub2-set-password
Enter password:
Confirm password:

[root] # cat /boot/grub2/user.cfg
GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.32E5BAF2C2723B0024C1541F444B8A3656E0A04429EC4BA234C8269AE022BD4690C884B59F344C3EC7F9AC1B51973D65F194D766D06ABA93432643FC94119F17.4E16DF72AA1412599EEA8E90D0F248F7399E45F34395670225172017FB99B61057FA64C1330E2EDC2EF1BA6499146400150CA476057A94957AB4251F5A898FC3

[root] # grub2-mkconfig -o /boot/grub2/grub.cfg

[root] # reboot
```

After executing the `grub2-set-password` command, the **/boot/grub2/user.cfg** file will be automatically generated.

Select the first boot menu item and type the ++"e"++ key, and then enter the corresponding user and password:

```bash
Enter username:
root
Enter password:

```

## Systemd

*Systemd* is a service manager for the Linux operating systems.

The development of `systemd` was to:

* remain compatible with older SysV initialization scripts,
* provide many features, such as parallel start of system services at system startup, on-demand activation of daemons, support for snapshots, or management of dependencies between services.

!!! Note

    `systemd` is the default initialization system since RedHat/CentOS 7.

`systemd` introduces the concept of unit files, also known as `systemd` units.

| Type         | File extension | Functionality                              |
|--------------|----------------|------------------------------------------|
| Service unit | `.service`       | System service                           |
| Target unit  | `.target`        | A group of systemd units                 |
| Mount unit   | `.automount`     | An automatic mount point for file system |

!!! Note

    There are many types of units: Device unit, Mount unit, Path unit, Scope unit, Slice unit, Snapshot unit, Socket unit, Swap unit, Timer unit.

* `systemd` supports system state snapshots and restore.

* You can configure mount points as `systemd` targets.

* At startup, `systemd` creates listening sockets for all system services that support this type of activation and passes these sockets to these services as soon as they start. This makes it possible to restart a service without losing a single message sent to it by the network during its unavailability. The corresponding socket remains accessible all messages queue up.

* System services that use D-BUS for their inter-process communications can start on-demand the first time the client uses them.

* `systemd` stops or restarts only running services. Previous versions (before RHEL7) attempted to stop services directly without checking their current status.

* System services do not inherit any context (like HOME and PATH environment variables). Each service operates in its own execution context.

All service unit operations are subject to a default timeout of 5 minutes to prevent a malfunctioning service from freezing the system.

Due to space limitations, this document will not provide a very detailed introduction to `systemd`. If you have an interest in exploring `systemd` further, there is a very detailed introduction in [this document](./16-about-sytemd.md),

### Managing system services

Service units end with the `.service` file extension and have a similar purpose to init scripts. The use of `systemctl` command is to `display`, `start`, `stop`, or `restart` a system service:

| systemctl                                 | Description                             |
|-------------------------------------------|-----------------------------------------|
| systemctl start *name*.service            | Starts a service                         |
| systemctl stop *name*.service             | Stops a service                         |
| systemctl restart *name*.service          | Restarts a service                       |
| systemctl reload *name*.service           | Reloads a configuration                  |
| systemctl status *name*.service           | Checks if a service is running          |
| systemctl try-restart *name*.service      | Restarts a service only if it is running |
| systemctl list-units --type service --all | Displays the status of all services      |

The `systemctl` command is also used for the `enable` or `disable` of system a service and displaying associated services:

| systemctl                                | Description                                             |
|------------------------------------------|---------------------------------------------------------|
| systemctl enable *name*.service            | Activates a service                                      |
| systemctl disable *name*.service           | Disables a service                                       |
| systemctl list-unit-files --type service | Lists all services and checks if they are running       |
| systemctl list-dependencies --after      | Lists the services that start before the specified unit |
| systemctl list-dependencies --before     | Lists the services that start after the specified unit  |

Examples:

```bash
systemctl stop nfs-server.service
# or
systemctl stop nfs-server
```

To list all units currently loaded:

```bash
systemctl list-units --type service
```

To check the activation status of all units, you can list them with:

```bash
systemctl list-unit-files --type service
```

```bash
systemctl enable httpd.service
systemctl disable bluetooth.service
```

### Example of a .service file for the postfix service

```bash
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

`systemd` targets replace the concept of run levels on Rocky8/RHEL8.

The representation of `systemd` targets is by target units. Target units end with the `.target` file extension and their sole purpose is to group other `systemd` units into a chain of dependencies.

For example, the `graphical.target` unit that starts a graphical session, starts system services such as the **GNOME display manager** (`gdm.service`) or the **accounts service** (`accounts-daemon.service`) and also activates the `multi-user.target` unit.

Similarly, the `multi-user.target` unit starts other essential system services, such as **NetworkManager** (`NetworkManager.service`) or **D-Bus** (`dbus.service`) and activates another target unit named `basic.target`.

| Target Units      | Description                                               |
|-------------------|-----------------------------------------------------------|
| poweroff.target   | Shuts down the system and turns it off                    |
| rescue.target     | Activates a rescue shell                                  |
| multi-user.target | Activates a multi-user system without graphical interface |
| graphical.target  | Activates a multi-user system with graphical interface    |
| reboot.target     | Shuts down and restarts the system                        |

#### The default target

To determine the default target used by default:

```bash
systemctl get-default
```

This command searches for the target of the symbolic link located at `/etc/systemd/system/default.target` and displays the result.

```bash
$ systemctl get-default
graphical.target
```

The `systemctl` command can also provide a list of available targets:

```bash
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

```bash
systemctl set-default name.target
```

Example:

```bash
# systemctl set-default multi-user.target
rm '/etc/systemd/system/default.target'
ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
```

To switch to a different target unit in the current session:

```bash
systemctl isolate name.target
```

The **Rescue mode** provides a simple environment to repair your system in cases where it is impossible to perform a normal boot process.

In `rescue mode`, the system attempts to mount all local file systems and start several important system services, but does not enable a network interface or allow other users to connect to the system at the same time.

On Rocky 8, the `rescue mode` is equivalent to the old `single user mode` and requires the root password.

To change the current target and enter `rescue mode` in the current session:

```bash
systemctl rescue
```

**Emergency mode** provides the most minimalist environment possible and allows the repairing of the system even in situations where the system is unable to enter rescue mode. In the emergency mode, the system mounts the root file system only for reading. It will not attempt to mount any other local file system, will not activate any network interface, and will start some essential services.

To change the current target and enter emergency mode in the current session:

```bash
systemctl emergency
```

#### Shutdown, suspension and hibernation

The `systemctl` command replaces many power management commands used in previous versions:

|Old command          | New command              | Description            |
|---------------------|--------------------------|------------------------|
| `halt`              | `systemctl halt`         |Shuts down the system.  |
| `poweroff`          | `systemctl poweroff`     |Turns off the system.   |
| `reboot`            | `systemctl reboot`       |Restarts the system.    |
| `pm-suspend`        | `systemctl suspend`      |Suspends the system.    |
| `pm-hibernate`      | `systemctl hibernate`    |Hibernates the system.  |
| `pm-suspend-hybrid` | `systemctl hybrid-sleep` |Hibernates and suspends the system.|

### The `journald` process

You can manage log files can, in addition to `rsyslogd`, with the `journald` daemon that is a component of `systemd`.

The `journald` daemon captures Syslog messages, kernel log messages, messages from the initial RAM disk and from the start of boot, and messages written to the standard output and the standard error output of all services, then indexes them and makes them available to the user.

The format of the native log file, which is a structured and indexed binary file, improves searches and allows for faster operation, it also stores metadata information, such as timestamps or user IDs.

### `journalctl` command

The `journalctl` command displays the log files.

```bash
journalctl
```

The command lists all log files generated on the system. The structure of this output is similar to that used in `/var/log/messages/` but it offers some improvements:

* shows the priority of entries is visually marked
* shows the conversion of timestamps to the local time zone of your system
* all logged data is displayed, including rotating logs
* shows the marking of the beginning of a start with a special line

#### Using continuous display

With continuous display, log messages are displayed in real time.

```bash
journalctl -f
```

This command returns a list of the ten most recent log lines. The `journalctl` utility then continues to run and waits for new changes to occur before displaying them immediately.

#### Filtering messages

It is possible to use different filtering methods to extract information that fits different needs. Log messages are often used to track erroneous behavior on the system. To view entries with a selected or higher priority:

```bash
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
