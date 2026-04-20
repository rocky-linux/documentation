---
title: QA:Testcase Network Attached Storage
author: Al Bowles
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  ver:
  - 8
  - 9
  level: Final
render_macros: true
---

!!! info "Associated release criterion"
    This test case is associated with the [Release_Criteria#Network Attached Storage](../../guidelines/release_criteria/r9/9_release_criteria.md#nas-network-attached-storage) release criterion. If you are doing release validation testing, a failure of this test case may be a breach of that release criterion.

## Description
The installer must be able to detect and install to supported NAS devices (if possible and supported by the kernel).

## Setup
1. Add steps for setup for this Testcase.

## How to test
### NFS
install nfs-utils
sudo mount -t nfs nfs-server:/nfs/path /mnt
then a created a file echo 1 > /mnt/1
verified it and permissions ls /mnt; cat /mnt/1
then deleted it rm /mnt/1
then unmounted sudo umount /mnt

### iSCSI

## Expected Results
1. This is what you should see/verify.
2. You should also see/verify this.

{% include 'teams/testing/qa_testcase_bottom.md' %}
