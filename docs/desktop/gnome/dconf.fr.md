---
title: Éditeur de Configuration – dconf
author: Ezequiel Bruni
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

GNOME adopte une approche très rationalisée de son interface utilisateur et de ses fonctionnalités. Ce n'est pas une mauvaise chose, car cela facilite l'apprentissage et l'installation GNOME par défaut vous permet de vous mettre directement au travail.

Cependant, cette approche signifie également que la configuration n'est pas aussi simple que certains le souhaiteraient. Bien sûr, si vous ne trouvez pas ce dont vous avez besoin dans le panneau `Settings`, vous pouvez installer `GNOME Tweaks` pour étendre vos possibilités. Vous pouvez même installer des extensions GNOME pour bénéficier de nouvelles fonctionnalités et options.

Mais que faire si vous souhaitez voir en détail tous les paramètres, fonctionnalités et configurations que les développeurs de GNOME vous ont dissimulés ? Bien sûr, vous pouvez rechercher votre problème actuel en ligne et saisir une commande pour modifier une variable mystérieuse, ou bien vous installez `dconf Editor`.

`dconf Editor` est essentiellement une application de paramètres GNOME qui contient _tout_ et sait tout faire. En fait, cela pourrait vous rappeler un peu le registre Windows, et la fonction _est_ similaire. Cependant, il est plus lisible mais il ne couvre que les fonctionnalités de GNOME et certains des logiciels créés pour GNOME.

Et vous pouvez également modifier les paramètres des extensions GNOME.

!!! warning "Avertissement"

```
La comparaison avec le registre Windows est tout à fait intentionnelle. Tout comme les clés de registre erronées, *certains* paramètres de GNOME Shell peuvent en fait endommager votre installation GNOME, ou au moins causer des problèmes. Vous devrez peut-être restaurer les anciens paramètres via la ligne de commande.

Si vous n'êtes pas sûr de la fonction d'un paramètre particulier, faites d'abord des recherches à ce sujet. La modification des paramètres d'application est toutefois acceptable et beaucoup plus facile à annuler.
```

## Prérequis

Pour ce guide, vous aurez besoin des conditions suivantes :

- Installation de Rocky Linux, GNOME inclus.
- Les droits nécessaires pour l'installation de logiciels sur votre système (privilèges `sudo`).

## `dconf Editor` — Installation

Accédez à l'application `Software`, recherchez `Dconf Editor` et appuyez sur le bouton d'installation. Il est disponible dans le dépôt de Rocky Linux par défaut.

![the GNOME software center, featuring dconf Editor](images/dconf-01.png)

Pour installer l'éditeur dconf avec la ligne de commande, procédez comme suit :

```bash
sudo dnf install dconf-editor
```

## `dconf Editor` — Utilisation

Une fois que vous aurez ouvert l’application, vous verrez trois éléments importants de l’interface utilisateur. Tout en haut se trouve le chemin. Les paramètres GNOME sont organisés selon une arborescence de dossiers.

En haut à droite vous verrez un bouton avec une petite étoile. C'est le bouton `Favorites`, vous pouvez ainsi enregistrer votre état dans l'application et y revenir plus tard rapidement et facilement. En dessous se trouve le panneau principal dans lequel vous sélectionnez vos sous-dossiers de paramètres et modifiez les paramètres comme bon vous semble.

![a screenshot of the dconf Editor window with arrows pointing at the aforementioned elements](images/dconf-02.png)

À gauche du bouton `Favorites`, vous verrez le bouton `Search`, qui fait exactement ce que vous attendez.

Que faire si vous souhaitez modifier certains paramètres dans le gestionnaire de fichiers ? Par exemple, l'auteur adore la barre latérale. L'auteur trouve ça bien pratique. Mais peut-être que vous ressentez différemment et vous souhaitez effectuer des modifications. Donc, pour les besoins de ce guide, il faut continuer.

![a screenshot of the Nautilus file manager, with a threatening red X over the doomed sidebar](images/dconf-03.png)

Allez dans `/org/gnome/nautilus/window-state` et vous verrez une option appelée `start-with-sidebar`. Appuyez sur le bouton bascule et cliquez sur `Reload` lorsque l'écran apparaît comme ceci :

![a screenshot of dconf Editor, showing the toggle and reload button in question](images/dconf-04.png)

Si tout s'est bien passé, la prochaine fenêtre du navigateur de fichiers que vous ouvrirez devrait ressembler à ceci :

![a screenshot of the file manager, bereft of its sidebar](images/dconf-05.png)

Si cela ne vous semble pas correct, rétablissez-le, appuyez à nouveau sur Recharger et ouvrez une nouvelle fenêtre du navigateur de fichiers.

Enfin, vous pouvez également cliquer directement sur n'importe quel paramètre dans la fenêtre `dconf Editor` pour voir plus d'informations (et parfois plus d'options). Par exemple, voici à quoi ressemble l'écran des paramètres `initial-size` du gestionnaire de fichiers GNOME.

![a screenshot of dconf Editor showing the initial-size settings for the file manager](images/dconf-06.png)

## Dépannage

Si vous modifiez vos paramètres dans `dconf Editor` et que vous ne voyez aucun changement, essayez alors l’une des solutions suivantes :

1. Redémarrez l'application sur laquelle vous effectuez les modifications.
2. Déconnectez-vous et reconnectez-vous, ou redémarrez pour apporter des modifications à GNOME Shell.
3. Abandonnez car cette option n’est tout simplement plus fonctionnelle.

Sur ce dernier point : oui, les développeurs GNOME vous suppriment parfois simplement la possibilité de modifier réellement un paramètre, même avec `dconf Editor`.

Par exemple, l'auteur a essayé d'apporter des modifications aux paramètres du sélecteur de fenêtres (la liste des fenêtres ouvertes qui s'affiche lorsque vous appuyez sur ++alt+tab++), et n'a obtenu aucun résultat. Peu importe ce que l'auteur a essayé, `dconf Editor` semble n'avoir aucun effet sur certaines de ses fonctions.

Cela pourrait être un bug, mais ce ne serait pas la première fois qu'un paramètre affiché dans `dconf Editor` était essentiellement désactivé de manière furtive. Si vous rencontrez ce problème, recherchez sur le site des extensions GNOME pour voir s'il existe une extension qui ajoute l'option que vous souhaitez dans GNOME.

## Conclusion

C'est tout ce que vous devez savoir pour commencer. N'oubliez pas de garder une trace de toutes vos modifications, de ne pas modifier les paramètres sans savoir exactement ce qu'ils font, et amusez-vous à explorer les options qui s'offrent (pour la plupart) à votre disposition.
