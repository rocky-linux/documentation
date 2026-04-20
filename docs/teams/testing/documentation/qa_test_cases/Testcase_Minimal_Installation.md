---
title: QA:Testcase Minimal Installation
author: Al Bowles
revision_date: 2026-04-17
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

{% include 'teams/testing/qa_data_loss_warning.md' %}

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
