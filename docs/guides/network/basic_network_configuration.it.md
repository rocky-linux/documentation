---
title: Configurazione della Rete
contributors: Steven Spencer, Hayden Young, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - networking
  - configuration
  - network
---

# Configurazione della Rete

Al giorno d'oggi non si può fare molto con un computer senza la connettività di rete. Sia che dobbiate aggiornare i pacchetti su un server, sia che dobbiate semplicemente navigare su siti web esterni dal vostro portatile, avrete bisogno di un accesso alla rete! Questa guida si propone di fornire agli utenti di Rocky Linux le conoscenze di base sull'impostazione della connettività di rete.

## Prerequisiti

* Una certa comodità nell'operare dalla riga di comando
* Privilegi elevati o amministrativi sul sistema (per esempio root, sudo e così via)
* Opzionale: familiarità con i concetti di rete

=== "9"

    ## Configurazione di rete - Rocky Linux 9
    
    A partire da Rocky Linux 9 sono cambiate molte cose nella configurazione di rete. Uno dei cambiamenti principali è il passaggio da Network-Scripts (ancora disponibile per l'installazione, ma di fatto deprecato) all'uso di Network Manager e di file chiave, piuttosto che di file basati su `ifcfg'. A partire dal 9, `NetworkManager` dà priorità ai `keyfiles` rispetto ai precedenti `ifcfg`. Dal momento che questa è l'impostazione predefinita, l'operazione di configurazione della rete dovrebbe considerare l'impostazione predefinita come il modo corretto di fare le cose, dato che altri cambiamenti nel corso degli anni hanno comportato la deprecazione e la rimozione di utilità più vecchie. Questa guida cercherà di guidarvi nell'uso di Network Manager e delle ultime modifiche apportate a Rocky Linux 9. 
    
    ## Prerequisiti

    * Una certa dimestichezza nell'operare dalla riga di comando
    * Privilegi elevati o amministrativi sul sistema (ad esempio root, `sudo` e così via)
    * Opzionale: familiarità con i concetti di rete


    ## Usare il servizio NetworkManager

    A livello utente, lo stack di rete è gestito da `NetworkManager`. Questo strumento viene eseguito come servizio ed è possibile verificarne lo stato con il seguente comando:

    ```bash
    systemctl status NetworkManager
    ```


    ## File di configurazione

    Come indicato all'inizio, i file di configurazione predefiniti sono ora file keys. È possibile vedere come `NetworkManager` assegna la priorità a questi file eseguendo il seguente comando:

    ```
    NetworkManager --print-config
    ```

    Si ottiene così un risultato simile a questo:

    ```
    [main]
    # plugins=keyfile,ifcfg-rh
    # rc-manager=auto
    # auth-polkit=true
    # iwd-config-path=
    dhcp=dhclient
    configure-and-quit=no

    [logging]
    # backend=journal
    # audit=false

    [device]
    # wifi.backend=wpa_supplicant

    # no-auto-default file "/var/lib/NetworkManager/no-auto-default.state"
    ```

    Notate all'inizio del file di configurazione il riferimento al `keyfile` seguito da `ifcfg-rh`. Questo significa che l'impostazione predefinita è il `keyfile`. Ogni volta che si esegue uno degli strumenti di `NetworkManager` per configurare un'interfaccia (ad esempio: `nmcli` o `nmtui`), questo costruisce o aggiorna automaticamente i file delle chiavi.

    !!! tip "Configurazione posizione di archiviazione"

        In Rocky Linux 8, la posizione di memorizzazione per la configurazione di rete era in `/etc/sysconfig/Network-Scripts/`. Con Rocky Linux 9, il nuovo percorso di archiviazione predefinito per i file chiave è in `/etc/NetworkManager/system-connections`.

    L'utilità principale (ma non l'unica) utilizzata per configurare un'interfaccia di rete è il comando `nmtui`. Questo può essere fatto anche con il comando `nmcli`, ma è molto meno intuitivo. Possiamo mostrare l'interfaccia come è attualmente configurata usando `nmcli` con:

    ```
    nmcli device show enp0s3
    GENERAL.DEVICE:                         enp0s3
    GENERAL.TYPE:                           ethernet
    GENERAL.HWADDR:                         08:00:27:BA:CE:88
    GENERAL.MTU:                            1500
    GENERAL.STATE:                          100 (connected)
    GENERAL.CONNECTION:                     enp0s3
    GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
    WIRED-PROPERTIES.CARRIER:               on
    IP4.ADDRESS[1]:                         192.168.1.151/24
    IP4.GATEWAY:                            192.168.1.1
    IP4.ROUTE[1]:                           dst = 192.168.1.0/24, nh = 0.0.0.0, mt = 100
    IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 192.168.1.1, mt = 100
    IP4.DNS[1]:                             8.8.8.8
    IP4.DNS[2]:                             8.8.4.4
    IP4.DNS[3]:                             192.168.1.1
    IP6.ADDRESS[1]:                         fe80::a00:27ff:feba:ce88/64
    IP6.GATEWAY:                            --
    IP6.ROUTE[1]:                           dst = fe80::/64, nh = ::, mt = 1024
    ```


    !!! tip "**Suggerimento:**"

        Esistono alcuni modi o meccanismi per assegnare ai sistemi le informazioni di configurazione IP. I due metodi più comuni sono: lo schema **Configurazione IP statica** e lo schema **Configurazione IP dinamica**.

        Lo schema di configurazione IP statico è molto diffuso nei sistemi o nelle reti di tipo server.

        L'approccio IP dinamico è molto diffuso nelle reti domestiche e di ufficio o nei sistemi di classe workstation e desktop in ambiente aziendale.  Lo schema dinamico di solito necessita di _qualcosa_ in più che sia disponibile localmente e che possa fornire le informazioni di configurazione IP corrette alle workstation e ai desktop richiedenti. Questo _qualcosa_ si chiama Dynamic Host Configuration Protocol (DHCP). In una rete domestica, e anche nella maggior parte delle reti aziendali, questo servizio è fornito da un server DHCP configurato allo scopo. Può trattarsi di un server separato o di una parte della configurazione del router.


    ## Indirizzi IP

    Nella sezione precedente, la configurazione visualizzata per l'interfaccia `enp0s3` è generata dal file `.ini` `/etc/NetworkManager/system-connections/enp0s3.nmconnection`. Questo indica che l'indirizzo IP4.ADDRESS[1] è stato configurato staticamente e non dinamicamente tramite DHCP. Se si vuole riportare questa interfaccia a un indirizzo allocato dinamicamente, il modo più semplice è usare il comando `nmtui`.

    1. Per prima cosa, eseguire il comando `nmtui` alla riga di comando, che dovrebbe mostrare quanto segue

        ![nmtui](images/nmtui_first.png)

    2. È già presente la selezione "Edit a connection", quindi premere il tasto <kbd>TAB</kbd> in modo da evidenziare "OK" e premere <kbd>INVIO</kbd>

    3. Verrà visualizzata una schermata che mostra le connessioni Ethernet della macchina e consentirà di sceglierne una. Nel nostro caso, ce n'è *SOLO* uno, quindi è già evidenziato; dobbiamo semplicemente premere il tasto <kbd>TAB</kbd> finché non viene evidenziato "Edit" e poi premere <kbd>INVIO</kbd>

        ![nmtui_edit](images/nmtui_edit.png)

    4. Una volta fatto questo, ci troveremo nella schermata che mostra la nostra configurazione attuale. Occorre passare da " Manual " a " Automatic ", quindi premere più volte il tasto <kbd>TAB</kbd> fino a evidenziare " Manual " e poi premere <kbd>INVIO</kbd>.

        ![nmtui_manual](images/nmtui_manual.png)

    5. La freccia verso l'alto fino a evidenziare " Automatic" e quindi premere <kbd>INVIO</kbd>

        ![nmtui_automatic](images/nmtui_automatic.png)

    6. Una volta che l'interfaccia è passata ad "Automatic", è necessario rimuovere l'IP assegnato staticamente, quindi premere il tasto <kbd>TAB</kbd> fino a evidenziare "Remove"accanto all'indirizzo IP e premere <kbd>INVIO</kbd>.

        ![nmtui_remove](images/nmtui_remove.png)

    7. Infine, premete più volte il tasto <kbd>TAB</kbd> finché non arrivate in fondo alla schermata `nmtui` e non viene evidenziato "OK" e premete <kbd>INVIO</kbd>

    È possibile disattivare e riattivare l'interfaccia anche con `nmtui`, ma facciamo questo con `nmcli`. In questo modo è possibile regolare la disattivazione dell'interfaccia e la sua riattivazione, in modo che l'interfaccia non sia mai inattiva per molto tempo:

    ```
    nmcli con down enp0s3 && nmcli con up enp0s3
    ```

    È l'equivalente del vecchio `ifdown enp0s3 && ifup enp0s3` usato nelle vecchie versioni del sistema operativo.

    Per verificare che abbia funzionato, controllate con il comando `ip addr` o con il comando `nmcli device show enp0s3` che abbiamo usato in precedenza.

    ```
    ip addr
    ```

    In caso di successo, si dovrebbe vedere che l'IP statico è stato rimosso e che è stato aggiunto un indirizzo allocato dinamicamente, come in questo caso:

    ```bash
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ba:ce:88 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.137/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
       valid_lft 6342sec preferred_lft 6342sec
    inet6 fe80::a00:27ff:feba:ce88/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
    ```


    ### Modifica dell'indirizzo IP con `nmcli`

    L'uso di `nmtui` è piacevole, ma se si vuole solo riconfigurare rapidamente l'interfaccia di rete senza dover passare tra una schermata e l'altra, probabilmente è meglio usare `nmcli` da solo. Vediamo l'esempio precedente di un IP assegnato staticamente e i passi per riconfigurare l'interfaccia in DHCP usando solo `nmcli`.

    Prima di iniziare, è necessario sapere che per riconfigurare l'interfaccia in DHCP è necessario:

    * Rimuovere il gateway IPv4
    * Rimuovere l'indirizzo IPv4 assegnato staticamente
    * Cambiare il metodo IPv4 in automatico
    * Disattivare e riattivare l'interfaccia

    Si noti anche che non stiamo usando esempi che dicono di usare -ipv4.address ecc. Questi non cambiano completamente l'interfaccia. Per farlo, è necessario impostare ipv4.address e ipv4.gateway su una stringa vuota. Anche in questo caso, per risparmiare il più possibile tempo con il nostro comando, li uniremo tutti in un'unica riga:

    ```
    nmcli con mod enp0s3 ipv4.gateway '' && nmcli con mod enp0s3 ipv4.address '' && nmcli con mod enp0s3 ipv4.method auto && nmcli con down enp0s3 && nmcli con up enp0s3
    ```

    Eseguendo nuovamente il comando `ip addr` si otterranno gli stessi risultati di quando abbiamo eseguito le modifiche con `nmtui`. Ovviamente potremmo fare tutto anche al contrario (cambiando il nostro indirizzo DHCP con uno statico). Per farlo, si eseguono i comandi al contrario, iniziando con il cambiare `ipv4.method` in manual, impostando `ipv4.gateway` e quindi impostando `ipv4.address`. Poiché in tutti questi esempi stiamo riconfigurando completamente l'interfaccia e non aggiungendo o sottraendo valori ad essa, non utilizzeremo gli esempi che parlano dell'uso di `+ipv4.method`,`+ipv4.gateway`, and `+ipv4.address`. Se si usassero questi comandi al posto di quelli usati sopra, si otterrebbe un'interfaccia con *sia* un indirizzo assegnato da DHCP che uno assegnato staticamente. Detto questo, a volte può essere molto utile. Se si dispone di un servizio Web in ascolto su un IP e di un server SFTP in ascolto su un altro IP. È molto utile disporre di un metodo per assegnare più IP a un'interfaccia.


    ## Risoluzione DNS

    L'impostazione dei server DNS può essere effettuata con `nmtui` o `nmcli`. Sebbene l'interfaccia `nmtui` sia facile da navigare e molto più intuitiva, il processo è molto più lento. L'operazione con `nmcli` è molto più veloce. Nel caso dell'indirizzo assegnato dal DHCP, di solito non è necessario impostare i server DNS, perché di solito vengono inoltrati dal server DHCP. Detto questo, *è possibile* aggiungere staticamente i server DNS a un'interfaccia DHCP. Nel caso di un'interfaccia assegnata staticamente, sarà *NECESSARIO* fare questa operazione, poiché dovrà sapere come ottenere la risoluzione DNS e non avrà un metodo assegnato automaticamente.

    Poiché l'esempio migliore per tutto questo è un IP assegnato staticamente, torniamo al nostro indirizzo statico originale della nostra interfaccia di esempio (enp0s3). Prima di modificare i parametri DNS, dobbiamo vedere quali sono gli attuali valori. Per ottenere una risoluzione corretta dei nomi, rimuovere i server DNS già impostati e aggiungerne di diversi. Attualmente `ipv4.dns` è impostato su `8.8.8.8.8.8.4.4.192.168.1.1`. In questo caso, non è necessario impostare ipv4.dns come una stringa vuota. Possiamo semplicemente usare il comando seguente per sostituire i nostri valori:

    ```
    nmcli con mod enp0s3 ipv4.dns '208.67.222.222,208.67.220.220,192.168.1.1'
    ```

    L'esecuzione di `nmcli con show enp0s3 | grep ipv4.dns` dovrebbe mostrare che la modifica dei server DNS è avvenuta con successo. Per attivare tutto, disattiviamo e riattiviamo l'interfaccia in modo che le modifiche vengano attivate:

    ```
    nmcli con down enp0s3 && nmcli con up enp0s3
    ```

    Per verificare se la risoluzione dei nomi viene *effettuata*, provare a eseguire il ping di un host noto. Utilizzeremo google.com come esempio:

    ```bash
    ping google.com
    PING google.com (172.217.4.46) 56(84) bytes of data.
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=1 ttl=119 time=14.5 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=2 ttl=119 time=14.6 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=3 ttl=119 time=14.4 ms
    ^C
    ```


    ## Usare l'utilità `ip`

    Il comando `ip` (fornito dal pacchetto *iproute2*) è un potente strumento per ottenere informazioni e configurare la rete di un sistema Linux moderno come Rocky Linux.

    In questo esempio, assumeremo i seguenti parametri:

    * nome dell'interfaccia: enp0s3
    * indirizzo ip: 192.168.1.151
    * maschera di sottorete: 24
    * gateway: 192.168.1.1


    ### Ottenere informazioni di carattere generale

    Per vedere lo stato dettagliato di tutte le interfacce, usare

    ```bash
    ip a
    ```

    !!! hint "**"Suggerimenti professionali:**"

        * usare il flag `-c` per ottenere un output colorato più leggibile: `ip -c a`.
        * `ip` accetta l'abbreviazione quindi `ip a`, `ip addr` e `ip address` sono equivalenti


    ### Porta l'interfaccia su o giù

    !!! note "Nota"

        Sebbene sia ancora possibile utilizzare questo metodo per portare l'interfaccia su e giù in Rocky Linux 9, il comando reagisce molto più lentamente rispetto al semplice comando `nmcli`.

    Per far cadere e ripartire il *enp0s3* possiamo semplicemente usare:

    ```
    ip link set enp0s3 down && ip link set enp0s3 up
    ```


    ### Assegnare all'interfaccia un indirizzo statico

    Attualmente, la nostra interfaccia enp0s3 ha un indirizzo IP di 192.168.1.151. Per passare a 192.168.1.152, si rimuove il vecchio IP con

    ```bash
    ip addr delete 192.168.1.151/24 dev enp0s3 && ip addr add 192.168.1.152/24 dev enp0s3
    ```

    Se si volesse assegnare un secondo IP all'interfaccia, invece di rimuovere l'indirizzo 192.168.1.151, sarebbe sufficiente aggiungere il secondo indirizzo con:

    ```bash
    ip addr add 192.168.1.152/24 dev enp0s3
    ```

    Si può verificare se l'indirizzo IP è stato aggiunto con

    ```bash
    ip a show dev enp0s3
    ```

    verrà visualizzato:

    ```bash
    2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ba:ce:88 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.151/24 brd 192.168.1.255 scope global noprefixroute enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.1.152/24 scope global secondary enp0s3
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:feba:ce88/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
    ```

    Mentre porta l'interfaccia su e giù usando l'utilità `ip` è molto più lenta di `nmcli`, `ip` ha un vantaggio distinto quando si impostano indirizzi IP nuovi o aggiuntivi, come accade in tempo reale, senza portare l'interfaccia giù e su.


    ### Configurazione del gateway


    Ora che l'interfaccia ha un indirizzo, dobbiamo impostare il suo percorso predefinito. Questo può essere fatto con:

    ```bash
    ip route add default via 192.168.1.1 dev enp0s3
    ```

    La tabella di routing del kernel può essere visualizzata con

    ```bash
    ip route
    ```

    o `ip r` in breve.

    Il risultato dovrebbe essere simile a questo:

    ```bash
    default via 192.168.1.1 dev enp0s3 
    192.168.1.0/24 dev enp0s3 proto kernel scope link src 192.168.1.151 metric 100
    ```


    ## Controllo della connettività di rete

    Negli esempi precedenti abbiamo effettuato alcuni test. La cosa migliore da fare è iniziare con il ping del gateway predefinito. Questo dovrebbe funzionare sempre:

    ```bash
    ping -c3 192.168.1.1
    PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
    64 bytes from 192.168.1.1: icmp_seq=1 ttl=64 time=0.437 ms
    64 bytes from 192.168.1.1: icmp_seq=2 ttl=64 time=0.879 ms
    64 bytes from 192.168.1.1: icmp_seq=3 ttl=64 time=0.633 ms
    ```

    Quindi, verificare se il routing LAN funziona completamente eseguendo il ping di un host sulla rete locale:

    ```bash
    ping -c3 192.168.1.10
    PING 192.168.1.10 (192.168.1.10) 56(84) bytes of data.
    64 bytes from 192.168.1.10: icmp_seq=2 ttl=255 time=0.684 ms
    64 bytes from 192.168.1.10: icmp_seq=3 ttl=255 time=0.676 ms
    ```

    Eseguire un test per verificare che venga visualizzato un host raggiungibile esterno alla rete. Per il test che segue, utilizziamo il server DNS aperto di Google:

    ```bash
    ping -c3 8.8.8.8
    PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
    64 bytes from 8.8.8.8: icmp_seq=1 ttl=119 time=19.8 ms
    64 bytes from 8.8.8.8: icmp_seq=2 ttl=119 time=20.2 ms
    64 bytes from 8.8.8.8: icmp_seq=3 ttl=119 time=20.1 ms
    ```

    Il test finale consiste nel verificare che la risoluzione DNS funzioni. Per questo esempio, utilizziamo google.com:

    ```bash
    ping -c3 google.com
    PING google.com (172.217.4.46) 56(84) bytes of data.
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=1 ttl=119 time=14.5 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=2 ttl=119 time=15.1 ms
    64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=3 ttl=119 time=14.6 ms
    ```

    Se la macchina dispone di diverse interfacce e si desidera eseguire il test da una particolare interfaccia, è sufficiente utilizzare l'opzione `-I` con ping:

    ```bash
    ping -I enp0s3 -c3 192.168.1.10
    ```


    ## Conclusioni

    In Rocky Linux 9 sono state apportate molte modifiche allo stack di rete. Tra queste c'è la priorità dei `keyfile` rispetto ai file `ifcfg` usati in precedenza e presenti in Network-Scripts. Poiché la direzione del cambiamento nelle future versioni di Rocky Linux prevede la deprecazione e la rimozione degli script di rete, è meglio concentrare l'attenzione su metodologie come `nmcli`, `nmtui` e, in alcuni casi, `ip`, per la configurazione della rete.

=== "8"

    ## Configurazione della rete - Rocky Linux 8
    
    ## Utilizzo del servizio NetworkManager
    
    A livello utente, lo stack di rete è gestito da *NetworkManager*. Questo strumento viene eseguito come servizio ed è possibile verificarne lo stato con il seguente comando:

    ```bash
    systemctl status NetworkManager
    ```


    ### File di configurazione
    
    NetworkManager applica semplicemente una configurazione letta dai file presenti in `/etc/sysconfig/network-scripts/ifcfg-<IFACE_NAME>`.
    Ogni interfaccia di rete ha il suo file di configurazione. Di seguito è riportato un esempio di configurazione predefinita di un server:

    ```bash
    TYPE=Ethernet
    PROXY_METHOD=none
    BROWSER_ONLY=no
    BOOTPROTO=none
    DEFROUTE=yes
    IPV4_FAILURE_FATAL=no
    IPV6INIT=no
    NAME=enp1s0
    UUID=74c5ccee-c1f4-4f45-883f-fc4f765a8477
    DEVICE=enp1s0
    ONBOOT=yes
    IPADDR=10.0.0.10
    PREFIX=24
    GATEWAY=10.0.0.1
    DNS1=10.0.0.1
    DNS2=1.1.1.1
    IPV6_DISABLED=yes
    ```


    Il nome dell'interfaccia è **enp1s0**, quindi il nome del file sarà `/etc/sysconfig/network-scripts/ifcfg-enp1s0`.
    
    !!! tip "**Consigli:**"  
    
        Esistono alcuni modi o meccanismi per assegnare ai sistemi le informazioni di configurazione IP. I due metodi più comuni sono: lo schema di **configurazione IP statica** e lo schema di **configurazione IP dinamica**.
    
        Lo schema di configurazione IP statico è molto diffuso nei sistemi o nelle reti di tipo server.
    
        L'approccio IP dinamico è molto diffuso nelle reti domestiche e di ufficio o nei sistemi di classe workstation e desktop.  Lo schema dinamico di solito necessita di qualcosa di aggiuntivo, disponibile localmente, in grado di fornire le informazioni di configurazione IP corrette alle workstation e ai desktop che ne fanno richiesta. Questo _qualcosa_ si chiama Dynamic Host Configuration Protocol (DHCP).
    
       Gli utenti di casa o dell'ufficio spesso non devono preoccuparsi del DHCP. Questo perché qualcosa di diverso se ne occupa automaticamente in background. L'utente finale deve connettersi fisicamente o in modalità wireless alla rete giusta (e naturalmente assicurarsi che i suoi sistemi siano accesi)!
    
    ### Indirizzo IP
    
    Nel precedente elenco `/etc/sysconfig/network-scripts/ifcfg-enp1s0`, vediamo che il valore del parametro o chiave `BOOTPROTO` è impostato su `none`. Il sistema configurato è impostato su uno schema di indirizzi IP statici.
    
    Se invece si vuole configurare il sistema per utilizzare uno schema di indirizzi IP dinamici, si dovrà cambiare il valore del parametro `BOOTPROTO` da `none` a `dhcp` e rimuovere anche le linee `IPADDR`, `PREFIX` e `GATEWAY`. Questo è necessario perché tutte le informazioni saranno ottenute automaticamente da qualsiasi server DHCP disponibile.
    
    Per configurare l'attribuzione di un indirizzo IP statico, impostare quanto segue:

    * IPADDR: l'indirizzo IP da assegnare all'interfaccia
    * PREFIX: la maschera di sottorete in [CIDR notation](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)
    * GATEWAY: il gateway predefinito

    Il parametro `ONBOOT` impostato su `yes` indica che questa connessione sarà attivata durante l'avvio.


    ### Risoluzione DNS

    Per ottenere una risoluzione corretta dei nomi, è necessario impostare i seguenti parametri:

    * DNS1: indirizzo IP del nameserver principale
    * DNS2: l'indirizzo IP del nameserver secondario


    ### Controllo della configurazione

    È possibile verificare che la configurazione sia stata applicata correttamente con il seguente comando `nmcli`:

    ```bash
    [user@server ~]$ sudo nmcli device show enp1s0
    ```

    che dovrebbe fornire il seguente risultato:

    ```conf
    GENERAL.DEVICE:                         enp1s0
    GENERAL.TYPE:                           ethernet
    GENERAL.HWADDR:                         6E:86:C0:4E:15:DB
    GENERAL.MTU:                            1500
    GENERAL.STATE:                          100 (connecté)
    GENERAL.CONNECTION:                     enp1s0
    GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
    WIRED-PROPERTIES.CARRIER:               marche
    IP4.ADDRESS[1]:                         10.0.0.10/24
    IP4.GATEWAY:                            10.0.0.1
    IP4.ROUTE[1]:                           dst = 10.0.0.0/24, nh = 0.0.0.0, mt = 100
    IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 10.0.0.1, mt = 100
    IP4.DNS[1]:                             10.0.0.1
    IP4.DNS[2]:                             1.1.1.1
    IP6.GATEWAY:                            --
    ```


    ### CLI

    La funzione principale di NetworkManager è la gestione delle "connessioni", che mappano un dispositivo fisico a più componenti di rete logici, come l'indirizzo IP e le impostazioni DNS. Per visualizzare le connessioni esistenti gestite da NetworkManager, è possibile eseguire `nmcli connection show`.

    ```bash
    [user@server ~]$ sudo nmcli connection show
    NAME    UUID                                  TYPE      DEVICE
    enp1s0  625a8aef-175d-4692-934c-2c4a85f11b8c  ethernet  enp1s0
    ```

    Dall'output precedente, possiamo determinare che NetworkManager gestisce una connessione (`NAME`) chiamata `enp1s0` che si riferisce al dispositivo fisico (`DEVICE`) `enp1s0`.

    !!! tip "Nome della connessione"

        In questo esempio, la connessione e il dispositivo condividono lo stesso nome, ma ciò potrebbe non essere sempre vero. È comune vedere una connessione chiamata `System eth0` che mappa un dispositivo chiamato `eth0`, ad esempio.

    Ora che conosciamo il nome della nostra connessione, possiamo visualizzarne le impostazioni. A tale scopo, utilizzare il comando `nmcli connection show [connection]`, che stamperà tutte le impostazioni registrate da NetworkManager per la connessione in questione.

    ```bash
    [user@server ~]$ sudo nmcli connection show enp1s0
    ...
    ipv4.method:                            auto
    ipv4.dns:                               --
    ipv4.dns-search:                        --
    ipv4.dns-options:                       --
    ipv4.dns-priority:                      0
    ipv4.addresses:                         --
    ipv4.gateway:                           --
    ipv4.routes:                            --
    ipv4.route-metric:                      -1
    ipv4.route-table:                       0 (unspec)
    ipv4.routing-rules:                     --
    ipv4.ignore-auto-routes:                no
    ipv4.ignore-auto-dns:                   no
    ipv4.dhcp-client-id:                    --
    ipv4.dhcp-iaid:                         --
    ipv4.dhcp-timeout:                      0 (default)
    ipv4.dhcp-send-hostname:                yes
    ...
    ```

    Nella colonna di sinistra si trova il nome dell'impostazione e in quella di destra il valore.

    Ad esempio, possiamo vedere che il metodo `ipv4.method` qui è attualmente impostato su `auto`. Ci sono molti valori consentiti per l'impostazione `ipv4.method`, ma i due principali che molto probabilmente si vedranno sono:

    * `auto`: per l'interfaccia viene utilizzato il metodo automatico appropriato (DHCP, PPP, ecc.) e la maggior parte delle altre proprietà possono essere lasciate non impostate.
    * `manual`: viene utilizzato un indirizzamento IP statico e almeno un indirizzo IP deve essere indicato nella proprietà 'addresses'.

    Se invece si desidera configurare il sistema in modo che utilizzi uno schema di indirizzi IP statici, è necessario modificare il valore di `ipv4.method` in `manual` e specificare anche `ipv4.gateway` e `ipv4.addresses`.

    Per modificare un'impostazione, è possibile utilizzare il comando nmcli <codice>nmcli connection modify \[connection\] \[setting\] [value]<codice>.

    ```bash
    # set 10.0.0.10 as the static ipv4 address
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.addresses 10.0.0.10

    # set 10.0.0.1 as the ipv4 gateway
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.gateway 10.0.0.1

    # change ipv4 method to use static assignments (set in the previous two commands)
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.method manual
    ```

    !!! tip "Quando viene aggiornata la connessione?"

        `nmcli connection edit` non modificherà la configurazione *runtime*, ma aggiornerà i file di configurazione `/etc/sysconfig/network-scripts` con i valori appropriati in base a ciò che si è detto a `nmcli` di configurare.

    Per configurare i server DNS con NetworkManager tramite la CLI, è possibile modificare l'impostazione `ipv4.dns`.

    ```bash
    # set 10.0.0.1 and 1.1.1.1 as the primary and secondary DNS servers
    [user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.dns '10.0.0.1 1.1.1.1'
    ```


    ### Applicare la configurazione

    Per applicare la configurazione di rete, si può usare il comando `nmcli connection up [connection]`.

    ```bash
    [user@server ~]$ sudo nmcli connection up enp1s0
    Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/2)
    ```

    Per ottenere lo stato della connessione, è sufficiente utilizzare:

    ```bash
    [user@server ~]$ sudo nmcli connection show
    NAME    UUID                                  TYPE      DEVICE
    enp1s0  625a8aef-175d-4692-934c-2c4a85f11b8c  ethernet  enp1s0
    ```

    Puoi anche usare i comandi `ifup` e `ifdown` per portare l'interfaccia su e giù (sono semplici wrapper intorno a `nmcli`):

    ```bash
    [user@server ~]$ sudo ifup enp1s0
    [user@server ~]$ sudo ifdown enp1s0
    ```


    ## Usare l'utilità ip

    Il comando `ip` (fornito dal pacchetto *iproute2*) è un potente strumento per ottenere informazioni e configurare la rete di un sistema Linux moderno come Rocky Linux.

    In questo esempio, assumeremo i seguenti parametri:

    * nome dell'interfaccia: ens19
    * indirizzo ip: 192.168.20.10
    * maschera di sottorete: 24
    * gateway: 192.168.20.254


    ### Ottenere informazioni di carattere generale

    Per vedere lo stato dettagliato di tutte le interfacce, usare

    ```bash
    ip a
    ```

    !!! hint "**"Suggerimenti professionali:**"

        * usare il flag `-c` per ottenere un output colorato più leggibile: `ip -c a`.
        * `ip` accetta l'abbreviazione quindi `ip a`, `ip addr` e `ip address` sono equivalenti


    ### Portare l'interfaccia su o giù

    Per portare l'interfaccia *ens19* su, basta usare `ip link set ens19 up` e per portarla giù, usare `ip link set ens19 down`.


    ### Assegnare all'interfaccia un indirizzo statico

    Il comando da utilizzare è del tipo:

    ```bash
    ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>
    ```

    Per assegnare i parametri dell'esempio precedente, utilizzeremo:

    ```bash
    ip a add 192.168.20.10/24 dev ens19
    ```

    Quindi, controllare il risultato con:

    ```bash
    ip a show dev ens19
    ```

    verrà visualizzato:

    ```bash
    3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
        inet 192.168.20.10/24 scope global ens19
        valid_lft forever preferred_lft forever
    ```

    La nostra interfaccia è attiva e configurata, ma manca ancora qualcosa!


    ### Usare l'utilità ifcfg

    Per aggiungere all'interfaccia *ens19* il nostro nuovo indirizzo IP di esempio, utilizzare il seguente comando:

    ```bash
    ifcfg ens19 add 192.168.20.10/24
    ```

    Per rimuovere l'indirizzo:

    ```bash
    ifcfg ens19 del 192.168.20.10/24
    ```

    Per disattivare completamente l'indirizzo IP su questa interfaccia:

    ```bash
    ifcfg ens19 stop
    ```

    *Si noti che questa operazione non comporta la disattivazione dell'interfaccia, ma semplicemente la disassegnazione di tutti gli indirizzi IP dall'interfaccia.*


    ### Configurazione del gateway

    Ora che l'interfaccia ha un indirizzo, dobbiamo impostare la sua rotta predefinita:

    ```bash
    ip route add default via 192.168.20.254 dev ens19
    ```

    La tabella di routing del kernel può essere visualizzata con

    ```bash
    ip route
    ```

    o `ip r` in breve.


    ## Controllo della connettività di rete

    A questo punto, l'interfaccia di rete dovrebbe essere attiva e configurata correttamente. Esistono diversi modi per verificare la connettività.

    Facendo *il ping* un altro indirizzo IP della stessa rete (useremo `192.168.20.42` come esempio):

    ```bash
    ping -c3 192.168.20.42
    ```

    Questo comando emette 3 *ping* (noti come richieste ICMP) e attende una risposta. Se tutto è andato bene, si dovrebbe ottenere questo risultato:

    ```bash
    PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
    64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
    64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
    64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms

    --- 192.168.20.42 ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 5ms
    rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms
    ```

    Quindi, per assicurarsi che la configurazione del routing sia corretta, provare a *puntare* un host esterno, come questo noto resolver DNS pubblico:

    ```bash
    ping -c3 8.8.8.8
    ```

    Se la macchina dispone di diverse interfacce di rete e si desidera effettuare una richiesta ICMP attraverso un'interfaccia specifica, è possibile utilizzare la flag `-I`:

    ```bash
    ping -I ens19 -c3 192.168.20.42
    ```

    Ora è il momento di verificare che la risoluzione DNS funzioni correttamente. Come promemoria, la risoluzione DNS è un meccanismo utilizzato per convertire i nomi delle macchine a misura d'uomo nei loro indirizzi IP e viceversa (reverse DNS).

    Se il file `/etc/resolv.conf` indica un server DNS raggiungibile, dovrebbe funzionare quanto segue:

    ```bash
    host rockylinux.org
    ```

    Il risultato dovrebbe essere:

    ```bash
    rockylinux.org has address 76.76.21.21
    ```


    ## Conclusioni

    Rocky Linux 8 dispone degli strumenti per configurare la rete dalla riga di comando. Questo documento dovrebbe consentirvi di utilizzare rapidamente questi strumenti.
