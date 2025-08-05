---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhrynova
tested on: All Versions
tags:
  - system monitoring
  - process monitoring
  - fuser
  - numactl
  - perf
  - chrt
  - schedtool
  - atop
  - strace
  - systemd-run
  - taskset
  - cgroups
---

# Laboratorio 4: Monitoraggio avanzato del sistema e dei processi

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di

- visualizzare e gestire i processi utilizzando strumenti avanzati
- diagnosticare ed eseguire il debug delle chiamate di sistema
- visualizzare e impostare la priorità dei processi utilizzando strumenti avanzati della CLI
- visualizzare e impostare politiche di pianificazione personalizzate per i processi
- analizzare le prestazioni di sistemi e applicazioni

Tempo stimato per completare questo laboratorio: 90 minuti

## Introduzione

I comandi di questo Laboratorio coprono una gamma più ampia di gestione dei processi, monitoraggio del sistema e controllo delle risorse in Linux. Aggiungono maggiore profondità e varietà al vostro repertorio di amministratori di sistema.

Questi esercizi coprono i comandi e i concetti aggiuntivi di Linux, fornendo esperienza pratica per la gestione dei processi, il monitoraggio delle risorse e il controllo avanzato.

## Esercizio 1

### fuser

Il comando `fuser` in Linux è utilizzato per identificare i processi che utilizzano file o socket. Può essere un utile aiuto nella gestione dei processi relativi ai file e nella risoluzione dei conflitti.

#### Per creare uno script per simulare l'utilizzo dei file

1. Per prima cosa, creare un file di prova vuoto a cui si vuole accedere. Digitare:

  ```bash
  touch ~/testfile.txt
  ```

2. Creare lo script che verrà utilizzato per simulare l'accesso a `testfile.txt`. Digitare:

  ```bash
  cat > ~/simulate_file_usage.sh << EOF
  #!/bin/bash
  tail -f ~/testfile.txt
  EOF   
  ```

3. Rendere lo script eseguibile. Digitare:

  ```bash
  chmod +x ~/simulate_file_usage.sh
  ```

4. Avviare lo script. Digitare:

  ```bash
  ~/simulate_file_usage.sh &
  ```

#### Identificazione dei processi che accedono a un file

1. Identificare i processi che utilizzano o accedono a `testfile.txt`, eseguire:

  ```bash
  fuser ~/testfile.txt
  ```

2. Esplorare altre opzioni `fuser` usando l'opzione `-v`. Digitare:

  ```bash
  fuser -v ~/testfile.txt
  ```

3. Il tutto è stato fatto con `testfile.txt` e `simulate_file_usage.sh`. Ora è possibile rimuovere i file. Digitare:

  ```bash
  kill %1
  rm ~/testfile.txt ~/simulate_file_usage.sh
  ```

#### Identificazione di un processo che accede a una porta TCP/UDP

1. Utilizzare il comando `fuser` per identificare il processo di accesso alla porta TCP 22 del server. Digitare:

  ```bash
  sudo fuser 22/tcp
  ```

## Esercizio 2

### `perf`

`perf` è uno strumento versatile per analizzare le prestazioni del sistema e delle applicazioni in Linux. Può offrire ulteriori approfondimenti che possono aiutare la messa a punto delle prestazioni.

#### Installazione di `perf`

1. Installare l'applicazione `perf` se non è installata sul server. Digitare:

  ```bash
  sudo dnf -y install perf
  ```

2. L'applicazione `bc` è una calcolatrice di precisione a riga di comando. In questo esercizio verrà utilizzato `bc` per simulare un elevato carico della CPU. Se `bc` non è già installato sul server, installarlo con:

  ```bash
  sudo dnf -y install bc
  ```

#### Per creare uno script per generare il carico della CPU

1. Creare uno script di carico della CPU e renderlo eseguibile eseguendo:

  ```bash
  cat > ~/generate_cpu_load.sh << EOF
  #!/bin/bash

  # Check if the number of decimal places is passed as an argument
  if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <number_of_decimal_places>"
    exit 1
  fi

  # Calculate Pi to the specified number of decimal places
  for i in {1..10}; do echo "scale=$1; 4*a(1)" | bc -l; done

  EOF
  chmod +x ~/generate_cpu_load.sh
  ```

  !!! tip "Suggerimento"

  ```
   Lo script `generate_cpu_load.sh` è un semplice strumento per generare il carico della CPU calcolando il Pi greco (π) ad alta precisione. Lo stesso calcolo viene eseguito 10 volte. Lo script accetta un intero come parametro per specificare il numero di cifre decimali per il calcolo del Pi greco.
  ```

#### Simulazione del carico supplementare della CPU

1. Eseguire un semplice test e calcolare il Pi greco con 50 cifre decimali. Eseguite lo script digitando:

  ```bash
  ~/generate_cpu_load.sh 50 & 
  ```

2. Eseguire nuovamente lo script, ma utilizzare `perf` per registrare le prestazioni dello script e analizzare l'utilizzo della CPU e altre metriche. Digitare:

  ```bash

   ./generate_cpu_load.sh 1000  &  perf record -p $! sleep 5
  ```

  !!! tip "Suggerimento"

  ```
   L'opzione `sleep 5` con il comando `perf record` definisce la finestra temporale in cui `perf` raccoglie i dati sulle prestazioni del carico della CPU generato dallo script generate_cpu_load.sh. Consente a `perf di registrare le metriche delle prestazioni del sistema per 5 secondi prima di fermarsi automaticamente.
  ```

#### Per analizzare i dati sulle prestazioni e monitorare gli eventi in tempo reale

1. Usare il comando `perf report` per esaminare il report dei dati sulle prestazioni e capire i modelli di utilizzo della CPU e della memoria. Digitare:

  ```bash
  sudo perf report
  ```

  È possibile utilizzare vari tasti della tastiera per esplorare ulteriormente il rapporto.
  Digitare ++"q"++ per uscire dall'interfaccia di visualizzazione dei rapporti `perf`.

2. Osservare/capire gli eventi della cache della CPU in tempo reale per 40 secondi per identificare potenziali colli di bottiglia delle prestazioni. Digitare:

  ```bash
  sudo perf stat -e cache-references,cache-misses sleep 40
  ```

#### Per registrare le prestazioni complete del sistema

1. Acquisizione di dati sulle prestazioni dell'intero sistema che possono essere utilizzati per ulteriori analisi. Digitare:

  ```bash
  sudo perf record -a sleep 10
  ```

2. Esplorare i contatori di eventi specifici. Contare eventi specifici come i cicli della CPU per valutare le prestazioni di un determinato script o applicazione. Eseguiamo un test con un comando `find` di base, digitando:

  ```bash
  sudo perf stat -e cycles find /proc
  ```

3. Fare la stessa cosa ma con lo script `generate_cpu_load.sh`. Acquisire eventi specifici come i cicli della CPU per valutare le prestazioni dello script `generate_cpu_load.sh`. Digitare:

  ```bash
  sudo perf stat -e cycles ./generate_cpu_load.sh 500
  ```

  OUTPUT:

  ```bash
  ...<SNIP>...
  3.141592653589793238462643383279502884197169399375105820974944592307\
  81640628620899862803482534211.....

  Performance counter stats for './generate_cpu_load.sh 500':

    1,670,638,886      cycles

       0.530479014 seconds time elapsed

       0.488580000 seconds user
       0.034628000 seconds sys
  ```

  !!! note "Nota"

  ```
   Ecco la ripartizione dell'output finale del comando `perf stat`:
   
   *1,670,638,886 cycles*: Indica il numero totale di cicli della CPU consumati durante l'esecuzione dello script. Ogni ciclo rappresenta un singolo passo nell'esecuzione delle istruzioni della CPU.

   *0.530479014 seconds time elapsed*: È il tempo totale trascorso nel mondo reale (o tempo wall-clock) dall'inizio alla fine dell'esecuzione dello script. Questa durata include tutti i tipi di attesa (come l'attesa di I/O su disco o le chiamate di sistema).

   *0.488580000 seconds user*: È il tempo di CPU trascorso in modalità utente. Questo tempo esclude esplicitamente il tempo dedicato alle attività a livello di sistema.  

   *0.034628000 seconds sys*: È il tempo trascorso dalla CPU in modalità kernel o di sistema. Include il tempo che la CPU trascorre eseguendo chiamate di sistema o eseguendo altre attività a livello di sistema per conto dello script.
  ```

4. Tutto fatto con lo strumento `perf`. Assicurarsi che tutti gli script in background garantiscano un ambiente di lavoro pulito.

  ```bash
  kill %1
  ```

## Esercizio 3

### `strace`

`strace` è utilizzato per la diagnosi e il debug delle interazioni delle chiamate di sistema in Linux.

#### Per creare uno script per l'esplorazione di `strace`

1. Creare un semplice script chiamato `strace_script.sh` e renderlo eseguibile. Digitare:

  ```bash
  cat > ~/strace_script.sh << EOF
  #!/bin/bash
  while true; do
    date
    sleep 1
  done
  EOF
  chmod +x ~/strace_script.sh
  ```

#### Per usare `strace` sui processi in esecuzione

1. Eseguire lo script e allegare `strace`. Digitare:

  ```bash
  ~/strace_script.sh &
  ```

2. Trovare il PID del processo `strace_script.sh` in un terminale separato. Memorizzare il PID in una variabile denominata MYPID. A tale scopo, utilizzare il comando `pgrep` eseguendo:

  ```bash
  export MYPID=$(pgrep strace_script) ; echo $MYPID
  ```

  OUTPUT:

  ```bash
  4006301
  ```

3. Iniziate a tracciare le chiamate di sistema dello script per capire come interagisce con il kernel. Collegare `strace` al processo di script in esecuzione digitando:

  ```bash
  sudo strace -p $MYPID
  ```

4. Interrompi o arresta il processo `strace` digitando ++ctrl+c++

5. L'output di `strace` può essere filtrato concentrandosi su specifiche chiamate di sistema come `open` e `read` per analizzarne il comportamento. Provate a farlo per le chiamate di sistema `open` e `read`. Digitare:

  ```bash
  sudo strace -e trace=open,read -p $MYPID
  ```

  Una volta terminato il tentativo di decifrare l'output di `strace`, interrompere il processo `strace` digitando ++ctrl+c++

6. Reindirizzare l'output in un file per un'analisi successiva, che può aiutare a diagnosticare i problemi. Salvare l'output di `strace` in un file eseguendo:

  ```bash
  sudo strace -o strace_output.txt -p $MYPID
  ```

#### Per analizzare la frequenza delle chiamate di sistema

1. Riassumere il conteggio delle chiamate di sistema per identificare le chiamate di sistema più frequentemente utilizzate dal processo. Eseguire questa operazione per soli 10 secondi, aggiungendo il comando `timeout`. Digitare:

  ```bash
  sudo timeout 10 strace -c -p $MYPID
  ```

  Il sistema di esempio mostra un report di riepilogo come questo:

  OUTPUT:

  ```bash
  strace: Process 4006301 attached
  strace: Process 4006301 detached
  % time     seconds  usecs/call     calls    errors syscall
  ------ ----------- ----------- --------- --------- ----------------
  89.59    0.042553        1182        36        18 wait4
  7.68    0.003648         202        18           clone
  1.67    0.000794           5       144           rt_sigprocmask
  0.45    0.000215           5        36           rt_sigaction
  0.36    0.000169           9        18           ioctl
  0.25    0.000119           6        18           rt_sigreturn
  ------ ----------- ----------- --------- --------- ----------------
  100.00    0.047498         175       270        18 total
  ```

2. Terminare lo script e rimuovere i file creati.

  ```bash
  kill $MYPID
  rm ~/strace_script.sh ~/strace_output.txt
  ```

## Esercizio 4

### `atop`

`atop` fornisce una visione completa delle prestazioni del sistema, coprendo varie metriche delle risorse.

#### Per lanciare ed esplorare `atop`

1. Installare l'applicazione `atop` se non è installata sul server. Digitare:

  ```bash
  sudo dnf -y install atop
  ```

2. Eseguire `atop` digitando:

  ```bash
  sudo atop
  ```

3. All'interno dell'interfaccia `atop`, è possibile esplorare varie metriche `atop` premendo tasti specifici sulla tastiera.

  È possibile utilizzare i tasti 'm', 'd' o 'n' per passare dalla visualizzazione della memoria a quella del disco o della rete. Osservare l'utilizzo delle risorse in tempo reale.

4. Monitorare le prestazioni del sistema a un intervallo personalizzato di 2 secondi, consentendo una visione più granulare dell'attività del sistema. Digitare:

  ```bash
  sudo atop 2
  ```

5. Passare da una visualizzazione all'altra delle risorse per concentrarsi su aspetti specifici delle prestazioni del sistema.

6. Generare un report su file di registro per l'attività del sistema, acquisendo i dati ogni 60 secondi, per tre volte. Digitare:

  ```bash
  sudo atop -w /tmp/atop_log 60 3
  ```

7. Una volta completato il comando precedente, è possibile esaminare con calma il file binario in cui sono stati salvati i registri. Per rileggere il file di registro salvato, digitare:

  ```bash
  sudo atop -r /tmp/atop_log   
  ```

8. Pulire rimuovendo i log o i file generati.

  ```bash
  sudo rm /tmp/atop_log
  ```

## Esercizio 5

### `numactl`

È una struttura/architettura di memoria per computer utilizzata nel multiprocessing che migliora la velocità di accesso alla memoria considerando la posizione fisica della memoria rispetto ai processori.
Nei sistemi basati su NUMA, più processori (o core di CPU) sono fisicamente raggruppati e ogni gruppo ha la sua memoria locale.

L'applicazione `numactl` gestisce la politica NUMA, ottimizzando le prestazioni sui sistemi basati su NUMA.

#### Installazione di `numactl`

1. Installare l'applicazione `numactl` se non è installata sul server. Digitare:

  ```bash
  sudo dnf -y install numactl
  ```

#### Per creare uno script ad alta intensità di memoria

1. Create un semplice script per simulare un carico di lavoro ad alta intensità di memoria sul vostro server. Digitare:

  ```bash
  cat > ~/memory_intensive.sh << EOF
    #!/bin/bash

    awk 'BEGIN{for(i=0;i<1000000;i++)for(j=0;j<1000;j++);}{}'
    EOF
    chmod +x ~/memory_intensive.sh
  ```

#### Utilizzo di `numactl`

1. Eseguire lo script con `numactl`, digitare:

  ```bash
  numactl --membind=0 ~/memory_intensive.sh
  ```

2. Se il sistema dispone di più di un nodo NUMA, è possibile eseguire lo script su più nodi NUMA tramite:

  ```bash
  numactl --cpunodebind=0,1 --membind=0,1 ~/memory_intensive.sh
  ```

3. Visualizzare l'allocazione della memoria sui nodi NUMA

  ```bash
  numactl --show
  ```

4. Legare la memoria a un nodo specifico eseguendo:

  ```bash
  numactl --membind=0 ~/memory_intensive.sh
  ```

5. Pulite l'ambiente di lavoro rimuovendo lo script.

  ```bash
  rm ~/memory_intensive.sh
  ```

## Esercizio 6

### `iotop`

Il comando `iotop` monitora l'utilizzo dell'I/O (input/output) del disco da parte di processi e thread. Fornisce informazioni in tempo reale simili al comando `top`, in particolare per l'I/O del disco. Ciò lo rende essenziale per diagnosticare i rallentamenti del sistema causati dall'attività del disco.

#### Installazione di `iotop`

1. Installare l'utilità `iotop` se non è installata. Digitare:

  ```bash
  sudo dnf -y install iotop
  ```

#### Per usare `iotop` per monitorare l'I/O del disco

1. Eseguire il comando \`iotop' senza alcuna opzione per utilizzarlo nella sua modalità interattiva predefinita. Digitare:

  ```bash
  sudo iotop
  ```

  Osservare l'utilizzo del disco live I/O da parte dei vari processi. Si usa per identificare i processi che stanno leggendo o scrivendo sul disco.

2. Digitare ++"q"++ per uscire da `iotop`.

#### Per usare `iotop` in modalità non interattiva

1. Eseguire `iotop` in modalità batch (-b) per ottenere una visione non interattiva e immediata dell'utilizzo dell'I/O. L'opzione `-n 10` indica a `iotop` di prelevare 10 campioni prima di uscire.

  ```bash
  sudo iotop -b -n 10
  ```

2. `iotop` può filtrare l'I/O per processi specifici. Identificare l'ID di un processo (PID) dal sistema utilizzando il comando ps o la visualizzazione `iotop`. Quindi, filtrare l'uscita `iotop` per quel PID specifico. Ad esempio, filtrare il PID del processo `sshd`, eseguendo:

  ```bash
  sudo iotop -p $(pgrep sshd | head -1)
  ```

3. L'opzione -`o` con `iotop` può essere usata per mostrare i processi o i thread che eseguono l'I/O effettivo, invece di visualizzare tutti i processi o i thread. Visualizzare solo i processi di I/O in esecuzione:

  ```bash
  sudo iotop -o
  ```

  !!! Question "Discussione"

  ```
   Discutere l'impatto dell'I/O del disco sulle prestazioni complessive del sistema e come strumenti come `iotop` possono aiutare nell'ottimizzazione del sistema.
  ```

## Esercizio 7

### `cgroups`

I gruppi di controllo (`cgroups`) forniscono un meccanismo in Linux per organizzare, limitare e dare priorità all'uso delle risorse da parte dei processi.

Questo esercizio dimostra l'interazione diretta con il filesystem `cgroup` v2.

### Per esplorare il filesystem `cgroup`

1. Usare il comando `ls` per esplorare il contenuto e la struttura del filesystem `cgroup`. Digitare:

  ```bash
  ls /sys/fs/cgroup/
  ```

2. Usare di nuovo il comando `ls` per elencare le cartelle \*.slice sotto il filesystem `cgroup`. Digitare:

  ```bash
  ls -d /sys/fs/cgroup/*.slice
  ```

  Le cartelle con estensione .slice sono solitamente utilizzate in `systemd` per rappresentare una porzione delle risorse di sistema. Si tratta di `cgroups` standard gestiti da `systemd` per organizzare e gestire i processi di sistema.

### Per creare un `cgroup` personalizzato

1. Creare una directory denominata "exercise_group" nel file system /sys/fs/cgroup. Questa nuova cartella ospiterà le strutture dei gruppi di controllo necessarie per il resto dell'esercizio. Utilizzare il comando `mkdir` digitando:

  ```bash
  sudo mkdir -p /sys/fs/cgroup/exercise_group
  ```

2. Elenca i file e le directory sotto la struttura /sys/fs/cgroup/exercise_group. Digitare:

  ```bash
  sudo ls /sys/fs/cgroup/exercise_group/
  ```

  L'output mostra i file e le directory creati automaticamente dal sottosistema `cgroup` per gestire e monitorare le risorse del `cgroup`.

#### Per impostare un nuovo limite di risorse di memoria

1. Impostare un limite di risorse di memoria per limitare l'uso della memoria a 4096 byte (4kB). Per limitare i processi nel `cgroup` affinché utilizzino un massimo di 4 kB di memoria, digitare:

  ```bash
  echo 4096 | sudo tee /sys/fs/cgroup/exercise_group/memory.max
  ```

2. Confermare l'impostazione del limite di memoria. Digitare:

  ```bash
  cat /sys/fs/cgroup/exercise_group/memory.max
  ```

#### Per creare lo script di test memory_stress

1. Creare un semplice script eseguibile usando il comando `dd` per testare il limite delle risorse di memoria. Digitare:

  ```bash
  cat > ~/memory_stress.sh << EOF
  #!/bin/bash
  dd if=/dev/zero of=/tmp/stress_test bs=10M count=2000
  EOF
  chmod +x ~/memory_stress.sh
  ```

#### Per eseguire e aggiungere processi/script alla memoria `cgroup`

1. Avviare lo script `memory_stress.sh`, catturare il suo PID e aggiungere il PID a `cgroup.procs`. Digitare:

  ```bash
  ~/memory_stress.sh &
  echo $! | sudo tee /sys/fs/cgroup/exercise_group/cgroup.procs
  ```

  Utilizzare il file /sys/fs/cgroup/exercise_group/cgroup.procs per aggiungere o visualizzare i PID (Process ID) dei processi che sono membri di un determinato `cgroup`. La scrittura di un PID in questo file assegna il processo di script `memory_stress.sh` al `cgroup`.

2. Il comando precedente terminerà molto rapidamente prima del completamento, perché ha superato i limiti di memoria di `cgroup`. È possibile eseguire il seguente comando `journalctl` in un altro terminale per visualizzare l'errore mentre si verifica. Digitare:

  ```bash
  journalctl -xe -f  | grep -i memory
  ```

  !!! tip "Suggerimento"

  ````
   È possibile utilizzare rapidamente il comando ps per verificare l'utilizzo approssimativo della memoria di un processo se si conosce il PID del processo in esecuzione:

   ```bash
   pidof <PROCESS_NAME> | xargs ps -o pid,comm,rss
   ```

  Questo output dovrebbe mostrare il Resident Set Size (RSS) in KB, che indica la memoria utilizzata dal processo specificato in un determinato momento. Ogni volta che il valore RSS di un processo supera il limite di memoria specificato nel valore memory.max di `cgroup`, il processo può essere soggetto alle politiche di gestione della memoria applicate dal kernel o dallo stesso `cgroup`. A seconda della configurazione del sistema, il sistema può intraprendere azioni quali la limitazione dell'uso della memoria del processo, l'arresto del processo o l'attivazione di un evento OOM (Out-of-Memory).
  ````

#### Per impostare un nuovo limite di risorse della CPU

1. Limitare l'uso dello script solo al 10% di un core della CPU. Digitare:

  ```bash
  echo 10000 | sudo tee /sys/fs/cgroup/exercise_group/cpu.max
  ```

  10000 rappresenta il limite di larghezza di banda della CPU. È impostato sul 10% della capacità totale di un singolo core della CPU.

2. Confermare che è stato impostato il limite della CPU. Digitare:

  ```bash
  cat /sys/fs/cgroup/exercise_group/cpu.max
  ```

#### Per creare lo script del test di stress della CPU

1. Creare e impostare le autorizzazioni di esecuzione per uno script che genera un elevato utilizzo della CPU. Digitare:

  ```bash
  cat > ~/cpu_stress.sh << EOF
  #!/bin/bash
  exec yes > /dev/null
  EOF
  chmod +x ~/cpu_stress.sh
  ```

  !!! note "Nota"

  ```
    `yes > /dev/null` è un comando semplice che genera un elevato carico di CPU.
  ```

#### Per eseguire e aggiungere un processo/script al `cgroup` della CPU

1. Eseguire lo script e aggiungere contemporaneamente il suo PID al `cgroup`, digitando:

  ```bash
  ~/cpu_stress.sh &
  echo $! | sudo tee /sys/fs/cgroup/exercise_group/cgroup.procs
  ```

#### Per confermare il controllo dell'utilizzo della CPU del processo

1. Controllare l'utilizzo della CPU del processo.

  ```bash
  pidof yes | xargs top -b -n 1 -p
  ```

  L'output dovrebbe mostrare l'utilizzo della CPU in tempo reale del processo yes. La %CPU per yes dovrebbe essere limitata in base alla configurazione di `cgroup` (ad esempio, circa il 10% se il limite è impostato a 10000).

2. Impostate e sperimentate altri valori per cpu.max per il gruppo di esercizio `cgroup` e poi osservate l'effetto ogni volta che rieseguite lo script ~/cpu_stress.sh nel gruppo di controllo.

#### Per identificare e selezionare il dispositivo di archiviazione primario

Il dispositivo di archiviazione primario può essere un obiettivo per impostare i limiti delle risorse di I/O. I dispositivi di archiviazione sui sistemi Linux hanno numeri di dispositivo maggiori e minori che possono essere utilizzati per identificarli in modo univoco.

1. Per prima cosa, creare una serie di variabili ausiliarie per rilevare e memorizzare il numero di dispositivo del dispositivo di archiviazione primario sul server. Digitare:

  ```bash
  primary_device=$(lsblk | grep disk | awk '{print $1}' | head -n 1)
  primary_device_num=$(ls -l /dev/$primary_device | awk '{print $5, $6}' | sed 's/,/:/')
  ```

2. Visualizzare il valore della variabile `$primary_device_num`. Digitare:

  ```bash
  echo "Primary Storage Device Number: $primary_device_num"
  ```

3. I numeri di dispositivo maggiore e minore dovrebbero corrispondere a quelli visualizzati nell'output di ls:

  ```bash
    ls -l /dev/$primary_device
  ```

#### Per impostare un nuovo limite di risorse di I/O

1. Impostare le operazioni di I/O a 1 MB/s per i processi di lettura e scrittura sotto il gruppo di esercizio `cgroup`. Digitare:

  ```bash
  echo "$primary_device_num rbps=1048576 wbps=1048576" | \
  sudo tee /sys/fs/cgroup/exercise_group/io.max
  ```

2. Confermare i limiti di I/O impostati. Digitare:

  ```bash
  cat /sys/fs/cgroup/exercise_group/io.max
  ```

#### Per creare il processo di stress test I/O

1. Avviare un processo `dd` per creare un file di grandi dimensioni chiamato `/tmp/io_stress`. Inoltre, catturare e memorizzare il PID del processo `dd` in una variabile chiamata `MYPID`. Digitare:

  ```bash
  dd if=/dev/zero of=/tmp/io_stress bs=10M count=500 oflag=dsync \
  & export MYPID=$!
  ```

#### Per aggiungere un processo/script al `cgroup` di I/O

1. Aggiungere il PID del processo `dd` precedente al controllo `cgroup` di exercise_group. Digitare:

  ```bash
  echo $MYPID | sudo tee /sys/fs/cgroup/exercise_group/cgroup.procs
  ```

#### Per confermare il controllo delle risorse di utilizzo dell'I/O del processo

1. Controllare l'utilizzo dell'I/O del processo eseguendo:

  ```bash
  iotop -p $MYPID
  ```

  L'output mostrerà la velocità di I/O in lettura/scrittura del processo io_stress.sh, che non dovrebbe superare 1 MB/s come da limite.

#### Eliminazione di `cgroups`

1. Digitare i seguenti comandi per terminare qualsiasi processo in background, eliminare il `cgroup` non più necessario e rimuovere il file /tmp/io_stress.

  ```bash
  kill %1
  sudo rmdir /sys/fs/cgroup/exercise_group/
  sudo rm -rf /tmp/io_stress
  ```

## Esercizio 8

### `taskset`

L'affinità della CPU associa processi o thread specifici a particolari core della CPU in un sistema multi-core. Questo esercizio dimostra l'uso di `taskset` per impostare o recuperare l'affinità della CPU di un processo in Linux.

### Esplorazione dell'affinità della CPU con `taskset`

1. Utilizzare `lscpu` per elencare le CPU disponibili sul sistema. Digitare:

  ```bash
  lscpu | grep "On-line"
  ```

2. Creare un processo campione utilizzando l'utilità `dd` e memorizzare il suo PID in una variabile `MYPID`. Digitare:

  ```bash
  dd if=/dev/zero of=/dev/null & export MYPID="$!"
  echo $MYPID
  ```

3. Recupera l'affinità corrente per il processo `dd`. Digitare:

  ```bash
  taskset -p $MYPID
  ```

  OUTPUT:

  ```bash
  pid 1211483's current affinity mask: f
  ```

  L'output mostra la maschera di affinità della CPU del processo con PID 1211483 (`$MYPID`), rappresentata in formato esadecimale. Nel nostro sistema campione, la maschera di affinità visualizzata è "f", che in genere significa che il processo può essere eseguito su qualsiasi core della CPU.

  !!! note "Nota"

  ```
   La maschera di affinità della CPU "f" rappresenta una configurazione in cui tutti i core della CPU sono abilitati. In notazione esadecimale, "f" corrisponde al valore binario "1111". Ogni bit nella rappresentazione binaria corrisponde a un core della CPU, con "1" che indica che il core è abilitato e disponibile per l'esecuzione del processo.

   Pertanto, su una CPU a quattro core, con la maschera "f":

   Core 0: Enabled
   Core 1: Enabled
   Core 2: Enabled
   Core 3: Enabled
  ```

### Impostazione/modifica dell'affinità della CPU

1. Imposta l'affinità della CPU del processo `dd` su una sola CPU (CPU 0). Digitare:

  ```bash
  taskset -p 0x1 $MYPID
  ```

  OUTPUT

  ```bash
  pid 1211483's current affinity mask: f
  pid 1211483's new affinity mask: 1
  ```

2. Verificate la modifica eseguendo il seguente comando:

  ```bash
  taskset -p $MYPID
  ```

  L'output indica la maschera di affinità della CPU del processo con PID `$MYPID`. La maschera di affinità è "1" in decimale, che si traduce in "1" in binario. Ciò significa che il processo è attualmente legato al core 0 della CPU.

3. Ora, impostare l'affinità della CPU del processo `dd` su più CPU (CPU 0 e 1). Digitare:

  ```bash
  taskset -p 0x3 $MYPID
  ```

4. Eseguire il comando `tasksel` corretto per verificare l'ultima modifica.

  ```bash
  taskset -p $MYPID
  ```

  Sul nostro server demo a 4 core, l'output mostra che la maschera di affinità della CPU del processo è "3" (in decimale). Ciò si traduce in "11" in binario.

  !!! tip "Suggerimento"

  ```
   Il "3" decimale corrisponde a "11" (o 0011) in binario.
   Ogni cifra binaria corrisponde a un core della CPU: core 0, core 1, core 2, core 3 (da destra a sinistra).
   La cifra "1" nella quarta e terza posizione (da destra) indica che il processo può essere eseguito sui core 0 e 1.
   Pertanto, "3" indica che il processo è legato ai core 0 e 1 della CPU.
  ```

5. Lanciate l'utilità `top` o `htop` in un terminale separato e osservate se vedete qualcosa di interessante mentre sperimentate diverse configurazioni di `taskset` per un processo.

6. Tutto fatto. Utilizzare il suo PID (`$MYPID`) per uccidere il processo `dd`.

## Esercizio 9

### `systemd-run`

Il comando `systemd-run` crea e avvia unità di servizio transitorie per comandi o processi in esecuzione. Può anche eseguire programmi in unità di scopo transitorie, unità di servizio con percorso, socket o timer.

Questo esercizio mostra come usare `systemd-run` per creare unità di servizio transitorie in `systemd`.

#### Esecuzione di un comando come servizio transitorio

1. Eseguire il semplice comando sleep 300 come servizio transitorio `systemd` usando `systemd-run`. Digitare:

  ```bash
  systemd-run --unit=mytransient.service --description="Example Service" sleep 300
  ```

2. Controllare lo stato del servizio transitorio usando `systemctl status`. Digitare:

  ```bash
  systemctl status mytransient.service
  ```

#### Impostazione di un limite di risorse di memoria per un servizio transitorio

1. Usare il parametro `--property` con `systemd-run` per limitare l'uso massimo della memoria per il processo transitorio a 200M. Digitare:

  ```bash
  systemd-run --unit=mylimited.service --property=MemoryMax=200M sleep 300
  ```

2. Cercare il processo nel file system `cgroup` corrispondente per verificare l'impostazione. Digitare:

  ```bash
  sudo cat /sys/fs/cgroup/system.slice/mytransient.service/memory.max
  ```

  !!! tip "Suggerimento"

  ```
   `systemd.resource-control` è un'entità di configurazione o di gestione (concetto) all'interno del framework `systemd`, progettata per controllare e allocare le risorse del sistema ai processi e ai servizi. E `systemd.exec` è un componente di `systemd` responsabile della definizione dell'ambiente di esecuzione in cui vengono eseguiti i comandi. Per visualizzare le varie impostazioni (proprietà) che si possono modificare quando si usa `systemd-run`, consultare le pagine di manuale di `systemd.resource-control` e `systemd.exec`. Qui si trova la documentazione delle proprietà come MemoryMax, CPUAccounting, IOWeight, ecc. 
  ```

#### Impostazione del limite delle risorse della CPU per un servizio transitorio

1. Creare un'unità transitoria `systemd` chiamata "myrealtime.service". Eseguire `myrealtime.service` con una specifica politica di schedulazione round robin (rr) e priorità. Digitare:

  ```bash
  systemd-run --unit=myrealtime.service \
  --property=CPUSchedulingPolicy=rr --property=CPUSchedulingPriority=50 sleep 300
  ```

2. Visualizzare lo stato di `myrealtime.service`. Inoltre, catturare/memorizzare il PID principale [sleep] in una variabile MYPID. Digitare:

  ```bash
  MYPID=$(systemctl status myrealtime.service   |  awk '/Main PID/ {print $3}')
  ```

3. Verificare la politica di programmazione della CPU mentre il servizio è ancora in esecuzione. Digitare:

  ```bash
  chrt  -p $MYPID
  pid 2553792's current scheduling policy: SCHED_RR
  pid 2553792's current scheduling priority: 50
  ```

### Creazione di una unità timer transitoria

1. Creare una semplice unità timer che esegua un semplice comando di eco. L'opzione `--on-active=2m` imposta l'attivazione del timer 2 minuti dopo l'attivazione dell'unità timer. Digitare:

  ```bash
  systemd-run --on-active=2m --unit=mytimer.timer \
  --description="Example Timer" echo "Timer triggered"
  ```

  Il timer inizia il conto alla rovescia dal momento in cui l'unità viene attivata e, dopo 2 minuti, attiva l'azione specificata.

2. Visualizza i dettagli/stato dell'unità timer appena creata. Digitare:

  ```bash
  systemctl status mytimer.timer
  ```

#### Arresto e pulizia delle unità transitorie di `systemd`

1. Digitare i seguenti comandi per assicurarsi che i vari servizi/processi transitori avviati per questa esercitazione siano correttamente arrestati e rimossi dal sistema. Digitare:

  ```bash
  systemctl stop mytransient.service
  systemctl stop mylimited.service
  systemctl stop myrealtime.service
  systemctl stop mytimer.timer
  ```

## Esercizio 10

### `schedtool`

Questo esercizio dimostra l'uso di `schedtool` per comprendere e manipolare la schedulazione dei processi in Rocky Linux. A tal fine, si creerà anche uno script per simulare un processo.

#### Installazione di `schedtool`

1. Installare l'applicazione `schedtool` se non è installata sul server. Digitare:

  ```bash
  sudo dnf -y install schedtool
  ```

#### Creazione di uno script di processo simulato

1. Creare uno script che generi il carico della CPU a scopo di test. Digitare:

  ```bash
  cat > ~/cpu_load_generator.sh << EOF
  #!/bin/bash
  while true; do
       openssl speed > /dev/null 2>&1
       openssl speed > /dev/null 2>&1

  done
  EOF
  chmod +x ~/cpu_load_generator.sh
  ```

2. Avviare lo script in background. Digitare:

  ```bash
  ~/cpu_load_generator.sh & echo $!
  ```

3. Acquisire il PID del processo principale `openssl` avviato all'interno dello script `cpu_load_generator.sh`. Memorizzare il PID in una variabile denominata `$MYPID`. Digitare:

  ```bash
  export  MYPID=$(pidof openssl) ; echo $MYPID
  ```

#### Utilizzo di `schedtool` per controllare la politica di schedulazione corrente

1. Usare il comando `schedtool` per visualizzare le informazioni di pianificazione del processo con PID `$MYPID`. Digitare:

  ```bash
  schedtool $MYPID
  ```

  OUTPUT:

  ```bash
  PID 2565081: PRIO   0, POLICY N: SCHED_NORMAL  , NICE   0, AFFINITY 0xf
  ```

#### Utilizzo di `schedtool` per modificare la politica di scheduling

1. Modificare la politica di schedulazione e la priorità dei processi FIFO e 10, rispettivamente. Digitare:

  ```bash
  sudo schedtool -F -p 10 $!
  ```

2. Visualizzare l'effetto delle modifiche. Digitare:

  ```bash
  schedtool $MYPID
  ```

3. Modificare la politica di schedulazione e la priorità del processo in round robin o SCHED_RR (RR) e 50, rispettivamente. Digitare:

  ```bash
  sudo schedtool -R -p 50 $MYPID
  ```

4. Visualizzare l'effetto delle modifiche. Digitare:

  ```bash
  schedtool $MYPID
  ```

5. Modificare la politica di pianificazione del processo in Idle o SCHED_IDLEPRIO (D). Digitare:

  ```bash
  sudo schedtool -D $MYPID
  ```

6. Visualizzare l'effetto delle modifiche.

7. Infine, ripristinare la politica di schedulazione del processo al valore predefinito originale SCHED_NORMAL (N o altro). Digitare:

  ```bash
  sudo schedtool -N $MYPID
  ```

#### Arresto e puliza del processo `cpu_load_generator.sh`

1. Tutto fatto. Terminare lo script e cancellare lo script `cpu_load_generator.sh`.

  ```bash
  kill $MYPID
  rm ~/cpu_load_generator.sh
  ```
