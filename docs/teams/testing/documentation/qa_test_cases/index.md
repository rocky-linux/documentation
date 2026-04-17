---
title: QA:Test Cases
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
render_macros: true
---

This page lists all test cases in work and who is working on them...

## Initialization Requirements

| Requirement                                         | Test Case                                                                | Assignee                | Status                                  |
| --------------------------------------------------- | ------------------------------------------------------------------------ | ----------------------- | --------------------------------------- |
| Release-blocking images must boot<br>[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#release-blocking-images-must-boot) [{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#release-blocking-images-must-boot) | [QA:Testcase Boot Methods Boot ISO](Testcase_Boot_Methods_Boot_Iso.md) | @tcooper | template exists, openQA covered (ref) |
| Release-blocking images must boot<br>[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#release-blocking-images-must-boot) [{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#release-blocking-images-must-boot) | [QA:Testcase Boot Methods DVD](Testcase_Boot_Methods_Dvd.md) | @tcooper | template exists, openQA covered (ref) |
| Basic Graphics Mode behaviors<br>[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#basic-graphics-mode-behaviors) | [QA:Testcase Basic Graphics Mode](Testcase_Basic_Graphics_Mode.md) | @tcooper | openQA TestCase |
| VNC Graphics Mode behaviors<br>[{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#vnc-graphics-mode-behaviors) | [QA:Testcase VNC Graphics Mode](Testcase_VNC_Graphics_Mode.md) | @tcooper | openQA TestCase |
| No Broken Packages<br>[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#no-broken-packages) [{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#no-broken-packages) | [QA:Testcase Media Repoclosure](Testcase_Media_Repoclosure.md)<br>[QA:Testcase Media File Conflicts](Testcase_Media_File_Conflicts.md) | @tcooper | manual using scripts or automated in CI |
| Repositories Must Match Upstream<br>[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#repositories-must-match-upstream) [{{ rc.prod }} 9 ](../../guidelines/release_criteria/r9/9_release_criteria.md#repositories-must-match-upstream) | [QA:Testcase repocompare](Testcase_Repo_Compare.md) | @tcooper | manual using Skip's repocompare |
| Debranding<br>[{{ rc.prod }} 8](../../guidelines/release_criteria/r8/8_release_criteria.md#debranding) [{{ rc.prod }} 9](../../guidelines/release_criteria/r9/9_release_criteria.md#debranding) | [QA:Testcase Debranding Analysis](Testcase_Debranding.md) | @tcooper | manual using scripts or automated in CI |


## Installer Requirements

| Requirement                                         | Test Case                                                                                 | Assignee                | Status                                  |
| --------------------------------------------------- | ----------------------------------------------------------------------------------------- | ----------------------- | --------------------------------------- |
| Media Consistency Verification                      | [QA:Testcase Media USB dd](Testcase_Media_USB_dd.md)<br>[QA:Testcase Boot Methods Boot ISO](Testcase_Boot_Methods_Boot_Iso.md)<br>[QA:Testcase Boot Methods DVD](Testcase_Boot_Methods_Dvd.md)  | @raktajino              |                                         |
| Packages and Installer Sources                      | [QA:Testcase Packages and Installer Sources](Testcase_Packages_Installer_Sources.md)      | @raktajino              | Implemented in openQA, document         |
| NAS (Network Attached Storage)                      | [QA:Testcase Network Attached Storage](Testcase_Network_Attached_Storage.md)              | @raktajino              |                                         |
| Installation Interfaces                             | [QA:Testcase Installation Interfaces](Testcase_Installation_Interfaces.md)                | @raktajino              | Implemented in openQA, document         |
| Minimal Installation                                | [QA:Testcase Minimal Installation](Testcase_Minimal_Installation.md)                      | @raktajino              | Implemented in openQA, document         |
| Kickstart Installation                              | [QA:Testcase Kickstart Installation](Testcase_Kickstart_Installation.md)                  | @raktajino              | Implemented in openQA, document         |
| Disk Layouts                                        | [QA:Testcase Disk Layouts](Testcase_Disk_Layouts.md)                                      | @raktajino              | Implemented in openQA, document         |
| Firmware RAID                                       | [QA:Testcase Firmware RAID](Testcase_Firmware_RAID.md)                                    | @raktajino              |                                         |
| Bootloader Disk Selection                           | [QA:Testcase Bootloader Disk Selection](Testcase_Bootloader_Disk_Selection.md)            | @raktajino              |                                         |
| Storage Volume Resize                               | [QA:Testcase Storage Volume Resize](Testcase_Storage_Volume_Resize.md)                    | @raktajino              | Implemented in openQA, document         |
| Update Image                                        | [QA:Testcase Update Image](Testcase_Update_Image.md)                                      | @raktajino              | Implemented in openQA, document         |
| Installer Help                                      | [QA:Testcase Installer Help](Testcase_Installer_Help.md)                                  | @raktajino              | Implemented in openQA, document         |
| Installer Translations                              | [QA:Testcase Installer Translations](Testcase_Installer_Translations.md)                  | @raktajino              | Implemented in openQA, document         |


## Cloud Image Requirements

| Requirement                                         | Test Case                                                                | Assignee                | Status                                  |
| --------------------------------------------------- | ------------------------------------------------------------------------ | ----------------------- | --------------------------------------- |
| Images Published to Cloud Providers                 | [QA:Testcase TBD](Testcase_Template.md)                                  | @tbd                    |                                         |
| Vagrant Images Boot Properly                        | [QA:Testcase Vagrant Images - BIOS Boot](Testcase_Vagrant_Images.md#vagrant-file-for-bios-boot)<br>[QA:Testcase Vagrant Images - UEFI Boot](Testcase_Vagrant_Images.md#vagrant-file-for-uefi-boot)                       | @tcooper |   |


## Post-Installation Requirements

| Requirement                                      | Test Case                                                                                                                                | Assignee | Status                                                               |
|--------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|----------|----------------------------------------------------------------------|
| System Services                                  | [QA:Testcase System Services](Testcase_Post_System_Services.md)                                                                          | @lumarel | manual guide documented or needs new openQA testcase                 |
| Keyboard Layout                                  | [QA:Testcase Keyboard Layout](Testcase_Post_Keyboard_Layout.md)                                                                          | @lumarel | implemented in openQA                                                |
| SELinux Errors (Server)                          | [QA:Testcase SELinux Errors on Server](Testcase_Post_SELinux_Errors_Server.md)                                                           | @lumarel | implemented in openQA                                                |
| SELinux and Crash Notifications (Desktop Only)   | [QA:Testcase SELinux Errors on Desktop](Testcase_Post_SELinux_Errors_Desktop.md)                                                         | @lumarel | partly implemented in openQA                                         |
| Default Application Functionality (Desktop Only) | [QA:Testcase Application Functionality](Testcase_Post_Application_Functionality.md)                                                      | @lumarel | manual guide documented                                              |
| Default Panel Functionality (Desktop Only)       | [QA:Testcase GNOME UI Functionality](Testcase_Post_GNOME_UI_Functionality.md)                                                            | @lumarel | implemented in openQA, additionally documented for manual inspection |
| Dual Monitor Setup (Desktop Only)                | [QA:Testcase Multimonitor Setup](Testcase_Post_Multimonitor_Setup.md)                                                                    | @lumarel | manual guide documented                                              |
| Artwork and Assets (Server and Desktop)          | [QA:Testcase Artwork and Assets](Testcase_Post_Artwork_and_Assets.md)                                                                    | @lumarel | implemented in openQA, additionally documented for manual inspection |
| Packages and Module Installation                 | [QA:Testcase Basic Package installs](Testcase_Post_Package_installs.md)<br>[QA:Testcase Module Streams](Testcase_Post_Module_Streams.md) | @lumarel | partly implemented in openQA, manual guide documented                |
| Identity Management (FreeIPA)                    | [QA:Testcase Identity Management](Testcase_Post_Identity_Management.md)                                                                  | @lumarel | manual guide documented, PR open for openQA implementation           |


{% include 'teams/testing/content_bottom.md' %}
