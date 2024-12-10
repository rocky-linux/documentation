---
title: Erstellen einer benutzerdefinierten Rocky Linux ISO
author: Howard Van Der Wal
contributors: Steven Spencer
tested with: 9.5
tags:
  - create
  - custom
  - ISO
---

## Einleitung

Aus vielen Gründen müssen Sie möglicherweise ein benutzerdefiniertes ISO erstellen. Vielleicht möchten Sie den Startvorgang ändern, bestimmte Pakete hinzufügen oder eine Konfigurationsdatei anpassen.

Diese Anleitung erklärt Ihnen von Anfang bis Ende, wie Sie Ihr eigenes Rocky Linux ISO erstellen.

## Voraussetzungen

- Eine 64-Bit-Maschine mit Rocky Linux 9 zum Erstellen des neuen ISO-Image.
- Ein Rocky Linux 9 DVD-ISO-Image.
- Eine `kickstart`-Datei, die auf die ISO angewendet werden soll.
- Lesen Sie die Lorax-Dokumentation [Quickstart](https://weldr.io/lorax/lorax.html#quickstart) und [mkksiso](https://weldr.io/lorax/mkksiso.html), um sich mit der Erstellung der `Anaconda`-Datei `boot.iso` vertraut zu machen.

## Paketinstallation und -einrichtung

- Installieren Sie das `lorax`-Paket:

```bash
sudo dnf install -y lorax
```

## Erstellen der ISO mit einer `kickstart`-Datei

- Führen Sie den Befehl `mkksiso` aus, um eine `kickstart`-Datei hinzuzufügen und erstellen Sie dann eine neue ISO:

```bash
mkksiso --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO_TO_MODIFY> <OUTPUT_PATH_FOR_BUILT_ISO>
```

- Unten sehen Sie ein Beispiel für eine `kickstart`-Datei `example-ks.cfg`, die eine Rocky Linux 9.5-Umgebung `Server mit GUI` einrichtet:

```bash
lang en_GB
keyboard --xlayouts='us'
timezone Asia/Tokyo --utc
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp
firstboot --disable
selinux --enforcing
firewall --enabled
%packages
@^server-product-environment
%end
```

## Hinzufügen eines Repositorys mit seinen Paketen zu einem ISO-Image

- Stellen Sie sicher, dass das Repository, das Sie hinzufügen möchten, das Verzeichnis `repodata` enthält. Wenn nicht, können Sie dies mit dem Befehl `createrepo_c` erstellen und mit `sudo dnf install -y createrepo_c` installieren
- Fügen Sie das Repository zu Ihrer `kickstart`-Datei hinzu, indem Sie die folgende Syntax verwenden:

```bash

repo --name=extra-repo --baseurl=file:///run/install/repo/<YOUR_REPOSITORY>/
```

- Fügen Sie Ihr Repository mit dem Flag `--add` und dem Tool `mkksiso` hinzu:

```bash
mkksiso --add <LINK_TO_YOUR_REPOSITORY> --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO_TO_MODIFY> <OUTPUT_PATH_FOR_BUILT_ISO>
```

- Weitere Details zu diesem Vorgang anhand des `baseos`-Repositorys können Sie im folgenden Beispiel sehen
- Das `Base-OS`-Repository wird zusammen mit allen seinen Paketen lokal heruntergeladen:

```bash
dnf reposync -p ~ --download-metadata --repo=baseos
```

- Fügen Sie dann das Repository zur `kickstart`-Datei hinzu:

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
```

- Die `kickstart`-Datei würde wie folgt aussehen:

```bash
lang en_GB
keyboard --xlayouts='us'
timezone Asia/Tokyo --utc
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp
firstboot --disable
selinux --enforcing
firewall --enabled
%packages
@^server-product-environment
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
%end
```

- Richten Sie dann den Befehl `mkksiso` direkt auf das Repository-Verzeichnis und erstellen Sie das ISO:

```bash
mkksiso --add ~/baseos --ks example-ks.cfg ~/Rocky-9.5-x86_64-dvd.iso ~/Rocky-9.5-x86_64-dvd-new.iso
```

## Zusammenfassung

Was hier besprochen wurde, sind nur einige der verfügbaren Optionen zum Optimieren und Erstellen Ihres eigenen Rocky Linux ISO. Für weitere Möglichkeiten, einschließlich der Änderung der Kernel-Befehlszeilenargumente, empfiehlt der Autor dringend, die [mkksiso](https://weldr.io/lorax/mkksiso.html)-Dokumentation genauer durchzugehen.
