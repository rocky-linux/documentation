---
title: QA:Testcase Disk Layouts
author: Al Bowles
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver:
  - 8
  - 9
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#Disk Layouts](../../guidelines/release_criteria/r9/9_release_criteria.md#disk-layouts) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This test case verifies successful installation to any supported partition layout using any file system or format combination.

{% include 'teams/testing/qa_data_loss_warning.md' %}

## Setup
{% include 'teams/testing/qa_setup_boot_to_media.md' %}

## How to test
1. Select the Installation Destination spoke.
1. Select the volumes to which the operating system should be installed.
1. Select the Custom radio button under the Storage Configuration section, then click "Done".
1. For each volume, perform these steps:
    1. Choose the desired partitioning scheme from the dropdown menu. Supported options are Standard Partition, LVM, and LVM Thin Provisioning.
    1. Select the "Encrypt my data" checkbox to create an encrypted filesystem.
    1. Select the plus (+) button in the lower left hand corner to add a partition.
    1. Define the desired mount point and volume capacity, then click "Add mount point".
    1. Set the device type. Supported options are LVM, RAID, Standard Partition, and LVM Thin Provisioning.
    1. If device type was set to RAID, select the RAID level. Supported options are RAID0, RAID1, RAID4, RAID5, RAID6, and RAID10.
    1. Set the filesystem type. Supported options are BIOS Boot, ext2, ext3, ext4, swap, vfat, and xfs.
    1. In supported cases you may choose to disable formatting of existing partitions by unchecking the Reformat checkbox.
1. When all partitions have been created, click the blue Done button in the upper left corner.
1. Review the Summary of Changes dialog, then click Accept Changes.
1. Continue the installation as normal.

## Expected Results
1. The installation should complete successfully and boot to the appropriate disk.
1. The specified filesystem type and partition scheme should be used.
1. If configured, software RAID should function as expected.

## Testing with openQA
The following openQA test suites satisfy this release criteria:

- `install_standard_partition_ext4`
- `install_custom_gui_standard_partition_ext4`
- `install_lvm_ext4`
- `install_custom_gui_lvm_ext4`
- `install_software_raid`
- `install_custom_gui_software_raid`
- `install_xfs`
- `install_custom_gui_xfs`
- `install_lvmthin`
- `install_multi`
- `install_multi_empty`

{% include 'teams/testing/qa_testcase_bottom.md' %}
