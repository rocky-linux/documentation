---
title: QA:Testcase Media Repo Compare
author: Trevor Cooper
contributors:
tested_with: 8.10, 9.7, 10.1
tags:
  - testing
  - qa
revision_date: 2026-05-08
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#repositories-must-match-upstream](../../guidelines/release_criteria/r9/9_release_criteria.md#repositories-must-match-upstream) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

This test case will verify that repositories and the packages within them match upstream as closely as possible. Notable exceptions would be kmods, kpatch, or what is deemed as “spyware” like insights. Packages that are available from upstream should not have hard requirements on RHSM and packages that have it default built in should be patched out.

* ⬇️ - Low priority. It would be good to have this tested, but if it isn't or if it fails then it is inconsequential. 
* ❗ - Important. It is best to have this tested, but if it isn't or if it fails then it won't block the release.

## Releases, Architectures, and ISO's

| Distro         | Aarch64 | ppc64le | risc-v | s390x | x86_64 |
| -------------- | ------- | -------- | ------ | ----- | ------ |
| Rocky Linux  9 | ❗       | ❗        | N/A    | ❗     | ❗      |
| Rocky Linux 10 | ❗       | ❗        | ⬇️      | ❗     | ❗      |

## Setup

1. Verify access to the Rocky Linux repocompare tooling.

## How to test

1. Access [Rocky Linux repocompare website](https://repocompare.rockylinux.org/).
2. Verify similarity of Rocky Linux repositories with upstream content.

## Expected Results

1. Rocky Linux repositories should match, as closely as possible, upstream repositories.
2. The content of Rocky Linux packages should match, as closely as possible, upstream repositories.

{% include 'teams/testing/qa_testcase_bottom.md' %}
