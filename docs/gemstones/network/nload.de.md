---
title: nload – Bandbreitenstatistik
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
date: 2024-01-16
---

# `nload` - Einleitung

`nload` ist ein textkonsolenbasierter Netzwerk-Traffic-Monitor. Es zeigt die Traffics- und Bandbreiten-Statistiken Ihres Servers.

## `nload`-Verwendung

```bash
dnf -y install epel-release
dnf -y install nload
```

Im Folgenden finden Sie allgemeine Optionen für den Befehl `nload`, die unter normalen Umständen keine weiteren Schritte erfordern. Die Optionen stehen vor der zu überwachenden Schnittstelle:

| Optionen    | Beschreibung                                                                                            |
| ----------- | ------------------------------------------------------------------------------------------------------- |
| -a PERIOD   | Dauer des Berechnungszeitfensters in Sekunden (Standard: 300)        |
| -m          | Zeigt mehrere Geräte an und zeigt kein Traffic-Diagramm                                                 |
| -t INTERVAL | Aktualisierungsintervall in Millisekunden (Standard: 500)            |
| -u UNIT     | Einbuchstaben-Einheit zur Anzeige der Bandbreite (Standard: k)       |
| -U UNIT     | Einbuchstaben-Einheit zur Anzeige der Datenübertragung (Standard: M) |

Die Einheiten für diese letzten beiden Optionen sind wie folgt:

| Einheit | Bedeutung |
| ------- | --------- |
| b       | bit       |
| B       | Byte      |
| k       | Kilobit   |
| K       | Kilobyte  |
| m       | Megabit   |
| M       | Megabyte  |
| g       | Gigabit   |
| G       | Gigabyte  |

Ein Beispiel für die Ausgabe vom Heimserver des Autors, auf dem ein [Tor](https://www.torproject.org/) [Relay](https://community.torproject.org/relay/types-of-relays/)-Programm ausgeführt wird:

```bash
Device bridge0 [172.20.0.3] (1/8):
================================================================================
Incoming:
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########  Curr: 79.13 MBit/s
                                             ########  Avg: 84.99 MBit/s
                                             ########  Min: 79.13 MBit/s
                                             ########  Max: 87.81 MBit/s
                                             ########  Ttl: 1732.95 GByte
Outgoing:
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########
                                             ########  Curr: 81.30 MBit/s
                                             ########  Avg: 88.05 MBit/s
                                             ########  Min: 81.30 MBit/s
                                             ########  Max: 91.36 MBit/s
                                             ########  Ttl: 1790.74 GByte
```

Aufschlüsselung der obigen Zeilen:

 - Curr - aktuell gemessene Bandbreitennutzung
 - Avg – durchschnittliche Bandbreitennutzung im Zeitraum
 - Min - minimale gemessene Bandbreitennutzung
 - Max – maximal gemessene Bandbreitennutzung
 - Ttl – in der `nload`-Sitzung übertragene Daten

## Tastaturkürzel

 - \++page-down++, ++down++ – Eine Schnittstelle nach unten gehen
 - \++page-up++, ++up++ – Eine Schnittstelle nach oben gehen
 - \++f2++ – Zeigt das Optionsfenster an
 - \++f5++ - Optionen speichern
 - \++f6++ – Einstellungen aus der Konfigurationsdatei neu laden
 - \++q++, ++Strg+C++ – `nload` beenden
