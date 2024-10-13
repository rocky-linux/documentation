---
title: Prozessverwaltung
---

# Prozessverwaltung

In diesem Kapitel erfahren Sie, wie Sie mit Prozessen arbeiten.

****

**Ziele**: In diesem Kapitel lernen zukünftige Linux-Administratoren Folgendes:

:heavy_check_mark: die `PID` und `PPID` eines Prozesses erkennen;  
:heavy_check_mark: Prozesse anschauen und durchsuchen;  
:heavy_check_mark: Prozesse verwalten.

:checkered_flag: **Prozess**, **Linux**

**Vorkenntnisse**: :star: :star:  
**Komplexität**: :star:

**Lesezeit**: 23 Minuten

****

## Allgemeines

Ein laufendes Betriebssystem besteht aus Prozessen. Diese Prozesse werden in einer bestimmten Reihenfolge ausgeführt und sind miteinander verknüpft. Es gibt zwei Kategorien von Prozessen, die sich auf die Benutzerumgebung und auf die Hardware-Umgebung konzentrieren.

Wenn ein Programm läuft, startet das System einen Prozess, indem es die Programmdaten und den Programmcode im Speicher platziert und einen **Runtime-Stack** erstellt. Ein Prozess ist daher eine Instanz eines Programms mit der dazugehörigen Prozessorumgebung (Ordinalzähler, Register, usw...) und Speicherumgebung.

Jeder Prozess wird durch Folgendes charakterisiert:

* eine _PID_: ***P**rocess **ID**entifier*, ein eindeutiger Prozess-Identifikator
* *PPID*: ***P**arent **P**rozess **ID**entifikator*, eindeutige Kennung des Elternprozesses

Durch aufeinanderfolgende Vererbung ist der `init`-Prozess der Vater aller Prozesse.

* Ein Prozess wird immer von einem übergeordneten Prozess abgeleitet
* Ein übergeordneter Prozess kann mehrere Child-Prozesse haben.

Es gibt eine Parent-/Child-Beziehung zwischen Prozessen. Ein Kindprozess ist das Ergebnis des Elternprozesses, der die Primitive *fork()* aufruft und seinen eigenen Code dupliziert, um ein Kind zu erstellen. Die *PID* des Kindes wird an den Elternprozess zurückgegeben, damit es mit ihm kommunizieren kann. Jedes Kind hat eine Eltern-Identifikation, die *PPID*.

Die *PID*-Nummer repräsentiert den Prozess zum Zeitpunkt der Ausführung. Wenn der Prozess beendet ist, steht die Nummer für einen anderen Prozess wieder zur Verfügung. Wenn Sie den gleichen Befehl mehrmals ausführen, wird jedes Mal eine andere *PID*-Nummer erzeugt.<!-- TODO !\[Parent/child relationship between processes\](images/FON-050-001.png) -->!!! note "Anmerkung"

    Prozesse dürfen nicht mit _threads_ verwechselt werden. Jeder Prozess hat seinen eigenen Speicher-Kontext (Ressourcen und Adressraum), während _threads_ aus demselben Prozess diesen Kontext gemeinsam teilen.

## Prozesse anzeigen

Das Kommando `ps` zeigt den Status laufender Prozesse an.

```bash
ps [-e] [-f] [-u login]
```

Beispiel:

```bash
# ps -fu root
```

| Option     | Beschreibung                         |
| ---------- | ------------------------------------ |
| `-e`       | Zeigt alle Prozesse an.              |
| `-f`       | Zeigt die gesamten Informationen an. |
| `-u` login | Zeigt die Prozesse des Benutzers an. |

Einige zusätzliche Optionen:

| Option                | Beschreibung                                            |
| --------------------- | ------------------------------------------------------- |
| `-g`                  | Zeigt die Prozesse aus der Gruppe an.                   |
| `-t tty`              | Zeigt die Prozesse, die vom Terminal ausgeführt werden. |
| `-p PID`              | Zeigt die Prozessinformation an.                        |
| `-H`                  | Zeigt die Informationen als Baumstruktur an.            |
| `-l`                  | Zeigt ausführliche Information an.                      |
| `--sort COL`          | Sortiert das Ergebnis nach einer Spalte.                |
| `--headers`           | Zeigt den Header auf jeder Seite des Terminals an.      |
| `--format "%a %b %c"` | Passt das Ausgabeformat an.                             |

Ohne Angabe einer Option zeigt der Befehl `ps` nur Prozesse an, die vom aktuellen Terminal ausgeführt werden.

Das Ergebnis wird in Spalten angezeigt:

```bash
# ps -ef
UID PID PPID C STIME TTY TIME CMD
root 1 0 Jan01 ?   00:00/03  /sbin/init
```

| Spalte  | Beschreibung                          |
| ------- | ------------------------------------- |
| `UID`   | Besitzer.                             |
| `PID`   | Prozess IDentifikationsnummer.        |
| `PPID`  | Parent-Prozess IDentifikationsnummer. |
| `C`     | Priorität des Prozesses.              |
| `STIME` | Datum und Uhrzeit der Ausführung.     |
| `TTY`   | Ausführungsterminal.                  |
| `TIME`  | Dauer der Bearbeitung.                |
| `CMD`   | Befehl ausgeführt.                    |

Das Verhalten der Steuerung kann vollständig angepasst werden:

```bash
# ps -e --format "%P %p %c %n" --sort ppid --headers
 PPID   PID COMMAND          NI
    0     1 systemd           0
    0     2 kthreadd          0
    1   516 systemd-journal   0
    1   538 systemd-udevd     0
    1   598 lvmetad           0
    1   643 auditd           -4
    1   668 rtkit-daemon      1
    1   670 sssd              0
```

## Arten von Prozessen

Der Benutzerprozess:

* wird von einem Terminal gestartet, das einem Benutzer zugeordnet ist;
* hat Zugriff auf Ressourcen über Anfragen oder Daemons.

Der Systemprozess (*daemon*):

* wird vom System gestartet;
* ist keinem Terminal zugeordnet und gehört einem Systembenutzer (oft `root`);
* wird beim Booten geladen, befindet sich im Speicher und wartet auf einen Aufruf;
* wird normalerweise durch den Buchstaben `d` identifiziert, der dem Prozessnamen assoziiert ist.

Systemprozesse werden daher als 'Daemon's bezeichnet (***D**isk **A**nd **E**xecution **MON**itor*).

## Berechtigungen und Rechte

Wenn ein Kommando ausgeführt wird, werden die Zugangsdaten des Benutzers an den erzeugten Prozess übergeben.

Standardmäßig sind die aktuelle `UID` und `GID` (des Prozesses) daher identisch mit der **tatsächlichen** `UID` und `GID` (die `UID` und `GID` des Benutzers, der den Befehl ausgeführt hat).

Wenn eine `SUID` (und/oder `SGID`) für einen Befehl gesetzt wird, wird die tatsächliche `UID` (und/oder `GID`) die des Eigentümers (und/oder der Eigentümergruppe) des Befehls und nicht mehr die des Benutzers oder der Benutzergruppe, die den Befehl ausgelöst hat. Effektive und echte **UIDs** sind daher **verschieden**.

Jedes Mal, wenn auf eine Datei zugegriffen wird, prüft das System die Rechte des Prozesses anhand seiner effektiven Identifikatoren.

## Prozessverwaltung

Ein Prozess kann nicht auf unbestimmte Zeit ausgeführt werden, da dies zu Lasten anderer laufender Prozesse würde und Multitasking verhindern würde.

Die gesamte Bearbeitungszeit ist daher in kleine Bereiche unterteilt und jeder Prozess (mit einer Priorität) greift sequenziell auf den Prozessor zu. Der Prozess wird mehrere Zustände während seiner Ausführung durchlaufen:

* ready: Warten auf die Verfügbarkeit des Prozesses;
* in execution: Zugriff auf den Prozessor;
* suspended: Warten auf I/O (Eingabe/Ausgabe);
* stopped: Warte auf ein Signal von einem anderen Prozess;
* zombie: Anfrage zur Zerstörung
* dead: Der Parent-Prozesse beendet den Child-Prozess.

Das Ende vom Prozesss läuft wie folgt ab:

1. Schließen der offenen Dateien;
2. Freigabe des verwendeten Speichers;
3. Ein Signal an die Eltern- und Kindprozesse senden.

Wenn ein Elternprozess nicht mehr existiert, werden seine Kinder als Orphan bezeichnet. Sie werden dann durch den `init`-Prozess übernommen, der sie beendet.

### Die Priorität eines Prozesses

GNU/Linux gehört zur Familie der Time-Sharing-Betriebssysteme. Prozessoren arbeiten im Time-Sharing-Verfahren, und jeder Prozess nimmt etwas Prozessorzeit in Anspruch. Prozesse werden nach Priorität klassifiziert:

* Echtzeitprozess: Der Prozess mit der Priorität **0-99** wird durch einen Echtzeit-Scheduling-Algorithmus geplant.
* Gewöhnliche Prozesse: Prozesse mit dynamischen Prioritäten von **100–139** werden mithilfe eines vollständig fairen Schedulings-Algorithmus geplant.
* Nice-Wert: ein Parameter, mit dem die Priorität eines normalen Prozesses angepasst wird. Der Wertebereich liegt zwischen **-20** und **19**.

Die Standardpriorität eines Prozesses ist **0**.

### Betriebsmodi

Prozesse können auf zwei Arten ausgeführt werden:

* **synchronous**: Der Benutzer verliert den Zugriff auf die Shell während der Ausführung des Befehls. Die Eingabeaufforderung erscheint am Ende der Prozessausführung wieder.
* **asynchronous**: Der Prozess wird im Hintergrund verarbeitet. Die Eingabeaufforderung wird sofort wieder angezeigt.

Die Einschränkungen des asynchronen Modus:

* der Befehl oder das Skript darf nicht auf die Eingabe der Tastatur warten;
* der Befehl oder das Skript darf kein Ergebnis auf dem Bildschirm zurückgeben;
* das Beenden der Shell beendet den Prozess.

## Prozessmanagement Kommandos

### `kill` Befehl

Der `kill` Befehl sendet ein Stoppsignal an einen Prozess.

```bash
kill [-signal] PID
```

Beispiel:

```bash
kill -9 1664
```

| Code | Signal    | Beschreibung                                                                                                 |
| ---- | --------- | ------------------------------------------------------------------------------------------------------------ |
| `2`  | *SIGINT*  | Sofortige Beendigung des Prozesses                                                                           |
| `9`  | *SIGKILL* | Den Prozess unterbrechen (++control+"d"++)                                                                   |
| `15` | *SIGTERM* | Bereinigung und Beenden des Prozesses                                                                        |
| `18` | *SIGCONT* | Prozess fortsetzen. Prozesse, die durch das Signal SIGSTOP gestoppt wurden, können dank SIGCONT weiterlaufen |
| `19` | *SIGSTOP* | Prozess unterbrechen (Stop process). Die Wirkung dieses Signals entspricht ++ctrl+"z"++                      |

Signale sind das Mittel der Kommunikation zwischen den Prozessen. Der `kill` Befehl sendet ein Signal an einen Prozess.

!!! tip "Hinweis"

    Die komplette Liste der Signale, die vom `kill` Befehl unterstüzt werden, kann durch folgendes Kommando ausgegeben werden:

    ```
    $ man 7 signal
    ```

### `nohup` Befehl

`nohup` erlaubt das Starten eines Prozesses unabhängig von einer Verbindung.

```bash
nohup Befehl
```

Beispiel:

```bash
nohup myprogram.sh 0</dev/null &
```

Durch `nohup` wird das `SIGHUP` Signal ignoriert, das gesendet wird, wenn ein Benutzer sich ausloggt.

!!! note "Hinweis"

    `nohup` behandelt Standard-Ausgabe und -Fehler, aber keine Standardeingabe, daher die Umleitung dieser Eingabe nach `/dev/null`.

### [Ctrl] + [z]

Durch gleichzeitiges Drücken der ++control+"z"++ Tasten wird der Synchronprozess vorübergehend unterbrochen. Der Zugriff auf die Eingabeaufforderung wird wiederhergestellt, nachdem die Nummer des gerade unterbrochenen Prozesses angezeigt wurde.

### `&` Anweisung

Die Anweisung `&` führt den Befehl asynchron aus (der Befehl wird dann *job* genannt) und zeigt die Id-Nummer vom *job* an. Der Zugriff auf die Eingabeaufforderung wird zurückgestellt.

Beispiel:

```bash
$ time ls -lR / > list.ls 2> /dev/null &
[1] 15430
$
```

Die *Job*-Nummer wird während der Hintergrundverarbeitung abgerufen und in eckigen Klammern angezeigt, gefolgt von der `PID`-Nummer.

### `fg` und `bg` Befehle

Der `fg` Befehl stellt den Prozess in den Vordergrund:

```bash
$ time ls -lR / > list.ls 2>/dev/null &
$ fg 1
time ls -lR / > list.ls 2/dev/null
```

während der Befehl `bg` ihn im Hintergrund platziert:

```bash
[CTRL]+[Z]
^Z
[1]+ Stopped
$ bg 1
[1] 15430
$
```

Ob es im Hintergrund gesetzt wurde, als es mit dem `&` Argument oder später mit der Tastenkombination ++control+"z"++ erstellt wurde, kann ein Prozess mit dem Befehl `fg` und seiner Jobnummer wieder in den Vordergrund gebracht werden.

### `jobs` Befehl

Der Befehl `jobs` zeigt die Liste der im Hintergrund laufenden Prozesse an und gibt deren Jobnummer an.

Beispiel:

```bash
$ jobs
[1]- Running    sleep 1000
[2]+ Running    find / > arbo.txt
```

Die Spalten repräsentieren:

1. Jobnummer;
2. die Reihenfolge in der die Prozesse ausgeführt werden:

   * ein `+` : Dieser Prozess ist der nächste Prozess, der standardmäßig mit `fg` oder `bg` ausgeführt wird;
   * ein `-` : Dieser Prozess ist der nächste Prozess, der die `+` übernimmt `+`

3. *Running* (laufender Prozess) oder *Stopped* (abgebrochener Prozess)
4. der Kommando

### `nice` und `renice` Befehle

Der Befehl `nice` erlaubt die Ausführung eines Befehls, wobei seine Priorität angegeben wird.

```bash
nice priority command
```

Beispiel:

```bash
nice -n+15 find / -name "file"
```

Anders als `root` kann ein Standardbenutzer die Priorität eines Prozesses nur reduzieren. Nur Werte zwischen +0 und +19 werden akzeptiert.

!!! tip "Hinweis"

    Diese letzte Einschränkung kann pro Benutzer oder pro Gruppe aufgehoben werden, indem die Datei `/etc/security/limits.conf` angepasst wird.

Mit dem `renice` Befehl können Sie die Priorität eines laufenden Prozesses ändern.

```bash
renice priority [-g GID] [-p PID] [-u UID]
```

Beispiel:

```bash
renice +15 -p 1664
```

| Option | Beschreibung                      |
| ------ | --------------------------------- |
| `-g`   | `GID` der Prozessbesitzer-Gruppe. |
| `-p`   | `PID` des Prozesses.              |
| `-u`   | `UID` des Prozess-Owner.          |

Der `renice` Befehl wirkt auf bereits laufende Prozesse. Es ist daher möglich, die Priorität eines bestimmten Prozesses, aber auch mehrerer Prozesse zu ändern, die einem Benutzer oder einer Gruppe angehören.

!!! tip "Hinweis"

    Der `pidof`-Befehl, kombiniert mit dem `xargs` Befehl (siehe den Kurs über erweiterte Befehle), erlaubt es, eine neue Priorität in einem einzigen Befehl anzuwenden:

    ```
    $ pidof sleep | xargs renice 20
    ```

### `top` Befehl

Der `top` Befehl zeigt die Prozesse und den Ressourcenverbrauch an.

```bash
$ top
PID  USER PR NI ... %CPU %MEM  TIME+    COMMAND
2514 root 20 0       15    5.5 0:01.14   top
```

| Spalte    | Beschreibung                   |
| --------- | ------------------------------ |
| `PID`     | Prozess IDentifikationsnummer. |
| `USER`    | Besitzer.                      |
| `PR`      | Prozesspriorität.              |
| `NI`      | Nice-Wert.                     |
| `%CPU`    | Prozessorlast                  |
| `%MEM`    | Speicherauslastung.            |
| `TIME+`   | Prozessor-Nutzungszeit.        |
| `COMMAND` | Befehl ausgeführt.             |

Der `top` Befehl erlaubt die Kontrolle der Prozesse in Echtzeit und im interaktiven Modus.

### `pgrep` und `pkill` Befehle

Der `pgrep` Befehl durchsucht die laufenden Prozesse nach einem Prozessnamen und zeigt auf der Standardausgabe die *PID* an, die den Auswahlkriterien entspricht.

Der Befehl `pkill` sendet das angegebene Signal (standardmäßig *SIGTERM*) an jeden Prozess.

```bash
pgrep process
pkill [option] [-signal] process
```

Beispiele:

* Prozessnummer von `sshd` ermitteln:

  ```bash
  pgrep -u root sshd
  ```

* Alle `tomcat` Prozesse endgültig beenden:

  ```bash
  pkill tomcat
  ```

!!! note "Anmerkung"

    Bevor Sie einen Prozess beenden, sollten Sie genau wissen, wozu er dient. Andernfalls kann es zu Systemabstürzen oder anderen unvorhersehbaren Problemen kommen.

Zusätzlich zum Senden von Signalen an die relevanten Prozesse kann der Befehl `pkill` auch die Verbindungssitzung des Benutzers entsprechend der Terminalnummer beenden, wie zum Beispiel:

```bash
pkill -t pts/1
```

### Das Kommando `killall`

Die Funktion dieses Befehls entspricht in etwa der des Befehls `pkill`. Die Syntax ist folgende — `killall [option] [ -s SIGNAL | -SIGNAL ] NAME`. Das Default-Signal ist *SIGTERM*.

| Option | Beschreibung                                                                            |
|:------ |:--------------------------------------------------------------------------------------- |
| `-l`   | listet sämtliche bekannten Signalnamen auf                                              |
| `-i`   | vor dem Schließen nach einer Bestätigung fragen                                         |
| `-I`   | Groß- und Kleinschreibung wird bei der Prozessnamenübereinstimmung nicht berücksichtigt |

Beispiel:

```bash
killall tomcat
```

### Das Kommando `pstree`

Dieser Befehl zeigt den Fortschritt baumartig an und wird wie folgt verwendet: `pstree [option]`.

| Option | Beschreibung                                          |
|:------ |:----------------------------------------------------- |
| `-p`   | Zeigt die PID des Prozesses an                        |
| `-n`   | sortiert die Ausgabe nach PID                         |
| `-h`   | hebt den aktuellen Prozess und seine Vorfahren hervor |
| `-u`   | zeigt UID-Übergänge                                   |

```bash
$ pstree -pnhu
systemd(1)─┬─systemd-journal(595)
           ├─systemd-udevd(625)
           ├─auditd(671)───{auditd}(672)
           ├─dbus-daemon(714,dbus)
           ├─NetworkManager(715)─┬─{NetworkManager}(756)
           │                     └─{NetworkManager}(757)
           ├─systemd-logind(721)
           ├─chronyd(737,chrony)
           ├─sshd(758)───sshd(1398)───sshd(1410)───bash(1411)───pstree(1500)
           ├─tuned(759)─┬─{tuned}(1376)
           │            ├─{tuned}(1381)
           │            ├─{tuned}(1382)
           │            └─{tuned}(1384)
           ├─agetty(763)
           ├─crond(768)
           ├─polkitd(1375,polkitd)─┬─{polkitd}(1387)
           │                       ├─{polkitd}(1388)
           │                       ├─{polkitd}(1389)
           │                       ├─{polkitd}(1390)
           │                       └─{polkitd}(1392)
           └─systemd(1401)───(sd-pam)(1404)
```

### Orphan- und Zombie-Prozesse

**verwaister Prozess**: Wenn ein übergeordneter Prozess stirbt, gelten seine untergeordneten Prozesse als Waisen. Der Init-Prozess übernimmt diese speziellen Statusprozesse und die Statuserfassung wird abgeschlossen, bis sie zerstört werden. Konzeptionell gesehen ist der `orphanage`-Prozess unproblematisch.

**Zombie-Prozess**: Nachdem ein untergeordneter Prozess seine Arbeit abgeschlossen und beendet wurde, muss sein übergeordneter Prozess die Signalverarbeitungsfunktion wait() oder waitpid() aufrufen, um den Beendigungsstatus des untergeordneten Prozesses abzurufen. Wenn der übergeordnete Prozess dies nicht tut, behält der untergeordnete Prozess, obwohl er bereits beendet wurde, dennoch einige Informationen zum Beendigungsstatus in der Systemprozesstabelle bei. Da der übergeordnete Prozess die Statusinformationen des untergeordneten Prozesses nicht abrufen kann, belegen diese Prozesse weiterhin Ressourcen in der Prozesstabelle. Prozesse in diesem Zustand bezeichnen wir als Zombies.

Hazard:

* Sie belegen Systemressourcen und ggf. führen zu einer Verringerung der Maschinenleistung.
* Es können keine neuen untergeordneten Prozesse generiert werden.

Wie können Sie das aktuelle System auf Zombie-Prozesse überprüfen?

```bash
ps -lef | awk '{print $2}' | grep Z
```

Diese Zeichen können in der Spalte erscheinen:

* **D** – ununterbrochener Zustand (normalerweise IO)
* **I** - Idle kernel thread
* **R** - läuft oder ausführbar (on run queue, Warteschleife)
* **S** – unterbrechbarer `sleep` (Warten auf ein Ereignis zum Abschluss)
* **T** - gestoppt durch `job control signal`
* **t** - vom Debugger während Tracing gestoppt
* **W** – Paging (nicht gültig seit dem 2.6.xx-Kernel)
* **X** - dead (sollte niemals vorkommen)
* **Z** - nicht mehr aktiver ("Zombie") Prozess, der beendet, aber nicht von seinem übergeordneten Prozess abgerufen wurde
