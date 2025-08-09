- - -
author: Wale Soyinka contributors: Steven Spencer, Ganna Zhyrnova tested on: All Versions tags:
  - lab exercise
  - system utilities
  - cli
- - -

# Laboratorio 3: Utilità di sistema comuni

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di

- Utilizzare le utilità di sistema comuni presenti sulla maggior parte dei sistemi Linux

Tempo stimato per completare questo laboratorio: 70 minuti

## Utilità di sistema comuni presenti nei sistemi Linux

Gli esercizi di questo laboratorio riguardano l'utilizzo di alcune utilità di sistema di base che sia gli utenti che gli amministratori devono conoscere bene. La maggior parte dei comandi viene utilizzata per navigare e manipolare il file system. Il file system è costituito da file e directory.

Gli esercizi tratteranno l'utilizzo delle utilità –`pwd`, `cd`, `ls`, `rm`, `mv`, `ftp`, `cp`, `touch`, `mkdir`, `file`, `cat`, `find`, e `locate`.

## Esercizio 1

### `cd`

Il comando `cd` sta per cambia directory. Inizierete questi laboratori passando ad altre directory sul file system.

#### Per utilizzare `cd`

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

6. Passare nuovamente alla directory /usr/local/. Digitare:

    ```bash
    [root@localhost root]# cd /usr/local
    ```

7. Per passare alla directory principale della directory locale, digitare "cd ..".

    ```bash
    [root@localhost local]# cd ..
    ```

    !!! question "Domanda"

     Qual è la directory principale della directory /usr/local/?

8. Per tornare rapidamente alla directory home di root, digitare "cd" senza alcun argomento.

    ```bash
    [root@localhost usr]# cd

    [root@localhost root]#
    ```

## Esercizio 2

### `pwd`

Il comando `pwd` sta per "directory di lavoro corrente". Mostra la posizione in cui ti trovi nel file system.

#### Per utilizzare `pwd`

1. Per scoprire la vostra directory di lavoro attuale, digitare:

    ```bash
    [root@localhost root]# pwd
    /root
    ```

2. Passare alla directory /usr/local/ utilizzando il comando "cd":

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

## Esercizio 3

### `mkdir`

Il comando `mkdir` viene utilizzato per creare directory. Si creeranno due directory chiamate "folder1" e "folder2".

#### Per utilizzare `mkdir`

1. Digitare:

    ```bash
    [root@localhost root]# mkdir folder1
    ```

2. Crea una seconda directory chiamata folder2

    ```bash
    [root@localhost root]# mkdir   folder2
    ```

3. Ora cambiate la vostra directory di lavoro nella directory “folder1” che avete creato sopra.

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

## Esercizio 4

### `touch`

Il comando `touch` può essere utilizzato per creare file ordinari. Verranno creati i file “file11, file12, file21 e file22” nelle cartelle create sopra.

#### Per utilizzare `touch`

1. Cambiare directory, ovvero `cd` alla folder1 e creare il  "file11:"

    ```bash
    [root@localhost folder1]# touch file11
    ```

2. Mentre si è ancora nella folder1, creare “file12:”

    ```bash
    [root@localhost folder1]# touch file12
    ```

3. Ora ritornare alla directory home di root.

4. `cd` nella folder2 e  creare "file21" e "file22"

    ```bash
    [root@localhost folder2]# Touch file21 file22
    ```

5. Tornare alla directory home di root.

## Esercizio 5

### `ls`

Il comando `ls` sta per lista. Elenca il contenuto di una directory.

#### Per utilizzare `ls`

1. Digitare `ls` nella directory home di root:

    ```bash
    [root@localhost root]# ls
    ```

    !!! question "Domanda"

     Elenca il contenuto della directory

2. Passare alla directory "folder1"

3. Elencare il contenuto della directory "folder1". Digitare `ls`

    ```bash
    [root@localhost folder1]# ls
    file11  file12
    ```

4. Passare alla directory "folder2" ed elencare il suo contenuto:

5. Tornare alla directory home ed elencare "tutti" i file e le cartelle nascosti:

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

## Esercizio 6

### `mv`

Il comando `mv` sta per muovere. Rinomina file o directory. Può anche spostare i file.

#### Per utilizzare `mv`

1. Passare alla directory "folder1" ed elencare il suo contenuto:

    ```bash
    [root@localhost root]# cd   folder1
    [root@localhost folder1] ls

    file11  file12
    ```

2. Si rinomineranno i file file11 e file12 nella directory “folder1” rispettivamente in temp_file11 e temp_file12:

    ```bash
    [root@localhost folder1]# mv file11 temp_file11
    ```

3. Elencare nuovamente il contenuto della folder1.

    ```bash
    [root@localhost folder1]# ls
    ```

    !!! question "Domanda"

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

## Esercizio 7

### `cp`

Il comando `cp` sta per copia. Crea copie di file o cartelle.

1. Cambiare la vostra directory nella directory "folder2".

2. Copiare il contenuto della "folder2" (temp_file21 e temp_file22) nella "folder1:"

    ```bash
    [root@localhost folder2]# cp  temp_file21  temp_file22    ../folder1
    ```

3. Elencare il contenuto della folder1.

    ```bash
    [root@localhost folder2]# ls  ../folder1
    temp_file11  temp_file12  temp_file21  temp_file22
    ```

4. Elencare il contenuto della folder2. Si noti che le copie originali di temp_file21 e temp_file22 rimangono nella folder2.

    ```bash
    [root@localhost folder2]# ls
    temp_file21  temp_file22
    ```

## Esercizio 8

### `file`

L'utilità `file` viene utilizzata per determinare i tipi di file o directory.

#### Per utilizzare `file`

1. Tornare alla directory home.

2. Per vedere se "folder1" è un file o una directory, digitare:

    ```bash
    [root@localhost root]# file    folder1
    folder1: directory
    ```

3. Passare alla folder1

4. Utilizzare l'utilità `file` per determinare il tipo di file per temp_file11:

    ```bash
    [root@localhost folder1]# file     temp_file11
    temp_file11: empty
    ```

5. Utilizzare l'utilità `file` per scoprire il tipo di file di tutti i file presenti nella folder1. Elenco qui:

6. Passare alla cartella /etc:

    ```bash
    [root@localhost folder1]# cd /etc
    ```

7. Utilizzare l'utilità `file` per scoprire il tipo di file del file "passwd".

    ```bash
    [root@localhost etc]# file passwd
    ```

    !!! question "Domanda"

     Di che tipo di file si tratta?

## Esercizio 9

### `cat`

Il comando `cat` è l'abbreviazione di concatenate, cioè mettere insieme i file. Il comando `cat` visualizza anche il contenuto di un intero file sullo schermo. Si utilizzerà `cat` insieme al simbolo di reindirizzamento ">" per creare un file.

#### Per usare `cat` per creare un file

1. Passare alla directory /root/folder1

2. Creare un nuovo file di testo chiamato "first.txt"

    ```bash
    [root@localhost folder1]# cat > first.txt
    ```

3. Digitare la frase seguente nel prompt vuoto e premere ++enter++.

    ```bash
    Questa è una riga di first.txt !!
    ```

4. Premere contemporaneamente i tasti ++ctrl+c++.

5. Digitare "cat first.txt" per leggere il testo appena digitato:

    ```bash
    [root@localhost folder1]#  cat    first.txt
    Questa è una riga di first.txt !!
    ```

6. Creare un altro file chiamato "second.txt" utilizzando `cat`. Digitare il seguente testo nel file – “Questa è una riga di second.txt !!”

    !!! question "Domanda"
   
        Qual è il comando per farlo?

#### Per usare `cat` per concatenare insieme i file

1. Si concatenaneranno i file "first.txt" e "second.txt". Digitare:

    ```bash
    [root@localhost folder1]#  cat     first.txt    second.txt
    ```

    !!! question "Domanda"

     Qual è il vostro risultato?

## Esercizio 10

### `ftp`

`ftp` è un programma client per l'utilizzo e la connessione ai servizi FTP tramite il File Transfer Protocol. Il programma consente agli utenti di trasferire file da e verso un sito di rete remoto. Si tratta di un'utility che potrebbe essere utilizzata spesso.

In questo esercizio imparerete ad accedere in modo anonimo a un server FTP e a scaricare un file dal server utilizzando un programma client `ftp`.

!!! note "Nota"

    Per poter seguire questo esercizio specifico, che richiede un server FTP disponibile e raggiungibile, è necessario aver completato gli esercizi del laboratorio precedente.

#### Per utilizzare `ftp`

1. Accedere al computer come root

2. Passare alla directory "/usr/local/src/"

3. Creare una nuova directory chiamata "downloads" nella directory "/usr/local/src/".

    !!! question "Domanda"
   
        Qual è il comando per farlo?

4. Passa alla directory "downloads" appena creata

    ```bash
    [root@localhost src]# cd  downloads
    ```

5. Digitare "ftp" per avviare il client `ftp`:

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

7. Accedere come utente anonimo. Digitare "anonymous" al prompt:

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

     Qual è l'output del comando binario e cos'è la modalità binaria “modalità binaria”?

10. Elencare le directory correnti sul server ftp. Digitare "ls" al prompt ftp. (ftp>):

    ```bash
    ftp>  ls  
    227 Entering Passive Mode (10,0,4,5,16,103).
    125 Data connection already open; Transfer starting.
    11-23-43  10:23PM       <DIR>          images
    11-02-43  02:20PM       <DIR>          pub
    226 Transfer complete.
    ```

11. Passare alla directory "pub". Digitare:

    ```bash
    ftp> cd  pub
    ```

12. Utilizzare il comando "ls" per elencare i file e le directory presenti nella directory "pub"

    !!! question "Domanda"
    
         Quanti file e directory ci sono adesso?

13. Scaricare il file denominato "hello-2.1.1.tar.gz" nella directory locale. Digitare "yes" quando richiesto.

    ```bash
    ftp>  mget     hello-2.1.1.tar.gz
    mget hello-2.1.1.tar.gz?    yes

    227 Entering Passive Mode (10,0,4,5,16,252).

    125 Data connection already open; Transfer starting.

    226 Transfer complete.

    389363 bytes received in 0.0745 secs (5.1e+03 Kbytes/sec)
    ```

14. Disconnettersi dal server FTP e chiudere il client `ftp`. Digitare:

    ```bash
    ftp> bye
    ```

15. Verrai reindirizzato alla tua shell locale.

16. Assicurati di trovarti ancora nella directory "download" del tuo computer locale.

    !!! question "Domanda"
    
         Elencare i file nella cartella dei downloads.

## Esercizio 11

### Utilizzo del reindirizzamento

La maggior parte delle utility e dei comandi utilizzati in Linux inviano il loro output allo schermo. Lo schermo è chiamato output standard (stdout). Il reindirizzamento consente di inviare l'output altrove – ad esempio in un file.

Ogni programma avviato su un sistema Linux ha tre descrittori di file aperti: stdin (0), stdout (1) e stderr (2). È possibile reindirizzarli o convogliarli individualmente tramite "pipe". I simboli di reindirizzamento sono ">, < "

#### Per utilizzare il reindirizzamento

1. Assicurarsi di essere ancora nella directory folder1.

2. Si utilizzerà il reindirizzamento dell'output per reindirizzare l'output del comando ls (elenco) a un file di testo denominato myredirects:

    ```bash
    [root@localhost folder1]# ls  > myredirects
    ```

3. Esaminare il contenuto del nuovo file (myredirects) creato nella directory folder1.

    ```bash
    [root@localhost folder1] # cat     myredirects
    temp_file11  temp_file12  temp_file21  temp_file22 myredirects
    ```

4. Ora il risultato del comando file verrà reindirizzato nello stesso file. Si vuole scoprire il tipo di file per temp_file11 nella directory folder1 e inviare l'output al file myredirects:

    ```bash
    [root@localhost folder1]#  file    temp_file11   >   myredirects
    ```

5. Esaminare il contenuto del file myredirects.

    !!! question "Domanda"
   
        È cambiato. Cos'è successo?

6. Se si vuole evitare che si verifichi quanto sopra, si utilizzerà il doppio simbolo di reindirizzamento “>>”.  Questo aggiungerà (appenderà) il nuovo output al file invece di sostituirlo. Fate una prova:

    ```bash
    [root@localhost folder1]#  ls  >>  myredirects
    ```

7. Ora esaminare nuovamente il contenuto del file myredirects utilizzando `cat`.

    !!! question "Domanda"
   
        Scrivi qui il suo contenuto:

### Utilizzo del reindirizzamento per sopprimere l'output di un comando

I concetti trattati in questa sezione saranno molto utili in Linux, quindi ti invitiamo a prestare particolare attenzione. Può essere un po' complicato.

Ci saranno momenti in cui non vorrai che l'utente veda l'output di un comando, ad esempio un messaggio di errore. Questo accade solitamente perché i messaggi di errore strani spesso spaventano gli utenti abituali. In questo esercizio si invierà l'output tuoi comandi al dispositivo nullo ( /dev/null/ ). Il dispositivo nullo è come un "bit bucket". Tutto ciò che metti dentro scompare per sempre. È anche possibile inviare (o reindirizzare) l'output regolare dei comandi al dispositivo nullo "null device".

Utilizzare le linee guida riportate di seguito:

```bash
|Redirector|<p></p><p>Function</p>|
| :- | :- |
|> file|Indirizza l'output standard su un file|
|< file|Prende l'input standard dal file|
|Cmd1 | cmd2|Pipe; prende lo standard out da cmd1 come input standard per cmd2|
|n> file|Descritore di file n a file|
|N< file|Imposta il file come descrittore di file n|
|>&n|Duplica l'output standard nel descrittore di file n|
|<&n|Duplica l'input standard dal descrittore di file n|
|&>file|Indirizza l'output standard e l'errore standard al file|

```

1. Assicurarsi di essere ancora nella directory folder1. Utilizzare l'opzione di elenco esteso del comando ls su temp_file11:

    ```bash
    [root@localhost folder1]#  ls   –l   temp_file11
    -rw-r--r--    1 root     root            0 Jul 26 18:26 temp_file11
    ```

2. Reindirizzare l'output dello stesso comando sopra riportato (ls –l  temp_file11) al dispositivo nullo.

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

4. Eseguire lo stesso comando di cui sopra con un nome file scritto in modo errato e reindirizzarlo a /dev/null

    ```bash
    [root@localhost folder1]# ls   -l   te_file1  >  /dev/null

    ls: te_file1: No such file or directory
    ```

    !!! question "Domanda"

     Cosa è successo qui? Perché l'output continuava a essere visualizzato sullo schermo (stdout)?

5. Per vari motivi potresti voler sopprimere messaggi di errore come quello sopra riportato. Per farlo, digitare:

    ```bash
    [root@localhost folder1]# ls –l te_file1 > /dev/null 2>&1
    ```

    Non otterrete alcun risultato.

    Questa volta vengono soppressi sia l'output standard che l'errore standard.

    L'ordine di reindirizzamento è IMPORTANTE!!

    Il reindirizzamento viene letto da sinistra a destra sulla riga di comando.

    La parte più a sinistra del simbolo di reindirizzamento - “>”: invierà l'output standard (stdout) a /dev/null. Quindi la parte più a destra del reindirizzamento - “2>&1 ”: duplicherà l'errore standard (2) nell'output standard (1).

    Quindi il comando sopra riportato può essere letto come: reindirizza stdout(1) a “/dev/null” e poi copia stderr (2) su stdout

6. Per dimostrare ulteriormente l'importanza dell'ordine di reindirizzamento, prova:

    ```bash
    [root@localhost folder1]# ls   –l    tem_file  2>&1   > order.txt
    ```

    Utilizzare il comando `cat` per esaminare il contenuto del file "order.txt"

    La parte più a sinistra – “2>&1” copierà l'errore standard nell'output standard. Quindi, la parte più a destra di quanto sopra – “ > order.txt” reindirizza stdout al file order.txt.

7. Provare questa variante del passaggio precedente:

    ```bash
    [root@localhost folder1]# ls  –l   hgh_ghz  2>  order2.txt   > order2.txt
    ```

    !!! question "Domanda"

     Esamina il file "order2.txt" e spiega cosa è successo?

8. Per inviare l'output standard e l'errore standard a file separati; Digitare:

    ```bash
    [root@localhost folder1]# ls  –l  tep_f   > standard_out  2> standard_err
    ```

    !!! question "Domanda"

     Sono stati creati due nuovi file. Quali sono i nomi dei file e qual è il loro contenuto?

9. È possibile reindirizzare sia stdout che stderr allo stesso file utilizzando:

    ```bash
    [root@localhost folder1]# ls  –l   te_fil   &>   standard_both
    ```

## Esercizio 12

### `rm`

Il comando `rm` viene utilizzato per eliminare file o directory. Si utilizzerà il comando `rm` per eliminare alcuni dei file creati negli esercizi precedenti.

#### Per utilizzare `rm`

1. Mentre si è ancora nella directory "folder1", eliminare il file standard_err. Digitare "y" alla richiesta di conferma:

    ```bash
    [root@localhost folder1]# rm   standard_err
    rm: remove `standard_err'? y
    ```

2. Eliminare il file "standard_out". Per evitare che venga richiesta la conferma prima di eliminare un file, utilizzare l'opzione "–f " con il comando `rm`:

    ```bash
    [root@localhost folder1]# rm   -f   standard_out
    ```

3. Ritornare alla directory home (/root) ed eliminare la directory "folder2". Se si vuole usare `rm` per eliminare una cartella, bisogna usare l'opzione “–r”:

    ```bash
    [root@localhost root]# rm  -r   folder2

    rm: descend into directory `folder2'? y

    rm: remove `folder2/temp_file21'? y

    rm: remove `folder2/temp_file22'? y

    rm: remove directory `folder2'? y
    ```

    !!! question "Domanda"

     Vi è stato nuovamente chiesto di confermare la rimozione di ogni singolo file nella directory e della directory stessa.  Quale opzione si utilizzerà con il comando `rm  –r` per evitare che ciò accada?

## Esercizio 13

### Imparare `vi`

`vi` è un editor di testo. Può essere utilizzato per modificare tutti i tipi di testo semplice. È particolarmente utile per i programmi di editing.

`vi` è un mostro enorme che può fare praticamente tutto, compreso prepararti il caffè o la cioccolata calda!!

Invece di cercare di insegnarvi `vi`, questo esercizio vi indicherà uno strumento che vi consentirà di familiarizzare meglio con `vi`.

Vi invitiamo a dedicare un po' di tempo alla lettura del tutorial online su `vi` (più precisamente su `vim`). Basta seguire le istruzioni.

#### Per imparare `vi`

1. Una volta effettuato l'accesso al sistema, digitare:

    [root@localhost root]# vimtutor

## Esercizio 14

### Ricerca di file: (`find` e `locate`)

Questo esercizio tratterà due delle utility più diffuse utilizzate per la ricerca di file e directory nel file system. Si tratta dei comandi `find` e `locate`.

#### `find`

L'utilità `find` esiste da molto tempo. Esegue una scansione ricorsiva delle directory per trovare i file che corrispondono a un determinato criterio.

La sintassi generale per `find` è:

```bash
find   [path]    [options]   [criterion]    [action]
```

Se non si specifica alcuna directory o percorso, find cercherà nella directory corrente. Se non si specifica alcun criterio, ciò equivale a "vero", quindi verranno trovati tutti i file. L'utilità `find` offre numerose opzioni per eseguire praticamente qualsiasi tipo di ricerca di un file. Di seguito sono elencate solo alcune delle opzioni, dei criteri e delle azioni disponibili.

```bash
OPZIONI:

-xdev: non effettuare ricerche nelle directory situate su altri file system.;

-mindepth <n> scendere di almeno <n> livelli al di sotto della directory specificata prima della

ricerca di file;

-maxdepth <n>: cerca i file che si trovano al massimo a n livelli sotto la directory specificata;

-follow: segui i collegamenti simbolici se puntano a directory.

-daystart: quando si utilizzano test relativi al tempo (vedi sotto), prendere l'inizio del giorno corrente come timestamp invece del valore predefinito (24 ore prima dell'ora corrente).
```

```bash
CRITERIO

-type <type>: cerca un determinato tipo di file; <type> può essere uno dei seguenti: f (file regolare), d (directory),

l (collegamento simbolico), s (socket), b (file in modalità blocco), c (file in modalità carattere) o

p (pipe con nome);

-name <pattern>: trova i file i cui nomi corrispondono al modello specificato <pattern>;

-iname <pattern>: like -name, but ignore case;

-atime <n>, -amin <n>: trova i file a cui è stato effettuato l'ultimo accesso <n> giorni fa (-atime) o <n> minuti fa (-amin). È anche possibile specificare +<n> o -<n>, nel qual caso la ricerca verrà effettuata rispettivamente sui file a cui è stato effettuato l'accesso al massimo o al minimo <n> giorni/minuti fa;

-anewer <file>: trova i file che sono stati aperti più di recente rispetto al file <file>;

-ctime <n>, -cmin <n>, -cnewer <file>: come per -atime, -amin e -anewer, ma si applica all'ultima volta in cui il contenuto del file è stato modificato;

-regex <pattern>: come per -name, ma il pattern viene trattato come un'espressione regolare;

-iregex <pattern>: come per -regex, ma ignora le maiuscole/minuscole.
```

```bash
AZIONE:

-print: stampa semplicemente il nome di ogni file sullo standard output. Questa è l'azione predefinita;

-ls: stampa sullo standard output l'equivalente di ls -ilds per ogni file trovato;

-exec <command>: execute command <command> su ogni file trovato. La riga di comando <command> deve terminare con un ;, che deve essere preceduto dal carattere di escape in modo che la shell non lo interpreti; la posizione del file è contrassegnata da {}.

-ok <command>: come per -exec, ma richiede una conferma per ogni comando.
```

#### Per utilizzare `find`

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

    Visualizza tutti i file e le directory (compresi i file nascosti) nella directory di lavoro in modo ricorsivo.

3. Ora utilizzare `find` per trovare solo le directory nella tua pwd. Digitare:

    ```bash
    [root@localhost root]# find   -type   d
    .
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

    La ricerca verrà eseguita solo su 3 directory in basso dalla directory “/”.

    L'asterisco utilizzato nel comando sopra riportato è uno dei caratteri "jolly" in Linux.

    L'uso dei caratteri jolly in Linux è chiamato "globbing".

5. Utilizzare il comando `find` per trovare tutti i file nella "pwd" che hanno una dimensione "inferiore" a 200 kilobyte. Digitare:

    ```bash
    [root@localhost root]# find   .   –size    -200k
    ```

6. Utilizzare il comando `find` per trovare tutti i file nella directory corrente che sono "più grandi" di 10 kilobyte e visualizzare anche il loro "tipo di file". Digitare:

    ```bash
    [root@localhost root]#  find   .  –size  +10k   –exec    file     "{ }"      ";"
    ```

#### `locate`

La sintassi del comando `find` può essere piuttosto difficile da usare in alcuni casi e, a causa della sua ricerca estesa, può essere lenta. Un comando alternativo è `locate`.

`locate` effettua una ricerca in un database creato in precedenza contenente tutti i file presenti nel file system.

Si basa sul programma `updatedb`.

```bash
utilizzo della ricerca:

locate [-qi] [-d <path>] [--database=<path>] <search string>...

locate [-r <regexp>] [--regexp=<regexp>]

database usage: locate [-qv] [-o <file>] [--output=<file>]

locate [-e <dir1,dir2,...>] [-f <fs_type1,...> ] [-l <level>]

[-c] <[-U <path>] [-u]>

general usage: locate [-Vh] [--version] [--help]
```

#### Per utilizzare `locate`

1. Passare alla directory folder1 e creare i file vuoti temp1, temp2 e temp3:

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
    [root@localhost folder1]# locate    temp
    ```

    !!! question "Domanda"

     Cosa è successo questa volta?

5. Tutto fatto con Lab 3.
