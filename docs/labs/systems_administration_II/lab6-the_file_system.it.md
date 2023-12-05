---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tested on: Tutte le versioni
tags:
  - lab exercise
  - file system
  - cli
  - Logical volume manager
  - lvm
---


# Laboratorio 6: Il File system

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di

- Partizionare un disco
- Utilizzare il sistema di gestione dei volumi logici (LVM)
- Creare nuovi file system
- Montare e utilizzare i file system

Tempo stimato per completare questo laboratorio: 90 minuti

## Panoramica delle applicazioni utili per il file system

Di seguito è riportato un riepilogo delle applicazioni più comuni utilizzate per gestire i file system.

### `sfdisk`

Utilizzato per visualizzare o manipolare le tabelle di partizione del disco

Synopsis:

    ```
    Usage:
    sfdisk [options] <dev> [[-N] <part>]
    sfdisk [options] <command>

    Commands:
    -A, --activate <dev> [<part> ...] list or set bootable (P)MBR partitions
    -d, --dump <dev>                  dump partition table (usable for later input)
    -J, --json <dev>                  dump partition table in JSON format
    -g, --show-geometry [<dev> ...]   list geometry of all or specified devices
    -l, --list [<dev> ...]            list partitions of each device
    -F, --list-free [<dev> ...]       list unpartitioned free areas of each device
    -r, --reorder <dev>               fix partitions order (by start offset)
    -s, --show-size [<dev> ...]       list sizes of all or specified devices
    -T, --list-types                  print the recognized types (see -X)
    -V, --verify [<dev> ...]          test whether partitions seem correct
        --delete <dev> [<part> ...]   delete all or specified partitions

    --part-label <dev> <part> [<str>] print or change partition label
    --part-type <dev> <part> [<type>] print or change partition type
    --part-uuid <dev> <part> [<uuid>] print or change partition uuid
    --part-attrs <dev> <part> [<str>] print or change partition attributes

    --disk-id <dev> [<str>]           print or change disk label ID (UUID)
    --relocate <oper> <dev>           move partition header
    ```

### `debugfs`

debugger del file system ext2/ext3/ext4

Synopsis:

    ```
     debugfs [-b blocksize] [-s superblock] [-f cmd_file] [-R request] [-d data_source_device] [-i] [-n] [-D] [-V] [[-w] [-z undo_file] [-c]] [device]
    ```

### `badblocks`

Ricerca di blocchi danneggiati su un dispositivo

Synopsis:

    ```
     badblocks  [ -svwnfBX ] [ -b block_size ] [ -c blocks_at_once ] [ -d read_delay_factor ] [ -e max_bad_blocks ] [ -i input_file ] [ -o output_file ] [ -p num_passes ] [
       -t test_pattern ] device [ last_block ] [ first_block ]
    ```

### `dosfsck`

Verificare la presenza di errori nel filesystem FAT del DISPOSITIVO.

Synopsis:

    ```
    Usage: dosfsck [OPTIONS] DEVICE
    Options:
    -a              automatically repair the filesystem
    -A              toggle Atari variant of the FAT filesystem
    -b              make read-only boot sector check
    -c N            use DOS codepage N to decode short file names (default: 850)
    -d PATH         drop file with name PATH (can be given multiple times)
    -f              salvage unused chains to files
    -F NUM          specify FAT table NUM used for filesystem access
    -l              list path names
    -n              no-op, check non-interactively without changing
    -p              same as -a, for compat with other *fsck
    -r              interactively repair the filesystem (default)
    -S              disallow spaces in the middle of short file names
    -t              test for bad clusters
    -u PATH         try to undelete (non-directory) file that was named PATH (can be
                      given multiple times)
    -U              allow only uppercase characters in volume and boot label
    -v              verbose mode
    -V              perform a verification pass
    --variant=TYPE  handle variant TYPE of the filesystem
    -w              write changes to disk immediately
    -y              same as -a, for compat with other *fsck
    --help          print this message
    ```

### `mkdosfs` o `mkfs.fat`

Utilizzato per creare file system MS-DOS (FAT12, FAT16 e FAT32) in Linux

Synopsis:

    ```
      Usage: mkdosfs [OPTIONS] TARGET [BLOCKS]

      Options:
        -a              Disable alignment of data structures
        -A              Toggle Atari variant of the filesystem
        -b SECTOR       Select SECTOR as location of the FAT32 backup boot sector
        -c              Check device for bad blocks before creating the filesystem
        -C              Create file TARGET then create filesystem in it
        -D NUMBER       Write BIOS drive number NUMBER to boot sector
        -f COUNT        Create COUNT file allocation tables
        -F SIZE         Select FAT size SIZE (12, 16 or 32)
        -g GEOM         Select disk geometry: heads/sectors_per_track
        -h NUMBER       Write hidden sectors NUMBER to boot sector
        -i VOLID        Set volume ID to VOLID (a 32 bit hexadecimal number)
        -I              Ignore and disable safety checks
        -l FILENAME     Read bad blocks list from FILENAME
        -m FILENAME     Replace default error message in boot block with contents of FILENAME
        -M TYPE         Set media type in boot sector to TYPE
        .........
    ```

### `dumpe2fs`

Elenca le informazioni sul superblocco e sul gruppo di blocchi del dispositivo elencato.

Synopsis:

    ```
    Usage: dumpe2fs [-bfghimxV] [-o superblock=<num>] [-o blocksize=<num>] device
    ```

### `fdisk`

Visualizzare e manipolare (aggiungere, rimuovere e modificare) le tabelle di partizione del disco

Synopsis:

    ```
    Usage:
    fdisk [options] <disk>         change partition table
    fdisk [options] -l [<disk>...] list partition table(s)
    Display or manipulate a disk partition table.

    Options:
    -b, --sector-size <size>      physical and logical sector size
    -B, --protect-boot            don't erase bootbits when creating a new label
    -c, --compatibility[=<mode>]  mode is 'dos' or 'nondos' (default)
    -L, --color[=<when>]          colorize output (auto, always or never) colors are enabled by default
    -l, --list                    display partitions and exit
    -x, --list-details            like --list but with more details
    -n, --noauto-pt               don't create default partition table on empty devices
    -o, --output <list>           output columns
    -t, --type <type>             recognize specified partition table type only
    -u, --units[=<unit>]          display units: 'cylinders' or 'sectors' (default)
    -s, --getsz                   display device size in 512-byte sectors [DEPRECATED]
     --bytes                   print SIZE in bytes rather than in human readable format
     --lock[=<mode>]           use exclusive device lock (yes, no or nonblock)
    -w, --wipe <mode>             wipe signatures (auto, always or never)
    -W, --wipe-partitions <mode>  wipe signatures from new partitions (auto, always or never)
    -C, --cylinders <number>      specify the number of cylinders
    -H, --heads <number>          specify the number of heads
    -S, --sectors <number>        specify the number of sectors per track
    ```

### `fsck`

Utilizzato per controllare e riparare i file system di Linux. In realtà è un wrapper per diverse altre utility specifiche per i file system (ad esempio fsck.ext3, fsck.ext2 e così via).

Synopsis:

    ```
    Usage:
        fsck [options] -- [fs-options] [<filesystem> ...]

        Check and repair a Linux filesystem.

    Options:
        -A         check all filesystems
        -C [<fd>]  display progress bar; file descriptor is for GUIs
        -l         lock the device to guarantee exclusive access
        -M         do not check mounted filesystems
        -N         do not execute, just show what would be done
        -P         check filesystems in parallel, including root
        -R         skip root filesystem; useful only with '-A'
        -r [<fd>]  report statistics for each device checked;
                    file descriptor is for GUIs
        -s         serialize the checking operations
        -T         do not show the title on startup
        -t <type>  specify filesystem types to be checked;
                    <type> is allowed to be a comma-separated list
        -V         explain what is being done
    ```

### `hdparm`

Utilizzato per ottenere o impostare i parametri del disco rigido

Synopsis:

    ```
    hdparm [options] [device]
    ```

### `tune2fs`

Utilizzato per regolare i parametri regolabili del file system su file system ext2/ext3/ext4. Il filesystem non deve essere montato in scrittura quando viene eseguita questa operazione.

Synopsis:

    ```
    Usage: tune2fs [-c max_mounts_count] [-e errors_behavior] [-f] [-g group]
        [-i interval[d|m|w]] [-j] [-J journal_options] [-l]
        [-m reserved_blocks_percent] [-o [^]mount_options[,...]]
        [-r reserved_blocks_count] [-u user] [-C mount_count]
        [-L volume_label] [-M last_mounted_dir]
        [-O [^]feature[,...]] [-Q quota_options]
        [-E extended-option[,...]] [-T last_check_time] [-U UUID]
        [-I new_inode_size] [-z undo_file] device
    ```

### `mkswap`

Crea un'area di swap Linux su un dispositivo

Synopsis:

    ```
    mkswap [-c] [-vN] [-f] [-p PSZ] device [size]
    ```

### `mkfs`

Creazione di file system Linux

Synopsis:

    ```
    mkfs [ -V ] [ -t fstype ] [ fs-options ] filesys [ blocks ]
    ```

### `parted`

Un programma di partizionamento e ridimensionamento del disco.

Synopsis:

    ```
    Parted [options] [device [command [options]]]
    ```

### `swapon` e `swapoff`

Abilitare/disabilitare i dispositivi e i file per il paging e lo swapping

Synopsis:

    ```
    swapon [-v] [-p priority] specialfile
    ```

### `mount`

Utilizzato per montare un filesystem.

Synopsis:

    ```
    Mount [-fnrsvw] [-o options [,...]] device | dir
    ```

## Esercizio 1

ESEGUIRE QUESTO ESERCIZIO SUL PROPRIO SISTEMA LOCALE

Creazione delle partizioni (`fdisk`, `mke2fs`, `fsck`, `tune2fs`)

In questo esercizio si creeranno partizioni aggiuntive sul disco rigido. Durante l'installazione iniziale è stato lasciato dello spazio libero. Su questo spazio verranno create delle partizioni.

Il partizionamento di un disco consente di considerarlo come un gruppo di aree di memorizzazione indipendenti.

Le partizioni facilitano inoltre i backup e aiutano a limitare e circoscrivere le aree potenzialmente problematiche.

Lo spazio sul disco rigido non è infinito e uno dei compiti dell'amministratore è gestire lo spazio limitato disponibile. Ad esempio, un modo semplice per limitare l'area di archiviazione totale su un disco in cui gli utenti possono memorizzare i propri file personali è quello di creare una partizione separata per la home directory degli utenti (naturalmente si possono usare anche le quote).

#### Per esplorare i dispositivi di archiviazione a blocchi

Si utilizzerà l'utilità `fdisk`

1. Mentre si è connessi come root, visualizzare la struttura attuale del disco. Digitare:

    ```bash
    [root@serverXY root]# fdisk -l

        Disk /dev/vda: 25 GiB, 26843545600 bytes, 52428800 sectors
        Units: sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes
        Disklabel type: dos
        Disk identifier: 0xb3053db5

        Device     Boot Start      End  Sectors Size Id Type
        /dev/vda1  *     2048 52428766 52426719  25G 83 Linux
    ```

2. Visualizzare le statistiche di utilizzo del disco. Digitare:

    ```bash
      [root@serverXY root]#  df -h
      Filesystem      Size  Used Avail Use% Mounted on
      devtmpfs        4.0M     0  4.0M   0% /dev
      tmpfs           479M   84K  479M   1% /dev/shm
      /dev/vda1        24G  8.5G   14G  39% /
      ...<SNIPPED>...
    ```

    Dall'output di esempio qui sopra, sotto la colonna Used, si può vedere che la partizione primaria ( /dev/vda1) su cui è montata la nostra directory root (/) è completamente occupata (100%).

    Naturalmente il risultato potrebbe essere diverso se si dispone di un disco di dimensioni diverse o se non si è seguito lo schema di partizionamento utilizzato durante l'installazione del sistema operativo.

#### Per creare un dispositivo di blocco [fake]

Non vogliamo che il disco rigido locale del sistema venga accidentalmente alterato e reso inutilizzabile, quindi completeremo i seguenti esercizi su uno pseudo-dispositivo che si comporta come un vero e proprio dispositivo a blocchi. Per farlo, si crea un file [sparse] di dimensioni adeguate e lo si associa a uno pseudo-dispositivo. Nei sistemi Linux, questi pseudo-dispositivi sono chiamati dispositivi di loop. Un dispositivo di loop è uno pseudo-dispositivo che consente di trattare [e accedere] a un normale file di dati come se fosse un dispositivo a blocchi.

(Questa fase è più o meno uguale alle decisioni da prendere per l'acquisto di dischi/storage per un server. Decisioni come - tipo, marca, dimensione, interfaccia, fattore di forma e così via)

1. Mentre si è ancora connessi al sistema come utente root, si utilizza l'utility losetup per creare un file di 10 GB. Digitare:

    ```bash
    [root@serverPR root]# truncate --size 10GiB /tmp/10G-fake-disk.img
    ```

2. Eseguire il comando `losetup` senza alcuna opzione per mostrare i dispositivi di loop attivi. Digitare:

    ```bash
    [root@serverPR root]# losetup
    ```

3. Eseguire nuovamente il comando `losetup` per visualizzare/trovare il primo dispositivo di loop inutilizzato. Digitare:

    ```bash
    [root@serverPR root]# losetup -f --nooverlap
    /dev/loop0
    ```

    Il primo dispositivo di loop utilizzabile o non utilizzato nell'output del nostro sistema di esempio è `/dev/loop0`.

4. Utilizzando il 10G-fake-disk.img come file di supporto, associate il file a un dispositivo di loop disponibile eseguendo:

    ```bash
    losetup -f --nooverlap --partscan /tmp/10G-fake-disk.img
    ```

5. Eseguire nuovamente il comando `losetup` per visualizzare i dispositivi di loop in uso. Digitare:

    ```bash
    [root@serverPR root]# losetup
    NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE              DIO LOG-SEC
    /dev/loop0         0      0         0  0 /tmp/10G-fake-disk.img   0     512
    ```

6. Usare l'utilità `sfdisk` per elencare tutte le partizioni sul nuovo dispositivo pseudo-blocco. Digitare:

    ```bash
    [root@localhost ~]# sfdisk -l /dev/loop0
    Disk /dev/loop0: 10 GiB, 10737418240 bytes, 20971520 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    ```

7. Ora usate `fdisk` per elencare tutte le partizioni sullo stesso dispositivo. Digitare:

    ```bash
    [root@localhost ~]# fdisk -l /dev/loop0
    Disk /dev/loop0: 10 GiB, 10737418240 bytes, 20971520 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    ```

#### Per creare le partizioni

1. Si creerà una nuova partizione utilizzando il programma `fdisk`. `fdisk` viene eseguito in modo interattivo, quindi vi verranno proposte molte domande e risposte per completare alcune operazioni specifiche.

    Iniziare fornendo il nome del dispositivo di blocco del loop come argomento al comando `fdisk`. Digitare:

    ```bash
    [root@localhost ~]# fdisk /dev/loop0

    Welcome to fdisk (util-linux 2.*).
    Changes will remain in memory only, until you decide to write them.
    Be careful before using the write command.

    Device does not contain a recognized partition table.
    Created a new DOS disklabel with disk identifier 0xe3aa91a1.

    Command (m for help):
    ```

2. Visualizzare il sistema di aiuto incorporato per `fdisk`, digitando `m` al prompt di `fdisk`.

    ```bash
    Command (m for help): m
    Help:

    DOS (MBR)
    a   toggle a bootable flag
    b   edit nested BSD disklabel
    c   toggle the dos compatibility flag

    Generic
    d   delete a partition
    F   list free unpartitioned space
    l   list known partition types
    n   add a new partition
    p   print the partition table
    t   change a partition type
    v   verify the partition table
    i   print information about a partition
    ...<SNIP>...
    ```

3. Dall'elenco della guida visualizzato, si può notare che l'opzione `n` è usata per aggiungere una nuova partizione. Digitare `n` al prompt:

    ```bash
    Command (m for help): n
    Partition type
    p   primary (0 primary, 0 extended, 4 free)
    e   extended (container for logical partitions)
    ```

4. Creare una partizione di tipo primario digitando `p`:

    ```bash
    Command (m for help): n
    Partition type
    p   primary (0 primary, 0 extended, 4 free)
    e   extended (container for logical partitions)
    Select (default p): p
    ```

5. Questa è la prima partizione primaria del dispositivo a blocchi. Impostare il numero della partizione su 1:

    ```bash
    Partition number (1-4, default 1): 1
    ```

6. Accettare il valore predefinito per il primo settore del dispositivo a blocchi premendo <kbd>INVIO</kbd>:

    ```bash
    First sector (2048-20971519, default 2048):
    ```

7. Accettare il valore predefinito per l'ultimo settore del dispositivo a blocchi premendo <kbd>INVIO</kbd>:

    ```bash
    Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-20971519, default 20971519):
    ```

8. Al prompt principale di `fdisk`, digitare `p` per stampare la tabella delle partizioni corrente del dispositivo a blocchi:

    ```bash
    Command (m for help): p
    Disk /dev/loop0: 10 GiB, 10737418240 bytes, 20971520 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xe3aa91a1

    Device       Boot Start      End  Sectors Size Id Type
    /dev/loop0p1       2048 20971519 20969472  10G 83 Linux
    ```

    La nuova partizione creata è quella su `/dev/loop0p1` di cui sopra. Si noterà che il tipo di partizione è "83".

9. Tutto sembra a posto. Scrivere tutte le modifiche alla tabella delle partizioni digitando il comando `w` di `fdisk`:

    ```bash
    Command (m for help): w
    ```

    Probabilmente verrà visualizzato un avviso di mancata rilettura della tabella delle partizioni.

    Il comando `w` di `fdisk` esce anche dal programma `fdisk` e riporta al prompt della shell.

10. In base al messaggio di avvertimento ricevuto dopo la scrittura della tabella delle partizioni sul disco nel passaggio precedente, a volte è necessario compiere ulteriori passi per sollecitare il kernel a riconoscere le nuove modifiche al disco rigido. A tale scopo, utilizzare il comando `partprobe`:

    ```bash
    [root@localhost ~]# partprobe
    ```

    !!! tip "Suggerimento"

     Quando si usa `fdisk`, il tipo di partizione predefinito per le nuove partizioni create è Linux (0x83). È possibile utilizzare il comando `fdisk` `t` per cambiare il tipo. Ad esempio, per cambiare il tipo di partizione in LVM (0x8e) si deve procedere come segue:
    
    Digitare `t` per cambiare il tipo di partizione:

        ```bash
        Comando (m per la guida): t
        ```


     Immettere quindi al prompt l'hexcode (0x8e) per le partizioni di tipo LVM:

        ```bash
        Codice esadecimale o alias (digitare L per elencarli tutti): 8e
        ```


     Scrivere tutte le modifiche nella tabella delle partizioni digitando il comando `w` `fdisk`:

        ```bash
        Comando (m per la guida): w
        ```

#### Per creare un volume fisico

Per dimostrare alcune delle sottili differenze tra il metodo tradizionale di gestione dei dispositivi a blocchi e gli approcci più moderni come quello del gestore di volumi, creeremo un nuovo dispositivo pseudo-blocco e cercheremo di prepararlo (in modo simile al partizionamento) per l'uso con un file system.

Nei passi successivi creeremo un nuovo dispositivo di loop appoggiato a un altro file regolare. Poi passeremo all'impostazione del dispositivo per il sistema Logical Volume Manager (LVM).

1. Mentre si è connessi come utente con privilegi di amministratore, creare un file limitato a 10 Gb chiamato `10G-fake-lvm-disk.img`. Digitare:

    ```bash
    [root@server root]# truncate --size 10GiB /tmp/10G-fake-lvm-disk.img
    ```

2. Eseguire il comando `losetup` per visualizzare/trovare il primo dispositivo di loop inutilizzato. Digitare:

    ```bash
    [root@serverPR root]# losetup -f --nooverlap
    ```

    Il primo dispositivo di loop utilizzabile o non utilizzato del nostro sistema di esempio è stato incrementato ed è ora /dev/loop1.

3. Utilizzando il 10G-fake-lvm-disk.img come file di supporto, associate il file a un dispositivo di loop disponibile eseguendo:

    ```bash
    [root@server root]# losetup -f --nooverlap --partscan /tmp/10G-fake-lvm-disk.img
    ```

4. Eseguire il comando `losetup` per mostrare i dispositivi di loop in uso. Digitare:

    ```bash
    [root@localhost ~]# losetup
    ```
    **RISULTATO**
    ```
    NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE                  DIO LOG-SEC
    /dev/loop1         0      0         0  0 /tmp/10G-fake-lvm-disk.img   0     512
    /dev/loop0         0      0         0  0 /tmp/10G-fake-disk.img       0     512
    ```

    Nel nostro output vediamo la mappatura di /dev/loop1 al file di supporto /tmp/10G-fake-lvm-disk.img. Perfetto.

5. Utilizzare il comando `pvdisplay` per visualizzare i volumi fisici attualmente definiti sul sistema. Digitare:

    ```bash
    [root@localhost ~]# pvdisplay
    --- Physical volume ---
    PV Name               /dev/vda3
    VG Name               rl
    PV Size               98.41 GiB / not usable 2.00 MiB
    ...<SNIP>...
    ```

2. Inizializzare il nuovo dispositivo a blocchi /dev/loop1 (10G-fake-lvm-disk.img) come volume fisico. Utilizzare l'utilità `pvcreate`. Digitare:

    ```bash
    [root@localhost ~]# pvcreate /dev/loop1
    Physical volume "/dev/loop1" successfully created.
    ```

3. Eseguire il comando `pvdisplay` per visualizzare le modifiche.

#### Per assegnare un volume fisico a un gruppo di volumi

In questa sezione verrà illustrato come assegnare un dispositivo PV a un gruppo di volumi esistente. Tale operazione consente di aumentare la capacità di archiviazione di un gruppo di volumi esistente.

Aggiungerete il volume fisico (PV) `/dev/loop1` che è stato preparato e creato in precedenza al gruppo di volumi (VG) esistente `rl`.

1. Usare il comando `vgdisplay` per visualizzare i gruppi di volumi attualmente configurati. Digitare:

    ```bash
    [root@localhost ~]# vgdisplay
    ```
    **RISULTATO**
    ```
    --- Volume group ---
    VG Name               rl
    System ID
    Format                lvm2
    ..........
    VG Size               98.41 GiB
    PE Size               4.00 MiB
    Total PE              25193
    Alloc PE / Size       25193 / 98.41 GiB
    Free  PE / Size       0 / 0
    ...<SNIP>...
    ```

    !!! note "Nota"

     Dall'output di cui sopra: 
    
     - The volume group name is rl 
     - The size of the VG is 98.41 GiB
     - There are 0 (zero) physical extents (PE) that are free in the VG, which is equivalent to 0MB of space.

2. Assegnare il nuovo PV (/dev/loop1) al gruppo di volumi `rl` esistente. Utilizzare il comando `vgextend`, digitando:

    ```bash
    [root@localhost ~]# vgextend rl /dev/loop1
    ```
    **RISULTATO**
    ```
    Volume group "rl" successfully extended
    ```

4. Eseguire nuovamente il comando `vgdisplay` per visualizzare le modifiche. Digitare:

    ```bash
    [root@localhost ~]# vgdisplay
    ```
    **RISULTATO**
    ```
    --- Volume group ---
    VG Name               rl
    System ID
    Format                lvm2
    Metadata Areas        2
    Metadata Sequence No  5
    .......
    VG Size               <108.41 GiB
    PE Size               4.00 MiB
    Total PE              27752
    Alloc PE / Size       25193 / 98.41 GiB
    Free  PE / Size       2559 / <10.00 GiB
    ...<SNIP>...
    ```

    !!! Question "Domanda"

     Utilizzando l'output di `vgdisplay`, annotare le modifiche apportate al sistema. Quali sono i nuovi valori di "Free PE / Size"?

#### Per rimuovere un LV, un VG e un PV

Questa sezione spiega come eliminare il PV `/dev/loop1` assegnato al VG `rl` presente nella sezione precedente.

1. Rimuovere il volume logico denominato scratch2. Digitare:

    ```bash
    [root@localhost ~]# lvremove -f  /dev/rl/scratch2
    Logical volume "scratch2" successfully removed.
    ```

2. Rimuovere il volume logico scratch3, eseguendo:

    ```bash
    [root@localhost ~]# lvremove -f  /dev/rl/scratch3
    ```

3. Dopo aver rimosso i volumi interessati, è possibile ridurre le dimensioni del VG `rl` per renderlo coerente. Digitate:

    ```bash
    [root@localhost ~]# vgreduce --removemissing  rl
    ```

4. Rimuovere le etichette LVM dal PV `/dev/loop1`. Digitare:

    ```bash
    [root@localhost ~]# pvremove /dev/loop1
    Labels on physical volume "/dev/loop1" successfully wiped.
    ```

#### Per creare un nuovo gruppo di volumi

In questa sezione verrà creato un nuovo gruppo di volumi autonomo denominato "scratch".  Lo scratch VG otterrà il suo spazio interamente dal dispositivo pseudo-blocco `/dev/loop1`.

1. Creare il nuovo spazio `scratch`. Digitare:

    ```bash
    [root@localhost ~]# vgcreate scratch /dev/loop1
    Physical volume "/dev/loop1" successfully created.
    Volume group "scratch" successfully created
    ```

2. Eseguire il comando `vgdisplay` per visualizzare le modifiche. Digitare:

    ```bash
    [root@localhost ~]# vgdisplay scratch
    --- Volume group ---
    VG Name               scratch
    System ID
    Format                lvm2
    Metadata Areas        1
    Metadata Sequence No  1
    .......
    VG Size               <10.00 GiB
    PE Size               4.00 MiB
    Total PE              2559
    Alloc PE / Size       0 / 0
    Free  PE / Size       2559 / <10.00 GiB
    VG UUID               nQZPfK-bo7E-vOSR***
    ...<SNIP>...
    ```

    !!! question "Domanda" 

     Esaminate l'output di `vgdisplay`. Quali sono i valori di "Free PE / Size"? E come sono diversi questi valori rispetto alla sezione precedente, quando si è aggiunto il PV `/dev/loop1` al gruppo di volumi `rl` esistente?

#### Per creare un volume logico

Con lo spazio libero aggiuntivo che è stato possibile aggiungere al gruppo di volumi (VG) rl, è ora possibile aggiungere un volume logico che può essere utilizzato per memorizzare i dati dopo la formattazione.

1. Utilizzare il comando `lvdisplay` per visualizzare i volumi logici attualmente configurati. Digitare:

    ```bash
    [root@localhost ~]# lvdisplay
    ```

    !!! question "Domanda"

     In base al risultato ottenuto, rispondete alle seguenti domande: 
    
     1. Quanti volumi logici (LV) sono definiti?
    
     2. Quali sono i nomi dei LV?
    
     3. A cosa servono i vari LV nel vostro sistema?


2. Utilizzare il comando `lvs` per visualizzare in modo simile i volumi logici, ma questa volta filtrando l'output per mostrare campi specifici. Filtrare per visualizzare i campi lv_name (nome del volume logico), lv_size (dimensione del volume logico), lv_path, vg_name (nome del gruppo di volumi). Digitare:

    ```bash
    [root@localhost ~]# lvs  -o lv_name,lv_size,lv_path,vg_name
    LV   LSize   Path         VG
    home <29.68g /dev/rl/home rl
    root <60.79g /dev/rl/root rl
    swap  <7.95g /dev/rl/swap rl
    ```

    !!! note "Nota"

     lv_name = nome del volume logico, lv_size = dimensione del volume logico, lv_path = percorso del volume logico, vg_name = nome del gruppo di volumi.

3. Sul nuovo VG `scratch`, creare un nuovo volume logico chiamato "scratch2" usando il comando `lvcreate`. Impostare la dimensione di `scratch2` a 2 GB. Digitare:

    ```bash
    [root@localhost ~]# lvcreate -L 2G --name scratch2 scratch
    Logical volume "scratch2" created.
    ```

4. Creare un secondo volume logico chiamato "scratch3". Questa volta verrà utilizzato tutto lo spazio rimanente disponibile nel gruppo di volumi `scratch`. Digitare:

    ```bash
    [root@localhost ~]# lvcreate -l 100%FREE --wipesignatures y --yes --zero y --name scratch3 scratch
    Logical volume "scratch3" created.
    ```

5. Utilizzare nuovamente il comando `lvdisplay` per visualizzare il nuovo LV.

## Esercizio 2

Per rendere la partizione tradizionale e i volumi in stile LVM creati in precedenza utilizzabili dal sistema operativo, è necessario che su di essi vengano creati dei file system. La scrittura di un file system su un dispositivo è nota anche come formattazione del disco.

Questo esercizio riguarda la creazione del file system e l'uso di alcuni strumenti comuni per la manutenzione del file system.

#### Per creare un file system VFAT

Qui si utilizzerà il programma `mke2fs` per creare un file system vFAT sulla nuova partizione /dev/loop0p1.

1. Usare l'utilità `mkfs.vfat` per creare un file system di tipo vfat sul volume `/dev/loop0p1`. Digitare:

    ```bash
    [root@localhost ~]# mkfs.vfat /dev/loop0p1
    ```
    **RISULTATO**
    ```
    mkfs.fat 4.*
    ```

2. Utilizzare il comando `lsblk` per interrogare il sistema e ottenere informazioni interessanti sul dispositivo a blocchi. Digitare:

    ```bash
    [root@localhost ~]# lsblk -f /dev/loop0
    ```
    **RISULTATO**
    ```
    NAME      FSTYPE LABEL UUID                 MOUNTPOINT
    loop0
    └─loop0p1 vfat         658D-4A90
    ```

#### Per creare un file system EXT4

Per rendere i volumi logici creati in precedenza utilizzabili dal sistema operativo, è necessario creare dei file system su di essi. La scrittura di un file system su un dispositivo è nota anche come formattazione del disco.

Qui si utilizzerà il programma `mke2fs` per creare un file system EXT4 sul nuovo volume scratch1.

1. Usare l'utilità `mkfs.ext4` per creare un filesystem di tipo EXT4 sul volume `/dev/scratch/scratch2`. Digitare:

    ```bash
    [root@localhost ~]# mkfs.ext4 /dev/scratch/scratch2
    ...<SNIP>...
    Writing superblocks and filesystem accounting information: done
    ```

2. Usare il comando `lsblk` per interrogare il sistema per ottenere informazioni pertinenti al volume scratch2. Digitare:

    ```bash
    [root@localhost ~]# lsblk -f /dev/scratch/scratch2
    NAME        FSTYPE LABEL UUID          MOUNTPOINT
    scratch-scratch2 ext4         6689b6aa****
    ```

#### Per creare un file system XFS

Qui si utilizzerà il programma `mke2fs` per creare un file system XFS sul nuovo volume scratch3.

1. Utilizzare l'utilità `mkfs.xfs` per creare un filesystem di tipo XFS sul volume `/dev/rl/scratch3`. Digitare:

    ```bash
    [root@localhost ~]# mkfs.xfs /dev/scratch/scratch3
    meta-data=/dev/scratch/scratch3  isize=512    agcount=4, agsize=524032 blks
    ...<SNIP>...
    Discarding blocks...Done.
    ```

2. Usare il comando `lsblk` per interrogare il sistema per ottenere informazioni pertinenti al volume scratch3. Digitare:

    ```bash
    [root@localhost ~]# lsblk -f /dev/scratch/scratch3
    ```
    **RISULTATO**
    ```
    NAME        FSTYPE LABEL UUID         MOUNTPOINT
    scratch-scratch3 xfs          1d1ac306***
    ```

#### Per utilizzare `dumpe2fs`, `tune2fs`, `lsblk` e `fsck`

In questa sede illustreremo l'uso di alcune utilità comuni del filesystem che possono essere utilizzate per la manutenzione del filesystem, la risoluzione di problemi del filesystem, il debug di problemi del filesystem, ecc.

1. Trova il valore dell'attuale "numero massimo di montaggi" sul volume scratch2. Digitare:

    ```bash
    [root@localhost ~]# dumpe2fs /dev/scratch/scratch2 | grep -i  "maximum mount count"
    dumpe2fs 1.4***
    Maximum mount count:      -1
    ```

    !!! question "Domanda"

     1. A cosa serve il "numero massimo di montaggi"?
     2. Qual è il valore del numero massimo di montaggi del volume `root` (/dev/rl/root)?

2. Regolare/impostare il valore del conteggio massimo di montaggi a zero per i controlli del filesystem sul volume `/dev/scratch/scratch2`. Utilizzare il comando `tune2fs`. Digitare:

    ```bash
    [root@localhost ~]# tune2fs -c 0 /dev/scratch/scratch2
    tune2fs 1.*.*
    Setting maximal mount count to -1
    ```

3. Usare il comando `fsck` per controllare il file system scratch2. Digitare:

    ```bash
    [root@localhost ~]# fsck -Cfp /dev/scratch/scratch2
    fsck from util-linux 2.*
    /dev/mapper/scratch-scratch2: 11/131072 files (0.0% non-contiguous), 26156/524288 blocks
    ```

4. Creare un'etichetta di volume per il nuovo volume EXT4 usando il programma `tune2fs`. Digitare:

    ```bash
    [root@localhost root]# tune2fs -L scratch2 /dev/scratch/scratch2
    ```

5. Utilizzare `lsblk` per visualizzare le informazioni su `/dev/scratch/scratch2`. Digitare:

    ```bash
    [root@localhost ~]# lsblk -o name,size,label /dev/scratch/scratch2
    NAME        SIZE LABEL    
    scratch-scratch2   2G scratch2
    ```

6. Controllare il file system XFS sul volume scratch3. Digitare:

    ```bash
    [root@localhost ~]# fsck -Cfp /dev/scratch/scratch3
    fsck from util-linux 2.*
    /usr/sbin/fsck.xfs: XFS file system.  
    ```

## Esercizio 3

Le esercitazioni precedenti hanno illustrato la preparazione di un dispositivo di blocco/storage da utilizzare in un sistema. Dopo aver eseguito tutte le operazioni di partizionamento, formattazione e così via, il passo finale per rendere il file system disponibile agli utenti per l'archiviazione dei dati è noto come montaggio.

Questo esercizio spiegherà come `montare` e `smontare` i file system creati nell'esercizio precedente.

### `mount`

Il comando `mount` è usato per collegare il filesystem creato su un dispositivo alla gerarchia dei file.

#### Per montare un file system VFAT

1. Accedere al sistema come utente con privilegi amministrativi.

2. Creare una cartella denominata `/mnt/10gb-scratch1-partition`. Questa cartella verrà utilizzata come punto di montaggio per il file system scratch1. Digitare:

    ```bash
    [root@localhost ~]# mkdir /mnt/10gb-scratch1-partition
    ```

3. Montare la partizione. Digitare:

    ```bash
    [root@localhost ~]# mount /dev/loop0p1  /mnt/10gb-scratch1-partition
    ```

4. Utilizzare il comando `mount` per visualizzare tutti i file system VFAT presenti nel sistema. Utilizzare grep per filtrare l'output per la parola `scratch`. Digitare:

    ```bash
    [root@localhost ~]# mount -t vfat | grep scratch
    ```

5. Utilizzare il comando `df` per visualizzare un rapporto sull'utilizzo dello spazio su disco del file system sul server. Digitare:

    ```bash
    [root@localhost ~]# df -ht vfat | grep scratch
    ```

6. Utilizzare l'opzione `--bind` con il comando `mount` per far sì che il file-system `/mnt/10gb-scratch1` appaia anche con un nome/percorso più semplice o più facile da usare, come `/mnt/scratch1`. Digitare:

    ```bash
    [root@localhost ~]# mount --bind /mnt/10gb-scratch1-partition /mnt/scratch1
    ```

7. Utilizzare nuovamente il comando `df` per visualizzare l'effetto del montaggio bind.

#### Per montare un file system EXT4

1. Creare una cartella denominata `/mnt/2gb-scratch2-volume`. Questa cartella verrà utilizzata come punto di montaggio per il volume scratch2. Digitare:

    ```bash
    [root@localhost ~]# mkdir /mnt/2gb-scratch2-volume
    ```

2. Montare la partizione. Digitare:

    ```bash
    [root@localhost ~]# mount /dev/scratch/scratch2  /mnt/2gb-scratch2-volume
    ```

3. Utilizzare il comando `mount` per visualizzare tutti i file system EXT4 presenti nel sistema. Digitare:

    ```bash
    [root@localhost ~]# mount -t ext4
    ```

4. Assicurarsi che il punto di montaggio abbia i permessi giusti per consentire a tutti gli utenti del sistema di scrivere sul volume montato, eseguendo:

    ```bash
    [root@localhost ~]# chmod 777 /mnt/2gb-scratch2-volume
    ```

5. Utilizzare il comando `df` per visualizzare un rapporto sull'utilizzo dello spazio su disco del file system sul server.

#### Per montare un file system XFS

1. Creare una cartella denominata `/mnt/8gb-scratch3-volume`. Questo sarà il punto di montaggio del file system scratch3. Digitare:

    ```bash
    [root@localhost ~]# mkdir /mnt/8gb-scratch3-volume
    ```

2. Montare la partizione. Digitare:

    ```bash
    [root@localhost ~]# mount /dev/scratch/scratch3  /mnt/8gb-scratch3-volume
    ```

3. Usare il comando `mount` per visualizzare tutti i file system XFS presenti sul sistema. Digitare:

    ```bash
    [root@localhost ~]# mount -t xfs | grep scratch
    ```

4. Utilizzare il comando `df` per visualizzare un rapporto sull'utilizzo dello spazio su disco del file system sul server.

#### Per rendere persistenti i montaggi del file system

1. Utilizzare il comando `cat` per esaminare il contenuto attuale del file `/etc/fstab`.

2. Prima di apportare qualsiasi modifica, eseguire il backup del file `/etc/fstab`. Digitare:

    ```bash
    [root@localhost ~]# cp /etc/fstab  /etc/fstab.copy
    ```

3. Utilizzando un editor di testo, aggiungete con cura le seguenti nuove voci nel file `/etc/fstab` per i 3 file system creati in precedenza.

    Le nuove voci sono:

    ```bash
    /dev/loop0p1           /mnt/10gb-scratch1-partition   auto   defaults,nofail  0  0
    /dev/scratch/scratch2  /mnt/2gb-scratch2-volume       ext4   defaults,nofail  0  0
    /dev/scratch/scratch3  /mnt/2gb-scratch3-volume        xfs   defaults,nofail  0  0
    ```

    Utilizzeremo il metodo BASH heredoc qui sotto per creare le voci. Digitare con attenzione:

    ```bash
    [root@localhost ~]# cat >> /etc/fstab << EOF
    /dev/loop0p1           /mnt/10gb-scratch1-partition   auto   defaults,nofail  0  0
    /dev/scratch/scratch2  /mnt/2gb-scratch2-volume       ext4   defaults,nofail  0  0
    /dev/scratch/scratch3  /mnt/8gb-scratch3-volume        xfs   defaults,nofail  0  0 
    EOF
    ```

4. Con i dischi o i dispositivi di archiviazione reali, i passaggi precedenti saranno sufficienti per far sì che il sistema monti automaticamente e correttamente tutti i nuovi file system e applichi eventuali opzioni di montaggio speciali.

    TUTTAVIA, poiché in questo laboratorio abbiamo utilizzato dispositivi speciali di pseudo-blocco (dispositivi di loop), dobbiamo completare un'ulteriore operazione importante per garantire che i dispositivi di loop corretti vengano ricreati automaticamente dopo il riavvio del sistema.

    A questo scopo creeremo un'unità di servizio systemd personalizzata.

    Per creare il file `/etc/systemd/system/loopdevices.service`, utilizzare un qualsiasi editor di testo con cui si abbia familiarità.

    Inserire il seguente testo nel file.

    ```bash
    [Unit]
    Description=Activate loop devices
    DefaultDependencies=no
    After=systemd-udev-settle.service
    Before=lvm2-activation.service
    Wants=systemd-udev-settle.service

    [Service]
    ExecStart=losetup -P /dev/loop0 /tmp/10G-fake-disk.img
    ExecStart=losetup -P /dev/loop1 /tmp/10G-fake-lvm-disk.img
    Type=oneshot

    [Install]
    WantedBy=local-fs.target
    ```

    Assicurarsi di salvare le modifiche apportate al file.

5. Utilizzare il comando `systemctl` per abilitare il nuovo servizio loopdevice. Digitare:

    ```bash
    [root@localhost ~]# systemctl enable loopdevices.service
    ```

6. Provare ad avviare il servizio per verificare che si avvii correttamente. Digitare:

    ```bash
    [root@localhost ~]# systemctl start loopdevices.service
    ```

    Se si avvia senza errori, si può passare alla fase successiva, in cui si effettuerà il vero test di riavvio del sistema.

7. Riavviare il sistema e verificare che tutto funzioni correttamente e che i nuovi file system siano stati montati automaticamente.

## Esercizio 4

**Premessa:**

Senza alcuna ragione, l'utente chiamato "unreasonable" ha deciso di creare un file estremamente GRANDE su un sistema condiviso con altri utenti!!

Il file ha occupato molto spazio sul disco rigido locale.

Come amministratore, potete trovare ed eliminare il file incriminato e continuare la vostra giornata sperando che si tratti di un caso isolato, OPPURE potete trovare ed eliminare il file per liberare spazio su disco ed elaborare un piano per evitare che si ripeta. Tenteremo quest'ultima soluzione nell'esercizio successivo.

Nel frattempo -
> L'utente unreasonable colpisce ancora!

#### Per creare il file di grandi dimensioni

**Eseguire questo esercizio dal sistema partner**

L'utente unreasonable si accorge accidentalmente che sul server sono stati resi disponibili nuovi file system ***scratch*** durante la notte. "È fantastico!", dice a se stesso.

Quindi procede a riempire il volume con un file di dimensioni arbitrarie.

1. Accedere al sistema come utente `unreasonable`.

2. Controllare il sistema per vedere se ci sono nuovi file system di cui si può abusare. Digitare:

    ```bash
    [unreasonable@localhost ~]$ df  -h
    ```

3. Procedere immediatamente a riempire di rifiuti il file system condiviso disponibile. Digitare

    ```bash
    [unreasonable@localhost ~]$ dd if=/dev/zero \
       of=/mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar bs=10240
    ```
    **OUTPUT**
    ```
    dd: error writing '/mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar': No space left on device
    187129+0 records in
    187128+0 records out
    1916194816 bytes (1.9 GB, 1.8 GiB) copied, 4.99021 s, 384 MB/s
    ```

4. Dopo aver avviato il processo `dd`, fate una passeggiata e tornate indietro quando il comando è stato completato o quando ha dato errore perché non può proseguire. Oppure andate a cercare l'amministratore per lamentarsi del fatto che lo spazio su disco del sistema è pieno.

5. Esplorare ulteriori cose irragionevoli/insensate/fastidiose che possono essere fatte sul sistema. Sei l'***utente unreasonable***.

## Esercizio 5

### Quotas

L'implementazione e l'applicazione delle quote del disco consentono di garantire che il sistema disponga di spazio su disco sufficiente e che gli utenti rimangano nei limiti dello spazio su disco loro assegnato. Prima di implementare le quote è necessario:

* Scegliere le partizioni o i volumi su cui implementare le quote disco.
* Decidere a quale livello applicare le quote, cioè per utente, per gruppo o per entrambi.
* Determinare quali saranno i vostri limiti soft e hard.
* Decidere quali saranno i periodi di tolleranza (cioè se ci saranno).

*Limite Hard*

Il limite hard definisce la quantità massima assoluta di spazio su disco che un utente o un gruppo può utilizzare. Una volta raggiunto questo limite, non è possibile utilizzare altro spazio su disco.

*Limite Soft*

Il limite soft definisce la quantità massima di spazio su disco che può essere utilizzata. Tuttavia, a differenza del limite hard, il limite soft può essere superato per un certo periodo di tempo. Questo periodo è noto come periodo di tolleranza.

*Periodo di tolleranza*

Il periodo di tolleranza è il periodo di tempo durante il quale è possibile superare il limite soft. Il periodo di tolleranza può essere espresso in secondi, minuti, ore, giorni, settimane o mesi, dando così all'amministratore del sistema una grande libertà nel determinare quanto tempo concedere agli utenti per far rientrare l'utilizzo del disco al di sotto del proprio soft limit.

Queste sono le fasi di alto livello dell'implementazione delle quote.

* Installazione del software per le quote
* Modificare il file "/etc/fstab"
* Rimontare i file system
* Eseguire quotacheck
* Assegnare le quote

I comandi da utilizzare sono:

`quotacheck`:

Utilità per controllare e riparare i file delle quote.

```bash
quotacheck [-gucbfinvdmMR] [-F <quota-format>] filesystem|-a

  -u, --user                check user files
  -g, --group               check group files
  -c, --create-files        create new quota files
  -b, --backup              create backups of old quota files
  -f, --force               force check even if quotas are enabled
  -i, --interactive         interactive mode
  -n, --use-first-dquot     use the first copy of duplicated structure
  -v, --verbose             print more information
  -d, --debug               print even more messages
  -m, --no-remount          do not remount filesystem read-only
  -M, --try-remount         try remounting filesystem read-only,
                            continue even if it fails
  -R, --exclude-root        exclude root when checking all filesystems
  -F, --format=formatname   check quota files of specific format
  -a, --all                 check all filesystems
```

`edquota`:

Strumento per modificare le quote utente

```bash
  SYNOPSIS
       edquota [ -p protoname ] [ -u | -g | -P ] [ -rm ] [ -F format-name ] [ -f filesystem ] username | groupname | projectname...

       edquota [ -u | -g | -P ] [ -F format-name ] [ -f filesystem ] -t

       edquota [ -u | -g | -P ] [ -F format-name ] [ -f filesystem ] -T username | groupname | projectname...
```

`repquota`:

Utilità per il reporting delle quote.

```bash
  Usage:
  repquota [-vugsi] [-c|C] [-t|n] [-F quotaformat] [-O (default | xml | csv)] (-a | mntpoint)

  -v, --verbose               display also users/groups without any usage
  -u, --user                  display information about users
  -g, --group                 display information about groups
  -P, --project               display information about projects
  -s, --human-readable        show numbers in human friendly units (MB, GB, ...)
  -t, --truncate-names        truncate names to 9 characters
  -p, --raw-grace             print grace time in seconds since epoch
  -n, --no-names              do not translate uid/gid to name
  -i, --no-autofs             avoid autofs mountpoints
  -c, --cache                 translate big number of ids at once
  -C, --no-cache              translate ids one by one
  -F, --format=formatname     report information for specific format
  -O, --output=format         format output as xml or csv
  -a, --all                   report information for all mount points with quotas
```

`quotaon` e `quotaoff`:

Strumenti utilizzati per attivare e disattivare le quote del filesystem

```bash
  SYNOPSIS
       quotaon [ -vugfp ] [ -F format-name ] filesystem...
       quotaon [ -avugPfp ] [ -F format-name ]

       quotaoff [ -vugPp ] [ -x state ] filesystem...
       quotaoff [ -avugp ]
```

#### Per installare il software delle quote

1.  Dopo aver effettuato il login come root, verificare innanzitutto se il pacchetto `quota-*.rpm` è installato sul sistema. Digitare:

    ```bash
    [root@localhost ~]# rpm -q quota
    quota-*
    ```

    !!! question "Domanda"

     Qual è stato il suo risultato?

2. Se il pacchetto quote non è installato sul sistema, usare `dnf` per installarlo.

#### Per impostare e configurare le quote

1. Si è deciso di implementare un sistema di quote in stile EXT4 sul volume "/dev/rl/scratch2". Si è inoltre deciso di implementare le quote sia a livello di utente che di gruppo.

2. Esaminare il file `/etc/fstab` con l'editor preferito. Di seguito è riportata la voce pertinente del file prima di apportare qualsiasi modifica al file.

    ```bash
    [root@localhost ~]# grep scratch2 /etc/fstab
    ```
    **OUTPUT**
    ```
    /dev/scratch/scratch2  /mnt/2gb-scratch2-volume    ext4     defaults  0  0
    ```

3. Eseguire un backup di `/etc/fstab`.

4. Per implementare le quote, è necessario aggiungere alla voce del volume scratch2 alcune nuove opzioni di montaggio relative alle quote. La voce del volume scratch2 deve essere aggiornata con la nuova riga riportata qui:

    ```bash
    /dev/scratch/scratch2  /mnt/2gb-scratch2-volume   ext4   defaults,usrquota,grpquota  0  0
    ```

    Si può utilizzare l'editor di testo preferito per effettuare la modifica o l'utilità `sed`, come mostrato nel passo successivo.

5. Utilizzare l'utilità `sed` per cercare la riga che si desidera modificare ed effettuare l'aggiornamento in loco. Digitare:

    ```bash
    [root@localhost ~]# sudo sed -i \
    '/^\/dev\/scratch\/scratch2/ s|.*|/dev/scratch/scratch2  /mnt/2gb-scratch2-volume   ext4   defaults,usrquota,grpquota  0  0|'\
    /etc/fstab
    ```

6. Utilizzate di nuovo `grep` per esaminare rapidamente il file e assicurarvi che sia stata apportata la modifica corretta in `/etc/fstab`.

7. Affinché le modifiche a `/etc/fstab` diventino effettive, è necessario eseguire alcune altre operazioni. Per prima cosa ricaricare systemd-daemon, eseguendo:

    ```bash
    [root@localhost ~]# systemctl daemon-reload
    ```

8. Successivamente, rimontare il file system corrispondente. Digitare:

    ```bash
    [root@localhost ~]# mount -o remount /mnt/2gb-scratch2-volume
    ```

9. Verificare che le nuove opzioni di montaggio siano state applicate controllando il file `/proc/mounts`. Digitare:

    ```bash
    [root@localhost ~]# cat /proc/mounts  | grep scratch2
    ```
    **OUTPUT**
    ```
    /dev/mapper/rl-scratch2 /mnt/2gb-scratch2-volume ext4 rw,relatime,quota,usrquota,grpquota 0 0
    ```

    !!! tip "Suggerimento"

     È inoltre possibile verificare le opzioni di montaggio in uso per qualsiasi file system utilizzando il comando `mount`. Per l'esempio precedente è possibile visualizzare le opzioni di montaggio per il volume scratch2 formattato in ext4 eseguendo:

        ```bash
        [root@localhost ~]# mount -t ext4 | grep scratch2
        ```


     **OUTPUT**
        ```
        /dev/mapper/scratch-scratch2 on /mnt/2gb-scratch2-volume type ext4   (rw,relatime,quota,usrquota,grpquota)
        ```

    !!! question "Domanda"

     Scrivete i comandi per `smontare` separatamente un dato filesystem e poi `montarlo` nuovamente?

11. Ora è necessario preparare il file system per supportare le quote. Creare i file delle quote e generare anche la tabella dell'utilizzo attuale del disco per file system. Digitare:

    ```bash
    [root@localhost ~]# quotacheck -avcug
    ```
    **OUTPUT**
    ```
    ....
    quotacheck: Scanning /dev/mapper/scratch-scratch2 [/mnt/2gb-scratch2-volume] done
    ...<SNIP>...
    quotacheck: Old file not found.
    quotacheck: Old file not found.  
    ```

    !!! question "Domanda"

     Dopo l'esecuzione del comando precedente si noteranno due nuovi file creati nella directory "/mnt/2gb-scratch2-volume". Elencare qui i file?


    !!! tip "Suggerimento"

     Per ottenere lo stato aggiornato delle quote del file system è necessario eseguire periodicamente il comando `quotacheck -avcug` con le quote disattivate sul file system.

12. Per abilitare le quote utente e di gruppo su tutti i file system specificati nel file "/etc/fstab" digitare:

    ```bash
    [root@localhost ~]# quotaon -av
    ```

#### Per assegnare le quote agli utenti

Avete deciso di assegnare un limite soft di 90 MB e un limite hard di 100 MB per ogni utente del sistema con un periodo di tolleranza di 5 minuti.

Ciò significa che tutti gli utenti per i quali applichiamo la quota non possono superare il limite hard di 100 MB, ma hanno circa 5 minuti per superare il loro limite soft di 90 MB, rimanendo comunque sotto il limite hard.

1. Si creeranno i limiti utilizzando un utente prototipo. L'utente chiamato "me" sarà il vostro utente prototipo. Utilizzare il comando `edquota` per creare i limiti. Digitare:

    ```bash
    [root@serverXY  root]# edquota -u me
    ```
    Il comando sopra riportato richiama l'editor predefinito con i contenuti sottostanti:

    ```bash
    Disk quotas for user me (uid 1001):
    Filesystem                   blocks       soft       hard     inodes     soft     hard
    /dev/mapper/scratch-scratch2           0          0          0          0        0        0
    ```

    Modificare il file di cui sopra (la terza riga) per riflettere i limiti desiderati. Modificare il file in modo che si legga:

    ```bash
    Disk quotas for user me (uid 1001):
    Filesystem                   blocks       soft       hard     inodes     soft     hard
    /dev/mapper/scratch-scratch2        0         90000      100000       0        0        0
    ```

    Salvare le modifiche al file e chiuderlo.

2. Il periodo di tolleranza viene creato utilizzando l'opzione `-t` con il comando `edquota`. Digitare:

    ```bash
    [root@serverXY  root]# edquota -t 
    ```

    Questo comando farà apparire l'editor predefinito con un contenuto simile a quello mostrato di seguito:

    ```bash
    Grace period before enforcing soft limits for users:
    Time units may be: days, hours, minutes, or seconds
    Filesystem             Block grace period     Inode grace period
    /dev/mapper/scratch-scratch2                  7days                  7days
    ```

    Modificare il file di cui sopra (la quarta riga) per applicare il periodo di tolleranza desiderato.

    Modificare il file in modo che si legga:

    ```bash
    Grace period before enforcing soft limits for users:
    Time units may be: days, hours, minutes, or seconds
    Filesystem             Block grace period     Inode grace period
    /dev/mapper/scratch-scratch1       5minutes                  7days
    ```

3. Quindi applicare le impostazioni configurate per il prototipo di utente "me" agli utenti "ying" e "unreasonable".  Digitare:

    ```bash
    [root@localhost ~]# edquota -p me -u ying unreasonable
    ```

4. Per ottenere un rapporto sullo stato di tutte le quote attivate, digitare:

    ```bash
    [root@localhost ~]# repquota /mnt/2gb-scratch2-volume
    ```
    **OUTPUT**
    ```
    *** Report for user quotas on device /dev/mapper/scratch-scratch2
    Block grace time: 00:05; Inode grace time: 7days
                          Block limits                File limits
    User            used    soft    hard  grace    used  soft  hard  grace
    ----------------------------------------------------------------------
    root      --      20       0       0              2     0     0
    unreasonable +- 1871288   90000  100000  00:04       1     0     0
    ```

    !!! Question "Domanda"

     Dall'output di cui sopra, sotto la colonna della tolleranza per l'utente `unreasonable`, quanto tempo di tolleranza rimane all'utente?

5. Dal rapporto, si nota che l'utente unreasonable ha superato i propri limiti di quota sul server. Cercate il file incriminato e aiutate l'utente unreasonable a "ripulirlo" e a rimetterlo in regola. Digitare:

    ```bash
    [root@localhost ~]# rm -rf /mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar
    ```

6. Utilizzare il comando `su` per assumere temporaneamente l'identità dell'utente `unreasonable` e provare a creare altri file o directory con quell'utente. Digitare:

    ```bash
    [root@localhost ~]# su - unreasonable
    ```

7. Mentre si è connessi come utente unreasonable, è possibile verificare che il file `/mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar` creato in un esercizio precedente è scomparso! Irritati, decidete di crearlo di nuovo. Digitare:

    ```bash
    [unreasonable@localhost ~]$ dd if=/dev/zero  of=/mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar bs=10240
    ```
    **OUTPUT**
    ```
    ...<SNIP>...
    dd: error writing '/mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar': Disk quota exceeded
    10001+0 records in
    10000+0 records out
    102400000 bytes (102 MB, 98 MiB) copied, 0.19433 s, 527 MB/s
    ```

    Hmmmm... interessante, borbottate.

8. Provare a creare una cartella chiamata test nella directory /mnt/2gb-scratch2-volume/. Una cartella vuota non deve occupare o utilizzare molto spazio su disco e quindi si digita:

    ```bash
    [unreasonable@localhost ~]$ mkdir /mnt/2gb-scratch2-volume/test
    mkdir: cannot create directory ‘/mnt/2gb-scratch2-volume/test’: Disk quota exceeded
    ```

9. Controllare la dimensione del file LARGE-USELESS-FILE.tar. Digitare:

    ```bash
    [unreasonable@localhost ~]$ ls -l /mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar
    -rw-rw-r-- 1 unreasonable unreasonable 102400000 Oct  5 19:37 /mnt/2gb-scratch2-volume/LARGE-USELESS-FILE.tar
    ```

    !!! Question "Domanda"

     Cos'è successo?

10. Frustrato dall'ignoranza come utente unreasonable digitare:

    ```bash
    [unreasonable@localhost ~]$ man quota
    ```

    !!! Note "Nota"

     L'utente "unreasonable" sarà costretto a fare qualcosa per il "LARGE-USELESS-FILE.tar" che ha creato.  Fino a quando l'utente non avrà ridotto la dimensione totale dei file al di sotto del suo limite, non sarà in grado di fare molto altro.

11. Fatto tutto con questo laboratorio sul file system di Linux.
