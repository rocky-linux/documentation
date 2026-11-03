---
title: QA:Test Live Image
author: Chris Stackpole
tags:
  - test logiciel
  - qa
revision_date: 2026-10-09
rc:
  prod: Rocky Linux
  level: Final
render_macros: true
---

## Description

Ce test permet de vérifier que le bureau est lancé correctement au démarrage des images ISO. Ce test peut être effectué soit en gravant un support optique, soit avec [Fedora Media Writer](https://docs.fedoraproject.org/en-US/fedora/latest/preparing-boot-media/), mais la méthode recommandée pour le test consiste à utiliser un utilitaire de virtualisation.

Tous les éléments de cette catégorie sont considérés comme de ⬇️ - moindre priorité. Il serait bon de tester cela, mais si ce n'est pas fait ou si le test échoue, ce n'est pas essentiel.

## Versions, architectures et fichiers ISO

Les images live ne sont créées que pour Aarch64 et x86_64. Toutes les images en direct de bureau ne sont pas créées lors de la publication, mais seront mises à jour en fonction des dépendances en amont.

| Distribution   | aarch64                                                                 | ppc64le | riscv64 | s390x | x86_64                                             |
| -------------- | ----------------------------------------------------------------------- | ------- | ------- | ----- | ----------------------------------------------------------------------- |
| Rocky Linux  9 | Cinnamon<br/>KDE<br/>MATE<br/>Workstation<br/>Workstation Lite<br/>XFCE | N/A     | N/A     | N/A   | Cinnamon<br/>KDE<br/>MATE<br/>Workstation<br/>Workstation Lite<br/>XFCE |
| Rocky Linux 10 | KDE<br/>Workstation<br/>Workstation Lite                                | N/A     | N/A     | N/A   | KDE<br/>Workstation<br/>Workstation Lite                                |

## Mise en place

1. Pour chaque ISO d'une architecture de version, téléchargez le fichier ISO correspondant.
2. Utilisez une application de virtualisation pour démarrer l'image ISO.

## Marche à suivre

1. Démarrez le système à partir du fichier ISO.
2. Vérifiez que l'environnement de bureau se charge correctement.

## Résultats escomptés

1. Le bureau s'affiche afin de permettre aux utilisateurs d'interagir. La navigation dans les menus et la sélection des entrées doivent fonctionner.
2. Le système démarre en lançant le desktop approprié.

{% include 'teams/testing/qa_testcase_bottom.md' %}
