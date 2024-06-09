---
title: Podman
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
date: 2024-03-07
tags:
  - docker
  - podman
---

# Einleitung

[Podman](https://podman.io/) ist eine Docker-kompatible alternative Container-Laufzeitumgebung, die im Gegensatz zu Docker in den Rocky Linux-Repositorys enthalten ist und Container als „systemd“-Dienst ausführen kann.

## Podman Installieren

Das Dienstprogramm „dnf“ verwenden, um Podman zu installieren:

```bash
dnf install podman
```

## Container hinzufügen

Lassen Sie uns als Beispiel eine selbst gehostete Cloud-Plattform von [Nextcloud](https://nextcloud.com/) betreiben:

```bash
podman run -d -p 8080:80 nextcloud
```

Sie werden aufgefordert, die Container-Registrierung auszuwählen, von der heruntergeladen werden soll. In unserem Beispiel verwenden wir „docker.io/library/nextcloud:latest“.

Nachdem Sie den Nextcloud-Container heruntergeladen haben, wird dieser ausgeführt.

Geben Sie **ip_address:8080** in Ihren Webbrowser ein (vorausgesetzt, Sie haben den Port in „firewalld“ geöffnet) und richten Sie Nextcloud ein:

![Nextcloud in container](../images/podman_nextcloud.png)

## Ausführen von Containern als „systemd“-Dienste

Wie bereits erwähnt, können Sie Podman-Container als „systemd“-Dienste ausführen. Lassen Sie es uns jetzt mit Nextcloud machen. Folgendes Kommando ausführen:

```bash
podman ps
```

Lassen Sie es uns jetzt mit Nextcloud machen:

```bash
04f7553f431a  docker.io/library/nextcloud:latest  apache2-foregroun...  5 minutes ago  Up 5 minutes  0.0.0.0:8080->80/tcp  compassionate_meninsky
```

Wie oben zu sehen ist, heißt unser Container `compassionate_meninsky`.

Um einen „systemd“-Dienst für den Nextcloud-Container zu erstellen und ihn beim Neustart zu aktivieren, führen Sie Folgendes aus:

```bash
podman generate systemd --name compassionate_meninsky > /usr/lib/systemd/system/nextcloud.service
systemctl enable nextcloud
```

Ersetzen Sie „compassionate_meninsky“ durch den Ihrem Container zugewiesenen Namen.

Beim Neustart Ihres Systems wird Nextcloud in Podman neu gestartet.
