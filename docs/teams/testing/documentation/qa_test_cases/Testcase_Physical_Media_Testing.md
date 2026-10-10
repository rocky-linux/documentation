---
title: QA:Testcase Physical Media Testing
author: Chris Stackpole
contributors: Trevor Cooper
tags:
  - testing
  - qa
revision_date: 2026-10-09
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Description

This is to verify that the Anaconda installer starts correctly when booting iso's from physical CD's, DVD's, or Bluray's.

## Releases, Architectures, and ISO's

| Distro | Aarch64 | ppc 64le | risc-v | s390x | x86_64 |
|-|-|-|-|-|-|
| Rocky Linux  9 | boot, minimal, dvd  | boot, minimal, dvd | N/A | boot, minimal, dvd | boot, minimal, dvd | 
| Rocky Linux 10 | boot, minimal, dvd  | boot, minimal, dvd | boot, minimal, dvd | boot, minimal, dvd | boot, minimal, dvd | 


## Setup

1. For each ISO in a release architecture, download the corresponding ISO. Due to the size of the ISO's, not all are expected to fit on a CD or DVD and Bluray's may be required.
2. Use an application to burn the ISO to a CD/DVD/Bluray disc.

## How to test

1. Boot the system from the prepared optical disc.
2. In the boot menu select the appropriate option to boot the installer.

## Expected Results

1. Graphical boot menu is displayed for users to select install options. Navigating the menu and selecting entries must work. If no option is selected, the installer should load after a reasonable timeout.
2. System boots into the Anaconda installer.

{% include 'teams/testing/qa_testcase_bottom.md' %}
