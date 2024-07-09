---
title: Systemd Harderning
author: Julian Patocki
tags:
    - security
    - systemd
    - capabilities
---

## Prerequisites

* Familiarity with command-line tools
* Basic understanding of systemd and file permissions
* Ability to read man pages

## Introduction

Many services run with privileges they do not really need to function properly. Systemd ships many tools that help to minimize the risk, when a process gets compromised by enforcing security measures and limiting permissions. 

## Objectives

* Improving the security of `systemd` units

## Disclaimer

This guide explains the mechanics of securing `systemd` units and does not cover the proper configuration of any particular unit. Some concepts are oversimplified; understanding them and some commands used requires a deeper dive into the topic.

## Resources

* [`SYSTEMD.EXEC(5)` man page](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html)
* [`Capabilities(7)` man page](https://man7.org/linux/man-pages/man7/capabilities.7.html)

## Analysis

Systemd comes with a great tool that gives a quick overview on overall security configuration of a `systemd` unit.
`systemd-analyze security` provides a quick overview of the security configuration of a `systemd` unit. Here's the score of a freshly installed `httpd`:

```
[user@rocky-vm ~]$ systemd-analyze security httpd
  NAME                                  DESCRIPTION                                                              EXPOSURE
✗ RootDirectory=/RootImage=             Service runs within the host's root directory                            0.1
  SupplementaryGroups=                  Service runs as root, option does not matter                                
  RemoveIPC=                            Service runs as root, option does not apply                                 
✗ User=/DynamicUser=                    Service runs as root user                                                0.4
✗ CapabilityBoundingSet=~CAP_SYS_TIME   Service processes may change the system clock                            0.2
✗ NoNewPrivileges=                      Service processes may acquire new privileges                             0.2
...
...
...
✓ NotifyAccess=                         Service child processes cannot alter service state                              
✓ PrivateMounts=                        Service cannot install system mounts                                            
✗ UMask=                                Files created by service are world-readable by default                   0.1

→ Overall exposure level for httpd.service: 9.2 UNSAFE 😨
```

## Capabilities

The concept of capabilities can be very confusing. Understanding it is crucial for improving the security of `systemd` units. Here's an excerpt from the `Capabilities(7)` man page:

```
For the purpose of performing permission checks, traditional UNIX implementations distinguish two categories of processes: privileged processes (whose effective user ID is 0, referred to as superuser or root), and unprivileged processes (whose effective UID is nonzero).  Privileged processes bypass all kernel permission checks, while  unprivileged  processes are subject to full permission checking based on the process's credentials (usually: effective UID, effective GID, and supplementary group list).

Starting  with  Linux 2.2, Linux divides the privileges traditionally associated with superuser into distinct units, known as capabilities, which can be independently enabled and disabled. Capabilities are a per-thread attribute.
```

Basically it means that capabilities can grant some of `root` privileges to unprivileged processes, but also limit the privileges of processes run by `root`. 

There are currently 41 capabilities. It means the privileges of the `root` user are divided into 41 sets of privileges. Here are a few examples:
* **CAP_CHOWN**: Make arbitrary changes to file UIDs and GIDs
* **CAP_KILL**: Bypass permission checks for sending signals
* **CAP_NET_BIND_SERVICE**: Bind a socket to Internet domain privileged ports (port numbers less than 1024)

The full list can be found in the `Capabilities(7)` man page.

There are two types of capabilities:
* File capabilities
* Thread capabilities

## File capabilities

File capabilities allow associating privileges with an executable, similar to `suid`. They are stored in an extended attribute and include three sets: `Permitted`, `Inheritable`, and `Effective`.

Please refer to the `Capabilities(7)` man page for a full explanation. 

File capabilities cannot affect the overall exposure level of a unit and are therefore only slightly relevant to this guide. Understanding them can be useful, though. Therefore a quick demonstration:

Let's try running `httpd` on the default (privileged) port 80 as an unprivileged user:

```bash
[user@rocky-vm ~]$ sudo -u apache /usr/sbin/httpd
(13)Permission denied: AH00072: make_sock: could not bind to address 0.0.0.0:80
no listening sockets available, shutting down
```

As expected, the operation fails. Let's equip the `httpd` binary with previously mentioned **CAP_NET_BIND_SERVICE** and **CAP_DAC_OVERRIDE** (to override file permission checks on log and pid files for the sake of this excercise) and try again:

```bash
[user@rocky-vm ~]$ sudo setcap "cap_net_bind_service=+ep cap_dac_override=+ep" /usr/sbin/httpd
[user@rocky-vm ~]$ sudo -u apache /usr/sbin/httpd
[user@rocky-vm ~]$ curl --head localhost
HTTP/1.1 403 Forbidden
...
```

As expected, the web server could be successfully started.

## Thread capabilities

Thread capabilities apply to a process and its children. There are five thread capability sets:
* Permitted
* Inheritable
* Effective
* Bounding
* Ambient

For full explanation refer to `Capabilities(7)` man page. 

We have already established that `httpd` does not need all the privileges available to the `root` user. Let's remove the previously granted capabilities from the `httpd` binary, start the `httpd` daemon and check its privileges:

```bash
[user@rocky-vm ~]$ sudo setcap -r /usr/sbin/httpd
[user@rocky-vm ~]$ sudo systemctl start httpd
[user@rocky-vm ~]$ grep Cap /proc/$(pgrep --uid 0 httpd)/status
CapInh: 0000000000000000
CapPrm: 000001ffffffffff
CapEff: 000001ffffffffff
CapBnd: 000001ffffffffff
CapAmb: 0000000000000000
[user@rocky-vm ~]$ capsh --decode=000001ffffffffff
0x000001ffffffffff=cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,cap_audit_read,cap_perfmon,cap_bpf,cap_checkpoint_restore
```

The main `httpd` process runs with all available capabilities, even though most of them are not required.

## Restricting capabilities

Systemd reduces the capability sets to the following:
* **CapabilityBoundingSet**: limits the capabilities that are gained during `execve`
* **AmbientCapabilities**: useful if you want to execute a process as a non-privileged user but still want to give it some capabilities

To preserve the configuration over package updates, create an `override.conf` file within the `/lib/systemd/system/httpd.service.d/` directory.

Knowing the service needs to access a privileged port and it is being started as `root`, but forks its threads as `apache`, the following capabilities need to be specified in the `[Service]` section of the `/lib/systemd/system/httpd.service.d/override.conf` file:

```
[Service]
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_SETUID CAP_SETGID
```

The overall exposure level could be reduced from `UNSAFE` to `MEDIUM`.

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 7.1 MEDIUM 😐
```

The process still runs as `root`, though. The exposure level could be lowered by running it exclusively as `apache`.

Apart from accessing the port 80, the process needs to write to the logs located in `/etc/httpd/logs/` and be able to create `/run/httpd/` and write to it. The former can be achieved by changing the permissions with `chown` and the latter by using the `systemd-tmpfiles` utility. It can be used with the option `--create` for it to create the file without rebooting, but the file will be created automatically on every system startup from now on.

```bash
[user@rocky-vm ~]$ sudo chown -R apache:apache /etc/httpd/logs/
[user@rocky-vm ~]$ echo 'd /run/httpd 0755 apache apache -' | sudo tee /etc/tmpfiles.d/httpd.conf
d /run/httpd 0755 apache apache -
[user@rocky-vm ~]$ sudo systemd-tmpfiles --create /etc/tmpfiles.d/httpd.conf
[user@rocky-vm ~]$ ls -ld /run/httpd/
drwxr-xr-x. 2 apache apache 40 Jun 30 08:29 /run/httpd/
```

The configuration within `/lib/systemd/system/httpd.service.d/override.conf` needs to be adjusted. The new capabilities need to be granted with **AmbientCapabilities**. If `httpd` is enabled on startup, the dependecies in the `[Unit]` section need to be expanded for the service to start after the creation of the temporary file.

```
[Unit]
After=systemd-tmpfiles-setup.service

[Service]
User=apache
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
```

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ grep Cap /proc/$(pgrep httpd | head -1)/status
CapInh: 0000000000000400
CapPrm: 0000000000000400
CapEff: 0000000000000400
CapBnd: 0000000000000400
CapAmb: 0000000000000400
[user@rocky-vm ~]$ capsh --decode=0000000000000400
0x0000000000000400=cap_net_bind_service
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 6.5 MEDIUM 😐
```

## File system restrictions

The permissions on the files that the process creates may be controlled by setting the `UMask`. 
The `UMask` parameter modifies default file permissions by performing bitwise operations. Mostly, the default permissions are set to octal `0644` (`-rw-r--r--`), and the default `UMask` is `0022`. This means the `UMask` does not change the default set:

```bash
[user@rocky-vm ~]$ printf "%o\n" $(echo $(( 00644 &  ~00022 )))
644
```

Assuming the desired permission set for files created by the daemon is `0640` (`-rw-r-----`), `UMask` can be set to `7137`. It achieves the goal even if the default permissions were set to `7777`:

```bash
[user@rocky-vm ~]$ printf "%o\n" $(echo $(( 07777 &  ~07137  )))
640
```

Furthermore: 

* `ProtectSystem=`: *"If set to "`strict`" the entire file system hierarchy is mounted read-only, except for the API file system subtrees `/dev/`, `/proc/` and `/sys/` (protect these directories using `PrivateDevices=`, `ProtectKernelTunables=`, `ProtectControlGroups=`)."*
* `ReadWritePaths=`: makes particular paths writable again
* `ProtectHome=`: makes `/home/`, `/root`, and `/run/user` inaccessible
* `PrivateDevices=`: turns off access to physical devices, allows access only to pseudo devices like `/dev/null`, `/dev/zero`, `/dev/random`
* `ProtectKernelTunables=`: makes `/proc/` und `/sys/` read-only
* `ProtectControlGroups=`: makes `cgroups`accessible read-only
* `ProtectKernelModules=`: denies explicit module loading
* `ProtectKernelLogs=`: restricts access to the kernel log buffer
* `ProtectProc=`: *"When set to "invisible" processes owned by other users are hidden from /proc/."*
* `ProcSubset=`: *"If "pid", all files and directories not directly associated with process management and introspection are made invisible in the /proc/ file system configured for the unit's processes."*

The executable paths can also be restricted. The daemon only needs to execute its own binaries and libraries they use. The `ldd` utility can tell us what libraries a binary uses:

```bash
[user@rocky-vm ~]$ ldd /usr/sbin/httpd
        linux-vdso.so.1 (0x00007ffc0e823000)
        libpcre.so.1 => /lib64/libpcre.so.1 (0x00007fa360d61000)
        libselinux.so.1 => /lib64/libselinux.so.1 (0x00007fa360d34000)
        libaprutil-1.so.0 => /lib64/libaprutil-1.so.0 (0x00007fa360d05000)
        libcrypt.so.2 => /lib64/libcrypt.so.2 (0x00007fa360ccb000)
        libexpat.so.1 => /lib64/libexpat.so.1 (0x00007fa360c9a000)
        libapr-1.so.0 => /lib64/libapr-1.so.0 (0x00007fa360c5a000)
        libc.so.6 => /lib64/libc.so.6 (0x00007fa360a00000)
        libpcre2-8.so.0 => /lib64/libpcre2-8.so.0 (0x00007fa360964000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fa360e70000)
        libuuid.so.1 => /lib64/libuuid.so.1 (0x00007fa360c4e000)
        libm.so.6 => /lib64/libm.so.6 (0x00007fa360889000)
```

The following lines will be appended to the `[Service]` section in the `override.conf` file:

```
UMask=7177
ProtectSystem=strict
ReadWritePaths=/run/httpd /etc/httpd/logs

ProtectHome=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelLogs=true
ProtectProc=invisible
ProcSubset=pid

NoExecPaths=/
ExecPaths=/usr/sbin/httpd /lib64
```

Let's reload the configuration and check the impact on the score:

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 4.9 OK 🙂
```

## System restrictions

Various parameters can restrict system operations to enhance security:

* `NoNewPrivileges=`: ensures the process cannot gain new privileges through `setuid`, `setgid` bits and filesystem capabilities
* `ProtectClock=`: denies writes to system and hardware clocks
* `SystemCallArchitectures=`: if set to `native`, processes can make only native `syscalls` (in most cases `x86-64`)
* `RestrictNamespaces=`: namespaces are mostly relevant to containers, therefore can be restricted for this unit
* `RestrictSUIDSGID=`: prevents the process from setting `setuid` and `setgid` bits on files
* `LockPersonality=`: prevents the execution domain from being changed, which could be useful only for running legacy applications, or software designed for other Unix-like systems 
* `RestrictRealtime=`: realtime scheduling is relevant only to applications that require strict timing guarantees, such as industrial control systems, audio/video processing, and scientific simulations
* `RestrictAddressFamilies=`: restricts socket address families that are available; can be set to `AF_(INET|INET6)` to allow only IPv4 and IPv6 sockets; some services will need `AF_UNIX` for internal communication and logging
* `MemoryDenyWriteExecute=`: ensures that the process cannot allocate new memory regions that are both writable and executable, prevents some types of attacks where malicious code is injected into writable memory and then executed; may cause JIT compilers used by JavaScript, Java or .NET to fail
* `ProtectHostname=`: prevents the process from using `syscalls` `sethostname()`, `setdomainname()`

Let's append the following to the `override.conf` file, reload the configuration and check the impact on the score:

```
NoNewPrivileges=true
ProtectClock=true
SystemCallArchitectures=native
RestrictNamespaces=true
RestrictSUIDSGID=true
LockPersonality=true
RestrictRealtime=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
MemoryDenyWriteExecute=true
ProtectHostname=true
```

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 3.0 OK 🙂
```

## System call filtering

Restricting system calls may not be easy. It is difficult to determine what system calls some daemons need to make to function properly. 

The `strace` utility can be useful to determine what syscalls are being made. The option `-f` specifies to follow forked processes and `-o` saves the output to the file called `httpd.strace`.

```bash
[user@rocky-vm ~]$ sudo strace -f -o httpd.strace /usr/sbin/httpd
```

After running the process for a while and interacting with it, stop the execution to inspect the output:

```bash
[user@rocky-vm ~]$ awk '{print $2}' httpd.strace | cut -d '(' -f 1 | sort | uniq | sed '/^[^a-zA-Z0-9]*$/d' | wc -l
79
```

The program made 79 unique system calls during its runtime. 
The list of the system calls can be set to allowed with the following one-liner:

```bash
[user@rocky-vm ~]$ echo SystemCallFilter=$(awk '{print $2}' httpd.strace | cut -d '(' -f 1 | sort | uniq | sed '/^[^a-zA-Z0-9]*$/d' | tr "\n" " ") | sudo tee -a /lib/systemd/system/httpd.service.d/override.conf
...
...
...
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 1.5 OK 🙂
[user@rocky-vm ~]$ curl --head localhost
HTTP/1.1 403 Forbidden
```

The web server is still running and the exposure has been significantly lowered. 

The above approach is very precise. If a system call has been left out, it may lead to the program crashing. Systemd groups system calls into predefined sets. To make restricting system calls easier, instead of a single system call, a whole group can be set on the allowed, or disallowed list. To look up the lists:

```bash
[user@rocky-vm ~]$ systemd-analyze syscall-filter
@default
    # System calls that are always permitted
    arch_prctl
    brk
    cacheflush
    clock_getres
...
...
...
```

System calls within groups may overlap, especially for some groups include other groups. Therefore single calls or groups can be set to disallowed by being specified with the `~` symbol. The following directives in the `override.conf` file should work for this unit:

```
SystemCallFilter=@system-service
SystemCallFilter=~@privileged @resources @mount @swap @reboot
```

## Conclusions

The default security configuration of most `systemd` units is loose. Hardening them may take some time, but it is worthwhile, especially in larger environments exposed to the internet. If an attacker exploits a vulnerability or misconfiguration, a hardened unit may prevent them from taking control of the system.