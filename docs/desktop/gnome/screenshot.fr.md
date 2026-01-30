---
title: Capture d'écran et enregistrement de screencasts sous GNOME
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - screenshot
  - screencast
  - guide
---

## Introduction

L'environnement de bureau GNOME moderne, présent dans Rocky Linux, comprend un outil efficace et parfaitement intégré pour la capture d'écran. Il ne s'agit pas d'une application distincte à installer, mais d'une partie intégrante de l'interface de bureau, offrant un moyen fluide et efficace de prendre des captures d'écran et d'enregistrer de courtes vidéos (screencasts).

Ce guide explique comment utiliser à la fois l'interface utilisateur interactive et les puissants raccourcis clavier pour capturer le contenu de votre écran.

## Utilisation d'une IU de capture d'écran interactive

Le moyen le plus simple de commencer est d'utiliser la superposition interactive, qui vous donne un contrôle total sur ce que vous capturez et sur la manière dont vous le capturez.

1. **Lancer l'outil :** Appuyez sur la touche `Print Screen` (souvent étiquetée `PrtSc`) de votre clavier. L'écran va s'assombrir et l'interface de capture d'écran apparaîtra.

2. **Comprendre l'interface :** Le panneau de commande au centre de l'écran comporte trois sections principales :
   - **Mode de capture :** À gauche, vous pouvez choisir de capturer une `Région` rectangulaire, l’`Écran` entier ou une `Fenêtre` spécifique.
   - **Action Toggle :** Au centre, vous pouvez basculer entre la prise d'une **Screenshot** (icône d'appareil photo) ou l'enregistrement d'une \*\*Screencast \*\* (icône de caméra vidéo).
   - **Bouton de capture :** Le gros bouton rond situé à droite lance la capture.

### Capture d'écran

1. Assurez-vous que le bouton d'action est réglé sur **Capture d'écran** (l'icône de l'appareil photo).
2. Choisissez votre mode de capture :
   `Region`, `Screen` ou `Window`.
3. Cliquez sur le bouton rond **Capture**.

Par défaut, l'image de la capture d'écran est automatiquement enregistrée dans le répertoire `Images/Screenshots` de votre dossier personnel.

### Screencast, capture vidéo

1. Réglez le bouton d'action sur **Screencast** (l'icône de la caméra vidéo).
2. Sélectionnez la zone que vous souhaitez enregistrer (« Région » ou « Écran »).
3. Cliquez sur le bouton circulaire **Capture** pour commencer l'enregistrement.

Un point rouge apparaîtra dans le coin supérieur droit de votre écran, accompagné d'une minuterie, indiquant que l'enregistrement est en cours. Pour arrêter, cliquez sur le point rouge. The video will be automatically saved as a `.webm` file in the `Videos/Screencasts` directory in your home folder.

## Raccourcis clavier pour utilisateurs avancés

Pour des captures encore plus rapides, GNOME propose un ensemble de raccourcis clavier qui contournent l'interface utilisateur interactive.

| Raccourci              | Action                                                                                                |
| ---------------------- | ----------------------------------------------------------------------------------------------------- |
| ++print-screen++       | Ouvre l'interface utilisateur interactive de capture d'écran.                         |
| ++alt+print-screen++   | Prend une capture d'écran immédiate de la fenêtre présentement active.                |
| ++shift+print-screen++ | Commence immédiatement à sélectionner une zone rectangulaire pour la capture d'écran. |
| ++ctrl+alt+shift+"R"++ | Démarre et arrête un enregistrement en plein écran.                                   |

### Le modificateur "Copy to Clipboard"

Il s'agit d'une fonctionnalité de productivité efficace. En ajoutant la touche ++ctrl++ à n'importe quel raccourci de capture d'écran, l'image capturée sera copiée directement dans votre presse-papiers au lieu d'être sauvegardée dans un fichier. C'est idéal pour coller rapidement une capture d'écran dans une autre application, comme un document ou une fenêtre de clavardage.

- \++ctrl+print-screen++ : Ouvre l’interface utilisateur interactive, mais la capture sera placée dans le presse-papiers.
- \++ctrl+alt+print-screen++ : Copie une capture d’écran de la fenêtre active dans le presse-papiers.
- \++ctrl+shift+print-screen++ : Copie une capture d’écran de la zone sélectionnée dans le presse-papiers.

L'outil intégré de capture d'écran et d'enregistrement d'écran de GNOME est un parfait exemple de conception élégante et efficace, offrant à la fois une interface simple et intuitive pour les nouveaux utilisateurs et un flux de travail rapide et basé sur des raccourcis pour les utilisateurs avancés.
