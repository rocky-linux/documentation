---
title: 7 Opzioni di Configurazione del Container
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd configuration
---

# Capitolo 7: Opzioni di configurazione del container

Nel corso di questo capitolo sarà necessario eseguire i comandi come utente non privilegiato ("lxdadmin" se si segue dall'inizio di questo libro).

Esistono numerose opzioni per configurare il container dopo l'installazione. Prima di vederli, però, esaminiamo il comando `info` per un container. In questo esempio, si utilizzerà il container ubuntu-test:

```
lxc info ubuntu-test
```

Verrà visualizzato quanto segue:

```
Name: ubuntu-test
Location: none
Remote: unix://
Architecture: x86_64
Created: 2021/04/26 15:14 UTC
Status: Running
Type: container
Profiles: default, macvlan
Pid: 584710
Ips:
  eth0:    inet    192.168.1.201    enp3s0
  eth0:    inet6    fe80::216:3eff:fe10:6d6d    enp3s0
  lo:    inet    127.0.0.1
  lo:    inet6    ::1
Resources:
  Processes: 13
  Disk usage:
    root: 85.30MB
  CPU usage:
    CPU usage (in seconds): 1
  Memory usage:
    Memory (current): 99.16MB
    Memory (peak): 110.90MB
  Network usage:
    eth0:
      Bytes received: 53.56kB
      Bytes sent: 2.66kB
      Packets received: 876
      Packets sent: 36
    lo:
      Bytes received: 0B
      Bytes sent: 0B
      Packets received: 0
      Packets sent: 0
```

Ci sono molte informazioni utili, dai profili applicati, alla memoria in uso, allo spazio su disco in uso e altro ancora.

### Una parola sulla configurazione e su alcune opzioni

Per impostazione predefinita, LXD assegna al container la memoria di sistema, lo spazio su disco, i core della CPU e altre risorse necessarie. Ma se si vuole essere più specifici? È assolutamente possibile.

Tuttavia, questo comporta degli svantaggi. Per esempio, se si assegna la memoria di sistema e il container non la usa tutta, la si sottrae a un altro container che potrebbe averne bisogno. Tuttavia, può accadere anche il contrario. Se un container vuole usare più della sua quota di memoria, può impedire agli altri container di averne a sufficienza, riducendo così le loro prestazioni.

Ricordate che ogni azione compiuta per configurare un contenitore _può_ avere effetti negativi da qualche altra parte.

Piuttosto che scorrere tutte le opzioni di configurazione, utilizzare il completamento automatico delle schede per visualizzare le opzioni disponibili:

```
lxc config set ubuntu-test
```

e <kbd>TAB</kbd>.

Mostra tutte le opzioni per la configurazione di un container. Se avete domande su cosa fa una delle opzioni di configurazione, consultate la [documentazione ufficiale di LXD](https://linuxcontainers.org/lxd/docs/master/instances/) e fate una ricerca per il parametro di configurazione, oppure cercate su Google l'intera stringa, ad esempio "lxc config set limits.memory" ed esaminate i risultati della ricerca.

Di seguito esaminiamo alcune delle opzioni di configurazione più utilizzate. Ad esempio, se si vuole impostare la quantità massima di memoria che un container può utilizzare:

```
lxc config set ubuntu-test limits.memory 2GB
```

Questo dice che se la memoria è disponibile per l'uso, ad esempio se ci sono 2 GB di memoria disponibile, il container può effettivamente usare più di 2 GB se è disponibile. Si tratta di un limite morbido, ad esempio.

```
lxc config set ubuntu-test limits.memory.enforce 2GB
```

Ciò significa che il container non può mai utilizzare più di 2 GB di memoria, indipendentemente dal fatto che sia attualmente disponibile o meno. In questo caso si tratta di un limite rigido.

```
lxc config set ubuntu-test limits.cpu 2
```

Questo dice di limitare a 2 il numero di core della CPU che il container può utilizzare.

!!! note "Nota"

    Quando questo documento è stato riscritto per Rocky Linux 9.0, il repository ZFS per il 9 non era disponibile. Per questo motivo tutti i nostri contenitori di prova sono stati costruiti usando "dir" nel processo di init. Per questo motivo l'esempio seguente mostra un pool di archiviazione "dir" invece di "zfs".

Ricordate quando avete impostato il nostro pool di archiviazione nel capitolo ZFS? Il pool è stato chiamato "storage", ma avrebbe potuto essere chiamato in qualsiasi modo. Se si desidera esaminarlo, si può usare questo comando, che funziona ugualmente bene anche per gli altri tipi di pool (come mostrato per dir):

```
lxc storage show storage
```


Questo mostra quanto segue:

```
config:
  source: /var/snap/lxd/common/lxd/storage-pools/storage
description: ""
name: storage
driver: dir
used_by:
- /1.0/instances/rockylinux-test-8
- /1.0/instances/rockylinux-test-9
- /1.0/instances/ubuntu-test
- /1.0/profiles/default
status: Created
locations:
- none
```

Questo mostra che tutti i container utilizzano il pool di archiviazione dir. Quando si usa ZFS, si può anche impostare una quota disco su un container. Ecco come appare il comando, che imposta una quota disco di 2 GB sul container ubuntu-test:

```
lxc config device override ubuntu-test root size=2GB
```

Come detto in precedenza, usare le opzioni di configurazione con parsimonia, a meno che non si abbia un container che vuole usare molto più della sua quota di risorse. LXD, nella maggior parte dei casi, gestisce l'ambiente in modo autonomo.

Esistono molte altre opzioni che potrebbero essere di interesse per alcuni. La ricerca personale vi aiuterà a scoprire se uno di questi elementi è utile nel vostro ambiente.

