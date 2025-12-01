---
author: Wale Soyinka
title: Lab 5 - Networking Essentials
contributors: Steven Spencer, Ganna Zhyrnova, Franco Colussi
tested on: All Versions
tags:
  - lab exercise
  - networking
  - nmcli
  - ip
  - iproute2
  - macvtap
---

## Obiettivi

Dopo aver completato questo laboratorio, si sarà in grado di:

- Creare dispositivi di rete virtuali
- Gestire i dispositivi di rete e le impostazioni su un sistema Linux utilizzando il toolkit `iproute2` (`ip`)
- Gestire i dispositivi di rete e le impostazioni su un sistema Linux utilizzando il toolkit di *NetworkManager*  (`nmcli`)
- Risolvere i problemi di rete più comuni

Tempo stimato per completare questo laboratorio: 60 minuti

## Sommario

Questo laboratorio Networking Essentials copre vari esercizi di configurazione e risoluzione dei problemi di rete su un server Linux. Potrete gestire e risolvere i problemi relativi alle impostazioni di rete in modo più efficace utilizzando le comuni utility di rete disponibili sui sistemi basati su Linux.

### Introduzione ai comandi utilizzati

Il comando `iproute2` è una suite delle utilities avanzate per la configurazione e la gestione delle reti sui sistemi Linux, sviluppata per sostituire la tradizionale suite *net-tools* (come *ifconfig*, *route* e *arp*).  
`iproute2` è progettato per gestire le moderne funzionalità del kernel Linux, tra cui namespace, policy routing e QoS avanzato. Ora è lo strumento consigliato per l'amministrazione di rete sulle moderne distribuzioni Linux.

Il comando `ip` è uno strumento essenziale per la gestione e la configurazione della rete. Fa parte del pacchetto `iproute2` e offre un controllo avanzato su interfacce di rete, indirizzi IP, tabelle di routing, tunnel e molto altro ancora.  
Grazie alla sua sintassi flessibile e alle sue opzioni, consente agli amministratori di sistema di monitorare, modificare e risolvere in modo efficiente i problemi di connettività.  
La sua struttura modulare consente di gestire in modo coerente diversi aspetti della configurazione di rete, semplificando così l'amministrazione.

Il comando `nmcli` è uno strumento potente e versatile incluso in *NetworkManager*, progettato per gestire le connessioni di rete sui sistemi Linux direttamente dal terminale.  A differenza degli strumenti grafici, `nmcli` consente di configurare, monitorare e controllare in modo efficiente le interfacce di rete sia su macchine locali che remote, rendendolo particolarmente utile per gli amministratori di sistema e gli utenti avanzati.  
Supporta un'ampia gamma di funzionalità, tra cui la configurazione di connessioni cablate, wireless e VPN, la gestione delle reti mobili e il debug dello stato della rete.

## Esercizi

### 1. Cambiare l'Hostname

Esistono molti metodi per identificare o fare riferimento ai computer. Alcuni di questi metodi garantiscono l'unicità (soprattutto su una rete), altri no. L'hostname di un computer può essere considerato come un nome intuitivo. Gli hostname dei computer dovrebbero idealmente essere univoci a seconda di come vengono gestiti e assegnati. Tuttavia, poiché chiunque disponga di privilegi amministrativi su un sistema può assegnare unilateralmente qualsiasi hostname desideri al sistema, **l'unicità non è sempre garantita**.

Questo primo esercizio illustra alcuni strumenti comuni per la gestione del hostname del computer.

#### Modificare l'hostname del sistema

1. Una volta effettuato l'accesso al sistema, visualizzare il *hostname* corrente utilizzando la popolare utility `hostname`. Digitare:

    ```bash
    hostname
    ```

2. Eseguire nuovamente l'utilità `hostname` con un'opzione diversa per visualizzare l'FQDN del server:

    ```bash
    hostname --fqdn
    ```

    !!! question "Domanda"

     Cosa significa FQDN? E perché il risultato del nome host del tuo server è diverso dal suo FQDN?

3. Utilizzare l'utilità `hostnamectl` per visualizzare il *hostname* corrente. Digitare:

    ```bash
    hostnamectl
    ```

   Sono davvero tante informazioni in più!

4. Aggiungere l'opzione `--static` al comando `hostnamectl` per visualizzare il nome host statico del server. Digitare:

    ```bash
    hostnamectl --static
    ```

5. Aggiungere l'opzione `--transient` al comando `hostnamectl` per visualizzare il nome host transitorio del server.

6. Ora provare l'opzione `--pretty` del comando `hostnamectl` per visualizzare il nome pretty host del server.

7. Impostare un nuovo nome host temporaneo per il server. Digitare:

    ```bash
    hostnamectl --transient set-hostname my-temp-server1 
    ```

8. Verificare la modifica temporanea del nome host. Digitare:

    ```bash
    hostnamectl --transient
    ```

9. Impostare un nuovo nome host statico per il server. Digitare:

    ```bash
    hostnamectl set-hostname my-static-hostname1
    ```

10. Verificare la modifica del nome host statico.

    !!! question "Domanda"
    
         Consultare la pagina man di `hostnamectl`. Quali sono le differenze tra hostname pretty, transitori e statici?

### 2. Creazione di un dispositivo virtuale

Il primo passo fondamentale da completare prima di procedere con gli altri esercizi di questo laboratorio di rete è la creazione di una speciale interfaccia di rete virtuale denominata *dispositivo MACVTAP*.

I dispositivi MACVTAP sono dispositivi virtuali che combinano le proprietà di un'interfaccia esclusivamente software, nota come dispositivo *TAP*, con quelle del driver *MACVLAN*.

La creazione e l'utilizzo di questi dispositivi MACVTAP consentirà di testare, modificare e configurare in modo sicuro varie attività relative alla configurazione di rete. Queste interfacce di rete virtuali saranno utilizzate in varie esercitazioni senza interferire con la configurazione di rete esistente.

!!! tip "Suggerimento"

    I dispositivi TAP forniscono un'interfaccia esclusivamente software a cui le applicazioni dello spazio utente possono accedere facilmente. I dispositivi TAP inviano e ricevono frame Ethernet non elaborati.  
    MACVLAN viene utilizzato per creare interfacce di rete virtuali che si collegano alle interfacce di rete fisiche.  
    I dispositivi MACVTAP hanno un proprio indirizzo MAC unico, distinto dall'indirizzo MAC della scheda di rete fisica sottostante a cui sono associati.

#### Creazione delle Interfacce MACVTAP

Questo esercizio inizia con la creazione delle interfacce di rete virtuali MACVTAP necessarie. Ciò consentirà di testare, modificare e configurare in modo sicuro varie attività relative alla configurazione di rete. Queste interfacce di rete virtuali saranno utilizzate in varie esercitazioni senza interferire con la configurazione di rete esistente.

#### Elenco di tutte le interfacce di rete presenti nel sistema

1. Assicurarsi di aver effettuato l'accesso al server.

2. Utilizzare il programma `ip` per visualizzare le interfacce di rete esistenti sul sistema. Digitare:

    ```bash
    ip link show
    ```

3. Provare ad utilizzare il comando `nmcli` per elencare tutti i dispositivi di rete. Digitare:

    ```bash
     nmcli -f DEVICE device
    ```

4. Interrogare il file system virtuale di basso livello `/sys` per enumerare manualmente *TUTTE* le interfacce di rete disponibili sul vostro server. Digitare:

    ```bash
     ls -l /sys/class/net/ | grep -v 'total' | awk '{print $9}'
    ```

#### Creazione di interfacce `macvtap`

1. Assicurarsi di aver effettuato l'accesso al sistema come utente con privilegi amministrativi.

2. È necessario interrogare e identificare i tipi di dispositivi di rete appropriati disponibili sul server per poterli associare al dispositivo `macvtap`. Digitare:

    ```bash
     ls -l /sys/class/net/ | grep -v 'virtual\|total' | tail -n 1 | awk '{print $9}'
     eno2
    ```

    L'output sul sistema demo di esempio mostra un'interfaccia adatta denominata `eno2`.

3. Eseguire nuovamente il comando per identificare il dispositivo, ma questa volta memorizzare il valore restituito in una variabile denominata `$DEVICE1`. Controllare nuovamente il valore di `$DEVICE1` usando *echo*. Per eseguire questa operazione, digitare i seguenti 2 comandi separati:

    ```bash
    # DEVICE1=$(ls -l /sys/class/net/ | grep -v 'virtual\|total' | tail -n 1 | awk '{print $9}')
    # echo $DEVICE1
    ```

4. Ora, creare un'interfaccia MACVTAP denominata - `macvtap1`. La nuova interfaccia sarà associata a `$DEVICE1`. Digitare:

    ```bash
    ip link add link $DEVICE1 name macvtap1 type macvtap mode bridge
    ```

5. Verificare la creazione dell'interfaccia `macvtap1`. Digitare:

    ```bash
    ip --brief link show macvtap1
    ```

    Notare lo stato **DOWN** dell'interfaccia `macvtap` nell'output.

6. Visualizzare le informazioni dettagliate su tutti i dispositivi di rete di *MACVTAP-type* presenti nel sistema. Digitare:

    ```bash
    ip --detail link show type macvtap
    ```

7. Eseguire un comando per visualizzare tutte le interfacce di rete sul server e confrontare il risultato con quello ottenuto dal comando simile nella sezione precedente "Per elencare tutte le interfacce di rete sul sistema".

#### Abilitare/Disabilitare le interfacce di rete

1. Controllare lo stato dell'interfaccia di rete `macvtap1`. Digitare:

    ```bash
    ip link show macvtap1
    ```

2. Abilitare l'interfaccia di rete `macvtap1` (se attualmente disabilitata). Eseguire:

    ```bash
    ip link set macvtap1 up
    ```

3. Verificare le modifiche di stato eseguendo:

    ```bash
    ip -br link show macvtap1
    ```

    !!! tip "Suggerimento"

     Nel caso in cui sia necessario disabilitare un'interfaccia di rete, la sintassi del comando `ip` per farlo è `ip link set <IFNAME> down`.  
     Ad esempio, per disabilitare un'interfaccia di rete denominata `macvtap7`, è necessario eseguire:

        ```bash
        ip link set macvtap7 down
        ```

Ora che sono state configurate le interfacce `macvtap`, è possibile eseguire in modo sicuro le varie attività di configurazione della rete e di risoluzione dei problemi negli esercizi rimanenti.

### 3. Assegnazione degli indirizzi IP

Un indirizzo **IP** (*Internet Protocol*) è un identificatore numerico univoco assegnato a ciascun dispositivo connesso a una rete che utilizza il protocollo IP per la comunicazione. Funziona come un “indirizzo” digitale che consente ai dispositivi di inviare e ricevere dati attraverso una rete, sia locale (LAN) che globale (Internet).

#### Per assegnare indirizzi IPv6 alle interfacce `macvtap`

1. Visualizzare gli indirizzi IP di tutte le interfacce di rete sul server. Digitare:

    ```bash
    ip address show
    ```

2. Assegnare l'indirizzo IP - **172.16.99.100** - a `macvtap1`. Digitare

    ```bash
    ip address add 172.16.99.100/24 dev macvtap1
    ```

3. Verificare l'assegnazione dell'indirizzo IP per `macvtap1`

    ```bash
    ip address show macvtap1
    ```

4. Utilizzare il comando `nmcli` per visualizzare gli indirizzi IPv4 di tutte le interfacce presenti nel sistema. Digitare:

    ```bash
    nmcli --get-values IP4.ADDRESS,GENERAL.DEVICE device show
    ```

#### Impostazione di un indirizzo IPv6 su `macvtap` interfacce

1. Partendo da `macvtap1`, assegnare l'indirizzo IPv6 **2001:db8::1/64** a `macvtap1` eseguendo:

    ```bash
     ip -6 address add 2001:db8::1/64 dev macvtap1
    ```

3. Verificare le assegnazioni degli indirizzi IPv6, digitare:

    ```bash
    ip --brief -6 address show macvtap1 && ip -br -6 address show macvtap1
    ```

4. Utilizzare `nmcli` per visualizzare gli indirizzi IPv6 di tutte le interfacce presenti nel sistema. Digitare:

    ```bash
    nmcli --get-values  IP6.ADDRESS,GENERAL.DEVICE  device show
    ```

### 5. Gestione del routing

Il routing in Linux è un meccanismo che consente al sistema operativo di gestire il traffico di rete indirizzando i pacchetti di dati alle destinazioni previste. Il kernel Linux utilizza una tabella di routing per determinare il percorso ottimale che i pacchetti devono seguire, in base agli *indirizzi IP*, alle *subnet masks* e ai *gateway*.  
Questa funzionalità è essenziale sia negli *ambienti domestici* che nelle complesse *reti aziendali*, dove più interfacce di rete e dispositivi devono comunicare tra loro.

#### Visualizzare la tabella di routing del sistema

1. Visualizzare la tabella di routing corrente per il sistema. Digitare:

    ```bash
    ip route show
    default via 192.168.2.1 dev enp1s0 proto dhcp src 192.168.2.121 metric 100
    10.99.99.0/24 dev tunA proto kernel scope link src 10.99.99.1 metric 450 linkdown
    192.168.2.0/24 dev enp1s0 proto kernel scope link src 192.168.2.121 metric 100
    ```

2. Utilizzando una delle reti visualizzate nella colonna più a sinistra dell'output del comando precedente come argomento, visualizzare la voce della tabella di routing per quella rete. Ad esempio, per visualizzare la voce della tabella di routing del kernel per la rete **10.99.99.0/24**, digitare:

    ```bash
    ip route show 10.99.99.0/24
    ```

3. Interrogare il sistema per vedere il percorso che verrà utilizzato per raggiungere una destinazione arbitraria di esempio. Ad esempio, per visualizzare i dettagli del percorso per raggiungere l'indirizzo IP di destinazione **8.8.8.8**, digitare:

    ```bash
    ip route get 8.8.8.8
    8.8.8.8 via 192.168.2.1 dev enp1s0 src 192.168.2.121 uid 0
    cache
    ```

    Ecco una spiegazione dettagliata dei risultati in parole semplici:

    - *Indirizzo IP di destinazione*: **8.8.8.8** è l'indirizzo IP che stiamo cercando di raggiungere
    - *Via*: **192.168.2.1** è l'indirizzo IP del prossimo hop a cui verrà inviato il pacchetto per raggiungere la destinazione.
    - *Dispositivo*: **enp1s0** è l'interfaccia di rete che verrà utilizzata per inviare il pacchetto
    - *Indirizzo IP di origine*: **192.168.2.121** è l'indirizzo IP dell'interfaccia di rete che verrà utilizzato come indirizzo di origine per il pacchetto.
    - *UID*: **0** è l'ID utente del processo che ha avviato questo comando
    - *Cache*: questo campo indica se questo percorso è memorizzato nella cache della tabella di routing del kernel.

4. Vediamo ora come il sistema instraderà un pacchetto da un indirizzo IP a un altro indirizzo IP di destinazione. Digitare:

    ```bash
    ip route get from 192.168.1.1 to 192.168.1.2

    local 192.168.1.2 from 192.168.1.1 dev lo uid 0
    cache <local>
    ```

#### Configurazione del gateway predefinito per il sistema

In un sistema Linux, il gateway predefinito rappresenta il punto di accesso predefinito attraverso il quale il traffico di rete viene instradato verso reti esterne non collegate direttamente all'interfaccia locale. La sua corretta configurazione è essenziale per garantire la connettività di un sistema a reti remote e servizi esterni.

1. Utilizzare `ip` per cercare ed elencare il gateway predefinito corrente sul sistema. Digitare:

    ```bash
     ip route show default
    ```

2. Impostare un gateway predefinito tramite l'interfaccia `macvtap1`. Digitare:

    ```bash
    ip route add default via 192.168.1.1
    ```

3. Verificare la nuova configurazione del gateway predefinito

    ```bash
    ip route show default
    ```

#### Aggiungere una route statica alla tabella di routing

1. Aggiungere una route statica demo per una rete fittizia  **172.16.0.0/16** tramite **192.168.1.2**. Digitare:

    ```bash
    ip route add 172.16.0.0/16 via 192.168.1.2
    ```

2. Verificare l'aggiunta della route statica eseguendo:

    ```bash
    ip route show 172.16.0.0/16
    ```

#### Rimuovere una route statica dalla tabella di routing

1. Elimina la route statica per **10.0.0.0/24**

    ```bash
    ip route del 10.0.0.0/24 via 192.168.1.2
    ```

2. Verificare la rimozione della route statica

    ```bash
    ip route show
    ```

### 6. Cancellare un indirizzo IP

La rimozione degli indirizzi IP dal server è un'operazione fondamentale per la gestione della sicurezza e delle risorse di rete. Questa procedura può essere necessaria per diversi motivi: mitigare gli attacchi DDoS, revocare l'accesso agli utenti malintenzionati, liberare indirizzi IP non più in uso o rispettare le politiche di sicurezza aziendali. Questa esercitazione illustra come eliminare gli indirizzi IP configurati (*IPv4* e *IPv6*) sulle interfacce di rete.

#### Rimuovere un indirizzo IPv4 assegnato da un'interfaccia di rete

1. Eliminare l'indirizzo IP su `macvtap1`. Digitare:

    ```bash
    ip address del 172.16.99.100/24 dev macvtap1
    ```

2. Verificare la rimozione dell'indirizzo IP eseguendo:

    ```bash
    ip address show macvtap1
    ```

#### Rimuovere un indirizzo IPv6 assegnato da un'interfaccia di rete

1. Eliminare l'indirizzo IPv6 su `macvtap1` con questo comando:

    ```bash
    ip -6 address del 2001:db8::1/64 dev macvtap1
    ```

2. Verificare la rimozione dell'indirizzo IPv6 con:

    ```bash
    ip -6 address show macvtap1
    ```

### 7. Configurazione delle interfacce di rete con `nmcli`

Il comando `nmcli` (*Interfaccia della riga di comando di NetworkManager*) è uno strumento per la gestione delle connessioni di rete. Progettato per interagire con *NetworkManager*, consente di controllare, configurare e monitorare in modo efficiente le reti direttamente dal terminale, senza la necessità di interfacce grafiche.  
Questo esercizio mostra come configurare le interfacce di rete utilizzando gli strumenti NetworkManager.

!!! Note "Nota"

    Per impostazione predefinita, qualsiasi modifica alla configurazione di rete effettuata utilizzando `nmcli` (NetworkManager) rimarrà attiva anche dopo il riavvio del sistema.
    Ciò contrasta con le modifiche di configurazione effettuate con l'utilità `ip`.

#### Creare un'interfaccia `macvtap` utilizzando `nmcli`

1. Iniziare elencando tutti i dispositivi di rete disponibili eseguendo:

    ```bash
    nmcli device
    ```

2. Successivamente, identificare un dispositivo di rete sottostante a cui associare la nuova interfaccia *MACVTAP*. Memorizzare il valore del dispositivo identificato nella variabile `$DEVICE2`. Digitare:

    ```bash
    DEVICE2=$(ls -l /sys/class/net/ | grep -v 'virtual\|total' | tail -n 1 | awk '{print $9}')
    ```

3. Ora, creare una nuova connessione *NetworkManager* chiamata `macvtap2` e un'interfaccia MACVTAP associata denominata - `macvtap2`. La nuova interfaccia sarà associata a `$DEVICE2`. Digitare:

    ```bash
    nmcli con add con-name macvtap2 type macvlan mode bridge tap yes dev $DEVICE2 ifname macvtap2
    ```

4. Utilizzare `nmcli` per verificare la creazione dell'interfaccia `macvtap2`. Digitare:

    ```bash
    nmcli device show macvtap2
    ```

5. Utilizzare `nmcli` per verificare la creazione della connessione `macvtap2`. Digitare:

    ```bash
    nmcli connection show macvtap2
    ```

6. Allo stesso modo, utilizzare `ip` per verificare la creazione dell'interfaccia `macvtap2`. Digitare:

    ```bash
    ip --brief link show macvtap2
    ```

    Notare lo stato **UP** dell'output dell'interfaccia `macvtap`.

    !!! question "Domanda"

     Qual è la differenza tra il concetto di *connessione* e quello di *dispositivo* in NetworkManager?

#### Modificare la configurazione di rete dell'interfaccia con `nmcli`

1. Inizia interrogando l'indirizzo  *IPv4* per la nuova interfaccia `macvtap2` eseguendo:

    ```bash
    nmcli -f ipv4.addresses con show macvtap2
    ```

    Il valore della proprietà **ipv4.addresses** dovrebbe essere vuoto.

2. Configurare la connessione `macvtap2` con queste impostazioni:

    - *IPv4 Method* =  **manual**
    - *IPv4 Addresses* =  **172.16.99.200/24**
    - *Gateway* = **172.16.99.1**
    - *DNS Servers*  = **8.8.8.8 and 8.8.4.4**
    - *DNS Search domain* = **example.com**

    Digitare:

    ```bash
    nmcli connection modify macvtap2  ipv4.method manual \
    ipv4.addresses 172.16.99.200/24 ipv4.gateway 172.16.99.1 \
    ipv4.dns 8.8.8.8,8.8.4.4 ipv4.dns-search example.com
    ```

3. Verificare la nuova impostazione dell'indirizzo IPv4 eseguendo:

    ```bash
    nmcli -f ipv4.addresses con show macvtap2
    ```

4. Eseguire una variante leggermente diversa del comando precedente per includere la configurazione di runtime delle impostazioni specificate. Digitare:

    ```bash
    nmcli -f ipv4.addresses,IP4.ADDRESS con show macvtap2
    ```

    !!! question "Domanda"

     Qual è la differenza tra queste proprietà di NetworkManager: ipv4.addresses e IP4.ADDRESS?

5. Controllare le modifiche alla connessione di rete utilizzando il comando `ip`. Digitare:

    ```bash
    ip -br address show dev macvtap2
    ```

6. Per applicare correttamente le nuove impostazioni e renderle i nuovi valori di runtime, utilizzare `nmcli` per spegnere prima la connessione (cioè disattivarla). Digitare:

    ```bash
    nmcli connection down macvtap2

    Connection macvtap2 successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/5)
    ```

7. Ora attivare la nuova connessione per applicare le nuove impostazioni. Digitare:

    ```bash
    nmcli connection up macvtap2

    Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/6)
    ```

8. Visualizzare l'impostazione finale utilizzando l'utility `ip`. Digitare:

    ```bash
    ip -br address show  dev macvtap2
    ```

### 8. Configurazione dei server DNS

Il servizio **DNS** (*Domain Name System*) è una componente fondamentale delle reti informatiche, responsabile della risoluzione dei *nomi di dominio* in *indirizzi IP* e viceversa. Ciò consente la comunicazione all'interno delle reti locali e su Internet.

#### Identificare e risolvere i problemi di rete più comuni

1. Configurare i server DNS per `macvtap1`

    ```bash
    nmcli con mod macvtap1 ipv4.dns 8.8.8.8, 8.8.4.4
    ```

2. Verificare la configurazione del server DNS

    ```bash
    nmcli con show macvtap1 | grep DNS
    ```

### 9. Risoluzione dei problemi di rete

Le reti informatiche sono fondamentali per la comunicazione e lo scambio di dati, ma spesso incontrano problemi che ne ostacolano il corretto funzionamento. Diversi fattori, tra cui errori di configurazione, guasti hardware o interferenze con le connessioni, possono causare questi malfunzionamenti.

#### Identificare e risolvere i problemi di rete più comuni

Il monitoraggio e la verifica dello stato delle interfacce di rete sono essenziali per garantire il corretto funzionamento di un sistema connesso.

1. Controllare lo stato delle interfacce di rete

    ```bash
    ip link show
    ```

Questo passaggio consente di verificare se un dispositivo è in grado di raggiungere un altro nodo sulla rete, che si tratti di un server, un router o un altro client.

2. Verificare la connettività di rete a un host remoto (ad esempio,  *google.com*)

    ```bash
    ping google.com
    ```

Il ping del gateway locale è un test essenziale per garantire che la connessione tra un dispositivo e il suo router predefinito funzioni correttamente. Il gateway è il punto di accesso alle reti esterne e un malfunzionamento in questa fase può impedire l'accesso a Internet o ad altre sottoreti.

3. Provare a eseguire il ping del gateway locale. Digitare:

    ```bash
    ping _gateway
    ```

    !!! question "Domanda"

     Attraverso quale meccanismo il tuo sistema è in grado di risolvere correttamente il nome '_gateway' all' *indirizzo IP* corretto per il tuo *gateway predefinito* configurato localmente?

#### Visuare le Connessioni Attive

Le connessioni di rete attive rappresentano canali di comunicazione aperti tra il computer e altri dispositivi o servizi sulla rete. Queste connessioni possono essere locali (all'interno della stessa macchina) o remote (a server o client esterni).

#### Elenco di tutte le connessioni di rete attive

1. Elencare tutte le connessioni di rete attive

    ```bash
    ss -tuln
    ```

#### Monitoraggio del traffico di rete

Il traffico di rete in Linux rappresenta l'insieme dei dati scambiati tra un sistema e la rete, sia in entrata che in uscita. Questo flusso di informazioni è essenziale per il funzionamento di servizi quali il web, la posta elettronica, il trasferimento di file e la comunicazione tra dispositivi. Il monitoraggio e la gestione di queste informazioni sono fondamentali per garantire la sicurezza, il debug e l'ottimizzazione delle prestazioni della rete.

#### Monitorare il traffico di rete in tempo reale

1. Catturare il traffico di rete su un'interfaccia specifica (ad esempio, `macvtap1`)

    ```bash
    tcpdump -i macvtap1
    ```

    Analizzare i pacchetti catturati e osservare l'attività di rete. È possibile interrompere l'acquisizione dei pacchetti al termine dell'operazione premendo ++ctrl+c++

#### Visualizzare i Log di rete

I log di rete sono essenziali per il monitoraggio, la risoluzione dei problemi e la sicurezza del sistema. Ogni volta che un pacchetto di dati viene inviato o ricevuto sulla rete, il sistema operativo registra informazioni dettagliate su queste attività. Questi log aiutano gli amministratori di sistema a identificare connessioni sospette, errori di configurazione e potenziali minacce alla sicurezza.

#### Visualizzare i log del daemon NetworkManager per la risoluzione dei problemi

1. Visualizzare i registri relativi alla rete

    ```bash
    journalctl -u NetworkManager
    ```
