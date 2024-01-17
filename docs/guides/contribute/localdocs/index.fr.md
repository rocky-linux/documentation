---
Title: Introduction
author: Steven Spencer
contributors: null
tags:
  - local docs
  - docs as code
  - linters
---

# Introduction

L'utilisation d'une copie locale de la documentation Rocky Linux est utile pour les contributeurs fréquents qui ont besoin de voir exactement à quoi ressemble un document dans l'interface Web finale. Les méthodes décrites ici représentent les préférences des contributeurs à ce jour.

L'utilisation d'une copie locale de la documentation constitue une étape du processus de développement pour ceux qui souscrivent à la philosophie de « docs as code », un flux de travail pour la documentation similaire au développement de code.

## Markdown - Analyse statique avec lint

En plus des environnements de stockage et de création de documentation, certains rédacteurs pourraient envisager l'utilisation d'un linter pour Markdown. Les linters Markdown sont utiles dans de nombreux aspects de la rédaction de documents, notamment la vérification de la grammaire, de l'orthographe, du formatage, etc. Il s’agit parfois d’outils ou de plugins distincts pour votre éditeur. L'un de ces outils est [markdownlint](https://github.com/DavidAnson/markdownlint), un outil Node.js. `markdownlint` est disponible sous forme de plugin pour de nombreux éditeurs populaires, notamment Visual Studio Code et NVChad. Pour cette raison, placé à la racine du dossier de documentation, il existe un fichier `.markdownlint.yml`, qui appliquera les règles disponibles et activées pour le projet. `markdownlint` est uniquement un linter de formatage. Il recherchera les espaces errants, les éléments HTML en ligne, les doubles lignes vides, les taquets de tabulation incorrects, etc. Pour la grammaire, l’orthographe, l’utilisation inclusive de la langue, etc., installez des outils supplémentaires.

!!! info "Disclaimer"

```
Aucun des éléments de cette catégorie (« Documentation locale ») n'est requis pour rédiger des documents et les soumettre pour approbation. Ils existent pour ceux qui souhaitent suivre les philosophies [docs as code](https://www.writethedocs.org/guide/docs-as-code/), qui incluent au minimum une copie locale de la documentation.
```
