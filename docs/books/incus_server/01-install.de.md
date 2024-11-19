---
title: "Kapitel 1: Installation und Konfiguration"
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - Incus
  - enterprise
  - incus-Installation
---

In diesem Abschnitt müssen Sie der root-Benutzer sein oder Sie müssen in der Lage sein, zu root-Rechte durch _sudo_ zu erlangen.

## Installation von EPEL und OpenZFS

Incus benötigt die EPEL (Extra Packages for Enterprise Linux) repository, die sehr einfach wie folgt zu installieren ist:

```bash
dnf install epel-release -y
```

Sobald installiert, können Sie prüfen, ob Updates verfügbar sind:

```bash
dnf upgrade
```

Wenn während des Upgrade-Vorgangs Kernel-Updates durchgeführt wurden, starten Sie den Server neu.

### OpenZFS-Repository

Installieren Sie das OpenZFS Repository wie folgt mit:

```bash
dnf install https://zfsonlinux.org/epel/zfs-release-2-2$(rpm --eval "%{dist}").noarch.rpm
```

## Installation von `dkms`, `vim` und `kernel-devel`

Benötigte Pakete installieren:

```bash
dnf install dkms vim kernel-devel bash-completion
```

## Incus-Installation

Sie benötigen das für einige spezielle Pakete verfügbare CRB-Repository und Neil Hanlons COPR (Cool Other Package Repo):

```bash
dnf config-manager --enable crb
dnf copr enable neil/incus
dnf install incus incus-tools
```

Aktivieren und starten Sie den Dienst:

```bash
systemctl enable incus --now
```

Starten Sie den Server neu, bevor Sie hier fortfahren.

## OpenZFS Installation

```bash
dnf install zfs
```

## Einrichtung der Umgebung

Zum Ausführen vieler Container sind mehr als die meisten Server-Kernel-Einstellungen erforderlich. Wenn wir von Anfang an annehmen, dass wir unseren Server in der Produktion verwenden, dann müssen wir diese Änderungen vornehmen, um Fehler wie "Zu viele offene Dateien" zu vermeiden.

Glücklicherweise ist das Optimieren der Einstellungen für `Incus` mit geeigneten Dateiänderungen und einem Neustart nicht schwierig.

### Anpassung von `limits.conf`

Die erste Datei, die Sie ändern müssen, ist die Datei `limits.conf`. Diese Datei ist selbst dokumentiert. Untersuchen Sie die Erklärungen als Kommentare in der Datei, um zu verstehen, was diese Datei macht. Um Ihre Änderungen vorzunehmen, geben Sie Folgendes ein:

```bash
vi /etc/security/limits.conf
```

Diese gesamte Datei besteht aus Kommentaren und zeigt unten die aktuellen Standardeinstellungen. Sie müssen Ihre benutzerdefinierten Einstellungen in den leeren Bereich über dem Ende der Dateimarkierung (#End of file) einfügen. Das Ende der Datei sieht so aus, wenn Sie fertig sind:

```text
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Speichern Sie Ihre Änderungen und beenden Sie das Programm (++shift+colon+"w"+"q"+exclam++ für _vi_).

### Modifizieren von `sysctl.conf` mit `90-incus-override.conf`

Mit _systemd_ können Sie die Gesamtkonfiguration und die Kerneloptionen Ihres Systems ändern, _ohne_ die Hauptkonfigurationsdatei zu ändern. Stattdessen setzen wir unsere Einstellungen in eine separate Datei, die einfach die spezifischen Einstellungen überschreibt, die wir benötigen.

Um diese Kerneländerungen vorzunehmen, erstellen Sie eine Datei namens `90-incus-override.conf` in `/etc/sysctl.d`. Geben Sie dazu Folgendes ein:

```bash
vi /etc/sysctl.d/90-incus-override.conf
```

Platzieren Sie den folgenden Inhalt in dieser Datei. Beachten Sie, dass, wenn Sie sich fragen, was wir hier tun, der folgende Dateiinhalt eine Selbstdokumentation ist:

```bash
## The following changes have been made for LXD ##

# fs.inotify.max_queued_events specifies an upper limit on the number of events that can be queued to the corresponding inotify instance
 - (default is 16384)

fs.inotify.max_queued_events = 1048576

# fs.inotify.max_user_instances This specifies an upper limit on the number of inotify instances that can be created per real user ID -
(default value is 128)

fs.inotify.max_user_instances = 1048576

# fs.inotify.max_user_watches specifies an upper limit on the number of watches that can be created per real user ID - (default is 8192)

fs.inotify.max_user_watches = 1048576

# vm.max_map_count contains the maximum number of memory map areas a process may have. Memory map areas are used as a side-effect of cal
ling malloc, directly by mmap and mprotect, and also when loading shared libraries - (default is 65530)

vm.max_map_count = 262144

# kernel.dmesg_restrict denies container access to the messages in the kernel ring buffer. Please note that this also will deny access t
o non-root users on the host system - (default is 0)

kernel.dmesg_restrict = 1

# This is the maximum number of entries in ARP table (IPv4). You should increase this if you create over 1024 containers.

net.ipv4.neigh.default.gc_thresh3 = 8192

# This is the maximum number of entries in ARP table (IPv6). You should increase this if you plan to create over 1024 containers.Not nee
ded if not using IPv6, but...

net.ipv6.neigh.default.gc_thresh3 = 8192

# This is a limit on the size of eBPF JIT allocations which is usually set to PAGE_SIZE * 40000. Set this to 1000000000 if you are running Rocky Linux 9.x

net.core.bpf_jit_limit = 1000000000

# This is the maximum number of keys a non-root user can use, should be higher than the number of containers

kernel.keys.maxkeys = 2000

# This is the maximum size of the keyring non-root users can use

kernel.keys.maxbytes = 2000000

# This is the maximum number of concurrent async I/O operations. You might need to increase it further if you have a lot of workloads th
at use the AIO subsystem (e.g. MySQL)

fs.aio-max-nr = 524288
```

Speichern Sie Ihre Änderungen und beenden Sie den Editor.

Starten Sie an diesem Punkt den Server neu.

### Überprüfung der `sysctl.conf`-Werte

Sobald der Neustart abgeschlossen ist, melden Sie sich erneut beim Server an. Wir müssen überprüfen, ob unsere Datei überschrieben wurde.

Das ist einfach zu bewerkstelligen. Es ist nicht notwendig, jede Einstellung zu überprüfen, es sei denn, Sie möchten, aber wenn Sie einige überprüfen, werden die Einstellungen geändert. Tun Sie dies mit dem `sysctl`-Befehl:

```bash
sysctl net.core.bpf_jit_limit
```

Dies sollte Folgendes ergeben:

```bash
net.core.bpf_jit_limit = 1000000000 
```

Machen Sie dasselbe mit einigen anderen Einstellungen in der Überschreibungsdatei, um die Änderungen zu überprüfen.
