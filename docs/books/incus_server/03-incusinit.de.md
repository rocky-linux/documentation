---
title: "Kapitel 3: Incus-Initialisierung und Benutzer-Konfiguration"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - Incus
  - Enterprise
  - Incus-Initialisierung
  - incus setup
---

In diesem Kapitel müssen Sie Root-Benutzer sein oder `sudo` verwenden können, um Root-Rechte
zu erhalten. Darüber hinaus wird davon ausgegangen, dass Sie einen ZFS-Speicherpool wie in [Kapitel 2] (02-zfs_setup.md) beschrieben eingerichtet haben. Wenn Sie sich gegen die Verwendung von ZFS entschieden haben, können Sie einen anderen Speicherpool verwenden. Sie müssen jedoch die Angaben während der Initialisierung anpassen.

## Incus-Initialisierung

Ihre Serverumgebung ist vollständig eingerichtet. Sie können Incus nun initialisieren. Dies ist ein automatisiertes Skript, das eine Reihe von Fragen stellt, um Ihre Incus-Instanz einzurichten:

```bash
incus admin init
```

Hier sind die Fragen und unsere Antworten zum Skript, ggf. mit einer kleinen Erklärung:

```text
Would you like to use clustering? (yes/no) [default=no]:
```

Wenn Sie sich für Clustering interessieren, können Sie [hier](https://linuxcontainers.org/incus/docs/main/explanation/clustering/) weitere Informationen dazu finden.

```text
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

Das scheint kontraintuitiv zu sein. Sie haben Ihren ZFS-Pool bereits erstellt, dies wird jedoch in einer späteren Frage klargestellt. Sie können die Standardeinstellung akzeptieren.

```text
Name of the new storage pool [default=default]: storage
```

Sie können die Standardeinstellung beibehalten, der Übersichtlichkeit halber ist es jedoch besser, den gleichen Namen zu verwenden, den Sie unserem ZFS-Pool gegeben haben.

```text
Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:
```

Sie sollten die Standard-Einstellung akzeptieren.

```text
Create a new ZFS pool? (yes/no) [default=yes]: no
```

Hier kommt die Lösung der früheren Frage zum Erstellen eines Speicherpools ins Spiel.

```text
Name of the existing ZFS pool or dataset: storage
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Metal As A Service (MAAS) ist nicht Gegenstand dieses Dokuments.

```text
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

Sie können diese Option aktivieren, um IPv6 auf Ihren Incus-Containern zu verwenden.

```text
Would you like the Incus server to be available over the network? (yes/no) [default=no]: yes
```

Dies ist erforderlich, um einen Snapshot des Servers zu erstellen.

```text
Address to bind Incus to (not including port) [default=all]:
Port to bind Incus to [default=8443]:
Trust password for new clients:
Again:
```

Mit diesem Trust-Passwort stellen Sie die Verbindung zum bzw. vom Snapshot-Server her. Setzen Sie es mit etwas ein, das in Ihrer Umgebung Sinn ergibt. Speichern Sie diesen Eintrag an einem sicheren Ort, beispielsweise einem Passwort-Manager.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "incus admin init" preseed to be printed? (yes/no) [default=no]:
```

## Benutzerrechte festlegen

Bevor Sie fortfahren, müssen Sie Ihren Benutzer `incusadmin` erstellen und sicherstellen, dass er über die erforderlichen Berechtigungen verfügt. Sie benötigen den Benutzer `incusadmin`, um mit `sudo` auf Root zugreifen zu können, und er muss Mitglied der Gruppe `incus-admin` sein. Um den Benutzer hinzuzufügen und sicherzustellen, dass er Mitglied beider Gruppen ist, gehen Sie wie folgt vor:

```bash
useradd -G wheel,incus-admin incusadmin
```

Passwort setzen:

```bash
passwd incusadmin
```

Speichern Sie dieses wie alle anderen Passwörter an einem sicheren Ort.

## Festlegen der `subuid`- und `subgid`-Werte für `root`

Sie müssen sowohl den Wert für `subuid` als auch für `subgid` (den Bereich der untergeordneten Benutzer- und Gruppen-IDs) des Root-Benutzers festlegen. Dieser Wert sollte, wie folgt, lauten:

```bash
root:1000000:1000000000
```

Bearbeiten Sie dazu `/etc/subuid` und fügen Sie die Zeile hinzu. Nach dem Editieren sieht Ihre Datei wie folgt aus:

```bash
root:1000000:1000000000
```

Editieren Sie die Datei `/etc/subgid` und fügen Sie die entsprechende Zeile hinzu. Nach dem Editieren sieht Ihre Datei wie folgt aus:

```bash
incusadmin:100000:65536
root:1000000:1000000000
```

Starten Sie den Server neu, bevor Sie fortfahren.
