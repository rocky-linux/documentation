---
title: MariaDB Datenbankserver
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron, Ganna Zhyrnova, Joseph Brinkman
tested_with: 8.5, 8.6, 9.0, 9.2, 10.0
tags:
  - Datenbank
  - mariadb
---

## Voraussetzungen

- Ein Rocky Linux Server
- Erfahrung mit einem Kommandozeilen-Editor (wir verwenden *vi* in diesem Beispiel)
- Eine solide Erfahrung mit der Befehlszeile, Anzeigen von Protokollen und anderen allgemeinen Aufgaben eines Systemadministrators
- Ein Verständnis von *mariadb-server* Datenbanken ist hilfreich
- Alle Befehle werden als Root-Benutzer oder mit _sudo_ ausgeführt

## Einleitung

Der *mariadb-server* und sein Client *mariadb* sind die freien Open-Source-Alternativen zu *mysql-server* und *mysql* und sie teilen sich die Befehlsstruktur. *mariadb-server* läuft auf vielen Webservern, da das beliebte [WordPress CMS](https://wordpress.org/) dies erfordert. Diese Datenbank deckt noch viele andere Anwendungsfälle ab.

Wenn Sie dies zusammen mit anderen Tools zum Härten eines Webservers verwenden möchten, lesen Sie den [Leitfaden zum gehärteten Apache-Webserver](../web/apache_hardened_webserver/index.md).

## `mariadb-server` — Installation

Sie müssen *mariadb-server* installieren:

```bash
dnf install mariadb-server
```

## `mariadb-server` absichern

Um die Sicherheit des *MariaDB-Servers* zu erhöhen, müssen Sie ein Skript ausführen. Zuvor müssen Sie jedoch MariaDB aktivieren und starten:

```bash
systemctl enable --now mariadb
```

Führen Sie als Nächstes diesen Befehl aus:

```bash
mysql_secure_installation
```

Dies öffnet einen Dialog:

```text
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. Wenn Sie MariaDB gerade erst installiert haben und
das Root-Passwort noch nicht festgelegt haben, drücken Sie hier einfach ++enter++.

Enter current password for root (enter for none):
```

Da es sich um eine brandneue Installation handelt, ist noch kein Root-Passwort festgelegt. Also einfach ++enter++ hier drücken.

Das nächste Teil des Dialogs wird fortgesetzt:

```text
Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n]
```

Antworten Sie mit ++"n"++ und drücken Sie ++enter++

```text
You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n]
```

Sie haben noch kein Kennwort für den Root-Benutzer festgelegt **ODER** die `unix_socket`-Authentifizierung verwendet. Antworten Sie hier also mit ++"Y"++ und drücken Sie die ++enter++.

Dadurch wird der Passwort-Dialog angezeigt:

```text
New password:
Re-enter new password:
```

Geben Sie Ihr gewähltes Passwort ein und bestätigen Sie es anschließend durch erneute Eingabe. Wenn dies erfolgreich war, erhalten Sie den folgenden Dialog:

```text
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

Speichern Sie dieses Passwort in einem Passwort-Manager oder an einem sicheren Speicherort.

Als nächstes behandelt der Dialog den anonymen Benutzer:

```text
By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them. This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n]
```

Die Antwort hier lautet "Y", also drücken Sie einfach ++enter++, um die Standardeinstellung zu bestätigen.

Das Dialogfeld fährt mit dem Abschnitt fort, in dem es darum geht, dem Root-Benutzer die Remote-Anmeldung zu ermöglichen:

```text
... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n]
```

`root` sollte nur lokal auf dem Rechner benötigt werden. Bestätigen Sie diese Voreinstellung also auch, indem Sie auf ++enter++ klicken.

Der Dialog wechselt dann zur `test`-Datenbank, die automatisch mit *mariadb-server* installiert wird:

```text
... Success!


By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n]
```

Auch hier ist die Antwort die Vorgabe, also drücken Sie einfach ++enter++, um sie zu entfernen.

Schließlich fragt der Dialog, ob Sie die Berechtigungen neu laden möchten:

```text
- Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n]
```

Drücken Sie dazu erneut ++enter++. Wenn alles gut geht, sollten Sie folgende Nachricht erhalten:

```text
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

MariaDB ist nun einsatzbereit.

## Zusammenfassung

Ein Datenbankserver wie *mariadb-server* kann für viele Zwecke verwendet werden. Aufgrund der Popularität des [WordPress CMS](wordpress.org) ist es häufig auf Webservern zu finden. Bevor wir die Datenbank in der Produktion betreiben, ist es jedoch eine gute Idee, ihre Sicherheit zu härten.
