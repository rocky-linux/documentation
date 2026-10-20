---
title: QA:Testcase Installation Interfaces
author: Al Bowles
contributors: Chris Stackpole
tested_with: 8.10, 9.7
tags:
  - testing
  - qa
revision_date: 2026-05-08rc:
  prod: Rocky Linux
  ver:
  - 8
  - 9
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#Installation Interfaces](../../guidelines/release_criteria/r9/9_release_criteria.md#installation-interfaces) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

This test case verifies that the installer can complete an installation using all Anaconda spokes.

* ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 
* ❗ - Important. It is best to have this tested, but if it isn't or if it fails then it won't block the release.

{% include 'teams/testing/qa_data_loss_warning.md' %}

## Releases, Architectures, and ISO's

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | -------- | ------ | ----- | ------ |
| Rocky Linux  9 | ❗       | ⬇️        | N/A    | ⬇️     | ❗      |
| Rocky Linux 10 | ❗       | ⬇️        | ⬇️      | ⬇️     | ❗      |

## Setup

{% include 'teams/testing/qa_setup_boot_to_media.md' %}

## How to test

<!-- localization -->

1. Select a keyboard layout in the Keyboard Layout spoke
1. Set language support in the Language spoke
1. Set the system time and date in the Time and Date spoke

<!-- user settings -->

1. Set a root password in the Root Password spoke
1. Create a user in the user creation spoke

<!-- software -->

1. Select an installation source from the Installation Source spoke
1. Select a set of packages to install from the Package Selection spoke

<!-- system -->

1. Set a disk to which the operating system should install in the Installation Destination spoke
1. Set the kdump state from the Kdump spoke
1. Configure the system's network and hostname from the Network and Hostname spoke
1. Select a security policy from the Security Policy spoke

## Expected Results

1. The installation should complete and boot successfully.

## Testing in openQA

The following openQA test suites satisfy this release criteria:

- `install_arabic_language` OR `install_asian_language`

<!--
TODO
- something with kdump
- set hostname
- set security policy
-->

{% include 'teams/testing/qa_testcase_bottom.md' %}
