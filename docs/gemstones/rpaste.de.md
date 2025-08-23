---
title: rpaste — Pastebin Tool
author: Steven Spencer
contributors:
tags:
  - rpaste
  - Mattermost
  - pastebin
---

# Einführung in `rpaste`

`rpaste` ist ein Tool zum Teilen von Code, Protokollausgaben und anderen besonders langen Texten. Es ist ein `Pastebin`, das von den Entwicklern von Rocky Linux erstellt wurde. Dieses Tool ist nützlich, wenn Sie etwas öffentlich teilen müssen, den Feed jedoch nicht mit Ihrem Text überladen möchten. Dies ist insbesondere bei der Verwendung von Mattermost wichtig, das Brücken zu anderen IRC-Diensten bietet. Das `rpaste`-Tool kann auf jedem Rocky Linux System installiert werden. Wenn Ihr Desktop-Computer nicht Rocky Linux ist oder Sie das Tool einfach nicht installieren möchten, können Sie es manuell verwenden, indem Sie auf die [Pinnwand-URL](https://rpa.st) zugreifen und dann die Systemausgabe oder den Text einfügen, den Sie teilen möchten. `rpaste` erlaubt es Ihnen, diese Informationen automatisch anzulegen.

## Installation

Installation von `rpaste` auf Rocky Linux:

```bash
sudo dnf --enablerepo=extras install rpaste
```

## Verwendung

Bei größeren Systemproblemen müssen Sie möglicherweise alle Informationen Ihres Systems senden, damit diese überprüft werden können. Um dies zu erreichen, geben Sie Folgendes ein:

```bash
rpaste --sysinfo
```

Gibt den Link auf die Pinnwand-Seite zurück:

```bash
Uploading...
Paste URL:   https://rpa.st/2GIQ
Raw URL:     https://rpa.st/raw/2GIQ
Removal URL: https://rpa.st/remove/YBWRFULDFCGTTJ4ASNLQ6UAQTA
```

Sie können die Informationen dann selbst in einem Browser überprüfen und entscheiden, ob Sie sie behalten oder entfernen und neu starten möchten. Wenn Sie es behalten möchten, können Sie die `Paste URL` kopieren und mit wem auch immer teilen oder im Feed auf Mattermost. Zum Entfernen kopieren Sie einfach die `Removal URL` und öffnen Sie diese in Ihrem Browser.

Sie können Ihrem `Pastebin` Inhalte hinzufügen, indem Sie Inhalte übermitteln. Wenn Sie zum Beispiel Inhalte aus Ihrer `/var/log/messages` Datei vom 10. März hinzufügen wollten, können Sie folgendes tun:

```bash
sudo more /var/log/messages | grep 'Mar 10' | rpaste
```

## Hilfe zu `rpaste`

Um Hilfe zum Befehl zu erhalten, geben Sie einfach folgendes ein:

```bash
rpaste --help
```

Dies ergibt folgende Ausgabe:

```bash
rpaste: A paste utility originally made for the Rocky paste service

Usage: rpaste [options] [filepath]
       command | rpaste [options]

This command can take a file or standard in as input

Options:
--life value, -x value      Sets the life time of a paste (1hour, 1day, 1week) (default: 1hour)
--type value, -t value      Sets the syntax highlighting (default: text)
--sysinfo, -s               Collects general system information (disables stdin and file input) (default: false)
--dry, -d                   Turns on dry mode, which doesn't paste the output, but shows the data to stdin (default: false)
--pastebin value, -p value  Sets the paste bin service to send to. Current supported: rpaste, fpaste (default: "rpaste")
--help, -h                  show help (default: false)
--version, -v               print the version (default: false)
```

## Fazit

Es ist manchmal wichtig, eine große Menge an Text zu teilen, wenn man an einem Problem, dem Implementieren von Code oder Editieren von Text usw. arbeitet. Durch die Verwendung von `rpaste` müssen andere nicht große Mengen an Textinhalten anzeigen, die für sie nicht wichtig sind. Achten Sie bitte auch auf die Chat-Etikette von Rocky Linux.
