---
title: openQA - Rocky Production Access
author: Trevor Cooper
revision_date: 2026-04-17
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## System Requirements

To access the Rocky Production openQA system, and complete any of the examples below you will need access to a system providing the openQA client. Typically that will be a Fedora based system/container (but could be Rocky 9.6) with the `openqa-client` package and it's (~239) dependencies installed.

Alternatively, you may install the openQA server on your own local machine.  See: [Manual Install](openqa_manual_install.md )

## Access Requirement

### API `GET` access

The {{ rc.prod }} openQA system allows unrestricted public access via it's web interface or using the `openqa-client` for `GET` operations against the API.

### API `POST` access

In order to use the openQA client to interact with the {{ rc.prod }} openQA system for `POST` operations the following are required:

- an account in good standing in the [{{ rc.prod }} Account Services](https://accounts.rockylinux.org) system,
- authorization for API `POST` access from the {{ rc.prod }} Testing Team, and
- an [openQA API key](https://open.qa/docs/#_authentication) generated on the {{ rc.prod }} openQA system.

## Configuring your openqa client

Per the openqa client command help you can configure your client to use your API key in a number of ways.

The following example shows how to configure your client by the most common method used. It's possible to configure
multiple openqa client API keys in this way.

```bash
$ mkdir -p ~/.config/openqa

$ vim ~/.config/openqa/client.conf

$ cat ~/.config/openqa/client.conf
[localhost]
key = your_localhost_api_key
secret = your_localhost_api_secret
[openqa.rockylinux.org]
key = your_api_key
secret = your_api_secret
```

## Testing your openqa client installation

```bash
$ openqa-cli api --host https://openqa.rockylinux.org --pretty jobs/overview
```
should provide a list of current jobs, then pick a job number and view info on that specific job, e.g.:

```bash
$ openqa-cli api --host https://openqa.rockylinux.org --pretty jobs/1
{
   "job" : {
      "assets" : {
         "iso" : [
            "Rocky-8.6-x86_64-boot.iso"
         ]
      },
      "assigned_worker_id" : 2,
      "blocked_by_id" : null,
      "children" : {
         "Chained" : [],
         "Directly chained" : [],
         "Parallel" : []
      },
      "clone_id" : null,
      "group" : "Rocky",
      "group_id" : 2,
      "has_parents" : 0,
      "id" : 1,
      "name" : "rocky-8.6-boot-iso-x86_64-Build-8.6-boot-iso--20221110.223812.0-install_default@64bit",
      "parents" : {
         "Chained" : [],
         "Directly chained" : [],
         "Parallel" : []
      },
      "parents_ok" : 1,
      "priority" : 10,
      "result" : "failed",
      "settings" : {
         "ARCH" : "x86_64",
         "ARCH_BASE_MACHINE" : "64bit",
         "BACKEND" : "qemu",
         "BUILD" : "-8.6-boot-iso--20221110.223812.0",
         "DESKTOP" : "gnome",
         "DISTRI" : "rocky",
         "FLAVOR" : "boot-iso",
         "GRUB" : "ip=dhcp",
         "HDDSIZEGB" : "15",
         "ISO" : "Rocky-8.6-x86_64-boot.iso",
         "MACHINE" : "64bit",
         "NAME" : "00000001-rocky-8.6-boot-iso-x86_64-Build-8.6-boot-iso--20221110.223812.0-install_default@64bit",
         "PACKAGE_SET" : "default",
         "PART_TABLE_TYPE" : "mbr",
         "POSTINSTALL" : "_collect_data",
         "QEMUCPU" : "Nehalem",
         "QEMUCPUS" : "2",
         "QEMURAM" : "3072",
         "QEMUVGA" : "virtio",
         "QEMU_VIRTIO_RNG" : "1",
         "TEST" : "install_default",
         "TEST_SUITE_NAME" : "install_default",
         "TEST_TARGET" : "ISO",
         "VERSION" : "8.6",
         "WORKER_CLASS" : "qemu_x86_64"
      },
      "state" : "done",
      "t_finished" : "2022-11-10T22:44:19",
      "t_started" : "2022-11-10T22:38:12",
      "test" : "install_default"
   }
}
```

## References

* [openQA Documentation](https://open.qa/documentation/)
* [Installation Info](https://github.com/rocky-linux/OpenQA-Fedora-Installation)
* [Tests for Rocky](https://git.resf.org/testing/os-autoinst-distri-rocky)

{% include 'teams/testing/content_bottom.md' %}
