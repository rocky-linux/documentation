---
title: Terminator – ein Terminal Emulator
author: Andrew Scott
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.4
---

!!! warning "Vorläufig abwarten der Verfügbarkeit"

```
Diese Anleitung funktioniert nicht für Rocky Linux 10. Der Grund dafür ist, dass EPEL Terminator nicht für RL 10 kompiliert hat. Es *könnte* sein, dass es noch kompiliert wird, allerdings stagniert das Terminator-Projekt seit dem Umzug zu GitHub im Jahr 2020 und wird kaum weiterentwickelt. Das Dokumentationsteam testet das Paket noch eine Weile, um zu sehen, ob es installierbar wird, kann diese Seite aber gegebenenfalls später löschen.
```

## Einleitung

Terminator ist ein auf GNOME Terminal basierender Terminal-Emulator, der erweiterte Funktionen wie Terminal-Felder, das Gruppieren von Terminals und das Speichern Ihrer bevorzugten Layouts unterstützt.

## Voraussetzungen

- Sie besitzen eine Rocky Linux-Workstation oder einen Server mit grafischer Benutzeroberfläche
- Sie sind ein Administrator mit `sudo`-Berechtigungen

## Installation von Terminator

Terminator befindet sich im Repository `Extra Packages for Enterprise Linux` (EPEL), das bei einer Neuinstallation nicht verfügbar ist. Also müssen wir zuerst EPEL zu Rocky Linux hinzufügen.

- Schritt 1 (optional): Aktivieren Sie das CodeReady Builder (CRB)-Repository

```bash
sudo dnf config-manager --set-enabled crb
```

Obwohl CRB für Terminator nicht unbedingt notwendig ist, stellt es Abhängigkeiten für einige der Pakete in EPEL bereit, was nützlich sein kann, wenn Sie planen, in Zukunft auf dieses Repository zurückzugreifen.

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

Standardmäßig unterscheidet sich Terminator nicht wesentlich vom Standard-GNOME-Terminal. Es sieht _noch_ spartanischer aus als die Standardversion.

![Default layout of Terminator](images/terminator-01.png)

Um mit der Anpassung Ihres neuen Terminals zu beginnen, öffnen Sie das Kontextmenü, indem Sie mit der rechten Maustaste irgendwo auf den Hintergrund klicken.

![Terminator context menu](images/terminator-02.png)

Von diesem Menü aus können Sie das Fenster teilen, neue Registerkarten öffnen und das Layout wechseln. Über das Untermenü `Preferences` können Sie auch das Design anpassen. Es lohnt sich möglicherweise, sich etwas Zeit zu nehmen, um sich mit den verfügbaren Optionen vertraut zu machen, da viele Einstellungen über den Rahmen dieses Handbuchs hinausgehen.

Für diejenigen, die ihre Hand nicht gerne zwischen Tastatur und Maus hin- und herbewegen, stehen auch mehrere Tastenkombinationen zur Verfügung. Beispielsweise teilt ++shift+ctrl+"O"++ das Fenster horizontal in mehrere Terminals auf. Darüber hinaus werden das mehrmalige Aufteilen des Fensters und die Neuanordnung per Drag & Drop unterstützt.

![Terminator window with 3 split terminals](images/terminator-03.png)

Schließlich kann es auch nützlich sein, eine Tastenkombination zum Öffnen Ihres neuen Terminals einzurichten. Dazu öffnen Sie zunächst das Menü `Settings`. Sie können auf das Menü auf verschiedene Arten zugreifen. Für diese Anleitung klicken Sie mit der rechten Maustaste auf den Desktop und dann mit der linken Maustaste auf `Settings`.

![Desktop context menu with "Settings" highlighted](images/terminator-04.png)

Navigieren Sie von hier aus zum Abschnitt `Keyboard`, indem Sie das Menü auf der linken Seite verwenden, und klicken Sie dann unten auf `Customize Shortcuts`.

![GNOME Settings Keyboard Menu](images/terminator-05.png)

Wenn Sie zum ersten Mal eine benutzerdefinierte Verknüpfung festlegen, wird eine Schaltfläche mit der Bezeichnung `Add Shortcut` angezeigt. Andernfalls wird Ihnen unten eine Liste Ihrer Tastenkombinationen mit einem Pluszeichen angezeigt. Klicken Sie auf die für Ihre Situation zutreffende Option, um das Dialogfeld `Add Custom Shortcut` zu öffnen. Geben Sie im Feld _Name_ eine leicht zu merkende Bezeichnung für Ihre Verknüpfung ein. Geben Sie für das Feld _Command_ den Namen unseres Programms ein: `terminator`. Klicken Sie anschließend auf `Set Shortcut`, um Ihre neue Tastenkombination festzulegen.

![Add Custom Shortcut dialog](images/terminator-06.png)

Obwohl ++ctrl+alt+"T"++ die traditionelle Wahl ist, können Sie jede beliebige Kombination wählen. Sie können den Namen und die Tastenkombination der Verknüpfung später jederzeit aktualisieren. Um Ihre Verknüpfung zu speichern, klicken Sie oben rechts im Dialogfeld `Add Custom Shortcut` auf `Add`.

![Add Custom Shortcut dialog completed for Terminator](images/terminator-07.png)

## Fazit

Terminator ist ein leistungsstarker Terminal-Emulator sowohl für normale als auch für erfahrene Benutzer. Diese Beispiele stellen nur einen kleinen Teil der Fähigkeiten von `Terminator` dar. Dieser Leitfaden bietet einen Überblick über die Installationsschritte für Rocky Linux. Eine vollständige Erklärung der Funktionen von Terminator finden Sie in der [Dokumentation](https://gnome-terminator.readthedocs.io/en/latest/).
