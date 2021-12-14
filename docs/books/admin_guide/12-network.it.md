---
title: Implementazione della Rete
---

# Implementazione della Rete

In questo capitolo imparerai come gestire e lavorare con la rete.

****

**Obiettivi** : In questo capitolo imparerai come:

:heavy_check_mark: Configurare una workstation per usare DHCP;  
:heavy_check_mark: Configurare una workstation per utilizzare una configurazione statica;  
:heavy_check_mark: Configura una workstation per utilizzare un gateway;  
:heavy_check_mark: Configurare una workstation per utilizzare i server DNS;  
:heavy_check_mark: Risolvere i problemi relativi alla rete di una workstation.

:checkered_flag: **rete**, **linux**, **ip**

**Knowledge**: :star: :star:  
**Complexity**: :star: :star:

**Tempo di lettura**: 30 minuti

****

## Generalità

Per illustrare questo capitolo, useremo la seguente architettura.

![Illustration of our network architecture](images/network-001.png)

Ci consentirà di prendere in considerazione:

* l'integrazione in una LAN (local area network);
* la configurazione di un gateway per raggiungere un server remoto;
* la configurazione di un server DNS e l'implementazione della risoluzione dei nomi.

I parametri minimi da definire per la macchina sono:

* il nome della macchina;
* l'indirizzo IP;
* la subnet mask.

Esempio:

*   `pc-rocky`;
*   `192.168.1.10`;
*   `255.255.255.0`.

La notazione chiamata CIDR è sempre più frequente: 192.168.1.10/24

Gli indirizzi IP vengono utilizzati per il corretto routing dei messaggi (pacchetti). Sono divisi in due parti:

* la parte fissa, identifica la rete;
* l'identificatore dell'host nella rete.

La subnet mask è un insieme di **4 byte** destinato a isolare:

* l'indirizzo di rete (**NetID** o **SubnetID**) eseguendo un AND logico bit per bit tra l'indirizzo IP e la maschera;
* l'indirizzo dell'host. (**HostID**) eseguendo un AND logico bit per bit tra l'indirizzo IP e il complemento della maschera.

Ci sono anche indirizzi specifici all'interno di una rete, che devono essere identificati. Il primo indirizzo di un intervallo e l'ultimo hanno un ruolo particolare:

* Il primo indirizzo di un intervallo è l'**indirizzo di rete**. Viene utilizzato per identificare le reti e per instradare le informazioni da una rete all'altra.

* L'ultimo indirizzo di un intervallo è l'**indirizzo di trasmissione**. Viene utilizzato per trasmettere informazioni a tutte le macchine sulla rete.

### Indirizzo MAC / Indirizzo IP

L'**indirizzo MAC** è un identificatore fisico scritto in fabbrica sul dispositivo. Questo a volte viene definito l'indirizzo hardware. Consiste di 6 byte spesso espressi in forma esadecimale (per esempio 5E:FF:56:A2:AF:15). È composto da: 3 byte dell'identificatore del produttore e 3 byte del numero di serie.

!!! Warning "Avvertimento" Quest'ultima affermazione è al giorno d'oggi un po' meno vera con la virtualizzazione. Ci sono anche soluzioni software per cambiare l'indirizzo MAC.

Un indirizzo Internet Protocol (**IP**) è un numero di identificazione permanente o temporaneo assegnato a ciascun dispositivo collegato a una rete di computer che utilizza l'Internet Protocol. Una parte definisce l'indirizzo di rete (NetID o SubnetID  a seconda dei casi), l'altra parte definisce l'indirizzo dell'host nella rete (HostID). La dimensione relativa di ciascuna parte varia in base alla (sub)mask della rete.

Un indirizzo IPv4 definisce un indirizzo su 4 byte. Per il numero di indirizzi disponibili che è vicino alla saturazione è stato creato un nuovo standard, l'IPv6 definito su 16 byte.

IPv6 è spesso rappresentato da 8 gruppi di 2 byte separati da un due punti. Gli zeri insignificanti possono essere omessi, uno o più gruppi di 4 zeri consecutivi possono essere sostituiti da un doppio due punti.

Le maschere di sottorete hanno da 0 a 128 bit. (Per esempio 21ac:0000:0000:0611:21e0:00ba:321b:54da/64 o 21ac::611:21e0:ba:321b:54da/64)

In un indirizzo web o URL (Uniform Resource Locator), un indirizzo IP può essere seguito da un due punti e dall'indirizzo della porta (che indica l'applicazione a cui i dati sono destinati). Inoltre per evitare confusione in un URL, l'indirizzo IPv6 è scritto in parentesi quadre [ ], due punti, indirizzo della porta.

Le macchine client possono far parte di un dominio DNS (**Domain Name System**, ad esempio `mydomain.lan`).

### Dominio DNS

Le macchine client possono far parte di un dominio DNS (**Domain Name System**, ad esempio `mydomain.lan`).

Il nome completo del computer (**FQDN**) diventa `pc-rocky.mydomain.lan`.

Un insieme di computer può essere raggruppato in un set logico, che risolve i nomi, chiamato dominio DNS. Un dominio DNS non è, ovviamente, limitato a una singola rete fisica.

Affinché un computer faccia parte di un dominio DNS, è necessario fornire un suffisso DNS (qui `mydomain.lan`) e un server da poter interrogare.

### Promemoria del modello OSI

!!! Note " Aiuto alla memoria " Per ricordare l'ordine dei livelli del modello OSI, ricordare la seguente frase:  __Please Do Not Touch Steven's Pet Alligator__.

| Livello                 | Protocolli                                 |
| ----------------------- | ------------------------------------------ |
| 7 - Applicazione        | POP, IMAP, SMTP, SSH, SNMP, HTTP, FTP, ... |
| 6 - Presentazione       | ASCII, MIME, ...                           |
| 5 - Sessione            | TLS, SSL, NetBIOS, ...                     |
| 4 - Trasporto           | TLS, SSL, TCP, UDP, ...                    |
| 3 - Rete                | IPv4, IPv6, ARP, ...                       |
| 2 - Collegamento dati   | Ethernet, WiFi, Token Ring, ...            |
| 1 - Collegamento fisici | Cavi, fibre ottiche, onde radio, ...       |

**Livello 1**  (Fisico) supporta la trasmissione su un canale di comunicazione (Wifi, fibra ottica, cavo RJ, ecc.). Unità: il bit.

**Livello 2** (Data Link) supporta la topologia di rete (token-ring, star, bus, etc.), divisione dei dati ed errori di trasmissione. Unità: il frame.

**Livello 3** (Rete) supporta la trasmissione dati end-to-end (Routing IP = Gateway). Unità: il pacchetto.

**Livello 4** (Trasporto) supporta il tipo di servizio (connesso o non connesso) crittografia e controllo del flusso. Unità: il segmento o il datagramma.

**Livello 5** (Sessione) supporta la comunicazione tra due computer.

**Livello 6** (Presentazione) rappresenta l'area indipendente dai dati a livello di applicazione. Essenzialmente questo livello traduce dal formato di rete al formato dell'applicazione, o dal formato dell'applicazione al formato di rete.

**Layer 7** (Applicazione) rappresenta il contatto con l'utente. Fornisce i servizi offerti dalla rete: http, dns, ftp, imap, pop, smtp, etc.

## La denominazione delle interfacce

*lo* è l'intefaccia di "**loopback**" che consente ai programmi TCP/IP di comunicare tra loro senza lasciare la macchina locale. Ciò consente di verificare se il modulo di rete **del sistema funziona correttamente** e consente anche il ping del localhost. Tutti i pacchetti che entrano attraverso localhost escono attraverso localhost. I pacchetti ricevuti corrispondono ai pacchetti inviati.

Il kernel Linux assegna i nomi delle interfacce con un prefisso specifico a seconda del tipo. Ad esempio tradizionalmente, tutte le interfacce **Ethernet**, iniziano con **eth**. Il prefisso è seguito da un numero, il primo è 0 (eth0, eth1, eth2...). Alle interfacce wifi è stato assegnato un prefisso wlan.

Sulle distribuzioni Linux Rocky 8, systemd nominerà le interfacce seguendo la nuova politica in cui "X" rappresenta un numero:

* `enoX`: dispositivi on-board
* `ensX`: slot hotplug PCI Express
* `enpXsX`: posizione fisica/geografica del connettore dell'hardware
* ...

## Uso del comandi `ip`

Dimentica il vecchio comando `ifconfig`! Pensa `ip`!

... Note Nota Commento per gli amministratori dei vecchi sistemi Linux:

    Il comando storico di gestione della rete è `ifconfig`. Questo comando è stato sostituito dal comando `ip`, che è già ben noto agli amministratori di rete.
    
    Il comando `ip` è l'unico comando per gestire**indirizzo IP, ARP, routing, ecc.**
    
    Il comando `ifconfig` non è più installato per impostazione predefinita in Rocky8.
    
    È importante iniziare con le buone abitudini ora.

## Il nome host

Il comando `hostname` visualizza o imposta il nome host del sistema

```
hostname [-f] [hostname]
```

| Opzione | Descrizione                             |
| ------- | --------------------------------------- |
| `-f`    | Mostra il FQDN                          |
| `-i`    | Visualizza gli indirizzi IP del sistema |

!!! Tip "Suggerimento" Questo comando viene utilizzato da vari programmi di rete per identificare la macchina.

Per assegnare un nome host, è possibile utilizzare il comando`hostname`, ma le modifiche non verranno mantenute all'avvio successivo. Il comando senza argomenti visualizza il nome host.

Per impostare il nome host, bisogna modificare il file `/etc/sysconfig/network`:

```
NETWORKING=yes
HOSTNAME=pc-rocky.mondomaine.lan
```

Lo script di avvio di RedHat consulta anche il file `/etc/hosts` per risolvere il nome host del sistema.

All'avvio del sistema, Linux valuta il valore `HOSTNAME` nel file `/etc/sysconfig/network`.

Utilizza quindi il file `/etc/hosts` per valutare l'indirizzo IP principale del server e il suo nome host. E dedurre il nome di dominio DNS.

È quindi essenziale compilare questi due file prima di qualsiasi configurazione dei servizi di rete.

!!! Tip "Suggerimento" Per sapere se questa configurazione è ben fatta, i comandi `hostname` e `hostname -f` devono restituire i valori previsti.

## /etc/hosts file

Il file `/etc/hosts` è una tabella di mapping dei nomi host statici, che segue il seguente formato:

```
@IP <hostname>  [alias]  [# comment]
```

Esempio di un file `/etc/hosts`:

```
127.0.0.1      localhost localhost.localdomain
::1            localhost localhost.localdomain
192.168.1.10   rockstar.rockylinux.lan rockstar
```

Il file `/etc/hosts` viene ancora utilizzato dal sistema, soprattutto al momento dell'avvio quando viene determinato il nome di dominio completo del sistema (FQDN).

!!! Tip "Suggerimento" RedHat raccomanda che sia compilata almeno una linea con il nome del sistema.

Se il servizio **DNS** (**D**domain **N**ame **S**ervice) non è presente, è necessario compilare tutti i nomi nel file hosts per ciascuno dei computer.

Il file `/etc/hosts` contiene una riga per voce, con l'indirizzo IP, il nome di dominio completo, quindi il nome host (in quest'ordine) e una serie di alias (alias1 alias2 ...). L'alias è opzionale.

## il file `/etc/nsswitch.conf`

Il **NSS** (**N**ame **S**ervice **S**witch) consente di sostituire i file di configurazione (ad esempio `/etc/passwd`, `/etc/group`, `/etc/hosts`) con uno o più database centralizzati.

Il file `/etc/nsswitch.conf` viene utilizzato per configurare i database del servizio dei nomi.

```
passwd: files
shadow: files
group: files

hosts: files dns
```

In questo caso, Linux cercherà prima una corrispondenza del nome host (riga `hosts:`) nel file `/etc/hosts` (valore `files`) prima di interrogare il DNS (valore `dns`)! Questo comportamento può essere variato modificando il file `/etc/nsswitch.conf`.

Naturalmente, è possibile immaginare di interrogare un LDAP, MySQL o altro server configurando il servizio dei nomi per rispondere alle richieste di sistema per host, utenti, gruppi, ecc.

La risoluzione del servizio dei nomi può essere testata con il comando `getent` che vedremo più avanti in questo corso.

## file `/etc/resolv.conf`

Il file `/etc/resolv.conf` contiene la configurazione della risoluzione dei nomi DNS.

```
#Generated by NetworkManager
domain mondomaine.lan
search mondomaine.lan
nameserver 192.168.1.254
```

!!! Tip "Suggerimento" Questo file è ormai storia. Non è più compilato direttamente!

Le nuove generazioni di distribuzioni hanno generalmente integrato il servizio `NetworkManager`. Questo servizio consente di gestire la configurazione in modo più efficiente, sia in modalità grafica che console.

Consente l'aggiunta di server DNS dal file di configurazione di un'interfaccia di rete. Quindi popola dinamicamente il file `/etc/resolv.conf` che non dovrebbe mai essere modificato direttamente, altrimenti le modifiche alla configurazione andranno perse al successivo avvio del servizio di rete.

## comando `ip`

Il comando `ip` del pacchetto `iproute2` consente di configurare un'interfaccia e la relativa tabella di routing.

Mostra le interfacce :

```
[root]# ip link
```

Mostra le informazioni sulle interfacce:

```
[root]# ip addr show
```

Mostra le informazioni su una interfaccia :

```
[root]# ip addr show eth0
```

Mostra la tabella ARP:

```
[root]# ip neigh
```

Tutti i comandi di gestione della rete storici sono stati raggruppati sotto il comando `ip`, che è ben noto agli amministratori di rete.

## configurazione DHCP

Il protocollo **DHCP** (**D**ynamic **H**ost **C**Control **P**rotocol) consente di ottenere una configurazione IP completa tramite la rete. Questa è la modalità di configurazione predefinita di un'interfaccia di rete sotto Rocky Linux, il che spiega perché un sistema connesso alla rete attraverso un router internet può funzionare senza ulteriori configurazioni.

La configurazione delle interfacce sotto Rocky Linux è contenuta nella cartella `/etc/sysconfig/network-scripts/`.

Per ogni interfaccia Ethernet, un file `ifcfg-ethX` consente la configurazione dell'interfaccia associata.

```
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=dhcp
HWADDR=00:0c:29:96:32:e3
```

*  Nome dell'interfaccia : (deve essere nel nome del file)

```
DEVICE=eth0
```

* Avvia automaticamente l'interfaccia:

```
ONBOOT=yes
```

* Effettuare una richiesta DHCP all'avvio dell'interfaccia:

```
BOOTPROTO=dhcp
```

* Specificare l'indirizzo MAC (opzionale ma utile quando ci sono diverse interfacce):

```
HWADDR=00:0c:29:96:32:e3
```

!!! Tip "Suggerimento" Se NetworkManager è installato, le modifiche vengono prese in considerazione automaticamente. In caso contrario, è necessario riavviare il servizio di rete.

* Riavviare il servizio di rete:

```
[root]# systemctl restart NetworkManager
```

## Configurazione statica

La configurazione statica richiede almeno:

```
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=none
IPADDR=192.168.1.10
NETMASK=255.255.255.0
```

* Qui stiamo sostituendo "dhcp" con "none" che equivale alla configurazione statica:

```
BOOTPROTO=none
```

* Indirizzo IP:

```
IPADDR=192.168.1.10
```

* Subnet mask:

```
NETMASK=255.255.255.0
```

* La maschera può essere specificata con un prefisso:

```
PREFIX=24
```

!!! Warning "Avvertimento" È necessario utilizzare il NETMASK o il PREFISSO - Non entrambi!

## Routing (Instradamento)

![Network architecture with a gateway](images/network-002.png)

```
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=none
HWADDR=00:0c:29:96:32:e3
IPADDR=192.168.1.10
NETMASK=255.255.255.0
GATEWAY=192.168.1.254
```

Il comando `ip route`:

```
[root]# ip route show
192.168.1.0/24 dev eth0 […] src 192.168.1.10 metric 1
default via 192.168.1.254 dev eth0 proto static
```

È una buona idea sapere come leggere una tabella di routing, specialmente in un ambiente con più interfacce di rete.

* Nell'esempio mostrato, la rete `192.168.1.0/24` è raggiungibile direttamente dal dispositivo `eth0`, quindi c'è una metrica a `1` (non attraversa un router).

* Tutte le altre reti oltre alla precedente saranno raggiungibili, sempre dal dispositivo `eth0`, ma questa volta i pacchetti saranno indirizzati a un gateway `192.168.1.254`. Il protocollo di routing è un protocollo statico (anche se è possibile aggiungere una route a un indirizzo assegnato dinamicamente in Linux).

## Risoluzione dei nomi

Un sistema deve risolvere:

* FQDN in indirizzi IP

```
www.free.fr = 212.27.48.10
```

* Indirizzi IP in nomi

```
212.27.48.10 = www.free.fr
```

* o per ottenere informazioni su un'area:

```
MX de free.fr = 10 mx1.free.fr + 20 mx2.free.fr
```

```
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=none
HWADDR=00:0c:29:96:32:e3
IPADDR=192.168.1.10
NETMASK=255.255.255.0
GATEWAY=192.168.1.254
DNS1=172.16.1.2
DNS2=172.16.1.3
DOMAIN=rockylinux.lan
```

In questo caso, per raggiungere il DNS, devi passare attraverso il gateway.

```
 #Generated by NetworkManager
 domain mondomaine.lan
 search mondomaine.lan
 nameserver 172.16.1.2
 nameserver 172.16.1.3
```

Il file è stato aggiornato da NetworkManager.

## Risoluzione dei problemi

Il comando `ping` invia i datagrammi a un'altra macchina e attende una risposta.

È il comando di base per testare la rete perché controlla la connettività tra l'interfaccia di rete e un'altra.

Sintassi del comando `ping`:

```
ping [-c numerical] destination
```

L'opzione `-c` (conteggio) consente di interrompere il comando dopo il conto alla rovescia in secondi.

Esempio:

```
[root]# ping –c 4 localhost
```

!!! Tip "Suggerimento" Convalida la connettività da vicino a lontano

1) Convalidare il livello software TCP/IP

```
[root]# ping localhost
```

Il "Pinging" del loop interno non rileva un errore hardware sull'interfaccia di rete. Determina semplicemente se la configurazione del software IP è corretta.

2) Convalidare la scheda di rete

```
[root]# ping 192.168.1.10
```

Per determinare se la scheda di rete è funzionante, ora dobbiamo eseguire il ping del suo indirizzo IP. La scheda di rete, se il cavo di rete non è collegato, dovrebbe essere in uno stato "down".

Se il ping non funziona, controllare prima il cavo di rete allo switch di rete e riassemblare l'interfaccia (vedere il comando `if up`), quindi controllare l'interfaccia stessa.

3) Convalidare la connettività del gateway

```
[root]# ping 192.168.1.254
```

4) Convalidare la connettività di un server remoto

```
[root]# ping 172.16.1.2
```

5) Convalidare il servizio DNS

```
[root]# ping www.free.fr
```

### comando `dig`

Il comando `dig` viene utilizzato per interrogare il server DNS.

La sintassi del comando `dig`:

```
dig [-t type] [+short] [name]
```

Esempi:

```
[root]# dig +short rockylinux.org
76.223.126.88
[root]# dig -t MX +short rockylinux.org                                                          ✔
5 alt1.aspmx.l.google.com.
!!!
```

Il comando `dig` viene utilizzato per eseguire query sui server DNS. È molto prolisso per impostazione predefinita, ma questo comportamento può essere modificato con l'opzione `+short`.

È anche possibile specificare un **tipo di record** DNS da risolvere, ad esempio un **tipo** MX per ottenere informazioni sugli scambiatori di posta per un dominio.

### comando `getent`

Il comando 'getent' (get entry) viene utilizzato per ottenere una voce NSSwitch (`hosts` + `dns`)

Sintassi del comando `getent`:


```
getent hosts name
```

Esempio:

```
[root]# getent hosts rockylinux.org
  76.223.126.88 rockylinux.org
```

Interrogare solo un server DNS può restituire un risultato errato che non tiene conto del contenuto di un file `hosts`, anche se questo dovrebbe essere raro al giorno d'oggi.

Per prendere in considerazione anche il file `/etc/hosts`, è necessario interrogare il servizio dei nomi NSSwitch, che si occuperà di qualsiasi risoluzione DNS.

### comando `ipcalc`

Il comando `ipcalc` (**calcolo ip**) viene utilizzato per calcolare l'indirizzo di una rete o di trasmissione da un indirizzo IP e una maschera.

Sintassi del comando `ipcalc`:

```
ipcalc  [options] IP <netmask>
```

Esempio:

```
[root]# ipcalc –b 172.16.66.203 255.255.240.0
BROADCAST=172.16.79.255
```

!!! Tip "Suggerimento" Questo comando è interessante se seguito da un reindirizzamento per compilare automaticamente i file di configurazione delle interfacce:

    ```
    [root]# ipcalc –b 172.16.66.203 255.255.240.0 >> /etc/sysconfig/network-scripts/ifcfg-eth0
    ```

| Opzione | Descrizione                                   |
| ------- | --------------------------------------------- |
| `-b`    | Visualizza l'indirizzo di trasmissione.       |
| `-n`    | Visualizza l'indirizzo di rete e la maschera. |

`ipcalc` è un modo semplice per calcolare le informazioni IP di un host. Le varie opzioni indicano a `ipcalc` quali informazioni devono essere visualizzate sull'uscita standard. È possibile specificare più opzioni. È necessario specificare un indirizzo IP su cui operare. La maggior parte delle operazioni richiede anche una maschera di rete o un prefisso CIDR.

| Opzione corta | Opzione lunga | Descrizione                                                                                                                                                                                                                                           |
| ------------- | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `-b`          | `--broadcast` | Visualizza l'indirizzo di trasmissione dell'indirizzo IP specifico e la maschera di rete.                                                                                                                                                             |
| `-h`          | `--hostname`  | Visualizza il nome host dell'indirizzo IP fornito tramite DNS.                                                                                                                                                                                        |
| `-n`          | `--netmask`   | Calcola la maschera di rete per l'indirizzo IP indicato. Presuppone che l'indirizzo IP faccia parte di una rete completa di classe A, B o C. Molte reti non utilizzano maschere di rete predefinite, nel qual caso verrà restituito un valore errato. |
| `-p`          | `--prefix`    | Indica il prefisso della maschera/indirizzo IP.                                                                                                                                                                                                       |
| `-n`          | `--network`   | Indica l'indirizzo di rete dell'indirizzo IP e della maschera forniti.                                                                                                                                                                                |
| `-s`          | `--silent`    | Non visualizza mai alcun messaggio di errore.                                                                                                                                                                                                         |

### comando `ss`

Il comando `ss` (**statistiche socket**) visualizza le porte in ascolto sulla rete.

Sintassi del comando `ss`:

```
ss [-tuna]
```

Esempio:

```
[root]# ss –tuna
tcp   LISTEN   0   128   *:22   *:*
```

I comandi `ss` e `netstat` (che segue) saranno molto importanti per il resto della tua vita con Linux.

Quando si implementano i servizi di rete, è molto comune verificare con uno di questi due comandi che il servizio sia in ascolto sulle porte previste.

### comando `netstat`

!!! Warning "Avvertimento" Il comando `netstat` è ora deprecato e non è più installato per impostazione predefinita su Rocky Linux. You may still find some Linux versions that have it installed, but it is best to move on to using `ss` for everything that you would have used `netstat` for.

Il comando `netstat` (**statistiche di rete**) visualizza le porte in ascolto sulla rete.

Sintassi del comando `netstat`:

```
netstat -tapn
```

Esempio:

```
[root]# netstat –tapn
tcp  0  0  0.0.0.0:22  0.0.0.0:*  LISTEN 2161/sshd
```

### Conflitti di indirizzi IP o MAC

Una configurazione errata può causare l'utilizzo dello stesso indirizzo IP da parte di più interfacce. Ciò può verificarsi quando una rete dispone di più server DHCP o quando lo stesso indirizzo IP viene assegnato manualmente più volte.

Quando la rete non funziona correttamente e quando la causa potrebbe essere un conflitto di indirizzi IP, è possibile utilizzare il software `arp-scan` (richiede il repository EPEL):

```
$ dnf install arp-scan
```

Esempio:

```
$ arp-scan -I eth0 -l

172.16.1.104  00:01:02:03:04:05       3COM CORPORATION
172.16.1.107  00:0c:29:1b:eb:97       VMware, Inc. 172.16.1.250  00:26:ab:b1:b7:f6       (Unknown)
172.16.1.252  00:50:56:a9:6a:ed       VMWare, Inc. (DUP: 2)
172.16.1.253  00:50:56:b6:78:ec       VMWare, Inc. (DUP: 3)
172.16.1.253  00:50:56:b6:78:ec       VMWare, Inc. (DUP: 4)
172.16.1.232   88:51:fb:5e:fa:b3       (Unknown) (DUP: 2)
```

!!! Tip "Suggerimento" Come mostra l'esempio precedente, è anche possibile avere conflitti di indirizzi MAC! Questi problemi sono causati dalle tecnologie di virtualizzazione e dalla copia delle macchine virtuali.

## Configurazione a caldo

Il comando `ip` può aggiungere a caldo un indirizzo IP a un'interfaccia

```
ip addr add @IP dev DEVICE
```

Esempio:

```
[root]# ip addr add 192.168.2.10 dev eth1
```

Il comando `ip` consente l'attivazione o la disattivazione di un'interfaccia:

```
ip link set DEVICE up
ip link set DEVICE down
```

Esempio:

```
[root]# ip link set eth1 up
[root]# ip link set eth1 down
```

Il comando `ip` viene utilizzato per aggiungere una route:

```
ip route add [default|netaddr] via @IP [dev device]
```

Esempio:

```
[root]# ip route add default via 192.168.1.254
[root]# ip route add 192.168.100.0/24 via 192.168.2.254 dev eth1
```

## In sintesi

I file utilizzati in questo capitolo sono:

![Synthesis of the files implemented in the network part](images/network-003.png)

Una configurazione completa dell'interfaccia potrebbe essere questa (file `/etc/sysconfig/network-scripts/ifcfg-eth0`):

```
 DEVICE=eth0
 ONBOOT=yes
 BOOTPROTO=none
 HWADDR=00:0c:29:96:32:e3
 IPADDR=192.168.1.10
 NETMASK=255.255.255.0
 GATEWAY=192.168.1.254
 DNS1=172.16.1.1
 DNS2=172.16.1.2
 DOMAIN=rockylinux.lan
```

Il metodo di risoluzione dei problemi dovrebbe andare dal più vicino al più lontano:

1. ping localhost (test del software)
2. ping indirizzo-IP (test dell'hardware)
3. ping gateway (test di connettività)
4. ping server remoto (test di instradamento)
5. DNS query (dig o ping)

![Method of troubleshooting or network validation](images/network-004.png)
