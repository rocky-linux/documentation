---
author: Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova
title: Capitolo 7. High availability
tags:
  - clustering
  - ha
  - high availability
  - pcs
  - pacemaker
---

## Clustering su Linux

> **High availability** è un termine spesso usato in IT, in relazione all'architettura di un sistema o di un servizio, per indicare il fatto che questa architettura o questo servizio hanno un tasso di disponibilità adeguato. ~ wikipedia

Questa availability è una misura di prestazione espressa come percentuale ottenuta dal rapporto **tempo Operativo** / **tempo operativo totale desiderato**.

| Disponibilità | Downtime annuale           |
| ------------- | -------------------------- |
| 90%           | 876 ore                    |
| 95%           | 438 ore                    |
| 99%           | 87 ore e 36 minuti         |
| 99,9%         | 8 ore 45 minuti 36 secondi |
| 99,99%        | 52 minuti e 33 secondi     |
| 99,999%       | 5 minuti e 15 secondi      |
| 99,9999%      | 31,68 secondi              |

Per "High Availability" (**HA**) si intendono tutte le misure adottate per garantire la massima disponibilità possibile di un servizio, ossia il corretto funzionamento 24 ore al giorno.

### Panoramica

Un cluster è un “cluster di computer”, un gruppo di due o più macchine.

Un cluster consente:

- calcolo distribuito utilizzando la potenza di calcolo di tutti i nodi
- high availability: continuità del servizio e failover automatico del servizio in caso di guasto di un nodo

#### Tipi di servizi

- Servizi attivi/passivi

  L'installazione di un cluster con due nodi attivi/passivi utilizzando Pacemaker e DRBD è una soluzione a basso costo per molte situazioni che richiedono un sistema ad high-availability.

- Servizi N+1

  Con più nodi, Pacemaker può ridurre i costi dell'hardware consentendo a diversi cluster attivi/passivi di combinarsi e condividere un nodo di backup.

- Servizi N to N

  Con la shared storage, ogni nodo può potenzialmente essere utilizzato per la fault tolerance. Pacemaker può anche eseguire più copie di servizi per distribuire il carico di lavoro.

- Servizi in remoto

  Pacemaker include funzionalità per semplificare la creazione di cluster su più siti.

#### VIP

Il VIP è un indirizzo IP virtuale assegnato a un cluster attivo/passivo. Assegnare il VIP a un nodo cluster attivo. Se si verifica un'interruzione del servizio, il VIP viene disattivato sul nodo guasto, mentre l'attivazione avviene sul nodo che lo sostituisce. Questo è noto come failover.

I client si rivolgono sempre al cluster tramite VIP, rendendo trasparenti i failover dei server attivi.

#### Split-brain

Lo split-brain è il rischio principale che un cluster può incontrare. Questa condizione si verifica quando diversi nodi di un cluster pensano che il loro vicino sia inattivo. Il nodo tenta quindi di avviare il servizio ridondante e diversi nodi forniscono lo stesso servizio, il che può portare a fastidiosi effetti collaterali (VIP duplicati sulla rete, accesso ai dati in competizione e così via).

Le possibili soluzioni tecniche per evitare questo problema sono:

- Separare il traffico della rete pubblica da quello del cluster
- Utilizzare network bonding

## Pacemaker (PCS)

In questo capitolo viene illustrato Pacemaker, una soluzione di clustering.

****

**Obiettivi**: si imparerà come:

:heavy_check_mark: installare e configurare un cluster Pacemaker;\
:heavy_check_mark: amministrare un cluster Pacemaker.

:checkered_flag: **clustering**, **ha**, **high availability**, **pcs**, **pacemaker**

**Conoscenza**: :star: :star: :star:\
**Complessità**: :star: :star:

**Tempo di lettura**: 20 minuti

****

### Generalità

**Pacemaker** è la parte software del cluster che gestisce le sue risorse (VIP, servizi, dati). È responsabile dell'avvio, dell'arresto e della supervisione delle risorse del cluster. Si assicura che i nodi operino in high availability.

Pacemaker utilizza il message layer fornito da **corosync** (predefinito) o **Heartbeat**.

Pacemaker consiste in **5 componenti chiave**:

- Cluster Information Base (**CIB**)
- Cluster Resource Management daemon (**CRMd**)
- Local Resource Management daemon (**LRMd**)
- Policy Engine (**PEngine** or **PE**)
- Fencing daemon (**STONITHd**)

La CIB rappresenta la configurazione del cluster e lo stato attuale di tutte le risorse del cluster. I suoi contenuti vengono sincronizzati automaticamente in tutto il cluster e utilizzati dal PEngine per calcolare come raggiungere lo stato ideale del cluster.

L'elenco delle istruzioni viene quindi fornito al controllore designato (DC). Pacemaker centralizza tutte le decisioni del cluster eleggendo una delle istanze di CRMd come master.

Il DC esegue le istruzioni della PEngine nell'ordine richiesto, trasmettendole all'LRMd locale o al CRMd degli altri nodi tramite Corosync o Heartbeat.

A volte può essere necessario arrestare i nodi per proteggere i dati condivisi o consentire il ripristino. A questo scopo, il pacemaker è dotato di STONITHd.

#### Stonith

Stonith è un componente di Pacemaker. È l'acronimo di Shoot-The-Other-Node-In-The-Head, una pratica consigliata per garantire l'isolamento del nodo malfunzionante il più rapidamente possibile (chiusura o almeno disconnessione dalle risorse condivise), evitando così la corruzione dei dati.

Un nodo che non risponde non significa che non possa più accedere ai dati. L'unico modo per assicurarsi che un nodo non stia più accedendo ai dati prima di cederli a un altro nodo è usare STONITH, che spegnerà o riavvierà il server guasto.

STONITH ha un ruolo anche nel caso in cui un servizio in cluster non riesca a spegnersi. In questo caso, Pacemaker utilizza STONITH per forzare l'arresto dell'intero nodo.

#### Gestione del quorum

Il quorum rappresenta il numero minimo di nodi in funzione per convalidare una decisione, come ad esempio decidere quale nodo di backup deve subentrare quando uno dei nodi è in errore. Per impostazione predefinita, Pacemaker richiede che più della metà dei nodi sia online.

Quando i problemi di comunicazione dividono un cluster in diversi nodi del gruppo, il quorum impedisce l'avvio delle risorse su un numero di nodi superiore a quello previsto. Un cluster è quorum quando più della metà di tutti i nodi noti per essere online sono nel suo gruppo (active_nodes_group > active_total_nodes / 2 ).

Quando non si raggiunge il quorum, la decisione predefinita è quella di disattivare tutte le risorse.

Casi studio:

- In un cluster a **due nodi**, poiché il raggiungimento del quorum **non è possibile**, il guasto di un nodo deve essere ignorato, altrimenti l'intero cluster verrà spento.
- Se un cluster di 5 nodi viene diviso in due gruppi di 3 e 2 nodi, il gruppo di 3 nodi avrà un quorum e continuerà a gestire le risorse.
- Se un cluster di 6 nodi viene diviso in 2 gruppi di 3 nodi, nessun gruppo avrà un quorum. In questo caso, il comportamento predefinito del pacemaker è quello di arrestare tutte le risorse per evitare la corruzione dei dati.

#### Gestione comunicazioni del cluster

Un Pacemaker utilizza **Corosync** o **Heartbeat** (dal progetto Linux-ha) per la comunicazione tra nodi e la gestione del cluster.

##### Corosync

**Corosync Cluster Engine** è un layer di messaggistica tra i membri del cluster che integra funzionalità aggiuntive per implementare l'high availability nelle applicazioni. Corosync deriva dal progetto OpenAIS.

I nodi comunicano in modalità client/server con il protocollo UDP.

Può gestire cluster con più di 16 modalità attive/passiva o attiva/attiva.

##### Heartbeat

La tecnologia Heartbeat è più limitata rispetto a Corosync. È impossibile creare un cluster di più di due nodi e le sue regole di gestione sono meno sofisticate di quelle del suo concorrente.

!!! NOTE "Nota"

```
La scelta di pacemaker/corosync sembra oggi più appropriata, poiché è la scelta predefinita per le distribuzioni RedHat, Debian e Ubuntu.
```

#### Gestione dei dati

##### Il raid DRDB network

DRDB è un driver di periferica block-type che consente l'implementazione di RAID 1 (mirroring) sulla rete.

DRDB può essere utile quando le tecnologie NAS o SAN non sono disponibili, ma è necessaria la sincronizzazione dei dati.

### Installazione

Per installare Pacemaker, occorre innanzitutto abilitare il repository `highavailability`:

```bash
sudo dnf config-manager --set-enabled highavailability
```

Alcune informazioni sul pacchetto pacemaker:

```bash
$ dnf info pacemaker
Rocky Linux 9 - High Availability                                                                                                                                     289 kB/s | 250 kB     00:00
Available Packages
Name         : pacemaker
Version      : 2.1.7
Release      : 5.el9_4
Architecture : x86_64
Size         : 465 k
Source       : pacemaker-2.1.7-5.el9_4.src.rpm
Repository   : highavailability
Summary      : Scalable High-Availability cluster resource manager
URL          : https://www.clusterlabs.org/
License      : GPL-2.0-or-later AND LGPL-2.1-or-later
Description  : Pacemaker is an advanced, scalable High-Availability cluster resource
             : manager.
             :
             : It supports more than 16 node clusters with significant capabilities
             : for managing resources and dependencies.
             :
             : It will run scripts at initialization, when machines go up or down,
             : when related resources fail and can be configured to periodically check
             : resource health.
             :
             : Available rpmbuild rebuild options:
             :   --with(out) : cibsecrets hardening nls pre_release profiling
             :                 stonithd
```

Utilizzando il comando `repoquery`, è possibile scoprire le dipendenze del pacchetto pacemaker:

```bash
$ repoquery --requires pacemaker
corosync >= 3.1.1
pacemaker-cli = 2.1.7-5.el9_4
resource-agents
systemd
...
```

Nell'installazione di Pacemaker sarà installato automaticamente corosync e un'interfaccia CLI per un pacemaker.

Alcune informazioni sul pacchetto corosync:

```bash
$ dnf info corosync
Available Packages
Name         : corosync
Version      : 3.1.8
Release      : 1.el9
Architecture : x86_64
Size         : 262 k
Source       : corosync-3.1.8-1.el9.src.rpm
Repository   : highavailability
Summary      : The Corosync Cluster Engine and Application Programming Interfaces
URL          : http://corosync.github.io/corosync/
License      : BSD
Description  : This package contains the Corosync Cluster Engine Executive, several default
             : APIs and libraries, default configuration files, and an init script.
```

Installare ora i pacchetti necessari:

```bash
sudo dnf install pacemaker
```

Aprire il firewall, se ne avete uno:

```bash
sudo firewall-cmd --permanent --add-service=high-availability
sudo firewall-cmd --reload
```

!!! NOTE "Nota"

```
Non avviare ora i servizi, poiché non sono configurati e non funzioneranno.
```

### Gestione del cluster

Il package `pcs` fornisce gli strumenti di gestione del cluster. Il comando `pcs` è un'interfaccia a riga di comando per la gestione del **Pacemaker high availability stack**.

La configurazione del cluster può essere fatta a mano, ma il pacchetto pcs rende la gestione (creazione, configurazione e risoluzione dei problemi) di un cluster molto più semplice!

!!! NOTE "Nota"

```
Ci sono altre alternative a pcs.
```

Installare il pacchetto su tutti i nodi e attivare il daemon pcsd:

```bash
sudo dnf install pcs
sudo systemctl enable pcsd --now
```

L'installazione del pacchetto ha creato un utente `hacluster` con una password vuota. Per eseguire operazioni come la sincronizzazione dei file di configurazione di corosync o il riavvio dei nodi remoti. È necessario assegnare una password a questo utente.

```text
hacluster:x:189:189:cluster user:/var/lib/pacemaker:/sbin/nologin
```

Su tutti i nodi, assegnare una password identica all'utente hacluster:

```bash
echo “pwdhacluster” | sudo passwd --stdin hacluster
```

!!! NOTE "Nota"

```
“pwdhacluster” è di esempio, sostituirla con una password più sicura.
```

Da qualsiasi nodo, è possibile autenticarsi come utente hacluster su tutti i nodi e utilizzare i comandi `pcs` su di essi:

```bash
$ sudo pcs host auth server1 server2
Username: hacluster
Password:
server1: Authorized
server2: Authorized
```

Dal nodo in cui si verifica l'autenticazione di pcs, lanciare la configurazione del cluster:

```bash
$ sudo pcs cluster setup mycluster server1 server2
No addresses specified for host 'server1', using 'server1'
No addresses specified for host 'server2', using 'server2'
Destroying cluster on hosts: 'server1', 'server2'...
server2: Successfully destroyed cluster
server1: Successfully destroyed cluster
Requesting remove 'pcsd settings' from 'server1', 'server2'
server1: successful removal of the file 'pcsd settings'
server2: successful removal of the file 'pcsd settings'
Sending 'corosync authkey', 'pacemaker authkey' to 'server1', 'server2'
server1: successful distribution of the file 'corosync authkey'
server1: successful distribution of the file 'pacemaker authkey'
server2: successful distribution of the file 'corosync authkey'
server2: successful distribution of the file 'pacemaker authkey'
Sending 'corosync.conf' to 'server1', 'server2'
server1: successful distribution of the file 'corosync.conf'
server2: successful distribution of the file 'corosync.conf'
Cluster has been successfully set up.
```

!!! NOTE "Nota"

```
Il comando pcs cluster setup gestisce il problema del quorum per i cluster a due nodi. Un cluster di questo tipo funzionerà quindi correttamente in caso di guasto di uno dei due nodi. Se si configura Corosync manualmente o si usa un'altra shell di gestione del cluster, è necessario configurare Corosync correttamente.
```

Ora è possibile avviare il cluster:

```bash
$ sudo pcs cluster start --all
server1: Starting Cluster...
server2: Starting Cluster...
```

Abilitare l'avvio del servizio cluster all'avvio:

```bash
sudo pcs cluster enable --all
```

Controllare lo stato di servizio:

```bash
$ sudo pcs status
Cluster name: mycluster

WARNINGS:
No stonith devices and stonith-enabled is not false

Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  * Last updated: Mon Jul  8 17:50:14 2024 on server1
  * Last change:  Mon Jul  8 17:50:00 2024 by hacluster via hacluster on server1
  * 2 nodes configured
  * 0 resource instances configured

Node List:
  * Online: [ server1 server2 ]

Full List of Resources:
  * No resources

Daemon Status:
  corosync: active/disabled
  pacemaker: active/disabled
  pcsd: active/enabled
```

#### Aggiungere risorse

Prima di configurare le risorse, è necessario cofigurare il messaggio di alert:

```bash
WARNINGS:
No stonith devices and stonith-enabled is not false
```

In questo stato, Pacemaker si rifiuta di avviare le nuove risorse.

Si ha due possibili scelte:

- disabilitare `stonith`
- configurarlo

Per prima cosa, si disabilita `stonith` finché non si imparerà a configurarlo:

```bash
sudo pcs property set stonith-enabled=false
```

!!! WARNING "Attenzione"

```
Fare attenzione a non lasciare `stonith` disabilitato in un ambiente di produzione!
```

##### Configurazione VIP

La prima risorsa creata nel cluster è una VIP.

Elenca le risorse standard disponibili con il comando `pcs resource standards`:

```bash
$ pcs resource standards
lsb
ocf
service
systemd
```

Questo VIP corrisponde agli indirizzi IP dei clienti, in modo che possano accedere ai futuri servizi del cluster. È necessario assegnarlo a uno dei nodi. Quindi, in caso di guasto, il cluster passerà questa risorsa da un nodo all'altro per garantire la continuità del servizio.

```bash
pcs resource create myclusterVIP ocf:heartbeat:IPaddr2 ip=192.168.1.12 cidr_netmask=24 op monitor interval=30s
```

L'argomento `ocf:heartbeat:IPaddr2` contiene tre campi che forniscono a Pacemaker quanto segue:

- lo standard (in questo caso `ocf`)
- lo script namespace (in questo caso `heartbeat`)
- lo resource script name

Il risultato è l'aggiunta di un indirizzo IP virtuale all'elenco delle risorse gestite:

```bash
$ sudo pcs status
Cluster name: mycluster

...
Cluster name: mycluster
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  ...
  * 2 nodes configured
  * 1 resource instance configured

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
...
```

In questo caso, il VIP è attivo sul server1. È possibile effettuare una verifica con il comando `ip`:

```bash
$ ip add show dev enp0s3
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:df:29:09 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.10/24 brd 192.168.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.1.12/24 brd 192.168.1.255 scope global secondary enp0s3
       valid_lft forever preferred_lft forever
```

###### Toggle tests

Da qualsiasi punto della rete, eseguire il comando ping sul VIP:

```bash
ping 192.168.1.12
```

Mettere il nodo attivo in standby:

```bash
sudo pcs node standby server1
```

Controllare che tutti i ping abbiano successo durante l'operazione (nessun `icmp_seq` mancante):

```bash
64 bytes from 192.168.1.12: icmp_seq=39 ttl=64 time=0.419 ms
64 bytes from 192.168.1.12: icmp_seq=40 ttl=64 time=0.043 ms
64 bytes from 192.168.1.12: icmp_seq=41 ttl=64 time=0.129 ms
64 bytes from 192.168.1.12: icmp_seq=42 ttl=64 time=0.074 ms
64 bytes from 192.168.1.12: icmp_seq=43 ttl=64 time=0.099 ms
64 bytes from 192.168.1.12: icmp_seq=44 ttl=64 time=0.044 ms
64 bytes from 192.168.1.12: icmp_seq=45 ttl=64 time=0.021 ms
64 bytes from 192.168.1.12: icmp_seq=46 ttl=64 time=0.058 ms
```

Controllare lo stato del cluster:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
...
  * 2 nodes configured
  * 1 resource instance configured

Node List:
  * Node server1: standby
  * Online: [ server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server2
```

Il VIP si è spostato sul server2. Verificare con il comando `ip add` come in precedenza.

Riportare il server1 nel pool:

```bash
sudo pcs node unstandby server1
```

!!! Nota
Una volta che il server1 è stato `unstandby`, il cluster torna al suo stato normale, ma la risorsa non viene trasferita di nuovo al server1: rimane sul server2.

##### Configurazione del servizio

Si installerà il servizio Apache su entrambi i nodi del cluster. Questo servizio viene avviato solo sul nodo attivo e cambia nodo contemporaneamente al VIP se il nodo attivo si guasta.

Per istruzioni dettagliate sull'installazione, consultare il capitolo Apache.

È necessario installare `httpd` su entrambi i nodi:

```bash
sudo dnf install -y httpd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

!!! WARNING "Attenzione"

```
Non avviare o attivare il servizio da soli. Se ne occuperà il Pacemaker.
```

Di default, viene visualizzata una pagina HTML contenente il nome del server:

```bash
echo "<html><body>Node $(hostname -f)</body></html>" | sudo tee "/var/www/html/index.html"
```

L'agente di risorse Pacemaker utilizzerà la pagina `/server-status` (si veda il capitolo Apache) per determinare il suo stato di salute. È necessario attivarlo creando il file `/etc/httpd/conf.d/status.conf` su entrambi i server:

```bash
sudo vim /etc/httpd/conf.d/status.conf
<Location /server-status>
    SetHandler server-status
    Require local
</Location>
```

Per creare una risorsa, la si chiamerà “WebSite”; si chiamerà lo script Apache della risorsa OCF e nello spazio dei nomi heartbeat.

```bash
sudo pcs resource create WebSite ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf statusurl="http://localhost/server-status" op monitor interval=1min
```

Il cluster controllerà la salute di Apache ogni minuto (`op monitor interval=1min`).

Infine, per garantire che il servizio Apache venga avviato sullo stesso nodo dell'indirizzo VIP, è necessario aggiungere un vincolo al cluster:

```bash
sudo pcs constraint colocation add WebSite with myclusterVIP INFINITY
```

È anche possibile configurare il servizio Apache in modo che si avvii dopo il VIP. Questo può essere utile se Apache ha configurazioni VHost per ascoltare l'indirizzo VIP (`Listen 192.168.1.12`):

```bash
$ sudo pcs constraint order myclusterVIP then WebSite
Adding myclusterVIP WebSite (kind: Mandatory) (Options: first-action=start then-action=start)
```

###### Testare il failover

Eseguire un failover e verificare che il vostro server web sia ancora disponibile:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  ...

Node List:
  * Online: [ server1 server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
  * WebSite     (ocf:heartbeat:apache):  Started server1
```

Attualmente si sta lavorando sul server1.

```bash
$ curl http://192.168.1.12/
<html><body>Node server1</body></html>
```

Simulare un failover sul server1:

```bash
sudo pcs node standby server1
```

```bash
$ curl http://192.168.1.12/
<html><body>Node server2</body></html>
```

Come si può vedere, il servizio Web funziona ancora, ma ora è sul server2.

```bash
sudo pcs node unstandby server1
```

Si noti che il servizio è stato interrotto solo per pochi secondi, mentre il VIP passava al servizio e i servizi si riavviavano.

### Cluster troubleshooting

#### Il comando `pcs status`

Il comando `pcs status` fornisce informazioni sullo stato generale del cluster:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  * Last updated: Tue Jul  9 12:25:42 2024 on server1
  * Last change:  Tue Jul  9 12:10:55 2024 by root via root on server1
  * 2 nodes configured
  * 2 resource instances configured

Node List:
  * Online: [ server1 ]
  * OFFLINE: [ server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
  * WebSite     (ocf:heartbeat:apache):  Started server1

Daemon Status:
  corosync: active/enabled
  pacemaker: active/enabled
  pcsd: active/enabled
```

Come si può vedere, uno dei due server è offline.

#### Il comando `pcs status corosync`

Il comando `pcs status corosync` fornisce informazioni sullo stato dei nodi `corosync`:

```bash
$ sudo pcs status corosync

Membership information
----------------------
    Nodeid      Votes Name
         1          1 server1 (local)
```

e quando il server2 è tornato disponibile:

```bash
$ sudo pcs status corosync

Membership information
----------------------
    Nodeid      Votes Name
         1          1 server1 (local)
         2          1 server2
```

#### Il comando `crm_mon`

Il comando `crm_mon` restituisce informazioni sullo stato del cluster. Usare l'opzione \`-1' per visualizzare lo stato del cluster una volta e uscire.

```bash
$ sudo crm_mon -1
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  * Last updated: Tue Jul  9 12:30:21 2024 on server1
  * Last change:  Tue Jul  9 12:10:55 2024 by root via root on server1
  * 2 nodes configured
  * 2 resource instances configured

Node List:
  * Online: [ server1 server2 ]

Active Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
  * WebSite     (ocf:heartbeat:apache):  Started server1
```

#### Il comando `corosync-*cfgtool*`

Il comando `corosync-cfgtool` controlla che la configurazione sia corretta e che la comunicazione con il cluster funzioni correttamente:

```bash
$ sudo corosync-cfgtool -s
Local node ID 1, transport knet
LINK ID 0 udp
        addr    = 192.168.1.10
        status:
                nodeid:          1:     localhost
                nodeid:          2:     connected
```

Il comando \`corosync-cmapctl' è uno strumento per accedere al object database.
Ad esempio, si può usare per controllare lo stato dei nodi membri del cluster:

```bash
$ sudo corosync-cmapctl  | grep members
runtime.members.1.config_version (u64) = 0
runtime.members.1.ip (str) = r(0) ip(192.168.1.10)
runtime.members.1.join_count (u32) = 1
runtime.members.1.status (str) = joined
runtime.members.2.config_version (u64) = 0
runtime.members.2.ip (str) = r(0) ip(192.168.1.11)
runtime.members.2.join_count (u32) = 2
runtime.members.2.status (str) = joined
```

### Workshop

Per questo workshop sono necessari due server con i servizi Pacemaker installati, configurati e protetti, come descritto nei capitoli precedenti.

Si configurerà un cluster Apache ad alta disponibilità.

I due server hanno i seguenti indirizzi IP:

- server1: 192.168.1.10
- server2: 192.168.1.11

Se non si dispone di un servizio di risoluzione dei nomi, inserire nel file `/etc/hosts` un contenuto simile al seguente:

```bash
$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

192.168.1.10 server1 server1.rockylinux.lan
192.168.1.11 server2 server2.rockylinux.lan
```

Si utilizzerà l'indirizzo VIP `192.168.1.12`.

#### Task 1: Installazione e configurazione

Per installare Pacemaker, abilitare il repository `highavailability`.

Su entrambi i nodi eseguire:

```bash
sudo dnf config-manager --set-enabled highavailability
sudo dnf install pacemaker pcs
sudo firewall-cmd --permanent --add-service=high-availability
sudo firewall-cmd --reload
sudo systemctl enable pcsd --now
echo "pwdhacluster" | sudo passwd --stdin hacluster
```

Sul server1 eseguire:

```bash
sudo dnf config-manager --set-enabled highavailability
sudo dnf install pacemaker pcs
sudo firewall-cmd --permanent --add-service=high-availability
sudo firewall-cmd --reload
sudo systemctl enable pcsd --now
echo "pwdhacluster" | sudo passwd --stdin hacluster
```

#### Task 2: Aggiungere un VIP

La prima risorsa creata nel cluster è una VIP.

```bash
pcs resource create myclusterVIP ocf:heartbeat:IPaddr2 ip=192.168.1.12 cidr_netmask=24 op monitor interval=30s
```

Controllare lo stato del cluster:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
...
  * 2 nodes configured
  * 1 resource instance configured

Node List:
  * Node server1: standby
  * Online: [ server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server2
```

#### Task 3: Installare il server Apache

Installare il server Apache su entrambi i nodi:

```bash
$ sudo dnf install -y httpd
$ sudo firewall-cmd --permanent --add-service=http
$ sudo firewall-cmd --reload
echo "<html><body>Node $(hostname -f)</body></html>" | sudo tee "/var/www/html/index.html"
sudo vim /etc/httpd/conf.d/status.conf
<Location /server-status>
    SetHandler server-status
    Require local
</Location>
```

#### Task 4: Aggiungere la risorsa `httpd`

Solo sul server1, aggiungere la nuova risorsa al cluster con i vincoli necessari:

```bash
sudo pcs resource create WebSite ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf statusurl="http://localhost/server-status" op monitor interval=1min
sudo pcs constraint colocation add WebSite with myclusterVIP INFINITY
sudo pcs constraint order myclusterVIP then WebSite
```

#### Task 5: Testare il cluster

Eseguire un failover e verificare che il vostro server web sia ancora disponibile:

```bash
$ sudo pcs status
Cluster name: mycluster
Cluster Summary:
  * Stack: corosync (Pacemaker is running)
  * Current DC: server1 (version 2.1.7-5.el9_4-0f7f88312) - partition with quorum
  ...

Node List:
  * Online: [ server1 server2 ]

Full List of Resources:
  * myclusterVIP        (ocf:heartbeat:IPaddr2):         Started server1
  * WebSite     (ocf:heartbeat:apache):  Started server1
```

Attualmente si sta lavorando sul server1.

```bash
$ curl http://192.168.1.12/
<html><body>Node server1</body></html>
```

Simulare un failover sul server1:

```bash
sudo pcs node standby server1
```

```bash
$ curl http://192.168.1.12/
<html><body>Node server2</body></html>
```

Come si può vedere, il servizio web funziona ancora, ma sul server2.

```bash
sudo pcs node unstandby server1
```

Si noti che il servizio è stato interrotto solo per pochi secondi, mentre il VIP passava al servizio e i servizi si riavviavano.

### Verificate le vostre conoscenze

:heavy_check_mark: Il comando `pcs` è l'unico per controllare un cluster di pacemaker?

:heavy_check_mark: Quale comando restituisce lo stato del cluster?

- [ ] `sudo pcs status`
- [ ] `systemctl status pcs`
- [ ] `sudo crm_mon -1`
- [ ] `sudo pacemaker -t`
