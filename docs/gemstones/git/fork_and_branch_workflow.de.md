---
title: Git-Workflow für Fork und Branch
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - GitHub
  - git
  - gh
  - git fetch
  - git add
  - git pull
  - git checkout
  - gh repo
---

## Fork und Branch Workflow

Bei diesem Workflow-Typ verzweigen Mitwirkende das Haupt-Repository in ihr eigenes GitHub-Konto, erstellen Feature-Branches für ihre Arbeit und übermitteln dann Beiträge über Pull Requests aus diesen Branches.

Dieses Gemstone führt Sie durch die Einrichtung eines lokalen Repositorys, um zu einem GitHub-Projekt beizutragen. Es beginnt mit der ersten Projektaufspaltung, dem Einrichten eines lokalen und eines Remote-Repositorys, dem Übernehmen von Änderungen und dem Erstellen einer Pull Request (PR) zum Einreichen Ihrer Beiträge.

## Voraussetzungen

- Ein Github-Konto.
- `git` und `GitHub CLI (gh)` sind auf Ihrem System installiert.
- Ein persönlicher Fork des Projekts auf GitHub.

## Prozedur

1. Falls es noch nicht vorhanden ist, erstellen Sie mit dem Dienstprogramm `gh` einen Fork des Projekts. Geben Sie bitte Folgendes ein:

   ```bash
   gh repo fork rocky-linux/documentation --clone=true --remote=true
   ```

   Die in diesem _gh repo fork_-Befehl verwendeten Optionen sind:

   - `--clone=true`: Klont das Fork-Repository auf Ihren lokalen Computer.
   - `--remote=true`: Fügt das ursprüngliche Repository als Remote hinzu, sodass Sie zukünftige Updates synchronisieren können.

2. Navigieren Sie zum lokalen Repository-Verzeichnis. Geben Sie bitte Folgendes ein:

   ```bash
   cd documentation
   ```

3. Überprüfen Sie, ob alle relevanten Remote-Repositorys in Ihrem lokalen Repository ordnungsgemäß konfiguriert wurden. Geben Sie Folgendes ein:

   ```bash
   git remote -vv
   ```

4. Holen Sie sich die neuesten Änderungen vom Upstream-Remote:

   ```bash
   git fetch upstream
   ```

5. Erstellen und checken Sie einen neuen Feature-Branch mit dem Namen `your-feature-branch` aus:

   ```bash
   git checkout -b your-feature-branch
   ```

6. Nehmen Sie Änderungen vor, fügen Sie neue Dateien hinzu und übertragen Sie Ihre Änderungen in Ihr lokales Repository:

   ```bash
   git add .
   git commit -m "Your commit message"
   ```

7. Synchronisieren Sie das Repo mit dem Hauptzweig des Remote-Repos mit dem Namen `upstream`:

   ```bash
   git pull upstream main
   ```

8. Übertragen Sie Push-Änderungen an Ihren Fork\*\*:

   ```bash
   git push origin your-feature-branch
   ```

9. Erstellen Sie abschließend einen Pull Request (PR) mit der CLI-Anwendung `gh`:

   ```bash
   gh pr create --base main --head your-feature-branch --title "Your PR Title" --body "Description of your changes"
   ```

   Die in diesem `gh pr create`-Befehl verwendeten Optionen sind:

   `--base` main: Gibt den Basiszweig im Upstream-Repository an, in dem die Änderungen mit `merge` zusammengeführt werden.
   `--head` your-feature-branch: Gibt den Head-Branch Ihres Forks an, der die Änderungen enthält.
   `--title` "Ihr PR-Titel": Legt den Titel für das Pull Request fest.
   `--body` "Beschreibung Ihrer Änderungen": Bietet eine detaillierte Beschreibung der Änderungen im Pull Request.

## Zusammenfassung

Der Fork-and-Branch-Workflow ist eine weitere gängige Zusammenarbeitstechnik.
Die wichtigsten Schritte sind:

1. Der Fork-and-Branch-Workflow ist eine weitere gängige Zusammenarbeitstechnik.
2. Den Fork klonen: Klonen Sie Ihren Fork für Entwicklungsarbeiten auf Ihren lokalen Computer.
3. Upstream-Remote festlegen: Um über die Änderungen auf dem Laufenden zu bleiben, fügen Sie das ursprüngliche Projekt-Repository als `upstream`-Remote hinzu.
4. Feature Branch erstellen: Erstellen Sie für jede neue Funktion oder Korrektur einen neuen Branch aus dem aktualisierten Main Branch. Der Name der Branch sollte die Funktion oder den Fix beschreiben.
5. Commit der Änderungen: Nehmen Sie Ihre Änderungen vor und `commit`en Sie sie mit klaren und präzisen `Commit`-Nachrichten fest.
6. Mit Upstream synchronisieren: Synchronisieren Sie Ihren Fork und Feature-Branch regelmäßig mit dem Upstream-Main-Branch, um neue Änderungen zu integrieren und `merge`-Konflikte zu reduzieren.
7. Erstellen Sie einen Pull Request (PR): Pushen Sie Ihren Feature-Branch zu Ihrem Fork auf GitHub und öffnen Sie einen PR für das Hauptprojekt. Ihre PR sollte die Änderungen klar beschreiben und auf alle relevanten Probleme verweisen.
8. Auf Feedback reagieren: Arbeiten Sie gemeinsam an der Überprüfung des Feedbacks, bis der PR zusammengeführt oder geschlossen wird.

Vorteile:

- Isoliert die Entwicklungsarbeit auf bestimmte Zweige und hält den Hauptzweig sauber.
- Es erleichtert das Review und die Integration von Änderungen.
- Reduziert das Risiko von Konflikten mit der sich entwickelnden Codebasis des Hauptprojekts.
