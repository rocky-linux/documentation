---
title: Analyser la configuration actuelle du noyau
author: David Hensley
contributors: Steven Spencer
tested_with: 8.5
tags:
  - kernel
  - config
  - modules
  - kmod
---

# Analyser la configuration actuelle du noyau

Le noyau Linux stocke ses informations en deux endroits via des systèmes de fichiers spéciaux : ([Un résumé](https://www.landoflinux.com/linux_procfs_sysfs.html))

  - Les [procfs plus anciens](https://man7.org/linux/man-pages/man5/procfs.5.html) qui montent `/proc` (vérifier via `mount -l -t proc`)
  - Les [sysfs plus récents](https://man7.org/linux/man-pages/man5/sysfs.5.html) qui montent `/sys`    (vérifiez via `mount -l -t sysfs`)

!!! warning "Attention"

    Soyez prudent si vous examinez les fichiers mentionnés ici, les modifier peut changer le comportement du noyau en cours d'exécution !


Ces deux interfaces vous permettent de visualiser et de modifier les paramètres du noyau en cours d'exécution.

Notez que si vous exécutez un [`ls`](https://man7.org/linux/man-pages/man1/ls.1.html) -l sur certains de ces fichiers, ils apparaissent comme ayant une longueur "0", mais si vous les extrayez avec [` cat`](https://man7.org/linux/man-pages/man1/cat.1.html), ils contiennent en fait des données. La plupart d'entre eux sont ASCII et modifiables, mais certains sont binaires. Dans les deux cas, des commandes comme [`file`](https://man7.org/linux/man-pages/man1/file.1.html) ou [`stat`](https://man7.org/linux/man-pages/man2/lstat.2.html) renvoient généralement simplement "fichier vide" ou "0" pour la taille, bien qu'ils afficheront d'autres informations.

Les programmes prédestinés et standards pour interagir avec ces fonctions sont [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html), [`modinfo`](https://man7.org/linux/man-pages/man8/modinfo.8.html), et [`sysctl`](https://man7.org/linux/man-pages/man8/sysctl.8.html), entre autres.

```bash
sysctl -a | grep -i <keyword>
```

```bash
lsmod | grep -i <keyword>
```

```bash
modinfo <module>
```

Voyez ce que vous utilisez actuellement avec la version "kernel release" :

`uname -r` et remplacer sa valeur retournée dans les commandes en utilisant `$(uname -r)`

RHEL et distributions dérivées (Fedora, CentOS Stream, Scientific Linux, RockyLinux, Almalinux, et autres) stocke également la configuration utilisée pour amorcer les noyaux installés dans le répertoire `/boot` utilisé par Grub2 comme fichiers ASCII :

```bash
/boot/config-<kernel-release>
```

Pour vérifier la configuration du noyau en cours d'exécution pour une valeur particulière:

```bash
cat /boot/config-$(uname -r) | grep -i <keyword>
```

Les résultats suivants devraient être affichés :

  - "=m" si compilé en tant que module de noyau
  - "=y" si compilé statiquement dans le noyau
  - "is not set" si ce paramètre a été commenté
  - une valeur numérique
  - une valeur de chaîne entre guillemets

Certaines distributions, comme Gentoo et Arch, utilisent le module du noyau `configs` pour fournir par défaut `/proc/config.gz` :

```bash
zcat /proc/config.gz | grep -i <keyword>
zgrep <keyword> /proc/config.gz
```

Pour toute distribution, si votre noyau en cours d'exécution a défini à la fois `CONFIG_IKCONFIG` et `CONFIG_IKCONFIG_PROC` et si

```bash
ls -lh /sys/module/configs
```

existe et est exécutable (interrogeable dans le cas d'un répertoire), vous pouvez alors créer `/proc/config.gz` avec cette commande si elle n'est pas présente :

```bash
modprobe configs
```

!!! note "Dépôts activés"

    Ce document ne couvre pas actuellement les paquets du noyau qui pourraient provenir de repos non par défaut tels que :
    
    appstream-debug, appstream-source, baseos-debug, baseos-source ou devel


Les paquets `kernel-devel` installent le fichier de configuration utilisé pour compiler chaque paquet de noyau standard installé en tant que fichier ASCII à l'emplacement suivant :

```bash
/usr/src/kernels/<kernel-release>/.config
```

Ce fichier est plus couramment accédé par un chemin symbolique fourni par les paquets `kernel-core` :

```bash
/lib/modules/<kernel-release>/build/ -> /usr/src/kernels/<kernel-release>/
```

Si vous avez des paquets `kernel-debug-devel` installés, vous aurez également ce répertoire :

```bash
 /usr/src/kernels/<kernel-release>+debug/
```

Vous pouvez regarder dans l'un des éléments suivants pour plus de détails sur les valeurs de configuration utilisées pour construire un noyau installé :

```bash
/lib/modules/<kernel-release>/config
/lib/modules/<kernel-release>/build/.config
/usr/src/kernels/<kernel-release>/.config
/usr/src/kernels/<kernel-release>+debug/.config
```

Les modules configurés pour le noyau en cours d'exécution, s'ils sont compilés comme internes (i.e. statiquement dans le noyau lui-même) ou dans un module chargeable, sont listés par sous-répertoires nommés comme nom de module dans :

```bash
/sys/module/
```

Pour chaque version du noyau installée, vous pouvez examiner ces fichiers pour voir quelles sont les valeurs compilées dans ce noyau, et quelle version de [GCC](https://man7.org/linux/man-pages/man1/gcc.1.html) a été utilisée pour la compiler :

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

Vous pouvez vérifier les dépendances du module de noyau dans le fichier :

```bash
/lib/modules/<kernel-release>/modules.dep
```

mais il est plus facile de lire ou d'analyser la sortie du champ "Used-by" dans [`lsmod`](https://man7.org/linux/man-pages/man8/lsmod.8.html).

## Références :

[depmod](https://man7.org/linux/man-pages/man8/depmod.8.html), [ls](https://man7.org/linux/man-pages/man1/ls.1.html), [lsmod](https://man7.org/linux/man-pages/man8/lsmod.8.html), [modinfo](https://man7.org/linux/man-pages/man8/modinfo.8.html), [modprobe](https://man7.org/linux/man-pages/man8/modprobe.8.html), [modules.dep](https://man7.org/linux/man-pages/man5/modules.dep.5.html), [namespaces](https://man7.org/linux/man-pages/man7/namespaces.7.html), [procfs](https://man7.org/linux/man-pages/man5/procfs.5.html), [sysctl](https://man7.org/linux/man-pages/man8/sysctl.8.html), [sysfs](https://man7.org/linux/man-pages/man5/sysfs.5.html), [uname](https://man7.org/linux/man-pages/man8/uname26.8.html)
