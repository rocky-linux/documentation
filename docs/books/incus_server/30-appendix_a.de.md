---
title: Appendix A - Workstation Setup
author: Steven Spencer
contributors: Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - workstation
---

# Anhang A – Workstation-Setup

Obwohl dies nicht Teil der Kapitel für einen Incus-Server ist, wird dieses Verfahren denjenigen helfen, die eine Laborumgebung oder ein semi-permanentes Betriebssystem und Anwendungen auf einer Rocky Linux-Workstation oder einem Notebook betreiben möchten.

## Voraussetzungen

- Erfahrung mit der Kommandozeile
- sicheren Umgang mit einen Kommandozeileneditor wie `vi` oder `nano`
- Bedarf nach einer stabilen Testumgebung, die regelmäßig verwendet werden kann
- in der Lage sein, `root` zu werden oder mit `sudo` erweiterte Berechtigungen zu bekommen

## Installation

Installieren Sie das EPEL-Repository über die Befehlszeile:

```bash
sudo dnf install epel-release -y
```

When the installation finishes, do an upgrade:

```bash
sudo dnf upgrade
```

Installation anderer Repositories:

```bash
sudo dnf config-manager --enable crb
sudo dnf copr enable neil/incus
```

Benötigte Pakete installieren:

```bash
sudo dnf install dkms vim kernel-devel bash-completion
```

Incus installieren und aktivieren:

```bash
sudo dnf install incus incus-tools
sudo systemctl enable incus
```

Please reboot your notebook or workstation before you continue.

## Incus-Initialisierung

If you have looked through the production server chapters, this is nearly identical to the production server initialization procedure.

```bash
sudo incus admin init
```

This will start a question-and-answer dialog.

Here are the questions and our answers for the script, with a little explanation where warranted:

```text
Would you like to use clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: storage
```

Jetzt können Sie die Default-Einstellung verwenden.

```text
Name of the storage backend to use (btrfs, dir, lvm, ceph) [default=btrfs]: dir
```

Note that `dir` is somewhat slower than `zfs`. If you can leave a disk empty, you can use that device (example: /dev/sdb) for the `zfs` device and then select `zfs`.

```text
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Metal As A Service (MAAS) is outside the scope of this document.

```text
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

Sie können diese Option aktivieren, wenn Sie IPv6 auf Ihren `Incus`-Containern verwenden möchten.

```text
Would you like the Incus server to be available over the network? (yes/no) [default=no]: yes
```

This is necessary to snapshot the workstation. Bitte hier mit "yes" antworten.

```text
Address to bind Incus to (not including port) [default=all]:
Port to bind Incus to [default=8443]:
Trust password for new clients:
Again:
```

This trust password is how you will connect to or back from the snapshot server. Set it with something that makes sense in your environment. Speichern Sie diesen Eintrag an einem sicheren Ort, wie zum Beispiel einem Passwort-Manager.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "incus admin init" preseed to be printed? (yes/no) [default=no]:
```

## Benutzerrechte

The next thing you need to do is to add your user to the `incus-admin` group. Again, you will need to use `sudo` or be root for this:

```text
sudo usermod -a -G incus-admin [username]
```

Where [username] is your user on the system.

## Festlegen der Werte `subuid` und `subgid` für `root`

Sie müssen sowohl den Wert für die `subuid` als auch für die `subgid` des Root-Benutzers festlegen (den Bereich der untergeordneten Benutzer- und Gruppen-IDs). Dieser Wert sollte, wie folgt, sein:

```bash
root:1000000:1000000000
```

Bearbeiten Sie dazu die Datei `/etc/subuid` und fügen Sie diese Zeile hinzu. Nach dem Edit sieht Ihre Datei wie folgt aus:

```bash
root:1000000:1000000000
```

Fügen Sie diese Zeile erneut der Datei `/etc/subgid` hinzu. Ihre Datei sieht in etwa so aus:

```bash
incusadmin:100000:65536
root:1000000:1000000000
```

You have made a number of changes at this point. Starten Sie Ihren Computer neu, bevor Sie fortfahren.

## Überprüfung der Installation

To ensure that `incus` started and that your user has privileges, from the shell prompt do:

```text
incus list
```

Bitte beachten Sie, dass Sie hier nicht einmal `sudo` verwendet haben. Ihr Benutzer kann diese Befehle eingeben. Sie sollten so etwas erhalten:

```bash
+------------+---------+----------------------+------+-----------+-----------+
|    NAME    |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------+---------+----------------------+------+-----------+-----------+
```

Wenn ja, dann sieht es gut aus!

## Zum Abschluss

From this point, you can use the chapters from our "Incus Production Server" to continue. There are some things on a workstation setup that you need to pay less attention to. Hier sind die empfohlenen Kapitel, um Ihnen den Einstieg zu erleichtern:

- [Kapitel 5 - Einrichten und Verwalten von Images](05-incus_images.md)
- [Kapitel 6 - Profile](06-profiles.md)
- [Kapitel 8 - Container Snapshots](08-snapshots.md)

## Weitere Informationen

- [Offizielle Incus-Übersicht und Dokumentation](https://linuxcontainers.org/incus/docs/main/)

## Zusammenfassung

Incus ist ein leistungsstarkes Tool zur Steigerung der Produktivität auf Workstations oder Servern. Es eignet sich hervorragend für Labortests auf einer Workstation und kann auch halbpermanente Instanzen von Betriebssystemen und Anwendungen in einem eigenen, privaten Bereich bereithalten.
