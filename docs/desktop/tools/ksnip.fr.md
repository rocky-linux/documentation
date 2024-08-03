---
title: Annotation de Captures d'Écran avec Ksnip
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - Desktop
  - Capture d'écran
---

## Prérequis

- Rocky 9.4 Workstation
- Droits d'accès `sudo`

## Introduction

`Ksnip` est un utilitaire de capture d'écran riche en outils pour annoter les captures d'écran. Ce guide se concentre sur l'installation de `Ksnip` et de ses outils d'annotation.

## Installation de `Ksnip`

Ksnip nécessite le référentiel EPEL. Si l'EPEL n'est pas activé, vous pouvez le faire avec la commande suivante :

```bash
sudo dnf install epel-release
```

Effectuez ensuite une mise à jour du système :

```bash
sudo dnf update -y
```

Maintenant, installez `Ksnip` :

```bash
sudo dnf install ksnip -y
```

## Ouvrir une image

1. Lancer Ksnip
2. Cliquez `File > Open`
3. Sélectionnez l'image que vous souhaitez annoter

![ksnip](images/ksnip.png)

## Annoter une image avec `Ksnip`

`Ksnip` dispose d'outils pratiques et intuitifs pour annoter des captures d'écran.  Dans l'image, en bas à gauche se trouvent les options décrites ci-dessous.

![ksnip\_open](images/ksnip_image_opened.png)

| Option | Outil              | Description                                                                                                                                                                                                                                                                                                              |
| ------ | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1      | `Select`           | l'outil permet de faire une sélection. Cliquez sur un élément pour le sélectionner ou cliquez et faites glisser pour effectuer une sélection.                                                                                                                                            |
| 2      | `Duplicate`        | l’outil permet de dupliquer une sélection. Cliquez et faites glisser pour effectuer une sélection. Cliquez ensuite sur la sélection et faites-la glisser pour la déplacer ou la transformer davantage.                                                                   |
| 3a     | `Arrow`            | l'outil de flèche par défaut, qui vous permet de cliquer pour créer une flèche et de faire glisser d'un endroit à un autre                                                                                                                                                                                               |
| 3b     | `Double Arrow`     | la deuxième option de flèche est accessible en cliquant sur la flèche vers le bas à côté de l'outil Arrow. Comme le suggère le nom de l'outil, il comporte une flèche aux deux extrémités.                                                                                               |
| 3c     | `Line`             | la troisième option est accessible en cliquant sur la flèche vers le bas à côté de l'outil Arrow. Il remplace les flèches par une simple ligne.                                                                                                                                          |
| 4      | `Pen`              | est utilisé pour créer des traits qui ressemblent à un stylo. Cliquez et déplacez le curseur sur la capture d’écran pour utiliser le stylo. ^1^                                                                                                                                          |
| 5a     | `Marker Pen`       | L'outil par défaut marker est utilisé pour créer des traits qui ressemblent à un surligneur. Maintenez le clic et déplacez le curseur sur la capture d'écran pour utiliser le marqueur. ^1^                                                                                              |
| 5b     | `Marker Rectangle` | la deuxième option de marqueur est accessible en cliquant sur la flèche vers le bas à côté de l'outil Marker. Lorsque vous cliquez avec le bouton gauche de la souris et faites glisser votre curseur, l'outil Marker Rectangle remplira le rectangle créé à partir de la sélection. ^1^ |
| 5c     | `Marker Elipse`    | la troisième option de marqueur est accessible en cliquant sur la flèche vers le bas à côté de l'outil Marker. Lorsque vous cliquez avec le bouton gauche et faites glisser votre curseur, l'outil Marker Ellipse remplira l'ellipse créée à partir de la sélection. ^1^                 |
| 6a     | `Text`             | L'outil `Text` par défaut est utilisé pour annoter une capture d'écran avec du texte. ^1^                                                                                                                                                                                                                |
| 6b     | `Text Pointer`     | la deuxième option de texte est accessible en cliquant sur la flèche vers le bas à côté de l'outil Text. Il attache un pointeur pour attirer l’attention sur le texte. ^1^                                                                                                               |
| 6c     | `Text Arrow`       | la troisième option de texte est accessible en cliquant sur la flèche vers le bas à côté de l'outil Text. Il attache une flèche pour attirer l'attention sur le texte. ^1^                                                                                                               |
| 7a     | `Number`           | l'outil Number par défaut, ajoute un numéro pour attirer l'attention et annoter la capture d'écran avec des numéros. ^1^                                                                                                                                                                                 |
| 7b     | `Number Pointer`   | la deuxième option est accessible en cliquant sur la flèche vers le bas à côté de l'outil Number. Ajoute un numéro avec un pointeur pour compléter les annotations d'une capture d'écran. ^1^                                                                                            |
| 7c     | `Number Arrow`     | la troisième option est accessible en cliquant sur la flèche vers le bas à côté de l'outil Number. Ajoute un numéro avec un pointeur pour compléter les annotations d'une capture d'écran. ^1^                                                                                           |
| 8a     | `Blur`             | l'outil de flou par défaut, qui vous permet de flouter des parties de la capture d'écran en cliquant avec le bouton gauche de la souris et en faisant glisser.                                                                                                                                           |
| 8b     | `Pixelate`         | la deuxième option de l'outil de flou est accessible en cliquant sur la flèche vers le bas à côté de l'outil Blur. Pixellisez n'importe où sur l'écran en cliquant avec le bouton gauche de la souris et en faisant glisser.                                                             |
| 9a     | `Rectangle`        | l'outil rectangle par défaut, vous permet de cliquer et de faire glisser pour créer un rectangle. ^1^                                                                                                                                                                                                    |
| 9b     | `Ellipse`          | la deuxième option de l'outil rectangle, accessible en cliquant sur la flèche vers le bas à côté de l'outil Rectangle. Vous permet de cliquer et de faire glisser pour créer une ellipse sur l'écran. ^1^                                                                                |
| 10     | `Sticker`          | place un sticker ou un émoji sur une capture d'écran. En sélectionnant l'outil et en cliquant, le sticker pourra être placé.                                                                                                                                                             |

## Conclusion

Ksnip est un utilitaire excellent pour annoter des captures d'écran. L'utilitaire peut également prendre des captures d'écran, mais ce guide se concentre principalement sur les capacités et les outils d'annotation fournis par `Ksnip`.

Consultez [Ksnip GitHub Repo](https://github.com/ksnip/ksnip){target="_blank"} pour en savoir plus sur cet excellent utilitaire de capture d'écran.

**1.** Chacun des outils dont les descriptions sont suivies de ==this superscript== (^1^), dispose de diverses options de commande disponibles dans le menu supérieur après avoir effectué la sélection de l'outil. Ils modifient l'opacité, la bordure, la police, le style de police et d'autres attributs.
