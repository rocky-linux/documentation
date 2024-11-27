---
title: 6 Profili
author: Spencer Steven
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus profiles
---

In questo capitolo, i comandi devono essere eseguiti come utente non privilegiato (“incusadmin” se avete seguito questo libro dall'inizio).

Quando si installa Incus, si ottiene un profilo predefinito, che non può essere rimosso o modificato. È possibile utilizzare il profilo predefinito per creare nuovi profili per i propri container.

Se si esamina l'elenco dei container, si noterà che l'indirizzo IP in ogni caso proviene dall'interfaccia bridged. In un ambiente di produzione, si potrebbe voler usare qualcos'altro. Può trattarsi di un indirizzo assegnato tramite DHCP dall'interfaccia LAN o di un indirizzo assegnato staticamente dalla WAN.

Se si configura il server Incus con due interfacce e si assegna a ciascuna un IP sulla WAN e sulla LAN, è possibile assegnare gli indirizzi IP del container in base all'interfaccia verso cui il container si deve rivolgere.

A partire dalla versione 9.4 di Rocky Linux (e da qualsiasi copia di Red Hat Enterprise Linux con bug), il metodo per assegnare gli indirizzi IP staticamente o dinamicamente con i profili non funziona.

Ci sono modi per aggirare questo problema, ma è difficile. Questo sembra avere a che fare con le modifiche apportate a Network Manager che influenzano `macvlan`. `macvlan` consente di creare molte interfacce con indirizzi Layer 2 diversi.

Tenere presente che questo comporta degli svantaggi quando si scelgono immagini di container basate su RHEL.

## Creare un profilo `macvlan` ed assegnarlo

Per creare il profilo `macvlan`, utilizzare questo comando:

```bash
incus profile create macvlan
```

Se ci si trova su una macchina multi-interfaccia e si vuole più di un modello `macvlan` in base alla rete che si vuole raggiungere, si potrebbe usare “lanmacvlan” o “wanmacvlan” o qualsiasi altro nome che si voglia usare per identificare il profilo. L'uso di “macvlan” nel comando di creazione del profilo dipende da voi.

Si vuole cambiare l'interfaccia `macvlan`, ma prima di farlo, è necessario sapere qual è l'interfaccia principale del server Incus. Questa interfaccia avrà un IP assegnato alla LAN (in questo caso). Per individuare l'interfaccia, utilizzare:

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

Successivamente, cambiare il profilo.

```bash
incus profile device add macvlan eth0 nic nictype=macvlan parent=enp3s0
```

Questo comando aggiunge tutti i parametri necessari al profilo `macvlan` per il suo utilizzo.

Esaminare ciò che questo comando ha creato utilizzando il comando:

```bash
incus profile show macvlan
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

I profili possono essere usati per molte altre cose, ma l'assegnazione di un IP statico a un container o l'uso del proprio server DHCP sono esigenze comuni.

Per assegnare il profilo `macvlan` a rockylinux-test-8, occorre procedere come segue:

```bash
incus profile assign rockylinux-test-8 default,macvlan
```

Fare la stessa cosa per rockylinux-test-9:

```bash
incus profile assign rockylinux-test-9 default,macvlan
```

Questo comando specifica che si vuole il profilo predefinito e che si vuole applicare anche il profilo `macvlan`.

## Rocky Linux `macvlan`

Il Network Manager è cambiato costantemente nelle distribuzioni e nei cloni di RHEL. Proprio per questo motivo, il modo in cui lavora il profilo `macvlan` non funziona (almeno rispetto ad altre distribuzioni) e richiede un lavoro aggiuntivo per assegnare gli indirizzi IP da DHCP o staticamente.

Bisogna ricordare che tutto questo non ha nulla a che fare con Rocky Linux, ma con l'implementazione dei pacchetti upstream.

Se si desidera eseguire i container Rocky Linux e utilizzare `macvlan` per assegnare un indirizzo IP dalle reti LAN o WAN, il processo è diverso a seconda della versione del container del sistema operativo (8.x o 9.x).

### Rocky Linux 9.x macvlan - la soluzione DHCP

Innanzitutto, si illustra cosa succede quando si arrestano e si riavviano i due container dopo aver assegnato il profilo `macvlan`.

L'assegnazione del profilo, tuttavia, non modifica la configurazione predefinita, che è DHCP per impostazione predefinita.

Per verificarlo, procedere come segue:

```bash
incus restart rocky-test-8
incus restart rocky-test-9
```

Elencare nuovamente i container e notare che rockylinux-test-9 non ha più un indirizzo IP:

```bash
incus list
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

Come si può vedere, il container Rocky Linux 8.x ha ottenuto l'indirizzo IP dall'interfaccia LAN, mentre il container Rocky Linux 9.x no.

Per dimostrare ulteriormente il problema, si deve eseguire `dhclient` sul container Rocky Linux 9.0. Questo mostrerà che il profilo `macvlan` è impostato:

```bash
incus exec rockylinux-test-9 dhclient
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

Ciò sarebbe dovuto accadere con l'arresto e l'avvio del contenitore, ma non è così. Supponendo di voler utilizzare sempre un indirizzo IP assegnato da DHCP, si può risolvere il problema semplicemente con una voce di crontab. Per fare ciò, è necessario ottenere l'accesso al container tramite shell, inserendo:

```bash
incus shell rockylinux-test-9
```

Quindi, determiniamo il percorso di `dhclient`. Per farlo, poiché questo contenitore proviene da un'immagine minimale, è necessario installare prima `which`:

```bash
dnf install which
```

Quindi eseguire:

```bash
which dhclient
```

Che restituirà questo:

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

Il comando crontab inserito utilizza _vi_. Utilizzare ++shift+colon+"w"+"q"++ per salvare le modifiche ed uscire.

Uscire dal container e riavviare rockylinux-test-9:

```bash
incus restart rockylinux-test-9
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

### Rocky Linux 9.x `macvlan` - Il fix al IP statico

Quando si assegna staticamente un indirizzo IP, le cose si complicano ulteriormente. Poiché `network-scripts` è ora deprecato in Rocky Linux 9.x, l'unico modo per farlo è attraverso l'assegnazione statica e, a causa del modo in cui i container utilizzano la rete, non è possibile impostare la route con una normale istruzione `ip route`. Il problema è che l'interfaccia assegnata quando si applica il profilo `macvlan` (eth0 in questo caso), non è gestibile con Network Manager. La soluzione consiste nel rinominare l'interfaccia di rete del contenitore dopo il riavvio e assegnare l'IP statico. È possibile farlo con uno script ed eseguirlo (di nuovo) nel crontab di root. Per farlo, utilizzare il comando `ip`.

Per farlo, è necessario ottenere nuovamente l'accesso al contenitore:

```bash
incus shell rockylinux-test-9
```

Successivamente, si creerà uno script bash in `/usr/local/sbin` chiamato “static”:

```bash
vi /usr/local/sbin/static
```

Il contenuto di questo script non è complicato:

```bash
#!/usr/bin/env bash

/usr/sbin/ip link set dev eth0 name net0
/usr/sbin/ip addr add 192.168.1.151/24 dev net0
/usr/sbin/ip link set dev net0 up
sleep 2
/usr/sbin/ip route add default via 192.168.1.1
```

Cosa si sta cercando di fare qui?

- si rinomina eth0 con un nuovo nome che si può gestire (“net0”)
- si assegna il nuovo IP statico che è stato assegnato al container (192.168.1.151)
- si apre la nuova interfaccia "net0"
- si attende 2 secondi affinché l'interfaccia sia attiva prima di aggiungere la route predefinita
- è necessario aggiungere la route predefinita per la propria interfaccia

Rendete il vostro script eseguibile con quanto segue:

```bash
chmod +x /usr/local/sbin/static
```

Aggiungerlo al crontab di root per il container con l'ora di @reboot:

```bash
@reboot     /usr/local/sbin/static
```

Infine, uscire dal container e riavviarlo:

```bash
incus restart rockylinux-test-9
```

Aspettate qualche secondo e elencate di nuovo i contenitori:

```bash
incus list
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

Fortunatamente, l'implementazione di Ubuntu di Network Manager non interrompe lo stack `macvlan`, rendendo molto più semplice la distribuzione!

Proprio come nel caso del container rockylinux-test-9, è necessario assegnare il profilo al container:

```bash
incus profile assign ubuntu-test default,macvlan
```

Per sapere se il DHCP assegna un indirizzo al container, arrestarlo e riavviarlo:

```bash
incus restart ubuntu-test
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

Successo!

La configurazione dell'IP statico è un po' diversa, ma non difficile. È necessario modificare il file `.yaml` associato alla connessione del container (`10-incus.yaml`). Per questo IP statico si utilizzerà 192.168.1.201:

```bash
vi /etc/netplan/10-incus.yaml
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
incus restart ubuntu-test
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

Successo!

Negli esempi qui utilizzati, è stato scelto intenzionalmente un container difficile da configurare e due meno difficili. Molte altre versioni di Linux sono presenti nell'elenco delle immagini. Se si ha una distro preferita, provare a installarla, assegnando il modello `macvlan` e impostare gli IP.
