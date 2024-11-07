---
title: "Chapitre 3 : Initialisation d'Incus et Configuration d'Utilisateur"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - entreprise
  - initialisation de incus
  - incus setup
---

Tout au long de ce chapitre, vous devez être l'utilisateur root ou pouvoir utiliser `sudo` pour obtenir les privilèges nécessaires. De plus, vous êtes supposé avoir configuré un pool de stockage ZFS comme décrit dans le [Chapitre 2](02-zfs_setup.md). Vous pouvez utiliser un pool de stockage différent si vous avez choisi de ne pas utiliser ZFS, mais vous devrez ajuster les réponses aux questions lors de l'initialisation.

## Initialisation de `Incus`

Votre environnement de serveur est prêt. Vous êtes prêt à initialiser Incus. Il s'agit d'un script automatisé qui pose une série de questions pour que votre instance Incus soit opérationnelle :

```bash
incus admin init
```

Voici les questions et nos réponses pour le script, avec une petite explication lorsque cela est nécessaire :

```text
Would you like to use clustering? (yes/no) [default=no]:
```

Si vous êtes intéressé par le clustering, faites des recherches supplémentaires à ce sujet [ici](https://linuxcontainers.org/incus/docs/main/explanation/clustering/)

```text
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

Cela peut sembler contre-intuitif. Vous avez déjà créé votre pool ZFS, mais cela sera clair dans une question ultérieure. Acceptez la valeur par défaut.

```text
Nom du nouveau pool de stockage [default=default] : storage
```

Laisser cette valeur « par défaut » est une option, mais utiliser le même nom que celui que vous avez donné à notre pool ZFS est préférable pour plus de clarté.

```text
Nom du backend de stockage à utiliser (btrfs, dir, lvm, zfs, ceph) [default=zfs] :
```

Vous accepterez le défaut.

```text
Create a new ZFS pool? (yes/no) [default=yes]: no
```

Voici où la question précédente sur la création d'un pool de stockage est résolue.

```text
Name of the existing ZFS pool or dataset: storage
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Metal As A Service (MAAS) n'entre pas dans le cadre de ce document.

```text
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

Vous pouvez activer cette option pour utiliser IPv6 sur vos conteneurs Incus.

```text
Would you like the Incus server to be available over the network? (yes/no) [default=no]: yes
```

Ceci est nécessaire pour faire un instantané du serveur.

```text
Address to bind Incus to (not including port) [default=all]:
Port to bind Incus to [default=8443]:
Trust password for new clients:
Again:
```

Ce mot de passe de confiance vous permettra de vous connecter ou de revenir depuis le serveur de captures instantanées. Définissez-le en l'associant à quelque chose qui a du sens dans votre environnement. Enregistrez cette donnée dans un endroit sécurisé, comme un gestionnaire de mots de passe.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "incus admin init" preseed to be printed? (yes/no) [default=no]:
```

## Définition des privilèges des utilisateurs

Avant de continuer, vous devez créer votre utilisateur `incusadmin` et vous assurer qu'il dispose des privilèges nécessaires. Vous avez besoin que l'utilisateur `incusadmin` puisse utiliser `sudo` pour obtenir les privilèges de `root` et vous avez besoin qu'il soit membre du groupe `incus-admin`. Pour ajouter l'utilisateur et vous assurer qu'il est membre des deux groupes, procédez comme suit :

```bash
useradd -G wheel,incus-admin incusadmin
```

Définition du mot de passe :

```bash
passwd incusadmin
```

Comme pour les autres mots de passe, enregistrez-le dans un endroit sûr.

## Définition des valeurs `subuid` et `subgid` pour `root`

Vous devez définir à la fois la valeur du `subuid` et du `subgid` de l'utilisateur `root` (la plage d'ID d'utilisateur et de groupe subordonnés). Cette valeur devrait être la suivante :

```bash
root:1000000:1000000000
```

Pour ce faire, éditez le fichier `/etc/subuid` et ajoutez cette ligne. Une fois terminé, votre fichier sera come suit :

```bash
root:1000000:1000000000
```

Éditez le fichier `/etc/subgid` et ajoutez cette ligne. Une fois terminé, votre fichier sera come suit :

```bash
incusadmin:100000:65536
root:1000000:1000000000
```

Redémarrez le serveur avant de continuer.
