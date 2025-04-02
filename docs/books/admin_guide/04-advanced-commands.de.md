---
title: Erweiterte Linux-Kommandos
---

# Erweiterte Befehle für Linux-Benutzer

Erweiterte Befehle bieten eine bessere Anpassung und Steuerung in speziellen Situationen, sofern Sie mit den Grundbefehlen vertraut sind.

****

**Ziele**: In diesem Kapitel werden zukünftige Linux-Administratoren Folgendes lernen:

:heavy_check_mark: Einige nützliche Befehle, die im vorherigen Kapitel nicht enthalten sind;  
:heavy_check_mark: Einige erweiterte Befehle.

:checkered_flag: **Benutzerbefehle**, **Linux**

**Vorkenntnisse**: :star:  
**Schwierigkeitsgrad**: :star: :star: :star:

**Lesezeit**: 23 Minuten

****

## `uniq`-Befehl

Der `uniq` Befehl ist ein sehr mächtiger Befehl, der mit dem `sort` Befehl benutzt wird, insbesondere für die Analyse von Logdateien. Sie können Einträge sortieren und anzeigen, indem Sie Duplikate entfernen.

Um zu veranschaulichen, wie der `uniq` Befehl funktioniert, verwenden wir eine Datei `firstnames.txt` mit einer Liste von Vornamen:

```text
antoine
xavier
steven
patrick
xavier
antoine
antoine
steven
```

!!! note "Hinweis"

    `uniq` erfordert, dass die Eingabedatei sortiert wird, da sie nur aufeinander folgende Zeilen vergleicht.

Ohne Argument wird der `uniq` Befehl die gleichen Zeilen nicht anzeigen, die einander in der `firstnames.txt` Datei folgen:

```bash
$ sort firstnames.txt | uniq
antoine
patrick
steven
xavier
```

Um nur die Zeilen anzuzeigen, die nur einmal erscheinen, verwenden Sie die `-u` Option:

```bash
$ sort firstnames.txt | uniq -u
patrick
```

Um dagegen nur die Zeilen anzuzeigen, die mindestens zweimal in der Datei erscheinen, müssen Sie die `-d` Option verwenden:

```bash
$ sort firstnames.txt | uniq -d
antoine
steven
xavier
```

Um nur Zeilen zu löschen, die nur einmal erscheinen, verwenden Sie die `-D` Option:

```bash
$ sort firstnames.txt | uniq -D
antoine
antoine
antoine
steven
steven
xavier
xavier
```

Um schließlich die Anzahl der Vorkommnisse jeder Zeile zu zählen, verwenden Sie die `-c` Option:

```bash
$ sort firstnames.txt | uniq -c
      3 antoine
      1 patrick
      2 steven
      2 xavier
```

```bash
$ sort firstnames.txt | uniq -cd
      3 antoine
      2 steven
      2 xavier
```

## `xargs` Befehle

Der `xargs` Befehl erlaubt die Konstruktion und Ausführung von Befehlszeilen aus der Standardeingabe.

Der `xargs` Befehl liest Argumente von der Standardeingabe ein und führt den Befehl (`/bin/echo`) standardmäßig aus oder mehrere Male unter Verwendung der ursprünglichen Argumente aus, gefolgt von den Argumenten, die von der Standardeingabe gelesen werden.

Ein erstes und einfachstes Beispiel wäre Folgendes:

```bash
$ xargs
use
of
xargs
<CTRL+D>
use of xargs
```

Der `xargs` Befehl wartet auf eine Eingabe von **stdin**. Es werden drei Zeilen eingegeben. Das Ende der Benutzereingabe `xargs` wird durch die Tastaturfolge ++ctrl+d++ festgelegt. `xargs` führt dann den Standardbefehl `echo` aus, gefolgt von den drei Argumenten, die der Benutzereingabe entsprechen, nämlich:

```bash
$ echo "use" "of" "xargs"
use of xargs
```

Es ist möglich, einen Befehl anzugeben, der von `xargs` ausgeführt werden soll.

Im folgenden Beispiel führt `xargs` den Befehl `ls -ld` auf dem Satz von Ordnern aus, die in der Standardeingabe angegeben sind:

```bash
$ xargs ls -ld
/home
/tmp
/root
<CTRL+D>
drwxr-xr-x. 9 root root 4096  5 avril 11:10 /home
dr-xr-x---. 2 root root 4096  5 avril 15:52 /root
drwxrwxrwt. 3 root root 4096  6 avril 10:25 /tmp
```

In der Praxis führt das Kommando `xargs` den `ls -ld /home /tmp /root` Befehl aus.

Was passiert, wenn der auszuführende Befehl nicht mehrere Argumente akzeptiert, wie z. B. beim Befehl `find`?

```bash
$ xargs find /var/log -name
*.old
*.log
find: paths must precede expression: *.log
```

Das Kommando `xargs` versucht, den `find` Befehl mit mehreren Argumenten hinter der `-name` Option auszuführen, die `find` dazu veranlasst einen Fehler zu generieren:

```bash
$ find /var/log -name "*.old" "*.log"
find: paths must precede expression: *.log
```

In diesem Fall der `xargs` Befehl muss gezwungen werden, den `find` Befehl mehrmals auszuführen (einmal pro Zeile als Standardeingabe). Die `-L` Option gefolgt von einem **Integer** erlaubt es Ihnen, die maximale Anzahl an Einträgen, die mit dem Befehl gleichzeitig bearbeitet werden sollen, anzugeben:

```bash
$ xargs -L 1 find /var/log -name
*.old
/var/log/dmesg.old
*.log
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Wenn wir beide Argumente in der gleichen Zeile angeben wollten, müssen wir die `-n 1` Option verwenden:

```bash
$ xargs -n 1 find /var/log -name
*.old *.log
/var/log/dmesg.old
/var/log/boot.log
/var/log/anaconda.yum.log
/var/log/anaconda.storage.log
/var/log/anaconda.log
/var/log/yum.log
/var/log/audit/audit.log
/var/log/anaconda.ifcfg.log
/var/log/dracut.log
/var/log/anaconda.program.log
<CTRL+D>
```

Case Studie eines Backups mit einem `tar` basierend auf einer Suche:

```bash
$ find /var/log/ -name "*.log" -mtime -1 | xargs tar cvfP /root/log.tar
$ tar tvfP /root/log.tar
-rw-r--r-- root/root      1720 2017-04-05 15:43 /var/log/boot.log
-rw-r--r-- root/root    499270 2017-04-06 11:01 /var/log/audit/audit.log
```

Die Besonderheit des `xargs` Befehls ist, dass es das Eingabeargument am Ende des aufgerufenen Befehls erwartet. Dies funktioniert sehr gut mit dem obigen Beispiel, da die übergebenen Dateien die Liste der Dateien bilden, die dem Archiv hinzugefügt werden sollen.

Wenn wir nun das Beispiel des `cp` Kommandos nehmen und eine Liste von Dateien in ein Verzeichnis kopieren wollen, diese Liste der Dateien wird am Ende des Befehls hinzugefügt, aber was das `cp` Kommando am Ende des Befehls erwartet, ist das Ziel. Um dies zu tun, verwenden wir die Option `-I` um die Eingabeargumente irgendwo anders als am Ende der Zeile zu platzieren.

```bash
find /var/log -type f -name "*.log" | xargs -I % cp % /root/backup
```

Mit der Option `-I` können Sie ein Zeichen (in unserem Beispiel das `%` Zeichen) angeben, als Platzhalter für die Eingabedateien von `xargs`.

## Das Paket `yum-utils`

Das `yum-utils` Paket ist eine Sammlung von Werkzeugen verschiedener Autoren für `yum`, die es einfacher und leistungsfähiger machen.

!!! note "Anmerkung"

    Während `yum` in Rocky Linux 8 durch `dnf` ersetzt wurde der Paketname bleibt `yum-utils`, obwohl er auch als `dnf-utils` installiert werden kann. Dies sind klassische YUM Werkzeuge, die als CLI Shims auf DNF implementiert werden, um die Rückwärtskompatibilität mit `yum-3` zu gewährleisten.

Nachfolgend finden Sie einige Beispiele für diese Dienstprogramme.

### Das Kommando `repoquery`

Der Befehl `repoquery` wird verwendet, um die Pakete im Repository abzufragen.

Anwendungsbeispiele:

* Zeigt die Abhängigkeiten eines Pakets an (es kann ein installiertes oder nicht installiertes Softwarepaket sein), entspricht `dnf deplist <package-name>`

```bash
repoquery --requires <package-name>
```

* Zeigt die Dateien, die von einem installierten Paket bereitgestellt werden (funktioniert nicht für nicht installierte Pakete), äquivalent zu `rpm -ql <package-name>`

```bash
$ repoquery -l yum-utils
/etc/bash_completion.d
/etc/bash_completion.d/yum-utils.bash
/usr/bin/debuginfo-install
/usr/bin/find-repos-of-install
/usr/bin/needs-restarting
/usr/bin/package-cleanup
/usr/bin/repo-graph
/usr/bin/repo-rss
/usr/bin/repoclosure
/usr/bin/repodiff
/usr/bin/repomanage
/usr/bin/repoquery
/usr/bin/reposync
/usr/bin/repotrack
/usr/bin/show-changed-rco
/usr/bin/show-installed
/usr/bin/verifytree
/usr/bin/yum-builddep
/usr/bin/yum-config-manager
/usr/bin/yum-debug-dump
/usr/bin/yum-debug-restore
/usr/bin/yum-groups-manager
/usr/bin/yumdownloader
…
```

### `yumdownloader` Befehl

Der `yumdownloader` Befehl lädt RPM-Pakete aus den Repositories herunter.  Äquivalent zu `dnf download --downloadonly --downloaddir ./ package-name`

!!! note "Anmerkung"

    Dieser Befehl ist sehr nützlich, um schnell ein lokales Repository für einige rpms zu erstellen!

Beispiel: `yumdownloader` lädt das _samba_ rpm Paket und all seine Abhängigkeiten:

```bash
$ yumdownloader --destdir /var/tmp --resolve samba
oder
$ dnf download --downloadonly --downloaddir /var/tmp  --resolve  samba
```

| Option      | Beschreibung                                                           |
| ----------- | ---------------------------------------------------------------------- |
| `--destdir` | Die heruntergeladenen Pakete werden im angegebenen Ordner gespeichert. |
| `--resolve` | Lädt auch die Paket-Abhängigkeiten herunter.                           |

## Das Paket `psmisc`

Das `psmisc` Paket enthält Hilfsprogramme zur Verwaltung von Systemprozesse:

* `pstree`: Der `pstree` Befehl zeigt die aktuellen Prozesse auf dem System in einer baumartige Struktur an.
* `killall`: der `killall` Befehl sendet ein Kill Signal an alle Prozesse, die mit dem Namen identifiziert werden.
* `fuser`: der `fuser` Befehl identifiziert die `PID` von Prozessen, die die angegebenen Dateien oder Dateisysteme verwenden.

Beispiele:

```bash
$ pstree
systemd─┬─NetworkManager───2*[{NetworkManager}]
        ├─agetty
        ├─auditd───{auditd}
        ├─crond
        ├─dbus-daemon───{dbus-daemon}
        ├─firewalld───{firewalld}
        ├─lvmetad
        ├─master─┬─pickup
        │        └─qmgr
        ├─polkitd───5*[{polkitd}]
        ├─rsyslogd───2*[{rsyslogd}]
        ├─sshd───sshd───bash───pstree
        ├─systemd-journal
        ├─systemd-logind
        ├─systemd-udevd
        └─tuned───4*[{tuned}]
```

```bash
# killall httpd
```

Unterbricht die Prozesse (`-k` Option), die auf die Datei `/etc/httpd/conf/httpd.conf` zugreifen:

```bash
# fuser -k /etc/httpd/conf/httpd.conf
```

## `watch` Befehl

Der `watch` Befehl führt regelmäßig einen Befehl aus und zeigt das Ergebnis im Terminal im Vollbildmodus an.

Mit der Option `-n` können Sie die Anzahl der Sekunden zwischen jeder Ausführung des Befehls festlegen.

!!! note "Anmerkung"

    Um den `watch` Befehl zu verlassen, müssen Sie Folgendes eingeben: 
    ++control+c++, um den Prozess zu beenden.

Beispiele:

* Zeigt das Ende der `/etc/passwd` Datei alle 5 Sekunden an:

```bash
watch -n 5 tail -n 3 /etc/passwd
```

Ergebnis:

```bash
Every 5.0s: tail -n 3 /etc/passwd                                                                                                                                rockstar.rockylinux.lan: Thu Jul  1 15:43:59 2021

sssd:x:996:993:User for sssd:/:/sbin/nologin
chrony:x:995:992::/var/lib/chrony:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
```

* Überwachung der Anzahl der Dateien in einem Ordner:

```bash
watch -n 1 'ls -l | wc -l'
```

* Uhr anzeigen:

```bash
watch -t -n 1 date
```

## `install` Befehl

Im Gegensatz zu dem, was der Name vermuten lässt, wird der Befehl `install` nicht zur Installation von Paketen verwendet.

Der Befehl kombiniert das Kopieren von Dateien (`cp`) und das Erstellen von Ordnern (`mkdir`) sowie die Zugriffsverwaltung (`chmod`, `chown`) und andere nützliche Funktionen (wie Backups).

```bash
install source dest
install -t directory source [...]
install -d directory
```

Optionen:

| Option                        | Beschreibung                                                          |
| ----------------------------- | --------------------------------------------------------------------- |
| `-b` oder `--backup[=suffix]` | ein Backup der Ziel-Datei erstellen.                                  |
| `-d`                          | Argumente als Directory-Namen behandeln                               |
| `-D`                          | Erstellen aller Hauptkomponenten, bevor QUELLE nach ZIEL kopiert wird |
| `-g` und `-o`                 | Eigentümer-Eigenschaft setzen.                                        |
| `-m`                          | Berechtigungen setzen                                                 |
| `-p`                          | Datum und Uhrzeit der ursprünglichen Dateien behalten                 |
| `-t`                          | kopiert alle Quellargumente in den Ordner                             |

!!! note "Anmerkung"

    Es gibt auch Optionen um den SELinux-Kontext zu verwalten (siehe man install).

Beispiele:

Mit der Option `-d` ein Verzeichnis anlegen:

```bash
install -d ~/samples
```

Quelldatei in einen Ordner kopieren:

```bash
install src/sample.txt ~/samples/
```

Diese beiden Anweisungen können auch mit einem einzigen Kommando bewerkstelligt werden:

```bash
$ install -v -D -t ~/samples/ src/sample.txt
install: creating directory '~/samples'
'src/sample.txt' -> '~/samples/sample.txt'
```

Dieses Kommando spart Zeit. Kombiniert Eigentümer-, Eigentümergruppen- und Rechteverwaltung zur Verbesserung und Zeitersparnis:

```bash
sudo install -v -o rocky -g users -m 644 -D -t ~/samples/ src/sample.txt
```

!!! note "Anmerkung"

     In diesem Fall ist `sudo` notwendig, um die Eigenschaften zu ändern.

Sie können mit der Option `-b` auch ein Backup vorhandener Dateien erstellen:

```bash
$ install -v -b -D -t ~/samples/ src/sample.txt
'src/sample.txt' -> '~/samples/sample.txt' (archive: '~/samples/sample.txt~')
```

Wie Sie sehen, erstellt der Befehl `install` eine Sicherung, indem er eine Tilde `~` an den ursprünglichen Dateinamen anfügt.

Das Suffix kann mit der Option `-S` festgelegt werden:

```bash
$ install -v -b -S ".bak" -D -t ~/samples/ src/sample.txt
'src/sample.txt' -> '~/samples/sample.txt' (archive: '~/samples/sample.txt.bak')
```

## Das Kommando `tree`

Anzeigen der Dateien oder Verzeichnisse innerhalb eines Verzeichnisses in einer Baumansicht.

| Optionen | Beschreibung                                              |
|:-------- |:--------------------------------------------------------- |
| `-a`     | Alle Dateien werden gelistet                              |
| `-h`     | Zeigt die Größe verständlicher an                         |
| `-u`     | Zeigt den Dateieigentümer oder die UID-Nummer an          |
| `-g`     | Zeigt den Besitzer der Dateigruppe oder die GID-Nummer an |
| `-p`     | Zeigt die Datei-Privilegien an                            |

Zum Beispiel:

```bash
$ tree -hugp /etc/yum.repos.d/
/etc/yum.repos.d/
├── [-rw-r--r-- root     root      1.6K]  epel-modular.repo
├── [-rw-r--r-- root     root      1.3K]  epel.repo
├── [-rw-r--r-- root     root      1.7K]  epel-testing-modular.repo
├── [-rw-r--r-- root     root      1.4K]  epel-testing.repo
├── [-rw-r--r-- root     root       710]  Rocky-AppStream.repo
├── [-rw-r--r-- root     root       695]  Rocky-BaseOS.repo
├── [-rw-r--r-- root     root      1.7K]  Rocky-Debuginfo.repo
├── [-rw-r--r-- root     root       360]  Rocky-Devel.repo
├── [-rw-r--r-- root     root       695]  Rocky-Extras.repo
├── [-rw-r--r-- root     root       731]  Rocky-HighAvailability.repo
├── [-rw-r--r-- root     root       680]  Rocky-Media.repo
├── [-rw-r--r-- root     root       680]  Rocky-NFV.repo
├── [-rw-r--r-- root     root       690]  Rocky-Plus.repo
├── [-rw-r--r-- root     root       715]  Rocky-PowerTools.repo
├── [-rw-r--r-- root     root       746]  Rocky-ResilientStorage.repo
├── [-rw-r--r-- root     root       681]  Rocky-RT.repo
└── [-rw-r--r-- root     root      2.3K]  Rocky-Sources.repo

0 directories, 17 files
```

## Das Kommando `stat`

Der Befehl `stat` zeigt den Status einer Datei oder eines Dateisystems an.

```bash
$ stat /root/anaconda-ks.cfg
  File: /root/anaconda-ks.cfg
  Size: 1352            Blocks: 8          IO Block: 4096   regular file
Device: 10302h/66306d   Inode: 2757097     Links: 1
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2024-01-20 13:04:57.012033583 +0800
Modify: 2023-09-25 14:04:48.524760784 +0800
Change: 2024-01-24 16:37:34.315995221 +0800
 Birth: 2
```

* `File` – Zeigt den Pfad der Datei an.
* `Size` – Zeigt die Dateigröße in Bytes an. Wenn es sich um ein Verzeichnis handelt, werden die festen 4096 Bytes angezeigt, die der Verzeichnisname belegt.
* `Blocks` – Zeigt die Anzahl der zugewiesenen Blöcke an. Bitte beachten! Die Größe jedes Blocks in diesem Befehl beträgt 512 Byte. Die Standardgröße jedes Blocks in `ls -ls` beträgt 1024 Bytes.
* `Device` – Gerätenummer in dezimaler oder hexadezimaler Form.
* `Inode` – Ein Inode ist eine eindeutige Identifikationsnummer, die der Linux-Kernel einer Datei oder einem Verzeichnis zuordnet.
* `Links` - Anzahl Hard-Links. Hardlinks werden manchmal auch als physische Links bezeichnet.
* `Access` – Die letzte Zugriffszeit von Dateien und Verzeichnissen, d. h., `atime` in GNU/Linux.
* `Modify` – Der letzte Änderungszeitpunkt von Dateien und Verzeichnissen, d. h. `mtime` in GNU/Linux.
* `Change` – Der letzte Zeitpunkt der Änderung der Eigenschaft, d. h. `ctime` in GNU/Linux.
* `Birth` - Birth time (Zeitstempel der Kreation). In einigen Dokumenten wird es als `btime` oder `crtime` abgekürzt. Sie benötigen eine Dateisystem- und Kernelversion, die höher als eine bestimmte Version ist, um die Erstellungszeit anzuzeigen.

Im Kontext der Dateien:

**atime** – Nach dem Zugriff auf den Dateiinhalt mit Befehlen wie `cat`, `less`, `more` und `head` kann die `atime` der Datei aktualisiert werden. Bitte beachten! Die `atime` der Datei wird nicht in Echtzeit aktualisiert und man muss aus Leistungsgründen eine Zeit lang warten, bevor sie angezeigt werden kann. **mtime** – Durch Ändern des Dateiinhalts kann die `mtime` der Datei aktualisiert werden (z. B. durch Anhängen oder Überschreiben des Dateiinhalts durch Umleitung). Da die Dateigröße eine Eigenschaft der Datei ist, wird auch die `ctime` gleichzeitig aktualisiert. **ctime** – Durch Ändern des Eigentümers, der Gruppe, der Berechtigungen, der Dateigröße und der Links (Soft- und Hardlinks) der Datei wird `ctime` aktualisiert.

Im Kontext der Verzeichnisse:

**atime** – Nachdem Sie mit dem Befehl `cd` ein neues Verzeichnis aufgerufen haben, auf das noch nie zuvor zugegriffen wurde, können Sie die `atime` dieses Verzeichnisses aktualisieren und korrigieren. **mtime** – Durch Ausführen von Vorgängen wie Erstellen, Löschen und Umbenennen von Dateien in diesem Verzeichnis werden `mtime` und `ctime` des Verzeichnisses aktualisiert. **ctime** – Wenn sich die Berechtigungen, der Eigentümer, die Gruppe usw. eines Verzeichnisses ändern, wird die `ctime` des Verzeichnisses aktualisiert.

!!! tip "Hinweis"

    * Wenn Sie eine neue Datei oder ein neues Verzeichnis erstellen, sind dessen `atime`, `mtime` und `ctime` genau gleich
    * Wenn der Dateiinhalt geändert wird, werden `mtime` und `ctime` der Datei zwangsläufig aktualisiert.
    * Wenn im Verzeichnis eine brandneue Datei erstellt wird, werden `atime`, `ctime` und `mtime` dieses Verzeichnisses gleichzeitig aktualisiert.
    * Wenn die `mtime` eines Verzeichnisses aktualisiert wird, muss die `ctime` dieses Verzeichnisses aktualisiert werden.
