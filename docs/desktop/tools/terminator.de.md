---
title: Terminator ein Terminal Emulator
author: Andrew Scott
contributors: Steven Spencer
tested with: 9.4
---

## Einleitung

Terminator ist ein auf GNOME Terminal basierender Terminal-Emulator, der erweiterte Funktionen wie viele Terminal-Felder, das Gruppieren von Terminals und das Speichern Ihrer bevorzugten Layouts unterstützt.

## Voraussetzungen

- Sie haben eine Rocky Linux-Workstation oder einen Server mit GUI
- Sie sind ein Administrator mit `sudo`-Berechtigungen

## Installation von Terminator

Terminator befindet sich im Repository „Extra Packages for Enterprise Linux“ (EPEL), das bei einer Neuinstallation nicht verfügbar ist. Also müssen wir zuerst EPEL zu Rocky Linux hinzufügen.

- Schritt 1 (optional): Aktivieren Sie das CodeReady Builder (CRB)-Repository

```bash
sudo dnf config-manager --set-enabled crb
```

Obwohl es für Terminator nicht unbedingt erforderlich ist, stellt CRB Abhängigkeiten für einige der Pakete in EPEL bereit. Es kann daher nützlich sein, wenn Sie planen, sich in Zukunft auf dieses Repository zu verlassen.

- Schritt 2: EPEL-Repository hinzufügen

```bash
sudo dnf install epel-release -y
```

- Schritt 3 (optional, aber dringend empfohlen): Aktualisieren Sie Ihr System

```bash
sudo dnf update -y --refresh
```

- Schritt 4: Terminator Installation

```bash
sudo dnf install terminator -y
```

## Konfiguration

Standardmäßig unterscheidet sich Terminator nicht wesentlich vom Standard-GNOME-Terminal. Tatsächlich sieht es _noch_ spartanischer aus als die Standardversion.

![Default layout of Terminator](images/terminator-01.png)

Um mit der Anpassung Ihres neuen Terminals zu beginnen, öffnen Sie das Kontextmenü, indem Sie mit der rechten Maustaste irgendwo auf den Hintergrund klicken.

![Terminator context menu](images/terminator-02.png)

Von diesem Menü aus können wir das Fenster teilen, neue Registerkarten öffnen und das Layout wechseln. Es ist auch möglich, das Design über das Untermenü `Preferences` anzupassen. Es lohnt sich möglicherweise, sich etwas Zeit zu nehmen, um sich mit den verfügbaren Optionen vertraut zu machen, da viele Einstellungen über den Rahmen dieses Handbuchs hinausgehen.

Für diejenigen, die ihre Hand nicht gerne zwischen Tastatur und Maus hin- und herbewegen, stehen auch mehrere Tastenkombinationen zur Verfügung. Beispielsweise teilt ++shift+ctrl+"O"++ das Fenster horizontal in mehrere Terminals auf. Darüber hinaus werden das mehrmalige Aufteilen des Fensters und die Neuanordnung per Drag & Drop unterstützt.

![Terminator window with 3 split terminals](images/terminator-03.png)

## Zusammenfassung

Terminator ist ein leistungsstarker Terminal-Emulator sowohl für normale als auch für erfahrene Benutzer. Diese Beispiele stellen nur einen kleinen Teil der Fähigkeiten von Terminator dar… Während dieses Handbuch einen Überblick über die Installationsschritte für Rocky Linux bietet, möchten Sie vielleicht einen Blick auf die [Dokumentation](https://gnome-terminator.readthedocs.io/en/latest/) werfen, um eine vollständige Erklärung der Funktionen von Terminator zu erhalten.
