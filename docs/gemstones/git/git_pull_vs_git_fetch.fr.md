---
title: Utilisation de `git pull` et `git fetch`
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - Git
  - git pull
  - git fetch
---

## Introduction

Ce Gemstone explique les différences entre les commandes `git pull` et `git fetch`. Il indique également quand utiliser chaque commande de manière appropriée.

## Git Fetch vs Git Pull

### Git Fetch

`git fetch` télécharge les modifications à partir d'un référentiel distant mais ne les intègre pas dans votre branche locale.

Il est bénéfique de voir ce que les autres ont apporté avec commit sans fusionner ces modifications dans votre branche locale.

1. Lister la branche actuellement extraite

   ```bash
   git branch
   ```

2. Récupérer les modifications avec `fetch` depuis la branche principale d'un référentiel distant nommé origin. Entrer la commande suivante :

   ```bash
   git fetch origin main
   ```

3. Comparez les modifications entre le HEAD de votre dépôt local et le dépôt `origin/main` distant.

   ```bash
   git log HEAD..origin/main
   ```

### Git Pull

Git Pull télécharge les modifications et les fusionne dans votre branche actuelle.
Il est utile pour mettre à jour rapidement votre branche locale avec les modifications du référentiel distant.

1. **Extraire et fusionner les modifications** :

   ```bash
   git pull origin main
   ```

2. **Vérifiez les modifications fusionnées** :

   ```bash
   git log
   ```

## Remarques Complémentaires

- **Utilisez `git fetch`** :
  \-- Lorsque vous devez vérifier les modifications avant la fusion.
  \-- Éviter des changements indésirables ou des conflits dans votre branche locale.

- **Utilisez `git pull`** :
  \-- Lorsque vous souhaitez mettre à jour votre branche locale avec les derniers commits.
  \-- Pour des mises à jour rapides et simples sans avoir à vérifier les modifications au préalable.

## Conclusion

Comprendre les distinctions entre `git fetch` et `git pull` est essentiel pour une gestion efficace du workflow Git. Choisir la bonne commande en fonction de vos besoins est important lorsque vous travaillez ou collaborez via des systèmes de contrôle de version comme GitHub, GitLab, Gitea, etc.
