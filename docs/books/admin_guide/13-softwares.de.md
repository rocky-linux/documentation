---
title: Softwareverwaltung
author: Antoine Le Morvan
contributors: Franco Colussi, Steven Spencer, Ganna Zhyrnova
tested version: 8.5
tags:
  - Schulung
  - Software
  - Softwareverwaltung
---

# Softwareverwaltung

## Allgemeines

Auf einem GNU/Linux-System ist es möglich, Software auf zwei Arten zu installieren:

* Verwendung eines Installationspakets;
* Kompilierung aus Quelldateien.

!!! note "Anmerkung"

    Die Installation aus dem Quellcode ist hier nicht abgedeckt. In der Regel sollten Sie die Paketmanager-Methode verwenden, es sei denn, die gewünschte Software ist nicht über den Paketmanager verfügbar. Ein Grund dafür ist, dass Abhängigkeiten im Allgemeinen vom Paketsystem verwaltet werden, während Sie mit dem Quellcode die Abhängigkeiten manuell verwalten müssen.

**Das Paket**: Es ist eine einzige Datei, die alle Daten enthält, die für die Installation eines Programms benötigt werden. Es kann direkt auf dem System aus einem Software-Repository installiert werden.

**Die Quelldateien**: Einige Programme wird nicht in Paketen bereitgestellt, die installiert werden können, sondern über ein Archiv, das die Quelldateien enthält. Es obliegt dem Administrator, diese Dateien vorzubereiten und zu kompilieren, um die Software zu installieren.

## RPM: RedHat Paketmanager

**RPM** (RedHat Package Manager) ist ein Software-Verwaltung-System. Es ist möglich, die in Paketen enthaltene Software zu installieren, zu deinstallieren, zu aktualisieren oder zu überprüfen.

**RPM** ist das Format, das von allen RedHat basierten Distributionen verwendet wird (Rocky Linux, Fedora, CentOS, SuSe, Mandriva, ...). Das Äquivalent in der Debian-Welt ist DPKG (Debian Package).

Der Name eines RPM-Pakets folgt einer spezifischen Nomenklatur:

![Beschreibung eines Paketnamens](images/software-001.png)

### Da Kommando `rpm`

Mit dem Befehl rpm können Sie ein Paket installieren.

```bash
rpm [-i][-U] package.rpm [-e] package
```

Beispiel (für ein Paket Namens 'package'):

```bash
rpm -ivh package.rpm
```

| Option           | Beschreibung                                   |
| ---------------- | ---------------------------------------------- |
| `-i package.rpm` | installiert das Paket.                         |
| `-U package.rpm` | aktualisiert ein bereits installiertes Paket.  |
| `-e package.rpm` | deinstalliert das Paket.                       |
| `-h`             | zeigt einen Fortschrittsbalken an.             |
| `-v`             | informiert über den Fortschritt der Operation. |
| `--test`         | testet den Befehl ohne ihn auszuführen.        |

Mit dem Befehl `rpm` können Sie auch die System-Paketdatenbank abfragen, indem Sie die Option `-q` hinzufügen.

Es ist möglich, mehrere Arten von Abfragen auszuführen, um verschiedene Informationen über die installierten Pakete zu erhalten. Die RPM-Datenbank befindet sich im Verzeichnis `/var/lib/rpm`.

Beispiel:

```bash
rpm -qa
```

Dieser Befehl fragt alle auf dem System installierten Pakete ab.

```bash
rpm -q [-a][-i][-l] package [-f] file
```

Beispiel:

```bash
rpm -qil package
rpm -qf /path/to/file
```

| Option           | Beschreibung                                                                                                            |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `-a`             | Listet alle auf dem System installierten Pakete auf.                                                                    |
| `-i __package__` | Zeigt die Paketinformation an.                                                                                          |
| `-l __package__` | Listet die im Paket enthaltenen Dateien auf.                                                                            |
| `-f`             | Zeigt den Namen des Pakets, das die angegebene Datei enthält.                                                           |
| `--last`         | Die Liste der Pakete wird nach dem Installationsdatum sortiert (die letzten installierten Pakete erscheinen als Erste). |

!!! warning "Warnung"

    Nach der `-q` Option muss der Paketname genau sein. Platzhalter (wildcards) werden nicht unterstützt.

!!! tip "Hinweis"

    Es ist jedoch möglich, alle installierten Pakete aufzulisten und mit dem Befehl `grep` zu filtern.

Beispiel, Liste der zuletzt installierten Pakete:

```bash
sudo rpm -qa --last | head
NetworkManager-config-server-1.26.0-13.el8.noarch Mon 24 May 2021 02:34:00 PM CEST
iwl2030-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl2000-firmware-18.168.6.1-101.el8.1.noarch  Mon 24 May 2021 02:34:00 PM CEST
iwl135-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl105-firmware-18.168.6.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
iwl100-firmware-39.31.5.1-101.el8.1.noarch    Mon 24 May 2021 02:34:00 PM CEST
iwl1000-firmware-39.31.5.1-101.el8.1.noarch   Mon 24 May 2021 02:34:00 PM CEST
alsa-sof-firmware-1.5-2.el8.noarch            Mon 24 May 2021 02:34:00 PM CEST
iwl7260-firmware-25.30.13.0-101.el8.1.noarch  Mon 24 May 2021 02:33:59 PM CEST
iwl6050-firmware-41.28.5.1-101.el8.1.noarch   Mon 24 May 2021 02:33:59 PM CEST
```

Beispiel, listet den Installationsverlauf des Kernels auf:

```bash
sudo rpm -qa --last kernel
kernel-4.18.0-305.el8.x86_64                  Tue 25 May 2021 06:04:56 AM CEST
kernel-4.18.0-240.22.1.el8.x86_64             Mon 24 May 2021 02:33:35 PM CEST
```

Beispiel, Liste aller installierten Pakete mit einem bestimmten Namen mit `grep`:

```bash
sudo dnf list installed | grep httpd
centos-logos-httpd.noarch           80.5-2.el8                              @baseos
httpd.x86_64                        2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
httpd-filesystem.noarch             2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
httpd-tools.x86_64                  2.4.37-30.module_el8.3.0+561+97fdbbcc   @appstream
```

## DNF: Dandified Yum

**DNF** (**Dandified Yum**) ist ein Software-Paketmanager, Nachfolger von **YUM** (**Y**ellow dog **U**pdater **M**odified). Es funktioniert mit **RPM**-Paketen, die in einem lokalen oder entfernten Repository gruppiert sind (ein Verzeichnis zum Speichern von Paketen). Bei den gängigsten Befehlen ist die Verwendung identisch mit der von `yum`.

Der `dnf` Befehl ermöglicht die Verwaltung von Paketen, indem er die installierten Pakete mit denen in den auf dem Server definierten Repositories vergleicht. Er installiert auch automatisch Abhängigkeiten wenn sie auch in den Repositories vorhanden sind.

`dnf` ist der Paketmanager, der von vielen RedHat-basierten Distributionen verwendet wird (Rocky Linux, Fedora, CentOS, ...). Das Pendant in der Debian-Welt ist **APT** (**A**dvanced **P**ackaging **T**ool).

### `dnf` Befehl

Mit dem `dnf` Befehl können Sie ein Paket installieren, indem Sie nur die Kurzbezeichnung angeben.

```bash
dnf [install][remove][list all][search][info] package
```

Beispiel:

```bash
dnf install tree
```

Es wird nur der Kurzname des Pakets benötigt.

| Option                    | Beschreibung                                                                                      |
| ------------------------- | ------------------------------------------------------------------------------------------------- |
| `install`                 | Installiert das Paket.                                                                            |
| `remove`                  | Das Paket deinstallieren.                                                                         |
| `list all`                | Listet die Pakete auf, die bereits im Repository sind.                                            |
| `search`                  | Suche nach einem Paket im Repository.                                                             |
| `provides */command_name` | Suche nach einem Befehl.                                                                          |
| `info`                    | Zeigt die Paketinformation an.                                                                    |
| `autoremove`              | Entfernt alle Pakete, die als Abhängigkeiten installiert wurden, aber nicht mehr benötigt werden. |

Mit dem `dnf install` Befehl können Sie das gewünschte Paket installieren, ohne sich um seine Abhängigkeiten zu kümmern, die direkt durch `dnf` selbst gelöst werden.

```bash
dnf install nginx
Last metadata expiration check: 3:13:41 ago on Wed 23 Mar 2022 07:19:24 AM CET.
Dependencies resolved.
============================================================================================================================
 Package                             Architecture    Version                                        Repository         Size
============================================================================================================================
Installing:
 nginx                               aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream         543 k
Installing dependencies:
 nginx-all-modules                   noarch          1:1.14.1-9.module+el8.4.0+542+81547229         appstream          22 k
 nginx-mod-http-image-filter         aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          33 k
 nginx-mod-http-perl                 aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          44 k
 nginx-mod-http-xslt-filter          aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          32 k
 nginx-mod-mail                      aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          60 k
 nginx-mod-stream                    aarch64         1:1.14.1-9.module+el8.4.0+542+81547229         appstream          82 k

Transaction Summary
============================================================================================================================
Install  7 Packages

Total download size: 816 k
Installed size: 2.2 M
Is this ok [y/N]:
```

Falls Sie sich nicht an den genauen Namen des Pakets erinnern, können Sie ihn mit dem Befehl `dnf search name` suchen. Wie Sie sehen können, gibt es einen Abschnitt, der den genauen Namen und einen anderen, der die Paketkorrespondenz enthält. Alle werden hervorgehoben, um die Suche zu vereinfachen.

```bash
dnf search nginx
Last metadata expiration check: 0:20:55 ago on Wed 23 Mar 2022 10:40:43 AM CET.
=============================================== Name Exactly Matched: nginx ================================================
nginx.aarch64 : A high performance web server and reverse proxy server
============================================== Name & Summary Matched: nginx ===============================================
collectd-nginx.aarch64 : Nginx plugin for collectd
munin-nginx.noarch : NGINX support for Munin resource monitoring
nginx-all-modules.noarch : A meta package that installs all available Nginx modules
nginx-filesystem.noarch : The basic directory layout for the Nginx server
nginx-mod-http-image-filter.aarch64 : Nginx HTTP image filter module
nginx-mod-http-perl.aarch64 : Nginx HTTP perl module
nginx-mod-http-xslt-filter.aarch64 : Nginx XSLT module
nginx-mod-mail.aarch64 : Nginx mail modules
nginx-mod-stream.aarch64 : Nginx stream modules
pagure-web-nginx.noarch : Nginx configuration for Pagure
pcp-pmda-nginx.aarch64 : Performance Co-Pilot (PCP) metrics for the Nginx Webserver
python3-certbot-nginx.noarch : The nginx plugin for certbot
```

Eine andere Möglichkeit, nach einem Paket zu suchen, indem Sie einen zusätzlichen Suchschlüssel eingeben, ist, das Ergebnis des `dnf` Befehls über eine Pipe an den grep-Befehl mit dem gewünschten Schlüssel zu senden.

```bash
dnf search nginx | grep mod
Last metadata expiration check: 3:44:49 ago on Wed 23 Mar 2022 06:16:47 PM CET.
nginx-all-modules.noarch : A meta package that installs all available Nginx modules
nginx-mod-http-image-filter.aarch64 : Nginx HTTP image filter module
nginx-mod-http-perl.aarch64 : Nginx HTTP perl module
nginx-mod-http-xslt-filter.aarch64 : Nginx XSLT module
nginx-mod-mail.aarch64 : Nginx mail modules
nginx-mod-stream.aarch64 : Nginx stream modules
```

Der `dnf remove` Befehl entfernt ein Paket vom System und seine Abhängigkeiten. Unten ist ein Auszug des **dnf remove httpd** Befehls.

```bash
dnf remove httpd
Dependencies resolved.
============================================================================================================================
 Package                        Architecture    Version                                            Repository          Size
============================================================================================================================
Removing:
 httpd                          aarch64         2.4.37-43.module+el8.5.0+727+743c5577.1            @appstream         8.9 M
Removing dependent packages:
 mod_ssl                        aarch64         1:2.4.37-43.module+el8.5.0+727+743c5577.1          @appstream         274 k
 php                            aarch64         7.4.19-1.module+el8.5.0+696+61e7c9ba               @appstream         4.4 M
 python3-certbot-apache         noarch          1.22.0-1.el8                                       @epel              539 k
Removing unused dependencies:
 apr                            aarch64         1.6.3-12.el8                                       @appstream         299 k
 apr-util                       aarch64         1.6.1-6.el8.1                                      @appstream         224 k
 apr-util-bdb                   aarch64         1.6.1-6.el8.1                                      @appstream          67 k
 apr-util-openssl               aarch64         1.6.1-6.el8.1                                      @appstream          68 k
 augeas-libs                    aarch64         1.12.0-6.el8                                       @baseos            1.4 M
 httpd-filesystem               noarch          2.4.37-43.module+el8.5.0+727+743c5577.1            @appstream         400
 httpd-tools                    aarch64         2.4.37-43.module+el8.5.0+727+743c5577.1
...
```

Der `dnf list` Befehl listet alle Pakete auf, die auf dem System installiert sind und im Repository vorhanden sind. Es akzeptiert mehrere Parameter:

| Parameter   | Beschreibung                                                                                              |
| ----------- | --------------------------------------------------------------------------------------------------------- |
| `all`       | Listet die installierten und die in den Repositories verfügbaren Pakete auf.                              |
| `available` | Listet nur die für die Installation verfügbaren Pakete auf.                                               |
| `updates`   | Listet Pakete auf, die aktualisiert werden können.                                                        |
| `obsoletes` | Listet die Pakete auf, die durch die Umstellung auf höheren verfügbaren Versionen, obsolet geworden sind. |
| `recent`    | Listet die neuesten Pakete auf, die dem Repository zuletzt hinzugefügt wurden.                            |

Der `dnf info` Befehl liefert detaillierte Informationen zu einem Paket:

```bash
dnf info firewalld
Last metadata expiration check: 15:47:27 ago on Tue 22 Mar 2022 05:49:42 PM CET.
Installed Packages
Name         : firewalld
Version      : 0.9.3
Release      : 7.el8
Architecture : noarch
Size         : 2.0 M
Source       : firewalld-0.9.3-7.el8.src.rpm
Repository   : @System
From repo    : baseos
Summary      : A firewall daemon with D-Bus interface providing a dynamic firewall
URL          : http://www.firewalld.org
License      : GPLv2+
Description  : firewalld is a firewall service daemon that provides a dynamic customizable
             : firewall with a D-Bus interface.

Available Packages
Name         : firewalld
Version      : 0.9.3
Release      : 7.el8_5.1
Architecture : noarch
Size         : 501 k
Source       : firewalld-0.9.3-7.el8_5.1.src.rpm
Repository   : baseos
Summary      : A firewall daemon with D-Bus interface providing a dynamic firewall
URL          : http://www.firewalld.org
License      : GPLv2+
Description  : firewalld is a firewall service daemon that provides a dynamic customizable
             : firewall with a D-Bus interface.
```

Manchmal kennen Sie nur die ausführbare Datei, die Sie verwenden möchten, nicht jedoch das Paket, das sie enthält. In diesem Fall können Sie den Befehl `dnf provide Paketname` verwenden, der die Datenbank nach der gewünschten Übereinstimmung durchsucht.

Beispiel für die Suche nach dem `semanage` Kommando:

```bash
dnf provides */semanage
Last metadata expiration check: 1:12:29 ago on Wed 23 Mar 2022 10:40:43 AM CET.
libsemanage-devel-2.9-6.el8.aarch64 : Header files and libraries used to build policy manipulation tools
Repo        : powertools
Matched from:
Filename    : /usr/include/semanage

policycoreutils-python-utils-2.9-16.el8.noarch : SELinux policy core python utilities
Repo        : baseos
Matched from:
Filename    : /usr/sbin/semanage
Filename    : /usr/share/bash-completion/completions/semanage
```

Das Kommando `dnf autoremove` benötigt keine Parameter. Dnf kümmert sich um die Suche nach Paketen als Kandidaten zur Entfernung.

```bash
dnf autoremove
Last metadata expiration check: 0:24:40 ago on Wed 23 Mar 2022 06:16:47 PM CET.
Dependencies resolved.
Nothing to do.
Complete!
```

### Andere nützliche `dnf` Optionen

| Option      | Beschreibung                                               |
| ----------- | ---------------------------------------------------------- |
| `repolist`  | Listet die auf dem System konfigurierten Repositories auf. |
| `grouplist` | Listet verfügbare Paket-Sammlungen auf.                    |
| `reinigen`  | Entfernt temporäre Dateien.                                |

Der `dnf repolist` Befehl listet die auf dem System konfigurierten Repositories auf. Standardmäßig listet er nur die aktivierten Repositorys auf, kann aber mit folgenden Parametern verwendet werden:

| Parameter    | Beschreibung                              |
| ------------ | ----------------------------------------- |
| `--all`      | Listet alle Repositories auf.             |
| `--enabled`  | Default                                   |
| `--disabled` | Listet nur deaktivierte Repositories auf. |

Beispiel:

```bash
dnf repolist
repo id                                                  repo name
appstream                                                Rocky Linux 8 - AppStream
baseos                                                   Rocky Linux 8 - BaseOS
epel                                                     Extra Packages for Enterprise Linux 8 - aarch64
epel-modular                                             Extra Packages for Enterprise Linux Modular 8 - aarch64
extras                                                   Rocky Linux 8 - Extras
powertools                                               Rocky Linux 8 - PowerTools
rockyrpi                                                 Rocky Linux 8 - Rasperry Pi
```

Und ein Auszug des Befehls mit dem `--all` Flag.

```bash
dnf repolist --all

...
repo id                                             repo name                                                                                       status
appstream                                           Rocky Linux 8 - AppStream                                                                       enabled
appstream-debug                                     Rocky Linux 8 - AppStream - Source                                                              disabled
appstream-source                                    Rocky Linux 8 - AppStream - Source                                                              disabled
baseos                                              Rocky Linux 8 - BaseOS                                                                          enabled
baseos-debug                                        Rocky Linux 8 - BaseOS - Source                                                                 disabled
baseos-source                                       Rocky Linux 8 - BaseOS - Source                                                                 disabled
devel                                               Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE                                       disabled
epel                                                Extra Packages for Enterprise Linux 8 - aarch64                                                 enabled
epel-debuginfo                                      Extra Packages for Enterprise Linux 8 - aarch64 - Debug                                         disabled
epel-modular                                        Extra Packages for Enterprise Linux Modular 8 - aarch64                                         enabled
epel-modular-debuginfo                              Extra Packages for Enterprise Linux Modular 8 - aarch64 - Debug                                 disabled
epel-modular-source                                 Extra Packages for Enterprise Linux Modular 8 - aarch64 - Source
...
```

Unten ist ein Auszug aus der Liste der deaktivierten Repositorys.

```bash
dnf repolist --disabled
repo id                                 repo name
appstream-debug                         Rocky Linux 8 - AppStream - Source
appstream-source                        Rocky Linux 8 - AppStream - Source
baseos-debug                            Rocky Linux 8 - BaseOS - Source
baseos-source                           Rocky Linux 8 - BaseOS - Source
devel                                   Rocky Linux 8 - Devel WARNING! FOR BUILDROOT AND KOJI USE
epel-debuginfo                          Extra Packages for Enterprise Linux 8 - aarch64 - Debug
epel-modular-debuginfo                  Extra Packages for Enterprise Linux Modular 8 - aarch64 - Debug
epel-modular-source                     Extra Packages for Enterprise Linux Modular 8 - aarch64 - Source
epel-source                             Extra Packages for Enterprise Linux 8 - aarch64 - Source
epel-testing                            Extra Packages for Enterprise Linux 8 - Testing - aarch64
...
```

Mit der Option `-v` wird die Liste um viele zusätzliche Informationen ergänzt. Unten sehen Sie einen Teil des Ergebnisses des Befehls.

```bash
dnf repolist -v

...
Repo-id            : powertools
Repo-name          : Rocky Linux 8 - PowerTools
Repo-revision      : 8.5
Repo-distro-tags      : [cpe:/o:rocky:rocky:8]:  ,  , 8, L, R, c, i, k, n, o, u, x, y
Repo-updated       : Wed 16 Mar 2022 10:07:49 PM CET
Repo-pkgs          : 1,650
Repo-available-pkgs: 1,107
Repo-size          : 6.4 G
Repo-mirrors       : https://mirrors.rockylinux.org/mirrorlist?arch=aarch64&repo=PowerTools-8
Repo-baseurl       : https://example.com/pub/rocky/8.8/PowerTools/x86_64/os/ (30 more)
Repo-expire        : 172,800 second(s) (last: Tue 22 Mar 2022 05:49:24 PM CET)
Repo-filename      : /etc/yum.repos.d/Rocky-PowerTools.repo
...
```

!!! info "Gruppen verwenden"

    Gruppen sind eine Sammlung von Paketen (Sie können sich sie als virtuelle Pakete vorstellen), die eine Reihe von logisch zusammenhängende Anwendungen gruppieren, um einen bestimten Zweck zu erfüllen (eine Desktop-Umgebung, ein Server, Entwicklungswerkzeuge, etc.).

Der `dnf grouplist` Befehl listet alle verfügbaren Gruppen auf.

```bash
dnf grouplist
Last metadata expiration check: 1:52:00 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Available Environment Groups:
   Server with GUI
   Server
   Minimal Install
   KDE Plasma Workspaces
   Custom Operating System
Available Groups:
   Container Management
   .NET Core Development
   RPM Development Tools
   Development Tools
   Headless Management
   Legacy UNIX Compatibility
   Network Servers
   Scientific Support
   Security Tools
   Smart Card Support
   System Tools
   Fedora Packager
   Xfce
```

Mit dem `dnf groupinstall` Befehl können Sie eine dieser Gruppen installieren.

```bash
dnf groupinstall "Network Servers"
Last metadata expiration check: 2:33:26 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Dependencies resolved.
================================================================================
 Package           Architecture     Version             Repository         Size
================================================================================
Installing Groups:
 Network Servers

Transaction Summary
================================================================================

Is this ok [y/N]:
```

Beachten Sie, dass es eine gute Praxis ist, den Gruppennamen in doppelte Anführungszeichen einzufügen, da ohne sie, den Befehl nur korrekt ausgeführt wird, wenn der Gruppenname keine Leerzeichen enthält.

Also erzeugt ein `dnf groupinstall Network Server` den folgenden Fehler:

```bash
dnf groupinstall Network Servers
Last metadata expiration check: 3:05:45 ago on Wed 23 Mar 2022 02:11:43 PM CET.
Module or Group 'Network' is not available.
Module or Group 'Servers' is not available.
Error: Nothing to do.
```

Der Befehl zum Entfernen einer Gruppe ist `dnf groupremove "name group"`.

Der `dnf clean` Befehl löscht alle Caches und temporären Dateien, die von `dnf` erstellt wurden. Er kann mit den folgenden Parametern verwendet werden.

| Parameter      | Beschreibung                                                                       |
| -------------- | ---------------------------------------------------------------------------------- |
| `all`          | Entfernt alle temporären Dateien, die für aktivierte Repositories erstellt wurden. |
| `dbcache`      | Entfernt Cache-Dateien für die Repository-Metadaten.                               |
| `expire-cache` | Entfernen der lokalen Cookie-Dateien.                                              |
| `metadata`     | Entfernt alle Repositories-Metadaten.                                              |
| `packages`     | Entfernt alle zwischengespeicherten Pakete.                                        |

### So funktioniert DNF

Der DNF-Manager setzt auf eine oder mehrere Konfigurationsdateien, um die Repositories mit den RPM-Paketen anzusprechen.

Diese Dateien befinden sich in `/etc/yum.repos.d/` und müssen mit `.repo` enden, um von DNS ausgewertet zu werden.

Beispiel:

```bash
/etc/yum.repos.d/Rocky-BaseOS.repo
```

Jede `.repo` Datei besteht aus mindestens den folgenden Informationen, einer Direktive pro Zeile.

Beispiel:

```bash
[baseos] # Short name of the repository
name=Rocky Linux $releasever - BaseOS # Short name of the repository #Detailed name
mirrorlist=http://mirrors.rockylinux.org/mirrorlist?arch=$basearch&repo=BaseOS-$releasever # http address of a list or mirror
#baseurl=http://dl.rockylinux.org/$contentdir/$releasever/BaseOS/$basearch/os/ # http address for direct access
gpgcheck=1 # Repository requiring a signature
enabled=1 # Activated =1, or not activated =0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial # GPG public key path
```

Standardmäßig ist die `enabled` Direktive nicht vorhanden, was bedeutet, dass das Repository aktiviert ist. Um ein Repository zu deaktivieren, müssen Sie die `enabled=0` Direktive angeben.

## DNF-Module

Module wurden in Rocky Linux 8 vom Upstream-System eingeführt. Um Module nutzen zu können, muss das AppStream-Repository existieren und aktiviert sein.

!!! hint "Package Confusion"

    Die Einführung von Modul-Streams im AppStream Repository verursachte viel Verwirrung. Da Module in einem Stream verpackt sind (siehe Beispiele unten), werden bestimmte Pakete in unseren RPMs auftauchen, aber wenn der Versuch gemacht wird, ein dieser Pakete ohne das Modul zu installieren, passiert nichts. Denken Sie daran, Module zu durchsuchen, wenn Sie versuchen, ein Paket zu installieren und es nicht gefunden wird.

### Was sind Module?

Module stammen aus dem AppStream Repository und enthalten sowohl Streams als auch Profile. Diese lassen sich wie folgt beschreiben:

* **Modul-Streams:** Ein Modul-Stream kann als separates Repository innerhalb des AppStream-Repository angesehen werden, das verschiedene Anwendungsversionen enthält. Diese Modul-Repositories enthalten die Anwendungs-RPMs, Abhängigkeiten und Dokumentation für diesen bestimmten Stream. Ein Beispiel für einen Modul-Stream in Rocky Linux 8 wäre `postgresql`. Wenn Sie `postgresql` mit dem Standard Befehl `sudo dnf install postgresql`, erhalten Sie die Version 10. Mit Hilfe von Modulen können Sie stattdessen die Versionen 9.6, 12 oder 13 installieren.

* **Modulprofile:** Was ein Modulprofil tut, ist den Anwendungsfall für den Modul-Stream bei der Installation des Pakets zu berücksichtigen. Das Anwenden eines Profils passt die Paket-RPMs, die Abhängigkeiten und dieDokumentation an die Verwendung des Moduls an. Mit dem gleichen `postgresql`-Stream in unserem Beispiel können Sie ein Profil von "Server" oder "Client" anwenden. Offensichtlich benötigen Sie nicht die gleichen Pakete, wenn Sie einfach `postgresql` als Client verwenden, um auf einen Server zuzugreifen.

### Übersicht der Module

Mit folgendem Befehl erhalten Sie eine Liste der verfügbaren Module:

```bash
dnf module list
```

Dadurch erhalten Sie eine lange Liste der Module und Profile, die Sie verwenden können. Wahrscheinlich wissen Sie schon, an welchem Paket Sie interessiert sind. Um herauszufinden, ob es Module für ein bestimmtes Paket gibt, fügen Sie bitte den Paketnamen nach "list" ein. Wir werden unser `postgresql`-Beispiel hier erneut verwenden:

```bash
dnf module list postgresql
```

Das Ergebnis sollte so aussehen:

```bash
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12                     client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Beachten Sie bitte das "[d]". Hiermit ist die Standardeinstellung gekennzeichnet. Es zeigt an, dass die Standardversion 10 ist und dass unabhängig davon für welche Version Sie sich entscheiden, wenn Sie kein Profil angeben, wird das Profil des Servers verwendet, da es auch die Standardeinstellung ist.

### Module aktivieren

Mit unserem Beispiel `postgresql` Paket wollen wir Version 12 aktivieren. Dazu verwenden Sie einfach Folgendes:

```bash
dnf module enable postgresql:12
```

Hier benötigt der Aktivierungsbefehl den Modulnamen gefolgt von einem ":" und dem Streamnamen.

Um zu überprüfen, ob das `postgresql`-Modul in der Stream-Version 12 aktiviert wurde, verwenden Sie erneut den Befehl „list“, der die folgende Ausgabe anzeigen sollte:

```bash
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12 [e]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Hier sehen Sie das „[e]“-Symbol für „aktiviert“ neben Stream 12. Wir wissen also, dass Version 12 aktiviert ist.

### Installatin der Pakete aus dem Modul-Stream

Jetzt, da unser Modul-Stream aktiviert ist, ist der nächste Schritt die Installation von `postgresql`, die Client-Anwendung für den Postgresql-Server. Dies kann erreicht werden, indem der folgende Befehl ausgeführt wird:

```bash
dnf install postgresql
```

Folgenges sollte dann ausgegeben werden:

```bash
========================================================================================================================================
 Package                    Architecture           Version                                              Repository                 Size
========================================================================================================================================
Installing group/module packages:
 postgresql                 x86_64                 12.12-1.module+el8.6.0+1049+f8fc4c36                 appstream                 1.5 M
Installing dependencies:
 libpq                      x86_64                 13.5-1.el8                                           appstream                 197 k

Transaction Summary
========================================================================================================================================
Install  2 Packages
Total download size: 1.7 M
Installed size: 6.1 M
Is this ok [y/N]:
```

Mit der Eingabe von "y" wird die Anwendung installiert.

### Pakete aus Modul-Stream-Profilen installieren

Sie können Pakete sogar direkt installieren, ohne das Modul-Streaming aktivieren zu müssen! In diesem Beispiel nehmen wir an, dass wir nur das Client-Profile aus Ihrer Installation anwenden. Um dies zu erreichen, verwenden wir folgendes Kommando:

```bash
dnf install postgresql:12/client
```

Die Ausgabe sollte wie folgt aussehen:

```bash
========================================================================================================================================
 Package                    Architecture           Version                                              Repository                 Size
========================================================================================================================================
Installing group/module packages:
 postgresql                 x86_64                 12.12-1.module+el8.6.0+1049+f8fc4c36                 appstream                 1.5 M
Installing dependencies:
 libpq                      x86_64                 13.5-1.el8                                           appstream                 197 k
Installing module profiles:
 postgresql/client
Enabling module streams:
 postgresql                                        12

Transaction Summary
========================================================================================================================================
Install  2 Packages

Total download size: 1.7 M
Installed size: 6.1 M
Is this ok [y/N]:
```

Durch die Angabe von "y" wird alles installiert, um postgresql Version 12 als Client zu verwenden.

### Modul entfernen und zurücksetzen oder die Version umschalten

Nach der Installation könnten Sie aus irgendeinem Grund entscheiden, dass Sie eine andere Version des Streams benötigen. Der erste Schritt ist das Entfernen der Pakete. Wenn wir unser Beispiel `postgresql` Paket erneut verwenden, würden wir dies tun mit folgendem Kommando:

```bash
dnf remove postgresql
```

Dies zeigt eine ähnliche Ausgabe wie die obige Installationsprozedur, es entfernt jedoch das Paket und alle seine Abhängigkeiten. Antworten Sie "y" auf die Eingabeaufforderung und drücken Sie Enter um `postgresql` zu deinstallieren.

Sobald dieser Schritt abgeschlossen ist, können Sie den Zurücksetzen-Befehl für das Modul anwenden:

```bash
dnf module reset postgresql
```

Das Ergebnis sollte so aussehen:

```bash
Dependencies resolved.
========================================================================================================================================
 Package                         Architecture                   Version                           Repository                       Size
========================================================================================================================================
Disabling module profiles:
 postgresql/client                                                                                                                     
Resetting modules:
 postgresql                                                                                                                            

Transaction Summary
========================================================================================================================================

Is this ok [y/N]:
```

Das Beantworten mit "y" auf die Eingabeaufforderung wird `postgresql` zurücksetzen und den von uns aktivierten Stream (12 in unserem Beispiel) deaktivieren:

```bash
Rocky Linux 8 - AppStream
Name                       Stream                 Profiles                           Summary                                            
postgresql                 9.6                    client, server [d]                 PostgreSQL server and client module                
postgresql                 10 [d]                 client, server [d]                 PostgreSQL server and client module                
postgresql                 12                     client, server [d]                 PostgreSQL server and client module                
postgresql                 13                     client, server [d]                 PostgreSQL server and client module
```

Jetzt können Sie die Default-Einstellung verwenden.

Sie können auch die "switch-to"-Anweisung verwenden, um von einem aktivierten Stream auf einen anderen zu wechseln. Mit dieser Methode wechseln Sie nicht nur zum neuen Stream, sondern installieren auch die erforderlichen Pakete (sowohl für Downgrade als auch Upgrade) ohne einen separaten Schritt. Um diese Methode zu verwenden, um `postgresql` Stream Version 13 zu aktivieren und das "Client"-Profil zu verwenden, würden Sie folgendes verwenden:

```bash
dnf module switch-to postgresql:13/client
```

### Modul-Stream deaktivieren

Es kann Fälle geben, in denen Sie die Möglichkeit deaktivieren möchten, Pakete von einem Modul-Stream zu installieren. Im Falle unseres `postgresql`-Beispiels könnte das daran liegen, dass Sie das Projektarchiv direkt von [PostgreSQL](https://www.postgresql.org/download/linux/redhat/) verwenden wollen, so dass Sie eine neuere Version verwenden können (zum Zeitpunkt dieses Schreibens, Versionen 14 und 15 sind in diesem Repository verfügbar). Das Deaktivieren eines Modul-Streams macht die Installation eines dieser Pakete unmöglich, ohne sie vorher wieder zu aktivieren.

Um die Modul-Streams für `postgresql` zu deaktivieren, genügt es wie folgt vorzugehen:

```bash
dnf module disable postgresql
```

Und wenn Sie die `postgresql` Module erneut auflisten, sehen Sie folgendes, wobei alle `postgresql` Modul-Versionen deaktiviert sind:

```bash
Rocky Linux 8 - AppStream
Name                       Stream                   Profiles                          Summary                                           
postgresql                 9.6 [x]                  client, server [d]                PostgreSQL server and client module               
postgresql                 10 [d][x]                client, server [d]                PostgreSQL server and client module               
postgresql                 12 [x]                   client, server [d]                PostgreSQL server and client module               
postgresql                 13 [x]                   client, server [d]                PostgreSQL server and client module
```

## Das EPEL-Repository

### Was ist EPEL und wie wird das verwendet?

**EPEL** (**E**xtra **P**Pakete für **E**nterprise **L**inux) ist ein Open-Source und kostenloses Community-basiertes Repository, das von der [EPEL Fedora Special Interest Group](https://docs.fedoraproject.org/en-US/epel/) betreut wird, das eine Reihe zusätzlicher Pakete für RHEL (sowie CentOS, Rocky Linux und andere) aus den Fedora-Quellen anbietet.

Es enthält Pakete, die nicht in den offiziellen RHEL-Repositories enthalten sind. Diese werden nicht einbezogen, weil sie in einem Unternehmensumfeld nicht als notwendig erachtet werden oder nur außerhalb des RHEL-Bereichs als notwendig erachtet werden. Wir dürfen nicht vergessen, dass RHEL eine Unternehmens-Distribution ist und Desktop-Utilities oder andere spezialisierte Software können ggf. keine Priorität für ein Unternehmensprojekt sein.

### Installation

Die Installation der notwendigen Dateien kann leicht mit dem Paket durchgeführt werden, das standardmäßig von Rocky Linux zur Verfügung gestellt wird.

Wenn Sie hinter einem Internet-Proxy stehen:

```bash
export http_proxy=http://172.16.1.10:8080
```

Dann:

```bash
dnf install epel-release
```

Nach der Installation, können Sie mit dem Befehl `dnf info` überprüfen, ob das Paket korrekt installiert wurde.

```bash
dnf info epel-release
Last metadata expiration check: 1:30:29 ago on Thu 24 Mar 2022 09:36:42 AM CET.
Installed Packages
Name         : epel-release
Version      : 8
Release      : 14.el8
Architecture : noarch
Size         : 32 k
Source       : epel-release-8-14.el8.src.rpm
Repository   : @System
From repo    : epel
Summary      : Extra Packages for Enterprise Linux repository configuration
URL          : http://download.fedoraproject.org/pub/epel
License      : GPLv2
Description  : This package contains the Extra Packages for Enterprise Linux
             : (EPEL) repository GPG key as well as configuration for yum.
```

Das Paket enthält keine ausführbaren Programme, Bibliotheken usw., aber nur die Konfigurationsdateien und GPG-Schlüssel zum Einrichten des Repository.

Eine weitere Möglichkeit, die Installation zu überprüfen, ist die Abfrage der rpm-Datenbank.

```bash
rpm -qa | grep epel
epel-release-8-14.el8.noarch
```

Nun müssen Sie ein Update ausführen um `dnf` das Projektarchiv erkennen zu lassen. Sie werden aufgefordert, die GPG-Schlüssel der Repositories zu akzeptieren. Natürlich müssen Sie "yes" antworten, um sie zu nutzen.

```bash
dnf update
```

Sobald die Aktualisierung abgeschlossen ist, können Sie überprüfen, ob das Projektarchiv korrekt mit dem `dnf repolist` Befehl konfiguriert wurde, der nun die neuen Repositories auflisten sollte.

```bash
dnf repolist
repo id            repo name
...
epel               Extra Packages for Enterprise Linux 8 - aarch64
epel-modular       Extra Packages for Enterprise Linux Modular 8 - aarch64
...
```

Die Konfigurationsdateien des Projektarchivs befinden sich in `/etc/yum.repos.d/`.

```bash
ll /etc/yum.repos.d/ | grep epel
-rw-r--r--. 1 root root 1485 Jan 31 17:19 epel-modular.repo
-rw-r--r--. 1 root root 1422 Jan 31 17:19 epel.repo
-rw-r--r--. 1 root root 1584 Jan 31 17:19 epel-testing-modular.repo
-rw-r--r--. 1 root root 1521 Jan 31 17:19 epel-testing.repo
```

Unten können wir den Inhalt der Datei `epel.repo` sehen.

```bash
[epel]
name=Extra Packages for Enterprise Linux $releasever - $basearch
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8

[epel-debuginfo]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Debug
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place its address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/$basearch/debug
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-debug-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
gpgcheck=1

[epel-source]
name=Extra Packages for Enterprise Linux $releasever - $basearch - Source
# It is much more secure to use the metalink, but if you wish to use a local mirror
# place it's address here.
#baseurl=https://download.example/pub/epel/$releasever/Everything/source/tree/
metalink=https://mirrors.fedoraproject.org/metalink?repo=epel-source-$releasever&arch=$basearch&infra=$infra&content=$contentdir
enabled=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
gpgcheck=1
```

### EPEL verwenden

An dieser Stelle sind wir bereit, die Pakete von EPEL zu installieren. Um zu starten, können wir die im Projektarchiv verfügbaren Pakete mit folgendem Befehl auflisten:

```bash
dnf --disablerepo="*" --enablerepo="epel" list available
```

Und ein Auszug des Kommandos

```bash
dnf --disablerepo="*" --enablerepo="epel" list available | less
Last metadata expiration check: 1:58:22 ago on Fri 25 Mar 2022 09:23:29 AM CET.
Available Packages
3proxy.aarch64                                                    0.8.13-1.el8                                    epel
AMF-devel.noarch                                                  1.4.23-2.el8                                    epel
AMF-samples.noarch                                                1.4.23-2.el8                                    epel
AusweisApp2.aarch64                                               1.22.3-1.el8                                    epel
AusweisApp2-data.noarch                                           1.22.3-1.el8                                    epel
AusweisApp2-doc.noarch                                            1.22.3-1.el8                                    epel
BackupPC.aarch64                                                  4.4.0-1.el8                                     epel
BackupPC-XS.aarch64                                               0.62-1.el8                                      epel
BibTool.aarch64                                                   2.68-1.el8                                      epel
CCfits.aarch64                                                    2.5-14.el8                                      epel
CCfits-devel.aarch64                                              2.5-14.el8                                      epel
...
```

Aus dem Befehl können wir sehen, dass wir **dnf** zwingen müssen, das angeforderte Projektarchiv mit den Optionen `--disablerepo` und `--enablerepo` abzufragen Dies liegt daran, dass sonst ein Match in anderen optionalen Repositories gefunden wird (RPM Fusion, REMI, ELRepo, etc.). neuer sein können und daher Priorität haben. Diese Optionen sind nicht erforderlich, wenn Sie EPEL nur als optionales Projektarchiv installiert haben, da die Pakete im Projektarchiv niemals im offiziellen Verzeichnis verfügbar sein werden. Zumindest in der gleichen Version!

!!! attention "Support-Überlegung"

    Ein Aspekt, der in Bezug auf die Unterstützung berücksichtigt werden muss (Updates, Bugfixes,...) ist, dass EPEL-Pakete keine offizielle Unterstützung von RHEL haben und technisch könnte ihr Leben den Zeitraum einer Entwicklung von Fedora (sechs Monate) überdauern und dann verschwinden. Dies ist eine entfernte Möglichkeit, aber eine Möglichkeit, die man in Betracht ziehen sollte.

Um also ein Paket aus den EPEL-Repositories zu installieren, können Sie wie folgt vorgehen:

```bash
dnf --disablerepo="*" --enablerepo="epel" install nmon
Last metadata expiration check: 2:01:36 ago on Fri 25 Mar 2022 04:28:04 PM CET.
Dependencies resolved.
==============================================================================================================================================================
 Package                            Architecture                          Version                                    Repository                          Size
==============================================================================================================================================================
Installing:
 nmon                               aarch64                               16m-1.el8                                  epel                                71 k

Transaction Summary
==============================================================================================================================================================
Install  1 Package

Total download size: 71 k
Installed size: 214 k
Is this ok [y/N]:
```

### Conclusion

EPEL ist kein offizielles Repository für RHEL, aber es kann nützlich für Administratoren und Entwickler sein, die mit RHEL oder Derivaten arbeiten und einige Hilfsprogramme benötigen, die für RHEL aus einer vertrauenswürdigen Quelle erstellt wurden.

## DNF-Plugins

Das `dnf-plugins-core` Paket fügt Plugins zu `dnf` hinzu, die für die Verwaltung Ihrer Repositories nützlich sind.

!!! note "Hinweis"

    Mehr Informationen sind hier verfügbar:
    https://dnf-plugins-core.readthedocs.io/de/latest/index.html

Das Paket auf Ihrem System installieren:

```bash
dnf install dnf-plugins-core
```

Nicht alle Plugins werden hier vorgestellt, aber Sie können in der Paketdokumentation eine komplette Liste der Plugins und ausführliche Informationen finden.

### `config-manager` Plugin

DNF-Optionen verwalten, Repos hinzufügen oder deaktivieren.

Beispiele:

* `.repo` Datei herunterladen und verwenden:

```bash
dnf config-manager --add-repo https://packages.centreon.com/ui/native/rpm-standard/23.04/el8/centreon-23.04.repo
```

* Sie können auch eine URL als Basis-URL für ein Repo festlegen:

```bash
dnf config-manager --add-repo https://repo.rocky.lan/repo
```

* Aktivieren oder deaktivieren eines oder mehrerer Repos:

```bash
dnf config-manager --set-enabled epel centreon
dnf config-manager --set-disabled epel centreon
```

* Fügen Sie einen Proxy zu Ihrer Konfigurationsdatei hinzu:

```bash
dnf config-manager --save --setopt=*.proxy=http://proxy.rocky.lan:3128/
```

### Plugin `copr`

`copr` ist eine automatische Forge, die ein Repo mit gebauten Paketen liefert.

* Copr Repo aktivieren:

```bash
copr enable xxxx
```

### `Plugin` herunterladen

rpm-Paket herunterladen, anstatt es zu installieren:

```bash
dnf download ansible
```

Wenn Sie nur die URL des Remote-Standorts des Pakets erhalten möchten:

```bash
dnf download --url ansible
```

Oder wenn Sie auch die Abhängigkeiten herunterladen möchten:

```bash
dnf download --resolv --alldeps ansible
```

### `needs-restarting` Plugin

Nach dem Ausführen eines `dnf update`werden die laufenden Prozesse weiterhin laufen, aber mit den alten Binärdateien. Um die Änderungen des Codes und insbesondere die Sicherheitsaktualisierungen zu berücksichtigen, müssen sie neu gestartet werden.

Das `needs-restarting` Plugin ermöglicht Ihnen Prozesse, die neu zu starten sind, zu erkennen.

```bash
dnf needs-restarting [-u] [-r] [-s]
```

| Option  | Beschreibung                                                          |
| ------- | --------------------------------------------------------------------- |
| `-u`    | nur die Prozesse berücksichtigen, die zum laufenden Benutzer gehören. |
| `-r`    | um zu überprüfen, ob ein Neustart erforderlich sein könnte.           |
| `-s`    | um zu überprüfen, ob Dienste neu gestartet werden müssen.             |
| `-s -r` | um beides in einem Lauf zu tun.                                       |

### `versionlock` Plugin

Manchmal ist es nützlich, Pakete vor Aktualisierungen zu schützen oder bestimmte Versionen eines Pakets auszuschließen (zum Beispiel wegen bekannter Probleme). Zu diesem Zweck wird das versionlock-Plugin eine große Hilfe sein.

Dazu müssen Sie ein zusätzliches Paket installieren:

```bash
dnf install python3-dnf-plugin-versionlock
```

Beispiele:

* Die ansible Version sperren:

```bash
dnf versionlock add ansible
Adding versionlock on: ansible-0:6.3.0-2.el9.*
```

* Gesperrte Pakete auflisten:

```bash
dnf versionlock list
ansible-0:6.3.0-2.el9.*
```
