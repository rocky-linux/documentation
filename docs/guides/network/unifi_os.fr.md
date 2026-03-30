---
title: Contrôleur Ubiquiti UniFi OS
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 10.1
tags:
  - réseau
  - gestion de réseau
  - Ubiquiti
---

## Introduction

La gamme UniFi d'Ubiquiti, composée de points d'accès sans fil et d'autres équipements réseau, est populaire dans les petites entreprises et les laboratoires à domicile. Cela inclut le laboratoire personnel de l'auteur.

Conçu autour de Podman, le serveur UniFi OS est le logiciel de contrôleur UniFi de nouvelle génération.

Bien que conçu à l'origine pour Debian et Ubuntu, le serveur UniFi OS d'Ubiquiti peut également être installé sur Rocky Linux.

## Prérequis

- Un serveur ou une machine virtuelle disposant d'au moins 15 Go d'espace disque libre
- Au moins un appareil Ubiquiti UniFi sur votre réseau local
- Connaissances en administration réseau
- La possibilité d'élever les privilèges (`sudo`) pour certaines commandes

## Prérequis à l'installation du système

Installer les paquets prérequis :

```bash
sudo dnf install -y podman slirp4netns
```

## Téléchargement du serveur UniFi OS

Rendez-vous sur la [page de téléchargement d'Ubiquiti](https://ui.com/download) et copiez le lien vers `UniFi OS` pour l'architecture CPU que vous souhaitez.

Téléchargez le fichier :

```bash
wget <UNIFI_OS_SERVER_DOWNLOAD_LINK>
```

Le fichier de l'auteur est `1856-linux-x64-5.0.6-33f4990f-6c68-4e72-9d9c-477496c22450.6-x64`. Rendez-le exécutable :

```bash
chmod a+x 1856-linux-x64-5.0.6-33f4990f-6c68-4e72-9d9c-477496c22450.6-x64
```

## Installation du serveur UniFi OS

Lancez le fichier téléchargé précédemment :

```bash
./1856-linux-x64-5.0.6-33f4990f-6c68-4e72-9d9c-477496c22450.6-x64
```

Vous recevrez une sollicitation à installer. Entrez `y` :

```text
You are about to install UOS Server version 5.0.6. Proceed? (y/N): y
```

Une fois l'installation terminée, désactivez `firewalld` :

```bash
sudo systemctl disable --now firewalld
```

Vous verrez apparaître une ligne indiquant :

```text
UOS Server is running at: https://IP:11443/
```

Saisissez le lien dans un navigateur.

À partir de là, tout devrait aller de soi.

## Conclusion

Contrairement au précédent contrôleur réseau UniFi d'Ubiquiti, UniFi OS offre la possibilité de fonctionner sous Rocky Linux au lieu d'être limité aux distributions basées sur Debian. Cela le rend accessible aux environnements qui ont standardisé leur utilisation sur `Enterprise Linux` et qui ne souhaitent pas de passerelle UniFi. Par exemple, l'auteur utilise un routeur et commutateur MikroTik en complément de points d'accès UniFi pour une meilleure couverture Wi-Fi.
