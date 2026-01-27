---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Kapitel 3 — Applikation Servers
tags:
  - web
  - php
  - php-fpm
  - Applikation Server
  - dynamische Webseiten
---

## PHP und PHP-FPM

In diesem Kapitel werden PHP und PHP-FPM behandelt.

**PHP** (**P**HP **H**ypertext **P**reprocessor) ist eine Quellskriptsprache, die speziell für die Entwicklung von Webanwendungen entwickelt wurde. Im Jahr 2024 entfielen knapp 80 % der weltweit generierten Webseiten auf PHP. PHP ist Open Source und das Herzstück der beliebtesten CMS (`WordPress`, `Drupal`, `Joomla!`, `Magento` und andere).

**PHP-FPM** (**F**astCGI **P**rocess **M**anager) ist seit Version 5.3.3 in PHP integriert. Die FastCGI-Version von PHP bietet zusätzliche Funktionalitäten.

****

**Ziele**: In diesem Kapitel lernen Sie Folgendes:

:heavy_check_mark: PHP-Anwendungsserver installieren
:heavy_check_mark: PHP-FPM-Pool konfigurieren
:heavy_check_mark: PHP-FPM-Anwendungsserver optimieren

:checkered_flag: **PHP**, **PHP-FPM**, **Anwendungs-Server**

**Vorkenntnisse**: :star: :star: :star:
**Komplexität**: :star: :star: :star:

**Lesezeit**: 31 Minuten

****

### Allgemeines

**CGI** (**C**ommon **G**ateway **I**nterface) und **FastCGI** ermöglichen die Kommunikation zwischen dem Webserver (Apache oder Nginx) und einer Entwicklungssprache (PHP, Python, Java):

- Im Fall von **CGI** erstellt jede Anfrage einen **neuen Prozess**, was weniger leistungseffizient ist.
- **FastCGI** stützt sich bei der Bearbeitung von Client-Anfragen auf eine **bestimmte Anzahl von Prozessen**.

PHP-FPM, **zusätzlich zu besseren Leistungen**, bietet folgende Vorteile:

- Die Möglichkeit einer besseren **Partitionierung der Anwendungen**: starten von Prozessen mit unterschiedlichen UIDs/GIDs, mit personalisierten `php.ini`-Dateien,
- Verwaltung der Statistiken,
- Log-Verwaltung
- Dynamisches Management von Prozessen und Neustart ohne Unterbrechung ('graceful').

!!! note "Anmerkung"

    Da Apache ein PHP-Modul hat, wird die Verwendung von `php-fpm` häufiger auf einem `Nginx`-Server verwendet.

### PHP-Version Auswählen

Rocky Linux bietet, genau wie sein `Upstream`, viele Versionen der Sprache PHP. Einige von ihnen haben das EOL – Ende ihres Lebens – erreicht, werden aber auch weiterhin mit Legacy Anwendungen betrieben, die noch nicht mit neuen PHP-Versionen kompatibel sind. Bitte beziehen Sie sich auf die Seite [Supported Versions](https://www.php.net/supported-versions.php) der Website `php.net`, um eine unterstützte Version auszuwählen.

Um eine Liste der verfügbaren Versionen zu erhalten, geben Sie einfach folgenden Befehl ein:

 ```bash
 sudo dnf module list php
 Last metadata expiration check: 0:01:43 ago on Tue 21 Oct 2025 02:12:49 PM UTC.
 Rocky Linux 9 - AppStream
 Name                  Stream                 Profiles                                   Summary
 php                   8.1                    common [d], devel, minimal                 PHP scripting language
 php                   8.2                    common [d], devel, minimal                 PHP scripting language
 php                   8.3                    common [d], devel, minimal                 PHP scripting language
 
 Hint: [d]efault, [e]nabled, [x]disabled, [i]nstalled
 ```

Sie können jetzt ein neueres Modul (PHP 8.3) aktivieren, indem Sie den folgenden Befehl eingeben:

 ```bash
 sudo dnf module enable php:8.3
 ```

Sie können nun mit der Installation der PHP-Engine fortfahren.

### Installation des PHP CGI-Modus

Installieren und verwenden Sie zunächst PHP im CGI-Modus. Es kann nur zusammen mit dem Apache-Webserver und seinem Modul `mod_php` funktionieren. This document's FastCGI part (php-fpm) explains how to integrate PHP in Nginx (but also Apache).

The installation of PHP is relatively trivial. Sie besteht aus der Installation des Hauptpakets und der wenigen Module, die Sie benötigen.

The example below installs PHP with the modules usually installed with it.

 ```bash
 sudo dnf install php php-cli php-gd php-curl php-zip php-mbstring
 ```

Überprüfen Sie Ihre Version mit:

 ```bash
 php -v
 PHP 8.3.19 (cli) (built: Mar 12 2025 13:10:27) (NTS gcc x86_64)
 Copyright (c) The PHP Group
 Zend Engine v4.3.19, Copyright (c) Zend Technologies
    with Zend OPcache v8.3.19, Copyright (c), by Zend Technologies
 ```

### Apache Integration

To serve PHP pages in CGI mode, you must install the Apache server, configure it, activate it, and start it.

- Installation:

 ```bash
 sudo dnf install httpd
 ```

    ```
    activation:
    ```

 ```bash
 sudo systemctl enable --now httpd
 sudo systemctl status httpd
 ```

- Vergessen Sie nicht, die Firewall zu konfigurieren:

 ```bash
 sudo firewall-cmd --add-service=http --permanent
 sudo firewall-cmd --reload
 ```

Der Standard-`vhost` sollte auf Anhieb funktionieren. PHP bietet eine Funktion `phpinfo()`, die eine Übersichtstabelle seiner Konfiguration generiert. Es ist sinnvoll zu testen, ob PHP gut funktioniert. However, be careful not to leave such test files on your servers. Sie stellen ein enormes Sicherheitsrisiko für Ihre Infrastruktur dar.

Erstellen Sie die Datei `/var/www/html/info.php` (`/var/www/html` ist das Standardverzeichnis `vhost` der Standardkonfiguration von Apache):

```bash
<?php
phpinfo();
?>
```

Überprüfen Sie mithilfe eines Webbrowsers, ob der Server ordnungsgemäß funktioniert, indem Sie auf die Seite
[http://your-server-ip/info.php](http://your-server-ip/info.php).

!!! warning "Warnhinweis"

    Lassen Sie die Datei `info.php` nicht auf Ihrem Server!

### Installation des PHP-CGI-Modus (PHP-FPM)

Wie bereits erwähnt, bietet die Umstellung des Webhostings auf den PHP-FPM-Modus viele Vorteile.

Die Installation umfasst nur das `php-fpm`-Paket:

```bash
sudo dnf install php-fpm
```

Da es sich bei `php-fpm` aus Systemsicht um einen Dienst handelt, müssen Sie diesen aktivieren und starten:

```bash
sudo systemctl enable --now php-fpm
sudo systemctl status php-fpm
```

#### Konfiguration des PHP-CGI-Modus

Die Hauptkonfigurationsdatei ist `/etc/php-fpm.conf`.

```bash
include=/etc/php-fpm.d/*.conf
[global]
pid = /run/php-fpm/php-fpm.pid
error_log = /var/log/php-fpm/error.log
daemonize = yes
```

!!! note "Anmerkung"

    Die `php-fpm`-Konfigurationsdateien sind ausführlich kommentiert. Schauen Sie doch mal rein!

Wie Sie sehen, sind die Dateien im Verzeichnis `/etc/php-fpm.d/` mit der Erweiterung `.conf` immer enthalten.

Standardmäßig befindet sich eine PHP-Prozesspool-Deklaration mit dem Namen `www` in `/etc/php-fpm.d/www.conf`.

```bash
[www]
user = apache
group = apache

listen = /run/php-fpm/www.sock
listen.acl_users = apache,nginx
listen.allowed_clients = 127.0.0.1

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

slowlog = /var/log/php-fpm/www-slow.log

php_admin_value[error_log] = /var/log/php-fpm/www-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
```

| Anweisungen | Beschreibung                                                                                                                                                                                         |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `[pool]`    | Name des Prozesspools. Die Konfigurationsdatei kann mehrere Prozesspools umfassen (der Name des Pools in Klammern beginnt einen neuen Abschnitt). |
| `listen`    | Definiert die Listening-Schnittstelle oder den verwendeten Unix-Socket.                                                                                                              |

#### Konfiguration der Art und Weise, auf PHP-FPM-Prozesse zuzugreifen

Es gibt zwei Möglichkeiten zur Verbindung.

Mit einer „Inet-Schnittstelle“ wie:

`listen = 127.0.0.1:9000`.

Oder über einen UNIX-Socket:

`listen = /run/php-fpm/www.sock`.

!!! note "Anmerkung"

    Wenn sich der Webserver und der PHP-Server auf derselben Maschine befinden, wird durch die Verwendung eines Sockets die TCP/IP-Schicht entfernt und die Leistung optimiert.

Wenn Sie mit einer Schnittstelle arbeiten, müssen Sie `listen.owner`, `listen.group` und `listen.mode` konfigurieren, um den Besitzer, die Besitzergruppe und die Rechte des UNIX-Sockets anzugeben. \*\*Warnung: \*\* beide Server (Web und PHP) müssen Zugriffsrechte auf den Socket haben.

Wenn Sie mit einem Socket arbeiten, müssen Sie `listen.allowed_clients` konfigurieren, um den Zugriff auf den PHP-Server auf bestimmte IP-Adressen zu beschränken.

Beispiel: `listen.allowed_clients = 127.0.0.1`

#### Statische oder dynamische Konfiguration

Sie können PHP-FPM-Prozesse statisch oder dynamisch verwalten.

Im statischen Modus setzt `pm.max_children` eine Grenze für die Anzahl der untergeordneten Prozesse:

```bash
pm = static
pm.max_children = 10
```

Diese Konfiguration beginnt mit 10 Prozessen.

In dynamic mode, PHP-FPM starts at _most_ the number of processes specified by the`pm.max_children` value. Es startet zunächst einige Prozesse, die `pm.start_servers` entsprechen, wobei mindestens der Wert von `pm.min_spare_servers` inaktiver Prozesse und höchstens `pm.max_spare_servers` inaktiver Prozesse beibehalten wird.

Beispiel:

```bash
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

PHP-FPM erstellt einen neuen Prozess, um einen Prozess zu ersetzen, der mehrere Anfragen verarbeitet hat, die `pm.max_requests` entsprechen.

Standardmäßig ist der Wert von `pm.max_requests` 0, was bedeutet, dass Prozesse nie wiederverwendet werden. Die Option `pm.max_requests` kann für Anwendungen mit Speicherlecks nützlich sein.

Ein dritter Betriebsmodus ist der `ondemand`-Modus. Ist der Modus eingestellt, startet der Server nur einen Prozess, wenn er eine Anfrage erhält. Dies ist kein optimaler Modus für stark frequentierte Sites und ist für spezielle Anforderungen reserviert (Sites mit wenigen Anfragen, Verwaltungs--Backend usw.).

!!! note "Anmerkung"

    Die Konfiguration des Betriebsmodus von PHP-FPM ist wichtig, um die optimale Funktion Ihres Webservers sicherzustellen.

#### Prozess-Status

Wie Apache und sein Modul `mod_status` bietet PHP-FPM eine Seite, die den Status des Prozesses anzeigt.

Um die Seite zu aktivieren, legen Sie ihren Zugriffspfad mit der Direktive `pm.status_path` fest:

```bash
pm.status_path = /status
```

```bash
$ curl http://localhost/status_php
pool:                 www
process manager:      dynamic
start time:           03/Dec/2021:14:00:00 +0100
start since:          600
accepted conn:        548
listen queue:         0
max listen queue:     15
listen queue len:     128
idle processes:       3
active processes:     3
total processes:      5
max active processes: 5
max children reached: 0
slow requests:        0
```

#### Lange Anfragen protokollieren

Die Direktive `slowlog` gibt die Datei an, die übermäßig lange Logging-Requests empfängt (z. B. solche, deren Zeit den Wert der Direktive `request_slowlog_timeout` überschreitet).

Der Standardspeicherort der generierten Datei ist `/var/log/php-fpm/www-slow.log`.

```bash
request_slowlog_timeout = 5
slowlog = /var/log/php-fpm/www-slow.log
```

Ein Wert von 0 für `request_slowlog_timeout` deaktiviert die Protokollierung.

### NGinx-Integration

Die Standardeinstellung von nginx enthält bereits die notwendige Konfiguration, damit PHP mit PHP-FPM funktioniert.

Die Konfigurationsdatei `fastcgi.conf` (oder `fastcgi_params`) befindet sich unter `/etc/nginx/`:

```bash
fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;

fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;
fastcgi_param  REQUEST_SCHEME     $scheme;
fastcgi_param  HTTPS              $https if_not_empty;

fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;
fastcgi_param  SERVER_NAME        $server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
```

Damit nginx `.php`-Dateien verarbeiten kann, fügen Sie der Site-Konfigurationsdatei die folgenden Anweisungen hinzu:

Wenn PHP-FPM auf Port 9000 lauscht:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass 127.0.0.1:9000;
}
```

Wenn PHP-FPM über einen UNIX-Socket lauscht:

```bash
location ~ \.php$ {
  include /etc/nginx/fastcgi_params;
  fastcgi_pass unix:/run/php-fpm/www.sock;
}
```

### Apache-Integration

Die Konfiguration von Apache für die Nutzung eines PHP-Pools ist recht einfach. Sie müssen die Proxy-Module mit einer `ProxyPassMatch`-Anweisung verwenden, zum Beispiel:

```bash
<VirtualHost *:80>
  ServerName web.rockylinux.org
  DocumentRoot "/var/www/html/current/public"

  <Directory "/var/www/html/current/public">
    AllowOverride All
    Options -Indexes +FollowSymLinks
    Require all granted
  </Directory>
  ProxyPassMatch ^/(.*\.php(/.*)?)$ "fcgi://127.0.0.1:9000/var/www/html/current/public"

</VirtualHost>

```

### Solide Konfiguration von PHP-Pools

Um die Anzahl der gestarteten Threads zu maximieren, ist es notwendig, die Anzahl der bearbeiteten Anfragen zu optimieren und den von den PHP-Skripten verwendeten Speicher zu analysieren.

Zunächst müssen Sie mit folgendem Befehl die durchschnittliche Speichermenge ermitteln, die von einem PHP-Prozess verwendet wird:

```bash
while true; do ps --no-headers -o "rss,cmd" -C php-fpm | grep "pool www" | awk '{ sum+=$1 } END { printf ("%d%s\n", sum/NR/1024,"Mb") }' >> avg_php_proc; sleep 60; done
```

Dies vermittelt Ihnen eine recht genaue Vorstellung vom durchschnittlichen Speicherverbrauch eines PHP-Prozesses auf diesem Server.

Der Rest dieses Dokuments führt bei voller Auslastung zu einem Speicherverbrauch von 120 MB pro Prozess.

Auf einem Server mit 8 GB RAM bleiben, nachdem 1 GB für das System und 1 GB für den OPCache reserviert wurden (siehe den Rest dieses Dokuments), noch 6 GB übrig, um PHP-Anfragen von Clients zu verarbeiten.

Man kann daraus schließen, dass dieser Server maximal **50 Threads** verarbeiten kann `((6*1024) / 120)`.

Eine beispielhafte Konfiguration von `php-fpm`, die speziell auf diesen Anwendungsfall zugeschnitten ist, sieht wie folgt aus:

```bash
pm = dynamic
pm.max_children = 50
pm.start_servers = 12
pm.min_spare_servers = 12
pm.max_spare_servers = 36
pm.max_requests = 500
```

mit:

- `pm.start_servers` = 25% von `max_children`
- `pm.min_spare_servers` = 25% von `max_children`
- `pm.max_spare_servers` = 75% von`max_children`

### Opcache-Konfiguration

Der `opcache` (Optimizer Plus Cache) ist die erste Cache-Ebene, die Sie beeinflussen können.

Es behält die kompilierten PHP-Skripte im Speicher, was sich stark auf die Ausführung der Webseiten auswirkt (reduziert das Lesen des Skripts von der Festplatte und die Kompilierungszeit).

Um es zu konfigurieren, müssen Sie folgende Schritte ausführen:

- Die Größe des dem Opcache zugewiesenen Speichers richtet sich nach der Trefferquote und muss korrekt konfiguriert werden
- Die Anzahl der zwischenzuspeichernden PHP-Skripte (Anzahl der Schlüssel + maximale Anzahl der Skripte)
- Die Anzahl der Zeichenketten, die zwischengespeichert werden sollen

Um sie zu installieren:

```bash
sudo dnf install php-opcache
```

Um dies zu konfigurieren, bearbeiten Sie die Konfigurationsdatei `/etc/php.d/10-opcache.ini`:

```bash
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
```

Wobei:

- `opcache.memory_consumption` entspricht der Speichermenge, die für den opcache benötigt wird (erhöht bis ein korrektes Treffer-Verhältnis erreicht wird).
- `opcache.interned_strings_buffer` ist die Anzahl der zwischenzuspeichernden Zeichenketten.
- `opcache.max_accelerated_files` entspricht in etwa dem Ergebnis des Befehls `find ./ -iname "*.php"|wc -l`.

Informationen zur Konfiguration des Opcache finden Sie auf einer `info.php`-Seite (einschließlich `phpinfo();`) (siehe beispielsweise die Werte von `Cached scripts` und `Cached strings`).

!!! note "Anmerkung"

    Bei jeder neuen Bereitstellung von neuem Code muss der Opcache geleert werden (z. B. durch Neustart des `php-fpm`-Prozesses).

!!! note "Anmerkung"

    Unterschätzen Sie nicht den Geschwindigkeitsgewinn, der durch die korrekte Einrichtung und Konfiguration des Opcache erzielt werden kann.

<!---

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

## Python

In this chapter, you will learn about XXXXXXX.

****

**Objectives**: In this chapter, you will learn how to:

:heavy_check_mark: XXX
:heavy_check_mark: XXX

:checkered_flag: **XXX**, **XXX**

**Knowledge**: :star:
**Complexity**: :star:

**Reading time**: XX minutes

****

### Generalities

### Configuration

### Security

### Workshop

#### Task 1 : XXX

#### Task 2 : XXX

#### Task 3 : XXX

#### Task 4 : XXX

### Check your Knowledge

:heavy_check_mark: Simple question? (3 answers)

:heavy_check_mark: Question with multiple answers?

* [ ] Answer 1
* [ ] Answer 2
* [ ] Answer 3
* [ ] Answer 4

-->
