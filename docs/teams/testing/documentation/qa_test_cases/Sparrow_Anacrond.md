---
title: QA:Sparrow Anacrond
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

Documentation link:- https://docs.rockylinux.org/guides/automation/anacron/

Project link:- https://git.resf.org/testing/Sparky_Anacron

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | ⚠️       | ⚠️       | ⚠️       | ⚠️     | 🔴     |
| Rocky Linux  9 | ✅       | ⚠️       | ⚠️       | ⚠️     | ✅      |
| Rocky Linux 10 | ⚠️       | ⚠️       | ⚠️       | ⚠️     | ✅      |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

```
[task check]
stdout match <anacrontab ok> True
stdout match <binary ok> True
stdout match <spool ok> True
stdout match <config valid> True
stdout match <0hourly ok> True
stdout match <timestamps ok> True
stdout match <executed> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
