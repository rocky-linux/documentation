---
title: Aktuelle Kernelkonfiguration anzeigen
author: David Hensley
contributors: Steven Spencer
tested_with: 8.5
tags:
  - kernel
  - config
  - modules
  - kmod
---

# Aktuelle Kernelkonfiguration anzeigen

Der Linux-Kernel speichert laufende Kernelinformationen an zwei Stellen durch spezielle Dateisysteme: ([Eine Zusammenfassung von ihnen](https://www.landoflinux.com/linux_procfs_sysfs.html))

  - Der ältere [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html), der `/proc` mountet (vergewissern Sie sich über `mount -l -t proc`)
  - Die neueren [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html) die `/sys` mountet (überprüfen mit `mount -l -t sysfs`)

!!! warning "Warnhinweis"

    Seien Sie vorsichtig, wenn Sie die hier genannten Dateien untersuchen, Änderungen können das Verhalten des aktuellen Kernels ändern!


Diese beiden Schnittstellen erlauben es Ihnen, die Parameter des aktuell laufenden Kernels anzuzeigen und zu ändern.

Beachten Sie, dass, wenn Sie auf einigen Dateien ein [`ls`](https://man7.org/linux/man-pages/man1/ls.1.html) -l ausführen, wird von diesen Dateien die Länge „0“ angezeigt, wenn Sie sie jedoch mit [`cat`](https://man7.org/linux/man-pages/man1/cat.1.html), enthalten sie tatsächlich Daten. Die meisten davon sind ASCII und editierbar, einige sind jedoch binär. In beiden Fällen Befehle wie [`file`](https://man7.org/linux/man-pages/man1/file.1.html) oder <a href= „https://man7.org/linux/man-pages/man2/lstat.2.html“>`stat`</a> gibt normalerweise nur „leere Datei“ oder „0“ für Längen zurück, obwohl sie Ihnen andere Informationen anzeigen.

Bevorzugte und Standardprogramme für die Interaktion mit diesen Funktionen sind [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html), [`modinfo`](https://man7.org/linux/man-pages/man8/modinfo.8.html), und [`sysctl`](https://man7.org/linux/man-pages/man8/sysctl.8.html), unter anderem.

```bash
sysctl -a | grep -i <keyword>
```

```bash
lsmod | grep -i <keyword>
```

```bash
modinfo <module>
```

Ihre aktuelle "Kernel-Release" Version ist:

`uname -r` und ersetze den Rückgabewert in Befehlen durch `$(uname -r)`

RHEL und Derivate (Fedora, CentOS Stream, Scientific Linux, RockyLinux, Almalinux, et. al.) speichert auch die Konfiguration, die für bootbare installierte Kernel im Verzeichnis `/boot` verwendet wird, das Grub2 als ASCII-Dateien verwendet:

```bash
/boot/config-<kernel-release>
```

Um die aktuell laufende Kernelkonfiguration auf einen bestimmten Wert zu überprüfen:

```bash
cat /boot/config-$(uname -r) | grep -i <keyword>
```

Ergebnisse werden angezeigt:

  - "=m" wenn als Kernelmodul kompiliert
  - "=y" wenn statisch in den Kernel kompiliert
  - "is not set", wenn diese Einstellung auskommentiert wurde
  - numerischer Wert
  - String-Wert

Einige Distributionen, wie Gentoo und Arch, verwenden das `configs` Kernelmodul um `/proc/config.gz` standardmäßig bereitzustellen:

```bash
zcat /proc/config.gz | grep -i <keyword>
zgrep <keyword> /proc/config.gz
```

Für jede Distribution, wenn Ihr laufender Kernel sowohl `CONFIG_IKCONFIG` als auch `CONFIG_IKCONFIG_PROC` gesetzt hat und wenn

```bash
ls -lh /sys/module/configs
```

existiert und ist ausführbar (durchsuchbar bei einem Verzeichnis), dann können Sie `/proc/config.gz` mit diesem Befehl generieren, wenn er nicht vorhanden ist:

```bash
modprobe configs
```

!!! note "aktivierte Repos"

    Dieses Dokument deckt derzeit keine Kernel-Pakete ab, die möglicherweise von Nicht-Standard-Repos stammen, wie z.B.:
    
    appstream-debug, appstream-source, baseos-debug, baseos-source oder devel


Die `kernel-devel` Pakete installieren die Konfigurationsdatei, die verwendet wird, um jedes installierte Standard-Kernel-Paket als ASCII-Datei an der folgenden Stelle zu kompilieren:

```bash
/usr/src/kernels/<kernel-release>/.config
```

Diese Datei wird häufiger durch einen symlinked Pfad aufgerufen, der von den `kernel-core` Paketen bereitgestellt wird:

```bash
/lib/modules/<kernel-release>/build/ -> /usr/src/kernels/<kernel-release>/
```

Wenn Sie `kernel-debug-devel` Pakete installiert haben, haben Sie auch dieses Verzeichnis:

```bash
 /usr/src/kernels/<kernel-release>+debug/
```

Sie können in jedem der folgenden Informationen zu den Konfigurationswerten durchsuchen, die zum Erstellen eines installierten Kernels verwendet werden:

```bash
/lib/modules/<kernel-release>/config
/lib/modules/<kernel-release>/build/.config
/usr/src/kernels/<kernel-release>/.config
/usr/src/kernels/<kernel-release>+debug/.config
```

Konfigurierte Module für den aktuell laufenden Kernel, ob kompiliert wie eingebaut (i.e., statisch in den Kernel selbst) oder ein ladbares Modul, werden von Unterverzeichnissen mit dem Namen des Moduls aufgelistet:

```bash
/sys/module/
```

Für jede installierte Kernel-Veröffentlichung können Sie diese Dateien überprüfen, um zu sehen, welche Werte in diesem Kernel kompiliert wurden, und welche Version von [GCC](https://man7.org/linux/man-pages/man1/gcc.1.html) verwendet wurde, um es zu kompilieren:

```bash
cat /lib/modules/$(uname -r)/config | grep -i <keyword>
```

```bash
cat /lib/modules/$(uname -r)/build/.config | grep -i <keyword>
```

```bash
cat /usr/src/kernels/$(uname -r)/.config | grep -i <keyword>
```

```bash
cat /usr/src/kernels/$(uname -r)+debug/.config | grep -i <keyword>
```

```bash
ls -lh /sys/module/ | grep -i <keyword>
```

Sie können in der Datei nach Abhängigkeiten des Kernelmoduls suchen:

```bash
/lib/modules/<kernel-release>/modules.dep
```

aber es ist einfacher, die Ausgabe des Feldes "Used-by" in [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html) zu lesen oder zu parsen.

## Referenzen:

[depmod](https://man7.org/linux/man-pages/man8/depmod.8.html), [ls](https://man7.org/linux/man-pages/man1/ls.1.html), [lsmod](https://man7.org/linux/man-pages/man8/lsmod.8.html), [modinfo](https://man7.org/linux/man-pages/man8/modinfo.8.html), [modprobe](https://man7.org/linux/man-pages/man8/modprobe.8.html), [modules.dep](https://man7.org/linux/man-pages/man5/modules.dep.5.html), [namespaces](https://man7.org/linux/man-pages/man7/namespaces.7.html), [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html), [sysctl](https://man7.org/linux/man-pages/man8/sysctl.8.html), [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html), [uname](https://man7.org/linux/man-pages/man8/uname26.8.html)
