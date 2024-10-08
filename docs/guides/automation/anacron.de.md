---
title: anacron - Kommandos Automatisierung
author: tianci li
contributors: Steven Spencer, Ganna Zhyrnova
update: 2021-10-20
---

# `anacron` - Kommandos Automatisierung

## Voraussetzungen

- Eine Maschine, auf der Rocky Linux läuft.
- Verstehen, wie Sie Ihren bevorzugten Editor verwenden, um eine Konfigurationsdatei (z. B. mit *vim*) zu ändern.
- Grundlagen der RPM-Paketverwaltung verstehen.

## Voraussetzungen

- Sie haben Grundkenntnisse von bash, python oder anderen Skript-/Programmierwerkzeugen und möchten das Skript automatisch ausführen.
- Sie sind als Root-Benutzer eingeloggt oder wechseln mit `su - root` zum Root.

## Einleitung

`anacron` wird verwendet, um Befehle automatisiert auszuführen. Die Einheit für die Wiederholung der Jobs ist der Tag. Es eignet sich für Computer, die nicht rund um die Uhr in Betrieb sind, wie zum Beispiel Laptops und Desktops. Angenommen, Sie haben eine geplante Aufgabe (z. B., ein Sicherungsskript), die jeden Tag frühmorgens mithilfe von `crontab` ausgeführt werden soll. Wenn Sie einschlafen, wird Ihr Desktop/Laptop heruntergefahren. Ihr Backup-Skript wird nicht ausgeführt. Wenn Sie jedoch `anacron` verwenden, können Sie sicher sein, dass das Sicherungsskript beim nächsten Einschalten des Desktops oder Notebooks ausgeführt wird.**

Die Implementierung und der Einsatz von `anacron` soll `crontab` nicht ersetzen, sondern `crontab` ergänzen. Ihre Verbindung zueinander ist wie folgt:

![ Beziehungen ](../images/anacron_01.png)

## `anacron` - Konfigurationsdatei

```bash
shell > rpm -ql cronie-anacron
/etc/anacrontab
/etc/cron.hourly/0anacron
/usr/lib/.build-id
/usr/lib/.build-id/0e
/usr/lib/.build-id/0e/6b094fa55505597cb69dc5a6b7f5f30b04d40f
/usr/sbin/anacron
/usr/share/man/man5/anacrontab.5.gz
/usr/share/man/man8/anacron.8.gz
/var/spool/anacron
/var/spool/anacron/cron.daily
/var/spool/anacron/cron.monthly
/var/spool/anacron/cron.weekly
```

Überprüfen Sie zuerst die Default-Konfigurationsdatei:

```bash
shell > cat /etc/anacrontab
# /etc/anacrontab: configuration file for anacron
# See anacron(8) and anacrontab(5) for details.
SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# Default 45 minutes delay for each specified job anacron random increase 0-45 minutes.
RANDOM_DELAY=45
# Specify the scope of work time, represented here 3:00 ~ 22:00
START_HOURS_RANGE=3-22
# period in days delay in minutes job-identifier command
# Boot every day to check whether the files in the directory /etc/cron.daily be executed in 5 minutes, if not executed today, then to the next
1 5 cron.daily nice run-parts /etc/cron.daily
# Every 7 days within 25 minutes if the file check /etc/cron.weekly directory is executed after boot, if not executed within a week, it will be executed next
7 25 cron.weekly nice run-parts /etc/cron.weekly
# Whether the files in the directory /etc/cron.monthly 45 minutes checking is performed after every start for a month
@monthly 45 cron.monthly nice run-parts /etc/cron.monthly
```

**/etc/cron.hourly/** - Durch `journalctl -u crond.service` können Sie feststellen, dass die eingefügten Dateien tatsächlich von crond.server aufgerufen werden. Das bedeutet, dass der Befehl nach der ersten Minute jeder Stunde ausgeführt wird. Wie folgt:

```bash
shell > cat /etc/cron.d/0hourly
# Run the hourly jobs
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
01 *  *  *  * root run-parts /etc/cron.hourly
```

```bash
shell > journalctl -u crond.service
- Logs begin at Wed 2021-10-20 19:27:39 CST, end at Wed 2021-10-20 23:32:42 CST. -
October 20 19:27:42 li systemd[1]: Started Command Scheduler.
October 20 19:27:42 li crond[733]: (CRON) STARTUP (1.5.2)
October 20 19:27:42 li crond[733]: (CRON) INFO (RANDOM_DELAY will be scaled with factor 76% if used.)
October 20 19:27:42 li crond[733]: (CRON) INFO (running with inotify support)
October 20 20:01:01 li CROND[1897]: (root) CMD (run-parts /etc/cron.hourly)
October 20 21:01:01 li CROND[1922]: (root) CMD (run-parts /etc/cron.hourly)
October 20 22:01:01 li CROND[1947]: (root) CMD (run-parts /etc/cron.hourly)
October 20 23:01:01 li CROND[2037]: (root) CMD (run-parts /etc/cron.hourly)
```

Weitere Informationen zu Konfigurationsdateien finden Sie [auf der Manpage](https://man7.org/linux/man-pages/man5/anacrontab.5.html).

## User use

Um bestimmte Dateien innerhalb dieser automatisch definierten Zeiten laufen zu lassen, müssen Sie nur die Skriptdatei in das entsprechende Verzeichnis kopieren und sicherstellen, dass sie **Ausführungsberechtigung hat (chmod +x)**. Daher muss das System das Skript nur zu einem dieser geplanten Zeiten ausführen, was die Automatisierung sehr einfach macht.

Lasst uns cron.daily anschauen, um den Ausführungsprozess von /etc/anacrontab zu verdeutlichen:

1. `anacron` liest die Datei **/var/spool/anacron/cron.daily** und aus dem Inhalt der Datei ergibt sich der Zeitpunkt der letzten Ausführung.
2. Verglichen mit der aktuellen Uhrzeit, wenn die Differenz zwischen den beiden letzten beiden Male einen Tag überschreitet, wird der cron.daily Job ausgeführt.
3. Diesen Job kann nur von 03:00-22:00 Uhr durchgeführt werden.
4. Prüfen, ob eine Datei nach 5 Minuten dem Booten ausgeführt wird. Wenn der erste ausgeführt wird, wird er zufällig um 0~45 Minuten verzögert, um den nächsten auszuführen.
5. Verwenden Sie den Parameter `nice`, um die Standardpriorität anzugeben, und verwenden Sie den Parameter `run-parts`, um alle ausführbaren Dateien im Verzeichnis `/etc/cron.daily/` auszuführen.

## verwandte Befehle

Verwenden Sie den Befehl `anacron`, <br/> häufig verwendete Optionen sind:

| Option | Beschreibung                                                                          |
| ------ | ------------------------------------------------------------------------------------- |
| -f     | Alle Jobs ausführen und Zeitstempel ignorieren                                        |
| -u     | Den Zeitstempel auf die aktuelle Uhrzeit aktualisieren ohne eine Aktion durchzuführen |
| -T     | Die Gültigkeit der Konfigurationsdatei /etc/anacrontab überprüfen                     |

Weitere Informationen erhalten Sie [auf der Handbuch-Seite](https://man7.org/linux/man-pages/man8/anacron.8.html)
