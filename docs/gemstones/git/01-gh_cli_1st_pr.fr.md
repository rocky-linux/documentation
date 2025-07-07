---
title: Première contribution à la documentation de Rocky Linux via CLI
author: Wale Soyinka
contributors:
tags:
  - GitHub
  - Rocky Linux
  - Contribution
  - Pull Request
  - CLI
---

## Introduction

Cette pépite détaille comment contribuer au projet de documentation Rocky Linux en utilisant uniquement l'interface de ligne de commande (CLI). Il couvre le fork du référentiel la première fois et la création d'une pull request.
Nous allons utiliser la contribution d'un nouveau document Gemstone dans notre exemple.

## Description du problème

Les contributeurs peuvent préférer ou avoir besoin d'effectuer toutes les actions via la CLI, depuis la création de référentiels jusqu'à la soumission de pull request pour la première fois.

## Prérequis

- Un compte GitHub
- Installation de `git` et `GitHub CLI (gh)` sur votre système
- Un fichier Markdown prêt pour contribution

## Étapes de la Solution

1. **Fork du référentiel à l'aide de la CLI GitHub** :
  Forkez le dépôt en amont sur votre compte.

  ```bash
  gh repo fork https://github.com/rocky-linux/documentation --clone
  ```

2. **Accéder au répertoire du référentiel** :

  ```bash
  cd documentation
  ```

3. **Ajouter le référentiel en amont** :

  ```bash
  git remote add upstream https://github.com/rocky-linux/documentation.git
  ```

4. **Création d'une branche** :
  Créez une nouvelle branche pour votre contribution. Entrer la commande suivante :

  ```bash
  git checkout -b new-gemstone
  ```

5. **Ajouter un nouveau document** :
  Utilisez votre éditeur de texte préféré pour créer et modifier votre nouveau fichier de contribution.
  Pour cet exemple, nous allons créer `gemstome_new_pr.md` et enregistrer ce fichier sous le répertoire `docs/gemstones/`.

6. **Commit des modifications** :
  Préparez et validez votre nouveau fichier. Entrer la commande suivante :

  ```bash
  git add docs/gemstones/gemstome_new_pr.md
  git commit -m "Add new Gemstone document"
  ```

7. **Push vers le fork** :
  Envoyez les modifications vers votre fork/copie du dépôt de documentation Rocky Linux. Entrer la commande suivante :

  ```bash
  git push origin new-gemstone
  ```

8. **Création d'une Pull Request** :
  Créez une requête vers le référentiel en amont.

  ```bash
  gh pr create --base main --head wsoyinka:new-gemstone --title "New Gemstone: Creating PRs via CLI" --body "Guide on how to contribute to documentation using CLI"
  ```

## Informations Supplémentaires (facultatif)

- Utilisez `gh pr list` et `gh pr status` pour suivre l'état de vos pull request.
- Relisez et vérifiez en suivant les directives de contribution du projet de documentation Rocky Linux.

## Conclusion

En suivant ces étapes, vous devriez être en mesure de créer avec succès votre tout premier PR et de contribuer au référentiel de documentation Rocky Linux entièrement via la CLI !
