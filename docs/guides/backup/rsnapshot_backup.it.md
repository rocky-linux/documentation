---
title: Soluzione di Backup - Rsnapshot
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0, 10.0
tags:
  - backup
  - rsnapshot
---

## Prerequisiti

- Saper installare repository e snapshot aggiuntivi dalla riga di comando
- Conoscere il montaggio di filesystem esterni al computer (unità esterna, filesystem remoto e così via)
- Saper usare un editor (qui si usa `vi`, ma si può usare il proprio editor preferito)
- Conoscere un po' di scripting BASH
- Sapere come modificare il `crontab` per l'utente root
- Conoscenza delle chiavi pubbliche e private SSH (solo se si intende eseguire backup remoti da un altro server)

## Introduzione

`rsnapshot` è una potente utility di backup con possibilità di installazione su qualsiasi macchina basata su Linux. È possibile eseguire il backup di una macchina a livello locale oppure eseguire il backup di più macchine, come i server, da una singola macchina.

Scritto interamente in Perl, `rsnapshot` utilizza `rsync` e non ha dipendenze da librerie. Non esistono requisiti particolari per l'installazione. Nel caso di Rocky Linux, è possibile installare `rnapshot` utilizzando il repository EPEL (Extra Packages for Enterprise Linux). Se preferisci, il metodo di installazione sorgente è disponibile qui come opzione.

Questa documentazione riguarda l'installazione di `rsnapshot` solo su Rocky Linux.

=== "Installazione EPEL"

    ## Installazione di `rsnapshot`
    
    Tutti i comandi qui presenti vengono richiamati dalla riga di comando, a meno che non sia indicato diversamente.
    
    ### Installazione del repository EPEL
    
    È necessario il repository del software EPEL di Fedora. Per installare il repository, basta usare questo comando:

    ```
    sudo dnf install epel-release -y
    ```


    Il repository sarà ora attivo.
    
    ### Installare il pacchetto `rsnapshot
    
    Installare `rsnapshot` e alcuni altri strumenti necessari:

    ``` 
    sudo dnf install rsnapshot openssh-server rsync
    ```


    Se mancano delle dipendenze, queste verranno visualizzate e sarà sufficiente rispondere alla richiesta per continuare. Per esempio:

    ```
    dnf install rsnapshot rsync
    Last metadata expiration check: 2:03:40 ago on Fri 19 Sep 2025 03:54:16 PM UTC.
    Package rsync-3.4.1-2.el10.x86_64 is already installed.
    Dependencies resolved.
    ==============================================================================================================================
    Package                         Architecture            Version                             Repository                  Size
    ==============================================================================================================================
    Installing:
    rsnapshot                       noarch                  1.5.1-1.el10_0                      epel                       112 k
    Installing dependencies:
    perl-DirHandle                  noarch                  1.05-512.2.el10_0                   appstream                   12 k

    Transaction Summary
    ==============================================================================================================================
    Install  2 Packages

    Total download size: 124 k
    Installed size: 388 k
    Is this ok [y/N]: y
    ```

=== "Installazione da sorgente"

    ## Installazione di `rsnapshot` dai sorgenti
    
    Installare `rsnapshot` dai sorgenti non è difficile. Tuttavia, ha un aspetto negativo: se viene rilasciata una nuova versione, sarà necessaria una nuova installazione dai sorgenti per aggiornare la versione, mentre il metodo di installazione EPEL vi terrà aggiornati con un semplice `dnf upgrade`. 
    
    ### Installazione degli strumenti di sviluppo e download del codice sorgente
    
    Il primo passo consiste nell'installare il gruppo "Strumenti di sviluppo":

    ```
    dnf groupinstall 'Development Tools'
    ```


    Sono necessari anche alcuni altri pacchetti:

    ```
    dnf install wget unzip rsync openssh-server
    ```


    Successivamente, scarica i file sorgente dal repository GitHub. È possibile farlo in diversi modi, ma il più semplice in questo caso è probabilmente quello di scaricare il file ZIP dal repository.

    1. Vai a https://github.com/rsnapshot/rsnapshot
    2. Fare clic sul pulsante verde "Code" sulla destra ![Codice](images/code.png)
    3. Fare clic con il tasto destro del mouse su "Download ZIP" e copiare il percorso del link ![Zip](images/zip.png)
    4. Utilizzare `wget` o `curl` per scaricare il link copiato. Esempio:
    ```
    wget https://github.com/rsnapshot/rsnapshot/archive/refs/heads/master.zip
    ```
    5. Decomprimere il file `master.zip`
    ```
    unzip master.zip
    ```


    ### Creare il sorgente

    Il passo successivo è costruire. Quando si decomprime il file `master.zip`, si ottiene una directory `rsnapshot-master`. Passa a quella directory per la procedura di compilazione. Si noti che la nostra compilazione utilizza tutte le impostazioni predefinite del pacchetto, quindi se si desidera qualcosa di diverso, è necessario fare un po' di indagini. Inoltre, questi passaggi sono tratti direttamente dalla pagina di [installazione di GitHub](https://github.com/rsnapshot/rsnapshot/blob/master/INSTALL.md):

    ```bash
    cd rsnapshot-master
    ```

    Esegui lo script `autogen.sh` per generare lo script di configurazione:

    ```bash
    ./autogen.sh
    ```

    !!! tip "Suggerimento"

        Si possono ottenere diverse righe di questo tipo:

        ```bash
        fatal: not a git repository (or any of the parent directories): .git
        ```

        Non sono fatali.

    Successivamente, è necessario eseguire `configure` con la directory di configurazione impostata:

    ```bash
    ./configure --sysconfdir=/etc
    ```

    Infine, eseguire `make install`:

    ```bash
    sudo make install
    ```

    Durante tutto questo, il file `rsnapshot.conf` verrà creato come `rsnapshot.conf.default`. Copia questo file su `rsnapshot.conf` e poi modificalo in base alle tue esigenze sul nostro sistema.

    ```bash
    sudo cp /etc/rsnapshot.conf.default /etc/rsnapshot.conf
    ```

    Si tratta di copiare il file di configurazione. La sezione "Configurazione di rsnapshot" illustrerà le modifiche necessarie a questo file di configurazione.

## Montaggio di un'unità o di un filesystem per il backup

In questo passaggio viene mostrato come montare un'unità, ad esempio un'unità USB esterna, utilizzata per il backup del sistema. Questo passaggio è necessario solo se si esegue il backup di un singolo computer o server, come nel primo esempio.

1. Inserire l'unità USB.
2. Digitare `dmesg | grep sd` che mostrerà l'unità che si desidera utilizzare. In questo caso, è _sda1_.  
   Esempio: `EXT4-fs (sda1): mounting ext2 file system using the ext4 subsystem`.
3. Sfortunatamente (o fortunatamente, a seconda delle opinioni) la maggior parte dei moderni sistemi operativi Linux per desktop esegue il montaggio automatico dell'unità, se possibile. Ciò significa che, a seconda di vari fattori, `rsnapshot` potrebbe perdere la traccia dell'unità. Si desidera che l'unità venga "montata" o che i suoi file siano sempre disponibili nella stessa posizione.  
   Per farlo, prendete le informazioni sull'unità visualizzate nel comando `dmesg` e digitate `mount | grep sda1`, che dovrebbe mostrare qualcosa di simile a questo: `/dev/sda1 on /media/username/8ea89e5e-9291-45c1-961d-99c346a2628a`
4. Digitate `sudo umount /dev/sda1` per smontare l'unità esterna.
5. Quindi, creare un punto di montaggio per il backup: `sudo mkdir /mnt/backup`
6. Montare l'unità nella posizione della cartella di backup: `sudo mount /dev/sda1 /mnt/backup`
7. Digitate di nuovo `mount | grep sda1` e vedrete questo: `/dev/sda1 on /mnt/backup type ext2 (rw,relatime)`
8. Quindi creare una directory che deve esistere affinché il backup continui sull'unità montata. In questo esempio viene utilizzata una cartella denominata "storage": `sudo mkdir /mnt/backup/storage`

Per una singola macchina, dovrai ripetere i passaggi `umount` e `mount` ogni volta che colleghi l'unità o ogni volta che il sistema si riavvia, oppure automatizzare questi comandi con uno script.

Si consiglia di utilizzare l'automazione.

## Configurazione di `rsnapshot`

Questo è il passo più importante. È possibile commettere un errore quando si apportano modifiche al file di configurazione. La configurazione di `rsnapshot` richiede l'uso di tabulazioni per la separazione degli elementi e un'avvertenza in tal senso si trova all'inizio del file di configurazione.

Un carattere di spazio farà fallire l'intera configurazione e il vostro backup. Ad esempio, nella parte superiore del file di configurazione è presente una sezione dedicata alla `# SNAPSHOT ROOT DIRECTORY #`. Se lo aggiungessi da zero, dovresti digitare `snapshot_root`, quindi ++tab++ e infine `/qualunque_sia_il_percorso_della_root_dello_snapshot/`

La cosa migliore è che la configurazione predefinita inclusa in `rsnapshot` necessita solo di piccole modifiche per funzionare per il backup di una macchina locale. È sempre una buona idea, però, fare una copia di backup del file di configurazione prima di iniziare a modificarlo:

`cp /etc/rsnapshot.conf /etc/rsnapshot.conf.bak`

## Backup di base della macchina o di un singolo server

In questo caso, `rsnapshot` viene eseguito localmente per eseguire il backup di una particolare macchina. In questo esempio, la ripartizione del file di configurazione mostra esattamente le modifiche da apportare.

È necessario utilizzare `vi` (o modificare con l'editor preferito) per aprire il file `/etc/rsnapshot.conf`.

La prima cosa da modificare è l'impostazione _snapshot_root_. Il valore predefinito è questo:

```text
snapshot_root   /.snapshots/
```

È necessario cambiare questo punto con il punto di montaggio creato e aggiungere "storage".

```text
snapshot_root   /mnt/backup/storage/`
```

È inoltre necessario indicare al backup di non essere eseguito se l'unità non è montata. Per farlo, rimuovere il segno "#" (chiamato anche commento, segno numerico, simbolo hash e così via) accanto a `no_create_root`, che si presenta in questo modo:

```text
no_create_root 1
```

Successivamente, scendere alla sezione intitolata `# EXTERNAL PROGRAM DEPENDENCIES #` e rimuovere il commento (anche in questo caso, il segno "#") da questa riga:

```text
#cmd_cp         /usr/bin/cp
```

Ora si legge:

```text
cmd_cp         /usr/bin/cp
```

Sebbene non sia necessario `cmd_ssh` per questa particolare configurazione, sarà necessario per l'altra opzione e non fa male averlo abilitato. Trovare la riga che dice:

```text
#cmd_ssh        /usr/bin/ssh
```

Rimuovere il simbolo "#":

```text
cmd_ssh        /usr/bin/ssh
```

Successivamente è necessario passare alla sezione intitolata `#    BACKUP LEVELS / INTERVALS #`

Le versioni precedenti di `rsnapshot` avevano `orario, giornaliero, mensile, annuale` ma ora sono `alfa, beta, gamma, delta`. Il che è un po' confuso. È necessario aggiungere un'annotazione a tutti gli intervalli che non verranno utilizzati. Nella configurazione, il delta è già stato commentato.

In questo esempio, non si eseguiranno altri incrementi oltre al backup notturno. Basta aggiungere un commento ad alfa e gamma. Una volta completato, il file di configurazione sarà:

```text
#retain  alpha   6
retain  beta    7
#retain  gamma   4
#retain delta   3
```

Passare alla riga `logfile`, che per impostazione predefinita è:

```text
#logfile        /var/log/rsnapshot
```

Rimuovere il commento:

```text
logfile        /var/log/rsnapshot
```

Infine, passate alla sezione `### BACKUP POINTS / SCRIPTS ###` e aggiungete tutte le directory che volete aggiungere nella sezione `# LOCALHOST`, ricordando di usare ++tab++ piuttosto che ++spazio++ tra gli elementi!

Per ora scrivete le vostre modifiche (++shift+colon+“wq!”++ per `vi`) e uscite dal file di configurazione.

### Verifica della configurazione

Si vuole verificare che non siano stati aggiunti spazi o altri errori evidenti al nostro file di configurazione mentre lo si modificava. Per farlo, si esegue `rsnapshot` contro la nostra configurazione con l'opzione `configtest`:

`rsnapshot configtest` mostrerà `Syntax OK` se non ci sono errori.

Prendete l'abitudine di eseguire `configtest` con una particolare configurazione. Il motivo sarà più evidente quando si entrerà nella sezione **Backup di più macchine o più server**.

Per eseguire `configtest` con un particolare file di configurazione, eseguirlo con l'opzione `-c` per specificare la configurazione:

```bash
rsnapshot -c /etc/rsnapshot.conf configtest
```

## Esecuzione del backup la prima volta

Dopo che il `configtest` ha verificato che tutto è a posto, è il momento di eseguire il backup per la prima volta. È possibile eseguire questa operazione prima in modalità di prova, in modo da vedere cosa farà lo script di backup.

Anche in questo caso non è necessario specificare la configurazione, ma è una buona idea prendere l'abitudine di farlo:

```bash
rsnapshot -c /etc/rsnapshot.conf -t beta
```

Questo restituirà qualcosa di simile a questo, mostrando cosa succederà quando il backup verrà effettivamente eseguito:

```bash
echo 1441 > /var/run/rsnapshot.pid
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /home/ /mnt/backup/storage/beta.0/localhost/
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded /etc/ \
    /mnt/backup/storage/beta.0/localhost/
mkdir -m 0755 -p /mnt/backup/storage/beta.0/
/usr/bin/rsync -a --delete --numeric-ids --relative --delete-excluded \
    /usr/local/ /mnt/backup/storage/beta.0/localhost/
touch /mnt/backup/storage/beta.0/
```

Quando il test soddisfa le vostre aspettative, eseguitelo manualmente la prima volta senza il test:

```bash
rsnapshot -c /etc/rsnapshot.conf beta
```

Al termine del backup, andare in `/mnt/backup` ed esaminare la struttura di directory creata. Sarà presente una directory `storage/beta.0/localhost`, seguita dalle directory di backup specificate.

### Ulteriori spiegazioni

Ogni volta che il backup viene eseguito, viene creato un altro incremento beta, 0-6 o 7 giorni di backup. Il backup più recente sarà sempre beta.0, mentre il backup di ieri sarà sempre beta.1.

Le dimensioni di ciascuno di questi backup sembreranno occupare la stessa quantità (o più) di spazio su disco, ma ciò è dovuto agli hard links utilizzati da `rsnapshot`. Per ripristinare i file dal backup di ieri, è sufficiente copiarli di nuovo dalla struttura di directory della beta.1.

Ogni backup è solo un backup incrementale rispetto all'esecuzione precedente, MA, grazie all'uso di collegamenti diretti, ogni directory di backup contiene il file o il collegamento diretto al file nella directory in cui è stato effettivamente eseguito il backup.

Per ripristinare i file, non è necessario decidere la directory o l'incremento da cui ripristinarli, ma solo il timestamp del backup che si desidera ripristinare. È un ottimo sistema e utilizza molto meno spazio su disco rispetto a molte altre soluzioni di backup.

## Impostazione dell'esecuzione automatica del backup

Una volta completati i test e sicuri che le cose funzioneranno senza problemi, il passo successivo è impostare `crontab` per l'utente root per automatizzare il processo ogni giorno:

```bash
sudo crontab -e
```

Se non si e' mai eseguito questa operazione, si scelga “vim.basic” come editor o l'editor preferito quando appare la riga `Seleziona un editor`.

Si intende impostare il backup in modo che venga eseguito automaticamente alle 23:00, quindi si aggiungerà questa voce a `crontab`:

```bash
## Running the backup at 11 PM
00 23 *  *  *  /usr/bin/rsnapshot -c /etc/rsnapshot.conf beta`
```

## Backup di più macchine o più server

Eseguire backup di più macchine da una macchina con un array RAID o un'unità con grande capacità di archiviazione, in loco o da una connessione Internet altrove, funziona bene.

Se i backup vengono eseguiti via Internet, è necessario assicurarsi che ogni sede disponga di una larghezza di banda adeguata per l'esecuzione dei backup. È possibile utilizzare `rsnapshot` per sincronizzare un server in sede con un array di backup o un server di backup fuori sede per migliorare la ridondanza dei dati.

## Presupposto

Eseguire di `rsnapshot` da una macchina in remoto, in sede. È possibile eseguire questa configurazione anche da remoto, fuori sede.

In questo caso, si dovrà installare `rsnapshot` sul computer che esegue tutti i backup. Altre ipotesi sono:

- Che i server su cui si eseguirà il backup abbiano una regola del firewall che consenta alla macchina remota di accedere al server SSH
- Che ogni server di cui si intende eseguire il backup abbia installato una versione recente di `rsync`. Per i server Rocky Linux, eseguire `dnf install rsync` per aggiornare la versione di `rsync` del sistema.
- Che ci si sia connessi alla macchina come utente root, o che si sia eseguito `sudo -s` per passare all'utente root

## Chiavi Pubbliche e Private SSH

Per il server che eseguirà i backup, è necessario generare una coppia di chiavi SSH da utilizzare durante i backup. Per il nostro esempio, creerai delle chiavi RSA.

Se si è già generato un set di chiavi, si può saltare questo passaggio. È possibile verificarlo eseguendo il comando `ls -al .ssh` e cercando la coppia di chiavi `id_rsa` e `id_rsa.pub`. Se non esistono, utilizzate il seguente link per impostare le chiavi per il vostro computer e per i server a cui volete accedere:

[Coppie di chiavi pubbliche private SSH](../security/ssh_public_private_keys.md)

## Configurazione di `rsnapshot`

Il file di configurazione deve essere quasi identico a quello creato per il **backup della macchina di base o del server singolo**, tranne che per la modifica di alcune opzioni.

La snapshot root è l'impostazione predefinita:

```text
snapshot_root   /.snapshots/
```

Commentare questa riga:

```text
no_create_root 1
#no_create_root 1
```

L'altra differenza è che ogni macchina avrà la propria configurazione. Quando avrai preso confidenza con questa procedura, ti basterà copiare uno dei tuoi file di configurazione esistenti con un nome diverso e modificarlo in modo che si adatti a qualsiasi macchina aggiuntiva di cui desideri eseguire il backup.

Per ora, devi modificare il file di configurazione e salvarlo. Copiate questo file come modello per il nostro primo server:

```bash
cp /etc/rsnapshot.conf /etc/rsnapshot_web.conf
```

Modifica il file di configurazione e crea il log e il `file di blocco` con il nome della macchina:

```text
logfile /var/log/rsnapshot_web.log
lockfile        /var/run/rsnapshot_web.pid
```

Successivamente, si deve modificare `rsnapshot_web.conf` per includere le directory di cui si vuole eseguire il backup. L'unica cosa diversa è l'obiettivo.

Ecco un esempio di configurazione di `web.ourdomain.com`:

```bash
### BACKUP POINTS / SCRIPTS ###
backup  root@web.ourourdomain.com:/etc/     web.ourourdomain.com/
backup  root@web.ourourdomain.com:/var/www/     web.ourourdomain.com/
backup  root@web.ourdomain.com:/usr/local/     web.ourdomain.com/
backup  root@web.ourdomain.com:/home/     web.ourdomain.com/
backup  root@web.ourdomain.com:/root/     web.ourdomain.com/
```

### Verifica della configurazione ed esecuzione del backup iniziale

Ora è possibile verificare la configurazione per assicurarsi che sia sintatticamente corretta:

```bash
rsnapshot -c /etc/rsnapshot_web.conf configtest
```

Si sta cercando il messaggio `Syntax OK`. Se tutto è a posto, è possibile eseguire il backup manualmente:

```bash
/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta
```

Supponendo che tutto funzioni, è possibile creare i file di configurazione per il server di posta (`rsnapshot_mail.conf`) e per il server del portale (`rsnapshot_portal.conf`), testarli ed eseguire un backup di prova.

## Automatizzare il backup

L'automazione dei backup per la versione per più macchine o server è leggermente diversa. Si vuole creare uno script bash per richiamare i backup in ordine. Quando uno finisce, inizia il successivo. Lo script avrà un aspetto simile a:

```bash
vi /usr/local/sbin/backup_all
```

Con il contenuto:

```bash
#!/bin/bash/
# script to run rsnapshot backups in succession
/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_mail.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_portal.conf beta
```

Salvate lo script in `/usr/local/sbin` e rendetelo eseguibile:

```bash
chmod +x /usr/local/sbin/backup_all
```

Creare la `crontab` per root per eseguire lo script di backup:

```bash
crontab -e
```

Aggiungere questa riga:

```bash
## Running the backup at 11 PM
00 23 *  *  *  /usr/local/sbin/backup_all
```

## Segnalazione dello stato del backup

Per assicurarsi che il backup avvenga secondo i piani, si consiglia di inviare i file di registro del backup all'indirizzo e-mail. Se si eseguono backup di più macchine utilizzando `rsnapshot`, ogni file di registro avrà il proprio nome, che potrà essere inviato alla propria e-mail per la revisione mediante la procedura [Usando postfix per il reporting dei processi del server](../email/postfix_reporting.md).

## Ripristino di un backup

Il ripristino di alcuni file o di un intero backup comporta la copia dei file desiderati dalla directory con la data (timestamp) da cui si desidera eseguire il ripristino, nuovamente sul computer.

## Conclusioni e altre risorse

La configurazione corretta di `rsnapshot` è un po' scoraggiante all'inizio, ma può far risparmiare molto tempo per il backup di macchine o server.

`rsnapshot` è potente, veloce ed economico nell'utilizzo dello spazio su disco. Per saperne di più su `rsnapshot`, visitate [il github di rsnapshot](https://github.com/rsnapshot/rsnapshot).
