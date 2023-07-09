---
title: Bind del Server DNS Privato
author: Steven Spencer
contributors: Ezequiel Bruni, Franco Colussi
tested_with: 8.5, 8.6, 9.0
tags:
  - dns
  - bind
---

# Server DNS Privato Usando Bind

## Prerequisiti e Presupposti

* Un server con Rocky Linux
* Diversi server interni a cui si deve accedere solo localmente, ma non tramite Internet
* Diverse postazioni di lavoro che devono accedere agli stessi server presenti sulla stessa rete
* Un buon livello di confidenza con l'inserimento di comandi dalla riga di comando
* Familiarità con un editor a riga di comando (in questo esempio utilizziamo _vi_)
* In grado di utilizzare _firewalld_ o _iptables_ per creare regole firewall. Vengono fornite entrambe le opzioni _iptables_ e _firewalld_. Se si prevede di utilizzare _iptables_ , utilizzare la procedura [Abilitazione del firewall Iptables](../security/enabling_iptables_firewall.md)

## Introduzione

I server DNS esterni, o pubblici, sono utilizzati su Internet per mappare i nomi host agli indirizzi IP e, nel caso dei record PTR (noti come "pointer" o "reverse"), per mappare l'IP al nome host. Si tratta di una parte essenziale di Internet. Fa sì che il server di posta, il server web, il server FTP o molti altri server e servizi funzionino come previsto, indipendentemente da dove ci si trovi.

Su una rete privata, in particolare quella utilizzata per lo sviluppo di più sistemi, è possibile utilizzare il file */etc/hosts* della propria workstation Rocky Linux per mappare un nome a un indirizzo IP.

Questo funzionerà per _la vostra workstation_, ma non per qualsiasi altro computer della rete. Se si vuole che le cose vengano applicate globalmente, il metodo migliore è quello di prendersi un po' di tempo e creare un server DNS locale e privato per gestire questo aspetto per tutti i computer.

Se doveste creare server e resolver DNS pubblici a livello di produzione, probabilmente questo autore consiglierebbe il più robusto [PowerDNS](https://www.powerdns.com/) DNS autoritativo e ricorsivo, facilmente installabile sui server Rocky Linux. Tuttavia, questo è semplicemente eccessivo per una rete locale che non espone i propri server DNS al mondo esterno. Ecco perché abbiamo scelto _bind_ per questo esempio.

### Spiegazione dei Componenti del Server DNS

Come detto, il DNS separa i servizi in server autoritativi e ricorsivi. Si raccomanda che questi servizi siano separati l'uno dall'altro su hardware o container distinti.

Il server autoritario è l'area di archiviazione di tutti gli indirizzi IP e i nomi host, mentre il server ricorsivo viene utilizzato per cercare indirizzi e nomi host. Nel caso del nostro server DNS privato, i servizi di server autoritario e ricorsivo funzioneranno insieme.

## Installazione e Abilitazione di Bind

Il primo passo è l'installazione dei pacchetti. Nel caso di _bind_ è necessario eseguire il seguente comando:

```
dnf install bind bind-utils
```

Il demone di servizio per _bind_ si chiama _named_ e occorre abilitarlo all'avvio:

```
systemctl enable named
```

E poi dobbiamo avviarlo:

```
systemctl start named
```

## Configurazione

Prima di apportare modifiche a qualsiasi file di configurazione, è buona norma fare una copia di backup del file di lavoro originale installato, in questo caso _named.conf_:

```
cp /etc/named.conf /etc/named.conf.orig
```

Questo aiuterà in futuro se vengono introdotti errori nel file di configurazione. È *sempre* una buona idea fare una copia di backup prima di apportare modifiche.

Queste modifiche richiedono la modifica del file named.conf; per farlo, stiamo usando _vi_, ma potete sostituire il vostro editor a riga di comando preferito (l'editor `nano` è anche installato in Rocky Linux ed è più facile da usare di `vi`):

```
vi /etc/named.conf
```

La prima cosa da fare è disattivare l'ascolto su localhost; per farlo, si possono omettere con il segno "#" queste due righe nella sezione "options". In questo modo si interrompe di fatto qualsiasi connessione con il mondo esterno.

Questo è utile, in particolare quando andiamo ad aggiungere questo DNS alle nostre postazioni di lavoro, perché vogliamo che il server DNS risponda solo quando l'indirizzo IP che richiede il servizio è locale, e semplicemente non risponda affatto se il servizio che viene cercato è da Internet.

In questo modo, gli altri server DNS configurati subentreranno quasi immediatamente per cercare i servizi basati su Internet:

```
options {
#       listen-on port 53 { 127.0.0.1; };
#       listen-on-v6 port 53 { ::1; };
```

Infine, si può andare in fondo al file *named.conf* e aggiungere una sezione per la vostra rete. Il nostro esempio utilizza ourdomain, quindi inserite il nome che volete dare agli host della vostra LAN:

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

Ora salvate le modifiche (per _vi_, `SHIFT:wq!`)

## I record di Forward e Reverse

Successivamente, occorre creare due file in `/var/named`. These files are the ones that you will edit if you add machines to your network that you want to include in the DNS.

Il primo è il file forward per mappare il nostro indirizzo IP al nome dell'host. Anche in questo caso, utilizziamo "ourdomain" come esempio. Si noti che l'IP del nostro DNS locale qui è 192.168.1.136. Gli host vengono aggiunti in fondo a questo file.

```
vi /var/named/ourdomain.lan.db
```

Al termine, il file avrà un aspetto simile a questo:

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

Aggiungete tutti gli host di cui avete bisogno nella parte inferiore del file insieme ai loro indirizzi IP e salvate le modifiche.

In questo caso, l'unica parte dell'IP di cui si ha bisogno è l'ultimo ottetto (in un indirizzo IPv4 ogni numero separato da un punto è un ottetto) dell'host e poi il PTR e l'hostname.

```
vi /var/named/ourdomain.lan.rev
```

Al termine, il file dovrebbe avere un aspetto simile a questo.:

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

Aggiungere tutti i nomi di host che compaiono nel file forward e salvate le modifiche.

### Cosa significa tutto questo

Ora che abbiamo aggiunto tutto questo e ci stiamo preparando a riavviare il nostro server DNS _bind_, esploriamo un po' la terminologia usata in questi due file.

Far funzionare le cose non è sufficiente se non si conosce il significato di ogni termine, giusto?

* **TTL** compare in entrambi i file e sta per "Time To Live". Il TTL indica al server DNS per quanto tempo mantenere la cache prima di richiederne una nuova copia. In questo caso, il TTL è l'impostazione predefinita per tutti i record, a meno che non venga impostato un TTL specifico per il record. L'impostazione predefinita è 86400 secondi o 24 ore.
* **IN** sta per Internet. In questo caso, non stiamo utilizzando Internet, ma una rete Intranet.
* **SOA** è l'acronimo di "Start Of Authority" o di quale sia il server DNS primario per il dominio.
* **NS** sta per "name server"
* **Serial** è il valore utilizzato dal server DNS per verificare che il contenuto del file di zona sia aggiornato.
* **Refresh** specifica la frequenza con cui un server DNS slave deve eseguire un trasferimento di zona dal master.
* **Retry** specifica il tempo di attesa in secondi prima di ritentare un trasferimento di zona non riuscito.
* **Expire** specifica quanto tempo un server slave deve aspettare per rispondere a una query quando il master non è raggiungibile.
* **A** È l'indirizzo host o il record forward e si trova solo nel file forward (sopra).
* **PTR** È il record del puntatore, meglio noto come " reverse ", e si trova solo nel nostro file reverse (sopra).

## Test della Configurazione

Una volta creati tutti i file, è necessario assicurarsi che i file di configurazione e le zone siano in ordine prima di avviare nuovamente il servizio _bind_.

Controllare la configurazione principale:

```
named-checkconf
```

Questo dovrebbe restituire un risultato vuoto se tutto è a posto.

Quindi controllare la zona forward:

```
named-checkzone ourdomain.lan /var/named/ourdomain.lan.db
```

Se tutto è a posto, dovrebbe restituire qualcosa di simile:

```
zone ourdomain.lan/IN: loaded serial 2019061800
OK
```

Infine, controllare la zona reverse:

```
named-checkzone 192.168.1.136 /var/named/ourdomain.lan.rev
```

Che dovrebbe restituire qualcosa di simile, se tutto è a posto:

```
zone 192.168.1.136/IN: loaded serial 2019061800
OK
```

Se tutto sembra a posto, riavviare _bind_:

```
systemctl restart named
```

=== "9"

    ## 9 Utilizzo di IPv4 sulla LAN
    
    Per utilizzare SOLO IPv4 sulla propria LAN, è necessario apportare una modifica in `/etc/sysconfig/named`:

    ```
    vi /etc/sysconfig/named
    ```


    e poi aggiungere questo in fondo al file:

    ```
    OPTIONS="-4"
    ```


    Ora salvate le modifiche (ancora una volta, per _vi_, `SHIFT:wq!`)
    
    ## 9 Macchine di prova
    
    È necessario aggiungere il server DNS (nel nostro esempio 192.168.1.136) a ogni macchina che si desidera abbia accesso ai server aggiunti al DNS locale. Vi mostreremo solo un esempio di come farlo su una workstation Rocky Linux, ma esistono metodi simili per altre distribuzioni Linux, oltre che per Windows e Mac.
    
    Tenete presente che dovrete solo aggiungere i server DNS all'elenco, non sostituire quelli attuali, poiché avrete comunque bisogno dell'accesso a Internet, che richiederà i server DNS attualmente assegnati. Questi possono essere assegnati tramite DHCP (Dynamic Host Configuration Protocol) o assegnati staticamente.
    
    Aggiungeremo il nostro DNS locale con `nmcli` e poi riavvieremo la connessione. 
    
    ??? warning "Nomi di profilo stupidi"
    
        In NetworkManager, le connessioni non sono modificate dal nome del dispositivo, ma dal nome del profilo. Può trattarsi di "Connessione cablata 1" o "Connessione wireless 1". È possibile vedere il profilo eseguendo `nmcli` senza alcun parametro:

        ```
        nmcli
        ```


        Si otterrà così un risultato come questo:

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


        Una volta fatto questo, eseguite nuovamente `nmcli` da solo e vedrete qualcosa di simile a questo:

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


    È possibile avere più server DNS e per una macchina configurata con server DNS pubblici, ad esempio l'open DNS di Google, si può avere qualcosa di simile:

    ```
    nmcli con mod enp0s3 ipv4.dns '192.168.1.138,8.8.8.8,8.8.4.4'
    ```


    Una volta aggiunti i server DNS desiderati alla connessione, si dovrebbe essere in grado di risolvere gli host in *ourdomain.lan*, così come gli host di Internet.
    
    ## 9.0 Regole del Firewall - `firewalld`
    
    !!! note "`firewalld` per impostazione predefinita"
    
        Con Rocky Linux 9.0 e successivi, l'uso delle regole `iptables` è deprecato. Dovresti usare `firewalld` invece.
    
    Non stiamo facendo alcuna ipotesi sulla rete o sui servizi che potrebbero essere necessari, a parte il fatto che stiamo attivando l'accesso SSH e l'accesso DNS solo per la nostra rete LAN. A tale scopo, si utilizzerà la zona incorporata `firewalld`, "trusted". Dovremo inoltre apportare alcune modifiche di servizio alla zona " public" per limitare l'accesso SSH alla LAN.
    
    Il primo passo è aggiungere la nostra rete LAN alla zona "trusted":

    ```
    firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
    ```


    Successivamente, dobbiamo aggiungere i nostri due servizi alla zona "trusted":

    ```
    firewall-cmd --zone=trusted --add-service=ssh --permanent
    firewall-cmd --zone=trusted --add-service=dns --permanent
    ```


    Infine, dobbiamo rimuovere il servizio SSH dalla nostra zona " public", che è attiva per impostazione predefinita:

    ```
    firewall-cmd --zone=public --remove-service=ssh --permanent
    ```


    Quindi, ricaricare il firewall ed elencare le zone che sono state modificate:

    ```
    firewall-cmd --reload
    firewall-cmd --zone=trusted --list-all
    ```


    Questo dovrebbe mostrare che i servizi e la rete di origine sono stati aggiunti correttamente:

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


    L'elenco della zona " public" dovrebbe mostrare che l'accesso SSH non è più consentito:

    ```
    firewall-cmd --zone=public --list-all
    ```


    Il che dovrebbe dimostrarlo:

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


    Queste regole dovrebbero garantire la risoluzione DNS sul server DNS privato da parte degli host sulla rete 192.168.1.0/24. Inoltre, dovreste essere in grado di accedere al vostro server DNS privato tramite SSH da uno qualsiasi di questi host.

=== "8"

    ## 8 Utilizzo di IPv4 sulla LAN
    
    Se si utilizza IPv4 solo sulla LAN, è necessario apportare due modifiche. Il primo si trova in `/etc/named.conf` e il secondo in `/etc/sysconfig/named`.
    
    Per prima cosa, si può accedere nuovamente al file `named.conf` con `vi /etc/named.conf`. È necessario aggiungere la seguente opzione in un punto qualsiasi della sezione delle opzioni.

    ```
    filter-aaaa-on-v4 yes;
    ```


    Questo è mostrato nell'immagine seguente:
    
    ![Aggiungi filtro IPv6](images/dns_filter.png)
    
    Una volta apportata la modifica, salvarla e uscire da `named.conf` (per _vi_, `SHIFT:wq!`).
    
    Successivamente è necessario apportare una modifica simile a `/etc/sysconfig/named`:

    ```
    vi /etc/sysconfig/named
    ```


    E poi aggiungere questo alla fine del file:

    ```
    OPTIONS="-4"
    ```


    Ora salvate le modifiche (ancora una volta, per _vi_, `SHIFT:wq!`)
    
    
    ## 8 Macchine di prova
    
    È necessario aggiungere il server DNS (nel nostro esempio 192.168.1.136) a ogni macchina che si desidera abbia accesso ai server aggiunti al nuovo DNS locale. Vi mostreremo solo un esempio di come farlo su una workstation Rocky Linux, ma esistono metodi simili per altre distribuzioni Linux, oltre che per Windows e Mac.
    
    Tenete presente che è meglio aggiungere solo il server DNS nell'elenco, poiché avrete comunque bisogno di un accesso a Internet, che richiederà i server DNS attualmente assegnati. Questi possono essere assegnati tramite DHCP (Dynamic Host Configuration Protocol) o assegnati staticamente.
    
    Su una workstation Rocky Linux in cui l'interfaccia di rete abilitata è eth0, si usa:

    ```
    vi /etc/sysconfig/network-scripts/ifcfg-eth0
    ```


    Se l'interfaccia di rete abilitata è diversa, è necessario sostituire il nome dell'interfaccia. Il file di configurazione che si apre avrà un aspetto simile a questo per un IP assegnato staticamente (non DHCP come detto sopra). Nell'esempio seguente, l'indirizzo IP della nostra macchina è 192.168.1.151:

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


    Vogliamo sostituire il nostro nuovo server DNS con il primario (DNS1) e poi spostare tutti gli altri server DNS verso il basso, in modo che la situazione sia questa:

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


    Una volta effettuata la modifica, riavviare il computer o riavviare la rete con:

    ```
    systemctl restart network
    ```


    Ora dovreste essere in grado di raggiungere qualsiasi cosa nel dominio *ourdomain.lan* dalle vostre postazioni di lavoro, oltre ad essere ancora in grado di risalire e raggiungere gli indirizzi Internet.
    
    ## 8 Regole Firewall
    
    ### Aggiungere Le Regole Firewall - `iptables`
    
    !!! note "Riguardo a `iptables`"
    
        Sebbene le regole `iptables` funzionino ancora in Rocky Linux 8.x, si consiglia di passare alle regole `firewalld` nella sezione seguente. Il motivo è che nelle versioni future di Rocky Linux, `iptables` sarà deprecato e rimosso. Inoltre, `firewalld` è il modo predefinito di fare le cose. Quando si cerca aiuto, si trovano più esempi di utilizzo di `firewalld` che di `iptables`. Abbiamo incluso le regole di `iptables` qui, ma per ottenere i migliori risultati e per essere a prova di futuro, raccomandiamo di passare subito a `firewalld`.
    
    Per prima cosa, creare un file in */etc* chiamato "firewall.conf" che conterrà le seguenti regole. Si tratta di una serie di regole minime, che possono essere modificate in base al proprio ambiente:

    ```
    #!/bin/sh
    #
    #IPTABLES=/usr/sbin/iptables

    #  Unless specified, the defaults for OUTPUT is ACCEPT
    #    The default for FORWARD and INPUT is DROP
    #
    echo "   clearing any existing rules and setting default policy.."
    iptables -F INPUT
    iptables -P INPUT DROP
    iptables -A INPUT -p tcp -m tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
    # dns rules
    iptables -A INPUT -p udp -m udp -s 192.168.1.0/24 --dport 53 -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
    iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

    /usr/sbin/service iptables save
    ```


    Valutiamo le regole di cui sopra:

    * La prima riga di "iptables" cancella le regole attualmente caricate (-F).
    * Successivamente, si imposta un criterio predefinito per la catena INPUT di DROP. Ciò significa che se il traffico non è esplicitamente consentito, viene eliminato.
    * Quindi, abbiamo una regola SSH per la nostra rete locale, in modo da poter accedere al server DNS da remoto.
    * Poi abbiamo la nostra regola DNS allow, solo per la nostra rete locale. Si noti che il DNS utilizza il protocollo UDP (User Datagram Protocol).
    * Quindi si autorizza INPUT dall'interfaccia locale.
    * Se poi si è stabilita una connessione per qualcos'altro, si consente anche l'ingresso dei relativi pacchetti.
    * E infine rifiutiamo tutto il resto.
    * L'ultima riga indica a iptables di salvare le regole in modo che al riavvio della macchina vengano caricate.

    Una volta creato il file firewall.conf, dobbiamo renderlo eseguibile:

    ```
    chmod +x /etc/firewall.conf
    ```

    Quindi eseguirlo:

    ```
    /etc/firewall.conf
    ```

    E questo è ciò che dovreste ottenere in cambio. Se si ottiene qualcos'altro, controllare che lo script non contenga errori:

    ```bash
    clearing any existing rules and setting default policy..
    iptables: Saving firewall rules to /etc/sysconfig/iptables:[  OK  ]
    ```


    ### Aggiunta delle Regole del Firewall - `firewalld`

    Con `firewalld`, stiamo duplicando le regole evidenziate in `iptables` sopra. Non facciamo altre ipotesi sulla rete o sui servizi che potrebbero essere necessari. Stiamo attivando l'accesso SSH e l'accesso DNS solo per la nostra rete LAN. Per questo, utilizzeremo la zona incorporata `firewalld`, "trusted". Dovremo inoltre apportare alcune modifiche di servizio alla zona " public" per limitare l'accesso SSH alla LAN.

    Il primo passo è aggiungere la nostra rete LAN alla zona "trusted":

    ```
    firewall-cmd --zone=trusted --add-source=192.168.1.0/24 --permanent
    ```

    Successivamente, dobbiamo aggiungere i nostri due servizi alla zona "trusted":

    ```
    firewall-cmd --zone=trusted --add-service=ssh --permanent
    firewall-cmd --zone=trusted --add-service=dns --permanent
    ```

    Infine, dobbiamo rimuovere il servizio SSH dalla nostra zona " public", che è attiva per impostazione predefinita:

    ```
    firewall-cmd --zone=public --remove-service=ssh --permanent
    ```

    Quindi, ricaricare il firewall ed elencare le zone che sono state modificate:

    ```
    firewall-cmd --reload
    firewall-cmd --zone=trusted --list-all
    ```

    Questo dovrebbe mostrare che i servizi e la rete di origine sono stati aggiunti correttamente:

    ```bash
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

    L'elenco della zona " public" dovrebbe mostrare che l'accesso SSH non è più consentito:

    ```
    firewall-cmd --zone=public --list-all
    ```

    ```bash
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


    Queste regole dovrebbero garantire la risoluzione DNS sul server DNS privato da parte degli host sulla rete 192.168.1.0/24. Inoltre, dovreste essere in grado di accedere al vostro server DNS privato tramite SSH da uno qualsiasi di questi host.

## Conclusioni

Sebbene l'uso di */etc/hosts* su una singola stazione di lavoro consenta di accedere a una macchina della rete interna, è possibile utilizzarlo solo su quella macchina. Aggiungendo un server DNS privato usando _bind_, è possibile aggiungere host al DNS e finché le workstation hanno accesso a quel server DNS privato, saranno in grado di raggiungere questi server locali.

Se non avete bisogno che le macchine risolvano su Internet, ma avete bisogno di un accesso locale da diverse macchine ai server locali, prendete in considerazione l'utilizzo di un server DNS privato.
