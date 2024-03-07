---
title: Test di compatibilità della CPU
author: Spencer Steven
contributors: Louis Abel, Ganna Zhyrnova
tags:
  - cpu test
---

# Introduzione

Dal rilascio di Rocky Linux 9, alcune installazioni su piattaforme x86-64 sono fallite con un kernel panic. Nella maggior parte dei casi, ==questo è dovuto all'incompatibilità della CPU== con Rocky Linux 9. Questa procedura consente di verificare la compatibilità della CPU prima dell'installazione.

## Verifica

1. Procurarsi un'immagine di avvio di Rocky Linux 8, Fedora o altri.

2. Avviare l'immagine live sulla macchina dove si desidera installare Rocky Linux 9.

3. Al termine dell'avvio, aprire una finestra del terminale ed eseguire questa operazione:

   ```bash
   /lib64/ld-linux-x86-64.so.2 --help | grep x86-64
   ```

   Si dovrebbe ottenere un risultato simile a questo:

   ```bash
   Usage: /lib64/ld-linux-x86-64.so.2 [OPTION]... EXECUTABLE-FILE [ARGS-FOR-PROGRAM...]
   This program interpreter self-identifies as: /lib64/ld-linux-x86-64.so.2
   x86-64-v4
   x86-64-v3
   x86-64-v2 (supported, searched)
   ```

   Questo output indica la versione minima richiesta per x86-64 (v2). In questo caso, l'installazione può continuare. Se accanto alla voce "x86-64-v2" non compare "(supported, searched)", allora la vostra CPU non è **compatibile** con Rocky Linux 9.x. Se il test mostra che l'installazione può continuare e indica anche x86-64-v3 e x86-64-v4 come "(supported, searched)", significa che la CPU è ben supportata per 9.x e le versioni future.
