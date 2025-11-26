---
title: Mit Xorriso auf physische CDs/DVDs brennen
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## Einleitung

Der Autor stellte kürzlich fest, dass das Brennen von Hybrid-ISOs auf eine physische CD/DVD unter Rocky Linux mit grafischen Tools eine Herausforderung darstellt. Zum Glück ist Xorriso eine einfach zu bedienende CLI-Anwendung, die diese Aufgabe gut bewältigt!

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
   sudo xorriso -as cdrecord -v dev=/dev/sr0 -blank=as_needed -dao Rocky-10.1-x86_64-boot.iso -eject
   ```

## Zusätzliche Informationen

Xorriso verwendet eine C-Bibliothek namens `libisofs`. Mehr über `libisofs` erfahren Sie im [Fedora-Package-Watcher](https://packages.fedoraproject.org/pkgs/libisofs/libisofs/index.html).

## Zusammenfassung

In diesem Kurs haben Sie gelernt, wie man mit Xorriso eine ISO-Datei auf eine physische Festplatte schreibt! Beachten Sie, dass `Xorriso` auch zum Schreiben anderer Dateitypen auf physische Datenträger verwendet werden kann, aber der Autor fand es besonders praktisch für das hybride ISO-Format, mit dem grafische Tools nicht umgehen konnten.<small>
<br/><br/>
🌐 Übersetzungen: 
<a href="https://crowdin.com/project/rockydocs/de">crowdin.com/project/rockydocs</a>
<br/>
🌍 Übersetzer:
<a href="https://crowdin.com/project/rockydocs/activity-stream">rockydocs/activity-stream</a>
, <a href="https://crowdin.com/project/rockylinuxorg/activity-stream">rockylinux.org</a>
<br/>
🖋 Mitmachen:
<a href="https://github.com/rocky-linux/documentation?tab=readme-ov-file#mattermost">github.com/rocky-linux</a>
</small>
