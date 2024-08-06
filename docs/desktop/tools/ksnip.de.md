---
title: Screenshots mit Ksnip mit Anmerkungen versehen
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - Desktop
  - Screenshot Utility
---

## Voraussetzungen

- Rocky 9.4 Workstation
- `sudo`-Berechtigungen

## Einleitung

`Ksnip` ist ein Dienstprogramm mit zahlreichen Funktionen und Tools zum Kommentieren von Screenshots. Der Schwerpunkt dieser Anleitung liegt auf der Installation von Ksnip und seinen Beschriftung-Tools.

## Ksnip-Installation

Ksnip erfordert das EPEL-Repository. Wenn Sie EPEL nicht aktiviert haben, können Sie dies folgendermaßen erreichen:

```bash
sudo dnf install epel-release
```

Dann System-Update ausführen:

```bash
sudo dnf update -y
```

Nun Ksnip installieren:

```bash
sudo dnf install ksnip -y
```

## Bild Öffnen

1. Ksnip Starten
2. Klicke `File > Open`
3. Wählen Sie das Bild aus, das Sie kommentieren möchten

![ksnip](images/ksnip.png)

## Mit `Ksnip` ein Screenshot mit Anmerkungen versehen

`Ksnip` verfügt über praktische und intuitive Tools zum Kommentieren von Screenshots.  Unten links im Bild sind die im Folgenden beschriebenen Optionen aufgeführt.

![ksnip\_open](images/ksnip_image_opened.png)

| Option | Tool               | Beschreibung                                                                                                                                                                                                                                                                           |
| ------ | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1      | `Select`           | das Werkzeug wird verwendet, um eine Auswahl zu treffen. Klicken Sie auf ein Element, um es auszuwählen, oder klicken Sie und ziehen Sie, um eine Auswahl zu treffen.                                                                                  |
| 2      | `Duplicate`        | das Werkzeug wird zum Duplizieren einer Auswahl verwendet. Klicken und ziehen Sie, um eine Auswahl zu treffen. Dann klicken und ziehen Sie dann die Auswahl, um sie zu verschieben oder weiter zu transformieren.                      |
| 3a     | `Arrow`            | das Standard Arrow-Tool, mit dem Sie durch Klicken und Ziehen einen Pfeil erstellen und von einer Position zu einer neuen Position bewegen können                                                                                                                                      |
| 3b     | `Double Arrow`     | die zweite Arrow-Option erreichen Sie, indem Sie auf den Abwärtspfeil neben dem Arrow-Tool klicken. Wie der Werkzeug-Name vermuten lässt, verfügt das Tool an beiden Endpunkten über einen Pfeil.                                                      |
| 3c     | `Line`             | die dritte Option erreichen Sie, indem Sie auf den Abwärtspfeil neben dem Arrow-Tool klicken. Es ersetzt Pfeile durch eine einfache Linie.                                                                                                             |
| 4      | `Pen`              | macht Striche, die an einen Stift erinnern. Klicken Sie und bewegen Sie den Mauszeiger über den Screenshot, um den Stift zu verwenden. ^1^                                                                                                             |
| 5a     | `Marker Pen`       | das Standard-Marker-Tool erzeugt Striche, die einem Textmarker ähneln. Um den Markierungsstift zu verwenden, halten Sie die Maustaste gedrückt und ziehen Sie den Cursor über den Screenshot. ^1^                                                      |
| 5b     | `Marker Rectangle` | die zweite Marker-Option erreichen Sie, indem Sie auf den Abwärtspfeil neben dem Marker-Tool klicken. Wenn Sie mit der linken Maustaste klicken und den Cursor ziehen, füllt das Marker-Rectangle-Werkzeug das aus der Auswahl gebildete Rechteck. ^1^ |
| 5c     | `Marker Elipse`    | die dritte Marker-Option erreichen Sie, indem Sie auf den Abwärtspfeil neben dem Marker-Tool klicken. Wenn Sie mit der linken Maustaste klicken und den Cursor ziehen, füllt das Marker-Ellipse-Werkzeug die aus der Auswahl erstellte Ellipse. ^1^    |
| 6a     | `Text`             | Mit dem Standard-Textwerkzeug können Sie den Screenshot mit Text kommentieren. ^1^                                                                                                                                                                                     |
| 6b     | `Text Pointer`     | die zweite Textoption erreichen Sie, indem Sie auf den Abwärtspfeil neben dem Textwerkzeug klicken. Es wird ein Zeiger angehängt, um die Aufmerksamkeit auf den Text zu lenken. ^1^                                                                    |
| 6c     | `Text Arrow`       | die dritte Textoption erreichen Sie, indem Sie auf den Abwärtspfeil neben dem Textwerkzeug klicken. Um die Aufmerksamkeit auf den Text zu lenken, wird ein Pfeil angebracht. ^1^                                                                       |
| 7a     | `Number`           | das Standard-Number-Tool fügt eine Zahl hinzu, um die Aufmerksamkeit auf den Screenshot zu lenken und ihn mit Zahlen zu kommentieren. ^1^                                                                                                                              |
| 7b     | `Number Pointer`   | die zweite Option erreichen Sie, indem Sie auf den Abwärtspfeil neben dem Number-Tool klicken. Fügt eine Zahl mit einem Zeiger hinzu, um einen Screenshot ergänzend zu kommentieren. ^1^                                                               |
| 7c     | `Number Arrow`     | die dritte Option erreichen Sie durch Klicken auf den Abwärtspfeil neben dem Number-Tool. Fügt eine Zahl mit einem Pfeil hinzu, um einen Screenshot ergänzend zu kommentieren. ^1^                                                                     |
| 8a     | `Blur`             | das standardmäßige Blur-Tool, mit dem Sie durch Linksklicken und Ziehen Teile des Screenshots weichzeichnen können.                                                                                                                                                    |
| 8b     | `Pixelate`         | die zweite Option des Weichzeichner-Werkzeugs erreichen Sie, indem Sie auf den Abwärtspfeil neben dem Blur-Tool klicken. Durch Linksklick und Ziehen können Sie überall auf dem Screenshot das Bild verpixeln.                                         |
| 9a     | `Rectangle`        | mit dem standardmäßigen Rectangle Tool können Sie durch Klicken und Ziehen ein Rechteck erstellen. ^1^                                                                                                                                                                 |
| 9b     | `Ellipse`          | die zweite Option des Rechteck-Werkzeugs, die Sie erreichen, indem Sie auf den Abwärtspfeil neben dem Rectangle Tool klicken. Ermöglicht Ihnen, durch Klicken und Ziehen eine Ellipse auf dem Bildschirm zu erstellen. ^1^                             |
| 10     | `Sticker`          | platziert einen Sticker oder Emoji auf einem Screenshot. Durch Auswahl des Tools und klicken wird der Sticker platziert.                                                                                                                               |

## Zusammenfassung

Ksnip ist ein ausgezeichnetes Dienstprogramm zum Kommentieren von Screenshots. Es können auch Screenshots erstellt werden. Der Schwerpunkt dieses Handbuchs liegt jedoch auf den Kommentierung-Funktionen und -Tools, die Ksnip bereitstellt.

Sehen Sie sich das [Ksnip GitHub Repo](https://github.com/ksnip/ksnip){target="_blank"} an, um mehr über dieses hervorragende Screenshot-Dienstprogramm zu erfahren.

**1.** Für jedes der Werkzeuge, deren Beschreibung mit ==diesem hochgestellten Zeichen== (^1^) beginnt, sind nach der Werkzeugauswahl im oberen Menü verschiedene Befehlsoptionen verfügbar. Diese ändern die Deckkraft, den Rahmen, die Schriftart, den Schriftstil und andere Attribute.
