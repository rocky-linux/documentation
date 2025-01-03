---
title: Podman
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova, Christian Steinert
date: 2024-03-07
tags:
  - docker
  - podman
---

# Einleitung

[Podman](https://podman.io/) ist eine Docker-kompatible alternative Container-Laufzeitumgebung, die im Gegensatz zu Docker in den Rocky Linux-Repositorys enthalten ist und Container als `systemd`-Dienst ausführen kann.

## Podman Installieren

Das Dienstprogramm `dnf` verwenden, um Podman zu installieren:

```bash
dnf install podman
```

## Container hinzufügen

Lassen Sie uns als Beispiel eine selbst gehostete Cloud-Plattform von [Nextcloud](https://nextcloud.com/) betreiben:

```bash
podman run -d -p 8080:80 nextcloud
```

Sie werden aufgefordert, die Container-Registry auszuwählen, von der heruntergeladen werden soll. In unserem Beispiel verwenden wir `docker.io/library/nextcloud:latest`.

Nachdem Sie den Nextcloud-Container heruntergeladen haben, wird dieser ausgeführt.

Geben Sie **ip_address:8080** in Ihren Webbrowser ein (vorausgesetzt, Sie haben den Port in `firewalld` geöffnet) und richten Sie Nextcloud ein:

![Nextcloud in container](../images/podman_nextcloud.png)

## Ausführen von Containern als `systemd`-Dienste

### `quadlet`-Verwendung

Seit 4.4 wird Podman mit [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) ausgeliefert, einem Systemd-Generator, der Unit-Dateien für Rootless- und Rootful-Systemd-Dienste generieren kann.

Quadlet-Dateien für Root-Dienste können in folgende Verzeichnisse abgelegt werden

- `/etc/containers/systemd/`
- `/usr/share/containers/systemd/`

während rootless Dateien in einem der folgenden Verzeichnisse abgelegt werden können

- `$XDG_CONFIG_HOME/containers/systemd/` oder `~/.config/containers/systemd/`
- `/etc/containers/systemd/users/$(UID)`
- `/etc/containers/systemd/users/`

Obwohl einzelne Container, Pods, Images, Netzwerke, Volumes und Kube-Dateien unterstützt werden, konzentrieren wir uns auf unser Nextcloud-Beispiel. Erstellen Sie eine neue Datei `~/.config/containers/systemd/nextcloud.cotainer` mit folgendem Inhalt:

```systemd
[Container]
Image=nextcloud
PublishPort=8080:80
```

Viele [andere Optionen](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#container-units-container) sind auch verfügbar.

So führen Sie den Generator aus und teilen systemd mit, dass ein neuer Dienst vorhanden ist:

```bash
systemctl --user daemon-reload
```

So starten Sie Ihren Dienst:

```bash
systemctl --user start nextcloud.service
```

!!! note "Anmerkung"

```
Wenn Sie eine Datei in einem der Verzeichnisse für Root-Dienste erstellt haben, lassen Sie das Flag `--user` weg.
```

Um den Container beim Systemstart oder bei der Benutzeranmeldung automatisch auszuführen, können Sie Ihrer Datei `nextcloud.container` einen weiteren Abschnitt hinzufügen:

```systemd
[Install]
WantedBy=default.target
```

Da die generierten Servicedateien als vorübergehend gelten, können sie von systemd nicht aktiviert werden. Um dies zu umgehen, wendet der Generator Installationen während der Generierung manuell an. Dadurch werden auch diese Servicedateien effektiv aktiviert.

Andere Dateitypen werden unterstützt: Pod, Volume, Network, Image und Kube. [Pods](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#pod-units-pod) können beispielsweise zum Gruppieren von Containern verwendet werden – die generierten systemd-Dienste und ihre Abhängigkeiten (erstellen vom Pod vor den Containern) werden automatisch von `systemd` verwaltet.

### Verwendung von `podman generate systemd`

Podman bietet zusätzlich den Unterbefehl `generate systemd`. Es kann zum Generieren von `systemd`-Servicedateien verwendet werden.

!!! warning "Warnhinweis"

```
`generate systemd` ist jetzt obsolet und wird keine weiteren Features bekommen. Die Verwendung von `Quadlet` wird empfohlen.
```

Sie werden es jetzt mit Nextcloud machen. Folgendes Kommando ausführen:

```bash
podman ps
```

Sie erhalten eine Liste der laufenden Container:

```bash
04f7553f431a  docker.io/library/nextcloud:latest  apache2-foregroun...  5 minutes ago  Up 5 minutes  0.0.0.0:8080->80/tcp  compassionate_meninsky
```

Wie oben zu sehen ist, heißt unser Container `compassionate_meninsky`.

Führen Sie Folgendes aus, um einen `systemd`-Dienst für den Nextcloud-Container zu erstellen und ihn beim Neustart zu aktivieren:

```bash
podman generate systemd --name compassionate_meninsky > /usr/lib/systemd/system/nextcloud.service
systemctl enable nextcloud
```

Ersetzen Sie den Platzhalter „compassionate_meninsky“ durch den Ihrem Container zugewiesenen Namen.

Beim Neustart Ihres Systems wird Nextcloud innerhalb Podman neu gestartet.
