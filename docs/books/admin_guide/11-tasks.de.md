---
title: Task Management
---

# Task Management

In diesem Kapitel erfahren Sie, wie Sie geplante Aufgaben verwalten.

****

**Ziele**: In diesem Kapitel lernen zukünftige Linux-Administratoren Folgendes:

:heavy_check_mark: wie GNU/Linux die Aufgabenplanung implementiert;  
:heavy_check_mark: die Verwendung von **`cron`** auf bestimmte Benutzer beschränken;  
:heavy_check_mark: Aufgaben planen.

:checkered_flag: **crontab**, **crond**, **scheduling**, **linux**

**Vorwissen**: :star: :star:  
**Komplexität**: :star: :star:

**Lesezeit**: 17 Minuten

****

## Allgemeines

Die Zeitplanung der Aufgaben wird mit dem `cron` Tool verwaltet. Es ermöglicht die periodische Ausführung von Aufgaben.

Es ist dem Administrator für Systemaufgaben vorbehalten, kann aber von normalen Benutzern für Aufgaben oder Skripte verwendet werden, auf die sie selber Zugriff haben. Um auf das `cron` Tool zuzugreifen, verwenden wir: `crontab`.

Der `cron` Dienst wird verwendet für:

* Wiederholte Verwaltungsvorgänge;
* Sicherungen;
* Überwachung der Systemaktivität;
* Programmausführung.

Der Name `crontab` steht für **cron-Tabelle**, kann aber als Task-Planungstabelle angesehen werden.

!!! warning "Warnhinweis"

    Um einen Zeitplan mit crontab einzurichten, muss die richtige Systemzeit eingestellt werden.

## Wie der Dienst funktioniert

Der `cron`-Dienst wird durch einen `crond`-Daemon im Speicher ausgeführt.

Um seinen Status zu überprüfen:

```bash
[root] # systemctl status crond
```

!!! tip "Hinweis"

    Wenn der `crond`-Daemon nicht läuft, müssen Sie ihn manuell initialisieren und/oder beim Start automatisch starten. Selbst wenn Aufgaben geplant sind, werden sie nicht gestartet.

Initialisierung des `crond`-Daemons, Syntax:

```bash
[root]# systemctl {status|start|restart|stop} crond
```

Initialisierung des `crond`-Daemons beim Start:

```bash
[root]# systemctl enable crond
```

## Sicherheit

Um einen Zeitplan zu implementieren, muss ein Benutzer die Berechtigung haben, den `cron`-Dienst zu verwenden.

Diese Berechtigung hängt von den Informationen ab, die in den folgenden Dateien enthalten sind:

* `/etc/cron.allow`
* `/etc/cron.deny`

!!! warning "Warnhinweis"

    Wenn keine der beiden Dateien vorhanden ist, können alle Benutzer `cron` verwenden.

### Die `cron.allow` und `cron.deny` Dateien

Datei `/etc/cron.allow`

Nur Benutzer, die in dieser Datei enthalten sind, dürfen `cron` verwenden.

Wenn die Datei existiert und leer ist, können keine Benutzer `cron` verwenden.

!!! warning "Warnhinweis"

    Wenn `cron.allow` vorhanden ist, wird `cron.deny` **ignoriert**.

Datei `/etc/cron.deny`

Benutzer in dieser Datei dürfen `cron` nicht verwenden.

Wenn es leer ist, können alle Benutzer `cron` verwenden.

Standardmäßig existiert `/etc/cron.deny` und ist leer und `/etc/cron.allow` existiert nicht.

### Einen Benutzer zulassen

Nur **user1** kann `cron` verwenden.

```bash
[root]# vi /etc/cron.allow
user1
```

### Benutzer verbieten

Nur **user2** kann `cron` nicht verwenden.

```bash
[root]# vi /etc/cron.deny
user2
```

`cron.allow` darf nicht vorhanden sein.

## Aufgabenplanung - tasks scheduling

Wenn ein Benutzer eine Aufgabe plant, wird eine Datei mit seinem Namen unter `/var/spool/cron/` erstellt.

Diese Datei enthält alle Informationen, die der `crond` über alle von diesem Benutzer erstellten Aufgaben wissen muss, die Befehle oder Programme zum Ausführen und wann sie ausgeführt werden sollen (Stunde, Minute, Tag, ...).

![Cron tree](images/tasks-001.png)

### Der `crontab` Befehl

Der `crontab` Befehl wird verwendet, um die schedule-Datei zu verwalten.

```bash
crontab [-u user] [-e | -l | -r]
```

Beispiel:

```bash
[root]# crontab -u user1 -e
```

| Option | Beschreibung                                                      |
| ------ | ----------------------------------------------------------------- |
| `-e`   | Bearbeitet die schedule-Datei mit vi                              |
| `-l`   | Zeigt den Inhalt der schedule-Datei an                            |
| `-u`   | Name des Benutzers, dessen schedule-Datei manipuliert werden soll |
| `-r`   | Schedule-Datei löschen                                            |

!!! warning "Warnhinweis"

    `crontab` ohne Option löscht die alte schedule-Datei und wartet auf die Eingabe neuer Zeilen. Mit der Tastenkombination <kbd>ctrl</kbd> + <kbd>d</kbd> können Sie den Editiermodus verlassen.
    
    Nur `root` kann die `-u user` Option verwenden, um die schedule-Datei eines anderen Benutzers zu bearbeiten.
    
    Das obige Beispiel erlaubt root eine Aufgabe für user1 zu planen.

### Anwendungen von `crontab`

Die Anwendungen von `crontab` sind vielfältig und beinhalten:

* Änderungen an den `crontab` Dateien werden sofort berücksichtigt;
* Kein Neustart erforderlich.

Andererseits müssen folgende Punkte berücksichtigt werden:

* Das Programm muss autonom sein;
* Stellt Umleitungen bereit (stdin, stdout, stderr);
* Es ist nicht relevant, Befehle auszuführen, die Eingabe- und Ausgabeanfragen auf einem Terminal verwenden.

!!! note "Anmerkung"

    Es ist wichtig zu verstehen, dass der Zweck von Scheduling darin besteht, die Aufgaben automatisch auszuführen, ohne dass ein externes Eingreifen erforderlich ist.

## Die Datei `crontab`

Die Datei `crontab` ist nach folgenden Regeln strukturiert.

* Jede Zeile dieser Datei entspricht einem Schedule;
* Jede Zeile hat sechs Felder, 5 für die Zeit und 1 für die Aufgabe;
* Jedes Feld wird durch ein Leerzeichen oder einen Tabulatorzeichen getrennt;
* Jede Zeile endet mit einem Zeilenvorschub;
* Das Zeichen `#` am Anfang der Zeile kommentiert sie aus.

```bash
[root]# crontab –e
10 4 1 * * /root/scripts/backup.sh
1  2 3 4 5       6
```

| Feld | Beschreibung              | Details                   |
| ---- | ------------------------- | ------------------------- |
| 1    | Minute(n)                 | Von 0 bis 59              |
| 2    | Stunde(n)                 | Von 0 bis 23              |
| 3    | Tag(e) des Monats         | Von 1 bis 31              |
| 4    | Monat des Jahres          | Von 1 bis 12              |
| 5    | Tag(e) der Woche          | Von 0 bis 7 (0=7=Sonntag) |
| 6    | Die auszuführende Aufgabe | Befehl oder Skript        |

!!! warning "Warnhinweis"

    Die auszuführenden Aufgaben müssen absolute Pfade verwenden und wenn möglich Umleitungen verwenden.

Um die Schreibweise für die Definition der Zeit zu vereinfachen, ist es ratsam, spezielle Symbole zu verwenden.

| Wildcards | Beschreibung                    |
| --------- | ------------------------------- |
| `*`       | Alle möglichen Werte des Feldes |
| `-`       | Zeigt einen Wertebereich an     |
| `,`       | Zeigt eine Werteliste an        |
| `/`       | Definiert einen Schritt         |

Beispiele:

Skript ausgeführt am 15. April um 10:25 Uhr:

```bash
25 10 15 04 * /root/scripts/script > /log/…
```

Starte jeden Tag um 11 Uhr und dann um 16 Uhr:

```bash
00 11,16 * * * /root/scripts/script > /log/…
```

Jeden Tag von 11:00 bis 16:00 Uhr:

```bash
00 11-16 * * * /root/scripts/script > /log/…
```

Alle 10 Minuten während der üblichen Geschäftszeiten:

```bash
*/10 8-17 * * 1-5 /root/scripts/script > /log/…
```

Für den Root-Benutzer hat `crontab` auch einige spezielle Zeiteinstellungen:

| @Option   | Beschreibung                                                          |
| --------- | --------------------------------------------------------------------- |
| @reboot   | Task beim Neustart des Systems ausführen                              |
| @hourly   | Task jede Stunde ausführen                                            |
| @daily    | Der Task läuft täglich unmittelbar nach Mitternacht                   |
| @weekly   | Der Task läuft jeden Sonntag kurz nach Mitternacht                    |
| @monthly  | Task wird am ersten Tag des Monats direkt nach Mitternacht ausgeführt |
| @annually | Der Task läuft am 1. Januar unmittelbar nach Mitternacht              |

### Ausführungsprozess des Tasks

Ein Benutzer, rockstar, möchte seine `crontab` Datei bearbeiten:

1. `crond` prüft, ob er berechtigt ist (`/etc/cron.allow` und `/etc/cron.deny`).

2. Falls er berechtigt ist, bearbeitet er seine `crontab` Datei (`/var/spool/cron/rockstar`).

    Die schedule-Dateien werden jede Minute von `crond` gelesen.

3. `crond` führt die geplanten Aufgaben aus.

4. Es aktualisiert systematisch eine Protokolldatei (`/var/log/cron`).
