---
title: Patchen mit dnf-automatic
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5
tags:
  - Sicherheit
  - dnf
  - Automatisierung
  - updates
---

# Server-Patch mit `dnf-automatic`

Für den Systemadministrator ist die Verwaltung der Installation von Sicherheitsupdates eine wichtige Angelegenheit. Die Bereitstellung von Software-Updates ist ein altbewährter Weg, der letztlich wenig Probleme verursacht. Aus diesen Gründen ist es vernünftig, den Download und die Anwendung von Updates täglich und automatisch auf Rocky Server zu automatisieren.

Die Sicherheit Ihres Informationssystems wird verbessert. `dnf-automatic` ist ein zusätzliches Werkzeug, mit dem Sie dies erreichen können.

!!! tip "Wenn Sie sich Sorgen machen..."

    Vor Jahren wäre die automatische Anwendung von Updates ein Rezept für Katastrophen gewesen. Es gab viele Male, bei denen ein Update zu Problemen führen konnte. Dies passiert immer noch selten, wenn etwa eine Aktualisierung eines Pakets eine veraltete Funktion löscht, die auf dem Server verwendet wird aber zum größten Teil handelt es sich heute einfach nicht um ein Problem. Wenn Sie sich jedoch immer noch unwohl fühlen, „dnf-automatic“ Aktualisierungen verwalten zu lassen, sollten Sie darüber nachdenken, sie zum Herunterladen und Benachrichtigen über verfügbare Aktualisierungen zu verwenden. Auf diese Weise bleibt Ihr Server nicht lange ohne Updates. Diese Funktionen sind `dnf-automatic-notifyonly` und `dnf-automatic-download`
    
    Für weitere Informationen zu diesen Features, werfen Sie einen Blick auf die [offizielle Dokumentation](https://dnf.readthedocs.io/en/latest/automatic.html).

## Installation

Sie können `dnf-automatic` aus den Rocky Linux Repositories installieren:

```bash
sudo dnf install dnf-automatic
```

## Konfiguration

Standardmäßig wird der Update-Prozess um 6 Uhr mit einem zufälligen zusätzlichen Zeitversatz gestartet, um zu vermeiden, dass alle Ihre Maschinen gleichzeitig aktualisiert werden. Um dieses Verhalten zu ändern, können Sie die Timer-Konfiguration des Anwendungsdienstes überschreiben:

```bash
sudo systemctl edit dnf-automatic.timer

[Unit]
Description=dnf-automatic timer
# See comment in dnf-makecache.service
ConditionPathExists=!/run/ostree-booted
Wants=network-online.target

[Timer]
OnCalendar=*-*-* 6:00
RandomizedDelaySec=10m
Persistent=true

[Install]
WantedBy=timers.target
```

Diese Konfiguration begrenzt die Startverzögerung zwischen 6:00 und 6:10 Uhr (ein Server, der zu diesem Zeitpunkt heruntergefahren würde, würde nach dem Neustart automatisch gepatcht werden).

Aktivieren Sie anschließend den mit dem Dienst verknüpften Timer (nicht den Dienst selbst):

```bash
sudo systemctl enable --now dnf-automatic.timer
```

## Was ist mit den CentOS 7 Servern?

!!! tip "Hinweis"

    Ja, dies ist die Dokumentation von Rocky Linux, aber falls Sie System- oder Netzwerkadministrator sind, haben Sie möglicherweise noch einige CentOS 7-Maschinen im Einsatz. Das verstehen wir, und deshalb fügen wir diesen Abschnitt hinzu.

Der Prozess unter CentOS 7 ist ähnlich, verwendet aber: `yum-cron`.

```bash
sudo yum install yum-cron
```

Diesmal erfolgt die Konfiguration des Dienstes in der Datei `/etc/yum/yum-cron.conf`.

Konfiguration nach Bedarf vornehmen:

```text
[commands]
#  What kind of update to use:
# default                            = yum upgrade
# security                           = yum --security upgrade
# security-severity:Critical         = yum --sec-severity=Critical upgrade
# minimal                            = yum --bugfix update-minimal
# minimal-security                   = yum --security update-minimal
# minimal-security-severity:Critical =  --sec-severity=Critical update-minimal
update_cmd = default

# Whether a message should be emitted when updates are available,
# were downloaded, or applied.
update_messages = yes

# Whether updates should be downloaded when they are available.
download_updates = yes

# Whether updates should be applied when they are available.  Note
# that download_updates must also be yes for the update to be applied.
apply_updates = yes

# Maximum amount of time to randomly sleep, in minutes.  The program
# will sleep for a random amount of time between 0 and random_sleep
# minutes before running.  This is useful for e.g. staggering the
# times that multiple systems will access update servers.  If
# random_sleep is 0 or negative, the program will run immediately.
# 6*60 = 360
random_sleep = 30
```

Die Kommentare in der Konfigurationsdatei sprechen für sich.

Sie können den Dienst nun aktivieren und starten:

```bash
sudo systemctl enable --now yum-cron
```

## Zusammenfassung

Die automatische Aktualisierung von Paketen lässt sich einfach aktivieren und erhöht die Sicherheit Ihres Informationssystems erheblich.
