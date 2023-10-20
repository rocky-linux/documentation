---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova 
tested on: All versions
tags:
  - lab exercises
  - bootup, target and service management
  - systemd
  - systemctl
---


# Lab 3: Boot and Startup processes


## Objectives 


After completing this lab, you will be able to 

- manually control some startup processes and services 
- automatically control services 


Estimated time to complete this lab: 50 minutes 


## Boot process overview

The exercises in this lab will begin from the booting-up process down to the logging in of the user. These steps will examine and try to customize parts of the boot-up processes. The high-level steps in the boot process are: 

*Summary Of Steps*

1. The Hardware loads, reads and executes the boot sector.  
2. The bootloader is executed. This bootloader is GRUB on most Linux distros.  
3. kernel unpacks and is executed.  
4. kernel initializes hardware.  
5. kernel mounts root file system.  
6. kernel executes /usr/lib/systemd/systemd as PID 1.  
7. systemd starts the units needed and configured to run the default boot target.
8. getty programs are spawned on each defined terminal.  
9. getty prompts for login.  
10. getty executes /bin/login to authentic user.  
11. login starts shell.


### `systemd`

systemd is a system and service manager for Linux operating systems.

### `systemd` units 

`systemd` provides a dependency system between various entities called "units". Units encapsulate various objects that are needed for system boot-up and maintenance. Most units are configured in so-called unit configuration files - plain text ini-style files.

### Types of `systemd` units

`systemd` has the following 11 unit types defined:

*Service units* start and control daemons and the processes they consist of.

*Socket units* encapsulate local IPC or network sockets in the system, useful for socket-based activation.

*Target units* are used for grouping other units. They provide well-known synchronization points during boot-up

*Device units* expose kernel devices in systemd and may be used to implement device-based activation.

*Mount units* control mount points in the file system

*Automount units* provide automount capabilities, for on-demand mounting of file systems as well as parallelized boot-up. 

*Timer units* are useful for triggering activation of other units based on timers.

*Swap units* are very similar to mount units and encapsulate memory swap partitions or files of the operating system.

*Path units* may be used to activate other services when file system objects change or are modified.

*Slice units* may be used to group units which manage system processes (such as service and scope units) in a hierarchical tree for resource management purposes.

*Scope units* are similar to service units, but manage foreign processes instead of starting them as well.

## Exercise 1

### /usr/lib/systemd/systemd | PID=1 

Historically init has been called many names and has taken several forms. 

Regardless of its name or implementation, init (or its equivalent) is often referred to as the *mother of all processes*. 

The man page for “init” refers to it as the parent of all processes. By convention, the kernel's first program or process to be executed always has a process ID of 1.
Once the first process runs, it then goes on to start other services, daemons, processes, programs and so on.

#### To explore the first system process

1. Log on to the system as any user. Query the /proc/<PID>/comm virtual file system path and find out the name of the process with the ID of 1. Type:

    ```bash
    [root@localhost ~]# cat /proc/1/comm

    systemd
    ```

2. Run the `ls` command to view the /proc/<PID>/exe virtual file system path and see the name and path to the executable behind the process with the ID of 1. Type:

    ```bash
    [root@localhost ~]# ls -l /proc/1/exe

    lrwxrwxrwx 1 root root 0 Oct  5 23:56 /proc/1/exe -> /usr/lib/systemd/systemd
    ```

3. Try using the `ps` command to find out the name of the process or program behind PID. Type:

    ```bash
    [root@localhost ~]# ps -p 1 -o comm=

    systemd
    ```
    
4. Use the `ps` command to view the full path and any command-line arguments of the process or program behind PID 1. Type:

    ```bash
    [root@localhost ~]# ps -p  1 -o args=
    
    /usr/lib/systemd/systemd --switched-root --system --deserialize 16
    ```
    
5. To check that the mother-of-all processes, traditionally referred to as init, is actually systemd, use `ls` to confirm that `init` is a symbolic link to the `systemd` binary. Type:
    
    ```bash
    [root@localhost ~]# ls -l /usr/sbin/init
    lrwxrwxrwx. 1 root root 22 Aug  8 15:33 /usr/sbin/init -> ../lib/systemd/systemd
    ```
    
6. Use the `pstree` command to show a tree-like view of the system processes. Type:
    
    ```bash
    [root@localhost ~]# pstree --show-pids
    
    ```
    
## Exercise 2

### `systemd` Targets (RUNLEVELS) 

`systemd` defines and relies on many different targets for managing the system. We'll focus on only 5 of the main targets in this exercise. The 5 main targets explored in this section are listed here:

1. poweroff.target
2. rescue.target
3. multi-user.target - Boots the system with full multi-user support with no graphical environment.
4. graphical.target - Boots the system with network, multi-user support, and a display manager. 
5. reboot.target 

!!! Tip

    Target units replace SysV runlevels in the classic SysV init system.

#### To manage systemd targets

1. List ALL (active + inactive + failed) available targets on the server.
       
    ```bash
    [root@localhost ~]# systemctl list-units --type target --all
    ```

2. List only the currently active targets. Type:
    
    ```bash
    [root@localhost ~]# systemctl list-units -t target    
    ```
    
3. Use the `systemctl` command to view/get the name of the default target that the system is configured to boot into. Type:
     
    ```bash
    [root@localhost ~]# systemctl get-default
    
    multi-user.target
    ```
    
4. View the contents of unit file for the default target (multi-user.target). Type: 
   
    ```bash
    [root@localhost ~]# systemctl cat multi-user.target
    
    # /usr/lib/systemd/system/multi-user.target
    ........
    [Unit]
    Description=Multi-User System
    Documentation=man:systemd.special(7)
    Requires=basic.target
    Conflicts=rescue.service rescue.target
    After=basic.target rescue.service rescue.target
    AllowIsolate=yes
    ```
    
    Note some properties and their values configured in the `multi-user.target` unit. Properties like - Description, Documentation, Requires, After, and so on.
    
5. The `basic.target` unit is listed as the value of the `Requires` property for `multi-user.target`. View the unit file for basic.target. Type:
    
    ```bash
    [root@localhost ~]# systemctl cat multi-user.target
    # /usr/lib/systemd/system/basic.target
    [Unit]
    Description=Basic System
    Documentation=man:systemd.special(7)
    Requires=sysinit.target
    Wants=sockets.target timers.target paths.target slices.target
    After=sysinit.target sockets.target paths.target slices.target tmp.mount
    RequiresMountsFor=/var /var/tmp
    ```
    
6. The `systemctl cat` command only shows a subset of the properties and values of a given unit. To view a dump of ALL the properties and values of the target unit, use the show subcommand. The `show` command will also display the low-level properties. Show ALL the properties of multi-user.target, type:
   
    ```bash
    [root@localhost ~]# systemctl show  multi-user.target
    ```
   
7. Filter out the Id, Requires and Description properties from the long list of properties in the multi-user.target unit. Type:
   
    ```bash
    [root@localhost ~]# systemctl --no-pager show \
    --property  Id,Requires,Description  multi-user.target

    Id=multi-user.target
    Requires=basic.target
    Description=Multi-User System
    ```

8. View the services and resources that the multi-user.target pulls in when it starts. In other words, display what multi-user.target "Wants". Type:   
   
    ```bash
    [root@localhost ~]# systemctl show --no-pager -p "Wants"  multi-user.target
    
    Wants=irqbalance.service sshd.service.....
    ...<SNIP>...
    ```
    
9.  Use `ls` and `file` commands to learn more about the relationship of the traditional `init` program to the `systemd` program. Type:
   
    ```bash
    [root@localhost ~]# ls -l /usr/sbin/init && file /usr/sbin/init
    
    lrwxrwxrwx. 1 root root 22 Aug  8 15:33 /usr/sbin/init -> ../lib/systemd/systemd
    /usr/sbin/init: symbolic link to ../lib/systemd/systemd
    ```
    
#### To change the default boot target


1. Set/change the default target that the system boots into. Use the `systemctl set-default` command to change the default target to `graphical.target`. Type:
    
    ```bash
    [root@localhost ~]# systemctl set-default graphical.target
    
    ```

2. Check if the newly set boot target is active. Type:
    
    ```bash
    [root@localhost ~]# systemctl is-active graphical.target

    inactive
    ```

    Note that the output shows the target is *not* active even though it was set as the default!

3. To force the system to immediately switch to, and use a given target, you have to use the `isolate` sub command. Type:
    
    ```bash
    [root@localhost ~]# systemctl isolate graphical.target
    ```

    !!! Warning
        
        The systemctl isolate command can be dangerous if used wrongly. This is because it will immediately stop processes not enabled in the new target, possibly including the graphical environment or terminal you currently use!
    
4. Check again if `graphical.target` is now in use and is active.

5. Query for and view what other services or resources the graphical.target "Wants".
    
    !!! Question
    
        What are the main differences between multi-user.target and graphical.target "Wants"?
    
6. Because your system is running a server class operating system spin, where a full-fledged graphical desktop environment may not be desirable, switch the system back to the more suitable multi-user.target. Type:
    
    ```bash
    [root@localhost ~]# systemctl isolate multi-user
    
    ```

7.  Set/change the default system boot up target back to multi-user.target.
   
8.  Run a quick [and extra] manual check to see what target the default.target symlink points to, by running:
    
    ```bash
    [root@localhost ~]# ls -l /etc/systemd/system/default.target
    ```
    
## Exercise 3 

The exercises in this section will show you how to configure system/user processes and daemons (aka services) that may need to be automatically started up with the system. 

### To view service status

1. While logged in as root, list all the systemd units that have a type of service. Type:
    
    ```bash
    root@localhost ~]# systemctl list-units -t service -all
    ```
    
    This will show the complete list of active and loaded but inactive units.
    
2. View the list of active systemd units that have a type of service. 
    
    ```bash
    [root@localhost ~]# systemctl list-units --state=active --type service
    UNIT                LOAD   ACTIVE SUB     DESCRIPTION
    atd.service         loaded active running Job spooling tools
    auditd.service      loaded active running Security Auditing Service
    chronyd.service     loaded active running NTP client/server
    crond.service       loaded active running Command Scheduler
    dbus.service        loaded active running D-Bus System Message Bus
    firewalld.service   loaded active running firewalld - dynamic firewall daemon
    ...<SNIP>...
    ```

3. Narrow down and learn more about the configuration of one of the services in the previous output, the *crond.service*. Type:  
    
    ```bash
    [root@localhost ~]# systemctl cat crond.service
    ```

4. Check if `crond.service` is configured to automatically start-up when the system boots. Type:
    
    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service
    
    enabled
    ```
    
5. View the real-time status of the `crond.service` service. Type:
    
    ```bash
    [root@localhost ~]# systemctl  status  crond.service  
    ```
    
   The output will include the most recent 10 journal lines/entries/logs by default.

6. View the status of `crond.service` and suppress showing any journal lines. Type:
    
    ```bash
    [root@localhost ~]# systemctl -n 0  status  crond.service  
    ```
    
7. View the status of sshd.service.

    !!! Question
    
        View the status of `firewalld.service`. What is the `firewalld.service` unit?
    
### To stop services

1. While still logged in as a user with Administrative privileges, use the `pgrep` command to see if the `crond` process appears in the list of processes running on the system. 
    
    ```bash
    [root@localhost ~]# pgrep  -a crond
    
    313274 /usr/sbin/crond -n
    ```
    
    If it finds a matching process name, the `pgrep` command should find and list the PID of `crond`.
    
2. Use `systemctl` to stop the `crond.service` unit. Type:
    
    ```bash
    [root@localhost ~]# systemctl stop crond.service
    ```

    The command should complete without any output.
    
3. Using `systemctl`, view the status of `crond.service` to see the effect of your change.

4. Use `pgrep` again to see if the crond process still appears in the list of processes.

### To start services

1. Login as Administrative user account. Use the `pgrep` command to see if a `crond` process appears in the list of processes running on the system. 
    
    ```bash
    [root@localhost ~]# pgrep  -a crond
    ```
    
    If `pgrep` finds a matching process name, it will list the PID of `crond`. 
    
2. Use `systemctl` to start the `crond.service` unit. Type:
    
    ```bash
    [root@localhost ~]# systemctl start crond.service
    ```
    
    The command should complete without any output or visible feedback.
    
3. Using `systemctl`, view the status of `crond.service` to see the effect of your change. Type:
    
    ```bash
    [root@localhost ~]# systemctl -n 0 status crond.service
    
    ● crond.service - Command Scheduler
    Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; vendor preset: enabled)
    Active: active (running) since Mon 2023-10-16 11:38:04 EDT; 54s ago
    Main PID: 313451 (crond)
        Tasks: 1 (limit: 48282)
    Memory: 1000.0K
    CGroup: /system.slice/crond.service
            └─313451 /usr/sbin/crond -n
    ```
    
    !!! Question
    
        From the output of the `systemctl` status command on your system, what is the PID of `crond`?

4. Similarly use `pgrep` again to see if the `crond` process now appears in the list of processes. Compare the PID displayed by pgrep with the PID shown in the previous `systemctl` status `crond.service`.
    
    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service
    
    enabled
    ```
    
### To restart services

For many services/daemons, restarting or reloading the running service/daemon whenever changes are made to their underlying configuration files is often necessary. This is so that the given process/service/daemon can apply the latest configuration changes.

1. View the status of crond.service. Type:
    
    ```bash
    [root@localhost ~]# systemctl -n 0 status crond.service
    ```
    
    Make a note of the PID for crond in the output.
    
2. Run `systemctl restart` to restart `crond.service`. Type:
    
    ```bash
    [root@localhost ~]# systemctl -n 0 status crond.service
    ```

    The command should complete without any output or visible feedback.
    
3. Check for the status of `crond.service` again. Compare the latest PID with the PID that you noted in Step 1. 
    
4. Use `systemctl` to check if `crond.service` is currently active. Type:
    
    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    active
    ```
    
    !!! Question
    
        Why do you think the PIDs are different everytime you restart a service?
    
    
    !!! Tip
    
        The functionality of the good old classic service command has been ported over to seamlessly work on systemd managed systems. You can use service commands like the following to stop, start, restart and view status of the `smartd` service.
        
        ```bash
        # service smartd status
        
        # service smartd stop
        
        # service smartd start
        
        # service smartd restart
        ```
    
### To disable a service

1. Use `systemctl` to check whether the `crond.service` is enabled to start with system boot automatically. Type: 
    
    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service
    
    enabled
    ```
    
    The sample output shows it is.
    
2. Disable the `crond.service` from automatic startup. Type: 
    
    ```bash
    [root@localhost ~]# systemctl disable crond.service
    Removed /etc/systemd/system/multi-user.target.wants/crond.service.
    ```
    
3. Run the `systemctl is-enabled` command again to view the effect of your changes.
    
    !!! Question
    
        On a server that you need to manage remotely, why would you NOT want to disable a service like `sshd.service` from automatic start-up with system boots?
    
### To ensure disabling (i.e. mask) a service 

Even though the `systemctl disable` command can be used to disable services as you saw in the previous exercises, other systemd units (processes, services , daemons and so on) can stealthily re-enable a disabled service if needed. This can happen when a service depends on another [disabled] service.

To ensure disabling of a systemd service unit and prevent accidental reactivation, you should mask the service.

1. Use `systemctl` to mask the `crond.service` and prevent any undesired reactivation, type:
    
    ```bash
    [root@localhost ~]# systemctl mask crond.service
    
    Created symlink /etc/systemd/system/crond.service → /dev/null.
    ```
    
2. Run the `systemctl is-enabled` command to view the effect of your changes. 
    
    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service
    
    masked
    ```
    
3. To undo your changes and unmask `crond.service`, use the `systemctl unmask` command by running:
    
    ```bash
    [root@localhost ~]# systemctl unmask crond.service
    
    Removed /etc/systemd/system/crond.service.
    ```
    
### To enable a service

1. Use `systemctl` to check the status of `crond.service` unit. Type:
    
    ```bash
    [root@localhost ~]# systemctl status crond.service
    ```
    
    The service should still be in a stopped state.
    
2. Use the `systemctl enable` command to enable `crond.service` for automatic startup. Type:
    
    ```bash
    [root@localhost ~]# systemctl enable crond.service
    
    Created symlink /etc/systemd/system/multi-user.target.wants/crond.service → /usr/lib/systemd/system/crond.service.
    ```
    
3. Again use `systemctl` to check if `crond.service` is active. Type:
    
    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    inactive
    ```
    
    !!! Question
    
        You just enabled `crond.service`. Why is it not running or not listed as being active in the previous command?
    
4. Use a slightly different variant of the `systemctl enable` command to enable `crond.service` and immediately start the daemon running. Type:
    
    ```bash
    [root@localhost ~]# systemctl --now enable crond.service
    ```
    
5. Check if `crond.service` is now active. Type:
    
    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    active
    ```
    
6. Using `systemctl`, ensure that the `crond.service` is started, running and enabled for automatic start-up.
