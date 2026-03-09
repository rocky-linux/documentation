---
title: KVM/libvirt performance tuning - NUMA, vCPU pinning, and hugepages on Rocky Linux
author: Howard Van Der Wal
tested_with: 8, 9, 10
ai_contributors: Claude (claude-opus-4-6)
tags:
  - kvm
  - libvirt
  - numa
  - performance
  - virtualization
---

## Introduction

This guide covers advanced performance tuning for KVM/libvirt virtual machines on Rocky Linux. It addresses common production issues including NUMA memory misallocation and vCPU scheduling contention.

The topics covered include:

- NUMA topology awareness and memory placement.
- The dangers of `vm.min_free_kbytes` on NUMA systems.
- vCPU pinning with libvirt domain XML.
- CPU isolation with `isolcpus` for dedicated VM workloads.
- `tuned` profiles for virtualization hosts.
- NUMA-aware VM placement with `virsh`.

## Prerequisites

- A machine running Rocky Linux 8, 9, or 10 with KVM/libvirt installed and configured. See the [Setting Up libvirt on Rocky Linux](libvirt-rocky.md) guide for initial setup.
- Root or `sudo` access on the hypervisor host.
- Familiarity with `virsh` and libvirt domain XML.
- A multi-socket or multi-NUMA-node server for NUMA-related sections.

## Understanding your NUMA topology

Before making any tuning changes, you must understand the NUMA (Non-Uniform Memory Access) topology of your host. On multi-socket systems, each CPU socket has its own local memory. Accessing remote memory on another socket incurs higher latency.

Install `numactl` if it is not already present:

```bash
sudo dnf install -y numactl
```

Display your NUMA topology:

```bash
numactl --hardware
```

Example output on a dual-socket system:

```text
available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
node 0 size: 65536 MB
node 0 free: 42000 MB
node 1 cpus: 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
node 1 size: 65536 MB
node 1 free: 45000 MB
```

You can also view the CPU-to-NUMA mapping:

```bash
lscpu --extended
```

Record which CPU cores belong to which NUMA node. You will need this information for vCPU pinning and memory placement in the sections that follow.

## The dangers of `vm.min_free_kbytes` on NUMA systems

The `vm.min_free_kbytes` kernel parameter controls the minimum amount of memory the kernel keeps free for emergency allocations^1^. On NUMA systems, this reservation is distributed across lowmem zones on all NUMA nodes, not applied as a single system-wide pool.

!!! danger "Setting `vm.min_free_kbytes` too high can cause immediate OOM kills"

    On a NUMA system, the kernel distributes the `vm.min_free_kbytes` reservation proportionally across each zone. If you set it to 10 GB on a system with two NUMA nodes, each node's Normal zone may be required to keep approximately 5 GB free. If one NUMA node has most of its memory committed to virtual machines, it cannot meet its watermark requirement. The kernel marks the zone as `all_unreclaimable` and triggers the OOM killer, even when other NUMA nodes have plenty of free memory.

### How the watermark distribution works

The kernel calculates per-zone minimum watermarks from `vm.min_free_kbytes`. You can view the current watermarks:

```bash
cat /proc/zoneinfo | grep -E "Node|min|low|high|managed"
```

Example output showing the per-zone distribution:

```text
Node 0, zone   Normal
  min      131072
  low      163840
  high     196608
  managed  16777216
Node 1, zone   Normal
  min      131072
  low      163840
  high     196608
  managed  16777216
```

### Safe guidelines for KVM hosts

On KVM hosts where most physical memory is committed to virtual machines, follow these guidelines:

- Keep `vm.min_free_kbytes` at a conservative value. A reasonable starting point is 1-2% of total physical memory, not exceeding a few hundred megabytes.
- Check the current value:

```bash
sysctl vm.min_free_kbytes
```

- To set a safe value (example for a 128 GB host):

```bash
sudo sysctl -w vm.min_free_kbytes=524288
```

- Make it persistent:

```bash
echo "vm.min_free_kbytes = 524288" | sudo tee /etc/sysctl.d/99-kvm-min-free.conf
sudo sysctl --system
```

!!! warning "Always check NUMA zone free memory before changing this value"

    Run `numactl --hardware` and verify that every NUMA node has significantly more free memory than its share of the proposed `vm.min_free_kbytes` value. If NUMA node 0 has only 2 GB free and you set `vm.min_free_kbytes` to 4 GB, node 0 will immediately enter a reclaim spiral.

## vCPU pinning with libvirt

By default, the KVM scheduler can migrate guest vCPUs across any host CPU core. This causes cache thrashing, cross-NUMA memory access, and unpredictable latency. vCPU pinning assigns each guest vCPU to a specific host CPU, eliminating these issues.

### Identifying available host CPUs

First, determine which host CPUs are available and their NUMA node membership:

```bash
virsh capabilities | grep -A 20 "topology"
```

Or use `lscpu`:

```bash
lscpu --extended
```

### Configuring vCPU pinning in domain XML

Edit your VM domain XML with `virsh edit`:

```bash
virsh edit your-vm-name
```

Add a `<cputune>` section^2^. Each `<vcpupin>` directive maps a guest vCPU to a specific host CPU:

```xml
<cputune>
  <vcpupin vcpu='0' cpuset='4'/>
  <vcpupin vcpu='1' cpuset='5'/>
  <vcpupin vcpu='2' cpuset='6'/>
  <vcpupin vcpu='3' cpuset='7'/>
  <emulatorpin cpuset='0-3'/>
</cputune>
```

!!! note "Terminology"

    - `vcpupin`: pins a guest vCPU to specific host CPU cores.
    - `emulatorpin`: pins the QEMU emulator threads (which handle I/O, timers, and device emulation) to specific host CPUs.

### The importance of `emulatorpin`

The `<emulatorpin>` directive is critical but often overlooked. Without it, QEMU emulator threads are free to run on any host CPU, including CPUs you have isolated for guest vCPUs. This causes contention that can deschedule guest vCPUs, leading to clock drift and application timeouts.

!!! danger "Always configure `emulatorpin`"

    Without `emulatorpin`, QEMU emulator threads can run on your isolated vCPU cores, causing the hypervisor to deschedule guest CPUs. Applications sensitive to timing (such as F5 BIG-IP, database clusters, and real-time workloads) will experience failures when vCPUs lose scheduling time.

Pin emulator threads to your housekeeping CPUs (the cores not assigned to any guest vCPU):

```xml
<emulatorpin cpuset='0-3'/>
```

### Pinning rules

Follow these rules for effective vCPU pinning:

- Pin all vCPUs to the same NUMA node as the VM memory allocation.
- Use dedicated 1:1 pinning, where each guest vCPU maps to exactly one host CPU. Avoid floating pools where multiple vCPUs share a cpuset.
- Reserve housekeeping CPUs (typically cores 0-3) for the host kernel, IRQ handling, QEMU emulator threads, and system daemons.
- Never overlap housekeeping cores with guest vCPU pins. Allowing guest vCPU pools to include housekeeping cores causes scheduling contention.

### Complete vCPU pinning example

This example shows a 12-vCPU VM pinned to NUMA node 0 with emulator threads on housekeeping cores:

```xml
<vcpu placement='static'>12</vcpu>
<cputune>
  <vcpupin vcpu='0' cpuset='4'/>
  <vcpupin vcpu='1' cpuset='5'/>
  <vcpupin vcpu='2' cpuset='6'/>
  <vcpupin vcpu='3' cpuset='7'/>
  <vcpupin vcpu='4' cpuset='8'/>
  <vcpupin vcpu='5' cpuset='9'/>
  <vcpupin vcpu='6' cpuset='10'/>
  <vcpupin vcpu='7' cpuset='11'/>
  <vcpupin vcpu='8' cpuset='12'/>
  <vcpupin vcpu='9' cpuset='13'/>
  <vcpupin vcpu='10' cpuset='14'/>
  <vcpupin vcpu='11' cpuset='15'/>
  <emulatorpin cpuset='0-3'/>
</cputune>
<numatune>
  <memory mode='strict' nodeset='0'/>
</numatune>
```

Verify the pinning after starting the VM:

```bash
virsh vcpuinfo your-vm-name
```

## CPU isolation with `isolcpus`

vCPU pinning alone does not prevent the host kernel scheduler from placing other processes on those CPUs. To fully dedicate CPUs to virtual machines, use kernel CPU isolation.

### Kernel command line parameters

Add the following to the kernel command line to isolate CPUs 4-63 for exclusive VM use:

```bash
sudo grubby --args="isolcpus=4-63 nohz_full=4-63 rcu_nocbs=4-63" --update-kernel=ALL
```

Reboot to apply:

```bash
sudo reboot
```

These parameters work together^3^:

- `isolcpus=4-63`: removes CPUs 4-63 from the general scheduler. Only explicitly pinned tasks run on them.
- `nohz_full=4-63`: disables the scheduler tick on isolated CPUs when only one task is running, reducing jitter^4^.
- `rcu_nocbs=4-63`: offloads RCU (Read-Copy-Update) callback processing from isolated CPUs to dedicated kthreads, which can then be affined to housekeeping CPUs.

### Verifying CPU isolation

After rebooting, confirm that isolation is active:

```bash
cat /sys/devices/system/cpu/isolated
```

Expected output:

```text
4-63
```

You can further verify with a stress test. Run `stress-ng` and confirm that processes only land on housekeeping CPUs:

```bash
taskset -c 0-63 stress-ng --cpu 8 --timeout 30s &
watch -n1 'ps -eo pid,psr,comm | grep stress'
```

The `PSR` column should show only CPUs 0-3 (the non-isolated housekeeping cores). If stress processes appear on isolated CPUs, the isolation configuration requires troubleshooting.

## `tuned` profiles for virtualization hosts

The `tuned` daemon provides system tuning profiles that automate kernel parameter and CPU governor settings. Rocky Linux includes profiles specifically designed for virtualization hosts.

### Installing the virtualization profiles

```bash
sudo dnf install -y tuned-profiles-cpu-partitioning
```

### Available profiles

View all available profiles:

```bash
tuned-adm list
```

The relevant profiles for KVM hosts are:

- **`virtual-host`**: basic tuning for virtualization hosts. Enables transparent hugepages and adjusts kernel scheduling parameters.
- **`cpu-partitioning`**: advanced profile that combines CPU isolation with optimized scheduling. Best for latency-sensitive VM workloads.

### Configuring `cpu-partitioning`

The `cpu-partitioning` profile requires configuration before activation. Edit the variables file:

```bash
sudo vi /etc/tuned/cpu-partitioning-variables.conf
```

Set the isolated and non-balanced cores to match your CPU isolation plan:

```ini
isolated_cores=4-63
no_balance_cores=4-63
```

!!! warning "The `no_balance_cores` option and multi-threaded tasks"

    On RHEL/Rocky Linux 8.x, the `no_balance_cores` option may not work correctly for multi-threaded processes. Multi-threaded tasks can still have their threads migrated onto nominally non-balanced cores. Verify isolation with the `stress-ng` test described in the CPU isolation section above.

Activate the profile:

```bash
sudo tuned-adm profile cpu-partitioning
```

Verify the active profile:

```bash
tuned-adm active
```

Expected output:

```text
Current active profile: cpu-partitioning
```

After activating the profile, reboot to ensure all kernel parameters are fully applied:

```bash
sudo reboot
```

### Verifying `tuned` settings

After reboot, confirm that the profile has applied the expected kernel parameters:

```bash
cat /proc/cmdline | tr ' ' '\n' | grep -E "isolcpus|nohz_full|rcu_nocbs"
```

## NUMA-aware VM placement with `virsh`

For optimal performance, a VM's memory and vCPUs must be on the same NUMA node. Accessing memory on a remote NUMA node adds significant latency.

### Configuring NUMA memory binding

In the VM domain XML, use the `<numatune>` element to bind VM memory to a specific NUMA node^2^:

```xml
<numatune>
  <memory mode='strict' nodeset='0'/>
</numatune>
```

The `strict` mode ensures that all memory allocations for this VM come from NUMA node 0. If the node does not have sufficient free memory, allocations will fail rather than silently falling back to remote memory. This may trigger the OOM killer rather than preventing VM startup, so ensure the target NUMA node has sufficient free memory before starting the VM.

### Aligning vCPU pins with NUMA memory

Ensure that the CPUs you pin vCPUs to belong to the same NUMA node as the memory binding. Using the `numactl --hardware` output from earlier, if NUMA node 0 contains CPUs 0-15, pin your vCPUs to cores within that range (excluding housekeeping cores):

```xml
<vcpu placement='static'>8</vcpu>
<cputune>
  <vcpupin vcpu='0' cpuset='4'/>
  <vcpupin vcpu='1' cpuset='5'/>
  <vcpupin vcpu='2' cpuset='6'/>
  <vcpupin vcpu='3' cpuset='7'/>
  <vcpupin vcpu='4' cpuset='8'/>
  <vcpupin vcpu='5' cpuset='9'/>
  <vcpupin vcpu='6' cpuset='10'/>
  <vcpupin vcpu='7' cpuset='11'/>
  <emulatorpin cpuset='0-3'/>
</cputune>
<numatune>
  <memory mode='strict' nodeset='0'/>
</numatune>
```

### Verifying NUMA placement at runtime

After starting the VM, verify its NUMA memory usage:

```bash
virsh numatune your-vm-name
```

Check which NUMA nodes the VM process is using:

```bash
numastat -c qemu-kvm
```

### Rebalancing VMs across NUMA nodes

If one NUMA node is overcommitted while another is underutilized, redistribute VMs between nodes. Shut down the VM, update its `<numatune>` and `<cputune>` to target the other NUMA node, then restart it:

```bash
virsh shutdown your-vm-name
virsh edit your-vm-name
# Change nodeset and vcpupin to target NUMA node 1 CPUs
virsh start your-vm-name
```

## Hugepages for KVM

Hugepages reduce TLB (Translation Lookaside Buffer) misses by using larger memory pages (2 MB or 1 GB instead of the default 4 KB). This significantly improves memory access performance for virtual machines.

### Configuring 2 MB hugepages

Calculate the number of hugepages needed. For a VM with 16 GB of memory:

```text
16384 MB / 2 MB = 8192 hugepages
```

Reserve hugepages:

```bash
echo "vm.nr_hugepages = 8192" | sudo tee /etc/sysctl.d/99-hugepages.conf
sudo sysctl --system
```

Verify the allocation:

```bash
grep HugePages /proc/meminfo
```

### Configuring hugepages in the VM domain XML

Add the `<memoryBacking>` element to use hugepages^2^:

```xml
<memoryBacking>
  <hugepages>
    <page size='2048' unit='KiB'/>
  </hugepages>
  <locked/>
</memoryBacking>
```

!!! note "The `locked` element"

    The `<locked/>` element prevents the host from swapping the VM memory. This is recommended for performance but requires sufficient physical memory. If using `<locked/>`, ensure you have enough hugepages allocated for all VMs.

### NUMA-aware hugepage allocation

For NUMA systems, allocate hugepages per node to ensure they are available where needed:

```bash
echo 4096 | sudo tee /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
echo 4096 | sudo tee /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
```

Match the hugepage allocation to the VM placement on each NUMA node.

## Putting it all together

A fully tuned VM configuration combines all the elements covered in this guide^5^. Here is a complete example for a performance-critical VM on a dual-socket Rocky Linux 9 host:

```xml
<domain type='kvm'>
  <name>production-vm</name>
  <memory unit='GiB'>16</memory>
  <vcpu placement='static'>8</vcpu>

  <cpu mode='host-passthrough'>
    <topology sockets='1' dies='1' cores='8' threads='1'/>
    <numa>
      <cell id='0' cpus='0-7' memory='16' unit='GiB'/>
    </numa>
  </cpu>

  <cputune>
    <vcpupin vcpu='0' cpuset='4'/>
    <vcpupin vcpu='1' cpuset='5'/>
    <vcpupin vcpu='2' cpuset='6'/>
    <vcpupin vcpu='3' cpuset='7'/>
    <vcpupin vcpu='4' cpuset='8'/>
    <vcpupin vcpu='5' cpuset='9'/>
    <vcpupin vcpu='6' cpuset='10'/>
    <vcpupin vcpu='7' cpuset='11'/>
    <emulatorpin cpuset='0-3'/>
  </cputune>

  <numatune>
    <memory mode='strict' nodeset='0'/>
  </numatune>

  <memoryBacking>
    <hugepages>
      <page size='2048' unit='KiB'/>
    </hugepages>
    <locked/>
  </memoryBacking>

  <!-- remaining domain configuration (disk, network, etc.) -->
</domain>
```

## Conclusion

Performance tuning KVM/libvirt on Rocky Linux requires a holistic approach that addresses CPU scheduling, memory placement, and I/O configuration together. The key principles are:

- Understand your NUMA topology before making any changes.
- Pin vCPUs to specific cores on the same NUMA node as the VM memory.
- Always configure `emulatorpin` to prevent QEMU threads from contending with guest vCPUs.
- Isolate CPUs with `isolcpus`, `nohz_full`, and `rcu_nocbs` for latency-sensitive workloads.
- Use the `cpu-partitioning` tuned profile for consistent system-wide tuning.
- Be cautious with `vm.min_free_kbytes` on NUMA systems to avoid OOM conditions.

## References

1. "Documentation for /proc/sys/vm/" by the Linux kernel documentation project [https://docs.kernel.org/admin-guide/sysctl/vm.html](https://docs.kernel.org/admin-guide/sysctl/vm.html)
2. "Domain XML format" by the libvirt project [https://libvirt.org/formatdomain.html](https://libvirt.org/formatdomain.html)
3. "The kernel's command-line parameters" by the Linux kernel documentation project [https://docs.kernel.org/admin-guide/kernel-parameters.html](https://docs.kernel.org/admin-guide/kernel-parameters.html)
4. "NO_HZ: Reducing scheduling-clock ticks" by the Linux kernel documentation project [https://docs.kernel.org/timers/no_hz.html](https://docs.kernel.org/timers/no_hz.html)
5. "KVM real time guest configuration" by the libvirt project [https://libvirt.org/kbase/kvm-realtime.html](https://libvirt.org/kbase/kvm-realtime.html)
