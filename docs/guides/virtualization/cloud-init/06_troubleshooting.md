---
title: 6. Troubleshooting cloud-init
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - cloud-init
  - rocky linux
  - cloud
  - automation
  - troubleshooting
---

## Troubleshooting cloud-init

In any complex, automated system, things will eventually go wrong. When a `cloud-init` configuration fails, knowing how to systematically diagnose the problem is an essential skill. This chapter is your guide to `cloud-init` forensics, covering both in-guest and on-host troubleshooting techniques.

## 1. In-guest troubleshooting toolkit

When you can access a running instance, `cloud-init` provides several commands and logs to show you what happened.

### Pillar 1: The status command (`cloud-init status`)

This is your first port of call. It provides a high-level summary of `cloud-init`'s state.

* **Check for the completion of `cloud-init`:** `cloud-init status`
    (A successful run will show `status: done`)

* **Wait for `cloud-init` to finish:** `cloud-init status --wait`
    (This is useful in scripts to pause execution until `cloud-init` completes)

### Pillar 2: The main log (`/var/log/cloud-init.log`)

This file is the golden source of truth: a detailed, chronological record of every stage and module. When you need to know *exactly* what happened, look here. Searching this file for `ERROR` or `WARNING` will often lead you directly to the problem.

### Pillar 3: The output log (`/var/log/cloud-init-output.log`)

This log captures the full `stdout` and `stderr` of all scripts executed by `cloud-init` (e.g., from `runcmd`). If a module ran but your script within it failed, the error message will be in this file.

**Hands-on: Debugging a failing `runcmd`**

1. Create a `user-data.yml` with a `runcmd` that has a subtle error:

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    runcmd:
      - [ ls, /non-existent-dir ]
    EOF
    ```

2. Boot a VM with this data. `cloud-init status` will report `status: done` because the `runcmd` module itself executed successfully.

3. However, `/var/log/cloud-init-output.log` will contain the actual error from the `ls` command, showing you what failed:

    ```
    ls: cannot access '/non-existent-dir': No such file or directory
    ```

## 2. Host-side troubleshooting with `libguestfs-tools`

Sometimes, a VM will fail to boot entirely, making in-guest tools useless. In these cases, you can diagnose problems by inspecting the VM's disk image directly from the host by using the powerful `libguestfs-tools` suite (install with `sudo dnf install libguestfs-tools`).

### `virt-cat`: Reading files from a guest disk

`virt-cat` allows for the reading of files from inside a VM's disk image without mounting it. This is perfect for grabbing log files from a non-booting instance.

```bash
# From the host, read the cloud-init.log from the VM's disk
sudo virt-cat -a /path/to/your-vm-disk.qcow2 /var/log/cloud-init.log
```

### `virt-inspector`: Deep system inspection

`virt-inspector` generates a detailed XML report of a VM's operating system, applications, and configuration. This is incredibly powerful for automated analysis.

* **Get a full report:**

    ```bash
    sudo virt-inspector -a your-vm-disk.qcow2 > report.xml
    ```

* **Perform a targeted query:** You can pipe the XML to `xmllint` to extract specific information. This example checks the installed version of `cloud-init` inside the image:

    ```bash
    sudo virt-inspector -a your-vm-disk.qcow2 | xmllint --xpath "//application[name='cloud-init']/version/text()" -
    ```

## 3. Common pitfalls and how to avoid them

### Pitfall 1: YAML and schema errors

Invalid YAML is the most common source of failures. A more advanced problem is a syntactically valid YAML file that violates `cloud-init`'s expected structure (e.g., a typo in a module name).

* **Solution:** Use the `cloud-init schema` command to validate your configuration *before* you boot. It will catch both YAML errors and structural errors.

    ```bash
    # Validate your user-data file against the official schema
    cloud-init schema --config-file user-data.yml
    ```

    If the file is valid, it will print `Valid cloud-config: user-data.yml`. If not, it will provide detailed errors.

### Pitfall 2: Network-dependent modules failing

If networking fails to come up, modules such as `packages` will fail. Check your network configuration and the `Network` stage in `/var/log/cloud-init.log`.

## 4. Controlling `cloud-init`'s execution

* **Forcing a re-run:** To test changes on a running VM, run `sudo cloud-init clean --logs` followed by `sudo reboot`.
* **Disabling `cloud-init`:** To prevent `cloud-init` from running on subsequent boots, create a sentinel file: `sudo touch /etc/cloud/cloud-init.disabled`.
* **Running on every boot (`bootcmd`):** Use the `bootcmd` module for scripts that must run on every single boot. This is rare but useful for certain diagnostics.

## What's next

You are now equipped with a powerful set of tools for both in-guest and on-host troubleshooting. In the final chapter, we will examine the `cloud-init` project itself, preparing you to explore its source code and contribute back to the community.
