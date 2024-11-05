---
title: Installieren und Einrichten von GitHub CLI unter Rocky Linux
author: Wale Soyinka
Contributor: Ganna Zhyrnova
tags:
  - GitHub CLI
  - gh
  - git
  - GitHub
---

## Einleitung

Dieses Gemstone behandelt die Installation und Grundeinrichtung des GitHub CLI-Tools (gh) auf dem Rocky Linux-System. Mit diesem Tool können Benutzer direkt über die Befehlszeile mit GitHub-Repositorys interagieren.

## Problembeschreibung

Benutzer benötigen eine bequeme Möglichkeit zur Interaktion mit GitHub, ohne die Befehlszeilen-Umgebung zu verlassen.

## Voraussetzungen

- Eine Maschine, auf der Rocky Linux läuft
- Terminal-Zugriff
- Grundlegende Erfahrung mit der Linux-Kommandozeilenschnittstelle
- Ein bestehender Github-Account

## Prozedur

1. **GitHub CLI-Repository mit curl installieren**:
   Verwenden Sie den Befehl curl, um die offizielle Repository-Datei für `gh` herunterzuladen. Die heruntergeladene Datei wird im Verzeichnis `/etc/yum.repos.d/` gespeichert. Verwenden Sie nach dem Herunterladen den Befehl dnf, um `gh` aus dem Repository zu installieren. Geben Sie bitte Folgendes ein:

   ```bash
   curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo | sudo tee /etc/yum.repos.d/github-cli.repo
   sudo dnf -y install gh
   ```

2. **Verifizierung der Installation**:
   Stellen Sie sicher, dass `gh` korrekt installiert ist. Geben Sie bitte Folgendes ein:

   ```bash
   gh --version
   ```

3. **Authentifizierung mit GitHub**:
   Loggen Sie sich in Ihr GitHub-Konto ein. Geben Sie bitte Folgendes ein:

   ```bash
   gh auth login
   ```

   Folgen Sie den Anweisungen zur Authentifizierung.

## Zusammenfassung

Sie sollten jetzt die GitHub CLI auf Ihrem Rocky Linux 9.3-System installiert und eingerichtet haben, sodass Sie direkt von Ihrem Terminal aus mit GitHub-Repositorys interagieren können.

## Zusätzliche Informationen (optional)

- Die GitHub-CLI bietet verschiedene Befehle, wie etwa `gh repo clone`, `gh pr create`, `gh issue list` und so weiter.
- Ausführlichere Informationen zur Verwendung finden Sie in der [offiziellen GitHub CLI-Dokumentation](https://cli.github.com/manual/).
