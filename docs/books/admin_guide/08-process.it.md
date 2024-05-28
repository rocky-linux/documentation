---
title: Gestione dei processi
---

# Gestione dei processi

In questo capitolo si apprenderà come lavorare con i processi.

****

**Obiettivi** : In questo capitolo, futuri amministratori Linux impareranno come:

:heavy_check_mark: Riconoscere il `PID` e il `PPID` di un processo;  
:heavy_check_mark: Visualizzare e cercare processi;  
:heavy_check_mark: Gestire i processi.

:checkered_flag: **processi**, **linux**

**Conoscenza**: :star: :star:  
**Complessità**: :star:

**Tempo di lettura**: 20 minuti

****

## Generalità

Un sistema operativo è costituito da processi. Questi processi vengono eseguiti in un ordine specifico e sono correlati. Ci sono due categorie di processi, quelli focalizzati sull'ambiente utente e quelli focalizzati sull'ambiente hardware.

Quando viene eseguito un programma, Il sistema creerà un processo posizionando i dati del programma e il codice in memoria e creando una **runtime stack**. Un processo è un'istanza di un programma con un ambiente di processore associato (contatore ordinale, registri, ecc.) e un ambiente di memoria.

Ogni processo ha:

* un *PID*: ***P**rocess **ID**entifier*, un identificatore di processo unico
* un *PPID*: ***P**arent **P**rocess **ID**entifier*, identificatore univoco del processo genitore

Da filiazioni successive, il processo `init` è il padre di tutti i processi.

* Un processo è sempre creato da un processo genitore
* Un processo genitore può avere più processi figlio

C'è una relazione genitore/figlio tra i processi. Un processo figlio è il risultato di un genitore che chiama la primitiva *fork()* e duplica il suo codice per creare un figlio. Il *PID* del processo figlio viene restituito al processo genitore in modo che possa comunicare. Ogni processo figlio ha l'identificatore del suo processo genitore, il *PPID*.

Il numero *PID* rappresenta il processo al momento dell'esecuzione. Al termine del processo, il numero è nuovamente disponibile per un altro processo. Eseguendo più volte lo stesso comando si otterrà ogni volta un *PID* diverso.<!-- TODO !\[Parent/child relationship between processes\](images/FON-050-001.png) -->!!! Note "Nota"

    I processi non devono essere confusi con i _threads_. Ogni processo ha il suo contesto di memoria (risorse e spazio degli indirizzi), mentre i _thread_ dello stesso processo condividono questo contesto.

## Visualizzazione dei processi

Il comando `ps` visualizza lo stato dei processi in esecuzione.

```bash
ps [-e] [-f] [-u login]
```

Esempio:

```bash
# ps -fu root
```

| Opzione    | Descrizione                        |
| ---------- | ---------------------------------- |
| `-e`       | Visualizza tutti i processi.       |
| `-f`       | Visualizza ulteriori informazioni. |
| `-u` login | Visualizza i processi dell'utente. |

Alcune opzioni aggiuntive:

| Opzione               | Descrizione                                             |
| --------------------- | ------------------------------------------------------- |
| `-g`                  | Visualizza i processi nel gruppo.                       |
| `-t tty`              | Visualizza i processi in esecuzione dal terminale.      |
| `-p PID`              | Visualizza le informazioni del processo.                |
| `-H`                  | Visualizza le informazioni in una struttura ad albero.  |
| `-I`                  | Visualizza ulteriori informazioni.                      |
| `--sort COL`          | Ordina il risultato secondo una colonna.                |
| `--headers`           | Visualizza l'intestazione di ogni pagina del terminale. |
| `--format "%a %b %c"` | Personalizza il formato di visualizzazione dell'uscita. |

Senza un'opzione specificata, il comando `ps` visualizza solo i processi in esecuzione sul terminale corrente.

Il risultato viene visualizzato nelle seguenti colonne:

```bash
# ps -ef
UID  PID PPID C STIME  TTY TIME      CMD
root 1   0    0 Jan01  ?   00:00/03  /sbin/init
```

| Colonna | Descrizione                           |
| ------- | ------------------------------------- |
| `UID`   | Utente proprietario.                  |
| `PID`   | Identificatore di processo.           |
| `PPID`  | Identificatore del processo genitore. |
| `C`     | Priorità del processo.                |
| `STIME` | Data e ora di esecuzione.             |
| `TTY`   | Terminale di esecuzione.              |
| `TIME`  | Durata di elaborazione.               |
| `CMD`   | Comando eseguito.                     |

Il comportamento del controllo può essere completamente personalizzato:

```bash
# ps -e --format "%P %p %c %n" --sort ppid --headers
 PPID   PID COMMAND          NI
    0     1 systemd           0
    0     2 kthreadd          0
    1   516 systemd-journal   0
    1   538 systemd-udevd     0
    1   598 lvmetad           0
    1   643 auditd           -4
    1   668 rtkit-daemon      1
    1   670 sssd              0
```

## Tipi di processi

Il processo dell'utente:

* è iniziato da un terminale associato a un utente
* accede alle risorse tramite richieste o daemons

Il processo di sistema (*daemon*):

* è iniziato dal sistema
* non è associato a nessun terminale, ed è di proprietà di un utente di sistema (spesso `root`);
* è caricato al momento dell'avvio, risiede in memoria, e sta aspettando una chiamata
* è solitamente identificato dalla lettera `d` associato al nome del processo

I processi di sistema sono quindi chiamati daemons (_**D**isk **A**nd **E**xecution **MON**itor_)

## Autorizzazioni e diritti

Le credenziali dell'utente vengono passate al processo creato quando viene eseguito un comando.

Per impostazione predefinita., l'attuale `UID` e `GID` (del processo) sono quindi identici al **effettivo** `UID` e `GID` (il `UID` e `GID` dell'utente che ha eseguito il comando).

Quando un `SUID` (e/o `SGID`) è impostato su un comando, l'attuale `UID` (e/o `GID`) diventa quello del proprietario (e/o gruppo proprietario) del comando e non più quello dell'utente o del gruppo di utenti che ha emesso il comando. Effettivo e reale **UIDs** sono quindi **differenti**.

Ogni volta che si accede a un file, il sistema controlla i diritti del processo in base ai suoi effettivi identificatori.

## Gestione dei processi

Un processo non può essere eseguito indefinitamente, perchè questo sarebbe a discapito di altri processi in esecuzione e impedirebbe il multitasking.

Pertanto, il tempo di elaborazione totale disponibile viene suddiviso in piccoli intervalli e ogni processo (con una priorità) accede al processore in modo sequenziale. Il processo prenderà diversi stati durante la sua vita tra gli stati:

* pronto: in attesa della disponibilità del processo
* in esecuzione: accede al processore
* sospeso: aspettando un I/O (input/output);
* fermato: aspettando un segnale da un altro processo
* zombie: richiesta di distruzione
* morto: il padre del processo chiude il suo processo figlio

La sequenza di chiusura del processo è la seguente:

1. Chiusura dei file aperti
2. Rilascio della memoria usata
3. Invio di un segnale ai processi genitore e figlio

Quando un genitore termina, i suoi figli diventano orfani. Vengono quindi adottati dal processo `init`, che provvederà a distruggerli.

### La priorità di un processo

Linux appartiene alla famiglia dei sistemi operativi a condivisione di tempo. I processori lavorano in time-sharing e ogni processo occupa una parte del tempo del processore. I processi vengono classificati per priorità:

* Processo in tempo reale: il processo con priorità **0-99** è programmato dall'algoritmo di schedulazione in tempo reale.
* Processi ordinari: i processi con priorità dinamiche da **100-139** sono programmati utilizzando un algoritmo di schedulazione completamente equo.
* Valore di nice: parametro utilizzato per regolare la priorità di un processo ordinario. L'intervallo è **-20-19**.

La priorità predefinita di un processo è **0**.

### Modalità di funzionamento

I processi possono essere eseguiti in due modi:

* **sincrona**: l'utente perde l'accesso alla shell durante l'esecuzione del comando. Il prompt dei comandi riappare alla fine dell'esecuzione del processo.
* **asincrona**: il processo viene elaborato in background. Il prompt dei comandi viene visualizzato di nuovo immediatamente.

I vincoli della modalità asincrona:

* il comando o lo script non devono attendere l'input della tastiera
* il comando o lo script non devono restituire alcun risultato sullo schermo
* lasciare che la shell termini il processo

## Controlli per la gestione dei processi

### comando `kill`

Il comando `kill` invia un segnale di arresto a un processo.

```bash
kill [-signal] PID
```

Esempio:

```bash
kill -9 1664
```

| Codice | Segnale   | Descrizione                               |
| ------ | --------- | ----------------------------------------- |
| `2`    | *SIGINT*  | Arresto immediato del processo            |
| `9`    | *SIGKILL* | Interruzione del processo (++control+d++) |
| `15`   | *SIGTERM* | Arresto pulito del processo               |
| `18`   | *SIGCONT* | Riprendere il processo                    |
| `19`   | *SIGSTOP* | Sospendere il processo                    |

I segnali sono i mezzi di comunicazione tra i processi. Il comando `kill` invia un segnale a un processo.

!!! Tip "Suggerimento"

    L'elenco completo dei segnali presi in considerazione dal comando `kill` è disponibile digitando il comando :

    ```
    $ man 7 signal
    ```

### comando `nohup`

`nohup` consente il lancio di un processo indipendentemente da una connessione.

```bash
comando nohup
```

Esempio:

```bash
nohup myprogram.sh 0</dev/null &
```

`nohup` ignora il segnale `SIGHUP` inviato quando un utente si disconnette.

!!! Note "Domanda"

    `nohup` gestisce l'output e l'error standard ma non l'input standard, da cui il reindirizzamento di questo input a `/dev/null`.

### [CTRL] + [Z]

Premendo la combinazione ++control+z++ contemporaneamente, il processo sincrono è temporaneamente sospeso. L'accesso al prompt viene ripristinato dopo aver visualizzato il numero del processo che è stato appena sospeso.

### istruzione `&`

La dichiarazione `&` esegue il comando in modo asincrono (il comando viene quindi chiamato *job*) e visualizza il numero di *job*. L'accesso al prompt viene quindi restituito.

Esempio:

```bash
$ time ls -lR / > list.ls 2> /dev/null &
[1] 15430
$
```

Il numero di *job* si ottiene durante l'elaborazione in background e viene visualizzato tra parentesi quadre, seguito dal numero `PID`.

### comandi `fg` e `bg`

Il comando `fg` mette il processo in primo piano:

```bash
$ time ls -lR / > list.ls 2>/dev/null &
$ fg 1
time ls -lR / > list.ls 2/dev/null
```

mentre il comando `bg` lo colloca in background:

```bash
[CTRL]+[Z]
^Z
[1]+ Stopped
$ bg 1
[1] 15430
$
```

Sia che sia stato messo in secondo piano quando è stato creato con l'argomento `&` o successivamente con i tasti ++control+z++, un processo può essere riportato in primo piano con il comando `fg` e il suo numero di job.

### comando `jobs`

Il comando `jobs` visualizza l'elenco dei processi in esecuzione in background e specifica il loro numero di lavoro.

Esempio:

```bash
$ jobs
[1]- Running    sleep 1000
[2]+ Running    find / > arbo.txt
```

Le colonne rappresentano:

1. numero di lavoro
2. l'ordine di esecuzione dei processi:

   * un `+` : Il processo selezionato per impostazione predefinita per i comandi `fg` e `bg` quando non viene specificato un numero di processo
   * a `-` : Questo processo è il processo successivo che prende il `+`

3. *Running* (processo in esecuzione) o *Stopped* (processo sospeso)
4. il comando

### comandi `nice` e `renice`

Il comando `nice` consente l'esecuzione di un comando specificando la sua priorità.

```bash
comando nice priority
```

Esempio:

```bash
nice -n+15 find / -name "file"
```

A differenza di `root`, un utente standard può solo ridurre la priorità di un processo. Saranno accettati solo valori tra +0 e +19.

!!! Tip "Suggerimento"

    Quest'ultima limitazione può essere eliminata per utente o per gruppo modificando il file `/etc/security/limits.conf`.

Il comando `renice` ti consente di modificare la priorità di un processo di esecuzione.

```bash
renice priority [-g GID] [-p PID] [-u UID]
```

Esempio:

```bash
renice +15 -p 1664
```

| Opzione | Descrizione                                 |
| ------- | ------------------------------------------- |
| `-g`    | `GID` del gruppo proprietario del processo. |
| `-p`    | `PID` del processo.                         |
| `-u`    | `UID` del proprietario del processo.        |

Il comando `renice` agisce sui processi già in esecuzione. È quindi possibile modificare la priorità di un processo specifico, ma anche di diversi processi appartenenti a un utente o un gruppo.

!!! Tip "Suggerimento"

    Il comando `pidof`, associato al comando `xargs` (vedi il corso Comandi avanzati), permette di applicare una nuova priorità in un singolo comando:

    ```
    $ pidof sleep | xargs renice 20
    ```

### comando `top`

Il comando `top` visualizza i processi e il loro consumo di risorse.

```bash
$ top
PID  USER PR NI ... %CPU %MEM  TIME+    COMMAND
2514 root 20 0       15    5.5 0:01.14   top
```

| Colonna   | Descrizione                       |
| --------- | --------------------------------- |
| `PID`     | Identificatore del processo.      |
| `USER`    | Utente proprietario.              |
| `PR`      | Priorità del processo.            |
| `NI`      | Valore di Nice.                   |
| `%CPU`    | Carico del processore.            |
| `%MEM`    | Carico di memoria.                |
| `TIME+`   | Tempo di utilizzo del processore. |
| `COMMAND` | Comando eseguito.                 |

Il comando `top` permette di controllare i processi in tempo reale e in modalità interattiva.

### comandi `pgrep` e `pkill`

Il comando `pgrep` cerca i processi in esecuzione per un nome di processo e visualizza il *PID* che soddisfa i criteri di selezione sull'output standard.

Il comando `pkill` invia a ogni processo il segnale specificato (per impostazione predefinita *SIGTERM*).

```bash
pgrep process
pkill [option] [-signal] process
```

Esempi:

* Ottenere il numero del processo da `sshd`:

  ```bash
  pgrep -u root sshd
  ```

* Terminare tutti i processi di `tomcat`:

  ```bash
  pkill tomcat
  ```

!!! note "Nota"

    Prima di terminare un processo, è meglio sapere esattamente a cosa serve; in caso contrario, si possono verificare crash del sistema o altri problemi imprevedibili.

Oltre a inviare segnali ai processi interessati, il comando `pkill` può anche terminare la sessione di connessione dell'utente in base al numero di terminale, come ad esempio:

```bash
pkill -t pts/1
```

### comando `killall`

La funzione di questo comando è più o meno la stessa del comando `pkill`. L'utilizzo è —`killall [option] [ -s SIGNAL | -SIGNAL ] NAME`. Il segnale predefinito è *SIGTERM*.

| Opzioni | Descrizione                                                                      |
|:------- |:-------------------------------------------------------------------------------- |
| `-l`    | elenca tutti i nomi dei segnali conosciuti                                       |
| `-i`    | chiede conferma prima di terminarlo                                              |
| `-I`    | corrispondenza del nome del processo senza distinzione tra maiuscole e minuscole |

Esempio:

```bash
killall tomcat
```

### comando `pstree`

Questo comando visualizza l'avanzamento in una struttura ad albero e il suo utilizzo è - `pstree [opzione]`.

| Opzione | Descrizione                                           |
|:------- |:----------------------------------------------------- |
| `-p`    | Visualizzare il PID del processo                      |
| `-n`    | ordinare l'output per PID                             |
| `-h`    | evidenziare il processo corrente e i suoi progenitori |
| `-u`    | mostrare le transizioni uid                           |

```bash
$ pstree -pnhu
systemd(1)─┬─systemd-journal(595)
           ├─systemd-udevd(625)
           ├─auditd(671)───{auditd}(672)
           ├─dbus-daemon(714,dbus)
           ├─NetworkManager(715)─┬─{NetworkManager}(756)
           │                     └─{NetworkManager}(757)
           ├─systemd-logind(721)
           ├─chronyd(737,chrony)
           ├─sshd(758)───sshd(1398)───sshd(1410)───bash(1411)───pstree(1500)
           ├─tuned(759)─┬─{tuned}(1376)
           │            ├─{tuned}(1381)
           │            ├─{tuned}(1382)
           │            └─{tuned}(1384)
           ├─agetty(763)
           ├─crond(768)
           ├─polkitd(1375,polkitd)─┬─{polkitd}(1387)
           │                       ├─{polkitd}(1388)
           │                       ├─{polkitd}(1389)
           │                       ├─{polkitd}(1390)
           │                       └─{polkitd}(1392)
           └─systemd(1401)───(sd-pam)(1404)
```

### Processi orfani e processi zombie

**processo orfano**: Quando un processo genitore termina, i suoi figli sono detti orfani. Il processo di init adotta questi processi in stato speciale e la raccolta dello stato viene completata finché non vengono distrutti. Dal punto di vista concettuale, il processo di orfanizzazione non comporta alcun danno.

**processo zombie**: Dopo che un processo figlio ha completato il suo lavoro e viene terminato, il suo processo genitore deve chiamare la funzione di elaborazione del segnale wait() o waitpid() per ottenere lo stato di cessazione del processo figlio. Se il processo padre non lo fa, anche se il processo figlio è già uscito, conserva alcune informazioni sullo stato di uscita nella tabella dei processi di sistema. Poiché il processo padre non può ottenere le informazioni sullo stato del processo figlio, questi processi continueranno a occupare risorse nella tabella dei processi. I processi in questo stato vengono chiamati zombie.

Pericolo:

* Occupano le risorse del sistema e causano una riduzione delle prestazioni della macchina.
* Impossibile generare nuovi processi figli.

Come si può verificare la presenza di processi zombie nel sistema attuale?

```bash
ps -lef | awk '{print $2}' | grep Z
```

Questi caratteri possono comparire in questa colonna:

* **D** - sospensione ininterrotta (di solito IO)
* **I** - Thread del kernel inattivo
* **R** - in esecuzione o eseguibile (in coda di esecuzione)
* **S** - sospensione interrompibile (attesa del completamento di un evento)
* **T** - fermato dal segnale di controllo del lavoro
* **t** - interrotto dal debugger durante il tracciamento
* **W** - paging (non più valido dal kernel 2.6.xx)
* **X** - morto (non si dovrebbe mai vedere)
* **Z** - processo defunto ("zombie"), terminato ma non recuperato dal suo genitore
