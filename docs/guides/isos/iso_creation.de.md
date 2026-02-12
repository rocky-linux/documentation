---
title: Erstellen einer benutzerdefinierten Rocky Linux ISO
author: Howard Van Der Wal
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9
tags:
  - create
  - custom
  - ISO
  - kickstart
  - linux
  - mkksiso
  - rocky
---

**Vorkenntnisse**: :star: :star:  
**Lesezeit**: 11 Minuten

## Einleitung

Es gibt viele Gründe für die Erstellung einer ISO. Vielleicht möchten Sie den Bootvorgang modifizieren, während der Installation bestimmte Pakete hinzufügen oder bestimmte Konfigurationsdateien aktualisieren.

Diese Anleitung zeigt Ihnen, wie Sie Ihr eigenes Rocky Linux ISO erstellen.

## Voraussetzungen

- Minimales ISO-Image für Rocky Linux (das DVD-Image wird nicht benötigt).
- Eine `kickstart`-Datei, die auf die ISO angewendet werden soll.
- Lesen Sie die [Lorax Quickstart](https://weldr.io/lorax/lorax.html#quickstart) und die [mkksiso](https://weldr.io/lorax/mkksiso.html) Dokumentation, um sich mit der Erstellung einer ISO-Datei vertraut zu machen.

## Paketinstallation und Einrichtung

- Installieren Sie das `lorax`-Paket:

```bash
dnf install -y lorax
```

## Erstellen der ISO mit einer `kickstart`-Datei

- Führen Sie den Befehl `mkksiso` aus, um eine `kickstart`-Datei hinzuzufügen und anschließend ein neues ISO-Image zu erstellen. Beachten Sie, dass Sie den Befehl als `root` oder als Benutzer mit `sudo`-Berechtigungen ausführen müssen:

```bash
mkksiso --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO> <PATH_TO_NEW_ISO>
```

## Hinzufügen eines Repositorys mit seinen Paketen zu einem ISO-Image

- Stellen Sie sicher, dass das Repository, das Sie hinzufügen möchten, das Verzeichnis `repodata` enthält. Falls nicht, können Sie dies mit dem Befehl  
  `createrepo_c`
  erstellen und mit  
  `dnf install -y createrepo_c`  
  installieren.
- Fügen Sie das Repository zu Ihrer `kickstart`-Datei hinzu, indem Sie die folgende Syntax verwenden:

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/<REPOSITORY>/
```

- Fügen Sie das Repository mithilfe des Flags `--add` über das Tool `mkksiso` hinzu:

```bash
mkksiso --add <LINK_TO_REPOSITORY> --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO> <PATH_TO_NEW_ISO>
```

- Weitere Details zu diesem Prozess können Sie im folgenden Beispiel anhand des `baseos`-Repositorys einsehen.
- Das `baseos`-Repository wird zusammen mit allen dazugehörigen Paketen lokal heruntergeladen:

```bash
dnf reposync -p ~ --download-metadata --repo=baseos
```

- Fügen Sie anschließend das Repository zu Ihrer `kickstart`-Datei hinzu:

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
```

- Geben Sie anschließend den Befehl `mkksiso` direkt im Repository-Verzeichnis ein und erstellen Sie die ISO-Datei:

```bash
mkksiso --add ~/baseos --ks <PATH_TO_KICKSTART_FILE> ~/<PATH_TO_ISO> ~/<PATH_TO_NEW_ISO>
```

## Zusammenfassung

Sobald Ihre ISO-Datei mit Ihrer Kickstart-Datei erstellt ist, wird es wesentlich einfacher, Hunderte von Maschinen von einem einzigen Image aus bereitzustellen, ohne jede Maschine einzeln konfigurieren zu müssen. Um mehr über `kickstart`-Dateien zu erfahren und zahlreiche Beispiele zu untersuchen, besuchen Sie bitte den [Kickstart Files and Rocky Linux guide](../../automation/kickstart-rocky/).
