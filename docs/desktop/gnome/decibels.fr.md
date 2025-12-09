---
title: Decibels — Audio Player
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - audio
  - flatpak
---

## Introduction

**Decibels** est un lecteur audio moderne et élégant pour l'environnement de bureau GNOME. Il repose sur une philosophie de simplicité, conçue pour exceller dans un seul domaine : la lecture de fichiers audio.

Contrairement aux applications de bibliothèque musicale complètes comme Rhythmbox, Decibels ne gère pas de collection musicale. Au lieu de cela, il se concentre sur la fourniture d'une expérience claire et simple pour la lecture de fichiers audio individuels. Sa caractéristique principale est un affichage de la forme d'onde qui permet une navigation facile et précise dans la piste audio.

Cela en fait l'outil idéal pour écouter rapidement un balado téléchargé, un mémo vocal ou une nouvelle chanson sans avoir à importer les fichiers dans une bibliothèque.

## Installation

La méthode recommandée pour installer Decibels sur Rocky Linux est via Flatpak depuis le dépôt Flathub. Cette méthode vous garantit d'avoir la dernière version de l'application, isolée du reste de votre système.

### 1. Activer Flathub

Assurez-vous d'abord que Flatpak est installé et que la télécommande Flathub est configurée sur votre système.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

!!! note
Vous devrez peut-être vous déconnecter puis vous reconnecter pour que les applications Flatpak apparaissent dans l'aperçu des activités GNOME.

### 2. Installation de Decibels

Une fois Flathub activé, vous pouvez installer Decibels avec une seule commande :

```bash
flatpak install flathub org.gnome.Decibels
```

## Utilisation de base

Après l'installation, vous pouvez lancer Decibels à partir de la vue d'ensemble des activités GNOME en recherchant `Decibels`.

Pour lire un fichier :

1. Lancez l'application. Une fenêtre propre et simple vous accueillera.
2. Cliquez sur le bouton bien visible **"Open a file..."** au centre de la fenêtre.
3. Utilisez le sélecteur de fichiers pour naviguer et sélectionner un fichier audio sur votre système (par exemple, un fichier `.mp3`, `.flac`, `.ogg` ou `.wav`).
4. Le fichier va s'ouvrir et sa forme d'onde s'affichera. La lecture démarrera automatiquement.

## Caractéristiques principales

Bien que simple, Decibels possède plusieurs fonctionnalités intéressantes :

- **Navigation par forme d'onde :** Plutôt qu'une simple barre de progression, Decibels affiche la forme d'onde audio. Vous pouvez cliquer n'importe où sur la forme d'onde pour accéder instantanément à cette partie du morceau.
- **Contrôle de la vitesse de lecture :** Une commande située dans le coin inférieur droit vous permet de régler la vitesse de lecture, ce qui est idéal pour accélérer les baladodiffusions ou ralentir l’audio pour la transcription.
- **Boutons de saut rapide :** Des boutons dédiés vous permettent de revenir en arrière ou d'avancer par intervalles de 10 secondes, ce qui facilite la réécoute d'une phrase manquée.

Decibels est un excellent choix pour tous ceux qui ont besoin d'une application simple, élégante et moderne pour lire des fichiers audio individuels sur le bureau GNOME.
