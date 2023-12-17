- - -
author: Wale Soyinka contributors: Steven Spencer, Ganna Zhyrnova tested on: Tutte le versioni tags:
  - lab exercises
  - bootup, target and service management
  - systemd
  - systemctl
- - -


# Laboratorio 3: Processi di avvio e di messa in servizio


## Obiettivi


Dopo aver completato questo laboratorio, sarete in grado di

- controllare manualmente alcuni processi e servizi di avvio
- controllare automaticamente i servizi


Tempo stimato per completare questo laboratorio: 50 minuti


## Panoramica del processo di avvio

Le esercitazioni di questo laboratorio inizieranno dal processo di avvio fino al login dell'utente. Questi passaggi esaminano e cercano di personalizzare alcune parti dei processi di avvio. Le fasi principali del processo di avvio sono:

*Riepilogo dei passaggi*

1. l'hardware carica, legge ed esegue il settore di boot
2. viene eseguito il bootloader (GRUB sulla maggior parte delle distribuzioni Linux)
3. il kernel viene decompresso ed eseguito
4. il kernel inizializza l'hardware
5. il kernel monta il file system di root
6. il kernel esegue /usr/lib/systemd/systemd come PID 1
7. systemd avvia le unità necessarie e configurate per eseguire il target di avvio predefinito
8. i programmi getty vengono generati su ciascun terminale definito
9. getty richiede il login
10. getty esegue /bin/login come utente effettivo
11. login avvia la shell


### `systemd`

systemd è un gestore di sistema e di servizi per i sistemi operativi Linux.

### units `systemd`

`systemd` fornisce un sistema di dipendenza tra varie entità chiamate "units". Le units incapsulano vari oggetti necessari per l'avvio e la manutenzione del sistema. La maggior parte delle units viene configurata nei cosiddetti file di configurazione delle units, file di testo semplice in stile ini.

### Tipi di units di `systemd`

`systemd` dispone dei seguenti 11 tipi di units definite:

*Service units* avviare e controllare i demoni e i processi che li compongono.

*Socket units* incapsulano nel sistema i socket IPC o di rete locali, utili per l'attivazione basata sui socket.

*Target units* sono utilizzati per raggruppare altre units. Forniscono punti di sincronizzazione riconosciuti durante l'avvio

*Device units* espongono i dispositivi del kernel in systemd e possono essere utilizzati per implementare l'attivazione basata sui dispositivi.

*Mount units* controllare i punti di mount nel file system

*Automount units* forniscono funzionalità di automount, per il montaggio on-demand dei file system e per l'avvio in parallelo.

*Timer units* sono utili per attivare altre units in base ai timer.

*Swap units* sono molto simili alle units di montaggio e incapsulano partizioni di memoria o file di swap del sistema operativo.

*Path units* può essere usato per attivare altri servizi quando gli oggetti del file system cambiano o vengono modificati.

*Slice units* può essere usato per raggruppare le units che gestiscono i processi del sistema (come le units di servizio e di ambito) in un albero gerarchico per la gestione delle risorse.

*Scope units* sono simili alle units di servizio, ma gestiscono processi estranei invece di avviarli.

## Esercizio 1

### /usr/lib/systemd/systemd | PID=1

Storicamente l'init è stato chiamato con molti nomi e ha assunto diverse forme.

Indipendentemente dal nome o dall'implementazione, init (o il suo equivalente) è spesso indicato come la *madre di tutti i processi*.

La pagina man di "init" lo indica come il genitore di tutti i processi. Per convenzione, il primo programma o processo del kernel ad essere eseguito ha sempre un ID di processo pari a 1. Una volta che il primo processo viene eseguito, esso prosegue con l'avvio di altri servizi, demoni, processi, programmi e così via.

#### Per esplorare il primo processo di sistema

!!! note "Nota"

    Negli esercizi che seguono, sostituire PID con il numero ID del processo.

1. Accedere al sistema come un utente qualsiasi. Interrogare il percorso del file system virtuale /proc/PID/comm e individuare il nome del processo con l'ID 1. Digitare:

    ```bash
    [root@localhost ~]# cat /proc/1/comm

    systemd
    ```

2. Eseguire il comando `ls` per visualizzare il percorso del file system virtuale /proc/PID/exe e vedere il nome e il percorso dell'eseguibile che si trova all'origine del processo con l'ID 1. Digitare:

    ```bash
    [root@localhost ~]# ls -l /proc/1/exe

    lrwxrwxrwx 1 root root 0 Oct  5 23:56 /proc/1/exe -> /usr/lib/systemd/systemd
    ```

3. Provare a usare il comando `ps` per scoprire il nome del processo o del programma collegato al PID. Digitare:

    ```bash
    [root@localhost ~]# ps -p 1 -o comm=

    systemd
    ```

4. Utilizzare il comando `ps` per visualizzare il percorso completo e gli eventuali argomenti della riga di comando del processo o del programma associato al PID 1. Digitare:

    ```bash
    [root@localhost ~]# ps -p  1 -o args=

    /usr/lib/systemd/systemd --switched-root --system --deserialize 16
    ```

5. Per verificare che la madre di tutti i processi, tradizionalmente chiamata init, sia effettivamente systemd, usare `ls` per confermare che `init` è un collegamento simbolico al binario di `systemd`. Digitare:

    ```bash
    [root@localhost ~]# ls -l /usr/sbin/init
    lrwxrwxrwx. 1 root root 22 Aug  8 15:33 /usr/sbin/init -> ../lib/systemd/systemd
    ```

6. Utilizzare il comando `pstree` per mostrare una vista ad albero dei processi del sistema. Digitare:

    ```bash
    [root@localhost ~]# pstree --show-pids

    ```

## Esercizio 2

### `systemd` Targets (RUNLEVELS)

`systemd` definisce e si affida a molti obiettivi diversi per la gestione del sistema. In questo esercizio ci concentreremo solo su 5 dei principali target. I 5 target principali esplorati in questa sezione sono elencati qui di seguito:

1. poweroff.target
2. rescue.target
3. multi-user.target - avvia il sistema con pieno supporto multiutente senza ambiente grafico
4. graphical.target - avvia il sistema con la rete, il supporto multiutente e un gestore di display
5. reboot.target

!!! Tip "Suggerimento"

    Le unità target sostituiscono i livelli di esecuzione SysV nel sistema di init SysV classico.

#### Per gestire i target systemd

1. Elenca TUTTI i target (attivi + inattivi + falliti) disponibili sul server.

    ```bash
    [root@localhost ~]# systemctl list-units --type target --all
    ```

2. Elenca solo i target attualmente attivi. Digitare:

    ```bash
    [root@localhost ~]# systemctl list-units -t target    
    ```

3. Utilizzare il comando `systemctl` per visualizzare/ottenere il nome del target predefinito su cui il sistema è configurato per l'avvio. Digitare:

    ```bash
    [root@localhost ~]# systemctl get-default

    multi-user.target
    ```

4. Visualizzare il contenuto del file di unit per il target predefinito (multi-user.target). Digitare:

    ```bash
    [root@localhost ~]# systemctl cat multi-user.target

    # /usr/lib/systemd/system/multi-user.target
    ........
    [Unit]
    Description=Multi-User System
    Documentation=man:systemd.special(7)
    Requires=basic.target
    Conflicts=rescue.service rescue.target
    After=basic.target rescue.service rescue.target
    AllowIsolate=yes
    ```

    Si notino alcune proprietà e i loro valori configurati nella unit `multi-user.target`. Proprietà come - Descrizione, Documentazione, Richiede, Dopo e così via.

5. La unit `basic.target` è elencata come valore della proprietà `Requires` per `multi-user.target`. Visualizzare il file unit per basic.target. Digitare:

    ```bash
    [root@localhost ~]# systemctl cat multi-user.target
    # /usr/lib/systemd/system/basic.target
    [Unit]
    Description=Basic System
    Documentation=man:systemd.special(7)
    Requires=sysinit.target
    Wants=sockets.target timers.target paths.target slices.target
    After=sysinit.target sockets.target paths.target slices.target tmp.mount
    RequiresMountsFor=/var /var/tmp
    ```

6. Il comando `systemctl cat` mostra solo un sottoinsieme delle proprietà e dei valori di una determinata unità. Per visualizzare un dump di TUTTE le proprietà e i valori della unit target, usare il sottocomando show. Il comando `show` visualizza anche le proprietà di basso livello. Per visualizzare TUTTE le proprietà di multiuser.target, digitare:

    ```bash
    [root@localhost ~]# systemctl show  multi-user.target
    ```

7. Filtrare le proprietà Id, Requires e Description dal lungo elenco di proprietà della unit multi-user.target. Digitare:

    ```bash
    [root@localhost ~]# systemctl --no-pager show \
    --property  Id,Requires,Description  multi-user.target

    Id=multi-user.target
    Requires=basic.target
    Description=Multi-User System
    ```

8. Visualizzare i servizi e le risorse che il multi-user.target richiama all'avvio. In altre parole, visualizzare ciò che multi-user.target "Wants". Digitare:

    ```bash
    [root@localhost ~]# systemctl show --no-pager -p "Wants"  multi-user.target

    Wants=irqbalance.service sshd.service.....
    ...<SNIP>...
    ```

9.  Utilizzare i comandi `ls` e `file` per saperne di più sulla relazione tra il programma di `init` tradizionale e il programma `systemd`. Digitare:

    ```bash
    [root@localhost ~]# ls -l /usr/sbin/init && file /usr/sbin/init

    lrwxrwxrwx. 1 root root 22 Aug  8 15:33 /usr/sbin/init -> ../lib/systemd/systemd
    /usr/sbin/init: symbolic link to ../lib/systemd/systemd
    ```

#### Per cambiare il target di avvio predefinito


1. Impostare/modificare il target predefinito in cui il sistema si avvia. Utilizzare il comando `systemctl set-default` per cambiare il target predefinito in `graphical.target`. Digitare:

    ```bash
    [root@localhost ~]# systemctl set-default graphical.target

    ```

2. Controllare se il target di avvio appena impostato è attivo. Digitare:

    ```bash
    [root@localhost ~]# systemctl is-active graphical.target

    inactive
    ```

    Si noti che l'output mostra che il target *non è* attivo anche se è stato impostato come predefinito!

3. Per forzare il sistema a passare immediatamente a un determinato target e a utilizzarlo, è necessario utilizzare il comando secondario `isolate`. Digitare:

    ```bash
    [root@localhost ~]# systemctl isolate graphical.target
    ```

    !!! Warning "Attenzione"

     Il comando systemctl isolate può essere pericoloso se usato in modo errato. Questo perché interromperà immediatamente i processi non abilitati nel nuovo target, incluso l'ambiente grafico o il terminale attualmente in uso!

4. Verificare nuovamente se `graphical.target` è in uso e attivo.

5. Cercare e visualizzare gli altri servizi o risorse "Wants" del target grafico.

    !!! Question "Domanda"
   
        Quali sono le principali differenze dei "Wants" tra il multi-user.target e il graphical.target?

6. Poiché il vostro sistema sta eseguendo un sistema operativo di classe server, in cui un ambiente desktop grafico completo potrebbe non essere desiderabile, passate il sistema al più adatto multi-user.target. Digitare:

    ```bash
    [root@localhost ~]# systemctl isolate multi-user

    ```

7.  Impostare/modificare la destinazione predefinita per l'avvio del sistema in multi-user.target.

8.  Eseguire un rapido [e aggiuntivo] controllo manuale per vedere a quale target punta il link simbolico default.target, eseguendo:

    ```bash
    [root@localhost ~]# ls -l /etc/systemd/system/default.target
    ```

## Esercizio 3

Gli esercizi di questa sezione mostrano come configurare i processi di sistema/utente e i demoni (alias servizi) che possono essere avviati automaticamente con il sistema.

### Per visualizzare lo stato dei servizi

1. Mentre si è connessi come root, elencare tutte le unit systemd il cui tipo è un servizio. Digitare:

    ```bash
    root@localhost ~]# systemctl list-units -t service -all
    ```

    Questo mostrerà l'elenco completo delle unità attive e di quelle caricate ma inattive.

2. Visualizzare l'elenco delle unit systemd attive che hanno come tipo un servizio.

    ```bash
    [root@localhost ~]# systemctl list-units --state=active --type service
    UNIT                LOAD   ACTIVE SUB     DESCRIPTION
    atd.service         loaded active running Job spooling tools
    auditd.service      loaded active running Security Auditing Service
    chronyd.service     loaded active running NTP client/server
    crond.service       loaded active running Command Scheduler
    dbus.service        loaded active running D-Bus System Message Bus
    firewalld.service   loaded active running firewalld - dynamic firewall daemon
    ...<SNIP>...
    ```

3. Restringete e approfondite la configurazione di uno dei servizi dell'output precedente, il *crond.service*. Digitare:

    ```bash
    [root@localhost ~]# systemctl cat crond.service
    ```

4. Controllare se `crond.service` è configurato per avviarsi automaticamente all'avvio del sistema. Digitare:

    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service

    enabled
    ```

5. Visualizzare lo stato in tempo reale del servizio `crond.service`. Digitare:

    ```bash
    [root@localhost ~]# systemctl  status  crond.service  
    ```

    Per impostazione predefinita, l'output includerà le ultime 10 righe/entrate/log del journal.

6. Visualizzare lo stato di `crond.service` e sopprimere la visualizzazione delle righe del journal. Digitare:

    ```bash
    [root@localhost ~]# systemctl -n 0  status  crond.service  
    ```

7. Visualizzare lo stato di sshd.service.

    !!! question "Domanda"
   
        Visualizza lo stato di `firewalld.service'. Cos'è la unit `firewalld.service`?

### Per arrestare i servizi

1. Mentre siete ancora connessi come utente con privilegi amministrativi, usate il comando `pgrep` per vedere se il processo `crond` appare nell'elenco dei processi in esecuzione sul sistema.

    ```bash
    [root@localhost ~]# pgrep  -a crond

    313274 /usr/sbin/crond -n
    ```

    Se trova un processo corrispondente, il comando `pgrep` dovrebbe trovare ed elencare il PID di `crond`.

2. Utilizzare `systemctl` per arrestare la unit `crond.service`. Digitare:

    ```bash
    [root@localhost ~]# systemctl stop crond.service
    ```

    Il comando dovrebbe terminare senza alcun output.

3. Utilizzando `systemctl`, visualizzare lo stato di `crond.service` per vedere l'effetto della modifica.

4. Utilizzare nuovamente `pgrep` per verificare se il processo crond compare ancora nell'elenco dei processi.

### Per avviare i servizi

1. Accedere come utente amministrativo. Utilizzare il comando `pgrep` per vedere se un processo `crond` appare nell'elenco dei processi in esecuzione sul sistema.

    ```bash
    [root@localhost ~]# pgrep  -a crond
    ```

    Se `pgrep` trova un processo corrispondente, elencherà il PID di `crond`.

2. Utilizzare `systemctl` per avviare la unit `crond.service`. Digitare:

    ```bash
    [root@localhost ~]# systemctl start crond.service
    ```

    Il comando dovrebbe concludersi senza alcun output o feedback visibile.

3. Utilizzando `systemctl`, visualizzare lo stato di `crond.service` per vedere l'effetto della modifica. Digitare:

    ```bash
    [root@localhost ~]# systemctl -n 0 status crond.service

    ● crond.service - Command Scheduler
    Loaded: loaded (/usr/lib/systemd/system/crond.service; enabled; vendor preset: enabled)
    Active: active (running) since Mon 2023-10-16 11:38:04 EDT; 54s ago
    Main PID: 313451 (crond)
        Tasks: 1 (limit: 48282)
    Memory: 1000.0K
    CGroup: /system.slice/crond.service
            └─313451 /usr/sbin/crond -n
    ```

    !!! Question "Domanda"

     Dall'output del comando `systemctl` status sul sistema, qual è il PID di `crond`?

4. Allo stesso modo, utilizzare nuovamente `pgrep` per verificare se il processo `crond` appare ora nell'elenco dei processi. Confrontare il PID visualizzato da pgrep con il PID mostrato dal precedente `systemctl` status `crond.service`.

    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service

    enabled
    ```

### Per riavviare i servizi

Per molti servizi/daemon, spesso è necessario riavviare o ricaricare il servizio/daemon in esecuzione ogni volta che vengono apportate modifiche ai file di configurazione corrispondenti. In questo modo il processo/servizio/daemon in questione può applicare le ultime modifiche della configurazione.

1. Visualizzare lo stato di crond.service. Digitare:

    ```bash
    [root@localhost ~]# systemctl -n 0 status crond.service
    ```

    Annotare il PID di crond nell'output.

2. Eseguire `systemctl restart` per riavviare `crond.service`. Digitare:

    ```bash
    [root@localhost ~]# systemctl -n 0 status crond.service
    ```

    Il comando dovrebbe concludersi senza alcun output o feedback visibile.

3. Verificare nuovamente lo stato di `crond.service`. Confrontare il PID più recente con quello annotato al punto 1.

4. Utilizzare `systemctl` per verificare se `crond.service` è attualmente attivo. Digitare:

    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    active
    ```

    !!! Question "Domanda"

     Perché si pensa che i PID siano diversi ogni volta che si riavvia un servizio?


    !!! Tip "Suggerimento"

     La funzionalità del classico comando del servizio è stata adattata per funzionare senza problemi sui sistemi gestiti da systemd. È possibile utilizzare comandi di servizio come i seguenti per arrestare, avviare, riavviare e visualizzare lo stato del servizio `smartd`.

        ```bash
        # service smartd status

        # service smartd stop

        # service smartd start

        # service smartd restart
        ```

### Per disabilitare un servizio

1. Utilizzare `systemctl` per verificare se il servizio `crond.service` è impostato per avviarsi automaticamente all'avvio del sistema. Digitare:

    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service

    enabled
    ```

    L'output di esempio mostra che è così.

2. Disabilitare il servizio `crond.service` dall'avvio automatico. Digitare:

    ```bash
    [root@localhost ~]# systemctl disable crond.service
    Removed /etc/systemd/system/multi-user.target.wants/crond.service.
    ```

3. Eseguire nuovamente il comando `systemctl is-enabled` per visualizzare l'effetto delle modifiche.

    !!! Question "Domanda"
   
        Su un server da gestire in remoto, perché NON si vuole disabilitare un servizio come `sshd.service` dall'avvio automatico all'avvio del sistema?

### Per garantire la disabilitazione (es. mask) di un servizio

Anche se il comando `systemctl disable` può essere usato per disabilitare i servizi, come si è visto negli esercizi precedenti, altre unit di systemd (processi, servizi, demoni e così via) possono riattivare silenziosamente un servizio disabilitato, se necessario. Questo può accadere quando un servizio dipende da un altro servizio [disabilitato].

Per garantire la disattivazione di una unit di servizio systemd ed evitare la riattivazione accidentale, è necessario mascherare il servizio.

1. Utilizzare `systemctl` per mascherare il servizio `crond.service` e prevenire qualsiasi riattivazione indesiderata, digitare:

    ```bash
    [root@localhost ~]# systemctl mask crond.service

    Created symlink /etc/systemd/system/crond.service → /dev/null.
    ```

2. Eseguire il comando `systemctl is-enabled` per visualizzare l'effetto delle modifiche.

    ```bash
    [root@localhost ~]# systemctl is-enabled  crond.service

    masked
    ```

3. Per annullare le modifiche e smascherare `crond.service`, utilizzare il comando `systemctl unmask` eseguendo:

    ```bash
    [root@localhost ~]# systemctl unmask crond.service

    Removed /etc/systemd/system/crond.service.
    ```

### Per abilitare un servizio

1. Utilizzare `systemctl` per verificare lo stato dell'unità `crond.service`. Digitare:

    ```bash
    [root@localhost ~]# systemctl status crond.service
    ```

    Il servizio dovrebbe essere ancora in uno stato di arresto.

2. Utilizzare il comando `systemctl enable` per abilitare `crond.service` all'avvio automatico. Digitare:

    ```bash
    [root@localhost ~]# systemctl enable crond.service

    Created symlink /etc/systemd/system/multi-user.target.wants/crond.service → /usr/lib/systemd/system/crond.service.
    ```

3. Utilizzare nuovamente `systemctl` per verificare se `crond.service` è attivo. Digitare:

    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    inactive
    ```

    !!! Question "Domanda"

     Si è appena abilitato `crond.service`. Perché non è in esecuzione o non è indicato come attivo nel comando precedente?

4. Utilizzare una variante leggermente diversa del comando `systemctl enable` per abilitare `crond.service` e lanciare immediatamente il demone in esecuzione. Digitare:

    ```bash
    [root@localhost ~]# systemctl --now enable crond.service
    ```

5. Controllare se `crond.service` è ora attivo. Digitare:

    ```bash
    [root@localhost ~]# systemctl is-active crond.service
    active
    ```

6. Utilizzando `systemctl`, assicurarsi che il servizio `crond.service` sia avviato, in esecuzione e abilitato all'avvio automatico.
