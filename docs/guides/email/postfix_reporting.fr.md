---
title: Rapports avec Postfix
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - courriel
  - rapports
  - outils
---

# Utiliser `postfix` pour les rapports des processus de serveur

## Prérequis

- Maîtrise de la ligne de commande sur un serveur Rocky Linux
- Maîtrise d'un éditeur de votre choix (ce document utilise l'éditeur `vi`, mais vous pouvez le remplacer par votre éditeur favori)
- Une compréhension du DNS (le système de noms de domaine) et des noms d'hôtes
- La possibilité d'assigner des variables dans un script bash
- Savoir ce que font les commandes _tail_, _more_, _grep_ et _date_

## Introduction

De nombreux administrateurs de serveur Rocky Linux écrivent des scripts pour effectuer des tâches spécifiques, comme les sauvegardes ou la synchronisation de fichiers, et beaucoup de ces scripts génèrent des fichiers logs qui contiennent des informations utiles et parfois très importantes. Mais il ne suffit pas d'avoir des fichiers logs. Si un processus échoue et que le log enregistre l'erreur, mais l'administrateur occupé ne passe pas en revue le journal, alors une catastrophe pourrait être en cours d'élaboration.

Ce document vous montre comment utiliser le MTA de _postfix_ (agent de transfert de courriel) pour saisir les détails du journal d'un processus particulier et vous les envoyer par courriel. Il interprète également les formats de date dans les journaux et aide à déterminer le format à utiliser dans la procédure de rapport.

Gardez toutefois à l'esprit qu'il ne s'agit que d'une partie visible de l'iceberg pour ce qui est de ce qui peut être fait avec les rapports de `postfix`. Notez aussi que c'est toujours un bon réflexe de sécurité de limiter les processus en cours d'exécution à ceux dont vous aurez besoin en permanence.

Ce document vous montre comment activer postfix uniquement pour les rapports que vous avez besoin de faire, puis le refermer.

## `postfix`

`postfix` est un daemon serveur utilisé pour envoyer des emails. Il est plus sûr et plus simple que sendmail, un autre MTA qui était le MTA par défaut depuis des années. Il peut être utilisé dans le cadre d'un serveur de messagerie complet.

## Installation de `postfix`

En dehors de `postfix`, nous aurons besoin de `mailx` pour tester notre capacité à envoyer des emails. Pour installer les deux, et toutes les dépendances nécessaires, entrez ce qui suit sur la ligne de commande du serveur Rocky Linux :

`dnf install postfix mailx`

!!! warning "Changements de Rocky Linux 9.0"

    Cette procédure fonctionne parfaitement bien avec Rocky Linux 9.0. La différence ici est la provenance de la commande `mailx`. Alors que vous pouvez l'installer nommément dans 8.x, `mailx` provient du paquet appstream `s-nail` en 9.0. Pour installer les paquets nécessaires, vous devez utiliser la commande suivante :

    ```
    dnf install postfix s-nail
    ```

## Tester et configurer `Postfix`

### Tester d'abord le courriel

Avant de configurer `postfix`, nous devons savoir à quoi ressemblera le courriel quand il quittera le serveur, parce que nous voudrons probablement changer cela. Pour ce faire, lancez `postfix` :

`systemctl start postfix`

Puis testez-le en utilisant la commande `mail` qui est installée avec `mailx` :

`mail -s "Testing from server" myname@mydomain.com`

Cela fera apparaître une ligne vide. Tapez simplement votre message de test ici :

`test depuis le serveur`

Maintenant appuyez sur ++enter ++ et entrez un simple point :

`.`

Le système répondra avec :

`EOT`

Le but de cette démarche est de voir à quoi ressemble notre courriel aux yeux du monde extérieur. Vous pouvez vous en faire une idée à partir du _maillog_ qui devient actif avec le démarrage de `postfix`.

Utilisez cette commande pour voir le contenu du fichier log :

`tail /var/log/maillog`

Vous devriez voir quelque chose comme ça, bien que le fichier journal puisse avoir des domaines différents pour l'adresse e-mail, et autres détails :

```bash
Mar  4 16:51:40 hedgehogct postfix/postfix-script[735]: starting the Postfix mail system
Mar  4 16:51:40 hedgehogct postfix/master[737]: daemon started -- version 3.3.1, configuration /etc/postfix
Mar  4 16:52:04 hedgehogct postfix/pickup[738]: C9D42EC0ADD: uid=0 from=<root>
Mar  4 16:52:04 hedgehogct postfix/cleanup[743]: C9D42EC0ADD: message-id=<20210304165204.C9D42EC0ADD@somehost.localdomain>
Mar  4 16:52:04 hedgehogct postfix/qmgr[739]: C9D42EC0ADD: from=<root@somehost.localdomain>, size=457, nrcpt=1 (queue active)
Mar  4 16:52:05 hedgehogct postfix/smtp[745]: connect to gmail-smtp-in.l.google.com[2607:f8b0:4001:c03::1a]:25: Network is unreachable
Mar  4 16:52:06 hedgehogct postfix/smtp[745]: C9D42EC0ADD: to=<myname@mydomain.com>, relay=gmail-smtp-in.l.google.com[172.217.212.26]
:25, delay=1.4, delays=0.02/0.02/0.99/0.32, dsn=2.0.0, status=sent (250 2.0.0 OK  1614876726 z8si17418573ilq.142 - gsmtp)
Mar  4 16:52:06 hedgehogct postfix/qmgr[739]: C9D42EC0ADD: removed
```

Le `somehost.localdomain` indique que vous devez apporter quelques modifications. Tout d’abord, arrêtez le démon `postfix` :

`systemctl stop postfix`

## Configuration de Postfix

Puisque nous ne mettons pas en place un serveur de messagerie complet et entièrement fonctionnel, les options de configuration que nous utiliserons ne sont pas très étendues. La première chose que nous devons faire est de modifier le fichier _main.cf_ (littéralement le fichier de configuration principal pour `postfix`). Effectuez d'abord une sauvegarde :

`cp /etc/postfix/main.cf /etc/postfix/main.cf.bak`

Puis éditer :

`vi /etc/postfix/main.cf`

Dans notre exemple, notre nom de serveur sera "bruno" et notre nom de domaine "ourdomain.com". Trouver la ligne dans le fichier :

`#myhostname = host.domain.tld`

Vous pouvez soit supprimer le commentaire (#) soit ajouter une nouvelle ligne sous cette ligne. Sur la base de notre exemple, la ligne sera la suivante :

`myhostname = bruno.ourdomain.com`

Ensuite, trouvez la ligne du nom de domaine :

`#mydomain = domain.tld`

Soit supprimer le commentaire et le modifier, soit ajouter une nouvelle ligne :

`mydomain = ourdomain.com`

Enfin, allez au bas du fichier et ajoutez cette ligne :

`smtp_generic_maps = hash:/etc/postfix/generic`

Enregistrez vos modifications (dans vi, cela sera `Shift : wq!`) et quittez le fichier.

Avant de continuer à éditer le fichier générique, nous devons voir à quoi ressemblera le courriel. Plus spécifiquement, nous voulons créer le fichier "générique" que nous avons référencé dans le fichier _main.cf_ ci-dessus :

`vi /etc/postfix/generic`

Ce fichier indique à `postfix` à quoi devrait ressembler tout courriel provenant de ce serveur. Vous vous souvenez de notre courriel de test et du fichier de log ? C'est là que nous réparons tout cela :

```bash
root@somehost.localdomain       root@bruno.ourdomain.com
@somehost.localdomain           root@bruno.ourdomain.com
```

Maintenant, nous devons dire à `postfix` d'utiliser tous nos changements. Ceci est fait avec la commande `postmap` :

`postmap /etc/postfix/generic`

Démarrez `postfix` et testez à nouveau votre courriel en utilisant la même procédure que ci-dessus. Vous devriez maintenant voir que toutes les instances "localdomain" ont été changées à votre vrai domaine.

### La commande `date` et une variable appelée "today"

Toutes les applications n'utiliseront pas le même format de journalisation pour la date. Vous devrez peut-être faire preuve de créativité avec le script que vous écrivez pour générer des rapports par date.

Disons que vous voulez examiner votre journal système comme un exemple et tirer tout ce qui a à voir avec dbus-daemon pour la date d'aujourd'hui, et l'envoyer à vous-même. (Ce n'est probablement pas l'exemple le plus génial, mais cela vous donnera une idée de la façon dont nous pourrions le faire.)

Nous devons utiliser une variable dans notre script. Appelons-la "today". Vous souhaitez qu'il soit lié à la sortie de la commande `date` et qu'il soit formaté d'une manière spécifique, afin que vous puissiez obtenir les données dont vous avez besoin à partir de notre journal système (dans _/var/log/messages_). Pour commencer, vous devrez effectuer un certain travail d’investigation.

Tout d'abord, entrez la commande `date` dans la ligne de commande :

`date`

Cela devrait vous donner par défaut la date du système, ce qui pourrait être quelque chose comme ceci :

`Thu Mar  4 18:52:28 UTC 2021`

Maintenant, regardons notre journal système et voyons comment il enregistre les informations. Pour cela, nous utiliserons les commandes `more` et `grep` :

`more /var/log/messages | grep dbus-daemon`

Ce qui devrait vous donner quelque chose comme ceci :

```bash
Mar  4 18:23:53 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.1' (uid=0 pid=61 comm="/usr/sbin/NetworkManager --no-daemon " label="unconfined")
Mar  4 18:50:41 hedgehogct dbus-daemon[60]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher
```

Les sorties de date et de journal doivent être exactement les mêmes dans votre script. Voyons comment formater la date avec une variable appelée `today`.

Tout d'abord, regardons ce que nous devons faire avec la date pour obtenir le même résultat que grâce au journal du système. Vous pouvez référencer la page du manuel de [Linux](https://man7.org/linux/man-pages/man1/date.1.html) ou tapez `man date` sur la ligne de commande pour récupérer la page de manuel de date pour obtenir les informations dont vous avez besoin.

Ce que vous trouverez est que pour formater la date de la même manière que _/var/log/messages_ l'a fait, nous devons utiliser les chaînes de format %b et %e, dont %b est le mois à 3 caractères et %e le jour formaté avec des espaces.

### Le script

Pour notre script bash, nous pouvons voir que nous allons utiliser la commande `date` et une variable appelée "today". (Gardez à l'esprit que "today" est arbitraire. Vous pouvez appeler cette variable comme vous le souhaitez). Nous allons appeler notre script dans cet exemple, `test.sh` et le placer dans _/usr/local/sbin_ :

`vi /usr/local/sbin/test.sh`

Au début, notez que même si le commentaire dans notre fichier indique que vous envoyez ces messages par courriel, pour l'instant, vous les envoyez simplement à une sortie de journal standard pour vérifier qu'ils sont corrects.

De plus, dans notre première tentative, nous saisissons tous les messages pour la date actuelle, pas seulement les messages dbus-daemon. Nous nous en occuperons un peu plus tard.

Une autre chose à savoir est que la commande `grep` retournera le nom du fichier en sortie, ce que nous ne voulons pas dans ce cas. Pour supprimer cela, ajoutez l'option `-h` à grep. De plus, lorsque vous définissez la variable `today`, vous devez rechercher la variable entière sous forme de string, ce qui nécessite la chaîne entre guillemets :

```bash
#!/bin/bash

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages
```

C'est tout pour le moment. Enregistrez vos modifications et rendez le script exécutable comme suit :

`chmod +x /usr/local/sbin/test.sh`

Et tester :

`/usr/local/sbin/test.sh`

Si tout fonctionne correctement, vous devriez obtenir une longue liste de tous les messages dans _/var/log/messages_ à partir d'aujourd'hui, y compris, mais sans s'y limiter, les messages dbus-daemon. L'étape suivante est de limiter les messages aux messages dbus-daemon. Modifions à nouveau notre script :

`vi /usr/local/sbin/test.sh`

```bash
#!/bin/bash

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages | grep dbus-daemon
```

Exécuter le script à nouveau, devrait vous livrer seulement les messages dbus-daemon et seulement ceux qui se sont produits aujourd'hui.

Il reste une dernière étape. Rappelez-vous que nous devons faire en sorte que ce courriel soit envoyé à l'administrateur pour examen. Étant donné que vous utilisez uniquement `postfix` sur ce serveur pour générer des rapports, il n'est pas nécessaire de laisser le service en cours d'exécution. Lancez-le au début du script et arrêtez-le à la fin. Ici, la commande `sleep` engendre une pause pendant 20 secondes, assurant l'envoi du courriel avant de fermer à nouveau `postfix`. Cette modification finale ajoute les actions `start`, `sleep` et `stop` qui viennent d'être évoquées, et transmet également le contenu à l'adresse e-mail de l'administrateur.

`vi /usr/local/sbin/test.sh`

Modifier le script :

```bash
#!/bin/bash

# start postfix
/usr/bin/systemctl start postfix

# set the date string to match /var/log/messages
today=`date +"%b %e"`

# grab the dbus-daemon messages and send them to email
grep -h "$today" /var/log/messages | grep dbus-daemon | mail -s "dbus-daemon messages for today" myname@mydomain.com

# make sure the email has finished before continuing
sleep 20

# stop postfix
/usr/bin/systemctl stop postfix
```

Exécutez à nouveau le script, et vous devriez maintenant avoir un courriel du serveur avec le message dbus-daemon.

Vous pouvez maintenant utiliser [un crontab](../automation/cron_jobs_howto.md) afin de planifier cela pour qu'il s'exécute à une heure spécifique.

## Conclusion

L'utilisation de `postfix` peut vous aider à garder la trace des journaux des processus que vous souhaitez surveiller. Vous pouvez l'utiliser en même temps que des scripts bash pour maîtriser les processus de votre système et être informé en cas de problème.
