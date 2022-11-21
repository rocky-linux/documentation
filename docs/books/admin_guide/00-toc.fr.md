---
title: Apprendre Linux avec Rocky
---

# Apprendre Linux avec Rocky

Le Guide d'administration est une collection de documents éducatifs destinés aux administrateurs systèmes. Ils peuvent être utilisés par les futurs administrateurs systèmes qui veulent se mettre à niveau, par les administrateurs systèmes actuels qui souhaitent se rafraîchir la mémoire, ou par tout utilisateur de Linux qui souhaite en savoir plus sur l'environnement, les commandes, les processus etc. de Linux. Comme tous les documents de ce type, il évoluera et sera mis à jour au fil du temps.

Dans un premier temps, nous parlerons de Linux, des distributions, et de tout l'écosystème autour de notre système d'exploitation.

Nous nous pencherons ensuite sur les commandes utilisateurs qui sont essentielles pour se familiariser avec Linux. Les utilisateurs les plus expérimentés pourront également consulter le chapitre consacré aux commandes "plus avancées".

Vient ensuite le chapitre sur l'éditeur VI. Si Linux est livré avec de nombreux éditeurs, VI est l'un des plus puissants. D'autres commandes utilisent parfois des syntaxes identiques à celles de VI (on pensera notamment à `sed`). Il est donc très important de connaître VI, ou du moins de démystifier ses fonctions essentielles (comment ouvrir un fichier, enregistrer, quitter ou quitter sans enregistrer). L'utilisateur deviendra plus à l'aise avec les autres fonctions de VI au fur et à mesure qu'il utilisera l'éditeur. Une alternative serait d'utiliser nano qui est installé par défaut dans Rocky Linux. Bien qu'il ne soit pas aussi polyvalent, il est simple à utiliser, direct, et fait le travail.

Nous pourrons ensuite entrer dans le fonctionnement profond de Linux pour découvrir comment le système gère :

* les utilisateurs.
* les systèmes de fichiers.
* les processus.

Ensuite, nous aborderons un sujet essentiel pour l'administrateur systèmes : Le processus de sauvegarde. De nombreuses solutions logicielles sont fournies avec Linux pour améliorer les sauvegardes (rsnapshot, lsyncd, etc.). Il est bon de connaître les composants essentiels de la sauvegarde qui se trouvent dans le système d'exploitation. Dans ce chapître, nous allons étudier deux outils : d'une part `tar` et d'autre part `cpio` qui est moins répandu.

La gestion du système pendant le processus de démarrage a beaucoup évolué ces dernières années depuis l'arrivée de systemd.


Nous terminerons en examinant la gestion des tâches, la mise en place du réseau et l'installation des logiciels.

