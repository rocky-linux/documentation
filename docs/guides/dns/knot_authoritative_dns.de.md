---
title: Knot Autoritativer DNS
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - dns
---

Eine Alternative zu BIND, [Knot DNS](https://www.knot-dns.cz/), ist ein moderner, rein autoritativer DNS-Server, der von der tschechischen Domain-Registrierung [CZ.NIC](https://www.nic.cz/) verwaltet wird.

## Voraussetzungen

- Ein Server mit Rocky Linux
- Die Möglichkeit _firewalld_ zum Erstellen von Firewall-Regeln verwenden
- Ein Domänenname oder ein interner rekursiver DNS-Server, der auf Ihren autoritativen DNS-Server verweist

## Einleitung

Externe oder öffentliche DNS-Server werden im Internet verwendet, um Hostnamen IP-Adressen zuzuordnen und im Falle von PTR (bekannt als "pointer" oder "reverse") Records, um die IP dem Hostnamen zuzuordnen. Das ist ein wesentlicher Teil des Internets. Es sorgt dafür, dass Ihr Mailserver, Webserver, FTP-Server oder viele andere Server und Dienste wie erwartet funktionieren, egal wo Sie sich befinden.

## Installation und Aktivierung von `Knot`

Zuerst EPEL installieren:

```bash
dnf install epel-release
```

Dann `Knot` installieren:

```bash
dnf install knot
```

## Knot-Konfiguration

Bevor Sie Änderungen an einer Konfigurationsdatei vornehmen, verschieben Sie die ursprünglich installierte Datei `knot.conf`:

```bash
mv /etc/knot/knot.conf /etc/knot/knot.conf.orig
```

Dies wird in der Zukunft helfen, wenn Fehler in die Konfigurationsdatei eingefügt werden. Es ist immer _eine gute Idee_, eine Sicherungskopie zu erstellen, bevor Sie Änderungen vornehmen.

Die Datei _knot.conf_ editieren. Der Autor verwendet _vi_, Sie können jedoch auch Ihren bevorzugten Befehlszeileneditor verwenden:

```bash
vi /etc/knot/knot.conf
```

Bitte Folgendes eingeben:

```bash
server:
    listen: 0.0.0.0@53
    listen: ::@53

zone:
  - domain: example.com
    storage: /var/lib/knot/zones
    file: example.com.zone

log:
  - target: syslog
    any: info
```

Ersetzen Sie `example.com` durch den Domainnamen, für den Sie einen Nameserver ausführen.

Als nächstes erstellen Sie die Zonendateien:

```bash
mkdir /var/lib/knot/zones
vi /var/lib/knot/zones/example.com.zone
```

Die DNS-Zone-Dateien sind BIND-kompatibel. Fügen Sie in die Datei Folgendes ein:

```bash
$TTL    86400 ; How long should records last?
; $TTL used for all RRs without explicit TTL value
$ORIGIN example.com. ; Define our domain name
@  1D  IN  SOA ns1.example.com. hostmaster.example.com. (
                              2024061301 ; serial
                              3h ; refresh duration
                              15 ; retry duration
                              1w ; expiry duration
                              3h ; nxdomain error ttl
                             )
       IN  NS     ns1.example.com. ; in the domain
       IN  MX  10 mail.another.com. ; external mail provider
       IN  A      172.20.0.100 ; default A record
; server host definitions
ns1    IN  A      172.20.0.100 ; name server definition     
www    IN  A      172.20.0.101 ; web server definition
mail   IN  A      172.20.0.102 ; mail server definition
```

Wenn Sie Hilfe beim Anpassen von Zone-Dateien im BIND-Stil benötigen, bietet Oracle [eine ausgezeichnete Einführung in Zonendateien](https://docs.oracle.com/en-us/iaas/Content/DNS/Reference/formattingzonefile.htm).

Speichern Sie Ihre Änderungen.

## `Knot` Aktivierung

Lassen Sie als Nächstes DNS-Ports in `firewalld` zu und aktivieren Sie Knot DNS:

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now knot
```

Überprüfen Sie die DNS-Auflösung mit dem Befehl `host`:

```bash
% host example.com 172.20.0.100
Using domain server:
Name: 172.20.0.100
Address: 172.20.0.100#53
Aliases: 

example.com has address 172.20.0.100
example.com mail is handled by 10 mail.another.com.
%
```

## Zusammenfassung

Während die meisten Menschen Dienste von Drittanbietern für DNS nutzen, gibt es Szenarien, in denen selbst gehostetes DNS gewünscht ist. Beispielsweise hosten Telekommunikations-, Hosting- und Social-Media-Unternehmen eine große Anzahl von DNS-Einträgen, bei denen auch gehostete Dienste unerwünscht sind.

Knot ist eines von vielen Open-Source-Tools, das das Hosten von DNS möglich macht. Herzlichen Glückwunsch, Sie haben Ihren eigenen DNS-Server! Glück auf!
