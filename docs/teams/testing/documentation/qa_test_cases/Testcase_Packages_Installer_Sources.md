---
title: QA:Testcase Packages and Installer Sources
author: Al Bowles
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#Packages and Installer Sources](../../guidelines/release_criteria/r9/9_release_criteria.md#packages-and-installer-sources) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This test case verifies that the installer can successfully install any of the supported package sets via any of the supported installer sources.

The following package sets are supported for installs from local media:

- server
- minimal

The following package sets are only available from remote sources and require a network connection:

- workstation
- graphical-server
- virtualization-host

{% include 'teams/testing/qa_data_loss_warning.md' %}

## Setup
{% include 'teams/testing/qa_setup_boot_to_media.md' %}

## How to test
1. For local package installations it is not necessary to enable networking or specify a mirror.
1. For package installation from remote sources:
    1. From the Network and Hostname spoke, enable networking.
    1. From the Installation Source spoke, configure a remote software source, supplying an appropriate [mirror](https://mirrors.rockylinux.org) for the version and architecture under test.
1. Complete the installer and wait for the machine to reboot.

## Expected Results
1. The installation should complete and boot successfully.
1. If a graphical package set was specified, the system should boot to a graphical login screen.

## Testing in openQA
The following openQA test suites satisfy this release criteria, provided they pass the `_do_install_reboot` module at a minimum:

- `install_packageset_server`
- `install_packageset_minimal`
- `install_packageset_workstation`
- `install_packageset_graphical-server`
- `install_packageset_virtualization-host`

{% include 'teams/testing/qa_testcase_bottom.md' %}
