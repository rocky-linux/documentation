- - -
title: Lab 3 - Utility di Sistema comuni author: Wale Soyinka contributors: Steven Spencer, Ganna Zhyrnova, Franco Colussi tested on: Tutte le versioni tags:
  - lab exercise
  - system utilities
  - cli
- - -

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di

- Utilizzare le utilità di sistema comuni presenti sulla maggior parte dei sistemi Linux

Tempo stimato per completare questo laboratorio: 70 minuti

## Utilità di sistema comuni presenti nei sistemi Linux

### Cos'è una Utility di Sistema?

In un ambiente Linux, le *utility di sistema* sono programmi e comandi che consentono di gestire, monitorare e ottimizzare il funzionamento del sistema operativo. Questi strumenti sono essenziali per amministratori di sistema, sviluppatori e utenti avanzati, poiché semplificano attività quali la gestione dei file, il controllo dei processi, la configurazione di rete e molto altro ancora.

Al posto d'interfacce grafiche, molte utilità sono accessibili tramite la riga di comando, offrendo maggiore flessibilità, automazione e controllo sul sistema.

Gli esercizi di questo laboratorio riguardano l'utilizzo di alcune utilità di sistema di base che sia gli utenti che gli amministratori devono conoscere bene. La maggior parte dei comandi viene utilizzata per navigare e manipolare il file system. Il file system è costituito da file e directory.

Gli esercizi tratteranno l'utilizzo delle utilità –`pwd`, `cd`, `ls`, `rm`, `mv`, `ftp`, `cp`, `touch`, `mkdir`, `file`, `cat`, `find`, e `locate`.

## Esercizi

### 1. Navigare nel file system con `cd`

Il comando `cd` (abbreviazione di ==Change Directory==) è uno dei comandi più comunemente utilizzati nei sistemi Linux e Unix-like. Consente di spostarsi tra le directory del file system, permettendo agli utenti di navigare tra le cartelle e accedere ai file in esse contenuti.  
Il comando `cd` è essenziale per lavorare nella shell Linux, poiché consente di esplorare e organizzare il file system in modo efficiente.

#### Come si usa `cd`

1. Accedere al computer come root

2. Passare dalla directory corrente alla directory /etc.

    ```bash
    [root@localhost root]# cd /etc
    ```

3. Si noti che il prompt è cambiato da "[root@localhost root]#" a: "[root@localhost etc]#"

4. Passare alla directory `/usr/local/`

    ```bash
    [root@localhost etc]# cd /usr/local

    [root@localhost local]#
    ```

    !!! question "Domanda"

     Cosa è cambiato nel tuo prompt?

5. Tornare alla directory home di root

    ```bash
    [root@localhost local]# cd /root
    ```

6. Passare nuovamente alla directory  `/usr/local/ `. Digitare:

    ```bash
    [root@localhost root]# cd /usr/local
    ```

7. Per passare alla directory superiore della directory locale, digitare `cd ..`.

    ```bash
    [root@localhost local]# cd ..
    ```

    !!! Question "Domanda"

     Qual è la directory a monte della directory `/usr/local/`?

8. Per tornare rapidamente alla directory home di root, digitare "cd" senza alcun argomento.

    ```bash
    [root@localhost usr]# cd
    [root@localhost root]#
    ```

### 2. Visualizzare il path con `pwd`

Il comando `pwd` (==Present Working Directory==) mostra all'utente il percorso (path) assoluto della directory corrente all'interno del file system. Viene utilizzato per identificare la posizione corrente quando si lavora col terminale e si desidera sapere esattamente dove ci si trova. Questo comando è essenziale per navigare nel file system, specialmente quando si lavora con percorsi complessi o script automatizzati.

#### Come utilizzare `pwd`

1. Per scoprire la vostra directory di lavoro attuale, digitare:

    ```bash
    [root@localhost root]# pwd
    /root
    ```

2. Passare alla directory `/usr/local/` utilizzando il comando `cd`:

    ```bash
    [root@localhost root]# cd /usr/local
    ```

3. Utilizzare `pwd` per trovare la vostra directory di lavoro attuale:

    ```bash
    [root@localhost local]# pwd
    /usr/local
    ```

4. Tornare alla directory home di root:

    ```bash
    [root@localhost root]#  cd
    ```

### 3. Creare cartelle con `mkdir`

Il comando `mkdir` (==Make Directory==) consente di creare nuove directory (cartelle) all'interno del file system. In questo esercizio si creeranno due cartelle denominate `cartella1` e `cartella2`.

#### Come usare `mkdir`

1. Creare la prima directory denominata `folder1`

    ```bash
    [root@localhost root]# mkdir folder1
    ```

2. Creare la seconda directory denominata `folder2`

    ```bash
    [root@localhost root]# mkdir   folder2
    ```

3. Ora spostatevi dalla vostra directory di lavoro nella directory “folder1” che avete creato sopra.

    ```bash
    [root@localhost root]# cd folder1
    ```

4. Visualizzare la directory di lavoro corrente.

    ```bash
    [root@localhost folder1]# pwd
    /root/folder1
    ```

    !!! question "Domanda"

     Senza uscire dalla directory corrente, passare alla directory “folder2”. Qual è il comando per farlo?

5. Tornare alla directory home di root.

### 4. Modificare i metadata dei file con `touch`

Il comando `touch` è uno strumento che consente di creare nuovi file vuoti o modificare le date di accesso/modifica dei file esistenti, oltre a consentire usi avanzati nella creazione di script e nell'automazione. Il nome ==touch== deriva dall'idea di “*toccare*” i metadati del file senza necessariamente modificarne il contenuto.  
I file *file11*, *file12*, *file21* e *file22* verranno creati nelle cartelle create sopra.

#### Come utilizzare `touch`

1. Cambiare directory, ovvero `cd` alla `folder1` e craere il file *file11*:

    ```bash
    [root@localhost folder1]# touch file11
    ```

2. Mentre si è ancora nella `folder1` creare *file12*:

    ```bash
    [root@localhost folder1]# touch file12
    ```

3. Ora ritornare alla directory home di root.

4. `cd` nella folder2 e  creare "file21" e "file22"

    ```bash
    [root@localhost folder2]# Touch file21 file22
    ```

5. Tornare alla directory home di root.

### 5. Elencare le directory con `ls`

Il comando ls (==List==) è uno dei comandi più basilari e ampiamente utilizzati nei sistemi Linux e Unix-like. Consente di visualizzare il contenuto di una directory, mostrando file e sottodirectory con varie opzioni di formattazione e ordinamento.

#### Come usare `ls`

1. Digitare `ls` nella directory home di root:

    ```bash
    [root@localhost root]# ls
    ```

    !!! Question "Domanda"

     Elenca il contenuto della directory

2. Passare alla directory "folder1"

3. Elencare il contenuto della directory  `folder1`. Digitare `ls`

    ```bash
    [root@localhost folder1]# ls
    file11  file12
    ```

4. Passare alla directory  `folder2` ed elencare il suo contenuto:

5. Tornare alla directory home ed elencare **tutti** i file e le cartelle nascosti:

    ```bash
    [root@localhost folder2]# cd

    [root@localhost root]# ls   –a
    ..  .bash_history  .bash_logout  .bash_profile  .bashrc  folder1  folder2  .gtkrc  .kde   screenrc
    ```

6. Per ottenere un elenco lungo o dettagliato di tutti i file e le cartelle presenti nella directory home, digitare:

    ```bash
    [root@localhost root]# ls –al
    total 44
    drwx------    5 root    root        4096 May  8 10:15 .
    drwxr-xr-x    8 root     root         4096 May  8 09:44 ..
    -rw-------    1 root    root          43 May  8 09:48 .bash_history
    -rw-r--r--    1 root    root          24 May  8 09:44 .bash_logout
    -rw-r--r--    1 root    root         191 May  8 09:44 .bash_profile
    -rw-r--r--    1 root    root         124 May  8 09:44 .bashrc
    drwxrwxr-x    2 root    root        4096 May  8 10:17 folder1
    drwxrwxr-x    2 root    root        4096 May  8 10:18 folder2
    ………………………..
    ```

### 6. Spostare i file con `mv`

Il comando `mv` (==Move==) fornisce uno strumento per la gestione dei file nel sistema. La sua funzione principale è quella di spostare o rinominare file e directory all'interno del file system. Questo comando è particolarmente utile per riorganizzare la struttura delle directory, eseguire operazioni batch su gruppi di file e gestire i backup in modo efficiente.

#### Come usare `mv`

1. Passare alla directory "folder1" ed elencare il suo contenuto:

    ```bash
    [root@localhost root]# cd   folder1
    [root@localhost folder1] ls

    file11  file12
    ```

2. Si rinominino i file file11 e file12 nella directory “folder1” rispettivamente in temp_file11 e temp_file12:

    ```bash
    [root@localhost folder1]# mv file11 temp_file11
    ```

3. Elencare nuovamente il contenuto della folder1.

    ```bash
    [root@localhost folder1]# ls
    ```

    !!! Question "Domanda"

     Annotare i contenuti:

4. Rinominare il file12 in temp_file12:

    ```bash
    [root@localhost folder1]# mv file12 temp_file12
    ```

5. Senza cambiare directory, rinominare il file21 e il file22 nella "folder2" rispettivamente in temp_file21 e temp_file22:

    ```bash
    [root@localhost folder1]# mv   /root/folder2/file21     /root/folder2/temp_file21

    [root@localhost folder1]# mv   /root/folder2/file22    /root/folder2/temp_file22
    ```

6. Senza cambiare la directory corrente, elencare il contenuto della folder2.

    !!! question "Domanda"
   
        Qual è il comando per farlo? Elencare anche l'output del comando?

### 7. Copiare file con `cp`

Il comando `cp` (==Copia==) consente di duplicare file e directory da una posizione all'altra nel file system, mantenendo intatto il file originale. La sua facilità d'uso e versatilità lo rendono indispensabile sia per le operazioni quotidiane che per le attività di amministrazione di sistema più complesse. Tra le caratteristiche più utili del comando `cp` vi è la capacità di preservare gli attributi originali dei file durante la copia, inclusi *permessi*, *timestamp* e *informazioni sul proprietario*. Questa funzione è particolarmente importante quando si lavora con file di configurazione o quando è necessario mantenere intatte determinate proprietà dei documenti.

#### Come usare `cp`

1. Passa alla directory `folder2`.

2. Copiare il contenuto della cartella `folder2` (*temp_file21* e *temp_file22*) nella cartella `folder1`:

    ```bash
    [root@localhost folder2]# cp temp_file21 temp_file22 ../folder1
    ```

3. Elencare il contenuto della `folder1`.

    ```bash
    [root@localhost folder2]# ls  ../folder1
    temp_file11  temp_file12  temp_file21  temp_file22
    ```

4. Elencare il contenuto della `folder2`. Si noti che le copie originali di *temp_file21* e *temp_file22*  rimangono nella `folder2`.

    ```bash
    [root@localhost folder2]# ls
    temp_file21  temp_file22
    ```

### 8. Determinare il tipo di file con `file`

Il comando `file` è uno strumento diagnostico che consente di determinare la tipologia di un file analizzandone il contenuto. A differenza delle estensioni dei file, che possono essere modificate o fuorvianti, questo comando esamina la struttura effettiva dei dati per identificarne con precisione la natura. Una delle caratteristiche più importanti del comando `file` è la sua capacità di distinguere tra diversi tipi di file di testo, identificando, ad esempio, script di shell, codice sorgente in vari linguaggi di programmazione, file XML o JSON. Per i file binari, è in grado di riconoscere eseguibili, librerie condivise, immagini in vari formati e molti altri tipi di dati strutturati.

#### Come utilizzare `file`

1. Tornare alla directory home.

2. Per verificare se `cartella1` è un file o una directory, digitare:

    ```bash
    [root@localhost root]# file    folder1
    folder1: directory
    ```

3. Passare alla cartella `folder1`

4. Utilizzare l'utilità `file` per determinare il tipo di file per *temp_file11*:

    ```bash
    [root@localhost folder1]# file     temp_file11
    temp_file11: empty
    ```

5. Utilizzare l'utilità `file` per scoprire il tipo di file di tutti i file presenti nella `folder1` . Elencare qui:

6. Passate alla directory `/etc`:

    ```bash
    [root@localhost folder1]# cd /etc
    ```

7. Utilizzare l'utilità `file` per scoprire il tipo di file del file *passwd*.

    ```bash
    [root@localhost etc]# file passwd
    ```

    !!! question "Domanda"

     Di che tipo di file si tratta?

### 9. Elenca e concatena i file con `cat`

Il comando `cat` (abbreviazione di ==Concatenate==) è uno strumento essenziale per la gestione dei file di testo in Linux. La sua funzione principale è quella di visualizzare il contenuto di uno o più file direttamente a terminale, ma può anche essere utilizzato per creare, unire o copiare file. Il comando cat è particolarmente utile in combinazione con altri strumenti (come grep o more) per elaborare o filtrare testi direttamente dal terminale. Nonostante la sua semplicità, è uno dei comandi più utilizzati per la rapida manipolazione dei file. Si utilizza `cat` insieme al simbolo di reindirizzamento “>” per creare un file.

#### Usare `cat` per creare un file

1. Passare alla directory /root/folder1

2. Creare un nuovo file di testo chiamato *first.txt*

    ```bash
    [root@localhost folder1]# cat > first.txt
    ```

3. Digitare la frase seguente nel prompt vuoto e premere ++enter++.

    ```bash
    Questa è una riga di first.txt !!
    ```

4. Premere contemporaneamente i tasti ++ctrl+c++.

5. Digitare `cat first.txt` per leggere il testo appena digitato:

    ```bash
    [root@localhost folder1]#  cat first.txt
    Questa è una riga di first.txt !!
    ```

6. Creare un altro file chiamato "second.txt" utilizzando `cat`. Digitare il seguente testo nel file – “Questa è una riga di second.txt !!”

    !!! question "Domanda"
   
        Qual è il comando per farlo?

#### Usare `cat` per concatenare insieme i file

1. Se si vuole concatenare i file  *first.txt* e *second.txt*. Digitare:

    ```bash
    [root@localhost folder1]# cat first.txt second.txt
    ```

    !!! question "Domanda"

     Qual è il risultato?

### 10. Trasferire file con `ftp`

Il comando `ftp` (File Transfer Protocol) è uno strumento a riga di comando che consente di trasferire file tra sistemi remoti e locali. Sebbene sia stato parzialmente sostituito da protocolli più moderni e sicuri come *SFTP* e *SCP*, rimane utile in contesti legacy o con server che supportano solo FTP.  
L'FTP trasmette i dati in **testo chiaro**, comprese le credenziali e i contenuti, quindi non è consigliato per i trasferimenti sensibili.  
Sebbene l'FTP sia ancora utilizzato in alcuni ambienti, per operazioni sicure sono preferibili i protocolli crittografati.  
In questo esercizio imparerai come accedere in modo anonimo a un server FTP e scaricare un file dal server utilizzando un programma *client FTP*.

!!! note "Nota"

    Per poter seguire questo esercizio specifico, che richiede un server FTP disponibile e raggiungibile, è necessario aver completato gli esercizi del laboratorio precedente.

#### Come usare `ftp`

1. Accedere al computer come root

2. Passare alla directory `/usr/local/src/`

3. Creare una nuova directory chiamata `downloads` all'interno della directory `/usr/local/src/`.

    !!! question "Domanda"
   
        Qual è il comando per farlo?

4. Andate nella directory `downloads` appena creata

    ```bash
    [root@localhost src]# cd  downloads
    ```

5. Digitare `ftp` per avviare il *client ftp*:

    ```bash
    [root@localhost downloads]#  ftp
    ftp>
    ```

6. Per connettersi al server FTP, digitare:

    ```bash
    ftp> open  < server-address>         (Obtain the <server-address> from your instructor)
    ………
    220 localhost.localdomain FTP server (Version wu-2.6.2-5) ready.
    ………..
    ```

7. Accedere come utente anonimo. Digitare  “*anonymous*” nel prompt:

    ```bash
    Name (10.4.51.29:root):  anonymous
    ```

8. Digitare un indirizzo e-mail qualsiasi alla richiesta della password e premere Invio

    ```bash
    Password:         ***************

    230 Guest login ok, access restrictions apply.
    Remote system type is UNIX.
    Using binary mode to transfer files.
    ftp>
    ```

9. Passare alla modalità binaria. Digitare:

    ```bash
    ftp> binary
    ```

    !!! question "Domanda"

     Qual è l'output del comando binario e cos'è la “modalità binaria”?

10. Elencare le directory correnti sul server ftp. Digitare `ls` nel *prompt ftp*:

    ```bash
    ftp>  ls  
    227 Entering Passive Mode (10,0,4,5,16,103).
    125 Data connection already open; Transfer starting.
    11-23-43  10:23PM       <DIR>          images
    11-02-43  02:20PM       <DIR>          pub
    226 Transfer complete.
    ```

11. Passare alla directory `pub` . Digitare:

    ```bash
    ftp> cd  pub
    ```

12. Utilizzare il comando `ls` per elencare i file e le directory presenti nella directory `pub`

    !!! question "Domanda"
    
         Quanti file e directory ci sono adesso?

13. Scaricare il file denominato “*hello-2.1.1.tar.gz*” in locale. Digitare “*yes*” quando richiesto.

    ```bash
    ftp>  mget     hello-2.1.1.tar.gz
    mget hello-2.1.1.tar.gz? yes

    227 Entering Passive Mode (10,0,4,5,16,252).
    125 Data connection already open; Transfer starting.
    226 Transfer complete.
    389363 bytes received in 0.0745 secs (5.1e+03 Kbytes/sec)
    ```

14. Disconnettersi dal server FTP e chiudere il *client ftp*. Digitare:

    ```bash
    ftp> bye
    ```

15. Si verrà reindirizzati alla shell locale.

16. Assicuratevi di trovarvi ancora nella directory `downloads` della vostra macchina in locale.

    !!! question "Domanda"
    
         Elencare i file nella cartella downloads.

### 11. Utilizzo del reindirizzamento

La maggior parte delle utility e dei comandi utilizzati in Linux inviano il loro output allo schermo. Lo schermo è chiamato standard output (*stdout*). Il reindirizzamento consente di inviare l'output altrove – ad esempio in un file.

Ogni programma avviato su un sistema Linux ha tre descrittori di file aperti, *stdin* **(0)**, *stdout* **(1)** e *stderr* **(2)**. È possibile reindirizzarli o “*pipe*” (ricondurli) singolarmente. I simboli di reindirizzamento sono ++maggiore++ e ++minore++.

#### Come usare il reindirizzamento

1. Assicurarsi di essere ancora nella directory `folder1`.

2. Si utilizzerà il reindirizzamento dell'output per reindirizzare l'output del comando `ls` (*lista*) a un file di testo denominato myredirects:

    ```bash
    [root@localhost folder1]# ls  > myredirects
    ```

3. Esaminare il contenuto del nuovo file (*myredirects*) creato nella directory `folder1`.

    ```bash
    [root@localhost folder1] # cat     myredirects
    temp_file11  temp_file12  temp_file21  temp_file22 myredirects
    ```

4. Ora il risultato del comando file verrà reindirizzato nello stesso file. Si vuole scoprire il tipo di file per *temp_file11* nella directory `folder1` e inviare l'output al file *myredirects*:

    ```bash
    [root@localhost folder1]# file temp_file11 > myredirects
    ```

5. Esaminare il contenuto del file myredirects.

    !!! question "Domanda"
   
        È cambiato. Cos'è successo?

6. Se si vuole evitare che si verifichi quanto sopra, si utilizzerà il doppio simbolo di reindirizzamento ++">>"++. Questo accoderà (*aggiungerà*) il nuovo output al file invece di sostituirlo. Fate una prova:

    ```bash
    [root@localhost folder1]# ls >> myredirects
    ```

7. Ora si esamini nuovamente il contenuto del file *myredirects* utilizzando `cat`.

    !!! question "Domanda"
   
        Scrivere qui il suo contenuto:

#### Utilizzare il reindirizzamento per sopprimere l'output di un comando

I concetti trattati in questa sezione saranno molto utili in Linux, quindi vi invitiamo a prestare particolare attenzione. Potrebbe apparire un po' complicato.

Ci saranno casi in cui non si vuole che l'utente veda l'output di un comando, ad esempio un messaggio di errore. Accade spesso infatti che i messaggi di errore strani spaventino gli utenti comuni. In questo esercizio si dirotterà l'output dei comandi al *dispositivo null* ( `/dev/null/` ). Il *dispositivo null* è simile a un “*bit bucket*”. Tutto ciò che metti dentro scompare per sempre. È anche possibile inviare (o reindirizzare) l'output regolare dei comandi al *dispositivo null*.

Utilizzare le linee guida riportate di seguito:

| Reindirizzatore | Funzione                                                                    |
| --------------- | --------------------------------------------------------------------------- |
| > file          | Indirizza lo standard output al file                                        |
| < file          | Riceve come standard input dal file                                         |
| Cmd1 \         | cmd2 | Pipe; prende lo standard output di cmd1 come standard input per cmd2 |
| n> file         | Indirizza il descrittore del file n al file                                 |
| N< file         | Imposta il file come descrittore del file N                                 |
| >&n             | Duplica lo standard output nel descrittore di file n                        |
| <&n             | Duplica lo standard input dal descrittore del file n                        |
| &>file          | Indirizza lo standard output e lo standard error nel file                   |

1. Assicurarsi di essere ancora nella directory `folder1`. Utilizzare l'opzione di elenco esteso del comando `ls` su *temp_file11*:

    ```bash
    [root@localhost folder1]#  ls   –l   temp_file11
    -rw-r--r--    1 root     root            0 Jul 26 18:26 temp_file11
    ```

2. Reindirizzare l'output dello stesso comando sopra riportato (0>ls –l  temp_file11</code>) al dispositivo null.

    ```bash
    [root@localhost folder1]#  ls   –l temp_file11  > /dev/null
    ```

    Non si dovrebbe ottenere alcun risultato.

3. Ora, se per sbaglio viene digitato in modo errato il nome del file di cui si desidera visualizzare le informazioni, verrà visualizzato il seguente messaggio:

    ```bash
    [root@localhost folder1]# ls –l te_file1
    ls: te_file1: No such file or directory
    ```

    Quanto sopra è il risultato del tipo di errore che il comando `ls` ha programmato di restituire.

4. Esegure lo stesso comando di cui sopra con un nome file scritto in modo errato e reindirizzalo a `/dev/null`.

    ```bash
    [root@localhost folder1]# ls   -l   te_file1  >  /dev/null

    ls: te_file1: No such file or directory
    ```

    !!! question "Domanda"

     Cosa è successo qui? Perché l'output continua a essere visualizzato sullo schermo (stdout)?

5. Per vari motivi potresti voler sopprimere messaggi di errore come quello sopra riportato. Per farlo, digitare:

    ```bash
    [root@localhost folder1]# ls –l te_file1 > /dev/null 2>&1
    ```

    Non otterrete alcun risultato. Questa volta vengono soppressi sia l'output standard che l'errore standard.

    L'ordine di reindirizzamento è IMPORTANTE!!

    Il reindirizzamento viene letto da sinistra a destra sulla riga di comando. La parte più a sinistra del simbolo di reindirizzamento - ++greater++ invierà lo standard output (*stdout*) a `/dev/null`. Quindi la parte più a destra del reindirizzamento - `2>&1` duplicherà lo standard error **(2)** nello standard output **(1)**.

    Pertanto, il comando sopra riportato può essere letto come: *reindirizza stdout(1) a “/dev/null” e poi copia stderr (2) a stdout*

6. Per dimostrare ulteriormente l'importanza dell'ordine di reindirizzamento, prova:

    ```bash
    [root@localhost folder1]# ls –l tem_file 2>&1 > order.txt
    ```

    Utilizzate il comando `cat` per esaminare il contenuto del file “*order.txt*”

    La parte più a sinistra – “2>&1” copierà l'errore standard nell'output standard. Quindi, la parte più a destra di quanto sopra – “ > order.txt” reindirizza stdout al file order.txt.

7. Provare questa variante del passaggio precedente:

    ```bash
    [root@localhost folder1]# ls –l hgh_ghz 2> order2.txt > order2.txt
    ```

    !!! question "Domanda"

     Esamina il file "order2.txt" e spiega cosa è successo?

8. Per inviare l'output standard e l'errore standard a file separati; Digitare:

    ```bash
    [root@localhost folder1]# ls –l tep_f > standard_out 2> standard_err
    ```

    !!! question "Domanda"

     Sono stati creati due nuovi file. Quali sono i nomi dei file e qual è il loro contenuto?

9. È possibile reindirizzare sia lo *stdout* che lo *stderr* allo stesso file utilizzando:

    ```bash
    [root@localhost folder1]# ls –l te_fil &> standard_both
    ```

### 12. Cancellare file con `rm`

Il comando `rm` (Rimuovi) consente di eliminare definitivamente uno o più file, directory e relativi contenuti, senza possibilità di recupero se non tramite soluzioni di recupero esterne. È un comando potente, ma potenzialmente pericoloso se usato in modo improprio, poiché opera in modo irreversibile. Per questo motivo è importante utilizzarlo con cautela, controllando sempre i percorsi e i nomi dei file prima di eseguire l'operazione.  
Utilizzerete `rm` per eliminare alcuni dei file creati negli esercizi precedenti.

#### Come si usa `rm`

1. Mentre si è ancora nella directory `folder1`, eliminare il file *standard_err*. Digitare ++“y”++ alla richiesta di conferma:

    ```bash
    [root@localhost folder1]# rm   standard_err
    rm: remove `standard_err'? y
    ```

2. Eliminare il file *standard_out*. Per evitare che venga richiesta la conferma prima di eliminare un file, utilizzare l'opzione `–f` con il comando `rm`:

    ```bash
    [root@localhost folder1]# rm -f standard_out
    ```

3. Tornare alla directory home (`/root`) ed eliminare la directory `folder2`. Utilizzare `rm` per eliminare una cartella è necessario utilizzare l'opzione `–r`:

    ```bash
    [root@localhost root]# rm -r folder2
    rm: descend into directory 'folder2'? y
    rm: remove 'folder2/temp_file21'? y
    rm: remove 'folder2/temp_file22'? y
    rm: remove directory 'folder2'? y
    ```

    !!! question "Domanda"

     Vi è stato nuovamente chiesto di confermare la rimozione di ogni singolo file nella directory e della directory stessa.  Quale opzione si utilizzerà con il comando `rm  –r` per evitare che ciò accada?

### 13. Imparare `vi`

L'editor `vi` è uno degli editor di testo più potenti e diffusi disponibili su sistemi Linux e Unix-like. È uno strumento essenziale per amministratori di sistema e sviluppatori grazie alla sua efficienza e versatilità. A differenza di molti editor moderni, `vi` funziona principalmente in modalità testo, offrendo comandi rapidi e combinazioni di tasti che consentono di modificare i file con estrema precisione e velocità.

All'inizio la curva di apprendimento può essere ripida, ma una volta acquisita padronanza delle funzionalità di base, diventa uno strumento indispensabile per modificare file di configurazione, script e codice sorgente direttamente dal terminale.

`vi` è un mostro enorme che può fare praticamente tutto, compreso prepararti il caffè o la cioccolata calda!!

Invece di cercare di insegnarvi `vi`, questo esercizio vi indicherà uno strumento che vi consentirà di familiarizzare meglio con `vi`. Vi invitiamo a dedicare un po' di tempo alla lettura del tutorial online su `vi` (più precisamente su `vim`). Basta seguire le istruzioni.

#### Per imparare `vi`

1. Una volta effettuato l'accesso al sistema, digitare:

    [root@localhost root]# vimtutor

### 14. Ricerca di file con `find` e `locate`

Questo esercizio tratterà due delle utility più diffuse utilizzate per la ricerca di file e directory nel file system. Si tratta dei comandi `find` e `locate`.

#### `find`

Il comando `find` consente di cercare file e directory all'interno del filesystem in base a una vasta gamma di criteri, quali nome, tipo, dimensione, data di modifica, autorizzazioni e molto altro ancora. La sua capacità di eseguire azioni sui risultati trovati, come eliminare, spostare o elaborare file, lo rende uno strumento indispensabile per gli amministratori di sistema e gli utenti avanzati.

La sintassi generale per `find` è:

```bash
find   [path]    [options]   [criterion]    [action]
```

Se non si specifica alcuna directory o percorso, `find` cercherà nella directory corrente. Se non si specifica alcun criterio, ciò equivale a “*true*”, quindi verranno trovati tutti i file. L'utilità `find` offre numerose opzioni per eseguire praticamente qualsiasi tipo di ricerca di un file. Di seguito sono elencate solo alcune delle opzioni, dei criteri e delle azioni disponibili.

| OPZIONI               | DESCRIZIONE                                                                                                                                                                 |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| -xdev                 | non effettua ricerche nelle directory situate su altri file system                                                                                                          |
| -mindepth `<n>` | scende di almeno `<n>` livelli al di sotto della directory specificata prima di cercare i file                                                                        |
| -maxdepth `<n>` | cerca i file che si trovano al massimo a `<n>` livelli sotto la directory specificata                                                                                 |
| -follow               | segue i collegamenti simbolici se questi rimandano una directory                                                                                                            |
| -daystart             | quando si utilizzano test relativi al tempo (vedi sotto), prende come timestamp l'inizio del giorno corrente invece del valore predefinito (24 ore prima dell'ora corrente) |

| CRITERIO                                                      | DESCRIZIONE                                                                                                                                                                                                                                                                                                                                |
| ------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| -type `<type>`                                          | cerca un determinato tipo di file; `<type>` può essere uno dei seguenti: **f** (*file regolare*), **d** (*directory*) **l** (*collegamento simbolico*), **s** (*socket*), **b** (*file in modalità blocco*), **c** (*file in modalità carattere*) o **p** (*pipe con nome*)                                                          |
| -name `<pattern>`                                       | trova i file i cui nomi corrispondono a quelli specificati `<pattern>`                                                                                                                                                                                                                                                               |
| -iname `<pattern>`                                      | come *-nome*, ma ignora le maiuscole e le minuscole                                                                                                                                                                                                                                                                                        |
| -atime `<n>`, -amin `<n>`                         | trova i file a cui è stato effettuato l'ultimo accesso `<n>` giorni fa (*-atime*) o `<n>` minuti fa (*-amin*). È anche possibile specificare `+<n>` o `-<n>`, nel qual caso la ricerca verrà effettuata rispettivamente sui file a cui si è avuto accesso *al massimo* o *al minimo* `<n>` giorni/minuti fa. |
| -anewer `<file>`                                        | trova i file che sono stati aperti più recentemente rispetto al file `<file>`                                                                                                                                                                                                                                                        |
| -ctime `<n>`, -cmin `<n>`, -cnewer `<file>` | come per *-atime*, *-amin* e *-anewer*, ma si applica all'ultima volta in cui il contenuto del file è stato modificato                                                                                                                                                                                                                     |
| -regex `<pattern>`                                      | uguale a *-name*, ma il pattern viene trattato come un'espressione regolare                                                                                                                                                                                                                                                                |
| -iregex `<pattern>`                                     | uguale a *-regex*, ma ignora le maiuscole/minuscole                                                                                                                                                                                                                                                                                        |

| AZIONE                  | DESCRIZIONE                                                                                                                                                                                                                                                         |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| -print                  | stampa semplicemente il nome di ciascun file sullo standard output. Questa è una azione di default                                                                                                                                                                  |
| -ls                     | stampa sullo standard output l'equivalente di `ls -ilds` per ogni file trovato                                                                                                                                                                                      |
| -exec `<command>` | esegue il comando `<command>` su ogni file trovato. La riga di comando `<command>` deve terminare con un `;`, che deve essere preceduto da un carattere di escape affinché la shell non lo interpreti; la posizione del file è contrassegnata con `{}`. |
| -ok `<command>`   | uguale a *-exec* ma richiede una conferma per ogni comando                                                                                                                                                                                                          |

#### Come usare `locate`

1. Assicurarsi di trovarsi nella directory home.

2. Utilizzare il comando find per visualizzare tutti i file nella directory corrente (`pwd`). Digitare:

    ```bash
    [root@localhost root]# find


    ………..
    ./.bash_profile
    ./.bashrc
    ./.cshrc
    ./.tcshrc
    ./.viminfo
    ./folder1
    ./folder1/first.txt
    …………
    ```

    Il risultato mostra il comportamento predefinito di find quando viene utilizzato senza alcuna opzione.  
Visualizza tutti i file e le directory (*compresi i file nascosti*) nella directory di lavoro in modo ricorsivo.

3. Ora utilizzate `find` per trovare solo le directory nella vostra *pwd*. Digitare:

    ```bash
    [root@localhost root]# find -type d
    ./folder1
    ./folder2
    ………
    ```

    !!! question "Domande"

     Dal comando sopra riportato "find  –type  d"; cos'è l'"opzione", cos'è il "percorso", cos'è il "criterio" e infine cos'è l'"azione"?

4. Successivamente si cercheranno tutti i file presenti nel sistema che terminano con il suffisso  “.txt”:

    ```bash
    [root@localhost root]# find    /   -maxdepth   3   -name   "*.txt"   -print
    /root/folder1/first.txt
    /root/folder1/second.txt
    /root/folder1/order.txt
    /root/folder1/order2.txt
    ```

    !!! question "Domande"

     Sempre dal comando sopra riportato, cosa sono l'"opzione", il "percorso", il "criterio" e infine l'"azione"? (SUGGERIMENTO: L'azione = “- print”)

    La ricerca verrà eseguita solo su 3 directory di profondità dalla directory `/`. L'asterisco utilizzato nel comando sopra riportato è uno dei caratteri “*jolly*” presenti in Linux.  
L'uso dei caratteri jolly in Linux è chiamato “*globbing*”.

5. Utilizzare il comando `find` per trovare tutti i file nella "pwd" che hanno una dimensione "inferiore" a 200 kilobyte. Digitare:

    ```bash
    [root@localhost root]# find   . –size    -200k
    ```

6. Utilizzare il comando `find` per trovare tutti i file nella directory corrente che sono "più grandi" di 10 kilobyte e visualizzare anche il loro "tipo di file". Digitare:

    ```bash
    [root@localhost root]#  find   . –size  +10k   –exec    file     "{ }"      ";"
    ```

#### `locate`

Il comando `locate` consente di cercare file e directory all'interno del sistema. A differenza di altri comandi come `find`, che eseguono una ricerca in tempo reale, `locate` si basa su un database precompilato contenente i percorsi di tutti i file presenti nel sistema, garantendo risultati quasi istantanei. Questo database viene solitamente aggiornato periodicamente utilizzando il comando `updatedb`, gestito da un *cron job*. Grazie alla sua efficienza, `locate` è particolarmente utile per trovare rapidamente file o cartelle senza dover eseguire manualmente la scansione dell'intero file system.  
Tuttavia, è importante ricordare che i risultati potrebbero non essere sempre aggiornati se il database non è stato sincronizzato di recente con lo stato attuale del sistema.

| Utilizzo della ricerca:                                                                 |
| --------------------------------------------------------------------------------------- |
| locate [-qi] [-d `<path>`] [--database=`<path>`] `<search string>`... |
| locate [-r `<regexp>`] [--regexp=`<regexp>`]                                |

| Uso del database:                                                                                                                 |
| --------------------------------------------------------------------------------------------------------------------------------- |
| locate [-qv] [-o `<file>`] [--output=`<file>`]                                                                        |
| locate [-e `<dir1,dir2,...>`] [-f `<fs_type1,...>`] [-l `<level>`] [-c] [-U `<path>`] [-u] [`pattern...`] |

| Uso generale:                         |
| ------------------------------------- |
| locate \[-Vh\] \[--version\] [--help] |

#### Come si usa `locate`

1. Passa alla directory `folder1` e crea i file vuoti *temp1*, *temp2* e *temp3*:

    ```bash
    [root@localhost root]# cd   folder1;   touch temp1   temp2    temp3
    [root@localhost folder1]#
    ```

    Il punto e virgola (;) utilizzato nel comando sopra riportato consente di eseguire più comandi su una singola riga!!

2. Utilizzare `locate` per cercare tutti i file nella directory corrente che hanno il suffisso "temp"

    ```bash
    [root@localhost folder1]# locate  temp*
    /root/folder1/temp_file11
    /root/folder1/temp_file12
    /root/folder1/temp_file21
    /root/folder1/temp_file22
    ```

    Si noti che i tre file creati nel passaggio 1 NON sono stati trovati.

3. Si forzerà un aggiornamento del database utilizzando `updatedb` per consentirgli di rilevare tutti i file appena creati. Digitare:

    ```bash
    [root@localhost folder1]# updatedb
    ```

4. Ora riprovare la ricerca. Digitare:

    ```bash
    [root@localhost folder1]# locate temp
    ```

    !!! question "Domanda"

     Cosa è successo questa volta?

5. Tutto fatto con Lab 3.
