---
title: Test der CPU-Kompatibilität
author: Steven Spencer
contributors: Louis Abel, Ganna Zhyrnova
tags:
  - cpu test
---

# Einleitung

Einige Installationen auf x86-64-Plattformen können einen Kernel-Panic verursachen. In den meisten Fällen ist dies auf die ==Inkompatibilität der CPU mit Rocky Linux== zurückzuführen.

## Testen

1. Besorgen Sie sich ein Boot-Image für Rocky Linux 9, Fedora oder andere Distributionen.

2. Booten Sie dieses Live-Image auf dem Computer, auf dem Sie Rocky Linux 10 installieren möchten.

3. Nachdem der Startvorgang abgeschlossen ist, öffnen Sie ein Terminalfenster und führen Sie dieses Kommando aus:

   ```bash
   /lib64/ld-linux-x86-64.so.2 --help | grep x86-64
   ```

   Sie sollten eine Ausgabe erhalten, die etwa dieser ähnelt:

   ```bash
   Usage: /lib64/ld-linux-x86-64.so.2 [OPTION]... EXECUTABLE-FILE [ARGS-FOR-PROGRAM...]
   This program interpreter self-identifies as: /lib64/ld-linux-x86-64.so.2
   x86-64-v4
   x86-64-v3 (supported, searched)
   x86-64-v2 (supported, searched)
   ```

   Diese Ausgabe gibt die minimal erforderliche x86-64-Version (v3) an. In diesem Fall kann die Installation fortgesetzt werden. Wenn Sie neben `x86-64-v3` kein Eintrag (`supported, searched`) sehen, ist Ihre CPU nicht mit Rocky Linux 10 kompatibel. Wenn der Test anzeigt, dass Ihre Installation fortgesetzt werden kann und x86-64-v4 auch als `(supported, searched)` aufgeführt wird, wird Ihre CPU für zukünftige Versionen von Rocky Linux gut unterstützt.
