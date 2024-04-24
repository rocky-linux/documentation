---
title: Migration to New Azure Images
author: Neil Hanlon
contributors: Steven Spencer
tags:
    - cloud
    - azure
    - microsoft azure
    - deprecation
---

!!! info "Old Publishing Account Images Deprecated April 2024"
    The images contained in the former publishing account (`erockyenterprisesoftwarefoundationinc1653071250513`) were marked for deprecation on April 23, 2024 with a 180-day (6 month) window until the images can no longer be used. 
    
    To continue using Rocky Linux on Azure, you must either migrate to the new publishing account (`resf`) or to the new Community Galleries images by following the guide below.

# Migration Guide: Transitioning to New Rocky Linux Images on Azure

This guide provides detailed steps on how to migrate your Azure Virtual Machines (VMs) from the deprecated Rocky Linux images to the new images under the `resf` publisher account or to utilize the Community Galleries. Following this guide will ensure a smooth transition with minimal disruption.

## Before You Start

- Ensure you have a current backup of your VM. While the migration process should not affect your data, having a backup is a best practice for any system changes.
- Verify that you have the necessary permissions to create new VMs and manage existing ones in your Azure account.

## Step 1: Locate Your Existing VMs

Identify the VMs deployed with the old Rocky Linux images. You can do this by filtering your VMs using the old publisher account name: `erockyenterprisesoftwarefoundationinc1653071250513`.

## Step 2: Prepare New VM

1. **Navigate** to the Azure Marketplace.
2. **Search** for the new Rocky Linux images under the `resf` publisher account or access the Community Galleries.
    * Current Marketplace Links:
        * [Rocky Linux x86_64](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/resf.rockylinux-x86_64)
        * [Rocky Linux aarch64](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/resf.rockylinux-aarch64)
    * Full instructions on accessing the Community Gallery images can be found in this [news post](https://rockylinux.org/news/rocky-on-azure-community-gallery/)
3. **Select** the desired Rocky Linux version and **create a new VM**. During setup, you can choose the same VM size and other configurations as your existing VM to ensure compatibility.

## Step 3: Transfer Data

### Option A: Using Azure Managed Disks (Recommended for simplicity)

1. **Stop** your existing VM.
2. **Detach** the OS disk from the existing VM.
3. **Attach** the detached disk to the new VM as a data disk.
4. **Boot** your new VM. You can mount the old OS disk and copy data to the new disk if required.

### Option B: Using Data Transfer Tools (For complex environments or specific needs)

1. **Select** a data transfer tool such as `rsync` or Azure Blob Storage for transferring data.
2. **Transfer** data from the old VM to the new VM. This might include application data, configurations, and user data.

```bash
# Example rsync command
rsync -avzh /path/to/old_VM_data/ user@new_VM_IP:/path/to/new_VM_destination/
```

## Step 4: Reconfigure the New VM

1. **Reapply** any custom configurations or adaptations you had on your old VM to the new VM, ensuring it matches the intended environment setup.
2. **Test** the new VM to confirm that applications and services are running as expected.

## Step 5: Update DNS Records (if applicable)

If your VM is accessed through a specific domain, you'll need to update your DNS records to point to the IP address of the new VM.

## Step 6: Decommission Old VM

Once you've confirmed that the new VM is running correctly and all necessary data and configurations have been moved, you can **deallocate and delete** the old VM.

## Final Steps

- Validate that all services on the new VM are running as expected.
- Monitor the performance and health of the new VM to ensure it meets your needs.

## Need Assistance?

If you encounter any issues during your migration or have questions, support is available. Visit [Rocky Linux support channels](https://wiki.rockylinux.org/rocky/support/) for assistance.



