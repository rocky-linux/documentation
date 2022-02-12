---
title: Configurazione della Rete
---

# Configurazione della Rete

## Prerequisiti

* Una certa comodità nell'operare dalla linea di comando
* Privilegi elevati o amministrativi sul sistema (per esempio root, sudo e così via)
* Opzionale: familiarità con i concetti di rete

# Introduzione

Oggi un computer senza connettività di rete è quasi inutile da solo. Sia che abbiate bisogno di aggiornare i pacchetti su un server o semplicemente di navigare su siti Web esterni dal vostro portatile - avrete bisogno di un accesso alla rete!

Questa guida mira a fornire agli utenti di Rocky Linux le conoscenze di base su come impostare la connettività di rete su un sistema Rocky Linux.

## Usare il servizio NetworkManager

A livello utente, lo stack di rete è gestito da *NetworkManager*. Questo strumento funziona come un servizio, e potete controllare il suo stato con il seguente comando:

    systemctl status NetworkManager

### File di configurazione

NetworkManager applica semplicemente una configurazione letta dai file trovati in `/etc/sysconfig/network-scripts/ifcfg-<IFACE_NAME>`. Ogni interfaccia di rete ha il suo file di configurazione. L'esempio seguente nella configurazione predefinita per un server:

    TYPE=Ethernet
    PROXY_METHOD=none
    BROWSER_ONLY=no
    BOOTPROTO=none
    DEFROUTE=yes
    IPV4_FAILURE_FATAL=no
    IPV6INIT=no
    NAME=ens18
    UUID=74c5ccee-c1f4-4f45-883f-fc4f765a8477
    DEVICE=ens18
    ONBOOT=yes
    IPADDR=192.168.0.1
    PREFIX=24
    GATEWAY=192.168.0.254
    DNS1=192.168.0.254
    DNS2=1.1.1.1
    IPV6_DISABLED=yes

Il nome dell'interfaccia è **ens18** quindi il nome di questo file sarà `/etc/sysconfig/network-scripts/ifcfg-ens18`.

**Suggerimento:**  
Ci sono alcuni modi o meccanismi con cui si possono assegnare ai sistemi le loro informazioni di configurazione IP. I 2 metodi più comuni sono: schema di **configurazione IP statico** e schema di **configurazione IP dinamico**.

Lo schema di configurazione IP statico è molto popolare nei sistemi o nelle reti di classe server.

L'approccio IP dinamico è popolare nelle reti domestiche e d'ufficio - o nei sistemi di classe workstation e desktop.  Lo schema dinamico di solito ha bisogno di _qualcosa_ in più che sia disponibile localmente e che possa fornire informazioni di configurazione IP adeguate alle workstation e ai desktop richiedenti. Questo _qualcosa_ si chiama Dynamic Host Configuration Protocol (DHCP).

Molto spesso, gli utenti di casa/ufficio non devono preoccuparsi o conoscere il DHCP. Questo perché qualcuno o qualcos'altro se ne sta occupando automaticamente in background. L'unica cosa che l'utente finale deve fare è connettersi fisicamente o senza fili alla rete giusta (e naturalmente assicurarsi che i suoi sistemi siano accesi)!

#### Indirizzo IP

Nel precedente elenco `/etc/sysconfig/network-scripts/ifcfg-ens18`, vediamo che il valore del parametro o chiave `BOOTPROTO` è impostato su `none`. Questo significa che il sistema che si sta configurando è impostato su uno schema di indirizzo IP statico.

Se invece volete configurare il sistema per usare uno schema di indirizzo IP dinamico, dovrete cambiare il valore del parametro `BOOTPROTO` da `none` a `dhcp` e rimuovere anche le linee `IPADDR`, `PREFIX` e `GATEWAY`. Questo è necessario perché tutte queste informazioni saranno ottenute automaticamente da qualsiasi server DHCP disponibile.

Per configurare l'attribuzione di un indirizzo IP statico, impostare quanto segue:

* IPADDR: l'indirizzo IP da assegnare all'interfaccia
* PREFIX: la subnet mask in [notazione CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing#CIDR_notation)
* GATEWAY: il gateway predefinito

Il parametro `ONBOOT` impostato su `yes` indica che questa connessione sarà attivata durante l'avvio.

#### Risoluzione DNS

Per ottenere una corretta risoluzione del nome, devono essere impostati i seguenti parametri:

* DNS1: indirizzo IP del nameserver principale
* DNS2: l'indirizzo IP del nameserver secondario


### Applicare la configurazione

Per applicare la configurazione della rete, si può usare il comando `nmcli`:

    nmcli connection up ens18

Per ottenere lo stato della connessione, usate semplicemente

    nmcli connection show

Puoi anche usare i comandi `ifup` e `ifdown` per portare l'interfaccia su e giù (sono semplici wrapper intorno a `nmcli`):

    ifup ens18
    ifdown ens18

### Controllo della configurazione

Potete controllare che la configurazione sia stata applicata correttamente con il seguente comando `nmcli`:

    nmcli device show ens18

che dovrebbe darvi il seguente output:

    GENERAL.DEVICE:                         ens18
    GENERAL.TYPE:                           ethernet
    GENERAL.HWADDR:                         6E:86:C0:4E:15:DB
    GENERAL.MTU:                            1500
    GENERAL.STATE:                          100 (connecté)
    GENERAL.CONNECTION:                     ens18
    GENERAL.CON-PATH:                       /org/freedesktop/NetworkManager/ActiveConnection/1
    WIRED-PROPERTIES.CARRIER:               marche
    IP4.ADDRESS[1]:                         192.168.0.1/24
    IP4.GATEWAY:                            192.168.0.254
    IP4.ROUTE[1]:                           dst = 192.168.0.0/24, nh = 0.0.0.0, mt = 100
    IP4.ROUTE[2]:                           dst = 0.0.0.0/0, nh = 192.168.0.254, mt = 100
    IP4.DNS[1]:                             192.168.0.254
    IP4.DNS[2]:                             1.1.1.1
    IP6.GATEWAY:                            --

## Usare l'utilità ip

Il comando `ip` (fornito dal pacchetto *iproute2* ) è un potente strumento per ottenere informazioni e configurare la rete di un moderno sistema Linux come Rocky Linux.

In questo esempio, assumeremo i seguenti parametri:

* nome dell'interfaccia: ens19
* indirizzo ip: 192.168.20.10
* maschera di sottorete: 24
* gateway: 192.168.20.254

### Ottenere informazioni generali

Per vedere lo stato dettagliato di tutte le interfacce, usate

    ip a

**Suggerimenti professionali:**
* usare il flag `-c` per ottenere un output colorato più leggibile: `ip -c a`.
* `ip` accetta l'abbreviazione quindi `ip a`, `ip addr` e `indirizzo ip` sono equivalenti

### Porta l'interfaccia su o giù

Per portare l'interfaccia *ens19* su, usate semplicemente `ip link set ens19 up` e per portarla giù, usate `ip link set ens19 down`.

### Assegnare all'interfaccia un indirizzo statico

Il comando da usare è della forma:

    ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>

Per assegnare i parametri dell'esempio precedente, useremo:

    ip a add 192.168.20.10/24 dev ens19

Poi, controllando il risultato con:

    ip a show dev ens19

produrrà un output:

    3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
        inet 192.168.20.10/24 scope global ens19
        valid_lft forever preferred_lft forever

La nostra interfaccia è pronta e configurata, ma manca ancora qualcosa!

### Usare l'utilità ifcfg

Per aggiungere all'interfaccia *ens19* il nostro nuovo indirizzo IP di esempio, usate il seguente comando:

    ifcfg ens19 add 192.168.20.10/24

Per rimuovere l'indirizzo:

    ifcfg ens19 del 192.168.20.10/24

Per disabilitare completamente l'indirizzamento IP su questa interfaccia:

    ifcfg ens19 stop

*Si noti che questo non porta l'interfaccia giù, semplicemente rimuove l'assegnazione di tutti gli indirizzi IP dall'interfaccia.*

### Configurazione del gateway

Ora che l'interfaccia ha un indirizzo, dobbiamo impostare il suo percorso predefinito, questo può essere fatto con:

    ip route add default via 192.168.20.254 dev ens19

La tabella di routing del kernel può essere visualizzata con

    ip route

o `ip r` in breve.

## Controllo della connettività di rete

A questo punto, dovreste avere la vostra interfaccia di rete attiva e correttamente configurata. Ci sono diversi modi per verificare la tua connettività.

Facendo *il ping* di un altro indirizzo IP nella stessa rete (useremo `192.168.20.42` come esempio):

    ping -c3 192.168.20.42

Questo comando emetterà 3 *ping* (noto come richiesta ICMP) e aspetterà una risposta. Se tutto è andato bene, dovreste ottenere questo output:

    PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
    64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
    64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
    64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms
    
    --- 192.168.20.42 ping statistics ---
    3 packets transmitted, 3 received, 0% packet loss, time 5ms
    rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms

Poi, per assicurarsi che la vostra configurazione di routing sia a posto, provate a *fare un ping* a un host esterno, come questo noto resolver DNS pubblico:

    ping -c3 8.8.8.8

Se la tua macchina ha diverse interfacce di rete e vuoi fare una richiesta ICMP attraverso un'interfaccia specifica, puoi usare la flag `-I`:

    ping -I ens19  -c3 192.168.20.42

Ora è il momento di assicurarsi che la risoluzione DNS funzioni correttamente. Come promemoria, la risoluzione DNS è un meccanismo utilizzato per convertire i nomi delle macchine a misura d'uomo nei loro indirizzi IP e viceversa (reverse DNS).

Se il file `/etc/resolv.conf` indica un server DNS raggiungibile, allora il seguente dovrebbe funzionare:

    host rockylinux.org

Il risultato dovrebbe essere:

    rockylinux.org has address 76.76.21.21
