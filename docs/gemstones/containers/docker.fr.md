---
title: Docker Engine – Installation
author: Wale Soyinka
contributors: Neel Chauhan, Srinivas Nishant Viswanadha, Stein Arne Storslett, Ganna Zhyrnova, Steven Spencer
date: 2021-08-04
tags:
  - docker
---

# Introduction

Docker Engine peut être utilisé en exécutant des charges de travail de type Docker natives sur des serveurs Rocky Linux. C'est parfois préférable que d'utiliser l'environnement complet Docker Desktop.

## Ajouter le dépôt Docker

Utilisez l'utilitaire `dnf` pour ajouter le référentiel docker à votre serveur Rocky Linux. Pour ce faire tapez la commande :

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
```

## Installer les paquets nécessaires

Installez la dernière version de Docker Engine, `containerd` et Docker Compose en utilisant :

```bash
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Démarrez le service docker de systemd (`dockerd`) et activez-le pour le démarrage automatique

Utilisez l'utilitaire `systemctl` afin de configurer Docker pour démarrer automatiquement avec le prochain redémarrage du système et le démarrer simultanément pour la session courante. Pour ce faire utilisez la commande :

```bash
sudo systemctl --now enable docker
```

## Autoriser, si besoin est, un utilisateur non root à gérer Docker

Ajoutez un utilisateur non root au groupe `docker` pour permettre à l'utilisateur de gérer `docker` sans `sudo`.

Il s'agit d'une étape facultative mais elle peut être pratique si vous êtes l'utilisateur principal du système ou si vous souhaitez autoriser plusieurs utilisateurs à gérer Docker mais ne souhaitez pas leur accorder d'autorisations `sudo`.

Entrer la commande suivante :

```bash
# Add the current user
sudo usermod -a -G docker $(whoami)

# Add a specific user
sudo usermod -a -G docker custom-user
```

Pour être affecté au nouveau groupe, vous devez vous déconnecter et vous reconnecter. Vérifiez avec la commande `id` que le groupe a été ajouté.

### Remarques

```docker
docker-ce : ce paquet fournit la technologie sous-jacente pour construire et exécuter des docker containers (dockerd) 
docker-ce-cli : fournit l'interface de ligne de commande (CLI) client docker tool (docker)
containerd.io : fournit le runtime conteneur (runc)
docker-compose-plugin : un plugin qui fournit la sous-commande 'docker compose' 
```
