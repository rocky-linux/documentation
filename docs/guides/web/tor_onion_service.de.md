---
title: Tor Onion Service
author: Neel Chauhan
contributors: Ganna Zhrynova
tested_with: 9.3
tags:
  - web
  - proxy
  - proxies
---

# Tor Onion Dienst

## Einleitung

[Tor](https://www.torproject.org/) ist ein Anonymisierungsdienst und eine Software, die den Datenverkehr über drei von Freiwilligen betriebene Server, sogenannte Relays, leitet. Das Three-Hop-Design soll die Privatsphäre gewährleisten, indem es Überwachungsversuchen widersteht.

Eine Besonderheit von Tor ist, dass man versteckte, Tor-exklusive Websites betreiben kann, die als [Onion-Dienste](https://community.torproject.org/onion-services/) bezeichnet werden. Der gesamte Datenverkehr zu einem Onion-Dienst ist daher privat und verschlüsselt.

## Voraussetzungen

Folgende Mindestvoraussetzungen gelten für die Anwendung dieses Verfahrens:

- Die Möglichkeit, Befehle als Root-Benutzer auszuführen oder mit `sudo` die Berechtigungen zu erhöhen
- Erfahrung im Umgang mit einem Kommandozeilen-Editor. Der Autor verwendet hier `vi` oder `vim`, Sie können aber Ihren bevorzugten Editor verwenden
- Ein Webserver, der auf localhost oder einem anderen TCP/IP-Port läuft

## Tor-Installation

Zur Installation von Tor müssen Sie zuerst EPEL (Extra Packages for Enterprise Linux) installieren und Updates ausführen:

```bash
dnf -y install epel-release && dnf -y update
```

Dann Tor installieren:

```bash
dnf -y install tor
```

## Tor-Konfiguration

Nach der Installation der Pakete müssen Sie Tor konfigurieren. Der Autor verwendet dafür `vim`, aber wenn Sie `nano` oder etwas anderes bevorzugen, können Sie das gerne entsprechend anpassen:

```bash
vi /etc/tor/torrc
```

Die standardmäßige `torrc`-Datei ist recht aussagekräftig, kann aber sehr lang werden, wenn man nur einen Onion-Dienst benötigt. Eine minimale Onion-Service-Konfiguration sieht in etwa so aus:

```bash
HiddenServiceDir /var/lib/tor/onion-site/
HiddenServicePort 80 127.0.0.1:80
```

### Genauere Betrachtung

- Das Verzeichnis `HiddenServiceDir` enthält den Hostnamen und die kryptografischen Schlüssel Ihres Onion-Dienstes. Sie speichern diese Schlüssel unter `/var/lib/tor/onion-site/`
- Der `HiddenServicePort` ist die Portweiterleitung von Ihrem lokalen Server zum Onion-Dienst. Sie leiten 127.0.0.1:80 an Port 80 unseres Tor-basierten Dienstes weiter

!!! warning

    Wenn Sie ein Verzeichnis außerhalb von `/var/lib/tor/` für Ihre Onion-Service-Signaturschlüssel verwenden möchten, müssen Sie sicherstellen, dass die Berechtigungen `0700` lauten und der Eigentümer `toranon:toranon` ist.

## Web-Server — Konfiguration

Sie benötigen außerdem einen Webserver auf Ihrem Rechner, um Clients für Ihren Onion-Dienst zu bedienen. Jeder Webserver (Caddy, Apache oder Nginx) ist verwendbar. Der Autor bevorzugt Caddy. Der Einfachheit halber installieren wir Caddy:

```bash
dnf -y install caddy
```

Als Nächstes fügen Sie Folgendes in die Datei `/etc/caddy/Caddyfile` ein:

```bash
http:// {
    root * /usr/share/caddy
    file_server
}
```

## Testen und Hochfahren

Sobald Sie Ihre Tor-Relay-Konfiguration eingerichtet haben, besteht der nächste Schritt darin, die Tor- und Caddy-Daemons zu aktivieren:

```bash
systemctl enable --now tor caddy
```

You can get your onion service's hostname with this command:

```bash
cat /var/lib/tor/onion-site/hostname
```

Within a few minutes, your onion service will propagate via the Tor network and you can view your new onion service in the Tor browser:

![Tor Browser showing our Onion Service](../images/onion_service.png)

## Zusammenfassung

Onion services are an invaluable tool if you are hosting a website privately or need to bypass your ISP's Carrier Grade NAT using only open source software.

While onion services are not as fast as hosting a website directly (understandable due to Tor's privacy-first design), it is way more secure and private than the public internet.
