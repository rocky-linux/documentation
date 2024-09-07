---
title: File Shredder
author: Christine Belzie
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

Besoin de supprimer une carte postale ou un fichier PDF contenant des informations telles que votre date de naissance ? Découvrez `File Shredder`, une application qui supprime définitivement les informations sensibles en ligne.

## Prérequis

Ce guide suppose que vous disposez de la configuration suivante :

- Rocky Linux
- Flatpak
- FlatHub

## Processus d'Installation

![Screenshot of the File Shredder app page on FlatHub, showing the blue install button being highlighted by a red rectangle](images/01_file-shredder.png)

1. Accédez au [site Web Flathub](https://flathub.org/), tapez `File Shredder` dans la barre de recherche et cliquez sur **Install**

   ![manual install script and run script](images/file-shredder_install.png)

2. Copiez le script d'installation manuelle dans un terminal :

   ```bash
   flatpak install flathub io.github.ADBeveridge.Raider
   ```

3. Enfin, exécutez le script d'installation manuelle dans votre terminal :

   ```bash
   flatpak run flathub io.github.ADBeveridge.Raider
   ```

## Mode d'emploi

Pour utiliser le programme `File Shredder`, procédez comme suit :

1. Faites glisser ou cliquez sur **Add File** pour sélectionner le(s) fichier(s) que vous souhaitez supprimer

   ![Screenshot of the File Shredder homepage, showing the add drop-down menu and drop here button being highlighted by red rectangles](images/02_file-shredder.png)

2. Cliquez sur **Shred All**

![Screenshot of a file named Social Security appearing on top. At the bottom, there is a red button with the phrase Shred All written in white font and surrounded by a red rectangle](images/03_file-shredder.png)

## Conclusion

Qu’il s’agisse d’un dossier de sécurité sociale ou d’un relevé bancaire, File Shredder est l’outil qui permet de supprimer définitivement des fichiers sans avoir à acheter un shredder. Vous souhaitez en savoir plus ou avoir plus d'idées pour cette application ? [Soumettez un issue dans le dépôt de File Shredder sur GitHub](https://github.com/ADBeveridge/raider/issues).
