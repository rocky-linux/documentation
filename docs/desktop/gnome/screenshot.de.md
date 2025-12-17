---
title: Screenshots und Screencasts in GNOME
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - screenshot
  - screencast
  - guide
---

## Introduction

Der moderne GNOME-Desktop, der in Rocky Linux zum Einsatz kommt, beinhaltet ein leistungsstarkes und nahtlos integriertes Tool zum Aufnehmen des Bildschirms. Dies ist keine separate Anwendung, die Sie installieren müssen, sondern ein fester Bestandteil der Desktop-Umgebung, der eine flüssige und effiziente Möglichkeit bietet, Screenshots zu erstellen und kurze Videos (Screencasts) aufzunehmen.

In dieser Anleitung erfahren Sie, wie Sie sowohl die interaktive Benutzeroberfläche als auch die geeigneten Tastenkombinationen zum Erfassen Ihres Bildschirminhalts verwenden.

## Verwendung der interaktiven Screenshot-Benutzeroberfläche

Am einfachsten gelingt der Einstieg mit dem interaktiven Overlay, mit dem Sie die volle Kontrolle darüber haben, was und wie Sie etwas aufnehmen.

1. \*\*Starten Sie das Tool: \*\* Drücken Sie die Taste `Print Screen` (oft mit `PrtSc` bezeichnet) auf Ihrer Tastatur. Der Bildschirm wird abgedunkelt und die Screenshot-Benutzeroberfläche wird angezeigt.

2. \*\*Die Benutzeroberfläche verstehen: \*\* das Bedienfeld in der Mitte des Bildschirms besteht aus drei Hauptbereichen:
   - \*\*Aufnahmemodus: \*\* Links können Sie auswählen, ob Sie einen rechteckigen `Bereich`, den gesamten `Bildschirm` oder ein bestimmtes `Fenster` aufnehmen möchten.
   - \*\*Aktionsumschalter: \*\* in der Mitte können Sie zwischen dem Aufnehmen eines **Screenshot** (Kamerasymbol) und dem Aufzeichnen eines **Screencast** (Videokamerasymbol) wechseln.
   - \*\*Aufnahme-Button: \*\* die große, runde Schaltfläche auf der rechten Seite startet die Aufnahme.

### Screenshot-Aufnahme

1. Stellen Sie sicher, dass die Aktionsschaltfläche auf **Screenshot** (das Kamerasymbol) eingestellt ist.
2. Wählen Sie Ihren Aufnahmemodus: `Region`, `Screen` oder `Window`.
3. Klicken Sie auf die runde **Capture**-Schaltfläche.

Standardmäßig wird das Screenshot-Bild automatisch im Verzeichnis `Pictures/Screenshots` in Ihrem Home-Verzeichnis gespeichert.

### Screencast-Aufnahme

1. Stellen Sie den Aktionsschalter auf **Screencast** (das Videokamerasymbol).
2. Wählen Sie den Bereich aus, den Sie aufzeichnen möchten (`Region` oder `Screen`).
3. Klicken Sie auf die runde **Capture**-Schaltfläche, um die Aufnahme zu starten.

In der oberen rechten Ecke Ihres Bildschirms erscheint ein roter Punkt zusammen mit einem Timer, der anzeigt, dass die Aufnahme aktiv ist. Klicken Sie auf den roten Punkt, um anzuhalten. Das Video wird automatisch als `.webm`-Datei im Verzeichnis `Videos/Screencasts` in Ihrem Benutzerordner gespeichert.

## Tastenkombinationen für fortgeschrittene Benutzer

Für noch schnellere Bedienung bietet GNOME eine Reihe direkter Tastenkombinationen, die die interaktive Benutzeroberfläche umgehen.

| Tastaturkürzel         | Zweck                                                                                     |
| ---------------------- | ----------------------------------------------------------------------------------------- |
| ++print-screen++       | Öffnet die interaktive Screenshot-Benutzeroberfläche.                     |
| ++alt+print-screen++   | Erstellt unmittelbar einen Screenshot des aktuell aktiven Fensters.       |
| ++shift+print-screen++ | Beginnt mit der Auswahl eines rechteckigen Bereichs für einen Screenshot. |
| ++ctrl+alt+shift+"R"++ | Startet und stoppt eine Vollbildaufnahme.                                 |

### Der Modifikator `Copy to Clipboard`

Dies ist eine leistungsstarke Produktivitätsfunktion. Durch Hinzufügen der Taste ++ctrl++ zu einer der Screenshot-Tastenkombinationen wird das aufgenommene Bild direkt in die Zwischenablage kopiert, anstatt in einer Datei gespeichert zu werden. Dies eignet sich perfekt, um schnell einen Screenshot in eine andere Anwendung einzufügen, beispielsweise in ein Dokument oder ein Chatfenster.

- \++ctrl+print-screen++:
  Öffnet die interaktive Benutzeroberfläche, aber die Aufnahme wird in die Zwischenablage kopiert.
- \++ctrl+alt+print-screen++:
  Kopiert einen Screenshot des aktiven Fensters in die Zwischenablage.
- \++ctrl+shift+print-screen++:
  Kopiert einen Screenshot des ausgewählten Bereichs in die Zwischenablage.

Das integrierte Screenshot- und Screencast-Tool von GNOME ist ein perfektes Beispiel für elegantes und effizientes Design und bietet sowohl eine einfache, leicht verständliche Benutzeroberfläche für neue Benutzer als auch einen schnellen, tastenkürzelbasierten Arbeitsablauf für fortgeschrittene Benutzer.
