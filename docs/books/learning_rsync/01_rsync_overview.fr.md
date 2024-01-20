---
title: description succincte de rsync
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2022-03-08
---

# Sauvegarde

Qu'est-ce qu'une sauvegarde ?

La sauvegarde fait référence à la duplication des données dans le système de fichiers ou dans la base de données. En cas d'erreur ou de catastrophe, les données effectives du système peuvent être restaurées en temps utile et de façon normale.

Quelles sont les méthodes de sauvegarde ?

* Sauvegarde complète : désigne une copie unique de tous les fichiers, dossiers ou données du disque dur ou de la base de données. (Avantages : le meilleur, peut récupérer les données plus rapidement. Inconvénients : prendre plus d'espace sur le disque dur.)
* Sauvegarde incrémentale : fait référence à la sauvegarde des données mise à jour après la dernière sauvegarde complète ou la dernière sauvegarde incrémentale. Le processus est ainsi, comme une sauvegarde complète le premier jour ; une sauvegarde des données récemment ajoutées le deuxième jour, par opposition à une sauvegarde complète ; le troisième jour, une sauvegarde des données nouvellement ajoutées sur la base du deuxième jour, relatif au lendemain.
* Sauvegarde différentielle : Se réfère à la sauvegarde des fichiers modifiés après la sauvegarde complète. Par exemple, une sauvegarde complète le premier jour ; une sauvegarde des nouvelles données le deuxième jour ; une sauvegarde des nouvelles données du deuxième jour au troisième jour; et une sauvegarde de toutes les nouvelles données du deuxième jour au quatrième jour le quatrième jour, et ainsi de suite.
* Sauvegarde sélective : Se réfère à la sauvegarde d'une partie du système.
* Sauvegarde froide : désigne la sauvegarde lorsque le système est en état d'arrêt ou de maintenance. Les données sauvegardées sont exactement les mêmes que celles du système durant cette période.
* Sauvegarde à chaud : se rapporte à la sauvegarde lorsque le système est en fonctionnement normal. Comme les données du système sont mises à jour à tout moment, les données sauvegardées ont un certain retard par rapport aux données réelles du système.
* Sauvegarde à distance : désigne la sauvegarde des données dans un autre endroit géographique pour éviter la perte de données et l'interruption de service causée par le feu, les catastrophes naturelles, le vol, etc.

## rsync en bref

Sur un serveur, nous avons sauvegardé la première partition sur la seconde partition, qui est communément appelée « sauvegarde locale ».  Les outils de sauvegarde spécifiques sont `tar` , `dd` , `dump` , `cp` , etc. Bien que les données soient sauvegardées sur ce serveur, si le matériel ne démarre pas correctement, les données ne seront pas récupérées. Afin de résoudre ce problème de la sauvegarde locale, nous avons introduit un autre type de sauvegarde --- "la sauvegarde distante".

Certaines personnes diront, ne puis-je pas simplement utiliser la commande `tar` ou `cp` sur le premier serveur et envoyer les données au second serveur via `scp` ou `sftp` ?

Dans un environnement de production, la quantité de données est relativement importante. Tout d'abord, `tar` ou `cp` consomme beaucoup de temps et réduit les performances du système. La transmission via `scp` ou `sftp` occupe également beaucoup de bande passante réseau, ce qui n'est pas autorisé dans un environnement de production réel. Deuxièmement, ces commandes ou outils doivent être saisis manuellement par l'administrateur et doivent être combinés avec le crontab de la tâche planifiée. Cependant, le temps défini par crontab n'est pas facile à saisir, et il n'est pas approprié que les données soient sauvegardées si le temps est trop court ou trop long.

Par conséquent, il doit y avoir une sauvegarde des données dans l'environnement de production qui doit satisfaire aux exigences suivantes :

1. Sauvegardes transmises sur le réseau
2. Synchronisation des fichiers de données en temps réel
3. Moins d'occupation des ressources du système et plus d'efficacité

`rsync` semble répondre aux besoins ci-dessus. Il utilise le contrat de licence GNU open source. C'est un outil de sauvegarde incrémentielle rapide. La dernière version est 3.2.3 (2020-08-06). Vous pouvez consulter le [site officiel](https://rsync.samba.org/) pour plus d'informations.

En termes de support de plate-forme, la plupart des systèmes UNIX ou apparentés sont supportés, qu'il s'agisse de GNU/Linux ou de BSD par exemple. En outre, il y a des logiciels similaires à `rsync` sous la plate-forme Windows, comme cwRsync par exemple.

L'original `rsync` a été maintenu par le programmeur australien <font color=red>Andrew Tridgell</font> (affiché dans la figure 1 ci-dessous), et maintenant il a été maintenu par <font color=red>Wayne Davison</font> (affiché sur la figure 2 ci-dessous) pour maintenance, vous pouvez aller à [ l'adresse du projet github ](https://github.com/WayneD/rsync) pour obtenir les informations que vous voulez.

![ Andrew Tridgell ](images/Andrew_Tridgell.jpg) ![ Wayne Davison ](images/Wayne_Davison.jpg)

!!! note "Note"

    **rsync lui-même n'est qu'un outil de sauvegarde incrémentiel et n'a pas la fonction de synchronisation des données en temps réel (il doit être complété par d'autres programmes). En outre, la synchronisation est à sens unique. Si vous voulez réaliser une synchronisation bidirectionnelle, vous devrez envisager d'autres outils.**

### Principes et fonctionnalités de base

Comment `rsync` fait-il une sauvegarde avec la synchronisation des données à sens unique ?

Le cœur de `rsync` est son algorithme **Checksum**. Si vous êtes intéressé, vous pouvez aller à [Comment fonctionne Rsync](https://rsync.samba.org/how-rsync-works.html) et [L'algorithme rsync](https://rsync.samba.org/tech_report/) pour plus d'informations. Cette section dépasse la compétence de l'auteur et ne sera pas trop couverte.

Les caractéristiques de `rsync` sont les suivantes :

* L'ensemble du répertoire peut être mis à jour récursivement ;
* Peut retenir sélectivement les attributs de synchronisation de fichiers, tels que le lien dur, le lien logiciel, le propriétaire, le groupe, les permissions correspondantes, le temps de modification, etc. et peut conserver certains attributs ;
* Prise en charge de deux protocoles pour la transmission, l'un est le protocole ssh, l'autre est le protocole rsync
