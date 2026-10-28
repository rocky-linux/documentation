---
title: QA:Sparrow Chryp
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

Documentation link:- https://docs.rockylinux.org/10/guides/cms/chyrp_lite/

Project link:- https://git.resf.org/testing/Sparky_Chyrp

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | 🔴      | ⚠️       | N/A     | ⚠️     | ✅      |
| Rocky Linux  9 | ✅       | ⚠️       | N/A     | ⚠️     | ✅      |
| Rocky Linux 10 | ✅       | ⚠️       | ⚠️       | ⚠️     | ✅      |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

```
[task check]
stdout match (s) <enabled> True
stdout match (s) <enabled> True
stdout match (s) <active> True
stdout match (s) <active> True
stdout match (s) <200> True
stdout match (s) <ok> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
