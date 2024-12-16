---
title: accel-ppp – Serveur PPPoE
author: Neel Chauhan
contributors: null
tested_with: 9.3
tags:
  - réseau
---

# `accel-ppp` – Serveur `PPPoE`

## Introduction

PPPoE est un protocole utilisé principalement par DSL et les FAI fibre optique jusqu'au domicile où les clients sont authentifiés avec une combinaison de nom d'utilisateur et de mot de passe. PPPoE est utilisé dans les pays où un FAI existant est tenu de partager son réseau avec d'autres FAI, car les clients peuvent être acheminés via un nom de domaine vers le FAI souhaité.

[accel-ppp](https://accel-ppp.org/) est une implémentation accélérée par le noyau Linux de PPPoE et de protocoles associés tels que PPTP, L2TP et autres.

## Prérequis

- Un serveur avec deux interfaces réseau
- Un routeur client ou une machine parlant PPPoE

## Installation de `accel-ppp`

Installez d’abord EPEL :

```bash
dnf install -y epel-release
```

Ensuite, installez `accel-ppp` :

```bash
dnf install -y accel-ppp
```

## Mise en place de `accel-ppp`

Tout d’abord, nous devons activer IP forwarding :

```bash
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
```

Ensuite, ajoutez ce qui suit à `/etc/accel-ppp.conf` :

```bash
[modules]
log_file
pppoe
auth_mschap_v2
auth_mschap_v1
auth_chap_md5
auth_pap
chap-secrets
ippool

[core]
log-error=/var/log/accel-ppp/core.log
thread-count=4

[ppp]
ipv4=require

[pppoe]
interface=YOUR_INTERFACE

[dns]
dns1=YOUR_DNS1
dns2=YOUR_DNS2

[ip-pool]
gw-ip-address=YOUR_GW
YOUR_IP_RANGE

[chap-secrets]
gw-ip-address=YOUR_GW
chap-secrets=/etc/chap-secrets
```

Remplacez les informations suivantes :

- **YOUR_INTERFACE** avec l'interface à l'écoute des clients PPPoE.
- **YOUR_DNS1** et **YOUR_DNS2** avec les serveurs DNS à remettre aux clients.
- **YOUR_GW** est l'adresse IP du serveur pour les clients PPPoE. Cela **doit** être différent de l'adresse IP WAN du serveur ou de la passerelle par défaut.
- **YOUR_IP_RANGE** avec les plages d'adresses IP à distribuer aux clients. Il peut s'agir d'une plage IP telle que X.X.X.Y-Z ou au format CDIR tel que X.X.X.X/MASK.

Par la suite, ajoutons un fichier `barebones` `/etc/chap-secrets` :

```bash
user	*	password	*
```

Vous pouvez ajouter plus d'utilisateurs avec des lignes supplémentaires en remplaçant `user` et `password` par le nom d'utilisateur et le mot de passe souhaités.

## Configuration d'un client PPPoE

Une fois le serveur PPPoE configuré, nous pouvons commencer à ajouter des clients PPPoE. L'auteur préfère utiliser [MikroTik CHR](https://help.mikrotik.com/docs/display/ROS/Cloud+Hosted+Router%2C+CHR) comme client PPPoE de test de référence, nous l'utiliserons donc.

Une fois que nous avons installé MikroTik CHR sur un système connecté au même réseau Ethernet que l'interface d'écoute du serveur PPPoE, nous pouvons configurer PPPoE :

```bash
[admin@MikroTik] > /interface pppoe-client
[admin@MikroTik] > add add-default-route=yes disabled=no interface=ether1 name=pppoe-out1 \
    password=password user=user
```

Si tout fonctionne correctement, nous devrions obtenir une adresse IPv4 :

```bash
[admin@MikroTik] > /ip/address/print
Flags: D - DYNAMIC
Columns: ADDRESS, NETWORK, INTERFACE
#   ADDRESS      NETWORK   INTERFACE 
0 D 10.0.0.1/32  10.0.0.0  pppoe-out1
```

## Conclusion

PPPoE a souvent mauvaise réputation et il est facile de comprendre pourquoi : vous devez configurer les noms d'utilisateur et les mots de passe manuellement. Malgré cela, cela permet d'assurer la sécurité lors de la connexion à un domaine de diffusion de couche 2 dans les scénarios de FAI où l'exigence de 802.1X ou MACsec serait indésirable, par exemple pour autoriser les routeurs appartenant au client ou les adresses IP statiques. Et maintenant vous possédez votre propre mini-FAI, félicitations !
