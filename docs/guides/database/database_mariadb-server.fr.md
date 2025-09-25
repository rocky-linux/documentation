---
title: MariaDB — Serveur de Banque de Données
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron, Ganna Zhyrnova, Joseph Brinkman
tested_with: 8.5, 8.6, 9.0, 9.2, 10.0
tags:
  - base de données
  - mariadb
---

## Prérequis

- Un serveur Rocky Linux
- Maîtrise d'un éditeur de ligne de commande (_vi_ dans cet exemple)
- Une bonne maîtrise de la ligne de commande, la visualisation des journaux et autres fonctions d'administrateur du système
- Une compréhension des bases de données de *mariadb-server* est souhaitable
- Toutes les commandes sont exécutées en tant qu'utilisateur root ou avec *sudo*

## Introduction

Le serveur _mariadb-server_ et son client _mariadb_ sont les alternatives open source à _mysql-server_ et _mysql_, et ils partagent la structure de commande. *mariadb-server* fonctionne sur de nombreux serveurs Web, en raison de la popularité du [CMS WordPress](https://wordpress.org/) qui l'exige. Cette base de données a cependant de nombreux autres usages.

Si vous souhaitez utiliser ceci avec d'autres outils pour renforcer un serveur web, reportez-vous au guide [Apache Hardened Web Server](../web/apache_hardened_webserver/index.md).

## Installation du serveur `mariadb-server`

Nous avons besoin d'installer le serveur *mariadb-server* :

```bash
dnf install mariadb-server
```

## Securisation du serveur `mariadb-server`

Pour renforcer la sécurité de _mariadb-server_, nous devons exécuter un certain script, mais avant de le faire, nous devons activer et démarrer mariadb :

```bash
systemctl enable --now mariadb
```

Ensuite, exécutez cette commande :

```bash
mysql_secure_installation
```

Ceci fait apparaître une boîte de dialogue :

```text
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

Pour se connecter à MariaDB et la sécuriser, nous aurons besoin du mot de passe actuel de l'utilisateur root. Si vous venez d'installer MariaDB et que vous n'avez pas encore défini le mot de passe root, appuyez simplement sur ++enter++.

Enter current password for root (enter for none):
```

Comme il s'agit d'une toute nouvelle installation, aucun mot de passe root n'est défini. Appuyez simplement sur ++enter++ ici.

La partie suivante du dialogue se poursuit :

```text
La définition du mot de passe `root` ou l'utilisation d'`unix_socket` garantissent que personne ne peut se connecter à l'utilisateur root MariaDB sans l'autorisation appropriée.

Votre compte `root` est déjà protégé, vous pouvez donc répondre `n` en toute sécurité.

Switch to unix_socket authentication [Y/n]
```

Répondez ++"n"++ et appuyez sur ++enter++

```text
Votre compte `root` est déjà protégé, vous pouvez donc répondre `n` en toute sécurité.

Change the root password? [Y/n]
```

En fait, vous n'avez pas défini de mot de passe pour l'utilisateur `root` **OU** utilisé l'authentification `unix_socket`, alors répondez ++"Y"++ ici et appuyez sur ++enter++.

Cela fera apparaître la boîte de dialogue du mot de passe :

```text
New password:
Re-enter new password:
```

Entrez le mot de passe que vous avez choisi, puis confirmez-le en le ressaisissant à nouveau. Si cela réussit, vous obtiendrez la boîte de dialogue suivante :

```text
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

Enregistrez ce mot de passe dans un gestionnaire de mots de passe ou dans un emplacement de stockage sûr.

Ensuite, la boîte de dialogue traite de l’utilisateur anonyme :

```text
Par défaut, une installation MariaDB possède un utilisateur anonyme, permettant à quiconque de se connecter à MariaDB sans avoir à créer de compte utilisateur. Ceci est uniquement destiné aux essais et à faciliter l'installation.  Vous devez les supprimer avant de passer à un environnement de production.

Remove anonymous users? [Y/n]
```

La réponse ici est `Y`, alors appuyez simplement sur ++enter++ pour accepter la valeur par défaut.

La boîte de dialogue passe à la section traitant de l'autorisation de connexion à distance de l'utilisateur `root` :

```text
... Success!

Normalement, `root` ne devrait être autorisé à se connecter qu'à partir de `localhost`.  Cela garantit que personne ne peut deviner le mot de passe `root` à partir du réseau.

Disallow root login remotely? [Y/n]
```

`root` devrait seulement être nécessaire localement sur la machine. Acceptez donc aussi cette valeur par défaut en appuyant sur ++enter++.

La boîte de dialogue passe ensuite à la base de données `test` qui est automatiquement installée avec *mariadb-server* :

```text
... Success!


Par défaut, MariaDB est fournie avec une base de données nommée `test` à laquelle tout le monde peut accéder.  Ceci est également destiné uniquement aux tests et doit être supprimé avant de passer à un environnement de production.

Remove test database and access to it? [Y/n]
```

Encore une fois, la réponse ici est la valeur par défaut, alors appuyez simplement sur ++enter++ pour la supprimer.

Finalement, la boîte de dialogue vous demande si vous voulez recharger les privilèges :

```text
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Le rechargement des tables de privilèges garantira que toutes les modifications apportées jusqu'à présent prendront effet immédiatement.

Reload privilege tables now? [Y/n]
```

Appuyez de nouveau sur ++enter++ pour ce faire. Si tout va bien, vous recevrez ce message :

```text
 ... Success!

Cleaning up...

C'est terminé !  Si vous avez suivi toutes les étapes ci-dessus, votre installation MariaDB devrait maintenant être sécurisée.

Thanks for using MariaDB!
```

MariaDB sera maintenant prête à être utilisée.

## Conclusion

Un serveur de base de données, comme *mariadb-server*, peut être utilisé à de nombreuses fins. En raison de la popularité du [CMS WordPress](https://wordpress.org), on le retrouve souvent sur les serveurs Web. Avant d’exécuter la base de données en production, il est toutefois judicieux de renforcer sa sécurité.
