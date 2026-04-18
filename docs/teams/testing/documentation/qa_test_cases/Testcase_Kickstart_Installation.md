---
title: QA:Testcase Kickstart Installation
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
    This test case is associated with the [Release_Criteria#Kickstart Installation](../../guidelines/release_criteria/r9/9_release_criteria.md#kickstart-installation) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This test case verifies that installations via both local and remote Kickstart configuration files are successful.

{% include 'teams/testing/qa_data_loss_warning.md' %}

## Setup
1. Copy a valid Kickstart file to a USB stick
1. Connect the USB stick to the test system
{% include 'teams/testing/qa_setup_boot_to_media.md' %}
1. Hit the Tab key to edit the boot command
1. Provide a local Kickstart file by supplying the GRUB boot option `inst.ks=file:/path/to/local.ks` or a remote Kickstart file by supplying the GRUB boot option `inst.ks=https://git.resf.org/testing/createhdds/raw/branch/rocky/server.ks`.

## How to test
1. Continue booting the installer as normal.

## Expected Results
1. The installation should complete and boot successfully, automatically populating the options specified in the Kickstart file.

## Testing in openQA
The following openQA test suites satisfy this release criteria:

- `install_kickstart_nfs`
- `server_realmd_join_kickstart`
<!-- TODO provide a test suite that does not require PARALLEL_WITH= -->

{% include 'teams/testing/qa_testcase_bottom.md' %}
