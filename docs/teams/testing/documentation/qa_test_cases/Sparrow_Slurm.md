---
title: QA:Sparrow Slurm
author: Chris Stackpole
contributors: 
tags:
  - testing
  - sparrow
revision_date: 2026-10-09
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Description

Documentation link:- 

Project link:- [https://git.resf.org/testing/Sparky_Slurm](https://git.resf.org/testing/Sparky_Slurm)

🔴 - Tested and known to fail.
✅ - Tested and known to work.
⚠️  - Untested.

## Releases and Architectures

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | ------ |
| Rocky Linux  8 | 🔴      | ⚠️       | N/A     | ⚠️     | 🔴     |
| Rocky Linux  9 | ✅       | ⚠️       | N/A     | ⚠️     | ✅      |
| Rocky Linux 10 | 🔴      | ⚠️       | ⚠️       | ⚠️     | 🔴     |

## Setup

1. See [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## How to test

1. See Sparky guide.

## Expected Results

``` Bash
[task check]
# db user created or exists
stdout match <"ERROR 1396 (HY000)" || "create db user ok"> True
# db created or exists
stdout match <"create database ok" || "Can't create database 'slurm_acct_db'; database exists"> True
# user created or exists
stdout match <"create user ok" || "adduser: user 'slurm' already exists"> True
[task run: task.bash - files/tasks/slurm-verify]
[task stdout]
02:32:06 :: PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
02:32:06 :: normal*      up 7-00:00:00      1   idle master
[task check]
stdout match (s) <PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST> True
stdout match (s) <normal*      up 7-00:00:00      1   idle master> True
```
   {% include 'teams/testing/qa_testcase_bottom.md' %}
