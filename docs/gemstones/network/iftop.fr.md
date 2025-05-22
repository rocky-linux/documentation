---
title: ifop - Statistiques Live de Bande Passante
author: Neel Chauhan
contributors: Ganna Zhyrnova, Steven Spencer
date: 2024-02-24
---

# `iftop` - Introduction

`igtop` est un moniteur de trafic réseau basé sur une console de texte. Il affiche les statistiques de trafic et de bande passante de votre serveur.

## Utilisation de `iftop`

```bash
dnf -y install epel-release
dnf -y install iftop
```

Les options de la commande `iftop` sont les suivantes.

| Options        | Observation                                                                                                                     |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| -R             | Évite les recherches de nom d'hôte                                                                                              |
| -N             | Évite de résoudre les numéros de port en noms de service                                                                        |
| -p             | Fonctionne en mode promiscuité, de sorte que tout le trafic est compté                                                          |
| -P             | Affiche les numéros de port pour les connexions                                                                                 |
| -l             | Affiche et compte le trafic vers ou depuis les adresses IPv6 locales                                                            |
| -b             | N'affiche pas de graphiques à barres pour le trafic                                                                             |
| -m LIMIT       | Définit une limite supérieure pour le graphique de bande passante, spécifiée sous la forme d'un nombre et d'un suffixe unitaire |
| -u UNIT        | Affiche les taux de trafic dans l'unité donnée                                                                                  |
| -B UNIT        | Synonyme pour -u                                                                                                                |
| -i INTERFACE   | Interface à évaluer                                                                                                             |
| -f FILTER CODE | Utilise le code de filtre suivant                                                                                               |
| -F NET/MASK    | Mesure uniquement le trafic passant par le réseau IPv4 spécifié                                                                 |
| -G NET/MASK    | Mesure uniquement le trafic passant par le réseau IPv6 spécifié                                                                 |
| -c config      | Utilise le fichier de configuration indiqué                                                                                     |
| -t             | Utilise le mode non-ncurses                                                                                                     |

Les unités pour l'indicateur **-M** sont les suivantes :

| Unité | Signification |
| ----- | ------------- |
| K     | Kilo          |
| M     | Mega          |
| G     | Giga          |

Les unités pour l'indicateur **-u** sont les suivantes :

| Unité   | Signification       |
| ------- | ------------------- |
| bit     | bits par seconde    |
| octets  | octets par seconde  |
| paquets | paquets par seconde |

Un exemple de sortie du serveur home de l'auteur exécutant un [relais](https://community.torproject.org/relay/types-of-relays/) [Tor](https://www.torproject.org/) :

```bash
 Listening on bridge b          25.0Kb          37.5Kb          50.0Kb    62.5Kb
└───────────────┴───────────────┴───────────────┴───────────────┴───────────────
tt.neelc.org               => X.X.X.X                    13.5Mb  13.5Mb  13.5Mb
                           <=                             749Kb   749Kb   749Kb
tt.neelc.org               => X.X.X.X                    6.21Mb  6.21Mb  6.21Mb
                           <=                             317Kb   317Kb   317Kb
tt.neelc.org               => X.X.X.X                    3.61Mb  3.61Mb  3.61Mb
                           <=                             194Kb   194Kb   194Kb
tt.neelc.org               => X.X.X.X                     181Kb   181Kb   181Kb
                           <=                            3.36Mb  3.36Mb  3.36Mb
tt.neelc.org               => X.X.X.X                     151Kb   151Kb   151Kb
                           <=                            3.24Mb  3.24Mb  3.24Mb
tt.neelc.org               => X.X.X.X                    2.97Mb  2.97Mb  2.97Mb
                           <=                             205Kb   205Kb   205Kb
tt.neelc.org               => X.X.X.X                     156Kb   156Kb   156Kb
                           <=                            2.97Mb  2.97Mb  2.97Mb
tt.neelc.org               => X.X.X.X                    2.80Mb  2.80Mb  2.80Mb
                           <=                             145Kb   145Kb   145Kb
tt.neelc.org               => X.X.X.X                     136Kb   136Kb   136Kb
                           <=                            2.45Mb  2.45Mb  2.45Mb
────────────────────────────────────────────────────────────────────────────────
TX:             cum:   30.1MB   peak:    121Mb  rates:    121Mb   121Mb   121Mb
RX:                    30.4MB            122Mb            122Mb   122Mb   122Mb
TOTAL:                 60.5MB            242Mb            242Mb   242Mb   242Mb
```

Analyse des lignes du volet inférieur :

- TX - Utilisation des données de transmission/téléchargement
- RX - Utilisation des données de réception/téléchargement
- TOTAL - Quantité totale de téléchargement/téléchargement

## Racourcis de clavier

- \++s++ - regroupe tout le trafic pour chaque source
- \++d++ - regroupe tout le trafic pour chaque destination
- \++shift+s++ - bascule vers l'affichage du port source
- \++shift+d++ - bascule vers l'affichage du port de destination
- \++t++ - bascule entre les modes d'affichage : affichage par défaut sur deux lignes avec le trafic d'envoi et de réception et affichage sur trois lignes du trafic d'envoi, de réception et total
- \++1++, ++2++, ++3++ - trier par 1ère, 2ème ou 3ème colonne
- \++l++ - entre une expression régulière POSIX pour filtrer les noms d'hôtes
- \++shift+p++ - met en pause l'affichage actuel
- \++o++ - gèle le comptage total de bande passante
- \++j++ - déroulement vers le bas
- \++k++ - déroulement vers le haut
- \++f++ - édite le code du filtre
