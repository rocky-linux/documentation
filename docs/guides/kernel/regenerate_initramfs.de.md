---
title: Regenerierung des `initramfs`
author: Neel Chauhan
contributors: Steven Spencer
tested_with: 9.4
tags:
  - Hardware
---

## Einleitung

Ein `initramfs` ist das Root-Dateisystem innerhalb eines Linux-Kernels, das beim Booten des Systems mitwirkt. Es enthält die Kernmodule, die zum Booten von Linux erforderlich sind.

Manchmal möchte ein Linux-Administrator das `initramfs` neu generieren, etwa wenn er einen Treiber auf die schwarze Liste setzen oder ein Out-of-Band Modul einbinden möchte. Der Autor hat dies getan, um [Intel vPro auf einem Minisforum MS-01 zu aktivieren](https://spaceterran.com/posts/step-by-step-guide-enabling-intel-vpro-on-your-minisforum-ms-01-bios/).

## Voraussetzungen

Für die Verwendung dieses Verfahrens sind folgende Mindestanforderungen zu beachten:

- Ein Rocky Linux-System oder eine virtuelle Maschine (kein Container)
- Änderungen am Kernel-Setup, wie z. B. Blacklisting oder Hinzufügen eines Moduls

## Regenerierung des `initramfs`

Um das `initramfs` neu zu generieren, sollten Sie zunächst das vorhandene `initramfs` sichern:

```bash
cp /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-$(date +%m-%d-%H%M%S).img
```

Führen Sie als Nächstes `dracut` aus, um `initramfs` neu zu generieren:

```bash
dracut -f /boot/initramfs-$(uname -r).img $(uname -r)
```

Dann neu starten:

```bash
reboot
```

## Zusammenfassung

Der Linux-Kernel ist äußerst leistungsstark und modular. Es ist sinnvoll, dass einige Benutzer bestimmte Module zulassen oder verbieten möchten, und die erneute Generierung des `initramfs` ermöglicht dies.
