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
* ❌ - Release blocker. This must be tested and until it is, or if it fails, then the issue must be properly addressed.

The information below is intended to be for high level review. Details on which major release, architecture, and testing details are linked.

## Community Testable Items

These are items which are easy for most to be able to test without having a requirement of specific hardware/software testing.

| Category | Requirement                                                                   | Test Case                                                                                            | Status            |
| -------- | ----------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ----------------- |
| ⬇️        | [Physical Media Testing on CD/DVD/Bluray](Testcase_Physical_Media_Testing.md) | To ensure a user can burn the ISO files to physical disc and boot/install from that disc.            | Community, openQA |
| ❌        | [Media Consistency Verification](Testcase_Media_Consistency_Verification.md)  | To ensure that a user can write the ISO files to a thumbdrive and boot/install from that thumbdrive. | Community         |
| ⬇️        | [Boot Live Image](Testcase_Live_Image.md)                                     | To ensure that each live environment can boot into the intended desktop.                             | Community         |
| ❗        | [FWUPD Secureboot](Testcase_FWUPD.md)                                         | To ensure that secureboot and firmware updates function with the latest packages.                    | Community         |
| ❗        | [Test Upgrade](Testcase_Upgrade.md)                                           | Ensure upgrades from previous versions work without issues.                                          | Manual            |
| ❗        | [Test Torrents](Testcase_Torrents.md)                                         | Verify Torrents (when released).                                                                     | Manual            |
| ⬇️      | [Hardware Probe](Testcase_Hardware_Probe.md)                                     | Hardware Probe (physical hardware; additional test; not RelEng request).                             | Manual            |

## Initialization Requirements

| Category | Requirement                                              | Test Case                                                                | Status        |
| -------- | -------------------------------------------------------- | ------------------------------------------------------------------------ | ------------- |
| ❌        | [Media Repoclosure](Testcase_Media_Repoclosure.md)       | To ensure that there are no critical errors between release and upstream | Manual Script |
| ❌        | [Media File Conflicts](Testcase_Media_File_Conflicts.md) | To ensure that there are no critical errors between package streams.     | Manual Script |
| ❗        | [Repo Compare](Testcase_Repo_Compare.md)                 | To ensure packages in repositories match upstream.                       | Manual Script |
| ❌        | [No Insights](Testcase_Packages_No_Insights.md)          | To ensure Insights has been removed.                                     | Manual Script |
| ❌        | [No RHSM](Testcase_Packages_No_RHSM.md)                  | To ensure RHSM has been removed.                                         | Manual Script |
| ❌        | [Debranding](Testcase_Debranding.md)                     | Ensure all debranding has been applied properly.                         | Manual Script |

## Installer Requirements

| Category | Requirement                                                              | Test Case                                                                                                                | Status          |
| -------- | ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ | --------------- |
| ⬇️        | [VNC Graphics Mode](Testcase_VNC_Graphics_Mode.md)                       | EL9:- Ensure that systems with very basic graphics can install.                                                          | openQA          |
| ⬇️        | [Check RDP Graphics Mode](Testcase_RDP_Graphics_Mode.md)                 | EL10:- Ensure that systems with very basic graphics can install.                                                         | openQA          |
| ⬇️        | [Packages and Installer Sources](Testcase_Packages_Installer_Sources.md) | Check all options for supported installation.                                                                            | openQA          |
| ❗        | [Installation Interfaces](Testcase_Installation_Interfaces.md)           | The installer must be able to complete an installation using all supported spokes.                                       | openQA          |
| ❗        | [Minimal Installation](Testcase_Minimal_Installation.md)                 | Ensure a minimal package set installation is functional.                                                                 | openQA          |
| ❗        | [Kickstart Installation](Testcase_Kickstart_Installation.md)             | Ensure kickstart installations are working.                                                                              | openQA, Sparrow |
| ❗        | [Disk Layouts](Testcase_Disk_Layouts.md)                                 | Test installs to a variety of partitions.                                                                                | openQA          |
| ❗        | [Storage Volume Resize](Testcase_Storage_Volume_Resize.md)               | Test resizing in the installation.                                                                                       | openQA          |
| ❗        | [Installer Help](Testcase_Installer_Help.md)                             | Any element in the installer which contains a “help” text must display the appropriate help documentation when selected. | openQA          |
| ❗        | [Installer Translations](Testcase_Installer_Translations.md)             | Test all translations available.                                                                                         | openQA          |

## Post-Installation Requirements

| Category | Requirement                                                             | Test Case                                                                                                                                                                                                                                                   | Status         |
| -------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| ❌        | [System Service SSHD](Testcase_Post_System_Services.md)                 | Ensure SSH works.                                                                                                                                                                                                                                           | openQA, manual |
| ❌        | [System Service FirewallD](Testcase_Post_System_Services.md)            | Ensure FirewallD works.                                                                                                                                                                                                                                     | openQA, manual |
| ❌        | [System Service AuditD](Testcase_Post_System_Services.md)               | Ensure AuditD works.                                                                                                                                                                                                                                        | openQA, manual |
| ❌        | [System Service ChronyD](Testcase_Post_System_Services.md)              | Ensure ChronyD works.                                                                                                                                                                                                                                       | openQA, manual |
| ❗        | [Keyboard Layout](Testcase_Post_Keyboard_Layout.md)                     | Test that keyboard matches layout.                                                                                                                                                                                                                          | openQA         |
| ❗        | [SELinux Errors on Server](Testcase_Post_SELinux_Errors_Server.md)      | Check for SELinux denials.                                                                                                                                                                                                                                  | openQA         |
| ❗        | [SELinux Errors on Desktop](Testcase_Post_SELinux_Errors_Desktop.md)    | Check for SELinux denials.                                                                                                                                                                                                                                  | openQA         |
| ❗        | [Application Functionality](Testcase_Post_Application_Functionality.md) | Applications that can be launched within GNOME or on the command line must start successfully and withstand basic functionality tests.                                                                                                                      | openQA, manual |
| ❗        | [GNOME UI Functionality](Testcase_Post_GNOME_UI_Functionality.md)       | All elements of GNOME should function properly in regular use.                                                                                                                                                                                              | openQA, manual |
| ⬇️        | [Multimonitor Setup](Testcase_Post_Multimonitor_Setup.md)               | Computers using two monitors, the graphical output is correctly shown on both monitors.                                                                                                                                                                     | manual         |
| ⬇️        | [Artwork and Assets](Testcase_Post_Artwork_and_Assets.md)               | Proposed final artwork (such as wallpapers and other assets) must be included. A wallpaper from this package should show up as a default for GDM and GNOME.                                                                                                 | manual         |
| ⬇️        | [Basic Package Installs](Testcase_Post_Package_installs.md)             | Packages (non-module) should be able to be installed without conflicts or dependencies on repositories outside of Rocky Linux.                                                                                                                              | openQA         |
| ⬇️        | [Module Stream Package Installs](Testcase_Post_Module_Streams.md)       | Default modules (as listed in dnf module list) should be installed without requiring them to be enabled.<br/><br/>Module streams should be able to be switched and those packages should be able to be installed without errors or unresolved dependencies. | openQA         |
| ⬇️        | [Identity Management](Testcase_Post_Identity_Management.md)             | It should be possible to setup a IdM server (FreeIPA), use it's functionality and connect clients.                                                                                                                                                          | openQA         |
| ❗        | [FIPS Mode](Testcase_FIPS.md)                                           | Verify FIPS mode is functional and working.                                                                                                                                                                                                                 | openQA         |

## Cloud Image Testing

| Category | Requirement                                                  | Test Case                                     | Status |
| -------- | ------------------------------------------------------------ | --------------------------------------------- | ------ |
| ❌        | [Container Base](Testcase_Cloud_Container_Base.md)           | Verify Container Base is functional           | manual |
| ❌        | [Container Minimal](Testcase_Cloud_Container_Minimal.md)     | Verify Container Minimal is functional        | manual |
| ❌        | [Container UBI](Testcase_Cloud_Container_UBI.md)             | Verify Container UBI is functional            | manual |
| ❌        | [GenericCloud](Testcase_Cloud_Generic_Cloud.md)              | Verify GenericCloud is functional             | manual |
| ❌        | [Amazon EC2](Testcase_Cloud_Amazon_EC2.md)                   | Verify Amazon EC2 image is functional         | manual |
| ❌        | [Azure](Testcase_Cloud_Azure.md)                             | Verify Azure image is functional              | manual |
| ❗        | [Oracle](Testcase_Cloud_Oracle.md)                           | Verify Oracle image is functional             | manual |
| ⬇️        | [Vagrant - Libvirt](Testcase_Cloud_Vagrant_Libvirt.md)       | Verify Vagrant Libvirt image is functional    | manual |
| ⬇️        | [Vagrant - VirtualBox](Testcase_Cloud_Vagrant_VirtualBox.md) | Verify Vagrant VirtualBox image is functional | manual |
| ⬇️        | [Vagrant - VMWare](Testcase_Cloud_Vagrant_VMWare.md)         | Verify Vagrant VMWare image is functional     | manual |

## Sparrow/Sparky Testing

| Category | Requirement                                       | Test Case                                 | Status  |
| -------- | ------------------------------------------------- | ----------------------------------------- | ------- |
|          | [Anacrond](Sparrow_Anacrond.md)                   | Test documentation of Anacrond            | Sparrow |
|          | [Bind](Sparrow_Bind.md)                           | Test documentation of Bind                | Sparrow |
|          | [Caddy](Sparrow_Caddy.md)                         | Test documentation of Caddy               | Sparrow |
|          | [Chrony](Sparrow_Chrony.md)                       | Test documentation of Chrony              | Sparrow |
|          | [Chyrp](Sparrow_Chyrp.md)                         | Test documentation of Chyrp               | Sparrow |
|          | [Cronie](Sparrow_Cronie.md)                       | Test documentation of Cronie              | Sparrow |
|          | [DNF](Sparrow_DNF.md)                             | Test documentation of DNF                 | Sparrow |
|          | [Knot](Sparrow_Knot.md)                           | Test documentation of Knott               | Sparrow |
|          | [Nvinx Multi Site](Sparrow_Nginx_Multi_Site.md)   | Test documentation of Nginx (Multi site)  | Sparrow |
|          | [Nginx Single Site](Sparrow_Nginx_Single_Site.md) | Test documentation of Nginx (Single site) | Sparrow |
|          | [NFS](Sparrow_NFS.md)                             | Test documentation of NFS                 | Sparrow |
|          | [NSD](Sparrow_NSD.md)                             | Test documentation of NSD                 | Sparrow |
|          | [PHP](Sparrow_PHP.md)                             | Test documentation of PHP                 | Sparrow |
|          | [Podman](Sparrow_Podman.md)                       | Test documentation of Podman              | Sparrow |
|          | [Python SSL](Sparrow_Python_SSL.md)               | Test documentation of  Python SSL         | Sparrow |
|          | [Redis](Sparrow_Redis.md)                         | Test documentation of Redis               | Sparrow |
|          | [Slurm](Sparrow_Slurm.md)                         | Test documentation of Slurm               | Sparrow |
|          | [Swap](Sparrow_Swap.md)                           | Test documentation of Swap                | Sparrow |
|          | [Tar](Sparrow_Tar.md)                             | Test documentation of Tar                 | Sparrow |
|          | [Unbound](Sparrow_Unbound.md)                     | Test documentation of Unbound             | Sparrow |
|          | [Wordpress LAMP](Sparrow_WP_LAMP.md)              | Test documentation of Wordpress LAMP      | Sparrow |
|          | [XFS Recovery](Sparrow_XfsRecovery.md)            | Test documentation of XFS Recovery        | Sparrow |
|          | [ZFS](Sparrow_ZFS.md)                             | Test documentation of ZFS                 | Sparrow |

## SIG/AltArch

| Category | Requirement                                        | Test Case                                           | Status |
| -------- | -------------------------------------------------- | --------------------------------------------------- | ------ |
| ⬇️        | [Raspberry Pi](Testcase_SIGAltArch_RPi.md)         | Verify Raspberry Pi 3/3b/4/5 can be booted/upgraded | manual |
| ⬇️        | [SiFive P550](Testcase_SIGAltArch_P550.md)         | Verify P550 can be booted/upgraded                  | manual |
| ⬇️        | [StarFive VisionFive2](Testcase_SIGAltArch_VF2.md) | Verify VF2 can be booted/upgraded                   | manual |

{% include 'teams/testing/content_bottom.md' %}
