---
title: 4. Advanced Provisioning
author: Wale Soyinka
contributors:
tags:
  - cloud-init
  - rocky linux
  - cloud
  - automation
  - networking
---

## Networking and Multi-Part Payloads

In the previous chapter, you mastered the core `cloud-init` modules for managing users, packages, and files. You can now build a well-configured server declaratively. Now, it's time to explore more advanced techniques that give you even greater control over your instance's configuration.

This chapter covers two powerful, advanced topics:

1.  Declarative Network Configuration: How to move beyond DHCP and define static network configurations for your instances.
2.  Multi-Part MIME Payloads: How to combine different types of user-data, like shell scripts and `#cloud-config` files, into a single, powerful payload.

## 1. Declarative Network Configuration

By default, most cloud images are configured to acquire an IP address via DHCP. While convenient, many production environments require servers to have predictable, static IP addresses. The `cloud-init` network configuration system provides a platform-agnostic, declarative way to manage this.

Network configurations are specified in a separate YAML document from your main `#cloud-config`. `cloud-init` processes both from the same file, using the standard YAML document separator (`---`) to distinguish between them.

!!! note "How `cloud-init` Applies Network State"
    On Rocky Linux, `cloud-init` does not directly configure the network interfaces. Instead, it acts as a translator, converting its network configuration into files that **NetworkManager** (the default network service) can understand. It then hands off control to NetworkManager to apply the configuration. You can inspect the resulting connection profiles in `/etc/NetworkManager/system-connections/`.

### Example 1: Configuring a Single Static IP

In this exercise, we will configure our virtual machine with a static IP address, a default gateway, and custom DNS servers.

1.  **Create `user-data.yml`:**

    This file contains two distinct YAML documents, separated by `---`. The first is our standard `#cloud-config`. The second defines the network state.

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    # We can still include standard modules.
    # Let's install a network troubleshooting tool.
    packages:
      - traceroute

    ---

    # This second document defines the network configuration.
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: no
          addresses:
            - 192.168.122.100/24
          gateway4: 192.168.122.1
          nameservers:
            addresses: [8.8.8.8, 8.8.4.4]
    EOF
    ```

2.  **Key Directives Explained:**
    *   `network:`: The top-level key for network configuration.
    *   `version: 2`: Specifies that we are using the modern, Netplan-like syntax.
    *   `ethernets:`: A dictionary of physical network interfaces to configure, keyed by the interface name (e.g., `eth0`).
    *   `dhcp4: no`: Disables DHCP for IPv4 on this interface.
    *   `addresses`: A list of static IP addresses to assign, specified in CIDR notation.
    *   `gateway4`: The default gateway for IPv4 traffic.
    *   `nameservers`: A dictionary containing a list of IP addresses for DNS resolution.

3.  **Boot and Verify:**

    Verification is different this time, as the VM will not get a dynamic IP address. You must connect to the VM's console directly.

    ```bash
    # Use a new disk image for this exercise
    qemu-img create -f qcow2 -F qcow2 -b Rocky-10-GenericCloud.qcow2 static-ip-vm.qcow2

    virt-install --name rocky10-static-ip \
    --memory 2048 --vcpus 2 \
    --disk path=static-ip-vm.qcow2,format=qcow2 \
    --cloud-init user-data=user-data.yml,hostname=network-server \
    --os-variant rockylinux10 \
    --import --noautoconsole
    
    # Connect to the virtual console
    virsh console rocky10-static-ip

    # Once logged in, check the IP address
    [rocky@network-server ~]$ ip a show eth0
    ```
    The output should show that `eth0` has the static IP address `192.168.122.100/24`.

### Example 2: Multi-Interface Configuration

A common real-world scenario is a server with multiple network interfaces. Here, we'll create a VM with two interfaces: `eth0` will use DHCP, and `eth1` will have a static IP.

1.  **Create `user-data.yml` for two interfaces:**
    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    packages: [iperf3]

    ---

    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: yes
        eth1:
          dhcp4: no
          addresses: [192.168.200.10/24]
    EOF
    ```

2.  **Boot a VM with two NICs:** We add a second `--network` flag to the `virt-install` command.
    ```bash
    virt-install --name rocky10-multi-nic \
    --memory 2048 --vcpus 2 \
    --disk path=... \
    --network network=default,model=virtio \
    --network network=default,model=virtio \
    --cloud-init user-data=user-data.yml,hostname=multi-nic-server \
    --os-variant rockylinux10 --import --noautoconsole
    ```

3.  **Verify:** SSH to the DHCP-assigned address on `eth0` and then check the static IP on `eth1` with `ip a show eth1`.

## 2. Unifying Payloads with Multi-Part MIME

Sometimes, you need to run a setup script *before* the main `#cloud-config` modules execute. MIME multi-part files are the solution, allowing you to bundle different content types into one ordered payload.

The structure of a MIME file can be visualized as follows:

```
+-----------------------------------------+
| Main Header (multipart/mixed; boundary) |
+-----------------------------------------+
|
| --boundary                              |
| +-------------------------------------+
| | Part 1 Header (e.g., text/x-shellscript)  |
| +-------------------------------------+
| | Part 1 Content (#/bin/sh...)        |
| +-------------------------------------+
|
| --boundary                              |
| +-------------------------------------+
| | Part 2 Header (e.g., text/cloud-config)   |
| +-------------------------------------+
| | Part 2 Content (#cloud-config...)   |
| +-------------------------------------+
|
| --boundary-- (closing)                  |
+-----------------------------------------+
```

### Hands-On: A Pre-flight Check Script

We will create a multi-part file that first runs a shell script and then proceeds to the main `#cloud-config`.

1.  **Create the Multi-Part `user-data.mime` file:**

    This is a specially formatted text file that uses a "boundary" string to separate the parts.

    ```bash
    cat <<EOF > user-data.mime
    Content-Type: multipart/mixed; boundary="//"
    MIME-Version: 1.0

    --//
    Content-Type: text/x-shellscript; charset="us-ascii"

    #!/bin/sh
    echo "Running pre-flight checks..."
    # In a real script, you might check disk space or memory.
    # If checks failed, you could 'exit 1' to halt cloud-init.
    echo "Pre-flight checks passed." > /tmp/pre-flight-status.txt

    --//
    Content-Type: text/cloud-config; charset="us-ascii"

    #cloud-config
    packages:
        - htop
        runcmd:
          - [ sh, -c, "echo 'Main cloud-config ran successfully' > /tmp/main-config-status.txt" ]

    --//--
    EOF
    ```

    !!! note "About the MIME Boundary"

        The boundary string (`//` in this case) is an arbitrary string that must not appear in the content of any part. It is used to separate the different sections of the file.

2.  Boot and Verify:

    You pass this file to `virt-install` in the same way as a standard `user-data.yml` file.

    ```bash
    # Use a new disk image
    qemu-img create -f qcow2 -F qcow2 -b Rocky-10-GenericCloud.qcow2 mime-vm.qcow2

    virt-install --name rocky10-mime-test \
    --memory 2048 --vcpus 2 \
    --disk path=mime-vm.qcow2,format=qcow2 \
    --cloud-init user-data=user-data.mime,hostname=mime-server \
    --os-variant rockylinux10 \
    --import --noautoconsole
    ```

    After booting, SSH into the VM and check that both parts ran by looking for the files they created:

    ```bash
    cat /tmp/pre-flight-status.txt
    cat /tmp/main-config-status.txt
    ```

!!! tip "Other Multi-Part Content Types"

    `cloud-init` supports other content types for advanced use cases, such as `text/cloud-boothook` for very early boot scripts or `text/part-handler` for running custom Python code. Refer to the official documentation for more details.

## What's Next?

You have now learned two powerful, advanced `cloud-init` techniques. You can now define static networks and orchestrate complex provisioning workflows with multi-part user-data.

In the next chapter, we will shift our perspective from *consuming* `cloud-init` on a per-instance basis to *customizing its default behavior* for creating your own pre-configured "golden images".
