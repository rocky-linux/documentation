---
title: Serveur Incus. Introduction
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - lxd
  - incus
  - entreprise
---

## Création d'un serveur Incus

### Présence de `Incus` sur Rocky Linux

Il y a presque un an maintenant – 2023 ? –, l'annonce suivante est sortie sur la liste de diffusion lxc-users :

> Canonical, the creator and main contributor of the LXD project has decided that after over 8 years as part of the Linux Containers community, the project would now be better served directly under Canonical’s own set of projects.
> —
> Canonical, le créateur et principal contributeur du projet LXD, a décidé qu'après plus de 8 ans au sein de la communauté Linux Containers, le projet serait désormais mieux servi directement dans le cadre du propre ensemble de projets de Canonical.
> —

L’un des facteurs décisifs a été la démission de certains développeurs principaux de LXD. Ces développeurs ont ensuite bifurqué LXD vers Incus, annonçant le fork en août 2023. Une version de publication (0.1) est sortie en octobre 2023, et les développeurs ont depuis rapidement développé cette version avec des versions progressives jusqu'à la 0.7 (en mars 2024). La sortie de la version de support à long terme (6.0 LTS) a suivi la sortie de la version 0.7. 2024-09-25 : La version actuelle est 6.5.

Tout au long du processus, Canonical était censé continuer à maintenir des liens vers les images de conteneurs fournies par Linux Containers. Cependant, un [changement de licence](https://stgraber.org/2023/12/12/lxd-now-re-licensed-and-under-a-cla/) a rendu impossible pour Linux Containers de continuer à proposer les images de conteneurs dans LXD. Cela signifie que LXD aura des images de conteneur, mais elles ne seront pas ce à quoi vous pourriez vous attendre. Linux Containers continue d'héberger et de prendre en charge leurs images si vous utilisez Incus.

Ce document est une conversion du [livre LXD](../lxd_server/00-toc.md) vers Incus. Depuis la création d'un référentiel par le co-responsable de l'infrastructure du projet Rocky Linux [Neil Hanlon](https://wiki.rockylinux.org/team/infrastructure/), vous avez la possibilité d'installer Incus avant son inclusion dans le référentiel EPEL (Extra Packages for Enterprise Linux).

!!! warning "Le serveur Incus n'est pas disponible sur Rocky Linux 8"

```
L'installation du serveur Incus n'est disponible que pour Rocky Linux 9.x et est actuellement testée sur Rocky Linux 9.4. Si vous avez besoin de quelque chose qui fonctionne sur Rocky Linux 8.x, utilisez la [procédure LXD mentionnée précédemment](../lxd_server/00-toc.md).
```

## Introduction

Incus est le mieux décrit sur le [site officiel](https://linuxcontainers.org/incus/), mais considérez-le comme un système de conteneur offrant les avantages des serveurs virtuels dans un conteneur.

Il est très puissant, et avec le matériel approprié et configuré, peut être mis à profit pour exécuter beaucoup d'instances de serveurs sur un seul matériel. Si vous associez cela à un serveur de snapshot, vous avez également un ensemble de conteneurs que vous pouvez faire tourner presque immédiatement si votre serveur principal se trouve déconnecté.

!!! warning "Ceci n'est pas une sauvegarde"

```
Il ne faut pas considérer cela comme une sauvegarde traditionnelle. Vous avez toujours besoin d'un système de sauvegarde classique, tel que [rsnapshot](../../guides/backup/rsnapshot_backup.md).
```

La courbe d'apprentissage d'Incus peut être raide, mais ce livre tentera de vous donner les connaissances nécessaires pour vous aider à déployer et à utiliser `Incus` sur Rocky Linux.

Pour ceux qui souhaitent utiliser Incus comme environnement de laboratoire sur leurs ordinateurs portables ou leurs postes de travail, voir [Annexe A : Configuration du poste de travail](30-appendix_a.md).

## Prérequis

- Un serveur Rocky Linux 9, configuré de manière adéquate. Envisagez un disque dur séparé pour l’espace disque ZFS dans un environnement de production (vous devez le faire si vous utilisez ZFS). En effet un des prérequis ici est un serveur bare metal, et non pas un VPS (Virtual Private Server).
- C'est un sujet avancé, mais pas très difficile à comprendre. Si vous suivez ces instructions dès le début, vous devriez réussir. Cela dit, avoir quelques notions de base sur la gestion des conteneurs sera très utile.
- Vous devriez maîtriser la ligne de commande sur chaque machine et pouvoir utiliser un éditeur de texte comme `vi` (par exemple). (L'auteur utilise _vi_ dans ces exemples, mais vous pouvez le remplacer par votre éditeur préféré.)
- Il suffit d'être un utilisateur sans privilège pour la majeure partie de ces procédures. Pour les premières étapes de configuration, vous devrez être connecté en tant qu'utilisateur root ou pouvoir utiliser `sudo` pour le devenir. Tout au long de ces chapitres, nous supposons que votre utilisateur non privilégié est `incusadmin`. Vous devrez créer ce compte utilisateur ultérieurement dans le processus.
- Pour ZFS, vérifiez que le démarrage sécurisé d'UEFI n'est PAS activé. Sinon, vous devrez signer cryptographiquement le module ZFS pour pouvoir le charger.
- Nous utilisons principalement des conteneurs basés sur Rocky Linux

!!! info "Info"

```
L'auteur inclut une méthodologie pour utiliser un système de fichiers ZFS. Veuillez noter que le projet Incus recommande BTRFS comme système de fichiers pour un serveur Incus. (ZFS est toujours une option de système de fichiers.) BTRFS, cependant, n'est pas du tout disponible sur Rocky Linux 9.4. Jusqu'à ce qu'il soit approuvé par le système en amont et publié, votre seule option est d'utiliser ZFS ou un autre système de fichiers inclus. Pour en savoir plus sur les options du système de fichiers Incus, consultez [le document officiel du projet ici.](https://linuxcontainers.org/incus/docs/main/reference/storage_dir/)
```

## Synopsis

- **Chapitre 1 : Installation et configuration** traite de l’installation du serveur principal. Généralement, la bonne façon de mettre en œuvre Incus en production est d'avoir un serveur principal et un serveur d'instantanés.
- **Chapitre 2 : Configuration de ZFS** décrit la configuration et l’installation de ZFS. ZFS est un gestionnaire de volume logique et système de fichiers open-source créé par Sun Microsystems, à l'origine pour son système d'exploitation Solaris.
- **Chapitre 3 : Initialisation d'Incus et configuration de l'utilisateur** traite de l'initialisation et des options de base, ainsi que de la configuration de votre utilisateur non privilégié que vous utiliserez pendant la majeure partie du reste de la procédure
- **Chapitre 4 : Configuration du pare-feu** Contient les options de configuration `firewalld`
- **Chapitre 5 : Configuration et gestion des images** décrit la procédure d'installation des images de système d'exploitation dans un conteneur et leur configuration
- **Chapitre 6 : Profils** traite de l'ajout de profils et de leur application aux conteneurs et couvre principalement `macvlan` et son importance pour l'adressage IP sur votre LAN ou WAN
- **Chapitre 7 : Options de configuration des conteneurs** couvre brièvement certaines des options de configuration de base des conteneurs et décrit certains avantages et effets secondaires pour la modification des options de configuration
- **Chapitre 8 : Snapshots de conteneurs** détaille le principe d'instantané pour les conteneurs sur le serveur principal
- **Chapitre 9 : Le serveur de snapshots** couvre l'installation et la configuration du serveur de snapshots et comment créer la relation symbiotique entre le serveur principal et le serveur de snapshots
- **Chapitre 10 : Automatisation des Snapshots** couvre l'automatisation de la création d'instantanés et le remplissage du serveur d'instantanés avec des Snapshots
- **L'annexe A : Configuration du poste de travail** ne fait techniquement pas partie des documents du serveur de production. Cette annexe présente une solution pour les personnes qui souhaitent créer un laboratoire de conteneurs `Incus` sur leurs ordinateurs portables ou leurs postes de travail.

## Conclusion

Vous pouvez utiliser ces chapitres pour configurer efficacement une paire de serveurs `Incus` primaire et de Snapshots au niveau d'entreprise. Ce faisant, vous en apprendrez énormément sur `Incus`. Sachez simplement qu’il y a encore beaucoup à apprendre et considérez ces documents comme un point de départ.

L’avantage le plus significatif d’Incus est qu’il est économique à utiliser sur un serveur, qu’il vous permet de lancer rapidement des installations de systèmes d’exploitation et qu’il permet à de nombreux serveurs d’applications autonomes de s’exécuter sur un seul matériel, en exploitant ce matériel pour une utilisation optimale.
