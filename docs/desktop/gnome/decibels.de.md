---
title: Decibels — Audio Player
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - audio
  - flatpak
---

## Einleitung

**Decibels** ist ein moderner und eleganter Audioplayer für den GNOME-Desktop. Es basiert auf einer Philosophie der Einfachheit und ist darauf ausgelegt, eine Sache außergewöhnlich gut zu machen: Audiodateien abzuspielen.

Im Gegensatz zu vollwertigen Musikbibliothek-Anwendungen wie Rhythmbox verwaltet Decibels keine Musiksammlung. Stattdessen konzentriert es sich darauf, ein sauberes, unkompliziertes Erlebnis beim Abspielen einzelner Sounddateien zu bieten. Das charakteristische Merkmal ist die übersichtliche Wellenformdarstellung, die eine einfache und präzise Navigation durch die Audiospur ermöglicht.

Dies macht es zum perfekten Tool, um schnell einen heruntergeladenen Podcast, eine Sprachnotiz oder ein neues Lied anzuhören, ohne den Aufwand des Importierens von Dateien in eine Bibliothek.

## Installation

Die empfohlene Methode zur Installation von Decibels auf Rocky Linux ist als Flatpak aus dem Flathub-Repository. Mit dieser Methode stellen Sie sicher, dass Sie über die neueste Version der Anwendung verfügen, die vom Rest Ihres Systems in einer Sandbox getrennt ist.

### 1. Flathub Aktivierung

Bitte stellen Sie zunächst sicher, dass Flatpak installiert und die Flathub-Remote auf Ihrem System konfiguriert ist.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

!!! note
Möglicherweise müssen Sie sich abmelden und erneut anmelden, damit Flatpak-Anwendungen in der GNOME-Aktivitätenübersicht angezeigt werden.

### 2. Decibels Installation

Sobald Flathub aktiviert ist, können Sie Decibels mit einem einzigen Befehl installieren:

```bash
flatpak install flathub org.gnome.Decibels
```

## Grundlegende Verwendung

Nach der Installation können Sie Decibels über die GNOME-Aktivitätenübersicht starten, indem Sie nach `Decibels` suchen.

So spielen Sie eine Datei ab:

1. Starten Sie die Anwendung. Ein sauberes, schlichtes Fenster empfängt Sie.
2. Klicken Sie auf die Schaltfläche **`Open a File...`** in der Mitte des Fensters.
3. Navigieren Sie mit der Dateiauswahl zu einer Audiodatei auf Ihrem System und wählen Sie sie aus (z. B. eine MP3-, FLAC-, OGG- oder WAV-Datei).
4. Die Datei wird geöffnet und ihre Wellenform wird angezeigt. Die Wiedergabe beginnt automatisch.

## Hauptmerkmale

Decibels ist zwar einfach, bietet aber einige wertvolle Funktionen:

- \*\*Wellenform-Navigation: \*\* anstelle eines einfachen Fortschrittsbalkens zeigt `Decibels` die Wellenform des Audios an. Sie können an beliebiger Stelle in der Wellenform klicken, um direkt zu diesem Teil des Musikstücks zu springen.
- \*\*Steuerung der Wiedergabegeschwindigkeit: \*\* mit einem Steuerelement in der unteren rechten Ecke können Sie die Wiedergabegeschwindigkeit anpassen. Dies ist ideal, um Podcasts zu beschleunigen oder Audio für die Transkription zu verlangsamen.
- **Schnellsprungtasten:** Mit speziellen Tasten können Sie in 10-Sekunden-Intervallen vor- oder zurückspringen, sodass Sie eine verpasste Phrase ganz einfach erneut anhören können.

Decibels ist eine ausgezeichnete Wahl für alle, die eine einfache, elegante und moderne Anwendung zum Abspielen einzelner Audiodateien auf dem GNOME-Desktop benötigen.
