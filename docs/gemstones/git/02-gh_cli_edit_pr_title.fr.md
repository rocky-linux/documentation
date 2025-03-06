---
title: Modification du titre d'une Pull Request via CLI
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - GitHub
  - Pull Request
  - Documentation
  - CLI
---

## Introduction

Ce Gemstone explique comment modifier ou changer le titre d'une pull request (PR) existante dans un référentiel GitHub à l'aide de l'interface Web GitHub et de la CLI.

## Description du Problème

Parfois, le titre d'une PR après sa création peut devoir être modifié pour mieux refléter les changements ou les discussions en cours.

## Prérequis

- Une pull request GitHub en cours de traitement.
- Accès à l'interface Web GitHub ou CLI avec les autorisations nécessaires.

## Procédure

### Utilisation du CLI de GitHub

1. **Check Out de la branche correspondante** :
  - Assurez-vous que vous êtes sur la branche associée à la PR.

    ```bash
    git checkout branch-name
    ```

2. **Modifier le PR à l'aide de la CLI** :
  - Utilisez la commande suivante pour modifier la PR :

    ```bash
    gh pr edit PR_NUMBER --title "New PR Title"
    ```

  - Remplacez `PR_NUMBER` par le numéro de votre pull request et `"New PR Title"` par le titre souhaité.

## Informations Supplémentaires (facultatif)

- La modification d'un titre de PR n'affectera pas son fil de discussion ni les modifications de code.
- Il est considéré comme une bonne pratique d'informer les collaborateurs si des modifications significatives sont apportées au titre d'un PR.

## Conclusion

En suivant ces étapes, vous pouvez facilement modifier le titre d'une pull request existante dans un référentiel GitHub via l'outil CLI GitHub (gh).
