---
title: "Kapitel 5: Einrichtung und Verwaltung von Images"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - Enterprise
  - incus images
---

In diesem Kapitel müssen Sie die Befehle als Benutzer ohne Administratorrechte ausführen (`incusadmin`, wenn Sie diesem Buch von Anfang an gefolgt sind).

## Verfügbare Images auflisten

Sie können es wahrscheinlich kaum erwarten, mit einem Container loszulegen. Es gibt viele Möglichkeiten für Container-Betriebssysteme. Um ein Gefühl dafür zu bekommen, wie viele Möglichkeiten es gibt, geben Sie diesen Befehl ein:

```bash
incus image list images: | more
```

Drücken Sie die Leertaste, um durch die Liste zu blättern. Diese Liste von Containern und virtuellen Maschinen wächst ständig weiter.

Als **letztes** sollten Sie nach einem Container-Image suchen, das Sie installieren können, insbesondere wenn Sie bereits wissen, welches Image Sie erstellen möchten. Ändern Sie den Befehl so, dass nur die Installationsoptionen für Rocky Linux angezeigt werden:

```bash
incus image list images: | grep rocky
```

Dadurch wird eine viel übersichtlichere Liste angezeigt:

```bash
| rockylinux/8 (3 more)                    | dede6169bb45 | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | VIRTUAL-MACHINE | 850.75MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/arm64 (1 more)              | b749bad83e60 | yes    | Rockylinux 8 arm64 (20240903_04:40)        | aarch64      | CONTAINER       | 125.51MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud (1 more)              | 4fefd464d25d | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | VIRTUAL-MACHINE | 869.95MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud (1 more)              | 729891475172 | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | CONTAINER       | 148.81MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud/arm64                 | 3642ec9652fc | yes    | Rockylinux 8 arm64 (20240903_04:52)        | aarch64      | CONTAINER       | 144.84MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9 (3 more)                    | 9e5e4469e660 | yes    | Rockylinux 9 amd64 (20240903_03:29)        | x86_64       | VIRTUAL-MACHINE | 728.60MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9 (3 more)                    | fff1706d5834 | yes    | Rockylinux 9 amd64 (20240903_03:29)        | x86_64       | CONTAINER       | 111.25MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/arm64 (1 more)              | d3a44df90d69 | yes    | Rockylinux 9 arm64 (20240903_04:49)        | aarch64      | CONTAINER       | 107.18MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud (1 more)              | 4329a67099ba | yes    | Rockylinux 9 amd64 (20240903_03:28)        | x86_64       | VIRTUAL-MACHINE | 749.29MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud (1 more)              | bc30d585b9f0 | yes    | Rockylinux 9 amd64 (20240903_03:28)        | x86_64       | CONTAINER       | 127.16MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud/arm64                 | 5c38ddd506bd | yes    | Rockylinux 9 arm64 (20240903_04:38)        | aarch64      | CONTAINER       | 122.87MiB  | 2024/09/02 19:00 CDT |
```

## Installation, Umbenennung und Auflistung von Images

Für den ersten Container verwenden Sie `rockylinux/8`. Zur Installation können Sie Folgendes verwenden:

```bash
incus launch images:rockylinux/8 rockylinux-test-8
```

Dadurch wird ein auf Rocky Linux basierender Container mit dem Namen `rockylinux-test-8` erstellt. Sie können einen Container nach seiner Erstellung umbenennen, müssen ihn aber vorher stoppen, da er nach der Erstellung automatisch startet.

Um den Container manuell zu starten wird Folgendes verwendet:

```bash
incus start rockylinux-test-8
```

Um das Image umzubenennen (wir werden dies hier nicht tun, aber so geht es), müssen Sie zuerst den Container stoppen:

```bash
incus stop rockylinux-test-8
```

Verwenden Sie den Befehl `move`, um den Namen des Containers zu ändern:

```bash
incus move rockylinux-test-8 rockylinux-8
```

Wenn Sie dieser Anweisung trotzdem gefolgt sind, stoppen Sie den Container und benennen Sie ihn wieder in seinen ursprünglichen Namen um, um den Anweisungen weiter folgen zu können.

Installieren Sie für diese Anleitung zunächst zwei weitere Images:

```bash
incus launch images:rockylinux/9 rockylinux-test-9
```

und

```bash
incus launch images:ubuntu/22.04 ubuntu-test
```

Prüfen Sie, was Sie haben, indem Sie Ihre Images auflisten:

```bash
incus list
```

was folgendes zurückgibt:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 10.146.84.179 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 10.146.84.180 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```
