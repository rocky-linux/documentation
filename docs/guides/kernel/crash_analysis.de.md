---
title: Crash-Analyse
author: Howard Van Der Wal
contributors: Steven Spencer
tested_with: 8, 9, 10
ai_contributors: Claude (claude-opus-4-6)
tags:
  - crash
  - debugging
  - kdump
  - Kernel
  - vmcore
---

**Vorkenntnisse**: :star: :star: :star:<br/>
**Lesezeit**: 31 minutes

## Einsatz von KI

Dieses Dokument entspricht der [Richtlinie für KI-Beiträge, die Sie hier finden](../contribute/ai-contribution-policy.md). Sollten Sie Fehler in den Anweisungen entdecken, teilen Sie uns diese bitte mit.

## Einleitung

Wenn ein Linux-Kernel abstürzt, erzeugt das System eine Speicherabbilddatei namens `vmcore`. Die Analyse dieses Speicherabbilds ist oft die einzige Möglichkeit, die Ursache für den Ausfall eines Produktionsservers zu ermitteln. Rocky Linux wird mit zwei unverzichtbaren Tools für diesen Workflow ausgeliefert: `kdump`, das den vmcore zum Zeitpunkt des Absturzes erfasst, und das Dienstprogramm `crash`, das den Dump zur anschließenden Analyse öffnet.

Dieser Leitfaden führt Sie durch den gesamten Prozess – von der Konfiguration von kdump zum Erfassen von vmcores bis hin zur Verwendung von Crash-Befehlen zur Identifizierung häufiger Absturzmuster wie blockierte Task-Paniken, Mutex-Beschädigung und Cgroup-Deadlocks. Außerdem umfasst es die sichere Sammlung von `sosreport`-Berichten während der Untersuchung von Abstürzen sowie Hinweise darauf, wann ein Kernel-Upgrade sinnvoll ist und wann Workarounds angewendet werden sollten. Grundlegende Informationen zur Behandlung von Kernel-Panics, bevor Sie sich mit der `vmcore`-Analyse befassen, finden Sie unter [How to deal with a kernel panic](../troubleshooting/kernel_panic.md).

## Voraussetzungen

- Ein Rocky Linux 8-, 9- oder 10-System.
- Root- oder `sudo`-Zugriff.
- Mindestens 2 GB freier Speicherplatz im Verzeichnis `/var/crash` für vmcore-Dumps.
- Netzwerkzugriff zum Installieren von Paketen aus den Rocky Linux-Repositorys.

## Einrichten von `kdump` für die `vmcore`-Erfassung

Der Dienst `kdump` reserviert einen Teil des Systemspeichers für einen sekundären Kernel. Wenn der primäre Kernel abstürzt, startet `kdump` diesen sekundären Kernel und verwendet ihn, um den Inhalt des Speichers als `vmcore`-Datei^1^ auf die Festplatte zu schreiben.

### `kdump`-Installation

Installieren Sie das Paket `kexec-tools`, das den Dienst `kdump` bereitstellt:

```bash
dnf install kexec-tools
```

### Konfiguration des reservierten Speichers

Der Kernel muss beim Systemstart Speicher für den `crash`-Kernel reservieren. Überprüfen Sie den aktuellen `crashkernel`-Parameter:

```bash
cat /proc/cmdline | grep crashkernel
```

Unter Rocky Linux 8 wird `crashkernel` standardmäßig über den Mechanismus `crashkernel=auto` eingestellt, wodurch der Kernel die Größe des reservierten Speichers automatisch berechnen kann. Bei Rocky Linux 9 und 10 wurde die Option `crashkernel=auto` durch einen neuen Mechanismus in `kexec-tools` ersetzt. Den Standardwert können Sie mit folgendem Befehl überprüfen:

```bash
kdumpctl get-default-crashkernel
```

Auf Rocky Linux 9 wird dadurch `1G-2G:192M,2G-64G:256M,64G-:512M` zurückgegeben. Unter Rocky Linux 10 wird das Ergebnis `2G-64G:256M,64G-:512M` zurückgegeben. Unter Rocky Linux 8 ist dieser Unterbefehl nicht verfügbar.

!!! note

    Bei standardmäßigen interaktiven Installationen (mithilfe des Anaconda-Installers) wird `crashkernel` automatisch über das `kdump`-Installer-Add-on konfiguriert. Bei Cloud-Images und Kickstart-Installationen ohne das Add-on `kdump` darf der Parameter `crashkernel` in der Boot-Befehlszeile nicht enthalten sein.

Falls `crashkernel` in der Boot-Befehlszeile fehlt, fügen Sie es mit `grubby` hinzu:

```bash
kdumpctl get-default-crashkernel
grubby --update-kernel=ALL --args="crashkernel=<value from above>"
```

Unter Rocky Linux 8, wo `kdumpctl get-default-crashkernel` nicht verfügbar ist, verwenden Sie Folgendes:

```bash
grubby --update-kernel=ALL --args="crashkernel=auto"
```

Ein Neustart ist erforderlich, damit die Änderung wirksam wird:

```bash
reboot
```

Überprüfen Sie nach dem Neustart, ob Speicher reserviert wurde:

```bash
cat /sys/kernel/kexec_crash_size
```

Ein Wert ungleich Null bestätigt, dass Speicher für den Crash-Kernel reserviert wurde.

### Konfiguration des Speicherorts für den Dump

Der Standardspeicherort für Speicherabbilder ist `/var/crash`. Die Konfigurationsdatei ist `/etc/kdump.conf`:

```bash
cat /etc/kdump.conf | grep -v "^#" | grep -v "^$"
```

Die Standardkonfiguration schreibt Speicherabbilder in das lokale Dateisystem. Zu den wichtigsten Einstellungen gehören Folgende:

- `auto_reset_crashkernel yes` — passt die Crashkernel-Reservierung automatisch an, wenn sich der Speicher ändert (nur Rocky Linux 9+)
- `path /var/crash` — Verzeichnis, in dem vmcores gespeichert werden
- `core_collector makedumpfile -l --message-level 7 -d 31` — komprimiert den Dump und filtert unnötige Seiten heraus

!!! note

    Der Parameter `-d 31` in `makedumpfile` filtert Nullseiten, Cache-Seiten, Benutzerdatenseiten und freie Seiten^3^ heraus. Dadurch wird die Größe von `vmcore` deutlich reduziert. Bei einem System mit 64 GB RAM beträgt der resultierende `vmcore` typischerweise 1-4 GB anstatt der vollen 64 GB.

### kdump aktivieren und überprüfen

Aktivieren und starten Sie den `kdump`-Dienst:

```bash
systemctl enable --now kdump
```

Überprüfen Sie, ob der Dienst ausgeführt wird:

```bash
systemctl status kdump
```

Nach einem Neustart mit dem Parameter `crashkernel` sollte die Ausgabe `Active: active (exited)` anzeigen, was darauf hinweist, dass der Crash-Kernel geladen wurde. Sie können dies auch überprüfen mit:

```bash
kdumpctl status
```

Folgendes sollte gemeldet werden
`Kdump is operational`.

## Installation der Crash-Utility- und Kernel-Debuginfo-Pakete

Das Dienstprogramm `crash` benötigt sowohl das Paket `crash` als auch das passende Paket `kernel-debuginfo` für den Kernel, der den `vmcore`^2^ erzeugt hat.

### `crash`-Installation

```bash
dnf install crash
```

### `kernel-debuginfo`-Installation

Die `kernel-debuginfo`-Pakete stellen die `vmlinux`-Datei mit vollständigen Debugging-Symbolen bereit. Zuerst muss die Kernelversion aus dem vmcore (oder dem laufenden Kernel beim Testen) ermittelt werden:

```bash
uname -r
```

Installieren Sie die passenden Debuginfo-Pakete mit `debuginfo-install`, wodurch die richtigen Repositorys automatisch aktiviert werden:

```bash
dnf debuginfo-install kernel-core-$(uname -r)
```

Dadurch werden sowohl das Paket `kernel-debuginfo` als auch das Paket `kernel-debuginfo-common` installiert. Der Befehl `debuginfo-install` übernimmt die automatische Aktivierung des Repositorys, was zuverlässiger ist als die manuelle Angabe des `baseos-debuginfo`-Repositorys.

!!! note

    Falls die `vmcore`-Datei von einer anderen Kernelversion als der aktuell ausgeführten erstellt wurde, ersetzen Sie `$(uname -r)` durch die entsprechende Versionszeichenfolge. Die Kernelversion einer `vmcore`-Datei lässt sich ermitteln, indem man den Header der `makedumpfile`-Datei untersucht oder die `uname`-Datei in einem entsprechenden `sosreport` überprüft.

Überprüfen Sie, ob die Datei `vmlinux` existiert:

```bash
ls /usr/lib/debug/lib/modules/$(uname -r)/vmlinux
```

## Öffnen eines `vmcore` mit dem Crash-Dienstprogramm

Um eine `vmcore`-Datei zu öffnen, geben Sie den Pfad zu den `vmlinux`-Debug-Symbolen und der vmcore-Datei an:

```bash
crash /usr/lib/debug/lib/modules/<kernel-version>/vmlinux /var/crash/<timestamp>/vmcore
```

Zum Beispiel:

```bash
crash /usr/lib/debug/lib/modules/5.14.0-611.36.1.el9_7.x86_64/vmlinux /var/crash/127.0.0.1-2025-03-09-10:30:00/vmcore
```

Wenn Crash die Datei `vmcore` öffnet, wird ein Header mit wichtigen Informationen angezeigt:

```text
      KERNEL: /usr/lib/debug/lib/modules/5.14.0-611.36.1.el9_7.x86_64/vmlinux
    DUMPFILE: vmcore  [PARTIAL DUMP]
        CPUS: 4
        DATE: Sun Mar  9 10:30:00 JST 2025
      UPTIME: 3 days, 12:45:30
LOAD AVERAGE: 45.67, 42.31, 38.92
       TASKS: 312
    NODENAME: rocky-server
     RELEASE: 5.14.0-611.36.1.el9_7.x86_64
     VERSION: #1 SMP PREEMPT_DYNAMIC
     MACHINE: x86_64
      MEMORY: 8 GB
       PANIC: "BUG: kernel NULL pointer dereference"
         PID: 0
     COMMAND: "swapper/0"
```

Wichtige zu untersuchende Felder:

- `UPTIME` — wie lange das System vor dem Absturz lief
- `LOAD AVERAGE` —
  Systemlast zum Zeitpunkt des Absturzes (hohe Werte können auf Ressourcenerschöpfung hinweisen)
- `PANIC` —
  die Panikmeldung, die den Absturz auslöste
- `PID` und `COMMAND` —
  der Prozess und der Befehl, die zum Zeitpunkt des Absturzes ausgeführt wurden

## Wesentliche Befehle zur Crash-Analyse

### `log` —&#xA;Kernel-Ringpuffer

Der Befehl `log` zeigt den Kernel-Ringpuffer an (entspricht `dmesg`)^4^. Dies ist üblicherweise der erste Befehl, der nach dem Öffnen einer `vmcore`-Instanz ausgeführt wird:

```text
crash> log
```

Um nach bestimmten Nachrichten zu suchen, leiten Sie die Ausgabe an `grep` weiter:

```text
crash> log | grep -i "blocked\|panic\|bug\|error"
```

### `bt` — backtrace

Zeigen Sie den Backtrace des Tasks an, der zum Zeitpunkt des Absturzes aktiv war:

```text
crash> bt
```

Display the backtrace for a specific PID:

```text
crash> bt <pid>
```

Backtraces für den aktiven Task auf jeder CPU anzeigen:

```text
crash> bt -a
```

### `ps` — Prozess-Listing

Zeigt die Liste der Prozesse an:

```text
crash> ps
```

Das Flag `-m` zeigt die Zeit an, die jeder Task in ihrem aktuellen Zustand verbracht hat. Dies ist entscheidend für die Identifizierung von Tasks, die über längere Zeiträume blockiert wurden:

```text
crash> ps -m
```

### `foreach` —&#xA;Iteration über Tasks

Die `foreach`-Aweisung führt einen Befehl für mehrere Tasks aus. Alle Aufgaben im nicht unterbrechbaren Schlafmodus (UN-Zustand) finden und anzeigen, wie lange sie blockiert sind:

```text
crash> foreach UN ps -m
```

Dies ist einer der wichtigsten Befehle zur Diagnose von Task-Panics, die durch Blockierung verursacht werden. Die Ausgabe zeigt jeden blockierten Task mit seiner akkumulierten Zeit im UN-Zustand an.

### `files` —&#xA;öffnet Dateideskriptoren

Offene Dateideskriptoren für einen bestimmten Task anzeigen:

```text
crash> files <pid>
```

### `struct` —&#xA;Untersuchung von Kernel-Datenstrukturen

Anzeige einer Kernel-Struktur an einer bestimmten Speicheradresse:

```text
crash> struct task_struct <address>
```

So werden bestimmte Felder angezeigt:

```text
crash> struct task_struct <address> | grep pi_blocked_on
```

```text
crash> struct task_struct.pi_blocked_on <address>
```

### `kmem -i` — Zusammenfassung der Speichernutzung

Zeigt eine Zusammenfassung der Systemspeichernutzung an:

```text
crash> kmem -i
```

Hier werden der gesamte Arbeitsspeicher, der freie Arbeitsspeicher, die Puffer, der Cache und die Auslagerung-Speichernutzung angezeigt. Ein hoher Speicherverbrauch oder eine hohe Auslagerung-Speichernutzung zum Zeitpunkt des Absturzes können auf eine Speicherüberlastung als mitentscheidenden Faktor hinweisen.

### `mod -t` —&#xA;Prüfung auf beschädigte Module

Den Kernel-Taint-Status und die Module, die den Taint verursacht haben, anzeigen:

```text
crash> mod -t
```

Ein `tainted`-Kernel (zum Beispiel durch externe oder proprietäre Module) kann sich anders verhalten, als es die Upstream-Kernel-Entwickler erwarten. Gängige `taint`-Flags sind folgende:

- `P` —
  proprietäres Modul geladen
- `O` —
  `out-of-tree`-Modul geladen
- `E` —
  unsigniertes Modul geladen

## Identifizierung häufiger Absturzmuster

### Blockierte `task panics` (khungtaskd)

Der Kernel-Thread `khungtaskd` überwacht Tasks im nicht unterbrechbaren Schlafzustand (D-Zustand). Wenn ein Task länger als der Schwellenwert `kernel.hung_task_timeout_secs` (Standard: 120 Sekunden) in diesem Zustand verbleibt, protokolliert `khungtaskd` eine Warnung. Wenn `kernel.hung_task_panic` auf 1 gesetzt ist, löst dies eine Kernel-Panic aus.

Muster in der Log-Ausgabe erkennen:

```text
crash> log | grep "blocked for more than"
```

Typische Ausgabe:

```text
INFO: task kworker/2:1:1234 blocked for more than 120 seconds.
INFO: task runc:[2:INIT]:5678 blocked for more than 600 seconds.
```

Alle blockierten `Tasks` finden:

```text
crash> foreach UN ps -m
```

Hier werden alle `Tasks` im nicht-unterbrechbaren Schlafmodus zusammen mit ihrer Dauer aufgelistet. Tasks, die Hunderte von Sekunden lang blockiert sind, kommen als mögliche Ursache infrage.

Tracing der Blockierung-Kette:

Sobald Sie einen blockierten `Task` identifiziert haben, untersuchen Sie deren Backtrace:

```text
crash> bt <pid>
```

Suchen Sie im Backtrace nach Funktionen, die mit Sperren, Mutexen oder E/A-Wartezeiten zusammenhängen. Häufige Blockierungspunkte sind `mutex_lock`, `rwsem_down_read_slowpath` und `io_schedule`.

### Mutex-Korruption (rt_mutex)

Bei Kerneln, die PREEMPT_RT verwenden, werden `spinlock_t` und `rwlock_t` durch `rt_mutex`-basierte Implementierungen ersetzt, wodurch sie von rotierenden Sperren in schlafende Sperren umgewandelt werden. Die Korruption dieser Strukturen kann zu kaskadierenden Aufgabenblockaden führen.

Untersuchung von `pi_blocked_on`:

Wenn ein Task durch einen rt_mutex blockiert wird, verweist das Feld `pi_blocked_on` in seiner `task_struct` auf die Struktur `rt_mutex_waiter`:

```text
crash> struct task_struct.pi_blocked_on <task_address>
```

Wenn das Ergebnis ein Wert ungleich NULL ist, untersuchen Sie die Waiter-Struktur:

```text
crash> struct rt_mutex_waiter <waiter_address>
```

Dadurch wird das Feld `lock` sichtbar, das auf den `rt_mutex` selbst verweist:

```text
crash> struct rt_mutex <mutex_address>
```

Das Feld `owner` des `rt_mutex` zeigt an, welche Aufgabe die Sperre hält. Ein ungültiger Besitzerzeiger (wie z. B. `0x1` oder eine andere eindeutig ungültige Adresse) deutet auf eine Beschädigung des Mutex hin.

Beispiel einer beschädigten `rt_mutex`-Kette:

```text
crash> struct task_struct.pi_blocked_on ffff9a3c0e4b0000
  pi_blocked_on = 0xffff9a3c12340100
crash> struct rt_mutex_waiter 0xffff9a3c12340100
  lock = 0xffff9a3c56780200
crash> struct rt_mutex 0xffff9a3c56780200
  owner = 0x1    <-- invalid pointer, indicates corruption
```

Ein `owner`-Wert von `0x1` bedeutet, dass die Besitzverfolgung des Lock's beschädigt ist. Dieses Muster wurde in PREEMPT_RT-Kerneln vor spezifischen rt_mutex-Korrekturen beobachtet.

### `cgroup`-Deadlocks

Containerumgebungen sind anfällig für „cgroup-bezogene Deadlocks“, insbesondere wenn Container-Laufzeitumgebungen (wie z. B. „runc“) mit Kernel-cgroup-Subsystemen interagieren.

Muster-Erkennung:

```text
crash> log | grep -i "cgroup\|threadgroup"
```

Ein häufiges Deadlock-Szenario betrifft die Sperren `cgroup_mutex` und `cgroup_threadgroup_rwsem`. Ein Task hält `cgroup_mutex`, während er auf `cgroup_threadgroup_rwsem` wartet, während ein anderer Task `cgroup_threadgroup_rwsem` hält und auf `cgroup_mutex` wartet.

Verfolgung des `Deadlocks`:

1. Blockierte Aufgaben im Zusammenhang mit Containeroperationen finden:

    ```text
    crash> foreach UN bt | grep -A 5 "cgroup\|runc"
    ```

2. Identifizieren Sie die Aufgaben, die die `Konflikt-Locks` halten, indem Sie deren Backtraces untersuchen. Suchen Sie nach Funktionen wie
   `cgroup_lock`, `cgroup_attach_task`, `copy_process` und `cgroup_exit`.

3. Das Deadlock beinhaltet oft Folgendes:
   - Ein Container-Laufzeitprozess (zum Beispiel `runc`), der während der Containereinrichtung einen `cgroup_mutex` hält.
   - Fork- oder Exit-Operationen blockieren auf `cgroup_threadgroup_rwsem`.
   - Die beiden Sperren erzeugen eine zirkuläre Abhängigkeit.

Minderung:

Durch die Reduzierung der Häufigkeit von Operationen, die zu Konflikten um `Cgroup`-Sperren führen – wie beispielsweise `Container-Exec-Probes` in Kubernetes –, können diese Deadlocks verhindert werden.

### Timer-Bugs

Kernel-Bugs im Zusammenhang mit dem Timer äußern sich als `BUG_ON`-Assertions in Timer-Codepfaden.

Muster-Erkennung:

```text
crash> log | grep -i "BUG.*timer\|timer.*BUG"
```

```text
crash> bt
```

Suchen Sie im Backtrace nach Funktionen wie `__run_timers`, `call_timer_fn` oder subsystemspezifischen Timer-Handlern (wie z. B. `sctp_generate_timeout_event` von SCTP).

Timer-Bugs werden typischerweise durch Upstream-Kernel-Patches behoben. Der Backtrace und die spezifische `BUG_ON`-Meldung sind die wichtigsten Informationen, die benötigt werden, um nach bekannten Lösungen zu suchen oder das Problem zu melden.

## Überlegungen zum PREEMPT_RT-Kernel

Das PREEMPT_RT Patch-Set wandelt die Kernel-Funktionen `spinlock_t` und `rwlock_t` in `rt_mutex`-basierte Implementierungen um, um eine deterministische Scheduling-Latenz^5^ zu gewährleisten. Standardmäßige `struct mutex`-Typen werden unter PREEMPT_RT ebenfalls auf Basis von `rt_mutex` neu implementiert und erhalten dadurch Unterstützung für Prioritätsvererbung, obwohl sie in beiden Konfigurationen weiterhin schlafende Sperren bleiben. Diese Umstellung verändert das Blockierungsverhalten erheblich.

Wesentliche Unterschiede unter PREEMPT_RT:

- Spinlocks werden zu schlafenden Sperren: Codepfade, die auf Standardkerneln nicht blockierend sind, können unter PREEMPT_RT blockieren, wodurch neue Deadlock-Möglichkeiten entstehen.
- Prioritätsvererbung: rt_mutexes implementieren Prioritätsvererbung, was bedeutet, dass Mutex-Ketten komplexer werden können. Die Felder `pi_blocked_on` und `pi_waiters` in `task_struct` werden aktiv verwendet.
- Längere Blockierungsketten: Da mehr Sperren pausiert werden können, können Aufgaben über längere Zeiträume blockiert werden, wodurch `khungtaskd`-Paniken wahrscheinlicher werden.

Zusätzliche Analysetechniken für RT-Kernel:

Untersuchen Sie die Prioritätsvererbungskette:

```text
crash> struct task_struct.pi_waiters <task_address>
crash> struct task_struct.pi_blocked_on <task_address>
```

Prüfen Sie auf `rt_mutex`-spezifische Felder:

```text
crash> struct rt_mutex <address>
```

Bei `PREEMPT_RT`-Kerneln ist besonderes Augenmerk auf den Zusammenhang zwischen Mutex-Besitz und Task-Scheduling-Priorität zu legen. Eine Aufgabe mit niedriger Priorität, die eine von einer Aufgabe mit hoher Priorität benötigte Sperre hält, kann zu einer verlängerten Blockierung führen, wenn die Priorität-Vererbung nicht korrekt weitergegeben wird.

## Sicheres Sammeln von `sosreport` während der Crash-Untersuchung

Das Tool `sosreport` (bereitgestellt vom Paket `sos`) sammelt Systemkonfigurations- und Diagnoseinformationen^6^. Die Ausführung eines vollständigen sosreport auf einem System, das bereits stark beansprucht ist – beispielsweise einem System, das sich kürzlich von einem Systemabsturz erholt hat oder bei dem Prozesse hängen bleiben – kann jedoch zu weiteren Abstürzen führen.

### Risiko eines vollständigen `sosreport` bei überlasteten Systemen

Ein vollständiger `sosreport` führt zahlreiche Diagnosebefehle aus und liest viele Dateien aus `/proc` und `/sys`. Auf einem System mit Kernel-Subsystemen in einem inkonsistenten Zustand kann diese Aktivität Folgendes bewirken:

- Durch den Zugriff auf beschädigte Datenstrukturen werden weitere Kernel-Panics ausgelöst.
- Führt dazu, dass das System nicht mehr reagiert.
- Es wird ein unvollständiger `sosreport` erstellt, der für die Analyse nicht brauchbar ist.

### Beschränkter Plugin-Umfang

Um das Risiko zu reduzieren, sollte `sosreport` auf bestimmte Plugins beschränkt werden:

```bash
sos report -o kernel,process,logs
```

Hierbei werden lediglich Kernelkonfiguration, Prozessinformationen und Systemprotokolle erfasst – in der Regel ausreichend für eine erste Untersuchung eines Absturzes, ohne das System übermäßig zu belasten.

Weitere nützliche Plugin-Kombinationen je nach Szenario:

```bash
sos report -o kernel,process,logs,networking
```

```bash
sos report -o kernel,process,logs,cgroups,container_log
```

### Vorgehensweise als Ersatz: Manuelle Sammlung einzelner Dateien

Falls selbst ein eingeschränkter `sosreport` zu riskant ist, sammeln Sie die wichtigsten Dateien manuell:

```bash
cp /var/log/messages /tmp/crash_collection/
cp /proc/cmdline /tmp/crash_collection/
cp /etc/kdump.conf /tmp/crash_collection/
uname -a > /tmp/crash_collection/uname.txt
lsmod > /tmp/crash_collection/lsmod.txt
ps auxf > /tmp/crash_collection/ps.txt
cat /proc/meminfo > /tmp/crash_collection/meminfo.txt
```

## Wann sollte man den Kernel aktualisieren und wann sollte man Workarounds anwenden?

Nachdem die Ursache eines Absturzes ermittelt wurde, muss entschieden werden, ob der Kernel aktualisiert oder ein Workaround angewendet werden soll.

### Überprüfung auf bekannte Korrekturen

Durchsuchen Sie das Kernel-Änderungsprotokoll nach Korrekturen, die mit dem von Ihnen identifizierten Absturzmuster zusammenhängen:

```bash
rpm -q --changelog kernel | grep -i "<search_term>"
```

Um beispielsweise zu prüfen, ob ein `rt_mutex`-Fix enthalten ist:

```bash
rpm -q --changelog kernel | grep -i "rt_mutex\|rtmutex"
```

Prüfen Sie, ob eine neuere Kernelversion verfügbar ist:

```bash
dnf check-update kernel
```

### Bewertung der Entscheidung

Aktualisieren Sie den Kernel, wenn:

- Das Absturzmuster entspricht einem bekannten Fehler, der in einer neueren Kernel-Version behoben wurde.
- Die Ausgabe von `rpm --changelog` für die neuere Version enthält die entsprechende Korrektur.
- Das System kann ein Wartungsfenster für den Neustart tolerieren.

Wenden Sie ein Workaround an, wenn:

- Es ist noch kein Kernel-Fix verfügbar.
- Das System kann keine Ausfallzeiten aufgrund eines Kernel-Upgrades tolerieren.
- Der Absturz kann durch eine Änderung des Systemverhaltens vermieden werden (z. B. durch Reduzierung der Container-Exec-Probe-Frequenz, um Konflikte mit Cgroup-Sperren zu vermeiden).

### Überprüfung, ob eine Korrektur enthalten ist

Nachdem eine mögliche Lösung identifiziert wurde, überprüfen Sie, ob diese in der Zielkernelversion enthalten ist:

```bash
rpm -q --changelog kernel-<new_version> | grep -i "<fix_description>"
```

Sie können auch die Kernelversionen der aktuellen und der verfügbaren Pakete vergleichen:

```bash
rpm -q kernel
dnf list available kernel
```

## Zusammenfassung

Die Kernel-Crash-Analyse mit `kdump` und `crash` bietet einen systematischen Ansatz zur Diagnose von Produktionssystemausfällen unter Rocky Linux. Durch die Konfiguration von kdump zum Erfassen von vmcores, die Verwendung des Crash-Utility zur Untersuchung des Kernelzustands zum Zeitpunkt des Fehlers und das Verständnis gängiger Absturzmuster können Administratoren die Ursachen identifizieren und geeignete Korrekturen vornehmen.

Wichtigste Erkenntnisse:

- Konfigurieren Sie `kdump` und überprüfen Sie, ob es betriebsbereit ist, bevor ein Absturz auftritt.
- Beginnen Sie die Analyse mit `log`, `bt` und `foreach UN ps -m`, um den Absturzkontext zu verstehen.
- Bei blockierten Task-Panics sollte die Blockierungskette über Mutex- und Sperrstrukturen verfolgt werden.
- Bei PREEMPT_RT-Kerneln ist besonderes Augenmerk auf das Verhalten von rt_mutex zu legen.
- Sammeln Sie SOS-Berichte sicher, indem Sie `-o` verwenden, um den Plugin-Bereich auf überlasteten Systemen einzuschränken.
- Verwenden Sie die Kernel-Änderungsprotokolle, um vor dem Upgrade zu überprüfen, ob die Korrekturen enthalten sind.

## Referenzen

1. "Documentation for kdump — The kexec-based Crash Dumping Solution" by The Linux Kernel documentation project [https://docs.kernel.org/admin-guide/kdump/kdump.html](https://docs.kernel.org/admin-guide/kdump/kdump.html)
2. "crash utility" by the crash-utility project [https://github.com/crash-utility/crash](https://github.com/crash-utility/crash)
3. "makedumpfile" by the makedumpfile project [https://github.com/makedumpfile/makedumpfile](https://github.com/makedumpfile/makedumpfile)
4. "crash(8) man page" by the crash-utility project [https://man7.org/linux/man-pages/man8/crash.8.html](https://man7.org/linux/man-pages/man8/crash.8.html)
5. "Real-Time Linux" by The Linux Foundation [https://wiki.linuxfoundation.org/realtime/start](https://wiki.linuxfoundation.org/realtime/start)
6. "sos — A unified tool for collecting system logs and other debug information" by the sos project [https://github.com/sosreport/sos](https://github.com/sosreport/sos)
