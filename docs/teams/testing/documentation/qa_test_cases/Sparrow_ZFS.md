---
title: QA:Sparrow ZFS
author: Chris Stackpole
contributors: 
tags:
  - testing
  - sparrow
revision_date: 2026-10-09
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Description

Documentation link:- 

Project link:- https://git.resf.org/testing/Sparky_ZFS

This tests the stable branch (currently 2.2), and the latest branch (currently 2.3). Both tests should be run. Currently we do not test the testing branch (currently 2.4). Because the test utilizes the RPM method for install, the test is only valid for x86_64 at this time.

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | ⚠️       | ⚠️       | ⚠️       | ⚠️     | 🔴     |
| Rocky Linux  9 | ⚠️       | ⚠️       | ⚠️       | ⚠️     | ✅     |
| Rocky Linux 10 | ⚠️       | ⚠️       | ⚠️       | ⚠️     | ✅     |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

```
[task check]
# Checking zpool status
stdout match (s) <pool: data> True
stdout match (s) <state: ONLINE> True
stdout match (s) <config:> True
stdout match (s) <^^  $$> True
stdout match (s) <NAME            STATE     READ WRITE CKSUM> True
stdout match (s) <data            ONLINE       0     0     0> True
stdout match (s) <mirror-0      ONLINE       0     0     0> True
stdout match (s) </mnt/disk1  ONLINE       0     0     0> True
stdout match (s) </mnt/disk2  ONLINE       0     0     0> True
stdout match (s) <^^  $$> True
stdout match (s) <errors: No known data errors> True
# Checking zpool iostat
stdout match (s) <capacity     operations     bandwidth> True
stdout match (s) <pool        alloc   free   read  write   read  write> True
stdout match (s) <----------  -----  -----  -----  -----  -----  -----> True
stdout match (s) <data \s*> True
# Checking zpool list
stdout match (s) <NAME   SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT> True
stdout match (s) <data \s*> True

```

   {% include 'teams/testing/qa_testcase_bottom.md' %}
