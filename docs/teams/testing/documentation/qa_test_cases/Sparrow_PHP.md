---
title: QA:Sparrow PHP
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

Documentation link:- https://docs.rockylinux.org/10/books/web_services/03-application-servers

Project link:- https://git.resf.org/testing/Sparky_PHP

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | 🔴      | ⚠️       | ⚠️       | ⚠️     | ✅     |
| Rocky Linux  9 | ✅      | ⚠️       | ⚠️       | ⚠️     | ✅     |
| Rocky Linux 10 | ✅      | ⚠️       | ⚠️       | ⚠️     | ✅     |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

```
[task check]
# php repo should be inabled
stdout match (r) <php \s+ "remi-8.5" \s+ "[e]"> True
# php version should be installed
stdout match <"PHP "8.5"."> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
