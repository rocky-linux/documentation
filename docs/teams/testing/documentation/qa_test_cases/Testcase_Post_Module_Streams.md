---
title: QA:Testcase Module Streams
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
    This test case is associated with the [Release_Criteria#packages-and-module-installation](../../guidelines/release_criteria/r9/9_release_criteria.md#packages-and-module-installation) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

This test case takes care of testing the module streams, that they are all installable, all available and working as expected.

## Setup

For this tests you will need to install every module stream on its own, so it's the best to setup a new system which gets snapshoted after the initial setup. After that it can be rolled back for every module install.

It's enough to setup a system with the Minimal Install group.

## How to test

1. Login to the machine
2. Get a list of all module streams and compare it to the [stream list from RHEL](https://access.redhat.com/support/policy/updates/rhel-app-streams-life-cycle) and to the source in [Git source repo](https://git.rockylinux.org/rocky/rocky-module-defaults)
3. The easiest way to test all streams is to install the package groups in the individual streams, i.e. for postgresql:

```bash
dnf module install postgresql
dnf module install postgresql:13
dnf module install postgresql:13/client
```

Repeat step 3 as often as module streams and package groups are available.

This could be automated with i.e. Ansible to do all the `install -> rollback -> install -> rollback -> ...` and emiting the output via Ansible.

## Expected Results

All module streams should be available and there shouldn't be any errors while installing any of the package groups of the individual streams. (some of the installs will show warnings though because they are incompatible with other streams)

{% include 'teams/testing/qa_testcase_bottom.md' %}
