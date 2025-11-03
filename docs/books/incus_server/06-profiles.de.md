---
title: "Kapitel 6: Profile"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - Enterprise
  - incus-Profile
---

In diesem Kapitel müssen Sie Befehle als nicht privilegierter Benutzer ausführen (`incusadmin`, wenn Sie diesem Buch von Anfang an gefolgt sind).

Wenn Sie `Incus` installieren, erhalten Sie ein Standardprofil, das Sie nicht entfernen oder ändern können. Sie können das Standardprofil verwenden, um neue Profile für Ihre Container zu erstellen.

Wenn Sie Ihre Containerliste untersuchen, werden Sie feststellen, dass die IP-Adresse in jedem Fall von der überbrückten Schnittstelle – _bridged interface_ – stammt. In einer Produktionsumgebung möchten Sie vielleicht etwas anderes verwenden. Dies kann eine per DHCP zugewiesene Adresse von Ihrer LAN-Schnittstelle oder eine statisch zugewiesene Adresse von Ihrem WAN sein.

Wenn Sie Ihren Incus-Server mit zwei Schnittstellen konfigurieren und jeder eine IP in Ihrem WAN und LAN zuweisen, können Sie die IP-Adressen Ihres Containers basierend auf der Schnittstelle zuweisen, mit der der Container verbunden sein muss.

Ab Rocky Linux Version 9.4 (und jeder Bug-für-Bug-Kopie von Red Hat Enterprise Linux) funktioniert die Methode zum statischen oder dynamischen Zuweisen von IP-Adressen mit den Profilen nicht mehr.

Es gibt Möglichkeiten, dieses Problem zu umgehen, aber es ist unangenehm. Dies scheint etwas mit Änderungen am Network Manager zu tun zu haben, die sich auf `macvlan` auswirken. `macvlan` ermöglicht Ihnen, viele Schnittstellen mit unterschiedlichen Layer-2-Adressen zu erstellen.

Beachten Sie, dass dies bei der Auswahl von Container-Images basierend auf RHEL Nachteile hat.

## Erstellen und Zuweisen eines `macvlan`-Profils

Um Ihr `macvlan`-Profil zu erstellen, verwenden Sie folgenden Befehl:

```bash
incus profile create macvlan
```

Wenn Sie sich auf einem Computer mit mehreren Schnittstellen befinden und mehr als eine `macvlan`-Vorlage basierend auf dem Netzwerk benötigen, das Sie erreichen möchten, können Sie `lanmacvlan` oder `wanmacvlan` oder einen anderen Namen verwenden, den Sie zur Identifizierung des Profils verwendet haben. Die Verwendung von `macvlan` in Ihrer Profilerstellungsanweisung liegt bei Ihnen.

Sie möchten die `macvlan`-Schnittstelle ändern, aber bevor Sie dies tun, müssen Sie wissen, was die übergeordnete Schnittstelle für Ihren Incus-Server ist. Dieser Schnittstelle wird (in diesem Fall) eine vom LAN definierte IP zugewiesen. Um herauszufinden, um welche Schnittstelle es sich handelt, verwenden Sie:

```bash
ip addr
```

Suchen Sie im Netzwerk 192.168.1.0/24 nach der Schnittstelle mit der LAN-IP-Zuweisung:

```bash
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 40:16:7e:a9:94:85 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.106/24 brd 192.168.1.255 scope global dynamic noprefixroute enp3s0
       valid_lft 4040sec preferred_lft 4040sec
    inet6 fe80::a308:acfb:fcb3:878f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

In diesem Fall wäre die Schnittstelle also `enp3s0`.

Jetzt ändern wir das Profil:

```bash
incus profile device add macvlan eth0 nic nictype=macvlan parent=enp3s0
```

Dieser Befehl fügt alle für die Verwendung erforderlichen Parameter zum `macvlan`-Profil hinzu.

Untersuchen Sie, was dieser Befehl erstellt hat, indem Sie den folgenden Befehl verwenden:

```bash
incus profile show macvlan
```

Dadurch erhalten Sie eine Ausgabe ähnlich der folgenden:

```bash
config: {}
description: ""
devices:
  eth0:
    nictype: macvlan
    parent: enp3s0 
    type: nic
name: macvlan
used_by: []
```

Profile können für viele andere Dinge verwendet werden, aber die Zuweisung einer statischen IP zu einem Container oder die Verwendung eines eigenen DHCP-Servers sind häufige Anforderungen.

Um das Profil `macvlan` rockylinux-test-8 zuzuweisen, müssen Sie Folgendes tun:

```bash
incus profile assign rockylinux-test-8 default,macvlan
```

Tun Sie das Gleiche für rockylinux-test-9:

```bash
incus profile assign rockylinux-test-9 default,macvlan
```

Dies bedeutet, dass Sie das Standardprofil verwenden und auch das `macvlan`-Profil anwenden möchten.

## Rocky Linux `macvlan`

Der Netzwerkmanager hat sich in RHEL-Distributionen und -Derivate ständig geändert. Aus diesem Grund passt die Funktionsweise des `macvlan`-Profils nicht (zumindest im Vergleich zu anderen Distributionen) und erfordert zusätzlichen Aufwand für die Zuweisung von IP-Adressen per DHCP oder statisch.

Denken Sie daran, dass dies alles nicht in erster Linie mit Rocky Linux zu tun hat, sondern mit der Upstream-Paketimplementierung.

Wenn Sie Rocky Linux-Container ausführen und `macvlan` verwenden möchten, um eine IP-Adresse aus Ihren LAN- oder WAN-Netzwerken zuzuweisen, ist der Vorgang je nach Containerversion des Betriebssystems (8.x oder 9.x) unterschiedlich.

### Rocky Linux 9.x macvlan – Der DHCP Fix

Lassen Sie uns zunächst veranschaulichen, was beim Stoppen und Neustarten der beiden Container nach der Zuweisung des Profils `macvlan` passiert.

Durch die Zuweisung des Profils wird jedoch die Standardkonfiguration, die standardmäßig DHCP ist, nicht geändert.

Um dies zu testen, gehen Sie wie folgt vor:

```bash
incus restart rocky-test-8
incus restart rocky-test-9
```

Listen Sie Ihre Container erneut auf und beachten Sie, dass rockylinux-test-9 keine IP-Adresse mehr hat:

```bash
incus list
```

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING |                      |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

Wie Sie sehen, hat Ihr Rocky Linux 8.x-Container die IP-Adresse von der LAN-Schnittstelle erhalten, der Rocky Linux 9.x-Container hingegen nicht.

Um das Problem weiter zu demonstrieren, müssen Sie `dhclient` auf dem Rocky Linux 9.x-Container ausführen. Dies zeigt uns, dass das Profil `macvlan` _angewendet_ wurde:

```bash
incus exec rockylinux-test-9 dhclient
```

Eine weitere Container-Auflistung zeigt nun Folgendes:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.113 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

Das hätte mit einem einfachen Stopp und dem Start des Containers geschehen müssen, aber das ist nicht der Fall. Angenommen, Sie möchten jedes Mal eine per DHCP zugewiesene IP-Adresse verwenden, können Sie dies mit einem einfachen Crontab-Eintrag beheben. Dazu müssen Sie Shell-Zugriff auf den Container erhalten, indem Sie Folgendes eingeben:

```bash
incus shell rockylinux-test-9
```

Als nächstes bestimmen wir den Pfad zu `dhclient`. Da dieser Container aus einem minimalen Image stammt, müssen Sie dazu zunächst `which` installieren:

```bash
dnf install which
```

Dann Folgendes ausführen:

```bash
which dhclient
```

Dies sollte Folgendes ergeben:

```bash
/usr/sbin/dhclient
```

Als nächstes ändern Sie die Crontab von Root:

```bash
crontab -e
```

Diese Zeile hinzufügen:

```bash
@reboot    /usr/sbin/dhclient
```

Der eingegebene Befehl `crontab` verwendet _vi_. Verwenden Sie ++shift+colon+"w"+"q"++, um Ihre Änderungen zu speichern und zu beenden.

Beenden Sie nun den Container und starten Sie `rockylinux-test-9` neu:

```bash
incus restart rockylinux-test-9
```

Eine neue Auflistung wird zeigen, dass dem Container die DHCP-Adresse zugewiesen wurde:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.113 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```

### Rocky Linux 9 and 10 `macvlan` - The static IP fix

Bei der statischen Zuweisung einer IP-Adresse wird es noch komplizierter. Da `network-scripts` in Rocky Linux 9.x mittlerweile veraltet ist, ist die einzige Möglichkeit, dies zu tun, die statische Zuweisung. Aufgrund der Art und Weise, wie die Container das Netzwerk verwenden, können Sie die Route nicht mit einer normalen `ip route`-Anweisung festlegen. Das Problem besteht darin, dass die Schnittstelle, die bei der Anwendung des `macvlan`-Profils zugewiesen wird (in diesem Fall `eth0`), nicht mit dem NetworkManager verwaltet werden kann. Die Lösung besteht darin, die Netzwerkschnittstelle des Containers nach dem Neustart umzubenennen und die statische IP zuzuweisen. Sie können dies mit einem Skript tun und es (erneut) in der Crontab von Root ausführen. Tun Sie dies mit dem `ip`-Befehl. Zusätzlich zur Festlegung der IP-Adresse müssen Sie auch den DNS-Server für die Namensauflösung konfigurieren. Auch dies ist nicht so einfach wie das Ausführen von `nmtui`, um die Verbindung zu ändern, da die Verbindung im NetworkManager nicht vorhanden ist. Die Lösung besteht darin, eine Textdatei zu erstellen, die die DNS-Server enthält, die Sie verwenden möchten.

Dazu benötigen Sie erneut Shell-Zugriff auf den Container:

```bash
incus shell rockylinux-test-9
```

Erstellen Sie eine Textdatei in `/usr/local/sbin/`:

```bash
vi /usr/local/sbin/dns.txt
```

Fügen Sie der Datei Folgendes hinzu:

```text
nameserver 8.8.8.8
nameserver 8.8.4.4
```

Speichern Sie die Datei und beenden Sie das Programm. Dies zeigt, dass Sie die offenen DNS-Server von Google verwenden. Wenn Sie andere DNS-Server verwenden möchten, ersetzen Sie die angezeigten IP-Adressen durch Ihre bevorzugten DNS-Server.

Als Nächstes erstellen Sie ein Bash-Skript in `/usr/local/sbin` mit dem Namen „static“:

```bash
vi /usr/local/sbin/static
```

Der Inhalt dieses Skripts ist nicht kompliziert:

```bash
#!/usr/bin/env bash

/usr/sbin/ip link set dev eth0 name net0
/usr/sbin/ip addr add 192.168.1.151/24 dev net0
/usr/sbin/ip link set dev net0 up
sleep 2
/usr/sbin/ip route add default via 192.168.1.1
/usr/bin/cat /usr/local/sbin/dns.txt > /etc/resolv.conf
```

Was machen Sie hier mit diesem Script?

- Sie benennen `eth0` in einen neuen Namen um, den Sie verwalten können (`net0`)
- Sie weisen die neue statische IP zu, die Sie für Ihren Container zugewiesen haben (`192.168.1.151`)
- Sie setzen die neue Schnittstelle `net0` auf
- Sie fügen eine Wartezeit von 2 Sekunden hinzu, bis die Schnittstelle aktiv ist, bevor Sie die Standardroute hinzufügen
- Sie müssen die Standardroute für Ihre Schnittstelle hinzufügen
- Sie müssen die Datei `resolv.conf` für die DNS-Auflösung füllen

Machen Sie Ihr Skript mit Folgendem ausführbar:

```bash
chmod +x /usr/local/sbin/static
```

Fügen Sie dies der Crontab des Root-Benutzers für den Container mit der @reboot-Zeit hinzu:

```bash
@reboot     /usr/local/sbin/static
```

Beenden Sie abschließend den Container und starten Sie ihn neu:

```bash
incus restart rockylinux-test-9
```

Warten Sie einige Sekunden und listen Sie die Container erneut auf:

```bash
incus list
```

Dies sollte Folgendes ergeben:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

## Ubuntu macvlan

Glücklicherweise zerstört die Ubuntu-Implementierung von Network Manager den `macvlan` Stack nicht, was die Bereitstellung erheblich vereinfacht!

Genau wie bei Ihrem Container `rockylinux-test-9` müssen Sie Ihrem Container das Profil zuweisen:

```bash
incus profile assign ubuntu-test default,macvlan
```

Um herauszufinden, ob DHCP dem Container eine Adresse zuweist, stoppen und starten Sie den Container erneut:

```bash
incus restart ubuntu-test
```

Die Container erneut auflisten:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 192.168.1.132 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

Geschafft!

Die Konfiguration der statischen IP ist etwas anders, aber nicht schwierig. Sie müssen die mit der Containerverbindung verknüpfte YAML-Datei ändern (`10-incus.yaml`). Für diese statische IP-Adresse können Sie `192.168.1.201` verwenden:

```bash
vi /etc/netplan/10-incus.yaml
```

Ändern Sie den Inhalt wie folgt:

```bash
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [192.168.1.201/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
```

Bitte speichern Sie Ihre Änderungen und verlassen Sie den Container.

Den Container neu starten:

```bash
incus restart ubuntu-test
```

Wenn Sie Ihre Container erneut auflisten, sehen Sie Ihre statische IP:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 192.168.1.201 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```

Geschafft!

In den hier verwendeten Beispielen wurde bewusst ein schwer zu konfigurierender Container und zwei weniger schwierige gewählt. Viele weitere Linux-Versionen sind in der Image-Liste enthalten. Wenn Sie einen Favoriten haben, versuchen Sie, ihn zu installieren, die Vorlage `macvlan` zuzuweisen und IPs festzulegen.
