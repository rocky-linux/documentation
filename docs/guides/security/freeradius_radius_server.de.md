---
title: FreeRADIUS RADIUS Server
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - Sicherheit
---

# FreeRADIUS 802.1X Server

## Einleitung

RADIUS ist ein AAA-Protokoll (authentication, authorization, accounting) zur Verwaltung des Netzwerkzugriffs. [FreeRADIUS](https://www.freeradius.org/) ist der De-facto-RADIUS-Server für Linux und andere Unix-ähnliche Systeme.

## Voraussetzungen

Für dieses Verfahren sind folgende Mindestanforderungen zu beachten:

- Die Möglichkeit, Befehle als Root-Benutzer auszuführen oder `sudo` zu verwenden, um Berechtigungen zu erhöhen
- Ein RADIUS-Client, beispielsweise ein Router, Switch oder WLAN-Zugangspunkt

## FreeRADIUS-Installation

Sie können FreeRADIUS aus den `dnf`-Repositories installieren:

```bash
dnf install -y freeradius
```

## FreeRADIUS-Konfiguration

Wenn die Pakete installiert sind, müssen Sie zuerst die TLS-Verschlüsselungszertifikate für FreeRADIUS generieren:

```bash
cd /etc/raddb/certs
./bootstrap
```

Anschließend müssen Sie zur Authentifizierung Benutzer hinzufügen. Öffnen Sie die Datei `users`:

```bash
cd ..
vi users
```

Fügen Sie in die Datei Folgendes ein:

```bash
user    Cleartext-Password := "password"
```

Ersetzen Sie `user` und `password` durch den jeweils gewünschten Benutzernamen und das Passwort.

Beachten Sie, dass das Passwort nicht gehasht ist. Wenn ein Angreifer also an die Datei `users` gelangt, könnte er sich unbefugten Zugriff auf Ihr geschütztes Netzwerk verschaffen.

Sie können auch ein mit `MD5` oder `Crypt` gehashtes Passwort verwenden. Um ein MD5-gehashtes Passwort zu generieren, führen Sie Folgendes aus:

```bash
echo -n password | md5sum | awk '{print $1}'
```

Ersetzen Sie `password` durch das gewünschte Passwort.

Sie erhalten den Hash `5f4dcc3b5aa765d61d8327deb882cf99`. Fügen Sie stattdessen Folgendes in die Datei `users` ein:

```bash
user    MD5-Password := "5f4dcc3b5aa765d61d8327deb882cf99"
```

Sie müssen auch Clients definieren. Dies dient dazu, unbefugten Zugriff auf unseren RADIUS-Server zu verhindern. Bearbeiten Sie die Datei `clients.conf`:

```bash
vi clients.conf
```

Bitte Folgendes eingeben:

```bash
client 172.20.0.254 {
        secret = secret123
}
```

Ersetzen Sie `172.20.0.254` und `secret123` durch die IP-Adresse und den geheimen Wert, die die Clients verwenden werden. Wiederholen Sie dies für andere Clients.

## FreeRADIUS-Aktivierung

Nach der Erstkonfiguration können Sie `radiusd` starten:

```bash
systemctl enable --now radiusd
```

## Konfigurieren von RADIUS auf einem Switch

Nach der Einrichtung des FreeRADIUS-Servers konfigurieren Sie einen RADIUS-Client.

Beispielsweise kann der MikroTik-Switch des Autors wie folgt konfiguriert werden:

```bash
/radius
add address=172.20.0.12 secret=secret123 service=dot1x
/interface dot1x server
add interface=combo3
```

Ersetzen Sie `172.20.0.12` durch die IP-Adresse des FreeRADIUS-Servers und `secret123` durch das zuvor festgelegte `secret`-Wert.
