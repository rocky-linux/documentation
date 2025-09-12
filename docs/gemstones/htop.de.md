---
title: htop — Prozessverwaltung
author: tianci li
contributors: Steven Spencer
date: 2021-10-16
tags:
  - htop
  - Prozesse
---

# htop-Prozessverwaltung

## i`htop`-Installation

Jeder Systemadministrator verwendet gerne einige der gebräuchlichsten Befehle. Heute empfehlen wir `htop` als Alternative zum Befehl `top`. Um den Befehl `htop` zu verwenden, müssen Sie ihn ggf. zuerst installieren.

``` bash
# Installation epel source (also called repository)
dnf -y install epel-release
# Generate cache
dnf makecache
# Install htop
dnf -y install htop
```

## `htop`-Verwendung

Sie müssen nur `htop` im Terminal eingeben und die interaktive Schnittstelle sieht wie folgt aus:

```bash
0[ |||                      3%]     Tasks: 22, 46thr, 174 kthr 1 running
1[ |                        1%]     Load average: 0.00 0.00 0.05
Mem[ |||||||           197M/8G]     Uptime: 00:31:39
Swap[                  0K/500M]
PID   USER   PRI   NI   VIRT   RES   SHR   S   CPU%   MEM%   TIME+   Command(merged)
...
```

++f1++ Help ++f2++ Setup ++f3++ Search ++f4++ Filter ++f5++ Tree ++f6++ SortBy ++f7++ Nice ++f8++ Nice ++f9++ Kill ++f10++ Quit

### Top Beschreibung

* 0 und 1 sind die Nummern der CPU-Kerne, und der Prozentsatz zeigt die Auslastungsrate der einzelnen Kerne an (die Gesamtbelegungsrate der CPU kann ebenfalls angezeigt werden).
    * Die Farbe des Fortschrittsbalkens zeigt den Prozentsatz der verschiedenen Prozessarten an:

        | Farbe | Beschreibung                                                                                  | Namen, die in anderen Stilen angezeigt werden |
        | ----- | --------------------------------------------------------------------------------------------- | --------------------------------------------- |
        | Blau  | Prozentsatz der CPU-Leistung, die von Prozessen mit niedriger Priorität verwendet wird        | niedrig                                       |
        | Grün  | Prozentsatz der Prozess-CPU-Leistung, die von gewöhnlichen Benutzer in Anspruch genommen wird |                                               |
        | Rot   | Prozentsatz der CPU-Leistung, die von Systemprozessen verwendet wird                          | sys                                           |
        | Cyan  | Prozentsatz der CPU-Leistung, die von der Steal-Time verwendet wird                           | vir                                           |

* Tasks: 22, 46thr, 174 kthr 1 running. In diesem Beispiel bedeutet dies, dass die aktuelle Maschine 22 Aufgaben hat, die in 46 Threads aufgeteilt sind, von denen sich nur 1 Prozess im laufenden Zustand befindet. `kthr` gibt an, wie viele Kernel-Threads es gibt.
* Mem information. Verwenden Sie in ähnlicher Weise verschiedene Farben, um Folgendes zu unterscheiden:

   | Farbe       | Beschreibung                                                              | Namen, die in anderen Stilen angezeigt werden |
   | ----------- | ------------------------------------------------------------------------- | --------------------------------------------- |
   | Blau        | Prozentsatz des vom Puffer verbrauchten Speichers                         | puffer                                        |
   | Grün        | Prozentsatz des vom Speicherbereich verbrauchten Speichers                | verwendet                                     |
   | Gelb/Orange | Prozentsatz des vom Cache-Bereich verbrauchten Speichers                  | cache                                         |
   | Magenta     | Prozentsatz des Arbeitsspeichers durch gemeinsame Speicherbereiche belegt | shared                                        |

* Swap-Information.

   | Farbe       | Beschreibung                                             | Namen, die in anderen Stilen angezeigt werden |
   | ----------- | -------------------------------------------------------- | --------------------------------------------- |
   | Grün        | Prozentsatz des vom Cache-Bereich verbrauchten Speichers | used                                          |
   | Gelb/Orange | Prozentsatz des vom Cache-Bereich verbrauchten Swaps     | cache                                         |

* Durchschnittliche Auslastung: die drei Werte repräsentieren jeweils die durchschnittliche Auslastung des Systems in der letzten Minute, den letzten 5 Minuten und den letzten 15 Minuten
* Uptime, d.h. die Laufzeit seit dem letztem Booten

### Prozessinformationen

* **PID - Prozess-ID Nummer**
* USER - Der Besitzer des Prozesses
* PRI-Anzeige der Prozesspriorität aus Sicht vom Linux-Kernel
* NI-zeigt die Prozesspriorität des Zurücksetzens durch normalen Benutzer oder Root an
* VIRT - Virtueller Speicher von einem Prozess belegt
* **RES - Physikalischer Speicher von einem Prozess belegt**
* SHR - Shred-Speicher von einem Prozess belegt
* S - Der aktuelle Status des Prozesses, es gibt einen besonderen Zustand zu beachten! Z (Zombie-Prozess). Wenn es eine große Anzahl von Zombie-Prozessen gibt, wird dies die Leistung der Maschine negativ beeinflussen.
* **CPU% - Prozentsatz der CPU, die von jedem Prozess verbraucht werden**
* MEM% - Prozentsatz des von jedem Prozess verbrauchten Speichers
* TIME+ - zeigt die Laufzeit seit Beginn des Prozesses an
* Command - der Befehl, der dem Prozess entspricht

### Beschreibung der Tastenkombination

Drücken Sie ++f1++ in der interaktiven Schnittstelle, um die entsprechende Tastenbeschreibung anzuzeigen.

* Mit den Pfeiltasten nach oben, unten, links und rechts lässt sich durch die interaktive Oberfläche scrollen und mit ++space++ lässt sich der entsprechende Vorgang markieren, der gelb unterlegt ist.
* Die Tasten ++n++, ++p++, ++m++ und ++t++ dienen jeweils zum Sortieren nach PID, CPU%, MEM% und TIME+. Natürlich können Sie auch per Mausklick eine aufsteigende oder absteigende Sortierung nach einem bestimmten Feld durchführen.

### Andere häufige Anwendungsfälle

Um den Prozess zu verwalten, verwenden Sie die Taste ++f9++ und so verschiedene Signale an den Prozess zu senden. Die Liste der Signale finden Sie mit dem Kommando `kill -l`. Die am häufigsten verwendeten sind:

| Signal | Beschreibung                                                                                                                                                                                           |
| ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1      | Ermöglicht den Prozess sofort herunterzufahren und dann nach dem erneuten Lesen der Konfigurationsdatei neu zu starten                                                                                 |
| 9      | Wird zum sofortigen Schließen eines Programms oder zum Erzwingen des Beendens eines Prozesses verwendet, ähnlich dem Erzwingen des Beendens in der Windows-Taskleiste                                  |
| 15     | Das Default-Signal für den kill Befehl. Manchmal, wenn im Prozess ein Problem aufgetreten ist und der Prozess mit diesem Signal nicht normal beendet werden kann, können Sie es mit Signal 9 versuchen |

## Zusammenfassung

`htop` ist viel einfacher zu verwenden als das mit dem System gelieferte `top`, es ist intuitiver und verbessert die tägliche Nutzung erheblich. Aus diesem Grund ist `htop` normalerweise eines der ersten Pakete, das der Autor nach der Installation eines neuen Betriebssystems installiert.
