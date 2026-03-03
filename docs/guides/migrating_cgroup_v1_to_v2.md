---
title: Migrating from cgroup v1 to cgroup v2 on Rocky Linux
author: Howard Van Der Wal
ai_contributors: Claude (claude-opus-4-6)
tested with: 8.10
tags:
- cgroups
- containers
- hpc
- podman
- slurm
---

## Introduction

Control groups (cgroups) are a Linux kernel feature that organizes processes into hierarchical groups to manage and limit system resources such as CPU, memory, and I/O. The cgroup v2 interface (also called the unified hierarchy) replaces the original cgroup v1 interface with a single, consistent tree structure.

Rocky Linux 8 defaults to cgroup v1. Migrating to cgroup v2 is necessary when:

- Running rootless Podman containers (cgroup v1 does not support rootless cgroups)
- Using Slurm 25.x or later on newer hardware where cgroup v1 causes instability
- Preparing for Rocky Linux 9 and later, where cgroup v2 is the default

This guide walks through enabling cgroup v2 on Rocky Linux 8.10, verifying the migration, resolving common issues with systemd 239, configuring rootless Podman, and integrating with Slurm on HPC compute nodes.

## Prerequisites

Before starting, ensure you have:

- A system running Rocky Linux 8.10
- Root or sudo access
- A current backup or snapshot of the system
- Knowledge of the current cgroup version in use

Verify your current cgroup version:

```bash
mount | grep cgroup
```

If the output shows `tmpfs on /sys/fs/cgroup type tmpfs` with multiple `cgroup` mount points beneath it, you are running cgroup v1. A single `cgroup2` mount point indicates cgroup v2 is already enabled.

Check your kernel and systemd versions:

```bash
uname -r
systemctl --version
```

Rocky Linux 8.10 ships with systemd 239, which has known limitations with cgroup v2. This guide addresses those limitations.

## Enabling cgroup v2

Enable the unified cgroup hierarchy by adding a kernel boot parameter:

```bash
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1"
```

!!! warning "Additional parameters for Slurm environments"

    If you are running Slurm, SchedMD recommends adding two additional parameters to prevent cgroup v1 controllers from loading alongside cgroup v2:

    ```bash
    sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1 systemd.legacy_systemd_cgroup_controller=0 cgroup_no_v1=all"
    ```

    The `systemd.legacy_systemd_cgroup_controller=0` parameter prevents systemd from mounting a hybrid cgroup v1/v2 hierarchy. The `cgroup_no_v1=all` parameter disables all cgroup v1 controllers at the kernel level.

Reboot the system for the changes to take effect:

```bash
sudo reboot
```

## Verifying the migration

After rebooting, confirm cgroup v2 is active.

Check the cgroup mount:

```bash
mount -l | grep cgroup
```

Expected output:

```text
cgroup2 on /sys/fs/cgroup type cgroup2 (rw,nosuid,nodev,noexec,relatime,seclabel,nsdelegate)
```

Verify the available controllers:

```bash
cat /sys/fs/cgroup/cgroup.controllers
```

Expected output:

```text
cpuset cpu io memory hugetlb pids rdma
```

Check the process cgroup assignment:

```bash
cat /proc/self/cgroup
```

Expected output (single line, unified hierarchy):

```text
0::/user.slice/user-1000.slice/session-1.scope
```

If you see multiple lines with numbered controllers (for example, `1:memory:/`, `2:cpu:/`), cgroup v1 is still active. Verify the grubby parameter was applied correctly:

```bash
cat /proc/cmdline | grep unified
```

## Enabling missing controllers on systemd 239

Rocky Linux 8.10 ships with systemd 239, which does not enable all cgroup v2 controllers by default. After migration, you may find that `cpu` and `cpuset` controllers are missing from the subtree control:

```bash
cat /sys/fs/cgroup/cgroup.subtree_control
```

If the output shows only `memory pids` instead of `cpuset cpu memory pids`, follow the steps below.

!!! warning "systemd 239 cpuset limitation"

    systemd versions earlier than 244 do not natively support the cpuset interface in cgroup v2. Rocky Linux 8.10 ships systemd 239. Enabling CPU accounting adds the `cpu` controller, and the `cpuset` controller must be enabled separately. A reboot is required for the changes to take full effect.

### Step 1: Enable CPU accounting

Edit `/etc/systemd/system.conf` and set `DefaultCPUAccounting=yes`:

```bash
sudo sed -i 's/^#DefaultCPUAccounting=no/DefaultCPUAccounting=yes/' /etc/systemd/system.conf
```

If the line does not exist, add it under the `[Manager]` section:

```ini
[Manager]
DefaultCPUAccounting=yes
```

### Step 2: Reload and reboot

```bash
sudo systemctl daemon-reload
sudo reboot
```

### Step 3: Enable the cpuset controller

After rebooting, verify the current state:

```bash
cat /sys/fs/cgroup/cgroup.subtree_control
```

You should see `cpu memory pids`. The `cpuset` controller is available but not yet in the subtree. Enable it:

```bash
echo "+cpuset" | sudo tee /sys/fs/cgroup/cgroup.subtree_control
```

Verify all controllers are now active:

```bash
cat /sys/fs/cgroup/cgroup.subtree_control
```

Expected output:

```text
cpuset cpu memory pids
```

!!! note "Persistent cpuset enablement"

    The manual `echo "+cpuset"` command does not survive reboots. On Slurm compute nodes, the `EnableControllers=yes` setting in `/etc/slurm/cgroup.conf` handles controller delegation automatically, including cpuset, so manual enablement is not needed. For non-Slurm systems, add the command to a systemd service to make it persistent. On some systems, `echo "+cpuset"` may fail with `Invalid argument` if real-time (FIFO/RR) kernel processes are running. In that case, a reboot after setting `DefaultCPUAccounting=yes` may resolve the issue.

## PAM configuration

When connecting over ssh, the `pam_systemd.so` module registers the user session with systemd, which creates the `/run/user/$UID` directory and sets the `XDG_RUNTIME_DIR` and `DBUS_SESSION_BUS_ADDRESS` environment variables. These are required for rootless containers and other user-level services that communicate over D-Bus.

On a default Rocky Linux 8.10 installation, `pam_systemd.so` is loaded through the `password-auth` include in `/etc/pam.d/sshd`. Check whether it is active:

```bash
grep pam_systemd /etc/pam.d/sshd /etc/pam.d/password-auth
```

If the line is commented out in `/etc/pam.d/password-auth` (common on HPC compute nodes where it was intentionally disabled), you can re-enable it by adding it directly to `/etc/pam.d/sshd` after the `pam_selinux.so open env_params` line:

```bash
sudo sed -i '/pam_selinux.so open env_params/a session    optional     pam_systemd.so' /etc/pam.d/sshd
```

Restart `systemd-logind` for the change to take effect:

```bash
sudo systemctl restart systemd-logind
```

Verify by opening a new ssh session (do not use `sudo -i -u` or `su`, as these do not trigger PAM session modules) and checking:

```bash
echo $XDG_RUNTIME_DIR
echo $DBUS_SESSION_BUS_ADDRESS
cat /proc/self/cgroup
```

Expected output:

```text
/run/user/<UID>
unix:path=/run/user/<UID>/bus
0::/user.slice/user-<UID>.slice/session-<N>.scope
```

!!! warning "HPC compute nodes with pam_slurm_adopt"

    If you use `pam_slurm_adopt` on compute nodes, do NOT enable `pam_systemd.so` in the PAM configuration. The `pam_slurm_adopt` documentation states it should be the last session module and that `pam_systemd.so` should be disabled. See the "HPC compute node configuration" section below for the recommended approach.

## Rootless Podman compatibility

Rootless Podman requires cgroup v2. With cgroup v1, rootless cgroup management is not supported by the kernel.

### Cgroup manager configuration

After migrating to cgroup v2, Podman defaults to using `systemd` as its cgroup manager. This requires an active systemd user session with a D-Bus socket. In environments where user sessions are not available (such as HPC compute nodes or batch jobs), configure Podman to use `cgroupfs` instead.

Create or edit `~/.config/containers/containers.conf`:

```ini
[engine]
cgroup_manager = "cgroupfs"
```

For system-wide configuration, edit `/etc/containers/containers.conf`.

### Known podman stats warnings

On Rocky Linux 8.10 with Podman 4.9.x, running `podman stats` may produce warnings:

```text
WARN[0005] Failed to retrieve cgroup stats: open /sys/fs/cgroup/.../memory.stat: no such file or directory
WARN[0005] Failed to retrieve cgroup stats: open /sys/fs/cgroup/.../pids.current: no such file or directory
```

!!! note "Cosmetic warnings in Podman 4.9.x"

    These warnings are caused by a race condition where the container cgroup directory is removed before `podman stats` finishes reading it. This is a cosmetic issue only and does not affect container functionality. The fix was merged into Podman 5.3 ([GitHub PR #24400](https://github.com/containers/podman/pull/24400)) but has not been backported to the 4.9.x series shipped with Rocky Linux 8.

!!! warning "NFS-backed container storage"

    If your container storage paths are on NFS, Podman may display:

    ```text
    WARN[0000] Network file system detected as backing store. Enforcing overlay option `force_mask="700"`. Add it to storage.conf to silence this warning
    ```

    NFS does not support `chown` operations required by rootless Podman. Use local storage (such as XFS) for the container graph root and tmpfs (`/dev/shm`) for the run root. Example `~/.config/containers/storage.conf`:

    ```ini
    [storage]
    driver = "overlay"
    graphroot = "/local/podman/graphroot"
    runroot = "/dev/shm/runroot"

    [storage.options]
    mount_program = "/usr/bin/fuse-overlayfs"
    ```

## Slurm considerations

Slurm supports cgroup v2 for job resource isolation. The following configuration changes are needed on the Slurm controller and compute nodes.

### Slurm cgroup configuration

Edit `/etc/slurm/cgroup.conf` on all nodes:

```ini
ConstrainCores=yes
ConstrainRAMSpace=yes
ConstrainSwapSpace=yes
ConstrainDevices=no
AllowedSwapSpace=0
EnableControllers=yes
```

The `EnableControllers=yes` setting tells Slurm to enable the cgroup controllers it needs in the cgroup v2 subtree.

### Slurmd service delegation

Ensure the `slurmd` service has cgroup delegation enabled. Create a systemd drop-in:

```bash
sudo mkdir -p /etc/systemd/system/slurmd.service.d
cat <<'EOF' | sudo tee /etc/systemd/system/slurmd.service.d/delegate.conf
[Service]
Delegate=yes
EOF
sudo systemctl daemon-reload
sudo systemctl restart slurmd
```

!!! tip "Mixed cgroup v1 and v2 clusters"

    If your cluster has some nodes on cgroup v1 and others on cgroup v2, use the default `CgroupPlugin=autodetect` setting in `slurm.conf`. Each node will detect its own cgroup version independently. Do not set `CgroupPlugin=cgroup/v2` unless all nodes have been migrated.

### Restart the Slurm controller

After changing `cgroup.conf`, restart `slurmctld` on the controller node:

```bash
sudo systemctl restart slurmctld
```

Verify the configuration:

```bash
scontrol show config | grep EnableControllers
scontrol show config | grep CgroupPlugin
```

## HPC compute node configuration (cgroupfs approach)

On HPC compute nodes managed by Slurm with `pam_slurm_adopt`, the recommended approach is to use `cgroupfs` as the Podman cgroup manager instead of relying on systemd user sessions. This eliminates the need for `pam_systemd.so` and linger mode on shared compute nodes.

This approach was validated through a joint call with SchedMD, where they confirmed that Podman can run without linger mode or `XDG_RUNTIME_DIR` from systemd by using `cgroupfs` as the cgroup manager.

### Containers configuration

Create `/etc/containers/containers.conf` on compute nodes:

```ini
[containers]
cgroupns = "host"

[engine]
cgroup_manager = "cgroupfs"
runtime = "crun"

[engine.runtimes]
crun = ["/usr/bin/crun"]
```

The `cgroupns = "host"` setting keeps containers within the Slurm job cgroup hierarchy, ensuring that Slurm resource limits (CPU, memory) are enforced on containers.

### PAM configuration for compute nodes

On compute nodes using `pam_slurm_adopt`, keep `pam_systemd.so` disabled in all PAM files:

- `/etc/pam.d/system-auth`: `#-session optional pam_systemd.so`
- `/etc/pam.d/password-auth`: `#-session optional pam_systemd.so`
- `/etc/pam.d/sshd`: `#session optional pam_systemd.so`

### Slurm prolog and epilog scripts

Since `pam_systemd.so` is disabled, Slurm prolog and epilog scripts create and clean up `/run/user/$UID` for each job.

Create `/etc/slurm/prolog.sh`:

```bash
#!/bin/bash
RUN_DIR="/run/user/$(id -u "$SLURM_JOB_USER")"
if [ ! -d "$RUN_DIR" ]; then
    mkdir -p "$RUN_DIR"
    chown "$SLURM_JOB_USER":"$(id -gn "$SLURM_JOB_USER")" "$RUN_DIR"
    chmod 700 "$RUN_DIR"
fi
exit 0
```

Create `/etc/slurm/epilog.sh`:

```bash
#!/bin/bash
RUN_DIR="/run/user/$(id -u "$SLURM_JOB_USER")"
OTHER_JOBS=0
for pid in $(scontrol listpids 2>/dev/null | awk -v jid="$SLURM_JOB_ID" 'NR!=1 { if ($2 != jid && $1 != "-1"){print $1} }'); do
    ps --noheader -o euser p "$pid" 2>/dev/null | grep -q "$SLURM_JOB_USER" && OTHER_JOBS=1
done
if [ "$OTHER_JOBS" -eq 0 ]; then
    [ -d "$RUN_DIR" ] && rm -rf "$RUN_DIR"
fi
exit 0
```

Create `/etc/slurm/task_prolog.sh`:

```bash
#!/bin/bash
echo "export XDG_RUNTIME_DIR=/run/user/$SLURM_JOB_UID"
```

Make the scripts executable and add them to `slurm.conf`:

```bash
sudo chmod 755 /etc/slurm/prolog.sh /etc/slurm/epilog.sh /etc/slurm/task_prolog.sh
```

Add to `slurm.conf`:

```ini
Prolog=/etc/slurm/prolog.sh
Epilog=/etc/slurm/epilog.sh
TaskProlog=/etc/slurm/task_prolog.sh
```

Restart the Slurm controller after updating `slurm.conf`:

```bash
sudo systemctl restart slurmctld
```

!!! warning "Linger mode on shared HPC nodes"

    Avoid using `loginctl enable-linger` on shared compute nodes without additional hardening. Linger mode allows user processes to persist beyond job completion, which can lead to unrestricted resource consumption, reduced audit visibility, and processes outside of Slurm job accounting. The cgroupfs approach with prolog and epilog scripts is the recommended alternative.

## Troubleshooting

### cgroup v2 not active after reboot

Verify the kernel parameter is set:

```bash
cat /proc/cmdline | grep unified
```

If `systemd.unified_cgroup_hierarchy=1` does not appear, the grubby command may not have applied to the current kernel. Re-run with the explicit kernel path:

```bash
sudo grubby --update-kernel=/boot/vmlinuz-$(uname -r) --args="systemd.unified_cgroup_hierarchy=1"
```

### XDG_RUNTIME_DIR not set after ssh login

Verify `pam_systemd.so` is enabled in `/etc/pam.d/sshd`:

```bash
grep pam_systemd /etc/pam.d/sshd
```

If the line is present but `XDG_RUNTIME_DIR` is still unset, restart `systemd-logind` and open a new ssh session:

```bash
sudo systemctl restart systemd-logind
```

Do not test with `su` or `sudo -i -u`; these do not trigger PAM session modules.

### D-Bus session bus errors with rootless Podman

If you see:

```text
dbus: couldn't determine address of session bus
Failed to create bus connection: No such file or directory
```

Check that `$DBUS_SESSION_BUS_ADDRESS` is set and the bus socket exists:

```bash
echo $DBUS_SESSION_BUS_ADDRESS
ls -la /run/user/$(id -u)/bus
```

If the bus socket is missing, verify `pam_systemd.so` is enabled as described in the PAM configuration section. For HPC compute nodes, switch to the cgroupfs cgroup manager instead, which does not require a D-Bus session.

### Slurm jobs fail with "Controller cpuset is not enabled"

This indicates the cpuset controller is not available in the Slurm cgroup scope. Verify:

```bash
cat /sys/fs/cgroup/cgroup.subtree_control
```

If `cpuset` and `cpu` are missing, follow the "Enabling missing controllers on systemd 239" section above. Ensure `DefaultCPUAccounting=yes` is set in `/etc/systemd/system.conf` and that the node has been rebooted.

Also verify that `EnableControllers=yes` is set in `/etc/slurm/cgroup.conf` and that `slurmctld` has been restarted.

### Podman falls back to cgroupfs with warnings

If every Podman command shows:

```text
WARN[0000] The cgroupv2 manager is set to systemd but there is no systemd user session available
WARN[0000] Falling back to --cgroup-manager=cgroupfs
```

This means Podman cannot find an active systemd user session. Either enable `pam_systemd.so` for proper user sessions, or set `cgroup_manager = "cgroupfs"` in your containers.conf to use cgroupfs intentionally and suppress the warnings.

## Conclusion

Migrating from cgroup v1 to cgroup v2 on Rocky Linux 8.10 requires addressing the limitations of systemd 239. The key steps are:

1. Enable the unified hierarchy via kernel boot parameters
2. Enable missing controllers with `DefaultCPUAccounting=yes`
3. Configure PAM for proper user sessions (or use prolog/epilog scripts in HPC environments)
4. Set the appropriate cgroup manager for Podman
5. Update Slurm cgroup configuration with `EnableControllers=yes`

For HPC environments, the cgroupfs approach with Slurm prolog and epilog scripts provides a robust solution that does not require systemd user sessions or linger mode on shared compute nodes.
