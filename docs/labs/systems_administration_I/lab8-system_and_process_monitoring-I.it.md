---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tested on: All Versions
tags:
  - system monitoring
  - process monitoring
  - ps
  - pgrep
  - pidof
  - cgroups
  - pstree
  - top
  - kill
  - lsof
  - pkill
  - exec
---

# Lab 8: Monitoraggio di Sistema e dei processi

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di:

- visualizzare e gestire i processi
- terminare i processi anomali
- modificare la priorità di processo

Tempo stimato per completare questo laboratorio: 60 minuti

## Introduzione

Questi esercizi trattano vari argomenti relativi al monitoraggio e alla gestione dei processi su sistemi Linux. Gli argomenti trattati includono l'identificazione e il controllo dei processi, la gestione delle priorità dei processi, la gestione dei segnali, il monitoraggio delle risorse e la gestione dei “cgroup”.

## Esercizio 1

### Esplorazione con `ps` e `/proc`

#### Esplorare e identificare il primo processo di sistema

1. Accedere al sistema come un utente qualsiasi.

2. Trovare il nome del processo con ID 1 utilizzando /proc.

   ```bash
   cat /proc/1/comm
   ```

   !!! question "Domanda"

   ```
    Qual è il nome del processo con PID 1?
   ```

3. Visualizzare il nome e il percorso dell'eseguibile che si trova dietro al processo con PID 1.

   ```bash
   ls -l /proc/1/exe
   ```

   !!! question "Domanda"

   ```
    Qual è il percorso dell'eseguibile dietro il PID 1?
   ```

4. Utilizzare il comando `ps` per scoprire il nome del processo o del programma associato al PID 1.

   ```bash
   ps -p 1 -o comm=
   ```

   !!! question "Domanda"

   ```
    Il comando `ps` conferma il nome del processo?
   ```

5. Utilizzare il comando `ps` per visualizzare il percorso completo e gli eventuali argomenti della riga di comando del processo o del programma associato al PID 1.

   ```bash
   ps -p 1 -o args=
   ```

   !!! question "Domanda"

   ```
    Qual è il percorso completo e gli argomenti della riga di comando per il processo con PID 1?
   ```

   !!! question "Domanda"

   ```
    Perché il processo con PID 1 è importante su un sistema Linux?
   ```

#### Visualizzazione delle informazioni dettagliate sul processo utilizzando `ps`

I seguenti passaggi mostrano come utilizzare `ps` per visualizzare le informazioni di base sui processi.

1. Utilizzare il comando `ps` per visualizzare un elenco di tutti i processi in una struttura ad albero.

   ```bash
   ps auxf
   ```

   !!! question "Domanda"

   ```
    Qual è la struttura dell'elenco dei processi e quali informazioni vengono visualizzate?
   ```

2. Filtrare l'elenco in modo da visualizzare solo i processi associati a un utente specifico, ad esempio l'utente “root”.

   ```bash
   ps -U root
   ```

   Verificare che vengano visualizzati solo i processi relativi all'utente “root”.

3. Mostrare i processi in un formato dettagliato, inclusi l'albero dei processi e i thread. Digitare:

   ```bash
   ps -eH
   ```

   !!! question "Domanda"

   ```
    Quali ulteriori dettagli vengono mostrati in questo formato?
   ```

4. Visualizzare i processi ordinati in base all'utilizzo della CPU in ordine decrescente.

   ```bash
   ps aux --sort=-%cpu
   ```

   !!! question "Domanda"

   ```
    Quale processo sta consumando più CPU?
   ```

## Esercizio 2

### Gestione dei processi con `kill`

#### Per terminare un processo utilizzando `kill`

1. Avviare un processo di sospensione a lungo termine in background e visualizzare il PID sul terminale. Digitare:

   ```bash
   (sleep 3600 & MYPROC1=$! && echo PID is: $MYPROC1) 2>/dev/null
   ```

   OUTPUT:

   ```bash
   PID is: 1331933
   ```

   Prendere nota del PID del nuovo processo sul sistema. Il PID viene salvato anche nella variabile $MYPROC1.

2. Inviare un segnale di chiusura (SIGTERM) al processo `sleep`.

   ```bash
   kill $MYPROC1
   ```

   Sostituire $MYPROC1 con il PID effettivo ottenuto al punto 1.

3. Verificare se il processo è terminato utilizzando `ps` e `ps aux`.

   ```bash
   ps aux | grep -v grep | grep sleep
   ```

#### Per terminare i processi utilizzando i segnali `kill`

1. Avviare un nuovo processo in sospeso e prendere nota del suo PID. Digitare:

   ```bash
   (sleep 3600 & MYPROC2=$! && echo PID is: $MYPROC2) 2>/dev/null
   ```

   OUTPUT:

   ```bash
   PID is: 1333258
   ```

2. Inviare un segnale diverso (ad esempio, SIGHUP) al nuovo processo in sospeso. Digitare:

   ```bash
   kill -1 $MYPROC2
   ```

   Verificare che $MYPROC2 non sia più presente nella tabella dei processi.

3. Avviare un nuovo processo ping e prendere nota del suo PID. Digitare:

   ```bash
   { ping localhost > /dev/null 2>&1 & MYPROC3=$!; } \
       2>/dev/null; echo "PID is: $MYPROC3"
   ```

4. Utilizzare il comando `kill` per inviare un segnale `SIGTERM` al processo ping. Digitare:

   ```bash
   kill -15 $MYPROC3
   ```

   Sostituire MYPROC3 con il PID effettivo del processo sul vostro sistema.

5. Avviare un processo di lunga durata utilizzando il comando `cat`. Digitare:

   ```bash
   { cat /dev/random > /dev/null 2>&1 & MYPROC4=$!; } \
    2>/dev/null; echo PID is: $MYPROC4
   ```

   Prendere nota del PID del processo sul vostro sistema.

6. Utilizzare `kill` per terminare forzatamente il processo inviando un segnale SIGKILL.

   ```bash
   kill -9 $MYPROC4
   ```

   Verificare che il processo sia terminato.

   !!! question "Domanda"

   ```
    Spiegare lo scopo dell'invio di segnali ai processi utilizzando il comando `kill` e il significato dei diversi tipi di segnale.
   ```

## Esercizio 3

### Monitoraggio delle risorse di sistema con `top`

#### Monitorare l'utilizzo delle risorse di sistema con `top`

1. Eseguire il comando top per visualizzare le statistiche di sistema in tempo reale.

   ```bash
   top
   ```

   !!! question "Domanda"

   ```
    Quali informazioni vengono visualizzate nell'interfaccia superiore?
   ```

2. Osservare l'utilizzo della CPU e della memoria dei processi nell'interfaccia superiore.

   !!! question "Domanda"

   ```
    Quali processi consumano più CPU e memoria?
   ```

3. Ordinare i processi in `top` in base all'utilizzo della CPU (premere P) e all'utilizzo della memoria (premere M).

   !!! question "Domanda"

   ```
    Quali sono i processi che consumano più CPU e memoria dopo l'ordinamento?
   ```

#### Monitorare l'utilizzo della CPU e della memoria per processi specifici utilizzando `top`

1. Creare un file di dimensioni arbitrarie pari a 512 Mb contenente dati casuali.

   ```bash
   sudo fallocate -l 512M  ~/large-file.data
   ```

2. Avviare un processo che richieda molte risorse, come la compressione di file di grandi dimensioni.

   ```bash
    tar -czf archive.tar.gz /path/to/large/directory
   ```

3. Aprire il comando `top` per monitorare l'utilizzo della CPU e della memoria.

   ```bash
    top
   ```

4. Individuare e selezionare il processo che richiede molte risorse nell'interfaccia superiore.

   !!! question "Domanda"

   ```
    Qual è l'ID del processo e l'utilizzo delle risorse del processo intensivo?
   ```

5. Modificare l'ordine di ordinamento in `top` per visualizzare i processi che utilizzano più CPU o memoria (premere P o M).

   !!! question "Domanda"

   ```
    Qual è il processo che si trova in cima alla lista dopo l'ordinamento?
   ```

6. Uscire da `top` premendo `q`.

#### Monitorare i processi e l'utilizzo delle risorse utilizzando `top`

1. Avviare il comando `top` in modalità interattiva.

   ```bash
   top
   ```

   !!! question "Domanda"

   ```
    Quali informazioni vengono visualizzate nella schermata superiore?
   ```

2. Utilizzare il tasto 1 per visualizzare un riepilogo dell'utilizzo dei singoli core della CPU.

   !!! question "Domanda"

   ```
    Qual è la ripartizione dell'utilizzo del core della CPU per ciascun core?
   ```

3. Premere u per visualizzare i processi di un utente specifico. Inserire il vostro nome utente.

   !!! question "Domanda"

   ```
    Quali processi sono attualmente in esecuzione per il vostro utente?
   ```

4. Ordinare i processi in base all'utilizzo della memoria (premere M) e osservare i processi che consumano più memoria.

   !!! question "Domanda"

   ```
    Quali processi stanno utilizzando più memoria?
   ```

5. Uscire da top premendo ++"q"++.

   !!! question "Domanda"

   ```
    Spiegare l'importanza del monitoraggio delle risorse di sistema mediante il comando `top` e come questo possa aiutare a risolvere i problemi relativi alle prestazioni.
   ```

## Esercizio 4

### Modifica della priorità di un processo con `nice` e `renice`

#### Regolare la priorità del processo utilizzando `nice`

1. Avviare un processo che richieda un uso intensivo della CPU con priorità predefinita/normale. Digitare:

   ```bash
   bash -c  'while true; do echo "Default priority: The PID is $$"; done'
   ```

   OUTPUT:

   ```bash
   Default priority: The PID is 2185209
   Default priority: The PID is 2185209
   Default priority: The PID is 2185209
   ....<SNIP>...
   ```

   Dall'output, il valore del PID sul nostro sistema di esempio è `2185209`.

   Il valore del PID sarà diverso sul vostro sistema.

   Si noti il valore del PID visualizzato continuamente sullo schermo del vostro sistema.

2. In un altro terminale, utilizzando il valore PID, controllare la priorità predefinita del processo utilizzando `ps`. Digitare:

   ```bash
   ps -p <PID> -o ni
   ```

   !!! question "Domanda"

   ```
    Qual è la priorità predefinita del processo in esecuzione (valore `nice`)?
   ```

3. Utilizzando il PID del processo stampato, terminare il processo utilizzando il comando `kill`.

4. Utilizzando il comando `nice`, riavviare un processo simile con un valore di niceness inferiore (ovvero più favorevole al processo O con priorità più alta). Utilizzare un valore `nice` pari a `-20`. Digitare:

   ```bash
   nice -n -20 bash -c  'while true; do echo "High priority: The PID is $$"; done'
   ```

5. Utilizzando il valore del PID, controllare la priorità del processo utilizzando `ps`. Digitare:

   ```bash
   ps -p <PID> -o ni
   ```

   !!! question "Domanda"

   ```
    La priorità del processo è stata impostata correttamente?
   ```

6. Premendo contemporaneamente i tasti ++ctrl+c++ sulla tastiera `terminare` il nuovo processo ad alta priorità.

7. Utilizzando nuovamente il comando `nice`, riavviare un altro processo, ma questa volta con un valore di niceness più alto (cioè meno favorevole al processo O con priorità inferiore). Utilizzare un valore `nice` pari a `19` Digitare:

   ```bash
    nice -n 19 bash -c  'while true; do echo "Low priority: The PID is $$"; done'
   ```

   OUTPUT:

   ```bash
   Low priority: The PID is 2180254
   Low priority: The PID is 2180254
   ...<SNIP>...
   ```

8. Controllare la priorità personalizzata del processo utilizzando `ps`. Digitare:

   ```bash
   ps -p <PID> -o ni
   ```

9. Premere contemporaneamente i tasti ++ctrl+c++ sulla tastiera per terminare il nuovo processo a bassa priorità.

10. Provare a modificare la priorità dei diversi processi assegnando valori più alti o più bassi e osservare l'impatto sull'utilizzo delle risorse del processo.

#### Per regolare la priorità di un processo in esecuzione utilizzando `renice`

1. Avviare un processo che richieda un uso intensivo della CPU, come un calcolo matematico complesso con l'utilità md5sum. Digitare:

   ```bash
   find / -path '/proc/*' -prune -o -type f -exec md5sum {} \; > /dev/null
   ```

2. Utilizzare il comando `ps` per individuare il PID del processo `find/md5sum` precedente. Digitare:

   ```bash
   ps -C find -o pid=
   ```

   OUTPUT:

   ```bash
   2577072
   ```

   Dall'output, il valore del PID sul sistema di esempio è `2577072`.

   Il valore del PID sarà diverso sul vostro sistema.

   Prendere nota del valore del PID sul sistema.

3. Utilizzare il comando `renice` per impostare la priorità del processo `find/md5sum` in esecuzione su un valore di niceness inferiore (ad esempio, -10, priorità più alta). Digitare:

   ```bash
   renice  -n -10 -p $(ps -C find -o pid=)
   ```

   OUTPUT:

   ```bash
        <PID> (process ID) old priority 0, new priority -10
   ```

   Sostituire `<PID>` (sopra) con il PID effettivo del processo in esecuzione.

4. Monitorare l'utilizzo delle risorse per il processo `find/md5sum`, utilizzando `top` (o `htop`).  Digitare:

   ```bash
   top -cp $(ps -C find -o pid=)
   ```

   !!! question "Domanda"

   ```
    Il processo ora riceve una quota maggiore di risorse della CPU?
   ```

5. Modificare la priorità del processo `find/md5sum` impostando un valore `nice` più alto (ad esempio 10, priorità più bassa). Digitare:

   ```bash
   renice  -n 10 -p <PID>
   ```

   OUTPUT:

   ```bash
   2338530 (process ID) old priority -10, new priority 10
   ```

   Sostituire `<PID>` (sopra) con il PID effettivo del processo in esecuzione.

   !!! question "Domanda"

   ```
    Spiegare come viene utilizzato il comando `nice` per regolare le priorità dei processi e come influisce sull'allocazione delle risorse di sistema.
   ```

6. Premere contemporaneamente i tasti ++ctrl+c++ sulla tastiera per interrompere il processo `find/md5sum` . È anche possibile utilizzare il comando `kill` per ottenere lo stesso risultato.

## Esercizio 5

### Identificazione dei processi con `pgrep`

#### Trovare i processi in base al nome utilizzando `pgrep`

1. Utilizzare il comando `pgrep` per identificare tutti i processi associati a un programma o servizio specifico, come ad esempio `sshd`.

   ```bash
   pgrep sshd
   ```

   !!! question "Domanda"

   ```
    Quali sono gli ID dei processi `sshd`?
   ```

2. Verificare l'esistenza dei processi identificati utilizzando il comando `ps`.

   ```bash
    ps -p <PID1,PID2,...>
   ```

   Sostituire “<PID1,PID2,...>” con gli ID di processo ottenuti al punto 1.

3. Utilizzare il comando `pgrep` per identificare i processi con un nome specifico, ad esempio “cron”.

   ```bash
   pgrep cron
   ```

   !!! question "Domanda"

   ```
    Esistono processi con il nome “cron”?
   ```

   !!! question "Domanda"

   ```
    Spiegare la differenza tra l'uso di `ps` e `pgrep` per identificare e gestire i processi.
   ```

## Esercizio 6

### Processi in foreground e in background

Questo esercizio riguarda la gestione dei processi con `fg` e `bg`.

#### Gestire i processi in background e in primo piano utilizzando `bg` e `fg`

1. Avviare un processo long-running in foreground. Ad esempio, si può usare un comando semplice come `sleep`. Digitare:

   ```bash
   sleep 300
   ```

2. Sospendere il processo in foreground premendo ++ctrl+z++ sulla tastiera. Questo dovrebbe riportarvi al prompt della shell.

3. Elencare i processi sospesi utilizzando il comando `jobs`. Digitare:

   ```bash
   jobs
   ```

   !!! question "Domanda"

   ```
    Qual è lo stato del lavoro sospeso?
   ```

4. Riportare il processo sospeso in foreground utilizzando il comando `fg`.

   ```bash
   fg
   ```

   !!! question "Domanda"

   ```
    Cosa succede quando si riporta il lavoro in foreground?
   ```

5. Sospendere nuovamente il processo utilizzando ++ctrl+z++, quindi spostarlo in background utilizzando il comando `bg`.

   ```bash
   bg
   ```

   !!! question "Domanda"

   ```
    Qual è lo stato attuale del lavoro?
   ```

   !!! question "Domanda"

   ```
    Spiegare lo scopo dei processi in primo piano e in background e come vengono gestiti utilizzando i comandi `fg` e `bg`.
   ```

#### Avviare un processo in background

1. Il simbolo `&` può avviare un processo che viene immediatamente eseguito in background. Ad esempio, per avviare il comando `sleep` in background, digitare:

   ```bash
   sleep 300 &
   ```

   Sospendere il processo in esecuzione utilizzando ++ctrl+z++.

2. Elencare lo stato di tutti i jobs attivi. Digitare:

   ```bash
   jobs -l
   ```

   !!! question "Domanda"

   ```
    Qual è lo stato del processo “sleep 300”?
   ```

3. Riportare il processo in background in primo piano utilizzando il comando `fg`.

   ```bash
   fg
   ```

4. Terminare anticipatamente il processo `sleep` inviandogli il segnale SIGSTOP premendo ++ctrl+c++.

#### Per gestire i processi interattivi utilizzando `bg` e `fg`

1. Avviare un processo interattivo come l'editor di testo `vi` per creare e modificare un file di testo di esempio denominato “foobar.txt”. Digitare:

   ```bash
   vi foobar1.txt
   ```

   Sospendere il processo in esecuzione utilizzando `Ctrl` + `Z`.

   Utilizzare il comando `bg` per spostare il processo sospeso in background.

   ```bash
   bg
   ```

   !!! question "Domanda"

   ```
    Il processo è ora in esecuzione in background?
   ```

2. Inserire “Hello” all'interno del file `foobar1.txt` nel vostro editor `vi`.

3. Sospendere la sessione di modifica del testo `vi` in esecuzione premendo ++ctrl+z++.

4. Avviare un'altra sessione separata dell'editor `vi` per creare un altro file di testo denominato “foobar2.txt”. Digitare:

   ```bash
   vi foobar2.txt
   ```

5. Inserire il testo di esempio “Hi inside foobar2.txt” nella seconda sessione di vi.

6. Sospendere la seconda sessione vi utilizzando ++ctrl+z++.

7. Elencare lo stato di tutti i `job` sul terminale corrente. Digitare:

   ```bash
   jobs -l
   ```

   OUTPUT:

   ```bash
   [1]- 2977364 Stopped       vi foobar1.txt
   [2]+ 2977612 Stopped       vi foobar2.txt
   ```

   Si dovrebbero avere almeno 2 job elencati nell'output. Il numero nella prima colonna dell'output mostra i numeri dei job: [1] e [2].

8. Riprendere ==e portare in primo piano== la prima sessione `vi` digitando:

   ```bash
   fg %1
   ```

9. Sospendere nuovamente la prima sessione `vi` utilizzando ++ctrl+z++.

10. Riprendere ==e portare in foreground== la seconda sessione `vi` digitando:

    ```bash
    fg %2
    ```

11. Terminare in modo non corretto entrambe le sessioni di modifica `vi` inviando il segnale KILL a entrambi i processi. Eseguire il comando `kill` seguito dal comando jobs. Digitare:

    ```bash
     kill -SIGKILL  %1 %2 && jobs
    ```

    OUTPUT:

    ```bash
    [1]-  Killed                  vi foobar1.txt
    [2]+  Killed                  vi foobar2.txt
    ```

## Esercizio 7

### Identificazione dei processi con `pidof`

#### Trovare l'ID di processo di un comando in esecuzione utilizzando `pidof`

1. Selezioniamo un processo in esecuzione standard/comune di cui vogliamo trovare l'ID. Useremo `systemd` come esempio.

2. Utilizzare il comando `pidof` per trovare l'ID del processo di `systemd`. Digitare:

   ```bash
   pidof systemd
   ```

   Prendere nota del ID di processo di `systemd`.

3. Verificare l'esistenza del processo identificato utilizzando il comando `ps`.

   ```bash
   ps -p <PID>
   ```

   Sostituire `<PID>` con l'ID del processo ottenuto al punto 2.

   !!! question "Domanda"

   ```
    Spiegare la differenza tra `pgrep` e `pidof` per trovare l'ID di processo di un comando in esecuzione.
   ```

## Esercizio 8

### Esplorazione del filesystem /sys

#### Esplorare il filesystem /sys

1. Elencare il contenuto della directory /sys. Digitare:

   ```bash
   ls /sys
   ```

   !!! question "Domanda"

   ```
    Che tipo di informazioni sono memorizzate nella directory /sys?
   ```

2. Passare a una voce specifica di /sys, ad esempio le informazioni sulla CPU.

   ```bash
   cd /sys/devices/system/cpu
   ```

3. Elencare il contenuto della directory corrente per esplorare le informazioni relative alla CPU.

   ```bash
   ls
   ```

   !!! question "Domanda"

   ```
    Quali informazioni relative alla CPU sono disponibili nel filesystem /sys?
   ```

   !!! question "Domanda"

   ```
    Spiegare lo scopo del filesystem /sys in Linux e il suo ruolo nella gestione dell'hardware e della configurazione del sistema.
   ```

## Esercizio 9

### Arresto dei processi in base al nome con `pkill`

#### Terminare i processi in base al nome utilizzando `pkill`

1. Identificare i processi con un nome specifico, come “firefox”.

   ```bash
   pkill firefox
   ```

   !!! question "Domanda"

   ```
    Sono stati terminati tutti i processi con il nome “firefox”?
   ```

2. Controllare che lo stato dei processi sia terminato utilizzando `ps`.

   ```bash
    ps aux | grep firefox
   ```

   !!! question "Domanda"

   ```
    Ci sono processi rimanenti con il nome “firefox”?
   ```

   Utilizza `pkill` per terminare forzatamente tutti i processi con un nome specifico.

   ```bash
   pkill -9 firefox
   ```

   Verificare che tutti i processi con il nome “firefox” siano stati terminati.

   !!! question "Domanda"

   ```
    Qual è la differenza tra l'uso di `kill` e `pkill` per terminare i processi in base al nome?
   ```

## Esercizio 10

Questo esercizio riguarda l'uso del potente comando `exec`.

### Controllo dei processi con `exec`

#### Rimpiazzare la shell corrente con un altro comando utilizzando `exec`

1. Avviare una nuova sessione shell. Digitare:

   ```bash
   bash
   ```

2. Lanciare un comando che non esce dalla nuova shell, come un semplice ciclo while.

   ```bash
    while true; do echo "Running..."; done
   ```

3. Nella shell corrente, sostituire il comando in esecuzione con uno diverso utilizzando `exec`.

   ```bash
    exec echo "This replaces the previous command."
   ```

   Da notare che il comando precedente è stato chiuso e quello nuovo è in esecuzione.

4. Verificare che il vecchio comando non sia più in esecuzione utilizzando `ps`.

   ```bash
   ps aux | grep "while true"
   ```

   !!! question "Domanda"

   ```
    Il comando precedente è ancora in esecuzione?
   ```

   !!! question "Domanda"

   ```
    Spiega come il comando `exec` può sostituire il processo della shell corrente con un comando diverso.
   ```

## Esercizio 11

### Gestione dei processi con `killall`

Come `kill`, `killall` è un comando che consente di terminare i processi in base al nome anziché al PID. Si possono osservare alcune somiglianze tra l'uso di `killall` , `kill` e `pkill` nella chiusura dei processi.

#### Terminare i processi in base al nome utilizzando `killall`

1. Identificare i processi con un nome specifico, come “chrome”.

   ```bash
    killall chrome
   ```

   !!! question "Domanda"

   ```
    Sono stati terminati tutti i processi con il nome “chrome”?
   ```

2. Controllare che lo stato dei processi sia terminato utilizzando `ps`.

   ```bash
    ps aux | grep chrome
   ```

   !!! question "Domanda"

   ```
    Ci sono processi rimanenti con il nome “chrome”?
   ```

3. Utilizzare `killall` per terminare forzatamente tutti i processi con un nome specifico.

   ```bash
    killall -9 chrome
   ```

   Verificare che tutti i processi con il nome “chrome” siano stati chiusi.

   !!! question "Domanda"

   ```
    In che modo `killall` differisce da `pkill` e `kill` quando si terminano i processi in base al nome?
   ```

## Esercizio 12

### Gestione di `cgroups`

#### Gestire i processi utilizzando `cgroups`

1. Elencare i `cgroups` esistenti sul vostro sistema.

   ```bash
   cat /proc/cgroups
   ```

   !!! question "Domanda"

   ```
    Quali sono i controller `cgroup` disponibili sul vostro sistema?
   ```

2. Creare un nuovo cgroup utilizzando il controller della CPU. Nominarlo “mygroup”.

   ```bash
   sudo mkdir -p /sys/fs/cgroup/cpu/mygroup
   ```

3. Spostare un processo specifico (ad esempio, un comando sleep in esecuzione) nel `cgroup` “mygroup”.

   ```bash
   echo <PID> | sudo tee /sys/fs/cgroup/cpu/mygroup/cgroup.procs
   ```

   Sostituire `<PID>` con il PID effettivo del processo.

4. Verificare se il processo è stato spostato nel `cgroup` “mygroup”.

   ```bash
   cat /sys/fs/cgroup/cpu/mygroup/cgroup.procs
   ```

   !!! question "Domanda"

   ```
    Il processo è elencato nel cgroup “mygroup”?
   ```

   !!! question "Domanda"

   ```
    Spiegare il concetto di “cgroups” in Linux e come questi possono gestire e controllare l'allocazione delle risorse per i processi.
   ```

## Esercizio 13

### Gestione dei processi con `renice`

#### Regolare la priorità di un processo in esecuzione utilizzando `renice`

1. Identificare un processo in esecuzione con un PID e una priorità specifici utilizzando `ps`.

   ```bash
   ps -p <PID> -o ni
   ```

   !!! question "Domanda"

   ```
    Qual è l'attuale priorità (valore nice) del processo?
   ```

2. Utilizzare il comando `renice` per modificare la priorità (valore nice) del processo in esecuzione.

   ```bash
   renice <PRIORITY> -p <PID>
   ```

   Sostituire `<PRIORITY>` con il nuovo valore di priorità che si desidera impostare e `<PID>` con il PID effettivo del processo.

3. Verificare che la priorità del processo sia cambiata utilizzando `ps`.

   ```bash
   ps -p <PID> -o ni
   ```

   !!! question "Domanda"

   ```
    La priorità ora è diversa?
   ```

4. Provare a modificare la priorità impostando un valore più alto o più basso e osservare l'impatto sull'utilizzo delle risorse del processo.

   !!! question "Domanda"

   ```
    Cosa succede al consumo di risorse del processo con valori nice diversi?
   ```

   !!! question "Domanda"

   ```
    Spiegare come viene utilizzato il comando renice per regolare la priorità dei processi in esecuzione e i suoi effetti sull'utilizzo delle risorse di processo.
   ```
