---
title: QA:Sparrow Anacrond
author: Chris Stackpole
contributors:
tags:
  - Softwaretest
  - sparrow
revision_date: 2026-10-09
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Beschreibung

Dokumentation-Link:- [anacron - Automatisierungs-Befehle](https://docs.rockylinux.org/guides/automation/anacron/)

Projekt-Link:- [https://git.resf.org/testing/Sparky_Anacron](https://git.resf.org/testing/Sparky_Anacron)

🔴 – Getestet und als fehlerhaft bekannt.
✅ – Getestet und nachweislich funktionsfähig.
⚠️ – Ungetestet.

## Releases und Architekturen

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | --------------------------- |
| Rocky Linux  8 | 🔴      | ⚠️      | N/A     | ⚠️    | 🔴                          |
| Rocky Linux  9 | ✅       | ⚠️      | N/A     | ⚠️    | ✅                           |
| Rocky Linux 10 | ✅       | ⚠️      | ⚠️      | ⚠️    | ✅                           |

## Einrichtung

1. Siehe [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## Test-Hinweise

1. Siehe Sparky guide.

## Erwartete Ergebnisse

```
[task check]
stdout match <anacrontab ok> True
stdout match <binary ok> True
stdout match <spool ok> True
stdout match <config valid> True
stdout match <0hourly ok> True
stdout match <timestamps ok> True
stdout match <executed> True
```

{% include 'teams/testing/qa_testcase_bottom.md' %}
