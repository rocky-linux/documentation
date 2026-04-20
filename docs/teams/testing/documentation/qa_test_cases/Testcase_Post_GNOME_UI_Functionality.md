---
title: QA:Testcase GNOME UI Functionality
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

!!! error "REFERENCED RELEASE CRITERIA IS OVERLY GENERAL AND UNTESTABLE"
    The associated release criteria, [Release_Criteria#default-panel-functionality-desktop-only](../../guidelines/release_criteria/r9/9_release_criteria.md#default-panel-functionality-desktop-only), for this test case is overly general and **must** be modified to specific enough to be testable.

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#default-panel-functionality-desktop-only](../../guidelines/release_criteria/r9/9_release_criteria.md#default-panel-functionality-desktop-only) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

This test collection takes care of the correct functionality of the GNOME UI.

## Setup

Obtain access to a suitable system with either a Workstation or a Graphical Server installation.

## How to test

1. Login to the Rocky Machine via the UI
2. Navigate through the GNOME UI

## Expected Results

1. After the login you should have landed on the desktop with the background and the top bar of GNOME visible
2. Clicking the the Activities button in the upper right should bring up the overview
3. Further there should be the favourite applications ribbon on the left
4. And after clicking the 9-dot-icon all applications should appear
5. Back on the desktop check the function of the system and clock panel on the upper right and middle

It is also a good measure to do some more basic clicking through the GNOME UI, like opening applications, interacting with the application headerbar, moving applications to different desktops or changing settings in the System settings.

{% include 'teams/testing/qa_testcase_bottom.md' %}
