---
title: Soluzione di Backup - Rsnapshot
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.5, 8.6, 9.0
tags:
  - backup
  - rsnapshot
---

# Soluzione di Backup - _rsnapshot_

## Prerequisiti

  * Saper installare repository e snapshot aggiuntivi dalla riga di comando
  * Conoscere il montaggio di filesystem esterni alla macchina (disco rigido esterno, filesystem remoto, ecc.)
  * Saper usare un editor (qui si usa`vi`, ma si può usare il proprio editor preferito)
  * Conoscere un po' di scripting BASH
  * Sapere come modificare il crontab per l'utente root
  * Conoscenza delle chiavi pubbliche e private SSH (solo se si intende eseguire backup remoti da un altro server)

## Introduzione

_rsnapshot_ è un'utilità di backup molto potente che può essere installata su qualsiasi macchina basata su Linux. È possibile eseguire il backup di una macchina in locale o di più macchine, ad esempio i server, da un'unica macchina.

_rsnapshot_ utilizza `rsync` ed è scritto interamente in perl senza dipendenze da librerie, quindi non ci sono requisiti strani per l'installazione. Nel caso di Rocky Linux, in genere si dovrebbe essere in grado di installare _rnapshot_ utilizzando il repository EPEL. Dopo il rilascio iniziale di Rocky Linux 9.0, c'è stato un periodo in cui EPEL non conteneva il pacchetto _rsnapshot_. Il problema è stato risolto, ma abbiamo incluso un metodo di installazione da sorgenti nel caso in cui ciò dovesse accadere di nuovo.

Questa documentazione riguarda l'installazione di _rsnapshot_ solo su Rocky Linux.

=== "Installazione EPEL"

    ## Installazione di _rsnapshot_
    
    Tutti i comandi qui mostrati sono richiamati dalla riga di comando sul server o sulla workstation, a meno che non sia indicato diversamente.
    
    ### Installazione del repository EPEL
    
    Per installare _rsnapshot_ abbiamo bisogno del repository EPEL di Fedora. Per installare il repository, basta usare questo comando:

    ```
    sudo dnf install epel-release
    ```


    Il repository dovrebbe ora essere attivo.
    
    ### Installare il pacchetto _rsnapshot
    
    Successivamente, installate _rsnapshot_ e alcuni altri strumenti necessari, che probabilmente sono già installati:

    ``` 
    sudo dnf install rsnapshot openssh-server rsync
    ```


    Se mancano delle dipendenze, queste verranno visualizzate e sarà sufficiente rispondere alla richiesta per continuare. Per esempio:

    ```
    dnf install rsnapshot
    Last metadata expiration check: 0:00:16 ago on Mon Feb 22 00:12:45 2021.
    Dependencies resolved.
    ========================================================================================================================================
    Package                           Architecture                 Version                              Repository                    Size
    ========================================================================================================================================
    Installing:
    rsnapshot                         noarch                       1.4.3-1.el8                          epel                         121 k
    Installing dependencies:
    perl-Lchown                       x86_64                       1.01-14.el8                          epel                          18 k
    rsync                             x86_64                       3.1.3-9.el8                          baseos                       404 k

    Transaction Summary
    ========================================================================================================================================
    Install  3 Packages

    Total download size: 543 k
    Installed size: 1.2 M
    Is this ok [y/N]: y
    ```

=== "Installazione da sorgente"

    ## Installazione di _rsnapshot_ da sorgente
    
    Installare _rsnapshot_ dai sorgenti non è difficile. Questo metodo ha però un lato negativo: se viene rilasciata una nuova versione, è necessaria una nuova installazione dai sorgenti per aggiornare la versione, mentre il metodo di installazione di EPEL permette di rimanere aggiornati con un semplice `dnf upgrade`. 
    
    ### Installazione degli strumenti di sviluppo e download del sorgente
    
    Come detto, il primo passo da fare è installare il gruppo 'Development Tools':

    ```
    dnf groupinstall 'Development Tools'
    ```


    Sono necessari anche alcuni altri pacchetti:

    ```
    dnf install wget unzip rsync openssh-server
    ```


    Successivamente dovremo scaricare i file sorgente dal repository GitHub. È possibile farlo in diversi modi, ma il più semplice in questo caso è probabilmente quello di scaricare il file ZIP dal repository.

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


    ### Costruire la Risorsa

    Ora che abbiamo tutto sulla nostra macchina, il passo successivo è quello di costruire. Quando abbiamo decompresso il file `master.zip`, abbiamo ottenuto una cartella `rsnapshot-master`. Dovremo entrare in questa per la nostra procedura di costruzione. Si noti che la nostra compilazione utilizza tutte le impostazioni predefinite del pacchetto, quindi se si desidera qualcosa di diverso, è necessario fare un po' di indagini. Inoltre, questi passaggi sono tratti direttamente dalla pagina di [installazione di GitHub](https://github.com/rsnapshot/rsnapshot/blob/master/INSTALL.md):

    ```
    cd rsnapshot-master
    ```

    Eseguire lo script `autogen.sh` per generare lo script di configurazione:

    ```
    ./autogen.sh
    ```

    !!! tip "Suggerimento"

        Si possono ottenere diverse righe di questo tipo:

        ```
        fatal: not a git repository (or any of the parent directories): .git
        ```

        Non sono fatali.

    Successivamente, occorre eseguire `configure` con la directory di configurazione impostata:

    ```
    ./configure --sysconfdir=/etc
    ```

    Infine, eseguire `make install`:

    ```
    sudo make install
    ```

    Durante tutto questo, il file `rsnapshot.conf` verrà creato come `rsnapshot.conf.default`. È necessario copiare questo file in `rsnapshot.conf` e modificarlo per adattarlo alle esigenze del nostro sistema.

    ```
    sudo cp /etc/rsnapshot.conf.default /etc/rsnapshot.conf
    ```

    Si tratta di copiare il file di configurazione. La sezione "Configurazione di rsnapshot" illustrerà le modifiche necessarie a questo file di configurazione.

## Montaggio di un'unità o di un file system per il backup

In questa fase viene mostrato come montare un disco rigido, ad esempio un disco rigido USB esterno, che verrà utilizzato per il backup del sistema. Questo passaggio è necessario solo se si esegue il backup di un singolo computer o server, come nel primo esempio riportato di seguito.

1. Collegare l'unità USB.
2. Digitare `dmesg | grep sd` che dovrebbe mostrare l'unità che si desidera utilizzare. In questo caso, si chiamerà _sda1_.  
   Esempio: `EXT4-fs (sda1): mounting ext2 file system using the ext4 subsystem`.
3. Sfortunatamente (o fortunatamente, a seconda delle opinioni) la maggior parte dei moderni sistemi operativi Linux per desktop esegue il montaggio automatico dell'unità, se possibile. Ciò significa che, a seconda di vari fattori, _rsnapshot_ potrebbe perdere la traccia del disco rigido. Vogliamo che l'unità venga "montata" o che i suoi file siano sempre disponibili nello stesso posto.  
   Per farlo, prendete le informazioni sull'unità rivelate dal comando `dmesg` di cui sopra e digitate `mount | grep sda1`, che dovrebbe mostrare qualcosa di simile a questo: `/dev/sda1 on /media/username/8ea89e5e-9291-45c1-961d-99c346a2628a`
4. Digitare `sudo umount /dev/sda1` per smontare il disco rigido esterno.
5. Quindi, creare un nuovo punto di montaggio per il backup: `sudo mkdir /mnt/backup`
6. Ora montate l'unità nella posizione della cartella di backup: `sudo mount /dev/sda1 /mnt/backup`
7. Ora digitate nuovamente `mount | grep sda1` e dovreste vedere qualcosa di simile: `/dev/sda1 on /mnt/backup type ext2 (rw,relatime)`
8. Quindi creare una directory che deve esistere affinché il backup continui sull'unità montata. Per questo esempio utilizzeremo una cartella chiamata "storage": `sudo mkdir /mnt/backup/storage`

Si noti che per una singola macchina, sarà necessario ripetere le operazioni di `umount` e `mount` ogni volta che l'unità viene ricollegata o ogni volta che il sistema si riavvia, oppure automatizzare questi comandi con uno script.

Raccomandiamo l'automazione. L'automazione è la via del sysadmin.

## Configurazione di rsnapshot

Questo è il passo più importante. È facile commettere un errore quando si apportano modifiche al file di configurazione. La configurazione di _rsnapshot_ richiede l'uso di tabulazioni per la separazione tra gli elementi e un'avvertenza in tal senso si trova all'inizio del file di configurazione.

Un carattere di spazio farà fallire l'intera configurazione e il vostro backup. Per esempio, all'inizio del file di configurazione c'è una sezione per la `# SNAPSHOT ROOT DIRECTORY #`. Se lo si aggiungesse da zero, si dovrebbe digitare `snapshot_root`, poi TAB e quindi digitare `/qualunque_percorso_per_la_root_di_snapshot/`

La cosa migliore è che la configurazione predefinita fornita con _rsnapshot_ richiede solo piccole modifiche per far funzionare il backup di una macchina locale. È sempre una buona idea, però, fare una copia di backup del file di configurazione prima di iniziare a modificarlo:

`cp /etc/rsnapshot.conf /etc/rsnapshot.conf.bak`

## Backup di base della macchina o del singolo server

In questo caso, _rsnapshot_ verrà eseguito localmente per eseguire il backup di un particolare computer. In questo esempio, scomporremo il file di configurazione e mostreremo esattamente le modifiche da apportare.

Per aprire il file _/etc/rsnapshot.conf_ è necessario utilizzare `vi` (o modificare con il proprio editor preferito).

La prima cosa da modificare è l'impostazione _snapshot_root_, che per impostazione predefinita ha questo valore:

`snapshot_root   /.snapshots/`

Dobbiamo cambiare questo punto con il nostro punto di montaggio creato in precedenza, con l'aggiunta di "storage".

`snapshot_root   /mnt/backup/storage/`

Vogliamo anche dire al backup di NON essere eseguito se l'unità non è montata. Per fare ciò, rimuovete il segno "#" (chiamato anche commento, segno di cancelletto, segno di numero, simbolo di hash, ecc.) accanto a `no_create_root`, in modo da ottenere l'aspetto seguente:

`no_create_root 1`

Quindi scendete alla sezione intitolata `# EXTERNAL PROGRAM DEPENDENCIES #` e rimuovete il commento (di nuovo, il segno "#") da questa riga:

`#cmd_cp         /usr/bin/cp`

Così che ora si legge:

`cmd_cp         /usr/bin/cp`

Anche se non abbiamo bisogno di `cmd_ssh` per questa particolare configurazione, ne avremo bisogno per l'altra opzione che segue e non fa male averla abilitata. Trovate quindi la riga che dice:

`#cmd_ssh        /usr/bin/ssh`

E rimuovete il segno "#" in modo che appaia come questo:

`cmd_ssh        /usr/bin/ssh`

Poi dobbiamo passare alla sezione intitolata `#     BACKUP LEVELS / INTERVALS         #`

Rispetto alle versioni precedenti di _rsnapshot_ è stato cambiato da `hourly, daily, monthly, yearly` in `alfa, beta, gamma, delta`. Il che è un po' confuso. È necessario aggiungere un'annotazione a tutti gli intervalli che non verranno utilizzati. Nella configurazione, il delta è già stato commentato.

Per questo esempio, non verranno eseguiti altri incrementi oltre al backup notturno, quindi è sufficiente aggiungere un'annotazione ad alfa e gamma in modo che la configurazione appaia come questa una volta terminata:

```
#retain  alpha   6
retain  beta    7
#retain  gamma   4
#retain delta   3
```

Ora passate alla riga del file di log, che per impostazione predefinita dovrebbe essere la seguente:

`#logfile        /var/log/rsnapshot`

E rimuovete il commento in modo che sia abilitato:

`logfile        /var/log/rsnapshot`

Infine, passate alla sezione `### BACKUP POINTS / SCRIPTS ###` e aggiungete tutte le directory che volete aggiungere nella sezione `# LOCALHOST`, ricordando di usare TAB anziché SPAZIO tra gli elementi!

Per ora scrivete le vostre modifiche (`SHIFT :wq!` per `vi`) e uscite dal file di configurazione.

### Controllo della Configurazione

Vogliamo assicurarci di non aver aggiunto spazi o altri errori evidenti al nostro file di configurazione mentre lo stavamo modificando. Per fare ciò, si esegue _rsnapshot_ con la nostra configurazione con l'opzione `configtest`:

`rsnapshot configtest` mostrerà `Syntax OK` se non ci sono errori nella configurazione.

Si dovrebbe prendere l'abitudine di eseguire `configtest` con una particolare configurazione. Il motivo sarà più evidente quando entreremo nella sezione **Backup di più Macchine o più Server**.

Per eseguire `configtest` con un particolare file di configurazione, è necessario eseguirlo con l'opzione -c per specificare la configurazione:

`rsnapshot -c /etc/rsnapshot.conf configtest`

## Eseguire il Backup la Prima Volta

Tutto è stato verificato, quindi è il momento di eseguire il backup per la prima volta. Se si vuole, si può eseguire prima in modalità di prova, in modo da vedere cosa farà lo script di backup.

Anche in questo caso non è necessario specificare la configurazione, ma si dovrebbe prendere l'abitudine di farlo:

`rsnapshot -c /etc/rsnapshot.conf -t beta`

Il risultato dovrebbe essere simile a questo, mostrando cosa accadrà quando il backup verrà effettivamente eseguito:

```
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

Una volta soddisfatti del test, procedere all'esecuzione manuale della prima volta senza il test:

`rsnapshot -c /etc/rsnapshot.conf beta`

Al termine del backup, navigare in /mnt/backup e dare un'occhiata alla struttura di directory che è stata creata. Ci sarà una directory `storage/beta.0/localhost`, seguita dalle directory specificate per il backup.

### Ulteriori spiegazioni

Ogni volta che viene eseguito il backup, viene creato un nuovo incremento beta, 0-6 o 7 giorni di backup. Il backup più recente sarà sempre beta.0, mentre il backup di ieri sarà sempre beta.1.

Le dimensioni di ciascuno di questi backup sembreranno occupare la stessa quantità (o più) di spazio su disco, ma ciò è dovuto all'uso di hard link _da parte di rsnapshot_. Per ripristinare i file dal backup di ieri, è sufficiente copiarli di nuovo dalla struttura di directory della beta.1.

Ogni backup è solo un backup incrementale rispetto all'esecuzione precedente, MA, grazie all'uso dei collegamenti diretti, ogni directory di backup contiene il file o il collegamento diretto al file nella directory in cui è stato effettivamente eseguito il backup.

Per ripristinare i file, non è necessario scegliere la directory o l'incremento da cui ripristinarli, ma solo la data e l'ora in cui il backup deve essere ripristinato. È un ottimo sistema e utilizza molto meno spazio su disco rispetto a molte altre soluzioni di backup.

## Impostazione dell'esecuzione automatica del backup

Una volta che tutto è stato testato e sappiamo che le cose funzioneranno senza problemi, il passo successivo è impostare il crontab per l'utente root, in modo che tutto questo possa essere fatto automaticamente ogni giorno:

`sudo crontab -e`

Se non avete mai eseguito questa operazione, scegliete vim.basic come editor o l'editor che preferite quando viene visualizzata la riga `Select an editor`.

Vogliamo impostare il nostro backup in modo che venga eseguito automaticamente alle 23:00, quindi lo aggiungeremo al crontab:

```
## Running the backup at 11 PM
00 23 *  *  *  /usr/bin/rsnapshot -c /etc/rsnapshot.conf beta`
```

## Backup di Più Macchine o Più Server

L'esecuzione di backup di più macchine da una macchina con un array RAID o una grande capacità di archiviazione, in sede o da Internet, funziona molto bene.

Se si eseguono questi backup da Internet, è necessario assicurarsi che entrambe le sedi dispongano di una larghezza di banda adeguata per l'esecuzione dei backup. È possibile utilizzare _rsnapshot_ per sincronizzare un server in sede con un array di backup o un server di backup fuori sede per migliorare la ridondanza dei dati.

## Presupposto

Si presume che si stia eseguendo _rsnapshot_ da un computer remoto, in sede. Questa esatta configurazione può essere duplicata, come indicato sopra, anche in remoto fuori sede.

In questo caso, è necessario installare _rsnapshot_ sul computer che esegue tutti i backup. Stiamo anche ipotizzando:

* Che i server su cui si eseguirà il backup abbiano una regola del firewall che consenta alla macchina remota di accedere al server SSH
* Che ogni server di cui si intende eseguire il backup abbia installato una versione recente di `rsync`. Per i server Rocky Linux, eseguire `dnf install rsync` per aggiornare la versione di `rsync` del sistema.
* Che vi siate connessi alla macchina come utente root o che abbiate eseguito `sudo -s` per passare all'utente root.

## Chiavi Pubbliche e Private SSH

Per il server che eseguirà i backup, è necessario generare una coppia di chiavi SSH da utilizzare durante i backup. Per il nostro esempio, creeremo chiavi RSA.

Se si è già generato un set di chiavi, si può saltare questo passaggio. È possibile scoprirlo eseguendo `ls -al .ssh` e cercando una coppia di chiavi `id_rsa` e `id_rsa.pub.`  Se non esistono, utilizzate il seguente link per impostare le chiavi per il vostro computer e per i server a cui volete accedere:

[Coppie di Chiavi Private Pubbliche SSH](../security/ssh_public_private_keys.md)

## Configurazione di _rsnapshot_

Il file di configurazione deve essere identico a quello creato per la **Macchina di Base o per il Backup di un Singolo Server**, tranne che per la modifica di alcune opzioni.

La radice dell'istantanea può essere riportata al valore predefinito in questo modo:

`snapshot_root   /.snapshots/`

E questa riga:

`no_create_root 1`

... può essere nuovamente commentata:

`#no_create_root 1`

L'altra differenza è che ogni macchina avrà una propria configurazione. Una volta che ci si è abituati, è sufficiente copiare uno dei file di configurazione esistenti con un nuovo nome e modificarlo per adattarlo alle macchine aggiuntive di cui si desidera eseguire il backup.

Per ora, vogliamo modificare il file di configurazione come abbiamo fatto sopra e poi salvarlo. Quindi copiare il file come modello per il nostro primo server:

`cp /etc/rsnapshot.conf /etc/rsnapshot_web.conf`

Si vuole modificare il nuovo file di configurazione e creare il log e il lockfile con il nome della macchina:

`logfile /var/log/rsnapshot_web.log`

`lockfile        /var/run/rsnapshot_web.pid`

Successivamente, si vuole modificare rsnapshot_web.conf in modo che includa le directory di cui si vuole fare il backup. L'unica cosa diversa è l'obiettivo.

Ecco un esempio di configurazione di web.ourdomain.com:

```
### BACKUP POINTS / SCRIPTS ###
backup  root@web.ourourdomain.com:/etc/     web.ourourdomain.com/
backup  root@web.ourourdomain.com:/var/www/     web.ourourdomain.com/
backup  root@web.ourdomain.com:/usr/local/     web.ourdomain.com/
backup  root@web.ourdomain.com:/home/     web.ourdomain.com/
backup  root@web.ourdomain.com:/root/     web.ourdomain.com/
```

### Controllo della Configurazione ed Esecuzione del Backup Iniziale

Come in precedenza, ora possiamo verificare la configurazione per assicurarci che sia sintatticamente corretta:

`rsnapshot -c /etc/rsnapshot_web.conf configtest`

Come in precedenza, cerchiamo il messaggio `Syntax OK`. Se tutto è a posto, possiamo eseguire il backup manualmente:

`/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta`

Supponendo che tutto funzioni bene, possiamo creare i file di configurazione per il server di posta (rsnapshot_mail.conf) e per il server del portale (rsnapshot_portal.conf), testarli ed eseguire un backup di prova.

## Automatizzare il Backup

L'automazione dei backup per la versione con più macchine/server è leggermente diversa. Vogliamo creare uno script bash per richiamare i backup in ordine. Quando uno finisce, inizia il successivo. Questo script avrà un aspetto simile a questo e sarà memorizzato in /usr/local/sbin:

`vi /usr/local/sbin/backup_all`

Con il contenuto:

```
#!/bin/bash/
# script to run rsnapshot backups in succession
/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_mail.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_portal.conf beta
```
Poi rendiamo lo script eseguibile:

`chmod +x /usr/local/sbin/backup_all`

Quindi creiamo il crontab per root per eseguire lo script di backup:

`crontab -e`

E aggiungere questa riga:

```
## Running the backup at 11 PM
00 23 *  *  *  /usr/local/sbin/backup_all
```

## Segnalazione dello Stato del Backup

Per assicurarsi che il backup avvenga secondo i piani, si consiglia di inviare i file di registro del backup all'indirizzo e-mail. Se si stanno eseguendo backup di più macchine utilizzando _rsnapshot_, ogni file di registro avrà il proprio nome, che potrà essere inviato all'indirizzo e-mail per la revisione utilizzando la procedura [Utilizzo di postfix per la Segnalazione dei Processi del Server](../email/postfix_reporting.md).

## Ripristino di un Backup

Il ripristino di un backup, di alcuni file o di un ripristino completo, comporta la copia dei file desiderati dalla directory con la data di ripristino al computer. Semplice!

## Conclusioni e altre risorse

La configurazione corretta di _rsnapshot_ è un po' scoraggiante all'inizio, ma può far risparmiare molto tempo per il backup delle macchine o dei server.

_rsnapshot_ è molto potente, molto veloce e molto economico per quanto riguarda l'utilizzo dello spazio su disco. Per ulteriori informazioni su _rsnapshot_, visitare il sito [rsnapshot.org](https://rsnapshot.org/download.html)
