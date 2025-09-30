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

!!! note "Remarque"

    Docker v28 n'a pas actuellement de dépôt RHEL 10, alors vous pouvez utiliser le référentiel CentOS.

Utilisez l’utilitaire `dnf` pour ajouter le référentiel `Docker` à votre serveur Rocky Linux. Pour ce faire tapez la commande suivante :

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## Installer les paquets nécessaires

Installez la dernière version de Docker Engine, `containerd` et Docker Compose en exécutant :

```bash
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Démarrer et activer Docker (`dockerd`)

Utilisez `systemctl` pour configurer Docker afin qu'il démarre automatiquement au redémarrage et le lancer simultanément maintenant. Pour ce faire tapez la commande suivante :

```bash
sudo systemctl --now enable docker
```

## Autoriser, si besoin est, un utilisateur non root à gérer Docker

Ajoutez un utilisateur non root au groupe `docker` pour permettre à l'utilisateur de gérer `docker` sans `sudo`.

Il s'agit d'une étape facultative mais elle peut être pratique si vous êtes l'utilisateur principal du système ou si vous souhaitez autoriser plusieurs utilisateurs à gérer Docker mais ne souhaitez pas leur accorder d'autorisations `sudo`.

Pour ce faire tapez la commande suivante :

```bash
# Add the current user
sudo usermod -a -G docker $(whoami)

# Add a specific user
sudo usermod -a -G docker custom-user
```

Pour être affecté au nouveau groupe, vous devez vous déconnecter et vous reconnecter. Vérifiez avec la commande `id` que le groupe a été ajouté.

### Remarques

```docker
docker-ce               : This package provides the underlying technology for building and running docker containers (dockerd) 
docker-ce-cli           : Provides the command line interface (CLI) client docker tool (docker)
containerd.io           : Provides the container runtime (runc)
docker-buildx-plugin    : Docker Buildx plugin for the Docker CLI
docker-compose-plugin   : A plugin that provides the 'docker compose' subcommand 
```
