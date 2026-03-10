---
title: FreeRADIUS – Serveur RADIUS
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - sécurité
---

# Serveur FreeRADIUS 802.1X

## Introduction

RADIUS est un protocole AAA (authentification, autorisation et comptabilisation – accounting) permettant de gérer l'accès au réseau. [FreeRADIUS](https://www.freeradius.org/) est le serveur RADIUS de facto pour Linux et autres systèmes de type Unix.

## Prérequis

Voici les exigences minimales pour cette procédure :

- La capacité d'exécuter des commandes en tant qu'utilisateur root ou d'utiliser `sudo` pour élever les privilèges
- Un client RADIUS, tel qu’un routeur, un commutateur ou un point d’accès Wi-Fi

## Installation de FreeRADIUS

Vous pouvez installer FreeRADIUS à partir des dépôts `dnf` :

```bash
dnf install -y freeradius
```

## Configuration de `FreeRADIUS`

Une fois les paquets installés, vous devez d'abord générer les certificats de chiffrement TLS pour FreeRADIUS :

```bash
cd /etc/raddb/certs
./bootstrap
```

Vous devrez ensuite ajouter des utilisateurs à authentifier. Accédez au fichier `users` :

```bash
cd ..
vi users
```

Dans le fichier, insérez ce qui suit :

```bash
user    Cleartext-Password := "password"
```

Remplacez `neha` et `iloveicecream` par le nom d'utilisateur et le mot de passe respectifs souhaités.

Sachez que le mot de passe n'est pas haché ; par conséquent, si un attaquant met la main sur le fichier `users`, il pourrait obtenir un accès non autorisé à votre réseau protégé.

Vous pouvez également utiliser un mot de passe haché avec `MD5` ou `Crypt`. Pour générer un mot de passe haché en MD5, exécutez :

```bash
echo -n password | md5sum | awk '{print $1}'
```

Remplacez
`password` par le mot de passe souhaité.

Vous obtiendrez un hachage de `5f4dcc3b5aa765d61d8327deb882cf99`. Dans le fichier `users`, insérez plutôt ce qui suit :

```bash
user    MD5-Password := "5f4dcc3b5aa765d61d8327deb882cf99"
```

Vous devrez aussi définir les clients. Ceci afin d'empêcher tout accès non autorisé à votre serveur RADIUS. Modifiez le fichier `clients.conf` ainsi :

```bash
vi clients.conf
```

Insérez les éléments suivants :

```bash
client 172.20.0.254 {
        secret = secret123
}
```

Remplacez `172.20.0.254` et `secret123` par l'adresse IP et la valeur secrète que les clients utiliseront. Répétez ceci pour les autres clients.

## Activation de `FreeRADIUS`

Après la configuration initiale, vous pouvez démarrer `radiusd` :

```bash
systemctl enable --now radiusd
```

## Configuration de RADIUS sur un switch

Après avoir configuré le serveur FreeRADIUS, vous configurerez un client RADIUS.

À titre d'exemple, le commutateur MikroTik de l'auteur peut être configuré comme suit :

```bash
/radius
add address=172.20.0.12 secret=secret123 service=dot1x
/interface dot1x server
add interface=combo3
```

Remplacez `172.20.0.12` par l'adresse IP du serveur FreeRADIUS et `secret123` par le secret que vous avez défini précédemment.
