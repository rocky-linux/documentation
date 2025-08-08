---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tested on: All Versions
tags:
  - lab exercise
  - networking
  - nmcli
  - ip
  - iproute2
  - macvtap
---


# Laboratorio 5: Nozioni di base sulla rete

## Obiettivi

Dopo aver completato questo laboratorio, si sarà in grado di:

- Creare dispositivi di rete virtuali
- Gestire i dispositivi di rete e le impostazioni su un sistema Linux utilizzando il toolkit `iproute2` (`ip`)
- Gestire i dispositivi di rete e le impostazioni su un sistema Linux utilizzando il toolkit NetworkManager (`nmcli`)
- Risolvere i problemi di rete più comuni

Tempo stimato per completare questo laboratorio: 60 minuti

## Sommario

Questo laboratorio Networking Essentials copre vari esercizi di configurazione e risoluzione dei problemi di rete su un server Linux. Potrete gestire e risolvere i problemi relativi alle impostazioni di rete in modo più efficace utilizzando le comuni utility di rete disponibili sui sistemi basati su Linux.

## Esercizio 1

### Cambiare il nome del host

Esistono molti metodi per identificare o fare riferimento ai computer. Alcuni di questi metodi garantiscono l'unicità [soprattutto su una rete], altri no. Il nome host di un computer può essere considerato come un nome intuitivo. I nomi host dei computer dovrebbero idealmente essere univoci a seconda di come vengono gestiti e assegnati. Tuttavia, poiché chiunque disponga dei privilegi amministrativi su un sistema può assegnare unilateralmente qualsiasi nome host desideri al sistema, l'unicità non è sempre garantita.

Questo primo esercizio illustra alcuni strumenti comuni per la gestione del nome host del computer.

#### Per modificare il nome host del sistema

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
    
         Consultare la pagina man di `hostnamectl`. Quali sono le differenze tra nomi host pretty, transitori e statici?

## Esercizio 2

Il primo passo fondamentale da completare prima di passare agli altri esercizi di questo laboratorio di rete sarà la creazione di una speciale interfaccia di rete virtuale nota come dispositivo MACVTAP.

I dispositivi MACVTAP sono dispositivi virtuali che combinano le proprietà di un'interfaccia esclusivamente software nota come dispositivo TAP con quelle del driver MACVLAN.

La creazione e l'utilizzo di questi dispositivi MACVTAP consentirà di testare, modificare e configurare in modo sicuro varie attività relative alla configurazione di rete. Queste interfacce di rete virtuali saranno utilizzate in varie esercitazioni senza interferire con la configurazione di rete esistente.

!!! tip "Suggerimento"

    I dispositivi TAP forniscono un'interfaccia esclusivamente software a cui le applicazioni dello spazio utente possono accedere facilmente. I dispositivi TAP inviano e ricevono frame Ethernet non elaborati. 
    MACVLAN viene utilizzato per creare interfacce di rete virtuali che si collegano alle interfacce di rete fisiche. 
    I dispositivi MACVTAP hanno un proprio indirizzo MAC unico, distinto dall'indirizzo MAC della scheda di rete fisica sottostante a cui sono associati.

### Creazione interfacce MACVTAP

Questo esercizio inizia con la creazione delle interfacce di rete virtuali MACVTAP necessarie. Ciò consentirà di testare, modificare e configurare in modo sicuro varie attività relative alla configurazione di rete. Queste interfacce di rete virtuali saranno utilizzate in varie esercitazioni senza interferire con la configurazione di rete esistente.

#### Per elencare tutte le interfacce di rete presenti nel sistema

1. Assicurarsi di aver effettuato l'accesso al server.

2. Utilizzare il programma `ip` per visualizzare le interfacce di rete esistenti sul sistema. Digitare:

    ```bash
    ip link show
    ```

3. Provare ad utilizzare il comando `nmcli` per elencare tutti i dispositivi di rete. Digitare:

    ```bash
     nmcli -f DEVICE device
    ```

4. Interrogare il file system virtuale di basso livello /sys per enumerare manualmente TUTTE le interfacce di rete disponibili sul server. Digitare:

    ```bash
     ls -l /sys/class/net/ | grep -v 'total' | awk '{print $9}'
    ```

#### Per creare interfacce `macvtap`

1. Assicurarsi di aver effettuato l'accesso al sistema come utente con privilegi amministrativi.

2. È necessario interrogare e identificare i tipi di dispositivi di rete appropriati disponibili sul server per poterli associare al dispositivo `macvtap`. Digitare:

    ```bash
     ls -l /sys/class/net/ | grep -v 'virtual\|total' | tail -n 1 | awk '{print $9}'

     eno2
    ```

    L'output sul sistema demo di esempio mostra un'interfaccia adatta denominata eno2.

3. Eseguire nuovamente il comando per identificare il dispositivo, ma questa volta memorizzare il valore restituito in una variabile denominata $DEVICE1. Controllare nuovamente il valore di $DEVICE1 utilizzando echo. Per eseguire questa operazione, digitare i seguenti 2 comandi separati:

    ```bash
    # DEVICE1=$(ls -l /sys/class/net/ | grep -v 'virtual\|total' | tail -n 1 | awk '{print $9}')

    # echo $DEVICE1
    ```

4. Ora, creare un'interfaccia MACVTAP denominata - `macvtap1`. La nuova interfaccia sarà associata a $DEVICE1. Digitare:

    ```bash
    ip link add link $DEVICE1 name macvtap1 type macvtap mode bridge
    ```

5. Verificare la creazione dell'interfaccia `macvtap1`. Digitare:

    ```bash
    ip --brief link show macvtap1
    ```

    Notare lo stato DOWN dell'interfaccia `macvtap` nell'output.

6. Visualizzare le informazioni dettagliate su tutti i dispositivi di rete di tipo MACVTAP presenti nel sistema. Digitare:

    ```bash
    ip --detail link show type macvtap
    ```

7. Eseguire un comando per visualizzare tutte le interfacce di rete sul server e confrontare il risultato con quello ottenuto dal comando simile nella sezione precedente "Per elencare tutte le interfacce di rete sul sistema".

### Abilitazione/Disabilitazione delle interfacce di rete

#### Per abilitare o disabilitare un'interfaccia di rete

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
    ip -br  link show macvtap1
    ```

    !!! tip "Suggerimento"

     Nel caso in cui sia necessario disabilitare un'interfaccia di rete, la sintassi del comando `ip` per farlo è `ip link set <IFNAME> down`. Ad esempio, per disabilitare un'interfaccia di rete denominata `macvtap7`, è necessario eseguire:

        ```bash
        ip link set macvtap7 down
        ```

Ora che sono state configurate le interfacce `macvtap`, è possibile eseguire in modo sicuro le varie attività di configurazione della rete e di risoluzione dei problemi negli esercizi rimanenti.

## Esercizio 3

### Assegnazione degli indirizzi IP

#### Per impostare un indirizzo IP su un'interfaccia di rete

1. Visualizzare gli indirizzi IP di tutte le interfacce di rete sul server. Digitare:

    ```bash
    ip address show   
    ```

2. Assegnare l'indirizzo IP - 172.16.99.100 - a `macvtap1`. Digitare

    ```bash
    ip address add 172.16.99.100/24 dev macvtap1    
    ```

3. Verificare l'assegnazione dell'indirizzo IP per `macvtap1`

    ```bash
    ip address show macvtap1
    ```

4. Utilizzare il comando `nmcli` per visualizzare gli indirizzi IPv4 di tutte le interfacce presenti nel sistema. Digitare:

    ```bash
    nmcli --get-values IP4.ADDRESS,GENERAL.DEVICE  device show  
    ```

## Esercizio 4

### Configurazione degli indirizzi IPv6

#### Per assegnare indirizzi IPv6 alle interfacce `macvtap`

1. Partendo da `macvtap1`, assegnare l'indirizzo IPv6 2001:db8::1/64 a `macvtap1` eseguendo:

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

## Esercizio 5

### Gestione del routing

#### Visualizzazione della tabella di routing del sistema

1. Visualizzare la tabella di routing corrente per il sistema. Digitare:

    ```bash
    ip route show
    default via 192.168.2.1 dev enp1s0 proto dhcp src 192.168.2.121 metric 100
    10.99.99.0/24 dev tunA proto kernel scope link src 10.99.99.1 metric 450 linkdown
    192.168.2.0/24 dev enp1s0 proto kernel scope link src 192.168.2.121 metric 100
    ```

2. Utilizzando una delle reti visualizzate nella colonna più a sinistra dell'output del comando precedente come argomento, visualizzare la voce della tabella di routing per quella rete. Ad esempio, per visualizzare la voce della tabella di routing del kernel per la rete 10.99.99.0/24, digitare:

    ```bash
    ip route show 10.99.99.0/24
    ```

3. Interrogare il sistema per vedere il percorso che verrà utilizzato per raggiungere una destinazione arbitraria di esempio. Ad esempio, per visualizzare i dettagli del percorso per raggiungere l'indirizzo IP di destinazione 8.8.8.8, digitare:

    ```bash
    ip route get 8.8.8.8

    8.8.8.8 via 192.168.2.1 dev enp1s0 src 192.168.2.121 uid 0
    cache
    ```

    Ecco una spiegazione dettagliata dei risultati in parole semplici:

    - Indirizzo IP di destinazione: 8.8.8.8 è l'indirizzo IP che stiamo cercando di raggiungere
    - Via: 192.168.2.1 è l'indirizzo IP del prossimo hop a cui verrà inviato il pacchetto per raggiungere la destinazione
    - Dispositivo: `enp1s0` è l'interfaccia di rete che verrà utilizzata per inviare il pacchetto
    - Indirizzo IP di origine: 192.168.2.121 è l'indirizzo IP dell'interfaccia di rete che verrà utilizzato come indirizzo di origine per il pacchetto
    - UID: 0 è l'ID utente del processo che ha avviato questo comando
    - Cache: questo campo indica se questo percorso è memorizzato nella tabella di routing del kernel

4. Vediamo ora come il sistema instraderà un pacchetto da un indirizzo IP a un altro indirizzo IP di destinazione. Digitare:

    ```bash
    ip route get from 192.168.1.1 to 192.168.1.2

    local 192.168.1.2 from 192.168.1.1 dev lo uid 0
    cache <local>
    ```

### Impostazione del gateway predefinito

#### Per configurare un gateway predefinito per il sistema

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

### Aggiunta di un percorso statico

#### Per aggiungere una route statica alla tabella di routing

1. Aggiungere una route statica demo per una rete fittizia 172.16.0.0/16 tramite 192.168.1.2. Digitare:

    ```bash
    ip route add 172.16.0.0/16 via 192.168.1.2
    ```

2. Verificare l'aggiunta della route statica eseguendo:

    ```bash
    ip route show 172.16.0.0/16
    ```

### Rimozione del percorso statico

#### Per rimuovere una route statica dalla tabella di routing

1. Eliminare la route statica per 10.0.0.0/24

    ```bash
    ip route del 10.0.0.0/24 via 192.168.1.2
    ```

2. Verificare la rimozione della route statica

    ```bash
    ip route show
    ```

## Esercizio 6

### Rimozione degli indirizzi IP

Questo esercizio illustra come eliminare gli indirizzi IP configurati (IPv4 e IPv6) sulle interfacce di rete.

### Eliminare un indirizzo IPv4

#### Per rimuovere un indirizzo IP assegnato da un'interfaccia di rete

1. Eliminare l'indirizzo IP su `macvtap1`. Digitare:

    ```bash
    ip address del 172.16.99.100/24 dev macvtap1
    ```

2. Verificare la rimozione dell'indirizzo IP eseguendo:

    ```bash
    ip address show macvtap1
    ```

### Eliminare un indirizzo IPv6

#### Per rimuovere un indirizzo IPv6 assegnato da un'interfaccia di rete

1. Eliminare l'indirizzo IPv6 su `macvtap1` con questo comando:

    ```bash
    ip -6 address del 2001:db8::1/64 dev macvtap1
    ```

2. Verificare la rimozione dell'indirizzo IPv6 con:

    ```bash
    ip -6 address show macvtap1
    ```

## Esercizio 7

### Configurazione delle interfacce di rete con `nmcli`

Questo esercizio mostra come configurare le interfacce di rete utilizzando lo strumento NetworkManager.

!!! note "Nota"

    Per impostazione predefinita, qualsiasi modifica alla configurazione di rete effettuata utilizzando `nmcli` (NetworkManager) rimarrà attiva anche dopo il riavvio del sistema.
    Ciò contrasta con le modifiche di configurazione effettuate con l'utilità `ip`.

#### Per creare un'interfaccia `macvtap` utilizzando `nmcli`

1. Iniziare elencando tutti i dispositivi di rete disponibili eseguendo:

    ```bash
    nmcli device
    ```

2. Successivamente, identificare un dispositivo di rete sottostante a cui associare la nuova interfaccia MACVTAP. Memorizzare il valore del dispositivo identificato nella variabile $DEVICE2. Digitare:

    ```bash
    DEVICE2=$(ls -l /sys/class/net/ | grep -v 'virtual\|total' | tail -n 1 | awk '{print $9}')
    ```

3. Ora, creare una nuova connessione NetworkManager chiamata `macvtap2` e un'interfaccia MACVTAP associata denominata - `macvtap2`. La nuova interfaccia sarà associata a $DEVICE2. Digitare:

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

    Notare lo stato UP dell'output dell'interfaccia `macvtap`.

    !!! question "Domanda"

     Qual è la differenza tra il concetto di connessione e quello di dispositivo in NetworkManager?

#### Modifica della configurazione di rete dell'interfaccia con `nmcli`

1. Inizia interrogando l'indirizzo IPv4 per la nuova interfaccia `macvtap2` eseguendo:

    ```bash
    nmcli -f ipv4.addresses con show macvtap2
    ```

    Il valore della proprietà ipv4.addresses dovrebbe essere vuoto.

2. Configurare la connessione `macvtap2` con queste impostazioni:

    - IPv4 Method =  manual
    - IPv4 Addresses =  172.16.99.200/24
    - Gateway = 172.16.99.1
    - DNS Servers  = 8.8.8.8 and 8.8.4.4
    - DNS Search domain = example.com

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
    ip -br address show  dev macvtap2
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

8. Visualizzare l'impostazione finale utilizzando l'utilità ip. Digitare:

    ```bash
    ip -br address show  dev macvtap2
    ```

## Esercizio 8

### Configurazione dei server DNS

#### Per impostare gli indirizzi dei server DNS per il sistema

1. Configurare i server DNS per `macvtap1`

    ```bash
    nmcli con mod macvtap1 ipv4.dns 8.8.8.8, 8.8.4.4
    ```

2. Verificare la configurazione del server DNS

    ```bash
    nmcli con show macvtap1 | grep DNS
    ```

## Esercizio 9

### Risoluzione dei problemi di rete

#### Identificare e risolvere i problemi di rete più comuni

1. Controllare lo stato delle interfacce di rete

    ```bash
    ip link show
    ```

2. Verificare la connettività di rete a un host remoto (ad esempio, google.com)

    ```bash
    ping google.com
    ```

3. Provare ad eseguire il ping del gateway locale. Digitare:

    ```bash
    ping _gateway
    ```

    !!! question "Domanda"

     Attraverso quale meccanismo il sistema è in grado di risolvere correttamente il nome "_gateway" nell'indirizzo IP corretto per il gateway predefinito configurato localmente?

### Visualizzazione delle connessioni attive

#### Per elencare tutte le connessioni di rete attive

1. Elencare tutte le connessioni di rete attive

    ```bash
    ss -tuln
    ```

### Monitoraggio del traffico di rete

#### Per monitorare il traffico di rete in tempo reale

1. Catturare il traffico di rete su un'interfaccia specifica (ad esempio, `macvtap1`)

    ```bash
    tcpdump -i macvtap1
    ```

    Analizzare i pacchetti catturati e osservare l'attività di rete. È possibile interrompere l'acquisizione dei pacchetti al termine dell'operazione premendo ++ctrl+c++

### Visualizzazione dei registri di rete

#### Per visualizzare i log relativi al demone NetworkManager per la risoluzione dei problemi

1. Visualizzare i registri relativi alla rete

    ```bash
    journalctl -u NetworkManager
    ```
