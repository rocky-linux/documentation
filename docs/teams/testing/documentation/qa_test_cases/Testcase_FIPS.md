---
title: QA:Testcase FIPS
author: Chris Stackpole
contributors: 
tags:
  - testing
  - qa
revision_date: 2026-10-09
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Description

This is to ensure that FIPS is working.

* ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 
* ❗ - Important. It is best to have this tested, but if it isn't or if it fails then it won't block the release.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  9 | ⬇️       | N/A     | N/A     | N/A   | ❗      |
| Rocky Linux 10 | ⬇️       | N/A     | N/A     | N/A   | ❗      |

## Setup

1. During installation select FIPS mode. Reboot into the install for testing.

## How to test

1. `fips-mode-setup --check`
2. `cat /proc/sys/crypto/fips_enabled # Should return 1`
3. `grep fips=1 /proc/cmdline`

## Expected Results

1. `FIPS mode is enabled.` should be displayed.
2. `1` should be returned.
3. `fips=1` should be highlighted.
   {% include 'teams/testing/qa_testcase_bottom.md' %}
