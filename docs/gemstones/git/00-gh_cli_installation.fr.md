---
title: Installation et Configuration de GitHub CLI sur Rocky Linux
author: Wale Soyinka
Contributor: Ganna Zhyrnova
tags:
  - GitHub CLI
  - gh
  - git
  - GitHub
---

## Introduction

Cette pépite couvre l'installation et la configuration de base de l'outil GitHub CLI (gh) sur le système Rocky Linux. Cet outil permet aux utilisateurs d'interagir avec les référentiels GitHub directement à partir de la ligne de commande.

## Description du problème

Les utilisateurs ont besoin d’un moyen pratique pour interagir avec GitHub sans quitter l’environnement de ligne de commande.

## Prérequis

- Un système utilisant Rocky Linux
- Accès à un terminal
- Maîtrise de la ligne de commande
- Un compte GitHub opérationnel

## Procédure

1. **Installer le référentiel CLI GitHub à l'aide de curl** :
   utilisez la commande curl pour télécharger le fichier du référentiel officiel pour `gh`. Le fichier téléchargé sera enregistré dans le répertoire `/etc/yum.repos.d/`. Après le téléchargement, utilisez la commande `dnf` pour installer `gh` à partir du référentiel. Tapez la commande suivante :

   ```bash
   curl -fsSL https://cli.github.com/packages/rpm/gh-cli.repo | sudo tee /etc/yum.repos.d/github-cli.repo
   sudo dnf -y install gh
   ```

2. **Vérifier l'installation** :
   Assurez-vous que `gh` est correctement installé. Tapez la commande suivante :

   ```bash
   gh --version
   ```

3. **Authentification avec GitHub** :
   Connectez-vous à votre compte GitHub. Tapez la commande suivante :

   ```bash
   gh auth login
   ```

   Suivez les instructions pour vous authentifier.

## Conclusion

Vous devriez maintenant avoir la CLI GitHub installée et configurée sur votre système Rocky Linux 9.3, vous permettant d'interagir avec les référentiels GitHub directement depuis votre terminal.

## Informations Supplémentaires (facultatif)

- La CLI GitHub fournit diverses commandes, telles que `gh repo clone`, `gh pr create`, `gh issue list`, etc.
- Pour une utilisation plus détaillée, reportez-vous à la [documentation officielle de GitHub CLI](https://cli.github.com/manual/).
