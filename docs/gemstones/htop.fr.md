---
title: htop - Gestion des Processus
author: tianci li
contributors: Steven Spencer
date: 2021-10-16
tags:
  - htop
  - processus
---

# htop - Gestion des Processus

## Installation de `htop`

Chaque administrateur système favorise certaines des commandes les plus couramment utilisées. Dans cet article, l'auteur recommande `htop` comme alternative à la commande `top`. Pour utiliser la commande `htop`, en général, vous devez d'abord l'installer.

``` bash
# Installation epel source (also called repository)
dnf -y install epel-release
# Generate cache
dnf makecache
# Install htop
dnf -y install htop
```

## Utilisation de `htop`

Vous n'avez qu'à taper `htop` dans le terminal et l'interface interactive est la suivante :

```bash
0[ |||                      3%]     Tasks: 22, 46thr, 174 kthr 1 running
1[ |                        1%]     Load average: 0.00 0.00 0.05
Mem[ |||||||           197M/8G]     Uptime: 00:31:39
Swap[                  0K/500M]
PID   USER   PRI   NI   VIRT   RES   SHR   S   CPU%   MEM%   TIME+   Command(merged)
...
```

++f1++ Help ++f2++ Setup ++f3++ Search ++f4++ Filter ++f5++ Tree ++f6++ SortBy ++f7++ Nice ++f8++ Nice ++f9++ Kill ++f10++ Quit

### Description de la partie supérieure

* Les 0 et 1 indiquent le numéro des cœurs de la CPU et le pourcentage indique le taux d'occupation d'un seul cœur (le taux d'occupation total de la CPU peut également être affiché)
    * Les différentes couleurs de la barre de progression indiquent le pourcentage de différents types de processus :

        | Couleur | Observation                                                               | Noms affichés avec d'autres styles |
        | ------- | ------------------------------------------------------------------------- | ---------------------------------- |
        | Bleu    | Pourcentage de CPU utilisé par les processus de faible priorité           | low                                |
        | Vert    | Pourcentage de CPU du processus appartenant à des utilisateurs ordinaires |                                    |
        | Rouge   | Pourcentage de CPU utilisé par les processus du système                   | sys                                |
        | Cyan    | Pourcentage du temps de CPU Steal Time                                    | vir                                |

* Tasks: 22, 46thr, 174 kthr 1 running. Dans notre exemple, cela signifie que notre machine actuelle a 24 tâches, qui sont divisés en 14 threads, dont un seul processus est en cours d'exécution, "kthr" indique le nombre de kernel-threads.
* Mem décrit la charge de mémoire. Les couleurs permettent de distinguer le type d'occupation de la mémoire :

   | Couleur      | Observation                                                    | Noms affichés |
   | ------------ | -------------------------------------------------------------- | ------------- |
   | Bleu         | Pourcentage de mémoire consommée par le tampon                 | buffers       |
   | Vert         | Pourcentage de mémoire consommée par la zone mémoire           | used          |
   | Jaune/Orange | Pourcentage de mémoire consommée par la zone de cache          | cache         |
   | Magenta      | Pourcentage de mémoire occupée par la zone de mémoire partagée | shared        |

* Swap information.

   | Couleur      | Observation                                | Noms affichés |
   | ------------ | ------------------------------------------ | ------------- |
   | Vert         | Pourcentage de cache utilisé sur le disque | used          |
   | Jaune/Orange | Pourcentage de cache - swap - utilisé      | cache         |

* Charge moyenne, les trois valeurs représentent respectivement la charge moyenne du système au cours de la dernière minute, des 5 dernières minutes et des 15 dernières minutes
* Uptime signifie le temps écoulé depuis le démarrage du système

### Description du processus

* **PID - Numéro d'identification du processus**
* USER - Le propriétaire du processus
* PRI - la priorité du processus du point de vue du noyau Linux
* NI - la priorité du processus de réinitialisation par l'utilisateur normal ou bien root
* VIRT - Mémoire virtuelle consommée par un processus
* **RES - Mémoire physique consommée par un processus**
* SHR - Mémoire partagée consommée par un processus
* S - L'état actuel du processus Z (processus zombie). Un trop grand nombre de processus zombies affectera les performances de la machine.
* **CPU% - Pourcentage de CPU consommé par chaque processus**
* MEM% - Pourcentage de mémoire consommée par chaque processus
* TIME+ - Indique le temps d'exécution depuis le démarrage du processus
* Command - La commande correspondant au processus

### Description des raccourcis

Dans l'interface interactive, appuyez sur le bouton ++f1++ pour voir la description de la touche de raccourci correspondante.

* Les touches de direction haut, bas, gauche et droite peuvent faire défiler l'interface interactive et ++space++ peut accentuer le processus correspondant, qui est marqué en jaune.
* Les boutons ++n++, ++p++, ++m++ et ++t++ respectivement PID, CPU%, MEM%, TIME+ sont utilisés pour le tri. Bien sûr, vous pouvez également utiliser la souris pour effectuer un tri ascendant ou descendant d'un certain champ.

### Autres utilisations courantes

Pour gérer le processus, utilisez le bouton ++f9++ et lui envoyer différents signaux. La liste des signaux peut être affichée avec la commande `kill -l`. Les plus couramment utilisées sont :

| Signal | Observation                                                                                                                                                                                              |
| ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1      | Arrête immédiatement le processus qui redémarre après avoir relu le fichier de configuration                                                                                                             |
| 9      | Utilisé pour mettre fin immédiatement à l'exécution du programme, pour terminer le processus de force, similaire à la fin forcée dans la barre des tâches de la fenêtre                                  |
| 15     | Le signal par défaut pour la commande kill. Parfois, si un problème s'est produit dans le processus et que le processus ne peut pas être terminé normalement avec ce signal, on peut essayer le signal 9 |

## Conclusion

`htop` est beaucoup plus facile à utiliser que la commande `top` qui fait partie du système, il est plus intuitif et améliore grandement l'utilisation au quotidien. C'est pourquoi c'est habituellement la première chose que l'auteur installe après l'installation du système d'exploitation.
