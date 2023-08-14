---
title: Clustering-GlusterFS
author: Antoine Le Morvan
contributors: Steven Spencer, Franco Colussi
update: 07-Feb-2022
---

# Cluster ad Alta Disponibilità con GlusterFS

## Prerequisiti

* Esperienza con un editor a riga di comando ( in questo esempio si usa _vi_)
* Un buon livello di confidenza con l'emissione di comandi dalla riga di comando, la visualizzazione dei log e altri compiti generali di amministratore di sistema
* Tutti i comandi sono eseguiti come utente root o sudo

## Introduzione

GlusterFS è un file system distribuito.

Consente di archiviare grandi quantità di dati distribuiti su cluster di server con una disponibilità molto elevata.

È composto da una parte server da installare su tutti i nodi dei cluster di server.

I client possono accedere ai dati tramite il client `glusterfs` o il comando `mount`.

GlusterFS può funzionare in due modalità:

  * modalità replicata: ogni nodo del cluster possiede tutti i dati.
  * modalità distribuita: nessuna ridondanza dei dati. Se uno storage si guasta, i dati sul nodo guasto vanno persi.

Entrambe le modalità possono essere utilizzate insieme per fornire un file system replicato e distribuito se si dispone del numero corretto di server.

I dati sono memorizzati all'interno dei blocchi.

> Un Blocco è l'unità di base dello storage in GlusterFS, rappresentato da una directory di esportazione su un server del pool di storage fidato.

## Piattaforma di Test

La nostra piattaforma fittizia comprende due server e un client, tutti server Rocky Linux.

* Primo nodo: node1.cluster.local - 192.168.1.10
* Secondo nodo: node2.cluster.local - 192.168.1.11
* Client1: client1.clients.local - 192.168.1.12

!!! Note "Nota"

    Assicuratevi di avere la larghezza di banda necessaria tra i server del cluster.

Ogni server del cluster dispone di un secondo disco per l'archiviazione dei dati.

## Preparazione dei dischi

Creeremo un nuovo volume logico LVM che verrà montato su `/data/glusterfs/vol0` su entrambi i server del cluster:

```
$ sudo pvcreate /dev/sdb
$ sudo vgcreate vg_data /dev/sdb
$ sudo lvcreate -l 100%FREE -n lv_data vg_data
$ sudo mkfs.xfs /dev/vg_data/lv_data
$ sudo mkdir -p /data/glusterfs/volume1
```

!!! Note "Nota"

    Se LVM non è disponibile sui vostri server, installatelo con il seguente comando:

    ```
    $ sudo dnf install lvm2
    ```

Ora possiamo aggiungere il volume logico al file `/etc/fstab`:

```
/dev/mapper/vg_data-lv_data /data/glusterfs/volume1        xfs     defaults        1 2
```

E montarlo:

```
$ sudo mount -a
```

Poiché i dati sono memorizzati in un sottovolume chiamato brick, è possibile creare una directory in questo nuovo spazio dati dedicata ad esso:

```
$ sudo mkdir /data/glusterfs/volume1/brick0
```

## Installazione

Al momento della stesura di questa documentazione, il repository originale CentOS Storage SIG non è più disponibile e il repository RockyLinux non è ancora disponibile.

Tuttavia, utilizzeremo (per il momento) la versione archiviata.

Prima di tutto, è necessario aggiungere il repository dedicato a gluster (nella versione 9) su entrambi i server:

```
sudo dnf install centos-release-gluster9
```

!!! Note "Nota"

    In seguito, quando sarà pronto sul sistema Rocky, potremo cambiare il nome di questo pacchetto.

Poiché l'elenco dei repo e l'url non sono più disponibili, cambiamo il contenuto di `/etc/yum.repos.d/CentOS-Gluster-9.repo`:

```
[centos-gluster9]
name=CentOS-$releasever - Gluster 9
#mirrorlist=http://mirrorlist.centos.org?arch=$basearch&release=$releasever&repo=storage-gluster-9
baseurl=https://dl.rockylinux.org/vault/centos/8.5.2111/storage/x86_64/gluster-9/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage
```

Ora siamo pronti a installare il server glusterfs:

```
$ sudo dnf install glusterfs glusterfs-libs glusterfs-server
```

## Regole del Firewall

Affinché il servizio funzioni sono necessarie alcune regole:

```
$ sudo firewall-cmd --zone=public --add-service=glusterfs --permanent
$ sudo firewall-cmd --reload
```

oppure:

```
$ sudo firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
$ sudo firewall-cmd --zone=public --add-port=49152/tcp --permanent
$ sudo firewall-cmd --reload
```

## Risoluzione dei Nomi

Si può lasciare che sia il DNS a gestire la risoluzione dei nomi dei server del cluster, oppure si può scegliere di alleggerire i server da questo compito inserendo dei record per ciascuno di essi nei file `/etc/hosts`. In questo modo, le cose continueranno a funzionare anche in caso si verifichi un'interruzione del DNS.

```
192.168.10.10 node1.cluster.local
192.168.10.11 node2.cluster.local
```

## Avviare il servizio

Senza ulteriori indugi, avviamo il servizio:

```
$ sudo systemctl enable glusterfsd.service glusterd.service
$ sudo systemctl start glusterfsd.service glusterd.service
```

Siamo pronti a unire i due nodi nello stesso pool.

Questo comando deve essere eseguito una sola volta su un singolo nodo (qui sul nodo1):

```
sudo gluster peer probe node2.cluster.local
peer probe: success
```

Verifica:

```
node1 $ sudo gluster peer status
Number of Peers: 1

Hostname: node2.cluster.local
Uuid: c4ff108d-0682-43b2-bc0c-311a0417fae2
State: Peer in Cluster (Connected)
Other names:
192.168.10.11

```

```
node2 $ sudo gluster peer status
Number of Peers: 1

Hostname: node1.cluster.local
Uuid: 6375e3c2-4f25-42de-bbb6-ab6a859bf55f
State: Peer in Cluster (Connected)
Other names:
192.168.10.10
```

Ora possiamo creare un volume con 2 repliche:

```
$ sudo gluster volume create volume1 replica 2 node1.cluster.local:/data/glusterfs/volume1/brick0/ node2.cluster.local:/data/glusterfs/volume1/brick0/
Replica 2 volumes are prone to split-brain. Use Arbiter or Replica 3 to avoid this. Vedere: https://docs.gluster.org/en/latest/Administrator-Guide/Split-brain-and-ways-to-deal-with-it/.
Do you still want to continue?
 (y/n) y
volume create: volume1: success: please start the volume to access data
```

!!! Note "Nota"

    Come dice il comando return, un cluster di 2 nodi non è la migliore idea al mondo contro lo split brain. Ma questo è sufficiente per la nostra piattaforma di prova.

Ora possiamo avviare il volume per accedere ai dati:

```
$ sudo gluster volume start volume1

volume start: volume1: success
```

Controllare lo stato del volume:

```
$ sudo gluster volume status
Status of volume: volume1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick node1.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1210
Brick node2.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1135
Self-heal Daemon on localhost               N/A       N/A        Y       1227
Self-heal Daemon on node2.cluster.local     N/A       N/A        Y       1152

Task Status of Volume volume1
------------------------------------------------------------------------------
There are no active volume tasks
```

```
$ sudo gluster volume info

Volume Name: volume1
Type: Replicate
Volume ID: f51ca783-e815-4474-b256-3444af2c40c4
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 2 = 2
Transport-type: tcp
Bricks:
Brick1: node1.cluster.local:/data/glusterfs/volume1/brick0
Brick2: node2.cluster.local:/data/glusterfs/volume1/brick0
Options Reconfigured:
cluster.granular-entry-heal: on
storage.fips-mode-rchecksum: on
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
```

Lo stato deve essere " Started".

Possiamo già limitare un po' l'accesso al volume:

```
$ sudo gluster volume set volume1 auth.allow 192.168.10.*
```

È molto semplice.

## Accesso client

Esistono diversi modi per accedere ai nostri dati da un client.

Il metodo preferito:

```
$ sudo dnf install glusterfs-client
$ sudo mkdir /data
$ sudo mount.glusterfs node1.cluster.local:/volume1 /data
```

Non ci sono repository aggiuntivi da configurare. Il client è già presente nei repo di base.

Creare un file e verificare che sia presente su tutti i nodi del cluster:

Sul client:

```
sudo touch /data/test
```

Su entrambe i server:

```
$ ll /data/glusterfs/volume1/brick0/
total 0
-rw-r--r--. 2 root root 0 Feb  3 19:21 test
```

Sembra buono! Ma cosa succede se il nodo 1 si guasta? È quello specificato al momento del montaggio dell'accesso remoto.

Fermiamo il nodo uno:

```
$ sudo shutdown -h now
```

Controlla lo stato sul nodo2:

```
$ sudo gluster peer status
Number of Peers: 1

Hostname: node1.cluster.local
Uuid: 6375e3c2-4f25-42de-bbb6-ab6a859bf55f
State: Peer in Cluster (Disconnected)
Other names:
192.168.10.10
[antoine@node2 ~]$ sudo gluster volume status
Status of volume: volume1
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick node2.cluster.local:/data/glusterfs/v
olume1/brick0                               49152     0          Y       1135
Self-heal Daemon on localhost               N/A       N/A        Y       1152

Task Status of Volume volume1
------------------------------------------------------------------------------
There are no active volume tasks
```

Il nodo1 non è presente.

E sul client:

```
$ ll /data/test
-rw-r--r--. 1 root root 0 Feb  4 16:41 /data/test
```

Il file è ancora presente.

Al momento della connessione, il client glusterfs riceve un elenco di nodi a cui può rivolgersi, il che spiega la commutazione trasparente a cui abbiamo appena assistito.

## Conclusioni

Anche se non ci sono repository attuali, l'uso dei repository archiviati che CentOS aveva per GlusterFS funzionerà ancora. Come già detto, GlusterFS è piuttosto facile da installare e mantenere. L'uso degli strumenti dalla riga di comando è un processo piuttosto semplice. GlusterFS aiuta a creare e mantenere cluster ad alta disponibilità per l'archiviazione e la ridondanza dei dati. Per ulteriori informazioni su GlusterFS e sull'utilizzo dello strumento, consultare le pagine della [documentazione ufficiale.](https://docs.gluster.org/en/latest/)
