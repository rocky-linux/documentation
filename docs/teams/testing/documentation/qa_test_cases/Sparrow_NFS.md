---
title: QA:Sparrow NFS
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

Documentation link:- https://docs.rockylinux.org/guides/file_sharing/nfsserver/

Project link:- https://git.resf.org/testing/Sparky_NFS

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
stdout match (s) <active> True
stdout match (s) <rpcbind is running> True
stdout match (s) <nfs-utils is installed> True
stdout match (s) <active> True
stdout match (s) <nfs-server is running> True
stdout match (s) </share directory exists> True
stdout match (s) </etc/exports configured> True
stdout match (s) <export is active> True
stdout match (s) <showmount shows export> True
stdout match (s) </mnt/nfs mount point exists> True
stdout match (s) <nfs share is mounted> True
stdout match (s) <can read from nfs share> True
stdout match (s) <write test> True
stdout match (s) <can write to nfs share> True
stdout match (s) <written file appears in share> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
