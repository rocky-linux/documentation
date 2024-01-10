---
Title: Docs As Code
author: Steven Spencer
contributors: null
tags:
  - local docs
  - docs as code
  - linters
---

# Einleitung

Die Verwendung einer lokalen Kopie der Rocky Linux-Dokumentation ist hilfreich für diejenigen, die häufig Beiträge leisten und genau sehen möchten, wie ein Dokument nach dem Zusammenführen in der Weboberfläche aussieht. Die hier enthaltenen Methoden spiegeln die bisherigen Präferenzen der Mitwirkenden wider.

Die Verwendung einer lokalen Kopie der Dokumentation ist ein Schritt im Entwicklungsprozess für diejenigen, die sich der Philosophie von „Dokumenten als Code“ anschließen, einem Workflow für die Dokumentation, der der Codeentwicklung ähnelt.

## Markdown-Linter

Neben Umgebungen zum Speichern und Erstellen der Dokumentation könnte für einige Autoren auch ein Linter für Markdown eine Überlegung wert sein. Markdown-Linters sind in vielen Aspekten der Verfassung von Dokumenten hilfreich, einschließlich der Überprüfung von Grammatik, Rechtschreibung, Formatierung und mehr. Manchmal handelt es sich dabei um separate Tools oder Plugins für Ihren Editor. Ein solches Tool ist [markdownlint](https://github.com/DavidAnson/markdownlint), ein Node.js-Tool. „markdownlint“ ist als Plugin für viele gängige Editoren verfügbar, darunter Visual Studio Code und NVChad. Aus diesem Grund befindet sich im Stammverzeichnis des Dokumentationsverzeichnisses eine Datei „.markdownlint.yml“, die die für das Projekt verfügbaren und aktivierten Regeln anwendet. `markdownlint` ist ein reiner Formatierungs-Linter. Es prüft auf fehlerhafte Leerzeichen, Inline-HTML-Elemente, doppelte Leerzeilen, falsche Tabulatoren und mehr. Für Grammatik, Rechtschreibung, inklusiven Sprachgebrauch und mehr installieren Sie bitte andere Tools.

!!! info „Haftungsausschluss“

```
Bei keinem der Punkte in dieser Kategorie („Lokale Dokumentation“) ist es erforderlich, Dokumente zu verfassen und zur Genehmigung einzureichen. Sie existieren für diejenigen, die der Philosophie von [docs as code](https://www.writethedocs.org/guide/docs-as-code/) folgen möchten, die mindestens eine lokale Kopie der Dokumentation enthalten.
```
