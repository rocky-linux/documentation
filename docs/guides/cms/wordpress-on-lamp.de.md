---
title: WordPress und LAMP
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.2
---

## Voraussetzungen

- ein Rocky Linux 9.x System
- `sudo`-Privilegien

## Einleitung

WordPress ist ein Open Source Content-Management-System (CMS), das für seine [berühmte 5-Minuten-Installation](https://developer.wordpress.org/advanced-administration/before-install/howto-install/) bekannt ist. Es wird üblicherweise auf einem LAMP-Stack (Linux, Apache, MySQL, PHP) bereitgestellt. Obwohl effiziente lokale Entwicklungstools wie [XAMPP](https://www.apachefriends.org/), [Vagrant](https://www.vagrantup.com/) und [wp-env](https://developer.wordpress.org/block-editor/reference-guides/packages/packages-env/) weithin verfügbar sind, bietet die manuelle Installation von WordPress auf LAMP für die lokale Entwicklung einen wertvollen praktischen Ansatz für Anfänger, die ein tieferes Verständnis anstreben.

Diese Anleitung setzt voraus, dass Sie Rocky Linux 9.x bereits installiert haben, wodurch der `L`-Teil des LAMP-Stacks abgedeckt wird.

In dieser Anleitung wird erläutert, wie Sie WordPress manuell mit dem LAMP-Stack auf einer Rocky Linux 9-Maschine installieren. Dies ist kein produktionsreifer Leitfaden, sondern ein Ausgangspunkt, auf dem Sie aufbauen können. Das in diesem Handbuch enthaltene LAMP-Setup wird ausschließlich für die lokale Entwicklung empfohlen, wenn nicht zuvor geeignete Sicherheitsmaßnahmen ergriffen werden, die eine zusätzliche Konfiguration erfordern.

## Systempakete aktualisieren

Stellen Sie sicher, dass die Pakete Ihres Systems auf dem neuesten Stand sind:

```bash
    sudo dnf upgrade -y
```

## Apache — Installation

Apache ist ein Webserver, der Ihre WordPress-Site bereitstellt. Installieren Sie ihn mit folgender Anweisung:

```bash
    sudo dnf install httpd -y
```

## Aktivieren Sie Apache für den automatischen Start beim Booten

Aktivieren Sie Apache nach der Installation, damit es beim Booten automatisch gestartet wird:

```bash
    sudo systemctl enable --now httpd
```

## MariaDB — Installation

WordPress speichert dynamische Inhalte in einer MySQL-Datenbank. MariaDB ist ein freies Open-Source-Fork von MySQL. Installieren Sie sie mit folgender Anweisung:

```bash
    sudo dnf install mariadb-server -y
```

## MariaDB-Server aktivieren

Aktivieren Sie MariaDB nach der Installation, sodass es beim Booten automatisch startet:

```bash
    sudo systemctl enable --now mariadb
```

## Absicherung von MariaDB

Führen Sie das Skript `mysql_secure_installation` aus:

```bash
    sudo mysql_secure_installation --use-default
```

Dieses Skript führt folgende Schritte aus:

1. Root-Passwort festlegen, falls noch keins eingerichtet ist

2. Anonyme Benutzer entfernen

3. Remote-Root-Anmeldung verbieten

4. Zugriff auf die Testdatenbank entfernen

5. Privilegien neu laden

## PHP — Installation

PHP ist die Programmier-Sprache, die zur Interaktion mit der MySQL-Datenbank und zur Durchführung dynamischer Aktionen verwendet wird. Es wird häufig im WordPress-Kern, in Designs und Plugins verwendet.

Installieren Sie PHP und die erforderlichen Pakete zur Verbindung mit MySQL:

```bash
    sudo dnf install php php-mysqlnd php-gd php-xml php-mbstring
```

Nach der Installation von PHP müssen Sie Apache neu laden, um es als Apache-Modul zu installieren und seine Konfigurationsdateien zu lesen:

## Apache neu starten

```bash
    sudo systemctl restart httpd
```

## WordPress herunterladen und entpacken

Verwenden Sie `curl`, um die neueste Version von WordPress herunterzuladen:

```bash
    curl -O https://wordpress.org/latest.tar.gz
```

Verwenden Sie `tar`, um das heruntergeladene Archiv zu extrahieren:

```bash
    tar -xzvf latest.tar.gz
```

Kopieren Sie die WordPress-Dateien in das öffentliche Standardverzeichnis von Apache:

```bash
   sudo cp -r wordpress/* /var/www/html 
```

## `owner` setzen

Machen Sie Apache zum Eigentümer der Dateien:

```bash
    sudo chown -R apache:apache /var/www/html/
```

Legen Sie die Berechtigungen für die WordPress-Dateien fest:

## Festlegen von Berechtigungen

```bash
    sudo chmod -R 755 /var/www/html/
```

Melden Sie sich beim MySQL-CLI an:

## Datenbank — Konfiguration

```bash
    sudo mysql -u root -p
```

Erstellen Sie eine neue Datenbank für Ihre WordPress-Website:

## Erstellen Sie eine neue Datenbank

```bash
    CREATE DATABASE LOCALDEVELOPMENTENV;
```

Erstellen Sie einen Benutzer mit einem Passwort für Ihre Datenbank:

!!! note "Anmerkung"

```
Es wird dringend empfohlen, ein sichereres Passwort zu verwenden.
```

## Einen neuen Benutzer und ein neues Passwort erstellen

```bash
    CREATE USER 'admin'@'localhost' IDENTIFIED BY 'password';
```

Gewähren Sie mit `grant` dem soeben erstellten Benutzer alle Berechtigungen für Ihre WordPress-Datenbank:

```bash
    GRANT ALL PRIVILEGES ON LOCALDEVELOPMENTENV.* TO 'admin'@'localhost';
```

Speichern Sie die Berechtigungen, um die Anwendung der Änderungen sicherzustellen:

```bash
    FLUSH PRIVILEGES;
```

Beenden Sie die MySQL-CLI:

```bash
    EXIT;
```

## WordPress — Konfiguration

Kopieren Sie die Vorlage `wp-config-sample.php` und benennen Sie sie um:

```bash
    sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
```

Öffnen Sie die Datei `wp-config.php` mit einem Texteditor Ihrer Wahl:

```bash
    sudo vi /var/www/html/wp-config.php
```

## Ersetzen der Datenbankeinstellungen

Sie müssen die folgenden Konstanten in Ihrer Datei `wp-config.php` definieren:

```bash
    define ('DB_NAME', 'LOCALDEVELOPMENTENV');
    define ('DB_USER', 'admin');
    define ('DB_PASSWORD', 'password');
```

## Firewall konfigurieren

Öffnen Sie HTTP- und HTTPS-Dienste in Ihrer Firewall:

```bash
    sudo firewall-cmd --add-service=http --add-service=https
```

Laden Sie `firewalld` neu, um sicherzustellen, dass die Änderungen wirksam werden:

```bash
    sudo systemctl reload firewalld
```

## SELinux — Konfiguration

Um Apache Lese- und Schreibzugriff auf Ihre WordPress-Dateien zu gewähren, führen Sie diesen Befehl aus:

```bash
   chcon -R -t httpd_sys_rw_content_t /var/www/html/ 
```

Führen Sie folgenden Befehl aus, damit Apache Netzwerkverbindungen herstellen kann:

!!! note "Anmerkung"

```
Das Flag `-P` macht diese Konfiguration über Neustarts hinweg persistent
```

```bash
    setsebool -P httpd_can_network_connect true
```

## Zusammenfassung

Um die Installation abzuschließen, sollten Sie nun in der Lage sein, über das Netzwerk eine Verbindung zu WordPress herzustellen, indem Sie den Hostnamen oder die private IP-Adresse des Servers verwenden. Denken Sie daran, dass dieses Setup in erster Linie für lokale Entwicklungszwecke gedacht ist. Für den Produktionseinsatz müssen Sie Folgendes konfigurieren: einen Domänennamen festlegen, ein SSL-Zertifikat installieren, Ihren Apache-Server härten, Ihre SELinux-Konfiguration optimieren und Backups implementieren. Dennoch hat das Befolgen dieser Anleitung einen soliden Ausgangspunkt für die WordPress-Entwicklung auf einem LAMP-Stack geschaffen.
