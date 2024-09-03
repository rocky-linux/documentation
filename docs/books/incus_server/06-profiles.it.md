---
title: 6 Profili
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - lxd profiles
---

# Capitolo 6: Profili

In tutto questo capitolo sarà necessario eseguire i comandi come utente non privilegiato ("lxdadmin" se si segue dall'inizio di questo libro).

Quando si installa LXD si ottiene un profilo predefinito, che non può essere rimosso o modificato. Detto questo, è possibile utilizzare il profilo predefinito per creare nuovi profili da utilizzare con i propri container.

Se si esamina l'elenco dei container, si noterà che l'indirizzo IP in ogni caso proviene dall'interfaccia bridged. In un ambiente di produzione, si potrebbe voler usare qualcos'altro. Potrebbe trattarsi di un indirizzo assegnato via DHCP dall'interfaccia LAN o anche di un indirizzo assegnato staticamente dalla WAN.

Se si configura il server LXD con due interfacce e si assegna a ciascuna un IP sulla WAN e sulla LAN, è possibile assegnare gli indirizzi IP del container in base all'interfaccia verso cui il container deve essere rivolto.

A partire dalla versione 9.0 di Rocky Linux (e in realtà qualsiasi copia di Red Hat Enterprise Linux con bug per bug) il metodo per assegnare gli indirizzi IP staticamente o dinamicamente con i profili non funziona.

Ci sono modi per aggirare questo problema, ma è fastidioso. Questo sembra avere a che fare con le modifiche apportate a Network Manager che influiscono su macvlan. macvlan consente di creare molte interfacce con indirizzi Layer 2 diversi.

Per il momento, è bene sapere che questo comporta degli svantaggi quando si scelgono immagini di container basate su RHEL.

## Creazione di un profilo macvlan e sua assegnazione

Per creare il profilo macvlan, utilizzare questo comando:

```bash
lxc profile create macvlan
```

Se si dispone di una macchina con più interfacce e si desidera più di un modello macvlan in base alla rete che si desidera raggiungere, si potrebbe usare "lanmacvlan" o "wanmacvlan" o qualsiasi altro nome che si desidera usare per identificare il profilo. L'uso di "macvlan" nella dichiarazione di creazione del profilo dipende totalmente da voi.

Si vuole cambiare l'interfaccia macvlan, ma prima è necessario sapere qual è l'interfaccia principale del nostro server LXD. Si tratta dell'interfaccia che ha un IP assegnato alla LAN (in questo caso). Per individuare l'interfaccia, utilizzare:

```bash
ip addr
```

Cercare l'interfaccia con l'assegnazione IP LAN nella rete 192.168.1.0/24:

```bash
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 40:16:7e:a9:94:85 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.106/24 brd 192.168.1.255 scope global dynamic noprefixroute enp3s0
       valid_lft 4040sec preferred_lft 4040sec
    inet6 fe80::a308:acfb:fcb3:878f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

In questo caso, l'interfaccia è "enp3s0".

Quindi cambiare il profilo:

```bash
lxc profile device add macvlan eth0 nic nictype=macvlan parent=enp3s0
```

Questo comando aggiunge al profilo macvlan tutti i parametri necessari per l'uso.

Esaminare ciò che questo comando ha creato, utilizzando il comando:

```bash
lxc profile show macvlan
```

Il risultato sarà simile a questo:

```bash
config: {}
description: ""
devices:
  eth0:
    nictype: macvlan
    parent: enp3s0 
    type: nic
name: macvlan
used_by: []
```

È possibile utilizzare i profili per molte altre cose, ma l'assegnazione di un IP statico a un contenitore o l'utilizzo di un server DHCP sono esigenze comuni.

Per assegnare il profilo macvlan a rockylinux-test-8 è necessario procedere come segue:

```bash
lxc profile assign rockylinux-test-8 default,macvlan
```

Fare la stessa cosa per rockylinux-test-9:

```bash
lxc profile assign rockylinux-test-9 default,macvlan
```

Questo dice che si vuole il profilo predefinito e che si vuole applicare anche il profilo macvlan.

## Rocky Linux macvlan

Nelle distribuzioni e nei cloni di RHEL, Network Manager è in costante mutamento. Per questo motivo, il modo in cui funziona il profilo `macvlan` non funziona (almeno rispetto ad altre distribuzioni) e richiede un po' di lavoro aggiuntivo per assegnare gli indirizzi IP da DHCP o staticamente.

Ricordate che tutto questo non ha nulla a che fare con Rocky Linux in particolare, ma con l'implementazione dei pacchetti upstream.

Se si desidera eseguire i container Rocky Linux e utilizzare macvlan per assegnare un indirizzo IP dalle reti LAN o WAN, il processo è diverso a seconda della versione del container del sistema operativo (8.x o 9.x).

### Rocky Linux 9.x macvlan - la soluzione DHCP

Innanzitutto, illustriamo cosa succede quando si arrestano e si riavviano i due container dopo l'assegnazione del profilo macvlan.

L'assegnazione del profilo, tuttavia, non modifica la configurazione predefinita, che è DHCP per impostazione predefinita.

Per verificarlo, procedere come segue:

```bash
lxc restart rocky-test-8
lxc restart rocky-test-9
```

Elencare nuovamente i container e notare che rockylinux-test-9 non ha più un indirizzo IP:

```bash
lxc list
```

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING |                      |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

Come si può vedere, il nostro contenitore Rocky Linux 8.x ha ricevuto l'indirizzo IP dall'interfaccia LAN, mentre il contenitore Rocky Linux 9.x no.

Per dimostrare ulteriormente il problema, è necessario eseguire `dhclient` sul contenitore Rocky Linux 9.0. Questo mostrerà che il profilo macvlan *è stato* effettivamente applicato:

```bash
lxc exec rockylinux-test-9 dhclient
```

Un altro elenco di container mostra ora quanto segue:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.113 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

Ciò sarebbe dovuto accadere con l'arresto e l'avvio del contenitore, ma non è così. Supponendo di voler utilizzare sempre un indirizzo IP assegnato da DHCP, si può risolvere il problema con una semplice voce di crontab. Per farlo, è necessario ottenere l'accesso al container tramite shell, inserendo:

```bash
lxc exec rockylinux-test-9 bash
```

Quindi, determiniamo il percorso di `dhclient`. Per fare ciò, poiché questo container proviene da un'immagine minimale, è necessario prima installare `which`:

```bash
dnf install which
```

quindi eseguire:

```bash
which dhclient
```

che restituirà:

```bash
/usr/sbin/dhclient
```

Successivamente, modificare il crontab di root:

```bash
crontab -e
```

Aggiungere questa riga:

```bash
@reboot    /usr/sbin/dhclient
```

Il comando crontab inserito utilizza *vi*. Per salvare le modifiche e uscire, utilizzare ++shift+colon+"w"+"q"++.

Uscire dal container e riavviare rockylinux-test-9:

```bash
lxc restart rockylinux-test-9
```

Un altro elenco rivelerà che al contenitore è stato assegnato un indirizzo DHCP:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.113 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```

### Rocky Linux 9.x macvlan - La soluzione per l'IP statico

Per assegnare staticamente un indirizzo IP, le cose si fanno ancora più complicate. Poiché gli `network-scripts` sono ormai deprecati in Rocky Linux 9.x, l'unico modo per farlo è l'assegnazione statica e, a causa del modo in cui i container utilizzano la rete, non è possibile impostare la route con una normale istruzione di `route ip`. Il problema è che l'interfaccia assegnata quando si applica il profilo macvlan (eth0 in questo caso) non è gestibile con Network Manager. La soluzione consiste nel rinominare l'interfaccia di rete sul contenitore dopo il riavvio e assegnare l'IP statico. È possibile farlo con uno script ed eseguirlo (di nuovo) nel crontab di root. Per farlo, utilizzare il comando `ip`.

Per farlo, è necessario ottenere nuovamente l'accesso al contenitore:

```bash
lxc exec rockylinux-test-9 bash
```

Successivamente, si creerà uno script bash in `/usr/local/sbin` chiamato "static":

```bash
vi /usr/local/sbin/static
```

Il contenuto di questo script non è difficile:

```bash
#!/usr/bin/env bash

/usr/sbin/ip link set dev eth0 name net0
/usr/sbin/ip addr add 192.168.1.151/24 dev net0
/usr/sbin/ip link set dev net0 up
/usr/sbin/ip route add default via 192.168.1.1
```

Cosa stiamo facendo qui?

* rinominare eth0 con un nuovo nome che possiamo gestire ("net0")
* si assegna il nuovo IP statico che abbiamo allocato per il nostro contenitore (192.168.1.151)
* si apre la nuova interfaccia "net0"
* è necessario aggiungere la route predefinita per la nostra interfaccia

Rendere il nostro script eseguibile con:

```bash
chmod +x /usr/local/sbin/static
```

Aggiungerlo al crontab di root per il contenitore con il @reboot time:

```bash
@reboot     /usr/local/sbin/static
```

Infine, uscire dal container e riavviarlo:

```bash
lxc restart rockylinux-test-9
```

Aspettate qualche secondo e elencate di nuovo i contenitori:

```bash
lxc list
```

Il successo dovrebbe essere visibile:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

## Ubuntu macvlan

Fortunatamente, nell'implementazione di Ubuntu di Network Manager, lo stack macvlan NON è rotto. È molto più facile da distribuire!

Proprio come nel caso del contenitore rockylinux-test-9, è necessario assegnare il profilo al nostro contenitore:

```bash
lxc profile assign ubuntu-test default,macvlan
```

Per scoprire se il DHCP assegna un indirizzo al contenitore, interrompere e riavviare il contenitore:

```bash
lxc restart ubuntu-test
```

Elencare nuovamente i contenitori:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 192.168.1.132 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```

Riuscito!

La configurazione dell'IP statico è leggermente diversa, ma non è affatto difficile. È necessario modificare il file .yaml associato alla connessione del contenitore`(10-lxc.yaml`). Per questo IP statico si utilizzerà 192.168.1.201:

```bash
vi /etc/netplan/10-lxc.yaml
```

Cambiare ciò che c'è con quanto segue:

```bash
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [192.168.1.201/24]
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8,8.8.4.4]
```

Salvare le modifiche e uscire dal container.

Riavviare il container:

```bash
lxc restart ubuntu-test
```

Quando si elencano nuovamente i containeri, si vedrà il proprio IP statico:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 192.168.1.114 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 192.168.1.151 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 192.168.1.201 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+

```

Riuscito!

Negli esempi utilizzati in questo capitolo, è stato scelto intenzionalmente un container difficile da configurare e due meno difficili. Ci sono molte altre versioni di Linux disponibili nell'elenco delle immagini. Se ne avete uno preferito, provate a installarlo, assegnate il modello macvlan e impostate gli IP.
