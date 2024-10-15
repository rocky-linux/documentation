---
title: 2 ZFS Setup
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus zfs
---

# Kapitel 2: ZFS-Einrichtung

In diesem Kapitel müssen Sie Root-Benutzer sein oder `sudo` verwenden können, um Root zu werden.

Wenn Sie ZFS bereits installiert haben, führt Sie dieser Abschnitt durch die ZFS-Einrichtung.

## ZFS-Aktivierung und Einrichten des Pools

Geben Sie zuerst diesen Befehl ein:

```bash
/sbin/modprobe zfs
```

Wenn keine Fehler vorliegen, wird zur Eingabeaufforderung zurückgekehrt und es wird nichts ausgegeben. Wenn eine Fehlermeldung angezeigt wird, können Sie jetzt abbrechen und mit der Fehlerbehebung beginnen. Stellen Sie erneut sicher, dass `Secure Boot` ausgeschaltet ist. Dies wird der wahrscheinlichste Übeltäter sein.

Als Nächstes müssen Sie die Festplatten in unserem System untersuchen, herausfinden, wo sich das Betriebssystem befindet, und feststellen, was für den ZFS-Pool verfügbar ist. Dies erreichen Sie mit `lsblk`:

```bash
lsblk
```

Das Ergebnis ist etwa das Folgende (Ihr System wird sicherlich anders sein!):

```bash
AME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0    7:0    0  32.3M  1 loop /var/lib/snapd/snap/snapd/11588
loop1    7:1    0  55.5M  1 loop /var/lib/snapd/snap/core18/1997
loop2    7:2    0  68.8M  1 loop /var/lib/snapd/snap/lxd/20037
sda      8:0    0 119.2G  0 disk
├─sda1   8:1    0   600M  0 part /boot/efi
├─sda2   8:2    0     1G  0 part /boot
├─sda3   8:3    0  11.9G  0 part [SWAP]
├─sda4   8:4    0     2G  0 part /home
└─sda5   8:5    0 103.7G  0 part /
sdb      8:16   0 119.2G  0 disk
├─sdb1   8:17   0 119.2G  0 part
└─sdb9   8:25   0     8M  0 part
sdc      8:32   0 149.1G  0 disk
└─sdc1   8:33   0 149.1G  0 part
```

Diese Auflistung zeigt, dass das Betriebssystem _/dev/sda_ verwendet. Sie werden _/dev/sdb_ für das `zpool` verwenden. Beachten Sie: Wenn Sie über viele verhandene Festplatten verfügen, sollten Sie die Verwendung von `raidz` (ein Software-Raid speziell für ZFS) in Betracht ziehen.

Dies liegt außerhalb des Rahmens dieses Dokuments, ist jedoch für die Produktion zu berücksichtigen. Es bietet eine bessere Leistung und Redundanz. Erstellen Sie zunächst Ihren Pool auf dem einzelnen Device, das Sie identifiziert haben:

```bash
zpool create storage /dev/sdb
```

Dies bedeutet, dass ein Pool mit dem Namen `storage` (ZFS) auf dem Gerät _/dev/sdb_ erstellt werden soll.

Sobald der Pool erstellt wurde, ist es eine gute Idee, den Server an dieser Stelle neu zu starten.
