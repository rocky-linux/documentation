---
title: Création d'image ISO Rocky Linux perso
author: Howard Van Der Wal
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9
tags:
  - create
  - custom
  - ISO
  - kickstart
  - linux
  - mkksiso
  - rocky
---

**Connaissances** : :star: :star:
**Temps de lecture** : 11 minutes

## Introduction

Il y a plusieurs raisons de créer une ISO. Vous voulez peut-être modifier le processus de démarrage, ajouter des paquets spécifiques lors de l'installation ou mettre à jour certains fichiers de configuration.

Ce guide vous expliquera comment créer votre propre image ISO de Rocky Linux.

## Prérequis

- Image ISO minimale de Rocky Linux (l'image DVD n'est pas requise).
- Fichier `kickstart` à appliquer à l'ISO.
- Lisez la documentation [Lorax Quickstart](https://weldr.io/lorax/lorax.html#quickstart) et [mkksiso](https://weldr.io/lorax/mkksiso.html) pour vous familiariser avec la création d'une image ISO.

## Installation des paquets et mise en place

- Installez le paquet `lorax` :

```bash
dnf install -y lorax
```

## Création de l'image ISO avec un fichier `kickstart`

- Exécutez la commande `mkksiso` pour ajouter un fichier `kickstart` puis créez une nouvelle image ISO. Notez que vous devez exécuter la commande en tant que `root` ou un utilisateur disposant des privilèges `sudo` :

```bash
mkksiso --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO> <PATH_TO_NEW_ISO>
```

## Ajout d'un référentiel avec les packages correspondants à une image ISO

- Assurez-vous que le référentiel que vous souhaitez ajouter contient le répertoire `repodata`. Sinon, vous pouvez le créer à l'aide de la commande `createrepo_c` et l'installer avec `dnf install -y createrepo_c`
- Ajoutez le dépôt à votre fichier `kickstart` en utilisant la syntaxe suivante :

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/<REPOSITORY>/
```

- Ajoutez votre dépôt en utilisant l'indicateur `--add` avec l'outil `mkksiso` :

```bash
mkksiso --add <LINK_TO_REPOSITORY> --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO> <PATH_TO_NEW_ISO>
```

- Vous pouvez consulter des détails supplémentaires sur ce processus en utilisant le référentiel `baseos` dans l'exemple ci-dessous.
- Le dépôt `baseos` sera téléchargé localement, ainsi que tous les paquets correspondants :

```bash
dnf reposync -p ~ --download-metadata --repo=baseos
```

- Ajoutez ensuite le dépôt à votre fichier `kickstart` :

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
```

- Pointez ensuite la commande `mkksiso` directement vers le répertoire du référentiel et construisez l'ISO :

```bash
mkksiso --add ~/baseos --ks <PATH_TO_KICKSTART_FILE> ~/<PATH_TO_ISO> ~/<PATH_TO_NEW_ISO>
```

## Conclusion

Une fois votre propre image ISO créée à partir de votre fichier `kickstart`, il devient beaucoup plus facile de déployer des centaines de machines avec une seule image, sans avoir besoin de configurer chaque machine individuellement. Pour en savoir plus sur les fichiers `kickstart`, ainsi que sur de nombreux exemples, veuillez consulter le [guide Kickstart Files et Rocky Linux](../../automation/kickstart-rocky/).
