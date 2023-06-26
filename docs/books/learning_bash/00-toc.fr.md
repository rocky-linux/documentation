---
title: Apprendre bash avec Rocky
author: Antoine Le Morvan
contributors: Steven Spencer
tested_with: 8.5
tags:
  - formation
  - script bash
  - bash
---

# Apprendre Bash avec Rocky

Dans cette section, vous en apprendrez plus sur les scripts Bash, un exercice que chaque administrateur devra effectuer un jour ou l'autre.

## Généralités

Le shell est l'interpréteur de commandes de Linux. C'est un binaire qui ne fait pas partie du noyau, mais qui forme une couche particulière, d'où son nom « shell ».

Il analyse les commandes entrées par l'utilisateur et les fait exécuter par le système.

Il y a plusieurs shells, qui partagent tous quelques caractéristiques communes. L'utilisateur est libre d'utiliser celui qui lui convient le mieux. Quelques exemples sont :

* le shell **Bourne-Again** (`bash`),
* le **Korn shell** (`ksh`),
* le **C shell** (`csh`),
* etc.

`bash` est présent par défaut dans la plupart des distributions Linux. Il se caractérise par ses caractéristiques pratiques et conviviales.

Le shell est également un **langage de programmation de base** qui, grâce à certaines commandes dédiées, permet :

* l'utilisation de **variables**,
* **exécution conditionnelle** de commandes,
* la **répétition** des commandes.

Les scripts shell ont l'avantage de pouvoir être créés **rapidement** et **de manière fiable**, sans **compilation** ou installation de commandes supplémentaires. Un script shell est juste un fichier texte sans enjolivements (gras, italique, etc.).

!!! NOTE

    Bien que le shell soit un langage de programmation « basique », il est toujours très puissant et parfois plus rapide que du code mal conçu.

Pour écrire un script shell, il vous suffit de mettre toutes les commandes nécessaires dans un seul fichier texte. En exécutant ce fichier, le shell le lit séquentiellement et exécute les commandes une par une. Il est également possible de l'exécuter en passant le nom du script comme argument au binaire bash.

Lorsque le shell rencontre une erreur, il affiche un message pour identifier le problème mais continue à exécuter le script. Mais il y a des mécanismes pour arrêter l'exécution d'un script quand une erreur survient. Des erreurs spécifiques à une commande sont également affichées à l'écran ou enregistrées dans des fichiers.

Qu'est-ce qu'un bon script? C'est :

* **fiable**: son fonctionnement est parfait même en cas d'utilisation inappropriée ;
* **commenté**: son code est annoté pour faciliter la relecture et l'évolution future ;
* **lisible**: le code est indenté de manière appropriée, les commandes sont espacées, ...
* **portable**: le code fonctionne sur n'importe quel système Linux, gestion des dépendances, gestion des droits, etc.
