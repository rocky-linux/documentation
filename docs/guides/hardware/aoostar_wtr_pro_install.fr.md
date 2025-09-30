---
title: Installation de Rocky Linux 10 sur `AOOSTAR WTR PRO`
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 10.0
tags:
  - hardware
---

## Introduction

L'`AOOSTAR WTR PRO` est un NAS x86 basse consommation doté de quatre baies de lecteur. Il s'agit d'une alternative plus rapide et moins chère au HPE ProLiant MicroServer. Par exemple, l'auteur en a acheté un comme NAS personnel.

Bien que la conception du WTR PRO soit conçue pour exécuter des distributions Linux standard, le programme d'installation de Rocky Linux ne démarrera pas immédiatement dessus. Cependant, vous pouvez toujours installer Rocky Linux.

## Prérequis

Les conditions suivantes sont indispensables pour utiliser la procédure décrite ici :

- Un installateur USB Rocky Linux

- Un système AOOSTAR WTR PRO

## Démarrage du programme d'installation de Rocky Linux

Tout d'abord, vous allez démarrer à partir de la clé USB.

Si un système d'exploitation existant est présent sur le SSD, appuyez sur ++delete++ lors de la mise sous tension du WTR PRO. Allez à **Save &amp; Exit** et sélectionnez la clé USB.

Lorsque vous démarrez la clé USB dans le menu GRUB, sélectionnez **Troubleshooting** :

![GRUB Main Menu](../images/aoostar_1.png)

Ensuite, sélectionnez **Install Rocky Linux _VERSION_ in basic graphics mode**:

![GRUB Troubleshooting Menu](../images/aoostar_2.png)

Rocky Linux devrait maintenant démarrer et s'installer normalement.

Notez qu'aucune option de noyau spéciale n'est requise lors de l'installation de Rocky Linux.
