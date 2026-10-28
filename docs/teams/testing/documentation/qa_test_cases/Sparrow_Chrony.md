---
title: QA:Sparrow Chronyd
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

Documentation link:- https://docs.rockylinux.org/guides/automation/configuring_chrony/

Project link:- https://git.resf.org/testing/Sparky_Chrony

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
<Dependencies resolved successfully> True
<Package operations completed (count: 1)> True
<Chrony package installed with version detected> True
<Chronyd service verified enabled via systemctl is-enabled> True
<Chronyd service unit found> True
<Chronyd service is active and running> True
<Chronyd service unit loaded> True
<Chrony sources table header validated> True
<Found 4 time sources> True
<Chrony tracking shows Reference ID> True
<Chrony tracking shows Stratum level> True
<Chrony tracking shows Reference time> True
<Chrony tracking shows System time offset> True
<Chrony tracking shows Last offset> True
<Chrony tracking shows RMS offset> True
<Chrony tracking shows Frequency adjustment> True
<Chrony activity shows online sources> True
<Chrony activity shows offline sources count> True
<Chrony activity shows burst sources> True
<System local time displayed> True
<System universal time displayed> True
<System RTC time displayed> True
<System timezone configured> True
<NTP service is active> True
<System clock is synchronized> True
<Package operations completed (count: 1)> True
<Chrony package installed> True
<Chronyd service verified enabled via systemctl is-enabled> True
<Chronyd service unit loaded> True
<Chronyd service is active and running> True
<Exactly 4 time sources detected (found 4)> True
<Tracking Reference ID present> True
<Tracking Stratum present> True
<Tracking Reference time present> True
<Tracking System time present> True
<Tracking Last offset present> True
<Tracking RMS offset present> True
<Tracking Frequency present> True
<Online sources detected (at least 1)> True
<Offline sources count shown> True
<Burst sources shown> True
<System timezone configured> True
<NTP service active> True
<System clock synchronized> True
---
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
