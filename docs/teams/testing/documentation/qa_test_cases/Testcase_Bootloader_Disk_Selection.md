---
title: QA:Testcase Bootloader Disk Selection
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
    This test case is associated with the [Release_Criteria#Bootloader Disk Selection](../../guidelines/release_criteria/r9/9_release_criteria.md#bootloader-disk-selection) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This test case verifies that the user is able to select an alternative disk on which to install the bootloader. It also verifies that, if the user is so inclined, they may choose not to install a bootloader at all.

{% include 'teams/testing/qa_data_loss_warning.md' %}

## Setup
{% include 'teams/testing/qa_setup_boot_to_media.md' %}

## How to test
1. In the Installation Destination spoke, select the disk(s) to install to, then click the "Full disk summary and bootloader..." button at the bottom of the screen: ![Full disk summary and bootloader...](../../../../assets/teams/testing/bootloader.png){ loading=lazy }
1. Click the checkbox next to the disk on which the bootloader is desired
1. Alternatively, uncheck the boot checkbox next to all disks to skip bootloader installation
1. Proceed with installation on the test system.

## Expected Results
1. Installation should complete successfully.
1. Note that if no bootloader is installed, the system may not boot after installation is complete. This is expected.

{% include 'teams/testing/qa_testcase_bottom.md' %}
