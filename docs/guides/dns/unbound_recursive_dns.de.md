---
title: Unbound – Rekursiv DNS
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - dns
---

Als Alternative zu BIND ist [Unbound](https://www.nlnetlabs.nl/projects/unbound/about/) ein moderner validierender, rekursiver und zwischenspeichernder DNS-Server, der von [NLnet Labs](https://www.nlnetlabs.nl/) verwaltet wird.

## Voraussetzungen

- Ein Server mit Rocky Linux
- Kann `firewalld` zum Erstellen von Firewall-Regeln verwenden

## Einleitung

Es gibt zwei Arten von DNS-Servern: autoritative und rekursive. Während autoritative DNS-Server eine DNS-Zone bekannt geben, lösen rekursive Server Abfragen im Auftrag der Clients auf, indem sie diese an einen ISP oder öffentlichen DNS-Resolver bzw. bei größeren Servern an die Root-Zonen weiterleiten.

Beispielsweise verfügt Ihr Heimrouter wahrscheinlich über einen eingebetteten rekursiven DNS-Resolver, der an Ihren ISP oder einen bekannten öffentlichen DNS-Server weiterleitet, der ebenfalls ein rekursiver DNS-Server ist.

## Installation und Aktivierung von `Unbound`

`Unbound`-Installation:

```bash
dnf install unbound
```

## `Unbound`-Konfiguration

Bevor Sie Änderungen an einer Konfigurationsdatei vornehmen, verschieben Sie die ursprünglich installierte Arbeitsdatei `unbound.conf`:

```bash
cp /etc/unbound/unbound.conf /etc/unbound/unbound.conf.orig
```

Dies wird in der Zukunft helfen, wenn Fehler in die Konfigurationsdatei eingefügt werden. Es ist immer _eine gute Idee_, eine Sicherungskopie zu erstellen, bevor Sie Änderungen vornehmen.

Bearbeiten Sie die Datei _unbound.conf_. Der Autor verwendet _vi_, Sie können jedoch auch Ihren bevorzugten Befehlszeileneditor verwenden:

```bash
vi /etc/unbound/unbound.conf
```

Bitte Folgendes eingeben:

```bash
server:
    interface: 0.0.0.0
    interface: ::
    access-control: 192.168.0.0/16 allow
    access-control: 2001:db8::/64 allow
    chroot: ""

forward-zone:
    name: "."
    forward-addr: 1.0.0.1@53
    forward-addr: 1.1.1.1@53
```

Ersetzen Sie `192.168.0.0/16` und `2001:db8::/64` durch die Subnetze, für die Sie DNS-Abfragen auflösen wollen. Speichern Sie Ihre Änderungen.

### Genauer betrachten

- Das `interface` bezeichnet die Schnittstellen (IPv4 oder IPv6), auf denen Sie auf DNS-Anfragen warten möchten. Wir lauschen auf allen Schnittstellen mit `0.0.0.0` und `::`.
- Das `access-control` gibt an, aus welchen Subnetzen (IPv4 oder IPv6) Sie DNS-Abfragen zulassen möchten. Wir erlauben Anfragen von `192.168.0.0/16` und `2001:db8::/64`.
- Die `forward-addr` definiert die Server, an die wir weiterleiten. Wir leiten zu `1.1.1.1` und `1.0.0.1` von Cloudflare weiter.

## Unbound-Aktivierung

Als nächstes erlauben Sie DNS-Ports in `firewalld` und aktivieren Unbound:

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now unbound
```

Überprüfen Sie die DNS-Auflösung mit dem Befehl `host`:

```bash
$ host google.com 172.20.0.100
Using domain server:
Name: 172.20.0.100
Address: 172.20.0.100#53
Aliases:

google.com has address 142.251.215.238
google.com has IPv6 address 2607:f8b0:400a:805::200e
google.com mail is handled by 10 smtp.google.com.
```

%

## Zusammenfassung

Die meisten Leute verwenden den DNS-Resolver ihres Heimrouters oder öffentliche DNS-Resolver, die von ISPs und Technologieunternehmen betrieben werden. In Heim-Labors und großen Netzwerken ist es üblich, einen Netzwerk-weiten Resolver zu betreiben, um die Latenz und die Netzwerklast zu reduzieren, indem DNS-Anfragen für häufig angeforderte Websites wie Google zwischengespeichert werden. Ein netzwerkweiter Resolver ermöglicht auch Intranetdienste wie SharePoint und Active Directory.

Unbound ist eines von vielen Open-Source-Tools, die die DNS-Auflösung ermöglichen. Herzlichen Glückwunsch, Sie haben Ihren eigenen DNS-Resolver!
