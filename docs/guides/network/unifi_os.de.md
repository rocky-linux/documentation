---
title: Ubiquiti UniFi OS Controller
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 10.1
tags:
  - Netzwerk
  - Netzwerk-Verwaltung
  - Ubiquiti
---

## Einleitung

Die UniFi-Produktlinie von Ubiquiti mit drahtlosen Zugangspunkten und anderer Netzwerkausrüstung ist in kleinen Unternehmen und Heim-Laborumgebungen beliebt. Dies schließt auch das Heimlabor des Autors ein.

Der UniFi OS Server, der auf Podman basiert, ist die nächste Generation der UniFi-Controller-Software.

Obwohl Ubiquitis UniFi OS Server technisch gesehen für Debian und Ubuntu konzipiert wurde, kann er auch auf Rocky Linux installiert werden.

## Voraussetzungen

- Ein Server oder eine virtuelle Maschine mit mindestens 15 GB freiem Speicherplatz
- Mindestens ein Ubiquiti UniFi-Gerät in Ihrem LAN
- Kenntnisse in der Netzwerkadministration
- Die Möglichkeit, die Berechtigungen für bestimmte Befehle zu erhöhen (`sudo`)

## Installation der vorausgesetzten Abhängigkeiten und Pakete

Installieren Sie die erforderlichen Pakete:

```bash
sudo dnf install -y podman slirp4netns
```

## UniFi OS-Server-Download

Gehen Sie zur [Ubiquiti Downloadseite](https://ui.com/download) und kopieren Sie den Link zum UniFi OS für die gewünschte CPU-Architektur.

Laden Sie die Datei herunter:

```bash
wget <UNIFI_OS_SERVER_DOWNLOAD_LINK>
```

Im Anwendungsfall des Autors hat er die Datei `1856-linux-x64-5.0.6-33f4990f-6c68-4e72-9d9c-477496c22450.6-x64` verwendet. Machen Sie die Datei ausführbar:

```bash
chmod a+x 1856-linux-x64-5.0.6-33f4990f-6c68-4e72-9d9c-477496c22450.6-x64
```

## UniFi OS Server - Installation

Führen Sie die heruntergeladene Datei aus:

```bash
./1856-linux-x64-5.0.6-33f4990f-6c68-4e72-9d9c-477496c22450.6-x64
```

Sie erhalten eine Aufforderung zur Installation. Wählen Sie `y`:

```text
You are about to install UOS Server version 5.0.6. Proceed? (y/N): y
```

Nach Abschluss der Installation deaktivieren Sie `firewalld`:

```bash
sudo systemctl disable --now firewalld
```

Sie erhalten folgende Ausgabe:

```text
UOS Server is running at: https://IP:11443/
```

Geben Sie den Link in einen Browser ein.

Von da an sollte es selbsterklärend sein.

## Zusammenfassung

Im Gegensatz zum vorherigen UniFi Network Controller von Ubiquiti bietet UniFi OS die Möglichkeit, auch auf Rocky Linux zu laufen, und nicht nur auf Debian-basierten Distributionen. Dadurch ist es auch für Umgebungen geeignet, die auf Enterprise Linux standardisiert sind und kein UniFi-Gateway benötigen. Der Autor verwendet beispielsweise einen MikroTik Core-Router und Switch zusammen mit UniFi Access Points, um eine bessere Wi-Fi-Abdeckung zu erzielen.
