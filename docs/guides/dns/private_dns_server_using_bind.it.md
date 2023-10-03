---
title: Bind del Server DNS Privato
author: Steven Spencer
contributors: Ezequiel Bruni, k3ym0, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - dns
  - bind
---

# Server DNS privato con `bind`

## Prerequisiti e presupposti

* Un server con Rocky Linux
* Alcuni server interni che necessitano solo di un accesso locale, non tramite Internet
* Diverse postazioni di lavoro che devono accedere agli stessi server presenti sulla stessa rete
* Un buon livello di confidenza con l'inserimento di comandi dalla riga di comando
* Familiarità con un editor a riga di comando ( in questo esempio si usa _vi_)
* In grado di utilizzare _firewalld_ per la creazione di regole del firewall

## Introduzione

I server DNS esterni, o pubblici, mappano gli hostname in indirizzi IP e, nel caso dei record PTR (noti come "pointer" o "reverse"), mappano gli indirizzi IP in hostname. Si tratta di una parte essenziale di Internet. Fa sì che il server di posta, il server web, il server FTP o molti altri server e servizi funzionino come previsto, indipendentemente da dove ci si trovi.

Su una rete privata, in particolare una rete per lo sviluppo di molti sistemi, è possibile utilizzare il file */etc/hosts* della propria workstation Rocky Linux per mappare un nome a un indirizzo IP.

Questo funzionerà per _la vostra workstation_, ma non per qualsiasi altro computer della rete. Il metodo migliore per rendere le cose universalmente applicabili è quello di prendersi un po' di tempo e creare un server DNS locale e privato per gestire questo aspetto per tutti i vostri computer.

Supponiamo di creare server e resolver DNS pubblici a livello di produzione. In questo caso, l'autore raccomanda il più robusto [PowerDNS](https://www.powerdns.com/) DNS autorevole e ricorsivo, installabile sui server Rocky Linux. Tuttavia, questo documento si riferisce a una rete locale che non espone i propri server DNS al mondo esterno. Ecco perché l'autore ha scelto `bind` per questo esempio.

### Spiegazione dei componenti del server DNS

Il DNS separa i servizi in server autoritari e ricorsivi. Attualmente si consiglia di separare questi servizi su hardware o container distinti.

Il server autorevole è l'area di archiviazione di tutti gli indirizzi IP e i nomi host, mentre il server ricorsivo cerca gli indirizzi e i nomi host. Nel caso del nostro server DNS privato, i servizi di server autorevole e ricorsivo lavoreranno insieme.

## Installazione e abilitazione di `bind`

Il primo passo è l'installazione dei pacchetti:

```
dnf install bind bind-utils
```

_bind_ è il demone di servizio di `named`. Abilitare l'avvio al boot:

```
systemctl enable named
```

Avviare `named`:

```
systemctl start named
```

## Configurazione

Prima di apportare modifiche a qualsiasi file di configurazione, creare una copia di backup del file di lavoro originale installato, _named.conf_:

```
cp /etc/named.conf /etc/named.conf.orig
```

Questo aiuterà in futuro se si verificano errori nel file di configurazione. È *sempre* una buona idea fare una copia di backup prima di apportare modifiche.

Modificare il file _named.conf_. L'autore utilizza _vi_ , ma è possibile sostituire l'editor a riga di comando preferito:

```
vi /etc/named.conf
```

Disattivare l'ascolto su localhost. Per farlo, contrassegnate con il segno "#" queste due righe nella sezione "options". In questo modo si interrompe qualsiasi connessione con il mondo esterno.

Questo è utile, soprattutto quando si aggiunge questo DNS alle nostre postazioni di lavoro, perché si vuole che il server DNS risponda solo quando l'indirizzo IP che richiede il servizio è locale e non reagisca se il server o il servizio si trova su Internet.

In questo modo, gli altri server DNS configurati subentreranno quasi immediatamente per cercare i servizi basati su Internet:

```
options {
#       listen-on port 53 { 127.0.0.1; };
#       listen-on-v6 port 53 { ::1; };
```

Infine, si può andare in fondo al file *named.conf* e aggiungere una sezione per la vostra rete. Il nostro esempio è "ourdomain", quindi inserite il nome che volete dare agli host della vostra LAN:

```
# primary forward and reverse zones
//forward zone
zone "ourdomain.lan" IN {
     type master;
     file "ourdomain.lan.db";
     allow-update { none; };
    allow-query {any; };
};
//reverse zone
zone "1.168.192.in-addr.arpa" IN {
     type master;
     file "ourdomain.lan.rev";
     allow-update { none; };
    allow-query { any; };
};
```

Salvare le modifiche (per _vi_, `SHIFT:wq!`)

## I record di forward e reverse

È necessario creare due file in `/var/named`. Questi file verranno modificati se si aggiungono macchine alla rete per includerle nel DNS.

Il primo è il file forward per mappare il nostro indirizzo IP al nome dell'host. Anche in questo caso, il nostro esempio è "ourdomain". Si noti che l'IP del nostro DNS locale è 192.168.1.136. Aggiungere gli host in fondo a questo file.

```
vi /var/named/ourdomain.lan.db
```

Una volta completato, il file avrà un aspetto simile a questo:

```
$TTL 86400
@ IN SOA dns-primary.ourdomain.lan. admin.ourdomain.lan. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)

;Name Server Information
@ IN NS dns-primary.ourdomain.lan.

;IP for Name Server
dns-primary IN A 192.168.1.136

;A Record for IP address to Hostname
wiki IN A 192.168.1.13
www IN A 192.168.1.14
devel IN A 192.168.1.15
```

Aggiungere tutti gli host e gli indirizzi IP necessari e salvare le modifiche.

È necessario un file reverse per mappare il nostro hostname all'indirizzo IP. In questo caso, l'unica parte dell'IP di cui si ha bisogno è l'ultimo ottetto (in un indirizzo IPv4 ogni numero separato da un "." è un ottetto) dell'host, il PTR e l'hostname.

```
vi /var/named/ourdomain.lan.rev
```

Una volta completato, il file avrà un aspetto simile a questo:

```
$TTL 86400
@ IN SOA dns-primary.ourdomain.lan. admin.ourdomain.lan. (
    2019061800 ;Serial
    3600 ;Refresh
    1800 ;Retry
    604800 ;Expire
    86400 ;Minimum TTL
)
;Name Server Information
@ IN NS dns-primary.ourdomain.lan.

;Reverse lookup for Name Server
136 IN PTR dns-primary.ourdomain.lan.

;PTR Record IP address to HostName
13 IN PTR wiki.ourdomain.lan.
14 IN PTR www.ourdomain.lan.
15 IN PTR devel.ourdomain.lan.
```

Aggiungere tutti i nomi di host presenti nel file forward e salvare le modifiche.

### Cosa significa tutto questo

Dal momento che tutto questo è stato aggiunto e ci si sta preparando a riavviare il nostro server DNS _bind_, esploriamo alcune delle terminologie utilizzate in questi due file.

Far funzionare le cose non è sufficiente se non si conosce il significato di ogni termine, giusto?

* **TTL** sta per "Time To Live". Il TTL indica al server DNS per quanto tempo conservare la cache prima di richiederne una nuova copia. In questo caso, il TTL è l'impostazione predefinita per tutti i record, a meno che non si inserisca manualmente un TTL specifico. L'impostazione predefinita è 86400 secondi o 24 ore.
* **IN** sta per Internet. In questo caso, Internet non viene utilizzato. Consideratela invece come una Intranet.
* **SOA** sta per "Start Of Authority" o per il server DNS primario del dominio
* **NS** sta per "name server"
* **Serial** è il valore utilizzato dal server DNS per verificare che il contenuto del file di zona sia aggiornato
* **Refresh** specifica la frequenza con cui un server DNS slave richiede il trasferimento di una zona dal server master
* **Retry** specifica il tempo di attesa, in secondi, prima di ritentare un trasferimento di zona non riuscito
* **Expire** specifica quanto tempo un server slave aspetterà per rispondere a una query quando il master non è raggiungibile
* **A** È l'indirizzo host o il record di inoltro e si trova solo nel file di inoltro
* **PTR** Il record del puntatore è meglio conosciuto come "reverse " e si trova solo nel nostro file reverse

## Test della configurazione

Una volta creati tutti i file, è necessario assicurarsi che i file di configurazione e le zone siano in ordine prima di avviare nuovamente il servizio _bind_.

Controllare la configurazione principale:

```
named-checkconf
```

Questo restituirà un risultato vuoto se tutto è a posto.

Controllare la zona forward:

```
named-checkzone ourdomain.lan /var/named/ourdomain.lan.db
```

Se tutto è a posto, si ottiene un risultato simile a questo:

```
zone ourdomain.lan/IN: loaded serial 2019061800
OK
```

Infine, controllare la zona reverse:

```
named-checkzone 192.168.1.136 /var/named/ourdomain.lan.rev
```

Che restituirà qualcosa di simile se tutto è a posto:

```
zone 192.168.1.136/IN: loaded serial 2019061800
OK
```

Se tutto sembra a posto, riavviare _bind_:

```
systemctl restart named
```

=== "9"

    ## 9 usare IPv4 sulla LAN
    
    Per utilizzare SOLO IPv4 sulla LAN, è necessario apportare una modifica in `/etc/sysconfig/named`:

    ```
    vi /etc/sysconfig/named
    ```


    Aggiungete questo alla fine del file:

    ```
    OPTIONS="-4"
    ```


    Salvare le modifiche.
    
    ## 9 Macchine di prova
    
    
    È necessario aggiungere il server DNS (nel nostro esempio 192.168.1.136) a ogni macchina che si desidera abbia accesso ai server aggiunti al DNS locale. L'autore mostra solo un esempio di come farlo su una workstation Rocky Linux. Metodi simili esistono per altre distribuzioni Linux, Windows e Mac.
    
    È necessario aggiungere i server DNS all'elenco, non sostituire quelli attualmente presenti, in quanto sarà comunque necessario l'accesso a Internet, che richiederà i server DNS attualmente assegnati. I servizi DHCP (Dynamic Host Configuration Protocol) in genere li assegnano o sono assegnati staticamente.
    
    Si aggiungerà il nostro DNS locale con `nmcli` e poi si riavvierà la connessione. 
    
    ??? warning ""Nomi di profilo stupidi""
    
        In NetworkManager, le connessioni non vengono modificate dal nome del dispositivo, ma dal nome del profilo. Può trattarsi di "Connessione cablata 1" o "Connessione wireless 1". È possibile vedere il profilo eseguendo `nmcli` senza alcun parametro:

        ```
        nmcli
        ```


        Verrà visualizzato un risultato come:

        ```bash
        enp0s3: connected to Wired Connection 1
        "Intel 82540EM"
        ethernet (e1000), 08:00:27:E4:2D:3D, hw, mtu 1500
        ip4 default
        inet4 192.168.1.140/24
        route4 192.168.1.0/24 metric 100
        route4 default via 192.168.1.1 metric 100
        inet6 fe80::f511:a91b:90b:d9b9/64
        route6 fe80::/64 metric 1024

        lo: unmanaged
            "lo"
            loopback (unknown), 00:00:00:00:00:00, sw, mtu 65536

        DNS configuration:
            servers: 192.168.1.1
            domains: localdomain
            interface: enp0s3

        Use "nmcli device show" to get complete information about known devices and
        "nmcli connection show" to get an overview on active connection profiles.
        ```


        Prima ancora di iniziare a modificare la connessione, si dovrebbe dare a questa un nome sensato, come il nome dell'interfaccia (**notare** che la "\" in basso evita gli spazi nel nome):

        ```
        nmcli connection modify Wired\ connection\ 1 con-name enp0s3
        ```


        Al termine, eseguire di nuovo `nmcli` da solo e si vedrà qualcosa di simile a questo:

        ```bash
        enp0s3: connected to enp0s3
        "Intel 82540EM"
        ethernet (e1000), 08:00:27:E4:2D:3D, hw, mtu 1500
        ip4 default
        inet4 192.168.1.140/24
        route4 192.168.1.0/24 metric 100
        route4 default via 192.168.1.1 metric 100
        ...
        ```


        Questo renderà molto più semplice la restante configurazione del DNS!
    
    Supponendo che il nome del profilo di connessione sia "enp0s3", includeremo il DNS già configurato, ma aggiungeremo prima il nostro server DNS locale:

    ```
    nmcli con mod enp0s3 ipv4.dns '192.168.1.138,192.168.1.1'
    ```


    È possibile avere più server DNS. Per una macchina configurata con server DNS pubblici, ad esempio l'open DNS di Google, si potrebbe invece avere questo problema:

    ```
    nmcli con mod enp0s3 ipv4.dns '192.168.1.138,8.8.8.8,8.8.4.4'
    ```


    Una volta aggiunti i server DNS desiderati alla connessione, si dovrebbe essere in grado di risolvere gli host in *ourdomain.lan*, così come gli host di Internet.

=== "8"

    ## 8 Utilizzo di IPv4 sulla LAN
    
    Se si utilizza solo IPv4 sulla LAN, è necessario apportare due modifiche. Il primo si trova in `/etc/named.conf` e la seconda in `/etc/sysconfig/named`.
    
    Per prima cosa, si può accedere nuovamente al file `named.conf` con `vi /etc/named.conf`. È necessario aggiungere la seguente opzione in un punto qualsiasi della sezione delle opzioni.

    ```
    filter-aaaa-on-v4 yes;
    ```


    Mostrato qui sotto:
    
    ![Aggiungi filtro IPv6](images/dns_filter.png)
    
    Una volta effettuata questa modifica, salvarla e uscire da `named.conf` (per _vi_, `SHIFT:wq!`).
    
    È necessario apportare una modifica simile in `/etc/sysconfig/named`:

    ```
    vi /etc/sysconfig/named
    ```


    Aggiungete questo in fondo al file:

    ```
    OPTIONS="-4"
    ```


    Salvare le modifiche (di nuovo, per _vi_, `SHIFT:wq!`).
    
    
    ## 8 Macchine di prova
    
    È necessario aggiungere il server DNS (nel nostro esempio 192.168.1.136) a ogni macchina che si desidera abbia accesso ai server aggiunti al DNS locale. L'autore mostra solo un esempio di come farlo su una workstation Rocky Linux. Metodi simili esistono per altre distribuzioni Linux, Windows e Mac.
    
    È necessario aggiungere il server DNS all'elenco, in quanto è ancora necessario l'accesso a Internet, che richiede i server DNS attualmente assegnati. In genere è il DHCP (Dynamic Host Configuration Protocol) ad assegnarli, oppure sono assegnati staticamente.
    
    Su una workstation Rocky Linux in cui l'interfaccia di rete abilitata è eth0, utilizzare:

    ```
    vi /etc/sysconfig/network-scripts/ifcfg-eth0
    ```


    Se l'interfaccia di rete attivata è diversa, è necessario sostituire il nome dell'interfaccia. Il file di configurazione che si apre avrà un aspetto simile a questo per un IP assegnato staticamente (non DHCP come detto sopra). Nell'esempio seguente, l'indirizzo IP della nostra macchina è 192.168.1.151:

    ```
    DEVICE=eth0
    BOOTPROTO=none
    IPADDR=192.168.1.151
    PREFIX=24
    GATEWAY=192.168.1.1
    DNS1=8.8.8.8
    DNS2=8.8.4.4
    ONBOOT=yes
    HOSTNAME=tender-kiwi
    TYPE=Ethernet
    MTU=
    ```


    Si vuole sostituire il nostro nuovo server DNS con il primario (DNS1) e spostare tutti gli altri server DNS verso il basso:

    ```
    DEVICE=eth0
    BOOTPROTO=none
    IPADDR=192.168.1.151
    PREFIX=24
    GATEWAY=192.168.1.1
    DNS1=192.168.1.136
    DNS2=8.8.8.8
    DNS3=8.8.4.4
    ONBOOT=yes
    HOSTNAME=tender-kiwi
    TYPE=Ethernet
    MTU=
    ```


    Dopo aver completato le modifiche, riavviare la macchina o riavviare la rete con:

    ```
    systemctl restart network
    ```


    Ora sarete in grado di raggiungere qualsiasi cosa nel dominio *ourdomain.lan* dalle vostre postazioni di lavoro, oltre a poter risolvere e raggiungere gli indirizzi Internet.


## Regole del firewall - `firewalld`

!!! note "`firewalld` come impostazione predefinita"

    Con Rocky Linux 9.0 e successivi, l'uso delle regole `iptables` è deprecato. Si dovrebbe invece usare `firewalld`.

L'autore non fa alcuna ipotesi sulla rete o sui servizi di cui potreste avere bisogno, tranne che per l'attivazione dell'accesso SSH e dell'accesso DNS solo per la nostra rete LAN. Per questo, si utilizzerà la zona incorporata di `firewalld`, "trusted". È necessario apportare modifiche al servizio nella zona "pubblica" per limitare l'accesso SSH alla LAN.

Il primo passo è aggiungere la nostra rete LAN alla zona "trusted":

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
```

Aggiungiamo i nostri due servizi alla zona "trusted":

```
firewall-cmd --zone=trusted --add-service=ssh --permanent
firewall-cmd --zone=trusted --add-service=dns --permanent
```

Rimuovere il servizio SSH dalla zona "public", che è attiva per impostazione predefinita:

```
firewall-cmd --zone=public --remove-service=ssh --permanent
```

Ricaricare il firewall ed elencare le zone modificate:

```
firewall-cmd --reload
firewall-cmd --zone=trusted --list-all
```

Questo mostrerà che i servizi e la rete di origine sono stati aggiunti correttamente:

```
trusted (active)
    target: ACCEPT
    icmp-block-inversion: no
    interfaces:
    sources: 192.168.1.0/24
    services: dns ssh
    ports:
    protocols:
    forward: no
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
```

L'elenco della zona "public " mostrerà che l'accesso SSH non è più consentito:

```
firewall-cmd --zone=public --list-all
```

Mostra:

```
public
    target: default
    icmp-block-inversion: no
    interfaces:
    sources:
    services: cockpit dhcpv6-client
    ports:
    protocols:
    forward: no
    masquerade: no
    forward-ports:
    source-ports:
    icmp-blocks:
    rich rules:
```

Queste regole consentono di ottenere la risoluzione DNS sul server DNS privato da parte degli host della rete 192.168.1.0/24. Inoltre, sarete in grado di accedere al vostro server DNS privato tramite SSH da uno qualsiasi di questi host.

## Conclusioni

Modificando */etc/hosts* su una singola workstation si ottiene l'accesso a una macchina della rete interna, ma si può usare solo su quella macchina. Un server DNS privato che utilizza _bind_ consente di aggiungere host al DNS e, a condizione che le workstation abbiano accesso a quel server DNS privato, saranno in grado di raggiungere questi server locali.

Se non avete bisogno che le macchine risolvano su Internet, ma avete bisogno di un accesso locale da diverse macchine ai server locali, prendete in considerazione un server DNS privato.
