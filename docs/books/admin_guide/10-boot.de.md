---
title: System Startup
---

# System Startup

In diesem Kapitel erfahren Sie, wie das System startet.

****
**Ziele** : In diesem Kapitel werden zukünftige Linux-Administratoren Folgendes lernen:

:heavy_check_mark: Die verschiedenen Etappen des Boot-Prozesses;  
:heavy_check_mark: Wie Rocky Linux diesen Bootvorgang über GRUB2 und systemd unterstützt;  
:heavy_check_mark: Wie man GRUB2 vor einem Angriff schützt;  
:heavy_check_mark: Wie man die Dienste verwaltet;  
:heavy_check_mark: Wie man auf die Protokolle aus dem Journal - `journald` - zugreift.

:checkered_flag: **Benutzer**

**Vorkenntnisse**: :star: :star:  
**Komplexität**: :star: :star: :star:

**Lesezeit**: 23 Minuten
****

## Der Boot-Prozess

Es ist wichtig, den Bootprozess von Linux zu verstehen, um Probleme lösen zu können, die auftreten könnten.

Der Boot-Prozess enthält:

### Das BIOS-Startup

Das **BIOS** (Basic Input/Output System) führt das **POST** (Power on Self-Test) aus, um die Hardwarekomponenten des Systems zu ermitteln, zu testen und zu initialisieren.

Es lädt dann den **MBR** (Master Boot Record).

### Der Master Boot-Rekord (MBR)

Der Master Boot Rekord umfasst die ersten 512 Bytes der Boot-Festplatte. Der MBR ermittelt das Boot-Gerät und lädt den Bootloader **GRUB2** in den Speicher und überträgt die Steuerung dorthin.

Die nächsten 64 Bytes enthalten die Partitionstabelle der Festplatte.

### Der GRUB2-Bootloader

Der Standard-Bootloader für die Rocky 8 Distribution ist **GRUB2** (GRand Unified Bootloader). GRUB2 ersetzt den alten GRUB-Bootloader (auch GRUB Legacy).

Die GRUB2-Konfigurationsdatei befindet sich unter `/boot/grub2/grub.cfg` aber diese Datei sollte nicht direkt editiert werden.

Die GRUB2-Menükonfigurationseinstellungen befinden sich unter `/etc/default/grub` und werden verwendet, um die `grub.cfg` Datei zu erzeugen.

```bash
# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/swap crashkernel=auto rd.lvm.lv=rhel/root rhgb quiet net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
```

Wenn Änderungen an einem oder mehreren dieser Parameter vorgenommen werden, muss der `grub2-mkconfig` Befehl ausgeführt werden, um die Datei `/boot/grub2/grub.cfg` neu zu generieren.

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

Systemd ist das Parent aller Systemprozesse. Es liest das Ziel des `/etc/systemd/system/default.target` Links (z.B. `/usr/lib/systemd/system/multi-user.target`), um das Standardziel des Systems zu bestimmen. Die Datei definiert die zu startenden Dienste.

Systemd platziert das System dann in den definierten Ziel-Zustand, indem es die folgenden Initialisierungsaufgaben ausführt:

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
2. Zugriff auf die GRUB-Konsole verhindern - Wenn ein Angreifer es schafft, GRUB-Konsole zu verwenden, kann er seine Konfiguration ändern oder Informationen über das System sammeln, indem er den `cat` Befehl benutzt.
3. Den Zugriff auf unsichere Betriebssysteme verhindern. Wenn es einen Dual-Boot auf dem System gibt, kann ein Angreifer beim Booten ein Betriebssystem wie DOS auswählen, das Zugriffskontrollen und Dateiberechtigungen ignoriert.

Zum Passwortschutz des GRUB2 Bootloaders:

* `-unrestricted` aus der Haupt `CLASS=` Anweisung in der Datei `/etc/grub.d/10_linux` entfernen.

* Wenn noch kein Benutzer konfiguriert ist, verwenden Sie den `grub2-setpassword` Befehl, um ein Passwort für den root-Benutzer anzugeben:

```bash
# grub2-setpassword
```

Eine neue Datei `/boot/grub2/user.cfg` wird erzeugt, wenn sie nicht bereits vorhanden war. Es enthält das gehashte Passwort des GRUB2.

!!! note "Hinweis"

    Dieser Befehl unterstützt nur Konfigurationen mit einem einzigen root-Benutzer.

```bash
[root]# cat /boot/grub2/user.cfg
GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.CC6F56....A21
```

* Erstelle die neue Konfigurationsdatei mit dem `grub2-mkconfig` Befehl:

```bash
[root]# grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-327.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-327.el7.x86_64.img
Found linux image: /boot/vmlinuz-0-rescue-f9725b0c842348ce9e0bc81968cf7181
Found initrd image: /boot/initramfs-0-rescue-f9725b0c842348ce9e0bc81968cf7181.img
done
```

* Server neu starten und überprüfen.

Alle im GRUB-Menü definierten Einträge erfordern nun die Eingabe eines Benutzers und Passworts bei jedem Boot-Vorgang. Das System wird keinen Kernel ohne direkte Benutzereingriffe von der Konsole booten.

* Wenn der Benutzer angefordert wird, geben Sie bitte `root` ein;
* Wenn ein Passwort angefordert wird, geben Sie bitte das Passwort ein, das unter `grub2-setpassword` angegeben wurde.

Um nur die Bearbeitung von GRUB Menüeinträgen und den Zugriff auf die Konsole zu schützen, reicht die Ausführung des `grub2-setpassword` Befehls aus. Es kann Fälle geben, in denen Sie dafür gute Gründe haben. Dies trifft insbesondere auf ein entferntes Rechenzentrum zu, wo die Eingabe eines Passworts bei jedem Neustart eines Servers schwierig oder unmöglich ist.

## Systemd

*Systemd* ist ein Service Manager für Linux-Betriebssysteme.

Es wird entwickelt mit folgender Motivation:

* um mit älteren SysV-Initialisierungsskripten kompatibel zu bleiben,
* bietet viele Funktionen, wie zum Beispiel den parallelen Start von Systemdiensten beim Systemstart, On-Demand-Aktivierung von Daemons, Unterstützung für Snapshots oder Verwaltung von Abhängigkeiten zwischen Diensten.

!!! note "Anmerkung"

    Systemd ist das Standard-Initialisierungssystem seit RedHat/CentOS 7.

Systemd führt das Konzept der System-Units ein.

| Typ          | Dateiendung  | Beschreibung                                        |
| ------------ | ------------ | --------------------------------------------------- |
| Service unit | `.service`   | Systemdienst                                        |
| Target unit  | `.target`    | Eine Gruppe von System-Units                        |
| Mount unit   | `.automount` | Ein automatischer Einhängepunkt für ein Dateisystem |

!!! note "Anmerkung"

    Es gibt viele verschiedene Unit-Typen: Device unit, Mount unit, Path unit, Scope unit, Slice unit, Snapshot unit, Socket unit, Swap unit, Timer unit.

* Systemd unterstützt Systemzustands-Snapshots und dessen Wiederherstellung.

* Einhängepunkte - mount points - können als systemd-Ziele konfiguriert werden.

* Beim Start erstellt systemd lauschende Sockets für alle Systemdienste, die diese Art der Aktivierung unterstützen, und übergibt diese Sockets an diese Dienste, sobald sie gestartet werden. Dadurch ist es möglich, einen Dienst neu zu starten, ohne eine einzelne Nachricht zu verlieren, die das Netzwerk während seiner Unverfügbarkeit an ihn sendet. Der entsprechende Socket bleibt erreichbar und alle Nachrichten werden in der Warteschlange aufbewahrt.

* Systemdienste, die D-BUS für ihre Interprozess-Kommunikation nutzen, können bei Bedarf beim ersten Einsatz eines Clients gestartet werden.

* Systemd stoppt oder startet nur aktivierte Dienste. Frühere Versionen (vor RHEL7) versuchten, Dienste direkt zu beenden, ohne ihren aktuellen Status zu überprüfen.

* Systemdienste erben keinen Kontext (wie HOME und PATH Umgebungsvariablen). Jeder Dienst arbeitet in seinem eigenen Ausführungskontext.

Alle Service Unit Operationen unterliegen einem Standard-Timeout von 5 Minuten, um zu verhindern, dass ein fehlerhafter Service das System einfriert.

### Systemdienste verwalten

Service-Einheiten enden mit der Dateiendung `.service` und haben einen ähnlichen Zweck wie Initskripte. Der Befehl `systemctl` verwendet folgende Optionen `display`, `start`, `stop`, `restart` um die entsprechende Aktion auf Dienste anzuwenden:

| systemctl                                 | Beschreibung                                            |
| ----------------------------------------- | ------------------------------------------------------- |
| systemctl start *name*.service            | Dienst starten                                          |
| systemctl stop *name*.service             | Stoppt einen Dienst                                     |
| systemctl restart *name*.service          | Dienst neu starten                                      |
| systemctl reload *name*.service           | Konfiguration neu laden                                 |
| systemctl status *name*.service           | Prüft, ob ein Dienst läuft                              |
| systemctl try-restart *name*.service      | Starte einen Dienst nur dann neu, wenn er bereits läuft |
| systemctl list-units --type service --all | Zeigt den Status aller Dienste an                       |

Der `systemctl` Befehl wird auch für die Aktivierung - `enable` - oder Deaktivierung - `disable` - der Dienste und um die damit verbundenen Dienste anzeigen, verwendet:

| systemctl                                | Beschreibung                                                  |
| ---------------------------------------- | ------------------------------------------------------------- |
| systemctl enable *name*.service          | Dienst aktivieren                                             |
| systemctl disable *name*.service         | Dienst deaktivieren                                           |
| systemctl list-unit-files --type service | Listet alle Dienste und prüft, ob sie ausgeführt werden       |
| systemctl list-dependencies --after      | Listet die Dienste auf, die vor der angegebenen Unit beginnen |
| systemctl list-dependencies --before     | Zeigt die Dienste, die nach der angegebenen Unit starten      |

Beispiele:

```bash
systemctl stop nfs-server.service
# oder
systemctl stop nfs-server
```

Alle aktuell geladenen Units auflisten:

```bash
systemctl list-units --type service
```

Um alle Units aufzulisten, die überprüft werden sollen, ob sie aktiviert sind:

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

Bei Rocky8/RHEL8 wurde das Konzept der Runlevel durch systemd-Ziele ersetzt.

Systemd-Ziele werden durch target units repräsentiert. Target units haben die Endung `.target` und ihr einziger Zweck ist es, andere Systemd-Units in eine Kette von Abhängigkeiten zu gruppieren.

Beispielsweise startet die Unit `graphical.target`, die zum Starten einer grafischen Sitzung verwendet wird, Systemdienste wie den **GNOME display manager** (< code>gdm.service</code>) oder den **Kontendienst** (`accounts-daemon.service`) und aktiviert auch die `multi -user.target` Unit.

Ebenso startet die `multi-user.target`-Unit andere wichtige Systemdienste, wie z. B. **NetworkManager** (`NetworkManager.service` ) oder **D-Bus** (`dbus.service`) und aktiviert eine weitere Zielunit namens `basic.target`.

| Target Units      | Beschreibung                                               |
| ----------------- | ---------------------------------------------------------- |
| poweroff.target   | Fährt das System herunter und schaltet es aus              |
| rescue.target     | Aktiviert eine Rettungs-Shell                              |
| multi-user.target | Aktiviert ein Mehrbenutzersystem ohne grafische Oberfläche |
| graphical.target  | Aktiviert ein Mehrbenutzersystem mit grafischer Oberfläche |
| reboot.target     | Fährt das System herunter und startet es neu               |

#### The default target

Um festzustellen, welches Ziel standardmäßig verwendet wird:

```bash
systemctl get-default
```

Dieser Befehl sucht nach dem Ziel des symbolischen Links unter `/etc/systemd/system/default.target` und zeigt das Ergebnis an.

```bash
$ systemctl get-default
graphical.target
```

Der `systemctl` Befehl kann auch eine Liste der verfügbaren Ziele anzeigen:

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

Um das System so zu konfigurieren, dass es ein anderes default target verwendet:

```bash
systemctl set-default name.target
```

Beispiel:

```bash
# systemctl set-default multi-user.target
rm '/etc/systemd/system/default.target'
ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
```

Um zu einer anderen Ziel-Unit in der aktuellen Sitzung zu wechseln:

```bash
systemctl isolate name.target
```

Der **Rettungsmodus - rescue mode -** bietet eine einfache Umgebung, um Ihr System zu reparieren, falls es unmöglich ist, einen normalen Boot-Prozess durchzuführen.

Im `Rettungsmodus` versucht das System, alle lokalen Dateisysteme zu mounten und mehrere wichtige Systemdienste zu starten aktiviert aber keine Netzwerkschnittstelle oder erlaubt es anderen Benutzern, sich gleichzeitig mit dem System zu verbinden.

Bei Rocky 8 entspricht der `-Rettungsmodus` dem alten `Einzelbenutzermodus` und benötigt das root-Passwort.

Um das aktuelle Ziel zu ändern und `Rettungsmodus` in der aktuellen Sitzung zu wechseln:

```bash
systemctl rescue
```

**Notfallmodus** bietet die minimalistische Umgebung und ermöglicht die Reparatur des Systems auch in Situationen, in denen das System nicht in den Rettungsmodus versetzt werden kann. Im Notfallmodus wird das Root-Dateisystem nur zum Lesen eingehängt. Es wird nicht versuchen, ein anderes lokales Dateisystem zu mounten, keine Netzwerkschnittstelle zu aktivieren und wird nur einige wichtige Dienste starten.

Um das aktuelle Ziel zu ändern und in der aktuellen Sitzung in den Notfallmodus zu wechseln:

```bash
systemctl emergency
```

#### Abschalten, Anhalten und Ruhezustand

Der `systemctl` Befehl ersetzt eine Reihe von Power-Management-Befehlen, die in früheren Versionen verwendet wurden:

| Alter Befehl        | Neuer Befehl             | Beschreibung                          |
| ------------------- | ------------------------ | ------------------------------------- |
| `halt`              | `systemctl halt`         | Fährt das System herunter.            |
| `poweroff`          | `systemctl poweroff`     | Schaltet das System aus.              |
| `reboot`            | `systemctl reboot`       | Startet das System neu.               |
| `pm-suspend`        | `systemctl suspend`      | Hält das System an.                   |
| `pm-hibernate`      | `systemctl hibernate`    | Versezt das System im Ruhezustand.    |
| `pm-suspend-hybrid` | `systemctl hybrid-sleep` | Ruhezustand und Anhalten des Systems. |

### Der Prozess `journald`

Logdateien können zusätzlich zu `rsyslogd`, auch vom `journald` Daemon verwaltet werden, der eine Komponente von `systemd` ist.

Der `journald` Daemon erfasst Syslog Nachrichten, Kernel-Log-Nachrichten, Nachrichten von der ursprünglichen RAM-Festplatte und vom Start des Boots, sowie Nachrichten, die in die Standardausgabe und die Standardfehlerausgabe aller Dienste geschrieben werden, indiziert sie und stellt sie dem Benutzer zur Verfügung.

Das Format der nativen Log-Datei, die eine strukturierte und indizierte Binärdatei ist, verbessert die Suche und ermöglicht eine schnellere Bedienung, es speichert auch Metadateninformationen, wie Zeitstempel oder Benutzer-IDs.

### `journalctl` Befehl

Der `journalctl` Befehl zeigt die Logdateien an.

```bash
journalctl
```

Der Befehl listet alle auf dem System generierten Logdateien auf. Die Struktur dieser Ausgabe ist ähnlich wie in `/var/log/messages/` aber sie bietet einige Verbesserungen:

* die Priorität der Einträge ist visuell geprägt;
* Zeitstempel werden in die lokale Zeitzone Ihres Systems konvertiert;
* alle protokollierten Daten werden angezeigt, einschließlich rotierende Protokolle;
* der Anfang eines Starts ist mit einer speziellen Zeile gekennzeichnet.

#### Daueranzeige verwenden

Mit kontinuierlicher Anzeige werden Logmeldungen in Echtzeit angezeigt.

```bash
journalctl -f
```

Dieser Befehl gibt eine Liste der zehn letzten Einträge zurück. Das Dienstprogramm Journalctl läuft dann weiter und wartet auf neue Änderungen, bevor sie sofort angezeigt werden.

#### Filtern von Nachrichten

Es ist möglich, unterschiedliche Filtermethoden zu verwenden, um Informationen zu extrahieren, die unterschiedlichen Anforderungen entsprechen. Logmeldungen werden oft verwendet, um fehlerhaftes Verhalten auf dem System zu analysieren. Um Einträge mit einer ausgewählten oder höheren Priorität anzuzeigen:

```bash
journalctl -p priority
```

Sie müssen die Priorität durch eines der folgenden Stichwörter (oder eine Zahl) ersetzen:

* debug (7),
* info (6),
* notice (5),
* warning (4),
* err (3),
* crit (2),
* alert (1),
* und emerg (0).
