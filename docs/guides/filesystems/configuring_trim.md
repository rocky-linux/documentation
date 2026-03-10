---
title: Configuring TRIM
author: Howard Van Der Wal
contributors: Steven Spencer
ai_contributors: Claude (claude-opus-4-6)
tested with: 8, 9, 10
tags:
- discard
- fstrim
- lvm
- storage
- trim
- xfs
---

**Knowledge**: :star: :star: :star:
**Reading time**: 20 minutes

## AI usage

This document adheres to the [AI contribution policy found here.](../contribute/ai-contribution-policy.md) If you find any errors in the instructions, please let us know.

## Introduction

When files are deleted from a filesystem, the underlying storage device has no way to know that those blocks are no longer in use. On traditional thick-provisioned storage this does not matter, but on solid-state drives and thin-provisioned SAN or virtual storage, informing the device about freed blocks is important for performance and space reclamation.

TRIM (for SSDs) and UNMAP (for SCSI/SAN storage) are commands that notify the storage device that specific blocks are no longer needed. Without these commands, thin-provisioned storage pools grow over time but never shrink, and SSDs cannot perform efficient garbage collection.

This guide covers configuring TRIM and discard on Rocky Linux with LVM and XFS, explains the differences between the available mechanisms, and provides recommendations for production environments.

## Prerequisites

- A system running Rocky Linux 8, 9, or 10.
- Root or `sudo` access.
- Storage that supports discard operations (SSD, thin-provisioned SAN LUN, or thin-provisioned virtual disk).
- LVM-based storage configuration.

## Understanding the TRIM and discard stack

Discard commands must pass through every layer of the storage stack to reach the physical device. On a typical LVM-based Rocky Linux system, the path is:

```text
Filesystem (XFS/ext4)
    ↓ discard request
Device Mapper (LVM)
    ↓ discard passdown
Block Device (sd*, nvme*)
    ↓ TRIM / UNMAP
Physical Storage (SSD controller / SAN array)
```

If any layer in the stack does not support or pass through discard commands, the commands never reach the storage device.

There are three mechanisms for issuing discard commands on Rocky Linux:

| Mechanism | Layer | Trigger | Use case |
| --------- | ----- | ------- | -------- |
| `discard` mount option | Filesystem | Every file delete or block free operation | Real-time space reclamation (not recommended for most workloads) |
| `fstrim` / `fstrim.timer` | Filesystem | Scheduled or manual execution | Periodic batch TRIM (recommended) |
| `issue_discards = 1` in lvm.conf | LVM | LVM operations (`lvremove`, `lvreduce`, `pvmove`) | LVM volume lifecycle management only |

## Filesystem `discard` mount option vs LVM `issue_discards`

These two settings are frequently confused because they both involve the word "discard," but they operate at different layers and serve different purposes.

### The `discard` mount option

Adding `discard` to a filesystem's mount options causes the filesystem to send a discard command to the block device every time blocks are freed. This happens inline during file deletions, truncations, and other operations that release space:

```bash
mount | grep discard
```

```text
/dev/mapper/rl-data on /data type xfs (rw,relatime,attr2,inode64,logbufs=8,logbsize=32k,noquota,discard)
```

### The `issue_discards` setting in lvm.conf

The `issue_discards` setting^1^ in `/etc/lvm/lvm.conf` controls whether LVM sends discard commands when LVM metadata operations free physical extents:

```bash
grep -n "issue_discards" /etc/lvm/lvm.conf
```

The output shows the setting is commented out and disabled by default. The exact line number varies by version (line 383 on Rocky Linux 8, line 421 on Rocky Linux 9 and 10).

To enable it:

```bash
sudo sed -i 's/.*issue_discards = 0/\tissue_discards = 1/' /etc/lvm/lvm.conf
```

!!! warning "Common misconception"

    Setting `issue_discards = 1` in lvm.conf does **not** cause space to be reclaimed when files are deleted from a filesystem. It only issues discard commands during LVM operations such as `lvremove`, `lvreduce`, and `pvmove`. If your goal is to reclaim thin-provisioned storage space after deleting files, you need either the `discard` mount option or periodic `fstrim`.

The following table summarizes the difference:

| Setting | Triggers on file deletion? | Triggers on `lvremove`/`lvreduce`? | Recommended for space reclamation? |
| ------- | -------------------------- | ---------------------------------- | ---------------------------------- |
| `discard` mount option | Yes | No | Yes, but has performance impact |
| `issue_discards = 1` | No | Yes | No (does not handle file deletions) |
| `fstrim.timer` | No (runs on schedule) | No | Yes (recommended approach) |

## XFS performance considerations with inline discard

The XFS documentation^2^ specifically recommends against using the `discard` mount option on production workloads. The performance impact stems from how TRIM and UNMAP commands interact with the storage I/O queue.

When XFS issues a discard command with the `discard` mount option enabled, the storage driver must process the TRIM or UNMAP command. On many devices, particularly SATA SSDs using non-queued TRIM:

1. The driver waits for all outstanding I/O commands to complete.
2. The TRIM command is issued.
3. No new I/O can begin until the TRIM command finishes.
4. This effectively serializes I/O during every discard operation.

!!! warning "Impact on high-I/O workloads"

    On systems running databases, busy web applications, or other I/O-intensive workloads, the `discard` mount option can cause unpredictable latency spikes. Each file deletion or block free operation stalls the entire I/O queue while the TRIM command is processed. Use `fstrim.timer` instead.

If you currently have `discard` in your mount options and want to remove it, edit `/etc/fstab`:

```bash
# Before (inline discard enabled):
/dev/mapper/rl-data  /data  xfs  defaults,discard  0 0

# After (inline discard removed):
/dev/mapper/rl-data  /data  xfs  defaults  0 0
```

Remount the filesystem to apply the change without rebooting:

```bash
sudo mount -o remount /data
```

Verify the `discard` option is no longer present:

```bash
mount | grep /data
```

## Configuring `fstrim.timer` for periodic TRIM (recommended)

The `fstrim.timer`^3^ systemd timer runs `fstrim` on mounted filesystems that support the `discard` option. This is the recommended approach because it batches all discard operations into a single maintenance window rather than issuing them inline with every file operation.

!!! note "Rocky Linux 10 enables `fstrim.timer` by default"

    On Rocky Linux 10, the `fstrim.timer` is enabled by default (preset: enabled). On Rocky Linux 8 and 9, it must be enabled manually.

### Enabling the timer

The `util-linux` package provides both `fstrim.timer` and `fstrim.service`. Enable and start the timer:

```bash
sudo systemctl enable --now fstrim.timer
```

Verify the timer is active:

```bash
systemctl status fstrim.timer
```

```text
● fstrim.timer - Discard unused blocks once a week
     Loaded: loaded (/usr/lib/systemd/system/fstrim.timer; enabled; preset: disabled)
     Active: active (waiting) since ...
    Trigger: Mon 2025-01-06 00:00:00 UTC; 6 days left
   Triggers: ● fstrim.service
```

The default configuration runs `fstrim` weekly (every Monday at midnight) with a built-in randomized delay.

### Creating a systemd override for I/O priority

The default `fstrim.service` does not set I/O scheduling priority. On production systems, you should configure `fstrim` to run at the lowest practical priority to minimize impact on other workloads:

```bash
sudo systemctl edit fstrim.service
```

Add the following override configuration:

```ini
[Service]
IOSchedulingClass=best-effort
IOSchedulingPriority=7
Nice=19
```

This creates an override file at `/etc/systemd/system/fstrim.service.d/override.conf`. Verify the override is applied:

```bash
systemctl cat fstrim.service
```

The output should show the override section after the original unit file contents.

What each setting does:

- `IOSchedulingClass=best-effort`: Places `fstrim` I/O in the best-effort scheduling class, which shares I/O bandwidth with other processes rather than waiting for the I/O queue to be completely idle.
- `IOSchedulingPriority=7`: Sets the lowest priority (0-7 scale) within the best-effort class^4^.
- `Nice=19`: Sets the lowest CPU scheduling priority, appropriate for background maintenance tasks.

!!! warning "`IOSchedulingClass=idle` and I/O starvation"

    Do not use `IOSchedulingClass=idle` on systems with consistently high I/O utilization (such as database servers). The idle scheduling class only allows I/O when no other process has pending I/O requests. On a busy system, this can prevent `fstrim` from ever completing, or cause it to run for hours. Use `best-effort` with priority 7 instead.

### Adding randomized delay for multi-VM environments

If multiple virtual machines share the same underlying storage (such as a SAN or hypervisor datastore), having all VMs run `fstrim` simultaneously can overwhelm the storage controller. The default `fstrim.timer` already includes a randomized delay (6000 seconds on Rocky Linux 8 and 9, 100 minutes on Rocky Linux 10). For large VM environments, you can increase this:

```bash
sudo systemctl edit fstrim.timer
```

```ini
[Timer]
RandomizedDelaySec=6h
```

This overrides the default delay with up to 6 hours, further spreading the load across VMs.

### Adjusting the schedule

To change from weekly to daily execution, override the timer:

```bash
sudo systemctl edit fstrim.timer
```

```ini
[Timer]
OnCalendar=
OnCalendar=daily
```

The empty `OnCalendar=` line clears the default weekly schedule before setting the new daily schedule.

After modifying timer overrides, reload the systemd configuration:

```bash
sudo systemctl daemon-reload
```

## Verifying TRIM support through the storage stack

To confirm that discard commands can reach your storage device, verify support at each layer.

### Block device level

Check whether the block device advertises discard support:

```bash
lsblk -D
```

```text
NAME              DISC-ALN DISC-GRAN DISC-MAX DISC-ZERO
sda                      0      512B       2G         0
├─sda1                   0      512B       2G         0
├─sda2                   0      512B       2G         0
└─sda3                   0      512B       2G         0
  ├─rl-root              0      512B       2G         0
  └─rl-swap              0      512B       2G         0
```

The key columns are:

- `DISC-GRAN` (discard granularity): The minimum size of a discard operation. A non-zero value indicates the device supports discard.
- `DISC-MAX` (maximum discard size): The maximum size of a single discard operation. A non-zero value confirms discard support.

If both `DISC-GRAN` and `DISC-MAX` show `0`, the device does not support discard operations, or the support is not exposed to the operating system.

### Device-mapper level

For LVM volumes, verify that the device-mapper layer passes discard commands through to the underlying device:

```bash
sudo dmsetup table
```

```text
rl-root: 0 104857600 linear 8:3 2048
rl-swap: 0 4194304 linear 8:3 104859648
```

If discard passdown is disabled, you will see `no_discard_passdown` in the table output. If it is not present, discard passdown is enabled (the default for LVM on devices that support discard).

You can also check the device-mapper discard support directly:

```bash
cat /sys/block/dm-0/queue/discard_max_bytes
```

A non-zero value confirms the device-mapper device supports discard.

### Filesystem level

Check whether the filesystem is currently mounted with the `discard` option:

```bash
mount | grep discard
```

If using the recommended `fstrim.timer` approach, the `discard` mount option should not be present.

### End-to-end verification with `fstrim`

Run `fstrim` manually with verbose output to verify the entire stack is working:

```bash
sudo fstrim -v /
```

```text
/: 1.2 GiB (1288490880 bytes) trimmed
```

A successful output shows the amount of space trimmed. If `fstrim` fails with an error such as `the discard operation is not supported`, one or more layers in the storage stack do not support discard.

## SSD vs SAN thin-provisioning considerations

TRIM and UNMAP are the same concept applied to different storage types. Understanding the differences helps you configure each correctly.

### SSD TRIM

On SSDs, TRIM informs the flash controller that specific blocks are no longer in use. This enables:

- Garbage collection: The SSD controller can erase and reclaim unused NAND blocks during idle periods, improving write performance.
- Wear leveling: The controller can more evenly distribute writes across all available NAND cells when it knows which blocks are free.

Without TRIM, SSD write performance degrades over time as the controller runs out of pre-erased blocks and must perform read-erase-write cycles inline with new writes.

### SAN thin-provisioning (SCSI UNMAP)

On thin-provisioned SAN storage, UNMAP informs the storage array that blocks are no longer in use. This enables:

- Space reclamation: The array returns the unused blocks to the thin pool, making them available for other volumes.
- Capacity reporting: Storage management tools accurately reflect the actual space consumed rather than the allocated size.

Without UNMAP, a thin-provisioned LUN only grows. Even after deleting large amounts of data, the SAN continues to report the high-water mark as the used space.

### Virtual machine virtual disks

Virtual machines using virtio-scsi^5^ can pass discard commands from the guest to the hypervisor, which then translates them to the appropriate storage operation:

- KVM/QEMU with virtio-scsi: The `discard='unmap'` option in the domain XML enables discard passthrough from the guest to the host storage.
- VMware: VMFS 6 supports UNMAP from guest operating systems on thin-provisioned virtual disks.
- Hyper-V: Generation 2 VMs support TRIM passthrough to Hyper-V virtual hard disks.

The guest operating system configuration (this guide) remains the same regardless of the virtualization platform. The hypervisor handles translating the discard commands to the underlying physical storage.

## Conclusion

For most Rocky Linux deployments on thin-provisioned storage or SSDs, the recommended configuration is:

1. Do not use the `discard` mount option on XFS filesystems in production. The inline TRIM operations drain the I/O queue and cause latency spikes.
2. Enable `fstrim.timer` with a systemd override that sets `IOSchedulingClass=best-effort`, `IOSchedulingPriority=7`, and `Nice=19`. On Rocky Linux 10, the timer is already enabled by default.
3. Set `issue_discards = 1` in lvm.conf only if you need discard commands during LVM operations such as `lvremove`. This setting does not replace `fstrim` for filesystem-level space reclamation.
4. Verify discard support at every layer of the storage stack using `lsblk -D`, `dmsetup table`, and `fstrim -v`.
5. Add `RandomizedDelaySec` to `fstrim.timer` when multiple VMs share the same underlying storage.

## References

1. "lvm.conf(5) - issue_discards setting" by the lvmteam project [https://man7.org/linux/man-pages/man5/lvm.conf.5.html](https://man7.org/linux/man-pages/man5/lvm.conf.5.html)
2. "xfs(5) - discard mount option documentation" by the xfsprogs project [https://man7.org/linux/man-pages/man5/xfs.5.html](https://man7.org/linux/man-pages/man5/xfs.5.html)
3. "fstrim(8)" by Lukas Czerner and Karel Zak [https://man7.org/linux/man-pages/man8/fstrim.8.html](https://man7.org/linux/man-pages/man8/fstrim.8.html)
4. "ionice(1) - I/O scheduling classes and priorities" by Jens Axboe and Karel Zak [https://man7.org/linux/man-pages/man1/ionice.1.html](https://man7.org/linux/man-pages/man1/ionice.1.html)
5. "Domain XML format - disk elements and discard configuration" by the libvirt project [https://libvirt.org/formatdomain.html#hard-drives-floppy-disks-cdroms](https://libvirt.org/formatdomain.html#hard-drives-floppy-disks-cdroms)
