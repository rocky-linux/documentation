---
title: Lokale Rocky-Repositories einrichten
author: codedude
contributors: Steven Spencer
update: 09-Dec-2021
---

# Einleitung

Manchmal müssen Sie Rocky Repositories lokal einrichten, um virtuelle Maschinen, Laborumgebungen usw. zu erstellen. Es kann auch helfen, Bandbreite zu sparen, wenn das ein Anliegen ist.  Dieser Artikel wird Sie mit `rsync` begleiten, um Rocky Repositories auf einen lokalen Webserver zu kopieren.  Der Aufbau eines Webservers geht über den Rahmen dieses kurzen Artikels hinaus.

## Voraussetzung

* Ein Webserver

## Code

```bash
#!/bin/bash
repos_base_dir="/web/path"

# Start sync if base repo directory exist
if [[ -d "$repos_base_dir" ]] ; then
  # Start Sync
  rsync  -avSHP --progress --delete --exclude-from=/opt/scripts/excludes.txt rsync://ord.mirror.rackspace.com/rocky  "$repos_base_dir" --delete-excluded
  # Download Rocky 8 repository key
  if [[ -e /web/path/RPM-GPG-KEY-rockyofficial ]]; then
     exit
  else
      wget -P $repos_base_dir https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-rockyofficial
  fi
fi
```

## Breakdown

Dieses einfache Shell-Skript verwendet `rsync`, um die Repository-Dateien vom nächstgelegenen Spiegel abzurufen.  Es nutzt auch die `exclude`-Option, die in einer Textdatei in Form von Schlüsselwörtern definiert ist, die nicht enthalten sein sollten.  `Excludes` sind nützlich, wenn Sie nur begrenzten Speicherplatz haben oder wenn Sie aus irgendeinem Grund nicht alles möchten.  Sie können `*` als Platzhalter verwenden.  Seien Sie vorsichtig bei der Verwendung von `*/ng`, da dadurch alles ausgeschlossen wird, was diesen Zeichen entspricht.  Hier ein Beispiel:

```bash
*/source*
*/debug*
*/images*
*/Devel*
8/*
8.4-RC1/*
8.4-RC1
```

## Zusammenfassung

Ein einfaches Skript, das dazu beitragen sollte, Bandbreite zu sparen oder das Erstellen einer Laborumgebung ein wenig zu vereinfachen.
