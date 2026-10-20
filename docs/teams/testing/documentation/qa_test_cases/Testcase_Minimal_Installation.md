---
title: QA:Testcase Minimal Installation
author: Al Bowles
contributors: Chris Stackpole
tested_with: 8.10, 9.7
tags:
  - testing
  - qa
revision_date: 2026-05-08
rc:
  prod: Rocky Linux
  ver:
  - 8
  - 9
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#Minimal Installation](../../guidelines/release_criteria/r9/9_release_criteria.md#minimal-installation) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

This test case verifies that a networked minimal installation is able to install the 'Minimal' package set. The installation should not require use of local packages to complete.

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

1. From the Installation Source spoke, configure a remote repository source from [MirrorManager](https://mirrors.rockylinux.org) appropriate to the architecture under test.
1. From the Software Selection spoke, select the Minimal package set.
1. Complete the installation using desired parameters.

## Expected Results

1. The installation should complete and boot successfully.

## Testing in openQA

The following openQA test suites satisfy this release criteria:

- `install_minimal`

{% include 'teams/testing/qa_testcase_bottom.md' %}
