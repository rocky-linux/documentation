---
title: À la docker
author: Wale Soyinka
contributors: Steve Spencer, Ganna Zhyrnova
update: 2022-02-27
---

# Ausführen einer lokalen Kopie der Website docs.rockylinux.org für Webentwickler und/oder Inhaltsautoren

In diesem Dokument wird erläutert, wie Sie eine lokale Kopie der gesamten Website docs.rockylinux.org auf Ihrem lokalen Computer neu erstellen und ausführen. **It is a work-in-progress.**

Das Ausführen einer lokalen Kopie der Dokumentationswebsite kann in den folgenden Szenarios hilfreich sein:

* Sie möchten mehr über die Webentwicklungsaspekte der Website docs.rockylinux.org erfahren und dazu beitragen
* Sie sind Autor und möchten sehen, wie Ihre Dokumente auf der Website gerendert/angezeigt werden, bevor Sie Ihren Beitrag veröffentlichen
* Sie sind ein Webentwickler, der einen Beitrag zur Website docs.rockylinux.org leisten oder bei der Pflege helfen möchte


### Einige Hinweise:

* Die Anweisungen in diesem Handbuch sind für Autoren/Mitwirkende der Rocky-Dokumentation **NICHT** verpflichtend
* Die gesamte Umgebung wird in einem Docker-Container ausgeführt, daher benötigen Sie eine Docker-Engine auf Ihrem lokalen Computer
* Der Container wird aus dem offiziellen Docker-Image von RockyLinux erstellt, das hier verfügbar ist: https://hub.docker.com/r/rockylinux/rockylinux
* Der Container speichert Dokumentationsinhalte (Handbücher, Bücher, Bilder usw.) getrennt von der Web-Engine (mkdocs)
* Der Container führt einen lokalen Webserver aus, der Port 8000 bedient.  Und Port 8000 wird an den Docker-Host weitergeleitet


## Eine Content-Umgebung erstellen

1. Ändern Sie das aktuelle Arbeitsverzeichnis auf Ihrem lokalen System in den Ordner, in den Sie schreiben möchten. Wir bezeichnen dieses Verzeichnis als `$ROCKYDOCS` im restlichen Teil dieses Handbuchs.  Für unsere Demo hier zeigt `$ROCKYDOCS` auf `~/projects/rockydocs` in unserem Demosystem.

Erstellen Sie $ROCKYDOCS, falls es noch nicht existiert, und geben Sie dann Folgendes ein:

```
cd  $ROCKYDOCS
```

2. Stellen Sie sicher, daß `git` installiert ist (`dnf -y install git`).  Verwenden Sie in $ROCKYDOCS Git, um das offizielle Inhalts-Repository von Rocky Documentation zu klonen. Geben Sie bitte Folgendes ein:

```
git clone https://github.com/rocky-linux/documentation.git
```

Sie haben jetzt einen Ordner `$ROCKYDOCS/documentation`. Dieser Ordner ist ein Git-Repository und wird von Git kontrolliert.


## Create and Start the RockyDocs web development environment

3.  Stellen Sie sicher, dass Docker auf Ihrem lokalen Computer ausgeführt wird (dies kann mit `systemctl` überprüft werden).

4. Geben Sie im Terminal Folgendes ein:

```
docker pull wsoyinka/rockydocs:latest
```

5. Stellen Sie sicher, dass das Image erfolgreich hochgeladen wurde. Geben Sie bitte Folgendes ein:

```
docker image  ls
```

## RockyDocs Container starten

1. Führen Sie den Container vom Rockydocs-Image aus. Geben Sie bitte Folgendes ein:

```
docker run -it --name rockydoc --rm \
     -p 8000:8000  \
     --mount type=bind,source="$(pwd)"/documentation,target=/documentation  \
     wsoyinka/rockydocs:latest

```


Wenn Sie möchten und `docker-compose` installiert haben, können Sie alternativ eine Compose-Datei namens `docker-compose.yml` mit folgendem Inhalt erstellen:

```
version: "3.9"
services:
  rockydocs:
    image: wsoyinka/rockydocs:latest
    volumes:
      - type: bind
        source: ./documentation
        target: /documentation
    container_name: rocky
    ports:
       - "8000:8000"

```

Speichern Sie die Datei mit dem Namen `docker-compose.yml` im Arbeitsverzeichnis $ROCKYDOCS.  Und starten Sie den Dienst/Container, indem Sie Folgendes ausführen:

```
docker-compose  up
```


## Die lokale Kopie von docs.rockylinux.org anzeigen

Wenn der Container ausgeführt wird, können Sie Ihren Webbrowser auf die folgende URL verweisen, um die lokale Kopie der Site anzuzeigen:

http://localhost:8000
