---
title: 10 Automatisierte Snapshots
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd-Automatisierung
---

# Kapitel 10: Automatisierte Snapshots

In diesem Kapitel müssen Sie der root-Benutzer sein oder Sie sollten in der Lage sein, zu root-Rechte durch `sudo` zu erlangen.

Die Automatisierung des Snapshots erleichtert die Arbeit erheblich.

## Automatisierung des Snapshot-Kopiervorgangs


Dieser Prozess wird auf dem lxd-primary durchgeführt. Als erstes müssen wir ein Skript namens "refresh-containers" erstellen, das von cron in /usr/local/sbin ausgeführt wird:

```
sudo vi /usr/local/sbin/refreshcontainers.sh
```

Das Skript ist ziemlich einfach:

```
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x lxd-snapshot:$x
        done

```

 Machen Sie es wie folgt ausführbar:

```
sudo chmod +x /usr/local/sbin/refreshcontainers.sh
```

Ändern Sie die Rechte - ownership - dieses Skripts auf lxdadmin Benutzer und Gruppe:

```
sudo chown lxdadmin.lxdadmin /usr/local/sbin/refreshcontainers.sh
```

Richten Sie die crontab für den lxdadmin-Benutzer ein, um dieses Skript auszuführen, in diesem Fall um 22 Uhr:

```
crontab -e
```

Der Eintrag sollte dann so aussehen:

```
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/lxdadmin/refreshlog 2>&1
```

Speichern Sie Ihre Änderungen und beenden Sie den Editor.

Dies wird ein Log in lxdadmin's Home-Verzeichnis namens "refreshlog" anlegen, damit stellen Sie sicher, ob Ihr Prozess funktioniert oder nicht. Ganz wichtig!

Die Prozedur wird manchmal fehlschlagen. Dies passiert in der Regel, wenn ein bestimmter Container nicht aktualisiert werden kann. Du kannst die Aktualisierung manuell mit dem folgenden Befehl ausführen (vorausgesetzt rockylinux-test-9 ist unser Container):

```
lxc copy --refresh rockylinux-test-9 lxd-snapshot:rockylinux-test-9
```
