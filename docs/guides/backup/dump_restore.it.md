---
title: Comandi dump e restore
author: tianci li
contributors: Steven Spencer
tested_with: 8.10
tags:
  - dump
  - restore
  - backup
---

## Panoramica

`dump` esamina i file di un filesystem, determina di quali eseguire il backup e copia tali file su un disco, un nastro o un altro supporto di memorizzazione specificato. Il comando `restore` esegue la funzione inversa di `dump`.

Questa utilità si applica ai seguenti file system:

- ext2
- ext3
- ext4

!!! tip

```
Per il file system xfs, usare `xfsdump`.
```

[Questa](https://dump.sourceforge.io/) è la homepage del progetto.

Prima di utilizzare questa utility, eseguire il seguente comando per installarla:

```bash
Shell > dnf -y install dump
```

Dopo l'installazione, sono disponibili due strumenti di comando comunemente utilizzati:

- `dump`
- `restore`

### Comando `dump`

Questo comando può essere utilizzato principalmente in due modi:

- Eseguire operazioni di backup (dump) - `dump [opzione/i] -f <File-Name> <File1> ...`
- Esaminare le informazioni di backup (dump) - `dump [-W | -w]`

Le opzioni più comuni sono:

- `-<level>` - Livello di backup. Sostituire “livello” con un numero qualsiasi da 0 a 9 quando viene utilizzato. Il numero 0 rappresenta il backup completo, mentre gli altri numeri rappresentano il backup incrementale.
- `-f <File-Name>` - Specifica il nome e il percorso del file dopo il backup.
- `-u` - Dopo un backup riuscito, registra l'ora del backup nel file **/etc/dumpdates**. È possibile utilizzare l'opzione `-u` quando l'oggetto di cui si esegue il backup è una partizione indipendente. Tuttavia, non è possibile utilizzare l'opzione `-u` quando l'oggetto di backup è una directory non partizionata.
- `-v` - Visualizza i dettagli dell'elaborazione durante il processo di backup.
- `-W` - Un'opzione per visualizzare le informazioni sul dump.
- `-z[LEVEL]` - Regola il livello di compressione usando la libreria zlib, con un livello di compressione predefinito pari a 2. Ad esempio, è possibile comprimere il file di backup in formato `.gz`. L'intervallo di regolazione del livello di compressione è da 1 a 9.
- `-j[LEVEL]` - Regola il livello di compressione usando la libreria bzlib, con un livello di compressione predefinito pari a 2. Ad esempio, è possibile comprimere il file di backup in formato `.bz2`. L'intervallo di regolazione del livello di compressione è da 1 a 9.

#### Esempio di utilizzo di `dump`

1. Eseguire un backup completo della partizione principale:

   ```bash
   Shell > dump -0u -j3 -f /tmp/root-20241208.bak.bz2 /
   DUMP: Date of this level 0 dump: Sun Dec  8 19:04:39 2024
   DUMP: Dumping /dev/nvme0n1p2 (/) to /tmp/root-20241208.bak.bz2
   DUMP: Label: none
   DUMP: Writing 10 Kilobyte records
   DUMP: Compressing output at transformation level 3 (bzlib)
   DUMP: mapping (Pass I) [regular files]
   DUMP: mapping (Pass II) [directories]
   DUMP: estimated 14693111 blocks.
   DUMP: Volume 1 started with block 1 at: Sun Dec  8 19:04:41 2024
   DUMP: dumping (Pass III) [directories]
   DUMP: dumping (Pass IV) [regular files]
   DUMP: 20.69% done at 10133 kB/s, finished in 0:19
   DUMP: 43.74% done at 10712 kB/s, finished in 0:12
   DUMP: 70.91% done at 11575 kB/s, finished in 0:06
   DUMP: 93.23% done at 11415 kB/s, finished in 0:01
   DUMP: Closing /tmp/root-20241208.bak.bz2
   DUMP: Volume 1 completed at: Sun Dec  8 19:26:08 2024
   DUMP: Volume 1 took 0:21:27
   DUMP: Volume 1 transfer rate: 5133 kB/s
   DUMP: Volume 1 14722930kB uncompressed, 6607183kB compressed, 2.229:1
   DUMP: 14722930 blocks (14377.86MB) on 1 volume(s)
   DUMP: finished in 1287 seconds, throughput 11439 kBytes/sec
   DUMP: Date of this level 0 dump: Sun Dec  8 19:04:39 2024
   DUMP: Date this dump completed:  Sun Dec  8 19:26:08 2024
   DUMP: Average transfer rate: 5133 kB/s
   DUMP: Wrote 14722930kB uncompressed, 6607183kB compressed, 2.229:1
   DUMP: DUMP IS DONE

   Shell > ls -lh /tmp/root-20241208.bak.bz2
   -rw-r--r-- 1 root root 6.4G Dec  8 19:26 /tmp/root-20241208.bak.bz2
   ```

2. Dopo aver effettuato lo scarico, controllare le informazioni pertinenti:

   ```bash
   Shell > cat /etc/dumpdates
   /dev/nvme0n1p2 0 Sun Dec  8 19:04:39 2024 +0800

   Shell > dump -W
   Last dump(s) done (Dump '>' file systems):
   /dev/nvme0n1p2        (     /) Last dump: Level 0, Date Sun Dec  8 19:04:39 2024
   ```

3. Implementare il backup incrementale sulla base del backup completo:

   ```bash
   Shell > echo "jack" >> /tmp/tmpfile.txt

   Shell > dump -1u -j4 -f /tmp/root-20241208-LV1.bak.bz2 /
   DUMP: Date of this level 1 dump: Sun Dec  8 19:38:51 2024
   DUMP: Date of last level 0 dump: Sun Dec  8 19:04:39 2024
   DUMP: Dumping /dev/nvme0n1p2 (/) to /tmp/root-20241208-LV1.bak.bz2
   DUMP: Label: none
   DUMP: Writing 10 Kilobyte records
   DUMP: Compressing output at transformation level 4 (bzlib)
   DUMP: mapping (Pass I) [regular files]
   DUMP: mapping (Pass II) [directories]
   DUMP: estimated 6620898 blocks.
   DUMP: Volume 1 started with block 1 at: Sun Dec  8 19:38:58 2024
   DUMP: dumping (Pass III) [directories]
   DUMP: dumping (Pass IV) [regular files]
   DUMP: 38.13% done at 8415 kB/s, finished in 0:08
   DUMP: 75.30% done at 8309 kB/s, finished in 0:03
   DUMP: Closing /tmp/root-20241208-LV1.bak.bz2
   DUMP: Volume 1 completed at: Sun Dec  8 19:52:03 2024
   DUMP: Volume 1 took 0:13:05
   DUMP: Volume 1 transfer rate: 8408 kB/s
   DUMP: Volume 1 6620910kB uncompressed, 6600592kB compressed, 1.004:1
   DUMP: 6620910 blocks (6465.73MB) on 1 volume(s)
   DUMP: finished in 785 seconds, throughput 8434 kBytes/sec
   DUMP: Date of this level 1 dump: Sun Dec  8 19:38:51 2024
   DUMP: Date this dump completed:  Sun Dec  8 19:52:03 2024
   DUMP: Average transfer rate: 8408 kB/s
   DUMP: Wrote 6620910kB uncompressed, 6600592kB compressed, 1.004:1
   DUMP: DUMP IS DONE

   Shell > cat /etc/dumpdates
   /dev/nvme0n1p2 0 Sun Dec  8 19:04:39 2024 +0800
   /dev/nvme0n1p2 1 Sun Dec  8 19:38:51 2024 +0800

   Shell > dump -W
   Last dump(s) done (Dump '>' file systems):
   /dev/nvme0n1p2        (     /) Last dump: Level 1, Date Sun Dec  8 19:38:51 2024
   ```

4. Per le directory non partizionate, è possibile utilizzare solo l'opzione Backup completo (`-0`), non l'opzione `-u`:

   ```bash
   Shell > dump -0uj -f /tmp/etc-full-20241208.bak.bz2 /etc/
   DUMP: You can't update the dumpdates file when dumping a subdirectory
   DUMP: The ENTIRE dump is aborted.

   Shell > dump -0j -f /tmp/etc-full-20241208.bak.bz2 /etc/
   DUMP: Date of this level 0 dump: Sun Dec  8 20:00:38 2024
   DUMP: Dumping /dev/nvme0n1p2 (/ (dir etc)) to /tmp/etc-full-20241208.bak.bz2
   DUMP: Label: none
   DUMP: Writing 10 Kilobyte records
   DUMP: Compressing output at transformation level 2 (bzlib)
   DUMP: mapping (Pass I) [regular files]
   DUMP: mapping (Pass II) [directories]
   DUMP: estimated 28204 blocks.
   DUMP: Volume 1 started with block 1 at: Sun Dec  8 20:00:38 2024
   DUMP: dumping (Pass III) [directories]
   DUMP: dumping (Pass IV) [regular files]
   DUMP: Closing /tmp/etc-full-20241208.bak.bz2
   DUMP: Volume 1 completed at: Sun Dec  8 20:00:40 2024
   DUMP: Volume 1 took 0:00:02
   DUMP: Volume 1 transfer rate: 3751 kB/s
   DUMP: Volume 1 29090kB uncompressed, 7503kB compressed, 3.878:1
   DUMP: 29090 blocks (28.41MB) on 1 volume(s)
   DUMP: finished in 2 seconds, throughput 14545 kBytes/sec
   DUMP: Date of this level 0 dump: Sun Dec  8 20:00:38 2024
   DUMP: Date this dump completed:  Sun Dec  8 20:00:40 2024
   DUMP: Average transfer rate: 3751 kB/s
   DUMP: Wrote 29090kB uncompressed, 7503kB compressed, 3.878:1
   DUMP: DUMP IS DONE
   ```

   L'esecuzione di un backup incrementale della directory /etc/ genera un errore:

   ```bash
   Shell > dump -1j -f /tmp/etc-incr-20241208.bak.bz2 /etc/
   DUMP: Only level 0 dumps are allowed on a subdirectory
   DUMP: The ENTIRE dump is aborted.
   ```

### Comando `restore`

L'uso di questo comando è - `restore <mode(flag)> [opzione/i] -f <Dump-File>`.

La modalità (flag) può essere una delle seguenti:

- `-C` - Modalità di confronto. Il ripristino legge il backup e ne confronta il contenuto con i file presenti su disco. Viene utilizzato principalmente per il confronto dopo l'esecuzione di un backup su una partizione. In questa modalità, `restore` confronta solo le modifiche basandosi sui dati di origine. Se sul disco sono presenti nuovi dati, non è possibile confrontarli o rilevarli.
- `-i` - Modalità interattiva. Questa modalità consente il ripristino interattivo dei file da un dump.
- `-t` - Modalità elenco. Elenca i dati contenuti nel file di backup.
- `-r` - Modalità di ripristino (rebuild). Se si tratta di un metodo “Backup completo + backup incrementale”, il ripristino dei dati avverrà in ordine cronologico.
- `-x` - Modalità estrazione. Estrarre alcuni o tutti i file dal file di backup.

#### Esempio di utilizzo di `restore`

1. Ripristinare i dati da /tmp/etc-full-20241208.bak.bz2 :

   ```bash
   Shell > mkdir /tmp/data/

   Shell > restore -t -f /tmp/etc-full-20241208.bak.bz2

   Shell > cd /tmp/data/ ; restore -r -f /tmp/etc-full-20241208.bak.bz2

   Shell > ls -l /tmp/data/
   total 4992
   drwxr-xr-x. 90 root root    4096 Dec  8 17:13 etc
   -rw-------   1 root root 5107632 Dec  8 20:39 restoresymtable
   ```

   Come si può vedere, dopo un ripristino riuscito viene visualizzato un file chiamato `restoresymtable`. Questo file è importante. Serve per le operazioni di ripristino del sistema di backup incrementale.

2. Elaborare i file di backup in modalità interattiva:

   ```bash
   Shell > restore -i -f /tmp/etc-full-20241208.bak.bz2
   Dump tape is compressed.

   restore > ?
   ```

   È possibile digitare ++question++ per visualizzare i comandi interattivi disponibili in questa modalità.
