---
title: Test der CPU-Kompatibilität
author: Steven Spencer
contributors: Louis Abel, Ganna Zhyrnova
tags:
  - cpu test
---

# Einleitung

Seit der Veröffentlichung von Rocky Linux 9 sind einige Installationen auf x86-64-Plattformen beim Start mit einer Kernel-Panic-Meldung fehlgeschlagen. In den meisten Fällen ist dies auf die ==Inkompatibilität der CPU mit Rocky Linux 9== zurückzuführen. Mit diesem Verfahren wird die CPU-Kompatibilität vor der Installation überprüft. **Update:** Dieses Verfahren spiegelt nun auch die Mindestprozessorkompatibilität für Rocky Linux 10 wider.

## Testen

1. Besorgen Sie sich ein Boot-Image von Rocky Linux 8, Fedora oder anderen.

2. Booten Sie dieses Live-Image auf dem Computer, auf dem Sie Rocky Linux 9 installieren möchten.

3. Nachdem der Startvorgang abgeschlossen ist, öffnen Sie ein Terminalfenster und führen Sie dieses Kommando aus:

  ```bash
  /lib64/ld-linux-x86-64.so.2 --help | grep x86-64
  ```

  Sie sollten eine Ausgabe erhalten, die etwa dieser ähnelt:

  ```bash
  Usage: /lib64/ld-linux-x86-64.so.2 [OPTION]... EXECUTABLE-FILE [ARGS-FOR-PROGRAM...]
  This program interpreter self-identifies as: /lib64/ld-linux-x86-64.so.2
  x86-64-v4
  x86-64-v3
  x86-64-v2 (supported, searched)
  ```

  Diese Ausgabe gibt die minimal erforderliche x86-64-Version (v2) an. In diesem Fall kann die Installation fortgesetzt werden. Wenn Sie neben `x86-64-v2` kein Eintrag (`supported, searched`) sehen, ist Ihre CPU nicht mit Rocky Linux 9.x kompatibel. Wenn der Test anzeigt, dass Ihre Installation fortgesetzt werden kann und x86-64-v3 (erforderlich für Rocky Linux 10) und x86-64-v4 auch als `(supported, searched)` aufgeführt werden, wird Ihre CPU für 9.x und zukünftige Versionen gut unterstützt.
