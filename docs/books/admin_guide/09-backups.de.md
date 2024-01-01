---
title: Datensicherung
---

# Datensicherung

In diesem Kapitel erfahren Sie, wie Sie Ihre Daten mit GNU/Linux sichern und wiederherstellen.

****

**Ziele**: In diesem Kapitel lernen zukünftige Linux-Administratoren Folgendes:

:heavy_check_mark: die Befehle `tar` und `cpio` verwenden, um eine Sicherung zu erstellen;   
:heavy_check_mark: die Backups überprüfen und die Daten zurückstellen;   
:heavy_check_mark: die Backups komprimieren oder dekomprimieren.

:checkered_flag: **Backup**, **Wiederherstellung**, **Kompression**

**Vorkenntnisse**: :star: :star: :star:   
**Komplexität**: :star: :star:

**Lesezeit**: 41 Minuten

****

!!! note "Anmerkung"

    In diesem Kapitel verwenden die Kommando-Anweisungen „device“, um sowohl einen Zielspeicherort für die Sicherung als auch den Quellspeicherort für die Wiederherstellung anzugeben. Das „device“ kann entweder ein externes Medium oder eine lokale Datei sein. Sie sollten im Laufe des Kapitels ein Gefühl dafür bekommen, können aber bei Bedarf jederzeit zur Klärung auf diesen Hinweis zurückgreifen.

Die Sicherung wird der Anforderungen entsprechen, Daten sicher und effektiv zu speichern und wiederherzustellen.

Mit dem Backup können Sie sich vor Folgendem schützen:

* **Zerstörung**: mutwillig oder versehentlich. Menschlich oder technisch. Malware, ...
* **Löschen**: mutwillig oder versehentlich. Menschlich oder technisch. Malware, ...
* **Integrität**: Daten sind unbrauchbar.

Kein System ist unfehlbar, kein Mensch ist unfehlbar, also um Datenverlust zu vermeiden, müssen Backups durchgeführt werden, um nach einem Problem di Daten wiederherstellen zu können.

Die Sicherungsmedien sollten in einem anderen Raum (oder Gebäude) als dem Server aufbewahrt werden, damit im Falle eines Desaster der Server und die Sicherungen nicht gleichzeitig zerstört werden.

Darüber hinaus muss der Administrator regelmäßig überprüfen, ob die Medien noch lesbar sind.

## Allgemeines

Es gibt zwei grundsätzliche Sicherungsarten: das **Backup** und das **Archiv**.

* Das Archiv zerstört die Informationsquelle nach der Operation.
* Die Sicherung bewahrt die Informationsquelle nach der Operation.

Diese Operationen bestehen darin, Informationen in einer Datei, auf einem Peripheriegerät oder einem unterstützten Datenträger (Tapes, Disks, ...) zu speichern.

### Der Prozess

Sicherungen erfordern viel Disziplin und Strenge vom Systemadministrator. Es ist notwendig, folgende Fragen zu stellen:

* Was ist das geeignete Medium?
* Was sollte gesichert werden?
* Wie viele Kopien?
* Wie lange wird die Sicherung dauern?
* Welche Methode?
* Wie oft?
* Automatisch oder manuell?
* Wo speichern?
* Wie lange wird die Datensicherung erhalten bleiben?

### Sicherungsmethoden

* **Komplett**: ein oder mehrere **Dateisysteme** werden gesichert (Kernel, Daten, Dienstprogramme, ...).
* **Partiell**: Eine oder mehrere **Dateien** werden gesichert (Konfigurationen, Verzeichnisse, ...).
* **Differenzial**: Es werden nur Dateien gespeichert, die seit der letzten **Vollsicherung** geändert wurden.
* **Inkrementelle**: Nur Dateien, die seit der letzten Sicherung geändert wurden.

### Periodizität

* **Voraktuelle**: zu einer bestimmten Zeit (vor einer Systemaktualisierung, ...).
* **Periodisch**: Täglich, wöchentlich, monatlich, ...

!!! tip "Hinweis"

    Vor einer Systemänderung kann es nützlich sein, ein Backup zu erstellen. Es hat jedoch keinen Sinn, täglich Daten zu sichern, die nur jeden Monat geändert werden.

### Wiederherstellungsmethoden

Abhängig von den verfügbaren Dienstprogrammen wird es möglich sein, mehrere Arten von Restaurierungen durchzuführen.

* **vollständige Restaurierung**: Verzeichnisse, ...
* **Selektive Wiederherstellung**: Teil des Baumes, Dateien, ...

Es ist möglich, ein ganzes Backup wiederherzustellen, aber es ist auch möglich, nur einen Teil davon wiederherzustellen. Beim Wiederherstellen eines Verzeichnisses werden jedoch die nach der Sicherung erstellten Dateien nicht gelöscht.

!!! tip "Hinweis"

    Um ein Verzeichnis wiederherzustellen, wie es zum Zeitpunkt der Sicherung war, ist es notwendig, den Inhalt vollständig zu löschen, bevor die Wiederherstellung gestartet wird.

### Die Werkzeuge

Es gibt viele Hilfsprogramme, um Backups zu erstellen.

* **Editorwerkzeuge**;
* **grafische Tools**;
* **Kommandozeilenwerkzeuge**: `tar`, `cpio`, `pax`, `dd`, `dump`, ...

Die Befehle, die wir hier verwenden werden sind `tar` und `cpio`.

* `tar`:
  * einfach zu bedienen;
  * erlaubt das Hinzufügen von Dateien zu einem bestehenden Backup.
* `cpio`:
  * behält Eigentümer;
  * behält Gruppen, Datum und Rechte;
  * überspringt defekte Dateien;
  * komplettes Dateisystem.

!!! note "Anmerkung"

    Diese Befehle speichern in einem proprietären und standardisierten Format.

### Namenskonvention

Durch die Verwendung einer Namenskonvention ist es möglich, den Inhalt einer Backup-Datei schnell zu steuern und so gefährliche Restaurierungen zu vermeiden.

* Name des Verzeichnisses;
* benutztes Tool;
* verwendete Option;
* Datum.

!!! tip "Hinweis"

    Der Name der Datensicherung muss ein expliziter Name sein.

!!! note "Anmerkung"

    Das Konzept der Erweiterung unter GNU/Linux existiert nicht. Mit anderen Worten, wir verwenden hier Erweiterungen für den menschlichen Operator. Wenn der Systemadministrator zum Beispiel eine `.tar.gz` oder `.tgz` Dateierweiterung sieht, dann weiß er, wie man mit der Datei umgeht.

### Inhalt eines Backups

Eine Sicherung enthält in der Regel folgende Elemente:

* die Datei;
* der Name;
* der Eigentümer;
* die Größe;
* die Berechtigungen;
* Zugriffsdatum.

!!! note "Anmerkung"

    Die `inode` Nummer fehlt.

### Speichermodi

Es gibt zwei verschiedene Speicherarten:

* auf der Festplatte;
* Gerät.

## Tape ArchiveR - `tar`

Der `tar` Befehl erlaubt das Speichern auf mehreren aufeinanderfolgenden Medien (Mehr-Volumen Optionen).

Es ist möglich, das ganze oder einen Teil eines Backups zu extrahieren.

`tar` sichert implizit im relativen Modus, auch wenn der Pfad der zu sichernden Informationen im absoluten Modus angegeben wird. Sicherungen und Restaurierungen sind jedoch im absoluten Modus möglich.

### Wiederherstellungsrichtlinien

Die richtigen Fragen, die gestellt werden müssen:

* was: teilweise oder vollständig;
* wo: der Ort, an dem die Daten wiederhergestellt werden;
* wie: absolut oder relativ.

!!! warning "Warnung"

    Vor einer Restaurierung ist es wichtig, sich Zeit zu nehmen, um über die geeignetste Methode nachzudenken und zu bestimmen, um Fehler zu vermeiden.

Die Wiederherstellung erfolgt in der Regel, nachdem ein Problem aufgetreten ist, das schnell behoben werden muss. Eine schlechte Wiederherstellung kann die Situation in einigen Fällen noch verschlimmern.

### Sichern mit `tar`

Das Standardwerkzeug zum Erstellen von Sicherungen auf UNIX-Systemen ist der `tar` Befehl. Diese Backups können durch `bzip2` komprimiert werden, `xz`, `lzip`, `lzma`, `lzop`, `gzip`, `compress` oder `zstd`.

`tar` erlaubt es Ihnen, eine einzelne Datei oder ein Verzeichnis aus einem Backup zu extrahieren, dessen Inhalt anzusehen oder seine Integrität zu überprüfen.

#### Die Größe eines Backups schätzen

Der folgende Befehl schätzt die Größe in Kilobytes einer möglichen _tar_ Datei:

```
$ tar cf - /directory/to/backup/ | wc -c
20480
$ tar czf - /directory/to/backup/ | wc -c
508
$ tar cjf - /directory/to/backup/ | wc -c
428
```

!!! warning "Warnhinweis"

    Achtung, das Vorhandensein von "-" in der Kommandozeile stört das Programm `zsh`. Zu `bash` wechseln!

#### Namens-Konvention für ein `tar` Backup

Hier ist ein Beispiel für die Namenskonvention für ein `tar` Backup, in dem Wissen, dass das Datum dem Namen hinzugefügt werden soll.

| Optionen | Dateien | Suffix           | Funktion                                         |
| -------- | ------- | ---------------- | ------------------------------------------------ |
| `cvf`    | `home`  | `home.tar`       | `/home` im relativen Modus, unkomprimierte Form  |
| `cvfP`   | `/etc`  | `etc.A.tar`      | `/etc` im absoluten Modus, keine Komprimierung   |
| `cvfz`   | `usr`   | `usr.tar.gz`     | `/usr` im relativen Modus, _gzip_ Komprimierung  |
| `cvfj`   | `usr`   | `usr.tar.bz2`    | `/usr` im relativen Modus, _bzip2_ Komprimierung |
| `cvfPz`  | `/home` | `home.A.tar.gz`  | `home` im absoluten Modus, _gzip_ Komprimierung  |
| `cvfPj`  | `/home` | `home.A.tar.bz2` | `home` im absoluten Modus, _bzip2_ Komprimierung |
| …        |         |                  |                                                  |

#### Ein Backup erstellen

##### Ein Backup im relativen Modus erstellen

Das Erstellen einer nicht komprimierten Sicherung im relativen Modus erfolgt mit den `cvf` Optionen:

```
tar c[vf] [device] [file(s)]
```

Ein Beispiel:

```
[root]# tar cvf /backups/home.133.tar /home/
```


| Option | Beschreibung                                                |
| ------ | ----------------------------------------------------------- |
| `c`    | Erstellt eine Sicherung.                                    |
| `v`    | Verbose, zeigt den Namen der verarbeiteten Dateien an.      |
| `f`    | Ermöglicht Ihnen den Namen des Backups (-Medium) anzugeben. |

!!! tip "Hinweis"

    Der Bindestrich (`-`) vor den `tar` Optionen ist nicht nötig!

##### Backup im absoluten Modus erstellen

Ein nicht-komprimiertes Backup wird explizit im absoluten Modus mit den `cvfP` Optionen erstellt:

```
$ tar c[vf]P [device] [file(s)]
```

Beispiel:

```
[root]# tar cvfP /backups/home.133.P.tar /home/
```

| Option | Beschreibung                         |
| ------ | ------------------------------------ |
| `P`    | Backup im absoluten Modus erstellen. |


!!! warning "Warnhinweis"

    Mit dem `P`-Key muss der Pfad der zu sichernden Dateien als **absolute** eingegeben werden. Wenn die beiden Bedingungen (Schlüssel `P` und Pfad **absolute**) nicht angegeben sind, befindet sich das Backup im relativen Modus.

##### Ein komprimiertes Backup mit `gzip` erstellen

Das Erstellen einer komprimierten Sicherung mit `gzip` erfolgt mit den `cvfz` Optionen:

```
$ tar cvzf backup.tar.gz dirname/
```

| Option | Beschreibung                         |
| ------ | ------------------------------------ |
| `z`    | Komprimiert die Sicherung in _gzip_. |


!!! note "Anmerkung"

    Die Erweiterung `.tgz` ist gleichbedeutend mit `.tar.gz`.

!!! note "Anmerkung"

    Das Behalten der `cvf` (`tvf` oder `xvf`) Optionen unverändert für alle Backup-Operationen und das einfache Hinzufügen der Komprimierungsoption zum Ende macht den Befehl einfacher zu verstehen (z.B., `cvfz` oder `cvfj`, etc.).

##### Ein komprimiertes Backup mit `bzip` erstellen

Das Erstellen einer komprimierten Sicherung mit `bzip` erfolgt mit den Optionen `cvfj`:

```
$ tar cvfj backup.tar.bz2 dirname/
```

| Option | Beschreibung                         |
| ------ | ------------------------------------ |
| `j`    | Komprimiert das Backup nach _bzip2_. |

!!! note "Anmerkung"

    Die Erweiterungen `.tbz` und `.tb2` entsprechen die `.tar.bz2` Erweiterungen.

##### Komprimierung `compress`, `gzip`, `bzip2`, `lzip` und `xz`

Die Komprimierung und damit die Dekomprimierung werden Auswirkungen auf den Ressourcenverbrauch (Zeit und CPU-Auslastung) haben.

Hier ist ein Ranking der Komprimierung einer Reihe von Textdateien, von am wenigsten effizient bis am effizientesten:

- compress (`.tar.Z`)
- gzip (`.tar.gz`)
- bzip2 (`.tar.bz2`)
- lzip (`.tar.lz`)
- xz (`.tar.xz`)

#### Eine Datei oder Verzeichnis zu einer bestehenden Sicherung hinzufügen

Es ist möglich, ein oder mehrere Elemente zu einer bestehenden Datensicherung hinzuzufügen.

```
tar {r|A}[key(s)] [device] [file(s)]
```

Um `/etc/passwd` zum Backup `/backups/home.133.tar` hinzuzufügen:

```
[root]# tar rvf /backups/home.133.tar /etc/passwd
```

Das Hinzufügen eines Verzeichnisses ist ähnlich. Hier soll `dirtoadd` zu `backup_name.tar` hinzugefügt werden:

```
$ tar rvf backup_name.tar dirtoadd
```

| Option | Beschreibung                                                                                        |
| ------ | --------------------------------------------------------------------------------------------------- |
| `r`    | Fügt eine oder mehrere Dateien am Ende einer direkten Mediensicherung (Festplatte) hinzu.           |
| `A`    | Fügt eine oder mehrere Dateien am Ende eines Backups auf sequentiellen Zugriffsmedien (Band) hinzu. |

!!! note "Anmerkung"

    Es ist nicht möglich, Dateien oder Ordner zu einer komprimierten Sicherung hinzuzufügen.

    ```
    $ tar rvfz backup.tgz filetoadd
    tar: Cannot update compressed archives
    Try `tar --help' or `tar --usage' for more information.
    ```

!!! note "Anmerkung"

    Wenn die Sicherung im relativen Modus durchgeführt wurde, fügen Sie Dateien au h im relativen Modus hinzu. Wenn die Sicherung im absoluten Modus durchgeführt wurde, fügen Sie Dateien im absoluten Modus hinzu.
    
    Das Mischen von Modi kann bei der Wiederherstellung zu Problemen führen.

#### Inhalt eines Backups auflisten

Das Betrachten des Inhalts einer Sicherung ohne Extrahieren ist möglich.

```
tar t[key(s)] [device]
```

| Option | Beschreibung                                               |
| ------ | ---------------------------------------------------------- |
| `t`    | Zeigt den Inhalt einer Sicherung (komprimiert oder nicht). |

Beispiele:

```
$ tar tvf backup.tar
$ tar tvfz backup.tar.gz
$ tar tvfj backup.tar.bz2
```

When the number of files in a backup becomes large, it is possible to _pipe_ the result of the `tar` command to a _pager_ (`more`, `less`, `most`, etc.):

```
$ tar tvf backup.tar | less
```

!!! tip "Hinweis"

    Um den Inhalt eines Backups aufzulisten oder abzurufen, ist es nicht notwendig, den Komprimierungsalgorithmus anzugeben, der bei der Erstellung des Backups verwendet wurde. Das heißt, ein `tar tvf` entspricht `tar tvfj`, um den Inhalt zu lesen, und ein `tar xvf` entspricht `tar xvfj`, beim Extrahieren.

!!! tip "Hinweis"

    Überprüfen Sie immer den Inhalt eines Backups.

#### Integrität eines Backups überprüfen

Die Integrität eines Backups kann bei der Erstellung mit der Option `W` getestet werden:

```
$ tar cvfW file_name.tar dir/
```

Die Integrität eines Backups kann nach der Erstellung mit der Option `d` getestet werden:

```
$ tar vfd file_name.tar dir/
```

!!! tip "Hinweis"

    Durch Hinzufügen eines zweiten `v` zum vorherigen Schlüssel, erhalten Sie die Liste der archivierten Dateien sowie die Unterschiede zwischen den archivierten und den im Dateisystem vorhandenen Dateien.

    ```
    $ tar vvfd  /tmp/quodlibet.tar .quodlibet/
    drwxr-x--- rockstar/rockstar     0 2021-05-21 00:11 .quodlibet/
    -rw-r--r-- rockstar/rockstar     0 2021-05-19 00:59 .quodlibet/queue
    […]
    -rw------- rockstar/rockstar  3323 2021-05-21 00:11 .quodlibet/config
    .quodlibet/config: Mod time differs
    .quodlibet/config: Size differs
    […]
    ```

Die Option `W` wird auch verwendet, um den Inhalt eines Archivs mit dem Dateisystem zu vergleichen:

```
$ tar tvfW file_name.tar
Verify 1/file1
1/file1: Mod time differs
1/file1: Size differs
Verify 1/file2
Verify 1/file3
```

Die Überprüfung mit der Option `W` kann nicht mit einem komprimierten Archiv durchgeführt werden. Die Option `d` muss verwendet werden:

```
$ tar dfz file_name.tgz
$ tar dfj file_name.tar.bz2
```

#### Aus einem Backup (_untar_) Dateien extrahieren

Extrahieren (_untar_) eines `*.tar` Backup wird mit den `xvf` Optionen gemacht:

Extrahieren Sie die `etc/exports` Datei aus dem `/savings/etc.133.tar` Backup in das `etc` Verzeichnis des aktiven lokalen Verzeichnisses:

```
$ tar xvf /backups/etc.133.tar etc/exports
```

Extrahieren Sie alle Dateien aus der komprimierten Sicherung `/backups/home.133.tar.bz2` in das aktive lokale Verzeichnis:

```
[root]# tar xvfj /backups/home.133.tar.bz2
```

Entpacken Sie alle Dateien aus dem Backup `/backups/etc.133.P.tar` in das ursprüngliche Verzeichnis des Backups:

```
$ tar xvfP /backups/etc.133.P.tar
```

!!! warning "Warnhinweis"

    Gehen Sie zur richtigen Stelle.
    
    Prüfen Sie den Inhalt des Backups.

| Option | Beschreibung                                                       |
| ------ | ------------------------------------------------------------------ |
| `x`    | Extrahieren Sie Dateien aus der Sicherung, komprimiert oder nicht. |


Das Entpacken eines _tar-gzipped_ (`*.tar.gz`) Backups erfolgt mit den `xvfz` Optionen:

```
$ tar xvfz backup.tar.gz
```

Das Entpacken eines _tar-bzipped_ (`*.tar.bz2`) Backups erfolgt mit den `xvfj` Schlüsseln:

```
$ tar xvfj backup.tar.bz2
```

!!! tip "Hinweis"

    Um den Inhalt eines Backups zu extrahieren oder aufzulisten, ist es nicht notwendig, den Komprimierungsalgorithmus zu erwähnen, mit dem das Backup erstellt wurde. Das heißt, ein `tar xvf` entspricht `tar xvfj`, um den Inhalt zu extrahieren, und ein `tar tvf` entspricht `tar tvfj`, der Liste entsprechend.

!!! warning "Warnhinweis"

    Um die Dateien in ihrem ursprünglichen Verzeichnis wiederherzustellen (Schlüssel `P` eines `tar xvf`), sollten Sie das Backup mit dem absoluten Pfad erzeugt haben. Das heißt, mit dem `P`-Schlüssel eines `tar cvf`.

##### Nur eine Datei aus einem _tar_ Backup extrahieren

Um eine bestimmte Datei aus einem _tar_ Backup zu extrahieren, geben Sie den Namen der Datei am Ende des `tar xvf` Befehls an.

```
$ tar xvf backup.tar /path/to/file
```

Der vorherige Befehl extrahiert nur die `/path/to/file` Datei aus der `backup.tar` Sicherung. Diese Datei wird im Verzeichnis `/path/to/` wiederhergestellt, das im aktiven Verzeichnis erstellt oder bereits vorhanden ist.

```
$ tar xvfz backup.tar.gz /path/to/file
$ tar xvfj backup.tar.bz2 /path/to/file
```

##### Ordner aus einem Backup mit _tar_ extrahieren

Um nur ein Verzeichnis (einschließlich seiner Unterverzeichnisse und Dateien) aus einem Backup zu extrahieren, geben Sie den Verzeichnisnamen am Ende des `tar xvf` Befehls an.

```
$ tar xvf backup.tar /path/to/dir/
```

Um mehrere Verzeichnisse zu extrahieren, geben Sie jeden der Namen nacheinander an:

```
$ tar xvf backup.tar /path/to/dir1/ /path/to/dir2/
$ tar xvfz backup.tar.gz /path/to/dir1/ /path/to/dir2/
$ tar xvfj backup.tar.bz2 /path/to/dir1/ /path/to/dir2/
```

##### Extrahieren Sie eine Gruppe von Dateien aus einem _tar_ Backup mit regulären Ausdrücken (_regex_)

Geben Sie einen regulären Ausdruck (_regex_) an, um die Dateien zu extrahieren, die dem angegebenen Auswahlmuster entsprechen.

Zum Beispiel, um alle Dateien mit der Endung `.conf` zu extrahieren:

```
$ tar xvf backup.tar --wildcards '*.conf'
```

keys:

  * **--wildcards *.conf** entspricht Dateien mit der Endung `.conf`.

## _CoPy Input Output_ - `cpio`

Der `cpio` Befehl erlaubt das Speichern auf mehreren aufeinanderfolgenden Medien, ohne irgendwelche Optionen anzugeben.

Es ist möglich, das ganze oder einen Teil eines Backups zu extrahieren.

Im Gegensatz zum `tar` Befehl gibt es keine Möglichkeit, gleichzeitig zu sichern und zu komprimieren. So geschieht es in zwei Schritten: Backup und Kompression.

Um ein Backup mit `cpio`durchzuführen, müssen Sie eine Liste der zu sichernden Dateien angeben.

Diese Liste wird mit den Befehlen `find`, `ls` oder `cat` zur Verfügung gestellt.

* `find` : Durchsucht einen Baum, rekursiv oder nicht;
* `ls` : listet ein Verzeichnis auf, rekursiv oder nicht;
* `cat` : liest eine Datei mit den zu speichernden Verzeichnis-Bäumen oder Dateien aus.

!!! note "Anmerkung"

    `ls` kann nicht mit `-l` (Details) oder `-R` (rekursiv) verwendet werden.
    
    Es erfordert eine einfache Liste von Namen.

### Backup mit dem `cpio` Befehl erstellen

Syntax des `cpio` Befehls:

```
[files command |] cpio {-o| --create} [-options] [<file-list] [>device]
```

Beispiel:

Mit einer Umleitung der Ausgabe von `cpio`:

```
$ find /etc | cpio -ov > /backups/etc.cpio
```

Den Namen eines Backup-Mediums verwenden:

```
$ find /etc | cpio -ovF /backups/etc.cpio
```

Das Ergebnis des `find` Befehls wird als Eingabe an den `cpio` Befehl über eine _Pipe_ gesendet (Zeichen `|`, <kbd>AltGr</kbd> + <kbd>6</kbd>).

Hier liefert der Befehl `find /etc` eine Liste von Dateien, die dem Inhalt des `/etc` Verzeichnis entsprechen (rekursiv) an den Befehl `cpio` welches die Sicherung ausführt.

Vergessen Sie nicht das Zeichen `>` beim Speichern oder das Zeichen `F save_name_cpio`.

| Option | Beschreibung                                           |
| ------ | ------------------------------------------------------ |
| `-o`   | Erstellt ein Backup (_output_).                        |
| `-v`   | Verbose, zeigt den Namen der verarbeiteten Dateien an. |
| `-F`   | Legt das zu ändernde Backup fest (Medium).             |

Sicherungskopie mit Medium:

```
$ find /etc | cpio -ov > /dev/rmt0
```

Das Medium kann mehrere Arten gehören:

* tape drive: `/dev/rmt0`;
* eine Partition: `/dev/sda5`, `/dev/hda5`, etc.

### Art der Datensicherung

#### Datensicherung mit relativem Pfad

```
$ cd /
$ find etc | cpio -o > /backups/etc.cpio
```

#### Datensicherung mit absoluter Pfad

```
$ find /etc | cpio -o > /backups/etc.A.cpio
```

!!! warning "Warnhinweis"

    Wenn der im `find`-Befehl angegebene Pfad **absolut** ist, wird das Backup als **absolut** durchgeführt.
    
    Wenn der im `find`-Befehl angegebene Pfad **relativ** ist, dann wird das Backup als **relativ** durchgeführt.

### Zur Datensicherung hinzufügen

```
[files command |] cpio {-o| --create} -A [-options] [<fic-list] {F|>device}
```

Beispiel:

```
$ find /etc/shadow | cpio -o -AF SystemFiles.A.cpio
```

Das Hinzufügen von Dateien ist nur auf Medien mit direktem Zugriff möglich.

| Option | Beschreibung                                               |
| ------ | ---------------------------------------------------------- |
| `-A`   | Fügt einer Datensicherung eine oder mehrere Dateien hinzu. |
| `-F`   | Definiert die zu ändernde Datensicherung.                  |

### Datensicherung komprimieren

* Sichern **dann** komprimieren

```
$ find /etc | cpio  –o > etc.A.cpio
$ gzip /backups/etc.A.cpio
$ ls /backups/etc.A.cpio*
/backups/etc.A.cpio.gz
```

* Sichern **und** komprimieren

```
$ find /etc | cpio –o | gzip > /backups/etc.A.cpio.gz
```

Im Gegensatz zum `tar` Befehl gibt es keine Option, um gleichzeitig zu speichern und zu komprimieren. So geschieht es in zwei Schritten: speichern und dann komprimieren.

Die Syntax der ersten Methode ist leichter zu verstehen und sich zu erinnern, weil es in zwei Schritten getan wird.

Für die erste Methode wird die Sicherungsdatei automatisch von dem `gzip` Programm umbenannt, das `.gz` an das Ende des Dateinamens hinzufügt. Ebenso fügt das `bzip2` Programm `.bz2` automatisch hinzu.

### Den Inhalt einer Sicherung lesen

Syntax des `cpio` Befehls, um den Inhalt eines _cpio_ Backups zu lesen:

```
cpio -t [-options] [<fic-list]
```

Beispiel:

```
$ cpio -tv </backups/etc.152.cpio | less
```

| Option | Beschreibung              |
| ------ | ------------------------- |
| `-t`   | Liest ein Backup.         |
| `-v`   | Zeigt Datei-Attribute an. |

Nachdem Sie ein Backup erstellt haben, sollten Sie den Inhalt lesen, um sicher zu gehen, dass es keine Fehler gab.

Genauso müssen Sie vor einer Wiederherstellung den Inhalt der zu verwendenden Sicherung lesen.

### Backup wiederherstellen

Syntax des `cpio` Befehls, um eine Sicherung wiederherzustellen:

```
cpio {-i| --extract} [-E file] [-options] [<device]
```

Beispiel:

```
$ cpio -iv </backups/etc.152.cpio | less
```

| Option                       | Beschreibung                                                                    |
| ---------------------------- | ------------------------------------------------------------------------------- |
| `-i`                         | Wiederherstellen einer kompletten Sicherung.                                    |
| `-E file`                    | Stellt nur die Dateien wieder her, deren Name in der Datei enthalten ist.       |
| `--make-directories` or `-d` | Erstellt die fehlende Baumstruktur neu.                                         |
| `-u`                         | Ersetzt alle Dateien, auch wenn sie existieren.                                 |
| `--no-absolute-filenames`    | Ermöglicht die Wiederherstellung einer im absoluten Modus erstellten Sicherung. |

!!! warning "Warnhinweis"

    Standardmäßig zum Zeitpunkt der Wiederherstellung, Dateien auf der Festplatte, deren letztes Änderungsdatum jünger oder gleich dem Datum der Sicherung ist, werden nicht wiederhergestellt (um zu vermeiden, dass aktuelle Informationen mit älteren Informationen überschrieben werden).
    
    Die `u` Option hingegen erlaubt es, ältere Versionen der Dateien wiederherzustellen - ggf. neue zu überschreiben.

Beispiele:

* Absolute Wiederherstellung einer absoluten Sicherung

```
$ cpio –ivF home.A.cpio
```

* Absolute Wiederherstellung auf einer bestehenden Baumstruktur

Mit der Option `u` können Sie vorhandene Dateien an dem Ort überschreiben, an dem die Wiederherstellung stattfindet.

```
$ cpio –iuvF home.A.cpio
```

* Absolute Sicherung im relativen Modus wiederherstellen

Die lange Option `no-absolute-Dateinamen` erlaubt eine Wiederherstellung im relativen Modus. Tatsächlich wird das Zeichen `/` am Anfang des Pfades entfernt.

```
$ cpio --no-absolute-filenames -divuF home.A.cpio
```

!!! tip "Hinweis"

    Die Erstellung von Verzeichnissen ist vielleicht notwendig, daher die Verwendung der `d` Option

* Relative Sicherung wiederherstellen

```
$ cpio –iv <etc.cpio
```

* Absolute Wiederherstellung einer Datei oder eines Verzeichnisses

Die Wiederherstellung einer bestimmten Datei oder eines bestimmten Verzeichnisses erfordert die Erstellung einer Listendatei, die dann gelöscht werden sollte.

```
echo "/etc/passwd" > tmp
cpio –iuE tmp -F etc.A.cpio
rm -f tmp
```

## Komprimierung - Dekomprimierungsprogramme

Die Verwendung von Komprimierung zum Zeitpunkt einer Sicherung kann eine Reihe von Nachteilen mit sich ziehen:

* Verlängerung die Backup-Zeit sowie die Wiederherstellungszeit.
* Es macht es unmöglich, Dateien nachträglich zum Backup hinzuzufügen.

!!! note "Anmerkung"

    Es ist daher besser, ein Backup zu machen und erst dann es zu komprimieren, als es während des Backups zu komprimieren.

### Mit `gzip` komprimieren

Der `gzip` Befehl komprimiert Daten.

Syntax des `gzip` Befehls:

```
gzip [options] [file ...]
```

Beispiel:

```
$ gzip usr.tar
$ ls
usr.tar.gz
```

Die Datei bekommt die Endung `.gz`.

Es behält die gleichen Rechte und die gleichen letzten Zugriffsrechte und Änderungszeiten.

### Komprimieren mit `bunzip2`

Der `bunzip2` Befehl komprimiert auch Daten.

Syntax des `bzip2` Befehls:

```
bzip2 [options] [file ...]
```

Beispiel:

```
$ bzip2 usr.cpio
$ ls
usr.cpio.bz2
```

Der Dateiname erhält die Endung `.bz2`.

Komprimierung durch `bzip2` ist besser als Komprimierung durch `gzip`, aber es dauert länger bis sie ausgeführt worden ist.

### Dekomprimieren mit `gunzip`

Der `gunzip` Befehl dekomprimiert komprimierte Daten.

Syntax des `gunzip` Befehls:

```
gunzip [options] [file ...]
```

Beispiel:

```
$ gunzip usr.tar.gz
$ ls
usr.tar
```

Der Dateiname wird von `gunzip` abgeschnitten und die Endung `.gz` wird entfernt.

`gunzip` entpackt auch Dateien mit den folgenden Dateiendungen:

* `.z` ;
* `-z` ;
* `_z` .

### Dekomprimieren mit `bunzip2`

Der `bunzip2` Befehl dekomprimiert komprimierte Daten.

Syntax des `bzip2` Befehls:

```
bzip2 [options] [file ...]
```

Beispiel:

```
$ bunzip2 usr.cpio.bz2
$ ls
usr.cpio
```

Der Dateiname wird von `bunzip2` abgeschnitten und die Endung `.bz2` wird entfernt.

`bunzip2` entpackt auch die Datei mit den folgenden Dateiendungen:

* `-bz` ;
* `.tbz2` ;
* `tbz` .
