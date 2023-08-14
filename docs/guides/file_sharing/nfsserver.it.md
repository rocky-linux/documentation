---
title: Network File System
author: Antoine Le Morvan
contributors: Steven Spencer, Serge
---

# Network File System

**Conoscenza**: :star: :star:  
**Complessità**: :star: :star:

**Tempo di lettura**: 15 minuti

**N**etwork **F**ile **S**ystem (**NFS**) è un sistema di condivisione di file montato in rete.

## Generalità

NFS è un protocollo client/server: il server fornisce le risorse del file system per tutta o parte della rete (clients).

La comunicazione tra i client e il server avviene mediante il sevizio  **R**emote **P**rocedure **C**all (**RPC**).

I file remoti vengono montati in una directory e appaiono come un file system locale. Gli utenti client accedono senza problemi ai file condivisi dal server, sfogliando le directory come se fossero locali.

## Installazione

Per funzionare, NFS richiede due servizi:

* Il servizio `network` (ovviamente)
* Il servizio `rpcbind`

Visualizzare lo stato dei servizi con il comando:

```
systemctl status rpcbind
```

Se il pacchetto `nfs-utils` non è installato:

```
sudo dnf install nfs-utils
```

Il pacchetto `nfs-utils` richiede l'installazione di diverse dipendenze, tra cui `rpcbind`.

Avviare il servizio NFS con:

```
sudo systemctl enable --now nfs-server rpcbind
```

L'installazione del servizio NFS crea due utenti:

* `nobody`: usato per le connessioni anonime
* `rpcuser`: per il funzionamento del protocollo RPC

È necessario configurare il firewall:

```
sudo firewall-cmd --add-service={nfs,nfs3,mountd,rpc-bind} --permanent 
sudo firewall-cmd --reload
```

## Configurazione del server

!!! warning "Attenzione"

    I diritti delle directory e i diritti NFS devono essere coerenti.

### Il file `/etc/exports`

Impostare le condivisioni delle risorse con il file `/etc/exports`. Ogni riga di questo file corrisponde a una condivisione NFS.

```
/share_name client1(permissions) client2(permissions)
```

* **/share_name**: Percorso assoluto della directory condivisa
* **clients**: Clienti autorizzati ad accedere alle risorse
* **(permissions)**: Permessi sulle risorse

Dichiarare le macchine autorizzate ad accedere alle risorse con:

* **Indirizzo IP**: `192.168.1.2`
* **Indirizzo di Rete**: `192.168.1.0/255.255.255.0` o formato CIDR `192.168.1.0/24`
* **FQDN**: client_*.rockylinux.org: consente gli FQDN che iniziano con client_ dal dominio rockylinux.org
* `*` per tutti

È possibile inserire più impostazioni del client sulla stessa riga, separate da uno spazio.

### Permessi sulle risorse

Esistono due tipi di permessi:

* `ro`: di sola lettura
* `rw`: lettura-scrittura

Se non viene specificato alcun diritto, il permesso applicato sarà di sola lettura.

Per impostazione predefinita, il server NFS conserva gli UID e i GID degli utenti client (tranne che per `root`).

Per forzare l'uso di un UID o GID diverso da quello dell'utente che scrive sulla risorsa, specificare le opzioni `anonuid=UID` e `nongid=GID`, oppure concedere l'accesso `anonimo` ai dati con l'opzione `all_squash`.

!!! warning "Attenzione" 

    Un parametro, `no_root_squash`, identifica l'utente root del client come utente root del server. Questo parametro può essere pericoloso dal punto di vista della sicurezza del sistema.

L'attivazione del parametro `root_squash` è predefinita (anche se non specificata) e identifica `root` come un utente `anonymous`.

### Casi di studio

* `/share client(ro,all_squash)` Gli utenti client hanno accesso alle risorse in sola lettura e sono identificati come anonimi sul server.

* `/share client(rw)` Gli utenti client possono modificare le risorse e mantenere il proprio UID sul server. Solo `root` è identificato come `anonymous`.

* `/share client1(rw) client2(ro)` Gli utenti della workstation client 1 possono modificare le risorse, mentre quelli della workstation client 2 hanno accesso in sola lettura. Gli UID sono conservati sul server e solo `root` è identificato come `anonymous`.

* `/share client(rw,all_squash,anonuid=1001,anongid=100)` Gli utenti del Client1 possono modificare le risorse. L'UID viene modificato in `1001` e il GID in `100` sul server.

### Il comando `exportfs`

Il comando `exportfs` (file system exported) è usato per gestire la tabella dei file locali condivisi con i client NFS.

```
exportfs [-a] [-r] [-u share_name] [-v]
```

| Opzioni         | Descrizione                                     |
| --------------- | ----------------------------------------------- |
| `-a`            | Abilita le condivisioni NFS                     |
| `-r`            | Applica le condivisioni dal file `/etc/exports` |
| `-u share_name` | Disabilita una determinata condivisione         |
| `-v`            | Visualizza l'elenco delle condivisioni          |

### Il comando `showmount`

Il comando `showmount` monitora i client.

```
showmount [-a] [-e] [host]
```

| Opzioni | Descrizione                                          |
| ------- | ---------------------------------------------------- |
| `-e`    | Visualizza le condivisioni sul server designato      |
| `-a`    | Visualizza tutte le condivisioni correnti sul server |

Questo comando determina anche se la workstation client è autorizzata a montare le risorse condivise.

!!! note "Nota"

    `showmount` ordina e nasconde i duplicati nei risultati, quindi è impossibile determinare se un client ha effettuato più montaggi della stessa directory o meno.

## Configurazione del client

Le risorse condivise su un server NFS sono accessibili attraverso un punto di montaggio sul client.

Se necessario, creare una cartella locale per il montaggio:

```
$ sudo mkdir /mnt/nfs
```

Elenca le condivisioni NFS disponibili sul server:

```
$ showmount –e 172.16.1.10
/share *
```

Montare la condivisione NFS del server:

```
$ mount –t nfs 172.16.1.10:/share /mnt/nfs
```

L'automazione del montaggio può essere effettuata all'avvio del sistema con il file `/etc/fstab`:

```
$ sudo vim /etc/fstab
172.16.1.10:/share /mnt/nfs nfs defaults 0 0
```
