---
title: Decoder — Outil de Code QR
author: Wale Soyinka
contributors: Ganna Zhyrnova
tags:
  - gnome
  - desktop
  - qr code
  - flatpak
---

## Scanner et générer des codes QR

**Decoder** est un utilitaire simple et élégant pour l'environnement de bureau GNOME, conçu dans un précis : la manipulation des codes QR. Dans un monde où les codes QR sont utilisés pour tout, du partage de mots de passe Wi-Fi à l'accès aux menus des restaurants, disposer d'un outil dédié pour les gérer est essentiel.

Decoder offre deux fonctions principales dans une interface claire et ciblée :

1. **Numérisation :** Décode les codes QR à l’aide de la caméra Web de votre ordinateur ou d’un fichier image.
2. **Génération :** Crée des codes QR à partir de n'importe quel texte que vous fournissez.

Son intégration étroite avec l'environnement de bureau GNOME lui donne l'impression d'être une partie intégrante du système d'exploitation.

## Installation

La méthode recommandée pour installer `Decoder` sur Rocky Linux est via `Flatpak` depuis le dépôt `Flathub`. Cette méthode vous garantit d'avoir la dernière version de l'application dans un environnement sécurisé et isolé.

### 1. Activer Flathub

Si vous ne l'avez pas déjà fait, veuillez vous assurer que Flatpak est installé et que la télécommande Flathub est configurée sur votre système.

```bash
# Install the Flatpak package
sudo dnf install flatpak

# Add the Flathub remote repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

### 2. Installation de Decoder

Une fois Flathub activé, vous pouvez installer Decoder avec une seule commande :

```bash
flatpak install flathub com.belmoussaoui.Decoder
```

## Utilisation de Decoder

Après l'installation, vous pouvez lancer Decoder à partir de la vue d'ensemble des activités GNOME.

### Scanner un code QR

Lorsque vous ouvrez Decoder pour la première fois, il est prêt à scanner. Vous avez deux options :

- **Scanner avec la caméra :** Cliquez sur l'icône de l'appareil photo en haut à gauche. Une fenêtre s'ouvrira, affichant le flux vidéo de votre webcam. Pointez la caméra Web vers un code QR pour le numériser en temps réel.
- **Scanner à partir d'une image :** Cliquez sur l'icône d'image dans le coin supérieur droit. Cela ouvrira une fenêtre de sélection de fichiers, vous permettant de sélectionner une image enregistrée ou une capture d'écran contenant un code QR.

Une fois le code numérisé, Decoder analyse son contenu. Si le code contient une URL de site Web, il affichera le lien avec un bouton permettant de l'ouvrir dans votre navigateur Web par défaut. S'il contient du texte brut, il affichera ce texte avec un bouton adéquat pour le copier dans votre presse-papiers.

### Génération de code QR

Pour créer votre propre code QR, cliquez sur le bouton `Generate` en haut de la fenêtre de Decoder\`.

1. Une zone de texte apparaîtra. Entrez ou collez le texte que vous voulez encoder dans cette zone.
2. Au fur et à mesure que vous tapez, un code QR représentant votre texte est instantanément généré à droite.
3. Vous pouvez ensuite cliquer sur le bouton **"Enregistrer comme image..."** pour enregistrer le code QR au format `.png`, ou cliquer sur le bouton **"Copier dans le presse-papiers"** pour le coller dans d'autres applications.

Decoder est un parfait exemple de la philosophie de conception de GNOME : un outil simple, esthétique et très efficace qui remplit une fonction de manière exceptionnelle.
