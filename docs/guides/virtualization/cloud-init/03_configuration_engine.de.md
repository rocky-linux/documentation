---
title: Kapitel 3. Die Konfigurations-Engine
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - cloud-init
  - rocky linux
  - cloud-init modules
  - Automatisierung
---

## Detaillierter Einblick in die `cloud-init`-Module

Im letzten Kapitel haben Sie erfolgreich ein Cloud-Image gestartet und eine einfache Anpassung vorgenommen. Obwohl es bereits effektiv ist, erschließen Sie die wahre Leistungsfähigkeit, Portabilität und Idempotenz von `cloud-init` erst mit seinem Modulsystem. Diese Module sind spezialisierte Werkzeuge im `cloud-init`-Toolkit, die dazu dienen, bestimmte Konfigurationsaufgaben auf deklarative und vorhersehbare Weise zu bewältigen.

Dieses Kapitel befasst sich eingehend mit dem Modulsystem und erklärt, was Module sind, wie sie funktionieren und wie die wichtigsten Module zum Erstellen eines gut konfigurierten Servers verwendet werden.

## 1. Besonderheiten der Konfiguration

### Was sind Cloud-Init-Module?

Ein `cloud-init`-Modul ist ein spezialisiertes Python-Skript, das für die Bearbeitung einer einzelnen, diskreten Bereitstellungsaufgabe entwickelt wurde. Man kann sie sich als Plugins für Funktionen wie Benutzerverwaltung, Paketinstallation und Dateierstellung vorstellen.

Der entscheidende Vorteil der Verwendung von Modulen gegenüber einfachen Skripten (wie `runcmd`) ist die **Idempotenz**. Eine idempotente Operation liefert immer das gleiche Ergebnis, egal ob man sie einmal oder zig-mal ausführt. Wenn Sie deklarieren, dass ein Benutzer vorhanden sein soll, stellt das Modul sicher, dass dieser Status erfüllt ist.
Es erstellt den Benutzer, wenn er nicht vorhanden ist, unternimmt jedoch nichts, wenn er bereits vorhanden ist. Dadurch werden Ihre Konfigurationen zuverlässig und wiederholbar.

### Das `#cloud-config`-Format erneut betrachtet

Wenn `cloud-init` den Header `#cloud-config` sieht, interpretiert es die Datei als YAML-formatierten Befehlssatz – die Schlüssel der obersten Ebene in dieser YAML-Datei werden direkt auf `cloud-init`-Module abgebildet.

### Modulausführung und Reihenfolge

Die Module werden in bestimmten Phasen des Bootvorgangs in einer in `/etc/cloud/cloud.cfg` definierten Reihenfolge ausgeführt. Eine vereinfachte Darstellung dieses Ablaufs sieht folgendermaßen aus:

```
System Boot
    |
    +--- Stage: Generator (Very early boot)
    |    `--- cloud_init_modules (e.g., migrator)
    |
    +--- Stage: Local (Pre-network)
    |    `--- (Modules for local device setup)
    |
    +--- Stage: Network (Network is up)
    |    `--- cloud_config_modules (e.g., users-groups, packages, write_files)
    |
    `--- Stage: Final (Late boot)
         `--- cloud_final_modules (e.g., runcmd, scripts-user)
```

Die Reihenfolge ist entscheidend. Beispielsweise wird das Modul `users-groups` vor `runcmd` ausgeführt, um sicherzustellen, dass ein Skript von einem Benutzer ausgeführt werden kann, der gerade in derselben Konfiguration erstellt wurde.

!!! tip "Anpassen des Verhaltens von `cloud-init`"

    Obwohl `/etc/cloud/cloud.cfg` das Standardverhalten definiert, sollten Sie es niemals direkt bearbeiten. Für dauerhafte, systemweite Anpassungen platzieren Sie Ihre eigenen `.cfg`-Dateien im Verzeichnis `/etc/cloud/cloud.cfg.d/`. Dies ist die Standardpraxis zum Erstellen benutzerdefinierter Images, die wir in einem späteren Kapitel näher erläutern.

## 2. Hochleistungsmodule: Die täglichen Treiber

Lassen Sie uns die gängigsten Module mithilfe der direkten Injektionsmethode mit `virt-install` in der Praxis ausprobieren.

### Modul im Detail: `users` und `groups`

Die ordnungsgemäße Verwaltung von Benutzerkonten ist die Grundlage für die Absicherung einer neuen Serverinstanz. Das Modul `users` ist hierfür Ihr primäres Tool. Es ermöglicht Ihnen, neue Benutzer zu erstellen, vorhandene zu ändern, Gruppenmitgliedschaften zu verwalten und, was am wichtigsten ist, SSH-Schlüssel einzufügen, um sichere, passwortlose Anmeldungen vom ersten Start an zu ermöglichen.

**Beispiel 1: Erstellen eines neuen Admin-Benutzers**

In diesem Beispiel richten wir einen neuen, dedizierten Administratorbenutzer mit dem Namen `sysadmin` ein. Wir werden diesem Benutzer passwortlose `sudo`-Berechtigungen erteilen, indem wir ihn der Gruppe `wheel` hinzufügen und eine spezifische `sudo`-Regel bereitstellen. Wir werden außerdem einen öffentlichen SSH-Schlüssel einfügen, um einen sicheren Zugriff zu gewährleisten.

1. **Erstellen der Datei `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    users:
      - name: sysadmin
        groups: [ wheel ]
        sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
        shell: /bin/bash
        ssh_authorized_keys:
          - <YOUR_SSH_PUBLIC_KEY_HERE>
    EOF
    ```

2. **Erläuterung der wichtigsten Direktiven:**

   - `name`: Der Benutzername für das neue Konto.
   - `groups`: Eine Liste der Gruppen, denen der Benutzer hinzugefügt werden soll. Unter Rocky Linux wird die Mitgliedschaft in der Gruppe `wheel` häufig genutzt, um administrative Rechte zu gewähren.
   - `sudo`: Eine Liste der anzuwendenden `sudoers`-Regeln. Die Regel `ALL=(ALL) NOPASSWD:ALL` gewährt dem Benutzer die Möglichkeit, jeden Befehl mit `sudo` auszuführen, ohne zur Eingabe eines Passworts aufgefordert zu werden.
   - `ssh_authorized_keys`: Eine Liste öffentlicher SSH-Schlüssel, die der Datei `~/.ssh/authorized_keys` des Benutzers hinzugefügt werden sollen.

3. **Booten und Verifizierung:** Starten Sie die VM mit diesen `user-data`. Sie sollten in der Lage sein, sich per SSH als `sysadmin` anzumelden und `sudo`-Befehle auszuführen.

**Beispiel 2: Ändern des Standardbenutzers**

Eine häufigere Aufgabe ist die Sicherung des Standardbenutzers, der mit dem Cloud-Image bereitgestellt wird (`rocky`). Hier werden wir diesen Benutzer so modifizieren, dass er den SSH-Schlüssel hinzufügt.

1. **Erstellen der Datei `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    users:
      - default
      - name: rocky
        ssh_authorized_keys:
          - <YOUR_SSH_PUBLIC_KEY_HERE>
    EOF
    ```

2. **Erläuterung der wichtigsten Direktiven:**

   - `default`: Dieser spezielle Eintrag weist `cloud-init` an, zuerst die Standardbenutzereinrichtung durchzuführen.
   - `name: rocky`: Durch Angabe des Namens eines bereits existierenden Benutzers ändert das Modul diesen Benutzer, anstatt einen neuen zu erstellen. Hier wird der bereitgestellte SSH-Schlüssel in das Benutzerkonto `rocky` integriert.

3. **Starten und überprüfen:** Starten Sie die VM. Sie können sich nun ohne Passwort als Benutzer `rocky` per SSH anmelden.

### Modul im Detail: `packages`

Das Modul `packages` bietet eine deklarative Möglichkeit, die Software auf Ihrer Instanz zu verwalten und stellt die Installation bestimmter Anwendungen beim Booten sicher.

In diesem Beispiel stellen wir die Installation von zwei nützlichen Tools sicher: `nginx` (ein Hochleistungs-Webserver) und `htop` (ein interaktiver Prozessbetrachter). Wir werden außerdem `cloud-init` anweisen, zuerst die Metadaten des Paket-Repositorys zu aktualisieren, um sicherzustellen, dass es die neuesten Versionen finden kann.

1. **Erstellen der Datei `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    package_update: true
    packages:
      - nginx
      - htop
    EOF
    ```

2. **Erläuterung der wichtigsten Direktiven:**

   - `package_update: true`: Weist den Paketmanager an, seine lokalen Metadaten zu aktualisieren. Unter Rocky Linux entspricht dies dem Ausführen von `dnf check-update`.
   - `packages`: Eine Liste der zu installierenden Paketnamen.

3. **Startvorgang und Überprüfung:** Nach dem Startvorgang stellen Sie eine SSH-Verbindung her und überprüfen Sie die Installation von `nginx` mit `rpm -q nginx`.

!!! note "Idempotenz in Aktion"

    Wenn Sie diese VM mit denselben Benutzerdaten neu starten, erkennt das Modul `packages`, dass `nginx` und `htop` bereits installiert sind und unternimmt keine weiteren Schritte. Es stellt den gewünschten Zustand (Pakete sind vorhanden) sicher, ohne unnötige Aktionen durchzuführen. Das ist Idempotenz.

### Modul im Detail: `write_files`

Dieses Modul ist unglaublich vielseitig und ermöglicht es Ihnen, beliebige Textinhalte in beliebige Dateien auf dem System zu schreiben. Es ist das perfekte Werkzeug zum Bereitstellen von Anwendungskonfigurationsdateien, zum Befüllen von Webinhalten oder zum Erstellen von Hilfsskripten.

Um seine Leistungsfähigkeit zu demonstrieren, verwenden wir `write_files`, um eine benutzerdefinierte Homepage für den `nginx`-Webserver zu erstellen, den wir im selben Lauf ebenfalls installieren.

1. **Erstellen der Datei `user-data.yml`:**

    ```bash
    cat <<EOF > user-data.yml
    #cloud-config
    packages: [nginx]
    write_files:
      - path: /usr/share/nginx/html/index.html
        content: '<h1>Hello from cloud-init!</h1>'
        owner: nginx:nginx
        permissions: '0644'
    runcmd:
      - [ systemctl, enable, --now, nginx ]
    EOF
    ```

2. **Erläuterung der wichtigsten Direktiven:**

   - `path`: Der absolute Pfad im Dateisystem, in dem die Datei gespeichert wird.
   - `content`: Der Textinhalt, der in die Datei geschrieben werden soll.
   - `owner`: Gibt den Benutzer und die Gruppe an, denen die Datei gehören soll (z. B. `nginx:nginx`).
   - `permissions`: Die Dateiberechtigungen im Oktalformat (z. B. `0644`).

3. **Booten und Verifizierung:** Nach dem Hochfahren stellen Sie eine SSH-Verbindung her und verwenden Sie `curl localhost`, um die neue Homepage anzuzeigen.

!!! tip "Schreiben von Binärdateien"

    Das Modul `write_files` ist nicht auf Text beschränkt. Durch Angabe einer „Kodierung“ —`encoding`— können Sie Binärdateien bereitstellen. Beispielsweise können Sie `encoding: b64` verwenden, um base64-kodierte Daten zu schreiben. Fortgeschrittene Anwendungsfälle finden Sie in der [offiziellen `write_files`-Dokumentation](https://cloudinit.readthedocs.io/de/latest/topics/modules.html#write-files).

## Wie geht es weiter?

Sie beherrschen nun die drei grundlegendsten `cloud-init`-Module. Durch die Kombination dieser Funktionen lässt sich ein erheblicher Teil der Serverkonfiguration automatisieren. Im nächsten Kapitel werden wir uns mit fortgeschritteneren Szenarien befassen, darunter der Netzwerkkonfiguration und der Kombination verschiedener „Benutzerdaten“-Formate in einem einzigen Durchlauf.
