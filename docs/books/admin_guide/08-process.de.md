---
title: Prozessverwaltung
---

# Prozessverwaltung

In diesem Kapitel erfahren Sie, wie Sie mit Prozessen arbeiten.

****

**Ziele**: In diesem Kapitel lernen zukünftige Linux-Administratoren Folgendes:

:heavy_check_mark: die `PID` und `PPID` eines Prozesss;   
erkennen :heavy_check_mark: Prozesse anschauen und durchsuchen;   
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

* eine _PID_: _**P**rocess **ID**entifier_, ein eindeutiger Prozess-Identifikator;
* _PPID_: _**P**arent **P**rozess **ID**entifikator_, eindeutige Kennung des Elternprozesses.

Durch aufeinanderfolgende Vererbung ist der `init`-Prozess der Vater aller Prozesse.

* Ein Prozess wird immer von einem übergeordneten Prozess abgeleitet;
* Ein übergeordneter Prozess kann mehrere Child-Prozesse haben.

Es gibt eine Parent-/Child-Beziehung zwischen Prozessen. Ein Kindprozess ist das Ergebnis des Elternprozesses, der die Primitive _fork()_ aufruft und seinen eigenen Code dupliziert, um ein Kind zu erstellen. Die _PID_ des Kindes wird an den Elternprozess zurückgegeben, damit es mit ihm kommunizieren kann. Jedes Kind hat eine Eltern-Identifikation, die _PPID_.

Die _PID_-Nummer repräsentiert den Prozess zum Zeitpunkt der Ausführung. Wenn der Prozess beendet ist, steht die Nummer für einen anderen Prozess wieder zur Verfügung. Wenn Sie den gleichen Befehl mehrmals ausführen, wird jedes Mal eine andere _PID_-Nummer erzeugt.<!-- TODO !\[Parent/child relationship between processes\](images/FON-050-001.png) -->!!! note "Anmerkung"

    Prozesse dürfen nicht mit _threads_ verwechselt werden. Jeder Prozess hat seinen eigenen Speicher-Kontext (Ressourcen und Adressraum), während _threads_ aus demselben Prozess diesen Kontext gemeinsam teilen.

## Prozesse anzeigen

Das Kommando `ps` zeigt den Status laufender Prozesse an.
```
ps [-e] [-f] [-u login]
```

Beispiel:
```
# ps -fu root
```

| Option     | Beschreibung                         |
| ---------- | ------------------------------------ |
| `-e`       | Zeigt alle Prozesse an.              |
| `-f`       | Zeigt zusätzliche Information an.    |
| `-u` login | Zeigt die Prozesse des Benutzers an. |

Einige zusätzliche Optionen:

| Option                | Beschreibung                                            |
| --------------------- | ------------------------------------------------------- |
| `-g`                  | Zeigt die Prozesse aus der Gruppe an.                   |
| `-t tty`              | Zeigt die Prozesse, die vom Terminal ausgeführt werden. |
| `-p PID`              | Zeigt die Prozessinformation an.                        |
| `-H`                  | Zeigt die Informationen als Baumstruktur an.            |
| `-I`                  | Zeigt zusätzliche Information an.                       |
| `--sort COL`          | Sortiert das Ergebnis nach einer Spalte.                |
| `--headers`           | Zeigt den Header auf jeder Seite des Terminals an.      |
| `--format "%a %b %c"` | Passt das Ausgabeformat an.                             |

Ohne Angabe einer Option zeigt der Befehl `ps` nur Prozesse an, die vom aktuellen Terminal ausgeführt werden.

Das Ergebnis wird in Spalten angezeigt:

```
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

```
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

Der Systemprozess (_daemon_):

* wird vom System gestartet;
* ist keinem Terminal zugeordnet und gehört einem Systembenutzer (oft `root`);
* wird beim Booten geladen, befindet sich im Speicher und wartet auf einen Aufruf;
* wird normalerweise durch den Buchstaben `d` identifiziert, der dem Prozessnamen assoziiert ist.

Systemprozesse werden daher als Daemons bezeichnet (_**D**isk **A**nd **E**xecution **MON**itor_).

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

Der Prozessor arbeitet in time-sharing, wobei jedem Prozess eine bestimmte Menge Prozessorzeit zugewiesen wird.

Die Prozesse sind nach Priorität klassifiziert, deren Wert von **-20** (die höchste Priorität) bis **+19** (die niedrigste Priorität) variiert.

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

```
kill [-signal] PID
```

Beispiel:

```
$ kill -9 1664
```Unterbreche den Prozess (<kbd>STRG</kdb> + <kdb>D</kdb>)</td> </tr> 

<tr>
  <td>
    <code>15</code>
  </td>
  
  <td>
    <em x-id="4">SIGTERM</em>
  </td>
  
  <td>
    Bereinigung und Beenden des Prozesses
  </td>
</tr>

<tr>
  <td>
    <code>18</code>
  </td>
  
  <td>
    <em x-id="4">SIGCONT</em>
  </td>
  
  <td>
    Prozess fortsetzen
  </td>
</tr>

<tr>
  <td>
    <code>19</code>
  </td>
  
  <td>
    <em x-id="4">SIGSTOP</em>
  </td>
  
  <td>
    Prozess anhalten
  </td>
</tr></tbody> </table> 

<p spaces-before="0">
  Signale sind das Mittel der Kommunikation zwischen den Prozessen. Der <code>kill</code> Befehl sendet ein Signal an einen Prozess.
</p>

<p spaces-before="0">
  !!! tip "Hinweis"
</p>

<pre><code>Die komplette Liste der Signale, die vom `kill` Befehl unterstüzt werden, kann durch folgendes Kommando ausgegeben werden:
</code></pre>

<pre><code>    $ man 7 signal
</code></pre>



<h3 spaces-before="0">
  <code>nohup</code> Befehl
</h3>

<p spaces-before="0">
  <code>nohup</code> erlaubt das Starten eines Prozesses unabhängig von einer Verbindung.
</p>

<pre><code>nohup Befehl
</code></pre>

<p spaces-before="0">
  Beispiel:
</p>

<pre><code>$ nohup myprogram.sh 0&lt;/dev/null &
</code></pre>

<p spaces-before="0">
  Durch <code>nohup</code> wird das <code>SIGHUP</code> Signal ignoriert, das gesendet wird, wenn ein Benutzer sich ausloggt.
</p>

<p spaces-before="0">
  !!! note "Hinweis"
</p>

<pre><code>`nohup` behandelt Standard-Ausgabe und -Fehler, aber keine Standardeingabe, daher die Umleitung dieser Eingabe nach `/dev/null`.
</code></pre>



<h3 spaces-before="0">
  [CTRL] + [Z]
</h3>

<p spaces-before="0">
  Durch gleichzeitiges Drücken der <kbd>STRG</kbd> + <kbd>Z</kbd> Tasten wird der Synchronprozess vorübergehend unterbrochen. Der Zugriff auf die Eingabeaufforderung wird wiederhergestellt, nachdem die Nummer des gerade unterbrochenen Prozesses angezeigt wurde.
</p>



<h3 spaces-before="0">
  <code>&</code> Anweisung
</h3>

<p spaces-before="0">
  Die Anweisung <code>&</code> führt den Befehl asynchron aus (der Befehl wird dann <em x-id="4">job</em> genannt) und zeigt die Id-Nummer vom <em x-id="4">job</em> an. Der Zugriff auf die Eingabeaufforderung wird zurückgestellt.
</p>

<p spaces-before="0">
  Beispiel:
</p>

<pre><code>$ time ls -lR / &gt; list.ls 2&gt; /dev/null &
[1] 15430
$
</code></pre>

<p spaces-before="0">
  Die <em x-id="4">Job</em>-Nummer wird während der Hintergrundverarbeitung abgerufen und in eckigen Klammern angezeigt, gefolgt von der <code>PID</code>-Nummer.
</p>



<h3 spaces-before="0">
  <code>fg</code> und <code>bg</code> Befehle
</h3>

<p spaces-before="0">
  Der <code>fg</code> Befehl stellt den Prozess in den Vordergrund:
</p>

<pre><code>$ time ls -lR / &gt; list.ls 2&gt;/dev/null &
$ fg 1
time ls -lR / &gt; list.ls 2/dev/null
</code></pre>

<p spaces-before="0">
  während der Befehl <code>bg</code> ihn im Hintergrund platziert:
</p>

<pre><code>[CTRL]+[Z]
^Z
[1]+ Stopped
$ bg 1
[1] 15430
$
</code></pre>

<p spaces-before="0">
  Ob es im Hintergrund gesetzt wurde, als es mit dem <code>&</code> Argument erstellt wurde oder später mit den <kbd>STRG</kbd> +<kbd>Z</kbd> Tasten erstellt wurde, kann ein Prozess mit dem Befehl <code>fg</code> und seiner Jobnummer wieder in den Vordergrund gebracht werden.
</p>



<h3 spaces-before="0">
  <code>jobs</code> Befehl
</h3>

<p spaces-before="0">
  Der Befehl <code>jobs</code> zeigt die Liste der im Hintergrund laufenden Prozesse an und gibt deren Jobnummer an.
</p>

<p spaces-before="0">
  Beispiel:
</p>

<pre><code>$ jobs
[1]- Running    sleep 1000
[2]+ Running    find / &gt; arbo.txt
</code></pre>

<p spaces-before="0">
  Die Spalten repräsentieren:
</p>

<ol start="1">
  <li>
    Jobnummer;
  </li>
  
  <li>
    die Reihenfolge in der die Prozesse ausgeführt werden
  </li>
</ol>

<ul>
  <li>
    ein <code>+</code> : Dieser Prozess ist der nächste Prozess, der standardmäßig mit <code>fg</code> oder <code>bg</code> ausgeführt wird;
  </li>
  <li>
    ein <code>-</code> : Dieser Prozess ist der nächste Prozess, der die <code>+</code> übernimmt <code>+</code>
  </li>
</ul>

<ol start="3">
  <li>
    <em x-id="4">Running</em> (laufender Prozess) oder <em x-id="4">Stopped</em> (abgehängter Prozess)  
  </li>
  
  <li>
    der Kommando
  </li>
</ol>



<h3 spaces-before="0">
  <code>nice</code> und <code>renice</code> Befehle
</h3>

<p spaces-before="0">
  Der Befehl <code>nice</code> erlaubt die Ausführung eines Befehls, wobei seine Priorität angegeben wird.
</p>

<pre><code>nice priority command
</code></pre>

<p spaces-before="0">
  Beispiel:
</p>

<pre><code>$ nice -n+15 find / -name "file"
</code></pre>

<p spaces-before="0">
  Anders als <code>root</code> kann ein Standardbenutzer die Priorität eines Prozesses nur reduzieren. Nur Werte zwischen +0 und +19 werden akzeptiert.
</p>

<p spaces-before="0">
  !!! tip "Hinweis"
</p>

<pre><code>Diese letzte Einschränkung kann pro Benutzer oder pro Gruppe aufgehoben werden, indem die Datei `/etc/security/limits.conf` geändert wird.
</code></pre>

<p spaces-before="0">
  Mit dem <code>renice</code> Befehl können Sie die Priorität eines laufenden Prozesses ändern.
</p>

<pre><code>renice priority [-g GID] [-p PID] [-u UID]
</code></pre>

<p spaces-before="0">
  Beispiel:
</p>

<pre><code>$ renice +15 -p 1664
</code></pre>
<table spaces-before="0">
  <tr>
    <th>
      Option
    </th>
    
    <th>
      Beschreibung
    </th>
  </tr>
  
  <tr>
    <td>
      <code>-g</code>
    </td>
    
    <td>
      <code>GID</code> der Prozessbesitzer-Gruppe.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>-p</code>
    </td>
    
    <td>
      <code>PID</code> des Prozesses.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>-u</code>
    </td>
    
    <td>
      <code>UID</code> des Prozess-Owner.
    </td>
  </tr>
</table>

<p spaces-before="0">
  Der <code>renice</code> Befehl wirkt auf bereits laufende Prozesse. Es ist daher möglich, die Priorität eines bestimmten Prozesses, aber auch mehrerer Prozesse zu ändern, die einem Benutzer oder einer Gruppe angehören.
</p>

<p spaces-before="0">
  !!! tip "Hinweis"
</p>

<pre><code>Der `pidof`-Befehl, kombiniert mit dem `xargs` Befehl (siehe den Kurs über erweiterte Befehle), erlaubt es, eine neue Priorität in einem einzigen Befehl anzuwenden:
</code></pre>

<pre><code>    $ pidof sleep | xargs renice 20
</code></pre>



<h3 spaces-before="0">
  <code>top</code> Befehl
</h3>

<p spaces-before="0">
  Der <code>top</code> Befehl zeigt die Prozesse und den Ressourcenverbrauch an.
</p>

<pre><code>$ Top
PID USER PR NI ... %CPU %MEM TIME+ COMMAND
2514 root 20 0 15 5.5 0:01.14 top
</code></pre>

<table spaces-before="0">
  <tr>
    <th>
      Spalte
    </th>
    
    <th>
      Beschreibung
    </th>
  </tr>
  
  <tr>
    <td>
      <code>PID</code>
    </td>
    
    <td>
      Prozess IDentifikationsnummer.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>USER</code>
    </td>
    
    <td>
      Besitzer.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>PR</code>
    </td>
    
    <td>
      Prozesspriorität.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>NI</code>
    </td>
    
    <td>
      Nice-Wert.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>%CPU</code>
    </td>
    
    <td>
      Prozessorlast
    </td>
  </tr>
  
  <tr>
    <td>
      <code>%MEM</code>
    </td>
    
    <td>
      Speicherauslastung.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>TIME+</code>
    </td>
    
    <td>
      Prozessor-Nutzungszeit.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>COMMAND</code>
    </td>
    
    <td>
      Befehl ausgeführt.
    </td>
  </tr>
</table>

<p spaces-before="0">
  Der <code>top</code> Befehl erlaubt die Kontrolle der Prozesse in Echtzeit und im interaktiven Modus.
</p>



<h3 spaces-before="0">
  <code>pgrep</code> und <code>pkill</code> Befehle
</h3>

<p spaces-before="0">
  Der <code>pgrep</code> Befehl durchsucht die laufenden Prozesse nach einem Prozessnamen und zeigt auf der Standardausgabe die <em x-id="4">PID</em> an, die den Auswahlkriterien entspricht.
</p>

<p spaces-before="0">
  Der Befehl <code>pkill</code> sendet das angegebene Signal (standardmäßig <em x-id="4">SIGTERM</em>) an jeden Prozess.
</p>

<pre><code>pgrep process
pkill [-signal] process
</code></pre>

<p spaces-before="0">
  Beispiele:
</p>

<ul>
  <li>
    Prozessnummer von <code>sshd</code> ermitteln:
  </li>
</ul>

<pre><code>$ pgrep -u root sshd
</code></pre>

<ul>
  <li>
    Alle <code>tomcat</code> Prozesse endgültig beenden:
  </li>
</ul>

<pre><code>$ pkill tomcat
</code></pre>
