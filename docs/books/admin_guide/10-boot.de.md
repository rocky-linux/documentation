---
title: System-Start
---

# System-Start

In diesem Kapitel erfahren Sie, wie das System startet.

****
**Ziele** : In diesem Kapitel werden zukünftige Linux-Administratoren Folgendes lernen:

:heavy_check_mark: Die verschiedenen Etappen des Boot-Prozesses;  
:heavy_check_mark: Wie Rocky Linux diesen Bootvorgang über GRUB2 und `systemd` unterstützt;  
:heavy_check_mark: Wie man GRUB2 vor einem Angriff schützt;  
:heavy_check_mark: Wie man die Dienste verwaltet;  
:heavy_check_mark: Wie man auf die Protokolle aus dem Journal - `journald` - zugreift.

:checkered_flag: **Benutzer**.

**Vorkenntnisse**: :star: :star:  
**Komplexität**: :star: :star: :star:

**Lesezeit**: 23 Minuten
****

## Der Boot-Prozess

Um auftretende Probleme lösen zu können, ist es unerlässlich, den Bootvorgang von Linux zu verstehen.

Der Boot-Prozess enthält:

### Das BIOS-Startup

Das **BIOS** (Basic Input/Output System) führt den **POST** (Power-On-Self-Test) durch, um die Hardwarekomponenten des Systems zu erkennen, zu testen und zu initialisieren.

Es lädt dann den **MBR** (Master Boot Record).

### Der Master Boot-Rekord (MBR)

Der Master Boot Rekord umfasst die ersten 512 Bytes der Boot-Festplatte. Der MBR erkennt das Boot-Gerät, lädt den Bootloader GRUB2 in den Speicher und übergibt die Kontrolle an ihn.

Die nächsten 64 Bytes enthalten die Partitionstabelle der Festplatte.

### Der GRUB2-Bootloader

Der Standard-Bootloader der Rocky 8-Distribution ist **GRUB2** (GRand Unified Bootloader). GRUB2 ersetzt den alten GRUB-Bootloader (auch GRUB Legacy).

Die GRUB2-Konfigurationsdatei befindet sich unter `/boot/grub2/grub.cfg` aber diese Datei sollte nicht direkt editiert werden.

Die GRUB2-Menükonfigurationseinstellungen finden Sie unter `/etc/default/grub`.  Der Befehl `grub2-mkconfig` verwendet diese, um die Datei `grub.cfg` zu generieren.

```bash
# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/swap crashkernel=auto rd.lvm.lv=rhel/root rhgb quiet net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
```

Wenn Sie einen oder mehrere dieser Parameter ändern, müssen Sie den Befehl `grub2-mkconfig` ausführen, um die Datei `/boot/grub2/grub.cfg` neu zu generieren.

```bash
[root] # grub2-mkconfig –o /boot/grub2/grub.cfg
```

* GRUB2 sucht nach dem komprimierten Kernel-Image (die Datei `vmlinuz`) im `/boot` Verzeichnis.
* GRUB2 lädt das Kernel-Image in den Speicher und extrahiert den Inhalt der Image-Datei `initramfs` in einen temporären Ordner im Speicher mit dem `tmpfs` Dateisystem.

### Der Kernel

Der Kernel startet den Prozess `systemd` mit PID 1.

```bash
root          1      0  0 02:10 ?        00:00:02 /usr/lib/systemd/systemd --switched-root --system --deserialize 23
```

### `systemd`

`systemd` ist der übergeordnete Prozess aller Systemprozesse. Es liest das Ziel des `/etc/systemd/system/default.target` Links (z.B. `/usr/lib/systemd/system/multi-user.target`), um das Standardziel des Systems zu bestimmen. Die Datei definiert die zu startenden Dienste.

`systemd` versetzt das System dann in den vom Ziel definierten Zustand, indem es die folgenden Initialisierungsaufgaben ausführt:

1. Den Maschinennamen setzen
2. Netzwerk initialisieren
3. SELinux initialisieren
4. Willkommens-Banner anzeigen
5. Initialisierung der Hardware basierend auf den Argumenten, die dem Kernel beim Booten übergeben wurden
6. Einbinden der Dateisysteme, inklusive virtuelle Dateisysteme wie /proc
7. Ordner in /var bereinigen
8. Virtuellen Speicher starten (Swap)

## Schutz des GRUB2 Bootloaders

Warum den Bootloader mit einem Passwort schützen?

1. Anmeldung im *Single user mode* verhindern – Wenn ein Angreifer im Einzelbenutzermodus booten kann, wird er zum Root-Benutzer.
2. Zugriff auf die GRUB-Konsole verhindern – Wenn es einem Angreifer gelingt, die GRUB-Konsole zu verwenden, kann er mit dem Befehl `cat` deren Konfiguration ändern oder Informationen über das System sammeln.
3. Den Zugriff auf unsichere Betriebssysteme verhindern. Bei Systemen mit Dual-Boot-Funktion kann ein Angreifer beim Systemstart ein Betriebssystem wie DOS auswählen, das Zugriffskontrollen und Dateiberechtigungen ignoriert.

Zum Passwortschutz des GRUB2-Bootloaders:

1. Melden Sie sich als Root-Benutzer beim Betriebssystem an und führen Sie den Befehl `grub2-mkpasswd-pbkdf2` aus. Die Ausgabe dieses Befehls lautet wie folgt:

    ```bash
    Enter password:
    Reenter password:
    PBKDF2 hash of your password is grub.pbkdf2.sha512.10000.D0182EDB28164C19454FA94421D1ECD6309F076F1135A2E5BFE91A5088BD9EC87687FE14794BE7194F67EA39A8565E868A41C639572F6156900C81C08C1E8413.40F6981C22F1F81B32E45EC915F2AB6E2635D9A62C0BA67105A9B900D9F365860E84F1B92B2EF3AA0F83CECC68E13BA9F4174922877910F026DED961F6592BB7
    ```

    Sie müssen Ihr Passwort während der Interaktion eingeben. Der Geheimtext des Passworts ist die lange Zeichenkette "grub.pbkdf2.sha512...".

2. Fügen Sie den Passwort-Chiffretext in die letzte Zeile der Datei **/etc/grub.d/00_header** ein. Der dazugehörige Abschnitt lautet wie folgt:

    ```bash
    cat <<EOF
    set superusers='frank'
    password_obkdf2 frank grub.pbkdf2.sha512.10000.D0182EDB28164C19454FA94421D1ECD6309F076F1135A2E5BFE91A5088BD9EC87687FE14794BE7194F67EA39A8565E868A41C639572F6156900C81C08C1E8413.40F6981C22F1F81B32E45EC915F2AB6E2635D9A62C0BA67105A9B900D9F365860E84F1B92B2EF3AA0F83CECC68E13BA9F4174922877910F026DED961F6592BB7
    EOF
    ```

    Sie können den Benutzer „frank“ durch einen beliebigen benutzerdefinierten Benutzer ersetzen.

    Sie können auch ein Klartextpasswort festlegen, zum Beispiel:

    ```bash
    cat <<EOF
    set superusers='frank'
    password frank rockylinux8.x
    EOF
    ```

3. Der letzte Schritt besteht darin, den Befehl `grub2-mkconfig -o /boot/grub2/grub.cfg` auszuführen, um die Einstellungen von GRUB2 zu aktualisieren.

4. Starten Sie das Betriebssystem neu, um die GRUB2-Verschlüsselung zu überprüfen. Wählen Sie den ersten Eintrag im Bootmenü, drücken Sie die Taste ++"e"++ und geben Sie anschließend den entsprechenden Benutzernamen und das Passwort ein.

    ```bash
    Enter username:
    frank
    Enter password:

    ```

    Nach sorgfältiger Überprüfung geben Sie ++ctrl+"x"++ ein, um das Betriebssystem zu starten.

Manchmal liest man in einigen Dokumenten, dass der Befehl `grub2-set-password` (`grub2-setpassword`) verwendet wird, um den GRUB2-Bootloader zu schützen:

| Befehl                  | Funktion                                        | Modifikation Methode der Config-Datei | Automatismus |
| ----------------------- | ----------------------------------------------- | ------------------------------------- | ------------ |
| `grub2-set-password`    | Sets password and updates configuration         | Automatische Vervollständigung        | high         |
| `grub2-mkpasswd-pbkdf2` | Erzeugt ausschließlich verschlüsselte Hashwerte | Erfordert manuelle Bearbeitung        | low          |

Melden Sie sich als Root-Benutzer am Betriebssystem an und führen Sie den Befehl `gurb2-set-password` wie folgt aus:

```bash
[root] # grub2-set-password
Enter password:
Confirm password:

[root] # cat /boot/grub2/user.cfg
GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.32E5BAF2C2723B0024C1541F444B8A3656E0A04429EC4BA234C8269AE022BD4690C884B59F344C3EC7F9AC1B51973D65F194D766D06ABA93432643FC94119F17.4E16DF72AA1412599EEA8E90D0F248F7399E45F34395670225172017FB99B61057FA64C1330E2EDC2EF1BA6499146400150CA476057A94957AB4251F5A898FC3

[root] # grub2-mkconfig -o /boot/grub2/grub.cfg

[root] # reboot
```

Nach Ausführung des Befehls `grub2-set-password` wird die Datei **/boot/grub2/user.cfg** automatisch generiert.

Wählen Sie den ersten Eintrag im Bootmenü aus und drücken Sie die Taste `++"e"++ `. Geben Sie anschließend den entsprechenden Benutzernamen und das Passwort ein:

```bash
Enter username:
root
Enter password:

```

## Systemd

*Systemd* ist ein Service Manager für Linux-Betriebssysteme.

Die Entwicklung von `systemd` zielte darauf ab:

* kompatibel mit älteren SysV-Initialisierungsskripten bleiben,
* viele Funktionen, wie zum Beispiel der parallele Start von Systemdiensten beim Systemstart, die bedarfsgesteuerte Aktivierung von Daemons, die Unterstützung von Snapshots oder die Verwaltung von Abhängigkeiten zwischen Diensten anbieten.

!!! note "Anmerkung"

    `systemd` ist das Standard-Initialisierungssystem seit RedHat/CentOS 7.

`systemd` führt das Konzept der Unit-Dateien ein, die auch als `systemd`-Units bekannt sind.

| Typ             | Dateiendung  | Beschreibung                                     |
| --------------- | ------------ | ------------------------------------------------ |
| Service-Einheit | `.service`   | Systemdienst                                     |
| Target unit     | `.target`    | Eine Gruppe von systemd-Units                    |
| Mount unit      | `.automount` | Ein automatischer Mountpunkt für das Dateisystem |

!!! note "Anmerkung"

    Es gibt viele Arten von Einheiten: Geräteeinheit, Montageeinheit, Pfadeinheit, Scope-Einheit, Slice-Einheit, Snapshot-Einheit, Socket-Einheit, Swap-Einheit und Timer-Einheit.

* `systemd` unterstützt Systemzustands-Snapshots und deren Wiederherstellung.

* Sie können Mount-Punkte als `systemd`-Ziele konfigurieren.

* Beim Start erstellt `systemd` Listening-Sockets für alle Systemdienste, die diese Art der Aktivierung unterstützen, und übergibt diese Sockets an diese Dienste, sobald sie starten. Dadurch ist es möglich, einen Dienst neu zu starten, ohne dass während seiner Nichtverfügbarkeit eine einzige Nachricht verloren geht, die ihm vom Netzwerk gesendet wurde. Der entsprechende Socket bleibt erreichbar, solange alle Nachrichten in der Warteschlange stehen.

* Systemdienste, die D-BUS für die Interprozesskommunikation nutzen, können beim ersten Aufruf durch den Client bedarfsgesteuert gestartet werden.

* `systemd` stoppt oder startet nur laufende Dienste neu. Frühere Versionen (vor RHEL7) versuchten, Dienste direkt zu stoppen, ohne deren aktuellen Status zu überprüfen.

* Systemdienste erben keinen Kontext (wie die Umgebungsvariablen HOME und PATH). Jeder Dienst wird in seinem Kontext ausgeführt.

Alle Vorgänge der Serviceeinheit unterliegen einem standardmäßigen Timeout von 5 Minuten, um zu verhindern, dass ein fehlerhafter Dienst das System einfriert.

Aus Platzgründen bietet dieses Dokument keine detaillierte Einführung in `systemd`. Falls Sie Interesse daran haben, `systemd` näher zu erkunden, finden Sie eine sehr detaillierte Einführung in [diesem Dokument](./16-about-systemd.md).

### Systemdienste verwalten

Service-Units enden mit der Dateiendung `.service` und haben einen ähnlichen Zweck wie Init-Skripte. Der Befehl `systemctl` verwendet folgende Optionen `display`, `start`, `stop`, `restart` um die entsprechende Aktion auf Dienste anzuwenden. Mit Ausnahme einiger weniger Fälle kann der einzeilige Befehl `systemctl` in den meisten Fällen auf einer oder mehreren Einheiten ausgeführt werden (nicht beschränkt auf den Einheitentyp „.service“). Sie können es über das Hilfesystem anzeigen.

| systemctl                                 | Beschreibung                                                            |
| ----------------------------------------- | ----------------------------------------------------------------------- |
| systemctl start *name*.service ...        | Startet einen oder mehrere Dienste                                      |
| systemctl stop *name*.service ...         | Stoppt einen oder mehrere Dienste                                       |
| systemctl restart *name*.service ...      | Startet einen oder mehrere Dienste neu                                  |
| systemctl reload *name*.service ...       | Lädt einen oder mehrere Dienste neu                                     |
| systemctl status *name*.service ...       | Überprüft den Status eines oder mehrerer Dienste                        |
| systemctl try-restart *name*.service ...  | Einen oder mehrere Dienste neu starten (sofern diese ausgeführt werden) |
| systemctl list-units --type service --all | Zeigt den Status aller Dienste an                                       |

Der Befehl `systemctl` wird auch zum Aktivieren `enable` oder Deaktivieren `disable` eines Systemdienstes und zum Anzeigen zugehöriger Dienste verwendet:

| systemctl                                | Beschreibung                                                  |
| ---------------------------------------- | ------------------------------------------------------------- |
| systemctl enable *name*.service ...      | Aktiviert einen oder mehrere Dienste                          |
| systemctl disable *name*.service ...     | Deaktiviert einen oder mehrere Dienste                        |
| systemctl list-unit-files --type service | Listet alle Dienste auf und prüft, ob sie laufen              |
| systemctl list-dependencies --after      | Listet die Dienste auf, die vor der angegebenen Unit beginnen |
| systemctl list-dependencies --before     | Listet die Dienste, die nach der angegebenen Unit starten     |

Beispiele:

```bash
systemctl stop nfs-server.service
# oder
systemctl stop nfs-server
```

Alle aktuell geladenen Einheiten aufzulisten:

```bash
systemctl list-units --type service
```

Um den Aktivierungsstatus aller Einheiten zu überprüfen, können Sie diese mit folgendem Befehl auflisten:

```bash
systemctl list-unit-files --type service
```

```bash
systemctl enable httpd.service
systemctl disable bluetooth.service
```

### Beispiel für eine .service Datei für den Postfix Dienst

```bash
postfix.service Unit File
What follows is the content of the /usr/lib/systemd/system/postfix.service unit file as currently provided by the postfix package:

[Unit]
Description=Postfix Mail Transport Agent
After=syslog.target network.target
Conflicts=sendmail.service exim.service

[Service]
Type=forking
PIDFile=/var/spool/postfix/pid/master.pid
EnvironmentFile=-/etc/sysconfig/network
ExecStartPre=-/usr/libexec/postfix/aliasesdb
ExecStartPre=-/usr/libexec/postfix/chroot-update
ExecStart=/usr/sbin/postfix start
ExecReload=/usr/sbin/postfix reload
ExecStop=/usr/sbin/postfix stop

[Install]
WantedBy=multi-user.target
```

### System targets verwenden

`systemd targets` ersetzen das Konzept der Runlevels bei SysV oder Upstart.

Systemd-Ziele werden durch `target units` repräsentiert. Target-Units haben die Endung `.target` und ihr einziger Zweck ist es, andere `Systemd`-Units in eine Kette von Abhängigkeiten zu gruppieren.

Beispielsweise startet die Unit `graphical.target`, die eine grafische Sitzung ausführt, Systemdienste wie den **GNOME-Anzeigemanager** (`gdm.service`) oder den **Kontendienst** (`accounts-daemon.service`) und aktiviert außerdem die Unit `multi-user.target`. Wenn Sie die Abhängigkeiten eines bestimmten „Ziels“ anzeigen müssen, führen Sie den Befehl `systemctl list-dependencies` aus. (Zum Beispiel `systemctl list-dependencies multi-user.target`).

`sysinit.target` und `basic.target` sind Checkpoints während des Startvorgangs. Obwohl eines der Designziele von `systemd` darin besteht, Systemdienste parallel zu starten, ist es notwendig, die „Ziele“ bestimmter Dienste und Funktionen zu starten, bevor andere Dienste und „Ziele“ gestartet werden. Jeder Fehler in `sysinit.target` oder `basic.target` führt dazu, dass die Initialisierung von `systemd` fehlschlägt. Zu diesem Zeitpunkt ist Ihr Terminal möglicherweise in den „Notfallmodus“ (`emergency.target`) gewechselt.

| Ziel-Einheit      | Beschreibung                                               |
| ----------------- | ---------------------------------------------------------- |
| poweroff.target   | Fährt das System herunter und schaltet es aus              |
| rescue.target     | Aktiviert eine Rescue-Shell                                |
| multi-user.target | Aktiviert ein Mehrbenutzersystem ohne grafische Oberfläche |
| graphical.target  | Aktiviert ein Mehrbenutzersystem mit grafischer Oberfläche |
| reboot.target     | Fährt das System herunter und startet es neu               |

#### The default target

So bestimmen Sie das standardmäßig verwendete Standardziel:

```bash
systemctl get-default
```

Dieser Befehl sucht nach dem Ziel des symbolischen Links unter `/etc/systemd/system/default.target` und zeigt das Ergebnis an.

```bash
$ systemctl get-default
graphical.target
```

Der Befehl `systemctl` kann auch eine Liste der verfügbaren Ziele liefern:

```bash
systemctl list-units --type target
UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
basic.target           loaded active active Basic System
bluetooth.target       loaded active active Bluetooth
cryptsetup.target      loaded active active Encrypted Volumes
getty.target           loaded active active Login Prompts
graphical.target       loaded active active Graphical Interface
local-fs-pre.target    loaded active active Local File Systems (Pre)
local-fs.target        loaded active active Local File Systems
multi-user.target      loaded active active Multi-User System
network-online.target  loaded active active Network is Online
network.target         loaded active active Network
nss-user-lookup.target loaded active active User and Group Name Lookups
paths.target           loaded active active Paths
remote-fs.target       loaded active active Remote File Systems
slices.target          loaded active active Slices
sockets.target         loaded active active Sockets
sound.target           loaded active active Sound Card
swap.target            loaded active active Swap
sysinit.target         loaded active active System Initialization
timers.target          loaded active active Timers
```

Um das System so zu konfigurieren, dass ein anderes Standardziel verwendet wird:

```bash
systemctl set-default name.target
```

Beispiel:

```bash
# systemctl set-default multi-user.target
rm '/etc/systemd/system/default.target'
ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
```

In der aktuellen Sitzung zu einer anderen Zieleinheit wechseln:

```bash
systemctl isolate name.target
```

Der Rettungsmodus `rescue mode` bietet eine einfache Umgebung, um Ihr System zu reparieren, falls es unmöglich ist, einen normalen Boot-Prozess durchzuführen.

Im `rescue mode` versucht das System, alle lokalen Dateisysteme zu mounten und mehrere wichtige Systemdienste zu starten, aktiviert jedoch keine Netzwerkschnittstelle und erlaubt anderen Benutzern nicht, gleichzeitig eine Verbindung zum System herzustellen.

Auf Rocky 8 ist der `Rescue Mode` äquivalent zum alten `Single User Mode` und erfordert das Root-Passwort.

Ändern Sie das aktuelle Ziel und rufen Sie den `rescue mode` in der aktuellen Sitzung auf:

```bash
systemctl rescue
```

Der **Notfallmodus** bietet eine minimalistische Umgebung, die Ihnen die Reparatur Ihres Systems ermöglicht, auch in Situationen, in denen das System nicht in den Rettungsmodus wechseln kann. Im Notfallmodus bindet das Betriebssystem das Root-Dateisystem mit der Option `read-only` ein. Es wird nicht versucht, ein anderes lokales Dateisystem einzubinden, keine Netzwerkschnittstelle zu aktivieren und einige essentielle Dienste zu starten.

Ändern Sie das aktuelle Ziel und aktivieren Sie den Notfallmodus in der aktuellen Sitzung:

```bash
systemctl emergency
```

#### Abschalten, Anhalten und Hibernation

Der `systemctl`-Befehl ersetzt eine Reihe von Power-Management-Befehlen, die in früheren Versionen verwendet wurden:

| Alter Befehl        | Neuer Befehl             | Beschreibung                                           |
| ------------------- | ------------------------ | ------------------------------------------------------ |
| `halt`              | `systemctl halt`         | Fährt das System herunter.                             |
| `poweroff`          | `systemctl poweroff`     | Schaltet das System aus.                               |
| `reboot`            | `systemctl reboot`       | Startet das System neu.                                |
| `pm-suspend`        | `systemctl suspend`      | Hält das System an.                                    |
| `pm-hibernate`      | `systemctl hibernate`    | Versetzt das System in den Ruhezustand.                |
| `pm-suspend-hybrid` | `systemctl hybrid-sleep` | Versetzt das System in den Ruhezustand und hält es an. |

### Der Prozess `journald`

Sie können Protokolldateien mit dem `journald`-Daemon verwalten, einer Komponente von `systemd`, zusätzlich zu rsyslogd</code>.

Der `journald`-Daemon ist für das Erfassen der folgenden Arten von Protokollmeldungen zuständig:

* Syslog-Meldungen
* Kernel-log-Meldungen
* Initramfs- und Systemstart-Logs
* Standardausgabe- (stdout) und Standardfehlerausgabe-Informationen (stderr) aller Dienste

Nach der Erfassung indiziert `journald` diese Protokolle und stellt sie den Benutzern über einen strukturierten Speichermechanismus zur Verfügung. Dieser Mechanismus speichert Protokolle im Binärformat, unterstützt die Verfolgung von Ereignissen in chronologischer Reihenfolge und bietet flexible Filter-, Such- und Ausgabefunktionen in mehreren Formaten (z. B. Text/JSON). Beachten Sie, dass `journald` die Protokollspeicherung nicht standardmäßig aktiviert. Das bedeutet, dass diese Komponente nur alle Protokolle seit dem Start speichert und aufzeichnet. Nach dem Neustart des Betriebssystems werden die historischen Protokolle gelöscht. Standardmäßig befinden sich alle temporär gespeicherten Protokolldateien im Verzeichnis **/run/log/journal/**.

### `journalctl` Befehl

Der Befehl `journalctl` wird verwendet, um im Binärformat gespeicherte Protokolldateien zu analysieren, z. B. um Protokolldateien anzuzeigen, Protokolle zu filtern und Ausgaben zu steuern.

```bash
journalctl
```

Wenn Sie den Befehl ohne weitere Optionen eingeben, ähnelt der Inhalt des Ausgabeprotokolls dem der Datei `/var/log/messages`, jedoch bietet `journalctl` die folgenden Verbesserungen:

* zeigt die Priorität der Einträge optisch gekennzeichnet
* zeigt die Umrechnung der Zeitstempel in die lokale Zeitzone Ihres Systems an
* alle protokollierten Daten werden angezeigt, einschließlich rotierende Protokolle
* zeigt die Markierung des Beginns eines Startvorgangs mit einer speziellen Linie an

#### Daueranzeige verwenden

Bei kontinuierlicher Anzeige werden Protokollmeldungen in Echtzeit angezeigt.

```bash
journalctl -f
```

Dieser Befehl gibt eine Liste der zehn letzten Log-Zeilen zurück. Das `journalctl`-Dienstprogramm läuft dann weiter und wartet auf neue Änderungen, bevor es diese sofort anzeigt.

#### Filtern von Nachrichten

Es ist möglich, verschiedene Filtermethoden anzuwenden, um Informationen zu extrahieren, die unterschiedlichen Bedürfnissen gerecht werden. Log-Meldungen werden häufig verwendet, um fehlerhaftes Verhalten im System zu verfolgen. So zeigen Sie Einträge mit einer ausgewählten oder höheren Priorität an:

```bash
journalctl -p priority
```

Sie müssen `priority` durch eines der folgenden Stichwörter (oder eine Zahl) ersetzen:

* debug (7),
* info (6),
* notice (5),
* warning (4),
* err (3),
* crit (2),
* alert (1),
* emerg (0).

Wenn Sie mehr über den Inhalt von Protokolldateien erfahren möchten, finden Sie ausführlichere Einführungen und Beschreibungen in [diesem Dokument](./17-log.md).
