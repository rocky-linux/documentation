---
title: Cloud-Server mit Nextcloud
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - cloud
  - nextcloud
---


## Voraussetzungen

- Server mit Rocky Linux (Sie können Nextcloud auf jeder Linux-Distribution installieren, das Verfahren hier setzt jedoch voraus, dass Sie Rocky verwenden).
- Efahrung mit der Kommandozeile für Installation und Konfiguration.
- Sicheren Umgang mit einem Kommandozeilen-Editor. Für dieses Beispiel wird `vi` verwendet, Sie können jedoch auch Ihren bevorzugten Editor verwenden, falls Sie einen haben.
- Dieses Verfahren umfasst die Installationsmethode mit der `.zip`-Datei. Sie können Nextcloud auch als `snap`-Anwendung installieren.
- Dieses Verfahren verwendet das Apache-Dokument _sites enabled_ (später verlinkt) für die Verzeichniseinrichtung.
- Dieses Verfahren verwendet auch die _mariadb-server_-Härtung (ebenfalls später verlinkt) für die Datenbankeinrichtung.
- In diesem Dokument wird davon ausgegangen, dass Sie Root-Rechte besitzen oder Ihre Berechtigungen mit `sudo` erhöhen können.
- Die hier verwendete Beispieldomäne ist `yourdomain.com`.

## Einleitung

Wenn Sie für die Serverumgebung eines großen (oder auch kleinen) Unternehmens verantwortlich sind, können Sie den Einsatz von Cloud-Anwendungen in Betracht ziehen. Die Verlagerung von Aufgaben in die Cloud kann Ihre eigenen Ressourcen für andere Aufgaben freisetzen, aber es gibt einen Nachteil: den Verlust der Kontrolle über die Daten Ihres Unternehmens. Wenn es zu einer Kompromittierung der Cloud-Anwendung kommt, könnten Sie auch die Daten Ihres Unternehmens gefährden.

Die Rückführung der Cloud in die eigene Umgebung ist eine Möglichkeit, die Kontrolle über die eigenen Daten zurückzugewinnen, allerdings auf Kosten von Zeit, Aufwand und Energie. Manchmal lohnt es sich, diese Kosten in Kauf zu nehmen.

Nextcloud bietet eine Open-Source-Cloud-Plattform, bei der Sicherheit und Flexibilität im Vordergrund stehen. Beachten Sie, dass der Aufbau eines Nextcloud-Servers eine gute Übung ist, selbst wenn Sie Ihre Cloud am Ende extern betreiben. Das folgende Verfahren befasst sich mit der Einrichtung von Nextcloud auf Rocky Linux.

## Nextcloud — Installation

### Installation und Konfiguration der Repositories und Modulen

Für diese Installation benötigen Sie zwei Repositories. Sie müssen EPEL (Extra Packages for Enterprise Linux) und das `Remi` Repository für RL10 installieren.

!!! note "Anmerkung"

    Während Rocky Linux 10 PHP 8.3 benötigt, bietet das Remi-Repository zusätzliche PHP-Pakete, die für Nextcloud erforderlich sind.

So installieren Sie EPEL:

```bash
dnf install epel-release
```

Um das Remi-Repository zu installieren, führen Sie Folgendes aus:

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-10.rpm
```

Führen Sie dann `dnf upgrade` erneut aus.

Führen Sie Folgendes aus, um eine Liste der verfügbaren PHP-Module anzuzeigen:

```bash
dnf module list php
```

Dies gibt Ihnen diese Ausgabe für Rocky Linux 10:

```bash
Remi's Modular repository for Enterprise Linux 10 - x86_64
Name                   Stream                      Profiles                                      Summary                                  
php                    remi-7.4                    common [d], devel, minimal                    PHP scripting language                   
php                    remi-8.0                    common [d], devel, minimal                    PHP scripting language                   
php                    remi-8.1                    common [d], devel, minimal                    PHP scripting language                   
php                    remi-8.2                    common [d], devel, minimal                    PHP scripting language                   
php                    remi-8.3                    common [d], devel, minimal                    PHP scripting language                   
php                    remi-8.4                    common [d], devel, minimal                    PHP scripting language

Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
```

Verwenden Sie das neueste PHP, mit dem Nextcloud kompatibel ist. Im Moment liegt dieser bei 8.4. Aktivieren Sie dieses Modul mit:

```bash
dnf module enable php:remi-8.4
```

Um zu sehen, wie sich dies auf die Ausgabe der Modulliste auswirkt, führen Sie den Befehl `module list` erneut aus. Neben 8.3 sehen Sie dann das `[e]`:

```bash
dnf module list php
```

Die Ausgabe ist bis auf diese Zeile dieselbe:

```bash
php                    remi-8.4 [e]                   common [d], devel, minimal                  PHP scripting language
```

### Installation der Pakete

Das Beispiel hier verwendet Apache und MariaDB. Um die benötigten Pakete zu installieren, gehen Sie wie folgt vor:

```bash
dnf install httpd mariadb-server vim wget zip unzip libxml2 openssl php84-php php84-php-ctype php84-php-curl php84-php-gd php84-php-iconv php84-php-json php84-php-libxml php84-php-mbstring php84-php-openssl php84-php-posix php84-php-session php84-php-xml php84-php-zip php84-php-zlib php84-php-pdo php84-php-mysqlnd php84-php-intl php84-php-bcmath php84-php-gmp
```

### Konfiguration

#### Apache Konfiguration

Stellen Sie _apache_ so ein, dass es beim Booten gestartet wird:

```bash
systemctl enable httpd
```

Und dann starten Sie den Dienst:

```bash
systemctl start httpd
```

#### Erstellen der Konfiguration

Im Abschnitt _Voraussetzungen_ gab es die Angabe, dass Sie für Ihre Konfiguration das Verfahren [Apache Sites Enabled](../web/apache-sites-enabled.md) verwenden sollten. Klicken Sie auf dieses Verfahren, richten Sie dort die Grundlagen ein und kehren Sie dann zu diesem Dokument zurück, um fortzufahren.

Für Nextcloud müssen Sie die folgende Konfigurationsdatei erstellen:

```bash
vi /etc/httpd/sites-available/com.yourdomain.nextcloud
```

Mit folgendem Inhalt:

```bash
<VirtualHost *:80>
  DocumentRoot /var/www/sub-domains/com.yourdomain.nextcloud/html/
  ServerName  nextcloud.yourdomain.com
  <Directory /var/www/sub-domains/com.yourdomain.nextcloud/html/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

Speichern Sie anschließend Ihre Änderungen (mit ++shift+colon+"w"+"q"+exclam++ im Falle _vi_).

Erstellen Sie als Nächstes einen Link zu dieser Datei in `/etc/httpd/sites-enabled`:

```bash
ln -s /etc/httpd/sites-available/com.yourdomain.nextcloud /etc/httpd/sites-enabled/
```

#### Verzeichnis anlegen

Wie zuvor in der Konfiguration erwähnt, müssen Sie das _DocumentRoot_ erstellen. So gehen Sie vor:

```bash
mkdir -p /var/www/sub-domains/com.yourdomain.com/html
```

Hier installieren Sie Ihre Nextcloud-Instanz.

#### PHP Konfiguration

Sie müssen die Zeitzone für PHP einstellen. Öffnen Sie dazu `php.ini` mit dem Texteditor Ihrer Wahl:

```bash
vi /etc/opt/remi/php84/php.ini
```

Suchen Sie dann folgende Zeile:

```php
;date.timezone =
```

Entfernen Sie das Kommentarzeichen (++semicolon++) und stellen Sie die Zeitzone ein. Für diese Beispielzeitzone können Sie Folgendes eingeben:

```php
date.timezone = "America/Chicago"
```

ODER

```php
date.timezone = "US/Central"
```

Speichern und beenden Sie anschließend die Datei `php.ini`.

Beachten Sie, dass Ihre Zeitzone in der Datei `php.ini` mit der Zeitzoneneinstellung Ihres Computers übereinstimmen sollte, damit alles consistent bleibt. Um herauszufinden, was das ist, gehen Sie wie folgt vor:

```bash
ls -al /etc/localtime
```

Sie sollten ungefähr Folgendes sehen, vorausgesetzt, Sie haben Ihre Zeitzone bei der Installation von Rocky Linux eingestellt und leben in der Central Time Zone:

```bash
/etc/localtime -> /usr/share/zoneinfo/America/Chicago
```

#### MariaDB-Server – Konfiguration

Stellen Sie `mariadb-server` so ein, dass es beim Booten gestartet wird:

```bash
systemctl enable mariadb
```

Und dann starten Sie den Dienst:

```bash
systemctl restart mariadb
```

Verwenden Sie, wie bereits zuvor angegeben, das Setup-Verfahren zum [Härten von `mariadb-server`](../database/database_mariadb-server.md) für die Erstkonfiguration.

### Installieren von .zip

Die nächsten Schritte setzen voraus, dass Sie per `ssh` mit Ihrem Nextcloud-Server verbunden sind und eine Remote-Konsole geöffnet ist:

- Navigieren Sie zur [Nextcloud-Website](https://nextcloud.com/).
- Bewegen Sie den Mauszeiger über `Download`, um ein Dropdown-Menü zu öffnen.
- Klicken Sie auf `Nextcloud server`.
- Klicken Sie auf `Download server archive`.
- Klicken Sie mit der rechten Maustaste auf `Get ZIP file` und kopieren Sie den Link.
- Geben Sie in Ihrer Remote-Konsole auf dem Nextcloud-Server `wget` und dann ein Leerzeichen ein und fügen Sie das ein, was Sie gerade kopiert haben. Sie sollten etwas Ähnliches wie das Folgende erhalten: `wget https://download.nextcloud.com/server/releases/latest.zip`.
- Sobald Sie die Eingabetaste drücken, beginnt der Download der ZIP-Datei und wird schnell abgeschlossen.

Sobald der Download abgeschlossen ist, extrahieren Sie die Nextcloud-ZIP-Datei mit:

```bash
unzip latest.zip
```

### Kopie vom Inhalt und Ändern von Berechtigungen

Nachdem Sie den Schritt zum Extrahieren der ZIP-Datei abgeschlossen haben, sollten Sie jetzt ein neues Verzeichnis in `/root` mit dem Namen `nextcloud` haben. Wechseln Sie in das Verzeichnis:

```bash
cd nextcloud
```

Kopieren oder verschieben Sie den Inhalt in _DocumentRoot_:

```bash
cp -Rf * /var/www/sub-domains/com.yourdomain.nextcloud/html/
```

ODER

```bash
mv * /var/www/sub-domains/com.yourdomain.nextcloud/html/
```

Der nächste Schritt besteht darin, sicherzustellen, dass `apache` Eigentümer des Verzeichnisses ist. So gehen Sie vor:

```bash
chown -Rf apache.apache /var/www/sub-domains/com.yourdomain.nextcloud/html
```

Aus Sicherheitsgründen sollten Sie außerdem den Ordner _data_ aus dem _DocumentRoot_ in einen Ordner außerhalb davon verschieben. Dies geschieht mit dem folgenden Befehl:

```bash
mv /var/www/sub-domains/com.yourdomain.nextcloud/html/data /var/www/sub-domains/com.yourdomain.nextcloud/
```

### `Nextcloud`-Konfiguration

Stellen Sie sicher, dass Ihre Dienste ausgeführt werden. Wenn Sie die vorherigen Schritte befolgt haben, sollten sie bereits ausgeführt werden. Zwischen den ersten Dienststarts sind mehrere Schritte ausgeführt worden. Starten Sie sie daher zur Sicherheit neu:

```bash
systemctl restart httpd
systemctl restart mariadb
```

Wenn alles neu gestartet wird und keine Probleme auftreten, können Sie fortfahren.

Um die Erstkonfiguration durchzuführen, laden Sie die Site in einem Webbrowser:

<http://your-server-hostname/> (ersetzen Sie dies durch Ihren tatsächlichen Hostnamen)

Vorausgesetzt, Sie haben bisher alles richtig gemacht, sollte ein Nextcloud-Setup-Bildschirm angezeigt werden:

![nextcloud login screen](../images/nextcloud_screen.jpg)

Es gibt einige Dinge, die Sie anders als die Standardeinstellungen machen sollten:

- Legen Sie oben auf der Webseite unter `Create an admin account` den Benutzernamen und das Passwort fest. Geben Sie für dieses Beispiel `admin` ein und legen Sie ein sicheres Passwort fest. Denken Sie daran, es an einem sicheren Ort (z. B. einem Passwort-Manager) zu speichern, damit Sie es nicht verlieren. Auch wenn Sie in dieses Feld etwas eingegeben haben, drücken Sie ==nicht== ++enter++, bis Sie **alle** Felder ausgefüllt haben.
- Ändern Sie im Abschnitt `Storage & database` den Speicherort des `Datenordners` vom Standard-Dokumentenstamm dorthin, wo Sie den Datenordner zuvor verschoben haben: `/var/www/sub-domains/com.yourdomain.nextcloud/data`.
- Wechseln Sie im Abschnitt `Configure the database` von `SQLite` zu `MySQL/MariaDB`, indem Sie auf diese Schaltfläche klicken.
- Geben Sie den MariaDB-Root-Benutzer und das Passwort, die Sie zuvor festgelegt haben, in die Felder `Database user` und `Database password` ein.
- Geben Sie im Feld `Database name` `nextcloud` ein.
- Geben Sie in das Feld `localhost` Folgendes ein <localhost:3306> (3306 ist der standardmäßige _mariadb_-Verbindungsport).

Wenn Sie dies alles haben, klicken Sie auf `Finish Setup` und alles sollte einsatzbereit sein.

Das Browserfenster wird kurz aktualisiert und lädt die Site dann normalerweise nicht neu. Geben Sie Ihre URL erneut in das Browserfenster ein und Sie sollten die Erste der Default-Seiten sehen.

Ihr Administrator-Benutzer ist zu diesem Zeitpunkt bereits angemeldet (oder sollte es sein) und es gibt mehrere Informationsseiten, die Ihnen den Einstieg erleichtern sollen. Das `Dashboard` ist das, was Benutzer sehen, wenn sie sich zum ersten Mal anmelden. Der Administrator-Benutzer kann jetzt andere Benutzer erstellen, zusätzliche Anwendungen installieren und viele andere Aufgaben ausführen.

Die Datei `Nextcloud Manual.pdf` ist das Benutzerhandbuch, damit sich Benutzer mit dem verfügbaren Inhalt vertraut machen können. Der administrative Benutzer sollte die wichtigsten Punkte des Administratorhandbuchs [On the Nextcloud website](https://docs.nextcloud.com/server/21/admin_manual/) durchlesen oder zumindest überfliegen

## Nächste Schritte

Vergessen Sie an dieser Stelle nicht, dass es sich um einen Server handelt, auf dem Sie Unternehmensdaten speichern. Es ist wichtig, die Site mit einer Firewall abzusichern, die [Sicherung einzurichten](../backup/rsnapshot_backup.md), die Site mit einem [SSL](../security/generating_ssl_keys_lets_encrypt.md) zu sichern und alle anderen erforderlichen Aufgaben auszuführen, um Ihre Daten zu schützen.

## Zusammenfassung

Sie müssen jede Entscheidung, die Unternehmens-Cloud ins eigene Haus zu holen, sorgfältig abwägen. Für diejenigen, die die lokale Speicherung von Unternehmensdaten einem externen Cloud-Host vorziehen, ist Nextcloud eine gute Alternative.
