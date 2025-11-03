---
title: DokuWiki Server
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - wiki
  - Dokumentation
---

## Voraussetzungen

- Eine Rocky Linux-Instanz, die auf einem Server, Container oder einer virtuellen Maschine installiert ist
- Sicheres Ändern von Konfigurationsdateien über die Befehlszeile mit einem Editor (in den Beispielen wird `vi` verwendet, Sie können jedoch auch Ihren bevorzugten Editor verwenden)
- Einige Kenntnisse über Webanwendungen und deren Einrichtung
- Verwendet für die Einrichtung [Apache Sites Enabled](../web/apache-sites-enabled.md). Überprüfen Sie das ggf. noch einmal.
- In diesem Dokument wird durchgehend `example.com` als Domänenname verwendet
- Sie müssen Root sein oder `sudo` verwenden können, um die Berechtigungen zu erhöhen
- Angenommen, es handelt sich um eine Neuinstallation des Betriebssystems, ist dies jedoch keine Voraussetzung

## Einleitung

Dokumentation kann in einer Organisation viele Formen annehmen. Es ist von unschätzbarem Wert, über ein Repository zu verfügen, auf das Sie für diese Dokumentation zurückgreifen können. Ein Wiki (was auf Hawaiianisch „schnell“ bedeutet) ist eine Möglichkeit, Dokumentationen, Prozessnotizen, Wissensdatenbanken und sogar Codebeispiele an einem zentralen Ort zu speichern. IT-Experten, die ein Wiki führen, selbst wenn es heimlich geschieht, verfügen über eine eingebaute Versicherung gegen das Vergessen einer obskuren Routine.

DokuWiki ist ein ausgereiftes, schnelles Wiki, das ohne Datenbank läuft, über integrierte Sicherheitsfunktionen verfügt und nicht komplex bereitzustellen ist. Weitere Informationen finden Sie auf ihrer [Webseite](https://www.dokuwiki.org/dokuwiki).

DokuWiki ist eines von vielen verfügbaren Wikis, aber es ist ein gutes. Ein großer Vorteil besteht darin, dass DokuWiki relativ leichtgewichtig ist und auf einem Server ausgeführt werden kann, auf dem bereits andere Dienste laufen, vorausgesetzt, Sie verfügen über ausreichend Speicherplatz und Arbeitsspeicher.

## Installation der Abhängigkeiten

Die Mindest-PHP-Version für DokuWiki beträgt jetzt 8. Rocky Linux 10 enthält standardmäßig PHP 8.3. Beachten Sie, dass einige der hier aufgeführten Pakete möglicherweise bereits vorhanden sind:

```bash
dnf install tar wget httpd php php-gd php-xml php-json php-mbstring
```

Akzeptieren und installieren Sie alle zusätzlichen Abhängigkeiten, die mit diesen Paketen gebunden sind.

## Erstellung der Verzeichnisse und Konfiguration ändern

### Apache-Konfiguration

Wenn Sie das Verfahren zum Aktivieren von [Apache Sites Enabled](../web/apache-sites-enabled.md) durchgelesen haben, wissen Sie, dass Sie einige Verzeichnisse erstellen müssen. Beginnen Sie mit den Ergänzungen zum `httpd`-Konfigurationsverzeichnis:

```bash
mkdir -p /etc/httpd/{sites-available,sites-enabled}
```

Sie müssen die Datei `httpd.conf` bearbeiten:

```bash
vi /etc/httpd/conf/httpd.conf
```

Fügen Sie dies ganz am Ende der Datei hinzu:

```bash
Include /etc/httpd/sites-enabled
```

Erstellen Sie die Site-Konfigurationsdatei in `sites-available`:

```bash
vi /etc/httpd/sites-available/com.example
```

Diese Konfigurationsdatei sieht in etwa so aus:

```apache
<VirtualHost *>
  ServerName    example.com
  DocumentRoot  /var/www/sub-domains/com.example/html

  <Directory ~ "/var/www/sub-domains/com.example/html/(bin/|conf/|data/|inc/)">
      <IfModule mod_authz_core.c>
                AllowOverride All
          Require all denied
      </IfModule>
      <IfModule !mod_authz_core.c>
          Order allow,deny
          Deny from all
      </IfModule>
  </Directory>

  ErrorLog   /var/log/httpd/example.com_error.log
  CustomLog  /var/log/httpd/example.com_access.log combined
</VirtualHost>
```

Beachten Sie, dass `AllowOverride All` hier die Funktion der Datei `.htaccess` (verzeichnisspezifische Sicherheit) ermöglicht.

Fahren Sie fort und verknüpfen Sie die Konfigurationsdatei mit `sites-enabled`, aber starten Sie die Webdienste noch nicht:

```bash
ln -s /etc/httpd/sites-available/com.example /etc/httpd/sites-enabled/
```

### Apache _DocumentRoot_

Sie müssen Ihr _DocumentRoot_ erstellen. So gehen Sie vor:

```bash
mkdir -p /var/www/sub-domains/com.example/html
```

## `DokuWiki`-Installation

Wechseln Sie auf Ihrem Server in das `root`-Verzeichnis.

```bash
cd /root
```

Holen Sie sich die neueste stabile Version von `DokuWiki`. Sie finden dies auf der [Download-Seite](https://download.dokuwiki.org/). Auf der linken Seite der Seite, unter `Version`, sehen Sie Folgendes: `Stable (Recommended) (direct link)`.

Klicken Sie mit der rechten Maustaste auf `(direct link)` und kopieren Sie den Link. Geben Sie in der Konsole Ihres DokuWiki-Servers `wget` und ein Leerzeichen ein und fügen Sie dann Ihren kopierten Link in das Terminal ein. Sie sollten etwas Ähnliches wie das hier erhalten:

```bash
wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz
```

Bevor Sie das Archiv dekomprimieren, untersuchen Sie den Inhalt mit `tar ztf`:

```bash
tar ztvf dokuwiki-stable.tgz
```

Beachten Sie das benannte datierte Verzeichnis vor allen anderen Dateien, die ähnlich wie diese aussehen:

```text
... (mehr oben)
dokuwiki-2020-07-29/inc/lang/fr/resetpwd.txt
dokuwiki-2020-07-29/inc/lang/fr/draft.txt
dokuwiki-2020-07-29/inc/lang/fr/recent.txt
... (mehr unten)
```

Sie möchten dieses führende Verzeichnis beim Entpacken des Archivs nicht haben, verwenden Sie daher die entsprechenden Optionen von `tar`, um es auszuschließen. Die erste Option ist `--strip-components=1`, die das führende Verzeichnis entfernt. Die zweite Option ist die Option `-C`, die `tar` mitteilt, wo das Archiv dekomprimiert werden soll. Die Dekomprimierung läuft ungefähr so ​​ab:

```bash
tar xzf dokuwiki-stable.tgz  --strip-components=1 -C /var/www/sub-domains/com.example/html/
```

Sobald Sie diesen Befehl ausführen, sollte sich das gesamte DokuWiki in Ihrem _DocumentRoot_ befinden.

Sie müssen eine Kopie der Datei `.htaccess.dist` erstellen, die mit DokuWiki geliefert wurde, und die alte Datei aufbewahren, falls Sie zum Original zurückkehren müssen.

Dabei ändern Sie den Namen in `.htaccess`. Dies ist, wonach _apache_ suchen wird. Um dies zu tun:

```bash
cp /var/www/sub-domains/com.example/html/.htaccess{.dist,}
```

Ändern Sie den Besitz des neuen Verzeichnisses und seiner Dateien in den Benutzer und die Gruppe _apache_:

```bash
chown -Rf apache.apache /var/www/sub-domains/com.example/html
```

## DNS oder `/etc/hosts` einrichten

Bevor Sie auf die DokuWiki-Oberfläche zugreifen können, müssen Sie die Namensauflösung für diese Site festlegen. Sie können die Datei `/etc/hosts` zu Testzwecken verwenden.

Gehen Sie in diesem Beispiel davon aus, dass DokuWiki unter der privaten IPv4-Adresse 10.56.233.179 ausgeführt wird. Angenommen, Sie ändern auch die Datei `/etc/hosts` auf einer Linux-Workstation. Um dies zu erreichen, geben Sie Folgendes ein:

```bash
sudo vi /etc/hosts
```

Ändern Sie dann Ihre Hostdatei so, dass sie ungefähr wie folgt aussieht (beachten Sie die IP-Adresse weiter oben im Beispiel):

```bash
127.0.0.1 localhost
127.0.1.1 myworkstation-home
10.56.233.179 example.com     example

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

Wenn Sie mit dem Testen fertig sind und bereit sind, die Dinge für alle live zu schalten, müssen Sie diesen Host zu einem DNS-Server hinzufügen. Sie könnten einen [privaten DNS-Server](../dns/private_dns_server_using_bind.md) oder einen öffentlichen DNS-Server verwenden.

## Starten von `httpd`

Bevor Sie `httpd` starten, testen Sie, ob Ihre Konfiguration in Ordnung ist:

```bash
httpd -t
```

Sie sollten folgendes Ergebnis erhalten:

```text
Syntax OK
```

Wenn ja, sollten Sie bereit sein, `httpd` zu starten und dann das Einrichten abzuschließen. Beginnen Sie, indem Sie `http` aktivieren, damit es beim Booten gestartet wird:

```bash
systemctl enable httpd
```

Dann starten:

```bash
systemctl start httpd
```

## DokuWiki-Test

Der nächste Schritt besteht darin, einen Webbrowser zu öffnen und Folgendes in die Adressleiste einzugeben:

<http://example.com/install.php>

Dadurch gelangen Sie zum Setup-Bildschirm:

- Geben Sie im Feld `Wiki Name` den Namen für Ihr Wiki ein. Beispiel `Technische Dokumentation`
- Geben Sie im Feld `Superuser` den Administrator-Benutzernamen ein. Beispiel `admin`
- Geben Sie im Feld `Real name` den Realnamen des Administratorbenutzers ein
- Geben Sie im Feld `E-Mail` die E-Mail-Adresse des Administratorbenutzers ein
- Geben Sie im Feld `Password` das sichere Passwort des Administratorbenutzers ein
- Geben Sie im Feld `once again` dasselbe Passwort erneut ein
- Wählen Sie im Dropdown-Menü `Initial ACL Policy` die Option aus, die für Ihre Umgebung am besten geeignet ist
- Aktivieren Sie das entsprechende Kontrollkästchen der Lizenz, unter die Sie Ihren Inhalt stellen möchten
- Lassen Sie das Kontrollkästchen `Once a month, send anonymous usage data to the DokuWiki developers` aktiviert (oder deaktivieren Sie es, wenn Sie dies bevorzugen)
- Klicken Sie auf die Schaltfläche `Save`.

Ihr Wiki ist nun bereit, Inhalte hinzuzufügen.

## DokuWiki-Sicherung

Beachten Sie neben der ACL-Richtlinie, die Sie gerade erstellt haben, Folgendes:

### Ihre `firewalld`-Firewall

!!! note "Anmerkung"

    Dieses Firewall-Beispiel geht nicht davon aus, welche anderen Dienste Sie möglicherweise auf Ihrem DokuWiki-Server zulassen müssen. Diese Regeln basieren auf Ihrer Testumgebung und befassen sich **NUR** mit der Gewährung des Zugriffs auf einen IP-Block eines LOKALEN Netzwerks. Sie benötigen mehr Dienste, die für einen Produktionsserver zulässig sind.

Bevor Sie alles als erledigt betrachten, müssen Sie über die Sicherheit nachdenken. Zunächst sollten Sie auf dem Server eine Firewall einrichten.

Es wird davon ausgegangen, dass sich jeder im Netzwerk 10.0.0.0/8 in Ihrem privaten lokalen Netzwerk befindet und dass dies die einzigen Personen sind, die Zugriff auf die Site benötigen.

Wenn Sie `firewalld` als Firewall verwenden, verwenden Sie die folgende Regelsyntax:

```bash
firewall-cmd --zone=trusted --add-source=10.0.0.0/8 --permanent
firewall-cmd --zone=trusted --add-service=http --add-service=https --permanent
firewall-cmd --reload
```

Nachdem Sie diese Regeln hinzugefügt und den Dienst `firewalld` neu geladen haben, listen Sie Ihre Zone auf, um sicherzustellen, dass alles vorhanden ist, was Sie benötigen:

```bash
firewall-cmd --zone=trusted --list-all
```

Wenn alles richtig funktioniert hat, sieht es etwa so aus:

```bash
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: 
  sources: 10.0.0.0/8
  services: http https
  ports: 
  protocols: 
  forward: yes
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
```

### SSL/TLS

Für optimale Sicherheit sollten Sie die Verwendung von SSL/TLS für verschlüsselten Webverkehr in Betracht ziehen. Sie können ein SSL/TLS-Zertifikat von einem SSL/TLS-Anbieter erwerben oder [Let’s Encrypt](../security/generating_ssl_keys_lets_encrypt.md) verwenden.

## Zusammenfassung

Egal, ob Sie Prozesse, Unternehmensrichtlinien, Programmcode oder etwas anderes dokumentieren müssen, ein Wiki ist hierfür eine hervorragende Lösung. DokuWiki ist ein sicheres, flexibles und benutzerfreundliches Produkt, das sich zudem unkompliziert installieren und bereitstellen lässt. Es handelt sich außerdem um ein stabiles Projekt, das es schon seit vielen Jahren gibt.
