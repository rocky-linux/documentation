---
title: "Chapitre 2 : ZFS Setup"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - entreprise
  - incus zfs
---

# Chapitre 2 : Mise en Place de ZFS

Tout au long de ce chapitre, vous devez être l'utilisateur root ou pouvoir utiliser `sudo` pour obtenir les privilèges nécessaires.

Si vous avez déjà installé ZFS, cette section vous guidera tout au long de la configuration de ZFS.

## Activation de ZFS et configuration du `pool`

Tout d'abord, entrez la commande suivante :

```bash
/sbin/modprobe zfs
```

S'il n'y a pas d'erreur, iel reviendra à l'invite sans afficher quoi que ce soit. Si vous obtenez une erreur, vous pouvez arrêter maintenant et commencer à trouver une solution. Encore une fois, assurez-vous que l'amorçage sécurisé est désactivé. C'est le coupable le plus probable.

Ensuite, vous devez examiner les disques de notre système, découvrir où se trouve le système d’exploitation et déterminer ce qui est disponible pour le pool ZFS. Pour ce faire utilisez `lsblk` :

```bash
lsblk
```

Ce qui renverra quelque chose comme ceci (sur votre système ce sera différent !) :

```bash
AME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
loop0    7:0    0  32.3M  1 loop /var/lib/snapd/snap/snapd/11588
loop1    7:1    0  55.5M  1 loop /var/lib/snapd/snap/core18/1997
loop2    7:2    0  68.8M  1 loop /var/lib/snapd/snap/lxd/20037
sda      8:0    0 119.2G  0 disk
├─sda1   8:1    0   600M  0 part /boot/efi
├─sda2   8:2    0     1G  0 part /boot
├─sda3   8:3    0  11.9G  0 part [SWAP]
├─sda4   8:4    0     2G  0 part /home
└─sda5   8:5    0 103.7G  0 part /
sdb      8:16   0 119.2G  0 disk
├─sdb1   8:17   0 119.2G  0 part
└─sdb9   8:25   0     8M  0 part
sdc      8:32   0 149.1G  0 disk
└─sdc1   8:33   0 149.1G  0 part
```

Cette liste montre que le système d'exploitation utilise _/dev/sda_. Vous pouvez utiliser _/dev/sdb_ pour le `zpool`. Notez que si vous avez beaucoup de disques durs disponibles, vous pouvez envisager d'utiliser raidz (un logiciel de raid spécialement conçu pour ZFS).

Cela n’entre pas dans le cadre de ce document mais devra être pris en compte pour la production. Il offre de meilleures performances et une meilleure redondance. Pour l'instant, créez votre pool sur le seul disque que vous avez identifié :

```bash
zpool create storage /dev/sdb
```

Cela indique de créer un pool appelé `storage` qui est ZFS sur le périphérique _/dev/sdb_.

Une fois le pool créé, redémarrez à nouveau le serveur.
