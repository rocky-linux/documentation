---
title: QA:Testcase Keyboard Layout
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
    This test case is associated with the [Release_Criteria#keyboard-layout](../../guidelines/release_criteria/r9/9_release_criteria.md#keyboard-layout) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

As there are a lot of different keyboard layouts available, it is necessary to test if the keyboard functionality works without any issues throughout the system.

## Setup

- Obtain access to a few different system configurations, especially with and without UI, and not to forget with disk encryption.
- Acquire access to either a baremetal machine or a VM host, to install a new machine
    - Prepare appropriate media for the selected ISO to be tested.
    - Example: [QA:Testcase Media USB dd](Testcase_Media_USB_dd.md)

## How to test

### Installer

1. Bootup the installer
2. Choose a language
3. Make sure that the keyboard layout got chosen correctly corresponding to the language setting
4. Change the keyboard layout if needed to test
5. Enter text all over Anaconda to make sure the keyboard layout works correctly with the chosen keyboard layout

### Disk Encryption

1. Setup a system with disk encryption
2. Check that the password for the disk encryption works on bootup with graphical UI
3. Check that the password for the disk encryption works on bootup with text mode

### Text mode

Check that the chosen keyboard layout works correctly on text mode.

### GNOME and Application

1. Check the login, that the keyboard layout works correctly on the graphical UI login screen
2. Also check that the GNOME UI works correctly with the chosen keyboard layout
3. And finally check some applications, that the keyboard works as expected

## Expected Results

The tests during the process could be successfully finished.

{% include 'teams/testing/qa_testcase_bottom.md' %}
