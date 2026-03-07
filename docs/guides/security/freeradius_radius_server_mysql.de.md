---
title: FreeRADIUS RADIUS Server und MariaDB
author: Neel Chauhan
contributors:
tested_with: 10.1
tags:
  - Sicherheit
---

## Einleitung

RADIUS ist ein AAA-Protokoll (Authentifizierung, Autorisierung und Abrechnung) zur Verwaltung des Netzwerkzugriffs. [FreeRADIUS](https://www.freeradius.org/) ist der De-facto-RADIUS-Server für Linux und andere Unix-ähnliche Systeme.

Sie können FreeRADIUS mit MariaDB verwenden, beispielsweise für die Authentifizierung nach 802.1X, Wi-Fi oder VPN.

## Voraussetzungen

Folgende Mindestanforderungen gelten für dieses Verfahren:

- Die Möglichkeit, Befehle als `root`-Benutzer auszuführen oder mit `sudo` die Berechtigungen zu erhöhen
- MariaDB-Server
- Ein RADIUS-Client, beispielsweise ein Router, Switch oder WLAN-Zugangspunkt

## FreeRADIUS-Installation

Sie benötigen zunächst EPEL und CRB:

```bash
dnf install epel-release
crb enable
```

Anschließend können Sie FreeRADIUS aus den `dnf`-Repositorys installieren:

```bash
dnf install -y freeradius freeradius-mysql
```

## MariaDB

Sie müssen MariaDB installieren:

```bash
dnf install mariadb-server
```

## FreeRADIUS-Konfiguration

Nach der Installation der Pakete müssen Sie zunächst die TLS-Verschlüsselungszertifikate für FreeRADIUS generieren:

```bash
cd /etc/raddb/certs
./bootstrap
```

Anschließend müssen Sie `sql` aktivieren. Bearbeiten Sie die Datei `/etc/raddb/sites-enabled/default` und ersetzen Sie `-sql` durch `sql`:

```bash
authorize {
   ...
   sql
   ...
}
...
accounting {
   ...
   sql
   ...
}
...
session {
   ...
   sql
   ...
}
...
post-auth {
    ...
    sql
    ...
    Post-Auth-Type REJECT {
        sql
    }
    ....

}
```

Führen Sie das gleiche Verfahren in `/etc/raddb/sites-enabled/inner-tunnel` durch:

```bash
authorize {
   ...
   sql
   ...
}
...
session {
   ...
   sql
   ...
}
...
post-auth {
    ...
    sql
    ...
    Post-Auth-Type REJECT {
        sql
    }
    ....

}
```

Ändern Sie die Zeile `program` in `/etc/raddb/mods-enabled/ntlm_auth` wie folgt:

Ändern Sie in der Datei `/etc/raddb/mods-available/sql` den Wert für `dialect` in `mysql`:

```bash
        dialect = "mysql"
```

Ändern Sie dann den Treiber – `driver` –:

```bash
        driver = "rlm_sql_${dialect}"
```

Löschen Sie im Abschnitt `mysql {` den Unterabschnitt `tls {`.

Legen Sie anschließend den Datenbanknamen, den Benutzernamen und das Passwort fest:

```bash
        server = "127.0.0.1"
        port = 3306
        login = "radius"
        password = "password"
        ...
        radius_db = "radius"
```

Ersetzen Sie die obigen Felder durch Ihre jeweiligen Server- und Benutzernamen.

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

## Einfügen des MariaDB-Schemas

Aktivieren Sie zunächst MariaDB und führen Sie das Setup aus.

```bash
systemctl enable --now mysql
mysql_secure_installation
```

Melden Sie sich zunächst bei MariaDB an:

```bash
mysql -u root -p
```

Erstellen Sie nun den RADIUS-Benutzer und die Datenbank:

```bash
create database radius;
create user 'radius'@'localhost' identified by 'password';
grant all privileges on radius.* to 'radius'@'localhost';
```

Ersetzen Sie Benutzername, Passwort und Datenbanknamen durch die gewünschten Werte.

Fügen Sie anschließend das MariaDB-Schema ein:

```bash
mysql -u root -p radius < /etc/raddb/mods-config/sql/dhcp/mysql/schema.sql
```

Ersetzen Sie den Datenbanknamen durch den von Ihnen ausgewählten Namen.

## Benutzer-Konten erstellen

Melden Sie sich zunächst bei MariaDB an:

```bash
mysql -u root -p radius
```

Dann können Sie Benutzer hinzufügen:

```bash
insert into radcheck (username,attribute,op,value) values("neha", "Cleartext-Password", ":=", "iloveicecream");
```

Ersetzen Sie `neha` und `iloveicecream` durch die gewünschten Benutzernamen und Passwort.

Sie können auch Software von Drittanbietern verwenden, um Benutzer hinzuzufügen. Beispielsweise ermöglichen WHMCS (Web Host Manager Complete Solution) und diverse Abrechnungssysteme von Internetdienstanbietern dies.

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

Ersetzen Sie `172.20.0.12` durch die IP-Adresse des FreeRADIUS-Servers und `secret123` durch den zuvor festgelegte `secret`-Wert.
