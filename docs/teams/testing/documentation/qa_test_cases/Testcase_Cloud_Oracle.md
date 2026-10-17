---
title: QA:Testcase Cloud Oracle
author: Chris Stackpole
contributors: 
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

This is to test the cloud image for Oracle.

* ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 
* ❗ - Important. It is best to have this tested, but if it isn't or if it fails then it won't block the release.

## Releases, and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------ | ----- | ------ |
| Rocky Linux  9 | ❗       | ⬇️       | N/A    | ⬇️     | ❗      |
| Rocky Linux 10 | ❗       | ⬇️       | ⬇️      | ⬇️     | ❗      |

## Setup

1. TBD

## How to test

1. TBD

## Expected Results

1. TBD 
   {% include 'teams/testing/qa_testcase_bottom.md' %}
