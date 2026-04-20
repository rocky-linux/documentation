---
title: QA:Testcase VNC Graphics Mode
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
This test case will verify that release-blocking installers function as intended using the VNC installation method on supported systems and classes of hardware.

{% include 'teams/testing/qa_testcase_supported_systems.md' %}

## Setup
1. Obtain access to supported system and hardware class to be installed.
2. Prepare appropriate media for the selected ISO to be tested.
    - Example: [QA:Testcase Media USB dd](Testcase_Media_USB_dd.md)
3. Obtain access to remote system with a VNC client installed to use for VNC connection.


!!! info "Suggested VNC Clients"
    Both [`tigervnc`](https://tigervnc.org) and [`vinagre`](https://wiki.gnome.org/Apps/Vinagre) are VNC clients provided in Rocky Linux but any VNC client may be used.

## How to test
1. Boot the system from the prepared optical, USB media or virtual device attachment.
    - Examples: [QA:Testcase Custom Boot Methods Boot ISO](Testcase_Custom_Boot_Methods_Boot_Iso.md)
2. Interrupt the kernel boot and specify the appropriate VNC installation option on the boot command line.
3. Proceed with installation on the test system.<br>**Depending on installer choices this MAY destroy all the data on the test system.**
4. Depending on the choice or `direct` or `connect` mode connect inbound to the system under test or wait for it to connect to your listening VNC client.

!!! error "DATA LOSS"
    If you choose to complete the installation of the test system any/all data on the system may be lost. Please do not install on a system whose contents you need to keep.

## Expected Results
1. Connection to (with direct mode) or from (in connect mode) to the Anaconda installer using VNC is possible.
2. Anaconda installer presents a usable graphical intallation environment.
3. System under test can be installed normally.
4. After reboot system boots into graphical environment.
5. After login user is able to operate the graphical environment.

{% include 'teams/testing/qa_testcase_bottom.md' %}
