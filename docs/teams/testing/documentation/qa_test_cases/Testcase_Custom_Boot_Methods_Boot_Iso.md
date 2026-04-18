---
title: QA:Testcase Custom Boot Methods Boot Iso
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver: 9
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#vnc-graphics-mode-behaviors](../../guidelines/release_criteria/r9/9_release_criteria.md#vnc-graphics-mode-behaviors) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This is to verify that the Anaconda installer starts correctly when booting from the Rocky Linux boot.iso using a custom kernel command line.

## Setup
1. Prepare your system for booting the boot.iso image. This may involve writing the image to a USB key or burning it to an optical disk. Additionally, attaching the boot.iso to a virtual machine instance as a Virtual Optical Disk or mounting the boot.iso to server via baseboard management controller virtual media attach should be possible but is not expressly required.

## How to test
1. Boot the system from the prepared optical, USB media or virtual device attachment.
2. In the boot menu select the appropriate option to boot the installer.
3. Interrupt the normal boot and edit the kernel command line.
4. Add appropriate/required options to the kernel command line and resume booting into the installer.
    - Example: For network install from an alternate repository add `--inst.url=http://<server>/<path_to_BaseOS_repo>` and (optionally) `--inst.repo=AppStream,http://<server>/<path_to_AppStream_repo>` to the kernel command line.
    - Example: For VNC install in **Direct Mode** add `--inst.vnc` to the kernel command line. For VNC install in **Connect Mode** add `--inst.vnc` and `--inst.vncserver=<host>:<port>` to the kernel command line.

## Expected Results
1. Boot menu is displayed for users to select install options. Navigating the menu and selecting entries must work. Editing the boot command line must be possible. If no option is selected, the installer should load after a reasonable timeout.
2. System boots into the Anaconda installer and any command line options specified are utilized.

{% include 'teams/testing/qa_testcase_bottom.md' %}
