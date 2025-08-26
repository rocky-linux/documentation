---
title: Comando tar
author: tianci li
contributors: Ganna Zhyrnova
tested_with: 8.10
tags:
  - tar
  - backup
  - archive
---

## Panoramica

`tar` è uno strumento per elaborare i file di archivio su GNU/Linux e altri sistemi operativi UNIX. Sta per “tape archive” (archiviazione su nastro magnetico).

L'archiviazione dei file su nastro magnetico è stato l'uso iniziale degli archivi tar. Il nome “tar” deriva da questo uso. Nonostante il nome dell'utilità, `tar` può dirigere il suo output verso dispositivi, file o altri programmi disponibili (usando le pipe) e accedere a dispositivi o file remoti (come archivi).

Il `tar' attualmente utilizzato nei moderni GNU/Linux proveniva inizialmente dal [Progetto GNU](https://www.gnu.org/). È possibile consultare e scaricare tutte le versioni di `tar\` sul [sito web di GNU](https://ftp.gnu.org/gnu/tar/).

!!! note

````
`tar` in distribuzioni diverse può avere opzioni predefinite diverse. Fate attenzione quando le usate.

```bash
# RockyLinux 8 e Fedora 41
Shell > tar --show-defaults
--format=gnu -f- -b20 --quoting-style=escape --rmt-command=/etc/rmt --rsh-command=/usr/bin/ssh
```
````

## Usare `tar`

Quando si usa `tar`, si noti che ha due modalità di salvataggio:

- **Relative mode** (default): Rimuove il carattere iniziale ‘/’ dal file. Anche se il file è stato aggiunto con un percorso assoluto, `tar` rimuoverà il carattere iniziale “/” in questa modalità.
- **Absolute mode**: Mantiene il carattere iniziale ‘/’ e lo include nel percorso del file. È necessario utilizzare l'opzione \`-P' per attivare questa modalità di archiviazione. In questa modalità, tutti i file devono essere rappresentati come percorsi assoluti. Per motivi di sicurezza, nella maggior parte dei casi non si dovrebbe utilizzare questa modalità di salvataggio, a meno che non vi siano requisiti particolari.

Quando si usa `tar`, si incontrano suffissi come `.tar.gz`, `.tar.xz` e `.tar.bz2`, che indicano che prima la creazione di un archivio (classificando i file correlati come un singolo file) e si e' compresso il file con il tipo o l'algoritmo di compressione specifico.

Il tipo di compressione o algoritmo può essere gzip, bzip2, xz, zstd o un altro.

`tar` consente di estrarre un singolo file o una directory da un backup, di visualizzarne il contenuto o di convalidarne l'integrità.

La sintassi per la creazione di un archivio e relativa compressione è:

- `tar [option] [PATH] [DIR1] ... [FILE1] ...`. Ad es., `tar -czvf /tmp/Fullbackup-20241201.tar.gz /etc/ /var/log/`

La sintassi per estrarre un file da un archivio è:

- `tar [option] [PATH] -C [dir]`. Ad es., `tar -xzvf /tmp/Fullbackup-20241201.tar.gz -C /tmp/D1`

!!! tip "antic"

Quando si estraggono file da file archiviati, `tar` seleziona automaticamente il tipo di compressione in base al suffisso aggiunto manualmente. Ad esempio, per i file `.tar.gz', si può usare direttamente `tar -vxf' senza usare \`tar -zvxf'.
È invece **obbligatorio** selezionare il tipo di compressione per la creazione di file compressi di archivio.

!!! Note

```
In GNU/Linux, la maggior parte dei file non richiede un'estensione, tranne che per l'ambiente desktop (GUI). La ragione dell'aggiunta artificiale di suffissi è quella di facilitare il riconoscimento da parte degli utenti umani. Se l'amministratore di sistema vede un file con estensione `.tar.gz' o `.tgz', ad esempio, sa come trattare il file.
```

### Parametri o tipi di funzionamento

|  Parametro | Descrizione                                                                                                                                                              |
| :--------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|    `-A`    | Aggiunge tutti i file di un archivio alla fine di un altro archivio. Applicabile solo per archiviare file non compressi del tipo `.tar`. |
|    `-c`    | Crea un archivio. Spesso utilizzato                                                                                                                      |
|    `-d`    | Confronta le differenze tra i file archiviati e quelli corrispondenti non archiviati.                                                                    |
|    `-r`    | Aggiunge i file o le directory alla fine dell'archivio. Applicabile solo per archiviare file non compressi del tipo `.tar`.              |
|    `-t`    | Elenca il contenuto dell'archivio                                                                                                                                        |
|    `-u`    | Aggiunge all'archivio solo i file più recenti. Applicabile solo per archiviare file non compressi del tipo `.tar`.                       |
|    `-x`    | Estrazione da un archivio. Spesso utilizzato                                                                                                             |
| `--delete` | Cancella file o cartelle dall'archivio ".tar" Applicabile solo per archiviare file non compressi del tipo `.tar`.                        |

!!! Tip

```
L'autore consiglia di mantenere il prefisso “-” per preservare le abitudini degli utenti riguardo ai tipi di operazione. Naturalmente, non è necessario. I parametri indicano la funzione principale di `tar`. In altre parole, è necessario scegliere uno dei tipi sopra elencati.
```

### Opzioni ausiliarie più comuni

| opzione | Descrizione                                                                                                                                    |
| :-----: | :--------------------------------------------------------------------------------------------------------------------------------------------- |
|   `-z`  | Usa `gzip` come tipo di compressione. E' applicabile sia per la creazione che l'estrazione degli archivi.      |
|   `-v`  | Visualizza i dettagli dell'elaborazione                                                                                                        |
|   `-f`  | Specifica il nome del file per l'archiviazione (compreso il suffisso del file)                                              |
|   `-j`  | Usa `bzip2` come tipo di compressione. E' applicabile sia per la creazione che l'estrazione degli archivi.     |
|   `-J`  | Utilizzare `xz` come tipo di compressione. E' applicabile sia per la creazione che l'estrazione degli archivi. |
|   `-C`  | Salva la posizione dopo l'estrazione dei file dall'archivio                                                                                    |
|   `-P`  | Salva utilizzando la modalità percorsi assoluti                                                                                                |

Per altre opzioni ausiliarie non menzionate, vedere `man 1 tar`.

!!! avviso "Differenza di versione"

```
In alcune vecchie versioni di tar, le opzioni sono indicate come "key", il che significa che l'uso di opzioni con il prefisso "-" può far sì che `tar` non funzioni come previsto. A questo punto, è necessario rimuovere il prefisso "-" per farlo funzionare correttamente.
```

### Dettaglio sugli stili dei parametri opzione

`tar` fornisce tre stili dei parametri:

1. Stile tradizionale:

   - `tar {A|c|d|r|t|u|x}[GnSkUWOmpsMBiajJzZhPlRvwo] [ARG...]`.

2. L'uso dello stile breve dei parametri è:

   - `tar -A [OPTIONS] ARCHIVE ARCHIVE`
   - `tar -c [-f ARCHIVE] [OPTIONS] [FILE...]`
   - `tar -d [-f ARCHIVE] [OPTIONS] [FILE...]`
   - `tar -t [-f ARCHIVE] [OPTIONS] [MEMBER...]`
   - `tar -r [-f ARCHIVE] [OPTIONS] [FILE...]`
   - `tar -u [-f ARCHIVE] [OPTIONS] [FILE...]`
   - `tar -x [-f ARCHIVE] [OPTIONS] [MEMBER...]`

3. L'uso dello stile lungo dei parametri è:

   - `tar {--catenate|--concatenate} [OPTIONS] ARCHIVE ARCHIVE`
   - `tar --create [--file ARCHIVE] [OPTIONS] [FILE...]`
   - `tar {--diff|--compare} [--file ARCHIVE] [OPTIONS] [FILE...]`
   - `tar --delete [--file ARCHIVE] [OPTIONS] [MEMBER...]`
   - `tar --append [-f ARCHIVE] [OPTIONS] [FILE...]`
   - `tar --list [-f ARCHIVE] [OPTIONS] [MEMBER...]`
   - `tar --test-label [--file ARCHIVE] [OPTIONS] [LABEL...]`
   - `tar --update [--file ARCHIVE] [OPTIONS] [FILE...]`
   - `tar --update [-f ARCHIVE] [OPTIONS] [FILE...]`
   - `tar {--extract|--get} [-f ARCHIVE] [OPTIONS] [MEMBER...]`

Il secondo metodo è più comunemente usato ed è in linea con le abitudini della maggior parte degli utenti GNU/Linux.

### Efficienza di compressione e frequenza di utilizzo

`tar` non ha capacità di compressione, quindi deve essere usato con altri strumenti di compressione. La compressione e la decompressione influiscono sul consumo di risorse.

Ecco una classifica della compressione di un insieme di file di testo, dalla meno efficiente alla più efficiente:

- compress (`.tar.Z`) - meno popolare
- gzip (`.tar.gz` or `.tgz`) - Popolare
- bzip2 (`.tar.bz2` or `.tb2` or `.tbz`) - Popolare
- lzip (`.tar.lz`) - meno popolare
- xz (`.tar.xz`) - Popolare

### Convenzioni nella nomenclatura di un `tar`

Ecco alcuni esempi di convenzioni di nomenclatura per gli archivi `tar`:

| Funzione principale e parametri ausiliari | Files   | Suffisso         | Funzionalità                                                    |
| ----------------------------------------- | ------- | ---------------- | --------------------------------------------------------------- |
| `-cvf`                                    | `home`  | `home.tar`       | `/home` in modalità relativa, archiviato in forma non compressa |
| `-cvfP`                                   | `/etc`  | `etc.A.tar`      | `/etc` in modalità percorso assoluto, senza compressione        |
| `-cvfz`                                   | `usr`   | `usr.tar.gz`     | `/usr` in modalità percorso relativo, compressione _gzip_       |
| `-cvfj`                                   | `usr`   | `usr.tar.bz2`    | `/usr` in modalità percorso relativo, compressione _bzip2_      |
| `-cvfPz`                                  | `/home` | `home.A.tar.gz`  | `/home` in modalità percorso assoluto, compressione _gzip_      |
| `-cvfPj`                                  | `/home` | `home.A.tar.bz2` | `/home` in modalità percorso assoluto, compressione _bzip2_     |

È anche possibile aggiungere la data al nome del file.

### Esempi

#### Casi con `-c`

1. Archivia e comprime **/etc/** in modalità percorso relativo, con un suffisso `.tar.gz`:

   ```bash
   Shell > tar -czvf /tmp/etc-20241207.tar.gz /etc/
   ```

   Poiché `tar` lavora in modalità percorsi relativi per impostazione predefinita, la prima riga dell'output del comando mostrerà quanto segue:

   ```bash
   tar: Removing leading '/' from member names
   ```

2. Archiviazione di **/var/log/** e selezionare il tipo xz per la compressione:

   ```bash
   Shell > tar -cJvf /tmp/log-20241207.tar.xz /var/log/

   Shell > du -sh /var/log/ ; ls -lh /tmp/log-20241207.tar.xz
   18M     /var/log/
   -rw-r--r-- 1 root root 744K Dec  7 14:40 /tmp/log-20241207.tar.xz
   ```

3. Stima delle dimensioni del file senza generare un archivio:

   ```bash
   Shell > tar -cJf - /etc | wc -c
   tar: Removing leading `/' from member names
   3721884
   ```

   L'unità di misura del comando `wc -c` è il byte.

4. Taglia i file \`.tar.gz' di grandi dimensioni:

   ```bash
   Shell > cd /tmp/ ; tar -czf - /etc/  | split -d -b 2M - etc-backup20241207.tar.gz.

   Shell > ls -lh /tmp/
   -rw-r--r-- 1 root root 2.0M Dec  7 20:46 etc-backup20241207.tar.gz.00
   -rw-r--r-- 1 root root 2.0M Dec  7 20:46 etc-backup20241207.tar.gz.01
   -rw-r--r-- 1 root root 2.0M Dec  7 20:46 etc-backup20241207.tar.gz.02
   -rw-r--r-- 1 root root  70K Dec  7 20:46 etc-backup20241207.tar.gz.03
   ```

   Il primo “-” rappresenta i parametri di ingresso di `tar`, mentre il secondo “-” indica a `tar` di reindirizzare l'output a `stdout`.

   Per estrarre questi piccoli file tagliati, si può puntare alla seguente operazione:

   ```bash
   Shell > cd /tmp/ ; cat etc-backup20241207.tar.gz.* >> /tmp/etc-backup-20241207.tar.gz

   Shell > cd /tmp/ ; tar -xvf etc-backup-20241207.tar.gz -C /tmp/dir1/
   ```

#### Casi con '-x'

1. Scaricate il codice sorgente di Redis ed estrarlo nella directory `/usr/local/src/`:

   ```bash
   Shell > wget -c https://github.com/redis/redis/archive/refs/tags/7.4.1.tar.gz

   Shell > tar -xvf 7.4.1.tar.gz -C /usr/local/src/
   ```

2. Estrarre solo un file dal file zip dell'archivio:

   ```bash
   Shell > tar -xvf /tmp/etc-20241207.tar.gz etc/chrony.conf
   ```

#### Casi con '-A' o '-r'

1. Aggiunge un file `.tar' a un altro file `.tar':

   ```bash
   Shell > tar -cvf /tmp/etc.tar /etc/

   Shell > tar -cvf /tmp/log.tar /var/log/

   Shell > tar -Avf /tmp/etc.tar /tmp/log.tar
   ```

   Ciò significa che tutti i file in “log.tar” saranno aggiunti alla fine di “etc.tar”.

2. Aggiunge file o directory a un file `.tar`:

   ```bash
   Shell > tar -rvf /tmp/log.tar /etc/chrony.conf
   tar: Removing leading `/' from member names
   /etc/chrony.conf
   tar: Removing leading `/' from hard link targets

   Shell > tar -rvf /tmp/log.tar /tmp/dir1
   ```

!!! warning "Attenzione"

```
Sia che si utilizzi l'opzione `-A` o `-r`, considerare la modalità di salvataggio dei file di archivio pertinenti.
```

!!! warning "Attenzione"

```
`-A` e `-r` non sono applicabili ai file compressi archiviati.
```

#### Casi con '-t'

1. Esaminare il contenuto dell'archivio:

   ```bash
   Shell > tar -tvf /tmp/log.tar

   Shell > tar -tvf /tmp/etc-20241207.tar.gz | less
   ```

#### Casi con '-d'

1. Confrontare le differenze:

   ```bash
   Shell > cd / ; tar -dvf /tmp/etc.tar etc/chrony.conf
   etc/chrony.conf

   Shell > cd / ; tar -dvf /tmp/etc-20241207.tar.gz etc/
   ```

   Per i metodi di archiviazione che usano la modalità percorsi relativi, quando si usa il tipo \`-d', cambiare il percorso del file in ‘/’.

#### Casi con '-u'

1. Se esistono più versioni dello stesso file, si può usare il parametro `-u`:

   ```bash
   Shell > touch /tmp/tmpfile1

   Shell > tar -rvf /tmp/log.tar /tmp/tmpfile1

   Shell > echo "File Name" >> /tmp/tmpfile1

   Shell > tar -uvf /tmp/log.tar /tmp/tmpfile1

   Shell > tar -tvf /tmp/log.tar
   ...
   -rw-r--r-- root/root         0 2024-12-07 18:53 tmp/tmpfile1
   -rw-r--r-- root/root        10 2024-12-07 18:54 tmp/tmpfile1
   ```

#### Casi con '--delete'

1. Si può anche usare `--delete` per cancellare i file all'interno di un file `.tar`.

   ```bash
   Shell > tar --delete -vf /tmp/log.tar tmp/tmpfile1

   Shell > tar --delete -vf /tmp/etc.tar etc/motd.d/
   ```

   Quando si elimina, si eliminano tutti i file con lo stesso nome dall'archivio.

## Terminologia comune

Alcuni siti web riportano due termini:

- **tarfile** - Si riferisce a file di archivio non compressi, come i file `.tar`.
- **tarball** - Si riferisce a file di archivio compressi, come `.tar.gz` e `.tar.xz`.
