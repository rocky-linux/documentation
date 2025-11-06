- - -
title: dnf — swap command <br/> author: wale soyinka <br/> translators: [https://crowdin.com/project/rockydocs](https://crowdin.com/project/rockydocs/activity-stream) <br/> date: 2025-09-05 19h49 <br/> tags: <br/>
  - cloud images
  - conteneurs
  - dnf
  - dnf swap
  - vim
  - vim-minimal
  - allowerasing
  - coreutils-single
- - -


# Introduction

Afin de rendre les images des conteneurs et les images cloud aussi petites que possible, les responsables de la distribution et les empaqueteurs peuvent parfois publier des versions dépouillées de paquets quasi indispensables. Des exemples de packages simplifiés fournis avec des images de conteneur ou de cloud sont **vim-minimal, curl-minimal, coreutils-single** et ainsi de suite.

Bien que certains des packages publiés soient des versions simplifiées, ils sont souvent tout à fait acceptables pour la plupart des cas d'utilisation.

Dans les cas où le package simplifié n'est pas suffisant, vous pouvez utiliser la commande `dnf swap` pour remplacer rapidement le package minimal par le package normal.

## Objectif

Ce GEMstone Rocky Linux démontre comment utiliser **dnf** pour _échanger_ le paquet `vim-minimal` intégré avec le paquet `vim` habituel.

## Vérifiez la variante de `vim` existante

Lorsque vous êtes connecté à votre environnement de conteneur ou de machine virtuelle en tant qu'utilisateur disposant de privilèges administratifs, vérifiez d'abord la variante du package `vim` installée. Entrer la commande suivante :

```bash
# rpm -qa | grep  ^vim
vim-minimal-9.1.083-5.el10_0.1.x86_64
```

Vous avez `vim-minimal` sur votre système de démonstration.

## Permuter `vim-minimal` pour `vim`

Utilisation de `dnf` pour remplacer le paquet `vim-minimal` par le paquet `vim` standard.

```bash
# dnf -y swap vim-minimal vim
```

## Vérifiez la nouvelle variante du package `vim`

Pour confirmer les modifications, interrogez à nouveau la base de données RPM pour le(s) package(s) `vim` installé(s) en exécutant :

```bash
# rpm -qa | grep  ^vim
vim-enhanced-9.1.083-5.el10_0.1.x86_64
```

Et c'est un Gemme !

## Remarques

La commande `dnf swap`

**Syntaxe** :

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Sous le capot, `dnf swap` utilise l'option `--allowerasing` de DNF pour résoudre tout problème de conflit de paquets. Par conséquent, l'exemple `vim-minimal` présenté dans ce GEMstone aurait aussi pu être réalisé en exécutant :

```bash
dnf install -y --allowerasing vim
```
