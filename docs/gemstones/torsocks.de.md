---
title: torsocks - Route Traffic Via Tor/SOCKS5
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
date: 2024-02-25
---

# `torsocks` - Einleitung

„torsocks“ ist ein Dienstprogramm zum Umleiten des IP-Verkehrs von einem Befehlszeilenprogramm über das [Tor](https://www.torproject.org/)-Netzwerk oder einen SOCKS5-Server.

## `torsocks` - Verwendung

```bash
dnf -y install epel-release
dnf -y install tor torsocks
systemctl enable --now tor
```

Die Standardoptionen für den Befehl „torsocks“ sind unten aufgeführt und erfordern unter normalen Umständen keine zusätzlichen Optionen. The options come before the application to run (e.g., `curl`):

| Optionen   | Beschreibung                                                            |
| ---------- | ----------------------------------------------------------------------- |
| --shell    | Erstellt mithilfe von LD\_PRELOAD eine neue Shell |
| -u USER    | Setzt den SOCKS5-Benutzernamen                                          |
| -p PASS    | Setzt das SOCKS5-Passwort                                               |
| -a ADDRESS | Setzt die SOCKS5-Server-Adresse                                         |
| -P PORT    | Setzt die SOCKS5-Server-Portnummer                                      |
| -i         | Aktiviert die Tor-Isolation                                             |

Beispielhafte (redigierte) Ausgabe vom IP checker [icanhazip.com](https://icanhazip.com/) via `torsocks`:

![torsocks output](./images/torsocks.png)

Beachten Sie, dass die IP-Adresse von `torsocks` sich von der direkten IP-Adresse von `curl` unterscheidet.
