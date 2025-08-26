---
title: Feature Branch Workflow in Git
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - git
  - Feature Branch Workflow
  - GitHub
  - gh
  - git fetch
  - git add
  - git pull
  - git checkout
---

## Feature Branch Workflow

Bei diesem beliebten Git-Workflow werden für jede neue Funktion oder Korrektur direkt im Haupt-Repository neue Zweige erstellt.
Es wird normalerweise in Projekten eingesetzt, bei denen Mitwirkende direkten Push-Zugriff auf das Repository haben.

Dieses Gemstone beschreibt den Prozess zum Einrichten eines lokalen Repositorys, um mithilfe des Git Feature Branch Workflow am Projekt `rocky-linux/documentation` zu arbeiten und dazu beizutragen.

Der Benutzer `Rockstar` hat dieses Repository geforkt und wir werden `https://github.com/rockstar/documentation` als Ursprung verwenden.

## Voraussetzungen

- Ein GitHub-Konto und ein Fork des Projekts (z. B. `https://github.com/rockstar/documentation`).
- `git` und `GitHub CLI (gh)` bereits installiert.

## Prozedur

1. Falls noch nicht geschehen, klonen Sie Ihren Fork:

   ```bash
   git clone https://github.com/rockstar/documentation.git
   cd documentation
   ```

2. Fügen Sie das Upstream-Remote hinzu:

   ```bash
   git remote add upstream https://github.com/rocky-linux/documentation.git
   ```

3. Upstream-Änderungen abrufen:

   ```bash
   git fetch upstream
   ```

4. Erstellen Sie einen neuen Feature-Zweig:

   ```bash
   git checkout -b feature-branch-name
   ```

5. Nehmen Sie Änderungen vor, fügen Sie neue Dateien hinzu und committen Sie sie:

   ```bash
   git add .
   git commit -m "Implementing feature X"
   ```

6. Halten Sie Ihr Branch auf dem neuesten Stand. Führen Sie regelmäßig Änderungen aus dem Upstream zusammen, um Konflikte zu vermeiden:

   ```bash
   git pull upstream main --rebase
   ```

7. Pushen Sie zu Ihrem Fork indem Sie Folgendes eingeben:

   ```bash
   git push origin feature-branch-name
   ```

8. Pull Request anlegen:

   ```bash
   gh pr create --base main --head rockstar:feature-branch-name --title "New Feature X" --body "Long Description of the feature"
   ```

## Zusammenfassung

Der `Feature-Branch-Workflow` ist eine gängige Zusammenarbeitstechnik, die es Teams ermöglicht, gleichzeitig an verschiedenen Aspekten eines Projekts zu arbeiten und gleichzeitig eine stabile Hauptcodebasis aufrechtzuerhalten.

Die wichtigsten Schritte sind:

1. Haupt-Repository klonen: Klonen Sie das Haupt-Projekt-Repository direkt auf Ihren lokalen Computer.
2. Erstellen Sie einen Feature-Branch: Erstellen Sie für jede neue Aufgabe einen neuen Branch des Haupt-Branchs mit einem aussagekräftigen Namen.
3. Änderungen committen: Arbeiten Sie an dem Feature oder führen Sie Korrekturen in Ihrem Zweig durch und committen Sie die Änderungen.
4. Halten Sie den Zweig auf dem neuesten Stand: Führen Sie regelmäßig Zusammenführungen –Merges– oder Rebases mit dem Hauptzweig durch, um über Änderungen auf dem Laufenden zu bleiben.
5. Öffnen Sie ein Pull-Request: Pushen Sie den Zweig in das Hauptrepository und öffnen Sie einen PR zum Review, sobald Ihre Funktion fertig ist.
6. Codereview und Merge: Der Zweig wird nach Überprüfung und Genehmigung in den Hauptzweig zusammengeführt.

_Vorteile_:

- Optimiert Beiträge für regelmäßige Mitwirkende mit direktem Repository-Zugriff.
- Stellt sicher, dass jede Funktion überprüft wird, bevor sie in die Hauptcodebasis integriert wird.
- Hilft, einen sauberen und linearen Projektverlauf aufrechtzuerhalten.
