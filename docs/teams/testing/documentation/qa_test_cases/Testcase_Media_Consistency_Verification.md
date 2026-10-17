---
title: QA:Testcase Media Consistency Verification
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

This is to verify that the Anaconda installer starts correctly when booting iso's from physical thumbdrives.

* ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 
* ❌ - Release blocker. This must be tested and until it is, or if it fails, then the issue must be properly addressed.

## Releases, Architectures, and ISO's

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------------------------------- | ------------------------------ | ------------------------------ | ------------------------------ | ------------------------------- |
| Rocky Linux  9 | ❌boot, <br/>❌minimal, <br/>❌dvd | ⬇️boot, <br/>⬇️minimal,<br/>⬇️dvd | N/A                            | ⬇️boot, <br/>⬇️minimal,<br/>⬇️dvd | ❌boot, <br/>❌minimal, <br/>❌dvd |
| Rocky Linux 10 | ❌boot, <br/>❌minimal,<br/>❌dvd  | ⬇️boot, <br/>⬇️minimal,<br/>⬇️dvd | ⬇️boot, <br/>⬇️minimal,<br/>⬇️dvd | ⬇️boot, <br/>⬇️minimal,<br/>⬇️dvd | ❌boot, <br/>❌minimal, <br/>❌dvd |

## Setup

1. For each ISO in a release architecture, download the corresponding ISO. Due to the size of the ISO's, thumbdrives over 16GB are adviced.
2. The only supported method for test verification is using [Fedora Media Writer](https://docs.fedoraproject.org/en-US/fedora/latest/preparing-boot-media/). Please use upstream documentation for installation and use details.

## How to test

1. Boot the system from the prepared thumbdrive.
2. In the boot menu select the appropriate option to boot the installer.

## Expected Results

1. Graphical boot menu is displayed for users to select install options. Navigating the menu and selecting entries must work. If no option is selected, the installer should load after a reasonable timeout.
2. System boots into the Anaconda installer.

{% include 'teams/testing/qa_testcase_bottom.md' %}
