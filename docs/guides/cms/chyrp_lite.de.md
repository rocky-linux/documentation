---
title: Chyrp Lite
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.5
tags:
  - cms
  - blogging
---

## Einleitung

[Chyrp Lite](https://chyrplite.net/) ist eine ultraleichte Blogging-Engine, die in PHP geschrieben ist.

## Voraussetzungen

Für die Verwendung dieses Verfahrens sind folgende Mindestanforderungen zu erfüllen:

- Die Möglichkeit, Befehle als Root-Benutzer auszuführen oder `sudo` zu verwenden, um Berechtigungen zu erhöhen
- Erfahrung mit einem Befehlszeileneditor. Der Autor verwendet hier `vi` oder `vim`, aber ersetzen Sie es durch Ihren bevorzugten Editor

## `Caddy`-Installation

Sie werden `Caddy` als Webserver verwenden. Um Caddy zu installieren, müssen Sie zuerst EPEL (Extra Packages for Enterprise Linux) installieren und Updates ausführen:

```bash
dnf -y install epel-release && dnf -y update
```

Dann `Caddy` installieren:

```bash
dnf -y install Caddy
```

Öffnen Sie anschließend die Datei `Caddyfile`:

```bash
vi /etc/caddy/Caddyfile
```

Fügen Sie Ihrer `Caddyfile` Folgendes hinzu:

```bash
your.domain.name {
        root * /var/www/chyrp-lite
        file_server
        php_fastcgi 127.0.0.1:9000
}
```

Speichern Sie die Datei mit `:wq!` und öffnen Sie anschließend die entsprechenden Firewall-Ports:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
```

Abschließend starten Sie `Caddy`:

```bash
systemctl enable --now caddy
```

## PHP — Installation

!!! note "Anmerkung"

```
Wenn Sie Rocky Linux 8.x oder 10.x ausführen, ersetzen Sie in der Installationszeile des Remi-Pakets neben der Version `8` oder `10`. 
```

Um PHP aufzusetzen, benötigen Sie das Remi-Repository. Um `Remi` zu installieren, führen Sie Folgendes aus:

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-9.rpm
```

Installieren Sie anschließend PHP und die benötigten Module:

```bash
dnf install -y php83-php php83-php-session php83-php-json php83-php-ctype php83-php-filter php83-php-libxml php83-php-simplexml php83-php-mbstring php83-php-pdo php83-php-curl
```

Öffnen Sie als Nächstes die PHP-Konfigurationsdatei:

```bash
vi /etc/opt/remi/php83/php-fpm.d/www.conf
```

Gehen Sie zur Zeile `listen =` und legen Sie sie wie folgt fest:

```bash
listen = 127.0.0.1:9000
```

Beenden Sie `vi` mit `:wq!` und aktivieren Sie PHP:

```bash
systemctl enable --now php83-php-fpm.service
```

## `Chyrp`-Installation

Jetzt installieren Sie Chyrp Lite. Laden Sie die neueste Version herunter:

```bash
cd /var/www
wget https://github.com/xenocrat/chyrp-lite/archive/refs/tags/v2024.03.zip
```

Als nächstes dekomprimieren und verschieben Sie den extrahierten Ordner:

```bash
unzip v2024.03.zip
mv chyrp-lite-2024.03/ chyrp-lite
```

Legen Sie die richtigen Berechtigungen für den Ordner `chyrp-lite` fest:

```bash
chown -R apache:apache chyrp-lite/
```

Richten Sie ein Datenverzeichnis zum Speichern der SQLite-Datenbank ein:

```bash
mkdir chyrp-lite-data
chown -R apache:apache chyrp-lite-data/
```

Als nächstes richten Sie die SELinux-Dateikontexte ein:

```bash
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/chyrp-lite(/.*)?"
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/chyrp-lite-data(/.*)?"
restorecon -Rv /var/www/chyrp-lite
restorecon -Rv /var/www/chyrp-lite-data
```

Öffnen Sie auf einem Client-Computer einen Webbrowser unter `https://example.com/install.php` und führen Sie das Installationsprogramm aus (ersetzen Sie `example.com` durch Ihren tatsächlichen Domänennamen oder Hostnamen):

![Chyrp Lite Setup](../images/chyrp_lite_setup.png)

Wählen Sie im Abschnitt **Database** einen Pfadnamen im zuvor erstellten Verzeichnis `chyrp-lite-data` aus, z. B. `/var/www/chyrp-lite-data/sqlite.db`.

Füllen Sie dann die anderen Felder aus, die selbsterklärend sein sollten.

Klicken Sie anschließend auf **Install me** und dann auf **Take me to my site**. Sie sollten jetzt in der Lage sein, eine abgeschlossene Installation Ihrer `Chyrp`-Site zu besuchen:

![Chyrp Lite](../images/chyrp_lite.png)

## Zusammenfassung

Wenn man bedenkt, dass sich WordPress zu einem Schweizer Taschenmesser der Webentwicklung entwickelt hat, ist es nicht überraschend, dass einige Webmaster (einschließlich des Autors) eine leichtgewichtige Blogging-Engine bevorzugen. `Chyrp Lite` ist perfekt für diese Benutzer.
