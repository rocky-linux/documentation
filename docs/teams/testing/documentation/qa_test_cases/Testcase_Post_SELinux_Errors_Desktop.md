---
title: QA:Testcase SELinux Errors on Desktop clients
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
    This test case is associated with the [Release_Criteria#selinux-and-crash-notifications-desktop-only](../../guidelines/release_criteria/r9/9_release_criteria.md#selinux-and-crash-notifications-desktop-only) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

Basically running a Workstation or Graphical Server install for a longer amount of time, while using it and then checking if there were any SELinux audit messages.

## Setup

Obtain access to a suitable system with either a Workstation or a Graphical Server installation.

## How to test

1. Setup new machine or get access to a installed machine
2. Click through the system and various applications, to mimic user behavior
3. Leave the system running for a few more minutes, if possible hours

## Expected Results

1. Open the SETroubleshoot Application and invoke the error summarization. 
2. There must not be shown any errors / denials

{% include 'teams/testing/qa_testcase_bottom.md' %}
