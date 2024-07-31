---
title: Partage du Desktop (via `x11vnc`)
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## Introduction

x11vnc est un logiciel VNC qui se distingue par l'utilisation de la session X existante plutôt que d'en démarrer une nouvelle. Cette fonctionnalité en fait un excellent outil d'assistance délocalisée, car elle vous permet de contrôler à distance l'écran ou la session X d'un utilisateur.

Dans ce guide, vous apprenez à configurer un serveur `x11vnc` et à vous y connecter à distance.

!!! note

```
L’un des principaux avantages de l’utilisation de x11vnc basée sur SSH est qu’il élimine le besoin d’ouvrir des ports supplémentaires sur votre machine, minimisant ainsi la surface de vulnérabilité du système.
```

## Prérequis

Pour ce guide, nous partons du principe que vous disposez déjà de la configuration suivante :

- Poste de travail Rocky Linux
- Droits d'accès `sudo`

## Mise en place du serveur VNC

Pour capturer une session X, vous devrez installer le serveur `x11vnc` sur votre poste de travail Rocky.

### Désactivation de Wayland

Tout d’abord, il est nécessaire de désactiver Wayland. Ouvrez le fichier `custom.conf` à l'aide de l'éditeur de texte de votre choix :

```bash
sudo vim /etc/gdm/custom.conf
```

Décommentez `WaylandEnable=false` :

```bash
# GDM configuration storage

[daemon]
WaylandEnable=false

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
#Enable=true
```

Redémarrez le service `gdm` :

```bash
sudo systemctl restart gdm
```

## Installation et configuration de x11vnc

Activez le dépôt EPEL :

```bash
sudo dnf install epel-release
```

Créer un mot de passe pour x11vnc :

```bash
x11vnc -storepasswd ~/.x11vnc.pwd
```

Créez un nouveau fichier avec l’éditeur de texte de votre choix. Vous utiliserez ceci afin de créer un service pour exécuter x11vnc :

```bash
sudo vim /etc/systemd/system/x11vnc.service
```

Copiez et collez le texte suivant dans le fichier, puis enregistrez et fermez :

!!! note

```
Remplacez le chemin `rfbauth` par le chemin d'accès au fichier de mots de passe que vous avez créé précédemment. Remplacez les valeurs `User` et `Group` caractérisant l'utilisateur auquel vous souhaitez fournir une assistance à distance.
```

```bash
[Unit]
Description=Start x11vnc at startup
After=display-manager.service

[Service]
Type=simple
Environment=DISPLAY=:1
Environment=XAUTHORITY=/run/user/1000/gdm/Xauthority
ExecStart=/usr/bin/x11vnc -auth /var/lib/gdm/.Xauthority -forever -loop -noxdamage -repeat -rfbauth /home/server/.x11vnc.pwd -rfbport 5900 -shared
User=server
Group=server

[Install]
WantedBy=multi-user.target
```

Activez et démarrez le service x11vnc :

```bash
sudo systemctl enable --now x11vnc.service
```

## Connexion au serveur VNC depuis votre poste de travail Rocky

### Activez le dépôt EPEL :

```bash
sudo dnf install epel-release
```

### Installation d'un Client VNC

Installation de TigerVNC. Le serveur n'est pas utilisé, mais vous utiliserez le client :

```bash
sudo dnf install tigervnc
```

### Création du Tunnel SSH

![The ssh command in a terminal window](images/x11vnc_plus_ssh_lan_images/vnc_ssh_tunnel.webp)

Créez un tunnel SSH pour vous connecter au serveur VNC en toute sécurité :

```bash
ssh -L 5900:localhost:5900 REMOTEIP
```

### Lancement de la visualisation VNC

Ouvrez la visualisation VNC avec la commande suivante :

```bash
vncviewer
```

![TigerVNC viewer](images/x11vnc_plus_ssh_lan_images/vnc_viewer.webp)

Connectez-vous au serveur VNC en entrant 127.0.0.1 ou localhost dans TigerVNC et confirmez.

![TigerVNC viewer password prompt](images/x11vnc_plus_ssh_lan_images/vnc_viewer_password.webp)

Saisissez le mot de passe x11vnc que vous avez créé précédemment.

## Conclusion

![TigerVNC viewer connected to an X session](images/x11vnc_plus_ssh_lan_images/x11vnc_over_ssh_lan_conclusion.webp)

Vous avez configuré avec succès un serveur x11vnc et vous y êtes connecté à l'aide d'un client TigerVNC. Cette solution est idéale pour la maintenance à distance, car elle partage la même session X que l’utilisateur, garantissant une expérience d’assistance transparente.
