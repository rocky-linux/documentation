---
title: Comandi Linux
author: Antoine Le Morvan
contributors: Steven Spencer, Franco Colussi
update: 11-10-2021
---

# Comandi per gli utenti Linux

In questo capitolo imparerai come lavorare con Linux e con i comandi.

****

**Obiettivi** : In questo capitolo, futuri amministratori Linux impareranno come fare per:

:heavy_check_mark: **spostarsi** nell'albero di sistema;  
:heavy_check_mark: **creare** un file di testo, **visualizzare** il suo contenuto e **modificarlo**;  
:heavy_check_mark: utilizzare i comandi Linux più utili.

:checkered_flag: **comandi utente**, **linux**

**Conoscenza**: :star:  
**Complessità**: :star:

**Tempo di lettura**: 40 minuti

****

## Generalità

I sistemi Linux attuali hanno utilità grafiche dedicate al lavoro di un amministratore. Tuttavia, è importante essere in grado di utilizzare l'interfaccia in modalità riga di comando per diversi motivi:

* La maggior parte dei comandi di sistema sono comuni a tutte le distribuzioni Linux, questo non è il caso degli strumenti grafici.
* Può accadere che il sistema non si avvii correttamente ma che un interprete di comando di backup rimanga accessibile.
* L'amministrazione remota viene eseguita dalla riga di comando con un terminale SSH.
* Per preservare le risorse del server, l'interfaccia grafica è installata o lanciata su richiesta.
* L'amministrazione è eseguita da scripts.

L'apprendimento di questi comandi consente all'amministratore di connettersi a un terminale Linux, per gestire le sue risorse, i suoi files, identificare la stazione, il terminale e gli utenti connessi, etc.

### Gli utenti

L'utente di un sistema Linux è definito nel file `/etc/passwd`, da:

* un **nome di login**, o più comunemente chiamato "login", che non può contenere spazi;
* un identificatore numerico : **UID** (User Identifier);
* un identificatore di gruppo : **GID** (Group Identifier);
* un **interprete di comandi**, una shell, che può essere diversa da un utente all'altro;
* una **directory di connessione**, la __home directory__.

In altri file da:

* una **password**, che verrà crittografata prima di essere memorizzata (`/etc/shadow`);
* un **prompt dei comandi**, o __prompt login__, che sarà simboleggiato da un `#` per gli amministratori e da un `$` per gli altri utenti (`/etc/profile`).

A seconda della politica di sicurezza implementata sul sistema, la password dovrà contenere un certo numero di caratteri e soddisfare determinati requisiti di complessità.

Tra gli interpreti di comando esistenti, la **Bourne-Again Shell** (`/bin/bash`) è quella più frequentemente usata. È assegnata per impostazione predefinita ai nuovi utenti. Per vari motivi, gli utenti avanzati di Linux possono scegliere shells alternative tra la Korn Shell (`ksh`), la C Shell (`csh`), etc.

La directory di accesso dell'utente è per convenzione memorizzata nella directory `/home` della workstation. Conterrà i dati personali dell'utente e i file di configurazione delle sue applicazioni. Per impostazione predefinita, al login, la directory di accesso è selezionata come directory corrente.

Un'installazione di tipo workstation (con interfaccia grafica) avvia questa interfaccia sul terminale 1. Linux può essere multiutente, è possibile connettere diversi utenti più volte, in differenti **terminali fisici** (TTY) o **terminali virtuali** (PTS). I terminali virtuali sono disponibili all'interno di un ambiente grafico. Un utente passa da un terminale fisico ad un altro usando <kbd>Alt</kbd> + <kbd>Fx</kbd> dalla riga di comando o utilizzando <kbd>CTRL</kbd> + <kbd>Alt</kbd> + <kbd>Fx</kbd> in modalità grafica.

### La shell

Una volta che l'utente è collegato a una console, la shell visualizza il **prompt** dei comandi. Quindi inizia un loop (ciclo infinito), con ogni stringa inserita:

* visualizzazione del prompt dei comandi;
* lettura del comando ;
* analisi della sintassi ;
* sostituzione di caratteri speciali ;
* esecuzione del comando;
* visualizza il prompt dei comandi;
* etc.

La sequenza chiave <kbd>CTRL</kbd> + <kbd>C</kbd> è usata per interrompere un comando in esecuzione.

L'uso di un comando segue generalmente questa sequenza:

```bash
comando [opzione(i)] [argomento(i)]
```

Il nome del comando è **spesso in minuscolo**.

Uno spazio separa ogni oggetto.

Le **opzioni** abbreviate iniziano con un trattino (`-l`), mentre le **opzioni lunghe** iniziano con due trattini (`--list`). Un doppio trattino (`--`) indica la fine dell'elenco delle opzioni.

È possibile raggruppare alcune opzioni brevi insieme:

```bash
$ ls -l -i -a
```

è equivalente a:

```bash
$ ls -lia
```

Naturalmente ci possono essere diversi argomenti dopo un'opzione:

```bash
$ ls -lia /etc /home /var
```

In letteratura, il termine "opzione" è equivalente al termine "parametro," che è più comunemente usato nella programmazione. Il lato opzionale di un'opzione o argomento è simboleggiata dall'inclusione in parentesi quadre `[` e `]`. Quando è possibile più di un'opzione, Una barra verticale chiamata "pipe" li separa `[a|e|i]`.

## Comandi generali

### comandi `apropos`, `whatis` e `man`

È impossibile per un amministratore a qualsiasi livello conoscere tutti i comandi e le opzioni in dettaglio. Un manuale è solitamente disponibile per tutti i comandi installati.

#### comando `apropos`

Il comando `apropos` ti consente di cercare per parola chiave all'interno di queste pagine manuali:

| Opzioni                                    | Osservazioni                                                             |
| ------------------------------------------ | ------------------------------------------------------------------------ |
| `-s`, `--sections list` o `--section list` | Limitato alle sezioni manuali.                                           |
| `-a` o `--and`                             | Visualizza solo la voce corrispondente a tutte le parole chiave fornite. |

Esempio:

```bash
$ apropos clear
clear (1)            - clear the terminal screen
clear_console (1)    - clear the console
clearenv (3)         - clear the environment
clearerr (3)         - check and reset stream status
clearerr_unlocked (3) - nonlocking stdio functions
feclearexcept (3)    - floating-point rounding and exception handling
fwup_clear_status (3) - library to support management of system firmware updates
klogctl (3)          - read and/or clear kernel message ring buffer; set console_loglevel
sgt-samegame (6)     - Block-clearing puzzle
syslog (2)           - read and/or clear kernel message ring buffer; set console_loglevel
timerclear (3)       - timeval operations
XClearArea (3)       - clear area or window
XClearWindow (3)     - clear area or window
XSelectionClearEvent (3) - SelectionClear event structure
```

Per trovare il comando che consentirà di cambiare la password di un account:

```bash
$ apropos --exact password  -a change
chage (1)            - change user password expiry information
passwd (1)           - change user password
```

#### comando `whatis`

Il comando `whatis` visualizza la descrizione del comando passata come argomento:

```bash
whatis clear
```

Esempio:

```bash
$ whatis clear
clear (1)            - clear the terminal screen
```

#### comando `man`

Una volta trovato con `apropos` o `whatis`, il manuale è letto da `man` ("Man è tuo amico"). Questo set di manuali è diviso in 8 sezioni, raggruppando le informazioni per argomento, la sezione predefinita è la 1:

1. Comandi utente;
2. Chiamate di sistema;
3. Funzioni della libreria C;
4. Periferiche e file speciali;
5. Formati di file ;
6. Giochi;
7. Varie;
8. Strumenti e demoni dell'amministrazione del sistema.

È possibile accedere alle informazioni su ciascuna sezione digitando `man x intro`, dove `x` è il numero della sezione.

Il comando:

```bash
man passwd
```

dirà all'amministratore le opzioni, etc, del comando passwd. Mentre:

```bash
$ man 5 passwd
```

lo informerà sui file relativi al comando.

Non tutte le pagine del manuale sono tradotte dall'inglese. Tuttavia, sono generalmente molto accurate e forniscono tutte le informazioni necessarie. La sintassi utilizzata e la divisione può confondere l'amministratore principiante, ma con la pratica, troverà rapidamente le informazioni che sta cercando.

La navigazione nel manuale viene eseguita con le frecce <kbd>↑</kbd> e <kbd>↓</kbd>. Il manuale si esce premendo il tasto <kbd>q</kbd>.

### comando `shutdown`

Il comando `shutdown` ti permette di fare lo **spegnimento elettrico** del server Linux, o immediatamente o dopo un certo periodo di tempo.

```bash
shutdown [-h] [-r] time [message]
```

Il tempo di spegnimento dovrebbe essere specificato nel formato `hh:mm` per un tempo preciso, o `+mm` per un ritardo in minuti.

Per forzare un arresto immediato, la parola `now` sostituirà il tempo. In questo caso, il messaggio opzionale non viene inviato agli altri utenti del sistema.

Esempi:

```bash
[root]# shutdown -h 0:30 "Server shutdown at 0:30"
[root]# shutdown -r +5
```

Opzioni:

| Opzioni | Osservazioni                     |
| ------- | -------------------------------- |
| `-h`    | Spegne il sistema elettricamente |
| `-r`    | Riavvia il sistema               |

### comando `history`

Il comando `history` visualizza la cronologia dei comandi che sono stati inseriti dall'utente.

I comandi sono memorizzati nel file `.bash_history` nella directory di accesso dell'utente.

Esempio di un comando history

```bash
$ history
147 man ls
148 man history
```

| Opzioni | Commenti                                                                                                      |
| ------- | ------------------------------------------------------------------------------------------------------------- |
| `-w`    | L'opzione`-w` copierà la cronologia della sessione corrente nel file.                                         |
| `-c`    | L'opzione`-c` eliminerà la cronologia della sessione corrente (ma non il contenuto del file `.bash_history`). |

* Manipolazione della history:

Per manipolare la history, i seguenti comandi immessi dal prompt dei comandi permetteranno di:

| Chiavi             | Funzione                                                   |
| ------------------ | ---------------------------------------------------------- |
| <kdb>!!</kdb>      | Richiama l'ultimo comando eseguito.                        |
| <kdb>!n</kdb>      | Richiama il comando per il suo numero nell'elenco.         |
| <kdb>!string</kdb> | Richiama il comando più recente che inizia con la stringa. |
| <kdb>↑</kdb>       | Richiama il comando più recente che inizia con la stringa. |
| <kdb>↓</kdb>       | Richiama il comando più recente che inizia con la stringa. |

### Il completamento automatico

Il completamento automatico è anche un grande aiuto.

* Ti consente di completare i comandi, i percorsi inseriti o i nomi dei file.
* Una pressione del tasto <kbd>TAB</kbd> completa la voce nel caso di una soluzione singola.
* Altrimenti, sarà richiesta una seconda pressione per ottenere l'elenco delle possibilità.

Se una doppia pressione del tasto <kbd>TAB</kbd> non produce nessuna reazione dal sistema, allora non c'è soluzione al completamento corrente.

## Visualizzazione e identificazione

### commando `clear`

Il comando `clear` cancella il contenuto della schermata del terminale. Infatti, per essere più precisi, sposta il display in modo che il prompt dei comandi sia nella parte superiore dello schermo sulla prima riga.

In un terminale, il display sarà permanentemente nascosto, mentre nell'interfaccia grafica, una barra di scorrimento ti permetterà sempre di scorrere la cronologia del terminale virtuale.

!!! Tip "Suggerimento" <kbd>CTRL</kbd> + <kbd>L</kbd> avrà lo stesso effetto del comando `clear`

### comando `echo`

Il comando `echo` è usato per visualizzare una stringa di caratteri.

Questo comando è più comunemente usato negli script amministrativi per informare l'utente durante l'esecuzione.

L'opzione `-n` non tornerà alla linea dopo aver visualizzato il testo (che è il comportamento predefinito del comando).

Per vari motivi, allo sviluppatore dello script potrebbe essere necessario utilizzare sequenze speciali (a partire da un carattere `\`). In questo caso, sara usata l'opzione `-e`, che consentirà l'interpretazione della sequenza.

Tra le sequenze usate frequentemente, possiamo menzionare:

| Sequenza | Risultato                          |
| -------- | ---------------------------------- |
| `\a`    | Invia un bip sonoro                |
| `\b`    | Indietro                           |
| `\n`    | Aggiunge una interruzione di linea |
| `\t`    | Aggiunge un tab orizzontale        |
| `\v`    | Aggiunge tab verticale             |

### comando `date`

Il comando `date` visualizza la data e l'ora. Il comando ha la seguente sintassi:

```bash
date [-d AAAAMMJJ] [format]
```

Esempi:

```bash
$ date
Mon May 24 16:46:53 CEST 2021
$ date -d 20210517 +%j
137
```

In questo ultimo esempio, l'opzione `d` visualizza una data fornita. L'opzione `+%j` formatta questa data per mostrare solo il giorno dell'anno.

!!! Warning Attenzione Il formato di una data può cambiare a seconda del valore della lingua definita nella variabile di ambiente `$LANG`.

Il display della data può seguire i seguenti formati:

| Opzione | Formato                                 |
| ------- | --------------------------------------- |
| `+%A`   | Nome completo del giorno                |
| `+%B`   | Nome completo del mese                  |
| `+%c`   | Visualizzazione completa della data     |
| `+%d`   | Numero del giorno                       |
| `+%F`   | Data nel formato`YYYY-MM-DD`            |
| `+%G`   | Anno                                    |
| `+%H`   | Ora del giorno                          |
| `+%j`   | Giorno dell'anno                        |
| `+%m`   | Numero del mese                         |
| `+%M`   | Minuti                                  |
| `+%R`   | Tempo nel formato`hh:mm`                |
| `+%s`   | Secondi dal 1° gennaio 1970             |
| `+%T`   | Tempo nel formato`hh:mm:ss`             |
| `+%u`   | Giorno della settimana (`1` per Lunedì) |
| `+%V`   | Numero della settimana (`+%V`)          |
| `+%x`   | Data in formato`DD/MM/YYYY`             |

Il comando `date` consente anche di modificare la data e l'ora del sistema. In questo caso, verrà utilizzata l'opzione `-s`.

```bash
[root]# date -s "2021-05-24 10:19"
```

Il formato da utilizzare usando l'opzione `-s` il seguente:

```bash
date -s "[AA]AA-MM-JJ hh:mm:[ss]"
```

### comando `id`, `who` e `whoami`

Il comando `id` visualizza il nome dell'attuale utente e dei suoi gruppi o quelli di un utente, se il login dell'utente viene assegnato come argomento.

```bash
$ id rockstar
uid=1000(rockstar) gid=1000(rockstar) groups=1000(rockstar),10(wheel)
```

Le opzioni `-g`, `-G`, `-n` e `-u` visualizzano il gruppo principale GID, sottogruppo GIDs, nomi al posto di identificatori numerici, e l'UID dell'utente.

Il comando `whoami` visualizza il login dell'utente corrente.

Il comando `who` da solo visualizza i nomi degli utenti registrati:

```bash
$ who
rockstar tty1   2021-05-24 10:30
root     pts/0  2021-05-24 10:31
```

Poiché Linux è multi-utente, è probabile che più sessioni siano aperte sulla stessa stazione, fisicamente o sulla rete. È interessante sapere quali utenti sono registrati, se non solo per comunicare con loro inviando messaggi.

* tty: rappresenta un terminale.
* pts/: rappresenta una console virtuale in un ambiente grafico con il numero dopo aver rappresentato l'istanza della console virtuale (0, 1, 2...)

L'opzione `-r` visualizza anche il livello di esecuzione (vedere il capitolo "startup").

## Albero dei File

In Linux, l'albero dei file è un albero invertito, chiamato **albero gerarchico singolo**, la cui radice è la directory `/`.

La **directory corrente** è la directory in cui si trova l'utente.

La **directory di connessione** è la directory di lavoro associata all'utente. Le directory di accesso sono, per impostazione predefinita, memorizzate nella directory `/home`.

Quando l'utente accede, la directory corrente è la directory di accesso.

Un **percorso assoluto** fa riferimento ad un file dalla radice attraversando l'intero albero fino al livello del file:

* `/home/groupA/alice/file`

Un **percorso relativo** fa riferimento allo stesso file attraversando l'intero albero dalla directory corrente:

* `../alice/file`

Nell'esempio sopra, il "`..` " si riferisce alla directory principale della directory corrente.

Una directory, anche se è vuota, conterrà necessariamente almeno **due riferimenti**:

* `.`: riferimento a se stessa.
* `..`: riferimento alla directory principale della directory corrente.

Un percorso relativo può quindi iniziare con `./` o `../`. Quando il percorso relativo si riferisce a una sottodirectory o ad un file nella directory corrente, il `./` è spesso omesso. L'inserimento del riferimento `./` sarà veramente richiesto solo per l'esecuzione di un file eseguibile.

Gli errori nei percorsi possono causare molti problemi: dalla creazione di cartelle o file nei luoghi sbagliati, alle eliminazioni involontarie, ecc. È quindi fortemente raccomandato di utilizzare il completamento automatico quando si immettono i percorsi.

![our example tree](images/commands-pathabsolute.png)

Nell'esempio sopra, stiamo cercando la posizione del file `myfile` nella directory di bob.

* in un **percorso assoluto**, la directory corrente non ha importanza. Iniziamo dalla radice e scendiamo fino alle directory `home`, `groupA`, `alice` e infine il file `myfile`: `/home/groupA/alice/myfile`.
* in un **percorso relativo**, il nostro punto di partenza è la directory corrente `bob`, saliamo di un livello con `..` (i.e., nella directpry `groupA`), poi giù nella directory di alice, e infine il file `myfile`: `../alice/myfile`.

### comando `pwd`

Il comando `pwd` (Print Working Directory) visualizza il percorso assoluto della directory corrente.

```bash
$ pwd
/home/rockstar
```

Per muoversi usando un percorso relativo, devi conoscere la sua posizione nell'albero.

A seconda dell'interprete di comando, il prompt dei comandi può anche visualizzare il nome della directory corrente.

### comando `cd`

Il comando `cd` (Change Directory) consente di modificare la directory corrente, in altre parole, serve per spostarsi attraverso l'albero.

```bash
$ cd /tmp
$ pwd
/tmp
$ cd ../
$ pwd
/
$ cd
$ pwd
/home/rockstar
```

Come puoi vedere nell'ultimo esempio sopra, il comando `cd` senza argomenti sposta la directory corrente alla `home directory`.

### comando `ls`

Il comando `ls` visualizza il contenuto di una directory

```bash
ls [-a] [-i] [-l] [directory1] [directory2] […]
```

Esempio:

```bash
$ ls /home
.    ..    rockstar
```

Le opzioni principali del comando `ls` sono:

| Opzione | Informazione                                                                                                            |
| ------- | ----------------------------------------------------------------------------------------------------------------------- |
| `-a`    | Visualizza tutti i file, anche quelli nascosti. I file nascosti in Linux sono quelli che iniziano con`.`.               |
| `-i`    | Visualizza i numeri di inode.                                                                                           |
| `-l`    | Il comando con l'opzione`-l` visualizza un elenco verticale dei file con informazioni aggiuntive formattate in colonne. |

Il comando `ls`, tuttavia, ha molte opzioni (vedi `man`):

| Opzione | Informazione                                                                                                                                          |
| ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-d`    | Visualizza le informazioni di una directory invece di elencare i suoi contenuti.                                                                      |
| `-g`    | Visualizza UID e GID al posto dei nomi dei proprietari.                                                                                               |
| `-h`    | Visualizza le dimensioni dei file nel formato più appropriato (byte, kilobyte, megabyte, gigabyte, ...). `h` stà per Human Readable.                  |
| `-s`    | Visualizza la dimensione in byte (tranne l'opzione`k`).                                                                                               |
| `-A`    | Visualizza tutti i file nella directory tranne`.` e `..`.                                                                                             |
| `-R`    | Visualizza il contenuto delle sottodirectory in modo ricorsivo.                                                                                       |
| `-F`    | Visualizza il tipo di file. Stampa un`/` per una directory, `*` per gli eseguibili, `@` per un collegamento simbolico, e niente per un file di testo. |
| `-X`    | ordina i file in base alle loro estensioni.                                                                                                           |

* Descrizione delle colonne:

```bash
$ ls -lia /home
78489 drwx------ 4 rockstar rockstar 4096 25 oct. 08:10 rockstar
```

| Valore          | Informazione                                                                                                    |
| --------------- | --------------------------------------------------------------------------------------------------------------- |
| `78489`         | Numero di inode.                                                                                                |
| `drwx------`    | Tipo di file (`d`) e permessi (`rwx------`).                                                                    |
| `4`             | Numero di sottodirectory. (`.` e `..` incluse). Per un file di tipo link fisico: numero di collegamenti fisici. |
| `rockstar`      | Per un file di collegamento fisico: numero di collegamenti fisici.                                              |
| `rockstar`      | Per un file di tipo link fisico: numero di collegamenti fisici.                                                 |
| `4096`          | Per un file di tipo di collegamento fisico: numero di collegamenti fisici.                                      |
| `25 oct. 08:10` | Ultima data di modifica.                                                                                        |
| `rockstar`      | Il nome del file (o directory).                                                                                 |

!!! Note Nota Gli **Alias** sono spesso già inseriti nelle distribuzioni comuni.

    Questo è il caso dell'alias `ll`:

    ```
    alias ll='ls -l --color=auto'
    ```

Il comando `ls` ha molte opzioni ed ecco alcuni esempi avanzati di uso:

* Elenca i file in `/etc` in base all'ultima modifica:

```bash
$ ls -ltr /etc
total 1332
-rw-r--r--.  1 root root    662 29 may   2021 logrotate.conf
-rw-r--r--.  1 root root    272 17 may.   2021 mailcap
-rw-------.  1 root root    122 12 may.  2021 securetty
...
-rw-r--r--.  2 root root     85 18 may.  17:04 resolv.conf
-rw-r--r--.  1 root root     44 18 may.  17:04 adjtime
-rw-r--r--.  1 root root    283 18 may.  17:05 mtab
```

* Elenca i file in `/var` più grandi di 1 megabyte ma minori di 1 Gigabyte:

```bash
$ ls -Rlh /var | grep [0-9]M
...
-rw-r--r--. 1 apache apache 1,2M 10 may.  13:02 XB RiyazBdIt.ttf
-rw-r--r--. 1 apache apache 1,2M 10 may.  13:02 XB RiyazBd.ttf
-rw-r--r--. 1 apache apache 1,1M 10 may.  13:02 XB RiyazIt.ttf
...
```

* Mostra i permessi di una cartella:

Per scoprire i permessi di una cartella, nel nostro esempio `/etc`, il seguente comando non sarebbe appropriato:

```bash
$ ls -l /etc
total 1332
-rw-r--r--.  1 root root     44 18 nov.  17:04 adjtime
-rw-r--r--.  1 root root   1512 12 janv.  2010 aliases
-rw-r--r--.  1 root root  12288 17 nov.  17:41 aliases.db
drwxr-xr-x.  2 root root   4096 17 nov.  17:48 alternatives
...
```

dal momento che elenca il contenuto della cartella e non la cartella stessa.

Per fare ciò, useremo l'opzione `d`:

```bash
$ ls -ld /etc
drwxr-xr-x. 69 root root 4096 18 nov.  17:05 /etc
```

* Elenca i file per dimensione:

```bash
$ ls -lhS
```

* Visualizza la data di modifica nel formato "timestamp":

```bash
$ ls -l --time-style="+%Y-%m-%d %m-%d %H:%M" /
total 12378
dr-xr-xr-x. 2 root root 4096 2014-11-23 11-23 03:13 bin
dr-xr-xr-x. 5 root root 1024 2014-11-23 11-23 05:29 boot
```

* Aggiungi la _trailing slash_ alla fine della cartella:

Per impostazione predefinita, il comando `ls` non visualizza l'ultima barra di una cartella. In alcuni casi, come per gli script, ad esempio, è utile visualizzarla:

```bash
$ ls -dF /etc
/etc/
```

* Nascondi alcune estensioni:

```bash
$ ls /etc --hide=*.conf
```

### comando `mkdir`

Il comando `mkdir` crea una directory o un albero di directory.

```bash
mkdir [-p] directory [directory] [...]
```

Esempio:

```bash
$ mkdir /home/rockstar/work
```

La directory "rockstar" deve esistere per creare la directory "work".

Altrimenti, dovrebbe essere utilizzata l'opzione `-p`. L'opzione `-p` crea le directory genitore se queste non esistono.

!!! Danger Pericolo Non è consigliato utilizzare i nomi dei comandi Linux come directory o nomi di file.

### comando `touch`

Il comando `touch` cambia il timestamp di un file o crea un file vuoto se il file non esiste.

```bash
touch [-t date] file
```

Esempio:

```bash
$ touch /home/rockstar/myfile
```

| Opzione   | Informazione                                                            |
| --------- | ----------------------------------------------------------------------- |
| `-t date` | Modifica la data dell'ultima modifica del file con la data specificata. |

Formato data: `[AAAA]MMJJhhmm[ss]`

!!! Tip Suggerimento Il comando `touch` viene utilizzato principalmente per creare un file vuoto, ma può essere utile per i backup incrementali o differenziali per esempio. Davvero, l'unico effetto di eseguire un `touch` su un file sarà quello di costringerlo a essere salvato durante il backup successivo.

### comando `rmdir`

Il comando `rmdir` elimina una directory vuota.

Esempio:

```bash
$ rmdir /home/rockstar/work
```

| Opzione | Informazione                                                          |
| ------- | --------------------------------------------------------------------- |
| `-p`    | Rimuove la directory o le directory principale fornite se sono vuote. |

!!! Tip Suggerimento Per eliminare sia una directory non vuota che il suo contenuto, utilizzare il comando `rm`.

### comando`rm`

Il comando `rm` elimina un file o una directory.

```bash
rm [-f] [-r] file [file] [...]
```

!!! Danger Pericolo Qualsiasi cancellazione di un file o directory è definitiva.

| Opzioni | Informazione                               |
| ------- | ------------------------------------------ |
| `-f`    | Non chiedere conferma della cancellazione. |
| `-i`    | Richiede conferma di cancellazione.        |
| `-r`    | Elimina ricorsivamente le sottodirectory.. |

!!! Note Nota Il comando `rm` non chiede la conferma durante l'eliminazione dei file. Tuttavia, con una distribuzione RedHat/Rocky, `rm` chiede la conferma della cancellazione in quanto il comando `rm` è un`alias` di `rm -i`. Non sorprenderti se su un'altra distribuzione, come Debian, ad esempio, non ottieni una richiesta di conferma.

L'eliminazione di una cartella con il comando `rm`, che la cartella sia vuota o meno, richiederà l'aggiunta dell'opzione `-r`.

La fine delle opzioni è segnalata alla shell da un doppio trattino `--`.

Nell'esempio:

```bash
$ >-hard-hard # Per creare un file vuoto chiamato -hard-hard
hard-hard
[CTRL+C] Per interrompere la creazione del file
$ rm -f -- -hard-hard
```

Il nome del file hard-hard inizia con un `-`. Senza l'uso del `--` la shell avrebbe interpretato il `-d` in `-hard-hard` come un'opzione.

### command `mv`

Il comando `mv` muove e rinomina un file.

```bash
mv file [file ...] destination
```

Esempi:

```bash
$ mv /home/rockstar/file1 /home/rockstar/file2
$ mv /home/rockstar/file1 /home/rockstar/file2 /tmp
```

| Opzioni | Informazione                                                                  |
| ------- | ----------------------------------------------------------------------------- |
| `-f`    | Non chiedere conferma per la sovrascrittura del file di destinazione.         |
| `-i`    | Richiedere conferma per la sovrascrittura del file di destinazione (default). |

Alcuni casi concreti ti aiuteranno a capire le difficoltà che possono sorgere:

```bash
$ mv /home/rockstar/file1 /home/rockstar/file2
```

Rinominare `file1` in `file2`, se `file2` esiste già, sarà sostituito da `file1`.

```bash
$ mv /home/rockstar/file1 /home/rockstar/file2 /tmp
```

Muovere `file1` e `file2` nella directory `/tmp`.

```bash
$ mv file1 /repexist/file2
```

Muovere `file1` in `repexist` e rinominarlo `file2`.

```bash
$ mv file1 file2
```

`file1` è rinominato con `file2`.

```bash
$ mv file1 /repexist
```

Se esiste la directory di destinazione, `file1` viene spostato in `/repexist`.

```bash
$ mv file1 /wrongrep
```

Se la directory di destinazione non esiste, `file1` viene rinominato in `wrongrep` nella directory principale.

### comando `cp`

Il comando `cp` copia un file.

```bash
cp file [file ...] destination
```

Esempio:

```bash
$ cp -r /home/rockstar /tmp
```

| Opzioni | Informazione                                                                 |
| ------- | ---------------------------------------------------------------------------- |
| `-i`    | Richiesta di conferma per la sovrascrittura (default).                       |
| `-f`    | Non chiedere conferma per la sovrascrittura del file di destinazione.        |
| `-p`    | Mantiene il proprietario, le autorizzazioni e il timestamp del file copiato. |
| `-r`    | Copia una directory con i suoi file e sottodirectory.                        |
| `-s`    | Crea un collegamento simbolico invece di copiare                             |

```bash
cp file1 /repexist/file2
```

`file1` viene copiato in `/repexist` con il nome `file2`.

```bash
$ cp file1 file2
```

`file1` è copiato come `file2` in questa directory.

```bash
$ cp file1 /repexist
```

Se esiste la directory di destinazione, `file1` viene copiato in `/repexist`.

```bash
$ cp file1 /wrongrep
```

Se la directory di destinazione non esiste, `file1` è copiato sotto il nome `wrongrep` nella directory principale.

## Visualizzazione

### comando `file`

Il comando `file` visualizza il tipo di un file.

```bash
file file1 [files]
```

Esempio:

```bash
$ file /etc/passwd /etc
/etc/passwd:    ASCII text
/etc:        directory
```

### comando `more`

Il comando `more` visualizza il contenuto di uno o più files tramite schermo.

```bash
more file1 [files]
```

Esempio:

```bash
$ more /etc/passwd
root:x:0:0:root:/root:/bin/bash
...
```

Usando il tasto <kbd>ENTER</kbd>, lo spostamento è linea per linea. Usando il tasto <kbd>SPACE</kbd>, lo spostamento è pagina per pagina. `/text` Ti consente di cercare la corrispondenza nel file.

### comando `less`

Il comando `Less` visualizza il contenuto di uno o più file. Il comando `less` è interattivo e ha i propri comandi per l'uso.

```bash
less file1 [files]
```

I comandi specifici per `less` sono:

| Command           | Action                                              |
| ----------------- | --------------------------------------------------- |
| `h`               | Aiuto.                                              |
| `Arrows`          | Sposta su, giù di una linea, o a destra e sinistra. |
| `Enter`           | Sposta giù di una riga.                             |
| `Space`           | Sposta giù di una pagina.                           |
| `PgUp` and `PgDn` | Sposta su o giù di una pagina.                      |
| `Begin` and `End` | Passa all'inizio o alla fine di un file.            |
| `/text`           | Cerca il testo.                                     |
| `q`               | Chiude il comando`less`.                            |

### comando `cat`

Il comando `cat` concatena il contenuto di più file e visualizza il risultato sull'output standard.

```bash
cat file1 [files]
```

Esempio 1 - Visualizzazione del contenuto di un file in output standard:

```bash
$ cat /etc/passwd
```

Esempio 2 - Visualizzazione del contenuto di più file in output standard:

```bash
$ cat /etc/passwd /etc/group
```

Esempio 3 - Visualizzazione del contenuto di diversi file nel file `usersAndGroups.txt`:

```bash
$ cat /etc/passwd /etc/group > usersAndGroups.txt
```

Esempio 4 - Visualizzazione della numerazione di linea:

```bash
$ cat -n /etc/profile
     1    # /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
     2    # and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).
     3
     4    if [ "`id -u`" -eq 0 ]; then
     5      PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
     6    else
…
```

Esempio 5 - Mostra la numerazione di linee non vuote:

```bash
$ cat -b /etc/profile
     1    # /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
     2    # and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

     3    if [ "`id -u`" -eq 0 ]; then
     4      PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
     5    else
…
```

### comando `tac`

Il comando `tac` fa quasi il contrario del comando `cat`. Visualizza il contenuto di un file a partire dalla fine (che è particolarmente interessante per la lettura dei log!).

Esempio: Visualizza un file di log visualizzando prima l'ultima riga:

```bash
[root]# tac /var/log/messages | less
```

### comando `head`

Il comando `head` visualizza l'inizio di un file.

```bash
head [-n x] file
```

| Opzione | Osservazione                      |
| ------- | --------------------------------- |
| `-n x`  | Mostra le prime linee`x` del file |

Per impostazione predefinita (senza l'opzione `-n`), il comando `head` visualizzerà le prime 10 righe del file.

### comando `tail`

Il comando `tail` visualizza la fine di un file.

```bash
tail [-f] [-n x] file
```

| Opzione | Osservazione                                   |
| ------- | ---------------------------------------------- |
| `-n x`  | Visualizza le ultime linee del file`x`         |
| `-f`    | Visualizza le modifiche al file in tempo reale |

Esempio:

```bash
tail -n 3 /etc/passwd
sshd:x:74:74:Privilege-separeted sshd:/var/empty /sshd:/sbin/nologin
tcpdump::x:72:72::/:/sbin/nologin
user1:x:500:500:grp1:/home/user1:/bin/bash
```

Con l'opzione `-f`, il comando `tail` non visualizza solo il file sullo standard output ma funziona finché l'utente non lo interrompe con la sequenza <kbd>CTRL</kbd> + <kbd>C</kbd>. Questa opzione è utilizzata molto frequentemente per tracciare i file di registro (i log) in tempo reale.

Senza l'opzione `-n`, il comando tail visualizza le ultime 10 righe del file.

### comando `sort`

Il comando `sort` ordina le linee di un file.

Ti consente di ordinare il risultato di un comando o del contenuto di un file in un determinato ordine, numericamente, alfabeticamente, per dimensione (KB, MB, GB) o in ordine inverso.

```bash
sort [-kx] [-n] [-o file] [-ty] file
```

Esempio:

```bash
$ sort -k3 -t: -n /etc/passwd
root:x:0:0:root:/root:/bin/bash
adm:x:3:4:adm:/var/adm/:/sbin/nologin
```

| Opzione   | Observation                                         |
| --------- | --------------------------------------------------- |
| `-kx`     | Specifica la colonna`x` per ordinare                |
| `-n`      | Richiede un ordinamento numerico                    |
| `-o file` | Salva l'ordinamento nel file specificato            |
| `-ty`     | Specifica il carattere del separatore del campo `y` |
| `-r`      | Inverte l'ordine del risultato                      |
| `- u`     | unico                                               |

Il comando `sort` ordina il file solo sullo schermo. Il file non è modificato dall'ordinamento. Per salvare l'ordinamento, usa l'opzione `-o` o un reindirizzamento dell'output `>`.

Per impostazione predefinita, i numeri sono ordinati in base al loro carattere. Quindi, "110" sarà prima del "20", che sarà a sua volta prima "3". L'opzione `-n` deve essere specificata in modo che i blocchi di caratteri numerici siano ordinati per il loro valore.

Il comanda `sort` inverte l'ordine del risultato, con l'opzione `-r`:

```bash
$ sort -k3 -t: -n -r /etc/passwd
root:x:0:0:root:/root:/bin/bash
adm:x:3:4:adm:/var/adm/:/sbin/nologin
```

In questo esempio, il comando `sort` ordinerà il contenuto del file `/etc /passwd` questa volta dal Uid più grande al più piccolo.

Alcuni esempi avanzati di utilizzazione del comando `sort`:

* Mischiando valori

Il comando `sort` ti consente anche di mescolare valori con l'opzione `-R`:

```bash
$ sort -R /etc/passwd
```

* Ordinamento degli indirizzi IP

Un amministratore di sistema si deve spesso confrontare con l'elaborazione di indirizzi IP provenienti dai registri dei suoi servizi come SMTP, VSFTP o Apache. Questi indirizzi sono tipicamente estratti con il comando `cut`.

Ecco un esempio con il file `dns-client.txt`:

```
192.168.1.10
192.168.1.200
5.1.150.146
208.128.150.98
208.128.150.99
```

```bash
$ sort -nr dns-client.txt
208.128.150.99
208.128.150.98
192.168.1.200
192.168.1.10
5.1.150.146
```

* Ordinamento file rimuovendo i duplicati

Il comando `sort` sa come rimuovere i duplicati dall'output del file usando `-u` come opzione.

Ecco un esempio con il file `colours.txt`:

```
Red
Green
Blue
Red
Pink
```
```
$ sort -u colours.txt
Blue
Green
Pink
Red
```

* Ordinamento file per dimensioni

Il comando `sort` sa riconoscere le dimensioni dei file, da comandi come `ls` con l'opzione `-h`.

Ecco un esempio con il file `size.txt`:

```
1,7G
18M
69K
2,4M
1,2M
4,2G
6M
124M
12,4M
4G
```

```bash
$ sort -hr size.txt
4,2G
4G
1,7G
124M
18M
12,4M
6M
2,4M
1,2M
69K
```

### comando `wc`

Il comando `wc` conta il numero di linee, parole e/o byte in un file.

```bash
wc [-l] [-m] [-w] file [files]
```

| Option | Osservazione                  |
| ------ | ----------------------------- |
| `-c`   | Conta il numero di byte.      |
| `-m`   | Conta il numero di caratteri. |
| `-l`   | Conta il numero di linee.     |
| `-w`   | Conta il numero di parole.    |

## Ricerca

### comando `find`

Il comando `find` ricerca per file o posizione della directory.

```bash
find directory [-name name] [-type type] [-user login] [-date date]
```

Dal momento che ci sono così tante opzioni nel comando `find`, è meglio fare riferimento a `man`.

Se la directory di ricerca non è specificata, il comando `find` cercherà dalla directory corrente.

| Opzione             | Osservazione                    |
| ------------------- | ------------------------------- |
| `-perm permissions` | Cerca i file dai loro permessi. |
| `-size size`        | Cerca i file per dimensione.    |

### opzione `-exec` del comando `find`

È possibile usare l'opzione `-exec` del comando `find` per eseguire un comando con il risultato ottenuto dalla ricerca:

```bash
$ find /tmp -name *.txt -exec rm -f {} \;
```

Il comando precedente cerca tutti i file nella directory `/tmp` con il suffisso `*.txt` e li elimina.

!!! Tip "Comprendere l'opzione `-exec`" Nell'esempio sopra, il comando `find` costruirà una stringa che rappresenta il comando da eseguire.

    Se il comando `find` trova tre file denominati `log1.txt`, `log2.txt`, e `log3.txt`, il comando `find` costruirà la stringa sostituendo nella stringa `rm -f {} \;` le parentesi graffe con uno dei risultati della ricerca, e farà questo tutte le volte che ci sono dei risultati.
    
    Questo ci darà:

    ```
    rm -f /tmp/log1.txt ; rm -f /tmp/log2.txt ; rm -f /tmp/log3.txt ;
    ```


    Il carattere `;` è un carattere speciale di shell che deve essere protetto da `\` per evitare che venga interpretato troppo presto dal comando `find` (e non nel `-exec`).

!!! Tip Suggerimento `$ find /tmp -name *.txt -delete` fa la stessa cosa.

### comando `whereis`

Il comando `whereis` ricerca i file relativi a un comando.

```bash
whereis [-b] [-m] [-s] command
```

Esempio:

```bash
$ whereis -b ls
ls: /bin/ls
```

| Opzione | Osservazione                    |
| ------- | ------------------------------- |
| `-b`    | Cerca solo il file binario.     |
| `-m`    | Ricerca solo per le pagine man. |
| `-s`    | Ricerca solo per file sorgente. |

### command `grep`

Il comando `grep` ricerca una stringa in un file.

```bash
grep [-w] [-i] [-v] "string" file
```

Esempio:

```bash
$ grep -w "root:" /etc/passwd
root:x:0:0:root:/root:/bin/bash
```

| Opzione | Osservazione                                         |
| ------- | ---------------------------------------------------- |
| `-i`    | Ignora il maiuscolo/minuscolo della stringa cercata. |
| `-v`    | Esclude le linee contenenti la stringa.              |
| `-w`    | Cerca la parola esatta.                              |

Il comando `grep` restituisce la linea completa contenente la stringa che stai cercando.
* Il carattere speciale `^` è usato per cercare una stringa all'inizio di una linea.
* Il carattere speciale `$` cerca una stringa alla fine di una linea.

```bash
$ grep -w "^root" /etc/passwd
```

!!! Note Nota Questo comando è molto potente ed è altamente raccomandata la consultazione del manuale. Ha molti utilizzi derivati.

È possibile cercare una stringa in un albero di file con l'opzione `-R`.

```bash
grep -R "Virtual" /etc/httpd
```

### Meta-caratteri (wildcards)

I Meta-caratteri sostituiscono uno o più caratteri (o anche un'assenza di caratteri) durante una ricerca. Questi meta-caratteri sono anche noti come wildcards. Possono essere combinati. Il carattere `*` sostituisce una stringa composta da qualsiasi carattere. Il carattere `*` può anche rappresentare un'assenza di caratteri.

```bash
$ find /home -name "test*"
/home/rockstar/test
/home/rockstar/test1
/home/rockstar/test11
/home/rockstar/tests
/home/rockstar/test362
```

I Meta-caratteri consentono ricerche più complesse sostituendo tutto o parte di una parola. Sostituiscono semplicemente le incognite con questi caratteri speciali.

Il carattere `?` sostituisce un singolo carattere, qualunque esso sia.

```bash
$ find /home -name "test?"
/home/rockstar/test1
/home/rockstar/tests
```

Le parentesi quadre `[` sono usate per specificare i valori che un singolo carattere può prendere.

```bash
$ find /home -name "test[123]*"
/home/rockstar/test1
/home/rockstar/test11
/home/rockstar/test362
```

!!! Note Nota Delimita sempre le parole contenenti meta-caratteri con `"` per evitare che vengano sostituiti dai nomi dei file che soddisfano i criteri.

!!! Warning Avvertimento Non confondere i meta-caratteri della shell con i meta-caratteri dell'espressione regolare. Il comando `grep` usa i meta-caratteri dell'espressione regolare.

## Reindirizzamenti e pipes

### Standard input e output

Sui sistemi UNIX e Linux, ci sono tre flussi standard. Consentono ai programmi, attraverso la libreria `stdio.h`, di inviare e ricevere informazioni.

Questi flussi sono chiamati canale X descrittore di file X.

Per impostazione predefinita:

* la tastiera è il dispositivo di input per il canale 0, chiamato **stdin** ;
* lo schermo è il dispositivo di uscita per i canali 1 e 2, chiamati **stdout** e **stderr**.

![standards channels](images/input-output.png)

**stderr** riceve i flussi di errore restituiti da un comando. Gli altri flussi sono diretti a **stdout**.

Questi flussi puntano ai file delle periferiche, ma poiché tutto è un file in UNIX/Linux, i flussi di I/O possono essere facilmente deviati ad altri file. Questo principio è la forza della shell.

### Redirezione Input

È possibile reindirizzare il flusso di input da un altro file con il carattere `<` o `<<`. Il comando leggerà il file anziché la tastiera:

```bash
$ ftp -in serverftp << ftp-commands.txt
```

!!! Note "Nota" Solo i comandi che richiedono l'input della tastiera saranno in grado di gestire il reindirizzamento dell'ingresso.

Il reindirizzamento dell'ingresso può anche essere utilizzato per simulare l'interattività dell'utente. Il comando leggerà il flusso di input finché non incontrerà la parola chiave definita dopo il reindirizzamento dell'ingresso.

Questa funzione è utilizzata per i comandi interattivi negli script:

```bash
$ ftp -in serverftp << END
user alice password
put file
bye
END
```

La parola chiave `END` può essere sostituita da qualsiasi parola.

```bash
$ ftp -in serverftp << STOP
user alice password
put file
bye
STOP
```

La shell esce dal comando `ftp` quando riceve una linea contenente solo la parola chiave.

!!! Warning Avvertimento La parola chiave finale, quì `END` o `STOP`, deve essere l'unica parola sulla linea e deve essere all'inizio della linea.

Il reindirizzamento dell'ingresso standard viene usato raramente perché la maggior parte dei comandi accetta un nome di file come argomento.

Il comando `wc` potrebbe essere usato in questo modo:

```bash
$ wc -l .bash_profile
27 .bash_profile # il numero di linee è seguito dal nome del file
$ wc -l < .bash_profile
27 # restituisce solo il numero di linee
```

### Redirezione Output

L'output standard può essere reindirizzato ad altri file usando il carattere `>` o `>>`.

Il semplice `>` reindirizzamento sovrascrive il contenuto del file di output:

```bash
$ date +%F > date_file
```

mentre il doppio reindirizzamento `>>` aggiunge (concatena) al contenuto del file di output.

```bash
$ date +%F >> date_file
```

In entrambi i casi, il file viene creato automaticamente quando non esiste.

L'output di errore standard può anche essere reindirizzato a un altro file. Questa volta sarà necessario specificare il numero del canale (che può essere omesso per i canali 0 e 1):

```bash
$ ls -R / 2> errors_file
$ ls -R / 2>> errors_file
```

### Esempi di reindirizzamento

Reindirizzamento di 2 uscite a 2 file:

```bash
$ ls -R / >> ok_file 2>> nok_file
```

Reindirizzamento delle 2 uscite a un singolo file:

```bash
$ ls -R / >> log_file 2>&1
```

Reindirizzamento del *stderr* a un "pozzo senza fondo" (`/dev/null`):

```bash
$ ls -R / 2>> /dev/null
```

Quando entrambi i flussi di uscita vengono reindirizzati, nessuna informazione viene visualizzata sullo schermo. Per utilizzare sia il reindirizzamento dell'uscita che per mantenere il display, dovrai usare il comando `tee`.

### Pipes

Una **pipe** è un meccanismo che consente di collegare l'output standard di un primo comando all'ingresso standard di un secondo comando.

Questa comunicazione è unidirezionale ed è fatta con il simbolo `|`. Il simbolo della pipe `|` è ottenuto premendo il tasto  <kbd>SHIFT</kbd> + <kbd>|</kbd> contemporaneamente.

![pipe](images/pipe.png)

Tutti i dati inviati dal controllo a sinistra della pipe tramite il canale di uscita standard vengono inviati al canale di ingresso standard del controllo a destra.

I comandi particolarmente utilizzati dopo una pipe sono i filtri.

* Esempi:

Mostra solo l'inizio:

```bash
$ ls -lia / | head
```

Mostra solo la fine:

```bash
$ ls -lia / | tail
```

Ordina il risultato:

```bash
$ ls -lia / | sort
```

Conta il numero di parole / caratteri:

```bash
$ ls -lia / | wc
```

Cerca una stringa nel risultato:

```bash
$ ls -lia / | grep fichier
```

## Punti speciali

### comando `tee`

Il comando `tee` viene utilizzato per reindirizzare l'output standard di un comando a un file mantenendo il display dello schermo.

Viene combinato con la pipe `|` per ricevere come input l'output del comando da reindirizzare:

```bash
$ ls -lia / | tee fic
$ cat fic
```

L'opzione `-a` aggiunge al file invece di sovrascriverla.

### comandi `alias` e `unalias`

Usare **alias** è un modo per chiedere alla shell di ricordare un determinato comando con le sue opzioni e dargli un nome.

Per esempio:

```bash
$ ll
```

sostituirà il comando:

```bash
$ ls -l
```

Il comando `alias` elenca gli alias per la sessione corrente. Gli alias sono stabiliti per impostazione predefinita sulle distribuzioni Linux. Qui, gli alias per un server Rocky Linux:

```bash
$ alias
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias vi='vim'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
```

Gli alias sono definiti temporaneamente solo per il tempo della sessione utente.

Per un uso permanente, devono essere creati nel:

* `.bashrc` file nella directory di accesso dell'utente;
* `/etc/profile.d/alias.sh` file per tutti gli utenti.

!!! Warning Avvertimento Prestare particolare attenzione quando si utilizzano alias che possono essere potenzialmente pericolosi! Ad esempio, un alias creato senza una conoscenza di base di amministratore:

    ```bash
    alias cd='rm -Rf'
    ```

Il comando `unalias` ti consente di eliminare gli alias.

Per eliminare un singolo alias:

```bash
$ unalias ll
```

Per eliminare tutti gli alias:

```bash
$ unalias -a
```

Per disabilitare temporaneamente un alias, la combinazione è `\<alias name>`.

Ad esempio se digitiamo:

```bash
$ type ls
```

potrebbe restituire quanto segue:

```bash
ls is an alias to « ls -rt »
```

Ora che questo è noto, possiamo vedere i risultati dell'utilizzo dell'alias o disabilitarlo in una volta con il carattere `\` eseguendo il seguente:

```bash
$ ls file*   # ordine per data
file3.txt  file2.txt  file1.txt
$ \ls file*  # ordine per nome
file1.txt  file2.txt  file3.txt
```

### Aliases e funzioni utili

* `grep` alias.

Colora il risultato del comando `grep`: `alias grep='grep --color=auto'`

* funzione `mcd`

È comune creare una cartella e poi muoversi dentro di essa: `mcd() { mkdir -p "$1"; cd "$1"; }`

* funzione `cls`

Muove in una cartella ed elenca i suoi contenuti: `cls() { cd "$1"; ls; }`

* funzione `backup`

Crea una copia di backup di un file: `backup() { cp "$1"{,.bak}; }`

* funzione `extract`

Estrai qualsiasi tipo di archivio:

```bash
extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2) tar xjf $1 ;;
      *.tar.gz) tar xzf $1 ;;
      *.bz2) bunzip2 $1 ;;
      *.rar) unrar e $1 ;;
      *.gz) gunzip $1 ;;
      *.tar) tar xf $1 ;;
      *.tbz2) tar xjf $1 ;;
      *.tgz) tar xzf $1 ;;
      *.zip) unzip $1 ;;
      *.Z) uncompress $1 ;;
      *.7z) 7z x $1 ;;
      *)
        echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

```

* Se `alias cmount` restituisce quanto segue: `alias cmount="mount | column -t"`

Quindi possiamo usare cmount per mostrare tutti i supporti di sistema in colonne come questa: `[root]# cmount`

che ritornerà il nostro filesystem montato nel seguente formato:

```bash
/dev/simfs  on  /                                          type  simfs        (rw,relatime,usrquota,grpquota)
proc        on  /proc                                      type  proc         (rw,relatime)
sysfs       on  /sys                                       type  sysfs        (rw,relatime)
none        on  /dev                                       type  devtmpfs     (rw,relatime,mode=755)
none        on  /dev/pts                                   type  devpts       (rw,relatime,mode=600,ptmxmode=000)
none        on  /dev/shm                                   type  tmpfs        (rw,relatime)
none        on  /proc/sys/fs/binfmt_misc                   type  binfmt_misc  (rw,relatime)
```

### Il carattere `;`

Il carattere `;` concatena i comandi.

I comandi saranno tutti eseguiti sequenzialmente nell'ordine di input una volta che l'utente preme <kbd>INVIO</kdb>.</p> 

<pre><code class="bash">$ ls /; cd /home; ls -lia; cd /
</code></pre>

<h2 spaces-before="0">
  Controlla la tua conoscenza
</h2>

<p spaces-before="0">
  :heavy_check_mark: Cosa definisce un utente sotto Linux? (7 risposte)
</p>

<p spaces-before="0">
  :heavy_check_mark: Cosa caratterizza un'opzione lunga per un ordine?
</p>

<p spaces-before="0">
  :heavy_check_mark: Quali comandi consentono di cercare aiuto su un comando:
</p>

<ul>
  <li>
    [ ] <code>google</code>
  </li>
  <li>
    [ ] <code>chuck --norris</code>
  </li>
  <li>
    [ ] <code>info</code>
  </li>
  <li>
    [ ] <code>apropos</code>
  </li>
  <li>
    [ ] <code>whatis</code>
  </li>
</ul>

<p spaces-before="0">
  :heavy_check_mark: Quale comando consente di visualizzare la cronologia di un utente?
</p>

<p spaces-before="0">
  :heavy_check_mark: Quale comando consente di cercare il testo in un file?
</p>

<ul>
  <li>
    [ ] <code>find</code>
  </li>
  <li>
    [ ] <code>grep</code>
  </li>
</ul>

<p spaces-before="0">
  :heavy_check_mark: Quale comando consente di cercare un file?
</p>

<ul>
  <li>
    [ ] <code>find</code>
  </li>
  <li>
    [ ] <code>grep</code>
  </li>
</ul>

<p spaces-before="0">
  :heavy_check_mark: Quale comando reindirizza il flusso di errore di un comando a un nuovo file <code>errors.log</code>:
</p>

<ul>
  <li>
    [ ] <code>ls -R / 2&gt; errors.log</code>
  </li>
  <li>
    [ ] <code>ls -R / 2&gt;&gt; errors.log</code>
  </li>
  <li>
    [ ] <code>ls -R / 2&gt; errors.log 2&gt;&1</code>
  </li>
</ul>   
