---
title: QA:Sparrow NSD
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

Documentation link:- https://docs.rockylinux.org/guides/dns/nsd_authoritative_dns/

Project link:- https://git.resf.org/testing/Sparky_NSD

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | ⚠️       | ⚠️       | ⚠️       | ⚠️     | ✅      |
| Rocky Linux  9 | ✅       | ⚠️       | ⚠️       | ⚠️     | ✅      |
| Rocky Linux 10 | ⚠️       | ⚠️       | ⚠️       | ⚠️     | ✅      |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

```
[task check]
stdout match (s) <enabled> True
stdout match (s) <active> True
stdout match (s) <Using domain server:> True
stdout match (s) <Name: 127.0.0.1> True
stdout match (s) <Address: 127.0.0.1> True
stdout match (s) <Aliases:> True
stdout match (s) <^^  $$> True
stdout match (s) <example.com has address 172.20.0.100> True
stdout match (s) <example.com mail is handled by 10 mail.another.com.> True
stdout match (s) <172.20.0.100> True
stdout match (s) <172.20.0.100> True
stdout match (s) <172.20.0.101> True
stdout match (s) <172.20.0.102> True
stdout match (s) <10 mail.another.com.> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
