---
author: Wale Soyinka
contributors: Steven Spencer
tested on: Tutte le versioni
tags:
  - network file system
  - nfs
  - exportfs
  - rpc
  - nfs-server
---

# Laboratorio 5: NFS

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di

- installare e configurare NFS
- condividere file e directory tra sistemi Linux utilizzando NFS
- utilizzare le comuni utilità NFS per interrogare o risolvere i problemi NFS

Tempo stimato per completare questo laboratorio: 40 minuti

## NFS

NFS è l'acronimo di Network File System. Permette di condividere file e cartelle in rete con altri sistemi. NFS offre un modo semplice per rendere disponibile il contenuto del file system locale a più utenti (o sistemi) su una rete.

Questa condivisione avviene tradizionalmente tra sistemi UNIX/Linux, ma anche i sistemi operativi Microsoft Windows possono accedere alle condivisioni NFS se hanno installato il software appropriato per farlo.

Il supporto per NFS deve essere abilitato o compilato nel kernel.

Come per la maggior parte dei concetti di rete, NFS ha lati client e server. Il lato server consiste nel sistema che esporta (condivide) i file system ad altri sistemi. Il lato client è costituito dai sistemi che devono accedere al file system esportato dal server.

NFSv4 richiede i servizi dei seguenti programmi (daemon):

- portmap - mappa i programmi RPC alle normali porte di rete
- mountd - gestisce le richieste di montaggio in arrivo
- nfsd - è il programma NFS principale che gestisce il trasferimento effettivo dei file

## /etc/exports

Il file di configurazione `/etc/exports` serve come elenco di controllo degli accessi per specificare i file system che possono essere esportati via NFS ai client autorizzati. Fornisce informazioni a `mountd` e al demone del server di file NFS basato sul kernel `nfsd`.

Le direttve in `/etc/exports` utilizzano la seguente sintassi:

```bash
shareable_directory  allowed_clients(options_affecting_allowed_clients) 
```

## Esercizio 1

### Gestione di NFS

In questo esercizio condividerete (esporterete) una directory locale da condividere con il sistema partner, ma prima imparerete a gestire il servizio NFS.

NFS è un'applicazione client e server basata su Remote Procedure Call (RPC). È quindi utile avere a portata di mano delle utility RPC che possono essere utilizzate per eseguire interrogazioni, debug e chiamate RPC a server RPC (come i server NFS). `rpcinfo` è una di queste utilità. La sintassi e le opzioni di utilizzo sono illustrate qui:

```bash
SYNOPSIS
     rpcinfo [-m | -s] [host]
     rpcinfo -p [host]
     rpcinfo -T transport host prognum [versnum]
     rpcinfo -l [-T transport] host prognum versnum
     rpcinfo [-n portnum] -u host prognum [versnum]
     rpcinfo [-n portnum] [-t] host prognum [versnum]
     rpcinfo -a serv_address -T transport prognum [versnum]
     rpcinfo -b [-T transport] prognum versnum
     rpcinfo -d [-T transport] prognum versnum
```

#### Per avviare NFS

1. Assicurarsi di aver effettuato l'accesso al sistema come utente con privilegi di amministrazione.

2. Iniziare installando il pacchetto `nfs-utils`. Questo pacchetto fornisce varie utilità da utilizzare con i client e server NFS. Digitate:

    ```bash
    dnf -y install nfs-utils
    ```

3. Tra le altre cose, il pacchetto nfs-util appena installato fornisce anche l'unità di servizio systemd (`nfs-server.service`), necessaria per gestire il daemon NFS sul sistema. Utilizzare `systemctl` per visualizzare alcuni dei servizi ausiliari che l'unità nfs-server "Vuole". Digitare:

    ```bash
     systemctl show  -p "Wants"  nfs-server
    ```
    **RISULTATO**
    ```bash
    Wants=nfs-idmapd.service nfsdcld.service rpcbind.socket rpc-statd-notify.service rpc-statd.service auth-rpcgss-module.service network-online.target
    ```

    Alcuni servizi importanti e degni di nota necessari a nfs-server sono `nfs-idmapd`, `nfsdcld`, `rpcbind`, `rpc-statd-notify`, `rpc-statd`, `aut-rpcgss-module`.

4. Il comando `rpcinfo` è usato per effettuare chiamate RPC a un server RPC e poi riportare i risultati. `rpcinfo` elenca tutti i servizi RPC registrati con `rpcbind`. Utilizzare `rpcinfo` per interrogare il server locale e ottenere un elenco di tutti i servizi RPC registrati. Digitare:

    ```bash
    rpcinfo -p localhost
    ```

    **RISULTATO**
    ```bash
    program vers proto   port  service
    100000    4   tcp    111  portmapper
    100000    3   tcp    111  portmapper
    100000    2   tcp    111  portmapper
    100000    4   udp    111  portmapper
    ```

    Dall'output di esempio sopra riportato, si può notare che un servizio `portmapper` è registrato sul server RPC in esecuzione su localhost.

    !!! Question "Domanda"

     A) Cos'è portmapper? 
     B) Avete scoperto il significato dei vari campi (intestazione della colonna) del comando 'rpcinfo'? (Program, Vers, proto, and service.)

5. Controlla lo stato di `nfs-server.service`. Digitare:

    ```bash
    systemctl status nfs-server
    ```
   **RISULTATO**
   ```bash
    ● nfs-server.service - NFS server and services
    Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; disabled; vendor preset: disabled)
    Active: inactive (dead)
    ```
    nfs-server.service non è attualmente in esecuzione, secondo l'output del nostro sistema demo.

6. Utilizzare systemctl per avviare il daemon nfs-server. Digitare:

    ```bash
    systemctl start nfs-server
    ```

7. Ricontrollare lo stato del servizio nfs-server.

8. Eseguire nuovamente il comando `rpcinfo` per verificare se qualcosa è cambiato.

    !!! Question "Domanda"
   
        Quali nuovi servizi sono elencati nell'output di `rpcinfo` dopo aver avviato nfs-server?

9. Verificare che `nfs-server.service` sia impostato per avviarsi automaticamente a ogni riavvio del sistema. Digitare:

    ```bash
    systemctl is-enabled nfs-server
    ```

10. Se il server nfs è disabilitato sul sistema, eseguire il comando per configurarlo per l'avvio automatico con il sistema.

11. Se il sottosistema firewall è in esecuzione sul server, è necessario consentire/permettere il traffico NFS attraverso il firewall per i client NFS remoti. Questo può essere fatto eseguendo:

    ```bash
    firewall-cmd --permanent --add-service nfs && firewall-cmd --reload
    ```

## Esercizio 2

### Esportare le Condivisioni

La creazione di una condivisione avviene creando una directory o condividendo una directory già esistente sul file system locale.

L'utilità `exportfs` è utilizzata per visualizzare e mantenere la tabella dei file system NFS esportati. La sintassi e le opzioni di utilizzo sono:

```bash
SYNOPSIS
       /usr/sbin/exportfs [-avi] [-o options,..] [client:/path ..]
       /usr/sbin/exportfs -r [-v]
       /usr/sbin/exportfs [-av] -u [client:/path ..]
       /usr/sbin/exportfs [-v]
       /usr/sbin/exportfs -f
       /usr/sbin/exportfs -s
```

!!! note "Nota"

    Non dimenticarsi di sostituire tutti i riferimenti a server<PR> con il nome host effettivo del partner.

#### Per creare ed esportare una condivisione

Verrà creata e condivisa una directory chiamata `/mnt/nfs`. Questa directory sarà il file system di origine esportato dal server NFS.

1. Assicurarsi di aver effettuato l'accesso al sistema come utente con privilegi amministrativi.

2. Creare una directory in `/mnt` chiamata `nfs` e passare a quella directory.

    ```bash
    mkdir /mnt/nfs && cd /mnt/nfs
    ```

3. Creare 5 file di esempio nella nuova directory creata. Digitare:

    ```bash
     touch {1..5}nfs
    ```

4. Utilizzare la funzione della shell HEREDOC per creare una nuova voce di esportazione NFS in `/etc/exports`. La voce a riga singola desiderata è - `/mnt/nfs  foocentos2(rw)  localhost(rw)`. Digitare:

    ```bash
    cat << EOF > /etc/exports
    /mnt/nfs    172.16.99.0/24(rw)   localhost(rw)
    EOF
    ```
    Per creare la voce si può anche utilizzare un qualsiasi editor di testo con cui si ha familiarità.

5. Verificare il contenuto di `/etc/exports` per assicurarsi che non ci siano errori.

6. Dopo aver apportato qualsiasi modifica al file `/etc/exports` è necessario eseguire il comando `exportfs`. Digitare:

    ```bash
    exportfs -r
    ```

7. Utilizzare l'opzione `-s` con il comando `exportfs` per visualizzare l'elenco di esportazione corrente adatto per `/etc/exports`. Ad esempio, visualizzare l'elenco delle directory, degli host consentiti e delle opzioni. Digitare:

    ```bash
    exportfs -s
    ```

    Elencate di seguito i risultati ottenuti.

## Esercizio 3

### Montare le condivisioni NFS

Questo esercizio tratta il lato client di NFS. Si proverà ad accedere al server NFS come client.

`showmount` è una comoda utility per interrogare e mostrare le informazioni di montaggio sui server NFS. Può anche mostrare lo stato del server NFS ed elencare i client che stanno montando dal server. La sintassi e le opzioni sono mostrate qui:

```bash
SYNOPSIS
       showmount [ -adehv ] [ --all ] [ --directories ] [ --exports ] [ --help ] [ --version ] [ host ]

OPTIONS
       -a or --all
              List  both  the  client  hostname or IP address and mounted directory in host:dir format.
       -d or --directories
              List only the directories mounted by some client.
       -e or --exports
              Show the NFS server's export list.
       -h or --help
              Provide a short help summary.
       -v or --version
              Report the current version number of the program.
       --no-headers
              Suppress the descriptive headings from the output.
```

#### Accedere localmente a una condivisione NFS

Verrà testata la configurazione del server NFS da *Esercizio 1* provando ad accedere alla directory esportata dalla macchina locale, prima di testarla da una macchina remota.

1. Mentre si è connessi come superutente, creare una directory chiamata `/mnt/nfs-local`. Questa directory servirà come punto di montaggio di prova per la condivisione NFS.

2. Come rapido controllo preliminare, eseguire `showmount` come client per mostrare l'elenco delle esportazioni disponibili sul server. Digitare:

    ```bash
    showmount  -e localhost
    ```
    **RISULTATO**
    ```
    Export list for localhost:
    /mnt/nfs 172.16.99.0/24,localhost
    ```

    Si dovrebbero vedere le esportazioni NFS configurate sul server.

3. Ora si è pronti a montare la condivisione NFS nel punto di montaggio di prova. Digitare:

    ```bash
    mount  -t  nfs  localhost:/mnt/nfs   /mnt/nfs-local
    ```

4. Cambiare la propria PWD nella directory `/mnt/nfs-local` ed elencarne il contenuto.

5. Mentre ci si trova ancora nella directory `/mnt/nfs-local`, provare a cancellare alcuni file. Digitare:

    ```bash
    rm -rf 1nfs  2nfs
    ```
    **RISULTATO**
    ```bash
    rm: cannot remove '1nfs': Permission denied
    rm: cannot remove '2nfs': Permission denied
    ```

    !!! Question "Domanda"

     Il tentativo di eliminazione dei file è riuscito?

7. Ora provare a creare altri file (6nfs, 7nfs, 8nfs) sulla condivisione NFS. Digitare:

    ```bash
    touch {6..8}nfs
    ```

    !!! Question "Domanda"

     Il tentativo di creazione del file è andato a buon fine? Perché pensi che sia fallito?


ESEGUIRE L'ESERCIZIO DAL SISTEMA PARTNER

#### Per accedere da remoto a una condivisione NFS

1. Mentre si è connessi al serverPR come superutente, installare il pacchetto `nfs-utils` se non è installato.

2. Creare una directory chiamata "`/mnt/nfs-remote`" che servirà come punto di montaggio per la condivisione NFS remota. Digitare:

    ```bash
    mkdir   /mnt/nfs-remote
    ```

3. Supponendo che l'indirizzo IP del server remotoXY sia 172.16.99.100, montate la condivisione NFS sul serverXY eseguendo:

    ```bash
    mount -t nfs  172.16.99.100:/mnt/nfs  /mnt/nfs-remote
    ```

4. Utilizzare il comando `mount` per visualizzare alcune informazioni aggiuntive sulla condivisione NFS appena montata. Digitare:

    ```bash
     mount -t nfs4
    ```
    **RISULTATO**
    ```bash
    172.16.99.100:/mnt/nfs on /mnt/nfs-remote type nfs4 (rw,relatime,vers=4.2,rsize=1048576,wsize=1048576,namlen=255
    ...<SNIP>...
    ```

5. `cd` al punto di montaggio NFS e provare a cancellarne il contenuto. Digitare:

    ```bash
    cd /mnt/nfs-remote ; rm -f   
    ```

    Il vostro tentativo è andato a buon fine?

6. Uscire dal serverPR come superutente e rientrare come utente non privilegiato "ying"

7. Mentre si accede al serverPR con il nome di "ying", si fa il cd della directory montata al punto 2. Digitare:

    ```bash
    cd /mnt/nfs-remote/
    ```

8. Prendete nota del contenuto della directory. Se si vedono i file previsti, il laboratorio NFS è stato completato con successo!

    !!! question "Domande"
   
        1. Impostare la configurazione NFS sul server locale (serverXY), in modo tale che il superutente del server H.Q. (hq.example.org) sarà in grado di montare la condivisione nfs (/mnt/nfsXY) per utilizzarla sulla macchina hq.
       
        2. Il superutente di HQ deve essere in grado di scrivere (creare) nuovi file e cancellare i file sulla condivisione NFS.

    !!! Tip "Suggerimento"
   
        È necessario disabilitare il trattamento speciale di NFS per i file di proprietà di root. Questo si ottiene specificando un'opzione speciale che "svincola" il superutente nel file "/etc/exports". L'opzione speciale è chiamata `no_root_squash`. Si noti che l'uso dell'opzione `no_root_squash` è considerata una cattiva pratica e un rischio per la sicurezza. Una voce di esempio per ottenere questo risultato per qualsiasi host che corrisponda a `localhost` in `/etc/exports` avrà l'aspetto seguente:

        ```bash
        /mnt/nfs    172.16.99.0/24(rw)   localhost(rw,no_root_squash)
        ```

