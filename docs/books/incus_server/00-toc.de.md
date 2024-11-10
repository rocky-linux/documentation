---
title: Incus Server Einleitung
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - lxd
  - incus
  - enterprise
---

## Incus-Server erstellen

### Incus-Status unter Rocky Linux

Vor ca einem Jahr – 2023 – kam folgende Ankündigung auf der lxc-users Mailingliste:

> _Canonical, the creator and main contributor of the LXD project has decided that after over 8 years as part of the Linux Containers community, the project would now be better served directly under Canonical’s own set of projects._

L’un des facteurs décisifs a été la démission de certains développeurs principaux de LXD. Diese Entwickler haben dann ein Fork von LXD nach Incus erstellt und diesen Fork im August 2023 angekündigt. Eine Release-Version (0.1) erschien im Oktober 2023, und die Entwickler haben diese Version seitdem mit schrittweisen Releases bis 0.7 (im März 2024) schnell weiterentwickelt. Die Veröffentlichung der langfristigen Support-Version (6.0 LTS) folgte auf die Version 0.7. Die aktuelle Version – September 2024 – ist 6.5.

Es wurde angenommen, dass Canonical während des gesamten Prozesses weiterhin Links zu den von Linux Containers bereitgestellten Container-Images aufrechterhalten würde. Eine [Lizenzänderung](https://stgraber.org/2023/12/12/lxd-now-re-licensed-and-under-a-cla/) machte es Linux Containern jedoch unmöglich, weiterhin die Containerbilder innerhalb von LXD anzubieten. Das bedeutet, dass LXD über Container-Images verfügt, diese jedoch nicht das sind, was Sie vielleicht erwarten. Linux Containers hostet und unterstützt weiterhin ihre Images, wenn Sie Incus verwenden.

Dieses Dokument ist eine Umwandlung vom [LXD-Buch](../lxd_server/00-toc.md) in Incus. Seit der Erstellung eines Repository durch den Co-Leiter der Rocky Linux-Projektinfrastruktur [Neil Hanlon](https://wiki.rockylinux.org/team/infrastructure/) haben Sie die Möglichkeit, Incus vor der Aufnahme in das EPEL (Extra Packages for Enterprise Linux Repository) zu installieren.

!!! warning "Incus-Server ist unter Rocky Linux 8 nicht verfügbar"

```
Die Incus-Serverinstallation ist nur für Rocky Linux 9.x verfügbar und wird derzeit auf Rocky Linux 9.4 getestet. Wenn Sie etwas benötigen, das auf Rocky Linux 8.x funktioniert, verwenden Sie das [zuvor erwähnte LXD-Verfahren](../lxd_server/00-toc.md).
```

## Einleitung

Incus wird am besten auf der [offiziellen Website](https://linuxcontainers.org/incus/) beschrieben, aber stellen Sie es sich als ein Containersystem vor, das die Vorteile virtueller Server in einem Container bietet.

Es ist sehr leistungsstark und mit der richtigen Hardware und Setup ist es möglich, viele Serverinstanzen auf einer einzigen Hardware zu erstellen. Wenn Sie das mit einem Snapshot-Server koppeln, verfügen Sie auch über eine Reihe von Containern, die Sie fast sofort hochfahren können, wenn Ihr primärer Server ausfällt.

!!! warning "Das kein Ersatz für Datensicherungen"

```
Sie sollten sich das nicht als traditionelles Backup vorstellen. Sie benötigen immer noch ein normales Sicherungssystem wie [rsnapshot](../../guides/backup/rsnapshot_backup.md).
```

Die Inckus-Lernkurve kann steil sein, aber dieses Buch wird versuchen, Ihnen das Wissen zu geben, um Ihnen zu helfen, Incus auf Rocky Linux zu verwenden.

Für diejenigen, die Incus als Laborumgebung auf ihren Notebooks oder Workstations verwenden möchten, siehe [Anhang A: Workstation Setup](30-appendix_a.md).

## Voraussetzungen

- Ein ordnungsgemäß konfigurierter Rocky Linux 9-Server. Erwägen Sie eine separate Festplatte für den ZFS-Festplattenspeicher in einer Produktionsumgebung (dies ist erforderlich, wenn Sie ZFS verwenden). Und ja, hier wird von einem Bare-Metal-Server ausgegangen, nicht von einem VPS (Virtual Private Server).
- Dies ist ein fortgeschrittenes Thema, aber es ist nicht allzu schwer zu verstehen. Wenn Sie diese Anweisungen von Anfang an befolgen, sollten Sie erfolgreich sein. Dennoch ist es hilfreich, ein paar grundlegende Dinge über die Containerverwaltung zu wissen.
- Sicherer Umgang mit der Befehlszeile auf Ihren Computern und mit einem Befehlszeileneditor. (Wir verwenden _vi_ in diesem Beispiel, aber Sie können Ihren Lieblingseditor einsetzen.)
- Für die meisten dieser Prozesse müssen Sie ein Benutzer ohne besondere Privilegien sein. Für die ersten Einrichtungsschritte müssen Sie Root-Benutzer sein oder in der Lage sein, sich mithilfe von `sudo` als Root-Benutzer anzumelden. Während dieser Kapitel gehen wir davon aus, dass Ihr Benutzer ohne besondere Privilegien `incusadmin` ist. Sie müssen dieses Benutzerkonto später im Vorgangsablauf erstellen.
- Stellen Sie für `ZFS` sicher, dass `UEFI` sicheres Booten NICHT aktiviert ist. Andernfalls müssen Sie das ZFS-Modul signieren, um es zum Laden zu bringen.
- Wir verwenden zum größten Teil Rocky Linux-basierte Container.

!!! info

```
Der Autor enthält eine Methodik zur Verwendung eines ZFS-Dateisystems. Bitte beachten Sie, dass das Incus Projekt BTRFS als Dateisystem für einen Incus Server empfiehlt (ZFS ist immer noch eine Dateisystem Option). BTRFS, ist jedoch unter Rocky Linux 9.4 überhaupt nicht verfügbar. Bis es vom Upstream zugelassen und dort veröffentlicht wird, besteht Ihre einzige Option darin, ZFS oder ein anderes mitgeliefertes Dateisystem zu verwenden. Um mehr über Incus-Dateisystem-Optionen zu erfahren, lesen Sie [das offizielle Dokument des Projekts hier.](https://linuxcontainers.org/incus/docs/main/reference/storage_dir/)  
```

## Synopsis

- **Kapitel 1: Installation und Konfiguration** behandelt die Installation des primären Servers. Der richtige Weg, Incus in der Produktion einzusetzen, besteht im Allgemeinen darin, einen Primär- und einen Snapshot-Server zu haben.
- **Kapitel 2: ZFS Setup** befasst sich mit der Einrichtung und Konfiguration von ZFS. `ZFS` ist ein Open-Source-Logical Volume Manager und Dateisystem, das von Sun Microsystems erstellt wurde, ursprünglich für sein Solaris-Betriebssystem.
- **Kapitel 3: Incus Initialisierung und Benutzer-Setup** behandelt die Basisinitialisierung und -optionen, und auch die Einrichtung Ihres unprivilegierten Benutzers, den Sie während des gesamten gesamten Prozesses verwenden werden
- **Kapitel 4: Firewall-Setup** beschreibt `firewalld` Setup-Optionen
- **Kapitel 5: Einrichten und Verwalten von Images** beschreibt den Prozess zur Installation von Betriebssystem-Images in einem Container und deren Konfiguration
- **Kapitel 6: Profiles** befasst sich mit dem Hinzufügen von Profilen und deren Anwendung auf Container und deckt hauptsächlich `macvlan` und dessen Bedeutung für die IP-Adressierung in Ihrem LAN oder WAN ab
- **Kapitel 7: Container Configuration Options** behandelt kurz einige der grundlegenden Konfigurationsoptionen für Container und beschreibt einige Vorteile und Nebeneffekte für die Änderung der Konfigurationsoptionen
- **Kapitel 8: Container Snapshots** zeigt detailliert den Snapshot-Prozess für Container auf dem primären Server
- **Kapitel 9: Der Snapshot-Server** behandelt die Einrichtung und Konfiguration des Snapshot-Servers und wie die symbiotische Verbindung zwischen dem Primär- und Snapshot-Server erstellt werden kann
- **Kapitel 10: Automatisierung von Snapshots** behandelt die Automatisierung der Snapshot-Erstellung und das Auffüllen des Snapshot-Servers mit Snapshots
- **Anhang A: Workstation-Setup** ist technisch gesehen nicht Bestandteil der Produktionsserver-Dokumente. Es bietet eine Lösung für Personen, die auf ihren Notebooks oder Workstations ein Labor aus Incus-Containern aufbauen möchten.

## Zusammenfassung

Mit diesen Kapiteln können Sie effektiv ein Primär- und Snapshot-Incus-Serverpaar – für Unternehmen geeignet – einrichten. Dabei lernen Sie viel über Incus. Bedenken Sie, dass es noch viel mehr zu lernen gibt, und betrachten Sie diese Dokumente als Ausgangspunkt.

Der größte Vorteil von Incus besteht darin, dass es sich wirtschaftlich auf einem Server verwenden lässt, eine schnelle Betriebssysteminstallation ermöglicht und den Betrieb mehrerer eigenständiger Anwendungsserver auf einer einzigen Hardware ermöglicht, sodass diese Hardware optimal genutzt wird.
