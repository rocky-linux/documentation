---
title: FreeRADIUS RADIUS Server und Samba Active Directory
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 10.1
tags:
  - Sicherheit
---

## Einleitung

RADIUS ist ein AAA-Protokoll (Authentifizierung, Autorisierung und Abrechnung) zur Verwaltung des Netzwerkzugriffs. [FreeRADIUS](https://www.freeradius.org/) ist der De-facto-RADIUS-Server für Linux und andere Unix-ähnliche Systeme.

Sie können FreeRADIUS mit Microsofts Active Directory nutzen, beispielsweise für die Authentifizierung nach 802.1X, Wi-Fi oder VPN.

## Voraussetzungen

Folgende Mindestanforderungen gelten für dieses Verfahren:

- Die Möglichkeit, Befehle als `root`-Benutzer auszuführen oder mit `sudo` die Berechtigungen zu erhöhen
- Ein Active Directory-Mitgliedsserver, unabhängig davon, ob er eine Windows Server- oder Samba-Domäne verwendet
- Ein RADIUS-Client, beispielsweise ein Router, Switch oder WLAN-Zugangspunkt

## Samba-Konfiguration

Sie müssen [Active Directory mit Samba konfigurieren](../security/authentication/active_directory_authentication_with_samba). Beachten Sie, dass `sssd` nicht funktionieren wird.

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

Anschließend müssen Sie `ntlm_auth` aktivieren. Bearbeiten Sie die Datei `/etc/raddb/sites-enabled/default` und fügen Sie Folgendes in den `authenticate`-Block ein:

```bash
authenticate {
...
    ntlm_auth
...
}
```

Fügen Sie dasselbe in `/etc/raddb/sites-enabled/inner_tunnel` ein:

```bash
authenticate {
...
    ntlm_auth
...
}
```

Ändern Sie die Zeile `program` in `/etc/raddb/mods-enabled/ntlm_auth` wie folgt:

```bash
    program = "/usr/bin/ntlm_auth --request-nt-key --domain=MYDOMAIN --username=%{mschap:User-Name} --password=%{User-Password}"
```

Ersetzen Sie `MYDOMAIN` durch Ihren Active Directory-Domänennamen.

Sie müssen `ntlm_auth` als Standardauthentifizierungstyp in `/etc/raddb/mods-config/files/authorize` festlegen. Fügen Sie die folgende Zeile hinzu:

```bash
DEFAULT   Auth-Type = ntlm_auth
```

Sie müssen außerdem Clients definieren. Dies dient dazu, unbefugten Zugriff auf unseren RADIUS-Server zu verhindern. Bearbeiten Sie die Datei `clients.conf`:

```bash
vi clients.conf
```

Bitte Folgendes einfügen:

```bash
client 172.20.0.254 {
        secret = secret123
}
```

Ersetzen Sie `172.20.0.254` und `secret123` durch die IP-Adresse und den geheimen Wert, die die Clients verwenden werden. Wiederholen Sie dies für weitere Clients.

## FreeRADIUS-Aktivierung

Nach der Erstkonfiguration können Sie `radiusd` starten:

```bash
systemctl enable --now radiusd
```

## RADIUS auf einem Switch konfigurieren

Nach der Einrichtung des FreeRADIUS-Servers konfigurieren Sie einen RADIUS-Client.

Beispielsweise kann der MikroTik-Switch des Autors wie folgt konfiguriert werden:

```bash
/radius
add address=172.20.0.12 secret=secret123 service=dot1x
/interface dot1x server
add interface=combo3
```

Ersetzen Sie `172.20.0.12` durch die IP-Adresse des FreeRADIUS-Servers und `secret123` durch das zuvor festgelegte `secret`-Wert.
