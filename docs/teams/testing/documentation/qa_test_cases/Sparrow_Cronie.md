---
title: QA:Sparrow Cronie
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

Documentation link:- [cronie - Timed Tasks](https://docs.rockylinux.org/guides/automation/cronie/)

Project link:- [https://git.resf.org/testing/Sparky_Cronie](https://git.resf.org/testing/Sparky_Cronie)

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | 🔴      | ⚠️       | N/A     | ⚠️     | 🔴     |
| Rocky Linux  9 | ✅       | ⚠️       | N/A     | ⚠️     | ✅      |
| Rocky Linux 10 | ✅       | ⚠️       | ⚠️       | ⚠️     | ✅      |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

```
stdout match <cronie installed> True
stdout match <crond active> True
stdout match <config valid> True
stdout match <log ok> True
stdout match <crontab cleared> True
stdout match <executable> True
stdout match <executed> True
stdout match <journalctl ok> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
