---
title: QA:Testcase Firmware RAID
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
    This test case is associated with the [Release_Criteria#Firmware RAID](../../guidelines/release_criteria/r9/9_release_criteria.md#firmware-raid) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
The installer must be able to detect and install to firmware RAID devices. Note that system-specific bugs do not count as blockers. It is likely that some hardware support might be broken or not available at all. DUDs (driver update disks) are not considered for this criteria.

## Setup
1. Add steps for setup for this Testcase.

## How to test
1. Do this first...
2. Then do this...

## Expected Results
1. This is what you should see/verify.
2. You should also see/verify this.

{% include 'teams/testing/qa_testcase_bottom.md' %}
