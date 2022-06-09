- - -

title: Soluzione di backup - Rsnapshot

author: Steven Spencer

contributors: Ezequiel Bruni, Colussi Franco

tested with: 8.5, 8.6

tags:
  - backup
  - rsnapshot

- - -

# Soluzione di Backup - Rsnapshot

## Prerequisiti

  * Saper installare repository e snapshot aggiuntivi dalla riga di comando
  * Conoscere il montaggio di filesystem esterni alla macchina (disco rigido esterno, filesystem remoto, ecc.)
  * Saper usare un editor (qui si usa`vi`, ma si può usare il proprio editor preferito)
  * Conoscere un po' di scripting BASH
  * Sapere come modificare il crontab per l'utente root
  * Conoscenza delle chiavi pubbliche e private SSH (solo se si intende eseguire backup remoti da un altro server)

## Introduzione

Per installare _rsnapshot_ abbiamo bisogno del repository del software EPEL di Fedora. È possibile eseguire il backup di una macchina in locale o di più macchine, ad esempio i server, da un'unica macchina.

_rsnapshot_ utilizza `rsync` ed è scritto interamente in perl senza dipendenze della libreria, quindi non ci sono requisiti strani per installarlo. Nel caso di Rocky Linux, dovresti essere in grado di installare _rsnapshot_ semplicemente installando il repository software EPEL.

Il repository dovrebbe ora essere attivo.

## Installazione di Rsnapshot

Tutti i comandi qui mostrati si riferiscono alla riga di comando del server o della workstation, a meno che non sia indicato diversamente.

### Installazione del repository EPEL

Abbiamo bisogno del repository software EPEL di Fedora per installare _rsnapshot_. Per installare il repository, basta usare questo comando:

`sudo dnf install epel-release`

Il repository dovrebbe ora essere attivo.

### Installare il pacchetto Rsnapshot

Successivamente, installare _rsnapshot_ stesso:

`sudo dnf install rsnapshot`

Questo è il passo più importante. Per esempio:

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
## Montaggio di un'unità o di un file system per il backup

Un carattere di spazio fa fallire l'intera configurazione e il backup. Per esempio, all'inizio del file di configurazione c'è una sezione per la `# SNAPSHOT ROOT DIRECTORY #`.

1. Collegare l'unità USB.
2. Digitare `dmesg | grep sd` che dovrebbe mostrare l'unità che si desidera utilizzare. In questo caso, si chiamerà _sda1_.  
   Esempio: `EXT4-fs (sda1): mounting ext2 file system using the ext4 subsystem`.
3. Sfortunatamente (o fortunatamente, a seconda delle opinioni) la maggior parte dei moderni sistemi operativi Linux per desktop esegue il montaggio automatico dell'unità, se possibile. Ciò significa che, a seconda di vari fattori, _rsnapshot_ potrebbe perdere la traccia del disco rigido. Vogliamo che l'unità venga "montata" o che i suoi file siano sempre disponibili nello stesso posto.  
   Per farlo, prendete le informazioni sull'unità rivelata dal comando dmesg di cui sopra e digitate `mount | grep sda1`, che dovrebbe mostrare qualcosa di simile a questo: `/dev/sda1 on /media/username/8ea89e5e-9291-45c1-961d-99c346a2628a`
4. Digitare `sudo umount /dev/sda1` per smontare il disco rigido esterno.
5. Quindi, creare un nuovo punto di montaggio per il backup: `sudo mkdir /mnt/backup`
6. Ora montate l'unità nella posizione della cartella di backup: `sudo mount /dev/sda1 /mnt/backup`
7. Ora digitate nuovamente `mount | grep sda1` e dovreste vedere qualcosa di simile: `/dev/sda1 on /mnt/backup type ext2 (rw,relatime)`
8. Quindi creare una directory che deve esistere affinché il backup continui sull'unità montata. Per questo esempio utilizzeremo una cartella chiamata "storage": `sudo mkdir /mnt/backup/storage`

Si noti che per una singola macchina è necessario ripetere i passi umount e montare ogni volta che l'unità è collegato di nuovo, o ogni volta che il sistema riavvia o automatizza questi comandi con uno script.

Si consiglia l'automazione. L'automazione è il modo sysadmin.

## Configurazione di rsnapshot

In questo caso, _rsnapshot_ verrà eseguito localmente per eseguire il backup di un particolare computer. In questo esempio, scomporremo il file di configurazione e mostreremo esattamente le modifiche da apportare. La configurazione _rsnapshot_ richiede schede per ogni separazione tra elementi, e un avviso a questo effetto è nella parte superiore del file di configurazione.

Un personaggio spazio farà fallire l'intera configurazione e il backup. Per esempio, vicino alla parte superiore del file di configurazione è una sezione per il `# SNAPSHOT ROOT DIRECTORY #`. Se lo si aggiungesse da zero, si digita `snapshot_root` poi TAB e quindi digita `/whatever_the_path_to_snapshot_root_will_be/`

La cosa migliore è che la configurazione predefinita che viene fornita con _rsnapshot_ necessita solo di modifiche minori per farlo funzionare per un backup di una macchina locale. È sempre una buona idea, però, fare una copia di backup del file di configurazione prima di iniziare a modificare:

`snapshot_root   /.snapshots/`

## Backup di base della macchina o del singolo server

In questo caso, _rsnapshot_ sta per essere eseguito localmente per eseguire il backup di una particolare macchina. In questo esempio, spezzeremo il file di configurazione e ti mostreremo esattamente quello che devi cambiare.

Dovrai usare `vi` (o modificare con il tuo editor preferito) per aprire il file _/etc/rsnapshot.conf_.

La prima cosa da cambiare è l'impostazione _snapshot_root_ che per impostazione predefinita ha questo valore:

`no_create_root 1`

Dobbiamo cambiare questo punto con il nostro punto di montaggio creato in precedenza, con l'aggiunta di "storage".

`#cmd_cp         /usr/bin/cp`

Vogliamo anche dire al backup di NON eseguire se l'unità non è montata. Per fare questo, rimuovere il segno "#" (chiamato anche una osservazione, segno libbre, segno numerico, simbolo hash, ecc. accanto a no_create_root in modo che assomigli a questo:

`cmd_cp         /usr/bin/cp`

Passa poi alla sezione intitolata `# PROGRAM ESTERNA DEPENDENZE #` e rimuovi il commento (ancora, il segno "#") da questa riga:

`#cmd_ssh        /usr/bin/ssh`

E rimuovete il segno "#" in modo che appaia come questo:

`cmd_ssh        /usr/bin/ssh`

Anche se non abbiamo bisogno di cmd_ssh per questa particolare configurazione, ne avremo bisogno per la nostra altra opzione qui sotto e non fa male per averla abilitata. Quindi trovare la linea che dice:

`#cmd_ssh        /usr/bin/ssh`

Per questo esempio, non verranno eseguiti altri incrementi oltre al backup notturno, quindi è sufficiente aggiungere un'annotazione ad alfa e gamma in modo che la configurazione appaia come questa una volta terminata:

`cmd_ssh        /usr/bin/ssh`

Successivamente dobbiamo passare alla sezione intitolata `# LIVELLI BACKUP / INTERVALS #`

Questo è stato cambiato dalle versioni precedenti di _rsnapshot_ da `orario, giornaliero, mensile, annuale` a `alfa, beta, gamma, delta`. Che è un po' confusa. Quello che devi fare è aggiungere un'osservazione a qualsiasi intervallo che non utilizzerai. Nella configurazione, il delta è già stato evidenziato.

Per questo esempio, non saranno in esecuzione altri incrementi diversi da un backup notturno, quindi basta aggiungere un'osservazione all'alfa e alla gamma in modo che la configurazione assomigli a questa quando hai finito:

```
#retain  alpha   6
retain  beta    7
#retain  gamma   4
#retain delta   3
```

Ora passate alla riga del file di log, che per impostazione predefinita dovrebbe essere la seguente:

`#logfile /var/log/rsnapshot`

E rimuovere l'osservazione in modo che sia abilitato:

`logfile /var/log/rsnapshot`

Infine, salta alla sezione `### BACKUP POINTS / SCRIPTS ###` e aggiungi tutte le directory che vuoi aggiungere nella sezione `# LOCALHOST` , ricordatevi di usare TAB piuttosto che SPACE tra gli elementi!

Per ora scrivete le vostre modifiche (`SHIFT :wq!` per `vi`) e uscite dal file di configurazione.

### Controllo della Configurazione

Vogliamo assicurarci di non aggiungere spazi o altri errori lampeggianti al nostro file di configurazione durante la modifica. Per fare questo, eseguiamo _rsnapshot_ contro la nostra configurazione con l'opzione configtest:

`rsnapshot configtest` mostrerà `Sintassi OK` se non ci sono errori nella configurazione.

Si dovrebbe avere l'abitudine di eseguire configtest contro una particolare configurazione. Il motivo di ciò sarà più evidente quando entreremo nella sezione **Multiple Machine o Multiple Server Backup**.

Per eseguire configtest su un particolare file di configurazione, eseguirlo con l'opzione -c per specificare la configurazione:

`rsnapshot -c /etc/rsnapshot.conf configtest`

## Eseguire il Backup la Prima Volta

Tutto ha fatto il check out, quindi è il momento di andare avanti ed eseguire il backup per la prima volta. È possibile eseguire questo in modalità di prova prima se ti piace, in modo da poter vedere cosa lo script di backup sta per fare.

Ancora una volta, per fare questo non è necessario specificare la configurazione in questo caso, ma si dovrebbe avere l'abitudine di farlo:

`rsnapshot -c /etc/rsnapshot.conf -t beta`

Che dovrebbe restituire qualcosa di simile, mostrando cosa accadrà quando il backup è effettivamente eseguito:

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

Una volta soddisfatto del test, procedere e eseguirlo manualmente la prima volta senza il test:

`rsnapshot -c /etc/rsnapshot.conf beta`

Per ripristinare i file, non è necessario scegliere la directory o l'incremento da cui ripristinarli, ma solo la data e l'ora in cui il backup deve essere ripristinato. È un ottimo sistema e utilizza molto meno spazio su disco rispetto a molte altre soluzioni di backup.

### Ulteriori spiegazioni

Ogni volta che il backup viene eseguito, creerà un nuovo incremento beta, 0-6, o 7 giorni di backup. Il backup più recente sarà sempre beta.0 mentre il backup di ieri sarà sempre beta.1.

La dimensione di ciascuno di questi backup apparirà occupare la stessa quantità (o più) di spazio su disco, ma questo è dovuto all'uso di _rsnapshot_ dei collegamenti rigidi. Per ripristinare i file dal backup di ieri, si sarebbe semplicemente copiarli di nuovo dalla struttura directory di beta.1.

Se non avete mai eseguito questa operazione, scegliete vim.basic come editor o l'editor che preferite quando viene visualizzata la riga `Select an editor`.

Quindi, per ripristinare i file, non è necessario scegliere e scegliere quale directory o incremento per ripristinarli da, a che ora timbro il backup dovrebbe avere che si sta ripristinando. È un grande sistema e utilizza molto meno spazio su disco rispetto a molte altre soluzioni di backup.

## Impostazione dell'esecuzione automatica del backup

Una volta che tutto è stato testato e sappiamo che le cose funzioneranno senza problemi, il passo successivo è impostare il crontab per l'utente root, in modo che tutto questo possa essere fatto automaticamente ogni giorno:

`sudo crontab -e`

Se non hai eseguito questo prima, scegli vim. asic come il tuo editor o la tua preferenza di editor quando viene visualizzata la linea `Seleziona un editor`.

Stiamo per impostare il nostro backup per eseguire automaticamente a 11 PM, quindi aggiungeremo questo al crontab:

```
## Running the backup at 11 PM
00 23 *  *  *  /usr/bin/rsnapshot -c /etc/rsnapshot.conf beta`
```

## Backup di Più Macchine o Più Server

Facendo backup di più macchine da una macchina con un array RAID o una grande capacità di archiviazione, in loco o da tutta Internet funziona molto bene.

Se si è già generato un set di chiavi, si può saltare questo passaggio. È possibile scoprirlo eseguendo `ls -al .ssh` e cercando una coppia di chiavi id_rsa e id_rsa.pub.

## Presupposto

Supponiamo che tu stia eseguendo _rsnapshot_ da una macchina da remoto, on-premise. Questa esatta configurazione può essere duplicata, come indicato sopra, anche fuori sede remota.

In questo caso, si desidera installare _rsnapshot_ sulla macchina che sta facendo tutti i backup. Supponiamo anche:

* Che i server su cui si eseguirà il backup abbiano una regola del firewall che consenta alla macchina remota di accedere al server SSH
* Che ogni server di cui si intende eseguire il backup abbia installato una versione recente di `rsync`. Per i server Rocky Linux, eseguire `dnf install rsync` per aggiornare la versione di `rsync` del sistema.
* Che vi siate connessi alla macchina come utente root o che abbiate eseguito `sudo -s` per passare all'utente root.

## Chiavi Pubbliche e Private SSH

Per il server che eseguirà i backup, abbiamo bisogno di generare una coppia di tasti SSH da utilizzare durante i backup. Per il nostro esempio, creeremo chiavi RSA.

Se si dispone già di un insieme di chiavi generate, è possibile saltare questo passaggio. Puoi scoprire facendo un `ls -al .ssh` e cercando una coppia di chiavi id_rsa e id_rsa.pub. Se non esiste, utilizzare il seguente link per impostare le chiavi per la macchina e il server a cui si desidera accedere:

[Ssh Portachiavi Private Pairs](../security/ssh_public_private_keys.md)

## Configurazione di Rsnapshot

Il file di configurazione deve essere simile a quello che abbiamo creato per il **Basic Machine o il Single Server Backup** di cui sopra, tranne che vogliamo cambiare alcune delle opzioni.

... può essere nuovamente commentata:

`#no_create_root 1`

E questa linea:

`cmd_cp         /usr/bin/cp`

... può essere commentato di nuovo:

`#no_create_root 1`

L'altra differenza è che ogni macchina avrà la propria configurazione. Una volta che ci si abitua, semplicemente copiare uno dei file di configurazione esistenti su un nuovo nome e quindi modificarlo per adattarsi a qualsiasi macchina aggiuntiva che si desidera eseguire il backup.

Per ora, vogliamo modificare il file di configurazione proprio come abbiamo fatto sopra, e poi salvarlo. Quindi copiare quel file come modello per il nostro primo server:

`cp /etc/rsnapshot.conf /etc/rsnapshot_web.conf`

Ecco un esempio di configurazione di web.ourdomain.com:

`logfile /var/log/rsnapshot_web.log`

`rsnapshot -c /etc/rsnapshot_web.conf configtest`

Come in precedenza, cerchiamo il messaggio `Syntax OK`. L'unica cosa diversa è l'obiettivo.

Ecco un esempio della configurazione di web.ourdomain.com:

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

E proprio come prima, stiamo cercando il messaggio `Sintassi OK`. Se tutto va bene, possiamo eseguire il backup manualmente:

`/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta`

Supponendo che tutto funzioni bene, possiamo creare i file di configurazione per il server di posta (rsnapshot_mail.conf) e per il server del portale (rsnapshot_portal.conf), testarli ed eseguire un backup di prova.

## Automatizzare il backup

L'automazione dei backup per la versione multipla di macchina/server è leggermente diversa. Vogliamo creare uno script bash per chiamare i backup in ordine. Quando uno finirà il prossimo inizierà. Questo script assomiglia a questo e sarà memorizzato in /usr/local/sbin:

`vi /usr/local/sbin/backup_all`

Con il contenuto:

```
#!/bin/bash
# script to run rsnapshot backups in succession
/usr/bin/rsnapshot -c /etc/rsnapshot_web.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_mail.conf beta
/usr/bin/rsnapshot -c /etc/rsnapshot_portal.conf beta
```
E aggiungere questa riga:

`chmod +x /usr/local/sbin/backup_all`

Quindi creare il crontab per eseguire lo script di backup:

`crontab -e`

E aggiungere questa riga:

```
## Running the backup at 11 PM
00 23 *  *  *  /usr/local/sbin/backup_all
```

## Segnalazione dello Stato del Backup

Per assicurarsi che tutto è il backup in base alla pianificazione, si potrebbe voler inviare i file di registro di backup alla vostra e-mail. Se stai eseguendo più backup di macchine usando _rsnapshot_, ogni file di log avrà il proprio nome, che puoi quindi inviare alla tua email per la revisione [Utilizzando la procedura postfix For Server Process Reporting](../email/postfix_reporting.md).

## Ripristinare un Backup

Ripristino di un backup, alcuni file o un ripristino completo, comporta la copia dei file che si desidera dalla directory con la data che si desidera ripristinare da indietro alla macchina. Semplice!

## Conclusioni e Altre Risorse

Ottenere la configurazione giusta con _rsnapshot_ è un po 'scoraggiante in un primo momento, ma può risparmiare un sacco di tempo di backup delle macchine o server.

_rsnapshot_ è molto potente, molto veloce e molto economico nell'utilizzo dello spazio su disco. Puoi trovare maggiori informazioni su Rsnapshot, visitando [rsnapshot.org](https://rsnapshot.org/download.html)
