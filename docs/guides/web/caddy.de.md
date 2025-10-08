---
title: Caddy — Web Server
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 9.3, 10.0
tags:
  - web
---

## Einleitung

_Caddy_ ist ein Webserver, der für moderne Webanwendungen entwickelt wurde. Caddy ist einfach zu konfigurieren und verfügt über die automatische Let's Encrypt-Funktion, sodass Ihre Websites standardmäßig immer sicher sind. Es ist der bevorzugte Webserver des Autors.

Hier ist ein kurzer Überblick über die Funktionen von Caddy:

- Ein einfacher Webserver
- Ein Reverse-Proxy für die Übertragung von Traffic zu mehreren Sites
- Module für viele Workloads, einschließlich TCP, SSH und mehr
- Ein integrierter Lastausgleich zur Verwaltung von Traffic zu mehreren Websites
- Integrierte, automatisierte `Let's Encrypt`-Unterstützung
- Eine API zur programmgesteuerten Neukonfiguration des Servers
- PHP FastCGI Support
- und IPv6

## Voraussetzungen

Sie werden Folgendes benötigen:

- Ein ans Internet angeschlossener Rocky Linux Rechner oder Server.
- Erfahrung mit der Kommandozeile.
- Die Möglichkeit, Befehle als Root-Benutzer oder mit `sudo` auszuführen.
- Ein Texteditor Ihrer Wahl, ob grafisch oder Kommandozeilen-basiert. Für dieses Tutorial verwendet der Autor `vim`.
- Ein Domänenname oder anderer Hostname, der auf die öffentliche IP-Adresse Ihres Servers verweist.

## `Caddy`-Installation

Stellen Sie zunächst sicher, dass Ihr Computer über die neuesten Updates verfügt:

```bash
sudo dnf update
```

Installieren Sie dann das Software-Repository `epel-release`:

```bash
sudo dnf install -y epel-release
```

Wenn Sie Rocky Linux 10 ausführen, aktivieren Sie das `Copr`-Repository:

```bash
sudo dnf copr enable @caddy/caddy
```

Installieren Sie als Nächstes den `Caddy`-Webserver:

```bash
sudo dnf install -y caddy
```

## Konfiguration der Firewall

Wenn Sie versuchen, von einem anderen Computer aus eine Webseite mit der IP-Adresse oder dem Domänennamen Ihres Computers anzuzeigen, wird wahrscheinlich nichts angezeigt. Dies ist der Fall, wenn Sie eine Firewall installiert und in Betrieb haben.

Um die erforderlichen Ports zu öffnen, damit Sie Ihre Webseiten tatsächlich „sehen“ können, verwenden Sie die integrierte Firewall von Rocky Linux, `firewalld`. Der `firewalld`-Befehl hierfür ist `firewall-cmd`.

Um die Dienste `http` und `https` zu öffnen, also die Dienste, die Webseiten verwalten, führen Sie Folgendes aus:

```bash
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
```

Im Detail:

- Das Flag `--permanent` weist die Firewall an, diese Konfiguration bei jedem Neustart der Firewall und beim Neustart des Servers anzuwenden.
- `–-zone=public` weist die Firewall an, eingehende Verbindungen zu diesem Port von allen zuzulassen.
- Schließlich weisen `--add-service=http` und `--add-service=https` `firewalld` an, den gesamten HTTP- und HTTPS-Verkehr an den Server weiterzuleiten.

Diese Konfigurationen werden erst wirksam, wenn Sie die Firewall neu laden. Um dies zu tun, weisen Sie `firewalld` an, seine Konfiguration neu zu laden:

```bash
sudo firewall-cmd --reload
```

!!! note "Anmerkung"

````
Es besteht eine sehr geringe Wahrscheinlichkeit, dass dies nicht funktioniert. In diesen seltenen Fällen können Sie `firewalld` mit der bewährten Methode „Ausschalten und wieder einschalten“ dazu bringen, Ihren Befehl auszuführen.

```bash
systemctl restart firewalld
```
````

Um die Zulassung der Ports sicherzustellen, führen Sie `firewall-cmd --list-all` aus. Eine richtig konfigurierte Firewall sieht ähnlich wie Folgendes:

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: cockpit dhcpv6-client ssh http https
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Das sollte alles sein, was Sie in Bezug auf die Firewall benötigen.

## Caddy Installation

Im Gegensatz zu herkömmlichen Webservern wie Apache und Nginx ist das Konfigurationsformat von Caddy deutlich einfacher. Vorbei sind die Zeiten, in denen Sie die kleinsten Details wie das Threading-Modell Ihres Webservers oder SSL-Zertifikate konfigurieren mussten.

So bearbeiten Sie die Caddy-Konfigurationsdatei:

```bash
sudo vim /etc/caddy/Caddyfile
```

Eine minimale statische Webserverkonfiguration kann etwa wie folgt aussehen:

```bash
example.com {
    root * /usr/share/caddy/example.com
    file_server
}
```

Ersetzen Sie `example.com` durch einen Hostnamen, der auf Ihren Server verweist.

Sie müssen dem Ordner im `root`-Verzeichnis von Caddy auch eine Website hinzufügen. Fügen Sie der Einfachheit halber eine einseitige statische Website hinzu:

```bash
mkdir -p /usr/share/caddy/example.com
echo "<h1>Hi!</h1>" >> /usr/share/caddy/example.com/index.html
```

Aktivieren Sie anschließend den systemd-Dienst von Caddy:

```bash
sudo systemctl enable --now caddy
```

Innerhalb einer Minute erhält Caddy SSL-Zertifikate von Let’s Encrypt. Anschließend können Sie die soeben eingerichtete Website in einem Browser anzeigen:

![Caddy serving our demo website](../images/caddy_example.png)

Es sollte über ein SSL-Vorhängeschloss verfügen, das in jedem modernen Browser funktionieren sollte, und nicht nur das, sondern auch eine A+-Bewertung beim [Qualys SSL Server Test](https://www.ssllabs.com/ssltest/).

## Optional: PHP FastCGI

Wie bereits erwähnt, bietet Caddy FastCGI-Unterstützung für PHP. Die gute Nachricht ist, dass Caddy im Gegensatz zu Apache und Nginx PHP-Dateierweiterungen automatisch verarbeitet.

Um PHP zu installieren, fügen Sie zuerst das Remi-Repository hinzu (Hinweis: Wenn Sie Rocky Linux 8.x oder 9.x ausführen, ersetzen Sie 8 oder 9 neben `release-` unten):

```bash
sudo dnf install https://rpms.remirepo.net/enterprise/remi-release-10.rpm
```

Als nächstes müssen wir PHP installieren (Hinweis: Wenn Sie eine andere PHP-Version verwenden, ersetzen Sie php83 durch Ihre gewünschte Version):

```bash
sudo dnf install -y php85-php-fpm
```

Wenn Sie zusätzliche PHP-Module benötigen (z. B. GD), fügen Sie diese dem obigen Befehl hinzu.

Dann müssen wir PHP so konfigurieren, dass es auf einem TCP-Socket lauscht:

```bash
sudo vim /etc/opt/remi/php85/php-fpm.d/www.conf
```

Suchen Sie als Nächstes folgende Zeile:

```bash
listen = /var/opt/remi/php85/run/php-fpm/www.sock
```

Ersetzen Sie es durch Folgendes:

```bash
listen = 127.0.0.1:9000
```

Sie können jetzt `php-fpm` aktivieren und starten:

```bash
sudo systemctl enable --now php85-php-fpm
```

Speichern und beenden Sie dann die Datei `www.conf` und öffnen Sie die Caddy-Datei:

```bash
sudo vim /etc/caddy/Caddyfile
```

Navigieren Sie zu dem Serverblock, den wir zuvor erstellt haben:

```bash
example.com {
    root * /usr/share/caddy/example.com
    file_server
}
```

Fügen Sie nach der Zeile `file_server` die folgende Zeile hinzu:

```bash
    php_fastcgi 127.0.0.1:9000
```

Ihr PHP-aktiver Serverblock sieht folgendermaßen aus:

```bash
example.com {
    root * /usr/share/caddy/example.com
    file_server
    php_fastcgi 127.0.0.1:9000
}
```

Speichern und beenden Sie anschließend die Caddy-Datei und starten Sie Caddy neu:

```bash
sudo systemctl restart caddy
```

Um zu testen, ob PHP funktioniert, fügen Sie eine einfache PHP-Datei hinzu:

```bash
echo "<?php phpinfo(); ?>" >> /usr/share/caddy/rockyexample.duckdns.org/phpinfo.php
```

Öffnen Sie in Ihrem Browser die von Ihnen erstellte Datei. Daraufhin sollten Ihnen PHP-Informationen angezeigt werden:

![Caddy serving our PHP file](../images/caddy_php.png)

## Zusammenfassung

Die grundlegende Installation und Konfiguration von Caddy ist unglaublich einfach. Vorbei sind die Zeiten, in denen Sie Stunden mit der Konfiguration von Apache verbracht haben. Ja, Nginx ist sicherlich ein Fortschritt, aber es fehlen immer noch moderne, aber wesentliche Funktionen wie Let’s Encrypt und Kubernetes-Ingress-Unterstützung, die Caddy integriert, während Sie diese bei Nginx (und Apache) separat hinzufügen müssen.

Der Autor verwendet Caddy seit 2019 als bevorzugten Webserver und er ist einfach zu gut. Tatsächlich ist es, wenn der Autor mit Apache, Nginx oder IIS arbeitet, fast so, als würde er mit einer Zeitmaschine ins Jahr 2010 oder früher reisen.
