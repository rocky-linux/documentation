---
title: Visualizzare la Configurazione Attuale del Kernel
author: David Hensley
contributors: Steven Spencer, Franco Colussi
tested_with: 8.5
tags:
  - kernel
  - configurazione
  - moduli
  - kmod
---

# Visualizzare la configurazione attuale del kernel

Il kernel Linux memorizza le informazioni sul kernel in esecuzione in due luoghi, tramite file system speciali:[(Una sintesi di questi](https://www.landoflinux.com/linux_procfs_sysfs.html))

  - Il vecchio [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html) che monta `/proc` (verificabile  tramite `mount -l -t proc`)
  - Il [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html) più recente che monta `/sys` (verificare tramite `mount -l -t sysfs`)

!!! warning "Attenzione"

    Siate cauti nell'esaminare i file qui menzionati, la loro modifica può cambiare il comportamento del kernel in esecuzione!


Queste due interfacce consentono di visualizzare e modificare i parametri del kernel in esecuzione.

Si noti che se si esegue un [`ls -l`](https://man7.org/linux/man-pages/man1/ls.1.html) su alcuni di questi file, essi vengono visualizzati con una lunghezza pari a "0", ma se si usa [`cat`](https://man7.org/linux/man-pages/man1/cat.1.html) contengono effettivamente dei dati; la maggior parte di essi sono ASCII e modificabili, ma alcuni sono binari, e in entrambi i casi comandi come [`file`](https://man7.org/linux/man-pages/man1/file.1.html) o [`stat`](https://man7.org/linux/man-pages/man2/lstat.2.html) restituiranno in genere solo "file vuoto" o "0" per le lunghezze, anche se mostreranno altre informazioni.

I programmi preferiti e standard per interagire con queste funzioni sono [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html), [`modinfo`](https://man7.org/linux/man-pages/man8/modinfo.8.html), e [`sysctl`](https://man7.org/linux/man-pages/man8/sysctl.8.html), tra gli altri.

```bash
sysctl -a | grep -i <keyword>
```

```bash
lsmod | grep -i <keyword>
```

```bash
modinfo <module>
```

Vedere la versione della "release del kernel" attualmente in uso:

`uname -r` e sostituire il suo valore di ritorno nei comandi usando `$(uname -r)`

RHEL e distribuzioni derivate (Fedora, CentOS Stream, Scientific Linux, RockyLinux, Almalinux, ecc.) memorizza anche la configurazione usata per i kernel installati avviabili nella directory `/boot` usata da Grub2 come file ASCII:

```bash
/boot/config-<kernel-release>
```

Per controllare la configurazione del kernel attualmente in esecuzione per un particolare valore:

```bash
cat /boot/config-$(uname -r) | grep -i <keyword>
```

I risultati mostreranno:

  - "=m" se compilato come modulo del kernel
  - "=y" se compilato staticamente nel kernel
  - "is not set" se l'impostazione è stata commentata
  - un valore numerico
  - un valore stringa quotato

Alcune distribuzioni, come Gentoo e Arch, utilizzano il modulo `configs` del kernel per fornire `/proc/config.gz` come impostazione predefinita:

```bash
zcat /proc/config.gz | grep -i <keyword>
zgrep <keyword> /proc/config.gz
```

Per qualsiasi distribuzione, se il kernel in esecuzione ha impostato sia `CONFIG_IKCONFIG` che `CONFIG_IKCONFIG_PROC` e se

```bash
ls -lh /sys/module/configs
```

esiste ed è eseguibile (ricercabile nel caso di una directory), allora si può creare `/proc/config.gz` con questo comando se non è presente:

```bash
modprobe configs
```

!!! note "Repository abilitati"

    Questo documento non copre attualmente i pacchetti del kernel che potrebbero provenire da repository non predefiniti, come ad esempio:
    
    appstream-debug, appstream-source, baseos-debug, baseos-source, o devel


I pacchetti `kernel-devel` installano il file di configurazione utilizzato per compilare ogni pacchetto standard del kernel installato come file ASCII nel seguente percorso:

```bash
/usr/src/kernels/<kernel-release>/.config
```

A questo file si accede più comunemente tramite un percorso collegato in symlink fornito dai pacchetti `kernel-core`:

```bash
/lib/modules/<kernel-release>/build/ -> /usr/src/kernels/<kernel-release>/
```

Se avete installato il pacchetto `kernel-debug-devel`, avrete anche questa directory:

```bash
 /usr/src/kernels/<kernel-release>+debug/
```

Per i dettagli sui valori di configurazione usati per costruire un kernel installato, si può consultare uno dei seguenti documenti:

```bash
/lib/modules/<kernel-release>/config
/lib/modules/<kernel-release>/build/.config
/usr/src/kernels/<kernel-release>/.config
/usr/src/kernels/<kernel-release>+debug/.config
```

I moduli configurati per il kernel in esecuzione, compilati come builtin (cioè staticamente nel kernel stesso) o come moduli caricabili, sono elencati in sottodirectory denominate come il nome del modulo in:

```bash
/sys/module/
```

Per ogni release del kernel installata è possibile esaminare questi file per vedere quali valori sono stati compilati in quel kernel e quale versione di [GCC](https://man7.org/linux/man-pages/man1/gcc.1.html) è stata usata per compilarlo:

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

È possibile verificare le dipendenze dei moduli del kernel nel file:

```bash
/lib/modules/<kernel-release>/modules.dep
```

ma è più facile leggere o analizzare l'output del campo "Used-by" in [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html).

## Riferimento:

[depmod](https://man7.org/linux/man-pages/man8/depmod.8.html), [ls](https://man7.org/linux/man-pages/man1/ls.1.html), [lsmod](https://man7.org/linux/man-pages/man8/lsmod.8.html), [modinfo](https://man7.org/linux/man-pages/man8/modinfo.8.html), [modprobe](https://man7.org/linux/man-pages/man8/modprobe.8.html), [modules.dep](https://man7.org/linux/man-pages/man5/modules.dep.5.html), [namespaces](https://man7.org/linux/man-pages/man7/namespaces.7.html), [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html), [sysctl](https://man7.org/linux/man-pages/man8/sysctl.8.html), [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html), [uname](https://man7.org/linux/man-pages/man8/uname26.8.html)
