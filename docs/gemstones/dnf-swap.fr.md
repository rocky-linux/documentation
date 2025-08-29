- - -
--- title: dnf - swap command author: wale soyinka contributors: date: 2025-08-29 19h12 tags: dnf ---
  - cloud images
  - conteneurs
  - dnf
  - dnf swap
  - curl
  - curl-minimal
  - allowerasing
  - coreutils-single
- - -


# Introduction

Afin de rendre les images des conteneurs et les images cloud aussi petites que possible, les responsables de la distribution et les empaqueteurs peuvent parfois publier des versions dépouillées de paquets quasi indispensables. Des exemples de packages simplifiés fournis avec des images de conteneur ou de cloud sont **vim-minimal, curl-minimal, coreutils-single** et ainsi de suite.

Bien que certains des packages publiés soient des versions simplifiées, ils sont souvent tout à fait acceptables pour la plupart des cas d'utilisation.

Dans les cas où le package simplifié n'est pas suffisant, vous pouvez utiliser la commande `dnf swap` pour remplacer rapidement le package minimal par le package normal.

## Objectif

Cette pépite de Rocky Linux montre comment utiliser **dnf** pour échanger – _swap_ – le package `curl-minimal` fourni avec le paquet `curl` normal.

## Vérifier la variante de `curl` existante

Lorsque vous êtes connecté à votre environnement de conteneur ou de machine virtuelle en tant qu'utilisateur disposant de privilèges administratifs, vérifiez d'abord la variante du package `curl` installée. Entrer la commande suivante :

```bash
# rpm -qa | grep  ^curl-minimal
curl-minimal-*
```

Prérequis : vous avez curl-minimal sur votre système de démonstration !

## Permuter curl-minimal pour curl

Utilisez `dnf` pour échanger le paquet `curl-minimal` installé avec le paquet `curl` normal.

```bash
# dnf -y swap curl-minimal curl

```

## Vérifiez la nouvelle variante du package `curl`

Pour confirmer les modifications, interrogez à nouveau la base de données RPM pour le(s) package(s) `curl` installé(s) en exécutant :

```bash
# rpm -qa | grep  ^curl
curl-*
```

Et c'est un Gemme !

## Remarques

La commande `dnf swap`

**Syntaxe** :

```bash
dnf [options] swap <package-to-be-removed> <replacement-package>
```

Sous le capot, `dnf swap` utilise l'option `--allowerasing` de DNF pour résoudre tout problème de conflit de paquets. Par conséquent, l'exemple minimal de `curl` démontré dans ce GEMstone aurait également pu être réalisé en exécutant :

```bash
dnf install -y --allowerasing curl
```
