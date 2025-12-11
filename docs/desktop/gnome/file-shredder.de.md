---
title: File Shredder — Sichere Löschung
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - Sicherheit
  - Datenschutz
  - flatpak
---

## Dateien endgültig und sicher löschen

Wenn Sie eine Datei mit Ihrem Dateimanager löschen, werden die Daten nicht tatsächlich gelöscht. Das Betriebssystem kennzeichnet den Speicherplatz auf Ihrer Festplatte als `available`, sodass die ursprünglichen Daten erhalten bleiben, bis sie schließlich von neuen Dateien überschrieben werden. Das bedeutet, dass „gelöschte“ Dateien oft mithilfe spezieller Software wiederhergestellt werden können.

**File Shredder** ist ein einfaches, modernes Hilfsprogramm für den GNOME-Desktop, das dieses Problem löst, indem es Ihnen ermöglicht, Dateien endgültig und sicher zu löschen. Dies geschieht, indem die Daten der Datei vor dem Löschen wiederholt mit zufälligem Rauschen überschrieben werden, wodurch eine Wiederherstellung praktisch unmöglich wird.

## Installation

Die empfohlene Methode zur Installation von File Shredder auf Rocky Linux ist die Installation als Flatpak-Paket aus dem Flathub-Repository.

### 1. Flathub Aktivierung

Falls Sie dies noch nicht getan haben, stellen Sie bitte sicher, dass Flatpak installiert und die Flathub-Fernbedienung auf Ihrem System konfiguriert ist.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### 2. File Shredder Installation

Sobald Flathub aktiviert ist, können Sie File Shredder mit einem einzigen Befehl installieren.

!!! note "Anwendungs-ID"
Die Anwendung heißt „File Shredder“, ihre technische ID auf Flathub lautet jedoch `io.github.ADBeveridge.Raider`.

```bash
flatpak install flathub io.github.ADBeveridge.Raider
```

## Wie man `File Shredder` benutzt

Nach der Installation starten Sie die Anwendung über die GNOME-Aktivitätenübersicht, indem Sie nach `File Shredder` suchen.

Der Vorgang ist unkompliziert:

1. Ziehen Sie die Dateien oder Ordner, die Sie endgültig löschen möchten, per Drag & Drop direkt in das `File Shredder` Fenster. Sie können auch auf die Schaltflächen **"Add Files..."** oder **"Add Folder..."** klicken.
2. Die Dateien werden in einer Liste angezeigt. Überprüfen Sie diese Liste sorgfältig.
3. Wenn Sie sicher sind, dass Sie die Dateien endgültig vernichten möchten, klicken Sie auf die Schaltfläche **Schred**.

!!! warning "Diese Aktion ist unumkehrbar."
Es gibt keine „undo“-Funktion. Sobald eine Datei vernichtet ist, ist sie endgültig verloren. Überprüfen Sie die hinzugefügten Dateien noch einmal, bevor Sie auf die Schaltfläche `Schred` klicken.

## Ein wichtiger Aspekt bei SSDs

Während File Shredder auf herkömmlichen magnetischen Festplattenlaufwerken (HDDs) sehr effektiv ist, ist seine Wirksamkeit auf modernen Solid-State-Laufwerken (SSDs) begrenzt.

SSDs nutzen komplexe interne Mechanismen wie Wear-Leveling und Garbage-Collection, um Daten zu verwalten und die Lebensdauer des Laufwerks zu verlängern. Diese Mechanismen bedeuten, dass nicht das Betriebssystem, sondern das Laufwerk selbst entscheidet, wo Daten physisch gespeichert werden. Ein Softwaretool wie File Shredder kann eine SSD nicht dazu zwingen, einen bestimmten physischen Datenblock zu überschreiben.

Obwohl die Verwendung von File Shredder auf einer SSD die Datenwiederherstellung deutlich schwieriger macht als eine Standardlöschung, **kann** es nicht garantieren, dass alle Datenspuren physisch aus den Speicherzellen des Laufwerks gelöscht wurden. Für ein Höchstmaß an Datensicherheit auf einer SSD empfiehlt sich die Verwendung einer vollständigen Festplattenverschlüsselung (z. B. LUKS, die während der Installation von Rocky Linux eingerichtet werden kann).

File Shredder ist weiterhin ein wertvolles Tool zur Verbesserung Ihres Datenschutzes, insbesondere auf Festplatten, und bietet für die meisten Anwendungsfälle eine starke Sicherheitsebene.
