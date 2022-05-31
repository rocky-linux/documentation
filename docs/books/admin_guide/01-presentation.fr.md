---
title: Introduction à Linux
---

# Introduction au système d'exploitation Linux

Dans ce chapitre, vous allez en apprendre plus à propos des distributions GNU/Linux.

****

**Objectifs : **Dans ce chapitre, vous apprendrez à :

:heavy_check_mark: Décrire les caractéristiques et les architectures possibles d'un système d'exploitation.   
:heavy_check_mark: Retracer l'histoire d'UNIX et de GNU/Linux   
:heavy_check_mark: Choisir la distribution Linux adaptée à ses besoins   
:heavy_check_mark: Expliquer la philosophie des logiciels libres et open source   
:heavy_check_mark: Découvrir l'utilité de la SHELL.

:checkered_flag: **généralités**, **linux**, **distributions**

**Connaissances : ** :star:    
**Complexité : ** :star:

**Temps de lecture : **10 minutes

****

## Qu'est-ce qu'un système d'exploitation ?

Linux, UNIX, BSD, Windows et MacOS sont tous des **systèmes d'exploitation**.

!!! abstract

    Un système d'exploitation est un **ensemble de programmes qui gèrent les ressources disponibles d'un ordinateur**.

Parmi cette gestion des ressources, le système d'exploitation doit :

* Gérer la mémoire physique ou virtuelle.
  * La **mémoire physique** est constituée des barrettes de RAM et de la mémoire cache du processeur, utilisées pour l'exécution des programmes.
  * La **mémoire virtuelle** est un emplacement sur le disque dur (la partition **swap**) qui permet de décharger la mémoire physique et de sauvegarder l'état actuel du système lors de l'arrêt électrique de l'ordinateur.
* Intercepter les **accès aux périphériques**. Les logiciels sont rarement autorisés à accéder directement au matériel (sauf les cartes graphiques pour des besoins très spécifiques).
* Fournir aux applications une **gestion correcte des tâches**. Le système d'exploitation est responsable de la planification des processus pour occuper le processeur.
* **Protéger les fichiers** contre les accès non autorisés.
* **Collecter des informations** sur les programmes utilisés ou en cours d'exécution.

![Fonctionnement d'un système d'exploitation](images/operating_system.png)

## Généralités UNIX - GNU/Linux

### Histoire

#### UNIX

* De **1964 à 1968** : MULTICS (MULTiplexed Information and Computing Service) est développé pour le MIT, Bell Labs (AT&T) et General Electric.

* **1969** : Après le retrait de Bell (1969) puis de General Electric du projet, deux développeurs (Ken Thompson et Dennis Ritchie), rejoint plus tard par Brian Kernighan, jugeant MULTICS trop complexe, ont lancé le développement de UNIX (UNiplexed Information and Computing Service). Développé à l'origine en assembleur, les concepteurs d'UNIX développent le langage B puis le langage C (1971) et réécrivent complètement UNIX. Ayant été développé en 1970, la date de référence des systèmes UNIX/Linux est toujours fixée au 1er janvier 1970.

Le langage C est encore l'un des langages de programmation les plus populaires aujourd'hui! Un langage de bas niveau, proche du matériel, il permet d'adapter le système d'exploitation à toute architecture de machine ayant un compilateur C.

UNIX est un système d'exploitation ouvert et évolutif qui a joué un rôle majeur dans l'histoire de l'informatique. Il a été la base de beaucoup d'autres systèmes : Linux, BSD, MacOS, etc.

UNIX est toujours d'actualité aujourd'hui (HP-UX, AIX, Solaris, etc.)

#### Minix

* **1987** : Andrew S. Tanenbaum développe MINIX, un UNIX simplifié, pour enseigner les systèmes d'exploitation de manière simple. M. Tanenbaum met à disposition le code source de son système d'exploitation.

#### Linux

* **1991** : Un étudiant finlandais, **Linus Torvalds**, crée un système d'exploitation dédié à son ordinateur personnel et le nomme Linux. Il publie sa première version 0.02, sur le forum de discussion Usenet et d'autres développeurs viennent l'aider à améliorer son système. Le terme Linux est un jeu de mots entre le prénom du fondateur, Linus, et UNIX.

* **1993** : La distribution Debian est créée. Debian est une distribution non commerciale basée sur la communauté. Développé à l'origine pour être utilisée sur les serveurs, elle est particulièrement adaptée à ce rôle, mais elle est destinée à être un système universel et donc utilisable sur un ordinateur personnel également. Debian est utilisée comme base pour de nombreuses autres distributions, comme Mint ou Ubuntu.

* **1994** : La distribution commerciale RedHat est créée par la société RedHat, qui est aujourd'hui le premier distributeur du système d'exploitation GNU/Linux. RedHat prend en charge la version communautaire Fedora et récemment la distribution gratuite CentOS.

* **1997** : L'environnement de bureau KDE est créé. Il est basé sur la bibliothèque de composants Qt et le langage de développement C++.

* **1999** : L'environnement de bureau Gnome est créé. Il est basé sur la bibliothèque de composants GTK+.

* **2002** : La distribution Arch est créée. Sa particularité est d'être diffusée en Rolling Release (mise à jour continue).

* **2004** : Ubuntu est créé par la compagnie Canonical (Mark Shuttleworth). Elle est basé sur Debian, mais inclut des logiciels libres et propriétaires.

* **2021** : Naissance de Rocky Linux, basée sur la distribution RedHat.

### Part de marché

<!--
TODO: graphics with market share for servers and pc.
-->

Linux n'est toujours pas bien connu du grand public, même s'ils l'utilisent régulièrement. En effet, Linux est caché dans les **smartphones**, **téléviseurs**, **boîtes Internet**, etc. Près de **70 % des pages web** servies dans le monde le sont par un serveur Linux ou UNIX !

Linux équipe un peu plus de **3% des ordinateurs personnels** mais plus de **82 % des smartphones**. **Android** étant un système d'exploitation dont le noyau est un Linux.

<!-- TODO: review those stats -->

Linux équipe 100% des 500 superordinateurs depuis 2018. Un superordinateur est un ordinateur conçu pour obtenir les meilleures performances possibles avec les techniques connues lors de sa conception, surtout en ce qui concerne la vitesse de calcul.

### Conception architecturale

* Le **noyau** est le premier composant logiciel.
  * C'est le cœur du système Linux.
  * Il gère les ressources matérielles du système.
  * Les autres composants logiciels doivent passer par lui pour accéder au matériel.
* Le **shell** est un utilitaire qui interprète les commandes utilisateur et assure leur exécution.
  * Principaux shells : Bourne shell, C shell, Korn shell et Bourne-Again shell (bash).
* Les applications sont des programmes utilisateur comme le :
  * Navigateur Internet ;
  * Traitement de texte ;
  * ...

#### Multi-tâche

Linux appartient à la famille des systèmes d'exploitation à temps partagé. Il partage le temps de traitement entre plusieurs programmes, passant d'un programme à l'autre d'une manière transparente pour l'utilisateur. Cela implique :

* l'exécution simultanée de plusieurs programmes ;
* la distribution du temps CPU par l’ordonnanceur ;
* la réduction des problèmes dus à une application défaillante ;
* une diminution des performances lorsqu’il y a trop de programmes lancés.

#### Multi-utilisateurs

Le but de Multics était de permettre à plusieurs utilisateurs de travailler à partir de plusieurs terminaux (écran et clavier) sur un seul ordinateur (très cher à l'époque). Linux, qui est inspiré par ce système d'exploitation, a conservé cette capacité de travailler avec plusieurs utilisateurs simultanément et indépendamment, chacun ayant son propre compte utilisateur, son propre espace mémoire et ses droits d'accès aux fichiers et aux logiciels.

#### Multi-processeur

Linux est capable de fonctionner sur des ordinateurs multi-processeurs ou avec des processeurs multi-cœurs.

#### Multi-plateforme

Linux est écrit dans un langage de haut niveau qui peut être adapté à différents types de plates-formes pendant la compilation. Il fonctionne donc sur :

* ordinateurs domestiques (PC ou ordinateur portable) ;
* serveurs (données, applications, ...) ;
* ordinateurs portables (smartphones ou tablettes)
* systèmes embarqués (ordinateur de voiture) ;
* éléments actifs de réseaux (routeurs, commutateurs) ;
* appareils électroménagers (télé, réfrigérateur, ...).

#### Ouvert

Linux est basé sur des normes reconnues [posix](http://fr.wikipedia.org/wiki/POSIX), TCP/IP, NFS, Samba, ..., permettant de partager des données et des services avec d'autres systèmes d'application.

### La philosophie UNIX/Linux

* Tout est fichier.
* Portabilité.
* Ne faire qu’une seule chose et la faire bien.
* KISS : Keep It Simple and Stupid.
* “UNIX est simple, il faut juste être un génie pour comprendre sa simplicité” (__Dennis Ritchie__)
* “UNIX est convivial. Cependant UNIX ne précise pas vraiment avec qui.” (__Steven King__)

## Les distributions GNU/LINUX

Une distribution Linux est un **ensemble cohérent de logiciels** assemblés autour du noyau Linux et prêt à être installé ainsi que le nécessaire à la gestion de ces logiciels (installation, suppression, configuration). Il existe des **distributions associatives ou communautaires** (Debian, CentOS) ou **commerciales** (RedHat, Ubuntu).

Chaque distribution propose un ou plusieurs **environnements de bureau**, fournit un ensemble de logiciels pré-installés et une logithèque de logiciels supplémentaires. Des options de configuration (options du noyau ou des services par exemple) sont propres à chacune.

Ce principe permet d’avoir des distributions orientées **débutants** (Ubuntu, Linux Mint …) ou d’une approche plus complexe (Gentoo, Arch), destinées à faire du **serveur** (Debian, RedHat, …) ou dédiées à des **postes de travail**.

### Les environnements de bureau

Les environnements graphiques sont nombreux : **Gnome**, **KDE**, **LXDE**, **XFCE**, etc. Il y en a pour tous les goûts, et leurs **ergonomies** n’ont pas à rougir de ce que l’on peut retrouver sur les systèmes Microsoft ou Apple !

Alors pourquoi si peu d’engouement pour Linux, **alors qu’il n'existe pas (ou presque pas) de virus pour ce système** ? Peut-être parce que tous les éditeurs (Adobe) ou constructeur (NVidia) ne jouent pas le jeu du libre et ne fournissent pas de version de leurs logiciels ou de leurs __drivers__ pour GNU/Linux ? La peur du changement ? La difficulté de trouver où acheter un ordinateur Linux ? Le trop peu de jeux (mais plus pour longtemps) distribués sous Linux ? La donne changera-t-elle avec l’arrivée de la steam-box console de jeux qui fonctionne sous Linux ?

![Le bureau Gnome](images/01-presentation-gnome.png)

L’environnement de bureau **Gnome 3** n’utilise plus le concept de Bureau mais celui de Gnome Shell (à ne pas confondre avec le shell de la ligne de commande). Il sert à la fois de bureau, de tableau de bord, de zone de notification et de sélecteur de fenêtre. L’environnement de bureau Gnome se base sur la bibliothèque de composants GTK+.

![Le bureau KDE](images/01-presentation-kde.png)

L’environnement de bureau **KDE** se base sur la bibliothèque de composants **Qt**.

Il est traditionnellement plus conseillé aux utilisateurs venant d’un monde Windows.

![Tux - La mascotte de Linux](images/tux.png)

### Libre / Open source

Un utilisateur de système d’exploitation Microsoft ou Mac doit s’affranchir d’une licence d’utilisation du système d’exploitation. Cette licence a un coût, même s’il est généralement transparent (le prix de la licence étant inclus dans le prix de l’ordinateur).

Dans le monde **GNU/Linux**, le mouvement du Libre permet de fournir des distributions majoritairement gratuites.

**Libre** ne veut pas dire gratuit !

**Open source** : les codes sources sont disponibles, il est donc possible de les consulter et de les modifier sous certaines conditions.

Un logiciel libre est forcément Open Source mais l’inverse n’est pas vrai puisqu’un logiciel Open Source est amputé d’une liberté proposée par la licence GPL.

#### License GPL (General Public License)

La **Licence GPL** garantit à l’auteur d’un logiciel sa propriété intellectuelle, mais autorise la modification, la rediffusion ou la revente de logiciels par des tiers, sous condition que les codes sources soient fournis avec le logiciel. La licence GPL est la licence issue du projet **GNU** (GNU is Not UNIX), projet déterminant dans la création de Linux.

Elle implique :

* la liberté d’exécuter le programme, pour tous les usages ;
* la liberté d’étudier le fonctionnement du programme et de l’adapter aux besoins ;
* la liberté de redistribuer des copies ;
* la liberté d’améliorer le programme et de publier vos améliorations, pour en faire profiter toute la communauté.

Par contre, même des produits sous licences GPL peuvent être payants. Ce n’est pas le produit en lui-même mais la garantie qu’une équipe de développeurs continue à travailler dessus pour le faire évoluer et dépanner les erreurs, voire fournir un soutien aux utilisateurs.

## Les domaines d’emploi

Une distribution Linux excelle pour :

* **Un serveur** : HTTP, messagerie, groupware, partage de fichiers, etc.
* **La sécurité** : Passerelle, pare-feu, routeur, proxy, etc.
* **Ordinateur central** : Banques, assurances, industrie, etc.
* **Système embarqué** : Routeurs, Box Internet, SmartTV, etc.

Linux est un choix adapté pour l’hébergement de bases de données ou de sites Web, ou comme serveur de messagerie, DNS, pare-feu. Bref Linux peut à peu près tout faire, ce qui explique la quantité de distributions spécifiques.

## Le Shell

### Généralités

Le **shell**, _interface de commandes_ en français, permet aux utilisateurs d’envoyer des ordres au système d’exploitation. Il est moins visible aujourd’hui, depuis la mise en place des interfaces graphiques, mais reste un moyen privilégié sur les systèmes Linux qui ne possèdent pas tous des interfaces graphiques et dont les services ne possèdent pas toujours une interface de configuration.

Il offre un véritable langage de programmation comprenant les structures classiques : boucles, alternatives et les constituants courants : variables, passage de paramètres, sous-programmes. Il permet donc la création de scripts pour automatiser certaines actions (sauvegardes, création d’utilisateurs, surveillance du système,…).

Il existe plusieurs types de Shell disponibles et configurables sur une plate-forme ou selon le choix préférentiel de l’utilisateur :

* sh, le shell aux normes POSIX ;
* csh, shell orienté commandes en C ;
* bash, Bourne-Again Shell, le shell de Linux.
* etc, ...

## Fonctionnalités

* Exécution de commandes (vérifie la commande passée et l’exécute) ;
* Redirections Entrées/Sorties (renvoi des données dans un fichier au lieu de l’inscrire sur l’écran) ;
* Processus de connexion (gère la connexion de l’utilisateur) ;
* Langage de programmation interprété (permettant la création de scripts) ;
* Variables d’environnement (accès aux informations propres au système en cours de fonctionnement).

### Principe

![Principe de fonctionnement du SHELL](images/shell-principle.png)

## Testez vos connaissances

:heavy_check_mark: Un système d’exploitation est un ensemble de programmes permettant la gestion des ressources disponibles d’un ordinateur :

- [ ] Vrai
- [ ] Faux

:heavy_check_mark: Le système d’exploitation est amené à :

- [ ] Gérer la mémoire physique et virtuelle
- [ ] Permettre l’accès direct au périphériques
- [ ] Sous traiter la gestion des tâches au processeur
- [ ] Collecter des informations sur les programmes utilisées ou en cours d’utilisation

:heavy_check_mark: Parmi ces personnalités, lesquelles ont participé au développement d’UNIX :

- [ ] Linus Torvalds
- [ ] Ken Thompson
- [ ] Lionel Richie
- [ ] Brian Kernighan
- [ ] Andrew Stuart Tanenbaum

:heavy_check_mark: La nationalité d’origine de Linus Torvalds, créateur du noyau Linux, est :

- [ ] Suédoise
- [ ] Finlandaise
- [ ] Norvégienne
- [ ] Flamande
- [ ] Française, évidement

:heavy_check_mark: Parmi les distributions suivantes, quelle est la plus ancienne :

- [ ] Debian
- [ ] Slackware
- [ ] RedHat
- [ ] Arch

:heavy_check_mark: Le noyau Linux est-il :

- [ ] Multitâche
- [ ] Multiutilisateurs
- [ ] Multiprocesseur
- [ ] Multicoeurs
- [ ] Multiplateforme
- [ ] Ouvert

:heavy_check_mark: Un logiciel libre est-il forcément Open Source ?

- [ ] Vrai
- [ ] Faux

:heavy_check_mark: Un logiciel Open Source est-il forcément libre ?

- [ ] Vrai
- [ ] Faux

:heavy_check_mark: Parmi les propositions suivantes, laquelle n’est pas un shell :

- [ ] Jason
- [ ] Jason-Bourne shell (jbsh)
- [ ] Bourne-Again shell (bash)
- [ ] C shell (csh)
- [ ] Korn shell (ksh)   
