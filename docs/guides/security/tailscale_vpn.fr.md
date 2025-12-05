---
title: Tailscale VPN
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 10.0
tags:
  - sécurité
  - vpn
---

# Tailscale VPN

## Introduction

[Tailscale](https://tailscale.com/) est un VPN peer-to-peer chiffré de bout en bout, sans configuration, basé sur Wireguard. Tailscale prend en charge tous les principaux systèmes d'exploitation de bureau et mobiles.

Comparé à d’autres solutions VPN, Tailscale ne nécessite pas de ports TCP/IP ouverts et peut fonctionner derrière la traduction d’adresses réseau ou un pare-feu.

## Prérequis

Voici les exigences minimales pour utiliser cette procédure :

- La possibilité d'exécuter des commandes en tant qu'utilisateur `root` ou d'utiliser `sudo` pour élever les privilèges
- Un compte Tailscale

## Installation de Tailscale

Pour installer Tailscale, il faut d'abord ajouter son dépôt `dnf` :

```bash
dnf config-manager --add-repo https://pkgs.tailscale.com/stable/rhel/10/tailscale.repo
```

Ensuite installez `Tailscale` :

```bash
dnf install tailscale
```

## Configuration de Tailscale

Une fois les paquets installés, vous devez activer et configurer Tailscale. Pour activer le démon Tailscale :

```bash
systemctl enable --now tailscaled
```

Par la suite, vous vous authentifierez auprès de Tailscale :

```bash
tailscale up
```

Vous obtiendrez une URL pour l'authentification. Visitez-le dans un navigateur et connectez-vous à Tailscale :

![Tailscale login screen](../images/tailscale_1.png)

Ensuite, vous accorderez l’accès à votre serveur. Cliquez **Connect** pour ce faire :

![Tailscale grant access dialog](../images/tailscale_2.png)

Une fois l'accès accordé, vous verrez une boîte de dialogue de réussite :

![Tailscale login successful dialog](../images/tailscale_3.png)

Une fois que votre serveur est authentifié avec Tailscale, il obtiendra une adresse IPv4 Tailscale :

```bash
tailscale ip -4
```

Il recevra également une adresse IPv6 Tailscale RFC 4193 (adresse locale unique) :

```bash
tailscale ip -6
```

## Conclusion

Les services VPN traditionnels utilisant une passerelle VPN sont centralisés. Cela nécessite une configuration manuelle, la configuration de votre pare-feu et l'attribution de comptes d'utilisateurs. Tailscale résout ce problème grâce à son modèle pair-à-pair combiné à un contrôle d'accès au niveau du réseau.
