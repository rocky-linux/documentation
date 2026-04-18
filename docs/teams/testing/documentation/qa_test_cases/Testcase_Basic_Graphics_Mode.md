---
title: QA:Testcase Basic Graphics Mode
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

!!! error "REFERENCED RELEASE CRITERIA IS OVERLY GENERAL AND UNTESTABLE"
    The associated release criteria, [Release_Criteria#basic-graphics-mode-behaviors](../../guidelines/release_criteria/r8/8_release_criteria.md#basic-graphics-mode-behaviors), for this test case is overly general and **must** be modified to specific enough to be testable.

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#basic-graphics-mode-behaviors](../../guidelines/release_criteria/r8/8_release_criteria.md#basic-graphics-mode-behaviors) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This test case will verify that release-blocking installers function as intended using the generic video driver option (“basic graphics mode”) on supported systems and classes of hardware.

{% include 'teams/testing/qa_testcase_supported_systems.md' %}

## Setup
1. Obtain access to supported system and hardware class to be installed.
2. Prepare appropriate media for the selected ISO to be tested.
    - Example: [QA:Testcase Media USB dd](Testcase_Media_USB_dd.md)

## How to test
1. Boot the system from the prepared optical, USB media or virtual device attachment.
    - Examples: [QA:Testcase Boot Methods Boot ISO](Testcase_Boot_Methods_Boot_Iso.md), [QA:Testcase Boot Methods DVD](Testcase_Boot_Methods_Dvd.md)
2. In the boot menu select the appropriate option to boot the installer.
3. In the installer select the appropriate option to intall in basic graphics mode.
4. Proceed with installation on the test system.<br>**Depending on installer choices this MAY destroy all the data on the test system.**

!!! error "DATA LOSS"
    If you choose to complete the installation of the test system any/all data on the system may be lost. Please do not install on a system whose contents you need to keep.

## Expected Results
1. Selection of basic graphics mode in the Anaconda installer is possible.
2. Anaconda installer presents a usable graphical intallation environment.
3. System under test can be installed normally.
4. After reboot system boots into graphical environment.
5. After login user is able to operate the graphical environment.

{% include 'teams/testing/qa_testcase_bottom.md' %}
