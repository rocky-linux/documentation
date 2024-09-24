---
title: Fork et Branche – Git workflow
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - GitHub
  - git
  - gh
  - git fetch
  - git add
  - git pull
  - git checkout
  - gh repo
---

## Fork et Branch Workflow

Dans ce type de workflow, les contributeurs transfèrent le référentiel principal vers un fork dans leur propre compte GitHub, créent des branches de fonctionnalités pour leur travail, puis soumettent des contributions via des Pull Requests depuis ces branches.

Ce Gemstone explique comment configurer un référentiel local pour contribuer à un projet GitHub. Cela commence par le fork initial du projet, la configuration d'un référentiel local et distant, la validation des modifications et la création d'une pull request (PR) pour soumettre vos contributions.

## Prérequis

- Un compte GitHub.
- Installation de `git` et `GitHub CLI (gh)` sur votre système.
- Un fork individuel du projet sur GitHub.

## Procédure

1. S'il n'existe pas déjà, créez un fork du projet en utilisant l'utilitaire `gh`. Entrer la commande suivante :

   ```bash
   gh repo fork rocky-linux/documentation --clone=true --remote=true
   ```

   Les options utilisées dans cette commande _gh repo fork_ sont les suivantes :

   - `--clone=true` : Clone le référentiel forké sur votre machine locale.
   - `--remote=true` : ajoute le référentiel d'origine en tant que référentiel distant, vous permettant de synchroniser les futures mises à jour.

2. Accédez au répertoire du dépôt local. Entrer la commande suivante :

   ```bash
   cd documentation
   ```

3. Vérifiez que tous les dépôts distants pertinents ont été correctement configurés dans votre dépôt local, tapez :

   ```bash
   git remote -vv
   ```

4. Récupérez les dernières modifications avec `fetch` depuis le dépôt distant en amont :

   ```bash
   git fetch upstream
   ```

5. Créez et extrayez avec `checkout` une nouvelle branche de fonctionnalités nommée your-feature-branch :

   ```bash
   git checkout -b your-feature-branch
   ```

6. Apportez des modifications, ajoutez de nouveaux fichiers et validez vos modifications dans votre dépôt local avec `commit` :

   ```bash
   git add .
   git commit -m "Your commit message"
   ```

7. Synchronisez avec la branche principale du dépôt distant nommée « upstream » :

   ```bash
   git pull upstream main
   ```

8. Transmission des modifications au Fork :

   ```bash
   git push origin your-feature-branch
   ```

9. Enfin, créez une Pull Request (PR) à l'aide de l'application CLI `gh` :

   ```bash
   gh pr create --base main --head your-feature-branch --title "Your PR Title" --body "Description of your changes"
   ```

   Les options utilisées dans cette commande _gh pr create_ sont les suivantes :

   `--base` main : spécifie la branche de base dans le référentiel upstream où les modifications seront fusionnées avec `merge`.
   `--head` your-feature-branch : indique la branche principale de votre fork qui contient les modifications.
   `--title` "Votre titre PR" : définit le titre de la demande de Pull Request.
   `--body` "Description de vos modifications" : Fournit une description détaillée des modifications dans la pull request.

## Conclusion

Le workflow `Fork and Branch` est une autre technique de collaboration courante.
Les étapes principales sont les suivantes :

1. Fork Repository : créez une copie individuelle du référentiel du projet sur votre compte GitHub.
2. Clone du fork : clonez votre fork sur votre machine locale pour les travaux de développement.
3. Définir le site distant en amont : pour rester à jour avec ses modifications, ajoutez le référentiel du projet d'origine en tant que site distant `upstream remote`.
4. Création d'une Feature Branch : créez une nouvelle branche à partir de la branche principale mise à jour pour chaque nouvelle fonctionnalité ou correctif. Les noms de branche doivent décrire succinctement la fonctionnalité ou le correctif.
5. Commit des modifications : effectuez vos modifications et validez-les – `commit` – avec des messages de validation clairs et concis.
6. Synchronisation avec Upstream : synchronisez régulièrement votre fork et votre branche de fonctionnalité avec la branche principale en amont – `Upstream` – pour intégrer les nouvelles modifications et réduire les conflits de fusion – `merge` – .
7. Création d'une Pull Request (PR) : envoyez votre branche de fonctionnalité à votre fork sur GitHub avec `push` et ouvrez une PR sur le projet principal. Votre PR doit décrire clairement les changements et établir un lien vers tout problème pertinent et toute demande d'amélioration ou de nouvelle fonctionnalité.
8. Répondre aux commentaires : collaborer sur les commentaires de révision jusqu'à ce que la PR soit fusionnée – `merge` – ou fermée.

Avantages :

- Isole le travail de développement dans des branches spécifiques, tout en gardant la branche principale propre.
- Cela facilite la révision et l’intégration des modifications.
- Réduit le risque de conflits avec la base de code évolutive du projet principal.
