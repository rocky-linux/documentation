---
title: QA:Sparrow Unbound
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

Documentation link:- https://docs.rockylinux.org/guides/dns/unbound_recursive_dns/

Project link:- https://git.resf.org/testing/Sparky_Unbound

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | ✅       | ⚠️       | N/A     | ⚠️     | ✅      |
| Rocky Linux  9 | ✅       | ⚠️       | N/A     | ⚠️     | ✅      |
| Rocky Linux 10 | ✅       | ⚠️       | ⚠️       | ⚠️     | ✅      |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

```
[task check]
stdout match (s) <Using domain server:> True
stdout match (s) <Name: 127.0.0.1> True
stdout match (s) <Address: 127.0.0.1> True
stdout match (s) <Aliases:> True
stdout match (s) <^^ \s* $$> True
stdout match (s) <google.com has address> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
