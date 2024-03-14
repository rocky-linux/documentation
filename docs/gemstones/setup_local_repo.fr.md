---
title: Mise en place des dépôts locaux de Rocky
author: codedude
contributors: Steven Spencer
update: 2021-12-09
---

# Introduction

Parfois, vous avez besoin d'avoir des dépôts Rocky locaux pour construire des machines virtuelles, des environnements de laboratoire, etc. Ça peut également aider à économiser de la bande passante si c'est une préoccupation.  Cet article vous guidera à travers l'utilisation de `rsync` pour copier les dépôts Rocky sur un serveur web local.  La construction d'un serveur web est hors du sujet de cet article succin.

## Prérequis

* Un serveur web

## Exemple de Code

```
#!/bin/bash
repos_base_dir="/web/path"

# Start sync if base repo directory exist
if [[ -d "$repos_base_dir" ]] ; then
  # Start Sync
  rsync  -avSHP --progress --delete --exclude-from=/opt/scripts/excludes.txt rsync://ord.mirror.rackspace.com/rocky  "$repos_base_dir" --delete-excluded
  # Download Rocky 8 repository key
  if [[ -e /web/path/RPM-GPG-KEY-rockyofficial ]]; then
     exit
  else
      wget -P $repos_base_dir https://dl.rockylinux.org/pub/rocky/RPM-GPG-KEY-rockyofficial
  fi
fi
```

## Détails de la procédure

Ce script shell simple utilise `rsync` pour extraire les fichiers de dépôt depuis le miroir le plus proche.  Il utilise également l'option "exclude" qui est définie dans un fichier texte sous la forme de mots-clés qui ne devraient pas être inclus.  Les exclusions sont adéquates si vous avez un espace disque limité ou si vous ne voulez pas tout pour une raison quelconque.  Nous pouvons utiliser l'étoile `*` comme caractère générique.  Faites attention en utilisant `*/ng` car il exclura tout ce qui correspond à ces caractères.  Cf. l'exemple ci-dessous :

```
*/source*
*/debug*
*/images*
*/Devel*
8/*
8.4-RC1/*
8.4-RC1
```

# Conclusion
Un script simple qui peut aider à économiser la bande passante ou rendre la construction d'un environnement de laboratoire un peu plus facile.
