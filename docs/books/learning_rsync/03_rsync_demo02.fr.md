---
title: rsync - Démo 02
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-11-04
---

# Démonstration basée sur le protocole rsync

Dans vsftpd, il y a des utilisateurs virtuels (utilisateurs personnalisés par l'administrateur) parce qu'il est très déconseillé d'utiliser des utilisateurs anonymes et des utilisateurs locaux. On sait qu'un serveur basé sur le protocole SSH doit garantir l'existence d'un système d'utilisateurs. Quand il y a beaucoup d'exigences de synchronisation, il peut être nécessaire de créer de nombreux utilisateurs. Cela ne répond évidemment pas aux normes de fonctionnement et de maintenance de GNU/Linux (plus il y a d'utilisateurs, plus il y a d'utilisateurs non sécurisés). Dans rsync, pour des raisons de sécurité, il y a une méthode d'authentification du protocole rsync.

**Comment faire?**

Il suffit d'écrire les paramètres et valeurs correspondants dans le fichier de configuration. Dans Rocky Linux 8, vous devez créer manuellement le fichier <font color=red>/etc/rsyncd.conf</font>.

```bash
[root@Rocky ~]# touch /etc/rsyncd.conf
[root@Rocky ~]# vim /etc/rsyncd.conf
```

Certains paramètres de ce fichier et leurs valeurs sont présentés ci-dessous, [ici](04_rsync_configure.md) vous trouverez des descriptions de paramètres supplémentaires :

| Élément                                   | Observation                                                                                                                                                                                        |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| address = 192.168.100.4                   | L'adresse IP sur laquelle rsync écoute par défaut                                                                                                                                                  |
| port = 873                                | port d'écoute par défaut de rsync                                                                                                                                                                  |
| pid file = /var/run/rsyncd.pid            | Emplacement du fichier pid du processus                                                                                                                                                            |
| log file = /var/log/rsyncd.log            | Emplacement du fichier log                                                                                                                                                                         |
| [share]                                   | Partage de nom                                                                                                                                                                                     |
| comment = rsync                           | Remarques ou informations de description                                                                                                                                                           |
| path = /rsync/                            | L'emplacement du chemin système où il est situé                                                                                                                                                    |
| read only = yes                           | yes signifie lecture seule, pas d'écriture                                                                                                                                                         |
| dont compress = \*.gz \*.gz2 \*.zip | Quels types de fichiers ne sont pas compressés                                                                                                                                                     |
| auth users = li                           | Activez les utilisateurs virtuels et définissez un utilisateur virtuel. Besoin de le créer vous-même                                                                                               |
| secrets file = /etc/rsyncd_users.db       | Utilisé pour spécifier l'emplacement du fichier de mot de passe de l'utilisateur virtuel, qui doit se terminer en .db. Le format de contenu du fichier est "Username : mot de passe", un par ligne |

!!! tip "tip"

    La permission du fichier de mot de passe doit être <font color=red>600</font>.

Écrire du contenu du fichier dans <font color=red>/etc/rsyncd.conf</font> et écrire le nom d'utilisateur et le mot de passe dans /etc/rsyncd_users.db, la permission est de 600

```bash
[root@Rocky ~]# cat /etc/rsyncd.conf
address = 192.168.100.4
port = 873
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
[share]
comment = rsync
path = /rsync/
read only = yes
dont compress = *.gz *.bz2 *.zip
auth users = li
secrets file = /etc/rsyncd_users.db
[root@Rocky ~]# ll /etc/rsyncd_users.db
-rw------- 1 root root 9 November 2 16:16 /etc/rsyncd_users.db
[root@Rocky ~]# cat /etc/rsyncd_users.db
li:13579
```

Vous devrez peut-être executer `dnf -y install rsync-daemon` avant de pouvoir démarrer le service : `systemctl start rsyncd.service`

```bash
[root@Rocky ~]# systemctl start rsyncd.service
[root@Rocky ~]# netstat -tulnp
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      691/sshd            
tcp        0      0 192.168.100.4:873       0.0.0.0:*               LISTEN      4607/rsync          
tcp6       0      0 :::22                   :::*                    LISTEN      691/sshd            
udp        0      0 127.0.0.1:323           0.0.0.0:*                           671/chronyd         
udp6       0      0 ::1:323                 :::*                                671/chronyd  
```

## pull/download

Créer un fichier dans le serveur pour vérification : `[root@Rocky]# touch /rsync/rsynctest.txt`

Le client fait ce qui suit :

```bash
[root@fedora ~]# rsync -avz li@192.168.100.4::share /root
Password:
receiving incremental file list
./
rsynctest.txt
sent 52 bytes received 195 bytes 7.16 bytes/sec
total size is 883 speedup is 3.57
[root@fedora ~]# ls
aabbcc anaconda-ks.cfg fedora rsynctest.txt
```

success ! En plus de l'écriture ci-dessus basée sur le protocole rsync, vous pouvez également écrire comme ceci : `rsync://li@10.1.2.84/share`

## push/upload

```bash
[root@fedora ~]# touch /root/fedora.txt
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
rsync: [sender] read error: Connection reset by peer (104)
rsync error: error in socket IO (code 10) at io.c(784) [sender = 3.2.3]
```

On vous indique que l'erreur de lecture est liée à la configuration "read only = yes" du serveur. Changez-la en "no" et redémarrez le service `[root@Rocky ~]# systemctl restart rsyncd.service`

Essayez à nouveau, à l'affichage de la permission refusée :

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
rsync: mkstemp " /.fedora.txt.hxzBIQ " (in share) failed: Permission denied (13)
sent 206 bytes received 118 bytes 92.57 bytes/sec
total size is 883 speedup is 2.73
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1330) [sender = 3.2.3]
```

Notre utilisateur virtuel ici est <font color=red>li</font>, qui est mappé à l'utilisateur système <font color=red>nobody</font> par défaut. Bien sûr, vous pouvez le changer à d'autres utilisateurs du système. En d'autres termes, nobody n'a pas de permission d'écriture dans le répertoire /rsync/ . Bien sûr, nous pouvons utiliser `[root@Rocky ~]# setfacl -mu:nobody:rwx /rsync/` , essayer à nouveau.

```bash
[root@fedora ~]# rsync -avz /root/* li@192.168.100.4::share
Password:
sending incremental file list
fedora.txt
sent 206 bytes received 35 bytes 96.40 bytes/sec
total size is 883 speedup is 3.66
```
