---
title: QA:Testcase Storage Volume Resize
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
    This test case is associated with the [Release_Criteria#Storage Volume Resize](../../guidelines/release_criteria/r9/9_release_criteria.md#storage-volume-resize) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This test case verifies that the installer will successfully resize or delete and overwrite existing partitions on storage volumes.

{% include 'teams/testing/qa_data_loss_warning.md' %}

## Setup
{% include 'teams/testing/qa_setup_boot_to_media.md' %}

## How to test

### Resize
1. From the Installation Destination spoke, in the Storage Configuration section, select the Custom radio button, then click Done.
1. Expand the list of available partitions by clicking the black arrow to the left of the release version and architecture.
1. Select the partition you wish to resize. Be sure to uncheck the Reformat checkbox if you wish to resize without reformatting the partition.
1. Click the Update Settings button to save your settings.
1. Click the + button to create a new partition off of the existing partition. Provide a mount point and desired capacity, then click Add Mount Point.
1. Repeat as necessary for additional partitions, or click Done to return to the Anaconda main hub.

### Delete
1. From the Installation Destination spoke, in the Storage Configuration section, select the Automatic radio button, then click Done.
1. You should be presented with an "Installation Options" dialog, indicating the amount of disk space that is available for use and available to reclaim.
1. Click the Reclaim Space button.
1. Select a partition, then click the Delete button to delete the partition and reclaim the space.
1. Alternatively, click the Delete All button to delete all existing partitions.
1. When you have finished, click the Reclaim Space button to reclaim available free space.

## Expected Results
1. The installation should complete and boot successfully.
1. Resized partitions should correctly reflect the desired size. This may be verified using the `lsblk` command.
1. Deleted partitions should no longer exist.

## Testing in openQA
The following openQA test suites satisfy this release criteria:

- `install_delete_partial`
- `install_delete_pata`
- `install_resize_lvm`

{% include 'teams/testing/qa_testcase_bottom.md' %}
