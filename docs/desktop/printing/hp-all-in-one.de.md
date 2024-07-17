---
title: Installation und Einrichtung eines HP All-in-One-Druckers
author: Joseph Brinkman
contributors: Steven Spencer
tested with: 9.4
tags:
  - Desktop
  - printer support
---

## Einleitung

Drucken und Scannen mit einem HP All-in-One-Drucker ist unter Linux dank [HPLIP](https://developers.hp.com/hp-linux-imaging-and-printing/about){target="_blank"} möglich.

Diese Anleitung wurde mit einem HP Deskjet 2700 series getestet.

Unter [Alle unterstützten Drucker](https://developers.hp.com/hp-linux-imaging-and-printing/supported_devices/index){target="_blank"} erfahren Sie, ob das HPLIP-Paket Ihren Drucker unterstützt.

## Download und HPLIP-Installation

HPLIP ist eine Drittanbietersoftware von HP, die die erforderlichen Druckertreiber enthält. Installieren Sie die drei unten aufgeführten Pakete, um vollständige Unterstützung mit einer grafischen Benutzeroberfläche zu erhalten.

```bash
sudo dnf install hplip-common.x86_64 hplip-libs.x86_64 hplip-gui
```

## Printer Setup

Wenn Sie mit der Installation des Druckertreibers fertig sind, sollten Sie Ihren HP All-in-One Drucker zu Ihrer Rocky Workstation hinzufügen können. Stellen Sie sicher, dass der Drucker physisch mit demselben Netzwerk verbunden ist, entweder über WLAN oder eine Direktverbindung. Zu den Einstellungen gehen

Klicken Sie im linken Menü auf ++"Printers"++

Klicken Sie bitte auf ++"Add a Printer"++

Wählen Sie Ihren HP All-in-One Drucker aus.

## Scanner Support

Obwohl Sie mit dem HPLIP-Paket mithilfe von CLI-Befehlen scannen können, wird keine Scanner-App bereitgestellt. Installieren Sie `xsane`, ein benutzerfreundliches Scanner-Dienstprogramm.

```bash
sudo dnf install sane-backends sane-frontends xsane
```

Die Benutzeroberfläche von `xsane` sieht ein wenig ungewöhnlich aus, aber ein einfacher Scan ist unkompliziert. Wenn Sie xsane starten, erscheint ein Fenster mit einer Schaltfläche
\++"Acquire a preview"++,
über die Sie eine Vorschau abrufen können. Dadurch wird ein Vorschaubild eines Scans aufgenommen. Sobald Sie zum Scannen bereit sind, klicken Sie im Hauptmenü auf die Schaltfläche `Start`.

Eine umfassendere `xsane`-Anleitung finden Sie in diesem [Artikel der Fakultät für Mathematik der Universität Cambridge](https://www.maths.cam.ac.uk/computing/printing/xsane){target="_blank"}

## Conclusion

Nach der Installation von `HPLIP` und `xsane` sollten Sie nun auf Ihrem HP All-in-One Drucker drucken und scannen können.
