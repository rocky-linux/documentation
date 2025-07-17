---
title: Activation du relais VLAN sur les cartes réseau Marvell de la série AQC
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.6
tags:
  - hardware
---

## Introduction

L'auteur utilise une carte réseau (NIC) basée sur Marvell AQC107 dans son serveur home, qui dispose d'une machine virtuelle utilisée pour un pare-feu virtualisé. Malheureusement, le pilote Rocky Linux Marvell d'origine AQC supprime les VLAN sur les interfaces bridge. Cela est arrivé à la machine virtuelle OPNsense de l'auteur. Heureusement, ça peut être évité.

## Prérequis

Les conditions suivantes sont indispensables pour utiliser cette procédure :

- Un serveur Rocky Linux avec une carte réseau Marvell de la série AQC
- Utilisation de NetworkManager pour la configuration du réseau

## Désactivation du filtrage VLAN

Vous pouvez désactiver le filtrage VLAN avec une seule commande :

    nmcli con modify enp1s0 ethtool.feature-rx-vlan-filter off

Remplacez `enp1s0` par le nom de votre adaptateur réseau basé sur AQC.
