---
title: Création d'image ISO Rocky Linux perso
author: Howard Van Der Wal
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.5
tags:
  - create
  - custom
  - ISO
---

## Introduction

Vous pourriez avoir besoin de créer une image ISO personnalisée pour de nombreuses raisons. Peut-être souhaitez-vous modifier le processus de démarrage, ajouter des packages spécifiques ou mettre à jour un fichier de configuration.

Ce guide vous expliquera du début à la fin comment créer votre propre image ISO Rocky Linux personnalisée.

## Prérequis

- Une machine 64 bits exécutant Rocky Linux 9
- Une image ISO DVD de Rocky Linux 9.
- Un fichier `kickstart` s'appliquant à l'ISO
- Lisez la documentation Lorax [Quickstart](https://weldr.io/lorax/lorax.html#quickstart) et [mkksiso](https://weldr.io/lorax/mkksiso.html) pour vous familiariser avec la création du fichier `Anaconda` `boot.iso`.

## Installation et mise en place des paquets

- Installez le paquet `lorax` :

```bash
sudo dnf install -y lorax
```

## Création de l`image ISO avec un fichier `kickstart\`

- Exécutez la commande `mkksiso` pour ajouter un fichier `kickstart`, puis créez une nouvelle ISO :

```bash
mkksiso --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO_TO_MODIFY> <OUTPUT_PATH_FOR_BUILT_ISO>
```

- Vous trouverez ci-dessous un exemple de fichier `kickstart` `example-ks.cfg`, qui configure un environnement Rocky Linux 9.5 `Server With GUI` :

```bash
lang en_GB
keyboard --xlayouts='us'
timezone Asia/Tokyo --utc
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp
firstboot --disable
selinux --enforcing
firewall --enabled
%packages
@^server-product-environment
%end
```

## Ajout d'un référentiel avec ses packages à une image ISO

- Assurez-vous que le référentiel que vous souhaitez ajouter contient le répertoire `repodata`. Sinon, vous pouvez le créer en utilisant la commande `createrepo_c` et l'installer avec `sudo dnf install -y createrepo_c`
- Ajoutez le dépôt à votre fichier `kickstart`, en utilisant la syntaxe suivante :

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/<YOUR_REPOSITORY>/
```

- Ajoutez votre dépôt en utilisant l'indicateur `--add` avec l'outil `mkksiso` :

```bash
mkksiso --add <LINK_TO_YOUR_REPOSITORY> --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO_TO_MODIFY> <OUTPUT_PATH_FOR_BUILT_ISO>
```

- Vous pouvez voir des détails supplémentaires sur ce processus en utilisant le référentiel `baseos` dans l'exemple ci-dessous
- Le référentiel `baseos` sera téléchargé localement avec tous ses packages :

```bash
dnf reposync -p ~ --download-metadata --repo=baseos
```

- Ajoutez ensuite le dépôt au fichier `kickstart` :

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
```

- Le fichier `kickstart` devrait ressembler à ceci :

```bash
lang en_GB
keyboard --xlayouts='us'
timezone Asia/Tokyo --utc
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp
firstboot --disable
selinux --enforcing
firewall --enabled
%packages
@^server-product-environment
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
%end
```

- Pointez ensuite la commande `mkksiso` directement vers le répertoire du référentiel et construisez l'ISO :

```bash
mkksiso --add ~/baseos --ks example-ks.cfg ~/Rocky-9.5-x86_64-dvd.iso ~/Rocky-9.5-x86_64-dvd-new.iso
```

## Conclusion

Ce qui a été discuté ici ne sont que quelques-unes des options disponibles pour peaufiner et créer votre propre image ISO Rocky Linux personnalisée. Pour d'autres méthodes, y compris la modification des arguments de la ligne de commande du noyau, l'auteur recommande fortement de parcourir la documentation [mkksiso](https://weldr.io/lorax/mkksiso.html) plus en détail.
