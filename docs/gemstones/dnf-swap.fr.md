---
title: dnf - la commande swap
author: Wale Soyinka
contributors:
date: 2023-01-24
tags:
  - Images Cloud
  - conteneurs
  - dnf
  - dnf swap
  - vim
  - vim-minimal
  - allowerasing
  - coreutils-single
---

# Introduction

Afin de rendre les images des conteneurs et les images cloud aussi petites que possible, les responsables de la distribution et les empaqueteurs peuvent parfois publier des versions dépouillées de paquets quasi indispensables. Des exemples de packages simplifiés fournis avec des images de conteneur ou de cloud sont **vim-minimal, curl-minimal, coreutils-single** et ainsi de suite.

Bien que certains des packages publiés soient des versions simplifiées, ils sont souvent tout à fait adaptés pour la plupart des cas d'utilisation.

Dans les cas où le package simplifié n'est pas suffisant, vous pouvez utiliser la commande `dnf swap` pour remplacer rapidement le package minimal par le package normal.

## Objectif

Ce GEMstone de Rocky Linux montre comment utiliser **dnf** pour remplacer – _swap_ – le package `vim-minimal` par le package `vim` normal.

## Vérifier la variante de `vim` existante

Lorsque vous êtes connecté à votre environnement de conteneur ou de machine virtuelle en tant qu'utilisateur disposant de privilèges administratifs, vérifiez d'abord la variante du package `vim` installée. Tapez la commande suivante :

```bash
# rpm -qa | grep  ^vim
vim-minimal-8.2.2637-22.el9_6.1.x86_64
```

Le paquet `vim-minimal` est installé sur votre système.

## Permuter `vim-minimal` pour `vim`

Utilisez `dnf` pour échanger le paquet `vim-minimal` installé avec le paquet `vim` normal.

```bash
# dnf -y swap vim-minimal vim

```

## Vérifiez la nouvelle variante du package `vim`

Pour confirmer les modifications, interrogez à nouveau la base de données RPM pour le(s) package(s) `vim` installé(s) en exécutant la commande suivante :

```bash
# rpm -qa | grep  ^vim
vim-enhanced-8.2.2637-22.el9_6.1.x86_64
```

CQFD !

## Remarques

La commande `dnf swap`

Syntaxe :

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Sous le capot, `dnf swap` utilise l'option `--allowerasing` de DNF pour résoudre tout problème de conflit de paquets. Par conséquent, l'exemple minimal de `vim` démontré dans ce GEMstone aurait également pu être réalisé en exécutant :

```bash
dnf install -y --allowerasing vim
```
