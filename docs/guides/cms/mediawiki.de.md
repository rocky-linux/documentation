---
title: MediaWiki
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 10.0
tags:
  - cms
---

## Einleitung

[MediaWiki](https://www.mediawiki.org/wiki/MediaWiki) ist eine beliebte Open-Source-Wiki-Software-Engine, die unter anderem Websites wie `Wikipedia`, `Fandom` und `wikiHow` unterstützt.

## Voraussetzungen

Für die Verwendung dieses Verfahrens sind folgende Mindestanforderungen zu erfüllen:

- Die Möglichkeit, Befehle als Root-Benutzer auszuführen oder `sudo` zu verwenden, um Berechtigungen zu erhöhen
- Erfahrung mit einem Kommandozeilen-Editor. Der Autor verwendet hier `vi` oder `vim`, Sie können es aber durch Ihren bevorzugten Editor ersetzen

## Apache-Installation

Apache ist der Webserver, den Sie verwenden werden. Installieren Sie es mit:

```bash
dnf -y install httpd
```

Öffnen Sie anschließend die entsprechenden Firewall-Ports:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload
```

## PHP-Installation

!!! note

    Wenn Sie Rocky Linux 8.x oder 9.x ausführen, ersetzen Sie in der Installationszeile des Remi-Pakets neben der Version „8“ oder „9“.

Um `PHP` zu installieren, müssen Sie zuerst EPEL (Extra Packages for Enterprise Linux) installieren:

```bash
dnf -y install epel-release && dnf -y update
```

Sie benötigen außerdem das Remi-Repository. Installieren Sie es wie folgt:

```bash
dnf install https://rpms.remirepo.net/enterprise/remi-release-10.rpm
```

Installieren Sie anschließend PHP und die benötigten Module:

```bash
dnf install -y dnf install php84-php-fpm php84-php-intl php84-php-mbstring php84-php-apcu php84-php-curl php84-php-mysql php84-php-xml
```

Enable PHP with:

```bash
systemctl enable --now php84-php-fpm.service
```

## MariaDB-Installation

You need MariaDB for the database. Installieren Sie es mit:

```bash
dnf install mariadb-server
```

Aktivieren Sie als Nächstes den `systemd`-Dienst `mariadb` und führen Sie den Setup-Assistenten aus:

```bash
systemctl enable --now mariadb
mysql_secure_installation
```

Wenn Sie nach dem Root-Passwort gefragt werden, drücken Sie ++enter++ :

```bash
Enter current password for root (++enter++ for none):
```

Antworten Sie mit ++"n"++ auf die `unix_socket`-Authentifizierung:

```bash
Switch to unix_socket authentication [Y/n] n
```

Antworten Sie mit ++"Y"++ auf die Änderung des Root-Passworts und geben Sie das benötigte Root-Passwort ein:

```bash
Change the root password? [Y/n] Y
New password: 
Re-enter new password: 
```

Entfernen Sie die anonymen Benutzer und verbieten Sie Remote-`Root`-Anmeldungen:

```bash
Remove anonymous users? [Y/n] Y
...
Disallow root login remotely? [Y/n] Y
```

Entfernen Sie den Zugriff auf die Testdatenbank und laden Sie die Berechtigungstabellen neu:

```bash
Remove test database and access to it? [Y/n] Y
...
Reload privilege tables now? [Y/n] Y
```

Melden Sie sich bei MariaDB an mit:

```bash
mysql -u root -p
```

Geben Sie das zuvor erstellte Root-Passwort ein.

Wenn Sie sich in der MariaDB-Konsole befinden, erstellen Sie die Datenbank für MediaWiki:

```bash
MariaDB [(none)]> create database mediawiki;
```

Als nächstes erstellen Sie den MediaWiki-Benutzer:

```bash
MariaDB [(none)]> create user 'mediawiki'@'localhost' identified by 'nchauhan11';
```

Erteilen Sie Berechtigungen für die MediaWiki-Datenbank:

```bash
grant all privileges on mediawiki.* to 'mediawiki'@'localhost';
```

Leeren Sie abschließend die Berechtigungen mit:

```bash
MariaDB [(none)]> flush privileges;
```

## MediaWiki-Installation

Gehen Sie zum Verzeichnis „/var/www/“ und laden Sie MediaWiki herunter:

```bash
cd /var/www/
wget https://releases.wikimedia.org/mediawiki/1.44/mediawiki-1.44.0.zip
```

MediaWiki entpacken und verschieben:

```bash
unzip mediawiki-1.44.0.zip
mv mediawiki-1.44.0/* html/
```

Legen Sie die richtigen SELinux-Berechtigungen fest:

```bash
chown -R apache:apache /var/www/html
semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html(/.*)?"
restorecon -Rv /var/www/html
```

Apache aktivieren:

```bash
systemctl enable --now httpd
```

Öffnen Sie als Nächstes einen Browser mit der Adresse „http://Ihre_IP“ (ersetzen Sie „Ihre_IP“ durch Ihre IP-Adresse):

![MediaWiki Initial Setup](../images/mediawiki_1.png)

Wählen Sie Ihre Sprache aus und klicken Sie auf **Continue**:

![MediaWiki Language Page](../images/mediawiki_2.png)

Überprüfen Sie, ob die PHP-Konfiguration korrekt ist, scrollen Sie nach unten und klicken Sie auf **Continue**:

![MediaWiki PHP Checks](../images/mediawiki_3.png)

Geben Sie nun die Datenbankinformationen wie folgt ein:

- **Database host**: `localhost`

- **Database name (no hyphens)**: `mediawiki` (or the database created in the **MariaDB** step)

- **Database username:**: `mediawiki` (or the user created in the **MariaDB** step)

- **Database password**: The password you created in the **MariaDB** step

![MediaWiki Database Information](../images/mediawiki_4.png)

Klicken Sie auf **Continue**:

![MediaWiki Database Access Settings](../images/mediawiki_5.png)

Geben Sie auf der Seite **MediaWiki _Version_-Installation** Folgendes ein:

- **URL host name**: The URL you want

- **Name of Wiki**: Der gewünschte Wiki-Name

- **Administrator account**/**Your username**: Der Administratorbenutzername, den Sie verwenden möchten

- **Administrator account**/**Password (again)**: Das Administratorkennwort, das Sie verwenden möchten

- **Administrator account**/**Email address**: E-Mail-Adresse des Administratorbenutzers

Optional können Sie auch **Stellen Sie mir weitere Fragen** auswählen, um das Wiki zu optimieren. Der Einfachheit halber wählen Sie einfach **Mir ist schon langweilig, installieren Sie einfach das Wiki** und klicken Sie auf **Continue**:

![MediaWiki Wiki Information](../images/mediawiki_6.png)

Klicken Sie auf **Continue**, um das Wiki zu installieren:

![MediaWiki Install Step Part 1](../images/mediawiki_7.png)

MediaWiki richtet die Datenbanken ein. Wenn der Vorgang abgeschlossen ist, klicken Sie auf **Continue**:

![MediaWiki Install Step Part 2](../images/mediawiki_8.png)

Ihr Browser lädt eine Datei `LocalSettings.php` herunter. Sie laden dies mit `sftp` auf Ihren Server hoch.

Beispielsweise verwendet der Autor zum Hochladen dieser Datei seinen Fedora 42-Laptop. Gehen Sie dazu wie folgt vor:

```bash
sftp root@your_ip
(Enter password)
cd /var/www/html
put LocalSettings.php 
```

![MediaWiki LocalSettings.php Step](../images/mediawiki_9.png)

Klicken Sie abschließend auf **enter your wiki**:

![Fresh MediaWiki Wiki](../images/mediawiki_10.png)

Sie haben jetzt eine neue MediaWiki-Installation.

## Zusammenfassung

Obwohl MediaWiki vor allem als Grundlage für Wikipedia bekannt ist, ist es auch als Content-Management-System nützlich, wenn Benutzer die Möglichkeit zum Bearbeiten von Seiten benötigen. MediaWiki ist eine gute Open-Source-Alternative zu Microsoft SharePoint.
