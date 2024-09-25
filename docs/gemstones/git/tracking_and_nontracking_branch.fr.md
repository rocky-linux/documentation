---
title: Tracking vs Non-Tracking Branch avec Git
author: Wale Soyinka
contributors: null
tags:
  - git
  - git branch
  - Tracking Branch
  - Branche sans suivi
---

## Introduction

Ce Gemstone explore les branches de suivi et de non-suivi dans Git. Il comprend également des étapes pour vérifier et convertir entre les types de branches.

## Tracking Branch

Une branche de suivi est une branche liée à une branche distante.

1. Créez une nouvelle branche en la nommant my-local-branch. Faites en sorte que la nouvelle branche locale suive la branche principale du référentiel distant nommé `origin`. Entrer la commande suivante :

   ```bash
   git checkout -b my-local-branch origin/main
   ```

2. Utilisez la commande `git branch -vv` pour vérifier que la branche est une branche de suivi – Tracking –. Entrer la commande suivante :

   ```bash
   git branch -vv
   ```

   Recherchez les branches avec `[origin/main]` indiquant qu'elles suivent `origin/main`.

## Branche sans suivi

Une branche sans suivi – `Non-Tracking` – est une branche qui fonctionne indépendamment des branches distantes.

1. Créez une nouvelle branche locale sans suivi nommée my-feature-branch. Entrer la commande suivante :

   ```bash
   git checkout -b my-feature-branch
   ```

2. Les branches sans suivi n’afficheront pas de branche distante à côté d’elles dans la sortie du résultat de la commande `git branch -vv`. Vérifiez si my-feature-branch est une branche sans suivi.

## Conversion de Non-Tracking à Tracking

1. Si vous le souhaitez, assurez-vous d’abord que les dernières modifications de la branche principale sont fusionnées dans la branche cible. Entrer la commande suivante :

   ```bash
   git checkout my-feature-branch
   git merge main
   ```

2. Configurer le suivi – tracking – vers une branche distante :

   ```bash
   git branch --set-upstream-to=origin/main my-feature-branch
   ```

   Résultat : `Branch 'my-feature-branch' set up to track remote branch 'main' from 'origin'.`

3. Vérifier les modifications. Entrer la commande suivante :

   ```bash
   git branch -vv
   ```

   Maintenant, `my-feature-branch` devrait afficher `[origin/main]` indiquant qu'elle est en cours de suivi – tracking –.

## Conclusion

Comprendre les nuances entre les branches de suivi et celles sans suivi est essentiel dans Git. Ce Gemstone clarifie ces concepts et montre également comment identifier et convertir entre ces types de branches pour une gestion optimale du workflow git.
