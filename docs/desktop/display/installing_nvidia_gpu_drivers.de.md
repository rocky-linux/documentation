---
title: Installation der NVIDIA-GPU-Treiber
author: Joseph Brinkman
contributors: Steven Spencer, Ganna Zhyrnova
---

## Einleitung

NVIDIA^®^ ist einer der beliebtesten GPU-Hersteller. Sie können NVIDIA-GPU-Treiber auf verschiedene Arten installieren. In diesem Handbuch wird das offizielle Repository von NVIDIA zur Installation der Treiber verwendet. Daher wird hier häufig auf [NVIDIA's Installationshandbuch](https://docs.nvidia.com/cuda/pdf/CUDA_Installation_Guide_Linux.pdf) verwiesen.

!!! note "Anmerkung"

```
Der Link für Vorinstallationsaktionen im offiziellen NVIDIA-Handbuch ist defekt. Um den NVIDIA-Treiber zu installieren, müssen Sie die erforderlichen Dienstprogramme und Abhängigkeiten aus dem offiziellen Repository installieren.
```

Zu den weiteren Möglichkeiten zum Installieren von NVIDIA-Treibern zählen:

- NVIDIA's `.run` installer
- RPMFusion-Repository eines Drittanbieters
- Third-party ELRepo-Treiber

In den meisten Fällen ist es am besten, NVIDIA-Treiber von der offiziellen Quelle zu installieren. RPMFusion und ELRepo stehen für diejenigen zur Verfügung, die ein Community-basiertes Repository bevorzugen. Für ältere Hardware funktioniert RPMFusion am besten. Es wird empfohlen, die Verwendung des `.run`-Installationsprogramms zu vermeiden. Die Verwendung des „.run“-Installationsprogramms ist zwar praktisch, ist aber dafür berüchtigt, Systemdateien zu überschreiben und Inkompatibilitätsprobleme zu verursachen.

## Voraussetzungen

Für diese Anleitung benötigen Sie Folgendes:

- Rocky Linux Workstation
- `sudo`-Berechtigungen

## Installieren Sie die erforderlichen Dienstprogramme und Abhängigkeiten

Aktivieren Sie das EPEL-Repository (Extra Packages for Enterprise Linux):

```bash
sudo dnf install epel-release -y
```

Durch die Installation von Entwicklungstools werden die erforderlichen Build-Abhängigkeiten sichergestellt:

```bash
sudo dnf groupinstall "Development Tools" -y
```

Das Paket `kernel-devel` bietet die erforderlichen Header und Tools zum Erstellen von Kernelmodulen:

```bash
sudo dnf install kernel-devel -y
```

Dynamic Kernel Module Support (DKMS) ist ein Programm, mit dem Kernelmodule automatisch neu erstellt werden:

```bash
sudo dnf install dkms -y
```

## Installation der NVIDIA-Treiber

Nach der Installation der notwendigen Voraussetzungen ist es an der Zeit, die NVIDIA-Treiber zu installieren.

Fügen Sie das offizielle NVIDIA-Repository mit dem folgenden Befehl hinzu:

!!! note "Anmerkung"

```
Wenn Sie Rocky 8 verwenden, ersetzen Sie `rhel9` im Dateipfad durch `rhel8`.
```

```bash
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo
```

Als nächstes installieren Sie die Pakete, die zum Erstellen und Installieren von Kernelmodulen erforderlich sind:

```bash
sudo dnf install kernel-headers-$(uname -r) kernel-devel-$(uname -r) tar bzip2 make automake gcc gcc-c++ pciutils elfutils-libelf-devel libglvnd-opengl libglvnd-glx libglv-devel acpid pkgconfig dkms -y
```

Installieren Sie das neueste NVIDIA-Treibermodul für Ihr System:

```bash
sudo dnf module install nvidia-driver:latest-dkms -y
```

## `Nouveau` deaktivieren

`Nouveau` ist ein Open-Source-NVIDIA-Treiber, der im Vergleich zu den proprietären Treibern von NVIDIA nur begrenzte Funktionalität bietet. Um Treiberkonflikte zu vermeiden, deaktivieren Sie es am besten:

Öffnen Sie die Grub-Konfigurationsdatei mit einem Editor Ihrer Wahl:

```bash
sudo vim /etc/default/grub
```

Fügen Sie am Ende von `GRUB_CMDLINE_LINUX` `nouveau.modeset=0` und `rd.driver.blacklist=nouveau` hinzu.

Der Wert von `GRUB_CMDLINE_LINUX` sollte in etwa dem folgenden Text ähneln, obwohl er nicht exakt übereinstimmen muss:

```bash
GRUB_CMDLINE_LINUX="resume=/dev/mapper/rl-swap rd.lvm.lv=rl/root rd.lvm.lv=rl/swap crashkernel=auto rhgb quiet nouveau.modeset=0 rd.driver.blacklist=nouveau"
```

Laden Sie die Grub-Umgebung neu:

```bash
grub2-mkconfig -o /boot/grub2/grubenv
```

Reboot:

```bash
sudo reboot now
```

## Zusammenfassung

Sie haben NVIDIA-GPU-Treiber mithilfe des offiziellen Repository von NVIDIA erfolgreich auf Ihrem System installiert. Genießen Sie die erweiterten Funktionen Ihrer NVIDIA-GPU, die die Standard-`Nouveau`-Treiber nicht bieten können.
