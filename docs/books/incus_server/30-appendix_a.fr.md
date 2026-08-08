---
title: Annexe A - Mise en place du poste de travail
author: Steven Spencer
contributors: Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - workstation
---

# Annexe A - Mise en place du poste de travail

Bien que ne faisant pas partie des chapitres relatifs à un serveur `Incus`, cette procédure aidera ceux qui souhaitent disposer d'un environnement de laboratoire ou d'un système d'exploitation et d'une application semi-permanents exécutés sur un poste de travail ou un ordinateur portable Rocky Linux.

## Prérequis

- maîtrise de la ligne de commande
- pouvoir utiliser un éditeur de ligne de commande, tel que `vi` ou `nano`
- avoir besoin d'un environnement de test stable qui peut être utilisé quotidiennement ou selon les besoins
- pouvoir se connecter comme root ou avoir des privilèges supplémentaires avec `sudo`

## Installation

À partir de la ligne de commande, installez le dépôt EPEL :

```bash
sudo dnf install epel-release -y
```

Une fois l'installation terminée, effectuez une mise à niveau avec `upgrade` :

```bash
sudo dnf upgrade
```

Installation de dépôts supplémentaires :

```bash
sudo dnf config-manager --enable crb
sudo dnf copr enable neil/incus
```

Installation de paquets nécessaires :

```bash
sudo dnf install dkms vim kernel-devel bash-completion
```

Installation et activation de Incus :

```bash
sudo dnf install incus incus-tools
sudo systemctl enable incus
```

Veuillez redémarrer votre ordinateur portable ou votre station de travail avant de continuer.

## Initialisation de `Incus`

Si vous avez parcouru les chapitres relatifs au serveur de production, vous constaterez que la procédure d’initialisation du serveur de production est presque identique.

```bash
sudo incus admin init
```

Cela lancera un dialogue de questions-réponses.

Voici les questions et nos réponses pour le script, avec une petite explication lorsque cela est nécessaire :

```text
Would you like to use clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: storage
```

En option, vous pouvez accepter la valeur par défaut.

```text
Nom du backend de stockage à utiliser (btrfs, dir, lvm, ceph) [default=btrfs]: dir
```

Notez que le backend de stockage `dir` est plus lent que `zfs`. Si vous pouvez laisser un disque vide, vous pouvez utiliser ce périphérique (par exemple : /dev/sdb) pour le périphérique `zfs`, puis sélectionner `zfs`.

```text
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Metal As A Service (MAAS) n'entre pas dans le cadre de ce document.

```text
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

Vous pouvez activer cette option si vous souhaitez utiliser IPv6 sur vos conteneurs Incus.

```text
Would you like the Incus server to be available over the network? (yes/no) [default=no]: yes
```

Cette opération est nécessaire pour effectuer un instantané de la station de travail. Répondez `yes` ici.

```text
Address to bind Incus to (not including port) [default=all]:
Port to bind Incus to [default=8443]:
Trust password for new clients:
Again:
```

Ce mot de passe de confiance vous permettra de vous connecter ou de revenir depuis le serveur de captures instantanées. Définissez-le en l'associant à quelque chose qui a du sens dans votre environnement. Enregistrez cette entrée dans un endroit sécurisé, comme un gestionnaire de mots de passe.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "incus admin init" preseed to be printed? (yes/no) [default=no]:
```

## Privilèges d'utilisateur

La prochaine chose que vous devez faire est d’ajouter votre utilisateur au groupe `incus-admin`. Encore une fois, vous devrez utiliser `sudo` ou être root pour cela :

```text
sudo usermod -a -G incus-admin [username]
```

Où [username] est votre utilisateur sur le système.

## Définition des valeurs `subuid` et `subgid` pour `root`

Vous devez définir à la fois la valeur de `subuid` et de `subgid` de l'utilisateur `root` (la plage d'ID d'utilisateur et de groupe subordonnés). Cette valeur devrait être la suivante :

```bash
root:1000000:1000000000
```

Pour ce faire, éditez le fichier `/etc/subuid` et ajoutez cette ligne. Une fois terminé, votre fichier sera :

```bash
root:1000000:1000000000
```

Ajoutez à nouveau cette ligne au fichier `/etc/subgid`. Votre fichier ressemblera à ceci :

```bash
incusadmin:100000:65536
root:1000000:1000000000
```

Vous avez apporté un certain nombre de modifications à ce stade. Avant de procéder, redémarrez votre machine.

## Vérification de l'Installation

Pour vous assurer que `incus` a démarré et que votre utilisateur dispose des privilèges adéquats, à partir de l'invite du shell, exécutez :

```text
incus list
```

Notez que nous n'avons pas utilisé `sudo` ici. Votre utilisateur peut tout à fait exécuter ces commandes. Vous devriez obtenir quelque chose de similaire à ce qui suit :

```bash
+------------+---------+----------------------+------+-----------+-----------+
|    NAME    |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------+---------+----------------------+------+-----------+-----------+
```

Si c'est le cas, tout va bien !

## À suivre

À partir de ce point, vous pouvez utiliser les chapitres de notre « Incus Production Server » pour continuer. Il y a certains éléments dans la configuration d'un poste de travail auxquels vous devez prêter une moindre attention. Voici les chapitres recommandés pour vous aider à démarrer:

- [Chapitre 5 - Configuration et gestion des images](05-incus_images.md)
- [Chapitre 6 - Profils](06-profiles.md)
- [Chapitre 8 - Snapshots de conteneurs](08-snapshots.md)

## Informations supplémentaires

- [Présentation et Documentation Officielles d'Incus](https://linuxcontainers.org/incus/docs/main/)

## Conclusion

Incus est un outil puissant pour augmenter la productivité sur les postes de travail ou les serveurs. Il est idéal pour les tests en laboratoire sur un poste de travail et peut également maintenir des instances semi-permanentes de systèmes d'exploitation et d'applications disponibles dans leur propre espace privé.
