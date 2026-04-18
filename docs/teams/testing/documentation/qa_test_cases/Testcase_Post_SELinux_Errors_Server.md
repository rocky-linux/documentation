---
title: QA:Testcase SELinux Errors on Server installations
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
    This test case is associated with the [Release_Criteria#selinux-errors-server](../../guidelines/release_criteria/r9/9_release_criteria.md#selinux-errors-server) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

Basically running a text mode installation for a longer amount of time, while using it and then checking if there were any SELinux audit messages.

## Setup

Obtain access to a suitable system with one of the text mode installation base groups.

It might also be beneficial to run this test with other than the core installation, but that is a long term test and a bit out of scope of this test.

## How to test

1. Setup new machine or get access to a installed machine
2. As this test is mostly about the stability of the core system it is mostly only needed to let the system run for a few minutes, if possible hours

## Expected Results

1. Install `sealert` with `dnf install setroubleshoot-server`
2. Run `sealert -a /var/log/audit/audit.log`
3. There must not be shown any errors / denials

{% include 'teams/testing/qa_testcase_bottom.md' %}
