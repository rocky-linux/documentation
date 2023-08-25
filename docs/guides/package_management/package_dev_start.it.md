---
title: Guida al Packaging per Sviluppatori
---

# Guida iniziale sul Packaging per sviluppatori


Rocky Devtools si riferisce a un insieme di script e utility create dai membri della comunità Rocky Linux per aiutare a reperire, creare, contrassegnare, patchare e costruire i pacchetti software distribuiti con il sistema operativo Rocky Linux. Rocky Devtools è costituito da `rockyget`, `rockybuild`, `rockypatch`, e `rockyprep`.

A basso livello Rocky Devtools è un wrapper per l'esecuzione di alcuni programmi personalizzati e tradizionali per varie attività di gestione dei pacchetti. Rocky Devtools si basa molto su [`srpmproc`](https://github.com/mstg/srpmproc), `go`, `git`, e `rpmbuild`.

Per installare e utilizzare Rocky devtools è necessario un sistema Linux moderno basato su RPM.

Vediamo uno scenario tipico di installazione e utilizzo di devtools.

## Dipendenze
Sono necessari diversi pacchetti sul sistema prima di poter iniziare a usare i devtools. Questi comandi sono stati testati su Rocky Linux ma dovrebbero funzionare anche su CentOS 8 / RHEL 8
```
dnf install git make golang
```

## 1. Scarica Rocky Devtools

Scaricare il sorgente zippato di devtools dal seguente URL:

https://github.com/rocky-linux/devtools/archive/refs/heads/main.zip

Qui si usa il comando `curl`:

```
curl -OJL https://github.com/rocky-linux/devtools/archive/refs/heads/main.zip
```

Ora si dovrebbe avere un archivio zippato chiamato `devtools-main.zip`


## 2. Installa Rocky Devtools

Individuare e decomprimere l'archivio devtools appena scaricato.

In questo caso utilizzeremo l'utilità a riga di comando `unzip`:

```
unzip devtools-main.zip
```

Cambiate la vostra directory di lavoro nella nuova directory dei sorgenti di devtool appena creata:

```
cd devtools-main
```

Eseguire `make` per configurare e compilare devtools:

```
make
```

Installare i devtools:

```
sudo make install
```

## 3. Usare Rocky Devtools (rockyget) per cercare e scaricare i sorgenti RPM (SRPM)

Una volta installata, l'utilità principale per trovare e scaricare gli SRPM è l'utilità `rockyget`.

Usiamo `rockyget` per scaricare l'SRPM del popolare pacchetto `sed`:

```
rockyget sed
```
La prima volta che rockyget viene eseguito, crea automaticamente una struttura di directory che imita approssimativamente la struttura dei repository dei server di compilazione di Rocky. Ad esempio, la cartella `~/rocky/rpms` verrà creata automaticamente.

Per il nostro attuale esempio di sed, i suoi sorgenti saranno memorizzati nella seguente cartella gerarchica di esempio:

```
~rocky/rpms/sed/
└── r8
    ├── SOURCES
    │   ├── sed-4.2.2-binary_copy_args.patch
    │   ├── sed-4.5.tar.xz
    │   ├── sedfaq.txt
    │   ├── sed-fuse.patch
    │   └── sed-selinux.patch
    └── SPECS
        └── sed.spec
```

### SUGGERIMENTO :
Una volta che si hanno i sorgenti originali, potrebbe essere un buon momento per dare un'occhiata al file SPECs (`~rocky/rpms/sed/SPECS/specs.spec`) per cercare potenziali opportunità di debranding in un dato pacchetto. Il debranding può comprendere la sostituzione di grafica/loghi a monte e così via.

### SUGGERIMENTO
Se state cercando altri pacchetti Rocky da compilare e sperimentare, potete consultare l'elenco dei pacchetti che attualmente non funzionano nell'ambiente di compilazione automatica di Rocky [qui](https://kojidev.rockylinux.org/koji/builds?state=3&order=-build_id) - https://kojidev.rockylinux.org/koji/builds?state=3&order=-build_id


## 4. Utilizzare Rocky Devtools (rockybuild) per creare un nuovo pacchetto per il sistema operativo Rocky

Sotto il cofano, `rockybuild` chiama le utility `rpmbuild` e `mock` per costruire il pacchetto sorgente in un ambiente chroot per l'applicazione specificata nella riga di comando. Si basa sui sorgenti dell'applicazione e sul file RPM SPEC scaricato automaticamente tramite il comando `rockyget`.

Utilizzare `rockybuild` per creare l'utilità sed:

```
rockybuild sed
```

Il tempo necessario per completare il processo/fase di compilazione dipende dalle dimensioni e dalla complessità dell'applicazione che si sta cercando di costruire.

Al termine dell'esecuzione di `rockybuild`, un output simile a quello qui riportato indica che la compilazione è stata completata con successo.

```
..........
+ exit 0
Finish: rpmbuild sed-4.5-2.el8.src.rpm
Finish: build phase for sed-4.5-2.el8.src.rpm
INFO: Done(~/rocky/rpms/sed/r8/SRPMS/sed-4.5-2.el8.src.rpm) Config(baseos) 4 minutes 34 seconds
INFO: Results and/or logs in: /home/centos/rocky/builds/sed/r8
........
```


Se tutto va bene, si dovrebbe ottenere un file SRPM pronto per Rocky nella directory `~/rocky/builds/sed/r8`.

`~/rocky/rpms/sed/r8/SRPMS/sed-4.5-2.el8.src.rpm`



## 5. Debug di una compilazione di un pacchetto fallita

Il processo rockybuild precedente genera alcuni file di log che possono essere utilizzati per il debug delle applicazioni fallite. I risultati e/o i registri del processo di compilazione sono memorizzati nella cartella `~/rocky/builds/<PACKAGE NAME>/r8`. Per esempio `~/rocky/builds/sed/r8`


```
~/rocky/builds/sed/r8
├── build.log
├── hw_info.log
├── installed_pkgs.log
├── root.log
├── sed-4.5-2.el8_3.src.rpm
├── sed-4.5-2.el8_3.x86_64.rpm
├── sed-debuginfo-4.5-2.el8_3.x86_64.rpm
├── sed-debugsource-4.5-2.el8_3.x86_64.rpm
└── state.log
```

I file principali in cui cercare indizi sulle cause degli errori sono build.log e root.log.     Il file build.log dovrebbe riportare tutti gli errori di compilazione e il file root.log conterrà informazioni sui processi di configurazione e rimozione dell'ambiente chroot. A parità di condizioni, la maggior parte del processo di debug/troubleshooting della compilazione può essere eseguito con il contenuto del file build.log.
