---
title: QA:Sparrow ZFS
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

Lien de documentation :-

Lien du projet :- [https://git.resf.org/testing/Sparky_ZFS](https://git.resf.org/testing/Sparky_ZFS)

Ce cas permet de tester la branche stable (actuellement 2.2) ainsi que la branche la plus récente (actuellement 2.3). Les deux tests doivent être effectués. Pour l'instant, nous ne testons pas la branche de test (actuellement la 2.4). Étant donné que le test utilise la méthode RPM pour l'installation, il n'est pour l'instant valide que pour l'architecture x86_64.

🔴 - testé et reconnu pour ses défaillances.
✅ - Testé et approuvé.
⚠️  - non testé.

## Versions et architectures

| Distribution   | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | --------------------------- |
| Rocky Linux  8 | ⚠️      | ⚠️      | ⚠️      | ⚠️    | 🔴                          |
| Rocky Linux  9 | ⚠️      | ⚠️      | ⚠️      | ⚠️    | ✅                           |
| Rocky Linux 10 | ⚠️      | ⚠️      | ⚠️      | ⚠️    | ✅                           |

## Mise en place

1. Cf. [Getting Started Guide](https://docs.rockylinux.org/guides/automation/sparky_getting_started/)

## Marche à suivre

1. Cf. le guide Sparky.

## Résultats escomptés

```
[task check]
# Checking zpool status
stdout match (s) <pool: data> True
stdout match (s) <state: ONLINE> True
stdout match (s) <config:> True
stdout match (s) <^^  $$> True
stdout match (s) <NAME            STATE     READ WRITE CKSUM> True
stdout match (s) <data            ONLINE       0     0     0> True
stdout match (s) <mirror-0      ONLINE       0     0     0> True
stdout match (s) </mnt/disk1  ONLINE       0     0     0> True
stdout match (s) </mnt/disk2  ONLINE       0     0     0> True
stdout match (s) <^^  $$> True
stdout match (s) <errors: No known data errors> True
# Checking zpool iostat
stdout match (s) <capacity     operations     bandwidth> True
stdout match (s) <pool        alloc   free   read  write   read  write> True
stdout match (s) <----------  -----  -----  -----  -----  -----  -----> True
stdout match (s) <data \s*> True
# Checking zpool list
stdout match (s) <NAME   SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT> True
stdout match (s) <data \s*> True

```

{% include 'teams/testing/qa_testcase_bottom.md' %}
