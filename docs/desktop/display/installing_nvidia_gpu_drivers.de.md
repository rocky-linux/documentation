---
title: Installation der NVIDIA-GPU-Treiber
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## Einleitung

NVIDIA^®^ ist einer der beliebtesten GPU-Hersteller. Sie können NVIDIA-GPU-Treiber auf verschiedene Arten installieren. In diesem Handbuch wird das offizielle Repository von NVIDIA zur Installation der Treiber verwendet. Daher wird hier häufig auf das [NVIDIA-Treiberinstallationshandbuch](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html) verwiesen.

Zu den weiteren Möglichkeiten zum Installieren von NVIDIA-Treibern zählen:

- NVIDIAs `.run`-Installationsprogramm
- RPMFusion-Repository eines Drittanbieters
- ELRepo-Treiber eines Drittanbieters

In den meisten Fällen ist es am besten, NVIDIA-Treiber von der offiziellen Quelle zu installieren. RPM Fusion und ELRepo stehen für diejenigen zur Verfügung, die ein Community-basiertes Repository bevorzugen. Für ältere Hardware funktioniert RPM Fusion am besten. Es wird empfohlen, den `.run`-Installer nicht zu verwenden. Obwohl die Verwendung des `.run`-Installationsprogramms praktisch ist, ist es dafür bekannt, dass es Systemdateien überschreibt und zu Inkompatibilitätsproblemen führt.

## Voraussetzungen

Für diese Anleitung benötigen Sie Folgendes:

- Rocky Linux Workstation
- `sudo`-Berechtigungen

## Installieren Sie die erforderlichen Dienstprogramme und Abhängigkeiten

Aktivieren Sie das EPEL-Repository (Extra Packages for Enterprise Linux):

```bash
sudo dnf install epel-release -y
```

Aktivieren Sie das CodeReady Builder (CRB)-Repository:

```bash
sudo dnf config-manager --enable crb
```

Durch die Installation von Entwicklungstools werden die erforderlichen Build-Abhängigkeiten sichergestellt:

```bash
sudo dnf groupinstall "Development Tools" -y
```

Das Paket `kernel-devel` bietet die erforderlichen Header und Tools zum Erstellen von Kernelmodulen:

```bash
sudo dnf install kernel-devel-matched kernel-headers -y
```

## Installation der NVIDIA-Treiber

Nach der Installation der notwendigen Voraussetzungen ist es an der Zeit, die NVIDIA-Treiber zu installieren.

Fügen Sie das offizielle NVIDIA-Repository mit dem folgenden Befehl hinzu:

```bash
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel10/$(uname -m)/cuda-rhel10.repo
```

Als nächstes bereinigen Sie den DNF-Repository-Cache:

```bash
sudo dnf clean expire-cache
```

Installieren Sie abschließend den neuesten NVIDIA-Treiber für Ihr System. Führen Sie für offene Kernel-Module Folgendes aus:

```bash
sudo dnf install nvidia-open -y
```

Für proprietäre Kernel-Module führen Sie Folgendes aus:

```bash
sudo dnf install cuda-drivers -y
```

## `Nouveau` deaktivieren

`Nouveau` ist ein Open-Source-NVIDIA-Treiber, der im Vergleich zu den proprietären Treibern von NVIDIA nur begrenzte Funktionalität bietet. Es empfiehlt sich, diese Funktion zu deaktivieren, um Treiberkonflikte zu vermeiden:

```bash
sudo grubby --args="nouveau.modeset=0 rd.driver.blacklist=nouveau" --update-kernel=ALL
```

!!! note "Anmerkung"

````
Bei Systemen mit aktiviertem Secure Boot führen Sie folgenden Schritt aus:

```bash
sudo mokutil --import /var/lib/dkms/mok.pub
```

Der Befehl `mokutil` fordert Sie zur Eingabe eines Passworts auf, das beim Neustart verwendet wird.

Nach dem Neustart werden Sie gefragt, ob Sie einen Schlüssel oder Ähnliches registrieren möchten. Bestätigen Sie mit `yes`, und Sie werden nach dem Passwort gefragt, das Sie im Befehl `mokutil` angegeben haben.
````

Reboot:

```bash
sudo reboot now
```

## Zusammenfassung

Sie haben NVIDIA-GPU-Treiber mithilfe des offiziellen Repository von NVIDIA erfolgreich auf Ihrem System installiert. Genießen Sie die erweiterten Funktionen Ihrer NVIDIA-GPU, die die Standard-`Nouveau`-Treiber nicht bieten können.
