---
title: installation et utilisation de inotify-tools
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# Compiler et installer

Effectuez les opérations suivantes sur le serveur. Dans votre environnement, certains paquets dépendants peuvent être manquants. Installez les en utilisant : `dnf -y install autoconf automake libtool`

```bash
[root@Rocky ~]# wget -c https://github.com/inotify-tools/inotify-tools/archive/refs/tags/3.21.9.6.tar.gz
[root@Rocky ~]# tar -zvxf 3.21.9.6.tar.gz -C /usr/local/src/
[root@Rocky ~]# cd /usr/local/src/inotify-tools-3.21.9.6/
[root@Rocky /usr/local/src/inotify-tools-3.21.9.6]# ./autogen.sh && \
./configure --prefix=/usr/local/inotify-tools && \
make && \
make install
...
[root@Rocky ~]# ls /usr/local/inotify-tools/bin/
inotifywait inotifywatch
```

Ajouter la variable d'environnement PATH, l'écrire dans le fichier de configuration et laisser prendre effet définitivement.

```bash
[root@Rocky ~]# vim /etc/profile
...
PATH=$PATH:/usr/local/inotify-tools/bin/
[root@Rocky ~]# . /etc/profile
```

**Pourquoi ne pas utiliser le paquet RPM inotify-tools du dépôt EPEL ? Ou bien procéder avec le code source pour compiler et installer ?**

L'auteur estime que la transmission de données à distance est une question d'efficacité, en particulier dans un environnement de production, où il y a un grand nombre de fichiers à synchroniser et un seul fichier peut être particulièrement grand. De plus, la nouvelle version aura quelques corrections de bugs et des extensions de fonctions et peut-être l'efficacité de la transmission de la nouvelle version sera plus élevée, donc l'auteur recommande d'installer inotify-tools par code source. Bien sûr, c'est la préférence personnelle de l'auteur, les utilisateurs sont libres de leur choix.

## Ajustement des paramètres du noyau

Vous pouvez ajuster les paramètres du noyau en fonction des besoins de l'environnement de production. Par défaut, il y a trois fichiers dans **/proc/sys/fs/inotity/**

```bash
[root@Rocky ~]# cd /proc/sys/fs/inotify/
[root@Rocky /proc/sys/fs/inotify]# cat max_queued_events ;cat max_user_instances ;cat max_user_watches
16384
128
28014
```

* max_queued_events-maximum monitor queue size, default 16384
* max_user_instances-the maximum number of monitoring instances, the default is 128
* max_user_watches-the maximum number of files monitored per instance, the default is 8192

Enregistrer certains paramètres dans le fichier **/etc/sysctl.conf** comme dans les exemples suivants. Ensuite, utilisez `sysctl -p` pour que les fichiers soient pris en compte

```txt
fs.inotify.max_queued_events = 16384
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 1048576
```

## Commandes associées

L'outil inotify-tools a deux commandes, à savoir :
*   **inotifywait** : pour une surveillance continue, résultats de sortie en temps réel. Elle est généralement utilisée avec l'outil de sauvegarde incrémentiel rsync. Parce qu'il s'agit d'une surveillance du système de fichiers, la commande peut être utilisée dans un script. Nous présenterons le script spécifique plus tard.
*   **inotifywatch** : pour une surveillance à court terme, les résultats de sortie après que la tâche soit terminée.

`inotifywait` a principalement les options suivantes :

```txt
-m Surveillance continue
-r Surveillance Recursive
-q Simplifie information de sortie
-e Spécifie le type d'événement des données de surveillance, plusieurs types d'événements sont séparés par des virgules
```

Les types d'événements sont les suivants :

| Type d'événement | Observation                                                                                     |
| ---------------- | ----------------------------------------------------------------------------------------------- |
| access           | Accès au contenu d'un fichier ou d'un répertoire                                                |
| modifier         | Le contenu du fichier ou du répertoire est enregistré                                           |
| attrib           | Les attributs du fichier ou du répertoire sont modifiés                                         |
| close_write      | Le fichier ou le répertoire est ouvert en mode écriture puis fermé                              |
| close_nowrite    | Le fichier ou le répertoire est fermé après avoir été ouvert en mode lecture seule              |
| close            | Indépendamment du mode lecture/écriture, le fichier ou le répertoire est fermé                  |
| open             | Le fichier ou répertoire est ouvert                                                             |
| moved_to         | Un fichier ou un répertoire est déplacé vers le répertoire surveillé                            |
| moved_from       | Un fichier ou un répertoire est déplacé du répertoire surveillé                                 |
| move             | Il y a des fichiers ou répertoires qui sont déplacés ou supprimés du répertoire de surveillance |
| move_self        | Le fichier ou répertoire surveillé a été déplacé                                                |
| create           | Il y a des fichiers ou répertoires créés dans le répertoire surveillé                           |
| delete           | Un fichier ou un répertoire dans le répertoire surveillé est supprimé                           |
| delete_self      | The file or directory has been deleted                                                          |
| unmount          | Système de fichiers contenant des fichiers ou des répertoires non montés                        |

Exemple : `[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/`

## Démonstration de la commande `inotifywait`

Tapez la commande dans le premier terminal pts/0 et, après avoir appuyé sur Entrée, la fenêtre est verrouillée indiquant qu'elle surveille

```bash
[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/

```

Dans le deuxième terminal pts/1, allez dans le répertoire /rsync/ et créez un fichier.

```bash
[root@Rocky ~]# cd /rsync/
[root@Rocky /rsync]# touch inotify
```

Retour au premier terminal pts/0, les informations de sortie sont les suivantes :

```bash
[root@Rocky ~]# inotifywait -mrq -e create,delete /rsync/
/rsync/ CREATE inotify
```

## Combinaison de  `inotifywait` et `rsync`

!!! tip "Astuce"

    Nous opérons sur le serveur Rocky Linux 8 en utilisant le protocole SSH pour la démonstration.

Pour l'authentification sans mot de passe du protocole SSH, veuillez vous référer à cet [article](05_rsync_authentication-free_login.md). Un exemple du contenu d'un script bash est le suivant. Vous pouvez ajouter différentes options après la commande en fonction de vos besoins. Par exemple, vous pouvez ajouter `--delete` après la commande `rsync`.

```bash
#!/bin/bash
a="/usr/local/inotify-tools/bin/inotifywait -mrq -e modify,move,create,delete /rsync/"
b="/usr/bin/rsync -avz /rsync/* testfedora@192.168.100.5:/home/testfedora/"
$a | while read directory event file
    do
        $b &>> /tmp/rsync.log
    done
```

```bash
[root@Rocky ~]# chmod +x rsync_inotify.sh
[root@Rocky ~]# bash /root/rsync_inotify.sh &
```

!!! tip "Astuce"

    Lors de l'utilisation du protocole SSH pour la transmission de la synchronisation des données, si le port de service SSH de la machine cible n'est pas 22, vous pouvez utiliser une méthode similaire à cela ——
    `b="/usr/bin/rsync -avz -e 'ssh -p [port-number]' /rsync/* testfedora@192. 68.100.5:/home/testfedora/"`

!!! tip "Astuce"

    Si vous voulez lancer automatiquement ce script au démarrage
    `[root@Rocky ~]# echo "bash /root/rsync_inotify. h &" >> /etc/rc.local`
    `[root@Rocky ~]# chmod +x /etc/rc.local`

Si vous utilisez le protocole rsync pour la synchronisation, vous devez configurer le service rsync de la machine cible, veuillez vous référer à [rsync demo 02](03_rsync_demo02.md), [fichier de configuration rsync](04_rsync_configure.md), [connexion rsync automatique](05_rsync_authentication-free_login.md)
