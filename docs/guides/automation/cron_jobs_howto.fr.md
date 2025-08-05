---
title: cron - Automatisation de Tâches
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested on: 8.5
tags:
  - job automation
  - automatisation
  - cron
---

# Automatisation de processus avec `cron` et `crontab`

## Prérequis

- Un ordinateur fonctionnant sous Rocky Linux
- Une certaine expérience pour pouvoir modifier les fichiers de configuration depuis la ligne de commande en utilisant votre éditeur préféré (`vi` est utilisé ici)

## Prérequis

- Connaissances de base de bash, python ou d'autres outils de programmation et le désir d'avoir un script exécuté automatiquement
- Que vous puissiez être utilisateur root ou que vous ayez la possibilité d'utiliser `sudo -s`  
  ** (Vous pouvez exécuter certains scripts dans vos propres répertoires en tant que votre propre utilisateur, Dans ce cas, le passage à root n'est pas nécessaire)**.

## Introduction

Linux fournit le système _cron_, un planificateur de tâches basé sur le temps, pour automatiser les processus. C'est assez simple et pourtant assez puissant. Vous voulez qu'un script ou un programme soit lancé tous les jours à 17h ? C'est ici que vous configurez cela.

Le *crontab* est essentiellement une liste où les utilisateurs ajoutent leurs propres tâches automatisées. Et il existe un certain nombre d'options qui peuvent encore simplifier les choses. Ce document va explorer certains de ces éléments. C'est un moyen de se rafraîchir la mémoire pour ceux qui ont une certaine expérience et les nouveaux utilisateurs peuvent ajouter le système `cron` à leur répertoire.

`anacron` est discuté brièvement ici en référence aux répertoires "dot" de `cron`. `anacron` est exécuté par `cron` et est avantageux pour les machines qui ne sont pas toujours opérationnelles, telles que les postes de travail et les ordinateurs portables. La raison en est que tant que `cron` exécute des tâches sur une planification, si la machine est éteinte lorsque la tâche est planifiée, la tâche ne s'exécutera pas. Avec `anacron` la tâche est exécutée lorsque la machine est à nouveau allumée même si l'exécution programmée est dans le passé. `anacron` cependant, utilise une approche plus randomisée pour exécuter des tâches où le timing n'est pas exact. Cela a du sens pour les postes de travail et les ordinateurs portables, mais pas tant pour les serveurs. Cela peut être un problème pour des choses comme les sauvegardes de serveur, par exemple, qui doivent être exécutées à un moment précis. C'est là que `cron` continue à fournir la meilleure solution pour les administrateurs de serveurs. Tout cela étant dit, les administrateurs de serveurs et les utilisateurs de postes de travail ou d'ordinateurs portables peuvent profiter des deux approches. Vous pouvez facilement adapter àvos besoins. Pour plus d'informations sur `anacron` voir [anacron - Automatisation des commandes](anacron.md).

### Débuter facilement - Les répertoires dot de `cron`

Construits dans tous les systèmes Linux pour de nombreuses versions maintenant, les répertoires `cron` « dot » aident à automatiser les processus rapidement. Celles-ci apparaissent comme des répertoires que le système `cron` appelle en fonction de leurs conventions de nommage. Ils sont appelés différemment cependant, en fonction du processus qui est assigné à les appeler, `anacron` ou `cron`. Le comportement par défaut est d'utiliser `anacron`, mais cela peut être modifié par un administrateur de serveur, de poste de travail ou d'ordinateur portable.

#### Pour les Serveurs

Comme indiqué dans l'introduction, `cron` exécute normalement `anacron` pour exécuter des scripts dans ces répertoires "dot". Vous pouvez *pouvez*, cependant, vouloir utiliser ces répertoires « dot » sur les serveurs également, et si c'est le cas, alors il y a deux étapes que vous pouvez faire pour vous assurer que ces répertoires « dot » sont exécutés sur un calendrier strict. Pour ce faire, nous devons installer un paquet et en supprimer un autre :

`dnf install cronie-noanacron`

et

`dnf remove cronie-anacron`

Comme vous pouvez vous y attendre, cela supprime `anacron` du serveur et revient aux tâches exécutées dans les répertoires « dot » sur un calendrier strict. Ceci est défini par le fichier `/etc/cron.d/dailyjobs`, qui a le contenu suivant :

```bash
# Run the daily, weekly, and monthly jobs if cronie-anacron is not installed
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# run-parts
02 4 * * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.daily
22 4 * * 0 root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.weekly
42 4 1 * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.monthly
```

Cela se traduit par ce qui suit :

- exécuter des scripts dans `cron.daily` à 04:02:00 chaque jour.
- exécuter des scripts dans `cron.weekly` à 04:22:00 le dimanche chaque semaine.
- exécuter des scripts dans `cron.monthly` à 04:42:00 le premier jour de chaque mois.

#### Pour postes de travail

Si vous voulez exécuter des scripts sur un poste de travail ou un ordinateur portable dans les répertoires `cron` "dot". Copiez simplement votre fichier de script dans le répertoire en question et assurez-vous qu'il est exécutable. Voici les répertoires :

- `/etc/cron.hourly` - Les scripts placés ici seront exécutés une minute après l'heure, toutes les heures (ils sont exécutés par `cron`, que `anacron` soit installé ou non)
- `/etc/cron.daily` - Les scripts placés ici seront exécutés chaque jour. `anacron` ajuste le timing de ceux-ci
- `/etc/cron.weekly` - Les scripts placés ici seront exécutés tous les 7 jours, en fonction du jour calendaire de la dernière exécution (voir l'astuce)
- `/etc/cron.monthly` - Les scripts placés ici seront exécutés mensuellement sur la base du jour calendaire de la dernière exécution (voir l'astuce)

!!! tip "Astuce"

    Ils sont susceptibles d'être exécutés à des heures similaires (mais pas exactement les mêmes) tous les jours, semaines et mois. Pour des temps de fonctionnement plus précis, voir les @options ci-dessous.

Donc pourvu que vous ayez tout à fait raison de laisser le système exécuter automatiquement vos scripts, et leur permettant de s'exécuter quelque temps pendant la période spécifiée, il rend très facile l'automatisation des tâches.

!!! note "Remarque"

    Il n'y a pas de règle qui dit qu'un administrateur du serveur ne peut pas utiliser les heures aléatoires que `anacron` utilise pour exécuter des scripts dans les répertoires "dot". Le cas d'utilisation pour cela serait pour un script qui est indépendant du temps.

### Créer votre propre `cron`

Si les horaires automatisés et aléatoires ne fonctionnent pas bien pour les postes de travail, ou les horaires prévus pour les serveurs, vous pouvez créer vos propres horaires. Dans cet exemple, nous supposons que vous faites cela en tant que root. Pour ce faire, tapez ce qui suit :

`crontab -e`

Cela va générer le `crontab` de l'utilisateur root tel qu'il existe actuellement dans l'éditeur que vous avez choisi et peut ressembler à ceci. Lisez cette version commentée, car elle contient les descriptions de chaque champ que nous utiliserons ensuite :

```text
# Modifier ce fichier pour indiquer les tâches à exécuter par cron.
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
# cron
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

Notez que ce fichier particulier `crontab` a une partie de sa propre documentation intégrée. Ce n'est pas toujours le cas. Lors de la modification d'un `crontab` sur un conteneur ou un système d'exploitation minimaliste, le `crontab` sera un fichier vide à moins qu'une entrée n'y ait déjà été placée.

Supposons que nous avons un script de sauvegarde que nous voulons exécuter à 22h la nuit. Le `crontab` utilise une horloge de 24 heures, donc ce serait 22:00. Supposons que le script de sauvegarde est appelé "backup" et qu'il se trouve actuellement dans le répertoire */usr/local/sbin*.

!!! note Remarque

    N'oubliez pas que ce script doit également être exécutable (`chmod +x`) pour que le `cron` puisse l'exécuter.

Afficher la liste des tâches en cours d'exécution

`crontab -l`

Pour lister toutes les tâches créées par l'utilisateur

`crontab -l -u <username>`

Pour ajouter la tâche, saisir :

`crontab -e`

`crontab` signifie « table cron » et le format du fichier est, en fait, une disposition de table libre. Maintenant que vous êtes dans le `crontab`, allez au bas du fichier et ajoutez votre entrée. Si vous utilisez `vi` comme éditeur du système par défaut, vous le ferez avec les touches suivantes :

++shift+colon+"$"++

Maintenant que vous êtes au bas du fichier, insérez une ligne et entrez un bref commentaire pour décrire ce que fait votre tâche. Pour ce faire, il suffit d'ajouter un « # » au début de la ligne :

`# Sauvegarde du système tous les soirs à 22h`

Appuyer sur ++enter++. Vous devriez toujours être en mode insertion, l’étape suivante consiste donc à ajouter votre entrée. Comme le montre notre `crontab` vide commenté (ci-dessus), il s'agit de **m** pour les minutes, **h** pour les heures, **dom** pour le jour du mois, **mon** pour le mois et **dow** pour le jour de la semaine.

Pour exécuter notre script de sauvegarde tous les jours à 22h00, l'entrée ressemblerait à ceci :

`00  22  *  *  *   /usr/local/sbin/backup`

Cela signifie que le script doit être exécuté à 22 heures, tous les jours du mois, tous les mois et tous les jours de la semaine. Il s'agit d'un exemple simpliste et les choses peuvent devenir très compliquées lorsqu'on a besoin de précisions.

### Les @options de `crontab`

Une autre façon d'exécuter des tâches à une heure strictement planifiée (c'est-à-dire un jour, une semaine, un mois, une année, etc.) consiste à utiliser @options, qui offrent la possibilité d'utiliser une heure plus intuitive. Les @options consistent en:

- `@hourly` exécute le script toutes les heures de chaque jour à 0 minute après l'heure (c'est exactement le résultat du placement de votre script dans `/etc/cron.hourly` également).
- `@daily` exécute le script tous les jours à minuit.
- `@weekly` exécute le script chaque semaine à minuit le dimanche.
- `@monthly` exécute le script chaque mois à minuit le premier jour du mois.
- `@yearly` exécute le script chaque année à minuit le premier jour de janvier.
- `@reboot` exécute le script uniquement au démarrage du système.

!!! note "Remarque"

    L'utilisation de ces entrées `crontab` contourne le système `anacron` et revient au `crond.service` si `anacron` est installé ou non.

Dans notre exemple de script de sauvegarde, si vous utilisez l’option @daily pour exécuter le script de sauvegarde à minuit, l’entrée ressemblera à ceci :

`@daily  /usr/local/sbin/backup`

### Options plus complexes

Jusqu'à présent, les solutions utilisées ont été des options assez simplistes, mais qu'en est-il de planification de tâches plus complexes ? Supposons que vous souhaitiez exécuter votre script de sauvegarde toutes les 10 minutes au cours de la journée (ce n'est probablement pas une solution pratique, mais c'est un exemple !) Pour ce faire, votre crontab doit être le suivant :

`*/10  *   *   *   *   /usr/local/sbin/backup`

Que se passerait-il si vous vouliez exécuter la sauvegarde toutes les 10 minutes, mais seulement le lundi, le mercredi et le vendredi ?

`*/10  *   *   *   1,3,5   /usr/local/sbin/backup`

Pourquoi pas toutes les 10 minutes tous les jours sauf le samedi et le dimanche ?

`*/10  *   *   *    1-5    /usr/local/sbin/backup`

Dans le tableau, les virgules vous permettent de spécifier des entrées individuelles dans un champ et le tiret vous permet de spécifier une plage de valeurs dans un champ. Ceci est vrai pour n'importe quel champ, et peut être vrai pour plusieurs champs à la fois. Comme vous pouvez le constater, les choses peuvent devenir assez compliquées.

Lorsqu'il s'agit de déterminer quand exécuter un script, il faut prendre le temps de le planifier, surtout si les critères sont complexes.

## Conclusion

Le système *cron/crontab* est un outil puissant pour l'administrateur système ou l'utilisateur de bureau de Rocky Linux. Il vous permet d'automatiser des tâches et des scripts afin que vous n'ayez pas à vous souvenir de les exécuter manuellement. Des exemples plus complexes sont présentés ici :

- Pour les machines qui ne sont **pas en marche tous les jours** 24 heures sur 24, veuillez consulter l'article [anacron - Automatisation des commandes](anacron.md).
- Pour une description concise des processus `cron`, consultez [cronie - Tâches chronométrées](cronie.md)

Si les principes de base sont assez simples, les options peuvent être plus complexes. Pour plus d'informations sur `crontab`, consultez la [page de manuel de crontab](https://man7.org/linux/man-pages/man5/crontab.5.html). Sur la plupart des systèmes, vous pouvez également saisir `man crontab` pour obtenir des détails supplémentaires sur les commandes. Vous pouvez également effectuer une recherche sur le web en tapant « crontab », ce qui vous donnera une multitude de résultats qui vous aideront à affiner vos compétences en matière de `crontab`.
