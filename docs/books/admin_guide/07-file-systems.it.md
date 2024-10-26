---
title: File system
author: Antoine Morvan
contributors: Steven Spencer, tianci li, Serge, Ganna Zhyrnova
tags:
  - file system
  - system administration
---

# File System

In questo capitolo si imparerà a lavorare con i file system.

---

**Obiettivi**: in questo capitolo i futuri amministratori Linux impareranno a:

:heavy_check_mark: gestire le partizioni su disco;  
:heavy_check_mark: utilizzare LVM per un migliore utilizzo delle risorse del disco;  
:heavy_check_mark: fornire agli utenti un filesystem e gestire i diritti di accesso.

e scoprire anche:

:heavy_check_mark: come è organizzata la struttura ad albero in Linux;  
:heavy_check_mark: i diversi tipi di file offerti e come lavorare con essi;

:checkered_flag: **hardware**, **disco**, **partizione**, **lvm**, **linux**

**Conoscenza**: :star: :star:  
**Complessità**: :star: :star:

**Tempo di lettura**: 20 minuti

---

## Partizionamento

Il partizionamento consente l'installazione di diversi sistemi operativi, poiché non è possibile che coabitino sulla stessa unità logica. Permette inoltre di separare i dati dal punto di vista logico (sicurezza, ottimizzazione degli accessi, ecc.).

La tabella delle partizioni, memorizzata nel primo settore del disco (MBR: *Master Boot Record*), registra la divisione del disco fisico in volumi partizionati.

Per i formati di tabelle di partizione **MBR**, lo stesso disco fisico può essere suddiviso in un massimo di 4 partizioni:

- *Partizione primaria* (o partizione principale)
- *Partizione estesa*

!!! Warning "Attenzione"

    Ci può essere solo una partizione estesa per disco fisico. Cioè, un disco fisico può avere nella tabella delle partizioni MBR fino a:

    1. Tre partizioni primarie più una partizione estesa
    2. Quattro partizioni primarie

    La partizione estesa non può scrivere dati ne essere formattata e può contenere solo partizioni logiche. Il disco fisico più grande che la tabella di partizione MBR può riconoscere è di **2TB**.

![Suddivisione in sole 4 partizioni primarie](images/07-file-systems-001.png)

![Suddivisione in 3 partizioni primarie e una estesa](images/07-file-systems-002.png)

### Convenzioni di denominazione per i nomi dei file del dispositivo

Nel mondo di GNU/Linux, tutto è un file. Per i dischi, vengono riconosciuti dal sistema come:

| Hardware                   | Nome del file del dispositivo |
| -------------------------- | ----------------------------- |
| Disco rigido IDE           | /dev/hd[a-d]                  |
| Disco rigido SCSI/SATA/USB | /dev/sd[a-z]                  |
| Unità ottica               | /dev/cdrom or /dev/sr0        |
| Floppy disk                | /dev/fd[0-7]                  |
| Stampante (25 pin)         | /dev/lp[0-2...]               |
| Stampante (USB)            | /dev/usb/lp[0-15]             |
| Mouse                      | /dev/mouse                    |
| Disco rigido virtuale      | /dev/vd[a-z]                  |

Il kernel Linux contiene i driver per la maggior parte dei dispositivi hardware.

Quelli che chiamiamo *dispositivi* sono i file memorizzati senza `/dev`, che identificano i diversi hardware rilevati dalla scheda madre.

Il servizio udev è responsabile dell'applicazione delle convenzioni di denominazione (regole) e della loro applicazione ai dispositivi rilevati.

Per ulteriori informazioni, vedere [qui](https://www.kernel.org/doc/html/latest/admin-guide/devices.html).

### Numero di partizione del dispositivo

Il numero dopo il dispositivo di blocco (dispositivo di memorizzazione) indica una partizione. Per le tabelle di partizione MBR, il numero 5 deve essere la prima partizione logica.

!!! Warning "Attenzione"

    Attenzione prego! Il numero di partizione citato si riferisce principalmente al numero di partizione del dispositivo a blocchi (dispositivo di archiviazione).

![Identificazione delle partizioni](images/07-file-systems-003.png)

Esistono almeno due comandi per il partizionamento di un disco: `fdisk` e `cfdisk`. Entrambi i comandi hanno un menu interattivo. `cfdisk` è più affidabile e meglio ottimizzato, quindi è il migliore da usare.

L'unica ragione per usare `fdisk` è quando si vogliono elencare tutti i dispositivi logici con l'opzione `-l`. `fdisk` utilizza tabelle di partizione MBR, pertanto non è supportato per le tabelle di partizione **GPT** e non può essere usato per dischi di dimensioni superiori a **2 TB**.

```bash
sudo fdisk -l
sudo fdisk -l /dev/sdc
sudo fdisk -l /dev/sdc2
```

### comando `parted`

Il comando `parted` (*partition editor*) è in grado di partizionare un disco senza gli inconvenienti di `fdisk`.

Il comando `parted` può essere usato sia dalla riga di comando che in modo interattivo. Dispone inoltre di una funzione di recupero in grado di riscrivere una tabella di partizione cancellata.

```bash
parted [-l] [device]
```

Sotto l'interfaccia grafica, c'è l'interfaccia completa di `gparted`: *Gnome* *PARtition* *EDitor*.

Il comando `gparted -l` elenca tutti i dispositivi logici di un computer.

Il comando `gparted`, se eseguito senza argomenti, mostrerà una modalità interattiva con le sue opzioni interne:

- `help` o un comando errato visualizzerà queste opzioni.
- `print all` in questa modalità avrà lo stesso risultato di `gparted -l` dalla riga di comando.
- `quit` per tornare al prompt.

### comando `cfdisk`

Il comando `cfdisk` viene utilizzato per gestire le partizioni.

```bash
cfdisk device
```

Esempio:

```bash
$ sudo cfdisk /dev/sda
                                 Disk: /dev/sda
               Size: 16 GiB, 17179869184 bytes, 33554432 sectors
                       Label: dos, identifier: 0xcf173747
    Device        Boot       Start        End    Sectors   Size   Id Type
>>  /dev/sda1     *           2048    2099199    2097152     1G   83 Linux
    /dev/sda2              2099200   33554431   31455232    15G   8e Linux LVM
 lqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk
 x Partition type: Linux (83)                                                 x
 x     Attributes: 80                                                         x
 xFilesystem UUID: 54a1f5a7-b8fa-4747-a87c-2dd635914d60                       x
 x     Filesystem: xfs                                                        x
 x     Mountpoint: /boot (mounted)                                            x
 mqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj
     [Bootable]  [ Delete ]  [ Resize ]  [  Quit  ]  [  Type  ]  [  Help  ]
     [  Write ]  [  Dump  ]
```

La preparazione, senza *LVM*, dei supporti fisici avviene in cinque fasi:

- Impostazione del disco fisico;
- Partizionamento dei volumi (divisione del disco, possibilità di installare più sistemi, ...);
- Creazione dei file system (permette al sistema operativo di gestire i file, la struttura ad albero, i diritti, ...);
- Montaggio dei file system (registrazione del file system nella struttura ad albero);
- Gestire l'accesso degli utenti.

## Gestore di volumi logici (LVM)

**L**ogical **V**olume **M**anager (*LVM]*)

La partizione creata dalla **partizione standard** non può regolare dinamicamente le risorse del disco rigido; una volta montata la partizione, la capacità è completamente fissa, questo vincolo è inaccettabile per il server. Anche se la partizione standard può essere espansa o ridotta forzatamente con alcuni accorgimenti tecnici, ciò può causare facilmente la perdita di dati. LVM può risolvere questo problema molto bene. LVM è disponibile in Linux dalla versione 2.4 del kernel e le sue caratteristiche principali sono:

- Capacità del disco più flessibile;
- Movimento di dati online;
- Dischi in modalità *stripe*;
- Volumi Mirrored (ricopiati);
- Istantanee del volume*(snapshot*).

Il principio di LVM è molto semplice:

- tra il disco fisico (o la partizione del disco) e il file system viene aggiunto un livello di astrazione logica
- unire più dischi (o partizioni di dischi) in un Gruppo di Volumi**(VG**)
- eseguire le operazioni di gestione del disco su di essi attraverso una funzionalità chiamata Logical Volume**(LV**).

**Il supporto fisico**: Il supporto di memorizzazione di LVM può essere l'intero disco rigido, una partizione del disco o un array RAID. Il dispositivo deve essere convertito, o inizializzato, in LVM Physical Volume (**PV**), prima di poter eseguire ulteriori operazioni.

**PV (Physical Volume)** è il blocco logico di archiviazione di base di LVM. È possibile creare un volume fisico utilizzando una partizione del disco o il disco stesso.

**VG (Volume Group)**: Simile ai dischi fisici di una partizione standard, un VG è costituito da uno o più PV.

**LV (Logical Volume)**: Simile alle partizioni del disco rigido nelle partizioni standard, il LV è costruito sopra il VG. È possibile impostare un file system su LV.

<b><font color="blue">PE</font></b>: L'unità di memoria più piccola che può essere allocata in un volume fisico, per impostazione predefinita <b>4MB</b>. È possibile specificare una dimensione aggiuntiva.

<b><font color="blue">LE</font></b>: La più piccola unità di memoria che può essere allocata in un Logical Volume. Nello stesso VG, PE e LE sono uguali e corrispondono uno a uno.

![Gruppo di volumi, dimensione PE pari a 4MB](images/07-file-systems-004.png)

Lo svantaggio è che se uno dei volumi fisici va fuori servizio, tutti i volumi logici che utilizzano questo volume fisico vanno persi. È necessario utilizzare LVM sui dischi raid.

!!! note "Nota"

    LVM è gestito solo dal sistema operativo. Pertanto il *BIOS* ha bisogno di almeno una partizione senza LVM per l'avvio.

!!! info "Informazione"

    Nel disco fisico, l'unità di memorizzazione più piccola è il **settore**, nel file system, l'unità di memorizzazione più piccola di GNU/Linux è il **blocco**, che è chiamato **cluster** nel sistema operativo Windows. In RAID, l'unità di memorizzazione più piccola si chiama **chunk**.

### Il Meccanismo di Scrittura di LVM

Per l'archiviazione dei dati in **LV** esistono diversi meccanismi di memorizzazione, due dei quali sono:

- Volumi lineari;
- Volumi in modalità *stripe*;
- Volumi Mirrored.

![Volumi lineari](images/07-file-systems-005.png)

![Volumi in modalità stripe](images/07-file-systems-006.png)

### Comandi LVM per la gestione dei volumi

I principali comandi rilevanti sono i seguenti:

|        Elemento         |    PV     |    VG     |    LV     |
|:-----------------------:|:---------:|:---------:|:---------:|
|          scan           |  pvscan   |  vgscan   |  lvscan   |
|         create          | pvcreate  | vgcreate  | lvcreate  |
|         display         | pvdisplay | vgdisplay | lvdisplay |
|         remove          | pvremove  | vgremove  | lvremove  |
|         extend          |           | vgextend  | lvextend  |
|         reduce          |           | vgreduce  | lvreduce  |
| informazioni sintetiche |    pvs    |    vgs    |    lvs    |

#### comando `pvcreate`

Il comando `pvcreate` viene utilizzato per creare volumi fisici. Trasforma le partizioni (o i dischi) di Linux in volumi fisici.

```bash
pvcreate [-opzioni] partizione
```

Esempio:

```bash
[root]# pvcreate /dev/hdb1
pvcreate -- physical volume « /dev/hdb1 » successfully created
```

È anche possibile utilizzare un disco intero (il che facilita l'aumento delle dimensioni del disco in ambienti virtuali, ad esempio).

```bash
[root]# pvcreate /dev/hdb
pvcreate -- physical volume « /dev/hdb » successfully created

# It can also be written in other ways, such as
[root]# pvcreate /dev/sd{b,c,d}1
[root]# pvcreate /dev/sd[b-d]1
```

| Opzione | Descrizione                                                                                        |
| ------- | -------------------------------------------------------------------------------------------------- |
| `-f`    | Forza la creazione del volume (disco già trasformato in volume fisico). Usare con estrema cautela. |

#### comando `vgcreate`

Il comando `vgcreate` crea gruppi di volumi. Raggruppa uno o più volumi fisici in un gruppo di volumi.

```bash
vgcreate <VG_name> <PV_name...> [opzione]
```

Esempio:

```bash
[root]# vgcreate volume1 /dev/hdb1
…
vgcreate – volume group « volume1 » successfully created and activated

[root]# vgcreate vg01 /dev/sd{b,c,d}1
[root]# vgcreate vg02 /dev/sd[b-d]1
```

#### comando `lvcreate`

Il comando `lvcreate` crea volumi logici. Il file system viene quindi creato su questi volumi logici.

```bash
lvcreate -L size [-n name] VG_name
```

Esempio:

```bash
[root]# lvcreate –L 600M –n VolLog1 volume1
lvcreate -- logical volume « /dev/volume1/VolLog1 » successfully created
```

| Opzione     | Descrizione                                                                                                                                |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `-L size`   | Imposta la dimensione del volume logico in K, M o G.                                                                                       |
| `-n name`   | Imposta il nome del LV. Con questo nome è stato creato un file speciale in `/dev/name_volume`.                                             |
| `-l numero` | Imposta la percentuale della capacità del disco rigido da utilizzare. È possibile utilizzare anche il numero di PE. Un PE equivale a 4 MB. |

!!! info "Informazione"

    Dopo aver creato un volume logico con il comando `lvcreate`, la regola di denominazione del sistema operativo è - `/dev/VG_name/LV_name`, questo tipo di file è un soft link (altrimenti noto come link simbolico). Il file di collegamento punta a file come `/dev/dm-0` e `/dev/dm-1`.

### Comandi LVM per visualizzare le informazioni sui volumi

#### comando `pvdisplay`

Il comando `pvdisplay` consente di visualizzare le informazioni sui volumi fisici.

```bash
pvdisplay /dev/PV_name
```

Esempio:

```bash
[root]# pvdisplay /dev/PV_name
```

#### comando `vgdisplay`

Il comando `vgdisplay` consente di visualizzare le informazioni sui gruppi di volumi.

```bash
vgdisplay VG_name
```

Esempio:

```bash
[root]# vgdisplay volume1
```

#### comando `lvdisplay`

Il comando `lvdisplay` consente di visualizzare le informazioni sui volumi logici.

```bash
lvdisplay /dev/VG_name/LV_name
```

Esempio:

```bash
[root]# lvdisplay /dev/volume1/VolLog1
```

### Preparazione dei supporti fisici

La preparazione con LVM del supporto fisico si articola come segue:

- Impostazione del disco fisico
- Partizione dei volumi
- **Volume fisico LVM**
- **Gruppi di volumi LVM**
- **Volumi logici LVM**
- Creazione di file system
- Montaggio dei file system
- Gestire l'accesso degli utenti

## Struttura di un file system

Un *file system* **FS** è responsabile delle seguenti azioni:

- Protezione dei diritti di accesso e modifica dei file;
- Manipolazione dei file: creazione, lettura, modifica e cancellazione;
- Individuazione dei file sul disco;
- Gestione dello spazio della partizione.

Il sistema operativo Linux è in grado di utilizzare diversi file system (ext2, ext3, ext4, FAT16, FAT32, NTFS, HFS, BtrFS, JFS, XFS, ...).

### comando `mkfs`

Il comando `mkfs`(make file system) consente di creare un file system Linux.

```bash
mkfs [-t fstype] filesys
```

Esempio:

```bash
[root]# mkfs -t ext4 /dev/sda1
```

| Opzione | Descrizione                                  |
| ------- | -------------------------------------------- |
| `-t`    | Indica il tipo di file system da utilizzare. |

!!! Warning "Attenzione"

    Senza un file system non è possibile utilizzare lo spazio su disco.

Ogni file system ha una struttura identica su ogni partizione. Il sistema inizializza un **Boot Sector** e un **Super block**, quindi l'amministratore inizializza una **tabella Inode** e un **Data block**.

!!! Note "Nota"

    L'unica eccezione è la partizione **swap**.

### Boot sector

Il settore di avvio è il primo settore del supporto di memorizzazione avviabile, ovvero cilindro 0, traccia 0, settore 1 (1 settore equivale a 512 byte). Si compone di tre parti:

1. MBR (master boot record): 446 byte.
2. DPT (tabella di partizione del disco): 64 byte.
3. BRID (boot record ID): 2 byte.

| Elemento | Descrizione                                                                                                                                                                                                       |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MBR      | Memorizza il "boot loader" (o "GRUB"); carica il kernel, passa i parametri; fornisce un'interfaccia di menu all'avvio; si trasferisce a un altro loader, ad esempio quando sono installati più sistemi operativi. |
| DPT      | Registra lo stato della partizione dell'intero disco.                                                                                                                                                             |
| BRID     | Determina se il dispositivo è utilizzabile per l'avvio.                                                                                                                                                           |

### Super block

La dimensione della tabella del **Super block** è definita al momento della creazione. È presente in ogni partizione e contiene gli elementi necessari per il suo utilizzo.

Descrive il File System:

- Nome del Volume Logico;
- Nome del File System;
- Tipo di File System;
- Stato del File System;
- Dimensione del File System;
- Numero di blocchi liberi;
- Puntatore all'inizio dell'elenco dei blocchi liberi;
- Dimensione dell'elenco di inode;
- Numero ed elenco degli inode liberi.

Dopo l'inizializzazione del sistema, una copia viene caricata nella memoria centrale. Questa copia viene aggiornata non appena viene modificata e il sistema la salva periodicamente (comando `sync`).

Quando il sistema si arresta, copia questa tabella in memoria nel suo blocco.

### Tabella degli inode

La dimensione della **tabella degli inode** è definita al momento della sua creazione ed è memorizzata nella partizione. È costituito da record, chiamati inode, corrispondenti ai file creati. Ogni record contiene gli indirizzi dei blocchi di dati che compongono il file.

!!! Note "Nota"

    Il numero di inode è unico all'interno di un file system.

Dopo l'inizializzazione del sistema, una copia viene caricata nella memoria centrale. Questa copia viene aggiornata non appena viene modificata e il sistema la salva periodicamente (comando `sync`).

Quando il sistema si arresta, copia questa tabella in memoria nel suo blocco.

Un file è gestito dal suo numero di inode.

!!! Note "Nota"

    La dimensione della tabella degli inode determina il numero massimo di file che il FS può contenere.

Informazioni presenti nella *tabella degli inode*:

- Numero di inode;
- Tipo di file e autorizzazioni di accesso;
- Numero di identificazione del proprietario;
- Numero di identificazione del gruppo proprietario;
- Numero di collegamenti in questo file;
- Dimensione del file in byte;
- Data dell'ultimo accesso al file;
- Data dell'ultima modifica del file;
- Data dell'ultima modifica dell'inode (= creazione);
- Tabella di diversi puntatori (tabella dei blocchi) ai blocchi logici contenenti i pezzi del file.

### Data block

La sua dimensione corrisponde al resto dello spazio disponibile della partizione. Quest'area contiene i cataloghi corrispondenti a ciascuna directory e i blocchi di dati corrispondenti al contenuto del file.

**Per garantire la coerenza del file system**, un'immagine del superblocco e della tabella degli inode viene caricata in memoria (RAM) al momento del caricamento del sistema operativo, in modo che tutte le operazioni di I/O vengano effettuate attraverso queste tabelle di sistema. Quando l'utente crea o modifica i file, questa immagine di memoria viene aggiornata per prima. Il sistema operativo deve quindi aggiornare regolarmente il superblocco del disco logico`(` comando`sync` ).

Queste tabelle vengono scritte sul disco rigido quando il sistema viene spento.

!!! danger "Attenzione"

    In caso di arresto improvviso, il file system potrebbe perdere la sua consistenza e causare la perdita di dati.

### Riparazione del file system

È possibile verificare la consistenza di un file system con il comando `fsck`.

In caso di errori, vengono proposte soluzioni per riparare le incongruenze. Dopo la riparazione, i file che rimangono senza voci nella tabella degli inode vengono inseriti nella cartella `/lost+found` dell'unità logica.

#### comando `fsck`

Il comando `fsck` è uno strumento di controllo e riparazione dell'integrità in modalità console per i file system di Linux.

```bash
fsck [-sACVRTNP] [ -t fstype ] filesys
```

Esempio:

```bash
[root]# fsck /dev/sda1
```

Per controllare la partizione root, è possibile creare un file `forcefsck` e riavviare o eseguire `shutdown` con l'opzione `-F`.

```bash
[root]# touch /forcefsck
[root]# reboot
or
[root]# shutdown –r -F now
```

!!! Warning "Attenzione"

    La partizione da controllare deve essere smontata.

## Organizzazione di un file system

Per definizione, un file system è una struttura ad albero di directory costruita a partire da una directory principale (un dispositivo logico può contenere un solo file system).

![Organizzazione di un file system](images/07-file-systems-008.png)

!!! Note "Nota"

    In Linux, ogni cosa è un file.

Documento di testo, directory, binario, partizione, risorsa di rete, schermo, tastiera, kernel Unix, programma utente, ...

Linux rispetta lo standard **FHS** (*Filesystems Hierarchy Standard*) (vedere `man hier`), che definisce i nomi e i ruoli delle cartelle.

| Directory  | Funzionalità                                                                                                                 | Parola completa                         |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| `/`        | Contiene directory speciali                                                                                                  |                                         |
| `/boot`    | File relativi all'avvio del sistema                                                                                          |                                         |
| `/sbin`    | Comandi necessari per l'avvio e la riparazione del sistema                                                                   | *binari di sistema*                     |
| `/bin`     | Eseguibili dei comandi di base del sistema                                                                                   | *binari*                                |
| `/usr/bin` | Comandi di amministrazione del sistema                                                                                       |                                         |
| `/lib`     | Librerie condivise e moduli del kernel                                                                                       | *librerie*                              |
| `/usr`     | Conserva le risorse di dati relative a UNIX                                                                                  | *Risorse di sistema UNIX*               |
| `/mnt`     | Directory del mount point temporaneo                                                                                         | *mount*                                 |
| `/media`   | Per il montaggio di supporti rimovibili                                                                                      |                                         |
| `/misc`    | Per montare la directory condivisa del servizio NFS.                                                                         |                                         |
| `/root`    | Directory di accesso dell'amministratore                                                                                     |                                         |
| `/home`    | La directory di livello superiore della home directory di un utente comune                                                   |                                         |
| `/tmp`     | La directory contenente i file temporanei                                                                                    | *temporanei*                            |
| `/dev`     | File speciali del dispositivo                                                                                                | *dispositivo*                           |
| `/etc`     | File di configurazione e scripts                                                                                             | *configurazione del testo modificabile* |
| `/opt`     | Specifico per le applicazioni installate                                                                                     | *opzionale*                             |
| `/proc`    | Si tratta di un punto di montaggio per il filesystem proc, che fornisce informazioni sui processi in esecuzione e sul kernel | *processi*                              |
| `/var`     | Questa directory contiene file che possono cambiare di dimensione, come i file di spool e di log                             | *variabili*                             |
| `/sys`     | File system virtuale, simile a /proc                                                                                         |                                         |
| `/run`     | Questo è /var/run                                                                                                            |                                         |
| `/srv`     | Service Data Directory                                                                                                       | *servizio*                              |

- Per montare o smontare a livello di albero, non bisogna trovarsi sotto il suo punto di montaggio.
- Il montaggio su una directory non vuota non cancella il contenuto. È solo nascosta.
- Solo l'amministratore può eseguire il montaggio.
- I punti di montaggio montati automaticamente all'avvio devono essere inseriti in `/etc/fstab`.

### file `/etc/fstab`

Il file `/etc/fstab` viene letto all'avvio del sistema e contiene i montaggi da eseguire. Ogni file system da montare è descritto su una singola riga, con i campi separati da spazi o tabulazioni.

!!! Note "Nota"

    Le righe vengono lette in sequenza (`fsck`, `mount`, `umount`).

```bash
/dev/mapper/VolGroup-lv_root   /         ext4    defaults        1   1
UUID=46….92                    /boot     ext4    defaults        1   2
/dev/mapper/VolGroup-lv_swap   swap      swap    defaults        0   0
tmpfs                          /dev/shm  tmpfs   defaults        0   0
devpts                         /dev/pts  devpts  gid=5,mode=620  0   0
sysfs                          /sys      sysfs   defaults        0   0
proc                           /proc     proc    defaults        0   0
  1                              2         3        4            5   6
```

| Colonna | Descrizione                                                                                                                                                                                                                                  |
| ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1       | Dispositivo del file system`(/dev/sda1`, UUID=..., ...)                                                                                                                                                                                      |
| 2       | Nome del punto di montaggio, **percorso assoluto** (eccetto **swap**)                                                                                                                                                                        |
| 3       | Tipo di filesystem (ext4, swap, ...)                                                                                                                                                                                                         |
| 4       | Opzioni speciali per il montaggio (`default`, `ro`, ...)                                                                                                                                                                                     |
| 5       | Abilita o disabilita la gestione dei backup (0:non eseguiti, 1:eseguiti). Per il backup viene utilizzato il comando `dump`. Questa funzione obsoleta è stata inizialmente progettata per eseguire il backup di vecchi file system su nastro. |
| 6       | Ordine di controllo quando si controlla lo SF con il comando `fsck` (0:nessun controllo, 1:priorità, 2:non priorità)                                                                                                                         |

Il comando `mount -a` consente di eseguire il montaggio automatico in base al contenuto del file di configurazione `/etc/fstab`. Le informazioni sul montaggio vengono quindi scritte in `/etc/mtab`.

!!! Warning "Attenzione"

    Solo i punti di montaggio elencati in `/etc/fstab` saranno montati al riavvio. In generale, si sconsiglia di scrivere i dischi flash USB e i dischi rigidi rimovibili nel file `/etc/fstab` perché quando il dispositivo esterno viene scollegato e riavviato, il sistema segnala che il dispositivo non può essere trovato, con conseguente mancato avvio. Quindi cosa dovrei fare? Montaggio temporaneo, ad esempio:

    ```bash
    Shell > mkdir /mnt/usb
    Shell > mount -t  vfat  /dev/sdb1  /mnt/usb

    # Read the information of the USB flash disk
    Shell > cd /mnt/usb/

    # When not needed, execute the following command to pull out the USB flash disk
    Shell > umount /mnt/usb
    ```

!!! info "Informazione"

    È possibile fare una copia del file `/etc/mtab` o copiare il suo contenuto in `/etc/fstab`.
    Se si desidera visualizzare l'UUID del numero di partizione del dispositivo, digitare il seguente comando: `lsblk -o name,uuid`. UUID è l'abbreviazione di `Universally Unique Identifier`.

### Comandi di gestione del montaggio

#### comando di `montaggio`

Il comando `mount` consente di montare e visualizzare le unità logiche nella struttura.

```bash
mount [-option] [device] [directory]
```

Esempio:

```bash
[root]# mount /dev/sda7 /home
```

| Opzione   | Descrizione                                                                                      |
| --------- | ------------------------------------------------------------------------------------------------ |
| `-n`      | Imposta il montaggio senza scrivere in `/etc/mtab`.                                              |
| `-t`      | Indica il tipo di file system da utilizzare.                                                     |
| `-a`      | Monta tutti i filesystem menzionati in `/etc/fstab`.                                             |
| `-r`      | Monta il file system in sola lettura (equivalente a `-o ro`).                                    |
| `-w`      | Monta il file system in lettura/scrittura, per impostazione predefinita (equivalente a `-o rw`). |
| `-o opts` | L'argomento opts è un elenco separato da virgole (`remount`, `ro`, ...).                         |

!!! Note "Nota"

    Il solo comando `mount` visualizza tutti i file system montati. Se il parametro di mount è `-o defaults`, è equivalente a `-o rw,suid,dev,exec,auto,nouser,async` e questi parametri sono indipendenti dal file system. Se è necessario consultare le opzioni di montaggio speciali relative al file system, leggere la sezione "Opzioni di montaggio FS-TYPE" in `man 8 mount` (FS-TYPE viene sostituito dal file system corrispondente, come ntfs, vfat, ufs, ecc.)

#### comando `umount`

Il comando `umount` viene utilizzato per smontare le unità logiche.

```bash
umount [-option] [device] [directory]
```

Esempio:

```bash
[root]# umount /home
[root]# umount /dev/sda7
```

| Opzione | Descrizione                                                          |
| ------- | -------------------------------------------------------------------- |
| `-n`    | Imposta la rimozione del montaggio senza scrivere in `/etc/mtab`.    |
| `-r`    | Rimonta in sola lettura se `umount` fallisce.                        |
| `-f`    | Forza la rimozione del montaggio.                                    |
| `-a`    | Rimuove i montaggi di tutti i filesystem menzionati in `/etc/fstab`. |

!!! Note "Nota"

    Durante lo smontaggio, non si deve rimanere al di sotto del punto di montaggio. In caso contrario, viene visualizzato il seguente messaggio di errore: `device is busy`.

## Convenzione di denominazione dei file

Come in ogni sistema, è importante rispettare le regole di denominazione dei file per navigare nella struttura ad albero e nella gestione dei file.

- I file sono codificati con 255 caratteri;
- È possibile utilizzare tutti i caratteri ASCII;
- Le lettere maiuscole e minuscole sono differenziate;
- La maggior parte dei file non ha un concetto di estensione. Nel mondo GNU/Linux, la maggior parte delle estensioni dei file non è richiesta, tranne alcune (ad esempio, .jpg, .mp4, .gif, ecc.).

I gruppi di parole separati da spazi devono essere racchiusi tra virgolette:

```bash
[root]# mkdir "working dir"
```

!!! Note "Nota"

    Anche se tecnicamente non c'è nulla di male nel creare un file o una directory con uno spazio, in genere è una "best practice" evitare questa situazione e sostituire ogni spazio con un trattino basso.

!!! Note "Nota"

    Il **.** all'inizio del nome del file lo nasconde solo a un semplice `ls`.

Esempi di convenzione sull'estensione dei file:

- `.c`: file sorgente in linguaggio C;
- `.h`: file di intestazione C e Fortran;
- `.o`: file oggetto in linguaggio C;
- `.tar`: file di dati archiviati con l'utilità `tar`;
- `.cpio`: file di dati archiviati con l'utilità `cpio`;
- `.gz`: file di dati compressi con l'utilità `gzip`;
- `.tgz`: file di dati archiviati con l'utilità `tar` e compressi con l'utilità `gzip`;
- `.html`: pagina web.

### Dettagli del nome di un file

```bash
[root]# ls -liah /usr/bin/passwd
266037 -rwsr-xr-x 1 root 59K mars 22 2019 /usr/bin/passwd
1 2 3 4 5 6 7 8 9
```

| Parte | Descrizione                                                                                                                                                                                                                                                         |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `1`   | Numero di inode                                                                                                                                                                                                                                                     |
| `2`   | Tipo di file (primo carattere del blocco di 10), "-" significa che si tratta di un file ordinario.                                                                                                                                                                  |
| `3`   | Diritti di accesso (ultimi 9 caratteri del blocco di 10)                                                                                                                                                                                                            |
| `4`   | Se si tratta di una directory, questo numero rappresenta il numero di sottodirectory presenti nella directory, comprese quelle nascoste. Se si tratta di un file, indica il numero di collegamenti diretti. Quando c'è il numero 1, c'è un solo collegamento fisso. |
| `5`   | Nome del proprietario                                                                                                                                                                                                                                               |
| `6`   | Nome del gruppo                                                                                                                                                                                                                                                     |
| `7`   | Dimensione (byte, kilo, mega)                                                                                                                                                                                                                                       |
| `8`   | Data dell'ultimo aggiornamento                                                                                                                                                                                                                                      |
| `9`   | Nome del file                                                                                                                                                                                                                                                       |

Nel mondo GNU/Linux esistono sette tipi di file:

| Tipi di file | Descrizione                                                                                                                                                                                                           |
|:------------:| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|    **-**     | Rappresenta un file ordinario. Compresi i file di testo semplice (ASCII); file binari (binario); file in formato dati (dati); vari file compressi.                                                                    |
|    **d**     | Rappresenta un file di directory.                                                                                                                                                                                     |
|    **b**     | Rappresenta un file di dispositivo a blocchi. Comprende dischi rigidi, unità USB e così via.                                                                                                                          |
|    **c**     | Rappresenta un file di dispositivo di caratteri. Dispositivo di interfaccia della porta seriale, come il mouse, la tastiera, ecc.                                                                                     |
|    **s**     | Rappresenta un file socket. Si tratta di un file appositamente utilizzato per la comunicazione di rete.                                                                                                               |
|    **p**     | Rappresenta un file pipe. È un tipo di file speciale. Lo scopo principale è quello di risolvere gli errori causati dall'accesso simultaneo di più programmi a un file. FIFO è l'abbreviazione del first-in-first out. |
|    **l**     | I file soft link, chiamati anche file di collegamento simbolico, sono simili ai collegamenti di Windows. File di collegamento rigido, noto anche come file di collegamento fisico.                                    |

#### Descrizione supplementare della directory

Ogni directory ha due file nascosti: **.** e **..**. È necessario utilizzare `ls -al` per visualizzarli, ad esempio:

```bash
# . Indica che nella directory corrente, ad esempio, è necessario eseguire uno script in una directory, di solito:
Shell > ./scripts

# .. rappresenta la directory un livello sopra la directory corrente, ad esempio:
Shell > cd /etc/
Shell > cd ..
Shell > pwd
/

# Per una directory vuota, la sua quarta parte deve essere maggiore o uguale a 2. Perché ci sono "." e ".."
Shell > mkdir /tmp/t1
Shell > ls -ldi /tmp/t1
1179657 drwxr-xr-x 2 root root 4096 Nov 14 18:41 /tmp/t1
```

#### File speciali

Per comunicare con le periferiche (dischi rigidi, stampanti, ecc.), Linux utilizza file di interfaccia chiamati file speciali (*device file* o *special file*). Questi file consentono alle periferiche di identificarsi.

Questi file sono speciali perché non contengono dati, ma specificano la modalità di accesso per comunicare con il dispositivo.

Sono definiti in due modalità:

- modalità **a blocchi**;
- modalità a **carattere**.

```bash
# Block device file
Shell > ls -l /dev/sda
brw-------   1   root  root  8, 0 jan 1 1970 /dev/sda

# Character device file
Shell > ls -l /dev/tty0
crw-------   1   root  root  8, 0 jan 1 1970 /dev/tty0
```

#### File di comunicazione

Si tratta dei file pipe (*pipes*) e *socket*.

- I **file Pipe** passano le informazioni tra i processi tramite FIFO (*First In, First Out*). Un processo scrive informazioni transitorie in un file *pipe* e un altro le legge. Dopo la lettura, le informazioni non sono più accessibili.

- I **file socket** consentono la comunicazione bidirezionale tra processi (su sistemi locali o remoti). Utilizzano un *inode* del file system.

#### File di collegamento

Questi file consentono di assegnare diversi nomi logici allo stesso file fisico. Viene quindi creato un nuovo punto di accesso al file.

Esistono due tipi di file di collegamento:

- File di collegamento soft, detti anche file di collegamento simbolico;
- File di collegamento hard, detti anche file di collegamento fisico.

Le loro caratteristiche principali sono:

| Tipi di link   | Descrizione                                                                                                                                                                                                                                                                                                                                                                         |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| file soft link | Una scorciatoia simile a quella di Windows. Ha un permesso di 777 e punta al file originale. Quando il file originale viene eliminato, il file collegato e il file originale vengono visualizzati in rosso. Nelle informazioni di output, il nome del file del soft link appare in rosso, mentre il file originale puntato appare in rosso con un messaggio lampeggiante.           |
| File hard link | Il file originale ha lo stesso numero di _inode_ del file collegato. Possono essere aggiornati in modo sincrono (compresi il contenuto del file, l'ora di modifica, il proprietario, l'appartenenza al gruppo, l'ora di accesso, ecc.). I file con collegamenti rigidi non possono essere utilizzati in partizioni e file system e non possono essere utilizzati nelle directory. |

Esempi specifici sono i seguenti:

```bash
# Permissions and the original file to which they point
Shell > ls -l /etc/rc.locol
lrwxrwxrwx 1 root root 13 Oct 25 15:41 /etc/rc.local -> rc.d/rc.local

# When deleting the original file. "-s" represents the soft link option
Shell > touch /root/Afile
Shell > ln -s /root/Afile /root/slink1
Shell > rm -rf /root/Afile
```

![Presentare l'effetto](images/07-file-systems-019.png)

```bash
Shell > cd /home/paul/
Shell > ls –li letter
666 –rwxr--r-- 1 root root … letter

# The ln command does not add any options, indicating a hard link
Shell > ln /home/paul/letter /home/jack/read

# The essence of hard links is the file mapping of the same inode number in different directories.
Shell > ls –li /home/*/*
666 –rwxr--r-- 2 root root … letter
666 –rwxr--r-- 2 root root … read

# If you use a hard link to a directory, you will be prompted:
Shell > ln  /etc/  /root/etc_hardlink
ln: /etc: hard link not allowed for directory
```

## Attributi dei file

Linux è un sistema operativo multiutente in cui il controllo dell'accesso ai file è essenziale.

Questi controlli sono funzioni di:

- permessi di accesso ai file ;
- utenti (*ugo* *Users Groups Others*).

### Permessi di base di file e directory

La descrizione dei **permessi dei file** è la seguente:

| Permessi dei file | Descrizione                                                                                 |
|:-----------------:| ------------------------------------------------------------------------------------------- |
|         r         | Leggi. Consente la lettura di un file`(cat`, `less`, ...) e la copia di un file`(cp`, ...). |
|         w         | Scrivere. Consente di modificare il contenuto del file`(cat`, `>>,` `vim`, ...).      |
|         x         | Eseguire. Considera il file come un file **eseguibile**(binario o script).                  |
|         -         | Nessun diritto                                                                              |

La descrizione dei **permessi delle directory** è la seguente:

| Autorizzazioni delle directory | Descrizione                                                                                                                              |
|:------------------------------:| ---------------------------------------------------------------------------------------------------------------------------------------- |
|               r                | Leggi. Consente di leggere il contenuto di una directory`(ls -R`).                                                                       |
|               w                | Scrivere. Permette di creare ed eliminare file/directory in questa directory, come i comandi `mkdir`, `rmdir`, `rm`, `touch` e così via. |
|               x                | Eseguire. Consente la discesa nella directory(`cd`).                                                                                     |
|               -                | Nessun diritto                                                                                                                           |

!!! info "Informazione"

    Per i permessi di una directory, `r` e `x` di solito compaiono assieme. Lo spostamento o la ridenominazione di un file dipende dal fatto che la directory in cui si trova abbia i permessi `w', così come anche per l'eliminazione di un file.

### Tipo di utente corrispondente all'autorizzazione di base

| Tipo utente | Descrizione         |
|:-----------:| ------------------- |
|      u      | Proprietario        |
|      g      | Gruppo proprietario |
|      o      | Altri utenti        |

!!! info "Informazione"

    In alcuni comandi è possibile designarli tutti con **a** (_all_). **a = ugo**.

### Gestione degli attributi

La visualizzazione dei diritti si effettua con il comando `ls -l`. Si tratta degli ultimi 9 caratteri di un blocco di 10. Più precisamente 3 volte 3 caratteri.

```bash
[root]# ls -l /tmp/myfile
-rwxrw-r-x  1  root  sys  ... /tmp/myfile
  1  2  3       4     5
```

| Parte | Descrizione                                             |
| ----- | ------------------------------------------------------- |
| 1     | Permessi del proprietario (**u**ser), qui `rwx`         |
| 2     | Permessi del gruppo proprietario (**g**roup), qui `rw-` |
| 3     | Permessi di altri utenti (**o**thers), qui `r-x`        |
| 4     | Proprietario del file                                   |
| 5     | Gruppo proprietario del file                            |

Per impostazione predefinita, il *proprietario* di un file è colui che lo ha creato. Il *gruppo* del file è il gruppo del proprietario che ha creato il file. Gli *altri* sono quelli che non rientrano nei casi precedenti.

Gli attributi vengono modificati con il comando `chmod`.

Solo l'amministratore e il proprietario di un file possono modificarne i diritti.

#### comando `chmod`

Il comando `chmod` consente di modificare i permessi di accesso a un file.

```bash
chmod [opzione] modalità file
```

| Opzione | Osservazione                                                                            |
| ------- | --------------------------------------------------------------------------------------- |
| `-R`    | Modifica ricorsivamente i permessi della directory e di tutti i file in essa contenuti. |

!!! Warning "Attenzione"

    I diritti dei file e delle directory non sono dissociati. Per alcune operazioni, sarà necessario conoscere i diritti della directory contenente il file. Un file protetto da scrittura può essere cancellato da un altro utente, purché i diritti della directory che lo contiene consentano a questo utente di eseguire questa operazione.

L'indicazione della modalità può essere una rappresentazione ottale (ad esempio `744`) o una rappresentazione simbolica ([`ugoa`][`+=-`][`rwxst`]).

##### Rappresentazione ottale (o numerica):

| Numero | Descrizione |
|:------:| ----------- |
|   4    | r           |
|   2    | s           |
|   1    | x           |
|   0    | -           |

Sommare i tre numeri per ottenere un'autorizzazione di tipo utente. ad es. **755=rwxr-xr-x**.

![Rappresentazione ottale](images/07-file-systems-011.png)

![Diritti 777](images/07-file-systems-012.png)

![Diritti 741](images/07-file-systems-013.png)

!!! info "Informazione"

    A volte si vedrà `chmod 4755`. Il numero 4 si riferisce al permesso speciale **set uid**. I permessi speciali non verranno per il momento ampliati in questa sede, ma solo come nozioni di base.

```bash
[root]# ls -l /tmp/fil*
-rwxrwx--- 1 root root … /tmp/file1
-rwx--x--- 1 root root … /tmp/file2
-rwx--xr-- 1 root root … /tmp/file3

[root]# chmod 741 /tmp/file1
[root]# chmod -R 744 /tmp/file2
[root]# ls -l /tmp/fic*
-rwxr----x 1 root root … /tmp/file1
-rwxr--r-- 1 root root … /tmp/file2
```

##### rappresentazione simbolica

Questo metodo può essere considerato come un'associazione "letterale" tra un tipo di utente, un operatore e i diritti.

![Metodo simbolico](images/07-file-systems-014.png)

```bash
[root]# chmod -R u+rwx,g+wx,o-r /tmp/file1
[root]# chmod g=x,o-r /tmp/file2
[root]# chmod -R o=r /tmp/file3
```

## Diritti predefiniti e maschera

Quando un file o una directory viene creata, ha già dei permessi.

- Per una directory: `rwxr-xr-x` o *755*.
- Per un file: `rw-r-r-` o *644*.

Questo comportamento è definito dalla **maschera predefinita**.

Il principio è quello di rimuovere il valore definito dalla maschera al massimo dei diritti senza il diritto di esecuzione.

Per una directory :

![Come funziona il SUID](images/07-file-systems-017.png)

Per un file, i diritti di esecuzione vengono rimossi:

![Diritti predefiniti di un file](images/07-file-systems-018.png)

!!! info "Informazione"

    Il file `/etc/login.defs' definisce l'UMASK predefinito, con un valore di **022**. Ciò significa che il permesso di creare un file è 755 (rwxr-xr-x). Tuttavia, per motivi di sicurezza, GNU/Linux non prevede il permesso **x** per i file appena creati. Questa restrizione si applica a root (uid=0) e agli utenti ordinari (uid>=1000).

    ```bash
    # root user
    Shell > touch a.txt
    Shell > ll
    -rw-r--r-- 1 root root     0 Oct  8 13:00 a.txt
    ```

### comando `umask`

Il comando `umask` consente di visualizzare e modificare la maschera.

```bash
umask [opzione] [modalità]
```

Esempio:

```bash
$ umask 033
$ umask
0033
$ umask -S
u=rwx,g=r,o=r
$ touch umask_033
$ ls -la  umask_033
-rw-r--r-- 1 rockstar rockstar 0 nov.   4 16:44 umask_033
$ umask 025
$ umask -S
u=rwx,g=rx,o=w
$ touch umask_025
$ ls -la  umask_025
-rw-r---w- 1 rockstar rockstar 0 nov.   4 16:44 umask_025
```

| Opzione | Descrizione                                     |
| ------- | ----------------------------------------------- |
| `-S`    | Visualizzazione simbolica dei diritti dei file. |

!!! Warning "Attenzione"

    `umask` non influisce sui file esistenti. `umask -S` visualizza i diritti dei file (senza il diritto di esecuzione) dei file che verranno creati. Quindi, non è la visualizzazione della maschera utilizzata per sottrarre il valore massimo.

!!! Note "Nota"

    Nell'esempio precedente, l'operazione di utilizzo dei comandi per modificare le maschere è applicabile solo alla sessione attualmente connessa.

!!! info "Informazione"

    Il comando `umask` appartiene ai comandi incorporati di bash, quindi quando si usa `man umask`, vengono visualizzati tutti i comandi incorporati. Se si desidera visualizzare solo la guida di `umask`, è necessario utilizzare il comando `help umask`.

Per mantenere il valore, è necessario modificare i seguenti file di profilo:

Per tutti gli utenti:

- `/etc/profile`
- `/etc/bashrc`

Per un particolare utente:

- `~/.bashrc`

Quando viene scritto il file di cui sopra, esso sovrascrive il parametro **UMASK** di `/etc/login.defs`. Se si desidera migliorare la sicurezza del sistema operativo, è possibile impostare umask a **027** o **077**.
