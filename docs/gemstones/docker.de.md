---
title: Docker - Engine Installieren
author: Wale Soyinka
contributors:
date: 2021-08-04
tags:
  - docker
---

# Einleitung

Die Docker Engine kann verwendet werden mit nativen Docker-Container-Workloads auf Rocky Linux Servern. Dies wird manchmal dem Ausführen der kompletten Docker Desktop-Umgebung vorgezogen.

## Docker Repository hinzufügen

Benutzen Sie das `dnf` Tool, um das Docker Repository zu Ihrem Rocky Linux Server hinzuzufügen. Geben Sie bitte Folgendes ein:

```
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## Benötigte Pakete installieren

Installieren Sie die neueste Version von Docker Engine, containerd und Docker Compose:

```
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Starten Sie den Systemd-Docker-Dienst (dockerd) und aktivieren Sie ihn für den automatischen Start

Benutzen Sie das Tool `systemctl` um den Dockerd-Daemon so zu konfigurieren, dass er automatisch mit dem nächsten System-Neustart gestartet wird und gleichzeitig für die aktuelle Sitzung gestartet wird. Geben Sie bitte Folgendes ein:

```
sudo systemctl --now enable docker
```


### Anmerkungen

```
docker-ce : Dieses Paket stellt die zugrunde liegende Technologie für den Bau und den Betrieb von Docker-Containern (dockerd) zur Verfügung
docker-ce-cli: Stellt die Kommandozeilenschnittstelle (CLI) Client Docker (Docker) zur Verfügung
containerd.io : Stellt die Container-Laufzeit (runc) zur Verfügung
docker-compose-plugin: Ein Plugin, das den 'docker compose' Sub-Kommando zur Verfügung stellt 

```



