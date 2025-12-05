---
title: Graver sur CD/DVD avec Xorriso
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

L'auteur a constaté récemment que la gravure d'images ISO hybrides sur un CD/DVD physique sous Rocky Linux à l'aide d'outils graphiques représente un réel défi. Heureusement, Xorriso propose une application CLI facile à utiliser qui gère parfaitement cette tâche !

## Description du problème

Graver une image ISO sur un CD/DVD matériel.

## Prérequis

- Connexion Internet
- Maîtrise de la ligne de commande
- Lecteur CD/DVD RW

## Procédure

**Installation de Xorriso** :

   ```bash
   sudo dnf install xorriso -y
   ```

**Écriture de l'ISO sur le disque** :

   ```bash
   sudo xorriso -as cdrecord -v dev=/dev/sr0 -blank=as_needed -dao Rocky-10.1-x86_64-boot.iso -eject
   ```

## Informations supplémentaires

Xorriso s'appuie sur une bibliothèque C `libisofs`. Pour en savoir plus sur `libisofs` veuillez consulter [le gestionnaire de paquets de Fedora](https://packages.fedoraproject.org/pkgs/libisofs/libisofs/index.html).

## Conclusion

Dans cet article, vous avez appris comment écrire une image ISO sur un disque physique avec Xorriso ! Il est à noter que Xorriso peut être utilisé pour écrire d'autres types de fichiers sur des disques physiques, mais l'auteur l'a trouvé particulièrement pratique pour le format ISO hybride que les outils graphiques ne savent pas gérer.<small>
<br/><br/>
🌐 Traductions : 
<a href="https://crowdin.com/project/rockydocs/fr">crowdin.com/project/rockydocs</a>
<br/>
🌍 Traducteurs :
<a href="https://crowdin.com/project/rockydocs/activity-stream">rockydocs/activity-stream</a>
, <a href="https://crowdin.com/project/rockylinuxorg/activity-stream">rockylinux.org</a>
<br/>
🖋 Participer:
<a href="https://github.com/rocky-linux/documentation?tab=readme-ov-file#mattermost">github.com/rocky-linux</a>
</small>
