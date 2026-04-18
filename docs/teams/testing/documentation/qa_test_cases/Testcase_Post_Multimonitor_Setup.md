---
title: QA:Testcase Multimonitor Setup
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
    This test case is associated with the [Release_Criteria#dual-monitor-setup-desktop-only](../../guidelines/release_criteria/r9/9_release_criteria.md#dual-monitor-setup-desktop-only) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description

This test covers the check if GNOME behaves as it should in multi-monitor setups.

## Setup

You will need either a machine which can be reinstalled with multiple screens, or a virtualization software which is capable of providing multiple screens (like VMware Workstation ([Pro](https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html) or [Player](https://www.vmware.com/products/workstation-player/workstation-player-evaluation.html)) or [VMware Fusion](https://www.vmware.com/products/fusion/fusion-evaluation.html), but there is also a [hack](https://communities.vmware.com/t5/VMware-vSphere-Discussions/ESXi-6-7-Multiple-Monitors-for-VMs/td-p/2748906) for [VMware ESXi](https://customerconnect.vmware.com/en/web/vmware/evalcenter?p=vsphere-eval-7))

## How to test

1. Run installer with multiple screens connected and install with either the Workstation or Graphical Server group
2. Login to the machine after the finished install

## Expected Results

There shouldn't be any graphical glitches, or scaling issues through the install and the usage.

{% include 'teams/testing/qa_testcase_bottom.md' %}
