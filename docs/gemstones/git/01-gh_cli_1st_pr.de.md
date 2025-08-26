---
title: Erster Beitrag zur Rocky Linux-Dokumentation über CLI
author: Wale Soyinka
contributors:
tags:
  - GitHub
  - Rocky Linux
  - Mitwirkung
  - Pull-Request
  - CLI
---

## Einleitung

In diesem Gemstone wird ausführlich beschrieben, wie Sie ausschließlich mithilfe der Befehlszeilenschnittstelle (CLI) zum Rocky Linux-Dokumentationsprojekt beitragen können. Es umfasst das erstmalige Forken des Repository und das Erstellen eines Pull-Requests.
In unserem Beispiel verwenden wir die Bereitstellung eines neuen Gemstone-Dokuments.

## Problembeschreibung

Mitwirkende möchten oder müssen möglicherweise alle Aktionen über die CLI ausführen, vom Forken von Repositorys bis zum erstmaligen Senden von Pull Requests.

## Voraussetzungen

- Ein Github-Konto
- `git` und `GitHub CLI (gh)` auf Ihrem System installiert
- Eine Markdown-Datei, die zur Veröffentlichung bereit ist

## Lösung-Etappen

1. **Repository mit GitHub CLI forken**:
   Forken Sie das Upstream-Repository zu Ihrem Konto.

   ```bash
   gh repo fork https://github.com/rocky-linux/documentation --clone
   ```

2. **Navigieren zum Repository-Verzeichnis**:

   ```bash
   cd documentation
   ```

3. **Upstream-Repository hinzufügen**:

   ```bash
   git remote add upstream https://github.com/rocky-linux/documentation.git
   ```

4. **Neuen Zweig erstellen**:
   Erstellen Sie einen neuen Zweig für Ihren Beitrag. Geben Sie bitte Folgendes ein:

   ```bash
   git checkout -b new-gemstone
   ```

5. **Neuen Zweig erstellen**:
   Erstellen Sie einen neuen Zweig für Ihren Beitrag.
   Für dieses Beispiel erstellen Sie eine neue Datei namens `gemstome_new_pr.md` im Verzeichnis „docs/gemstones/“.

6. **Übernahme der Änderungen mit Commit**:
   Stellen Sie Ihre neue Datei bereit mit `commit`. Geben Sie bitte Folgendes ein:

   ```bash
   git add docs/gemstones/gemstome_new_pr.md
   git commit -m "Add new Gemstone document"
   ```

7. **Auf Ihren Fork mit Push übertragen**:
   Übertragen Sie die Änderungen mit `push` auf Ihren Fork/Kopie des Rocky Linux-Dokumentationsrepos. Geben Sie bitte Folgendes ein:

   ```bash
   git push origin new-gemstone
   ```

8. **Pull Request erstellen**:
   Erstellen Sie einen Pull Request an das Upstream-Repository.

   ```bash
   gh pr create --base main --head wsoyinka:new-gemstone --title "New Gemstone: Creating PRs via CLI" --body "Guide on how to contribute to documentation using CLI"
   ```

## Zusätzliche Informationen (optional)

- Verwenden Sie `gh pr list` und `gh pr status`, um den Status Ihrer Pull Requests zu verfolgen.
- Lesen Sie die Beitragsrichtlinien des Rocky Linux-Dokumentationsprojekts und befolgen Sie diese.

## Zusammenfassung

Wenn Sie diese Schritte befolgen, sollten Sie in der Lage sein, Ihren PR erfolgreich zu erstellen und vollständig über die CLI zum Rocky Linux-Dokumentations-Repository beizutragen!
