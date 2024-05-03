---
title: Migration to New Azure Images
author: Neil Hanlon
contributors: Steven Spencer, Ganna Zhyrnova
tags:
    - cloud
    - azure
    - microsoft azure
    - deprecation
---

!!! info "Old Publishing Account Images Deprecated April 2024"

    A Microsoft publishing account is an Azure marketplace account that allows developers to publish their offers to Microsoft AppSource or Azure Marketplace. 
    The RESF provides Rocky Linux Virtual Machine images under 2 separate publishing accounts in Azure; a legacy account identified as `erockyenterprisesoftwarefoundationinc1653071250513` and a newer official account called `resf`.
    The images published under the legacy publishing account (`erockyenterprisesoftwarefoundationinc1653071250513`) were marked for deprecation on April 23, 2024, with a 180-day (6 months) window until they can no longer be used. 

    To continue using Rocky Linux on Azure, you must follow this guide to migrate to the new publishing account (`resf`) or to the new Community Galleries images.

# Migration Guide: Transitioning to new Rocky Linux images on Azure

This guide provides detailed steps for migrating your Azure virtual machines (VMs) from the deprecated Rocky Linux images to the new images under the `resf` publisher account or using the Community Galleries. Following this guide will ensure a smooth transition with minimal disruption.

## Before you start

- Ensure you have a current backup of your VM. While the migration process should not affect your data, having a backup is a best practice for any system changes.
- Verify you have the necessary permissions to create new VMs and manage existing ones in your Azure account.

## Step 1: Locate your existing VMs

Identify the VMs deployed with the old Rocky Linux images. You can do this by filtering your VMs with the old publisher account name:

```text
erockyenterprisesoftwarefoundationinc1653071250513`
```

## Step 2: Prepare a new VM

1. **Navigate** to the Azure Marketplace.
2. **Search** for the new Rocky Linux images under the `resf` publisher account or access the Community Galleries.
    - Current Marketplace Links:
      - [Rocky Linux x86_64](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/resf.rockylinux-x86_64)
    - [Rocky Linux aarch64](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/resf.rockylinux-aarch64)
    - Full instructions on accessing the Community Gallery images are found in this [news post](https://rockylinux.org/news/rocky-on-azure-community-gallery/)
3. **Select** the desired Rocky Linux version and **create a new VM**. During setup, you can choose the same VM size and other configurations as your existing VM to ensure compatibility.

## Step 3: Transfer data

### Option A: Using Azure-managed disks (recommended for simplicity)

1. **Stop** your existing VM.
2. **Detach** the operating system disk from the existing VM.
3. **Attach** the detached disk to the new VM as a data disk.
4. **Boot** your new VM. If required, you can mount the old OS disk and copy data to the new disk.

### Option B: Using Data Transfer Tools (For complex environments or specific needs)

1. **Select** a data transfer tool such as `rsync` or Azure Blob Storage for transferring data.
2. **Transfer** data from the old VM to the new VM. This might include application data, configurations, and user data.

```bash
# Example rsync command
rsync -avzh /path/to/old_VM_data/ user@new_VM_IP:/path/to/new_VM_destination/
```

## Step 4: Reconfigure the new VM

1. **Reapply** any custom configurations or adaptations you had on your old VM to the new VM, ensuring it matches the intended environment setup.
2. **Test** the new VM to confirm that applications and services are running as expected.

## Step 5: Update DNS records (if applicable)

If you access your VM through a specific domain, you must update your DNS records to point to the new VM's IP address.

## Step 6: Decommission old VM

Once you have confirmed that the new VM is running correctly and moved all necessary data and configurations, you can **deallocate and delete** the old VM.

## Final steps

- Validate that all services on the new VM are running as expected.
- Monitor the performance and health of the new VM to ensure it meets your needs.

## Support

Support is available if you encounter any issues during your migration or have questions. Visit [Rocky Linux support channels](https://wiki.rockylinux.org/rocky/support/) for assistance.
