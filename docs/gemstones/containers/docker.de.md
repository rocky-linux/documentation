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

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## Benötigte Pakete installieren

Installieren Sie die neueste Version der Docker Engine, `containerd` und Docker Compose:

```bash
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Starten Sie den Systemd-Docker-Dienst (`dockerd`) und aktivieren Sie ihn für den automatischen Start

Benutzen Sie das Tool `systemctl` um den Dockerd-Daemon so zu konfigurieren, dass er automatisch mit dem nächsten System-Neustart gestartet wird und gleichzeitig für die aktuelle Sitzung gestartet wird. Geben Sie bitte Folgendes ein:

```bash
sudo systemctl --now enable docker
```

## Optional: Nicht-root Benutzern erlauben Docker zu verwalten

Fügen Sie einen Benutzer zur Gruppe `docker` hinzu, um diesen die Verwaltung von Docker ohne die Verwendung von `sudo` zu ermöglichen.

> [!NOTE]
> Dieser Schritt ist optional. Es kann nütlich sein, wenn Sie der Hauptverwender des Systems sind, oder anderen Benutzern die Verwaltung von Docker ermöglichen wollen, ohne diesen `sudo`-Berechtigungen einzuräumen.

Geben Sie ein:

```bash
# Aktuellen Benutzer hinzufügen
sudo usermod -a -G docker $(whoami)

# Einen Benutzer explizit hinzufügen
sudo usermod -a -G docker custom-user
```

Um der neuen Gruppe zugewiesen zu sein, müssen Sie sich aus- und einloggen. Prüfen Sie mit `id`, dass Sie dieser Gruppe hinzugefügt wurden.

### Anmerkungen

```docker
docker-ce            : Dieses Paket stellt die zugrunde liegende Technologie für den Bau und den Betrieb von Docker-Containern (dockerd) zur Verfügung
docker-ce-cli        : Stellt die Kommandozeilenschnittstelle (CLI) Client Docker (Docker) zur Verfügung
containerd.i         : Stellt die Container-Laufzeit (runc) zur Verfügung
docker-compose-plugin: Ein Plugin, das den 'docker compose' Sub-Kommando zur Verfügung stellt 

```
