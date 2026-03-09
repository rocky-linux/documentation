---
title: XFS recovery
author: Howard Van Der Wal
ai_contributors: Claude (claude-opus-4-6)
tested with: 8, 9, 10
tags:
- filesystem
- recovery
- storage
- troubleshooting
- xfs
---

## Introduction

Rocky Linux uses `XFS` as its default file system for all partitions except `/boot` (which uses `ext4`). `XFS` is a high-performance, journal-based file system that handles large files and high I/O workloads well^1^, but like any file system, it can encounter issues ranging from kernel-level memory leaks to metadata corruption that prevents booting.

This guide covers:

- Monitoring `XFS`-related kernel slab memory usage
- Diagnosing slab memory leaks caused by known kernel bugs
- Mitigating memory issues related to Transparent Huge Pages (`THP`)
- Recovering a system that will not boot using `rd.break` and `xfs_repair`
- Understanding when and how to use `xfs_repair -L`
- Avoiding data loss during RAID controller recovery

The procedures in this guide apply to Rocky Linux 8 and Rocky Linux 9. Where the two versions differ, the guide notes the distinction.

## Prerequisites

Before working through this guide, ensure you have:

- Root or `sudo` access to the Rocky Linux system
- Basic familiarity with `LVM` (Logical Volume Manager) concepts
- Console access (physical, `IPMI`, or `iDRAC`) for `rd.break` recovery procedures
- A current backup of critical data before running any repair operations

Install the `xfsprogs` package if it is not already present:

```bash
dnf install xfsprogs
```

## Viewing `XFS` file system information

Use `xfs_info` to display the configuration of a mounted `XFS` file system^2^. Pass the mount point as the argument:

```bash
xfs_info /
```

!!! note "Standard Rocky Linux installations"

    The `xfs_info /` command works on standard Rocky Linux installations where `/` is formatted as `XFS`. Some cloud provider images may use `ext4` for the root file system. Verify with `df -Th /` before running `xfs_info`.

This shows the block size, `inode` size, log size, and other structural details. Record this output as a baseline before troubleshooting.

To list all mounted `XFS` file systems:

```bash
mount -t xfs
```

## Monitoring `XFS` slab memory usage

The Linux kernel uses slab memory managers to handle internal objects, including those used by `XFS`^3^. Monitoring slab usage helps identify memory leaks and abnormal growth patterns.

### Viewing slab allocations with `slabtop`

The `slabtop` command displays real-time slab statistics. Sort by cache size to see the largest consumers:

```bash
slabtop -s c
```

Key `XFS`-related slab objects to monitor:

- `xfs_inode` - cached `XFS` `inode` structures
- `xfs_buf` - `XFS` buffer cache entries
- `xfs_ili` - `XFS` `inode` log items
- `xfs_trans` - `XFS` transaction structures

Other kernel slab objects that grow alongside `XFS` under memory pressure:

- `dentry` - directory entry cache
- `inode_cache` - `VFS` `inode` cache
- `radix_tree_node` - tree nodes used for page cache searches

### Checking `/proc/slabinfo` directly

For scripting or automated monitoring, read `/proc/slabinfo` directly:

```bash
grep -E 'xfs_inode|xfs_buf|dentry|inode_cache' /proc/slabinfo
```

Each line shows the object name, active objects, total objects, object size, and other details.

### Monitoring memory fields in `/proc/meminfo`

Three fields in `/proc/meminfo` track slab memory^4^:

```bash
grep -E 'Slab|SReclaimable|SUnreclaim' /proc/meminfo
```

- `Slab` - total memory used by the slab manager
- `SReclaimable` - slab memory that the kernel can reclaim under pressure
- `SUnreclaim` - slab memory that cannot be reclaimed

An increasing `SUnreclaim` value over days or weeks indicates a potential memory leak.

### Establishing a baseline

Record slab values shortly after a clean boot to establish a normal baseline:

```bash
date && grep -E 'Slab|SReclaimable|SUnreclaim' /proc/meminfo && slabtop -o -s c | head -20
```

Compare against this baseline during routine monitoring. Normal growth depends on workload, but doubling of slab values without a corresponding increase in application activity warrants investigation.

## Diagnosing `XFS` slab memory leaks

Slab memory leaks in the kernel manifest as a steady increase in slab allocations over days or weeks that do not decrease when workloads are reduced.

### Identifying the growth pattern

Signs of a kernel slab memory leak:

- `SUnreclaim` in `/proc/meminfo` grows steadily over days without returning to baseline
- Specific slab objects (such as `numa_policy`, `xfs_inode`, or `pid`) grow by 10x or more compared to a freshly booted system
- Total memory usage climbs to 80-90% of physical RAM despite stable application workloads
- Swap usage increases as the kernel consumes available memory

### Checking for runaway `kworker` threads

Kernel worker threads (`kworker`) handle deferred I/O operations including `XFS` journal writes. An abnormally high count indicates a kernel I/O issue:

```bash
ps -eLf | grep -c kworker
```

A healthy system typically has dozens to low hundreds of `kworker` threads depending on CPU count and I/O load. Counts of 500 or more, combined with high slab growth, indicate a kernel-level problem.

### Known Rocky Linux 8 kernel bug

A confirmed memory leak affects Rocky Linux 8 kernels from `4.18.0-553.81.1` through versions prior to `4.18.0-553.94.1`. The leak is triggered when both Transparent Huge Pages (`THP`) and swap are enabled simultaneously.

The mechanism:

1. Applications using `NUMA` memory policies (such as `JVM` with `-XX:+UseNUMA`) call `set_mempolicy()` and `mbind()`, which create `numa_policy` slab objects
2. `THP` memory compaction attempts to consolidate memory by migrating huge pages
3. A bug in the compaction code fails to free `numa_policy` objects after migration
4. Over approximately 23 days, these leaked objects exhaust system memory

The fix is included in `kernel-4.18.0-553.94.1` (`RHSA-2026:0759`), which contains the upstream commit for proper compaction event handling.

!!! warning "Long incubation period"

    This memory leak takes approximately 23 days to reach critical levels on a 1 TB RAM system. Short monitoring windows of hours or even days may not reveal the problem. If you suspect this bug, monitor slab growth continuously for at least one week.

To check your current kernel version:

```bash
uname -r
```

To update to the fixed kernel on Rocky Linux 8:

```bash
dnf update kernel
reboot
```

## Mitigating `XFS` memory issues with `THP`

Transparent Huge Pages (`THP`) can interact poorly with the kernel memory compaction system, triggering slab memory leaks on affected kernel versions^5^. Disabling `THP` is the recommended workaround when a kernel update is not immediately possible.

### Checking the current `THP` state

```bash
cat /sys/kernel/mm/transparent_hugepage/enabled
```

The output shows three options with the active setting in brackets. For example, `always [madvise] never` means `madvise` is active.

### Disabling `THP` immediately

To disable `THP` on a running system without a reboot:

```bash
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
```

Verify the change:

```bash
cat /sys/kernel/mm/transparent_hugepage/enabled
```

The output should show `always madvise [never]`.

### Making the `THP` change persistent

To ensure `THP` remains disabled across reboots, add a kernel boot parameter^9^. Edit the GRUB configuration:

```bash
grubby --update-kernel=ALL --args="transparent_hugepage=never"
```

Verify the parameter was added:

```bash
grubby --info=ALL | grep args
```

The `transparent_hugepage=never` parameter should appear in the kernel arguments.

!!! note "Performance considerations"

    Disabling `THP` may reduce performance for applications that benefit from large memory pages, such as databases and in-memory caches. Monitor application performance after disabling `THP`. If the kernel has been updated to the fixed version (`4.18.0-553.94.1` or later for Rocky Linux 8), re-enable `THP` if your workload benefits from it.

## Recovering a system that will not boot with `rd.break`

When an `XFS` file system suffers metadata corruption, the system may fail to mount its root file system during boot. The error `Metadata has LSN ahead of current LSN` in the boot output indicates that the `XFS` journal (log) contains sequence numbers that are inconsistent with the file system metadata. The `rd.break` kernel parameter interrupts the boot process before the root file system is mounted^6^.

!!! warning "Console access required"

    The `rd.break` recovery procedure requires interactive access to the GRUB boot menu. This means physical console access, or remote console access through `IPMI`, `iDRAC`, `iLO`, or a similar baseboard management controller. You cannot perform this procedure over SSH.

### When to use `rd.break`

Use `rd.break` when:

- The system drops to a `dracut` emergency shell during boot
- Boot messages show `XFS` mount failures with `LSN` errors
- The root file system (`/sysroot`) fails to mount
- Standard rescue mode (`systemd.unit=rescue.target`) also fails because it depends on mounting root

### Step-by-step recovery procedure

**Step 1** - Access the GRUB boot menu. When the GRUB menu appears during boot, press `e` to edit the default boot entry.

**Step 2** - Add `rd.break` to the kernel command line. Find the line that begins with `linux` (or `linuxefi`) and append `rd.break` to the end of that line.

**Step 3** - Boot with the modified parameters. Press `Ctrl+X` to boot. The system will stop in the `initramfs` environment before mounting the root file system. You will see a `switch_root:/#` prompt.

**Step 4** - Activate `LVM` volumes. If the system uses `LVM` (which is the default Rocky Linux layout)^7^, activate all volume groups:

```bash
lvm vgchange -ay
```

List the available logical volumes to identify which ones need repair:

```bash
lvm lvs
```

**Step 5** - Run `xfs_repair` on each `XFS` logical volume. Start without the `-L` flag to assess the damage:

```bash
xfs_repair /dev/mapper/rootvg-rootlv
```

If `xfs_repair` completes but reports `Maximum metadata LSN is ahead of log` or shows extensive `CRC` errors and metadata corruption, the file system needs log zeroing. Proceed with the `-L` flag as described in the next section.

Run `xfs_repair -L` on every `XFS` logical volume that reported `LSN` or metadata errors:

```bash
xfs_repair -L /dev/mapper/rootvg-rootlv
xfs_repair -L /dev/mapper/rootvg-homelv
xfs_repair -L /dev/mapper/rootvg-varlv
xfs_repair -L /dev/mapper/rootvg-tmplv
xfs_repair -L /dev/mapper/rootvg-optlv
xfs_repair -L /dev/mapper/rootvg-varloglv
```

!!! note "Skip swap volumes"

    Do not run `xfs_repair` on swap volumes. Swap uses a different format and is not an `XFS` file system. Running `xfs_repair` on a swap volume will produce errors or damage the swap signature.

**Step 6** - Reboot the system. After repairing all `XFS` volumes:

```bash
reboot -f
```

The system should now boot normally. After booting, verify file system health by checking `dmesg` for `XFS` messages:

```bash
dmesg | grep -i xfs
```

## Understanding `xfs_repair -L`

The `xfs_repair` command checks and repairs `XFS` file system metadata^8^. The `-L` flag has a specific and significant purpose that you should understand before using it.

### What `-L` does

The `-L` flag tells `xfs_repair` to zero (clear) the file system journal log. The `XFS` journal records pending metadata operations. When `-L` is used, any operations recorded in the journal that have not yet been written to the file system are permanently discarded.

### When to use `-L`

Use `xfs_repair -L` when:

- The file system cannot be mounted due to journal corruption (`LSN` errors)
- Running `xfs_repair` without `-L` reports `Maximum metadata LSN is ahead of log` and formats the log
- Running `xfs_repair` without `-L` shows extensive `CRC` errors and metadata corruption
- The system will not boot and standard repair alone did not restore the ability to mount

### When NOT to use `-L`

Do not use `xfs_repair -L` when:

- The file system mounts normally - use `xfs_repair` without `-L` instead
- You have not tried `xfs_repair` without `-L` first
- The issue is performance-related rather than corruption-related

### Always try standard repair first

Run `xfs_repair` without any flags first:

```bash
xfs_repair /dev/mapper/rootvg-rootlv
```

If the journal can be replayed cleanly, this preserves all pending writes. Only escalate to `-L` when standard repair reports `LSN` mismatches or extensive metadata `CRC` errors. Note that `xfs_repair` without `-L` may still complete its phases but output a `Maximum metadata LSN is ahead of log` message - this indicates that `-L` is needed for a full repair.

!!! danger "Potential data loss"

    Using `xfs_repair -L` discards all pending journal entries. This may result in recent file changes being lost. Files that were being written when the system crashed may be incomplete or missing. Always back up data before running `xfs_repair -L` if possible.

### Post-repair verification

After running `xfs_repair` (with or without `-L`), mount the file system and verify:

```bash
mount /dev/mapper/rootvg-rootlv /mnt
ls -la /mnt
df -h /mnt
umount /mnt
```

Check the kernel log for `XFS` messages after mounting:

```bash
dmesg | grep -i xfs
```

Clean mount messages without errors confirm the repair was successful.

## RAID controller recovery considerations

When a server with hardware RAID fails to boot, the RAID controller configuration is a critical factor. Incorrect RAID recovery actions can cause permanent data loss.

!!! warning "Physical servers only"

    This section applies to physical servers with hardware RAID controllers such as Dell PERC, Broadcom MegaRAID, or HPE Smart Array. Virtual machines and cloud instances do not use hardware RAID.

### Understanding foreign RAID configurations

A "foreign configuration" occurs when a RAID controller detects physical disks that contain RAID metadata from a different controller or a previous configuration. This commonly happens after:

- Cable or disk removal and replacement during hardware maintenance
- Controller replacement or firmware update
- Moving disks between servers

The RAID controller presents two options:

- **Import** - reads the existing RAID metadata and reconstructs the virtual disk. All data is preserved.
- **Clear** - removes the RAID metadata and treats the disks as new. All data on the array is destroyed.

### Import preserves data, clear destroys data

!!! danger "Clearing a foreign configuration is irreversible"

    Clearing a foreign RAID configuration removes all RAID metadata, partition tables, `LVM` metadata, and file system data from the affected disks. The data cannot be recovered after clearing. Always import the foreign configuration unless you are intentionally rebuilding the array from scratch.

When presented with a foreign configuration:

1. **Always attempt import first.** Importing reads the existing metadata and reconstructs the array as it was before the disruption.
2. **Verify the array state after import.** Check that virtual disks show as "Online" or "Optimal" in the RAID management interface (`iDRAC`, BIOS RAID utility, or `storcli`/`perccli`).
3. **Only clear if import fails and you accept data loss.** Some scenarios where import is not possible include physical disk failure or metadata corruption. In these cases, clearing is the only option, but it requires a full OS install.

### Verifying disk state after RAID recovery

After recovering from a RAID issue, verify that the disks contain valid data before attempting to boot:

Check for a valid partition table:

```bash
fdisk -l /dev/sda
```

A valid disk shows a `Disklabel type` line (such as `gpt` or `dos`) and one or more partition entries. A disk with no `Disklabel` and no partitions has been wiped.

Check for `LVM` physical volumes:

```bash
lvm pvscan
```

This should list physical volumes. If the boot disk is not listed, its `LVM` metadata has been destroyed.

Check the first sector for data:

```bash
dd if=/dev/sda bs=512 count=1 | hexdump -C | head -5
```

A valid disk contains non-zero data in the first sector (partition table, boot code). A disk that shows all zeros has been wiped.

### Prevention

To reduce the risk of RAID-related data loss:

- Document the RAID configuration (virtual disk layout, RAID level, disk slot assignments) before any hardware maintenance
- Take screenshots of the RAID management interface before and after hardware work
- Ensure hardware maintenance personnel understand the difference between importing and clearing foreign configurations
- Keep current backups of all boot disks

## Quick reference

### Command summary

| Task | Command |
| ------ | --------- |
| View `XFS` file system info | `xfs_info /` |
| List mounted `XFS` file systems | `mount -t xfs` |
| Monitor slab allocations | `slabtop -s c` |
| Check slab memory in `/proc/meminfo` | `grep -E 'Slab\|SReclaimable\|SUnreclaim' /proc/meminfo` |
| Search for `XFS` slab objects | `grep -E 'xfs_inode\|xfs_buf' /proc/slabinfo` |
| Count `kworker` threads | `ps -eLf \| grep -c kworker` |
| Check `THP` status | `cat /sys/kernel/mm/transparent_hugepage/enabled` |
| Disable `THP` (runtime) | `echo never > /sys/kernel/mm/transparent_hugepage/enabled` |
| Disable `THP` (persistent) | `grubby --update-kernel=ALL --args="transparent_hugepage=never"` |
| Activate `LVM` volume groups | `lvm vgchange -ay` |
| Repair `XFS` (standard) | `xfs_repair /dev/mapper/<vg>-<lv>` |
| Repair `XFS` (zero log) | `xfs_repair -L /dev/mapper/<vg>-<lv>` |
| Check kernel version | `uname -r` |
| Check `XFS` messages in kernel log | `dmesg \| grep -i xfs` |

### Decision tree for boot failures

1. System drops to `dracut` emergency shell or fails to mount `/sysroot`:
    - Access GRUB, add `rd.break`, boot to `initramfs` shell
    - Run `lvm vgchange -ay` to activate volumes
    - Run `xfs_repair /dev/mapper/<vg>-<lv>` on the root volume
    - If standard repair fails, run `xfs_repair -L /dev/mapper/<vg>-<lv>`
    - Repeat for all `XFS` logical volumes in the volume group
    - Reboot with `reboot -f`

2. System shows "No boot device available":
    - Check RAID controller for foreign configuration
    - If foreign configuration exists, **import** it (do not clear)
    - If no foreign configuration and disks show as empty, data has been lost - reinstall the OS
    - Verify disk state with `fdisk -l`, `lvm pvscan`, and `dd | hexdump`

3. System boots but shows high memory usage with no application cause:
    - Check slab memory with `slabtop -s c` and `/proc/meminfo`
    - Count `kworker` threads with `ps -eLf | grep -c kworker`
    - If slab objects show 10x+ growth and `kworker` count exceeds 500, check kernel version
    - Disable `THP` as an immediate workaround
    - Update to a kernel version containing the fix

## References

1. [`XFS` Administration - Linux Kernel Project](https://docs.kernel.org/admin-guide/xfs.html)
2. [`xfs_info`(8) - Linux manual page](https://man7.org/linux/man-pages/man8/xfs_info.8.html)
3. [Short Users Guide for `SLUB` - Linux Kernel Project](https://docs.kernel.org/mm/slab.html)
4. [The `/proc` File System - Linux Kernel Project](https://www.kernel.org/doc/html/latest/filesystems/proc.html)
5. [Transparent Huge Page Support - Linux Kernel Project](https://docs.kernel.org/admin-guide/mm/transhuge.html)
6. [`dracut.cmdline`(7) - Linux manual page](https://man7.org/linux/man-pages/man7/dracut.cmdline.7.html)
7. [`LVM2` Resource Page](https://www.sourceware.org/lvm2/)
8. [`xfs_repair`(8) - Linux manual page](https://man7.org/linux/man-pages/man8/xfs_repair.8.html)
9. [GNU GRUB Manual - GNU Project](https://www.gnu.org/software/grub/manual/grub/grub.html)
