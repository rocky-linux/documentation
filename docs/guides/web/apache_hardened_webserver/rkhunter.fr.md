---
title: Rootkit Hunter
author: Steven Spencer
contributors: Ezequiel Bruni, Andrew Thiesen
tested_with: 8.8, 9.2
tags:
  - serveur
  - sécurité
  - rkhunter
---

# Rootkit hunter

## Introduction

Rootkit hunter`(rkhunter`) est un outil bien connu pour vérifier les vulnérabilités, les rootkits, les portes dérobées et les éventuels exploits locaux sur un serveur. Il est possible de l'utiliser sur _n'importe quel_ serveur destiné à _n’importe_ quel usage. Une fois réglé et automatisé, il peut signaler toute activité suspecte à l'administrateur du système. Cette procédure décrit l'installation, le réglage et l'utilisation de rootkit hunter.

## Prérequis

* Maîtrise d'un éditeur de ligne de commande (nous utilisons `vi` dans cet exemple)
* Être à l'aise avec la saisie de commandes à partir de la ligne de commande, la consultation de journaux et d'autres tâches générales d'administrateur de systèmes
* Il est utile de comprendre ce qui peut déclencher une réponse à des fichiers modifiés sur le système de fichiers (comme les mises à jour de paquets)
* Exécuter toutes les commandes en tant que root ou en tant qu'utilisateur normal avec `sudo`

Ce document a été écrit à l'origine en conjonction avec les routines du serveur web durci Apache, mais il fonctionne également sur un serveur utilisant n'importe quel logiciel.

## Introduction

`rkhunter` (Root Kit Hunter) est un outil Unix qui recherche les rootkits, les portes dérobées et les éventuels exploits locaux. Il s'agit d'un élément important d'un serveur renforcé, qui informe rapidement l'administrateur lorsque quelque chose de suspect se produit sur le système de fichiers du serveur, à condition qu'il soit correctement configuré.

`rkhunter` n'est qu'un élément parmi d'autres d'une configuration de serveur web Apache renforcé. Utilisez-le seul ou avec d'autres outils pour maximiser la sécurité. Si vous souhaitez l'utiliser avec d'autres outils de durcissement, reportez-vous au [guide du serveur Web Apache renforcé](index.md).

Ce document utilise également toutes les hypothèses et conventions décrites dans le document original. Il est conseillé de l'examiner avant de poursuivre.

## Étapes globales

1. installer `rkhunter`
2. configurer `rkhunter`
3. configurer le courrier électronique et s'assurer qu'il fonctionne correctement
4. exécuter `rkhunter` manuellement pour générer une liste d'avertissements afin de tester vos paramètres de messagerie`(rkhunter --check`)
5. exécuter `rkhunter --propupd` pour générer un fichier `rkhunter.dat` que `rkhunter` utilisera à partir de maintenant comme base de référence pour les vérifications ultérieures.

## Installation de `rkhunter`

`rkhunter` nécessite le dépôt EPEL (Extra Packages for Enterprise Linux). Installez ce référentiel si ce n'est pas déjà fait :

```
dnf install epel-release
```

Installer `rkhunter` :

```
dnf install rkhunter
```

## Configuration de `rkhunter`

Les seules options de configuration que vous _devez_ définir sont celles qui concernent l'envoi des rapports à l'administrateur.

!!! warning "Avertissement"

    La modification de _tout_ fichier de configuration sous Linux comporte certains risques. Avant de modifier **n'importe quel** fichier de configuration sous Linux, il est recommandé de créer une sauvegarde du fichier de configuration _original_, au cas où vous devriez revenir à la configuration originale.


Pour modifier le fichier de configuration, exécutez la commande suivante :

```
vi /etc/rkhunter.conf
```

Recherche de :

```
#MAIL-ON-WARNING=me@mydomain root@mydomain
```

Supprimez la marque de commentaire et modifiez l'`adresse me@mydomain.com` pour qu'elle corresponde à votre adresse électronique.

Remplacez `root@mydomain` par `root@whatever_the_server_name_is`.

Vous voudrez probablement décommenter (et modifier en fonction de vos besoins) la ligne `MAIL-CMD` :


```
MAIL_CMD=mail -s "[rkhunter] Avertissements trouvés pour ${HOST_NAME}"
```

Il se peut que vous deviez également configurer [les courriels de rapport Postfix](../../email/postfix_reporting.md) pour que la section e-mail fonctionne correctement.

## Exécution de `rkhunter`

Exécutez `rkhunter` manuellement en saisissant la ligne de commande. Un job cron se charge de lancer `rkhunter` pour vous automatiquement dans `/etc/cron.daily`. Si vous souhaitez automatiser la procédure selon un calendrier différent, consultez le guide [Automatisation des tâches cron](../../automation/cron_jobs_howto.md).

Vous devrez également déplacer le script ailleurs que dans `/etc/cron.daily/`, par exemple dans `/usr/local/sbin/` et l'appeler à partir de votre tâche cron personnalisée. La méthode la plus simple consiste à laisser intacte la configuration par défaut de `cron.daily`.

Si vous souhaitez tester `rkhunter` avant de commencer, y compris toutes les fonctionnalités de messagerie, exécutez `rkhunter --check` à partir de la ligne de commande. S'il est installé et fonctionne correctement, vous devriez recevoir un message similaire à celui qui suit :

```
[root@sol admin]# rkhunter --check
[Rootkit Hunter version 1.4.6]

Checking system commands...

Vérification de la commande 'strings
- Vérification de la commande 'strings'                               [OK]

Vérification des bibliothèques partagées
- Vérification des variables de préchargement                               [Aucun trouvé]
- Vérification des bibliothèques préchargées                               [Aucun trouvé]
- Vérification de la variable LD_LIBRARY_PATH                               [Non trouvée]

Vérification des propriétés des fichiers
- Vérification des prérequis                                [Avertissement]
- /usr/bin/awk [                               OK]
- /usr/bin/basename                                [OK]
- /usr/bin/bash                                [OK]
- /usr/bin/cat                                [OK]
- /usr/bin/chattr                                [OK]
- /usr/bin/chmod                                [OK]
- /usr/bin/chown                                [OK]
- /usr/bin/cp                                [OK]
- /usr/bin/curl                                [OK]
- /usr/bin/cut                                [OK]
- /usr/bin/date                                [OK]
- /usr/bin/df                                [OK]
- /usr/bin/diff                                [OK]
- /usr/bin/dirname                                [OK]
- /usr/bin/dmesg                                [OK]
- /usr/bin/diff                                [OK]
- /usr/bin/dirname                                [OK]
- /usr/bin/du                                [OK]
- /usr/bin/echo                                [OK]
- /usr/bin/ed                                [OK]
- /usr/bin/egrep                                [Avertissement]
- /usr/bin/env                                [OK]
- /usr/bin/fgrep                                [Avertissement]
- /usr/bin/file                                [OK]
- /usr/bin/find                                [OK]
- /usr/bin/GET                                [OK]
- /usr/bin/grep                                [OK]
- /usr/bin/groups                                [OK]
- /usr/bin/head                                [OK]
- /usr/bin/id                                [OK]
- /usr/bin/ipcs                                [OK]
- /usr/bin/kill                                [OK]
- /usr/bin/killall                                [OK]
- /usr/bin/last                                [OK]
- /usr/bin/lastlog                                [OK]
- /usr/bin/ldd                                [OK]
- /usr/bin/less                                [OK]
- /usr/bin/locate                                [OK]
- /usr/bin/logger                                [OK]
- /usr/bin/login                                [OK]
- /usr/bin/ls                                [OK]
- /usr/bin/lsattr                                [OK]
- /usr/bin/lsof                                [OK]
- /usr/bin/mail                                [OK]
- /usr/bin/md5sum                                [OK]
- /usr/bin/mktemp                                [OK]
- /usr/bin/more                                [OK]
- /usr/bin/mount                                [OK]
- /usr/bin/mv                                [OK]
- /usr/bin/netstat                                [OK]
- /usr/bin/newgrp                                [OK]
- /usr/bin/passwd                                [OK]
- /usr/bin/perl                                [OK]
- /usr/bin/pgrep                                [OK]
- /usr/bin/ping                                [OK]
- /usr/bin/pkill                                [OK]
- /usr/bin/ps                                [OK]
- /usr/bin/pstree                                [OK]
- /usr/bin/pwd                                [OK]
- /usr/bin/readlink                                [OK]
- /usr/bin/rkhunter                                [OK]
- /usr/bin/rpm                                [OK]
- /usr/bin/runcon                                [OK]
- /usr/bin/sed                                [OK]
- /usr/bin/sestatus                                [OK]
- /usr/bin/sh                                [OK]
- /usr/bin/sha1sum                                [OK]
- /usr/bin/sha224sum                                [OK]
- /usr/bin/sha256sum                                [OK]
- /usr/bin/sha384sum                                [OK]
- /usr/bin/sha512sum                                [OK]
- /usr/bin/size                                [OK]
- /usr/bin/sort                                [OK]
- /usr/bin/ssh                                [OK]
- /usr/bin/stat                                [OK]
- /usr/bin/strace                                [OK]
- /usr/bin/strings                                [OK]
- /usr/bin/su                                [OK]
- /usr/bin/sudo                                [OK]
- /usr/bin/tail                                [OK]
- /usr/bin/test                                [OK]
- /usr/bin/top                                [OK]
- /usr/bin/touch                                [OK]
- /usr/bin/tr                                [OK]
- /usr/bin/uname                                [OK]
- /usr/bin/uniq                                [OK]
- /usr/bin/users                                [OK]
- /usr/bin/vmstat                                [OK]
- /usr/bin/w                                [OK]
- /usr/bin/watch                                [OK]
- /usr/bin/wc                                [OK]
- /usr/bin/wget                                [OK]
- /usr/bin/whatis                                [OK]
- /usr/bin/whereis                                [OK]
- /usr/bin/which                                [OK]
- /usr/bin/who                                [OK]
- /usr/bin/whoami                                [OK]
- /usr/bin/numfmt                                [OK]
- /usr/bin/gawk                                [OK]
- /usr/bin/s-nail                                [OK]
- /usr/bin/whatis.man-db                                [OK]
- /usr/bin/kmod                                [OK]
- /usr/bin/systemctl                                [OK]
- /usr/sbin/adduser                                [OK]
- /usr/sbin/chroot                                [OK]
- /usr/sbin/depmod                                [OK]
- /usr/sbin/fsck                                [OK]
- /usr/sbin/fuser                                [OK]
- /usr/sbin/groupadd                                [OK]
- /usr/sbin/groupdel                                [OK]
- /usr/sbin/groupmod                                [OK]
- /usr/sbin/grpck                                [OK]
- /usr/sbin/ifconfig                                [OK]
- /usr/sbin/init                                [OK]
- /usr/sbin/insmod                                [OK]
- /usr/sbin/ip                                [OK]
- /usr/sbin/lsmod                                [OK]
- /usr/sbin/modinfo                                [OK]
- /usr/sbin/modprobe                                [OK]
- /usr/sbin/nologin                                [OK]
- /usr/sbin/ping                                [OK]
- /usr/sbin/pwck                                [OK]
- /usr/sbin/rmmod                                [OK]
- /usr/sbin/route                                [OK]
- /usr/sbin/rsyslogd                                [OK]
- /usr/sbin/runlevel                                [OK]
- /usr/sbin/sestatus                                [OK]
- /usr/sbin/sshd                                [OK]
- /usr/sbin/sulogin                                [OK]
- /usr/sbin/sysctl                                [OK]
- /usr/sbin/useradd                                [OK]
- /usr/sbin/userdel                                [OK]
- /usr/sbin/usermod                                [OK]
- /usr/sbin/vipw                                [OK]
- /usr/libexec/gawk                                [OK]
- /usr/lib/systemd/systemd                                [OK]

[Appuyez sur <ENTER&gt ; pour continuer]
```

Si la configuration du courrier électronique pose des problèmes, ne passez pas à l'étape suivante. Lorsque la confirmation du courrier électronique fonctionne, mais avant d'autoriser l'exécution automatique de `rkhunter`, exécutez à nouveau la commande manuellement avec l'option "--propupd" pour créer le fichier `rkhunter.dat`. Cela permet de reconnaître votre environnement et votre configuration :

```
rkhunter --propupd
```

## Conclusion

`rkhunter` fait partie d'une stratégie de serveur renforcé qui peut aider à surveiller le système de fichiers et à signaler tout problème à l'administrateur. C'est peut-être l'un des outils de renforcement les plus faciles à installer, à configurer et à utiliser.
