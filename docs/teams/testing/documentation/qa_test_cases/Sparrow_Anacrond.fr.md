---
title: QA:Sparrow Anacrond
author: Chris Stackpole
contributors:
tags:
  - test logiciel
  - sparrow
revision_date: 2026-10-09
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Description

Lien de documentation :- [anacron - Automating commands](https://docs.rockylinux.org/guides/automation/anacron/)

Lien du project :- [https://git.resf.org/testing/Sparky_Anacron](https://git.resf.org/testing/Sparky_Anacron)

🔴 - testé et reconnu pour ses défaillances.
✅ - Testé et approuvé.
⚠️  - non testé.

## Releases et Architectures

| Distribution   | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | --------------------------- |
| Rocky Linux  8 | 🔴      | ⚠️      | ⚠️      | ⚠️    | 🔴                          |
| Rocky Linux  9 | ✅       | ⚠️      | ⚠️      | ⚠️    | ✅                           |
| Rocky Linux 10 | ✅       | ⚠️      | ⚠️      | ⚠️    | ✅                           |

## Mise en place

1. Cf. [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## Marche à suivre

1. Cf. le guide Sparky.

## Résultats escomptés

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
