---
title: QA:Sparrow Bind
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

Documentation link:- [Private DNS server with bind](https://docs.rockylinux.org/guides/dns/private_dns_server_using_bind/)

Project link:- [https://git.resf.org/testing/Sparky_Bind](https://git.resf.org/testing/Sparky_Bind)

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
stdout match (s) <active> True
stdout match (s) <ok> True
stdout match (s) <zone ourdomain.lan/IN: loaded serial 2019061800> True
stdout match (s) <OK> True
stdout match (s) <zone 192.168.1.136/IN: loaded serial 2019061800> True
stdout match (s) <OK> True
stdout match (s) <192.168.1.13> True
stdout match (s) <192.168.1.14> True
stdout match (s) <192.168.1.15> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
