---
title: cron - zeitgesteuerte Prozesse
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested on: 8.5
tags:
  - Job-Automatisierung
  - Automatisierung
  - cron
---

# Prozess-Automatisierung mit `cron` und `crontab`

## Voraussetzungen

- Eine Maschine, auf der Rocky Linux läuft
- Erfahrung beim Ändern von Konfigurationsdateien aus der Befehlszeile mit Ihrem Lieblingseditor (`vi` wird hier verwendet)

## Voraussetzungen

- Grundlegendes Wissen über Bash, Python oder andere Skript-/Programmierwerkzeuge und der Wunsch nach automatischer Ausführung eines Skripts
- Dass Sie entweder als Root-Benutzer angemeldet sind oder mit `sudo -s`  
  ** zu root wechseln können (Sie können bestimmte Skripte in Ihren eigenen Verzeichnissen als Ihren eigenen Benutzer ausführen. In diesem Fall ist der Root-Wechsel nicht notwendig).**

## Einleitung

Linux stellt das *cron* Scheduling-System zur Verfügung, einen zeitbasierten Job-Planer, um Prozesse zu automatisieren. Es ist relativ einfach und doch ziemlich mächtig. Möchten Sie ein Skript oder Programm jeden Tag um 17 Uhr laufen lassen? Hier wird beschrieben wie es eingerichtet wird.

Bei der *crontab* handelt es sich im Wesentlichen um eine Liste, in der Benutzer ihre eigenen automatisierten Aufgaben und Jobs hinzufügen, und sie bietet viele Optionen, die die Dinge noch weiter vereinfachen können. Dieser Artikel wird einige davon näher beleuchten. Für diejenigen mit etwas Erfahrung ist es eine gute Auffrischung, und neue Benutzer können das `cron`-System zu ihrem Repertoire hinzufügen.

`anacron` wird hier kurz in Bezug auf `cron` „dot“-Verzeichnisse besprochen. `cron` wird von `anacron` ausgeführt und ist für Maschinen nützlich, die nicht immer aktiv sind, wie z. B. Workstations und Notebooks. Der Grund dafür ist, dass `cron` Jobs zwar nach einem Zeitplan ausführt, der Job jedoch nicht ausgeführt wird, wenn der Computer zum Zeitpunkt der Jobplanung ausgeschaltet ist. Mit `anacron` wird der Job ausgeführt, wenn die Maschine wieder eingeschaltet ist, auch wenn der geplante Run in der Vergangenheit liegt. `anacron` verwendet jedoch einen eher randomisierten Ansatz, um Aufgaben auszuführen, bei denen das Timing nicht genau ist. Das mag für Workstations und Laptops sinnvoll sein, aber nicht so sehr für Server. Dies kann beispielsweise bei Server-Backups ein Problem darstellen, bei denen die Ausführung eines Jobs zu einem bestimmten Zeitpunkt erforderlich ist. Hier stellt `cron` die beste Lösung für Serveradministratoren dar. Serveradministratoren und Benutzer von Workstations oder Notebooks können jedoch von beiden Ansätzen profitieren. Sie können sie ganz nach Ihren Bedürfnissen kombinieren. Weitere Informationen zu `anacron` finden Sie unter [anacron - Kommandos Automatisierung](anacron.md).

### Leicht starten - die `cron` dot Directories

In jedem Linux-System für zahlreiche Versionen eingebaut, helfen die `cron` "dot" Verzeichnisse dabei, Prozesse schnell zu automatisieren. Diese werden als Verzeichnisse angezeigt, die das `cron` System basierend auf seinen Namenskonventionen aufruft. Sie werden jedoch anders aufgerufen, basierend auf dem Prozess, der ihnen zugewiesen wird, `anacron` oder `cron`. Das Standardverhalten ist die Verwendung von `anacron`, aber dies kann von einem Server, einer Workstation oder einem Laptop Administrator geändert werden.

#### Für Server

Wie in der Einführung angegeben, führt `cron` in diesen Tagen `anacron` aus, um Skripte in diesen "dot" Verzeichnissen auszuführen. Möglicherweise möchten Sie diese „dot“-Verzeichnisse auch auf Ihren Servern verwenden. In diesem Fall müssen Sie zwei Schritte ausführen, um zu überprüfen, ob diese „dot“-Verzeichnisse ausgeführt werden nach einer strengen Planung. Dazu müssen wir ein Paket installieren und ein anderes entfernen:

`dnf install cronie-noanacron`

und

`dnf remove cronie-anacron`

Wie Sie erwarten können, entfernt dies `anacron` vom Server und kehrt mit einem strengen Zeitplan zu laufenden Aufgaben innerhalb der "dot" Verzeichnisse zurück. Dies wird durch diese Datei definiert: `/etc/cron.d/dailyjobs`, die folgende Inhalte aufweist:

```bash
# Run the daily, weekly, and monthly jobs if cronie-anacron is not installed
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root

# run-parts
02 4 * * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.daily
22 4 * * 0 root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.weekly
42 4 1 * * root [ ! -f /etc/cron.hourly/0anacron ] && run-parts /etc/cron.monthly
```

Dies bedeutet Folgendes:

- Skripte in `cron.daily` um 04:02:00 jeden Tag ausführen.
- die Skripte jede Woche am Sonntag um 04:22:00 Uhr in `cron.weekly` ausführen.
- die Skripte in `cron.monthly` um 04:42:00 Uhr am Ersten jedes Monats ausführen.

#### Für Workstations

Wenn Sie Skripte auf einer Workstation oder einem Laptop in den `cron` "dot" Verzeichnissen ausführen wollen, dann gibt es nichts Besonderes, was Sie tun müssen. Kopieren Sie einfach Ihre Skriptdatei in das betreffende Verzeichnis und stellen Sie sicher, dass sie ausführbar ist. Hier sind die Verzeichnisse:

- `/etc/cron.hourly` – Hier platzierte Skripte werden jede Stunde eine Minute nach der vollen Stunde ausgeführt (ausgeführt von `cron`, unabhängig davon, ob `anacron` installiert ist oder nicht)
- `/etc/cron.daily` - Hier platzierte Skripte werden jeden Tag ausgeführt. `anacron` passt das Timing dieser an (siehe Hinweis)
- `/etc/cron.weekly` – Hier platzierte Skripte werden alle 7 Tage ausgeführt, basierend auf dem Kalendertag der letzten Ausführung (siehe Hinweis)
- `/etc/cron.monthly` – Hier platzierte Skripte werden monatlich basierend auf dem Kalendertag der letzten Ausführung ausgeführt (siehe Hinweis)

!!! tip "Hinweis"

    Diese werden wahrscheinlich jeden Tag, jede Woche und jeden Monat zu ähnlichen (aber nicht genau dieselben) Zeiten durchgeführt. Genauere Laufzeiten finden Sie unter @options unten.

Wenn Sie die Möglichkeit haben, dass das System Skripte automatisch zu einem bestimmten Zeitpunkt ausführt, können Sie Aufgaben einfacher automatisieren.

!!! note "Anmerkung"

    Es gibt keine Regel, die besagt, dass ein Serveradministrator die zufälligen Laufzeiten nicht verwenden kann, die `anacron` verwendet, um Skripte in den "dot" Verzeichnissen auszuführen. Der Anwendungsfall dafür wäre ein Skript, das nicht Zeit kritisch ist.

### Eigenen `cron` erstellen

Natürlich, wenn die automatisierten zufälligen Zeiten in [für Workstations oberhalb](#for-workstations) nicht gut funktionieren, und die geplanten Zeiten in den [für Server oben](#for-servers), dann können Sie Ihre eigenen erstellen. In diesem Beispiel gehen wir davon aus, dass Sie dies als root tun. [Siehe Voraussetzungen](#assumptions) Um dies zu tun, geben Sie folgendes ein:

`crontab -e`

Dadurch wird die `crontab` des Root-Benutzers aufgerufen, wie sie derzeit in Ihrem ausgewählten Editor vorliegt und ungefähr so ​​aussehen könnte. Lesen Sie diese kommentierte Version, da sie Beschreibungen aller Felder enthält, die Sie als Nächstes verwenden werden:

```text
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# cron
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
```

Beachten Sie, dass in diese spezielle `crontab`-Datei teilweise eine eigene Dokumentation integriert ist. Das ist nicht immer der Fall. Wenn Sie eine `crontab` auf einem Container oder einem minimalistischen Betriebssystem ändern, ist die `crontab` eine leere Datei, es sei denn, sie enthält einen Eintrag.

Nehmen wir an, dass wir ein Backup-Skript haben, das wir um 22:00 Uhr laufen lassen möchten. Der `crontab` benötigt eine 24 Stunden Notation, also wäre dies 22:00 Uhr. Angenommen, Ihr Sicherungsskript heißt `backup` und befindet sich derzeit im Verzeichnis */usr/local/sbin*.

!!! note "Anmerkung"

    Denken Sie daran, dass dieses Skript auch ausführbar sein muss (`chmod +x`), damit es von `cron` ausgeführt werden kann.

So listen Sie die aktuell ausgeführten Jobs auf

`crontab -l`

Um alle vom Benutzer erstellten Jobs aufzulisten

`crontab -l -u <username>`

Um den Job hinzuzufügen, bitte Folgendes eingeben:

`crontab -e`

`crontab` steht für „cron table“ und das Format der Datei ist tatsächlich ein loses Tabellenlayout. Da Sie sich nun in der `crontab` befinden, gehen Sie zum Ende der Datei und fügen Sie Ihren Eintrag hinzu. Wenn Sie `vi` als Ihren Standard-Systemeditor verwenden, tun Sie dies mit der folgenden Tastenkombination:

++shift+colon+"$"++

Nachdem Sie sich nun am Ende der Datei befinden, fügen Sie eine Zeile und einen kurzen Kommentar ein, um Ihren Eintrag zu beschreiben. Dazu geben Sie das Zeichen "#" am Anfang der Zeile ein:

`# Backing up the system every night at 10PM`

Bitte ++enter++ eingeben. Sie sollten sich noch im Einfügemodus befinden. Der nächste Schritt besteht also darin, Ihren Eintrag hinzuzufügen. As shown in our empty commented `crontab` (above) this is **m** for minutes, **h** for hours, **dom** for day of month, **mon** for month, and **dow** for day of week.

Um unser Backup-Skript jeden Tag um 10:00 Uhr auszuführen, sieht der Eintrag folgendermaßen aus:

`00  22  *  *  *   /usr/local/sbin/backup`

Dies besagt, dass das Skript jeden Tag im Monat, jeden Monat und jeden Tag der Woche um 22 Uhr ausgeführt werden soll. Dies ist ein sehr einfaches Beispiel und die Dinge können kompliziert werden, wenn Sie spezifische Informationen benötigen.

### Die Optionen — @options – für `crontab`

Eine andere Möglichkeit, Jobs zu einem streng geplanten Zeitpunkt (z. B. Tag, Woche, Monat, Jahr usw.) auszuführen, besteht in der Verwendung der @Optionen, die eine natürlichere Zeitskala ermöglichen. Die Optionen – @options – bestehen aus:

- `@hourly` führt das Skript jeden Tag stündlich um 0 Minuten nach der vollen Stunde aus (dies ist genau das Ergebnis der Platzierung des Skripts in `/etc/cron.hourly`).
- `@daily` das Skript wird jeden Tag um Mitternacht ausgeführt.
- `@weekly` das Skript wird jede Woche sonntags um Mitternacht ausgeführt.
- `@monthly` das Skript wird jeden Monat um Mitternacht am ersten Tag des Monats ausgeführt.
- `@yearly` das Skript wird jedes Jahr am ersten Tag im Januar um Mitternacht ausgeführt.
- `@reboot` das Skript wird nur beim Systemstart ausgeführt.

!!! note "Anmerkung"

    Durch die Verwendung dieser `crontab`-Einträge wird das `Anacron`-System umgangen und auf `crond.service` zurückgegriffen, unabhängig davon, ob `anacron` installiert ist oder nicht.

Wenn Sie für unser Backup-Skriptbeispiel die Option @daily verwenden, um das Backup-Skript um Mitternacht auszuführen, sieht der Eintrag folgendermaßen aus:

`@daily  /usr/local/sbin/backup`

### Erweiterte Optionen

Bisher waren die verwendeten Lösungen eher simpel, aber wie sieht es mit komplexeren Zeitplänen aus? Nehmen wir an, Sie möchten das Backup-Skript tagsüber alle 10 Minuten ausführen (wahrscheinlich keine praktische Vorgehensweise, aber ein Beispiel!). Um dies zu erreichen, lautet die Crontab wie folgt:

`*/10  *   *   *   *   /usr/local/sbin/backup`

Was ist, wenn Sie alle 10 Minuten ein Backup durchführen möchten, jedoch nur am Montag, Mittwoch und Freitag?

`*/10  *   *   *   1,3,5   /usr/local/sbin/backup`

Wie wäre es mit einem 10-Minuten-Takt jeden Tag außer Samstag und Sonntag?

`*/10  *   *   *    1-5    /usr/local/sbin/backup`

In der Tabelle können Sie mit Kommas einzelne Einträge und mit dem Bindestrich einen Wertebereich innerhalb eines Felds angeben. Dies gilt für jedes dieser Felder und kann für viele Felder gleichzeitig gelten. Wie Sie sehen, kann es ziemlich kompliziert werden.

Wenn Sie festlegen, wann ein Skript ausgeführt werden soll, müssen Sie sich Zeit nehmen und es planen, insbesondere wenn die Kriterien komplex sind.

## Zusammenfassung

Das *cron/crontab*-System ist ein leistungsstarkes Tool für den Rocky Linux-Systemadministrator oder Desktop-Benutzer. Damit können Sie Aufgaben und Skripts automatisieren, sodass Sie nicht daran denken müssen, sie manuell auszuführen. Komplexere Beispiele finden Sie hier:

- Für Maschinen, die **nicht** rund um die Uhr eingeschaltet sind, siehe [anacron – Befehle automatisieren](anacron.md).
- Eine kurze Beschreibung der `cron`-Prozesse finden Sie unter [cronie - Timed Tasks](cronie.md)

Während die Grundlagen nicht schwierig sind, können die Optionen komplexer sein. Weitere Informationen zu `crontab` finden Sie auf der [Crontab-Handbuchseite](https://man7.org/linux/man-pages/man5/crontab.5.html). Auf den meisten Systemen können Sie auch `man crontab` eingeben, um zusätzliche Befehlsdetails zu erhalten. Sie können auch im Internet nach „crontab“ suchen. Sie erhalten zahlreiche Ergebnisse, mit deren Hilfe Sie Ihre `crontab`-Kenntnisse verfeinern können.
