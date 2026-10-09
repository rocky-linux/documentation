---
title: QA:Testcase Live Image
author: Chris Stackpole
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

This is to verify that the correct Desktop starts correctly when booting ISO's. This testing can be done either via burning optical media or [Fedora Media Writer](https://docs.fedoraproject.org/en-US/fedora/latest/preparing-boot-media/), however, the recommended method for testing is utilizing a virtualization utility. 

## Releases, Architectures, and ISO's

Live images are only created for Aarch64 and x86_64. Not all Desktop live images are created at release but will be updated as upstream dependencies allow.

| Distro | Cinnamon | KDE | MATE | Workstation | Workstation Lite | XFCE |
|-|-|-|-|-|-|-|
| Rocky Linux  9 | aarch64, x86_64  | aarch64, x86_64 | aarch64, x86_64 | aarch64, x86_64 | aarch64, x86_64 | aarch64, x86_64 |
| Rocky Linux 10 | N/A  | aarch64, x86_64 | N/A | aarch64, x86_64 | aarch64, x86_64 | N/A |


## Setup

1. For each ISO in a release architecture, download the corresponding ISO.
2. Use an virtualization application to boot the ISO image.

## How to test

1. Boot the system from the ISO.
2. Validate the Desktop environment loads correctly.

## Expected Results

1. Desktop is displayed for users to interact in. Navigating the menus and selecting entries must work.
2. System boots into the appropriate desktop.

{% include 'teams/testing/qa_testcase_bottom.md' %}
