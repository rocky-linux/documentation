---
title: Erweiterte Linux-Kommandos
---

# Erweiterte Befehle für Linux-Benutzer

Erweiterte Befehle bieten eine bessere Anpassung und Steuerung in speziellen Situationen, sofern Sie mit den Grundbefehlen vertraut sind.

****

**Ziele**: In diesem Kapitel werden zukünftige Linux-Administratoren Folgendes lernen:

:heavy_check_mark: einige nützliche Befehle, die im vorherigen Kapitel nicht behandelt wurden. :heavy_check_mark: einige erweiterte Befehle.

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

    .

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
