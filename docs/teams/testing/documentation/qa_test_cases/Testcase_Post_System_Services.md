---
title: QA:Testcase System Services
author: Lukas Magauer
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver:
    - 8
    - 9
  level: Final
render_macros: true
---

!!! info "Release relevance"
    This Testcase applies the following versions of {{ rc.prod }}: {% for version in rc.ver %}{{ version }}{% if not loop.last %}, {% endif %}{% endfor %}

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#system-services](../../guidelines/release_criteria/r9/9_release_criteria.md#system-services) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

This test covers the check, that all basic system service which are getting installed with the base groups are starting / running normally.

## Setup

1. Acquire access to either a baremetal machine or a VM host, to install a new machine
2. Prepare appropriate media for the selected ISO to be tested.
    - Example: [QA:Testcase Media USB dd](Testcase_Media_USB_dd.md)

## How to test

Startup the system and check that all services are running without any failure:

```bash
systemctl status
```

## Expected Results

The tests during the process could be successfully finished.

{% include 'teams/testing/qa_testcase_bottom.md' %}
