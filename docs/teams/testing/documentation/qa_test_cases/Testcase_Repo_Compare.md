---
title: QA:Testcase Media Repo Compare
author: Trevor Cooper
revision_date: 2022-05-18
rc:
  prod: Rocky Linux
  ver: 8
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#repositories-must-match-upstream](../../guidelines/release_criteria/r9/9_release_criteria.md#repositories-must-match-upstream) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
This test case will verify that repositories and the packages within them match upstream as closely as possible.

## Setup
1. Verify access to the Rocky Linux repocompare tooling.

## How to test
1. Access [Rocky Linux repocompare website](https://repocompare.rockylinux.org/).
2. Verify similarity of Rocky Linux repositories with upstream content.

## Expected Results
1. Rocky Linux repositories should match, as closely as possible, upstream repositories.
2. The content of Rocky Linux packages should match, as closely as possible, upstream repositories.

{% include 'teams/testing/qa_testcase_bottom.md' %}
