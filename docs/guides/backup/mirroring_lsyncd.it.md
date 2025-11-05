---
title: Soluzione di mirroring - lsyncd
author: Steven Spencer
contributors: Ezequiel Bruni, tianci li, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - lsyncd
  - synchronization
  - mirroring
---

## Prerequisiti

- Un computer con Rocky Linux in esecuzione
- Un livello di confidenza con la modifica dei file di configurazione da riga di comando
- Conoscenza dell'uso di un editor a riga di comando (in questo caso si utilizza `vi`, ma è possibile utilizzare l'editor preferito)
- È necessario avere accesso a root e, idealmente, essere registrati come utente root nel proprio terminale
- Coppia di chiavi SSH pubbliche e private
- I repository EPEL (Extra Packages for Enterprise Linux) di Fedora
- È necessario avere familiarità con `inotify`, un'interfaccia di monitoraggio degli eventi
- Facoltativo: familiarità con *tail*

## Introduzione

Se si desidera sincronizzare automaticamente file e cartelle tra computer, `lsyncd` è un'ottima opzione. Tuttavia, è necessario configurare tutto dalla riga di comando.

È un programma che vale la pena di imparare per qualsiasi amministratore di sistema.

La migliore descrizione di `lsyncd` e' fornita dalla sua stessa pagina man. Parafrasando leggermente, `lsyncd` è una soluzione live-mirror leggera e facile da installare. Non richiede nuovi file system o dispositivi a blocchi e non ostacola le prestazioni del file system locale. In breve, fa il mirror dei file.

`lsyncd` controlla l'interfaccia di monitoraggio degli eventi di una struttura di directory locale (`inotify`). Aggrega e combina gli eventi per alcuni secondi e genera uno (o più) processi per sincronizzare le modifiche. Per impostazione predefinita, si tratta di `rsync`.

Aggrega e combina gli eventi per alcuni secondi e genera uno (o più) processi per sincronizzare le modifiche. Utilizzando `lsyncd`, è possibile eseguire il mirroring completo di un server specificando attentamente le directory e i file che si desidera sincronizzare.

È inoltre necessario configurare [Rocky Linux SSH Public Private Key Pairs](../security/ssh_public_private_keys.md) per la sincronizzazione remota. Gli esempi qui riportati utilizzano SSH (porta 22).

## Installazione di `lsyncd`

!!! info

    A partire da questa data (settembre 2025), Rocky Linux 10 con EPEL (Extra Packages for Enterprise Linux) abilitato non include il pacchetto `lsyncd`. Per utilizzare `lsyncd` su Rocky Linux 10, è necessario utilizzare il metodo **Installazione di `lsyncd` - metodo sorgente**. Il metodo RPM viene mantenuto in questo caso, poiché è probabile che EPEL crei questo pacchetto per la versione 10 in futuro. Non fa mai male verificare se il pacchetto è disponibile prima di compilare da sorgente.

È possibile installare `lsyncd` in due modi. Sono incluse le descrizioni di entrambi i metodi. Gli RPM sono leggermente in ritardo rispetto ai pacchetti sorgente, ma solo di poco. La versione installata con il metodo RPM al momento in cui scriviamo è la 2.2.3-5, mentre la versione del codice sorgente è ora la 2.3.1. Scegliete il metodo con cui vi sentite più a vostro agio.

## Installazione di `lsyncd` - Metodo RPM

L'unica cosa che dovrai installare prima è il repository software EPEL di Fedora. Eseguire:

```bash
dnf install -y epel-release
```

Installare ora `lsyncd` con tutte le dipendenze mancanti:

```bash
dnf install lsyncd
```

Impostate il servizio in modo che si avvii all'avvio, ma non avviatelo ancora:

```bash
systemctl enable lsyncd
```

## Installazione di `lsyncd` - Metodo sorgente

L'installazione dalla sorgente non è difficile.

### Installare le dipendenze

Sono necessarie alcune dipendenze per `lsyncd` e per costruire i pacchetti dai sorgenti. Installa il gruppo "Strumenti di sviluppo":

```bash
dnf groupinstall 'Development Tools'
```

Eseguendo questi nove passaggi prima dei successivi, si potrà terminare la costruzione senza tornare indietro.

```bash
dnf config-manager --enable crb
```

Ecco le dipendenze necessarie per `lsyncd`:

```bash
dnf install lua lua-libs lua-devel cmake unzip wget rsync
```

### Scaricare `lsyncd` e compilarlo

Successivamente, è necessario il codice sorgente:

```bash
wget https://github.com/axkibe/lsyncd/archive/master.zip
```

Decomprimere il file `master.zip:`:

`unzip master.zip`

Verrà creata una directory chiamata "lsyncd-master". È necessario passare a questa cartella e creare una cartella chiamata build:

```bash
cd lsyncd-master
```

Quindi:

```bash
mkdir build
```

Cambiare directory per accedere alla directory di creazione:

```bash
cd build
```

Eseguire questi comandi:

```bash
cmake ..
make
make install
```

Una volta completata l'operazione, il binario `lsyncd` sarà installato e pronto per l'uso in `/usr/local/bin`

### servizio systemd `lsyncd`

With the RPM install method, the `systemd` service will install for you, but if you install from the source, you will need to create the `systemd` service. Sebbene sia possibile avviare il binario senza il servizio systemd, si vuole garantire che esso *si* avvii all'avvio. In caso contrario, un riavvio del server interromperà il tentativo di sincronizzazione.

Creare il servizio systemd è relativamente facile e vi farà risparmiare tempo nel lungo periodo.

#### Creare il file di servizio `lsyncd`

Questo file può essere creato ovunque, anche nella directory principale del server. Una volta creato, è possibile spostarlo nella posizione giusta.

```bash
vi /root/lsyncd.service`
```

Il contenuto di questo file sarà:

```bash
[Unit]
Description=Live Syncing (Mirror) Daemon
After=network.target

[Service]
Restart=always
Type=simple
Nice=19
ExecStart=/usr/local/bin/lsyncd -nodaemon -pidfile /run/lsyncd.pid /etc/lsyncd.conf
ExecReload=/bin/kill -HUP $MAINPID
PIDFile=/run/lsyncd.pid

[Install]
WantedBy=multi-user.target
```

Installa questo file nella posizione corretta:

```bash
install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service
```

Infine, ricaricare il servizio daemon `systemctl` in modo che systemd "veda" il nuovo file di servizio:

```bash
systemctl daemon-reload
```

## Configurazione di `lsyncd`

Con entrambi i metodi di installazione `lsyncd`, è necessario un file di configurazione: */etc/lsyncd.conf*. La sezione seguente spiega come costruire e testare un file di configurazione.

### Configurazione di esempio per il test

Ecco un esempio di file di configurazione semplicistico che sincronizza */home* con un altro computer. Il nostro computer di destinazione sarà un indirizzo IP locale: *192.168.1.40*

```bash
  settings {
   logfile = "/var/log/lsyncd.log",
   statusFile = "/var/log/lsyncd-status.log",
   statusInterval = 20,
   maxProcesses = 1
   }

sync {
   default.rsyncssh,
   source="/home",
   host="root@192.168.1.40",
   excludeFrom="/etc/lsyncd.exclude",
   targetdir="/home",
   rsync = {
     archive = true,
     compress = false,
     whole_file = false
   },
   ssh = {
     port = 22
   }
}
```

Scomporre un po' questo file:

- Il `logfile` e lo `statusFile` vengono creati automaticamente all'avvio del servizio
- `StatusInterval` è il numero di secondi da attendere prima di scrivere sul file di stato
- `maxProcesses` è il numero di processi `lsyncd` che possono essere generati. A meno che non si tratti di un computer molto trafficato, un processo è sufficiente.
- Nella sezione di sincronizzazione `default.rsyncssh` dice di usare `rsync` su SSH
- `source=` è il percorso della directory da cui si sta effettuando la sincronizzazione
- Il `host=` è il computer di destinazione con cui stai effettuando la sincronizzazione
- Il parametro `excludeFrom=` indica a `lsyncd` dove si trova il file delle esclusioni. Deve esistere, ma può essere vuoto.
- `Targetdir=` è la directory a cui inviare i file. Nella maggior parte dei casi sarà uguale alla sorgente, ma non sempre.
- La sezione `rsync =` e le opzioni con le quali si esegue `rsync`
- La sezione `ssh =`, che specifica la porta SSH in ascolto sul computer di destinazione

Se si aggiunge più di una directory da sincronizzare, è necessario ripetere l'intera sezione “sync”, comprese tutte le parentesi di apertura e chiusura per ogni directory.

## Il File `lsyncd.exclude`

Come già detto, il file `excludeFrom` deve esistere. Createlo subito:

```bash
touch /etc/lsyncd.exclude
```

Ad esempio, se si stesse sincronizzando la cartella `/etc` del computer, ci sarebbero molti file e directory da escludere nel processo `lsyncd`. Ogni file o directory esclusa è presente nel file, una per riga:

```bash
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## Test e Messa in Funzione

Una volta impostato tutto, è possibile testare il tutto. Assicurarsi che systemd `lsyncd.service` si avvii:

```bash
systemctl start lsyncd
```

Se non vengono visualizzati errori dopo l'esecuzione di questo comando, verificare lo stato del servizio per assicurarsene:

```bash
systemctl start lsyncd
```

Se mostra che il servizio è in esecuzione, usa tail per vedere la fine dei due file di log e assicurati che tutto sia visibile:

```bash
tail /var/log/lsyncd.log
tail /var/log/lsyncd-status.log
```

Supponendo che tutto sia corretto, spostatevi nella directory `/home/[user]`, dove `[user]` è un utente del computer, e create un file con *touch*.

```bash
touch /home/[user]/testfile
```

Andate sul computer di destinazione e verificate se il file viene visualizzato. In caso affermativo, tutto funziona. Impostare `lsyncd.service` da avviare all'avvio con:

```bash
systemctl enable lsyncd
```

## Ricordate di fare attenzione

Ogni volta che si sincronizza un insieme di file o directory su un altro computer, è necessario considerare attentamente l'effetto che avrà sul computer di destinazione. Supponiamo di tornare al **file lsyncd.exclude** dell'esempio precedente. Si provi ad immaginare, cosa potrebbe succedere se non si escludesse **/etc/fstab**?

`fstab` è il file che configura le unità di archiviazione su qualsiasi computer Linux. I dischi e le etichette sono quasi certamente diversi su macchine diverse. Il successivo riavvio del computer di destinazione potrebbe fallire.

## Conclusioni e riferimenti

`lsyncd` è un potente strumento per la sincronizzazione delle directory tra computer. Come avete visto, non è difficile da installare e non sarà complesso da mantenere.

Per saperne di più su `lsyncd`, visitate [il sito ufficiale](https://github.com/axkibe/lsyncd).
