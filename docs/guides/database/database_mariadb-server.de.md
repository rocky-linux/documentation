---
title: MariaDB Datenbankserver
author: Steven Spencer
contributors: Ezequiel Bruni, William Perron, Ganna Zhyrnova, Joseph Brinkman
tested_with: 8.5, 8.6, 9.0, 9.2
tags:
  - Datenbank
  - mariadb
---

# MariaDB Datenbankserver

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

!!! tip "Hinweis"

    Die Version von `mariadb-server`, die standardmäßig in Rocky Linux 8.5 aktiviert wird, ist 10.3.32. Sie können 10.5.13 installieren, indem Sie das entsprechende Modul aktivieren:

    ```bash
    dnf module enable mariadb:10.5
    ```


    Und dann installieren Sie den Client `mariadb`. Ab Version 10.4.6 von MariaDB sind MariaDB-spezifische Befehle verfügbar, die Sie anstelle der alten mit dem Präfix `mysql` versehenen Befehle verwenden können. Dazu gehört die bereits erwähnte `mysql_secure_installation`, die nun mit der MariaDB-Version `mariadb-secure-installation` aufgerufen werden kann.

Dies öffnet folgenden Dialog:

```text
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, you will need the current
password for the root user.  Wenn Sie MariaDB gerade erst installiert haben und das Root-Passwort noch nicht festgelegt haben, ist das Passwort leer. Sie sollten hier also einfach die Eingabetaste ++enter++ drücken.

Enter current password for root (enter for none):
```

Da es sich um eine brandneue Installation handelt, ist noch kein Root-Passwort festgelegt. Also einfach ++enter++ hier drücken.

Das nächste Teil des Dialogs wird fortgesetzt:

```text
OK, successfully used password, moving on...

Durch das Festlegen des Root-Passworts wird sichergestellt, dass sich niemand ohne entsprechende Berechtigung beim MariaDB-Root-Benutzer anmelden kann.

Set root password? [Y/n]
```

Sie sollten *unbedingt* ein Root-Passwort festlegen. Sie sollten festlegen, was das sein sollte, und es irgendwo in einem Passwort-Manager dokumentieren, damit Sie es bei Bedarf abrufen können. Drücken Sie zunächst ++enter++, um den Standardwert `Y` zu übernehmen. Dadurch wird der Passwort-Dialog angezeigt:

```text
New password:
Re-enter new password:
```

Geben Sie Ihr gewähltes Passwort ein und bestätigen Sie es anschließend durch erneute Eingabe. Wenn dies erfolgreich ist, erhalten Sie den folgenden Dialog:

```text
Password updated successfully!
Reloading privilege tables..
 ... Success!
```

Als nächstes behandelt der Dialog den anonymen Benutzer:

```text
Standardmäßig verfügt eine MariaDB-Installation über einen anonymen Benutzer, sodass sich jeder
bei MariaDB anmelden kann, ohne dass für ihn ein Benutzerkonto erstellt werden muss. This is intended only for testing, and to make the installation
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

Anschließend wechselt der Dialog zur `Test`-Datenbank, die automatisch mit *mariadb-server* installiert wird:

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

### Rocky Linux 9.x

Rocky Linux 9.2 verwendet `mariadb-server-10.5.22` als Standard-MariaDB-Serverversion. Ab Version 10.4.3 wird automatisch ein neues Plugin auf dem Server aktiviert, welches den `mariadb-secure-installation` Dialog ändert. Dieses Plugin ist die `Unix-Socket`-Authentifizierung. [Dieser Artikel](https://mariadb.com/kb/en/authentication-plugin-unix-socket/) erklärt die neue Funktion ausführlich. Mit der `Unix-Socket`-Authentifizierung werden die Zugangsdaten des eingeloggten Benutzers verwendet, um auf die Datenbank zuzugreifen. Dadurch ist es möglich, dass für den Zugriff kein Kennwort erforderlich ist, wenn sich beispielsweise der Root-Benutzer anmeldet und dann `mysqladmin` zum Erstellen oder Löschen einer Datenbank (oder für eine andere Funktion) verwendet. Dasselbe funktioniert mit `mysql`. Dies bedeutet auch, dass kein Passwort existiert, das aus der Ferne kompromittiert werden könnte. Dies hängt von der Sicherheit der auf dem Server eingerichteten Benutzer für den gesamten Datenbankschutz ab.

Der zweite Dialog während der `mariadb-secure-Installation`, nachdem das Passwort für den administrativen Benutzer gesetzt wurde, ist folgender:

```text
Switch to unix_socket authentication Y/n
```

Die Vorgabe ist hier „Y“, doch auch bei der Antwort „n“ wird bei aktiviertem Plugin keine Passwortabfrage für den Benutzer durchgeführt, zumindest nicht über die Kommandozeilenschnittstelle. Sie können entweder ein Passwort oder kein Passwort angeben und beides funktioniert:

```bash
mysql

MariaDB [(none)]>
```

```bash
mysql -p
Enter password:

MariaDB [(none)]>
```

Weitere Informationen zu dieser Funktion finden Sie unter dem obigen Link. Es gibt eine Möglichkeit, dieses Plugin abzuschalten und zurück zum Passwort als Pflichtfeld zu gehen. Dies wird auch unter diesem Link detailliert.

## Zusammenfassung

Ein Datenbankserver wie *Mariadb-Server* kann für viele Zwecke genutzt werden. Aufgrund der Popularität des [WordPress CMS](https://wordpress.org) ist es häufig auf Webservern zu finden. Bevor wir die Datenbank in der Produktion betreiben, ist es jedoch eine gute Idee, ihre Sicherheit zu härten.
