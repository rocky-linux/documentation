---
title: Configurazione della Rete
contributors: Steven Spencer, Hayden Young, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - networking
  - configuration
  - network
---

## Introduzione

You cannot do much with a computer these days without network connectivity. Sia che dobbiate aggiornare i pacchetti su un server o navigare su siti web esterni dal tuo laptop, avrete bisogno di un accesso alla rete. Questa guida ha lo scopo di fornire agli utenti di Rocky Linux le conoscenze di base sulla configurazione della connettività di rete.

Molto è cambiato nella configurazione di rete a partire da Rocky Linux 10. Una delle modifiche principali è la rimozione di Network-Scripts (deprecato in Rocky Linux 9) a favore dell'uso di Network Manager e dei file chiave. `NetworkManager` dalla versione 10 in poi, preferisce i `keyfiles` rispetto ai precedenti file `ifcfg`. Questa guida intende illustrare l'utilizzo di Network Manager e le ultime modifiche apportate a Rocky Linux 10.

## Prerequisiti

- Una certa comodità nell'operare dalla riga di comando
- Privilegi elevati o amministrativi sul sistema (ad esempio, root, `sudo` e così via)
- Opzionale: familiarità con i concetti di rete

## Usare il servizio NetworkManager

A livello utente, la gestione dello stack di rete è affidata a `NetworkManager`. Questo tool è eseguito come un servizio. È possibile verificarne lo stato con il seguente comando:

```bash
systemctl status NetworkManager
```

## File di configurazione

Come indicato all'inizio, i file di configurazione predefiniti sono ora key file. È possibile vedere come `NetworkManager` assegna la priorità a questi file eseguendo il seguente comando:

```
NetworkManager --print-config
```

Il comando darà questo risultato o uno simile:

```
[main]
# plugins=keyfile
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

Notare il riferimento a `keyfile` nella parte superiore del file di configurazione. Ogni volta che si esegue uno degli tools di `NetworkManager` per configurare un'interfaccia (ad esempio: `nmcli` o `nmtui`), questo costruisce o aggiorna automaticamente i key files.

!!! tip "Configurazione posizione di archiviazione"

    Con Rocky Linux 10, il nuovo percorso di archiviazione predefinita per i keyfile è in `/etc/NetworkManager/system-connections`.

L'utilità principale (ma non l'unica) utilizzata per configurare un'interfaccia di rete è il comando `nmtui`. È possibile eseguire questa operazione anche con il comando `nmcli`, ma è molto meno intuitivo. È possibile visualizzare l'interfaccia così come è attualmente configurata utilizzando `nmcli` con:

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

!!! tip "**Suggerimenti:**"  

    Esistono diversi meccanismi attraverso i quali i sistemi ottengono le informazioni relative alla configurazione IP.
    I due metodi più comuni sono: lo schema di **configurazione IP statica** e lo schema di **configurazione IP dinamica**.
    
    Lo schema di configurazione IP statico è molto diffuso nei sistemi o nelle reti di tipo server.
    
    L'approccio IP dinamico è molto diffuso nelle reti domestiche e di ufficio o nei sistemi di classe workstation e desktop in ambiente aziendale.  Lo schema dinamico richiede solitamente *qualcosa* in più che sia disponibile localmente e che possa fornire informazioni adeguate sulla configurazione IP alle workstation e ai desktop che ne fanno richiesta. Questo *qualcosa* si chiama Dynamic Host Configuration Protocol (DHCP). In una rete domestica, e anche nella maggior parte delle reti aziendali, questo servizio è fornito da un server DHCP configurato allo scopo. Può trattarsi di un server separato o di una parte della configurazione del router.

## Indirizzo IP

Nella sezione precedente, la configurazione visualizzata per l'interfaccia `enp0s3` viene generata dal file `.ini`  `/etc/NetworkManager/system-connections/enp0s3.nmconnection`. Ciò dimostra che IP4.ADDRESS[1] è configurato in modo statico, anziché dinamico con DHCP. Se si desidera riportare questa interfaccia a un indirizzo allocato dinamicamente, il modo più semplice è utilizzare il comando `nmtui`.

 1. Per prima cosa, eseguire il comando `nmtui` a riga di comando, che dovrebbe mostrare quanto segue

    ![nmtui](images/nmtui_first.png)

 2. È già presente la selezione "Modifica una connessione", quindi premere il tasto ++tab++ in modo da evidenziare "OK" e premete ++enter++

 3. Verrà visualizzata una schermata che mostra le connessioni Ethernet della macchina e consentirà di sceglierne una. In questo caso, ce n'è *SOLO* uno, quindi è già evidenziato. È necessario premere il tasto ++tab++ fino a quando non viene evidenziata la voce “Modifica”, quindi premere ++enter++.

    ![nmtui_edit](images/nmtui_edit.png)

 4. Una volta fatto questo, ci troveremo nella schermata che mostra la nostra configurazione attuale. È necessario passare da "Manuale" ad "Automatico", quindi premere più volte il tasto ++tab++ fino ad evidenziare "Manuale" e premere ++enter++.

    ![nmtui_manual](images/nmtui_manual.png)

 5. La freccia verso l'alto fino a evidenziare "Automatico", quindi premere ++enter++

    ![nmtui_automatic](images/nmtui_automatic.png)

 6. Una volta impostata l'interfaccia su “Automatico”, è necessario rimuovere l'IP assegnato staticamente. Premere il tasto ++tab++ fino a quando non viene evidenziata la voce “Rimuovi” accanto all'indirizzo IP, quindi premere ++Invio++.

    ![nmtui_remove](images/nmtui_remove.png)

 7. Infine, premete più volte il tasto ++tab++ finché non arrivate in fondo alla schermata `nmtui` e non viene evidenziato "OK" e premete ++enter++

È possibile disattivare e riattivare l'interfaccia anche con `nmtui`, ma facciamo questo con `nmcli`. In questo modo è possibile concatenare la disattivazione dell'interfaccia e la sua riattivazione in modo che l'interfaccia non rimanga mai inattiva a lungo:

```
nmcli con down enp0s3 && nmcli con up enp0s3
```

Lo si consideri equivalente al vecchio `ifdown enp0s3 && ifup enp0s3` utilizzato nelle versioni precedenti del sistema operativo.

Per verificare che funzioni, procedere e controllare utilizzando il comando `ip addr` o il comando `nmcli device show enp0s3` utilizzato in precedenza.

```
ip addr
```

Se l'operazione ha avuto esito positivo, si dovrebbe ora vedere che l'IP statico è stato rimosso e che è stato aggiunto un indirizzo assegnato dinamicamente, simile a questo:

```bash
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
link/ether 08:00:27:ba:ce:88 brd ff:ff:ff:ff:ff:ff
inet 192.168.1.137/24 brd 192.168.1.255 scope global dynamic noprefixroute enp0s3
    valid_lft 6342sec preferred_lft 6342sec
inet6 fe80::a00:27ff:feba:ce88/64 scope link noprefixroute 
    valid_lft forever preferred_lft forever
```

### Modificare l'indirizzo IP con `nmcli`

L'uso di `nmtui` è comodo, ma se si vuole solo riconfigurare rapidamente l'interfaccia di rete senza dover passare tra una schermata e l'altra, probabilmente è meglio usare `nmcli` da solo. Si esamini l'esempio precedente di un IP assegnato staticamente e i passi per riconfigurare l'interfaccia in DHCP usando solo `nmcli`.

Prima di iniziare, è necessario sapere che per riconfigurare l'interfaccia in DHCP è necessario:

- Rimuovere il gateway IPv4
- Rimuovere l'indirizzo IPv4 che si è assegnato in modo statico
- Cambiare il metodo IPv4 in automatico
- Disattivare e riattivare l'interfaccia

Si noti anche che non si stanno usando esempi che dicono di usare -ipv4.address ecc. Questi non cambiano completamente l'interfaccia. Per farlo, è necessario impostare ipv4.address e ipv4.gateway su una stringa vuota. Anche in questo caso, per risparmiare il più possibile tempo con questi comandi, li uniremo tutti in un'unica riga:

```bash
nmcli con mod enp0s3 ipv4.gateway '' && nmcli con mod enp0s3 ipv4.address '' && nmcli con mod enp0s3 ipv4.method auto && nmcli con down enp0s3 && nmcli con up enp0s3
```

Eseguendo nuovamente il comando `ip addr` si otterranno gli stessi risultati di quando si sono eseguite le modifiche con `nmtui`. Ovviamente si potrebbe fare tutto anche al contrario (cambiando l'indirizzo DHCP con uno statico). Per farlo, si eseguono i comandi al contrario, iniziando con il cambiare `ipv4.method` in manual, impostando `ipv4.gateway` e quindi impostando `ipv4.address`. Poiché in tutti questi esempi si stà riconfigurando completamente l'interfaccia e non aggiungendo o sottraendo valori ad essa, non si utilizzeranno gli esempi che parlano dell'uso di `+ipv4.method`,`+ipv4.gateway`, e `+ipv4.address`. Se si usassero questi comandi al posto di quelli usati sopra, si otterrebbe un'interfaccia con *sia* un indirizzo assegnato da DHCP che uno assegnato staticamente. Detto questo, a volte può essere molto utile. Se si dispone di un servizio Web in ascolto su un IP e di un server `sftp` in ascolto su un altro IP. Avere un metodo di assegnazione di IP multipli a un'interfaccia è abbastanza utile.

## Risoluzione del DNS

È possibile impostare i server DNS con `nmtui` o `nmcli`. Sebbene l'interfaccia `nmtui` sia facile da navigare e molto più intuitiva, il processo è molto più lento. L'operazione con `nmcli` è molto più veloce. Nel caso dell'indirizzo assegnato dal DHCP, solitamente non è necessario impostare i server DNS poiché questi vengono normalmente inoltrati dal server DHCP. Detto questo, *è possibile* aggiungere staticamente i server DNS a un'interfaccia DHCP. Nel caso di un'interfaccia assegnata staticamente, sarà *NECESSARIO* fare questa operazione, poiché dovrà sapere come ottenere la risoluzione DNS e non avrà un metodo assegnato automaticamente.

Poiché l'esempio migliore per tutto ciò è un IP assegnato staticamente, torniamo all'indirizzo assegnato staticamente originale nell'interfaccia di esempio (enp0s3). Prima di modificare i valori DNS, è necessario verificare quali sono quelli attuali. Per ottenere una risoluzione corretta dei nomi, rimuovere i server DNS già impostati e aggiungerne di diversi. Attualmente `ipv4.dns` è `8.8.8.8,8.8.4.4,192.168.1.1`. In questo caso, non è necessario impostare ipv4.dns su una stringa vuota. È possibile utilizzare il seguente comando per sostituire i valori:

```bash
nmcli con mod enp0s3 ipv4.dns '208.67.222.222,208.67.220.220,192.168.1.1'
```

Eseguendo `nmcli con show enp0s3 | grep ipv4.dns` si dovrebbe vedere che sono stati modificati correttamente i server DNS. Per attivare il tutto, chiudere e riaprire l'interfaccia in modo che le modifiche siano attive:

```bash
nmcli con down enp0s3 && nmcli con up enp0s3
```

Per verificare che *funzioni* la risoluzione dei nomi, provare a eseguire il ping di un host noto. Prendiamo come esempio google.com:

```bash
ping google.com
PING google.com (172.217.4.46) 56(84) bytes of data.
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=1 ttl=119 time=14.5 ms
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=2 ttl=119 time=14.6 ms
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=3 ttl=119 time=14.4 ms
^C
```

## Utilizzo dell'utility `ip`

Il comando `ip` (fornito dal pacchetto *iproute2*) è un potente strumento per ottenere informazioni e configurare la rete di un sistema Linux moderno come Rocky Linux.

In questo esempio, si assumeranno i seguenti parametri:

- nome dell'interfaccia: enp0s3
- indirizzo ip: 192.168.1.151
- subnet mask: 24
- gateway: 192.168.1.1

### Ottenere informazioni di carattere generale

Per vedere lo stato dettagliato di tutte le interfacce, usare

```bash
ip a
```

!!! hint "**"Suggerimenti professionali:**"

    * usare il flag `-c` per ottenere un output colorato più leggibile: `ip -c a`.
    * `ip` accetta l'abbreviazione, quindi `ip a`, `ip addr` e `ip address` sono equivalenti

### Porta l'interfaccia su o giù

!!! note "Nota"

    Sebbene sia ancora possibile utilizzare questo metodo per attivare e disattivare l'interfaccia in Rocky Linux 10, il comando reagisce in modo molto più lento rispetto al semplice utilizzo del comando `nmcli`.

Per disattivare e riattivare *enp0s3*, è sufficiente utilizzare:

```bash
ip link set enp0s3 down && ip link set enp0s3 up
```

### Assegnare all'interfaccia un indirizzo statico

Attualmente, l'interfaccia enp0s3 ha un indirizzo IP pari a 192.168.1.151. Per passare a 192.168.1.152, si dovrebbe rimuovere il vecchio IP con

```bash
ip addr delete 192.168.1.151/24 dev enp0s3 && ip addr add 192.168.1.152/24 dev enp0s3
```

Se si desidera assegnare un secondo indirizzo IP all'interfaccia invece di rimuovere l'indirizzo 192.168.1.151, è sufficiente aggiungere il secondo indirizzo con:

```bash
ip addr add 192.168.1.152/24 dev enp0s3
```

È possibile verificare l'indirizzo IP aggiunto con:

```bash
ip a show dev enp0s3
```

Questo produrrà il seguente risultato:

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

Sebbene l'utilizzo dell'utilità `ip` per disattivare e riattivare l'interfaccia sia molto più lento rispetto a `nmcli`, `ip` presenta un netto vantaggio quando si impostano indirizzi IP nuovi o aggiuntivi, poiché l'operazione avviene in tempo reale, senza disattivare e riattivare l'interfaccia.

### Configurazione del gateway

Ora che l'interfaccia ha un indirizzo, si deve impostare il suo percorso predefinito. E' possibile farlo con:

```bash
ip route add default via 192.168.1.1 dev enp0s3
```

È possibile visualizzare la tabella di routing del kernel con:

```bash
ip route
```

o `ip r` in breve.

Il risultato dovrebbe essere simile al seguente:

```bash
default via 192.168.1.1 dev enp0s3 
192.168.1.0/24 dev enp0s3 proto kernel scope link src 192.168.1.151 metric 100
```

## Controllo della connettività di rete

Nel corso degli esempi riportati in questo documento si sono effettuati alcuni test. La cosa migliore da fare è iniziare con il ping del gateway predefinito. Questo dovrebbe funzionare sempre:

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

Esegui un test per assicurarsi di poter vedere un host raggiungibile esterno alla rete locale. Per questo test, l'esempio utilizza il server DNS aperto di Google:

```bash
ping -c3 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=119 time=19.8 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=119 time=20.2 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=119 time=20.1 ms
```

Il test finale consiste nel verificare che la risoluzione DNS funzioni. Per questo esempio, utilizzando google.com:

```bash
ping -c3 google.com
PING google.com (172.217.4.46) 56(84) bytes of data.
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=1 ttl=119 time=14.5 ms
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=2 ttl=119 time=15.1 ms
64 bytes from lga15s46-in-f14.1e100.net (172.217.4.46): icmp_seq=3 ttl=119 time=14.6 ms
```

Se sul computer sono presenti diverse interfacce e si desidera eseguire il test da un'interfaccia specifica, utilizzare l'opzione `-I` con ping:

```bash
ping -I enp0s3 -c3 192.168.1.10
```

## Conclusione

Ci sono molte modifiche allo stack di rete in Rocky Linux 10. Tra queste vi è la rimozione di Network-Scripts e, con essa, la possibilità di utilizzare `ifcfg`. Rocky Linux 10 utilizza invece `keyfiles`. Questo documento si concentra sull'uso di Network Manager e degli strumenti sottostanti, `nmcli` e `nmtui`. Inoltre, questo documento illustra il comando `ip` insieme ad alcuni esempi del suo utilizzo per la configurazione di rete.
