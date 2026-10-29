---
title: QA:Testfall Upgrades
author: Chris Stackpole
contributors:
tested_with: 8.10, 9.8, 10.2
tags:
  - Softwaretest
  - qa
revision_date: 2026-10-20
rc:
  prod: Rocky Linux
  ver:
    - 8
    - 9
    - 10
  level: Final
render_macros: true
---

## Beschreibung

Benutzer müssen in der Lage sein, ein Upgrade von einer früheren Hauptversion (z. B. 9.8 → 9.9) durchzuführen.

- ⬇️ - niedrige Priorität. Es wäre gut, dies testen zu lassen; sollte dies jedoch nicht geschehen oder sollte der Test fehlschlagen, so ist das unerheblich.
- ❗ - wichtig. Es empfiehlt sich, dies testen zu lassen, aber falls dies nicht möglich ist oder der Test fehlschlägt, wird die Veröffentlichung dadurch nicht verhindert.

## Releases, Architekturen und ISOs

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | --------------------------- |
| Rocky Linux  9 | ❗       | ⬇️      | N/A     | ⬇️    | ❗                           |
| Rocky Linux 10 | ❗       | ⬇️      | ⬇️      | ⬇️    | ❗                           |

## Setup

1. Verwenden Sie eine frühere Version oder installieren Sie eine solche.

## Test-Hinweise

1. Ändern oder aktualisieren Sie die Repositories, sodass sie auf die neue Version verweisen.
2. `sudo dnf --refresh upgrade`

## Erwartete Ergebnisse

1. Alle Aktualisierungen sollten fehlerfrei verlaufen.
2. Neustarts mit dem neuen Kernel sollten fehlerfrei und ohne Probleme verlaufen.

{% include 'teams/testing/qa_testcase_bottom.md' %}
