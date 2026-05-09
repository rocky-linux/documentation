---
title: openQA - Rocky Produktionszugriff
author: Trevor Cooper
contributors: Lukas Magauer
tested_with:
tags:
  - testing
  - openQA
revision_date: 2026-05-08
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## System Anforderungen

Um auf das Rocky Production openQA-System zuzugreifen und eines der folgenden Beispiele durchzuführen, benötigen Sie Zugriff auf ein System, das den openQA-Client bereitstellt. Typischerweise handelt es sich dabei um ein Fedora-basiertes System/einen Container (es könnte aber auch Rocky 9.6 sein), auf dem das Paket `openqa-client` und seine (~239) Abhängigkeiten installiert sind.

Alternativ können Sie den openQA-Server auch auf Ihrem eigenen lokalen Rechner installieren.  Siehe: [Manual Install](openqa_manual_install.md)

## Zugangsvoraussetzungen

### API `GET` Zugriff

Das {{ rc.prod }} openQA-System ermöglicht uneingeschränkten öffentlichen Zugriff über seine Weboberfläche oder durch Verwendung des `openqa-client` für `GET`-Operationen gegen die API.

### API `POST`–Zugriff

Um mit dem openQA-Client für `POST`-Operationen mit dem {{ rc.prod }} openQA-System zu interagieren, sind folgende Voraussetzungen erforderlich:

- ein Konto mit einwandfreiem Status im [{{ rc.prod }} Account Services](https://accounts.rockylinux.org)-System,
- Autorisierung für den API-`POST`-Zugriff durch das {{ rc.prod }} Testteam, und
- ein [openQA API-Schlüssel](https://open.qa/docs/#_authentication), der auf dem {{ rc.prod }}-openQA-System generiert wurde.

## Konfiguration Ihres OpenQA-Clients

Mit dem Befehl `help` des OpenQA-Clients können Sie Ihren Client auf verschiedene Arten so konfigurieren, dass er Ihren API-Schlüssel verwendet.

Das folgende Beispiel zeigt, wie Sie Ihren Client mit der gebräuchlichsten Methode konfigurieren. Es ist möglich, mehrere OpenQA-Client-API-Schlüssel auf diese Weise zu konfigurieren.

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

## Testen Ihrer OpenQA-Clientinstallation

```bash
openqa-cli api --host https://openqa.rockylinux.org --pretty jobs/overview
```

sollte eine Liste der aktuellen `jobs`~ bereitstellen;  wählen Sie dann eine Jobnummer aus und sehen Sie Informationen zu diesem spezifischen Job an, z.B.:

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

## Referenzen

- [openQA-Documentation](https://open.qa/documentation/)
- [Installation-Info](https://github.com/rocky-linux/OpenQA-Fedora-Installation)
- [Tests für Rocky](https://git.resf.org/testing/os-autoinst-distri-rocky)

{% include 'teams/testing/content_bottom.md' %}
