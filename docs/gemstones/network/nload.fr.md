---
title: nload - Statistiques de Bande Passante
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
date: 2024-01-16
---

# Présentation de `nload`

`nload` est un moniteur de trafic réseau basé sur une console de texte. Il affiche les statistiques de trafic et de bande passante de votre serveur.

## Utilisation de `nload`

```bash
dnf -y install epel-release
dnf -y install nload
```

Voici les options courantes de la commande `nload` qui, dans des circonstances normales, ne nécessitent rien de plus. Les options précèdent l'interface à surveiller :

| Options     | Observation                                                                                                     |
| ----------- | --------------------------------------------------------------------------------------------------------------- |
| -a PERIOD   | Durée de la fenêtre de calcul en secondes (par défaut : 300)                 |
| -m          | Affiche plusieurs périphériques et ne présente pas de graphique de trafic                                       |
| -t INTERVAL | Intervalle d'actualisation en millisecondes (par défaut : 500)               |
| -u UNIT     | Unité à une lettre pour l'affichage de la bande passante (par défaut : k)    |
| -U UNIT     | Unité à une lettre pour l'affichage du transfert de données (par défaut : M) |

Les unités pour les deux dernières options sont les suivantes :

| Unité | Signification |
| ----- | ------------- |
| b     | bit           |
| B     | octet         |
| k     | kilobit       |
| K     | kilooctet     |
| m     | megabit       |
| M     | mégaoctet     |
| g     | gigabit       |
| G     | gigaoctet     |

Un exemple de sortie du serveur home de l'auteur exécutant un [relais](https://community.torproject.org/relay/types-of-relays/) [Tor](https://www.torproject.org/) :

```bash
Device bridge0 [172.20.0.3] (1/8):
================================================================================
Incoming:
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########  Curr: 79.13 MBit/s
                                             ########  Avg: 84.99 MBit/s
                                             ########  Min: 79.13 MBit/s
                                             ########  Max: 87.81 MBit/s
                                             ########  Ttl: 1732.95 GByte
Outgoing:
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########  Curr: 81.30 MBit/s
                                             ########  Avg: 88.05 MBit/s
                                             ########  Min: 81.30 MBit/s
                                             ########  Max: 91.36 MBit/s
                                             ########  Ttl: 1790.74 GByte
```

Décorticage des lignes ci-dessus :

- Curr – utilisation actuelle de la bande passante
- Avg - utilisation moyenne de la bande passante au cours d'une période donnée
- Min - utilisation minimale de la bande passante mesurée
- Max - utilisation maximale de la bande passante mesurée
- Ttl - données transférées lors de la session `nload`

## Racourcis de clavier

- \++page-down++, ++down++ – Descendre d'une interface
- \++page-up++, ++up++ – Remonter d'une interface
- \++f2++ - Affiche la fenêtre des options
- \++f5++ - Enregistrer les options
- \++f6++ – Recharger les paramètres à partir du fichier de configuration
- \++q++, ++ctrl+c++ - Quitter `nload`
