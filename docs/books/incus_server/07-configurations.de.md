---
title: "Kapitel 7: Container-Konfigurationsoptionen"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - Enterprise
  - Incus-Konfiguration
---

In diesem Kapitel müssen Sie Befehle als nicht privilegierter Benutzer ausführen (`incusadmin`, wenn Sie seit Beginn dieses Buches mitgelesen haben).

Es gibt zahlreiche Optionen, den Container nach der Installation zu konfigurieren. Bevor wir uns diese ansehen, wollen wir uns jedoch den `info`-Befehl für einen Container ansehen. In diesem Beispiel verwenden Sie den Container `ubuntu-test`:

```bash
incus info ubuntu-test
```

Dies ergibt Folgendes:

```bash
Name: ubuntu-test
Location: none
Remote: unix://
Architecture: x86_64
Created: 2021/04/26 15:14 UTC
Status: Running
Type: container
Profiles: default, macvlan
Pid: 584710
Ips:
  eth0:    inet    192.168.1.201    enp3s0
  eth0:    inet6    fe80::216:3eff:fe10:6d6d    enp3s0
  lo:    inet    127.0.0.1
  lo:    inet6    ::1
Resources:
  Processes: 13
  Disk usage:
    root: 85.30MB
  CPU usage:
    CPU usage (in seconds): 1
  Memory usage:
    Memory (current): 99.16MB
    Memory (peak): 110.90MB
  Network usage:
    eth0:
      Bytes received: 53.56kB
      Bytes sent: 2.66kB
      Packets received: 876
      Packets sent: 36
    lo:
      Bytes received: 0B
      Bytes sent: 0B
      Packets received: 0
      Packets sent: 0
```

Die Profile liefern nützliche Informationen über den verwendeten Speicher, den belegten Festplattenspeicher und vieles mehr.

## Ein Paar Worte über die Konfiguration und einige Optionen

Incus weist dem Container standardmäßig den benötigten Systemspeicher, Festplattenspeicher, CPU-Kerne und andere Ressourcen zu. Was aber, wenn Sie spezifische Einstellungen benötigen? Das ist durchaus möglich.

Dabei müssen Kompromisse eingegangen werden. Wenn Sie beispielsweise Systemspeicher zuweisen und der Container nicht den gesamten Speicher nutzt, haben Sie ihn für einen anderen Container reserviert, der ihn möglicherweise benötigt. Auch der umgekehrte Fall kann eintreten. Wenn ein Container mehr Speicher als ihm zusteht beanspruchen möchte, kann dies dazu führen, dass andere Container nicht genügend Speicher erhalten und dadurch deren Leistung beeinträchtigt wird.

Denken Sie daran, dass jede Aktion, die Sie zur Konfiguration eines Containers vornehmen, an anderer Stelle negative Auswirkungen haben kann.

Anstatt alle Konfigurationsoptionen einzeln durchzugehen, verwenden Sie die automatische Vervollständigung per Tabulator, um die verfügbaren Optionen anzuzeigen:

```bash
incus config set ubuntu-test
```

und dann ++tab++ drücken.

Hier werden Ihnen alle Optionen zur Konfiguration eines Containers angezeigt. Wenn Sie Fragen dazu haben, was eine der Konfigurationsoptionen bewirkt, gehen Sie zur [offiziellen Dokumentation für Incus](https://linuxcontainers.org/incus/docs/main/config-options/) und suchen Sie nach dem Konfigurationsparameter oder googeln Sie die gesamte Zeichenfolge, z. B. `incus config set limits.memory`, und prüfen Sie die Suchergebnisse.

Hier betrachten wir einige der am häufigsten verwendeten Konfigurationsoptionen. Wenn Sie beispielsweise die maximale Speichermenge festlegen möchten, die ein Container verwenden darf:

```bash
incus config set ubuntu-test limits.memory 2GB
```

Das bedeutet, dass, wenn beispielsweise 2 GB Arbeitsspeicher zur Verfügung stehen, der Container tatsächlich mehr als 2 GB nutzen kann. Es handelt sich beispielsweise um eine soft-limit.

```bash
incus config set ubuntu-test limits.memory.enforce 2GB
```

Das bedeutet, dass der Container niemals mehr als 2 GB Arbeitsspeicher nutzen kann, unabhängig davon, ob dieser aktuell verfügbar ist oder nicht. In diesem Fall handelt es sich um eine harte Grenze – `hard limit`.

```bash
incus config set ubuntu-test limits.cpu 2
```

Das bedeutet, dass die Anzahl der vom Container verwendeten CPU-Kerne auf 2 begrenzt wird.

!!! note "Hinweis"

```
Als dieses Dokument für Rocky Linux 9.0 neu geschrieben wurde, war das ZFS-Repository für 9 nicht verfügbar. Aus diesem Grund wurden alle unsere Testcontainer mit `dir` im Init-Prozess erstellt. Aus diesem Grund zeigt das folgende Beispiel einen `dir`-Speicherpool anstelle eines `zfs`-Speicherpools.
```

Erinnern Sie sich noch an die Einrichtung unseres Speicherpools im ZFS-Kapitel? Sie haben den Pool `storage` genannt, aber Sie hätten ihn auch beliebig benennen können. Wenn Sie dies untersuchen möchten, können Sie diesen Befehl verwenden, der gleichermaßen für alle anderen Pool-Typen funktioniert (wie am Beispiel von `dir` gezeigt):

```bash
incus storage show storage
```

Dies ergibt Folgendes:

```bash
config:
  source: /var/snap/lxd/common/lxd/storage-pools/storage
description: ""
name: storage
driver: dir
used_by:
- /1.0/instances/rockylinux-test-8
- /1.0/instances/rockylinux-test-9
- /1.0/instances/ubuntu-test
- /1.0/profiles/default
status: Created
locations:
- none
```

Dies zeigt, dass alle unsere Container unseren `dir`-Speicherpool verwenden. Bei der Verwendung von ZFS können Sie auch ein Festplattenkontingent für einen Container festlegen. So sieht der Befehl aus, der ein Festplattenkontingent von 2 GB für den ubuntu-test-Container festlegt:

```bash
incus config device override ubuntu-test root size=2GB
```

Wie ich bereits erwähnt habe, können Sie Konfigurationsoptionen sparsam einsetzen, es sei denn, Sie haben einen Container, der mehr Ressourcen nutzen möchte, als ihm zustehen. Incus wird die Umgebung größtenteils gut managen.

Es gibt noch viele weitere Optionen, die für manche Leute von Interesse sein könnten. Eigene Recherchen helfen Ihnen dabei, festzustellen, ob einige dieser Punkte in Ihrem Umfeld von Nutzen sind.
