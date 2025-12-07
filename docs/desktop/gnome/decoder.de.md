---
title: Decoder – QR-Code-Tool
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - QR-Code
  - flatpak
---

## Scan und Generierung von QR-Codes

**Decoder** ist ein einfaches und elegantes Dienstprogramm für den GNOME-Desktop, das für die Arbeit mit QR-Codes entwickelt wurde. In einer Welt, in der QR-Codes für alles Mögliche verwendet werden, vom Teilen von WLAN-Passwörtern bis zum Zugriff auf Restaurantmenüs, ist ein spezielles Tool für deren Handhabung unerlässlich.

Decoder bietet zwei Hauptfunktionen in einer übersichtlichen, einfachen Schnittstelle:

1. **Scannen:** Dekodiert QR-Codes mithilfe der Webcam Ihres Computers oder einer Bilddatei.
2. **Generierung:** Erstellt QR-Codes aus jedem von Ihnen bereitgestellten Text.

Durch die enge Integration in die GNOME-Desktopumgebung fühlt es sich wie ein natürlicher Bestandteil des Betriebssystems an.

## Installation

Die empfohlene Methode zur Installation von Decoder auf Rocky Linux ist die Installation als Flatpak-Paket aus dem Flathub-Repository. Diese Methode gewährleistet, dass Sie die neueste Version der Anwendung in einer sicheren, isolierten Umgebung erhalten.

### 1. Flathub Aktivierung

Falls Sie dies noch nicht getan haben, stellen Sie bitte sicher, dass Flatpak installiert und Flathub-Remote auf Ihrem System konfiguriert ist.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### 2. Decoder installieren

Sobald Flathub aktiviert ist, können Sie Decoder mit einem einzigen Befehl installieren:

```bash
flatpak install flathub com.belmoussaoui.Decoder
```

## So verwenden Sie `Decoder`

Nach der Installation können Sie Decoder über die GNOME-Aktivitätenübersicht starten.

### Scannen eines QR-Codes

Beim ersten Öffnen von `Decoder` ist dieser sofort zum Scannen bereit. Sie haben zwei Möglichkeiten:

- **Scannen mit der Kamera:** Klicken Sie auf das Kamerasymbol oben links. Es öffnet sich ein Fenster, das das Bild Ihrer Webcam anzeigt. Richten Sie die Webcam auf einen QR-Code, um ihn in Echtzeit zu scannen.
- **Scannen aus Bild:** Klicken Sie auf das Bildsymbol oben rechts. Dadurch öffnet sich ein Dateiauswahldialog, in dem Sie ein gespeichertes Bild oder einen Screenshot auswählen können, der einen QR-Code enthält.

Sobald ein Code gescannt wurde, analysiert Decoder dessen Inhalt. Wenn der Code eine Website-URL enthält, wird der Link mit einer Schaltfläche angezeigt, über die Sie die Website in Ihrem Standard-Webbrowser öffnen können. Wenn es sich um Klartext handelt, wird der Text zusammen mit einer praktischen Schaltfläche zum Kopieren in die Zwischenablage angezeigt.

### Einen QR-Code generieren

Um Ihren eigenen QR-Code zu erstellen, klicken Sie auf die Schaltfläche `Generate` oben im Decoder-Fenster.

1. Es erscheint ein Textfeld. Geben Sie den zu kodierenden Text in dieses Feld ein oder fügen Sie ihn dort ein.
2. Während Sie tippen, wird rechts sofort ein QR-Code generiert, der Ihren Text repräsentiert.
3. Sie können dann auf die Schaltfläche **`Save as Image...`** klicken, um den QR-Code als PNG-Datei zu speichern, oder auf die Schaltfläche **`Copy to Clipboard`** klicken, um ihn in andere Anwendungen einzufügen.

Decoder ist ein perfektes Beispiel für die GNOME-Designphilosophie: ein einfaches und elegantes Werkzeug, das eine Aufgabe effektiv erfüllt.
