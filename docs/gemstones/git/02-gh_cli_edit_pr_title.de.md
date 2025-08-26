---
title: Bearbeiten des Titels eines vorhandenen Pull Requests über die CLI
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - GitHub
  - Pull-Request
  - Dokumentation
  - CLI
---

## Einleitung

In diesem Gemstone wird erklärt, wie Sie den Titel eines vorhandenen Pull Requests (PR) in einem GitHub-Repository mithilfe der GitHub-Weboberfläche und der CLI bearbeiten.

## Problembeschreibung

Manchmal muss der Titel eines PR nach seiner Erstellung angepasst werden, um die aktuellen Änderungen oder Diskussionen besser widerzuspiegeln.

## Voraussetzungen

- Ein vorhandener GitHub-Pull-Request.
- Zugriff auf die GitHub-Weboberfläche oder CLI mit den erforderlichen Berechtigungen.

## Prozedur

### GitHub CLI – Verwendung

1. **Checken Sie den entsprechenden Zweig aus**:
   - Stellen Sie sicher, dass Sie sich auf dem mit dem PR verknüpften Branch befinden.

     ```bash
     git checkout branch-name
     ```

2. **Bearbeiten Sie den PR mithilfe der CLI**:
   - Verwenden Sie den folgenden Befehl, um den PR zu bearbeiten:

     ```bash
     gh pr edit PR_NUMBER --title "New PR Title"
     ```

   - Ersetzen Sie `PR_NUMBER` durch die Nummer Ihres Pull Requests und `"New PR Title"` durch den gewünschten Titel.

## Zusätzliche Informationen (optional)

- Das Bearbeiten eines PR-Titels hat keine Auswirkungen auf den Diskussionsthread oder Codeänderungen.
- Es gilt als gute Praxis, Mitwirkende zu informieren, wenn an einem PR-Titel wesentliche Änderungen vorgenommen werden.

## Zusammenfassung

Mit diesen Schritten können Sie den Titel einer vorhandenen Pull-Anfrage in einem GitHub-Repository ganz einfach über das GitHub-CLI-Tool (gh) ändern.
