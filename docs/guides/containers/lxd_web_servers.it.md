---
title: Guida Per Principianti Lxd-Server Multipli
author: Ezequiel Bruni
contributors: Steven Spencer
update: 28-Feb-2022
---

# Costruire una Rete di Siti web/Server web con LXD, per Principianti

## Introduzione

Ok, abbiamo già [una guida sull'installazione di LXD/LXC su Rocky Linux](../../books/lxd_server/00-toc.md), ma è stata scritta da qualcuno che sa cosa stava facendo e che voleva costruire una rete containerizzata di server e/o applicazioni su una macchina fisica della sua rete locale. È fantastico, e ne ruberò subito dei pezzi per non dover scrivere tanto.

Ma se avete appena sentito parlare di Linux Containers e non avete ancora capito bene come funzionano, ma volete ospitare qualche sito web, questa è la guida che fa per voi. *Questo tutorial vi insegnerà come ospitare siti web di base con LXD e LXC su qualsiasi sistema, compresi i server privati virtuali e il cloud hosting.*

Quindi, in primo luogo, che cos'è un Container Linux? Per i principianti, si tratta di un modo per far sì che un computer finga di essere in realtà molti altri computer. Questi " container " ospitano ciascuno una versione di base, solitamente ridotta, di un sistema operativo scelto dall'utente. È possibile usare ogni contenitore come un server individuale; mettere *nginx* su uno, *Apache* su un altro e persino usare un terzo come server di database.

Il vantaggio fondamentale è che se un'applicazione o un sito web all'interno del proprio contenitore presenta gravi bug, un hack o altri problemi, è improbabile che si ripercuotano sul resto del server o sulle altre applicazioni e siti web. Inoltre, i container sono facilissimi da visualizzare in snapshot, eseguire il backup e ripristinare.

In questo caso, eseguiremo Rocky Linux nei nostri container, sopra il nostro sistema "host", che è anch'esso Rocky Linux.

Concettualmente, è qualcosa di simile:

![Un grafico che mostra come un computer possa fingere di essere più di un altro](../images/lxd-web-server-01.png)

Se avete mai giocato con VirtualBox per eseguire alcune applicazioni Windows, è come questo, ma non è così. A differenza delle macchine virtuali, i container Linux non emulano un intero ambiente hardware per ogni container. Piuttosto, tutti condividono alcuni dispositivi virtuali per impostazione predefinita per la rete e lo storage, anche se è possibile aggiungere altri dispositivi virtuali. Di conseguenza, richiedono molto meno overhead (potenza di elaborazione e RAM) di una macchina virtuale.

Per gli amici di Docker (Docker è un altro sistema basato su container, *non* un sistema di macchine virtuali), i container Linux sono meno effimeri di quelli a cui siete abituati. Tutti i dati in ogni istanza del container sono persistenti e qualsiasi modifica apportata è permanente, a meno che non si ripristini un backup. In breve, lo spegnimento del container non cancellerà gli eventuali problemi introdotti.

LXD, in particolare, è un'applicazione a riga di comando che aiuta a configurare e gestire i container Linux. Questo è ciò che installeremo oggi sul nostro server host Rocky Linux. Scriverò parecchio su LXC/LXD, perché c'è molta documentazione vecchia che si riferisce solo a LXC e sto cercando di rendere più facile per le persone il reperimento di guide aggiornate come questa.

!!! Note

    Esisteva un'applicazione precursore di LXD che si chiamava anche "LXC". Oggi LXC è la tecnologia e LXD è l'applicazione.

Li useremo entrambi per creare un ambiente che funzioni in questo modo:

![A diagram of the intended Linux Container structure](../images/lxd-web-server-02.png)

In particolare, vi mostrerò come configurare semplici server web Nginx e Apache all'interno dei vostri container server e come utilizzare un altro container con Nginx come reverse proxy. Anche in questo caso, questa configurazione dovrebbe funzionare in qualsiasi ambiente: dalle reti locali ai server privati virtuali.

!!! Note

    Un reverse proxy è un programma che prende le connessioni in entrata da Internet (o dalla rete locale) e le indirizza al server, al container o all'applicazione appropriata. Esistono anche strumenti dedicati a questo lavoro, come HaProxy... ma trovo che Nginx sia molto più facile da usare.

## Prerequisiti E Presupposti

* Conoscenza di base dell'interfaccia a riga di comando Linux. È necessario sapere come usare SSH se si installa LXC/LXD su un server remoto.
* Un server connesso a Internet, fisico o virtuale, su cui è già in esecuzione Rocky Linux.
* Due nomi di dominio puntati correttamente sul vostro server con un record A.
    * Anche due sottodomini andrebbero bene. Un dominio con un record di sottodominio wildcard può andare bene, oppure un dominio LAN personalizzato.
* Un editor di testo a riga di comando. *nano* va bene, *micro* è il mio preferito, ma si può usare quello che si preferisce.
* *Potete* seguire l'intero tutorial come utente root, ma non è una buona idea. Dopo l'installazione iniziale di LXC/LXD, vi guideremo nella creazione di un utente non privilegiato specifico per i comandi LXD.
* Le immagini di Rocky Linux su cui basare i container sono ora disponibili.
* Se non avete molta familiarità con Nginx o Apache, allora **dovrete** consultare alcune delle nostre altre guide se volete ottenere un server di produzione completo e funzionante. Non preoccupatevi, le inserirò nei link qui sotto.

## Impostazione dell'Ambiente del Server Host

### Installa il repository EPEL

LXD richiede il repository EPEL (Extra Packages for Enterprise Linux), facile da installare con:

```bash
dnf install epel-release
```

Una volta installato, controllate gli aggiornamenti:

```bash
dnf update
```

Se sono stati eseguiti aggiornamenti del kernel durante il processo di aggiornamento di cui sopra, riavviare il server

### Installazione di snapd

LXD deve essere installato da un pacchetto snap\* per Rocky Linux. Per questo motivo, è necessario installare snapd con:

```bash
dnf install snapd
```

Ora abilitate il servizio snapd per l'avvio automatico al riavvio del server e avviatelo direttamente:

```bash
systemctl enable snapd
```

E poi eseguire:

```bash
systemctl start snapd
```

Riavviare il server prima di continuare. È possibile farlo con il comando `reboot` o dal pannello di amministrazione del VPS/cloud hosting.

\* *snap* è un metodo per impacchettare le applicazioni in modo che siano dotate di tutte le dipendenze necessarie e possano essere eseguite su quasi tutti i sistemi Linux.

### Installare LXD

L'installazione di LXD richiede l'uso del comando snap. A questo punto, stiamo solo installando, non stiamo facendo alcuna configurazione:

```bash
snap install lxd
```

Se state eseguendo LXD su un server fisico (AKA "bare metal"), probabilmente dovreste tornare all'altra guida e leggere la sezione "Impostazione dell'ambiente". C'è un sacco di materiale interessante su kernel e file system, e molto altro ancora.

Se state eseguendo LXD in un ambiente virtuale, riavviate e continuate a leggere.

### Inizializzazione LXD

Ora che l'ambiente è stato configurato, siamo pronti a inizializzare LXD. Si tratta di uno script automatico che pone una serie di domande per rendere operativa l'istanza LXD:

```bash
lxd init
```

Ecco le domande e le nostre risposte per lo script, con una piccola spiegazione dove necessario:

```
Would you like to use LXD clustering? (yes/no) [default=no]:
```

Se siete interessati al clustering, fate ulteriori ricerche al riguardo [qui](https://linuxcontainers.org/lxd/docs/master/clustering/). Altrimenti, basta premere "Invio" per accettare l'opzione predefinita.

```
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

 Accettare l'impostazione predefinita.

```
Name of the new storage pool [default=default]: server-storage
```

Scegliere un nome per il pool di archiviazione. Mi piace chiamarlo come il server su cui gira LXD. (Un pool di archiviazione è in pratica una quantità prestabilita di spazio su disco rigido messa da parte per i vostri container)

```
Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]: lvm
```

La domanda precedente riguarda il tipo di file system che si desidera utilizzare per l'archiviazione e l'impostazione predefinita può variare a seconda di ciò che è disponibile sul sistema. Se siete su un server bare metal e volete usare ZFS, fate riferimento alla guida di cui sopra.

In un ambiente virtuale, ho scoperto che "LVM" funziona bene e di solito è quello che uso. È possibile accettare l'impostazione predefinita alla domanda successiva.

```
Create a new LVM pool? (yes/no) [default=yes]:
```

Se si dispone di un disco rigido o di una partizione specifica che si desidera utilizzare per l'intero pool di archiviazione, scrivere " yes". Se state facendo tutto questo su un VPS, probabilmente *dovrete* scegliere "no".

```
`Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]:`
```

Il Metal As A Service (MAAS) non rientra nell'ambito di questo documento. Accettare le impostazioni predefinite.

```
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

E ancora altri default. È tutto a posto.

```
Would you like to create a new local network bridge? (yes/no) [default=yes]:

What should the new bridge be called? [default=lxdbr0]: `

What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
```

Se si desidera utilizzare IPv6 sui propri contenitori LXD, è possibile attivare la prossima opzione. Questo dipende da voi, ma per lo più non dovrebbe essere necessario.

```
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
```

Questo è necessario per eseguire facilmente il backup del server e può consentire di gestire l'installazione di LXD da altri computer. Se tutto questo vi sembra buono, rispondete " yes"

```
Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
```

Se avete risposto sì alle ultime domande, scegliete i valori predefiniti:

```
Address to bind LXD to (not including port) [default=all]:

Port to bind LXD to [default=8443]:
```

Ora vi verrà chiesta una password di fiducia. È il modo in cui ci si connette al server host LXC da altri computer e server, quindi è necessario impostare qualcosa che abbia senso nel proprio ambiente. Salvate la password in un luogo sicuro, ad esempio in un gestore di password.

```
Trust password for new clients:

Again:
```

E poi continuare a utilizzare i valori predefiniti da qui in avanti:

```
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]

Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

#### Impostazione dei Privilegi degli Utenti

Prima di continuare, dobbiamo creare l'utente "lxdadmin" e assicurarci che abbia i privilegi necessari. L'utente "lxdadmin" deve poter usare _sudo_ per accedere ai comandi di root e deve essere membro del gruppo "lxd". Per aggiungere l'utente e assicurarsi che sia membro di entrambi i gruppi, eseguire:

```bash
useradd -G wheel,lxd lxdadmin
```

Quindi impostare la password:

```bash
passwd lxdadmin
```

Come per le altre password, salvatela in un luogo sicuro.

## Impostare il vostro Firewall

Prima di fare qualsiasi altra cosa con i container, è necessario poter accedere al server proxy dall'esterno. Se il firewall blocca la porta 80 (la porta predefinita utilizzata per il traffico HTTP/web) o la porta 443 (utilizzata per il traffico web HTTPS/*sicuro*), non si potrà fare molto a livello di server.

L'altra guida di LXD mostra come farlo con il firewall *iptables*, se è questo che si vuole fare. Tendo a utilizzare il firewall predefinito di CentOS: *firewalld*. Ecco cosa faremo questa volta.

`firewalld` è configurato tramite il comando `firewall-cmd`. **La prima cosa da fare,** prima di aprire qualsiasi porta, è assicurarsi che ai container possano essere assegnati automaticamente gli indirizzi IP:

```bash
firewall-cmd --zone=trusted --permanent --change-interface=lxdbr0
```

!!! Warning "Attenzione"

    Se non si esegue quest'ultimo passaggio, i contenitori non saranno in grado di accedere correttamente a Internet o tra loro. Si tratta di un elemento pazzescamente essenziale, e conoscerlo vi risparmierà *anni* di frustrazione.

Ora, per aggiungere una nuova porta, basta eseguire questa istruzione:

```bash
firewall-cmd --permanent --zone=public --add-port=80/tcp
```

Vediamo di analizzare il tutto:

* La flag `--permanent` dice al firewall di assicurarsi che questa configurazione sia usata ogni volta che il firewall viene riavviato, e quando il server stesso viene riavviato.
* `--zone=public` dice al firewall di accettare connessioni in entrata a questa porta da chiunque.
* Infine, `–-add-port=80/tcp` dice al firewall di accettare connessioni in entrata sulla porta 80, fintanto che stanno utilizzando il Transmission Control Protocol, che è quello che si desidera in questo caso.

Per ripetere il processo per il traffico HTTPS, basta eseguire nuovamente il comando e cambiare il numero.

```bash
firewall-cmd --permanent --zone=public --add-port=443/tcp
```

Queste configurazioni non avranno effetto finché non forzerete la questione. Per farlo, dite a *firewalld* di ricaricare le sue configurazioni, in questo modo:

```bash
firewall-cmd --reload
```

Ora, c'è una piccolissima possibilità che questo non funzioni. In questi rari casi, fate in modo che *firewalld* esegua i vostri ordini con il vecchio "spegni e riaccendi".

```bash
systemctl restart firewalld
```

Per verificare che le porte siano state aggiunte correttamente, eseguire `firewall-cmd --list-all`. Un firewall correttamente configurato avrà un aspetto simile a questo (ho alcune porte extra aperte sul mio server locale, ignoratele):

```bash
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp9s0
  sources:
  services: cockpit dhcpv6-client ssh
  ports: 81/tcp 444/tcp 15151/tcp 80/tcp 443/tcp
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

E questo dovrebbe essere tutto ciò di cui avete bisogno, a livello di firewall.

## Impostazione dei Container

In realtà la gestione dei container è piuttosto semplice. Pensate che è come poter evocare un intero computer a comando e avviarlo o fermarlo a piacimento. È inoltre possibile accedere a tale "computer" ed eseguire qualsiasi comando, proprio come si farebbe con il server host.

!!! Note "Nota"

    Da questo momento in poi, ogni comando deve essere eseguito come utente `lxdadmin`, o come avete deciso di chiamarlo, anche se alcuni richiederanno l'uso di *sudo* per ottenere temporaneamente i privilegi di root.

Per questa esercitazione sono necessari tre container: il server reverse proxy, un server Nginx di prova e un server Apache di prova, tutti eseguiti su container basati su Rocky.

Se per qualche motivo si ha bisogno di un container completamente riservato (e per lo più non dovrebbe), si possono eseguire tutti questi comandi come root.

Per questa esercitazione sono necessari tre container:

Li chiameremo "proxy-server" (per il container che dirigerà il traffico web agli altri due container), "nginx-server" e "apache-server". Sì, vi mostrerò come effettuare il reverse proxy sia verso i server basati su *nginx* che su *apache*.

Cominciamo con lo stabilire su quale immagine vogliamo basare i nostri container. Per questa esercitazione, utilizzeremo solo Rocky Linux. L'uso di Alpine Linux, ad esempio, può portare a container molto più piccoli (se l'archiviazione è un problema), ma questo va oltre lo scopo di questo documento.

### Trovare l'immagine desiderata

Ecco il metodo rapido per avviare un container con Rocky Linux:

```bash
lxc launch images:rockylinux/8/amd64 my-container
```

Naturalmente, quel "my-container" alla fine deve essere rinominato con il nome del container che si desidera, ad es. “proxy-server”. La parte "/amd64" dovrebbe essere cambiata in "arm64" se si sta facendo tutto questo su qualcosa come un Raspberry Pi.

Ecco la versione lunga: per trovare le immagini desiderate, si può usare questo comando per elencare tutte le immagini disponibili nei repository LXC principali:

```bash
lxc image list images: | more
```

Poi basta premere "Invio" per scorrere un enorme elenco di immagini e premere "Control-C" per uscire dalla modalità di visualizzazione dell'elenco.

Oppure, ci si può semplificare la vita e specificare il tipo di Linux che si desidera, in questo modo:

```bash
lxc image list images: | grep rockylinux
```

Dovrebbe essere visualizzato un elenco molto più breve, simile a questo:

```bash
| rockylinux/8 (3 more)                    | 4e6beda70200 | yes    | Rockylinux 8 amd64 (20220129_03:44)          | x86_64       | VIRTUAL-MACHINE | 612.19MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8 (3 more)                    | c04dd2bcf20b | yes    | Rockylinux 8 amd64 (20220129_03:44)          | x86_64       | CONTAINER       | 127.34MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/arm64 (1 more)              | adc0561d6330 | yes    | Rockylinux 8 arm64 (20220129_03:44)          | aarch64      | CONTAINER       | 124.03MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/cloud (1 more)              | 2591d9716b04 | yes    | Rockylinux 8 amd64 (20220129_03:43)          | x86_64       | CONTAINER       | 147.04MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/cloud (1 more)              | c963253fcea9 | yes    | Rockylinux 8 amd64 (20220129_03:43)          | x86_64       | VIRTUAL-MACHINE | 630.56MB  | Jan 29, 2022 at 12:00am (UTC) |
| rockylinux/8/cloud/arm64                 | 9f49e80afa5b | yes    | Rockylinux 8 arm64 (20220129_03:44)          | aarch64      | CONTAINER       | 143.15MB  | Jan 29, 2022 at 12:00am (UTC) |
```

### Creazione dei Container

!!! Note "Nota"

    Di seguito viene illustrato un modo rapido per creare tutti questi contenitori. Si consiglia di aspettare prima di creare il container proxy-server. C'è un trucco che vi mostrerò di seguito e che potrebbe farvi risparmiare tempo.

Una volta trovata l'immagine desiderata, utilizzate il comando `lxc launch` come mostrato sopra. Per creare i container desiderati per questa esercitazione, eseguire questi comandi (modificandoli se necessario) in successione:

```bash
lxc launch images:rockylinux/8/amd64 proxy-server
lxc launch images:rockylinux/8/amd64 nginx-server
lxc launch images:rockylinux/8/amd64 apache-server
```

Dopo aver eseguito ogni comando, si dovrebbe ricevere una notifica che indica che i container sono stati creati e persino avviati. Quindi, è necessario controllarli tutti.

Eseguite questo comando per verificare che siano tutti attivi e funzionanti:

```bash
lxc list
```

Il risultato dovrebbe essere simile a questo (anche se, se si è scelto di usare IPv6, ci sarà molto più testo):

```bash
+---------------+---------+-----------------------+------+-----------+-----------+
|     NAME      |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+---------------+---------+-----------------------+------+-----------+-----------+
| proxy-server  | RUNNING | 10.199.182.231 (eth0) |      | CONTAINER | 0         |
+---------------+---------+-----------------------+------+-----------+-----------+
| nginx-server  | RUNNING | 10.199.182.232 (eth0) |      | CONTAINER | 0         |
+---------------+---------+-----------------------+------+-----------+-----------+
| apache-server | RUNNING | 10.199.182.233 (eth0) |      | CONTAINER | 0         |
+---------------+---------+-----------------------+------+-----------+-----------+
```

#### Una parola sulla Rete di Container

Quindi l'altra guida riportata all'inizio di questa ha un intero tutorial su come impostare LXC/LXD per lavorare con Macvlan. Questo è particolarmente utile se si gestisce un server locale e si vuole che ogni container abbia un indirizzo IP visibile sulla rete locale.

Quando si lavora su un VPS, spesso non si ha questa possibilità. In effetti, potreste avere un solo indirizzo IP con cui siete autorizzati a lavorare. La configurazione di rete predefinita è progettata per soddisfare questo tipo di limitazioni; rispondendo alle richieste `lxd init` come ho specificato sopra *dovrebbe* occuparsi di tutto.

Fondamentalmente, LXD crea un dispositivo di rete virtuale chiamato bridge (di solito chiamato "lxdbr0") e tutti i container vengono connessi a quel bridge per impostazione predefinita. Attraverso di esso, possono connettersi a Internet tramite il dispositivo di rete predefinito dell'host (Ethernet, wi-fi o un dispositivo di rete virtuale fornito dal VPS). Cosa ancora più importante, tutti i container possono connettersi tra loro.

Per garantire questa connessione tra i container, *ogni container ottiene un nome di dominio interno*. Per impostazione predefinita, è solo il nome del contenitore più ".lxd". Quindi il container "proxy-server" è disponibile per tutti gli altri container in "proxy-server.lxd". Ma ecco la cosa *davvero* importante da sapere: per **default i domini ".lxd" sono disponibili solo all'interno dei container stessi.**

Se si esegue `ping proxy-server.lxd` sul sistema operativo host (o altrove), non si otterrà nulla. Questi domini interni, però, ci torneranno molto utili in seguito.

Tecnicamente si può cambiare e rendere disponibili i domini interni del container sull'host... ma non l'ho mai capito. Probabilmente è meglio mettere il server reverse proxy in un container, in modo da poter eseguire snapshot e backup con facilità.

### Gestione dei container

Alcune cose da sapere prima di procedere:

#### Avviamento & Arresto

Tutti i container possono essere avviati, fermati e riavviati a seconda delle necessità con i seguenti comandi:

```bash
lxc start mycontainer
lxc stop mycontainer
lxc restart mycontainer
```

Anche Linux ha bisogno di riavviarsi a volte. È possibile avviare, arrestare e riavviare tutti i container contemporaneamente con i seguenti comandi.

```bash
lxc start --all
lxc stop --all
lxc restart --all
```

L'opzione `restart --all` è molto utile per alcuni dei bug temporanei più oscuri.

#### Eseguire operazioni all'interno dei container

È possibile controllare il sistema operativo all'interno del container in due modi: si possono semplicemente eseguire comandi al suo interno dal sistema operativo host, oppure si può aprire una shell.

Ecco cosa voglio dire. Per eseguire un comando all'interno di un container, ad esempio per installare *Apache*, basta usare `lxc exec`, in questo modo:

```bash
lxc exec my-container dnf install httpd -y
```

Questo permetterà a *Apache* di installarsi da solo e di vedere l'output del comando sul terminale dell'host.

Per aprire una shell (in cui è possibile eseguire tutti i comandi desiderati come root), utilizzare questa procedura:

```bash
lxc exec my-container bash
```

Se, come me, preferite la comodità allo spazio di archiviazione e avete installato una shell alternativa come *fish* in tutti i vostri container, cambiate semplicemente il comando in questo modo:

```bash
lxc exec my-container fish
```

In quasi tutti i casi, verrete automaticamente assegnati all'account di root e alla directory `/root`.

Infine, se si è aperta una shell in un container, la si abbandona nello stesso modo in cui si abbandona qualsiasi shell: semplicemente con il comando `exit`.

#### Copia dei Container

Ora, se si dispone di un container che si desidera replicare con il minimo sforzo, non è necessario avviarne uno nuovo e installare nuovamente tutte le applicazioni di base. Questo richiede un lavoro supplementare che non è necessario. Basta eseguire:

```bash
lxc copy my-container my-other-container
```

Verrà creata una copia esatta di "my-container" con il nome "my-other-container". Tuttavia, potrebbe non avviarsi automaticamente, quindi si dovranno apportare le eventuali modifiche alla configurazione del nuovo container e poi avviarlo:

```bash
lxc start my-other-container
```

A questo punto, si potrebbero apportare alcune modifiche, come cambiare l'hostname interno del container o altro.

#### Configurazione dello Storage & Limiti della CPU

LXC/LXD di solito definisce la quantità di spazio di archiviazione di un container e in generale gestisce le risorse, ma è possibile che si voglia avere il controllo su questo aspetto. Se si desidera mantenere i contenitori di dimensioni ridotte, si può usare il comando `lxc config` per rimpicciolirli e allargarli secondo le necessità.

Il comando seguente imposta un limite "soft" di 2GB su un container. Un limite soft è in realtà più che altro una "memoria minima" e il container utilizzerà più memoria se è disponibile. Come sempre, cambiate "my-container" con il nome del container vero e proprio.

```bash
lxc config set my-container limits.memory 2GB
```

È possibile impostare un limite hard in questo modo:

```bash
lxc config set my-container limits.memory.enforce 2GB
```

Se si desidera evitare che un determinato container possa occupare tutta la potenza di elaborazione disponibile sul server, è possibile limitare i core della CPU a cui ha accesso con questo comando. Basta modificare il numero di core della CPU alla fine, a seconda delle esigenze.

```bash
lxc config set my-container limits.cpu 2
```

#### Eliminare i Container (e Come Evitare Che Ciò Accada)

Infine, è possibile eliminare i container eseguendo questo comando:

```bash
lxc delete my-container
```

Non sarà possibile eliminare il container se è in esecuzione, quindi lo si può fermare prima o usare la flag `--force` per saltare questa parte.

```bash
lxc delete my-container --force
```

Ora, grazie al completamento del comando Tab, all'errore dell'utente e al fatto che la "d" si trova accanto alla "s" sulla maggior parte delle tastiere, è possibile cancellare accidentalmente i container.

Per evitare che ciò accada, è possibile impostare qualsiasi container come "protetto" (facendo in modo che il processo di cancellazione richieda un passo in più) con questo comando:

```bash
lxc config set my-container security.protection.delete true
```

Per togliere la protezione al contenitore, basta eseguire nuovamente il comando, cambiando "true" in "false".

## Impostazione dei Server

Ok, ora che i container sono attivi e funzionanti, è il momento di installare ciò che serve. Per prima cosa, assicurarsi che tutti siano aggiornati con i seguenti comandi (saltare il contenitore "proxy-server" se non è stato ancora creato):

```bash
lxc exec proxy-server dnf update -y
lxc exec nginx-server dnf update -y
lxc exec apache-server dnf update -y
```

Poi, entrare in ogni container e iniziare a lavorare.

È inoltre necessario un editor di testo per ogni container. Per impostazione predefinita, Rocky Linux viene fornito con *vi*, ma se volete semplificarvi la vita, *nano* andrà bene. È necessario installarlo in ogni contenitore prima di aprirlo.

```bash
lxc exec proxy-server dnf install nano -y
lxc exec nginx-server dnf install nano -y
lxc exec apache-server dnf install nano -y
```

In seguito userò *nano* in tutti i comandi relativi all'editor di testo, ma fate voi.

### Il Server del Sito Web Apache

La faremo breve, a scopo di apprendimento e di verifica. Di seguito trovate il link alle guide complete di Apache.

Per prima cosa, aprite una shell nel vostro container. Si noti che, per impostazione predefinita, i container vi porteranno nell'account di root. Per i nostri scopi, questo va bene, anche se si potrebbe voler creare un utente del server web specifico per la produzione effettiva.

```bash
lxc exec apache-server bash
```

Una volta effettuato l'accesso, basta installare *Apache* nel modo più semplice:

```bash
dnf install httpd
```

Ora, si potrebbe seguire la nostra guida [Apache Web Server Multi-Site Setup](.../web/apache-sites-enabled.md) da qui in avanti, ma in realtà è un po' eccessivo per i nostri scopi. Di solito non si vuole configurare Apache per più siti web in un ambiente containerizzato come questo. Il punto centrale dei container è la separazione delle problematiche, dopotutto.

Inoltre, i certificati SSL andranno sul server proxy, quindi manterremo le cose semplici.

Una volta installato *Apache*, assicurarsi che sia in funzione e che possa continuare a funzionare al riavvio:

```bash
systemctl enable --now httpd
```

La flag `--now` consente di saltare il comando di avvio del server vero e proprio. Per riferimento, sarebbe:

```bash
systemctl start httpd
```

Se avete installato `curl` sul vostro host server, potete assicurarvi che la pagina web predefinita sia attiva e funzionante con:

```bash
curl [container-ip-address]
```

Ricordare che è possibile vedere tutti gli IP del contenitore con `lxc list`. E se si installa curl su tutti i container, si *potrebbe* eseguire semplicemente:

```bash
curl localhost
```

#### Ottenere gli IP degli utenti reali dal server proxy

Ora c'è un passo da fare per preparare Apache all'uso del reverse proxy. Per impostazione predefinita, gli indirizzi IP effettivi degli utenti non vengono registrati dai server nei container del server web. Si desidera che questi indirizzi IP attraversino la rete, perché alcune applicazioni web hanno bisogno degli IP degli utenti per operazioni come la moderazione, l'interdizione e la risoluzione dei problemi.

Per far sì che gli indirizzi IP dei visitatori superino il server proxy, sono necessarie due parti: le giuste impostazioni del server proxy (di cui parleremo più avanti) e un semplice file di configurazione per il server Apache.

Un grosso ringraziamento va a Linode e [alla loro guida LXD](https://www.linode.com/docs/guides/beginners-guide-to-lxd-reverse-proxy) per i modelli di questi file di configurazione.

Creare un nuovo file di configurazione:

```bash
nano /etc/httpd/conf.d/real-ip.conf
```

E aggiungere questo testo:

```
RemoteIPHeader X-Real-IP
RemoteIPTrustedProxy proxy-server.lxd
```

Ricordarsi di cambiare `proxy-server.lxd` con il nome del container proxy effettivo, se necessario. Ora **non riavviate ancora il server Apache.** Il file di configurazione che abbiamo aggiunto potrebbe causare problemi *fino a quando* non avremo il server proxy attivo e funzionante.

Uscire dalla shell per ora e iniziare con il server Nginx.

!!! Note "Nota"

    Anche se questa tecnica *funziona* (le applicazioni web e i siti web otterranno gli IP reali degli utenti), i log di accesso di Apache *non mostreranno gli IP giusti* e di solito mostreranno l'IP del container in cui si trova il reverse proxy. A quanto pare si tratta di un problema nel modo in cui Apache registra i log.
    
    È possibile controllare i registri di accesso del server proxy se si desidera vedere gli indirizzi IP, oppure controllare i registri dell'applicazione web che si sta installando.

### Il server web Nginx

Anche in questo caso, la faremo breve. Se volete usare la versione più recente (e consigliata) di Nginx in produzione, consultate la nostra [guida per principianti all'installazione di Nginx](../web/nginx-mainline.md). Questo contiene la guida completa all'installazione e alcune buone pratiche per la configurazione del server.

Per i test e l'apprendimento, *potreste* installare Nginx normalmente, ma vi consiglio di installare l'ultima versione, che è chiamata ramo "mainline".

Per prima cosa, accedere alla shell del container:

```bash
lxc exec nginx-server bash
```

Quindi, installare il repository `epel-release` in modo da poter installare l'ultima versione di Nginx:

```bash
dnf install epel-release
```

Una volta fatto questo, cercare l'ultima versione di Nginx con:

```bash
dnf module list nginx
```

Si dovrebbe ottenere un elenco simile a questo:

```bash
Rocky Linux 8 - AppStream
Name       Stream        Profiles        Summary
nginx      1.14 [d]      common [d]      nginx webserver
nginx      1.16          common [d]      nginx webserver
nginx      1.18          common [d]      nginx webserver
nginx      1.20          common [d]      nginx webserver
nginx      mainline      common [d]      nginx webserver
```

Quella desiderata è, avete indovinato, il ramo mainline. Abilitare il modulo con questo comando:

```bash
dnf enable module nginx:mainline
```

Ti verrà chiesto se sei sicuro di volerlo fare, quindi scegli `Y` come al solito. Quindi, utilizzare il comando predefinito per installare Nginx:

```bash
dnf install nginx
```

Quindi, abilitare e avviare Nginx:

```bash
dnf enable --now nginx
```

!!! Note "Nota"

    Ricordate quando vi ho detto di aspettare prima di creare il contenitore proxy? Ecco perché: a questo punto, si può risparmiare tempo lasciando il container "nginx-server" e copiandolo per creare il container "proxy-server":

    ```bash
    lxc copy nginx-server proxy-server
    ```


    Assicurarsi di avviare il container proxy con `lxc start proxy-server` e di aggiungere le porte proxy al container come descritto di seguito.

Anche in questo caso, si può verificare che il container funzioni dall'host con:

```bash
curl [your-container-ip]
```

#### Ottenere gli IP utente reali dal server proxy (nuovamente)

I log *dovrebbero* funzionare questa volta. Dovrebbero. Per farlo, inseriamo un file simile in `/etc/nginx/conf.d`:

```bash
nano /etc/nginx/conf.d/real-ip.conf
```

Poi inserite questo testo:

```bash
real_ip_header    X-Real-IP;
set_real_ip_from  proxy-server.lxd;
```

Infine, **non riavviare ancora il server**. Anche in questo caso, il file di configurazione potrebbe causare problemi finché non viene impostato il server proxy.

### Il Server Reverse Proxy

Ricordate quando vi ho detto che vi servono due domini o sottodomini? È qui che servono. I sottodomini che sto utilizzando per questo tutorial sono:

* apache.server.test
* nginx.server.test

Modificateli in tutti i file e le istruzioni, se necessario.

Se si è copiato il container "proxy-server" dal container "nginx-server" e vi si sono aggiunti i dispositivi proxy, basta entrare nella shell. Se il container è stato creato in precedenza, è necessario ripetere tutti i passaggi per l'installazione di Nginx nel container "proxy-server".

Una volta installato e verificato che funziona correttamente, è sufficiente impostare un paio di file di configurazione per indirizzare il traffico dai domini scelti ai server del sito web vero e proprio.

Prima di farlo, assicuratevi di poter accedere a entrambi i server tramite i loro domini interni:

```bash
curl apache-server.lxd
curl nginx-server.lxd
```

Se questi due comandi caricano nel terminale l'HTML delle pagine di benvenuto del server predefinito, allora tutto è stato configurato correttamente.

#### *Passo essenziale:* Configurare il Container "proxy-server" per Accettare Tutto il Traffico Server in Entrata

Anche in questo caso, si consiglia di farlo in un secondo momento, quando si creerà effettivamente il server proxy, ma ecco le istruzioni necessarie:

Ricordate quando abbiamo aperto le porte 80 e 443 nel firewall? Qui si fa in modo che il container "proxy-server" ascolti queste porte e riceva tutto il traffico diretto verso di esse.

Basta eseguire questi due comandi in successione:

```bash
lxc config device add proxy-server myproxy80 proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80
lxc config device add proxy-server myproxy443 proxy listen=tcp:0.0.0.0:443 connect=tcp:127.0.0.1:443
```

Vediamo di analizzare la situazione. Ogni comando aggiunge un "device" virtuale al container proxy-server. Questi dispositivi sono impostati per ascoltare la porta 80 e la porta 443 del sistema operativo host e sono collegati alla porta 80 e alla porta 443 del container. Ogni dispositivo ha bisogno di un nome, quindi ho scelto "myproxy80" e "myproxy443".

L'opzione "listen" è la porta del sistema operativo host e, se non sbaglio, 0.0.0.0 è l'indirizzo IP dell'host sul bridge "lxdbr0". L'opzione "connect" indica l'indirizzo IP locale e le porte a cui ci si connette.

!!! Note "Nota"

    Una volta impostati questi dispositivi, è necessario riavviare tutti i container, per sicurezza.

Questi dispositivi virtuali dovrebbero essere idealmente unici. Di solito è meglio non aggiungere un dispositivo "myport80" a un altro container in esecuzione; dovrà essere chiamato in un altro modo.

*Allo stesso modo, solo un container alla volta può ascoltare su una specifica porta del sistema operativo host.*

#### Direzione del traffico al server Apache

Nel container "proxy-server", creare un file di configurazione chiamato `apache-server.conf` in `/etc/nginx/conf.d/`:

```bash
nano /etc/nginx/conf.d/apache-server.conf
```

Quindi incollate questo test, modificate il nome del dominio secondo necessità e salvatelo:

```
upstream apache-server {
    server apache-server.lxd:80;
}

server {
    listen 80 proxy_protocol;
    listen [::]:80 proxy_protocol;
    server_name apache.server.test; #< Your domain goes here

    location / {
        proxy_pass http://apache-server;

        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Vediamo di scomporlo un po':

* La sezione `upstream` definisce esattamente dove il reverse proxy invierà tutto il suo traffico. In particolare, invia il traffico al nome di dominio interno del container "apache-server": `apache-server.lxd`.
* Le due righe che iniziano con `listen` indicano al server di ascoltare il traffico in arrivo sulla porta 80 con il protocollo proxy. La prima via IPv4 e la seconda via IPv6.
* La funzione `server_name` prende tutto il traffico che arriva specificamente da "apache.server.test" e lo instrada attraverso il reverse proxy.
* La funzione `proxy-pass` è la parte che dirige effettivamente tutto il traffico catturato dalla variabile `server_name` e lo invia al server definito nella sezione `upstream`.
* La funzione `proxy_redirect` può apparentemente interferire con i reverse proxy, quindi ci assicuriamo che sia disattivata.
* Tutte le opzioni `proxy-set-header` inviano al server web informazioni come l'IP dell'utente e altro.

!!! warning "Attenzione"

    Il valore `proxy_protocol` nelle variabili `listen` è *essenziale* per il funzionamento del server proxy. Non lasciarlo mai fuori.

Per ogni file di configurazione di LXD/sito web, è necessario modificare le impostazioni di `upstream`, `server`, `server_name` e `proxy_pass`. Il testo dopo "http://" in `proxy-pass` deve corrispondere al testo che viene dopo il testo `upstream`.

Ricaricare il server con `systemctl restart nginx`, quindi puntare il browser sul dominio che si sta usando al posto di `apache.server.test`. Se la pagina ha questo aspetto, il successo è assicurato:

![A screenshot of the default Rocky Linux Apache welcome page](../images/lxd-web-server-03.png)

!!! Note "Nota"

    È possibile assegnare ai file di configurazione il nome che si preferisce. Per le esercitazioni sto usando nomi semplificati, ma alcuni sysadmin raccomandano nomi basati sul dominio attuale, ma al contrario. È un'organizzazione basata sull'ordine alfabetico.
    
    es. "apache.server.test" otterrebbe un file di configurazione chiamato `test.server.apache.conf`.
#### Direzione del traffico al server Nginx

Ripetere il procedimento. Creare un file come in precedenza:

```bash
nano /etc/nginx/conf.d/nginx-server.conf
```

Aggiungere il testo appropriato:

```
upstream nginx-server {
    server rocky-nginx.lxd:80;
}

server {
    listen 80 proxy_protocol;
    listen [::]:80 proxy_protocol;
    server_name nginx.server.test; #< Your domain goes here

    location / {
        proxy_pass http://nginx-server;

        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Di nuovo, ricaricate il server proxy, puntate il browser all'indirizzo appropriato e auguratevi di vedere questo:

![A screenshot of the default Rocky Linux Nginx welcome page](../images/lxd-web-server-04.png)

#### Riavviare i server nei container che ospitano il server web

Uscire dal container "proxy-server" e riavviare i server negli altri due container con un semplice comando:

```bash
lxc exec apache-server systemctl restart httpd && lxc exec nginx-server restart nginx
```

Questo applicherà i file "real-ip.conf" che abbiamo creato nelle rispettive configurazioni dei server.

#### Ottenere i certificati SSL per i tuoi siti web
Ottenere certificati SSL ufficiali e corretti è più facile con Let's Encrypt e una piccola applicazione chiamata certbot. certbot rileva automaticamente i vostri siti web, ottiene i certificati SSL e configura i siti stessi. Rinnova anche i certificati per voi ogni 30 giorni circa, senza alcun intervento da parte vostra o cron job.

Tutto questo deve essere fatto dal container "proxy-server", quindi si deve accedere a quella shell. Una volta lì, installare i repository EPEL, proprio come si è fatto sull'host. Assicurarsi che il container sia stato prima aggiornato:

```bash
dnf update
```

Quindi, aggiungere il repository EPEL:

```bash
dnf install epel-release
```

Quindi è sufficiente installare certbot e il suo modulo Nginx:

```bash
dnf install certbot python3-certbot-nginx
```

Una volta installato, se si dispone già di un paio di siti web configurati, è sufficiente eseguirlo:

```bash
certbot --nginx
```

Certbot leggerà la configurazione di Nginx e capirà quanti siti web avete e se hanno bisogno di certificati SSL. A questo punto, vi saranno poste alcune domande. Accettate i termini di servizio, volete ricevere e-mail, ecc?

Le domande più importanti sono le seguenti. Inserite il vostro indirizzo e-mail quando vedete questo:

```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel):
```

Qui è possibile scegliere per quali siti web ottenere i certificati. Basta premere invio per ottenere i certificati per tutti quanti.

```
Which names would you like to activate HTTPS for?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1: apache.server.test
2: nginx.server.test
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Select the appropriate numbers separated by commas and/or spaces, or leave input
blank to select all options shown (Enter 'c' to cancel):
```

Verrà visualizzato un testo di conferma e la procedura sarà conclusa. Ma se andate sui vostri siti web, potreste scoprire che non funzionano. Questo perché quando certbot crea la configurazione aggiornata, dimentica una cosa molto importante.

Andate nei file `apache-server.conf` e `nginx-server.conf` e trovate le due righe seguenti:

```
listen [::]:443 ssl ipv6only=on; # managed by Certbot
listen 443 ssl; # managed by Certbot
```

Sì, manca l'impostazione `proxy_protocol` e questo non va bene. Aggiungetelo voi stessi.

```
listen proxy_protocol [::]:443 ssl ipv6only=on; # managed by Certbot
listen proxy_protocol 443 ssl; # managed by Certbot
```

Salvate il file, riavviate il server e i vostri siti web si caricheranno senza problemi.

## Note

1. In questa guida non ho parlato molto della configurazione dei server web. Il minimo che si dovrebbe fare, in produzione, è cambiare i nomi dei domini nei file di configurazione del server nei container del server web vero e proprio, e non solo nel container proxy. E magari impostare un utente del server web in ciascuno di essi.
2. Se volete saperne di più sulla gestione manuale dei certificati SSL e delle configurazioni dei server SSL, consultate [la nostra guida all'installazione di certbot e alla generazione dei certificati SSL](../security/generating_ssl_keys_lets_encrypt.md).
3. Applicazioni come Nextcloud richiedono una configurazione aggiuntiva (per motivi di sicurezza) se vengono inserite in un contenitore LXD dietro un proxy.

## Conclusione

C'è molto altro da imparare su LXC/LXD, sulla containerizzazione, sui server web e sull'esecuzione dei siti web, ma questo dovrebbe essere un buon inizio. Una volta appreso come deve essere impostato tutto e come configurare le cose nel modo desiderato, si può anche iniziare ad automatizzare il processo.

Potreste usare Ansible, oppure essere come me e avere una serie di script scritti su misura da eseguire per rendere tutto più veloce. È anche possibile creare piccoli "container modello" con tutti i software preferiti preinstallati, per poi copiarli ed espanderne la capacità di archiviazione in base alle esigenze.

Va Bene. Questo è fatto. Io sono fuori per giocare a videogiochi. Buon divertimento!
