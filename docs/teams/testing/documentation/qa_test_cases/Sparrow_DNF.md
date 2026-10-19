---
title: QA:Sparrow DNF
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

Documentation link:- https://docs.rockylinux.org/guides/package_management/dnf_package_manager/

Project link:- https://git.resf.org/testing/Sparky_DNF

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
stdout match <dnf install -y perl> True
stdout match <perl installed> True
stdout match <dnf list kernel*> True
stdout match <dnf list installed sudo*> True
stdout match <dnf list installed perl> True
stdout match <dnf group list> True
stdout match <dnf repolist baseos> True
stdout match <dnf repolist appstream> True
stdout match <dnf history list> True
stdout match <dnf search wget> True
stdout match <dnf info perl> True
stdout match <dnf remove -y perl> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
