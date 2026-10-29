---
title: QA:Hardware Probe
author: Chris Stackpole
contributors: 
tested_with: 8.10, 9.8, 10.2
tags:
  - testing
  - qa
revision_date: 2026-10-20
rc:
  prod: Rocky Linux
  ver:
  - 8
  - 9
  - 10
  level: Final
render_macros: true
---

## Description

Getting physical hardware tests under the latest version helps identify known good hardware configurations. The tool used is hw-probe.

All tests are considered ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 

## Releases, Architectures, and ISO's

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  9 | ⬇️       | ⬇️       | N/A     | ⬇️     | ⬇️      |
| Rocky Linux 10 | ⬇️       | ⬇️       | ⬇️       | ⬇️     | ⬇️      |

## Setup

1. The [Hardware Compatibility](https://docs.rockylinux.org/teams/testing/documentation/hardware/hardware_compat/) document is the best place for information regarding installation on all Rocky releases.

## How to test

1. `sudo -E hw-probe -all -upload` (or equivellent command; see [Hardware Compatibility](https://docs.rockylinux.org/teams/testing/documentation/hardware/hardware_compat/) for more options)
2. Post the link the tool provides (ex: https://linux-hardware.org/?probe=a42dbc6763) along with the information in the next section.

## Expected Results

From the link the command outputs, please verify:-

1. The "System" field is the correct version of the release. Especially true post update from past version.
2. The "Kernel" field is the correct version of the kernel.
3. There are no known errors or warnings. (exclude hardware warnings such as a failing SMART harddrive which is specific to that failing device and not a indicator of working hardware not being functional.)

{% include 'teams/testing/qa_testcase_bottom.md' %}
