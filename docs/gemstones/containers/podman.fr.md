---
title: Podman
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova, Christian Steinert
date: 2024-03-07
tags:
  - docker
  - podman
---

# Introduction

[Podman](https://podman.io/) est un environnement d'exécution de conteneur alternatif compatible Docker qui, contrairement à Docker, est inclus dans les référentiels de Rocky Linux et peut exécuter des conteneurs en tant que service `systemd`.

## Installation de Podman

Utilisez l'utilitaire `dnf` pour installer Podman :

```bash
dnf install podman
```

## Ajout de Conteneur

Prenons l'exemple d'une plateforme cloud auto-hébergée [Nextcloud](https://nextcloud.com/) :

```bash
podman run -d -p 8080:80 nextcloud
```

Vous recevrez une invite pour sélectionner le registre de conteneurs à partir duquel télécharger. Dans notre exemple, nous utiliserons `docker.io/library/nextcloud:latest`.

Une fois que vous aurez téléchargé le conteneur Nextcloud, il s'exécutera.

Saisissez **ip_address:8080** dans votre navigateur Web (en supposant que vous ayez ouvert le port dans `firewalld`) et configurez Nextcloud :

![Nextcloud in container](../images/podman_nextcloud.png)

## Execution de conteneurs en tant que services `systemd`

### Utilisation de `quadlet`

Depuis la version 4.4, Podman est livré avec [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html), un générateur systemd qui peut générer des fichiers `unit` pour les services systemd rootless et rootful.

Les fichiers Quadlet pour les services `rootful` peuvent être placés dans

- `/etc/containers/systemd/`
- `/usr/share/containers/systemd/`

tandis que les fichiers `rootless` peuvent être placés dans l'un d'eux

- `$XDG_CONFIG_HOME/containers/systemd/` ou bien `~/.config/containers/systemd/`
- `/etc/containers/systemd/users/$(UID)`
- `/etc/containers/systemd/users/`

Bien que les conteneurs uniques, les pods, les images, les réseaux, les volumes et les fichiers Kube soient pris en charge, concentrons-nous sur notre exemple Nextcloud. Créez un nouveau fichier `~/.config/containers/systemd/nextcloud.container` avec le contenu suivant :

```systemd
[Container]
Image=nextcloud
PublishPort=8080:80
```

De nombreuses autres [options](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#container-units-container) sont disponibles.

Pour exécuter le générateur et informer systemd qu'il existe un nouveau service, exécutez la commande suivante :

```bash
systemctl --user daemon-reload
```

Pour activer votre service lancez la commande suivante :

```bash
systemctl --user start nextcloud.service
```

!!! note "Remarque"

```
Si vous avez créé un fichier dans l'un des répertoires des services root, omettez l'indicateur `--user`.
```

Pour exécuter automatiquement le conteneur au démarrage du système ou à la connexion de l'utilisateur, vous pouvez ajouter une autre section à votre fichier `nextcloud.container` :

```systemd
[Install]
WantedBy=default.target
```

Étant donné que les fichiers de service générés sont considérés comme transitoires, ils ne peuvent pas être activés par systemd. Pour atténuer ce problème, le générateur applique manuellement les installations pendant la génération. Cela active également efficacement ces fichiers de services.

D'autres types de fichiers sont pris en charge : `pod`, `volume`, `network`, `image° et `kube\`. Les [Pods](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#pod-units-pod), par exemple, peuvent être utilisés pour regrouper des conteneurs – les services systemd générés et leurs dépendances (créer le pod avant les conteneurs) sont automatiquement gérés par systemd.

### Utilisation de `podman generate systemd`

Podman fournit également la sous-commande `generate systemd`. Il peut être utilisé pour générer des fichiers de service `systemd`.

!!! warning "Avertissement"

```
`generate systemd` est désormais obsolète et ne recevra plus de fonctionnalités supplémentaires. L'utilisation de Quadlet est recommandée.
```

Faisons-le désormais avec Nextcloud. Exécuter :

```bash
podman ps
```

Vous obtiendrez une liste des conteneurs en cours d’exécution :

```bash
04f7553f431a  docker.io/library/nextcloud:latest  apache2-foregroun...  5 minutes ago  Up 5 minutes  0.0.0.0:8080->80/tcp  compassionate_meninsky
```

Comme vu ci-dessus, le nom du conteneur est `compassionate_meninsky`.

Pour créer un service `systemd` pour le conteneur Nextcloud et l'activer au redémarrage, exécutez la commande suivante :

```bash
podman generate systemd --name compassionate_meninsky > /usr/lib/systemd/system/nextcloud.service
systemctl enable nextcloud
```

Remplacez `compassionate_meninsky` par le nom attribué à votre conteneur.

Lorsque votre système sera relancé, Nextcloud redémarrera dans Podman.
