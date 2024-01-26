---
title: démo rsync 01
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# Préface

`rsync` doit effectuer l'authentification de l'utilisateur avant la synchronisation des données. **Il y a deux méthodes de protocole d'authentification : protocole SSH et protocole rsync (le port par défaut de rsync est 873)**

* Méthode de connexion de vérification du protocole SSH : utiliser le protocole SSH comme base pour l'authentification de l'identité de l'utilisateur (c'est-à-dire utiliser l'utilisateur système et le mot de passe de GNU/Linux lui-même pour la vérification), puis effectuer une synchronisation des données.
* méthode de connexion de vérification du protocole rsync : utilisez le protocole rsync pour l'authentification de l'utilisateur (utilisateurs système non-GNU/Linux, similaires aux utilisateurs virtuels vsftpd), puis effectuez la synchronisation des données.

Avant la démonstration spécifique de la synchronisation rsync, vous devez utiliser la commande `rsync`. Dans Rocky Linux 8, le paquet rpm rsync  est installé par défaut et la version est 3.1.3-12, comme suit :

```bash
[root@Rocky ~]# rpm -qa|grep rsync
rsync-3.1.3-12.el8.x86_64
```

```txt
Basic format: rsync [options] original location target location
Commonly used options:
-a: archive mode, recursive and preserves the attributes of the file object, which is equivalent to -rlptgoD (without -H, -A, -X)
-v: Display detailed information about the synchronization process
-z: compress when transferring files
-H: Keep hard link files
-A: retain ACL permissions
-X: retain chattr permissions
-r: Recursive mode, including all files in the directory and subdirectories
-l: still reserved for symbolic link files
-p: Permission to retain file attributes
-t: time to retain file attributes
-g: retain the group belonging to the file attribute (only for super users)
-o: retain the owner of the file attributes (only for super users)
-D: Keep device files and other special files
```

Utilisation favorisée par l'auteur : `rsync -avz original location target location`

## Description de l'environnement

| Élément                 | Observation      |
| ----------------------- | ---------------- |
| Rocky Linux 8 (Serveur) | 192.168.100.4/24 |
| Fedora 34 (client)      | 192.168.100.5/24 |

Vous pouvez utiliser Fedora 34 pour télécharger

```mermaid
graph LR;
RockyLinux8-->|pull/download|Fedora34;
Fedora34-->|push/upload|RockyLinux8;
```

Vous pouvez également utiliser Rocky Linux 8 pour télécharger

```mermaid
graph LR;
RockyLinux8-->|push/upload|Fedora34;
Fedora34-->|pull/download|RockyLinux8;
```

## Démonstration basée sur le protocole SSH

!!! tip "Astuce"

    Ici, Rocky Linux 8 et Fedora 34 utilisent l'utilisateur root pour se connecter. Fedora 34 est le client et Rocky Linux 8 le serveur.

### pull/download

Puisqu'il est basé sur le protocole SSH, nous allons créer d'abord un utilisateur sur le serveur :

```bash
[root@Rocky ~]# useradd testrsync
[root@Rocky ~]# passwd testrsync
```

Du côté du client, nous utilisons pull/download et le fichier sur le serveur est /rsync/aabbcc

```bash
[root@fedora ~]# rsync -avz testrsync@192.168.100.4:/rsync/aabbcc /root
testrsync@192.168.100.4 ' s password:
receiving incremental file list
aabbcc
sent 43 bytes received 85 bytes 51.20 bytes/sec
total size is 0 speedup is 0.00
[root@fedora ~]# cd
[root@fedora ~]# ls
aabbcc
```
Le transfert a réussi.

!!! tip "Astuce"

    Si le port SSH du serveur n'est pas le port par défaut 22, vous pouvez spécifier le port de manière similaire---`rsync -avz -e 'ssh -p [port]' `.

### push/upload

```bash
[root@fedora ~]# touch fedora
[root@fedora ~]# rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
rsync: mkstemp " /rsync/.anaconda-ks.cfg.KWf7JF " failed: Permission denied (13)
rsync: mkstemp " /rsync/.fedora.fL3zPC " failed: Permission denied (13)
sent 760 bytes received 211 bytes 277.43 bytes/sec
total size is 883 speedup is 0.91
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1330) [sender = 3.2.3]
```

**Demande de permission refusée, comment y faire face ?**

Vérifiez d'abord les permissions du répertoire /rsync/ . Évidemment, il n'y a pas de permission "w". Nous pouvons utiliser `setfacl` pour accorder des permission :

```bash
[root@Rocky ~ ] # ls -ld /rsync/
drwxr-xr-x 2 root root 4096 November 2 15:05 /rsync/
```

```bash
[root@Rocky ~ ] # setfacl -mu:testrsync:rwx /rsync/
[root@Rocky ~ ] # getfacl /rsync/
getfacl: Removing leading ' / ' from absolute path names
# file: rsync/
# owner: root
# group: root
user::rwx
user:testrsync:rwx
group::rx
mask::rwx
other::rx
```

Essayez à nouveau !

```bash
[root@fedora ~ ] # rsync -avz /root/* testrsync@192.168.100.4:/rsync/
testrsync@192.168.100.4 ' s password:
sending incremental file list
anaconda-ks.cfg
fedora
sent 760 bytes received 54 bytes 180.89 bytes/sec
total size is 883 speedup is 1.08
```
