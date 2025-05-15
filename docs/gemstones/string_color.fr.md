---
title: bash - Couleur de Chaîne
author: tianci li
contributors: Steven Spencer
tested_with: 8.6, 9.0
tags:
  - bash
  - couleur
---

# Introduction

Lorsque nous téléchargeons des scripts bash qui ont été écrits par d'autres auteurs dans notre travail quotidien, certaines chaînes clés sont parfois marquées avec des couleurs spéciales. Comment cet effet peut-il être obtenu en implémentant un script ?

## Font color

| **code de couleur** | **description** |
|:-------------------:|:---------------:|
|         30          |      noir       |
|         31          |      rouge      |
|         32          |      vert       |
|         33          |      jaune      |
|         34          |      bleu       |
|         35          |     violet      |
|         36          |   vert foncé    |
|         37          |      blanc      |

## Couleur d'arrière-plan de la police

| **Code couleur d'arrière-plan** | **description** |
|:-------------------------------:|:---------------:|
|               40                |      noir       |
|               41                |     crimson     |
|               42                |      vert       |
|               43                |      jaune      |
|               44                |      bleu       |
|               45                |     violet      |
|               46                |   vert foncé    |
|               47                |      blanc      |

## Mode d'affichage

| **Code** |          **description**          |
|:--------:|:---------------------------------:|
|    0     | Paramètres par défaut du terminal |
|    1     |             Surligner             |
|    4     |             Souligné              |
|    5     |      Clignotement du curseur      |
|    7     |         Affichage inversé         |
|    8     |              Masquer              |

## Mode d'Exécution

* **\033[1;31;40m** "1" indique le mode d'affichage, qui est optionnel. "31" indique la couleur de police. "40m" indique la couleur de fond de la police

* **\033[0m** Restaurer la couleur par défaut du terminal, c'est-à-dire annuler le réglage de couleur

## Exemple de Script

Vous pouvez écrire un script pour observer le changement des couleurs.

```bash
#!/bin/bash
# Font color cycle
for color1 in {31..37}
    do
        echo -e "\033[0;${color1};40m---hello! world---\033[0m"
    done

echo "-------"

# Background color cycle
for color2 in {40..47}
    do
        echo -e "\033[30;${color2}m---hello! world---\033[0m"
    done

echo "-------"

# Cycle of display mode
for color3 in 0 1 4 5 7 8
    do
        echo -e "\033[${color3};37;40m---hello! Rocky---\033[0m"
    done
```

```bash
Shell > chmod a+x color_set.sh
Shell > ./color_set.sh
```

Le résultat est le suivant :

![image1](./images/string_color_image1.png)
