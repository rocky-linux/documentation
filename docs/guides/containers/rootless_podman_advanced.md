---
title: Rootless Podman on Rocky Linux
author: Howard Van Der Wal
ai_contributors: Claude (claude-opus-4-6)
tested with: 8.10, 9.7, 10.1
tags:
- podman
- containers
- rootless
- cgroups
---

## Introduction

Rootless Podman runs containers entirely within a non-root user's namespace, eliminating the need for a privileged daemon. While the basic setup is straightforward, production environments — especially HPC clusters and multi-user systems — encounter issues around user namespace mappings, filesystem compatibility, networking limitations, and system service integration.

This guide covers advanced rootless Podman configuration and troubleshooting on Rocky Linux 8, 9, and 10. Topics include verifying cgroups v2 and user namespace support, configuring subordinate ID mappings, resolving supplementary group visibility problems, handling NFS incompatibility, understanding multicast limitations, fixing D-Bus session bus errors, and writing robust wrapper scripts.

## Prerequisites

Before starting, ensure you have:

- A system running Rocky Linux 8, 9, or 10 with cgroups v2 enabled.
- User namespaces enabled (the default on all supported Rocky Linux versions).
- `/etc/subuid` and `/etc/subgid` configured for each non-root user who will run containers.
- The `podman` package installed.
- `slirp4netns` or `pasta` installed for rootless networking.
- `pam_systemd.so` enabled in PAM configuration (required for D-Bus and `XDG_RUNTIME_DIR`).
- Root access for system-level configuration changes.

Install Podman and the rootless networking dependencies:

```bash
dnf install podman slirp4netns
```

!!! note

    Rocky Linux 9 and 10 ship with Podman 5.x, which uses `pasta` as the default rootless network backend. Rocky Linux 8 ships with Podman 4.x and uses `slirp4netns`. Installing `slirp4netns` on Rocky Linux 9 and 10 provides a fallback if `pasta` is unavailable.

## Verifying cgroups v2 and user namespace support

Rootless Podman requires cgroups v2 (the unified hierarchy) and unprivileged user namespaces. Rocky Linux 9 and 10 enable both by default. Rocky Linux 8 defaults to cgroups v1 and requires a kernel parameter change.

### Confirm cgroups v2

Check the filesystem type mounted at `/sys/fs/cgroup`:

```bash
stat -fc %T /sys/fs/cgroup
```

The expected output is:

```text
cgroup2fs
```

If the output is `tmpfs`, your system is running cgroups v1. Rocky Linux 8 defaults to cgroups v1. Enable cgroups v2 by adding the unified hierarchy kernel parameter and rebooting:

```bash
sudo grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1"
sudo reboot
```

After the reboot, run the `stat` command again to confirm the output is `cgroup2fs`. Rocky Linux 9 and 10 use cgroups v2 by default and do not require this step.

### Confirm user namespace support

Verify that user namespaces are enabled and the maximum count is greater than zero:

```bash
sysctl user.max_user_namespaces
```

The expected output is:

```text
user.max_user_namespaces = 31790
```

Any non-zero value is acceptable. If the value is `0`, enable user namespaces:

```bash
echo "user.max_user_namespaces = 31790" | sudo tee /etc/sysctl.d/userns.conf
sudo sysctl --system
```

## Configuring /etc/subuid and /etc/subgid

Rootless Podman uses subordinate UID and GID ranges from `/etc/subuid` and `/etc/subgid` to map container users into the host user namespace. Each non-root user who runs containers needs entries in both files.

### Format and meaning of entries

Each line in `/etc/subuid` and `/etc/subgid` follows the format:

```text
username:start_id:count
```

- `username` — the login name of the user.
- `start_id` — the first subordinate ID allocated to this user.
- `count` — how many subordinate IDs this user can use.

For example:

```text
testuser:100000:65536
```

This gives `testuser` subordinate IDs 100000 through 165535 (65536 IDs total), enough for a full container user namespace.

### Adding subordinate ranges for users

Add entries for a new user:

```bash
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 testuser
```

Verify the entries:

```bash
grep testuser /etc/subuid
grep testuser /etc/subgid
```

!!! warning

    After any change to `/etc/subuid` or `/etc/subgid`, you must run `podman system migrate` to apply the new mappings. Stop any running containers first — `podman system migrate` will force-stop them if they are still running, which may cause data loss.

Apply the changes:

```bash
podman system migrate
```

If the migration command does not resolve the issue, a full reset clears all container state:

```bash
podman system reset --force
```

!!! danger

    `podman system reset --force` deletes all containers, images, and volumes for the current user. Use this only when `podman system migrate` does not resolve the mapping issue.

## Interaction with Apptainer fakeroot

Apptainer (formerly Singularity) and Podman share the same `/etc/subuid` and `/etc/subgid` files for user namespace mappings. This means:

- Subordinate UID and GID ranges configured for Podman also work for Apptainer fakeroot builds.
- Changes to either file affect both tools.

After modifying `/etc/subuid` or `/etc/subgid`, verify Apptainer fakeroot still works:

```bash
apptainer exec --fakeroot docker://alpine:latest id
```

!!! note

    If your environment uses both Podman and Apptainer, coordinate subordinate ID ranges to avoid overlapping allocations between users.

## Known limitation: multicast networking

Rootless containers cannot use IP multicast. Multicast requires the `IP_ADD_MEMBERSHIP` socket option, which the kernel blocks inside user namespaces even when the container has `CAP_NET_ADMIN`.

Attempting multicast in a rootless container produces an error similar to:

```text
OSError: [Errno 19] No such device
```

### Workaround

The only way to use multicast from a container is to run it with host networking:

```bash
podman run --network=host your-multicast-app
```

!!! warning

    Using `--network=host` removes network namespace isolation. The container shares the host's network stack, including all interfaces and ports. Evaluate the security implications before using this option in production.

Adding `CAP_NET_ADMIN` alone does not fix multicast in rootless mode:

```bash
# This does NOT enable multicast — user namespace restrictions still apply
podman run --cap-add=NET_ADMIN your-multicast-app
```

## NFS and shared filesystem incompatibility

Rootless Podman stores container images and runtime state in `graphroot` and `runroot` directories. These directories require POSIX filesystem operations including `chown` across multiple UIDs in the subordinate range. NFS v4 does not support these operations and produces errors such as:

```text
chown ... operation not permitted
```

### Keep storage on local filesystems

Configure Podman to use local storage paths. Edit the user-level storage configuration file:

```bash
mkdir -p ~/.config/containers
```

Create or edit `~/.config/containers/storage.conf`:

```ini
[storage]
driver = "overlay"
graphroot = "/home/testuser/.local/share/containers/storage"
runroot = "/run/user/1000/containers"
```

Replace `/home/testuser` and `1000` with the appropriate home directory and UID for the user.

!!! warning

    Do not place `graphroot` or `runroot` on NFS, GPFS, Lustre, or other network filesystems. Rootless Podman requires a local POSIX-compliant filesystem such as XFS or ext4.

### Alternative for HPC shared-filesystem workflows

In HPC environments where containers must run from shared storage, consider NVIDIA enroot as an alternative container runtime. Enroot is designed for unprivileged container execution on shared filesystems and does not require subordinate UID/GID mappings.

!!! danger

    Never install enroot with file capabilities (`enroot+caps`). File capabilities conflict with unprivileged user namespaces and cause permission failures. Use the standard `enroot` package without capabilities.

## Supplementary group visibility in containers

When a user belongs to supplementary groups (such as a shared project group on an HPC cluster), those groups may appear as `nobody(65534)` inside a rootless container when using the `--group-add=keep-groups` flag. This flag is intended to pass all host supplementary groups automatically, but it does not map them correctly in rootless mode.

### Symptoms

Running `id` inside a container with `--group-add=keep-groups` shows incorrect group membership:

```bash
podman run --rm --userns=keep-id \
  --group-add=keep-groups \
  docker.io/library/alpine:latest id
```

Supplementary groups appear as `nobody(65534)` instead of the actual GIDs:

```text
uid=1001(testuser) gid=1001(testuser) groups=1001(testuser),65534(nobody),65534(nobody)
```

### Using explicit group IDs

The fix is to specify each supplementary GID explicitly with `--group-add` instead of using `--group-add=keep-groups`.

Identify the user's supplementary GIDs:

```bash
id -G testuser
```

Example output:

```text
1001 2001 2002
```

Run the container with each supplementary GID (other than the primary GID) specified explicitly:

```bash
podman run --rm --userns=keep-id \
  --group-add 2001 --group-add 2002 \
  docker.io/library/alpine:latest id
```

The output shows the correct GIDs:

```text
uid=1001(testuser) gid=1001(testuser) groups=1001(testuser),2001,2002
```

!!! note

    The GID numbers appear without group names because the container image does not have `/etc/group` entries for your custom groups. The numeric GIDs are correct and functional for file permission checks.

## Troubleshooting: D-Bus session bus errors

After migrating to cgroups v2 or on systems where PAM configuration has been modified, rootless Podman may fail with an error such as:

```text
Error: creating events dirs: mkdir /run/user/1001: permission denied
```

This error occurs because `systemd-logind` is not creating the user runtime directory (`/run/user/<UID>`) that rootless Podman depends on. The root cause is typically `pam_systemd.so` being disabled or commented out in the PAM configuration.

### Verify the issue

Check whether `XDG_RUNTIME_DIR` is set for the user:

```bash
echo $XDG_RUNTIME_DIR
```

If this variable is empty or unset, the PAM session module is not running.

Check the D-Bus session bus address:

```bash
echo $DBUS_SESSION_BUS_ADDRESS
```

If this variable is also empty, confirm that `pam_systemd.so` is enabled.

### Re-enabling `pam_systemd.so`

Check the PAM configuration files for `pam_systemd.so`:

```bash
grep pam_systemd /etc/pam.d/system-auth
grep pam_systemd /etc/pam.d/password-auth
```

If the lines are commented out (prefixed with `#`), uncomment them:

```bash
sudo sed -i 's/^#\(-session.*pam_systemd.so\)/\1/' /etc/pam.d/system-auth
sudo sed -i 's/^#\(-session.*pam_systemd.so\)/\1/' /etc/pam.d/password-auth
```

On Rocky Linux 9, the lines use the `-session` form (the leading dash tells PAM to ignore errors if the module is missing):

```text
-session   optional pam_systemd.so
```

Restart `systemd-logind` to apply the changes:

```bash
sudo systemctl restart systemd-logind
```

!!! warning

    Restarting `systemd-logind` terminates all user sessions. Run this command from a console session or ensure you can reconnect via SSH.

Log out and log back in, then verify the environment variables are set:

```bash
echo $XDG_RUNTIME_DIR
echo $DBUS_SESSION_BUS_ADDRESS
```

Expected output:

```text
/run/user/1000
unix:path=/run/user/1000/bus
```

Rootless Podman commands should now work without D-Bus errors.

## Custom wrapper scripts: detecting subcommands with global flags

In environments that inject network configuration (such as HTTP proxies) into containers, administrators often use wrapper scripts around the `podman` command. A common mistake is checking only the first argument (`$1`) for the `run` subcommand, which fails when global flags appear before `run`:

```bash
# This wrapper FAILS when global flags precede "run"
# Example: podman --log-level=debug run ...
if [ "$1" = "run" ]; then
    exec /usr/bin/podman run --network=custom "$@"
fi
```

### Correct approach

Iterate through all arguments to find the `run` subcommand:

```bash
#!/bin/bash
# Podman wrapper that injects network configuration for "run" commands
# Handles global flags that may appear before the subcommand

PODMAN=/usr/bin/podman
FOUND_RUN=0
ARGS=()

for arg in "$@"; do
    if [ "$FOUND_RUN" -eq 0 ] && [ "$arg" = "run" ]; then
        FOUND_RUN=1
        ARGS+=("run" "--network=custom")
        continue
    fi
    ARGS+=("$arg")
done

exec "$PODMAN" "${ARGS[@]}"
```

This wrapper correctly handles invocations such as:

```bash
podman run myimage                        # run is $1
podman --log-level=debug run myimage      # run is $2
podman --remote --log-level=info run myimage  # run is $3
```

!!! note

    Adjust the `--network=custom` flag to match your environment's network configuration requirements.

## Conclusion

Rootless Podman on Rocky Linux 8, 9, and 10 provides secure, unprivileged container execution, but advanced deployments require attention to user namespace configuration, filesystem compatibility, and system service integration. The key points covered in this guide are:

- Verify cgroups v2 and user namespace support before configuring rootless containers. Rocky Linux 8 requires a kernel parameter change to enable cgroups v2.
- Use explicit `--group-add <GID>` instead of `--group-add=keep-groups` to pass supplementary groups into rootless containers.
- Keep container storage on local filesystems — NFS and other network filesystems are not compatible with rootless Podman.
- Multicast networking is a known limitation of user namespaces and requires `--network=host` as a workaround.
- Runtime directory errors typically trace back to `pam_systemd.so` being disabled in PAM configuration.
- Wrapper scripts must iterate through arguments to find subcommands, because global flags can appear first.

## References

1. "Apptainer User Guide: Fakeroot feature" by the Apptainer Team [https://apptainer.org/docs/user/main/fakeroot.html](https://apptainer.org/docs/user/main/fakeroot.html)
2. "Basic Networking Guide for Podman" by the Podman Team [https://github.com/containers/podman/blob/main/docs/tutorials/basic_networking.md](https://github.com/containers/podman/blob/main/docs/tutorials/basic_networking.md)
3. "Basic Setup and Use of Podman in a Rootless environment" by the Podman Team [https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)
4. "containers-storage.conf(5) Container Storage Configuration File" by the Containers Team [https://github.com/containers/storage/blob/main/docs/containers-storage.conf.5.md](https://github.com/containers/storage/blob/main/docs/containers-storage.conf.5.md)
5. "Enroot" by NVIDIA [https://github.com/NVIDIA/enroot](https://github.com/NVIDIA/enroot)
6. "Podman documentation" by the Podman Team [https://docs.podman.io/en/latest/](https://docs.podman.io/en/latest/)
7. "subuid(5) — subordinate user IDs" by the Linux man-pages Project [https://man7.org/linux/man-pages/man5/subuid.5.html](https://man7.org/linux/man-pages/man5/subuid.5.html)
8. "Troubleshooting" by the Podman Team [https://github.com/containers/podman/blob/main/troubleshooting.md](https://github.com/containers/podman/blob/main/troubleshooting.md)
