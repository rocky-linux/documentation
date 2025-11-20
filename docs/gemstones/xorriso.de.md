---
title: Mit Xorriso auf physische CDs/DVDs brennen
author: Joseph Brinkman
---

## Einleitung

Der Autor stellte kürzlich fest, dass das Brennen von Hybrid-ISOs auf eine physische CD/DVD unter Rocky Linux mit grafischen Werkzeugen eine Herausforderung darstellt. Zum Glück ist Xorriso eine einfach zu bedienende CLI-Anwendung, die diese Aufgabe gut erledigt!

## Problembeschreibung

Eine ISO-Datei auf eine physische CD/DVD brennen.

## Voraussetzungen

- Internetverbindung
- Erfahrung mit der Kommandozeile
- CD/DVD-RW-Laufwerk

## Prozedur

**Xorriso installieren**:

   ```bash
   sudo dnf install xorriso -y
   ```

**ISO auf Festplatte schreiben**:

   ```bash
   sudo xorriso -as cdrecord -v dev/=/dev/sr0 -blank=as_needed -dao Rocky-10.1-x86_64-boot.iso
   ```

## Zusätzliche Informationen

Xorriso verwendet die C-Bibliothek `libisofs`. Mehr über libisofs erfahren Sie im [Fedora-Paketbeobachter](https://packages.fedoraproject.org/pkgs/libisofs/libisofs/index.html).

## Zusammenfassung

In diesem Kurs haben Sie gelernt, wie man mit Xorriso eine ISO-Datei auf eine physische Disk schreibt! Beachten Sie, dass Xorriso auch zum Schreiben anderer Dateitypen auf physische Datenträger verwendet werden kann, aber der Autor fand es besonders praktisch für das hybride ISO-Format, mit dem grafische Tools nicht umgehen konnten.
