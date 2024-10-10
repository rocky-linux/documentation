---
title: anacron - Automatisation de tâches
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-10-20
---

# anacron - Exécution de tâches périodiques

## Prérequis

- Un ordinateur fonctionnant sous Rocky Linux.
- Savoir comment utiliser votre éditeur favori pour modifier le fichier de configuration (par exemple *vim*) dans la ligne de commande.
- Comprendre la gestion des paquets RPM.

## Prérequis

- Vous avez compris les concepts de base de bash, python ou d'autres outils de script/programmation et vous voulez exécuter le script automatiquement.
- Vous êtes connecté en tant qu'utilisateur root ou pouvez accéder à root avec `su - root`.

## Introduction

`anacron` est utilisé pour exécuter des commandes périodiquement et la fréquence de fonctionnement est définie en unités de jours. Il convient aux ordinateurs qui ne fonctionnent pas 24/7, tels que les ordinateurs portables et les ordinateurs de bureau. Supposons que vous ayez une tâche planifiée (comme un script de sauvegarde) à exécuter tôt le matin à l'aide de crontab. Lorsque vous vous endormez, votre ordinateur de bureau ou votre ordinateur portable est éteint. Votre script de sauvegarde ne sera pas exécuté. Cependant, si vous utilisez `anacron`, vous pouvez être assuré que la prochaine fois que vous allumerez l'ordinateur, le script de sauvegarde sera exécuté.

La finalité de `anacron` n'est pas de remplacer `crontab`, mais de compléter `crontab`. Leur relation est la suivante :

![ Relations ](../images/anacron_01.png)

## `anacron` - Fichier de configuration

```bash
shell > rpm -ql cronie-anacron
/etc/anacrontab
/etc/cron.hourly/0anacron
/usr/lib/.build-id
/usr/lib/.build-id/0e
/usr/lib/.build-id/0e/6b094fa55505597cb69dc5a6b7f5f30b04d40f
/usr/sbin/anacron
/usr/share/man/man5/anacrontab.5.gz
/usr/share/man/man8/anacron.8.gz
/var/spool/anacron
/var/spool/anacron/cron.daily
/var/spool/anacron/cron.monthly
/var/spool/anacron/cron.weekly
```

Vérifier d'abord le fichier de configuration par défaut :

```bash
shell > cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron
# See anacron(8) and anacrontab(5) for details.
SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# Default 45 minutes delay for each specified job anacron random increase 0-45 minutes.
RANDOM_DELAY=45
# Specify the scope of work time, represented here 3:00 ~ 22:00
START_HOURS_RANGE=3-22
# period in days delay in minutes job-identifier command
# Boot every day to check whether the files in the directory /etc/cron.daily be executed in 5 minutes, if not executed today, then to the next
1 5 cron.daily nice run-parts /etc/cron.daily
# Every 7 days within 25 minutes if the file check /etc/cron.weekly directory is executed after boot, if not executed within a week, it will be executed next
7 25 cron.weekly nice run-parts /etc/cron.weekly
# Whether the files in the directory /etc/cron.monthly 45 minutes checking is performed after every start for a month
@monthly 45 cron.monthly nice run-parts /etc/cron.monthly
```

**/etc/cron.hourly/** -Grâce à `journalctl -u crond.service`, vous pouvez constater que les fichiers placés à l'intérieur sont en fait appelés par `crond.server`, ce qui signifie que la commande sera exécutée après la première minute de chaque heure. Comme suit :

```bash
shell > cat /etc/cron.d/0hourly
# Run the hourly jobs
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
01 *  *  *  * root run-parts /etc/cron.hourly
```

```bash
shell > journalctl -u crond.service
- Logs begin at Wed 2021-10-20 19:27:39 CST, end at Wed 2021-10-20 23:32:42 CST. -
October 20 19:27:42 li systemd[1]: Started Command Scheduler.
October 20 19:27:42 li crond[733]: (CRON) STARTUP (1.5.2)
October 20 19:27:42 li crond[733]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 76% if used.)
October 20 19:27:42 li crond[733]: (CRON) INFO (running with inotify support)
October 20 20:01:01 li CROND[1897]: (root) CMD (run-parts /etc/cron.hourly)
October 20 21:01:01 li CROND[1922]: (root) CMD (run-parts /etc/cron.hourly)
October 20 22:01:01 li CROND[1947]: (root) CMD (run-parts /etc/cron.hourly)
October 20 23:01:01 li CROND[2037]: (root) CMD (run-parts /etc/cron.hourly)
```

Pour plus d'informations sur le fichier de configuration, veuillez consulter [la page de manuel](https://man7.org/linux/man-pages/man5/anacrontab.5.html)

## Usage par l'utilisateur

Afin de veiller à ce que certains fichiers soient exécutés dans ces temps définis automatiquement, tout ce que vous avez à faire est de copier le fichier de script dans le répertoire concerné et de vous assurer qu'il a **la permission d'exécution (chmod +x)**. Par conséquent, il vous suffit de laisser le système exécuter automatiquement le script à une de ces heures planifiées, ce qui rend la tâche d'automatisation plutôt facile.

Utilisons cron.daily pour illustrer le processus d'exécution de /etc/anacrontab :

1. `anacron` lit le fichier **/var/spool/anacron/cron.daily** et le contenu du fichier montre l'heure de la dernière exécution.
2. Par rapport à l'heure actuelle, si la différence entre les deux fois dépasse 1 jour, la tâche cron.daily sera exécutée.
3. Cette tâche ne peut être exécutée que de 03h00 à 22h00.
4. Vérifier si un fichier est exécuté plus de 5 minutes après le démarrage. Lorsque le premier job est exécuté, les suivants serons retardés aléatoirement de 0 à 45 minutes.
5. Utilisez le paramètre nice pour spécifier la priorité par défaut, et utilisez le paramètre run-parts pour lancer tous les fichiers exécutables du répertoire /etc/cron.daily/ .

## Commandes associées

Utilisation de la commande `anacron`, les options couramment utilisées sont :

| Options | Observation                                                                |
| ------- | -------------------------------------------------------------------------- |
| -t      | Exécuter toutes les tâches, ignorer les horodatages                        |
| -u      | Mettre à jour l'horodatage à l'heure actuelle sans effectuer aucune action |
| -T      | Tester la validité du fichier de configuration /etc/anacrontab             |

Pour plus d'informations, veuillez consulter [la page de manuel](https://man7.org/linux/man-pages/man8/anacron.8.html)
