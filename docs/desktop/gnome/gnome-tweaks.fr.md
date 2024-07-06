---
title: GNOME Tweaks
author: Steven Spencer
contributors: Ganna Zhyrnova
---

## Introduction

GNOME Tweaks est un outil permettant de personnaliser l'environnement de bureau, notamment les polices par défaut, les fenêtrages, les espaces de travail, etc.

## Prérequis

- Un poste de travail ou un serveur Rocky Linux avec une interface graphique qui utilise GNOME.

## Installation de GNOME tweaks

GNOME Tweaks est disponible depuis le référentiel « appstream », ne nécessitant aucune configuration de référentiel supplémentaire. Installez avec la commande suivante :

```bash
sudo dnf install gnome-tweaks
```

L’installation inclut toutes les dépendances nécessaires.

## Écrans et fonctionnalités

![Activities Menu](images/activities.png)

Pour lancer 'tweaks', dans la recherche du menu Activités, tapez « tweaks » et cliquez sur « Tweaks ».

![Tweaks](images/tweaks.png)

<!-- Please, add here a screen where you click Tweaks -->

_General_ permet de modifier le comportement par défaut des animations, de la suspension et de la suramplification.

![Tweaks General](images/01_tweaks.png)

_Appearance_ permet de modifier les paramètres par défaut du thème ainsi que les images d'arrière-plan et de verrouillage.

![Tweaks Appearance](images/02_tweaks.png)

_Fonts_ permet de modifier les polices et les tailles par défaut.

![Tweaks Fonts](images/03_tweaks.png)

_Keyboard & Mouse_ permet de modifier le comportement par défaut du clavier et de la souris.

![Tweaks Keyboard and Mouse](images/04_tweaks.png)

Si vous souhaitez lancer des applications au démarrage du shell GNOME, vous pouvez les configurer dans _Startup Applications_.

![Tweaks Startup Applications](images/05_tweaks.png)

Personnalisez ici les paramètres par défaut de la _Top Bar_ (horloge, calendrier, batterie).

![Tweaks Top Bar](images/06_tweaks.png)

_Window Titlebars_ permet de modifier le comportement par défaut des barres de titre.

![Tweaks Window Titlebars](images/07_tweaks.png)

_Windows_ permet de changer le comportement par défaut des fenêtres.

![Tweaks Windows](images/08_tweaks.png)

_Workspaces_ vous permet de modifier la façon dont les espaces de travail sont créés (dynamiquement ou statiquement) et la manière dont vous souhaitez que ces espaces de travail apparaissent.

![Tweaks Workspaces](images/09_tweaks.png)

!!! note "Remarque"

```
Vous pouvez tout réinitialiser aux valeurs par défaut en utilisant le menu à trois barres à côté de « Tweaks » dans le coin gauche.
```

## Conclusion

GNOME Tweaks est un excellent outil pour personnaliser votre environnement de bureau GNOME.
