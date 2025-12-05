---
title: Synchronisation avec `rsync`
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li, Ganna Zhyrnova
tags:
  - synchronisation
  - rsync
---

## Prérequis

Voici ce dont vous aurez besoin pour comprendre et suivre ce guide :

- Un ordinateur fonctionnant sous Rocky Linux
- Être à l'aise avec la modification des fichiers de configuration à partir de la ligne de commande
- Connaissance de l'utilisation d'un éditeur de ligne de commande (nous utilisons `vi` ici, mais n'hésitez pas à le remplacer par votre éditeur favori)
- Vous aurez besoin des droits d'accès `root` ou bien obtenir les privilèges nécessaires grâce à `sudo`
- Les paires de clés SSH publique et privée
- Pouvoir créer un script bash avec `vi` ou votre éditeur préféré et le tester.
- Être capable d'utiliser `crontab` pour automatiser l'exécution du script

## Introduction

L'utilisation de `rsync` sur SSH n'est pas aussi efficace que [lsyncd](../backup/mirroring_lsyncd.md) (qui vous permet de surveiller les modifications apportées à un répertoire ou à un fichier et de le maintenir synchronisé en temps réel), ni aussi flexible que [rsnapshot](../backup/rsnapshot_backup.md) (qui offre la possibilité de sauvegarder plusieurs cibles à partir d'un seul ordinateur). Cependant, il fournit la possibilité de tenir deux ordinateurs à jour selon un calendrier que vous pouvez définir vous-même.

Si vous avez besoin de garder à jour un ensemble de répertoires sur l'ordinateur cible, et vous ne vous souciez pas de la synchronisation en temps réel en tant que fonctionnalité, alors `rsync` par l'intermédiaire de SSH est probablement la meilleure solution.

Vous travaillerez en tant qu'utilisateur `root` pour cette procédure. Connectez-vous en tant qu'utilisateur `root` ou utilisez la commande `sudo -s` pour passer à l'utilisateur `root` dans votre terminal.

### Installation de `rsync`

Il est probable que `rsync` soit déjà installé. Pour vous assurer que `rsync` est à jour, procédez comme suit sur les deux ordinateurs :

```bash
dnf install rsync
```

Si le paquet n'est pas installé, `dnf` vous demandera de confirmer l'installation. S'il est déjà installé, `dnf` cherchera une mise à jour et vous demandera de l'installer.

### Préparation de l’environnement

Cet exemple utilisera `rsync` sur l'ordinateur cible pour extraire de la source au lieu de transférer de la source vers la cible. Pour cela vous devez configurer une [paire de clés SSH](../security/ssh_public_private_keys.md). Après avoir créé la paire de clés SSH, vérifiez l’accès sans mot de passe de l’ordinateur cible à l’ordinateur source.

### `rsync` — Paramètres et Configuration d'un Script

Avant de poursuivre la configuration du script, vous devez décider quels paramètres vous souhaitez utiliser avec `rsync`. Il existe de nombreuses possibilités. Consultez le [manuel de rsync](https://linux.die.net/man/1/rsync) pour une liste complète. La façon la plus courante d'utiliser `rsync` est d'utiliser l'option `-a`, car `-a`, ou `archive`, combine plusieurs options standard. Qu'est-ce que `-a` inclus ?

- `-r`, parcoure les sous-répertoires
- `-l`, maintiens les liens symboliques comme tels
- `-p`, préserve les permissions
- `-t`, préserve date et heure de modification
- `-g`, conserve le groupe
- `-o`, préserve le propriétaire
- `-D`, préserve les fichiers de périphérique

Les seules options supplémentaires dont nous aurons besoin dans cet exemple sont les suivantes :

- `-e`, précise le shell distant à utiliser
- `--delete`, qui indique que si le répertoire cible contient un fichier qui n'existe pas sur la source, il faut le supprimer

Ensuite, configurez un script sur l'ordinateur cible en créant un fichier pour celui-ci (encore une fois, utilisez votre éditeur favori si vous n'êtes pas familier avec `vi`). Pour créer le fichier, utilisez la commande suivante :

```bash
vi /usr/local/sbin/rsync_dirs
```

Ajoutez le contenu :

```bash
#!/usr/bin/env bash
/usr/bin/rsync -ae ssh --delete root@source.domain.com:/home/your_user /home
```

Remplacez `source.domain.com` par votre propre nom de domaine, nom d’hôte ou adresse IP.

Rendez le script exécutable :

```bash
chmod +x /usr/local/sbin/rsync_dirs
```

## Test

Les scripts vous permettent de tester sans souci.

!!! warning "Avertissement"

    Dans ce cas, nous partons du principe que votre répertoire personnel n'existe pas sur l'ordinateur cible. **S'il existe déjà, vous devriez faire une copie de sécurité avant de lancer le script !**

Exécutez le script :

```bash
/usr/local/sbin/rsync_dirs
```

Si tout se passe bien, vous obtiendrez une copie synchronisée de votre répertoire personnel sur l'ordinateur cible. Vérifiez pour être sûr que c'est bien le cas.

En supposant que tout a bien marché comme prévu, continuez en créant un nouveau fichier dans votre répertoire personnel sous `/home/` de l'ordinateur source :

```bash
touch /home/your_user/testfile.txt
```

Relancez le script :

```bash
/usr/local/sbin/rsync_dirs
```

Ensuite vérifiez que la cible reçoit bien le nouveau fichier. Si oui, l'étape suivante consiste en la vérification de la bonne marche de l'effacement d'un fichier. Effacez le fichier créé précédemment sur l'ordinateur source :

```bash
rm -f /home/your_user/testfile.txt
```

Relancez le script :

```bash
/usr/local/sbin/rsync_dirs
```

Vérifiez que le fichier n'existe plus sur l'ordinateur cible.

Finalement créons sur l'ordinateur cible un fichier qui n'existe pas sur l'ordinateur source :

```bash
touch /home/your_user/a_different_file.txt
```

Relancez le script une dernière fois :

```bash
/usr/local/sbin/rsync_dirs
```

Le fichier qui vient d'être créé sur l'ordinateur de destination devrait disparaître, du fait qu'il n'existe pas sur l'ordinateur source.

En supposant que tout fonctionne correctement, modifiez le script pour synchroniser tous les répertoires requis.

## Automatisation complète

Vous ne souhaiterez probablement pas exécuter ce script chaque fois que vous voulez effectuer une synchronisation manuelle. Utilisez un `crontab` pour effectuer cette opération automatiquement selon un calendrier précis. Supposons que vous désiriez lancer le script à 23: 00 chaque soir :

```bash
crontab -e
```

Cela s'affichera et ressemblera à ceci :

```bash
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
#
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

!!! info "Info"

    L'exemple `crontab` montre un fichier vide mais commenté. Les commentaires n'apparaissent pas sur tous les ordinateurs et peuvent correspondre à un fichier vide. Sur un ordinateur en service vous pouvez voir d’autres entrées.

Le `crontab` correspond à une horloge de 24 heures. Vous devrez insérer la ligne suivante au bas du fichier :

```crontab
00 23   *  *  *    /usr/local/sbin/rsync_dirs
```

Cela indique d'exécuter cette commande à minuit et à 23 h tous les jours, tous les mois et tous les jours de la semaine. Enregistrez votre entrée `crontab` comme suit :

++shift+colon+"w"+"q"+exclam++

## Paramètres facultatifs

```bash
-n: Dry-Run to see what files would be transferred
-v: list out all the files that are being transferred
-vvv: to provide debug info while transferring files
-z: to enable compression during the transfer
```

## Conclusion

Bien que `rsync` ne sois pas aussi sophistiqué que d'autres outils, il propose une solution simple de synchronisation de fichiers très utile.
