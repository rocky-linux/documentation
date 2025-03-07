---
title: Feature Branch Workflow avec Git
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - git
  - Workflow de branche de fonctionnalités
  - GitHub
  - gh
  - git fetch
  - git add
  - git pull
  - git checkout
---

## Workflow de branche de fonctionnalités

Ce workflow git répandu implique la création de nouvelles branches pour chaque nouvelle fonctionnalité ou correctif directement dans le référentiel principal.
Il est généralement utilisé dans les projets où les contributeurs ont un accès direct au référentiel.

Ce Gemstone décrit le processus de configuration d'un référentiel local sur lequel travailler et contribuer au projet `rocky-linux/documentation` à l'aide du workflow Git Feature Branch.

L'utilisateur "rockstar" a créé un fork de ce référentiel et nous utiliserons `https://github.com/rockstar/documentation` comme origine.

## Prérequis

- Un compte GitHub et un fork du projet (par exemple, `https://github.com/rockstar/documentation`).
- L'installation de `git` et `GitHub CLI (gh)`.

## Procédure

1. Si besoin est, clonez votre fork :

  ```bash
  git clone https://github.com/rockstar/documentation.git
  cd documentation
  ```

2. Ajoutez `upstream remote` :

  ```bash
  git remote add upstream https://github.com/rocky-linux/documentation.git
  ```

3. Récupérer les modifications en amont :

  ```bash
  git fetch upstream
  ```

4. Créer une nouvelle branche, Feature Branch :

  ```bash
  git checkout -b feature-branch-name
  ```

5. Apportez des modifications, ajoutez de nouveaux fichiers et validez-les avec `commit` :

  ```bash
  git add .
  git commit -m "Implementing feature X"
  ```

6. Maintenir votre Branche à Jour. Fusionnez régulièrement les modifications en amont avec `pull` pour éviter les conflits :

  ```bash
  git pull upstream main --rebase
  ```

7. Transmettez vers votre fork en tapant :

  ```bash
  git push origin feature-branch-name
  ```

8. Créer un Pull Request :

  ```bash
  gh pr create --base main --head rockstar:feature-branch-name --title "New Feature X" --body "Long Description of the feature"
  ```

## Conclusion

Le workflow Feature Branch est une technique de collaboration courante, permettant aux équipes de travailler simultanément sur divers aspects d'un projet tout en conservant une base de code principale stable.

Les étapes principales sont les suivantes :

1. Cloner le référentiel principal : clonez directement le référentiel principal du projet sur votre machine locale.
2. Créer une branche de fonctionnalités : pour chaque nouvelle tâche, créez une nouvelle branche de la branche principale avec un nom descriptif.
3. Valider les modifications : travaillez sur la fonctionnalité ou le correctif dans votre branche et validez les modifications avec `commit`.
4. Maintenir la branche à jour : fusionnez avec `pull` ou rebasez régulièrement avec la branche principale pour rester synchrone avec d'éventuelles modifications.
5. Ouvrez une Pull Request : envoyez la branche au référentiel principal avec `push` et ouvrez une PR pour examen une fois que votre fonctionnalité est prête à vérifier.
6. Révision et fusion du code : la branche est fusionnée dans la branche principale avec `merge` après vérification et approbation.

_Avantages :_

- Simplifie les contributions pour les contributeurs réguliers avec un accès direct au référentiel.
- Assure que chaque fonctionnalité est examinée et vérifiée avant d'être intégrée à la base de code principale.
- Permet de maintenir un historique de projet propre et linéaire.
