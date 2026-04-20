---
title: QA:Testcase Application Functionality
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
    This test case is associated with the [Release_Criteria#default-application-functionality-desktop-only](../../guidelines/release_criteria/r9/9_release_criteria.md#default-application-functionality-desktop-only) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

!!! error "REFERENCED RELEASE CRITERIA IS OVERLY GENERAL AND UNTESTABLE"
    The associated release criteria, [Release_Criteria#default-application-functionality-desktop-only](../../guidelines/release_criteria/r9/9_release_criteria.md#default-application-functionality-desktop-only), for this test case is overly general and **must** be modified to specific enough to be testable.

## Description

This testcase handles all applications, considered as core applications of the desktop environment GNOME or user facing commandline applications.

The following tasks apply in general to all of the following applications:

- Firefox
- Files (Nautilus)
- GNOME Software
- (Image Viewer)
- (Document Viewer)
- Gedit (Text Editor)
- Archive Manager
- GNOME Terminal (Terminal Emulator)
- Problem Reporter
- Help Viewer
- System Settings
- vim (Console Text Editor)

## Setup

Obtain access to a suitable system with either a Workstation or a Graphical Server installation.

## How to test

1. Check that the application starts without any errors
2. Further check that the context menus for the correct function
3. Open files to test the functionality of the individual applications

## Expected Results

Make sure that the individual applications behave as they should.

{% include 'teams/testing/qa_testcase_bottom.md' %}
