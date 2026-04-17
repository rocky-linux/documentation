---
title: QA:Testcase Boot Methods Boot Iso
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#initialization-requirements](../../guidelines/release_criteria/r9/9_release_criteria.md#initialization-requirements) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This is to verify that the Anaconda installer starts correctly when booting from the Rocky Linux boot.iso.

## Setup
1. Prepare your system for booting the boot.iso image. This may involve writing the image to a USB key or burning it to an optical disk. Additionally, attaching the boot.iso to a virtual machine instance as a Virtual Optical Disk or mounting the boot.iso to server via baseboard management controller virtual media attach should be possible but is not expressly required.

## How to test
1. Boot the system from the prepared optical, USB media or virtual device attachment.
2. In the boot menu select the appropriate option to boot the installer.

## Expected Results
1. Graphical boot menu is displayed for users to select install options. Navigating the menu and selecting entries must work. If no option is selected, the installer should load after a reasonable timeout.
2. System boots into the Anaconda installer.

{% include 'teams/testing/qa_testcase_bottom.md' %}
