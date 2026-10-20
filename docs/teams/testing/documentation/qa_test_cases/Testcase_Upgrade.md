---
title: QA:Testcase Upgrades
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

Users must be able to upgrade from a previous major version (eg: 9.8->9.9).

* ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 
* ❗ - Important. It is best to have this tested, but if it isn't or if it fails then it won't block the release.

## Releases, Architectures, and ISO's

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  9 | ❗       | ⬇️       | N/A     | ⬇️     | ❗      |
| Rocky Linux 10 | ❗       | ⬇️       | ⬇️       | ⬇️     | ❗      |

## Setup

1. Start with or install a previous version.

## How to test

1. Change or update repos to point to new version.
2. `sudo dnf --refresh upgrade`

## Expected Results

1. All updates should succeed without errors.
2. Reboots into new kernel should succeed without error or issues.

{% include 'teams/testing/qa_testcase_bottom.md' %}
