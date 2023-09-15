---
title: Présentation
author: Franco Colussi
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.7, 9.1
tags:
  - nvchad
  - extensions
  - éditeur
---

# Présentation

## Introduction

La configuration personnalisée créée par les développeurs de NvChad vous permet d'avoir un environnement intégré avec de nombreuses fonctionnalités d'un IDE graphique. Ces fonctionnalités sont intégrées dans la configuration de Neovim au moyen de plugiciels. Ceux sélectionnés pour NvChad par les développeurs ont la fonction de configurer l'éditeur pour un usage général.

Cependant, l'écosystème des plugiciels pour Neovim est beaucoup plus étendu et par leur utilisation, vous permet d'adapter l'éditeur à vos propres besoins.

Le scénario abordé dans cette section est la création de documentation pour Rocky Linux, donc les plugiciels pour l'écriture de code Markdown, la gestion des dépôts Git et autres tâches liées au résultat souhaité seront expliquées.

## Prérequis

- NvChad correctement installé sur le système avec le «*template chadrc*»
- Maîtrise de la ligne de commande
- Une connexion à internet

## Astuces générales concernant les plugiciels

Si vous avez choisi lors de l'installation de NvChad d'installer également le [template chadrc](../template_chadrc.md) votre configuration contiendra un répertoire **~/.config/nvim/lua/custom/**. Toutes les modifications pour vos plugiciels doivent être effectuées dans le fichier **/custom/plugins.lua** situé dans ce répertoire. Si le plugiciel a besoin de configurations supplémentaires, celles-ci seront placées dans le répertoire **/custom/configs**.

Neovim, sur lequel se base la configuration de NvChad, n'intègre pas de mécanisme de mise à jour automatique de configuration avec un éditeur en cours d'exécution. Cela implique que à chaque fois que le fichier de configuration des plugiciels est modifié, il est nécessaire de relancer `nvim` pour obtenir toute la fonctionnalité de l'extension.

L'installation du plugiciel peut être effectuée immédiatement après qu'il soit placé dans le fichier à condition que le gestionnaire de plugins `lazy.nvim` garde la trace des changements dans **plugins.lua** et permette donc son installation "live".

![plugins.lua](./images/plugins_lua.png)
