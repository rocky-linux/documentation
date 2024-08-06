---
title: GNOME Shell Erweiterungen
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.4
tags:
  - Desktop
  - gnome
---

## Einleitung

Zitat aus der [GNOME-Website](https://extensions.gnome.org/about/){:target="_blank"}:

> GNOME Shell stellt grundlegende Benutzeroberflächenfunktionen für GNOME bereit, wie z.B. das Wechseln zwischen Fenstern und das Starten von Anwendungen. Zu den von GNOME Shell bereitgestellten Elementen der Benutzeroberfläche gehören das Panel oben auf dem Bildschirm, die Aktivitätenübersicht und die Nachrichtenleiste unten auf dem Bildschirm."
> GNOME-Shell-Erweiterungen sind kleine Codeteile, die von Drittanbietern geschrieben werden und die Funktionsweise von GNOME ändern. (Wenn Sie mit Chrome-Erweiterungen oder Firefox-Add-ons vertraut sind, sind GNOME-Shell-Erweiterungen diesen ähnlich.) Sie können GNOME Shell-Erweiterungen auf dieser Website finden und installieren.
> Die Erstellung von Erweiterungen erfolgt außerhalb des normalen GNOME-Design- und Entwicklungsprozesses. Sie werden von ihren Autoren und nicht von der GNOME-Community unterstützt. Einige Funktionen, die zunächst als Erweiterungen implementiert wurden, finden möglicherweise ihren Weg in zukünftige Versionen von GNOME.

## Voraussetzungen

- Eine Rocky Linux-Workstation oder ein Server mit einer GUI-Installation, die GNOME verwendet.

## GNOME Erweiterungen Installieren

GNOME-Erweiterungen werden über das `gnome-shell`-Paket bereitgestellt, das im `appstream`-Repository verfügbar ist. Wird wie folgt installiert:

```bash
sudo dnf install gnome-shell
```

Die Installation umfasst alle benötigten Abhängigkeiten.

## Browserintegration installieren

GNOME-Extensions verfügt über eine Softwarebibliothek, die auf der Website `gnome.extensions.org` verfügbar ist. Dort können Sie Erweiterungen direkt von der Website installieren. Um dies zu erreichen, müssen Ihr Browser und die GNOME-Erweiterungen eine Verbindung ermöglichen.

```bash
sudo dnf install chrome-gnome-shell
```

[Installations-Hanbuch](https://gnome.pages.gitlab.gnome.org/gnome-browser-integration/pages/installation-guide.html){target="_blank"}

## Bestimmen der GNOME-Shell-Version

Die Browsererweiterung, die zur Erleichterung der Erweiterungsinstallation von `extensions.gnome.org` verwendet wird, sollte die Version der GNOME-Shell, die auf Ihrem System aktuell ausgeführt wird, automatisch erkennen.

Wenn Sie eine lokale Installation durchführen möchten, müssen Sie die Erweiterung mit der richtigen GNOME-Shell-Version herunterladen.

```bash
gnome-shell --version
```

## Installation einer Erweiterung

In diesem Beispiel installieren wir die beliebte Erweiterung `dash-to-dock`.

1. Gehen Sie zur [Webseite der Dash-to-Dock-Erweiterung](https://extensions.gnome.org/extension/307/dash-to-dock/){target="_blank"}
2. Erweiterung von „aus“ auf „ein“ umschalten
   ![Erweiterung umschalten](images/gnome_extensions_images/gnome-shell-extensions-toggle-btn.webp)
3. Wenn Sie zur Installation der Erweiterung aufgefordert werden, klicken Sie auf `yes`.

## Installierte Erweiterungen verwalten

GNOME-Erweiterungen werden auf `gnome.extensions.org` installiert und verwaltet.

Um Ihre GNOME-Erweiterungen zu verwalten, gehen Sie zunächst zu https://extensions.gnome.org/local/

![Manage GNOME extensions](images/gnome_extensions_images/gnome-shell-installed-extensions.webp)

Auf der Seite finden Sie eine Liste der installierten Erweiterungen. Sie können jedes dieser Elemente ein- oder ausschalten. Sie können die Shell-Einstellungen auch mithilfe des Umschaltknopfs auf einer der beiden verfügbaren Menüoptionen „Alle Erweiterungen deaktivieren“ oder „Versionsvalidierung deaktivieren“ konfigurieren.

## Zusammenfassung

GNOME Extensions ist ein hervorragendes Tool zum Hinzufügen zusätzlicher Funktionen und Anpassen Ihrer GNOME-Desktopumgebung.
