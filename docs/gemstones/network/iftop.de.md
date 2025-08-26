---
title: iftop - Echtzeit-Bandbreitenstatistik pro Verbindung
author: Neel Chauhan
contributors: Ganna Zhyrnova, Steven Spencer
date: 2024-02-24
---

# `iftop` - Einleitung

`iftop` ist ein textbasierter Netzwerk-Monitor. Zeigen Sie die Traffic- und Bandbreiten-Statistiken Ihres Servers für jede Verbindung an.

## `iftop`-Verwendung

```bash
dnf -y install epel-release
dnf -y install iftop
```

Es folgen die Optionen des Befehls `iftop`.

| Options        | Beschreibung                                                                                   |
| -------------- | ---------------------------------------------------------------------------------------------- |
| -n             | Vermeidet Hostnamen-Lookups                                                                    |
| -N             | Vermeidet die Auflösung von Port-Nummern in Dienstnamen                                        |
| -p             | Es läuft im Promiscuous-Modus, sodass der gesamte Verkehr gezählt wird                         |
| -P             | Zeigt die Portnummern für Verbindungen an                                                      |
| -l             | Zeigt und zählt den Traffic zu oder von lokalen IPv6-Adressen                                  |
| -b             | Zeigt keine Balkendiagramme für den Traffic an                                                 |
| -m LIMIT       | Legt eine Obergrenze für das Bandbreitendiagramm fest, angegeben als Zahl und Einheiten-Suffix |
| -u UNIT        | Zeigt die Traffic-Geschwindigkeiten für die angegebene Maßeinheit an                           |
| -B UNIT        | Synonym für `-u`                                                                               |
| -i INTERFACE   | Gemessene Schnittstelle                                                                        |
| -f FILTER CODE | Verwendet den folgenden Filtercode                                                             |
| -F NET/MASK    | Misst nur den Traffic zum angegebenen IPv4-Netzwerk                                            |
| -G NET/MASK    | Misst den Traffic nur zum angegebenen IPv6-Netzwerk                                            |
| -c config      | Verwendet die angegebene Konfigurationsdatei                                                   |
| -t             | `non-ncurses`-Modus verwenden                                                                  |

Die Einheiten für das Flag **-M** sind folgende:

| Einheit | Bedeutung |
| ------- | --------- |
| K       | Kilo      |
| M       | Mega      |
| G       | Giga      |

Die Einheiten für das Flag **-u** sind folgende:

| Einheit | Bedeutung          |
| ------- | ------------------ |
| bit     | bits per second    |
| bytes   | bytes per second   |
| packets | packets per second |

Ein Beispiel für die Ausgabe vom Heimserver des Autors, auf dem ein [Tor](https://www.torproject.org/) [Relay](https://community.torproject.org/relay/types-of-relays/)-Programm ausgeführt wird:

```bash
 Listening on bridge b          25.0Kb          37.5Kb          50.0Kb    62.5Kb
└───────────────┴───────────────┴───────────────┴───────────────┴───────────────
tt.neelc.org               => X.X.X.X                    13.5Mb  13.5Mb  13.5Mb
                           <=                             749Kb   749Kb   749Kb
tt.neelc.org               => X.X.X.X                    6.21Mb  6.21Mb  6.21Mb
                           <=                             317Kb   317Kb   317Kb
tt.neelc.org               => X.X.X.X                    3.61Mb  3.61Mb  3.61Mb
                           <=                             194Kb   194Kb   194Kb
tt.neelc.org               => X.X.X.X                     181Kb   181Kb   181Kb
                           <=                            3.36Mb  3.36Mb  3.36Mb
tt.neelc.org               => X.X.X.X                     151Kb   151Kb   151Kb
                           <=                            3.24Mb  3.24Mb  3.24Mb
tt.neelc.org               => X.X.X.X                    2.97Mb  2.97Mb  2.97Mb
                           <=                             205Kb   205Kb   205Kb
tt.neelc.org               => X.X.X.X                     156Kb   156Kb   156Kb
                           <=                            2.97Mb  2.97Mb  2.97Mb
tt.neelc.org               => X.X.X.X                    2.80Mb  2.80Mb  2.80Mb
                           <=                             145Kb   145Kb   145Kb
tt.neelc.org               => X.X.X.X                     136Kb   136Kb   136Kb
                           <=                            2.45Mb  2.45Mb  2.45Mb
────────────────────────────────────────────────────────────────────────────────
TX:             cum:   30.1MB   peak:    121Mb  rates:    121Mb   121Mb   121Mb
RX:                    30.4MB            122Mb            122Mb   122Mb   122Mb
TOTAL:                 60.5MB            242Mb            242Mb   242Mb   242Mb
```

Aufschlüsselung der Zeilen im unteren Bereich:

 - TX – Datennutzung beim Senden/Hochladen
 - RX - Datennutzung empfangen/herunterladen
 - TOTAL – Kombinierte Upload-/Download-Nutzung

## Tastaturkürzel

 - \++s++ - aggregiert den gesamten Datenverkehr für jede Quelle
 - \++d++ - aggregiert den gesamten Datenverkehr für jedes Ziel
 - \++shift+s++ - schaltet die Anzeige des Quellports um
 - \++shift+d++ - schaltet die Anzeige des Zielports um
 - \++t++ - schaltet zwischen den Anzeigemodi um: Standardmäßige zweizeilige Anzeige mit Sende- und Empfangsverkehr und dreizeilige Anzeige von Sende-, Empfangs- und Gesamt-Traffic
 - \++1++, ++2++, ++3++ – Sortieren nach 1., 2. oder 3. Spalte
 - \++l++ - geben Sie einen POSIX-regulären Ausdruck ein, um Hostnamen zu filtern
 - \++shift+p++ - Pausiert die aktuelle Anzeige
 - \++o++ - friert die Gesamtbandbreiten-Auswertung ein
 - \++j++ - nach unten scrollen
 - \++k++ - nach oben scrollen
 - \++f++ – bearbeitet den Filtercode
