- - -
Title:  Lab 3 - Auditing the System author: Wale Soyinka contributors: Steven Spencer, Ganna Zhyrnova
- - -

# Laboratorio 3: Auditing del Sistema

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di:

- creare da zero uno strumento di auditing semplice e personalizzato
- utilizzare e comprendere strumenti di verifica della sicurezza come Tripwire

Tempo stimato per completare questo laboratorio: 90 minuti

## Un semplice programma di controllo dell'integrità

Prima di installare e configurare Tripwire, creiamo uno script di esempio che svolge una funzione simile. Questo script aiuterà a comprendere meglio il funzionamento di Tripwire e di strumenti simili.

Lo script si basa principalmente sul programma md5sum. Il programma md5sum viene utilizzato per calcolare una somma di controllo (o "impronta digitale") a 128 bit per un FILE specificato.

Le funzioni dello script sono riassunte di seguito:

1. Subito dopo l'installazione del sistema di base, alcuni dei file di configurazione del sistema nella directory /etc verranno sottoposti a backup in una directory denominata  etc.bak nella directory home di root.

    In particolare, verrà eseguito il backup di tutti i file presenti in /etc con il suffisso "*.conf"

    Lo fa quando viene eseguito con l'opzione di inizializzazione ( -- initialization| -i)

2. Lo script otterrà quindi le checksum md5 dei file idonei noti (file non contaminati).

3. L'elenco delle somme MD5 sarà memorizzato in un file chiamato "md5_good".

4. Quando lo script viene eseguito in modalità di verifica, il programma md5sum viene richiamato con l'opzione " - -check" per controllare le somme MD5 correnti rispetto a un elenco dato (il file md5_good).

    Lo script stamperà il risultato della verifica nell'output standard e invierà una copia del risultato via e-mail al superutente.

5. Ogni volta che vengono apportate modifiche (legali o illegali) ai file di configurazione presenti in /etc, lo script può essere richiamato con l'opzione `--rebuild| -r` per approvare le modifiche e ricostruire il pseudo database di base.

6. È possibile eseguire periodicamente lo script manualmente o creare un cron job per eseguirlo automaticamente.

Lo script seguente può essere perfezionato e scalato per fare molto di più di quello che fa. Spetta a voi e alla vostra immaginazione fargli fare quello che volete.

Se volete solo un modo rapido e pratico per svolgere il lavoro, lo script sarà sufficiente, ma per tutto il resto c'è Tripwire.

## Esercizio 1

1. Accedere come root e lanciare l'editor di testo desiderato. Inserisci il testo qui sotto:

```bash

#!/bin/sh
# This script checks for changes in the MD5 sums of files named "/etc/*.conf"

case $1 in
    -i|--initialize)
        # This section will run if the script is run in an initialization mode
        # Delete old directory, make directory, backup good files, and change directory to /root/etc.bak

        rm -rf /root/etc.bak
        mkdir /root/etc.bak
        cp /etc/*.conf /root/etc.bak
        cd /root/etc.bak

        # Create our baseline file containing a list of good MD5 sums

        for i in /etc/*.conf; do
            md5sum $i >> md5_good
        done
        echo -e "\nUntainted baseline file (~/etc.bak/md5_good) has been created !!\n"
        ;;

    -v|--verify)
        # This section will run if the script is called in a verify mode
        cd /root/etc.bak

        # Check if there is any file containing output from a previous run

        if [ -f md5_diffs ]; then
            rm -f md5_diffs # if it exists we delete it
        fi

        # We re-create the file with a pretty sub-heading and some advice

        echo -e "\n **** Possibly tainted File(s) ****\n" > md5_diffs

        # Run the md5sum program against a known good list i.e. "md5_good" file

        md5sum -c md5_good 2> /dev/null | grep FAILED >> md5_diffs
        if [ $? -ge 1 ]; then
            echo "Nothing wrong here."
        else
            # Append some helpful text to the md5_diffs file

            echo -e "\nUpdate the baseline file if you approve of the changes to the file(s) above \n" >> md5_diffs
            echo -e "Re-run the script with the re-build option (e.g. ./check.sh --rebuild) to approve \n" >> md5_diffs

            cat md5_diffs # print the md5_diffs file to the display
            if [ -x /usr/bin/mail ]; then
                mail -s "Changed Files" root < md5_diffs # also e-mail the md5_diffs file to root
            fi
        fi
        ;;

    -r|--rebuild)
        # This section is for re-building the Baseline file just in case
        # the changes to the configuration files are legal and sanctioned

        cd /root/etc.bak/
        mv md5_good md5_good.bak # make a backup copy of the current untainted baseline file

        for j in /etc/*.conf; do
            md5sum $j >> md5_good
        done
        echo -e "\nBaseline file updated with approved changes !!!\n"
        ;;

    *)
        echo "This script accepts: only ( -i|--initialize or -v|--verify or -r|--rebuild ) parameters"
        ;;
esac

```

Salvate il testo qui sopra in un file di testo e nominatelo "check.sh"

### Per utilizzare lo script check.sh

1. Creare una cartella nella home directory di root chiamata "scripts"

2. Copiate lo script creato in precedenza nella cartella degli script.

3. Rendete lo script eseguibile.

4. Eseguire lo script con l'opzione di inizializzazione. Digitare:

    ```bash
    [root@localhost scripts]# ./check.sh -i

    Untainted baseline file (~/etc.bak/md5_good) has been created !!
    ```

5. Usare il comando `ls` per visualizzare il contenuto della home directory di root. Dovrebbe esserci una nuova directory denominata `etc.bak`. Usate il comando `cat` per visualizzare il file `/root/etc.bak/md5_good`.

6. Eseguire lo script utilizzando l'opzione verify. Digitare:

    ```bash
    [root@localhost scripts]# ./check.sh -v

    Nothing wrong here.
    ```

    Se tutto è a posto, si dovrebbe ottenere l'output di cui sopra.

7. Si modificheranno deliberatamente i file `/etc/kdump.conf` nella directory `/etc`. Digitare:

    ```bash
    [root@localhost scripts]# echo "# This is just a test" >> /etc/kdump.conf
    ```

8. Ora eseguite nuovamente lo script check.sh in modalità di verifica. Digitare:

    ```bash
    [root@localhost scripts]# ./check.sh -v
    ****

    /etc/kdump.conf: FAILED

    Update the baseline file if you approve of the changes to the file(s) above

    Re-run the script with the re-build option (e.g. ./check.sh  --rebuild) to approve
    ```

9. In base all'avviso di cui sopra, dovreste approfondire l'indagine per verificare se il file alterato possa essere approvato. In tal caso, è possibile eseguire lo script con l'opzione `--rebuild`. Per visualizzare solo le differenze tra il file "contaminato" e quello "non contaminato" si può digitare:

    ```bash
    [root@localhost scripts]# sdiff -s /etc/kdump.conf  /root/etc.bak/kdump.conf
    ```

## Tripwire

Una delle prime cose da fare dopo aver creato un nuovo sistema è ottenere un'istantanea dello stato ottimale del sistema prima che questo venga “contaminato” o prima di implementarlo in produzione.

Esistono diversi strumenti per farlo. Uno di questi strumenti è Tripwire. Tripwire è uno strumento avanzato, quindi preparatevi a molte opzioni, sintassi, stranezze e interruttori.

Tripwire può essere considerato una forma di sistema di rilevamento delle intrusioni (IDS) basato su host. Esegue funzioni di rilevamento delle intrusioni scattando un'istantanea di un "sistema sano" e confrontando successivamente questo stato sano con qualsiasi altro stato sospetto. Fornisce un mezzo per conoscere/monitorare se determinati file sensibili sono stati alterati illegalmente. L'amministratore del sistema decide naturalmente quali file devono essere monitorati.

Gli autori di tripwire lo descrivono come un software Open Source per la Sicurezza, il Rilevamento delle Intrusioni, la Valutazione dei Danni e il Ripristino, con Funzionalità Forensi.

Tripwire confronta la nuova firma di un file con quella acquisita al momento della creazione del database.

Le fasi di installazione e configurazione di tripwire sono elencate di seguito:

1. Installare il software dal sorgente o dal binario

2. Eseguire lo script di configurazione: (twinstall.sh). Questo script viene utilizzato per: a) Creare la chiave del sito, la chiave locale e le richieste di passphrase per entrambe b) Firmare il file dei criteri e il file di configurazione con la chiave del sito

3. Inizializzare il database Tripwire

4. Eseguire il primo controllo di integrità.

5. Modificare il file di configurazione (twcfg.txt)

6. Modificare il file dei criteri (twpol.txt)

Tripwire accetta le seguenti opzioni dalla riga di comando:

**Modalità di Inizializzazione del database:**

```bash

       -m i            --init
       -v              --verbose
       -s              --silent, --quiet
       -c cfgfile      --cfgfile cfgfile
       -p polfile      --polfile polfile
       -d database     --dbfile database
       -S sitekey      --site-keyfile sitekey
       -L localkey     --local-keyfile localkey
       -P passphrase   --local-passphrase passphrase
       -e              --no-encryption
```

**Modalità di Controllo dell'Integrità:**

```bash

           -m c                  --check
           -I                    --interactive
           -v                    --verbose
           -s                    --silent, --quiet
           -c cfgfile            --cfgfile cfgfile
           -p polfile            --polfile polfile
           -d database           --dbfile database
           -r report             --twrfile report
           -S sitekey            --site-keyfile sitekey
           -L localkey           --local-keyfile localkey
           -P passphrase         --local-passphrase passphrase
           -n                    --no-tty-output
           -V editor             --visual editor
           -E                    --signed-report
           -i list               --ignore list
           -l { level | name }   --severity { level | name }
           -R rule               --rule-name rule
           -x section            --section section
           -M                    --email-report
           -t { 0|1|2|3|4 }      --email-report-level { 0|1|2|3|4 }
           -h                    --hexadecimal
           [ object1 [ object2... ]]
```

**Modalità di Aggiornamento del Database:**

```bash
 -m u                --update
           -v                  --verbose
           -s                  --silent, --quiet
           -c cfgfile          --cfgfile cfgfile
           -p polfile          --polfile polfile
           -d database         --dbfile database
           -r report           --twrfile report
           -S sitekey          --site-keyfile sitekey
           -L localkey         --local-keyfile localkey
           -P passphrase       --local-passphrase passphrase
           -V editor           --visual editor
           -a                  --accept-all
           -Z { low | high }   --secure-mode { low | high }
```

**Modalità di Aggiornamento dei Criteri:**

```bash
 -m p                --update-policy
           -v                  --verbose
           -s                  --silent, --quiet
           -c cfgfile          --cfgfile cfgfile
           -p polfile          --polfile polfile
           -d database         --dbfile database
           -S sitekey          --site-keyfile sitekey
           -L localkey         --local-keyfile localkey
           -P passphrase       --local-passphrase passphrase
           -Q passphrase       --site-passphrase passphrase
           -Z { low | high }   --secure-mode { low | high }
           policyfile.txt
```

**Riepilogo delle opzioni per il comando `tripwire`:**

```bash
SYNOPSIS
  Database Initialization:    tripwire { -m i | --init } [ options... ]
  Integrity Checking:    tripwire { -m c | --check } [ options... ]
            [ object1 [ object2... ]]
  Database Update:      tripwire { -m u | --update } [ options... ]
  Policy update:     tripwire { -m p | --update-policy } [ options... ]
            policyfile.txt
  Test:     tripwire { -m t | --test } [ options... ]

```

### `twadmin`

L'utilità `twadmin` esegue le funzioni amministrative relative ai file e alle opzioni di configurazione di Tripwire. In particolare, `twadmin` consente di codificare, decodificare, firmare e verificare i file Tripwire e fornisce un mezzo per generare e modificare le chiavi locali e del sito.

```bash
Create Configuration File:  twadmin [-m F|--create-cfgfile][options] cfgfile.txt
Print Configuration File:   twadmin [-m f|--print-cfgfile] [options]
Create Policy File:     twadmin [-m P|--create-polfile] [options] polfile.txt
Print Policy File:     twadmin [-m p|--print-polfile] [options]
Remove Encryption:     twadmin [-m R|--remove-encryption] [options] [file1...]
Encryption:       twadmin [-m E|--encrypt] [options] [file1...]
Examine Encryption:     twadmin [-m e|--examine] [options] [file1...]
Generate Keys:       twadmin [-m G|--generate-keys] [options]
```

### `twprint`

Stampa i file del database e dei rapporti di Tripwire in formato testo semplice.

**Modalità di stampa del report:**

```bash
-m r                     --print-report
-v                       --verbose
-s                       --silent, --quiet
-c cfgfile            --cfgfile cfgfile
-r report              --twrfile report
-L localkey            --local-keyfile localkey
-t { 0|1|2|3|4 }       --report-level { 0|1|2|3|4 }
```

**Modalità di stampa del Database:**

```bash
-m d                   --print-dbfile
-v                       --verbose
-s                       --silent, --quiet
-c cfgfile             --cfgfile cfgfile
-d database            --dbfile database
-L localkey            --local-keyfile localkey
[object1 [object2 ...]
```

### `siggen`

`siggen` è una routine di raccolta delle firme per Tripwire. È un'utilità che visualizza i valori della funzione hash per i file specificati.

```bash
OPTIONS
       ‐t, --terse
              Terse mode.  Prints requested hashes for a given file on one line, delimited by spaces, with no extraneous information.

       ‐h, --hexadecimal
              Display results in hexadecimal rather than base64 notation.

       ‐a, --all
              Display all hash function values (default).

       ‐C, --CRC32
              Display CRC-32, POSIX 1003.2 compliant 32-bit Cyclic Redundancy Check.

       ‐M, --MD5
              Display MD5, the RSA Data Security, Inc. Message Digest Algorithm.

       ‐S, --SHA
              Display SHA, Tripwire's implementation of the NIST Secure Hash Standard, SHS (NIST FIPS 180).

       ‐H, --HAVAL
              Display Haval value, a 128-bit hash code.

       file1 [ file2... ]
              List of filesystem objects for which to display values.
```

## Esercizio 2

### Per installare Tripwire

1. Verificare se Tripwire è già installato sul sistema. Digitare:

    ```bash
    [root@localhost root]# rpm -q tripwire
    tripwire-*
    ```

    Se si ottiene un risultato simile a quello riportato sopra, il programma è già installato. Saltare il passaggio successivo.

2. Se non è installato, procuratevi il binario di Tripwire e installatelo. Digitare:

    ```bash
    [root@localhost root]# dnf -y install tripwire
    ```

### Configurare Tripwire

La configurazione di Tripwire comporta (se necessario) la personalizzazione del file di configurazione di Tripwire, del file dei criteri e l'esecuzione dello script di configurazione. Lo script richiede una passphrase che verrà utilizzata per firmare/proteggere il file di configurazione, il file dei criteri e il file del database.

1. Cambiare la pwd con la directory di lavoro di Tripwire: Digitare:

    ```bash
    [root@localhost  root]# cd /etc/tripwire/
    ```

2. Elencare il contenuto della directory.

3. Per visualizzare/studiare i file presenti nella directory, utilizzare un qualsiasi paginatore o editor di testo.

4. Accetteremo le impostazioni della configurazione predefinita. (twcfg.txt) e il file dei criteri predefiniti (twpol.txt).

5. Eseguire l'utilità di configurazione di Tripwire come root. Verrà richiesta (due volte) la passphrase della chiave del sito. Selezionate una passphrase che NON dimenticherete (la chiave del sito è destinata al file twcfg.txt e al file twpol.txt):

    ```bash
    [root@localhost tripwire]# tripwire-setup-keyfiles
    .....
    Enter the site keyfile passphrase:
    Verify the site keyfile passphrase:
    ......
    Generating key (this may take several minutes)...Key generation complete.
    ```

    Successivamente verrà richiesta una chiave locale. Di nuovo, scegliete un'altra password che NON dimenticherete. (La chiave locale firma i file del database tripwire e i file dei report)

    ```bash
    Enter the local keyfile passphrase:
    Verify the local keyfile passphrase:
    ....
    Generating key (this may take several minutes)...Key generation complete.

    ```

    Dopo aver scelto le passphrase, il programma `tripwire-setup-keyfiles` procederà alla creazione/firma delle versioni criptate dei file originali in testo normale (ad esempio, verranno creati rispettivamente tw.cfg e tw.pol). Verranno nuovamente richieste le passphrase scelte in precedenza. A questo punto, seguite le istruzioni finché lo script non termina.

    ```bash
    ----------------------------------------------
    Signing configuration file...
    Please enter your site passphrase: ********

    ----------------------------------------------
    Signing policy file...
    Please enter your site passphrase: ********
    ......

    Wrote policy file: /etc/tripwire/tw.pol
    ```

    !!! question "Compito di laboratorio:"

     Elencare il nuovo contenuto della cartella /etc/tripwire.

6. In base all'avviso ricevuto durante l'esecuzione dell'utilità `tripwire-setup-keyfiles`, ora si sposteranno le versioni in testo semplice del file di configurazione e dei file delle policy lontano dal sistema locale. Potreste memorizzarli su un supporto di rimozione esterno o crittografarli in loco (utilizzando uno strumento come GPG, ad esempio) OPPURE eliminarli completamente se vi sentite particolarmente audaci. Digitare: Digitare:

    ```bash
    [root@localhost tripwire]# mkdir /root/tripwire_stuff && mv twcfg.txt twpol.txt /root/tripwire_stuff
    ```

!!! note "Nota"

    Può essere utile conservare le versioni in chiaro in un luogo sicuro, nel caso in cui si dimentichino le passphrase. È sempre possibile rieseguire "tripwire-setup-keyfiles" in base alle configurazioni e ai criteri perfezionati nel tempo.

### Per inizializzare il database

L'inizializzazione del database è la terminologia di Tripwire per indicare l'acquisizione di un'istantanea iniziale "non contaminata" dei file che si è deciso di monitorare (in base al file di criterio). Questo genera il database e lo firma con la chiave locale. Il database serve come base per tutti i futuri controlli di integrità.

1. Mentre si è ancora connessi come root digitare:

    ```bash
    [root@localhost tripwire]# tripwire --init

    Please enter your local passphrase:
    Parsing policy file: /etc/tripwire/tw.pol
    Generating the database...
    *** Processing Unix File System ***

    ```

    Quando viene richiesto, inserire la passphrase locale. La creazione del database verrà portata a termine e si dovrebbe ottenere un output simile a quello riportato di seguito:

    **The database was successfully generated.**

2. Utilizzare il comando `ls` per verificare che il database sia stato creato nella posizione indicata. Digitare:

    ```bash
    [root@localhost tripwire]# ls -lh /var/lib/tripwire/$(hostname).twd
    -rw-r--r--. 1 root root 3.3M Sep 27 18:35 /var/lib/tripwire/localhost.twd
    ```

## Esercizio 3

### Controllo dell'integrità e visualizzazione dei rapporti

In questa esercitazione imparerete a eseguire un controllo di integrità del sistema e a visualizzare i rapporti generati da Tripwire.

### Per eseguire un controllo di integrità

L'esecuzione di tripwire in questa modalità (modalità di controllo dell'integrità) confronta gli oggetti del file system corrente con le loro proprietà nel database di tripwire. Le discrepanze tra il database e gli oggetti del file system corrente vengono stampate sullo standard output durante l'esecuzione di Tripwire in questa modalità. Al termine del controllo Tripwire genera anche un file di report nella directory specificata nel file twcfg.txt (/var/lib/tripwire/report/).

1. Eseguire un controllo di integrità. Digitare:

    ```bash
    [root@localhost tripwire]# tripwire --check
    ```

    Durante questo controllo si vedranno scorrere alcuni avvisi [previsti].

    Controllare la cartella `/var/lib/tripwire/report` per vedere se è stato creato un rapporto anche lì.

    !!! question "Compito di laboratorio:"

     Scrivere il nome del file di report creato.
    
     FILE_NAME =

2. Eseguire nuovamente il controllo di integrità, ma specificare manualmente il nome del file di report. Digitare:

    ```bash
    [root@localhost tripwire]# tripwire -m c -r /root/tripwire_report.twr
    ```

3. Assicurarsi che sia stato creato un nuovo file nella home directory di root. Digitare:

    ```bash
    [root@localhost tripwire]# ls -l /root/tripwire_report.twr
    ```

### Per esaminare il rapporto

I file di report di Tripwire sono una raccolta di violazioni delle regole rilevate durante un controllo di integrità.

Esistono diversi modi per visualizzare un file di report di Tripwire:

- durante il controllo di integrità
- sotto forma di un'e-mail inviata automaticamente all'utente
- utilizzando il comando `twprint` fornito con il pacchetto Tripwire

!!! note "Nota"

    Probabilmente avrete notato dall'esercizio precedente che Tripwire utilizza una combinazione del nome FQDN del sistema, della data e dell'ora per assegnare un nome predefinito ai file di report.

1. Per prima cosa, passare alla directory del report predefinito e visualizzare il report predefinito creato al punto 1 (FILE_NAME). Digitare:

    ```bash
    [root@localhost report]# cd /var/lib/tripwire/report && twprint --print-report -r <FILE_NAME>
    ```

    Sostituire <FILE_NAME> con il valore indicato in precedenza.

    Per utilizzare la forma abbreviata del comando precedente, digitare:

    ```bash
    [root@localhost report]# twprint -m r -r <FILE_NAME> | less
    ```

    L'output viene inviato al comando less perché il report scorre rapidamente.

2. Ora visualizzate l'altro report creato manualmente, nella directory home di root. Digitare:

    ```bash
    [root@localhost root]# cd && twprint --print-report -r /root/tripwire_report.twr | less
    ```

3. Tenetevi forte e studiate attentamente l'output del file di report.

4. Dovreste aver notato di nuovo che Tripwire ha creato forme binarie/dati dei file di report. Creare una versione solo testo del file di report nella directory home di root. Digitare:

    ```bash
    [root@localhost root]# twprint --print-report -r /root/tripwire_report.twr > tripwire_report.txt
    ```

### Per visualizzare i rapporti via e-mail

Here you will test the e-mail functionality of Tripwire. Il sistema di notifica via e-mail di Tripwire utilizza l'impostazione specificata nel file di configurazione di Tripwire. (twcfg.txt).

1. Per prima cosa visualizzate il file di configurazione e notate le variabili che controllano il sistema di notifica via e-mail di Tripwire. Per visualizzare il tipo di file di configurazione:

    ```bash
    [root@localhost report]# twadmin  -m f | less
    ```

    !!! question "Compito di laboratorio:"

     Scrivere le variabili rilevanti.

2. Quindi, assicurarsi che il sistema di posta locale sia attivo e funzionante controllando lo stato di postfix. Digitare:

    ```bash
    [root@localhost report]# systemctl -n 0 status postfix
    .......
         Active: active (running) since Thu 2023-08-31 16:21:26 UTC; 3 weeks 6 days ago
    .......
    ```

    L'output dovrebbe essere simile a quello sopra riportato. Se il sistema di posta elettronica non è in funzione, prima di continuare, cercate di risolvere il problema e di renderlo operativo.

3. Inviare un messaggio di prova a root. Digitare:

    ```bash
    [root@localhost report]# tripwire --test --email root
    ```

4. Utilizzare il programma di posta per controllare la posta di root. Digitare:

    ```bash
    [root@localhost report]# mail
    ```

    Il superutente dovrebbe ricevere un messaggio con oggetto "Test email message from Tripwire"

5. Dopo aver confermato il funzionamento della funzionalità e-mail, si può provare a inviare manualmente una copia di uno dei report a se stessi.

    !!! question "Domanda"
   
        Qual era il comando per farlo?

### Messa a punto di Tripwire

Dopo l'installazione di Tripwire, l'acquisizione di un'istantanea del sistema e l'esecuzione del primo controllo di integrità, è molto probabile che sia necessario mettere a punto Tripwire per soddisfare le esigenze del vostro ambiente specifico. Ciò è dovuto principalmente al fatto che il file di configurazione e di criterio predefinito fornito con Tripwire potrebbe non essere esattamente adatto alle vostre esigenze o riflettere gli oggetti effettivi presenti nel vostro file system.

È necessario verificare se le violazioni del file system segnalate nel file di report durante il controllo di integrità sono violazioni effettive o modifiche legittime/autorizzate agli oggetti del file system. Anche in questo caso Tripwire offre diversi modi per farlo.

### Aggiornamento del file dei criteri

Con questo metodo è possibile modificare o regolare con precisione ciò che Tripwire considera violazioni agli oggetti del file system, modificando le regole nel file dei criteri. Il database può quindi essere aggiornato senza una nuova inizializzazione completa. In questo modo si risparmia tempo e si preserva la sicurezza, mantenendo il file dei criteri sincronizzato con il database utilizzato.

Utilizzerete il file di report creato in precedenza ( /root/tripwire_report.txt ) per perfezionare il vostro file di criterio, impedendo innanzitutto a Tripwire di segnalare l'assenza di file che non sono mai stati presenti sul filesystem.

In questo modo si riduce notevolmente la lunghezza del file di report da gestire.

#### Per mettere a punto Tripwire

1. Usare il comando grep per filtrare tutte le righe del file di report che si riferiscono a file mancanti (ad es. Linee contenenti la parola "Filename"). Linee contenenti la parola "Filename"). Reindirizzare l'output in un altro file, tripwire_diffs.txt. Digitare:

    ```bash
    [root@localhost root]# grep Filename  /root/tripwire_report.txt > tripwire_diffs.txt
    ```

2. Visualizzare il contenuto del file creato in precedenza. Digitare:

    ```bash
    [root@localhost root]# less tripwire_diffs.txt
    207:     Filename: /proc/scsi

    210:     Filename: /root/.esd_auth

    213:     Filename: /root/.gnome_private

    216:     Filename: /sbin/fsck.minix

    219:     Filename: /sbin/mkfs.bfs
    ..................................
    ```

3. Ora è necessario modificare il file dei criteri di Tripwire e commentare o eliminare le voci del file che non dovrebbero essere presenti. Ad esempio, alcuni file non sono presenti sul sistema e non lo saranno mai. Uno dei file, ad esempio, che il file di criterio cerca di monitorare è il file /proc/scsi. Se il sistema non dispone di dispositivi SCSI, non ha senso monitorare questo file.

    Un altro esempio discutibile di cosa monitorare o meno è rappresentato dai vari file di blocco sotto la directory `/var/lock/subsys/`. La scelta di monitorare questi file deve essere una decisione personale.

    Creare nuovamente una versione di testo del file di criterio, nel caso in cui sia stato rimosso (come consigliato) dal sistema locale. Digitare:

    ```bash
    [root@localhost root]# twadmin --print-polfile  > twpol.txt
    ```

4. Modificare il file di testo creato in precedenza utilizzando un qualsiasi editor di testo. Eliminare i riferimenti agli oggetti che non si desidera monitorare. Si può usare il file tripwire_diffs.txt creato in precedenza come linea guida. Digitare:

    ```bash
    [root@localhost  root]# vi twpol.txt
    ```

    Salvare le modifiche al file e chiuderlo.

5. Eseguire `tripwire` in modalità di aggiornamento dei file di criterio. Digitare:

    ```bash
    [root@localhost root]# tripwire  --update-policy   /root/twpol.txt
    ```

    Quando viene richiesto, inserire le passphrase locale e del sito.

    Verrà creato un nuovo file di criterio firmato e crittografato nella directory `/etc/tripwire/`.

6. Eliminare o rimuovere la versione di testo del file di criterio dal sistema locale.

7. L'esecuzione del comando al punto 5 crea un file di report nella directory `/var/lib/tripwire/report`.

    !!! Question "Compito di laboratorio:"
   
        Scrivere il nome dell'ultimo file di report.
       
        <LATEST_REPORT>

8. Eseguire nuovamente un controllo di integrità del sistema fino a quando non si è certi di avere una buona base del sistema, con la quale prendere decisioni future.

    !!! Question "Domanda"
   
        Qual è il comando per farlo?

### Aggiornamento del database

L'esecuzione di `tripwire` in modalità di aggiornamento del database dopo un controllo di integrità offre un modo rapido e approssimativo per mettere a punto Tripwire. Questo perché la modalità di aggiornamento del database consente di riconciliare le differenze tra il database e il sistema corrente.  In questo modo si eviterà che le violazioni vengano visualizzate nei rapporti futuri.

Questo processo di aggiornamento permette di risparmiare tempo, consentendo di aggiornare il database senza doverlo reinizializzare.

#### Per aggiornare il database

1. Cambiate la pwd nella posizione in cui Tripwire memorizza i file di report sul vostro sistema. Digitare:

    ```bash
    [root@localhost root]# cd /var/lib/tripwire/report/
    ```

2. Per prima cosa si utilizzerà la modalità di aggiornamento del database in modo interattivo. Digitare:

    ```bash
    [root@localhost report]# tripwire --update  -Z  low  -r  <LATEST_REPORT>
    ```

    Sostituire <LATEST_REPORT> con il nome del file di report annotato in precedenza.

    Il comando di cui sopra lancerà anche il vostro editor di testo predefinito (ad esempio, `vi`), che vi presenterà le cosiddette "caselle di aggiornamento". Potrebbe essere necessario scorrere il file.

    Le voci contrassegnate con una "[x]" implicano che il database deve essere aggiornato con quel particolare oggetto.

    Rimuovere la "x" dal riquadro "[ ]" per impedire l'aggiornamento del database con i nuovi valori per la voce.

    Per salvare e uscire dall'editor di testo, utilizzare i tasti abituali.

3. Provate quindi a utilizzare la modalità di aggiornamento del database in modo non interattivo. cioè si accettano tutte le voci del file di report senza che venga richiesto. Digitare:

    ```bash
    [root@localhost report]# tripwire --update -Z  low -a -r  <LATEST_REPORT>
    ```

### File di configurazione di Tripwire

Inizierete questi esercizi mettendo a punto il vostro file di configurazione. In un esercizio precedente è stato consigliato di rimuovere o eliminare dal sistema tutte le versioni in chiaro del file di Tripwire. È possibile creare un'installazione di Tripwire leggermente più sicura modificando alcune variabili del file di configurazione di Tripwire. Si specificherà che Tripwire deve sempre cercare le versioni binarie dei file di policy e di configurazione su supporti rimovibili come dischetti o CDROM.

1. Cambiate la vostra pwd nella directory /etc/tripwire.

2. Genera una versione in chiaro del file di configurazione. Digitare:

    ```bash
    [root@localhost tripwire]# twadmin --print-cfgfile  > twcfg.txt
    ```

3. Aprire il file di configurazione creato in precedenza nell'editor di testo. Digitare:

    ```bash
    [root@localhost tripwire]# vi twcfg.txt
    ```

    Modificare il file in modo che assomigli al file di esempio qui sotto:

    (NOTA: le nuove variabili aggiunte e modificate sono state evidenziate)

    ```bash
    1 ROOT                     =/usr/sbin

    2 POLFILE                  =/mnt/usbdrive/tw.pol

    3 DBFILE                   =/var/lib/tripwire/$(HOSTNAME).twd

    4 REPORTFILE             =/var/lib/tripwire/report/$(HOSTNAME)-$(DATE).twr

    5 SITEKEYFILE            =/mnt/usbdrive/site.key

    6 LOCALKEYFILE      =/mnt/usbdrive/$(HOSTNAME)-local.key

    7 EDITOR                   =/bin/vi

    8 LATEPROMPTING    =false

    9 LOOSEDIRECTORYCHECKING   =true

    10 GLOBALEMAIL                =root@localhost

    11 MAILNOVIOLATIONS           =true

    12 EMAILREPORTLEVEL         =3

    13 REPORTLEVEL                =3

    14 MAILMETHOD                 =SENDMAIL

    15 SYSLOGREPORTING         =true

    16 MAILPROGRAM                =/usr/sbin/sendmail -oi -t
    ```

    !!! question "Compito di laboratorio:"

     Consultate la pagina man di "twconfig" per scoprire a cosa servono le seguenti variabili:

        ```txt
        LOOSEDIRECTORYCHECKING

        GLOBALEMAIL

        SYSLOGREPORTING
        ```

4. Montate un supporto rimovibile nella directory /mnt/usbdrive. Digitare:

    ```bash
    [root@localhost tripwire]# mount /dev/usbdrive   /mnt/usbdrive
    ```

    !!! note "Nota"  

     Se si sceglie di memorizzare i file in una posizione diversa (ad esempio un supporto Cdrom), apportare le modifiche necessarie ai comandi.

5. Trasferire la chiave del sito, la chiave locale e i file binari nella posizione specificata nel nuovo file di configurazione. Digitare:

    ```bash
    [root@localhost tripwire]# mv site.key tw.pol localhost.localdomain-local.key /mnt/usbdrive
    ```

6. Creare una versione binaria del file di configurazione in chiaro. Digitare:

    ```bash
    [root@localhost tripwire]# twadmin --create-cfgfile -S /mnt/usbdrive/site.key twcfg.txt*
    ```

    Il file `/etc/tripwire/tw.cfg` verrà creato per voi.

7. Testare la nuova configurazione. Smontare l'unità USB ed espellerla.

8. Provare a eseguire uno dei comandi di `tripwire` che richiede i file memorizzati nell'unità floppy. Digitare:

    ```bash
    [root@localhost tripwire]# twadmin --print-polfile

    ### Error: File could not be opened.

    ### Filename: /mnt/usbdrive/tw.pol

    ### No such file or directory

    ###

    ### Unable to print policy file.

    ### Exiting...
    ```

    Si dovrebbe ottenere un errore simile a quello riportato sopra.

9. Montare il supporto in cui sono memorizzati i file di tripwire e ripetere il comando precedente.

    !!! question "Domanda"
   
        Il comando è stato eseguito correttamente questa volta?

10. Cercare ed eliminare dal sistema tutte le versioni in testo semplice dei file di configurazione di Tripwire creati finora.

Dover montare e smontare un supporto rimovibile ogni volta che si desidera amministrare un aspetto di Tripwire potrebbe risultare una seccatura, ma il vantaggio potrebbe essere rappresentato dalla maggiore sicurezza. È assolutamente necessario considerare l'archiviazione di una versione incontaminata del database di tripwire su un supporto di sola lettura come un DVD.

### ESERCIZI SUPPLEMENTARI

1. Configurate l'installazione di Tripwire per eseguire un controllo di integrità ogni giorno alle 2 del mattino e inviare un rapporto del controllo di integrità via e-mail al superutente del sistema.

    !!! hint "Suggerimento"
   
        Potrebbe essere necessario utilizzare un cron job.
