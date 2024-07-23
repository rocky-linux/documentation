---
title: Screenshots mit Ksnip mit Anmerkungen versehen
author: Joseph Brinkman
contributors: Steven Spencer
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

![ksnip\_open](images/ksnip_image_opened.png)

## Ein Bild mit Ksnip mit Anmerkungen versehen

`Ksnip` verfügt über praktische und intuitive Tools zum Kommentieren von Screenshots.  Unten links im Bild sind die im Folgenden beschriebenen Optionen aufgeführt.

Das Werkzeug `Select`: wird verwendet, um eine Auswahl zu treffen. Klicken Sie auf ein Element, um es auszuwählen, oder klicken Sie und ziehen Sie, um eine Auswahl zu treffen.

Das Werkzeug `Duplicate`: wird zum Duplizieren einer Auswahl verwendet. Klicken und ziehen Sie, um eine Auswahl zu treffen. Klicken und ziehen Sie dann die Auswahl, um sie zu verschieben oder weiter zu transformieren.

Das Werkzeug `Arrow`: wird zum Erstellen von Pfeilen verwendet. Klicken und ziehen Sie, um einen Pfeil zu erstellen.

Das Werkzeug `Double Arrow` (auswählbar durch Klicken auf den Abwärtspfeil neben dem Pfeil): wird zum Erstellen doppelseitiger Pfeile verwendet. Klicken und ziehen Sie, um einen doppelseitigen Pfeil zu erstellen.

Das Werkzeug `Line`: wird zum Erstellen gerader Linien verwendet. Klicken und ziehen Sie, um eine Linie zu erstellen.

Das `Pen`-Werkzeug: wird verwendet, um Striche zu zeichnen, die einem Stift ähneln. Klicken Sie und bewegen Sie den Mauszeiger über den Screenshot, um den Stift zu verwenden. In der oberen Symbolleiste gibt es Anpassungsoptionen, mit denen Sie Stil und Strich des Stifts ändern können.

Das Werkzeug `Marker Pen`: wird verwendet, um Striche zu erstellen, die einem Textmarker ähneln. Um den Markierungsstift zu verwenden, halten Sie die Maustaste gedrückt und ziehen Sie den Cursor über den Screenshot. Es gibt Anpassungen zum Ändern der Deckkraft in der oberen Symbolleiste.

Das Werkzeug `Marker Rectangle` ist das Markierungsstift-Werkzeug, aber wenn Sie klicken und den Cursor ziehen, füllt das Markierungsrechteck-Werkzeug die rechteckige Auswahl. Es gibt Anpassungen zum Ändern der Deckkraft in der oberen Symbolleiste.

Das Werkzeug `Marker Ellipse` ist das Markierungsstift-Werkzeug, aber wenn Sie mit der linken Maustaste klicken und den Cursor ziehen, füllt das Markierungsellipsen-Werkzeug die aus der Auswahl erstellte Ellipse. Es gibt Anpassungen zum Ändern der Deckkraft in der oberen Symbolleiste.

Das Werkzeug `Text`: wird verwendet, um einen Screenshot mit Text zu kommentieren. Klicken Sie auf eine beliebige Stelle im Bild und beginnen Sie mit der Eingabe, um das Textwerkzeug zu verwenden. In der oberen Symbolleiste können Sie Rahmen, Farbe, Schriftfamilie, Schriftgröße, Schriftstil und Deckkraft Ihres Textes anpassen.

Das Tool `Text Pointer`: wird verwendet, um einen Screenshot mit Text zu kommentieren, der an einen Zeiger angehängt ist. Der Zeiger soll die Aufmerksamkeit auf den Text lenken, ähnlich wie das `Text Arrow`-Werkzeug.

Das Werkzeug `Text Arrow`: wird verwendet, um einen Screenshot mit Text zu kommentieren, der an einen Pfeil angehängt ist. Der Zeiger soll die Aufmerksamkeit auf den Text lenken, ähnlich wie das `Text Pointer`-Werkzeug.

Das `Number`-Werkzeug: wird verwendet, um einen Screenshot mit einer numerischen Form zu kommentieren. Klicken Sie auf eine beliebige Stelle im Bild, um eine numerische Form zu platzieren. In der oberen Symbolleiste sind Anpassungsmöglichkeiten zum Ändern von Farbe, Breite und Deckkraft vorhanden.

Das Werkzeug `Number Pointer`: wird verwendet, um einen Screenshot mit einer numerischen Form zu kommentieren, die an einen Zeiger angehängt ist. Klicken Sie auf eine beliebige Stelle im Bild, um eine numerische Form zu platzieren, die an einen Zeiger gebunden ist. In der oberen Symbolleiste sind Anpassungsmöglichkeiten zum Ändern von Farbe, Breite und Deckkraft vorhanden.

Das Werkzeug `Number Arrow`: wird verwendet, um einen Screenshot mit einer numerischen Form zu kommentieren, die an einem Zeiger angebracht ist. Klicken Sie irgendwo auf das Bild, um eine numerische Form an einem Pfeil zu platzieren. In der oberen Symbolleiste sind Anpassungsmöglichkeiten zum Ändern von Farbe, Breite und Deckkraft vorhanden.

Das `Blur`-Werkzeug: Wird zum Weichzeichnen einer Auswahl verwendet. Klicken Sie mit der linken Maustaste und ziehen Sie an eine beliebige Stelle im Screenshot, um eine Auswahl unscharf zu machen.

Das Werkzeug `Pixelate`: wird zum Verpixeln einer Auswahl verwendet. Klicken Sie mit der linken Maustaste und ziehen Sie an einer beliebigen Stelle auf dem Screenshot, um eine Auswahl zu verpixeln.

Das Werkzeug `Rectangle`: wird verwendet, um aus einer Auswahl ein Rechteck zu erstellen. Klicken Sie mit der linken Maustaste und ziehen Sie an einer beliebigen Stelle auf dem Screenshot, um eine rechteckige Auswahl zu treffen. In der oberen Symbolleiste sind Anpassungsmöglichkeiten zum Ändern von Farbe, Breite und Deckkraft vorhanden.

Das Werkzeug `Ellipse`: wird verwendet, um aus einer Auswahl eine Ellipse zu erstellen. Klicken Sie mit der linken Maustaste und ziehen Sie an einer beliebigen Stelle im Screenshot, um eine Ellipse zu platzieren. In der oberen Symbolleiste sind Anpassungsmöglichkeiten zum Ändern von Farbe, Breite und Deckkraft vorhanden.

Das Tool `Sticker`: wird verwendet, um einen Sticker oder ein Emoji auf einem Screenshot zu platzieren. Durch Auswahl des Tools und klicken wird der Sticker platziert.

## Conclusion

Ksnip ist ein ausgezeichnetes Dienstprogramm zum Kommentieren von Screenshots. Es können auch Screenshots erstellt werden. Der Schwerpunkt dieses Handbuchs liegt jedoch auf den Kommentierung-Funktionen und -Tools, die Ksnip bereitstellt.

Sehen Sie sich das [Ksnip GitHub Repo](https://github.com/ksnip/ksnip){target="_blank"} an, um mehr über dieses hervorragende Screenshot-Dienstprogramm zu erfahren.
