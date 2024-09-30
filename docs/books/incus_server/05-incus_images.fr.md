---
title: "Chapitre 5 : Mise en place et Gestion des Images"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - entreprise
  - incus images
---

Tout au long de ce chapitre, vous devez exécuter des commandes en tant qu'utilisateur non privilégié (`incusadmin` si vous avez suivi ce livre depuis le début).

## Liste des images disponibles

Vous avez probablement hâte de commencer à utiliser un conteneur. Il existe de nombreuses possibilités de système d'exploitation de conteneur. Pour avoir une idée du nombre de possibilités, entrez la commande suivante :

```bash
incus image list images: | more
```

Appuyez sur la barre d'espace pour naviguer à travers la liste. Cette liste de conteneurs et de machines virtuelles ne cesse de croître.

La **dernière** chose que vous souhaitez faire est de rechercher une image de conteneur à installer, en particulier si vous connaissez l’image que vous souhaitez créer. Modifions la commande ci-dessus pour n'afficher que les options d'installation de Rocky Linux :

```bash
incus image list images: | grep rocky
```

Ce qui fait apparaître une liste beaucoup plus facile à gérer :

```bash
| rockylinux/8 (3 more)                    | dede6169bb45 | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | VIRTUAL-MACHINE | 850.75MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/arm64 (1 more)              | b749bad83e60 | yes    | Rockylinux 8 arm64 (20240903_04:40)        | aarch64      | CONTAINER       | 125.51MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud (1 more)              | 4fefd464d25d | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | VIRTUAL-MACHINE | 869.95MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud (1 more)              | 729891475172 | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | CONTAINER       | 148.81MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud/arm64                 | 3642ec9652fc | yes    | Rockylinux 8 arm64 (20240903_04:52)        | aarch64      | CONTAINER       | 144.84MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9 (3 more)                    | 9e5e4469e660 | yes    | Rockylinux 9 amd64 (20240903_03:29)        | x86_64       | VIRTUAL-MACHINE | 728.60MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9 (3 more)                    | fff1706d5834 | yes    | Rockylinux 9 amd64 (20240903_03:29)        | x86_64       | CONTAINER       | 111.25MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/arm64 (1 more)              | d3a44df90d69 | yes    | Rockylinux 9 arm64 (20240903_04:49)        | aarch64      | CONTAINER       | 107.18MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud (1 more)              | 4329a67099ba | yes    | Rockylinux 9 amd64 (20240903_03:28)        | x86_64       | VIRTUAL-MACHINE | 749.29MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud (1 more)              | bc30d585b9f0 | yes    | Rockylinux 9 amd64 (20240903_03:28)        | x86_64       | CONTAINER       | 127.16MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud/arm64                 | 5c38ddd506bd | yes    | Rockylinux 9 arm64 (20240903_04:38)        | aarch64      | CONTAINER       | 122.87MiB  | 2024/09/02 19:00 CDT |
```

## Installation, renommage et liste des images

Pour le premier conteneur, nous allons choisir "rockylinux/8". Pour l'installer, vous pouvez utiliser la commande suivante :

```bash
incus launch images:rockylinux/8 rockylinux-test-8
```

Cela créera un conteneur basé sur Linux Rocky nommé `rockylinux-test-8`. Vous pouvez renommer un conteneur après qu'il ait été créé, mais vous devez d'abord arrêter le conteneur, qui démarre automatiquement lorsqu'il est créé.

Pour démarrer le conteneur manuellement, utilisez la commande suivante :

```bash
incus start rockylinux-test-8
```

Pour renommer l'image (nous n'allons pas le faire ici, mais voici comment procéder), arrêtez d'abord le conteneur :

```bash
incus stop rockylinux-test-8
```

Utilisez la commande `move` pour modifier le nom du conteneur :

```bash
incus move rockylinux-test-8 rockylinux-8
```

Si vous avez quand même suivi cette instruction, arrêtez le conteneur et remettez-le sur le nom d'origine avant de continuer.

Pour ce guide, continuez et installez deux images supplémentaires pour le moment :

```bash
incus launch images:rockylinux/9 rockylinux-test-9
```

et

```bash
incus launch images:ubuntu/22.04 ubuntu-test
```

Voyons maintenant ce que nous avons en listant nos images :

```bash
incus list
```

qui devrait retourner quelque chose comme ceci :

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 10.146.84.179 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 10.146.84.180 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```
