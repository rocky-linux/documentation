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

# Soluzione di mirroring - `lsyncd`

## Prerequisiti

Ecco tutto ciò di cui avrete bisogno per capire e seguire questa guida:

* Un computer con Rocky Linux in esecuzione
* Un livello di confidenza con la modifica dei file di configurazione da riga di comando
* Conoscenza dell'uso di un editor a riga di comando (qui usiamo vi, ma potete usare il vostro editor preferito)
* È necessario avere accesso a root e, idealmente, essere registrati come utente root nel proprio terminale
* Coppia di chiavi SSH pubbliche e private
* I repository EPEL di Fedora
* È necessario avere familiarità con *inotify*, un'interfaccia per il monitoraggio degli eventi
* Facoltativo: familiarità con *tail*

## Introduzione

Se state cercando un modo per sincronizzare automaticamente file e cartelle tra i computer, `lsyncd` è un'ottima opzione. L'unico inconveniente per i principianti? È necessario configurare tutto alla riga di comando e nei file di testo.

Tuttavia, è un programma che vale la pena di imparare per qualsiasi sysadmin.

La migliore descrizione di `lsyncd` proviene dalla sua stessa pagina man. Parafrasando leggermente, `lsyncd` è una soluzione live mirror leggera e non difficile da installare. Non richiede nuovi filesystem o dispositivi a blocchi e non ostacola le prestazioni del filesystem locale. In breve, fa il mirror dei file.

`lsyncd` controlla un'interfaccia di monitoraggio degli eventi degli alberi delle directory locali (inotify). Aggrega e combina gli eventi per alcuni secondi, quindi genera uno (o più) processi per sincronizzare le modifiche. Per impostazione predefinita è `rsync`.

Ai fini di questa guida, il sistema con i file originali sarà chiamato "sorgente", mentre quello su cui si sta effettuando la sincronizzazione sarà la "destinazione". È possibile eseguire il mirroring completo di un server utilizzando `lsyncd`, specificando con molta attenzione le directory e i file che si desidera sincronizzare. È piuttosto facile!

Per la sincronizzazione remota, è necessario impostare anche le [Coppie di Chiavi Pubbliche e Private Rocky Linux SSH](../security/ssh_public_private_keys.md). Gli esempi qui riportati utilizzano SSH (porta 22).

## Installazione di `lsyncd`

Esistono due modi per installare `lsyncd`. Li includeremo entrambi in questa sede. L'RPM tende a rimanere un po' indietro rispetto ai pacchetti sorgente, ma solo di poco. La versione installata con il metodo RPM al momento in cui scriviamo è la 2.2.2-9, mentre la versione del codice sorgente è attualmente la 2.2.3. Detto questo, vogliamo offrirvi entrambe le opzioni e lasciarvi scegliere.

## Installazione di `lsyncd` - Metodo RPM

L'installazione della versione RPM non è difficile. L'unica cosa che dovrete installare prima è il repository del software EPEL di Fedora. Questo può essere fatto con un solo comando:

`dnf install -y epel-release`

A questo punto è sufficiente installare `lsyncd` e tutte le dipendenze mancanti saranno installate insieme ad esso:

`dnf install lsyncd`

Impostate il servizio in modo che parta all'avvio, ma non avviatelo ancora:

`systemctl enable lsyncd`

Fatto!

## Installazione di `lsyncd` - Metodo sorgente

L'installazione da sorgente non è così male come sembra. Seguite questa guida e sarete subito operativi!

### Installare le dipendenze

Avremo bisogno di alcune dipendenze: alcune richieste da `lsyncd` stesso e altre necessarie per compilare i pacchetti dai sorgenti. Usate questo comando sul vostro computer Rocky Linux per assicurarvi di avere le dipendenze necessarie. Se si costruisce dai sorgenti, è una buona idea avere tutti gli strumenti di sviluppo installati:

`dnf groupinstall 'Development Tools'`

!!! warning "Per Rocky Linux 9.0"

    `lsyncd` è stato completamente testato in Rocky Linux 9.0 e funzionerà come previsto. Per poter installare tutte le dipendenze necessarie, tuttavia, è necessario abilitare un repository aggiuntivo:

    ```
    dnf config-manager --enable crb
    ```


    Eseguendo questa operazione in 9 prima delle fasi successive, si potrà terminare la costruzione senza tornare indietro.

Ecco le dipendenze necessarie per `lsyncd` stesso e per il suo processo di compilazione:

`dnf install lua lua-libs lua-devel cmake unzip wget rsync`

### Scaricare `lsyncd` e costruirlo

Poi abbiamo bisogno del codice sorgente:

`wget https://github.com/axkibe/lsyncd/archive/master.zip`

Ora decomprimere il file master.zip:

`unzip master.zip`

Verrà creata una directory chiamata "lsyncd-master". Dobbiamo passare a questa cartella e creare una cartella chiamata build:

`cd lsyncd-master`

E quindi:

`mkdir build`

Ora cambiate nuovamente directory, in modo da trovarvi nella directory di compilazione:

`cd build`

Ora eseguite questi comandi:

```
cmake ...
make
make install
```

Al termine, il binario `lsyncd` sarà installato e pronto all'uso in */usr/local/bin*

### `lsyncd` Servizio Systemd

Con il metodo di installazione RPM, il servizio systemd sarà installato per voi, ma se scegliete di installare da sorgente, dovrete creare il servizio systemd. Sebbene sia possibile avviare il binario senza il servizio systemd, vogliamo assicurarci che esso *parta* all'avvio. In caso contrario, un riavvio del server interromperà il tentativo di sincronizzazione. Se si dimenticasse di riavviarlo, cosa molto probabile, sarebbe un problema per qualsiasi amministratore di sistema!

La creazione del servizio systemd, tuttavia, non è molto difficile e a lungo andare vi farà risparmiare tempo.

#### Creare il Service File `lsyncd`

Questo file può essere creato ovunque, anche nella directory principale del server. Una volta creato, è possibile spostarlo nella posizione appropriata.

`vi /root/lsyncd.service`

Il contenuto di questo file dovrebbe essere:

```
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
Ora installiamo il file appena creato nella posizione corretta:

`install -Dm0644 /root/lsyncd.service /usr/lib/systemd/system/lsyncd.service`

Infine, ricaricare il demone `systemctl` in modo che systemd "veda" il nuovo file di servizio:

`systemctl daemon-reload`

## Configurazione di `lsyncd`

Qualunque sia il metodo scelto per installare `lsyncd`, è necessario un file di configurazione: */etc/lsyncd.conf*. La prossima sezione spiega come costruire un file di configurazione e come testarlo.

## Configurazione di Esempio per i Test

Ecco un esempio di un file di configurazione semplicistico che sincronizza */home* con un altro computer. Il nostro computer di destinazione sarà un indirizzo IP locale: *192.168.1.40*

```
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

* I file "logfile" e "statusFile" verranno creati automaticamente all'avvio del servizio.
* Lo "statusInterval" è il numero di secondi da attendere prima di scrivere sullo statusFile.
* "maxProcesses" è il numero di processi che `lsyncd` può generare. Onestamente, a meno che non si tratti di un computer molto trafficato, un processo è sufficiente.
* Nella sezione di sincronizzazione "default.rsyncssh" dice di usare rsync su SSH
* "source=" è il percorso della directory da cui si effettua la sincronizzazione.
* L'"host=" è il computer di destinazione su cui stiamo effettuando la sincronizzazione.
* L'opzione "excludeFrom=" indica a `lsyncd` dove si trova il file delle esclusioni. Deve esistere, ma può essere vuoto.
* "targetdir=" è la directory di destinazione a cui inviare i file. Nella maggior parte dei casi sarà uguale alla sorgente, ma non sempre.
* Poi abbiamo la sezione "rsync =" e queste sono le opzioni con cui eseguire rsync.
* Infine, abbiamo la sezione "ssh =", che specifica la porta SSH in ascolto sul computer di destinazione.

Se si aggiunge più di una directory da sincronizzare, è necessario ripetere l'intera sezione "sync", comprese tutte le parentesi di apertura e chiusura per ogni directory.

## Il File lsyncd.exclude

Come già detto, il file "excludeFrom" deve esistere, quindi creiamolo ora:

`touch /etc/lsyncd.exclude`

Se si stesse sincronizzando la cartella /etc del nostro computer, ci sarebbero molti file e directory da escludere. Ogni file o directory esclusa viene elencata nel file, una per riga, in questo modo:

```
/etc/hostname
/etc/hosts
/etc/networks
/etc/fstab
```

## Test e Messa in Funzione

Ora che tutto il resto è stato impostato, possiamo testare il tutto. Per cominciare, assicuriamoci che il servizio systemd lsyncd.service si avvii:

`systemctl start lsyncd`

Se non vengono visualizzati errori dopo l'esecuzione di questo comando, controllare lo stato del servizio, per sicurezza:

`systemctl status lsyncd`

Se il servizio è in esecuzione, usare tail per vedere le estremità dei due file di log e verificare che tutto sia a posto:

`tail /var/log/lsyncd.log`

E quindi:

`tail /var/log/lsyncd-status.log`

Supponendo che tutto sia corretto, spostatevi nella directory `/home/[user]`, dove `[user]` è un utente del computer e create un nuovo file con *touch*.

`touch /home/[user]/testfile`

Ora andate sul computer di destinazione e verificate se il file viene visualizzato. Se è così, tutto funziona come dovrebbe. Impostare il servizio lsyncd.service da avviare all'avvio con:

`systemctl enable lsyncd`

E siete pronti a partire.

## Ricordatevi di Essere Prudenti

Ogni volta che si sincronizza un insieme di file o directory su un altro computer, è bene considerare attentamente l'effetto che avrà sul computer di destinazione. Se si torna al **File lsyncd.exclude** dell'esempio precedente, si può immaginare cosa potrebbe accadere se */etc/fstab* venisse sincronizzato?

Per i neofiti, *fstab* è il file utilizzato per configurare le unità di archiviazione su qualsiasi computer Linux. I dischi e le etichette sono quasi certamente diversi. Al successivo riavvio del computer di destinazione, è probabile che non riesca ad avviarsi del tutto.

# Conclusioni e riferimenti

`lsyncd` è un potente strumento per la sincronizzazione delle directory tra computer. Come avete visto, non è difficile da installare e non è complesso da mantenere in seguito. Non si può chiedere di più.

Per saperne di più su `lsyncd` visitate [Il Sito Ufficiale](https://github.com/axkibe/lsyncd)
