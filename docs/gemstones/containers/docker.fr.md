---
title: Docker Engine
author: Wale Soyinka
contributors:
date: 2021-08-04
tags:
  - docker
---

# Introduction

Le Docker Engine peut être utilisé en exécutant des charges de travail de type Docker natives sur des serveurs Rocky Linux. C'est parfois préférable que d'utiliser l'environnement complet Docker Desktop.

## Ajouter le dépôt Docker

Utilisez l'utilitaire `dnf` pour ajouter le référentiel docker à votre serveur Rocky Linux. Pour ce faire tapez la commande :

```
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## Installer les paquets nécessaires

Installez la dernière version de Docker Engine, `containerd` et Docker Compose en utilisant :

```
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Démarrez le service docker de systemd (`dockerd`) et activez-le pour le démarrage automatique

Utilisez l'utilitaire `systemctl` afin de configurer Docker pour démarrer automatiquement avec le prochain redémarrage du système et le démarrer simultanément pour la session courante. Pour ce faire utilisez la commande :

```
sudo systemctl --now enable docker
```

### Notes

```
docker-ce : ce paquet fournit la technologie sous-jacente pour construire et exécuter des docker containers (dockerd) 
docker-ce-cli : fournit l'interface de ligne de commande (CLI) client docker tool (docker)
containerd.io : fournit le runtime conteneur (runc)
docker-compose-plugin : un plugin qui fournit la sous-commande 'docker compose' 
```
