---
title: Ansible Grundlagen
author: Antoine Le Morvan
contributors: Steven Spencer, tianci li, Aditya Putta, Ganna Zhyrnova
update: 2021-12-15
---

# Ansible Grundlagen

In diesem Kapitel werden Sie lernen, wie Sie mit Ansible arbeiten.

****

**Ziele**: In diesem Kapitel wird Folgendes behandelt:

:heavy_check_mark: Ansible-Implementierung;  
:heavy_check_mark: Konfigurationsänderungen auf einem Server anwenden;  
:heavy_check_mark: erste Ansible-Playbooks entwerfen;

:checkered_flag: **ansible**, **module**, **playbook** .

**Vorkenntnisse**: :star: :star: :star:  
**Schwierigkeitsgrad**: :star: :star:

**Lesezeit**: 31 Minuten

****

Ansible zentralisiert und automatisiert Verwaltungsaufgaben. Ansible ist:

* **agentenlos** (es erfordert keine spezielle Installation auf Clients),
* **idempotent** (das Ergebnis ist bei jedem Lauf identisch).

Es verwendet das **SSH**-Protokoll, um GNU/Linux-Clients zu konfigurieren oder das **WinRM**-Protokoll für Windows-Clients. Wenn keines dieser Protokolle verfügbar ist, ist es für Ansible immer möglich, eine API zu verwenden, das Ansible zu einem echten Schweizermesser für die Konfiguration von Servern, Workstations, Docker-Diensten, Netzwerkgeräten usw. macht (praktisch fast alles).

!!! warning "Warnhinweis"

    Das Öffnen von SSH oder WinRM Kanälen zu allen Clients des Ansible Servers macht es zu einem kritischen Element der Architektur, das sorgfältig überwacht werden muss.

Da Ansible push-basiert ist, wird die Software den Status seiner Zielserver nach jeder seiner Ausführung nicht zwischenspeichern. Im Gegenteil, Ansible wird bei jeder Ausführung eine neue Statusprüfung durchführen. Es wird als zustandslos bezeichnet.

Es wird Ihnen bei folgenden Aufgaben helfen:

* Provisionierung (Bereitstellung einer neuen VM),
* Verteilung von Applikationen,
* Konfigurationsverwaltung,
* Automatisierung,
* Orchestrierung (wenn mehr als ein Ziel verwendet wird).

!!! note "Anmerkung"

    Ansible wurde ursprünglich von Michael DeHaan, dem Erfinder anderer Tools wie Cobbler, geschrieben.
    
    ![Michael DeHaan](images/Michael_DeHaan01.jpg)
    
    Die früheste erste Version war 0.0.1, veröffentlicht am 9. März 2012.
    
    Am 17. Oktober 2015 wurde AnsibleWorks (das Unternehmen hinter Ansible) von Red Hat für 150 Millionen Dollar übernommen.

![Die Features von Ansible](images/ansible-001.png)

Um eine grafische Oberfläche für Ihre tägliche Arbeit mit Ansible bereitzustellen, können Sie einige Tools wie Ansible Tower (Red Hat) installieren, das nicht kostenlos ist, oder sein Open-Source-Gegenstück Awx, oder es können auch andere Projekte wie Jenkins und das hervorragende Rundeck verwendet werden.

!!! abstract "Abstrakt"

    Um diesem Training zu folgen, benötigst du mindestens 2 Server unter Rocky 8:

    * die erste wird die **Management Maschine** sein, auf der Ansible installiert wird.
    * die zweite wird der Server, der zu konfigurieren und zu verwalten ist (ein weiteres Linux als Rocky Linux wird es genauso tun).

    In den folgenden Beispielen hat die Administrations-Station die IP-Adresse 172.16.1.10, die Managed-Station 172.16.1.11. Es liegt an Ihnen, die Beispiele entsprechend Ihrem IP-Adressierungs-Schema anzupassen.

## Das Ansible Vokabular

* Die **Verwaltungsmaschine**: die Maschine, auf der Ansible installiert ist. Da Ansible **agentenlos** ist, wird auf den verwalteten Servern keine Software verteilt.
* **verwaltete Knoten**: Die Zielgeräte, die Ansible verwaltet, werden auch „hosts“ genannt. Dabei kann es sich um Server, Netzwerkgeräte oder beliebige andere Computer handeln.
* Das **Inventar**: eine Datei mit Informationen zu verwalteten Servern.
* **Aufgaben**: Eine Aufgabe ist ein Block, der eine auszuführende Prozedur definiert (z. B. einen Benutzer oder eine Gruppe erstellen, ein Softwarepaket installieren usw.).
* Ein **Modul**: ein Modul abstrahiert eine Aufgabe. Viele Module werden zusammen mit Ansible zur Verfügung gestellt.
* Die **Playbooks**: einfache Dateien im Yaml-Format, die die Zielserver und die auszuführenden Aufgaben definieren.
* Eine **Rolle**: Eine Rolle ermöglicht es Ihnen, die Playbooks und alle anderen erforderlichen Dateien (Vorlagen, Skripte usw.) zu organisieren, um die Wiederverwendung von Code zu erleichtern.
* Eine **Kollektion**: Eine Kollektion umfasst einen logischen Satz von Playbooks, Rollen, Modulen und Plugins.
* Die **Fakten**: Hierbei handelt es sich um globale Variablen, die Informationen über das System enthalten (Maschinenname, Systemversion, Netzwerkschnittstelle und Konfiguration, usw.).
* **Handler**: werden verwendet, um zu veranlassen, dass ein Dienst angehalten oder neu gestartet wird, wenn er sich ändert.

## Installation auf dem Management-Server

Ansible ist im _EPEL_-Repository verfügbar, aber manchmal ist es für die aktuelle Version veraltet und Sie möchten mit einer neueren Version arbeiten.

Wir betrachten daher zwei Installationsarten:

* EPEL-Intallation basierend auf EPEL-Repositories
* eine basierend auf dem Python-Paketmanager `pip`

Das _EPEL_ ist für beide Versionen erforderlich, Sie können es also jetzt installieren:

* EPEL-Installation:

```bash
sudo dnf install epel-release
```

### Installation über EPEL

Um Ansible über _EPEL_ zu installieren, können wir Folgendes tun:

```bash
sudo dnf install ansible
```

Und dann sollten wir die Installation überprüfen:

```bash
$ ansible --version
ansible [core 2.14.2]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/rocky/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.11/site-packages/ansible  ansible collection location = /home/rocky/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.11.2 (main, Jun 22 2023, 04:35:24) [GCC 8.5.0 20210514 
(Red Hat 8.5.0-18)] (/usr/bin/python3.11)
  jinja version = 3.1.2
  libyaml = True

$ python3 --version
Python 3.6.8
```

Beachten Sie, dass Ansible mit einer eigenen Python-Version geliefert wird, die sich von der Systemversion (hier 3.11.2 gegenüber 3.6.8) unterscheidet. Sie müssen dies berücksichtigen, wenn Sie die für Ihre Installation erforderlichen Python-Module per PIP installieren (z.B., `pip3.11 install PyVMomi`).

### Installation über python pip

Da wir eine neuere Version von Ansible verwenden möchten, installieren wir diese von `python3-pip`:

!!! note "Hinweis"

    Entfernen Sie Ansible, wenn es zuvor von _EPEL_ installiert wurde.

In dieser Phase können wir Ansible mit der gewünschten Python-Version installieren.

```bash
sudo dnf install python38 python38-pip python38-wheel python3-argcomplete rust cargo curl
```

!!! note "Anmerkung"

    `python3-argcomplete` wird von _EPEL_ zur Verfügung gestellt. Installieren Sie epel-release, falls Sie dies noch nicht getan haben.
    Dieses Paket hilft Ihnen beim Ergänzen von Ansible-Befehlen.

Wir können jetzt Ansible installieren:

```bash
pip3.8 install --user ansible
activate-global-python-argcomplete --user
```

Überprüfen Sie Ihre Ansible-Version:

```bash
$ ansible --version
ansible [core 2.13.11]
  config file = None
  configured module search path = ['/home/rocky/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/rocky/.local/lib/python3.8/site-packages/ansible
  ansible collection location = /home/rocky/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/rocky/.local/bin/ansible
  python version = 3.8.16 (default, Jun 25 2023, 05:53:51) [GCC 8.5.0 20210514 (Red Hat 8.5.0-18)]
  jinja version = 3.1.2
  libyaml = True
```

!!! note "Hinweis"

    Die manuell installierte Version ist in unserem Fall älter als die durch RPM gepackte Version, da wir eine ältere Python-Version verwendet haben. Diese Beobachtung wird natürlich mit der Zeit und dem Alter der Distribution und der Python-Version variieren.

## Konfigurationsdateien

Die Server-Konfiguration befindet sich unter `/etc/ansible`.

Es gibt zwei grundlegende Konfigurationsdateien:

* Die Hauptkonfigurationsdatei `ansible.cfg`, in der sich die Befehle, Module, Plugins und die SSH-Konfiguration befinden;
* Die `hosts`-Clientcomputerverwaltungsinventardatei, in der Clients und Clientgruppen deklariert werden.

Die Konfigurationsdatei wird automatisch erstellt, wenn Ansible mit seinem RPM-Paket installiert wurde. Bei einer `pip`-Installation existiert diese Datei nicht. Wir müssen es manuell mit dem Befehl `ansible-config` erstellen:

```bash
$ ansible-config -h
usage: ansible-config [-h] [--version] [-v] {list,dump,view,init} ...

Ansible Konfiguration anzeigen.

positional arguments:
  {list,dump,view,init}
    list                Print all config options
    dump                Dump configuration
    view                View configuration file
    init                Create initial configuration
```

Beispiel:

```bash
ansible-config init --disabled > /etc/ansible/ansible.cfg
```

Mit der Option `--disabled` können Sie den Optionsset auskommentieren, indem Sie ihm `;` voranstellen.

!!! note "Hinweis"

    Sie können Ihre Ansible-Konfiguration auch in Ihr Code-Repository einbetten, wobei Ansible die gefundenen Konfigurationsdateien in der folgenden Reihenfolge lädt (die erste Datei, auf die es trifft, wird verarbeitet und andere werden ignoriert):

    * Wenn die Umgebungsvariable `$ANSIBLE_CONFIG` gesetzt ist, wird die angegebene Datei geladen.
    * `ansible.cfg`, wenn es im aktuellen Verzeichnis vorhanden ist.
    * `~/.ansible.cfg`, falls vorhanden (im Home-Verzeichnis des Benutzers).

    Wird keine dieser drei Dateien gefunden, wird die Standarddatei geladen.

### Die Inventar-Datei `/etc/ansible/hosts`

Da Ansible mit allen zu konfigurierenden Geräten arbeiten muss, ist es wichtig, ihm eine (oder mehrere) gut strukturierte Inventardatei(en) zur Verfügung zu stellen, die perfekt zu Ihrem Projekt passen.

Manchmal müssen Sie sorgfältig darüber nachdenken, wie Sie diese Datei gestalten.

Wechseln Sie zur Default-Inventardatei, die sich unter `/etc/ansible/hosts` befindet. Einige Beispiele werden bereitgestellt und kommentiert:

```text
# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# Ex 1: Ungrouped hosts, specify before any group headers:

## green.example.com
## blue.example.com
## 192.168.100.1
## 192.168.100.10

# Ex 2: A collection of hosts belonging to the 'webservers' group:

## [webservers]
## alpha.example.org
## beta.example.org
## 192.168.1.100
## 192.168.1.110

# If you have multiple hosts following a pattern, you can specify
# them like this:

## www[001:006].example.com

# Ex 3: A collection of database servers in the 'dbservers' group:

## [dbservers]
##
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57

# Here's another example of host ranges, this time there are no
# leading 0s:

## db-[99:101]-node.example.com
```

Wie Sie feststellen können, verwendet die als Beispiel bereitgestellte Datei das INI-Format, das bei Systemadministratoren gut bekannt ist. Beachten Sie, dass Sie ein anderes Dateiformat wählen können (z.B., Yaml), aber für erste Tests passt das INI-Format gut in den nächsten Beispielen.

Das Inventar kann automatisch in der Produktion generiert werden, insbesondere wenn Sie über eine Virtualisierungsumgebung wie VMware VSphere oder eine Cloud-Umgebung (AWS, OpenStack oder andere) verfügen.

* Erstellen Sie eine Hostgruppe in `/etc/ansible/hosts`:

Wie Sie vielleicht bemerkt haben, werden Gruppen in eckigen Klammern angegeben. Dann kommen die Elemente, die zu den Gruppen gehören. Sie können beispielsweise eine `rocky8`-Gruppe erstellen, indem Sie den folgenden Block in die Datei einfügen:

```bash
[rocky8]
172.16.1.10
172.16.1.11
```

Gruppen können innerhalb anderer Gruppen verwendet werden. In diesem Fall müssen Sie mit dem Attribut `:children` angeben, dass die übergeordnete Gruppe aus Untergruppen besteht, wie in diesem Fall:

```bash
[linux:children]
rocky8
debian9

[ansible:children]
ansible_management
ansible_clients

[ansible_management]
172.16.1.10

[ansible_clients]
172.16.1.10
```

Wir werden nicht näher auf das Inventory eingehen, aber wenn Sie interessiert sind, schauen Sie sich [diesen Link an ](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html).

Nachdem unser Verwaltungsserver nun installiert und unser Inventory bereit ist, ist es an der Zeit, unsere ersten `ansible`-Befehle auszuführen.

## Verwendung von `ansible` in der Befehlszeile

Der Befehl `ansible` startet eine Aufgabe auf einem oder mehreren Zielhosts.

```bash
ansible <host-pattern> [-m module_name] [-a args] [options]
```

Beispiele:

!!! warning "Warnhinweis"

    Da wir die Authentifizierung auf unseren beiden Testservern noch nicht konfiguriert haben, funktionieren nicht alle der folgenden Beispiele. Sie dienen als Beispiele zum besseren Verständnis und werden später in diesem Kapitel voll funktionsfähig sein.

* Listen Sie die Hosts auf, die zur Gruppe „rocky8“ gehören:

```bash
ansible rocky8 --list-hosts
```

* Testen Sie eine Gruppe von Hosts mit dem Modul `ping`:

```bash
ansible rocky8 -m ping
```

* Fakten über eine Hostgruppe mit dem `setup`-Modul anzeigen:

```bash
ansible rocky8 -m setup
```

* Führen Sie den Befehl auf der Hostgruppe aus, indem Sie das `command`-Modul mit den folgenden Argumenten aufrufen:

```bash
ansible rocky8 -m command -a 'uptime'
```

* Einen Befehl mit Administratorrechten ausführen:

```bash
ansible ansible_clients --become -m command -a 'reboot'
```

* Run a command using a custom inventory file:

```bash
ansible rocky8 -i ./local-inventory -m command -a 'date'
```

!!! note "Anmerkung"

    Wie in diesem Beispiel ist es manchmal einfacher, die Deklaration verwalteter Geräte in verschiedene Dateien zu unterteilen (z. B. beim Cloud-Projekt) und Ansible den Pfad zu diesen Dateien bereitzustellen, als eine lange Inventardatei zu pflegen.

| Option                   | Beschreibung                                                                                                 |
| ------------------------ | ------------------------------------------------------------------------------------------------------------ |
| `-a 'arguments'`         | Die Argumente, die an das Modul übergeben werden.                                                            |
| `-b -K`                  | Fordert ein Passwort an und führt das Kommando mit höheren Rechten aus.                                      |
| `--user=username`        | Verwendet diesen Benutzer, um sich mit dem Zielhost zu verbinden, anstatt mit dem aktuellen Benutzer.        |
| `--become-user=username` | Führt die Operation als diesen Benutzer aus (Standard: `root`).                                              |
| `-C`                     | Simulation. Macht bitte keine Änderungen am Ziel, sondern testet es um zu sehen, was geändert werden sollte. |
| `-m module`              | Führt folgendes Modul aus:                                                                                   |

### Client Vorbereitung

Sowohl auf der Verwaltungsmaschine als auch auf den Clients erstellen wir einen `ansible`-Benutzer, der für die von Ansible ausgeführten Operationen zuständig ist. Dieser Benutzer braucht sudo-Rechte haben und muss daher zur Gruppe `wheel` hinzugefügt werden.

Dieser Benutzer wird verwendet:

* Auf der Admin-Station-Seite: Zum Ausführen von `ansible`- und SSH-Befehlen für verwaltete Clients.
* Auf verwalteten Stationen (hier fungiert der Server, der als Verwaltungsstation fungiert, auch als Client, wird also selbst verwaltet), um die von der Verwaltungsstation gestarteten Befehle auszuführen: Er muss daher über Sudo-Rechte verfügen.

Erstellen Sie auf beiden Maschinen einen `ansible`-Benutzer, der Ansible gewidmet ist:

```bash
sudo useradd ansible
sudo usermod -aG wheel ansible
```

Passwort für diesen Benutzer setzen:

```bash
sudo passwd ansible
```

Ändern Sie die sudoers-Konfiguration, um Mitgliedern der `wheel`-Gruppe die Ausführung von sudo ohne Passwort zu ermöglichen:

```bash
sudo visudo
```

Unser Ziel ist es, die vorbelegung auszukommentieren und die NOPASSWD-Option zu ändern, sodass diese Zeilen wie folgt aussehen:

```bash
## Allows people in group wheel to run all commands
# %wheel  ALL=(ALL)       ALL

## Same thing without a password
%wheel        ALL=(ALL)       NOPASSWD: ALL
```

!!! warning "Warnhinweis"

    Wenn Sie bei der Eingabe von Ansible-Befehlen die folgende Fehlermeldung erhalten, liegt das wahrscheinlich daran, dass Sie diesen Schritt auf einem Ihrer Clients vergessen haben:
    `"msg": "Missing sudo password`

Wenn Sie ab diesem Zeitpunkt die Verwaltung nutzen, beginnen Sie mit diesem neuen Benutzer zu arbeiten:

```bash
sudo su - ansible
```

### Test mit ping Modul

Standardmäßig ist die Passwortanmeldung bei Ansible nicht zulässig.

Kommentieren Sie die folgende Zeile aus dem Abschnitt `[defaults]` der Konfigurationsdatei `/etc/ansible/ansible.cfg` aus und setzen Sie sie auf True:

```bash
ask_pass      = True
```

Führen Sie einen `ping` auf jeden Server der rocky8-Gruppe aus:

```bash
# ansible rocky8 -m ping
SSH password:
172.16.1.10 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
172.16.1.11 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

!!! note "Anmerkung"

    Sie werden nach dem „ansible“ Passwort der Remote-Server gefragt, was ein Sicherheitsproblem darstellt...

!!! tip "Hinweis"

    Wenn Sie folgende Fehlermeldung erhalten: 
    `"msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"`, 
    installieren Sie einfach `sshpass` auf der Verwaltungstation:

    ```
    $ sudo dnf install sshpass
    ```

!!! abstract "Abstrakt"

    Jetzt können Sie Befehle testen, die zuvor in diesem Kapitel nicht funktionierten.

## Schlüsselauthentifizierung

Die Passwortauthentifizierung wird durch eine wesentlich sicherere Authentifizierung mit privatem/öffentlichem Schlüssel ersetzt.

### SSH key generieren

Der Dual-Key wird mit dem Befehl `ssh-keygen` auf der Managementstation vom `ansible`-Benutzer generiert:

```bash
[ansible]$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ansible/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/ansible/.ssh/id_rsa.
Your public key has been saved in /home/ansible/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:Oa1d2hYzzdO0e/K10XPad25TA1nrSVRPIuS4fnmKr9g ansible@localhost.localdomain
The key's randomart image is:
+---[RSA 3072]----+
|           .o . +|
|           o . =.|
|          . . + +|
|         o . = =.|
|        S o = B.o|
|         = + = =+|
|        . + = o+B|
|         o + o *@|
|        . Eoo .+B|
+----[SHA256]-----+

```

Der öffentliche Schlüssel kann auf die Server kopiert werden:

```bash
# ssh-copy-id ansible@172.16.1.10
# ssh-copy-id ansible@172.16.1.11
```

Kommentieren Sie die folgende Zeile aus dem Abschnitt `[defaults]` in der Konfigurationsdatei `/etc/ansible/ansible.cfg` erneut aus, um die Kennwortauthentifizierung zu verhindern:

```bash
#ask_pass      = True
```

### Authentifizierungstest mit privatem Schlüssel

Für den nächsten Test wird das `shell`-Modul verwendet, das die Ausführung von Remote-Befehlen ermöglicht:

```bash
# ansible rocky8 -m shell -a "uptime"
172.16.1.10 | SUCCESS | rc=0 >>
 12:36:18 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00

172.16.1.11 | SUCCESS | rc=0 >>
 12:37:07 up 57 min,  1 user,  load average: 0.00, 0.00, 0.00
```

Es ist kein Passwort erforderlich, die Authentifizierung mit privatem und öffentlichem Schlüssel funktioniert!

!!! note "Anmerkung"

    In der Produktionsumgebung sollten Sie jetzt die zuvor festgelegten „ansible“ Passwörter entfernen, um Sicherheit zu gewährleisten (da jetzt kein Authentifizierungspasswort erforderlich ist).

## Verwendung von Ansible

Ansible kann aus der Shell oder über Playbooks genutzt werden.

### Module

Die Liste der nach Kategorien klassifizierten Module finden Sie [hier](https://docs.ansible.com/ansible/latest/collections/index_module.html). Ansible bietet mehr als 750!

Module sind jetzt in Modulsammlungen gruppiert, deren Liste [hier](https://docs.ansible.com/ansible/latest/collections/index.html) zu finden ist.

Collections sind ein Verteilungsformat für Ansible-Inhalte, das Playbooks, Rollen, Module und Plugins umfassen kann.

Ein Modul wird mit der Option `-m` des Befehls `ansible` aufgerufen:

```bash
ansible <host-pattern> [-m module_name] [-a args] [options]
```

There is a module for almost every need! Wir empfehlen Ihnen daher, statt des shell-Moduls nach einem Modul zu suchen, das Ihren Bedürfnissen entspricht.

Jede Bedarfskategorie hat ihr eigenes Modul. Hier ist eine unvollständige Liste:

| Typ                 | Beispiele                                                      |
| ------------------- | -------------------------------------------------------------- |
| Systemverwaltung    | `user` (Benutzerverwaltung), `group` (Gruppenverwaltung), etc. |
| Software-Verwaltung | `dnf`,`yum`, `apt`, `pip`, `npm`                               |
| Dateiverwaltung     | `copy`, `fetch`, `lineinfile`, `template`, `archive`           |
| Datenbankverwaltung | `mysql`, `postgresql`, `redis`                                 |
| Cloud-Verwaltung    | `amazon S3`, `cloudstack`, `openstack`                         |
| Cluster-Verwaltung  | `consul`, `zookeeper`                                          |
| Send commands       | `shell`, `script`, `expect`                                    |
| Downloads           | `get_url`                                                      |
| Quellenverwaltung   | `git`, `gitlab`                                                |

#### Beispiel einer Software-Installation

Mit dem `dnf`-Modul können Sie die Software auf Ziel-Clients installieren:

```bash
# ansible rocky8 --become -m dnf -a name="httpd"
172.16.1.10 | SUCCESS => {
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
      ...
      \n\nComplete!\n"
    ]
}
172.16.1.11 | SUCCESS => {
    "changed": true,
    "msg": "",
    "rc": 0,
    "results": [
      ...
    \n\nComplete!\n"
    ]
}
```

Da es sich bei der installierten Software um einen Dienst handelt, ist es notwendig, diesen mit dem Modul `systemd` zu starten:

```bash
# ansible rocky8 --become  -m systemd -a "name=httpd state=started"
172.16.1.10 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "started"
}
172.16.1.11 | SUCCESS => {
    "changed": true,
    "name": "httpd",
    "state": "started"
}
```

!!! tip "Hinweis"

    Versuchen Sie, die letzten beiden Befehle zweimal auszuführen. Sie werden feststellen, dass Ansible beim ersten Mal Aktionen ausführt, um den durch den Befehl festgelegten Zustand zu erreichen. Beim zweiten Mal wird nichts getan, da erkannt wurde, dass der Status bereits erreicht wurde!

### Übungen

Um mehr über Ansible zu erfahren und sich mit der Suche in der Ansible-Dokumentation vertraut zu machen, finden Sie hier einige Übungen, die Sie durchführen können, bevor Sie fortfahren:

* Erstellen Sie die Gruppen Paris, Tokio, NewYork
* Erstellen Sie den Benutzer `supervisor`
* Ändern Sie den Benutzer auf eine UID von 10000
* Ändern Sie den Benutzer, so dass er zur Paris-Gruppe gehört
* tree-Software installieren
* crond-Dienst stoppen
* Eine leere Datei mit `644` Rechten erstellen
* Client-Distribution aktualisieren
* Client neu starten

!!! warning "Warnhinweis"

    shell-Module vermeiden. Schauen Sie in der Dokumentation nach den passenden Modulen!

#### `setup` Modul: Einführung in facts

System-facts sind Variablen, die von Ansible über das `setup`-Modul abgerufen werden.

Werfen Sie einen Blick auf die verschiedenen facts Ihrer Clients, um eine Vorstellung davon zu bekommen, wie viele Informationen mit einem einfachen Befehl leicht abgerufen werden können.

Wir werden später sehen, wie wir Fakten in unseren Playbooks nutzen und wie wir eigene Fakten - facts - erstellen können.

```bash
# ansible ansible_clients -m setup | less
192.168.1.11 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.1.11"
        ],
        "ansible_all_ipv6_addresses": [
            "2001:861:3dc3:fcf0:a00:27ff:fef7:28be",
            "fe80::a00:27ff:fef7:28be"
        ],
        "ansible_apparmor": {
            "status": "disabled"
        },
        "ansible_architecture": "x86_64",
        "ansible_bios_date": "12/01/2006",
        "ansible_bios_vendor": "innotek GmbH",
        "ansible_bios_version": "VirtualBox",
        "ansible_board_asset_tag": "NA",
        "ansible_board_name": "VirtualBox",
        "ansible_board_serial": "NA",
        "ansible_board_vendor": "Oracle Corporation",
        ...
```

Nachdem wir nun gesehen haben, wie man einen Remote-Server mit Ansible über die Befehlszeile einrichtet, können wir das Konzept der Playbooks untersuchen. Playbooks sind eine weitere Möglichkeit, Ansible zu verwenden. Sie sind zwar nicht viel komplexer, erleichtern aber die Wiederverwendung von Code.

## Playbooks

Ansible's playbooks describe a policy to be applied to remote systems, to force their configuration. Playbooks sind in einem leicht verständlichen Textformat geschrieben, das eine Reihe von Tasks gruppiert: dem `yaml`-Format.

!!! note "Anmerkung"

    Weitere Informationen zu yaml finden Sie [hier](https://docs.ansible.com/ansible/latest/reference_appendixes/YAMLSyntax.html)

```bash
ansible-playbook <file.yml> ... [options]
```

Die Optionen sind mit dem Befehl `ansible` identisch.

Der Befehl gibt die folgenden Fehlercodes zurück:

| Code  | Fehler                                       |
| ----- | -------------------------------------------- |
| `0`   | OK oder kein passender Host                  |
| `1`   | Fehler                                       |
| `2`   | Ein oder mehrere Hosts scheitern             |
| `3`   | Ein oder mehrere Hosts sind nicht erreichbar |
| `4`   | Fehler analysieren                           |
| `5`   | Falsche oder unvollständige Optionen         |
| `99`  | Ausführen durch Benutzer unterbrochen        |
| `250` | Unerwarteter Fehler                          |

!!! note "Anmerkung"

    Beachten Sie, dass „ansible“ Ok zurückgibt, wenn kein Host mit dem Ziel übereinstimmt, was irreführend sein kann!

### Playbook-Beispiel für Apache und MySQL

Mit dem folgenden Playbook können wir Apache und MariaDB auf unseren Zielservern installieren.

Erstellen Sie eine `test.yml`-Datei mit folgendem Inhalt:

```bash
---
- hosts: rocky8 <1>
  become: true <2>
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      dnf: name=httpd,php,php-mysqli state=latest

    - name: ensure httpd is started
      systemd: name=httpd state=started

    - name: ensure mariadb is at the latest version
      dnf: name=mariadb-server state=latest

    - name: ensure mariadb is started
      systemd: name=mariadb state=started
...
```

* <1> Die entsprechende Ziel-Gruppe bzw. der betreffende Ziel-Server muss im Inventar vorhanden sein
* <2> Sobald die Verbindung hergestellt ist, wird der Benutzer zum `root` (standardmäßig über `sudo`)

Die Ausführung des Playbooks erfolgt mit dem Befehl `ansible-playbook`:

```bash
$ ansible-playbook test.yml

PLAY [rocky8] ****************************************************************

TASK [setup] ******************************************************************
ok: [172.16.1.10]
ok: [172.16.1.11]

TASK [ensure apache is at the latest version] *********************************
ok: [172.16.1.10]
ok: [172.16.1.11]

TASK [ensure httpd is started] ************************************************
changed: [172.16.1.10]
changed: [172.16.1.11]

TASK [ensure mariadb is at the latest version] **********************************
changed: [172.16.1.10]
changed: [172.16.1.11]

TASK [ensure mariadb is started] ***********************************************
changed: [172.16.1.10]
changed: [172.16.1.11]

PLAY RECAP *********************************************************************
172.16.1.10             : ok=5    changed=3    unreachable=0    failed=0
172.16.1.11             : ok=5    changed=3    unreachable=0    failed=0
```

Für eine bessere Lesbarkeit wird empfohlen, Playbooks im vollständigen yaml-Format zu schreiben. Im vorherigen Beispiel werden die Argumente in derselben Zeile des Formulars angegeben, wobei der Argumentwert auf seinen Namen getrennt durch ein Gleichheitzeichen `=` folgt. Schauen Sie sich das gleiche Playbook im vollständigen Yaml-Format an:

```bash
---
- hosts: rocky8
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      systemd:
        name: httpd
        state: started

    - name: ensure mariadb is at the latest version
      dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      systemd:
        name: mariadb
        state: started
...
```

!!! tip "Hinweis"

    „dnf“ ist eines der Module, das es Ihnen ermöglicht, eine Liste als Argument anzugeben.

Hinweis zu collections: Ansible stellt Module jetzt in Form von Sammlungen bereit. Einige Module werden standardmäßig in der `ansible.builtin`-collection bereitgestellt, andere müssen manuell installiert werden über:

```bash
ansible-galaxy collection install [collectionname]
```

dabei ist [collectionname] der Name der Kollektion (die eckigen Klammern hier werden verwendet, um hervorzuheben, dass dieser durch einen tatsächlichen Kollektiosnamen ersetzt werden muss, und sind NICHT Teil des Befehls).

Das vorherige Beispiel sollte wie folgt geschrieben werden:

```bash
---
- hosts: rocky8
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      ansible.builtin.dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      ansible.builtin.systemd:
        name: httpd
        state: started

    - name: ensure mariadb is at the latest version
      ansible.builtin.dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      ansible.builtin.systemd:
        name: mariadb
        state: started
...
```

Ein Playbook ist nicht auf ein Ziel beschränkt:

```bash
---
- hosts: webservers
  become: true
  become_user: root

  tasks:

    - name: ensure apache is at the latest version
      ansible.builtin.dnf:
        name: httpd,php,php-mysqli
        state: latest

    - name: ensure httpd is started
      ansible.builtin.systemd:
        name: httpd
        state: started

- hosts: databases
  become: true
  become_user: root

    - name: ensure mariadb is at the latest version
      ansible.builtin.dnf:
        name: mariadb-server
        state: latest

    - name: ensure mariadb is started
      ansible.builtin.systemd:
        name: mariadb
        state: started
...
```

Sie können die Syntax des Playbooks wie folgt prüfen:

```bash
ansible-playbook --syntax-check play.yml
```

Sie können auch ein "linter" für yaml verwenden:

```bash
dnf install -y yamllint
```

und dann die yaml-Syntax der Playbooks überprüfen:

```bash
$ yamllint test.yml
test.yml
  8:1       error    syntax error: could not find expected ':' (syntax)
```

## Ergebnisse der Übungen

* Die Gruppen Paris, Tokio, NewYork anlegen
* Den Benutzer `supervisor` anlegen
* Ändern der UID des Benutzers auf 10000
* Ändern des Benutzers so, dass er zur Gruppe „Paris“ gehört
* tree-Software installieren
* crond-Dienst stoppen
* Eine leere Datei mit den Rechten `0644` anlegen
* Client-Distribution aktualisieren
* Client neustarten

```bash
ansible ansible_clients --become -m group -a "name=Paris"
ansible ansible_clients --become -m group -a "name=Tokio"
ansible ansible_clients --become -m group -a "name=NewYork"
ansible ansible_clients --become -m user -a "name=Supervisor"
ansible ansible_clients --become -m user -a "name=Supervisor uid=10000"
ansible ansible_clients --become -m user -a "name=Supervisor uid=10000 groups=Paris"
ansible ansible_clients --become -m dnf -a "name=tree"
ansible ansible_clients --become -m systemd -a "name=crond state=stopped"
ansible ansible_clients --become -m copy -a "content='' dest=/tmp/test force=no mode=0644"
ansible ansible_clients --become -m dnf -a "name=* state=latest"
ansible ansible_clients --become -m reboot
```
