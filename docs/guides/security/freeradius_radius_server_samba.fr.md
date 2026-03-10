---
title: FreeRADIUS RADIUS Serveur et Samba Active Directory
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 10.1
tags:
  - sécurité
---

## Introduction

RADIUS est un protocole AAA (authentification, autorisation et comptabilisation – accounting) permettant de gérer l'accès au réseau. [FreeRADIUS](https://www.freeradius.org/) est le serveur RADIUS de facto pour Linux et autres systèmes de type Unix.

Vous pouvez faire fonctionner FreeRADIUS avec Active Directory de Microsoft, par exemple pour l'authentification 802.1X, Wi-Fi ou VPN.

## Prérequis

Voici les exigences minimales pour cette procédure :

- La capacité d'exécuter des commandes en tant qu'utilisateur root ou d'utiliser `sudo` pour élever les privilèges
- Un serveur membre d'Active Directory, qu'il utilise un domaine Windows Server ou Samba
- Un client RADIUS, tel qu’un routeur, un commutateur ou un point d’accès Wi-Fi

## Configuration de Samba

Vous devrez [configurer Active Directory avec Samba](../security/authentication/active_directory_authentication_with_samba). Notez que sssd ne fonctionnera pas.

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

Vous devrez ensuite activer `ntlm_auth`. Modifiez le fichier `/etc/raddb/sites-enabled/default` et insérez le code suivant dans le bloc `authenticate` :

```bash
authenticate {
...
    ntlm_auth
...
}
```

Insérez la même ligne dans `/etc/raddb/sites-enabled/inner_tunnel` :

```bash
authenticate {
...
    ntlm_auth
...
}
```

Modifier la ligne `program` dans `/etc/raddb/mods-enabled/ntlm_auth` comme suit :

```bash
    program = "/usr/bin/ntlm_auth --request-nt-key --domain=MYDOMAIN --username=%{mschap:User-Name} --password=%{User-Password}"
```

Remplacez `MYDOMAIN` par le nom de votre domaine Active Directory.

Vous devrez définir `ntlm_auth` comme type d'authentification par défaut dans `/etc/raddb/mods-config/files/authorize`. Ajoutez la ligne suivante :

```bash
DEFAULT   Auth-Type = ntlm_auth
```

Vous devrez aussi définir les clients. Ceci afin d'empêcher tout accès non autorisé à notre serveur RADIUS. Modifiez le fichier `clients.conf` ainsi :

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
