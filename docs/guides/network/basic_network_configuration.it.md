---
title: Configurazione della Rete
author: unknown
contributors: Steven Spencer, Franco Colussi
tested with: 8.5
tags:
  - networking
  - configuration
  - network
---

# Configurazione della Rete

## Prerequisiti

* Una certa comodità nell'operare dalla riga di comando
* Privilegi elevati o amministrativi sul sistema (per esempio root, sudo e così via)
* Opzionale: familiarità con i concetti di rete

## Introduzione

Oggi un computer senza connettività di rete è quasi inutile da solo. Sia che abbiate bisogno di aggiornare i pacchetti su un server o semplicemente di navigare su siti Web esterni dal vostro portatile - avrete bisogno di un accesso alla rete!

Questa guida mira a fornire agli utenti di Rocky Linux le conoscenze di base su come impostare la connettività di rete su un sistema Rocky Linux.

## Usare il servizio NetworkManager

A livello utente, lo stack di rete è gestito da *NetworkManager*. Questo strumento funziona come un servizio, e potete controllare il suo stato con il seguente comando:

```bash
systemctl status NetworkManager
```

### File di configurazione

NetworkManager applica semplicemente una configurazione letta dai file trovati in `/etc/sysconfig/network-scripts/ifcfg-<IFACE_NAME>`. Ogni interfaccia di rete ha il suo file di configurazione. Di seguito è riportato un esempio di configurazione predefinita di un server:

```bash
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
```

Il nome dell'interfaccia è **enp1s0** quindi il nome di questo file sarà `/etc/sysconfig/network-scripts/ifcfg-enp1s0`.

!!! hint "**Suggerimenti:**"  

    Ci sono alcuni modi o meccanismi con cui i sistemi possono essere assegnati alle loro informazioni di configurazione IP. I due metodi più comuni sono: lo schema **Configurazione IP statica** e lo schema **Configurazione IP dinamica**.
    
    Lo schema di configurazione IP statico è molto popolare nei sistemi o nelle reti di classe server.
    
    L'approccio IP dinamico è popolare nelle reti domestiche e d'ufficio - o nei sistemi di classe workstation e desktop.  Lo schema dinamico di solito ha bisogno di _qualcosa_ in più che sia disponibile localmente e che possa fornire informazioni di configurazione IP adeguate alle stazioni di lavoro e ai desktop richiedenti. Questo _qualcosa_ si chiama Dynamic Host Configuration Protocol (DHCP).

Molto spesso, gli utenti di casa/ufficio non devono preoccuparsi o conoscere il DHCP. Questo perché qualcuno o qualcos'altro se ne sta occupando automaticamente in background. L'unica cosa che l'utente finale deve fare è connettersi fisicamente o senza fili alla rete giusta (e naturalmente assicurarsi che i suoi sistemi siano accesi)!

#### Indirizzi IP

Nel precedente elenco `/etc/sysconfig/network-scripts/ifcfg-enp1s0`, vediamo che il valore del parametro o chiave `BOOTPROTO` è impostato su `none`. Questo significa che il sistema che si sta configurando è impostato su uno schema di indirizzo IP statico.

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

#### Controllo della configurazione

Potete controllare che la configurazione sia stata applicata correttamente con il seguente comando `nmcli`:

```bash
[user@server ~]$ sudo nmcli device show enp1s0
```

che dovrebbe darvi il seguente output:

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

La funzione primaria di NetworkManager è quella di gestire le "connessioni" che mappano un dispositivo fisico a componenti di rete più logici come un indirizzo IP e impostazioni DNS. Per visualizzare le connessioni esistenti mantenute da NetworkManager, è possibile eseguire `nmcli connection show`.

```bash
[user@server ~]$ sudo nmcli connection show
NAME    UUID                                  TYPE      DEVICE
enp1s0  625a8aef-175d-4692-934c-2c4a85f11b8c  ethernet  enp1s0
```

Dall'output precedente, possiamo determinare che NetworkManager gestisce una connessione (`NAME`) chiamata `enp1s0` che si riferisce al dispositivo fisico (`DEVICE`) `enp1s0`.

!!! hint "Nome connessione"

    In questo esempio, sia la connessione che il dispositivo condividono lo stesso nome, ma questo potrebbe non essere sempre il caso. È comune vedere una connessione chiamata `System eth0` che viene mappata su un dispositivo chiamato `eth0`, per esempio.

Ora che conosciamo il nome della nostra connessione, possiamo visualizzare le sue impostazioni. Per fare questo, usa il comando `nmcli connection show [connection]`, che stamperà tutte le impostazioni di NetworkManager registrate per la connessione specificata.

```bash
[user@server ~]$ sudo nmcli connection show enp1s0
...
ipv4.method: auto
ipv4. ns: --
ipv4. ns-search: --
ipv4. ns-options: --
ipv4. ns-priority: 0
ipv4. ddresses: --
ipv4. ateway: --
ipv4. outes: --
ipv4. oute-metric: -1
ipv4. oute-table: 0 (unspec)
ipv4. outing-rules: --
ipv4. gnore-auto-routes: no
ipv4. gnore-auto-dns: no
ipv4. hcp-client-id: --
ipv4. hcp-iaid: --
ipv4. hcp-timeout: 0 (predefinito)
ipv4. hcp-send-hostname: sì
...
```

Lungo la colonna di sinistra, vediamo il nome dell'impostazione e giù a destra vediamo il valore.

Ad esempio, possiamo vedere che il metodo `ipv4.method` qui è attualmente impostato su `auto`. Ci sono molti valori consentiti per l'impostazione `ipv4.method` , ma i due principali che molto probabilmente vedrai sono:

* `auto`: per l'interfaccia viene utilizzato il metodo automatico appropriato (DHCP, PPP, ecc.) e la maggior parte delle altre proprietà possono essere lasciate non impostate.
* `manual`: viene utilizzato un indirizzamento IP statico e almeno un indirizzo IP deve essere indicato nella proprietà 'addresses'.

Se invece si desidera configurare il sistema in modo che utilizzi uno schema di indirizzi IP statici, è necessario modificare il valore di `ipv4.method` in `manual` e specificare anche `ipv4.gateway` e `ipv4.addresses`.

Per modificare un'impostazione, è possibile utilizzare il comando nmcli `nmcli connection modify [connection] [setting] [value]`.

```bash
# set 10.0.0.10 as the static ipv4 address
[user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.addresses 10.0.0.10

# set 10.0.0.1 as the ipv4 gateway
[user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.gateway 10.0.0.1

# change ipv4 method to use static assignments (set in the previous two commands)
[user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.method manual
```

!!! hint "Quando viene aggiornata la connessione?"

    `nmcli connection modify` non modificherà la configurazione *runtime*, ma aggiorna i file di configurazione `/etc/sysconfig/network-scripts` con i valori appropriati in base a quello che hai detto a `nmcli` di configurare.

Per configurare i server DNS con NetworkManager tramite la CLI, è possibile modificare l'impostazione `ipv4.dns`.

```bash
# set 10.0.0.1 and 1.1.1.1 as the primary and secondary DNS servers
[user@server ~]$ sudo nmcli connection modify enp1s0 ipv4.dns '10.0.0.1 1.1.1.1'
```

### Applicare la configurazione

Per applicare la configurazione di rete, è possibile utilizzare il comando `nmcli connection up [connection]`.

```bash
[user@server ~]$ sudo nmcli connection up enp1s0
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/2)
```

Per ottenere lo stato della connessione, usate semplicemente:

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

Il comando `ip` (fornito dal pacchetto *iproute2*) è un potente strumento per ottenere informazioni e configurare la rete di un moderno sistema Linux come Rocky Linux.

In questo esempio, assumeremo i seguenti parametri:

* nome dell'interfaccia: ens19
* indirizzo ip: 192.168.20.10
* maschera di sottorete: 24
* gateway: 192.168.20.254

### Ottenere informazioni generali

Per vedere lo stato dettagliato di tutte le interfacce, usate

```bash
ip a
```

!!! hint "**"Suggerimenti:**"

    * usare il flag `-c` per ottenere un output colorato più leggibile: `ip -c a`.
    * `ip` accetta l'abbreviazione quindi `ip a`, `ip addr` e `ip address` sono equivalenti

### Porta l'interfaccia su o giù

Per portare l'interfaccia *ens19* su, usate semplicemente `ip link set ens19 up` e per portarla giù, usate `ip link set ens19 down`.

### Assegnare all'interfaccia un indirizzo statico

Il comando da usare è della forma:

```bash
ip addr add <IP ADDRESS/CIDR> dev <IFACE NAME>
```

Per assegnare i parametri dell'esempio precedente, useremo:

```bash
ip a add 192.168.20.10/24 dev ens19
```

Poi, controllando il risultato con:

```bash
ip a show dev ens19
```

produrrà un output:

```bash
    3: ens19: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        link/ether 4a:f2:f5:b6:aa:9f brd ff:ff:ff:ff:ff:ff
        inet 192.168.20.10/24 scope global ens19
        valid_lft forever preferred_lft forever
```

La nostra interfaccia è pronta e configurata, ma manca ancora qualcosa!

### Usare l'utilità ifcfg

Per aggiungere l'interfaccia *ens19* del nostro nuovo indirizzo IP di esempio, usate il seguente comando:

```bash
ifcfg ens19 add 192.168.20.10/24
```

Per rimuovere l'indirizzo:

```bash
ifcfg ens19 del 192.168.20.10/24
```

Per disabilitare completamente l'indirizzamento IP su questa interfaccia:

```bash
ifcfg ens19 stop
```

*Si noti che questo non porta l'interfaccia giù, semplicemente rimuove l'assegnazione di tutti gli indirizzi IP dall'interfaccia.*

### Configurazione del gateway

Ora che l'interfaccia ha un indirizzo, dobbiamo impostare il suo percorso predefinito, questo può essere fatto con:

```bash
ip route add default via 192.168.20.254 dev ens19
```

La tabella di routing del kernel può essere visualizzata con

```bash
ip route
```

o `ip r` in breve.

## Controllo della connettività di rete

A questo punto, dovreste avere la vostra interfaccia di rete attiva e correttamente configurata. Ci sono diversi modi per verificare la tua connettività.

Facendo *il ping* di un altro indirizzo IP nella stessa rete (useremo `192.168.20.42` come esempio):

```bash
ping -c3 192.168.20.42
```

Questo comando emetterà 3 *ping* (noto come richiesta ICMP) e aspetterà una risposta. Se tutto è andato bene, dovreste ottenere questo output:

```bash
PING 192.168.20.42 (192.168.20.42) 56(84) bytes of data.
64 bytes from 192.168.20.42: icmp_seq=1 ttl=64 time=1.07 ms
64 bytes from 192.168.20.42: icmp_seq=2 ttl=64 time=0.915 ms
64 bytes from 192.168.20.42: icmp_seq=3 ttl=64 time=0.850 ms

--- 192.168.20.42 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 0.850/0.946/1.074/0.097 ms
```

Poi, per assicurarsi che la vostra configurazione di routing sia a posto, provate a *fare un ping* a un host esterno, come questo noto resolver DNS pubblico:

```bash
ping -c3 8.8.8.8
```

Se la tua macchina ha diverse interfacce di rete e vuoi fare una richiesta ICMP attraverso un'interfaccia specifica, puoi usare la flag `-I`:

```bash
ping -I ens19 -c3 192.168.20.42
```

Ora è il momento di assicurarsi che la risoluzione DNS funzioni correttamente. Come promemoria, la risoluzione DNS è un meccanismo utilizzato per convertire i nomi delle macchine a misura d'uomo nei loro indirizzi IP e viceversa (reverse DNS).

Se il file `/etc/resolv.conf` indica un server DNS raggiungibile, allora il seguente dovrebbe funzionare:

```bash
host rockylinux.org
```

Il risultato dovrebbe essere:

```bash
rockylinux.org has address 76.76.21.21
```
