---
title: QA:Testcase Artwork and Assets
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
    This test case is associated with the [Release_Criteria#artwork-and-assets-server-and-desktop](../../guidelines/release_criteria/r9/9_release_criteria.md#artwork-and-assets-server-and-desktop) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

There are several brand artworks and assets throughout the whole OS, this testcase will take care of checking, that these are actually in place, and don't produce any UI errors. This is exclusively for installations with the default desktop environment GDM and GNOME.

## Setup

1. Acquire access to either a baremetal machine or a VM host, to install a new machine
2. Prepare appropriate media for the selected ISO to be tested.
    - Example: [QA:Testcase Media USB dd](Testcase_Media_USB_dd.md)

## How to test

1. While booting the image check, that the correct logo is visible in the loading screen before Anaconda comes up
2. Look at the Anaconda images in the [rocky-logos repo](https://github.com/rocky-linux/rocky-logos/tree/r8-fedora/anaconda) and check if all assets are correctly applied in Anaconda (they will generally be visible right away while going through the install process)
3. Install the system with either the Workstation install set or Graphical Server
4. While the OS does its first boot, check that the correct logo is visible in the loading screen before the boot login screen shows up
5. Check the logo and background of the boot login screen
6. After the login check the desktop background and further all available options in the settings menu for the desktop background
7. Lock the screen and check the background visible in the flyover
8. At last check the logo and background of the login screen

## Expected Results

The tests during the process could be successfully finished.

{% include 'teams/testing/qa_testcase_bottom.md' %}
