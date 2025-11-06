---
title: Test di compatibilità della CPU
author: Steven Spencer
contributors: Louis Abel, Ganna Zhyrnova
tags:
  - cpu test
---

# Introduzione

Alcune installazioni su piattaforme x86-64 potrebbero causare un kernel panic. Nella maggior parte dei casi, ==ciò è dovuto all'incompatibilità della CPU== con Rocky Linux.

## Verifica

1. Ottieni un'immagine di avvio per Rocky Linux 9, Fedora o altre distribuzioni.

2. Avvia questa immagine live sul computer su cui desideri installare Rocky Linux 10.

3. Al termine dell'avvio, aprire una finestra del terminale ed eseguire questa operazione:

   ```bash
   /lib64/ld-linux-x86-64.so.2 --help | grep x86-64
   ```

   Si dovrebbe ottenere un risultato simile a questo:

   ```bash
   Usage: /lib64/ld-linux-x86-64.so.2 [OPTION]... EXECUTABLE-FILE [ARGS-FOR-PROGRAM...]
   This program interpreter self-identifies as: /lib64/ld-linux-x86-64.so.2
   x86-64-v4
   x86-64-v3 (supported, searched)
   x86-64-v2 (supported, searched)
   ```

   Questo output indica la versione minima richiesta di x86-64 (v3). In questo caso, l'installazione può continuare. Se accanto alla voce "x86-64-v3" manca la dicitura "(supported, searched)", allora la tua CPU **non** è compatibile con Rocky Linux 10. Se il test indica che l'installazione può procedere e riporta anche x86-64-v4 come "(supported, searched)", la tua CPU è ben supportata per le versioni future di Rocky Linux.
