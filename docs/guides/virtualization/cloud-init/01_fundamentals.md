---
title: 1. cloud-init Fundamentals
author: Wale Soyinka
contributors:
tags:
  - cloud-init
  - cloud
  - automation
---


## The Architecture of First Boot

This guide explores `cloud-init`, the essential tool for automating the initial setup of your Rocky Linux 10 cloud instances. When we talk about deploying servers in the cloud—or even in your local virtualization lab—we often take for granted the almost instantaneous transition from a blank image to a fully functional, network-ready machine. This feat of digital alchemy is performed by a single, tireless utility: cloud-init.

## 1. The Bootstrapping Conundrum

### The Problem: When a Server Wakes Up Blind

Imagine a generic Rocky Linux 10 QCOW2 image. It’s a perfect, pristine copy, unaware of its final destination. It doesn’t know its hostname, which user account should have SSH access, what timezone it’s in, or if it needs Apache or NGINX.

If you were deploying physical hardware, a system administrator would manually configure all these parameters. But in the cloud, servers are ephemeral, scaled up and down by the thousands. We need a standardized, generic, and reliable mechanism to inject the necessary context into that blank image the very first time it boots.

This is the problem **cloud-init** solves.

### What is cloud-init?

Simply put, cloud-init is the industry-standard multi-distribution package that handles early initialization of cloud instances. It is the core service responsible for taking a generic image (like the one we’re using) and performing the required configuration tasks to transform it into a unique, production-ready server.

It literally sits at the heart of the provisioning process, interpreting **metadata** and **user-defined instructions** to set up the system. Without it, your cloud instance is just a beautifully compiled Linux kernel with an identity crisis.

### The cloud-init Ecosystem

cloud-init is a consumer, not a creator. It relies on the underlying cloud platform (AWS, Azure, GCP, OpenStack, or local tools like libvirt) to provide it with configuration information.

*   **Cloud Providers** expose data via a specialized *data source* (often a local HTTP endpoint, a specific disk label, or a kernel parameter).
*   **cloud-init** detects this data source, reads the configuration, and executes the appropriate configuration steps.

This decoupling—where the image is generic and the configuration is provided externally—is the fundamental genius of the entire cloud deployment model.

## 2. Rocky Linux 10 and the Generic Cloud Image

For this guide, we'll be using the official [Rocky-10-GenericCloud-Base.latest.x86_64.qcow2](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2).

### The Target Image: A Pre-Wired Workhorse

This image is special because it comes with the cloud-init package pre-installed and enabled. It has been *generalized*, meaning all machine-specific identifiers, SSH host keys, and log files have been stripped out. It’s ready to receive its new identity on first boot.

!!! warning "Use the Recommended Image"
    If you attempt to use cloud-init on a standard Rocky Linux installation (like a minimal ISO install), you’ll find it’s not present by default. Stick to the **Generic Cloud image** to avoid needless complexity and ensure everything works exactly as the doctor prescribed. Attempting the exercises in this guide with other images will likely fail and is not supported.

### Core Concepts: User-Data vs. Meta-Data

The configuration information that cloud-init processes is categorized into two key types. Understanding this distinction is critical to knowing what you can control and what the cloud provider controls.

Think of it like building a house: **Meta-Data** is the street address assigned by the city, while **User-Data** is the blueprint you provide for the interior design.

| Data Type   | Source & Purpose                                                                                                                            | Configuration Type  |
| :---------- | :------------------------------------------------------------------------------------------------------------------------------------------ | :------------------ |
| **Meta-Data** | Provided by the cloud platform (read-only). Contains system identifiers like instance ID, hostname (if provided by the platform), region, and availability zone. | *System Context*    |
| **User-Data** | Provided by the user. This is your instruction set—YAML configuration blocks or shell scripts that customize the server.                  | *User Instructions* |

**Meta-Data** tells cloud-init *where* it is. **User-Data** tells cloud-init *what to do*.

We will focus primarily on crafting effective **User-Data** files, which typically start with the mandatory YAML header:

```yaml
#cloud-config
```

## 3. The Lifecycle: cloud-init's Four Stages of Initialization

cloud-init doesn't just run a script and exit; it executes a series of highly structured stages that align with the server's boot process. This methodical approach ensures that dependencies are met (e.g., networking is configured before packages are downloaded).

Understanding this lifecycle is crucial for debugging and knowing precisely when your custom instructions are executed.

| Stage       | Timing & Description                                                                                                                    | Key Actions/Modules                                                                                             |
| :---------- | :-------------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------- |
| **Generator** | Runs very early in the boot process. Sets up internal directories and performs basic configuration checks.                               | Internal setup, log initialisation.                                                                             |
| **Local**     | Runs before the network is necessarily up. It processes local data sources like CD-ROM or virtual drives (which we'll use in our lab). | Setting hostname from local data, initial disk setup.                                                           |
| **Network**   | Runs once networking is fully configured and operational. It queries network-based data sources (like the cloud provider's API).      | Configure network interfaces, fetch keys from network metadata.                                                 |
| **Final**     | Runs last. This is where the majority of user-defined configuration takes place, as all prerequisites (users, network, disks) are now ready. | Installing packages, running custom scripts (runcmd), writing files (write_files), system clean-up. |

!!! tip "Check the Logs"
    When troubleshooting, always check `/var/log/cloud-init.log`. This file is the forensic report of the `cloud-init` process, showing exactly when each stage began and finished, and what modules were executed along the way. If your script didn't run, the log will tell you exactly why, and which stage failed.

## What's Next?

Now that you understand the fundamental architecture of `cloud-init`—the "what" and "why," the different data types, and the boot stages—you are ready to move from theory to practice. The next chapter will guide you through your first hands-on exercise: booting the Rocky Linux 10 cloud image and performing a simple, real-world customization.
