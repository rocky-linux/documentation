---
Title: II. First Contact: Simple Bootstrapping
author: Wale Soyinka
contributors:
tags:
  - cloud-init
  - cloud
  - automation
---


## Simple Bootstrapping with the Rocky Linux 10 QCOW2 Image

In the previous chapter, we covered the fundamental concepts of `cloud-init`. Now, it’s time to move from theory to practice. This chapter is your first hands-on mission: you will take the official Rocky Linux 10 Generic Cloud image, provide it with a simple set of instructions, and watch it configure itself on first boot.

## 1. Prepping the Lab Environment

Before we can boot our first instance, we need to prepare our local lab environment. For these exercises, we will simulate a cloud environment using standard Linux virtualization tools.

### Prerequisites: Host Tools

Ensure you have the following tools installed on your host machine. On a Rocky Linux host, you can install them with `dnf`:

```bash
sudo dnf install -y libvirt qemu-kvm virt-install genisoimage
```

*   **Virtualization Hypervisor:** A tool like KVM/QEMU or VirtualBox.
*   `virt-install`: A command-line utility for provisioning new virtual machines.
*   `genisoimage` (or `mkisofs`): A tool to create an ISO9660 filesystem.

### **The QCOW2 Image**

If you haven't already, download the official Rocky Linux 10 Generic Cloud image.

```bash
curl -L -o Rocky-10-GenericCloud.qcow2 \
https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2
```

To preserve the original, create a working copy of the image for your VM.

```bash
cp Rocky-10-GenericCloud.qcow2 first-boot-vm.qcow2
```

!!! tip "Save Disk Space with Backing Files"

    A full copy of the image can be large. To save disk space, you can create a *linked clone* that uses the original image as a backing file. This creates a much smaller `qcow2` file that only stores the differences from the original.

    ```bash
    qemu-img create -f qcow2 -F qcow2 \
    -b Rocky-10-GenericCloud.qcow2 first-boot-vm.qcow2
    ```

## **2. Method 1: The `NoCloud` Datasource (ISO)**

One of the most common ways to provide data to `cloud-init` in a local environment is the `NoCloud` datasource. This method requires packaging our configuration files into a virtual CD-ROM (an ISO file) that `cloud-init` will automatically detect and read on boot.

### **Creating the Configuration Files**

1.  **Create a directory for your configuration files:**
    ```bash
    mkdir cloud-init-data
    ```

2.  **Create the `user-data` file:** This file is your primary instruction set. We will use a `cat` heredoc to create it.
    ```bash
    cat <<EOF > cloud-init-data/user-data
    #cloud-config
    hostname: cloud-rockstar-01
    runcmd:
      - [ sh, -c, "echo 'Hello from the cloud-init Final Stage!' > /root/boot_done.txt" ]
    EOF
    ```

3.  **Create the `meta-data` file:** This file provides context *about* the instance. The `instance-id` is particularly important, as `cloud-init` uses it to determine if it has run on this instance before. Changing the ID will cause `cloud-init` to run again.
    ```bash
    cat <<EOF > cloud-init-data/meta-data
    {
      "instance-id": "i-first-boot-01",
      "local-hostname": "cloud-rockstar-01"
    }
    EOF
    ```

4.  **Generate the ISO:** Use `genisoimage` to package the files into `config.iso`. The volume label `-V cidata` is the magic key that `cloud-init` looks for.
    ```bash
    genisoimage -o config.iso -V cidata -r -J cloud-init-data
    ```

### **Booting and Verification**

1.  **Launch the VM** with `virt-install`, attaching both the VM image and the `config.iso`.
    ```bash
    virt-install --name rocky10-iso-boot \
    --memory 2048 --vcpus 2 \
    --disk path=first-boot-vm.qcow2,format=qcow2 \
    --disk path=config.iso,device=cdrom \
    --os-variant rockylinux10 \
    --import --noautoconsole
    ```

2.  **Find the IP and connect via SSH.** The default user is `rocky`.
    ```bash
    virsh domifaddr rocky10-iso-boot
    ssh rocky@<IP_ADDRESS>
    ```
    !!! tip "Secure Logins with SSH Keys"
        Connecting with a default user is convenient for a quick lab test, but it is not a secure practice. In the next chapter, we will explore how to use `cloud-init` to automatically inject your SSH public key, allowing for secure, passwordless logins.

3.  **Verify the changes:** Check the hostname and the file created by `runcmd`.
    ```bash
    hostname
    sudo cat /root/boot_done.txt
    ```

## **3. Method 2: Direct Injection with `virt-install`**

Creating an ISO is a reliable method, but for users of `libvirt` and `virt-install`, there is a much simpler way. The `--cloud-init` flag allows you to pass `user-data` directly, letting `virt-install` handle the creation of the datasource automatically.

### **Simplified `user-data`**

Create a simple `user-data.yml` file. You can even add the SSH key pre-emptively.

```bash
cat <<EOF > user-data.yml
#cloud-config
users:
  - name: rocky
    ssh_authorized_keys:
      - <YOUR_SSH_PUBLIC_KEY>
EOF
```

### **Booting and Verification**

1.  **Launch the VM** using the `--cloud-init` flag. Notice we can set the hostname here directly.
    ```bash
    virt-install --name rocky10-direct-boot \
    --memory 2048 --vcpus 2 \
    --disk path=first-boot-vm.qcow2,format=qcow2 \
    --cloud-init user-data=user-data.yml,hostname=cloud-rockstar-02 \
    --os-variant rockylinux10 \
    --import --noautoconsole
    ```

2.  **Find the IP and connect.** If you added your SSH key, you should be able to connect without a password.

3.  **Verify the hostname.** It should be `cloud-rockstar-02`.

This direct method is often faster and more convenient for local development and testing with `libvirt`.
