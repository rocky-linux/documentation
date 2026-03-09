---
title: KVM/libvirt performance tuning on Rocky Linux
author: Howard Van Der Wal
tested_with: 8, 9, 10
tags:
  - kvm
  - libvirt
  - virtualization
  - performance
  - numa
  - gpu
ai_contributors: Claude (claude-opus-4-6)
---

## Introduction

This guide covers advanced performance tuning for KVM/libvirt virtual machines on Rocky Linux. It addresses common production issues including NUMA memory misallocation, vCPU scheduling contention, and GPU passthrough optimization.

The topics covered include:

- NUMA topology awareness and memory placement
- The dangers of `vm.min_free_kbytes` on NUMA systems
- vCPU pinning with libvirt domain XML
- CPU isolation with `isolcpus` for dedicated VM workloads
- `tuned` profiles for virtualization hosts
- GPU passthrough with IOMMU and VFIO
- Diagnosing slow VM boot times
- NUMA-aware VM placement with `virsh`

## Prerequisites

- A 64-bit machine running Rocky Linux 9 with KVM/libvirt installed and configured. See the [Setting Up libvirt on Rocky Linux](https://docs.rockylinux.org/guides/virtualization/libvirt-rocky/) guide for initial setup.
- Root or `sudo` access on the hypervisor host.
- Familiarity with `virsh` and libvirt domain XML.
- A multi-socket or multi-NUMA-node server for NUMA-related sections.
- For GPU passthrough: a discrete GPU with IOMMU support and VT-d or AMD-Vi enabled in the BIOS.

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

The `vm.min_free_kbytes` kernel parameter controls the minimum amount of memory the kernel keeps free for emergency allocations. On NUMA systems, this reservation is **distributed across all memory zones and NUMA nodes**, not applied as a single system-wide pool.

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

Add a `<cputune>` section. Each `<vcpupin>` directive maps a guest vCPU to a specific host CPU:

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

- **Pin all vCPUs to the same NUMA node** as the VM memory allocation.
- **Use dedicated 1:1 pinning**, where each guest vCPU maps to exactly one host CPU. Avoid floating pools where multiple vCPUs share a cpuset.
- **Reserve housekeeping CPUs** (typically cores 0-3) for the host kernel, IRQ handling, QEMU emulator threads, and system daemons.
- **Never overlap housekeeping cores with guest vCPU pins.** Allowing guest vCPU pools to include housekeeping cores causes scheduling contention.

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

These parameters work together:

- `isolcpus=4-63`: removes CPUs 4-63 from the general scheduler. Only explicitly pinned tasks run on them.
- `nohz_full=4-63`: disables the scheduler tick on isolated CPUs when only one task is running, reducing jitter.
- `rcu_nocbs=4-63`: offloads RCU (Read-Copy-Update) callback processing from isolated CPUs to housekeeping CPUs.

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

## GPU passthrough with IOMMU and VFIO

GPU passthrough allows a virtual machine to directly access a physical GPU, achieving near-native performance. This requires IOMMU (Input/Output Memory Management Unit) support and the VFIO (Virtual Function I/O) driver framework.

### Enabling IOMMU

Ensure that VT-d (Intel) or AMD-Vi (AMD) is enabled in the BIOS. Then add the appropriate kernel parameters.

For Intel systems:

```bash
sudo grubby --args="intel_iommu=on iommu=pt" --update-kernel=ALL
```

For AMD systems:

```bash
sudo grubby --args="amd_iommu=on iommu=pt" --update-kernel=ALL
```

Reboot to apply:

```bash
sudo reboot
```

!!! note "The purpose of `iommu=pt`"

    The `iommu=pt` (passthrough) parameter enables DMA passthrough mode for devices that are not assigned to VMs. Without it, all DMA operations go through IOMMU translation, adding latency to every I/O operation on the host. Always use `iommu=pt` alongside `intel_iommu=on` or `amd_iommu=on`.

### Verifying IOMMU is active

After rebooting, confirm IOMMU is enabled:

```bash
dmesg | grep -i -e DMAR -e IOMMU
```

You should see messages indicating that IOMMU is enabled and DMAR (DMA Remapping) is active.

### Identifying the GPU IOMMU group

List IOMMU groups and find your GPU:

```bash
for d in /sys/kernel/iommu_groups/*/devices/*; do
  n=${d#*/iommu_groups/*}
  n=${n%%/*}
  printf "IOMMU Group %s: " "$n"
  lspci -nns "${d##*/}"
done | sort -t: -k1 -n
```

Note the PCI IDs for your GPU and its audio device (if present). For example:

```text
IOMMU Group 15: 41:00.0 VGA compatible controller [0300]: NVIDIA Corporation [...] [10de:2684]
IOMMU Group 15: 41:00.1 Audio device [0403]: NVIDIA Corporation [...] [10de:22ba]
```

!!! warning "All devices in an IOMMU group must be passed through together"

    If your GPU shares an IOMMU group with other devices, all devices in that group must be passed through to the same VM. If unrelated devices share the group, you may need to enable ACS (Access Control Services) override, although this has security implications.

### Binding the GPU to VFIO

Create a configuration file to bind the GPU to the `vfio-pci` driver at boot. Replace the PCI IDs with your GPU's IDs:

```bash
echo "options vfio-pci ids=10de:2684,10de:22ba" | sudo tee /etc/modprobe.d/vfio.conf
```

To prevent the native GPU driver from loading before `vfio-pci`, add a soft dependency:

```bash
echo "softdep nouveau pre: vfio-pci" | sudo tee -a /etc/modprobe.d/vfio.conf
```

!!! note "NVIDIA proprietary driver"

    If you are using the NVIDIA proprietary driver instead of `nouveau`, replace the soft dependency line with: `softdep nvidia pre: vfio-pci`

Create a `dracut` configuration to load the VFIO modules early in the initramfs:

```bash
echo 'force_drivers+=" vfio vfio_pci vfio_iommu_type1 "' | sudo tee /etc/dracut.conf.d/vfio.conf
```

!!! note "The `vfio_virqfd` module"

    On Rocky Linux 9 (kernel 5.14+), `vfio_virqfd` has been merged into the core `vfio` module and does not need to be loaded separately. On Rocky Linux 8, it is still a separate module. If you are running Rocky Linux 8, add `vfio_virqfd` to the `force_drivers` line.

Rebuild the initramfs:

```bash
sudo dracut -f --kver $(uname -r)
```

Reboot and verify the GPU is bound to `vfio-pci`:

```bash
lspci -nnk -s 41:00.0
```

The `Kernel driver in use` field should show `vfio-pci`.

### Adding the GPU to a VM

Add the GPU as a hostdev in your VM domain XML:

```xml
<hostdev mode='subsystem' type='pci' managed='yes'>
  <source>
    <address domain='0x0000' bus='0x41' slot='0x00' function='0x0'/>
  </source>
</hostdev>
```

For VMs with large GPU BARs (such as NVIDIA data center GPUs with 256 GB or larger BARs), you must configure the OVMF 64-bit MMIO window size. Add the following to your domain XML inside the `<domain>` element:

```xml
<qemu:commandline xmlns:qemu='http://libvirt.org/schemas/domain/qemu/1.0'>
  <qemu:arg value='-fw_cfg'/>
  <qemu:arg value='name=opt/ovmf/X-PciMmio64Mb,string=262144'/>
</qemu:commandline>
```

!!! note "Large GPU BAR support"

    Data center GPUs such as the NVIDIA B200 have very large prefetchable BARs (256 GB per GPU). Without the `X-PciMmio64Mb` OVMF configuration, the guest UEFI firmware cannot allocate sufficient address space for these devices.

## Diagnosing slow VM boot times

Virtual machines with GPU passthrough or many PCI devices may exhibit unusually long boot times. The delay typically occurs during the kernel phase, not during userspace initialization.

### Using `systemd-analyze` inside the guest

From within the guest VM, run:

```bash
systemd-analyze
```

Example output indicating a kernel-phase bottleneck:

```text
Startup finished in 12min 22.264s (kernel) + 20.027s (initrd) + 1min 1.747s (userspace) = 13min 44.039s
```

If the kernel phase dominates the boot time, the delay is occurring during PCI device enumeration, not in systemd services.

### Analyzing `dmesg` for PCI enumeration delays

Check the guest `dmesg` for large time gaps during PCI initialization:

```bash
dmesg -T | grep -i "pci"
```

Look for messages like:

```text
[  120.456789] pci 0000:08:00.0: reg 0x18: [mem 0x380000000000-0x383fffffffff 64bit pref]
```

Large timestamps (120+ seconds) on PCI register messages indicate that BAR (Base Address Register) sizing operations are taking a long time. Each operation requires a round trip through the VFIO stack: Guest Kernel to QEMU/KVM to Host Kernel to physical hardware and back.

### Common causes and solutions

**Missing `iommu=pt` on the host**: without passthrough mode, every DMA operation goes through IOMMU translation. Add `iommu=pt` to the host kernel cmdline.

**Missing `pci=realloc` on the guest**: this parameter allows the guest kernel to dynamically reallocate PCI resources. Add it to the guest kernel cmdline:

```bash
sudo grubby --args="pci=realloc" --update-kernel=ALL
```

**Outdated kernel**: kernels older than `5.14.0-558.el9` lack PCI BAR batch sizing optimizations. On these kernels, each BAR sizing operation runs sequentially, adding 10-20 seconds per large GPU BAR. Updating to a current Rocky Linux 9 kernel resolves this issue.

**Soft lockup warnings during boot**: messages such as `watchdog: BUG: soft lockup - CPU#76 stuck for 21s!` during PCI enumeration are a symptom of slow BAR sizing operations, not a separate issue. Updating the kernel resolves these warnings.

## NUMA-aware VM placement with `virsh`

For optimal performance, a VM's memory and vCPUs must be on the same NUMA node. Accessing memory on a remote NUMA node adds significant latency.

### Configuring NUMA memory binding

In the VM domain XML, use the `<numatune>` element to bind VM memory to a specific NUMA node:

```xml
<numatune>
  <memory mode='strict' nodeset='0'/>
</numatune>
```

The `strict` mode ensures that all memory allocations for this VM come from NUMA node 0. The VM will fail to start if the node does not have sufficient free memory, which is preferable to silently falling back to remote memory.

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

Add the `<memoryBacking>` element to use hugepages:

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

A fully tuned VM configuration combines all the elements covered in this guide. Here is a complete example for a performance-critical VM on a dual-socket Rocky Linux 9 host:

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

- **Understand your NUMA topology** before making any changes.
- **Pin vCPUs to specific cores** on the same NUMA node as the VM memory.
- **Always configure `emulatorpin`** to prevent QEMU threads from contending with guest vCPUs.
- **Isolate CPUs** with `isolcpus`, `nohz_full`, and `rcu_nocbs` for latency-sensitive workloads.
- **Use the `cpu-partitioning` tuned profile** for consistent system-wide tuning.
- **Be cautious with `vm.min_free_kbytes`** on NUMA systems to avoid OOM conditions.
- **Enable `iommu=pt`** alongside `intel_iommu=on` for GPU passthrough to reduce DMA translation overhead.
- **Keep your kernel up to date** to benefit from PCI performance improvements and bug fixes.
