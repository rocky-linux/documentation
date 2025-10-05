---
title: "`git pull` und `git fetch` im Vergleich"
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - Git
  - git pull
  - git fetch
---

## Einleitung

Dieses Gemstone erklärt die Unterschiede zwischen den Befehlen `git pull` und `git fetch`. Außerdem wird erläutert, wann welcher Befehl angemessen verwendet werden sollte.

## Git Fetch versus Git Pull

### Git Fetch

`git fetch` lädt Änderungen aus einem Remote-Repository herunter, integriert sie jedoch nicht in Ihren lokalen Zweig.

Es ist hilfreich zu sehen, was andere mit `commit` eingereicht haben, ohne diese Änderungen mit `merge` in Ihren lokalen Zweig zu übernehmen.

1. Listet den aktuell ausgecheckten Zweig auf

   ```bash
   git branch
   ```

2. Rufen Sie Änderungen aus dem Hauptzweig eines Remote-Repos namens `origin` mit `fetch` ab. Geben Sie bitte Folgendes ein:

   ```bash
   git fetch origin main
   ```

3. Vergleichen Sie die Änderungen zwischen dem HEAD Ihres lokalen Repo und dem Remote-`origin/main`-Repo.

   ```bash
   git log HEAD..origin/main
   ```

### Git Pull

`git pull` lädt Änderungen herunter und führt sie in Ihren aktuellen Branch zusammen.
Es ist nützlich, um Ihren lokalen Zweig schnell mit Änderungen aus dem Remote-Repository zu aktualisieren.

1. **Änderungen abrufen und zusammenführen**:

   ```bash
   git pull origin main
   ```

2. **Zusammengeführte – merged – Änderungen überprüfen**:

   ```bash
   git log
   ```

## Zusätzliche Anmerkungen

- **Verwenden Sie `git fetch`**:
  \-- Wenn Sie Änderungen vor dem Zusammenführen überprüfen müssen.
  – Um unerwünschte Änderungen oder Konflikte in Ihrem lokalen Branch zu vermeiden.

- **Verwenden Sie `git pull`**:
  \-- Wenn Sie Ihren lokalen Branch mit den neuesten Commits aktualisieren möchten.
  – Für schnelle, unkomplizierte Updates, ohne dass Änderungen vorher überprüft werden müssen.

## Zusammenfassung

Für ein effektives Git-Workflow-Management ist es wichtig, die Unterschiede zwischen `git fetch` und `git pull` zu verstehen. Die Auswahl des richtigen Befehls basierend auf Ihren Anforderungen ist wichtig, wenn Sie über Versionskontrollsysteme wie GitHub, GitLab, Gitea usw. arbeiten oder zusammenarbeiten.
