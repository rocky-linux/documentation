---
title: Gestione dei processi
---

# Gestione dei processi

In questo capitolo imparerai come lavorare con i processi.

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

Un sistema operativo è costituito da processi. Questi processi sono eseguiti in un ordine specifico e sono correlati tra loro. Ci sono due categorie di processi, quelli focalizzati sull'ambiente utente e quelli focalizzati sull'ambiente hardware.

Quando viene eseguito un programma, Il sistema creerà un processo posizionando i dati del programma e il codice in memoria e creando una **runtime stack**. Un processo è quindi un'istanza di un programma con un ambiente di processore associato (contatore ordinale, registri, etc...) e ambiente di memoria.

Ogni processo ha:

* un _PID_ : _**P**rocess **ID**entifier_, un identificatore di processo unico;
* un _PPID_ : _**P**arent **P**rocess **ID**entifier_, identificatore univoco del processo genitore.

Da filiazioni successive, il processo `init` è il padre di tutti i processi.

* Un processo è sempre creato da un processo genitore;
* Un processo genitore può avere più processi figlio.

C'è una relazione genitore/figlio tra i processi. Un processo figlio è il risultato del processo genitore che chiama il _fork ()_ iniziale e duplicando il proprio codice crea un processo figlio. Il _PID_ del processo figlio viene restituito al processo genitore in modo che possa comunicare. Ogni processo figlio ha l'identificatore del suo processo genitore, il _PPID_.

Il numero _PID_ rappresenta il processo al momento dell'esecuzione. Quando il processo finisce, il numero è di nuovo disponibile per un altro processo. Eseguendo lo stesso comando più volte produrrà un diverso _PID_ ogni volta.<!-- TODO !\[Parent/child relationship between processes\](images/FON-050-001.png) -->!!! Note "Nota" I processi non devono essere confusi con i _threads_. Ogni processo ha il proprio contesto di memoria (risorse e spazio di indirizzamento), mentre il _threads_ dello stesso processo condivide lo stesso contesto.

## Visualizzazione dei processi

Il comando `ps` visualizza lo stato dei processi in esecuzione.
```
ps [-e] [-f] [-u login]
```

Example:
```
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
| `--headers`           | Visualizza l'intestazione su ogni pagina del terminale. |
| `--format "%a %b %c"` | Personalizza il formato di visualizzazione dell'uscita. |

Senza un'opzione specificata, il comando `ps` visualizza solo i processi in esecuzione sul terminale corrente.

Il risultato viene visualizzato in colonne:

```
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

```
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

* è iniziato da un terminale associato a un utente;
* accede alle risorse tramite richieste o daemons.

Il processo di sistema (_daemon_):

* è iniziato dal sistema;
* non è associato a nessun terminale, ed è di proprietà di un utente di sistema (spesso `root`);
* è caricato al momento dell'avvio, risiede in memoria, e sta aspettando una chiamata;
* è solitamente identificato dalla lettera `d` associato al nome del processo.

I processi di sistema sono quindi chiamati daemons (_**D**isk **A**nd **E**xecution **MON**itor_).

## Autorizzazioni e diritti

Quando viene eseguito un comando, le credenziali dell'utente sono passate al processo creato.

Per impostazione predefinita., l'attuale `UID` e `GID` (del processo) sono quindi identici al **effettivo** `UID` e `GID` (il `UID` e `GID` dell'utente che ha eseguito il comando).

Quando un `SUID` (e/o `SGID`) è impostato su un comando, l'attuale `UID` (e/o `GID`) diventa quello del proprietario (e/o gruppo proprietario) del comando e non più quello dell'utente o del gruppo di utenti che ha emesso il comando. Effettivo e reale **UIDs** sono quindi **differenti**.

Ogni volta che si accede a un file, il sistema controlla i diritti del processo in base ai suoi effettivi identificatori.

## Gestione dei processi

Un processo non può essere eseguito indefinitamente, perchè questo sarebbe a discapito di altri processi in esecuzione e impedirebbe il multitasking.

Il tempo totale di elaborazione disponibile è quindi diviso in piccoli intervalli, e ogni processo (con una priorità) accede al processore in modo sequenziale. Il processo prenderà diversi stati durante la sua vita tra gli stati:

* pronto: in attesa della disponibilità del processo;
* in esecuzione: accede al processore;
* sospeso: aspettando un I/O (input/output);
* fermato: aspettando un segnale da un altro processo;
* zombie: richiesta di distruzione;
* morto: il padre del processo chiude il suo processo figlio.

La sequenza di chiusura del processo è la seguente:

1. Chiusura dei file aperti;
2. Rilascio della memoria usata;
3. Invio di un segnale ai processi genitore e figlio.

Quando un processo genitore muore, si dice che i suoi processi figli sono orfani. Sono quindi adottati dal processo `init` che li distruggerà.

### La priorità di un processo

Il processore funziona in condivisione del tempo (time sharing) con ogni processo occupando una determinata quantità di tempo del processore.

I processi sono classificati per priorità il cui valore varia da **-20** (la massima priorità) a **+19** (la priorità più bassa).

La priorità predefinita di un processo è **0**.

### Modalità di funzionamento

I processi possono essere eseguiti in due modi:

* **sincrona**: l'utente perde l'accesso alla shell durante l'esecuzione del comando. Il prompt dei comandi riappare alla fine dell'esecuzione del processo.
* **asincrona**: il processo viene elaborato in background. Il prompt dei comandi viene visualizzato di nuovo immediatamente.

I vincoli della modalità asincrona:

* il comando o lo script non devono attendere l'input della tastiera;
* il comando o lo script non devono restituire alcun risultato sullo schermo;
* lasciare che la shell termini il processo.

## Controlli per la gestione dei processi

### comando `kill`

Il comando `kill` invia un segnale di arresto a un processo.

```
kill [-signal] PID
```

Example:
```
$ kill -9 1664
```Interruzione del processo ( <kbd>CTRL</kdb> + <kdb>D</kdb> )</td> </tr> 

<tr>
  <td>
    <code>15</code>
  </td>
  
  <td>
    <em x-id="4">SIGTERM</em>
  </td>
  
  <td>
    Arresto pulito del processo
  </td>
</tr>

<tr>
  <td>
    <code>18</code>
  </td>
  
  <td>
    <em x-id="4">SIGCONT</em>
  </td>
  
  <td>
    Riprendere il processo
  </td>
</tr>

<tr>
  <td>
    <code>19</code>
  </td>
  
  <td>
    <em x-id="4">SIGSTOP</em>
  </td>
  
  <td>
    Sospendere il processo
  </td>
</tr></tbody> </table> 

<p spaces-before="0">
  I segnali sono i mezzi di comunicazione tra i processi. Il comando <code>kill</code> invia un segnale a un processo.
</p>

<p spaces-before="0">
  !!! Tip "Suggerimento"<br x-id="2" /> L'elenco completo dei segnali presi in considerazione dal comando <code>kill</code> è disponibile digitando il comando:
</p>

<pre><code>$ man 7 signal
</code></pre>



<h3 spaces-before="0">
  comando <code>nohup</code>
</h3>

<p spaces-before="0">
  <code>nohup</code> consente il lancio di un processo indipendentemente da una connessione.
</p>

<pre><code>nohup command
</code></pre>

<p spaces-before="0">
  Example:
</p>

<pre><code>$ nohup myprogram.sh 0&lt;/dev/null &
</code></pre>

<p spaces-before="0">
  <code>nohup</code> ignora il segnale <code>SIGHUP</code> inviato quando un utente si disconnette.
</p>

<p spaces-before="0">
  !!! Note "Domanda"<br x-id="2" /> <code>nohup</code> gestisce l'output e l'errore standard, ma non l'input standard, da qui il reindirizzamento di questo input a <code>/dev/null</code>.
</p>



<h3 spaces-before="0">
  [CTRL] + [Z]
</h3>

<p spaces-before="0">
  Premendo la combinazione <kbd>CTRL</kbd> + <kbd>Z</kbd> contemporaneamente, il processo sincrono è temporaneamente sospeso. L'accesso al prompt viene ripristinato dopo aver visualizzato il numero del processo che è stato appena sospeso.
</p>



<h3 spaces-before="0">
  istruzione <code>&</code>
</h3>

<p spaces-before="0">
  La dichiarazione <code>&</code> esegue il comando in modo asincrono (il comando viene quindi chiamato <em x-id="4">job</em>) e visualizza il numero di <em x-id="4">job</em>. L'accesso al prompt viene quindi restituito.
</p>

<p spaces-before="0">
  Example:
</p>

<pre><code>$ time ls -lR / &gt; list.ls 2&gt; /dev/null &
[1] 15430
$
</code></pre>

<p spaces-before="0">
  Il numero <em x-id="4">job</em> è ottenuto durante l'elaborazione in background e viene visualizzato in parentesi quadre, seguito dal numero di <code>PID</code>.
</p>



<h3 spaces-before="0">
  comandi <code>fg</code> e <code>bg</code>
</h3>

<p spaces-before="0">
  Il comando <code>fg</code> mette il processo in primo piano:
</p>

<pre><code>$ time ls -lR / &gt; list.ls 2&gt;/dev/null &
$ fg 1
time ls -lR / &gt; list.ls 2/dev/null
</code></pre>

<p spaces-before="0">
  mentre il comando <code>bg</code> lo colloca in background:
</p>

<pre><code>[CTRL]+[Z]
^Z
[1]+ Stopped
$ bg 1
[1] 15430
$
</code></pre>

<p spaces-before="0">
  Se è stato messo in background quando è stato creato con l'argomento <code>&</code> o più tardi con la combinazione <kbd>CTRL</kbd> +<kbd>Z</kbd>, un processo può essere riportato in primo piano con il comando <code>fg</code> e il suo numero di lavoro.
</p>



<h3 spaces-before="0">
  comando <code>jobs</code>
</h3>

<p spaces-before="0">
  Il comando <code>jobs</code> visualizza l'elenco dei processi in esecuzione in background e specifica il loro numero di lavoro.
</p>

<p spaces-before="0">
  Example:
</p>

<pre><code>$ jobs
[1]- Running    sleep 1000
[2]+ Running    find / &gt; arbo.txt
</code></pre>

<p spaces-before="0">
  Le colonne rappresentano:
</p>

<ol start="1">
  <li>
    numero di lavoro;
  </li>
  
  <li>
    l'ordine in cui i processi sono in esecuzione
  </li>
</ol>

<ul>
  <li>
    un <code>+</code> : questo processo è il prossimo processo da eseguire per impostazione predefinita con <code>fg</code> o <code>bg</code> ;
  </li>
  <li>
    un <code>-</code> : questo processo è il prossimo processo a prendere il <code>+</code> ;
  </li>
</ul>

<ol start="3">
  <li>
    <em x-id="4">Running</em> (processo in esecuzione) o <em x-id="4">Stopped</em> (processo sospeso).
  </li>
  
  <li>
    il comando
  </li>
</ol>



<h3 spaces-before="0">
  comandi <code>nice</code> e <code>renice</code>
</h3>

<p spaces-before="0">
  Il comando <code>nice</code> consente l'esecuzione di un comando specificando la sua priorità.
</p>

<pre><code>nice priority command
</code></pre>

<p spaces-before="0">
  Example:
</p>

<pre><code>$ nice -n+15 find / -name "file"
</code></pre>

<p spaces-before="0">
  a differenza di <code>root</code>, un utente standard può solo ridurre la priorità di un processo. Saranno accettati solo valori tra +0 e +19.
</p>

<p spaces-before="0">
  !!! Tip "Suggerimento"<br x-id="2" /> Quest'ultima limitazione può essere modificata su base utente o per gruppo modificando il file <code>/etc/security/limits.conf</code>.
</p>

<p spaces-before="0">
  Il comando <code>renice</code> ti consente di modificare la priorità di un processo di esecuzione.
</p>

<pre><code>renice priority [-g GID] [-p PID] [-u UID]
</code></pre>

<p spaces-before="0">
  Example:
</p>

<pre><code>$ renice +15 -p 1664
</code></pre>
<table spaces-before="0">
  <tr>
    <th>
      Opzione
    </th>
    
    <th>
      Descrizione
    </th>
  </tr>
  
  <tr>
    <td>
      <code>-g</code>
    </td>
    
    <td>
      <code>GID</code> del gruppo proprietario del processo.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>-p</code>
    </td>
    
    <td>
      <code>PID</code> del processo.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>-u</code>
    </td>
    
    <td>
      <code>UID</code> del proprietario del processo.
    </td>
  </tr>
</table>

<p spaces-before="0">
  Il comando <code>renice</code> agisce sui processi già in esecuzione. È quindi possibile modificare la priorità di un processo specifico, ma anche di diversi processi appartenenti a un utente o un gruppo.
</p>

<p spaces-before="0">
  !!! Tip "Suggerimento"<br x-id="2" /> Il comando <code>pidof</code>, accoppiato con il comando <code>xargs</code> (vedi il pagina dei comandi avanzati), consente di applicare una nuova priorità in un singolo comando:
</p>

<pre><code>$ pidof sleep | xargs renice 20
</code></pre>



<h3 spaces-before="0">
  comando <code>top</code>
</h3>

<p spaces-before="0">
  Il comando <code>top</code> visualizza i processi e il loro consumo di risorse.
</p>

<pre><code>$ top
PID  USER PR NI ... %CPU %MEM  TIME+    COMMAND
2514 root 20 0       15    5.5 0:01.14   top
</code></pre>

<table spaces-before="0">
  <tr>
    <th>
      Colonna
    </th>
    
    <th>
      Descrizione
    </th>
  </tr>
  
  <tr>
    <td>
      <code>PID</code>
    </td>
    
    <td>
      Identificatore del processo.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>USER</code>
    </td>
    
    <td>
      Utente proprietario.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>PR</code>
    </td>
    
    <td>
      Priorità del processo.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>NI</code>
    </td>
    
    <td>
      Valore di Nice.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>%CPU</code>
    </td>
    
    <td>
      Carico del processore.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>%MEM</code>
    </td>
    
    <td>
      Carico di memoria.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>TIME+</code>
    </td>
    
    <td>
      Tempo di utilizzo del processore.
    </td>
  </tr>
  
  <tr>
    <td>
      <code>COMMAND</code>
    </td>
    
    <td>
      Comando eseguito.
    </td>
  </tr>
</table>

<p spaces-before="0">
  Il comando <code>top</code> consente il controllo dei processi in tempo reale e in modalità interattiva.
</p>



<h3 spaces-before="0">
  comandi <code>pgrep</code> e <code>pkill</code>
</h3>

<p spaces-before="0">
  Il comando <code>pgrep</code> cerca i processi in esecuzione per un nome di processo e visualizza il <em x-id="4">PID</em> che soddisfa i criteri di selezione sull'output standard.
</p>

<p spaces-before="0">
  Il comando <code>pkill</code> invierà il segnale specificato (per impostazione predefinita <em x-id="4">SIGTERM</em>) ad ogni processo.
</p>

<pre><code>pgrep process
pkill [-signal] process
</code></pre>

<p spaces-before="0">
  Esempi:
</p>

<ul>
  <li>
    Ottenere il numero di processo di <code>sshd</code>:
  </li>
</ul>

<pre><code>$ pgrep -u root sshd
</code></pre>

<ul>
  <li>
    Termina tutti i processi <code>tomcat</code>:
  </li>
</ul>

<pre><code>$ pkill tomcat
</code></pre>
