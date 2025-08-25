---
title: Ajout d'un dépôt distant à l'aide de git CLI
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - GitHub
  - git
  - git remote
  - git fetch
---

## Introduction

Ce Gemstone illustre comment ajouter un référentiel distant spécifique à un clone local existant d'un projet FOSS à l'aide de l'interface de ligne de commande Git.
Nous utiliserons le référentiel du projet de documentation Rocky Linux comme exemple de projet FOSS - <https://github.com/rocky-linux/documentation.git>

## Prérequis

- Un compte GitHub.
- Installation de `git` sur le système.
- Un clone local d'un dépôt de projet FOSS.

## Procédure

1. Ouvrez un terminal et changez votre répertoire de travail vers le dossier contenant votre clone local du projet.
   Par exemple, si vous avez cloné le dépôt github dans ~/path/to/your/rl-documentation-clone, tapez

   ```bash
   cd ~/path/to/your/rl-documentation-clone
   ```

2. Avant d’effectuer des modifications, répertoriez les `remote`s que vous avez configurées. Tapez la commande suivante :

   ```bash
   git remote -vv
   ```

   S'il s'agit d'un dépôt fraîchement cloné, vous verrez probablement une seule branche remote nommée `origin` dans votre affichage de sortie.

3. Ajoutez le référentiel de documentation Rocky Linux (`https://github.com/rocky-linux/documentation.git`) en tant que nouveau référentiel distant – `remote` – à votre référentiel local. Ici, nous allons attribuer `upstream` comme nom à cette `remote` particulière. Tapez la commande suivante :

   ```bash
   git remote add upstream https://github.com/rocky-linux/documentation.git
   ```

4. Pour souligner davantage que les noms attribués aux référentiels distants sont arbitraires, créez un autre référentiel distant nommé rocky-docs qui pointe vers le même référentiel en exécutant la commande suivante :

   ```bash
   git remote add rocky-docs https://github.com/rocky-linux/documentation.git
   ```

5. Vérifiez que le nouveau dépôt distant a été ajouté avec succès :

   ```bash
   git remote -v
   ```

   Vous devriez voir `upstream` répertorié avec son URL.

6. Facultativement, avant de commencer à apporter des modifications à votre dépôt local, vous pouvez récupérer des données à partir de la branche nouvellement ajoutée.
   Récupérez les branches et les commits de la `remote` nouvellement ajoutée en exécutant :

   ```bash
   git fetch upstream
   ```

## Remarques Complémentaires

- _Origin_ : il s'agit du nom par défaut que Git donne au référentiel distant à partir duquel vous avez cloné. C'est comme un surnom pour l'URL du dépôt. Lorsque vous clonez un dépôt, ce référentiel distant est automatiquement défini comme `origine` dans votre configuration Git locale. Le nom est arbitraire mais une convention.

- _Upstream_ : cela fait souvent référence au référentiel d'origine lorsque vous avez créé un fork d'un projet.
  Dans les projets open-source, si vous dupliquez un référentiel pour apporter des modifications, le référentiel dupliqué est votre `origin` et le référentiel d'origine est généralement appelé `upstream`. Le nom est arbitraire mais une convention.

  Cette distinction subtile entre usages/affectation de `remote` et `origin` est cruciale pour contribuer au projet original via des pull request.

## Conclusion

L'utilitaire Git CLI permet d'utiliser facilement un nom descriptif et d'ajouter un référentiel distant spécifique à un clone local d'un projet FOSS. Cela vous permet de vous synchroniser et de contribuer efficacement à divers dépôts.
