---
title: V. The Image Builder's Perspective
author: Wale Soyinka
contributors:
tags:
  - cloud-init
  - rocky linux
  - cloud
  - automation
  - image-building
---

# **V. The Image Builder's Perspective: Defaults and Generalization**

So far, our journey has focused on configuring individual instances at boot time using `user-data`. In this chapter, we will shift our perspective to that of an **image builder**—someone who creates and maintains the "golden images" that serve as templates for other virtual machines.

Our goal is to create a new, custom image with our own baked-in policies and defaults. This involves two key processes:

1.  **Customizing System-Wide Defaults:** Modifying the `cloud-init` configuration *within the image itself*.
2.  **Generalizing the Image:** Using tools like `cloud-init clean` and `virt-sysprep` to strip all machine-specific data, preparing the image for cloning.

## **1. The Customization Lab Setup**

To begin, we need a running instance of the base cloud image that we can modify. We will boot this VM *without* providing any `user-data` to get a clean system.

```bash
# Create a disk image for our new template
qemu-img create -f qcow2 -o size=10G golden-image-template.qcow2

# Boot the base image using virt-install
virt-install --name golden-image-builder \
--memory 2048 --vcpus 2 \
--disk path=golden-image-template.qcow2,format=qcow2 \
--cloud-init none --os-variant rockylinux10 --import

# Connect to the console and log in as the default 'rocky' user
virsh console golden-image-builder
```

## **2. System-Wide Configuration with `cloud.cfg.d`**

Inside our running VM, we can now customize the system-wide `cloud-init` configuration. The master file, `/etc/cloud/cloud.cfg`, should never be edited directly. The correct, upgrade-safe location for customizations is the `/etc/cloud/cloud.cfg.d/` directory. `cloud-init` reads all `.cfg` files here in alphabetical order after the main `cloud.cfg`, allowing you to override defaults.

### **Hands-On: Setting Golden Image Defaults**

Let's enforce a policy on our golden image: we will disable password authentication, set a new default user, and ensure a baseline set of packages is always installed.

1.  **Create a custom configuration file:** From inside the VM, create `/etc/cloud/cloud.cfg.d/99-custom-defaults.cfg`. The `99-` prefix ensures it is read last.

    ```bash
    sudo cat <<EOF > /etc/cloud/cloud.cfg.d/99-custom-defaults.cfg
    # Golden Image Customizations

    # Define a new default user named 'admin'
    system_info:
      default_user:
        name: admin
        sudo: ["ALL=(ALL) NOPASSWD:ALL"]
        shell: /bin/bash

    # Enforce key-based SSH authentication
    ssh_pwauth: false

    # Ensure a baseline of packages is always installed
    packages:
      - htop
      - vim-enhanced
    EOF
    ```

!!! tip "Disabling Specific Modules"
A powerful security technique is to completely disable certain `cloud-init` modules. For example, to prevent any user from ever using `runcmd`, you can add the following to your custom `.cfg` file. This tells `cloud-init` to run an empty list of modules during the final stage.
    ```yaml
    cloud_final_modules: []
    ```

## **3. Generalizing the Image**

Our VM now contains our custom configuration, but it also holds unique machine identifiers (like `/etc/machine-id`) and SSH host keys. Before we can clone it, we **must** remove this data in a process called **generalization**.

### **Method 1: `cloud-init clean` (Inside the VM)**

`cloud-init` provides a built-in command for this purpose.

1.  **Run `cloud-init clean`:** From inside the VM, run the following to strip instance-specific data.
    ```bash
    sudo cloud-init clean --logs --seed
    ```
    !!! note "On `cloud-init clean --seed`"
        This command removes the unique seed `cloud-init` uses to identify the instance, forcing it to run from scratch on the next boot. It does **not** remove your custom configurations in `/etc/cloud/cloud.cfg.d/`. This step is essential for creating a truly generic template.

2.  **Immediately Shut Down:** After cleaning, power off the VM immediately.
    ```bash
    sudo poweroff
    ```

### **Method 2: `virt-sysprep` (From the Host)**

An even more thorough, industry-standard tool is `virt-sysprep`. It can be run from your host machine on the shutdown VM disk. It performs all the actions of `cloud-init clean` and much more, such as clearing command history, removing temporary files, and resetting log files.

1.  **Ensure the VM is shut down.**
2.  **Run `virt-sysprep` from your host:**
    ```bash
    sudo virt-sysprep -a golden-image-template.qcow2
    ```

Once the generalization process is complete, the disk file (`golden-image-template.qcow2`) is your new golden image.

!!! note "Golden Image Naming Conventions"
    It is a good practice to give your golden images descriptive names that include the OS and a version number, such as `rocky10-base-v1.0.qcow2`. This helps with version control and infrastructure management.

## **4. Verifying the Golden Image**

Let's test our new image by booting a new instance *from* it without any `user-data`.

1.  **Create a new VM disk from our golden image:**
    ```bash
    qemu-img create -f qcow2 -F qcow2 -b golden-image-template.qcow2 test-instance.qcow2
    ```

2.  **Boot the test instance:**
    ```bash
    virt-install --name golden-image-test --cloud-init none ...
    ```

3.  **Verify:** Connect to the console (`virsh console golden-image-test`). The login prompt should be for the user `admin`, not `rocky`. Once logged in, you can also verify that `htop` is installed (`rpm -q htop`). This confirms your baked-in defaults are working.

## **What's Next?**

You have now learned how to create standardized templates by baking in defaults with `cloud-init`'s system-wide configuration and properly generalizing them for cloning. In the next chapter, we will cover the essential skill of troubleshooting when `cloud-init` doesn't behave as expected.