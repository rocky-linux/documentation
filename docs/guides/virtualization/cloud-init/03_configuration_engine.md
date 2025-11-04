---
title: 3. The configuration engine
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - cloud-init
  - rocky linux
  - cloud-init modules
  - automation
---

## Deep dive into cloud-init modules

In the last chapter, you successfully booted a cloud image and performed a simple customization. While effective, you unlock the true power, portability, and idempotency of `cloud-init` with its module system. These modules are specialized tools in the `cloud-init` toolkit, designed to handle specific configuration tasks in a declarative, predictable way.

This chapter dives deep into the module system, explaining what modules are, how they work, and how to use the most essential ones to build a well-configured server.

## 1. The anatomy of configuration

### What are cloud-init modules

A `cloud-init` module is a specialized Python script designed to handle a single, discrete provisioning task. Think of them as plugins for functions like user management, package installation, and file writing.

The key advantage of using modules over simple scripts (like `runcmd`) is **idempotency**. An idempotent operation produces the same result whether you run it once or ten times. When you declare that a user should exist, the module ensures the state is met—it creates the user if it does not exist, but does nothing if it already does. This makes your configurations reliable and repeatable.

### The `#cloud-config` format revisited

When `cloud-init` sees the `#cloud-config` header, it interprets the file as a YAML-formatted instruction set — the top-level keys in this YAML file map directly to `cloud-init` modules.

### Module execution and order

Modules run at specific stages of the boot process in a sequence defined in `/etc/cloud/cloud.cfg`. A simplified view of this flow looks like this:

```
System Boot
    |
    +--- Stage: Generator (Very early boot)
    |    `--- cloud_init_modules (e.g., migrator)
    |
    +--- Stage: Local (Pre-network)
    |    `--- (Modules for local device setup)
    |
    +--- Stage: Network (Network is up)
    |    `--- cloud_config_modules (e.g., users-groups, packages, write_files)
    |
    `--- Stage: Final (Late boot)
         `--- cloud_final_modules (e.g., runcmd, scripts-user)
```

The order is critical. For example, the `users-groups` module runs before `runcmd`, ensuring a script can be run by a user who was just created in the same configuration.

!!! tip "Customizing `cloud-init` behavior"

    While `/etc/cloud/cloud.cfg` defines the default behavior, you should never edit it directly. For persistent, system-wide customizations, place your own `.cfg` files in the `/etc/cloud/cloud.cfg.d/` directory. This is the standard practice for building custom images, which we will explore in a later chapter.

## 2. High-utility modules: The daily drivers

Let us get hands-on with the most common modules by using the direct injection method with `virt-install`.

### Module deep dive: `users` and `groups`

Properly managing user accounts is the cornerstone of securing a new server instance. The `users` module is your primary tool for this, allowing you to create new users, modify existing ones, manage group memberships, and, most importantly, inject SSH keys to facilitate secure, passwordless logins from the very first boot.

**Example 1: Creating a new admin user**

In this example, we will provision a new, dedicated administrative user named `sysadmin`. We will grant this user passwordless `sudo` capabilities by adding them to the `wheel` group and providing a specific `sudo` rule. We will also inject an SSH public key to ensure secure access.

1. **Create `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    users:
      - name: sysadmin
        groups: [ wheel ]
        sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
        shell: /bin/bash
        ssh_authorized_keys:
          - <YOUR_SSH_PUBLIC_KEY_HERE>
    EOF
    ```

2. **Key directives explained:**

    * `name`: The username for the new account.
    * `groups`: A list of groups to add the user to. On Rocky Linux, membership in the `wheel` group is commonly used to grant administrative rights.
    * `sudo`: A list of `sudoers` rules to apply. The rule `ALL=(ALL) NOPASSWD:ALL` grants the user the ability to run any command with `sudo` without a prompt for a password.
    * `ssh_authorized_keys`: A list of public SSH keys to add to the user's `~/.ssh/authorized_keys` file.

3. **Boot and verify:** Boot the VM with this `user-data`. You should be able to SSH as `sysadmin` and run `sudo` commands.

**Example 2: Modifying the default user**

A more common task is to secure the default user provided with the cloud image (`rocky`). Here, we will modify this user to add our SSH key.

1. **Create `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    users:
      - default
      - name: rocky
        ssh_authorized_keys:
          - <YOUR_SSH_PUBLIC_KEY_HERE>
    EOF
    ```

2. **Key directives explained:**

    * `default`: This special entry tells `cloud-init` to perform its default user setup first.
    * `name: rocky`: By specifying the name of an existing user, the module will modify that user instead of creating a new one. Here, it merges the provided SSH key into the `rocky` user's account.

3. **Boot and verify:** Boot the VM. You can now SSH as the `rocky` user without a password.

### Module deep dive: `packages`

The `packages` module provides a declarative way to manage the software on your instance, ensuring the installation of specific applications at boot time.

In this example, we will ensure the installation of two useful tools, `nginx` (a high-performance web server) and `htop` (an interactive process viewer). We will also instruct `cloud-init` to update the package repository metadata first, ensuring it can find the latest versions.

1. **Create `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    package_update: true
    packages:
      - nginx
      - htop
    EOF
    ```

2. **Key directives explained:**

    * `package_update: true`: Instructs the package manager to refresh its local metadata. On Rocky Linux, this is equivalent to running `dnf check-update`.
    * `packages`: A list of package names to install.

3. **Boot and verify:** After booting, SSH in and check the installation of `nginx` with `rpm -q nginx`.

!!! note "Idempotency in action"

    If you were to reboot this VM with the same `user-data`, the `packages` module would see that `nginx` and `htop` are already installed and take no further action. It ensures the desired state (packages are present) without taking unnecessary action. That is idempotency.

### Module deep dive: `write_files`

This module is incredibly versatile, allowing you to write any text content to any file on the system. It is the perfect tool for deploying application configuration files, populating web content, or creating helper scripts.

To demonstrate its power, we will use `write_files` to create a custom homepage for the `nginx` web server that we are also installing in the same run.

1. **Create `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    packages: [nginx]
    write_files:
      - path: /usr/share/nginx/html/index.html
        content: '<h1>Hello from cloud-init!</h1>'
        owner: nginx:nginx
        permissions: '0644'
    runcmd:
      - [ systemctl, enable, --now, nginx ]
    EOF
    ```

2. **Key directives explained:**

    * `path`: The absolute path on the filesystem where the file will write to.
    * `content`: The text content to write to the file.
    * `owner`: Specifies the user and group that should own the file (e.g., `nginx:nginx`).
    * `permissions`: The file permissions in octal format (e.g., `0644`).

3. **Boot and verify:** After booting, SSH in and use `curl localhost` to see the new homepage.

!!! tip "Writing binary files"

    The `write_files` module is not limited to text. By specifying an `encoding`, you can deploy binary files. For example, you can use `encoding: b64` to write base64-encoded data. For advanced use cases, refer to the [official `write_files` documentation](https://cloudinit.readthedocs.io/en/latest/topics/modules.html#write-files).

## What's next

You have now mastered the three most fundamental `cloud-init` modules. By combining them, you can perform a significant amount of automated server configuration. In the next chapter, we will tackle more advanced scenarios, including network configuration and combining different `user-data` formats in a single run.
