---
title: Fichier de configuration rsync
author: tianci li
update: 2021-11-04
---

# /etc/rsyncd.conf

Dans l'article précédent [rsync démo 02](03_rsync_demo02.md) nous avons introduit quelques paramètres de base. Cet article est destiné à présenter d'autres paramètres supplémentaires.

| Paramètres                          | Description                                                                                                                                                                                                                                                                                                                                                                 |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| fake super = yes                    | yes signifie que vous n'avez pas besoin que le daemon soit exécuté sous root pour enregistrer les attributs complets du fichier.                                                                                                                                                                                                                                            |
| uid =                               | user id                                                                                                                                                                                                                                                                                                                                                                     |
| gid =                               | Deux paramètres sont utilisés pour indiquer l'utilisateur et le groupe pour transférer les fichiers en exécutant le `daemon rsync` sous `root`. La valeur par défaut est `nobody`                                                                                                                                                                                     |
| utilisez chroot = yes               | Suivant que le répertoire root doit être vérouillé avant la transmission, `yes yes`, `no no`. Pour des raisons de sécurité, il est préférable de régler les paramètres de `rsync` à `yes` par défaut.                                                                                                                                                               |
| max connections = 4                 | Le nombre maximum de connexions autorisées, la valeur par défaut étant `0`, ce qui signifie que le nombre est illimité                                                                                                                                                                                                                                                    |
| lock file = /var/run/rsyncd.lock    | Le fichier de verrouillage qui est associé au paramètre " `max connections` "                                                                                                                                                                                                                                                                                             |
| exclude = lost+found/               | Les répertoires exclus du transfert                                                                                                                                                                                                                                                                                                                                         |
| transfer logging = yes              | Suivant que les transferts de rsync sont enregistrés en utilisant un formatage similaire à ftp                                                                                                                                                                                                                                                                              |
| timeout = 900                       | Indique le délai de timeout. Si aucunes données ne sont transmises dans le délai indiqué, `rsync` se terminera immédiatement. L'unité est la seconde, la valeur de `0` par défaut indique un délai illimité                                                                                                                                                             |
| ignore nonreadable = yes            | Suivant que les fichiers qui ont des droits d'accès insuffisants ne sont pas pris en compte                                                                                                                                                                                                                                                                                 |
| motd file = /etc/rsyncd/rsyncd.motd | Indique le chemin vers le fichier des messages. Par défaut il n'existe pas de fichier `motd`. Ce message est le message de bienvenue affiché lors de l'enregistrement de l'utilisateur.                                                                                                                                                                                   |
| hosts allow = 10.1.1.1/24           | Indique l'adresse IP ou la plage d'adresses qui sont accessibles aux clients. Vous pouvez indiquer l'adresse ip, la plage d'adresses, le nom d'hôte, l'hôte du domaine en séparant les indications multiples par des espaces. Autorise l'accès universel par défaut                                                                                                         |
| hosts deny = 10.1.1.20              | Indique l'adresse ou la plage d'adresse du réseau auxquelles l'utilisateur n'a pas accès. Si `hosts allow` et `hosts deny` correspondent aux mêmes résultats, le client risque de ne pas avoir accès. Si l'adresse du client ne figure ni dans `hosts allow` ni dans `hosts deny`, alors le client aura droit d'accès. Par défaut, il n'existe pas de tel paramètre |
| auth users = li                     | Autorise les utilisateurs virtuels, les utilisateurs multiples sont séparés par des virgules dans state                                                                                                                                                                                                                                                                     |
| syslog facility = daemon            | Défini le niveau de journalisation du système. Les valeurs possibles sont : auth, authpriv, cron, daemon, ftp, kern, lpr, mail, news, security, syslog, user, uucp, local0, local1, local2 local3, local4, local5, local6 et local7. `daemon` est la valeur par défaut                                                                                                    |

## Configuration recommandée

```ini title="/etc/rsyncd.conf"
uid = nobody
gid = nobody
address = 192.168.100.4
use chroot = yes
max connections = 10
syslog facility = daemon
pid file = /var/run/rsyncd.pid
log file = /var/log/rsyncd.log
lock file = /var/run/rsyncd.lock
[file]
  comment = rsync
  path = /rsync/
  read only = no
  dont compress = *.gz *.bz2 *.zip
  auth users = li
  secrets file = /etc/rsyncd users.db
```
