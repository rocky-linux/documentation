---
title: QA:Test Cases
author: Chris Stackpole
contributors: Trevor Cooper, Bob Robison
tested_with:
tags:
  - testing
revision_date: 2026-05-08
rc:
  prod: Rocky Linux
render_macros: true
---

Every release undergoes numerous tests to validate a proper release of Rocky Linux. The 2026.10 update of release criteria is the latest coordination between Release Engineering and Testing Team.

Specific Testcases can/will be implemented in either openQA or Sparky/Sparrow. For further details, please see:-
* [Testing's Meta Project](https://git.resf.org/testing/meta) repository
* [os-autoinst-distri-rocky](https://github.com/rocky-linux/os-autoinst-distri-rocky/issues) repository
* [Sparky Rocky](https://git.resf.org/testing/Sparky_Rocky) repository

For historical testing, please see the release channels in [Mattermost chat](https://chat.rockylinux.org).

For 9.9+, 10.3+ releases, please see [TestRARC](https://testrarc.rockylinux.org/).

Icon guide:-
* ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 
* ❗ - Important. It is best to have this tested, but if it isn't or if it fails then it won't block the release.
* ❎ - Release blocker. This must be tested and until it is, or if it fails, then the issue must be properly addressed.

The information below is intended to be for high level review. Details on which major release, architecture, and testing details are linked.

## Community Testable Items

These are items which are easy for most to be able to test without having a requirement of specific hardware/software testing.

| Category | Requirement | Test Case | Status |
|-|-|-|-|
| ⬇️ | [Physical Media Testing on CD/DVD/Bluray](Testcase_Physical_Media_Testing.md) | To ensure a user can burn the ISO files to physical disc and boot/install from that disc. | Community, openQA covered |
| ❎ | [Media Consistency Verification](Testcase_Media_Consistency_Verification.md) | To ensure that a user can write the ISO files to a thumbdrive and boot/install from that thumbdrive. | Community |
| ⬇️ | [Boot Live Image](Testcase_Live_Image.md) | To ensure that each live environment can boot into the intended desktop. | Community |
| ❗ | [FWUPD Secureboot](Testcase_FWUPD.md) | To ensure that secureboot and firmware updates function with the latest packages. | Community |

## Initialization Requirements

| Requirement                                                                                                                                                                                                                                                      | Test Case                                                                                                                          | Assignee | Status                                  |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|----------|-----------------------------------------|
| Release-blocking images must boot[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#release-blocking-images-must-boot) [{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#release-blocking-images-must-boot) | [QA:Testcase Boot Methods Boot ISO](Testcase_Boot_Methods_Boot_Iso.md)                                                             | @tcooper | template exists, openQA covered (ref)   |
| Release-blocking images must boot[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#release-blocking-images-must-boot) [{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#release-blocking-images-must-boot) | [QA:Testcase Boot Methods DVD](Testcase_Boot_Methods_Dvd.md)                                                                       | @tcooper | template exists, openQA covered (ref)   |
| Basic Graphics Mode behaviors[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#basic-graphics-mode-behaviors)                                                                                                                         | [QA:Testcase Basic Graphics Mode](Testcase_Basic_Graphics_Mode.md)                                                                 | @tcooper | openQA TestCase                         |
| VNC Graphics Mode behaviors[{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#vnc-graphics-mode-behaviors)                                                                                                                             | [QA:Testcase VNC Graphics Mode](Testcase_VNC_Graphics_Mode.md)                                                                     | @tcooper | openQA TestCase                         |
| No Broken Packages[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#no-broken-packages) [{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#no-broken-packages)                                              | [QA:Testcase Media Repoclosure](Testcase_Media_Repoclosure.md)[QA:Testcase Media File Conflicts](Testcase_Media_File_Conflicts.md) | @tcooper | manual using scripts or automated in CI |
| Repositories Must Match Upstream[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#repositories-must-match-upstream) [{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#repositories-must-match-upstream)    | [QA:Testcase repocompare](Testcase_Repo_Compare.md)                                                                                | @tcooper | manual using Skip's repocompare         |
| Debranding[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#debranding) [{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#debranding)                                                                      | [QA:Testcase Debranding Analysis](Testcase_Debranding.md)                                                                          | @tcooper | manual using scripts or automated in CI |

## Installer Requirements

| Requirement                    | Test Case                                                                                                                                                                              | Assignee   | Status                            |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------|-----------------------------------|
| Media Consistency Verification | [QA:Testcase Media USB dd](Testcase_Media_USB_dd.md)[QA:Testcase Boot Methods Boot ISO](Testcase_Boot_Methods_Boot_Iso.md)[QA:Testcase Boot Methods DVD](Testcase_Boot_Methods_Dvd.md) | @raktajino |                                   |
| Packages and Installer Sources | [QA:Testcase Packages and Installer Sources](Testcase_Packages_Installer_Sources.md)                                                                                                   | @raktajino | Implemented in openQA, documented |
| NAS (Network Attached Storage) | [QA:Testcase Network Attached Storage](Testcase_Network_Attached_Storage.md)                                                                                                           | @tbd       |                                   |
| Installation Interfaces        | [QA:Testcase Installation Interfaces](Testcase_Installation_Interfaces.md)                                                                                                             | @raktajino | Implemented in openQA, documented |
| Minimal Installation           | [QA:Testcase Minimal Installation](Testcase_Minimal_Installation.md)                                                                                                                   | @raktajino | Implemented in openQA, documented |
| Kickstart Installation         | [QA:Testcase Kickstart Installation](Testcase_Kickstart_Installation.md)                                                                                                               | @raktajino | Implemented in openQA, documented |
| Disk Layouts                   | [QA:Testcase Disk Layouts](Testcase_Disk_Layouts.md)                                                                                                                                   | @raktajino | Implemented in openQA, documented |
| Firmware RAID                  | [QA:Testcase Firmware RAID](Testcase_Firmware_RAID.md)                                                                                                                                 | @tbd       |                                   |
| Bootloader Disk Selection      | [QA:Testcase Bootloader Disk Selection](Testcase_Bootloader_Disk_Selection.md)                                                                                                         | @tbd       |                                   |
| Storage Volume Resize          | [QA:Testcase Storage Volume Resize](Testcase_Storage_Volume_Resize.md)                                                                                                                 | @raktajino | Implemented in openQA, documented |
| Update Image                   | [QA:Testcase Update Image](Testcase_Update_Image.md)                                                                                                                                   | @raktajino | Implemented in openQA, documented |
| Installer Help                 | [QA:Testcase Installer Help](Testcase_Installer_Help.md)                                                                                                                               | @raktajino | Implemented in openQA, documented |
| Installer Translations         | [QA:Testcase Installer Translations](Testcase_Installer_Translations.md)                                                                                                               | @tbd       | Implemented in openQA, document   |

## Cloud Image Requirements

| Requirement                         | Test Case                                                                                                                                                                                      | Assignee | Status           |
|-------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|------------------|
| Images Published to Cloud Providers | [QA:Testcase TBD](Testcase_Template.md)                                                                                                                                                        | @tbd     |                  |
| Vagrant Images Boot Properly        | [QA:Testcase Vagrant Images - BIOS Boot](Testcase_Vagrant_Images.md#vagrant-file-for-bios-boot)[QA:Testcase Vagrant Images - UEFI Boot](Testcase_Vagrant_Images.md#vagrant-file-for-uefi-boot) | @tcooper | manual, document |

## Post-Installation Requirements

| Requirement                                      | Test                                                                                                                                 | Assignee | Status                                                               |
|--------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|----------|----------------------------------------------------------------------|
| System Services                                  | [QA:Testcase System Services](Testcase_Post_System_Services.md)                                                                      | @lumarel | manual guide documented                                              |
| Keyboard Layout                                  | [QA:Testcase Keyboard Layout](Testcase_Post_Keyboard_Layout.md)                                                                      | @lumarel | implemented in openQA, documented                                    |
| SELinux Errors (Server)                          | [QA:Testcase SELinux Errors on Server](Testcase_Post_SELinux_Errors_Server.md)                                                       | @lumarel | implemented in openQA, documented                                    |
| SELinux and Crash Notifications (Desktop Only)   | [QA:Testcase SELinux Errors on Desktop](Testcase_Post_SELinux_Errors_Desktop.md)                                                     | @lumarel | partly implemented in openQA, documented                             |
| Default Application Functionality (Desktop Only) | [QA:Testcase Application Functionality](Testcase_Post_Application_Functionality.md)                                                  | @lumarel | implemented in openQA, additionally documented for manual inspection |
| Default Panel Functionality (Desktop Only)       | [QA:Testcase GNOME UI Functionality](Testcase_Post_GNOME_UI_Functionality.md)                                                        | @lumarel | implemented in openQA, additionally documented for manual inspection |
| Dual Monitor Setup (Desktop Only)                | [QA:Testcase Multimonitor Setup](Testcase_Post_Multimonitor_Setup.md)                                                                | @lumarel | manual guide documented                                              |
| Artwork and Assets (Server and Desktop)          | [QA:Testcase Artwork and Assets](Testcase_Post_Artwork_and_Assets.md)                                                                | @lumarel | implemented in openQA, additionally documented for manual inspection |
| Packages and Module Installation                 | [QA:Testcase Basic Package installs](Testcase_Post_Package_installs.md)[QA:Testcase Module Streams](Testcase_Post_Module_Streams.md) | @lumarel | partly implemented in openQA, documented                             |
| Identity Management (FreeIPA)                    | [QA:Testcase Identity Management](Testcase_Post_Identity_Management.md)                                                              | @lumarel | implemented in openQA, documented                                    |

{% include 'teams/testing/content_bottom.md' %}
