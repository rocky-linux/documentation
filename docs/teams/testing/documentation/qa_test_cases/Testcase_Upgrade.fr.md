---
title: QA:cas de test Upgrades
author: Chris Stackpole
contributors:
tested_with: 8.10, 9.8, 10.2
tags:
  - test logiciel
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

## Description

Les utilisateurs doivent être capables d'effectuer une mise à niveau à partir d'une version majeure précédente (par exemple : 9.8 -> 9.9).

- ⬇️ - moindre priorité. Il serait bon de tester ça, mais si ce n'est pas fait ou si ça échoue, ce n'est pas grave.
- ❗ - important. Il est préférable de faire tester cela, mais si ce n'est pas fait ou si ça échoue, ça n'empêchera pas la publication.

## Releases, Architectures, et fichiers ISO

| Distro         | aarch64 | ppc64le | riscv64 | s390x | x86_64 |
| -------------- | ------- | ------- | ------- | ----- | --------------------------- |
| Rocky Linux  9 | ❗       | ⬇️      | N/A     | ⬇️    | ❗                           |
| Rocky Linux 10 | ❗       | ⬇️      | ⬇️      | ⬇️    | ❗                           |

## Mise en place

1. Lancez une version précédente ou installez-la.

## Marche à suivre

1. Modifiez ou mettez à jour les dépôts pour qu'ils pointent vers la nouvelle version.
2. `sudo dnf --refresh upgrade`

## Résultats escomptés

1. Toutes les mises à jour devraient se dérouler sans erreur.
2. Le redémarrage vers le nouveau noyau devrait se dérouler sans erreur ni problème.

{% include 'teams/testing/qa_testcase_bottom.md' %}
