---
title: Kapitel 8 — Container-Snapshots
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - Enterprise
  - incus snapshots
---

In diesem Kapitel müssen Sie alle Befehle als Ihr Benutzer mit eingeschränkten Rechten ausführen (<code>incusadmin</code>, falls Sie den Anweisungen von Anfang dieses Buches gefolgt sind).

Container-Snapshots und ein Snapshot-Server (darauf kommen wir später zurück) sind die wichtigsten Aspekte beim Betrieb eines Incus-Servers in der Produktion. Snapshots gewährleisten eine schnelle Wiederherstellung. Es empfiehlt sich, sie als Sicherheitsmaßnahme zu verwenden, wenn die primäre Software aktualisiert wird, die auf einem bestimmten Container läuft. Sollte während des Updates etwas passieren, das die Anwendung beschädigt, stellen Sie einfach die Momentaufnahme wieder her, und die Anwendung ist nach nur wenigen Sekunden Ausfallzeit wieder betriebsbereit.

Der Autor verwendete Incus-Container für die öffentlich zugänglichen PowerDNS-Server, und die Aktualisierung dieser Anwendungen wurde dank der Erstellung von Snapshots vor jeder Aktualisierung weniger problematisch.

Sie können sogar einen Snapshot eines Containers erstellen, während er gerade läuft.

## Der Snapshot-Prozess

Beginnen Sie damit, einen Snapshot des Containers `ubuntu-test` zu erstellen, indem Sie folgenden Befehl verwenden:

```bash
incus snapshot create ubuntu-test ubuntu-test-1
```

Hier nennen Sie den Snapshot `ubuntu-test-1`, Sie können ihn aber auch beliebig benennen. Um sicherzustellen, dass Sie den Snapshot haben, führen Sie ein `incus info` des Containers durch:

```bash
incus info ubuntu-test
```

Sie haben sich bereits einen Infobildschirm angesehen. Wenn Sie nach unten scrollen, sehen Sie jetzt Folgendes:

```bash
Snapshots:
  ubuntu-test-1 (taken at 2021/04/29 15:57 UTC) (stateless)
```

Success! Unser Snapshot liegt vor.

Mit folgendem Befehl erhalten Sie Zugang zum Container `ubuntu-test`:

```bash
incus shell ubuntu-test
```

Erstellen Sie eine leere Datei mit dem Befehl _touch_:

```bash
touch this_file.txt
```

Container verlassen.

Bevor man den Container in den Zustand vor der Erstellung der Datei zurückversetzt, ist es am sichersten, den Container zunächst anzuhalten, insbesondere wenn viele Änderungen vorgenommen wurden:

```bash
incus stop ubuntu-test
```

Wiederherstellen:

```bash
incus snapshot restore ubuntu-test ubuntu-test-1
```

Den Container erneut starten:

```bash
incus start ubuntu-test
```

Wenn Sie zum Container zurückkehren und nachsehen, ist die von Ihnen erstellte Datei `this_file.txt` verschwunden.

Wenn Sie einen Snapshot nicht mehr benötigen, können Sie ihn löschen:

```bash
incus snapshot delete ubuntu-test ubuntu-test-1
```

!!! warning "Warnhinweis"

````
Sie sollten Snapshots dauerhaft löschen, während der Container läuft. Warum? Der Befehl 
`incus delete` löscht auch den gesamten Container. Wenn wir im obigen Befehl versehentlich nach `ubuntu-test` die Eingabetaste drücken und der Container gestoppt ist, wird er gelöscht. Es erfolgt keine Warnung. Der Container führt einfach die gewünschte Aktion aus.

Wenn der Container läuft, erhalten Sie jedoch folgende Meldung:

```
Error: The instance is currently running, stop it first or pass --force
```

Löschen Sie Snapshots daher immer, während der Container läuft.
````

In den folgenden Kapiteln werden Sie:

- den Prozess zum automatischen Erstellen von Snapshots einrichten
- das Ablaufdatum des Snapshots so festlegen, dass er nach einer bestimmten Zeitspanne verschwindet
- automatische Aktualisierung von Snapshots auf dem Snapshot-Server einrichten
