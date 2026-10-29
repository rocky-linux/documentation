---
title: QA:Sparrow Tar
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

Documentation link:- [Tar command](https://docs.rockylinux.org/guides/backup/tar/)

Project link:- [https://git.resf.org/testing/Sparky_Tar](https://git.resf.org/testing/Sparky_Tar)

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | ⚠️       | ⚠️       | N/A     | ⚠️     | ✅      |
| Rocky Linux  9 | ✅       | ⚠️       | N/A     | ⚠️     | ✅      |
| Rocky Linux 10 | ✅       | ⚠️       | ⚠️       | ⚠️     | ✅      |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

```
[task check]
stdout match </tmp/etc-sparky.tar.gz exists and is not empty> True
stdout match </tmp/log-sparky.tar.xz exists and is not empty> True
stdout match <Estimated size is greater than 0> True
stdout match <Split files exist> True
stdout match <Files extracted to /tmp/dir1> True
stdout match <Files extracted to /usr/local/src/redis-7.4.1> True
stdout match </etc/chrony.conf extracted successfully> True
stdout match <Validation successful: both /etc/ and /var/log/ are in the tar> True
stdout match <File etc/chrony.conf found in /tmp/log.tar> True
stdout match <Contents of /tmp/log.tar exists> True
stdout match <Contents of /tmp/etc-sparky.tar.gz exists> True
stdout match <Successfully compared etc/chrony.conf in /tmp/etc.tar> True
stdout match <Successfully deleted> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
