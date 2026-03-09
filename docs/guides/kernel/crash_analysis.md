---
title: Crash analysis
author: Howard Van Der Wal
contributors: Steven Spencer
tested_with: 8,9,10
ai_contributors:
- Claude (claude-opus-4-6)
tags:
  - crash
  - debugging
  - kdump
  - kernel
  - vmcore
---

**Knowledge**: :star: :star: :star:
**Reading time**: 30 minutes

## AI usage

This document adheres to the [AI contribution policy found here.](../contribute/ai-contribution-policy.md) If you find any errors in the instructions, please let us know.

## Introduction

When a Linux kernel crashes, the system produces a memory dump called a `vmcore`. Analyzing this dump is often the only way to determine why a production server went down. Rocky Linux ships with two essential tools for this workflow: `kdump`, which captures the vmcore at crash time, and the `crash` utility, which opens the dump for post-mortem analysis.

This guide walks through the complete process — from configuring kdump to capture vmcores, to using crash commands to identify common crash patterns such as blocked task panics, mutex corruption, and cgroup deadlocks. It also covers safe sosreport collection during crash investigation and guidance on when to upgrade the kernel versus apply workarounds.

## Prerequisites

- A Rocky Linux 8, 9, or 10 system.
- Root or sudo access.
- At least 2 GB of free disk space in `/var/crash` for vmcore dumps.
- Network access to install packages from Rocky Linux repositories.

## Setting up kdump for vmcore capture

The `kdump` service reserves a portion of system memory for a secondary kernel. When the primary kernel crashes, `kdump` boots this secondary kernel and uses it to write the contents of memory to disk as a vmcore file.

### Installing kdump

Install the `kexec-tools` package, which provides the `kdump` service:

```bash
dnf install kexec-tools
```

### Configuring reserved memory

The kernel must reserve memory for the crash kernel at boot time. Check the current `crashkernel` parameter:

```bash
cat /proc/cmdline | grep crashkernel
```

On Rocky Linux 9 and 10, the `kexec-tools` package sets a default crashkernel value. You can check the default with:

```bash
kdumpctl get-default-crashkernel
```

On Rocky Linux 9.5+, this returns `1G-2G:192M,2G-64G:256M,64G-:512M`. The exact values vary by version and architecture. If the parameter is missing from the boot command line, add it using `grubby`:

```bash
grubby --update-kernel=ALL --args="crashkernel=1G-2G:192M,2G-64G:256M,64G-:512M"
```

!!! note

    On Rocky Linux 8, `kdumpctl get-default-crashkernel` is not available. Rocky Linux 8 uses `crashkernel=auto` by default, which lets the kernel calculate the reserved memory size automatically.

Reboot for the change to take effect:

```bash
reboot
```

After rebooting, verify that memory was reserved:

```bash
cat /sys/kernel/kexec_crash_size
```

A non-zero value confirms that memory has been reserved for the crash kernel.

### Configuring the dump location

The default dump location is `/var/crash`. The configuration file is `/etc/kdump.conf`:

```bash
cat /etc/kdump.conf | grep -v "^#" | grep -v "^$"
```

The default configuration writes dumps to the local filesystem. Key settings include:

- `auto_reset_crashkernel yes` — automatically adjusts crashkernel reservation when memory changes (Rocky Linux 9+ only)
- `path /var/crash` — directory where vmcores are stored
- `core_collector makedumpfile -l --message-level 7 -d 31` — compresses the dump and filters unnecessary pages

!!! note

    The `-d 31` flag in `makedumpfile` filters out zero pages, cache pages, user data pages, and free pages. This significantly reduces vmcore size. For a system with 64 GB of RAM, the resulting vmcore is typically 1-4 GB rather than the full 64 GB.

### Enabling and verifying kdump

Enable and start the `kdump` service:

```bash
systemctl enable --now kdump
```

Verify the service is running:

```bash
systemctl status kdump
```

After rebooting with the `crashkernel` parameter set, the output should show `Active: active (exited)`, indicating that the crash kernel has been loaded. You can also verify with:

```bash
kdumpctl status
```

This should report `Kdump is operational`.

## Installing the crash utility and kernel-debuginfo packages

The `crash` utility requires both the `crash` package and the matching `kernel-debuginfo` package for the kernel that produced the vmcore.

### Installing crash

```bash
dnf install crash
```

### Installing kernel-debuginfo

The `kernel-debuginfo` packages provide the `vmlinux` file with full debugging symbols. First, identify the kernel version from the vmcore (or the running kernel if testing):

```bash
uname -r
```

Install the matching debuginfo packages using `debuginfo-install`, which automatically enables the correct repositories:

```bash
dnf debuginfo-install kernel-core-$(uname -r)
```

This installs both `kernel-debuginfo` and `kernel-debuginfo-common` packages. The `debuginfo-install` command handles repository enablement automatically, which is more reliable than manually specifying the `baseos-debuginfo` repository.

!!! note

    If the vmcore was produced by a different kernel version than the one currently running, replace `$(uname -r)` with the specific version string. You can find the kernel version from a vmcore by examining the `makedumpfile` header or by checking the `uname` file in a corresponding sosreport.

Verify the `vmlinux` file exists:

```bash
ls /usr/lib/debug/lib/modules/$(uname -r)/vmlinux
```

## Opening a vmcore with crash

To open a vmcore, provide the path to the `vmlinux` debugging symbols and the vmcore file:

```bash
crash /usr/lib/debug/lib/modules/<kernel-version>/vmlinux /var/crash/<timestamp>/vmcore
```

For example:

```bash
crash /usr/lib/debug/lib/modules/5.14.0-611.36.1.el9_7.x86_64/vmlinux /var/crash/127.0.0.1-2025-03-09-10:30:00/vmcore
```

When crash opens the vmcore, it displays a header with key information:

```text
      KERNEL: /usr/lib/debug/lib/modules/5.14.0-611.36.1.el9_7.x86_64/vmlinux
    DUMPFILE: vmcore  [PARTIAL DUMP]
        CPUS: 4
        DATE: Sun Mar  9 10:30:00 JST 2025
      UPTIME: 3 days, 12:45:30
LOAD AVERAGE: 45.67, 42.31, 38.92
       TASKS: 312
    NODENAME: rocky-server
     RELEASE: 5.14.0-611.36.1.el9_7.x86_64
     VERSION: #1 SMP PREEMPT_DYNAMIC
     MACHINE: x86_64
      MEMORY: 8 GB
       PANIC: "BUG: kernel NULL pointer dereference"
         PID: 0
     COMMAND: "swapper/0"
```

Key fields to examine:

- **UPTIME** — how long the system was running before the crash
- **LOAD AVERAGE** — system load at crash time (high values may indicate resource exhaustion)
- **PANIC** — the panic message that triggered the crash
- **PID** and **COMMAND** — the process and command running when the crash occurred

## Essential crash analysis commands

### `log` — kernel ring buffer

The `log` command displays the kernel ring buffer (equivalent to `dmesg`). This is usually the first command to run after opening a vmcore:

```text
crash> log
```

To search for specific messages, pipe through `grep`:

```text
crash> log | grep -i "blocked\|panic\|bug\|error"
```

### `bt` — backtrace

Display the backtrace of the task that was active when the crash occurred:

```text
crash> bt
```

Display the backtrace for a specific PID:

```text
crash> bt <pid>
```

Display backtraces for the active task on each CPU:

```text
crash> bt -a
```

### `ps` — process listing

List all processes:

```text
crash> ps
```

The `-m` flag shows the time each task has spent in its current state, which is critical for identifying tasks that have been blocked for extended periods:

```text
crash> ps -m
```

### `foreach` — iterating over tasks

The `foreach` command runs a command against multiple tasks. To find all tasks in uninterruptible sleep (UN state) and show how long they have been blocked:

```text
crash> foreach UN ps -m
```

This is one of the most important commands for diagnosing blocked task panics. The output shows each blocked task with its accumulated time in the UN state.

### `files` — open file descriptors

Display open file descriptors for a specific task:

```text
crash> files <pid>
```

### `struct` — examining kernel data structures

Display a kernel structure at a specific memory address:

```text
crash> struct task_struct <address>
```

To display specific fields:

```text
crash> struct task_struct <address> | grep pi_blocked_on
```

```text
crash> struct task_struct.pi_blocked_on <address>
```

### `kmem -i` — memory usage summary

Display a summary of system memory usage:

```text
crash> kmem -i
```

This shows total memory, free memory, buffers, cache, and swap usage. High memory consumption or swap usage at crash time may indicate memory pressure as a contributing factor.

### `mod -t` — checking tainted modules

Display the kernel taint state and which modules caused tainting:

```text
crash> mod -t
```

A tainted kernel (for example, by out-of-tree or proprietary modules) may behave differently from what upstream kernel developers expect. Common taint flags include:

- `P` — proprietary module loaded
- `O` — out-of-tree module loaded
- `E` — unsigned module loaded

## Identifying common crash patterns

### Blocked task panics (khungtaskd)

The `khungtaskd` kernel thread monitors tasks in uninterruptible sleep (D state). If a task remains in this state for longer than the `kernel.hung_task_timeout_secs` threshold (default: 120 seconds), `khungtaskd` logs a warning. If `kernel.hung_task_panic` is set to 1, it triggers a kernel panic.

**Recognizing the pattern in log output:**

```text
crash> log | grep "blocked for more than"
```

Typical output:

```text
INFO: task kworker/2:1:1234 blocked for more than 120 seconds.
INFO: task runc:[2:INIT]:5678 blocked for more than 600 seconds.
```

**Finding all blocked tasks:**

```text
crash> foreach UN ps -m
```

This lists every task in uninterruptible sleep along with the duration. Tasks blocked for hundreds of seconds are strong candidates for the root cause.

**Tracing the blocking chain:**

Once you identify a blocked task, examine its backtrace:

```text
crash> bt <pid>
```

Look for functions related to locks, mutexes, or I/O waits in the backtrace. Common blocking points include `mutex_lock`, `rwsem_down_read_slowpath`, and `io_schedule`.

### Mutex corruption (rt_mutex)

On kernels using PREEMPT_RT, `spinlock_t` and `rwlock_t` are replaced with `rt_mutex`-based implementations, converting them from spinning locks to sleeping locks. Corruption of these structures can cause cascading task blockages.

**Examining pi_blocked_on:**

If a task is blocked on an rt_mutex, the `pi_blocked_on` field in its `task_struct` points to the `rt_mutex_waiter` structure:

```text
crash> struct task_struct.pi_blocked_on <task_address>
```

If the result is a non-NULL value, examine the waiter structure:

```text
crash> struct rt_mutex_waiter <waiter_address>
```

This reveals the `lock` field, which points to the `rt_mutex` itself:

```text
crash> struct rt_mutex <mutex_address>
```

The `owner` field of the `rt_mutex` shows which task holds the lock. An invalid owner pointer (such as `0x1` or another clearly invalid address) indicates mutex corruption.

**Example of a corrupted rt_mutex chain:**

```text
crash> struct task_struct.pi_blocked_on ffff9a3c0e4b0000
  pi_blocked_on = 0xffff9a3c12340100
crash> struct rt_mutex_waiter 0xffff9a3c12340100
  lock = 0xffff9a3c56780200
crash> struct rt_mutex 0xffff9a3c56780200
  owner = 0x1    <-- invalid pointer, indicates corruption
```

An `owner` value of `0x1` means the lock's ownership tracking has been corrupted. This pattern was observed in PREEMPT_RT kernels prior to specific rt_mutex fixes.

### cgroup deadlocks

Container environments are susceptible to cgroup-related deadlocks, particularly when container runtimes (such as `runc`) interact with kernel cgroup subsystems.

**Identifying the pattern:**

```text
crash> log | grep -i "cgroup\|threadgroup"
```

A common deadlock scenario involves the `cgroup_mutex` and `cgroup_threadgroup_rwsem` locks. One task holds `cgroup_mutex` while waiting for `cgroup_threadgroup_rwsem`, while another task holds `cgroup_threadgroup_rwsem` and waits for `cgroup_mutex`.

**Tracing the deadlock:**

1. Find blocked tasks related to container operations:

    ```text
    crash> foreach UN bt | grep -A 5 "cgroup\|runc"
    ```

2. Identify tasks holding the conflicting locks by examining their backtraces. Look for functions like `cgroup_lock`, `cgroup_attach_task`, `copy_process`, and `cgroup_exit`.

3. The deadlock often involves:
    - A container runtime process (runc) holding `cgroup_mutex` during container setup
    - Fork or exit operations blocking on `cgroup_threadgroup_rwsem`
    - The two locks creating a circular dependency

**Mitigation:**

Reducing the frequency of operations that trigger cgroup lock contention — such as container exec probes in Kubernetes — can prevent these deadlocks from occurring.

### Timer bugs

Timer-related kernel bugs manifest as `BUG_ON` assertions in timer code paths.

**Recognizing the pattern:**

```text
crash> log | grep -i "BUG.*timer\|timer.*BUG"
```

```text
crash> bt
```

Look for functions such as `__run_timers`, `call_timer_fn`, or subsystem-specific timer handlers (such as SCTP's `sctp_generate_timeout_event`) in the backtrace.

Timer bugs are typically fixed in upstream kernel patches. The backtrace and the specific `BUG_ON` message are the key pieces of information needed when searching for known fixes or reporting the issue.

## PREEMPT_RT kernel considerations

The PREEMPT_RT patch set converts kernel `spinlock_t` and `rwlock_t` into `rt_mutex`-based implementations to provide deterministic scheduling latency. Standard `struct mutex` types are also reimplemented on top of `rt_mutex` under PREEMPT_RT, gaining priority inheritance support, though they remain sleeping locks in both configurations. This conversion changes blocking behavior significantly.

**Key differences under PREEMPT_RT:**

- **Spinlocks become sleeping locks**: Code paths that are non-blocking on standard kernels can block under PREEMPT_RT, creating new deadlock possibilities.
- **Priority inheritance**: rt_mutexes implement priority inheritance, which means mutex chains can become more complex. The `pi_blocked_on` and `pi_waiters` fields in `task_struct` are actively used.
- **Longer blocking chains**: Because more locks are sleepable, tasks can be blocked for longer periods, making `khungtaskd` panics more likely.

**Additional analysis techniques for RT kernels:**

Examine the priority inheritance chain:

```text
crash> struct task_struct.pi_waiters <task_address>
crash> struct task_struct.pi_blocked_on <task_address>
```

Check for rt_mutex-specific fields:

```text
crash> struct rt_mutex <address>
```

On PREEMPT_RT kernels, pay particular attention to the relationship between mutex ownership and task scheduling priority. A low-priority task holding a lock needed by a high-priority task can cause extended blocking if priority inheritance does not propagate correctly.

## Collecting sosreport safely during crash investigation

The `sosreport` tool (provided by the `sos` package) collects system configuration and diagnostic information. However, running a full sosreport on a system that is already under stress — for example, one that has recently recovered from a panic or is exhibiting hung tasks — can trigger additional crashes.

### Risk of full sosreport on stressed systems

A full sosreport runs numerous diagnostic commands and reads many files from `/proc` and `/sys`. On a system with kernel subsystems in an inconsistent state, this activity can:

- Trigger additional kernel panics by accessing corrupted data structures
- Cause the system to become completely unresponsive
- Produce an incomplete sosreport that is not useful for analysis

### Using limited plugin scope

To reduce the risk, restrict the sosreport to specific plugins:

```bash
sos report -o kernel,process,logs
```

This collects only kernel configuration, process information, and system logs — usually sufficient for initial crash investigation without putting excessive load on the system.

Other useful plugin combinations depending on the scenario:

```bash
sos report -o kernel,process,logs,networking
```

```bash
sos report -o kernel,process,logs,cgroups,container_log
```

### Alternative: collecting individual files manually

If even a limited sosreport is too risky, collect the essential files manually:

```bash
cp /var/log/messages /tmp/crash_collection/
cp /proc/cmdline /tmp/crash_collection/
cp /etc/kdump.conf /tmp/crash_collection/
uname -a > /tmp/crash_collection/uname.txt
lsmod > /tmp/crash_collection/lsmod.txt
ps auxf > /tmp/crash_collection/ps.txt
cat /proc/meminfo > /tmp/crash_collection/meminfo.txt
```

## When to upgrade the kernel versus apply workarounds

After identifying the root cause of a crash, you must decide whether to upgrade the kernel or apply a workaround.

### Checking for known fixes

Search the kernel changelog for fixes related to the crash pattern you identified:

```bash
rpm -q --changelog kernel | grep -i "<search_term>"
```

For example, to check if an rt_mutex fix is included:

```bash
rpm -q --changelog kernel | grep -i "rt_mutex\|rtmutex"
```

Check if a newer kernel version is available:

```bash
dnf check-update kernel
```

### Evaluating the decision

**Upgrade the kernel when:**

- The crash pattern matches a known bug with a fix in a newer kernel version
- The `rpm --changelog` output for the newer version includes the relevant fix
- The system can tolerate a maintenance window for the reboot

**Apply a workaround when:**

- No kernel fix is available yet
- The system cannot tolerate downtime for a kernel upgrade
- The crash can be avoided by changing system behavior (for example, reducing container exec probe frequency to avoid cgroup lock contention)

### Verifying a fix is included

After identifying a potential fix, verify it is included in the target kernel version:

```bash
rpm -q --changelog kernel-<new_version> | grep -i "<fix_description>"
```

You can also compare kernel versions between the current and available packages:

```bash
rpm -q kernel
dnf list available kernel
```

## Conclusion

Kernel crash analysis with kdump and crash provides a systematic approach to diagnosing production system failures on Rocky Linux. By configuring kdump to capture vmcores, using the crash utility to examine kernel state at the time of failure, and understanding common crash patterns, administrators can identify root causes and apply appropriate fixes.

Key takeaways:

- Configure kdump and verify it is operational **before** a crash occurs
- Start analysis with `log`, `bt`, and `foreach UN ps -m` to understand the crash context
- For blocked task panics, trace the blocking chain through mutex and lock structures
- On PREEMPT_RT kernels, pay particular attention to rt_mutex behavior
- Collect sosreports safely using `-o` to limit plugin scope on stressed systems
- Use kernel changelogs to verify that fixes are included before upgrading

## References

1. [Red Hat Enterprise Linux 9 — Managing, monitoring, and updating the kernel](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html-single/managing_monitoring_and_updating_the_kernel/index)
2. [crash utility GitHub repository](https://github.com/crash-utility/crash)
3. [makedumpfile GitHub repository](https://github.com/makedumpfile/makedumpfile)
4. [crash utility man page](https://man7.org/linux/man-pages/man8/crash.8.html)
5. [Rocky Linux Documentation — How to deal with a kernel panic](https://docs.rockylinux.org/guides/troubleshooting/kernel_panic/)
6. [kernel.org — PREEMPT_RT documentation](https://wiki.linuxfoundation.org/realtime/start)
7. [Red Hat Enterprise Linux 9 — Generating sos reports for technical support](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/getting_the_most_from_your_support_experience/generating-an-sos-report-for-technical-support_getting-the-most-from-your-support-experience)
