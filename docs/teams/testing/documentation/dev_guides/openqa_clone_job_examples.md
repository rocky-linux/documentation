---
title: openQA - openqa-clone-job Examples
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

# openqa-clone-job Examples

This page will provide a brief overview of basic and advanced job cloning using the `openqa-clone-job` command.

## System / Access Requirements

To complete any of the examples please complete the API `POST` Access steps outlined in the [openQA - Access](openqa_access.md) document.

## Basic `openqa-clone-job`

### Querying openQA for a specific test or job

First you might want to query the {{ rc.prod }} openQA system for the latest job ID for a specific job or test. The openQA client, hereafter refered to as `openqa-cli` will allow you to quickly do that via the API. Here is an example...

```bash
$ openqa-cli api --host http://openqa.rockylinux.org jobs/overview groupid=0 distri=rocky version=9.1 test=install_default_upload latest=1 | jq '.'
[
  {
    "id": 22735,
    "name": "rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit"
  }
]
```

This basically says "give me the job id and name of the most recent `install_default_upload` test for {{ rc.prod }} 9.1".

### Cloning a job "as-is"

With that job id in hand you can now clone that job directly to your local openQA development system with...

```bash
$ openqa-clone-job --from https://openqa.rockylinux.org --skip-download 22735
Cloning children of rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit
Created job #23: rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit -> http://localhost/t23
```

### Basic job overview

Now you should have the same job running in your local instance...

```bash
$ openqa-cli api jobs/overview
[{"id":23,"name":"rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit"}]
```

### Basic job details

```bash
$ openqa-cli api jobs/23 | jq '.'
{
  "job": {
    "assets": {
      "iso": [
        "Rocky-9.1-20221214.1-x86_64-dvd.iso"
      ]
    },
    "assigned_worker_id": 2,
    "blocked_by_id": null,
    "children": {
      "Chained": [],
      "Directly chained": [],
      "Parallel": []
    },
    "clone_id": null,
    "group": "Rocky",
    "group_id": 2,
    "has_parents": 0,
    "id": 23,
    "name": "rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit",
    "parents": {
      "Chained": [],
      "Directly chained": [],
      "Parallel": []
    },
    "parents_ok": 1,
    "priority": 50,
    "result": "none",
    "settings": {
      "ARCH": "x86_64",
      "ARCH_BASE_MACHINE": "64bit",
      "BACKEND": "qemu",
      "BUILD": "20230423-Rocky-9.1-x86_64.0",
      "CLONED_FROM": "https://openqa.rockylinux.org/tests/22735",
      "CURRREL": "9",
      "DEPLOY_UPLOAD_TEST": "install_default_upload",
      "DESKTOP": "gnome",
      "DISTRI": "rocky",
      "FLAVOR": "dvd-iso",
      "HDDSIZEGB": "15",
      "ISO": "Rocky-9.1-20221214.1-x86_64-dvd.iso",
      "LOCATION": "https://download.rockylinux.org/pub/rocky/9.1/BaseOS",
      "MACHINE": "64bit",
      "NAME": "00000023-rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit",
      "NICTYPE_USER_OPTIONS": "net=172.16.2.0/24",
      "PACKAGE_SET": "default",
      "PART_TABLE_TYPE": "mbr",
      "POSTINSTALL": "_collect_data",
      "QEMUCPU": "Nehalem",
      "QEMUCPUS": "2",
      "QEMURAM": "2048",
      "QEMU_HOST_IP": "172.16.2.2",
      "QEMU_VIDEO_DEVICE": "virtio-vga",
      "QEMU_VIRTIO_RNG": "1",
      "STORE_HDD_1": "disk_dvd-iso_64bit.qcow2",
      "TEST": "install_default_upload",
      "TEST_SUITE_NAME": "install_default_upload",
      "TEST_TARGET": "ISO",
      "VERSION": "9.1",
      "WORKER_CLASS": "qemu_x86_64",
      "XRES": "1024",
      "YRES": "768"
    },
    "state": "running",
    "t_finished": null,
    "t_started": "2023-04-23T03:02:06",
    "test": "install_default_upload"
  }
}
```

**NOTE: In the above job information you can clearly see the job was cloned from `https://openqa.rockylinux.org/tests/22735`.**

## Advanced `openqa-clone-job`

You can, of course, perform more elaborate operations while cloneing a job either from your local instance or from the production instance. Typically, this might be done to modify some of the job POST variables in the cloned job while keeping all other variables unchanged.

### Changing variable during clone

Here is an example where the ISO is changed in the cloned job...

```bash
$ openqa-clone-job --from https://openqa.rockylinux.org --skip-download 22735 ISO=Rocky-9.1-x86_64-dvd.iso
Cloning children of rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit
Created job #24: rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit -> http://localhost/t24
```

### Job overview

```bash
$ openqa-cli api jobs/overview
[{"id":24,"name":"rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit"}]
```

### Job details

```bash
$ openqa-cli api jobs/24 | jq '.'
{
  "job": {
    "assets": {
      "iso": [
        "Rocky-9.1-x86_64-dvd.iso"
      ]
    },
    "assigned_worker_id": 1,
    "blocked_by_id": null,
    "children": {
      "Chained": [],
      "Directly chained": [],
      "Parallel": []
    },
    "clone_id": null,
    "group": "Rocky",
    "group_id": 2,
    "has_parents": 0,
    "id": 24,
    "name": "rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit",
    "parents": {
      "Chained": [],
      "Directly chained": [],
      "Parallel": []
    },
    "parents_ok": 1,
    "priority": 50,
    "result": "none",
    "settings": {
      "ARCH": "x86_64",
      "ARCH_BASE_MACHINE": "64bit",
      "BACKEND": "qemu",
      "BUILD": "20230423-Rocky-9.1-x86_64.0",
      "CLONED_FROM": "https://openqa.rockylinux.org/tests/22735",
      "CURRREL": "9",
      "DEPLOY_UPLOAD_TEST": "install_default_upload",
      "DESKTOP": "gnome",
      "DISTRI": "rocky",
      "FLAVOR": "dvd-iso",
      "HDDSIZEGB": "15",
      "ISO": "Rocky-9.1-x86_64-dvd.iso",
      "LOCATION": "https://download.rockylinux.org/pub/rocky/9.1/BaseOS",
      "MACHINE": "64bit",
      "NAME": "00000024-rocky-9.1-dvd-iso-x86_64-Build20230423-Rocky-9.1-x86_64.0-install_default_upload@64bit",
      "NICTYPE_USER_OPTIONS": "net=172.16.2.0/24",
      "PACKAGE_SET": "default",
      "PART_TABLE_TYPE": "mbr",
      "POSTINSTALL": "_collect_data",
      "QEMUCPU": "Nehalem",
      "QEMUCPUS": "2",
      "QEMURAM": "2048",
      "QEMU_HOST_IP": "172.16.2.2",
      "QEMU_VIDEO_DEVICE": "virtio-vga",
      "QEMU_VIRTIO_RNG": "1",
      "STORE_HDD_1": "disk_dvd-iso_64bit.qcow2",
      "TEST": "install_default_upload",
      "TEST_SUITE_NAME": "install_default_upload",
      "TEST_TARGET": "ISO",
      "VERSION": "9.1",
      "WORKER_CLASS": "qemu_x86_64",
      "XRES": "1024",
      "YRES": "768"
    },
    "state": "running",
    "t_finished": null,
    "t_started": "2023-04-23T03:08:03",
    "test": "install_default_upload"
  }
}
```

## Difference between Basic and Advanced `openqa-clone-job`

You should notice that the only substantive difference between the two cloned jobs is the ISO that is used to run the `install_default_upload` test...

```bash
$ openqa-cli api jobs/23 | jq '.job.settings.ISO'
"Rocky-9.1-20221214.1-x86_64-dvd.iso"

$ openqa-cli api jobs/24 | jq '.job.settings.ISO'
"Rocky-9.1-x86_64-dvd.iso"
```

## References

[openQA Documentation](http://open.qa/documentation/)

{% include 'teams/testing/content_bottom.md' %}
