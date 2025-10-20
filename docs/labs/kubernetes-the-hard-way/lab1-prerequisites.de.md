---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - Laborübung
---

# Labor 1: Voraussetzungen

!!! info

    Dies ist ein Fork des ursprünglichen ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), das ursprünglich von Kelsey Hightower geschrieben wurde (GitHub: kelseyhightower). Im Gegensatz zum Original, das auf Debian-ähnlichen Distributionen für die ARM64-Architektur basiert, zielt dieser Fork auf Enterprise-Linux-Distributionen wie Rocky Linux ab, das auf der x86_64-Architektur läuft.

In diesem Labor überprüfen Sie die Maschinenanforderungen, die zum Durchführen dieses Lernprogramms erforderlich sind.

## Virtuelle oder Physische Maschinen

Dieses Tutorial erfordert vier (4) virtuelle oder physische x86_64-Maschinen mit Rocky Linux 9.5 (Incus- oder LXD-Container sollten auch funktionieren). In der folgenden Tabelle sind die vier Maschinen und ihre CPU-, Speicher- und Speicherplatzanforderungen aufgeführt.

| Name    | Beschreibung             | CPU | RAM   | Speicher |
| ------- | ------------------------ | --- | ----- | -------- |
| jumpbox | Verwaltungs-Host         | 1   | 512MB | 10GB     |
| server  | Kubernetes-Server        | 1   | 2GB   | 20GB     |
| node-0  | Kubernetes-Worker-Knoten | 1   | 2GB   | 20GB     |
| node-1  | Kubernetes-Worker-Knoten | 1   | 2GB   | 20GB     |

Wie Sie die Maschinen bereitstellen, bleibt Ihnen überlassen. Die einzige Voraussetzung ist, dass jede Maschine die oben genannten Systemanforderungen erfüllt, einschließlich der Maschinenspezifikationen und der Betriebssystemversion. Sobald Sie alle vier Maschinen bereitgestellt haben, überprüfen Sie die Systemanforderungen, indem Sie auf jeder Maschine den Befehl `uname` ausführen:

```bash
uname -mov
```

Nachdem Sie den Befehl `uname` ausgeführt haben, sollten Sie die folgende Ausgabe sehen:

```text
#1 SMP PREEMPT_DYNAMIC Wed Feb 19 16:28:19 UTC 2025 x86_64 GNU/Linux
```

Das „x86_64“ in der Ausgabe bestätigt, dass das System eine x86_64-Architektur hat. Dies sollte bei verschiedenen AMD- und Intel-basierten Systemen der Fall sein.

Weiter: [setting-up-the-jumpbox](lab2-jumpbox.md)
