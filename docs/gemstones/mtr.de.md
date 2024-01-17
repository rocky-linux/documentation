---
title: mtr - Netzwerk-Diagnose
author: tianci li
contributors: Steven Spencer, Neel Chauhan
date: 2021-10-20
---

# `mtr` Einleitung

`mtr` ist ein Netzwerkdiagnosetool, das Netzwerkprobleme untersuchen kann. Es wird verwendet, um die Befehle `ping` und `traceroute` zu ersetzen. In Bezug auf die Leistung ist der Befehl `mtr` performanter.

## Verwendung von `mtr`

```bash
# Install mtr
shell > dnf -y install mtr
```

Die allgemeinen Optionen des Befehls `mtr` sind folgende. Normalerweise ist keine Option erforderlich, es reicht aus, einfach einen Namen oder eine IP-Adresse anzugeben:

| Optionen | Beschreibung                     |
| -------- | -------------------------------- |
| -4       | # Nur IPv4 verwenden            |
| -6       | # Nur IPv6 verwenden            |
| -c COUNT | # Anzahl gesendeter Pakete      |
| -n       | # Hostname wird nicht aufgelöst |
| -z       | # AS-Nummer anzeigen            |
| -b       | # IP und Hostname anzeigen      |
| -w       | # Umfangreiche Reports ausgeben |

Die vom Terminal ausgetauschten Informationen sind folgende:

```bash
shell > mtr -c 10 bing.com
 My traceroutr [v0.92]
li(192.168.100.4) 2021-10-20T08:02:05+0800
Keys:Help Display mode Restart Statistics Order of fields quit
HOST: li Loss% Snt Last Avg Best Wrst StDev
 1. _gateway 0.0% 10 2.0 5.6 2.0 12.9 3.6
 2. 10.9.128.1 0.0% 10 13.9 14.8 8.5 20.7 3.9
 3. 120.80.175.109 0.0% 10 15.8 15.0 10.0 20.1 3.1
 4. 112.89.0.57 20.0% 10 18.9 15.2 11.5 18.9 2.9
 5.219.158.8.114 0.0% 10 10.8 14.4 10.6 20.5 3.5
 6. 219.158.24.134 0.0% 10 13.1 14.5 11.9 18.9 2.2
 7. 219.158.10.30 0.0% 10 14.9 21.2 12.0 29.8 6.9
 8. 219.158.33.114 0.0% 10 17.7 17.1 13.0 20.0 2.0
 9. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
10. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
11. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
12. ??? 100.0 10 0.0 0.0 0.0 0.0 0.0
13. a-0001.a-msedge.net 0.0% 10 18.4 15.7 9.5 19.3 3.1
...
```

* Loss% - Paketverlustrate
* Snt - Anzahl der gesendeten Pakete
* Last - die Verzögerung des letzten Paketes
* Avg - mittlere Verzögerung
* Best - niedrigste Latenz
* Wtst - maximale Verzögerung
* StDev - Varianz (Stabilität)

## Tastaturkürzel

* ++p++ - Pause
* ++d++ - Switch display mode
* ++n++ - Turn on/off DNS
* ++r++ - Reset all counters
* ++j++ - Toggle delay display information
* ++y++ - Switch IP information
* ++q++ - Quit `mtr`
