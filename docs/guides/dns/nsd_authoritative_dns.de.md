---
title: NSD Autoritativer DNS
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.4
tags:
  - dns
---

Als Alternative zu BIND ist [NSD](https://www.nlnetlabs.nl/projects/nsd/about/) (Name Server Daemon) ein moderner, ausschließlich autoritativer DNS-Server, der von [NLnet Labs](https://www.nlnetlabs.nl/) verwaltet wird.

## Voraussetzungen

- Ein Server mit Rocky Linux
- Die Möglichkeit _firewalld_ zum Erstellen von Firewall-Regeln zu verwenden
- Ein Domänenname oder ein interner rekursiver DNS-Server, der auf Ihren autoritativen DNS-Server verweist

## Einleitung

Externe oder öffentliche DNS-Server werden im Internet verwendet, um Hostnamen IP-Adressen zuzuordnen und im Falle von PTR (bekannt als `pointer` oder `reverse`) Records, um die IP dem Hostnamen zuzuordnen. Das ist ein wesentlicher Teil des Internets. Es sorgt dafür, dass Ihr Mailserver, Webserver, FTP-Server oder viele andere Server und Dienste wie erwartet funktionieren, egal wo Sie sich befinden.

## Installation und Aktivierung von `NSD`

Zuerst EPEL installieren:

```bash
dnf install epel-release
```

Installieren Sie nun NSD:

```bash
dnf install nsd
```

## NSD-Konfiguration

Bevor Sie Änderungen an einer Konfigurationsdatei vornehmen, kopieren Sie die ursprünglich installierte Arbeitsdatei `nsd.conf`:

```bash
cp /etc/nsd/nsd.conf /etc/nsd/nsd.conf.orig
```

Dies wird in der Zukunft helfen, wenn Fehler in die Konfigurationsdatei eingefügt werden. Es ist immer _eine gute Idee_, eine Sicherungskopie zu erstellen, bevor Sie Änderungen vornehmen.

Bearbeiten Sie die Datei _nsd.conf_. Der Autor verwendet _vi_, Sie können jedoch auch Ihren bevorzugten Befehlszeileneditor verwenden:

```bash
vi /etc/nsd/nsd.conf
```

Navigieren Sie nach unten und geben Sie Folgendes ein:

```bash
zone:
    name: example.com
    zonefile: /etc/nsd/example.com.zone
```

Ersetzen Sie `example.com` durch den Domainnamen, für den Sie einen Nameserver ausführen.

Als nächstes erstellen Sie die Zonendateien:

```bash
vi /etc/nsd/example.com.zone
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

## `NSD` Aktivierung

Als nächstes erlauben Sie DNS-Ports in `firewalld` und aktivieren NSD:

```bash
firewall-cmd --add-service=dns --zone=public
firewall-cmd --runtime-to-permanent
systemctl enable --now nsd
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

Die meisten Menschen nutzen Dienste von Drittanbietern für DNS. Es gibt jedoch Szenarien, in denen ein selbst gehostetes DNS erwünscht ist. Beispielsweise hosten Telekommunikations-, Hosting- und Social-Media-Unternehmen eine große Anzahl von DNS-Einträgen, bei denen auch gehostete Dienste unerwünscht sind.

NSD ist eines von vielen Open-Source-Tools, die das Hosten von DNS ermöglichen. Herzlichen Glückwunsch, Sie haben Ihren eigenen DNS-Server!
