---
title: QA:Sparrow Swap
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

Project link:- https://git.resf.org/testing/Sparky_Swap

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | 🔴      | ⚠️       | ⚠️       | ⚠️     | 🔴     |
| Rocky Linux  9 | ✅      | ⚠️       | ⚠️       | ⚠️     | ✅     |
| Rocky Linux 10 | 🔴      | ⚠️       | ⚠️       | ⚠️     | 🔴     |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

```
[task check]
# curl-minimal should be installed
# on the case number 1
stdout match (w) <case1 \s (\S+)> True
stdout match (w) <curl-minimal> True
# curl should be installed
# on the case number 2
stdout match (w) <case2 \s (\S+)> True
stdout match (w) <( "curl-" \S+  )> True
stdout match (w) <!minimal> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
