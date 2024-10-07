---
title: Docker - Engine Installieren
author: Wale Soyinka
contributors: Neel Chauhan, Srinivas Nishant Viswanadha, Stein Arne Storslett, Ganna Zhyrnova, Steven Spencer
date: 2021-08-04
tags:
  - docker
---

# Einleitung

Die Docker-Engine kann zum Ausführen nativer Container-Workloads im Docker-Stil auf Rocky Linux-Servern verwendet werden. Dies wird manchmal dem Ausführen der kompletten Docker Desktop-Umgebung vorgezogen.

## Docker Repository hinzufügen

Benutzen Sie das `dnf`-Tool, um das Docker Repository zu Ihrem Rocky Linux Server hinzuzufügen. Geben Sie bitte Folgendes ein:

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
```

## Benötigte Pakete installieren

Installieren der neuesten Version von Docker Engine, `containerd` und Docker Compose:

```bash
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Starten und aktivieren vom Systemd-Docker-Dienst (`dockerd`)

Benutzen Sie das Tool `systemctl` um den Dockerd-Daemon so zu konfigurieren, dass er automatisch mit dem nächsten System-Neustart ausgeführt wird und gleichzeitig für die aktuelle Sitzung gestartet wird. Geben Sie bitte Folgendes ein:

```bash
sudo systemctl --now enable docker
```

## Erlauben Sie optional einem Nicht-Root-Benutzer, Docker zu verwalten

Fügen Sie der Gruppe `docker` einen Nicht-Root-Benutzer hinzu, um dem Benutzer die Verwaltung von `docker` ohne `sudo` zu ermöglichen.

Dies ist ein optionaler Schritt, er kann jedoch praktisch sein, wenn Sie der Hauptbenutzer des Systems sind oder wenn Sie mehreren Benutzern die Verwaltung von Docker gestatten möchten, ihnen jedoch keine `sudo`-Berechtigungen erteilen möchten.

Geben Sie bitte Folgendes ein:

```bash
# Add the current user
sudo usermod -a -G docker $(whoami)

# Add a specific user
sudo usermod -a -G docker custom-user
```

Um der neuen Gruppe zugewiesen zu werden, müssen Sie sich ab- und erneut anmelden. Überprüfen Sie mit dem Befehl `id`, ob die Gruppe hinzugefügt wurde.

### Anmerkungen

```docker
docker-ce : Dieses Paket stellt die zugrunde liegende Technologie für den Bau und den Betrieb von Docker-Containern (dockerd) zur Verfügung
docker-ce-cli: Stellt die Kommandozeilenschnittstelle (CLI) Client Docker (Docker) zur Verfügung
containerd.io : Stellt die Container-Laufzeit (runc) zur Verfügung
docker-compose-plugin: Ein Plugin, das den `docker compose' Sub-Kommando zur Verfügung stellt 
```
