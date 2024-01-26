---
title: Connexion rsync sans mot de passe
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# Préface

Suivant la [brève description de rsync](01_rsync_overview.md) nous savons que rsync est un outil de synchronisation incrémental. Chaque fois que la commande `rsync` est exécutée, les données peuvent être synchronisées une fois, mais les données ne peuvent pas être synchronisées en temps réel. Comment faire ?

Grâce à inotify-tools, cet outil peut réaliser une synchronisation à sens unique en temps réel. Comme il s'agit de synchronisation des données en temps réel, il est nécessaire de se connecter sans authentification par mot de passe.

**Peu importe qu'il s'agisse du protocole rsync ou du protocole SSH, les deux peuvent obtenir une connexion sans mot de passe.**

## Authentification sans mot de passe du protocole SSH

Premièrement, générez une paire de clés publique et privée sur le client et appuyer sur Entrée après avoir tapé la commande. La paire de clés est enregistrée dans le répertoire <font color=red>/root/.ssh/</font>.

```bash
[root@fedora ~]# ssh-keygen -t rsa -b 2048
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256: TDA3tWeRhQIqzTORLaqy18nKnQOFNDhoAsNqRLo1TMg root@fedora
The key's randomart image is:
+---[RSA 2048]----+
|O+. +o+o. .+. |
|BEo oo*....o. |
|*o+o..*.. ..o |
|.+..o. = o |
|o o S |
|. o |
| o +. |
|....=. |
| .o.o. |
+----[SHA256]-----+
```

Ensuite, utilisez la commande `scp` pour télécharger le fichier de clé publique sur le serveur. Par exemple, nous téléchargeons cette clé publique à l'utilisateur **testrsync**

```bash
[root@fedora ~]# scp -P 22 /root/.ssh/id_rsa.pub root@192.168.100.4:/home/testrsync/
```

```bash
[root@Rocky ~]# cat /home/testrsync/id_rsa.pub >> /home/testrsync/.ssh/authorized_keys
```

Essayez de vous connecter sans authentification secrète.

```bash
[root@fedora ~]# ssh -p 22 testrsync@192.168.100.4
Last login: Tue Nov 2 21:42:44 2021 from 192.168.100.5
[testrsync@Rocky ~]$
```

!!! tip "Astuce"

    Le fichier de configuration du serveur **/etc/ssh/sshd_config** doit être ouvert <font color=red>PubkeyAuthentication yes</font>

## Connexion sans mot de passe pour le protocole rsync

Du côté client, le service rsync prépare une variable d'environnement pour **RSYNC_PASSWORD** du système, qui est vide par défaut, comme indiqué ci-dessous :

```bash
[root@fedora ~]# echo "$RSYNC_PASSWORD"

[root@fedora ~]#
```

Si vous voulez obtenir l'authentification sans mot de passe, vous devez simplement assigner une valeur à cette variable. La valeur assignée est le mot de passe précédemment défini pour l'utilisateur virtuel <font color=red>li</font>. En même temps, déclarer cette variable comme une variable globale.

```bash
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

```bash
[root@fedora ~]# export RSYNC_PASSWORD=13579
```

Essayez ! Aucun nouveau fichier n'apparaît ici, donc la liste des fichiers transférés n'est pas affichée.

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root/
receiving incremental file list
./

sent 30 bytes received 193 bytes 148.67 bytes/sec
total size is 883 speedup is 3.96
```

!!! tip "Tip"

    Vous pouvez écrire cette variable dans **/etc/profile** pour qu'elle prenne effet définitivement. Le contenu est : `export RSYNC_PASSWORD=13579`
