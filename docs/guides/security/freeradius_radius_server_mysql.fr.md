---
title: FreeRADIUS – Serveur RADIUS et MariaDB
author: Neel Chauhan
contributors:
tested_with: 10.1
tags:
  - sécurité
---

## Introduction

RADIUS est un protocole AAA (authentification, autorisation et comptabilisation – accounting) permettant de gérer l'accès au réseau. [FreeRADIUS](https://www.freeradius.org/) est le serveur RADIUS de facto pour Linux et autres systèmes de type Unix.

Vous pouvez faire fonctionner FreeRADIUS avec MariaDB, par exemple pour l'authentification 802.1X, Wi-Fi ou VPN.

## Prérequis

Voici les exigences minimales pour cette procédure :

- La capacité d'exécuter des commandes en tant qu'utilisateur root ou d'utiliser `sudo` pour élever les privilèges
- Un serveur MariaDB
- Un client RADIUS, tel qu’un routeur, un commutateur ou un point d’accès Wi-Fi

## Installation de FreeRADIUS

Vous devez d'abord installer EPEL et CRB :

```bash
dnf install epel-release
crb enable
```

Vous pouvez ensuite installer FreeRADIUS à partir des dépôts `dnf` :

```bash
dnf install -y freeradius freeradius-mysql
```

## Installation de MariaDB

Il vous faut installer MariaDB :

```bash
dnf install mariadb-server
```

## Configuration de `FreeRADIUS`

Une fois les paquets installés, vous devez d'abord générer les certificats de chiffrement TLS pour FreeRADIUS :

```bash
cd /etc/raddb/certs
./bootstrap
```

Vous devrez ensuite activer `sql`. Modifiez le fichier `/etc/raddb/sites-enabled/default` et remplacez `-sql` par `sql` :

```bash
authorize {
   ...
   sql
   ...
}
...
accounting {
   ...
   sql
   ...
}
...
session {
   ...
   sql
   ...
}
...
post-auth {
    ...
    sql
    ...
    Post-Auth-Type REJECT {
        sql
    }
    ....

}
```

Insérez de même la ligne dans `/etc/raddb/sites-enabled/inner_tunnel` :

```bash
authorize {
   ...
   sql
   ...
}
...
session {
   ...
   sql
   ...
}
...
post-auth {
    ...
    sql
    ...
    Post-Auth-Type REJECT {
        sql
    }
    ....

}
```

Modifier la ligne `program` dans `/etc/raddb/mods-enabled/ntlm_auth` comme suit :

Dans le fichier `/etc/raddb/mods-available/sql`, remplacez `dialect` par `mysql` :

```bash
        dialect = "mysql"
```

Ensuite, modifiez le pilote – `driver`– :

```bash
        driver = "rlm_sql_${dialect}"
```

Dans la section `mysql {`, supprimez la sous-section `tls {`.

Ensuite, définissez le nom de la base de données, le nom d'utilisateur et le mot de passe :

```bash
        server = "127.0.0.1"
        port = 3306
        login = "radius"
        password = "password"
        ...
        radius_db = "radius"
```

Remplacez les champs ci-dessus par votre serveur et votre nom d'utilisateur respectifs.

Vous devrez aussi définir les clients. Ceci afin d'empêcher tout accès non autorisé à votre serveur RADIUS. Modifiez le fichier `clients.conf` ainsi :

```bash
vi clients.conf
```

Insérez ce qui suit :

```bash
client 172.20.0.254 {
        secret = secret123
}
```

Remplacez `172.20.0.254` et `secret123` par l'adresse IP et la valeur secrète que les clients utiliseront. Répétez ceci pour les autres clients.

## Insertion du schéma MariaDB

Commencez par activer MariaDB et exécutez le programme d'installation.

```bash
systemctl enable --now mysql
mysql_secure_installation
```

Ensuite, connectez-vous à MariaDB :

```bash
mysql -u root -p
```

Créez maintenant l'utilisateur et la base de données de RADIUS :

```bash
create database radius;
create user 'radius'@'localhost' identified by 'password';
grant all privileges on radius.* to 'radius'@'localhost';
```

Remplacez le nom d'utilisateur, le mot de passe et le nom de la base de données par les valeurs souhaitées.

Insérez ensuite le schéma MariaDB :

```bash
mysql -u root -p radius < /etc/raddb/mods-config/sql/dhcp/mysql/schema.sql
```

Remplacez le nom de la base de données par celui que vous avez choisi.

## Création d'utilisateurs

Connectez-vous d'abord à MariaDB :

```bash
mysql -u root -p radius
```

Vous pouvez ensuite ajouter des utilisateurs :

```bash
insert into radcheck (username,attribute,op,value) values("neha", "Cleartext-Password", ":=", "iloveicecream");
```

Remplacez `neha` et `iloveicecream` par le nom d'utilisateur et le mot de passe respectifs souhaités.

Vous pouvez également utiliser des logiciels tiers pour ajouter des utilisateurs. Par exemple, WHMCS (Web Host Manager Complete Solution) et divers systèmes de facturation des fournisseurs d'accès Internet rendent cela possible.

## Activation de `FreeRADIUS`

Après la configuration initiale, vous pouvez démarrer `radiusd` :

```bash
systemctl enable --now radiusd
```

## Configuration de RADIUS sur un commutateur

Après avoir configuré le serveur FreeRADIUS, vous configurerez un client RADIUS.

À titre d'exemple, le commutateur MikroTik de l'auteur peut être configuré comme suit :

```bash
/radius
add address=172.20.0.12 secret=secret123 service=dot1x
/interface dot1x server
add interface=combo3
```

Remplacez `172.20.0.12` par l'adresse IP du serveur FreeRADIUS et `secret123` par le secret que vous avez défini précédemment.
