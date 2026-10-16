---
title: QA:Testcase Cloud Azure
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

This is to test the cloud image for Azure.

* ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 
* ❌ - Release blocker. This must be tested and until it is, or if it fails, then the issue must be properly addressed.

## Releases, and Architectures

| Distro         | Aarch64 | ppc64le | risc-v | s390x | x86_64 |
| -------------- | ------- | ------- | ------ | ----- | ------ |
| Rocky Linux  9 | ❌       | ⬇️       | N/A    | ⬇️     | ❌      |
| Rocky Linux 10 | ❌       | ⬇️       | ⬇️      | ⬇️     | ❌      |

## Setup

1. TBD

## How to test

1. TBD

## Expected Results

1. TBD 
   {% include 'teams/testing/qa_testcase_bottom.md' %}
