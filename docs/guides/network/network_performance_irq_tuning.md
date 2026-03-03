---
title: Network performance tuning - IRQ affinity and packet drop diagnosis
author: Howard Van Der Wal
ai_contributors: Claude (claude-opus-4-6)
tested with: 8.10, 9.7, 10.1
tags:
- network
- performance
- irq
- tuning
---

## Introduction

Servers under heavy network load can experience packet drops, latency spikes, and degraded throughput even when the hardware is capable of handling the traffic. These problems often stem from how the Linux kernel distributes network interrupt processing across CPUs rather than from the network interface card (NIC) itself.

This guide covers diagnosing and resolving common network performance issues on Rocky Linux, including:

- Distinguishing kernel-level packet drops from NIC hardware drops
- Identifying and correcting IRQ imbalance across CPUs
- Tuning NIC ring buffers, channel counts, and transmit queue lengths
- Configuring irqbalance for optimal interrupt distribution
- Persisting all changes across reboots

These techniques apply to bare-metal servers and virtual machines with paravirtualized or SR-IOV network interfaces. The diagnostic commands work on any Rocky Linux system, while some tuning operations require hardware support.

## Prerequisites

Before starting, ensure you have:

- A system running Rocky Linux 8.10, 9.x, or 10.x
- Root or sudo access
- The `ethtool` package installed (`dnf install ethtool`)
- The `irqbalance` package installed (`dnf install irqbalance`)
- The `sysstat` package installed for `mpstat` (`dnf install sysstat`)
- Basic familiarity with Linux networking and the command line

Install all required packages at once:

```bash
dnf install ethtool irqbalance sysstat iproute
```

## Understanding packet drops

Packet drops on Linux can occur at two levels: the NIC hardware and the kernel software stack. Identifying where drops happen is the first step toward resolving them.

### Checking drop counters

Use `ip -s link show` to view interface statistics:

```bash
ip -s link show eth0
```

The output includes RX and TX statistics. Look for the `dropped` counter in the RX line:

```text
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 56:00:04:b2:a5:f1 brd ff:ff:ff:ff:ff:ff
    RX:  bytes packets errors dropped  missed  mcast
    1234567890 9876543   0      1523      0       0
    TX:  bytes packets errors dropped carrier collsns
    9876543210 8765432   0       0       0       0
```

For NIC-level statistics, use `ethtool -S` and filter for drop counters:

```bash
ethtool -S eth0 | grep -i drop
```

Example output:

```text
     rx_dropped: 1523
     tx_dropped: 0
     rx_dropped.nic: 0
     tx_dropped_link_down.nic: 0
```

!!! note "Counter names vary by driver"

    The exact counter names depend on the NIC driver. Intel `ice` and `i40e` drivers report `rx_dropped` and `rx_dropped.nic`. Virtio (KVM/cloud) drivers report per-queue counters like `rx_queue_0_drops`. Broadcom `bnxt_en` drivers use `rx_discard_pkts`. Check your driver documentation for the specific counter names.

### Interpreting drop counters

The distinction between `rx_dropped` and `rx_dropped.nic` is critical:

- **rx_dropped.nic: 0** means the NIC hardware received all packets successfully. The NIC ring buffer did not overflow.
- **rx_dropped: 1523** means the kernel dropped 1523 packets after the NIC delivered them. The kernel software stack could not process them fast enough.

When `rx_dropped.nic` is zero but `rx_dropped` is increasing, the problem is in the kernel, not the hardware. This pattern points to IRQ imbalance, insufficient ring buffers, or CPU saturation preventing timely packet processing.

!!! warning "Do not confuse kernel drops with NIC drops"

    A nonzero `rx_dropped` with `rx_dropped.nic: 0` does not indicate a hardware problem. Replacing cables, SFP transceivers, or NICs will not resolve kernel-level drops. Focus on IRQ distribution and kernel tuning instead.

## Diagnosing IRQ imbalance

Network interface cards generate hardware interrupts (IRQs) to notify the kernel when packets arrive. Each NIC queue has its own IRQ, and the kernel assigns each IRQ to a specific CPU. When too many IRQs land on the same CPU, that CPU becomes a bottleneck while other CPUs sit idle.

### Reading /proc/interrupts

View the current interrupt distribution:

```bash
cat /proc/interrupts | head -1; cat /proc/interrupts | grep eth0
```

Each row shows an IRQ number and the count of interrupts processed by each CPU. Look for large disparities where one CPU handles significantly more interrupts than others.

To summarize the distribution for a specific interface, count how many IRQs are assigned to each CPU:

```bash
grep eth0 /proc/interrupts | awk '{max=0; maxcpu=""; for(i=2; i<=NF; i++) {if($i ~ /^[0-9]+$/ && $i+0 > max) {max=$i+0; maxcpu=i-2}}} {print "IRQ " $1 " -> CPU " maxcpu " (" max " interrupts)"}'
```

### Checking CPU utilization

Use `mpstat` to identify CPUs that are saturated by interrupt processing:

```bash
mpstat -P ALL 1 5
```

Look for CPUs where `%irq` or `%soft` (softIRQ) utilization is high while other CPUs show near-zero values. This indicates IRQ imbalance.

### Checking softnet statistics

The file `/proc/net/softnet_stat` provides per-CPU network processing statistics. Each line corresponds to a CPU (starting from CPU 0):

```bash
cat /proc/net/softnet_stat
```

The output is in hexadecimal with the following columns:

| Column | Field        | Meaning                                            |
| ------ | ------------ | -------------------------------------------------- |
| 1      | processed    | Total packets processed by this CPU                |
| 2      | dropped      | Packets dropped (backlog overflow)                 |
| 3      | time_squeeze | Times the CPU ran out of budget before finishing   |

A nonzero `time_squeeze` value (column 3) means the kernel ran out of its `netdev_budget` before it could process all pending packets. This causes packets to remain in the ring buffer longer and can contribute to drops under burst load.

To view the statistics in a readable format:

```bash
awk '{printf "CPU%-4d processed=%-12d dropped=%-8d time_squeeze=%d\n", NR-1, strtonum("0x"$1), strtonum("0x"$2), strtonum("0x"$3)}' /proc/net/softnet_stat
```

### Checking current IRQ affinity

To see which CPU an IRQ is currently assigned to:

```bash
cat /proc/irq/45/smp_affinity_list
```

Replace `45` with the actual IRQ number from `/proc/interrupts`. The output shows which CPU or CPUs handle that IRQ.

To list the affinity for all IRQs associated with an interface:

```bash
for irq in $(grep eth0 /proc/interrupts | awk '{print $1}' | tr -d ':'); do
    echo "IRQ $irq -> CPU $(cat /proc/irq/$irq/smp_affinity_list)"
done
```

## Understanding APIC vector exhaustion

Each CPU has a limited number of APIC vectors (approximately 200 usable per CPU) for handling hardware interrupts. Every MSI/MSI-X capable PCI device consumes one or more vectors on each CPU it targets.

### How vectors become exhausted

Modern servers with multiple high-speed NICs, storage controllers, and SR-IOV virtual functions can consume hundreds of vectors. When a CPU has no free vectors remaining, the kernel cannot assign new IRQs to that CPU. This forces IRQs onto whichever CPUs still have available vectors, creating severe imbalance.

### Symptoms of vector exhaustion

- IRQ affinity scripts (such as `set_irq_affinity`) fail or produce unexpected results
- Network IRQs cluster on a small number of CPUs despite irqbalance running
- `/proc/interrupts` shows extreme skew with most CPUs handling zero network interrupts

!!! note "Vector exhaustion is not limited to SR-IOV"

    Any MSI/MSI-X capable PCI device consumes APIC vectors, including storage controllers, GPU accelerators, and InfiniBand adapters. Servers with many PCI devices can experience vector exhaustion even without SR-IOV enabled.

!!! note "Rocky Linux 9 kernel improvements"

    Rocky Linux 9 ships with kernel 5.14 and later, which includes improvements to APIC vector management introduced in Linux 4.15. These improvements reduce but do not eliminate the risk of vector exhaustion on systems with many PCI devices.

### Reducing vector consumption

The most effective way to reduce vector consumption is to lower the number of NIC queues. Each combined queue consumes one IRQ and one APIC vector per targeted CPU. Reducing a NIC from 128 to 64 combined queues cuts its vector consumption in half. See the "Tuning NIC channel count" section below.

## Configuring irqbalance

The `irqbalance` daemon automatically distributes hardware interrupts across CPUs. It runs by default on Rocky Linux and is usually the right starting point for interrupt management.

### Verifying irqbalance status

```bash
systemctl status irqbalance
```

If irqbalance is not running, enable and start it:

```bash
systemctl enable --now irqbalance
```

### Configuration file

The irqbalance configuration file is at `/etc/sysconfig/irqbalance`. Key settings include:

- **IRQBALANCE_BANNED_CPULIST**: A comma-separated list or range of CPUs that irqbalance should not assign IRQs to. This is useful for isolating CPUs dedicated to real-time or latency-sensitive workloads.

For example, to prevent irqbalance from assigning IRQs to CPUs 8-63:

```bash
# /etc/sysconfig/irqbalance
IRQBALANCE_BANNED_CPULIST=8-63
```

After changing the configuration, restart irqbalance:

```bash
systemctl restart irqbalance
```

### Verifying interrupt distribution

After restarting irqbalance, wait 10-30 seconds for it to redistribute IRQs, then check the distribution:

```bash
for irq in $(grep eth0 /proc/interrupts | awk '{print $1}' | tr -d ':'); do
    echo "IRQ $irq -> CPU $(cat /proc/irq/$irq/smp_affinity_list)"
done
```

!!! warning "Overly restrictive CPU banning can worsen imbalance"

    Banning too many CPUs forces all IRQs onto a small set of remaining CPUs. If the unbanned CPUs also run out of APIC vectors, irqbalance cannot distribute IRQs effectively. Only ban CPUs that genuinely need isolation, and verify the resulting distribution after changes.

## Manually redistributing IRQ affinity

When irqbalance cannot achieve an adequate distribution (for example, due to APIC vector constraints), you can manually pin IRQs to specific CPUs.

### Setting IRQ affinity via /proc

To assign a specific IRQ to a specific CPU:

```bash
echo 4 > /proc/irq/45/smp_affinity_list
```

This assigns IRQ 45 to CPU 4. Replace the numbers with your actual IRQ and target CPU.

### Distributing IRQs across multiple CPUs

The following script distributes all IRQs for an interface evenly across a set of CPUs:

```bash
#!/bin/bash
IFACE="eth0"
CPUS=(0 1 2 3 4 5 6 7)
IDX=0

for IRQ in $(grep "$IFACE" /proc/interrupts | awk '{print $1}' | tr -d ':'); do
    CPU=${CPUS[$IDX]}
    echo "$CPU" > /proc/irq/$IRQ/smp_affinity_list
    echo "IRQ $IRQ -> CPU $CPU"
    IDX=$(( (IDX + 1) % ${#CPUS[@]} ))
done
```

Save this script and run it with root privileges. Adjust the `CPUS` array to match the CPUs you want to handle network interrupts.

### NUMA-aware IRQ placement

For best performance, assign NIC IRQs to CPUs on the same NUMA node as the NIC. Determine the NIC NUMA node:

```bash
cat /sys/class/net/eth0/device/numa_node
```

Then list the CPUs on that NUMA node:

```bash
lscpu | grep "NUMA node"
```

Assign IRQs only to CPUs on the matching NUMA node to avoid cross-node memory access during packet processing.

!!! note "NUMA and virtual machines"

    Virtual machines and cloud instances may not expose NUMA topology or the `/sys/class/net/<iface>/device/numa_node` path. NUMA-aware IRQ placement is most relevant on bare-metal servers with multiple CPU sockets.

## Tuning NIC ring buffers

Ring buffers are fixed-size queues in the NIC where incoming packets wait for the kernel to process them. Larger ring buffers give the kernel more time to process packets before the buffer overflows and drops occur.

### Checking current ring buffer sizes

```bash
ethtool -g eth0
```

Example output:

```text
Ring parameters for eth0:
Pre-set maximums:
RX:         4096
TX:         4096
Current hardware settings:
RX:         256
TX:         256
```

### Increasing ring buffers

Set ring buffers to the maximum supported values:

```bash
ethtool -G eth0 rx 4096 tx 4096
```

Replace `4096` with the maximum values shown in the "Pre-set maximums" section of the `ethtool -g` output for your NIC.

!!! warning "Ring buffer changes and memory"

    Larger ring buffers consume more kernel memory per queue. On a NIC with 64 combined queues at 4096 entries each, this can use several hundred megabytes of memory. On systems with limited memory, increase ring buffers incrementally and monitor memory usage.

### Persisting ring buffer changes

Ring buffer settings reset on reboot. To persist them, create a NetworkManager dispatcher script:

```bash
cat > /etc/NetworkManager/dispatcher.d/20-ring-buffers <<'SCRIPT'
#!/bin/bash
IFACE=$1
ACTION=$2

if [ "$ACTION" = "up" ] && [ "$IFACE" = "eth0" ]; then
    ethtool -G eth0 rx 4096 tx 4096
fi
SCRIPT
chmod +x /etc/NetworkManager/dispatcher.d/20-ring-buffers
```

## Tuning transmit queue length

The transmit queue length (`txqueuelen`) controls how many packets the kernel can queue for transmission before dropping new ones. The default value is typically 1000.

### When to increase txqueuelen

After an OS upgrade or kernel change, the default transmit behavior may change. If you observe TX drops or application-reported packet loss that resolves when increasing the queue length, tuning `txqueuelen` may help.

### Setting txqueuelen

Check the current value:

```bash
ip link show eth0 | grep qlen
```

Set a new value:

```bash
ip link set eth0 txqueuelen 5000
```

Safe values range from 1000 to 20000. Start with the default (1000) and increase only if monitoring confirms TX drops.

!!! warning "Avoid setting txqueuelen too high"

    Values above 20000 can cause bufferbloat, where packets sit in the queue so long that they arrive at their destination too late to be useful. This manifests as high latency under load even though throughput appears normal. If latency increases after raising txqueuelen, reduce the value.

### Persisting txqueuelen with a NetworkManager dispatcher script

Create a dispatcher script that runs whenever the interface comes up:

```bash
cat > /etc/NetworkManager/dispatcher.d/30-txqueuelen <<'SCRIPT'
#!/bin/bash
IFACE=$1
ACTION=$2

if [ "$ACTION" = "up" ] && [ "$IFACE" = "eth0" ]; then
    ip link set eth0 txqueuelen 5000
fi
SCRIPT
chmod +x /etc/NetworkManager/dispatcher.d/30-txqueuelen
```

Verify the script works by restarting the interface:

```bash
nmcli connection down eth0 && nmcli connection up eth0
ip link show eth0 | grep qlen
```

### Persisting txqueuelen with udev rules

As an alternative to NetworkManager dispatcher scripts, use a udev rule:

```bash
echo 'ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth0", ATTR{tx_queue_len}="5000"' > /etc/udev/rules.d/90-txqueuelen.rules
```

Reload udev rules:

```bash
udevadm control --reload-rules
```

## Tuning NIC channel count

NIC channels (also called queues) determine how many independent packet processing paths the NIC provides. Each channel gets its own IRQ. More channels allow more parallelism but also consume more APIC vectors.

### Checking current channels

```bash
ethtool -l eth0
```

Example output:

```text
Channel parameters for eth0:
Pre-set maximums:
RX:         0
TX:         0
Other:      0
Combined:   4
Current hardware settings:
RX:         0
TX:         0
Other:      0
Combined:   2
```

### Adjusting channel count

To reduce combined queues (for example, from 128 to 64 to lower IRQ count):

```bash
ethtool -L eth0 combined 2
```

!!! note "Matching channels to CPUs"

    A common approach is to set the combined channel count equal to the number of CPUs available for network processing. Having more queues than available CPUs means some queues will share CPUs, offering no performance benefit while consuming additional APIC vectors.

### Why fewer queues can improve performance

On systems with APIC vector pressure, reducing the queue count lowers the total interrupt count. This allows the kernel to distribute the remaining IRQs more evenly across CPUs. For example, reducing from 128 to 64 combined queues on two interfaces cuts the total IRQ count from 256 to 128, significantly easing vector pressure.

## Monitoring network performance

Regular monitoring helps identify problems before they affect applications.

### Interface statistics

Monitor interface statistics in real time:

```bash
watch -n 1 'ip -s link show eth0'
```

### NIC-level counters

View all NIC statistics:

```bash
ethtool -S eth0
```

Filter for specific counters:

```bash
ethtool -S eth0 | grep -E 'rx_dropped|tx_dropped|rx_error|tx_error'
```

### softnet statistics

Monitor softnet statistics for changes over time:

```bash
watch -n 1 'awk "{printf \"CPU%-4d processed=%-12d dropped=%-8d time_squeeze=%d\n\", NR-1, strtonum(\"0x\"\$1), strtonum(\"0x\"\$2), strtonum(\"0x\"\$3)}" /proc/net/softnet_stat'
```

### Useful sysctl tunables

Two sysctl parameters control how aggressively the kernel processes network packets:

- **net.core.netdev_budget**: Maximum number of packets the kernel processes in one softIRQ cycle (default: 300)
- **net.core.netdev_budget_usecs**: Maximum time in microseconds for one softIRQ cycle (default: 2000)

Check current values:

```bash
sysctl net.core.netdev_budget
sysctl net.core.netdev_budget_usecs
```

If `/proc/net/softnet_stat` shows frequent time squeezes, increase the budget:

```bash
sysctl -w net.core.netdev_budget=600
sysctl -w net.core.netdev_budget_usecs=4000
```

Another useful tunable is `netdev_max_backlog`, which controls the per-CPU backlog queue size:

```bash
sysctl net.core.netdev_max_backlog
```

If the dropped column in `/proc/net/softnet_stat` is nonzero, increase the backlog:

```bash
sysctl -w net.core.netdev_max_backlog=5000
```

## LACP bond interface considerations

When tuning network performance on bonded interfaces, several additional factors apply.

### IRQ tuning targets slave interfaces

IRQ affinity, ring buffers, and channel count changes apply to the individual slave interfaces (such as `eth0` and `eth1`), not to the bond interface (`bond0`). The bond interface is a software construct that does not have its own IRQs or ring buffers.

```bash
# Correct: tune the slave interfaces
ethtool -G eth0 rx 4096 tx 4096
ethtool -G eth1 rx 4096 tx 4096

# This has no effect on ring buffers:
# ethtool -G bond0 rx 4096 tx 4096
```

### Transmit hash policy

The transmit hash policy determines how outbound traffic is distributed across bond slave interfaces. Check the current policy:

```bash
cat /proc/net/bonding/bond0 | grep "Transmit Hash"
```

Common policies:

- **layer2**: Hash on MAC addresses (default)
- **layer2+3**: Hash on MAC and IP addresses (better distribution for routed traffic)
- **layer3+4**: Hash on IP addresses and ports (best distribution but may reorder packets)

### Monitoring bond status

View bond status and slave interface health:

```bash
cat /proc/net/bonding/bond0
```

Check for `Link Failure Count` on each slave. A nonzero value indicates historical link flap events that warrant investigation of the physical cable, SFP transceiver, or switch port.

### Link failure detection

In LACP mode, the `miimon` parameter controls how frequently the bond driver checks link status. The default (100ms) is suitable for most environments. If link failures are not detected quickly enough, lower the value:

```bash
# Check current miimon setting
cat /proc/net/bonding/bond0 | grep "MII Polling"
```

## Persisting changes across reboots

Network tuning changes made with `sysctl`, `ethtool`, and `ip link` commands are lost on reboot. Use the following methods to make them permanent.

### sysctl.d for kernel parameters

Create a configuration file for network tuning parameters:

```bash
cat > /etc/sysctl.d/99-network-tuning.conf <<'EOF'
# Increase softIRQ processing budget
net.core.netdev_budget = 600
net.core.netdev_budget_usecs = 4000

# Increase per-CPU backlog queue
net.core.netdev_max_backlog = 5000
EOF
```

Apply without rebooting:

```bash
sysctl --system
```

### NetworkManager dispatcher scripts

Dispatcher scripts in `/etc/NetworkManager/dispatcher.d/` run automatically when interface state changes. They are the recommended method for persisting interface-specific settings on Rocky Linux 9.

The scripts shown in the ring buffer and txqueuelen sections above demonstrate this approach. Ensure scripts are executable and named with a numeric prefix for ordering:

```bash
ls -la /etc/NetworkManager/dispatcher.d/
```

### udev rules

For device-level settings that should apply regardless of NetworkManager, use udev rules in `/etc/udev/rules.d/`:

```bash
# Example: Set txqueuelen for a specific interface
echo 'ACTION=="add", SUBSYSTEM=="net", KERNEL=="eth0", ATTR{tx_queue_len}="5000"' > /etc/udev/rules.d/90-net-tuning.rules
udevadm control --reload-rules
```

### tuned profiles

The `tuned` daemon provides profiles that apply a collection of tuning parameters. Rocky Linux includes several network-oriented profiles:

```bash
tuned-adm list | grep -i network
```

The `network-throughput` and `network-latency` profiles apply standard network optimizations. Apply a profile:

```bash
tuned-adm profile network-throughput
```

Verify the profile is active and all settings match:

```bash
tuned-adm active
tuned-adm verify
```

!!! warning "Tuned profile drift"

    If `tuned-adm verify` reports that current settings differ from the profile, manual changes or other services have overridden the tuned settings. Re-apply the profile and investigate which service is modifying the settings.

## Conclusion

Network performance issues on Rocky Linux most often come from software-level bottlenecks in how the kernel distributes and processes network interrupts, rather than from hardware failures. The diagnostic and tuning workflow follows this order:

1. **Identify where drops occur**: Use `ethtool -S` to determine if drops are at the kernel level (`rx_dropped` with `rx_dropped.nic: 0`) or the NIC level
2. **Check IRQ distribution**: Read `/proc/interrupts` and `/proc/net/softnet_stat` to find imbalance and time squeezes
3. **Reduce interrupt count**: Lower combined queue count with `ethtool -L` to ease APIC vector pressure
4. **Increase buffer capacity**: Raise ring buffers with `ethtool -G` and transmit queue length with `ip link set`
5. **Redistribute IRQs**: Configure irqbalance or manually pin IRQs to spread the load evenly across CPUs
6. **Tune kernel parameters**: Adjust `netdev_budget` and `netdev_max_backlog` via sysctl
7. **Persist all changes**: Use sysctl.d files, NetworkManager dispatcher scripts, and tuned profiles to survive reboots
8. **Monitor continuously**: Watch drop counters and softnet statistics over time to verify improvements
