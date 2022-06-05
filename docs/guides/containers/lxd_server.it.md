- - -
title: Server LXD author: Steven Spencer contributors: Ezequiel Bruni, Colussi Franco tested with: 8.5 tags:
  - lxd
  - enterprise
- - -

# Creare un server LXD completo
## Introduzione

LXD è meglio descritto sul [sito web ufficiale](https://linuxcontainers.org/lxd/introduction/), ma consideratelo come un sistema di container che offre i vantaggi dei server virtuali in un container, o un container con gli steroidi.

È molto potente e, con l'hardware e la configurazione giusta, può essere sfruttato per eseguire molte istanze di server su un singolo pezzo di hardware. Se lo si abbina a un server snapshot, si ha anche una serie di container che possono essere avviati quasi immediatamente nel caso in cui il server primario si guasti.

(Non si deve pensare a questo come a un backup tradizionale. È comunque necessario un sistema di backup regolare di qualche tipo, come [rsnapshot](../backup/rsnapshot_backup.md))

La curva di apprendimento di LXD può essere un po' ripida, ma questo documento cercherà di fornire un bagaglio di conoscenze a portata di mano, per aiutarvi a distribuire e utilizzare LXD su Rocky Linux.

## Prerequisiti e Presupposti

* Un server Linux Rocky, ben configurato. In un ambiente di produzione si dovrebbe considerare un disco rigido separato per lo spazio su disco ZFS (è necessario se si usa ZFS). E sì, si presume che si tratti di un server bare metal, non di un VPS.
* Questo dovrebbe essere considerato un argomento avanzato, ma abbiamo fatto del nostro meglio per renderlo il più semplice possibile da capire per tutti. Detto questo, conoscere alcune nozioni di base sulla gestione dei container vi porterà lontano.
* Dovete essere a vostro agio con la riga di comando del vostro computer e saper usare con disinvoltura un editor da riga di comando. (In questo esempio utilizziamo _vi_, ma potete sostituirlo con il vostro editor preferito)
* È necessario essere un utente non privilegiato per la maggior parte dei processi LXD. Tranne quando indicato, inserire i comandi LXD come utente non privilegiato. Si presume che per i comandi LXD si sia connessi come utente "lxdadmin". La maggior parte della configurazione _viene_ eseguita come root fino a quando non si supera l'inizializzazione di LXD. L'utente "lxdadmin" verrà creato più avanti nel processo.
* Per ZFS, assicurarsi che l'avvio UEFI secure boot NON sia abilitato. Altrimenti, si finirà per dover firmare il modulo ZFS per poterlo caricare.
* Per il momento utilizzeremo contenitori basati su CentOS, poiché LXC non dispone ancora di immagini Rocky Linux. Rimanete sintonizzati per gli aggiornamenti, perché è probabile che questo cambierà con il tempo.

!!! Note "Nota"

    La situazione è cambiata! Negli esempi che seguono, potete sostituire i contenitori Rocky Linux con altri.

## Parte 1: Preparazione dell'ambiente

Per tutta la "Parte 1" dovrete essere l'utente root o dovrete essere in grado di fare _sudo_ a root.

### <a name="repos"></a>Installare i repository EPEL e OpenZFS

LXD richiede il repository EPEL (Extra Packages for Enterprise Linux), che sono facili da installare:

`dnf install epel-release`

Una volta installato, verificare la presenza di aggiornamenti:

`dnf update`

Se si utilizza ZFS, installare il repository OpenZFS con:

`dnf installa https://zfsonlinux.org/epel/zfs-release.el8_3.noarch.rpm`

Abbiamo bisogno anche della chiave GPG, per cui utilizziamo questo comando per ottenerla:

`gpg --import --import-options show-only /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux`

Se sono stati eseguiti aggiornamenti del kernel durante il processo di aggiornamento di cui sopra, riavviare il server

### Installare snapd, dkms e vim

LXD deve essere installato da uno snap per Rocky Linux. Per questo motivo, è necessario installare snapd (e alcuni altri programmi utili) con:

`dnf install snapd dkms vim`

Ora abilitate e avviate snapd:

`systemctl enable snapd`

E poi eseguire:

`systemctl start snapd`

Riavviare il server prima di continuare.

### <a name="pkginstall"></a>Installare LXD

L'installazione di LXD richiede l'uso del comando snap. A questo punto, stiamo solo installando, non stiamo facendo alcuna configurazione:

`sudo snap install lxd`

### Installare OpenZFS

`dnf install kernel-devel zfs`

### <a name="envsetup"></a> Impostazione dell'Ambiente

La maggior parte delle impostazioni del kernel del server non sono sufficienti per eseguire un gran numero di container. Se si presume fin dall'inizio che il server verrà utilizzato in produzione, è necessario apportare queste modifiche in anticipo per evitare errori come "Too many open files".

Fortunatamente, modificare le impostazioni di LXD è facile con alcune modifiche ai file e un riavvio.

#### Modifica di limits.conf

Il primo file da modificare è il file limits.conf. Questo file è autodocumentato, quindi si consiglia di consultare le spiegazioni contenute nel file per sapere cosa fa. Per apportare le nostre modifiche digitate:

`vi /etc/security/limits.conf`

L'intero file è commentato e, in fondo, mostra le impostazioni predefinite attuali. Nello spazio vuoto sopra il marcatore di fine file (#End of file) dobbiamo aggiungere le nostre impostazioni personalizzate. Al termine, il file avrà questo aspetto:

```
# Modifications made for LXD

*               soft    nofile           1048576
*               hard    nofile           1048576
root            soft    nofile           1048576
root            hard    nofile           1048576
*               soft    memlock          unlimited
*               hard    memlock          unlimited
```

Salvare le modifiche e uscire. (`SHIFT:wq!` per _vi_)

#### Modifica di sysctl.conf con 90-lxd.override.conf

Con _systemd_, si possono apportare modifiche alla configurazione generale del sistema e alle opzioni del kernel *senza* modificare il file di configurazione principale. Invece, metteremo le nostre impostazioni in un file separato che semplicemente sovrascriverà le impostazioni particolari di cui abbiamo bisogno.

Per apportare queste modifiche al kernel, creeremo un file chiamato _90-lxd-override.conf_ in /etc/sysctl.d. Per farlo, digitare:

`vi /etc/sysctl.d/90-lxd-override.conf`

Inserite il seguente contenuto nel file. Se vi state chiedendo cosa stiamo facendo qui, il contenuto del file sottostante è autodocumentante:

```
## The following changes have been made for LXD ##

# fs.inotify.max_queued_events specifies an upper limit on the number of events that can be queued to the corresponding inotify instance
 - (default is 16384)

fs.inotify.max_queued_events = 1048576

# fs.inotify.max_user_instances This specifies an upper limit on the number of inotify instances that can be created per real user ID -
(default value is 128)

fs.inotify.max_user_instances = 1048576

# fs.inotify.max_user_watches specifies an upper limit on the number of watches that can be created per real user ID - (default is 8192)

fs.inotify.max_user_watches = 1048576

# vm.max_map_count contains the maximum number of memory map areas a process may have. Memory map areas are used as a side-effect of cal
ling malloc, directly by mmap and mprotect, and also when loading shared libraries - (default is 65530)

vm.max_map_count = 262144

# kernel.dmesg_restrict denies container access to the messages in the kernel ring buffer. Please note that this also will deny access t
o non-root users on the host system - (default is 0)

kernel.dmesg_restrict = 1

# This is the maximum number of entries in ARP table (IPv4). You should increase this if you create over 1024 containers.

net.ipv4.neigh.default.gc_thresh3 = 8192

# This is the maximum number of entries in ARP table (IPv6). You should increase this if you plan to create over 1024 containers.Not nee
ded if not using IPv6, but...

net.ipv6.neigh.default.gc_thresh3 = 8192

# This is a limit on the size of eBPF JIT allocations which is usually set to PAGE_SIZE * 40000.

net.core.bpf_jit_limit = 3000000000

# This is the maximum number of keys a non-root user can use, should be higher than the number of containers

kernel.keys.maxkeys = 2000

# This is the maximum size of the keyring non-root users can use

kernel.keys.maxbytes = 2000000

# This is the maximum number of concurrent async I/O operations. You might need to increase it further if you have a lot of workloads th
at use the AIO subsystem (e.g. MySQL)

fs.aio-max-nr = 524288
```

A questo punto è necessario riavviare il server.

#### Controllo dei valori di _sysctl.conf_

Una volta completato il riavvio, accedere nuovamente al server. Dobbiamo verificare che il nostro file di override abbia effettivamente svolto il suo compito.

È facile da fare. Non è necessario controllare tutte le impostazioni, a meno che non lo si voglia fare, ma controllarne alcune consente di verificare che le impostazioni siano state modificate. Questo viene fatto con il comando _sysctl_:

`sysctl net.core.bpf_jit_limit`

Il che dovrebbe dimostrarlo:

`net.core.bpf_jit_limit = 3000000000`

Fate lo stesso con alcune delle altre impostazioni del file di override (sopra) per verificare che le modifiche siano state apportate.

### <a name="zfssetup"></a>Abilitazione di ZFS e Impostazione del Pool

Se l'avvio UEFI secure boot è disattivato, dovrebbe essere abbastanza facile.  Per prima cosa, caricare il modulo ZFS con modprobe:

`/sbin/modprobe zfs`

Questa operazione non dovrebbe restituire un errore, ma semplicemente tornare al prompt dei comandi una volta terminata. Se si verifica un errore, interrompere subito e iniziare la risoluzione dei problemi. Anche in questo caso, assicuratevi che il secure boot sia disattivato, in quanto è la causa più probabile.

Successivamente dobbiamo esaminare i dischi del nostro sistema, determinare quali sono quelli su cui è caricato il sistema operativo e quali sono disponibili per il pool ZFS. Lo faremo con _lsblk_:

`lsblk`

Il quale dovrebbe restituire qualcosa di simile (il vostro sistema sarà diverso!):

```
AME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
loop0 7:0 0 32,3M 1 loop /var/lib/snapd/snap/snapd/11588
loop1 7:1 0 55,5M 1 loop /var/lib/snapd/snap/core18/1997
loop2 7:2 0 68,8M 1 loop /var/lib/snapd/snap/lxd/20037
sda 8:0 0 119,2G 0 disco
├─sda1 8:1 0 600M 0 parte /boot/efi
├─sda2 8:2 0 1G 0 parte /boot
├─sda3 8:3 0 11.9G 0 part [SWAP]
├─sda4 8:4 0 2G 0 parte /home
└─sda5 8:5 0 103,7G 0 parte /
sdb 8:16 0 119,2G 0 disco
├─sdb1 8:17 0 119,2G 0 parte
└─sdb9 8:25 0 8M 0 parte
sdc 8:32 0 149,1G 0 disco
└─sdc1 8:33 0 149,1G 0 parte
```

In questo elenco, possiamo vedere che */dev/sda* è utilizzato dal sistema operativo, quindi useremo */dev/sdb* per il nostro zpool. Si noti che se si dispone di più dischi rigidi liberi, si può prendere in considerazione l'uso di raidz (un software raid specifico per ZFS).

Questo non rientra nell'ambito di questo documento, ma dovrebbe essere preso in considerazione per la produzione, in quanto offre migliori prestazioni e ridondanza. Per ora, creiamo il nostro pool sul singolo dispositivo che abbiamo identificato:

`zpool create storage /dev/sdb`

Questo dice di creare un pool chiamato "storage" che è ZFS sul dispositivo */dev/sdb*.

Una volta creato il pool, a questo punto è bene riavviare il server.

### <a name="lxdinit"></a>Inizializzazione LXD

Ora che l'ambiente è stato configurato, siamo pronti a inizializzare LXD. Si tratta di uno script automatico che pone una serie di domande per rendere operativa l'istanza LXD:

`lxd init`

Ecco le domande e le nostre risposte per lo script, con una piccola spiegazione dove necessario:

`Would you like to use LXD clustering? (yes/no) [default=no]:`

Se siete interessati al clustering, fate qualche ricerca aggiuntiva su questo argomento [qui](https://lxd.readthedocs.io/en/latest/clustering/)

`Do you want to configure a new storage pool? (yes/no) [default=yes]:`

Questo può sembrare controintuitivo, dato che abbiamo già creato il nostro pool ZFS, ma sarà risolto in una domanda successiva. Accept the default.

`Name of the new storage pool [default=default]: storage`

Si potrebbe lasciare questo nome come predefinito, ma noi abbiamo scelto di usare lo stesso nome che abbiamo dato al nostro pool ZFS.

`Name of the storage backend to use (btrfs, dir, lvm, zfs, ceph) [default=zfs]:`

Ovviamente vogliamo accettare l'impostazione predefinita.

`Create a new ZFS pool? (yes/no) [default=yes]: no`

Qui si risolve la domanda precedente sulla creazione di un pool di storage.

`Name of the existing ZFS pool or dataset: storage`

`Would you like to connect to a MAAS server? (yes/no) [default=no]:`

Il Metal As A Service (MAAS) non rientra nell'ambito di questo documento.

`Would you like to create a new local network bridge? (yes/no) [default=yes]:`

`What should the new bridge be called? [default=lxdbr0]:`

`What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:`

`What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none`

Se si desidera utilizzare IPv6 sui propri contenitori LXD, è possibile attivare questa opzione. Questo dipende da voi.

`Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes`

È necessario per eseguire lo snapshot del server, quindi rispondere "yes".

`Address to bind LXD to (not including port) [default=all]:`

`Port to bind LXD to [default=8443]:`

`Trust password for new clients:`

`Again:`

Questa password di fiducia è il modo in cui ci si connetterà al server snapshot o al suo ritorno, quindi va impostata con qualcosa che abbia senso nel vostro ambiente. Salvare questa voce in un luogo sicuro, ad esempio in un gestore di password.

`Would you like stale cached images to be updated automatically? (yes/no) [default=yes]`

`Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:`

#### Impostazione dei Privilegi degli Utenti

Prima di continuare, dobbiamo creare l'utente "lxdadmin" e assicurarci che abbia i privilegi necessari. Abbiamo bisogno che l'utente "lxdadmin" sia in grado di fare il _sudo_ a root e che sia membro del gruppo lxd. Per aggiungere l'utente e assicurarsi che sia membro di entrambi i gruppi, procedere come segue:

`useradd -G wheel,lxd lxdadmin`

Quindi impostare la password:

`passwd lxdadmin`

Come per le altre password, salvatela in un luogo sicuro.

### <a name="firewallsetup"></a>Impostazione del Firewall - iptables

Prima di continuare, è necessario impostare un firewall sul server. Questo esempio utilizza _iptables_ e [questa procedura](../security/enabling_iptables_firewall.md) per disabilitare _firewalld_. Se si preferisce usare _firewalld_, è sufficiente sostituire le regole di _firewalld_ con le istruzioni riportate in questa sezione.

Creare lo script firewall.conf:

`vi /etc/firewall.conf`

Si ipotizza un server LXD su una rete LAN 192.168.1.0/24 di seguito riportata. Si noti inoltre che stiamo accettando tutto il traffico dalla nostra interfaccia bridged. Questo è importante se si vuole che i container ricevano indirizzi IP dal bridge.

Questo script del firewall non fa altre ipotesi sui servizi di rete necessari. Esiste una regola SSH che consente agli IP della nostra rete LAN di accedere al server tramite SSH. È possibile che siano necessarie molte più regole, a seconda dell'ambiente. In seguito, aggiungeremo una regola per il traffico bidirezionale tra il server di produzione e il server snapshot.

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
iptables -A INPUT -i lxdbr0 -j ACCEPT
iptables -A INPUT -p tcp -m tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable

/usr/sbin/service iptables save
```
### Impostazione del Firewall - firewalld

Per le regole di _firewalld_, è necessario utilizzare [questa procedura di base](../security/firewalld.md) o avere familiarità con questi concetti. Le nostre ipotesi sono le stesse delle regole _iptables_ di cui sopra: Rete LAN 192.168.1.0/24 e un bridge chiamato lxdbr0. Per essere chiari, si potrebbero avere più interfacce sul server LXD, con una forse rivolta anche verso la WAN. Creeremo anche una zona per le reti bridged e locali. Questo è solo per chiarezza di zona, dato che gli altri nomi non sono applicabili. Quanto segue presuppone che si conoscano già le basi di _firewalld_.

```
firewall-cmd --new-zone=bridge --permanent
```

È necessario ricaricare il firewall dopo aver aggiunto una zona:

```
firewall-cmd --reload
```

Vogliamo consentire tutto il traffico dal bridge, quindi aggiungiamo l'interfaccia e cambiamo il target da "default" ad "ACCEPT" e avremo finito:

!!! attention "Attenzione"

    La modifica della destinazione di una zona firewalld deve essere fatta con l'opzione --permanent, quindi è meglio inserire questo flag anche negli altri comandi e rinunciare all'opzione --runtime-to-permanent.

!!! Note "Nota"

    Se si deve creare una zona in cui si vuole consentire l'accesso all'interfaccia o alla sorgente, ma non si vuole specificare alcun protocollo o servizio, è necessario modificare l'obiettivo da "default" ad ACCEPT. Lo stesso vale per DROP e REJECT per un particolare blocco IP per il quale sono state create zone personalizzate. Per essere chiari, la zona "drop" si occuperà di questo aspetto, a patto che non si utilizzi una zona personalizzata.

```
firewall-cmd --zone=bridge --add-interface=lxdbr0 --permanent
firewall-cmd --zone=bridge --set-target=ACCEPT --permanent
```
Supponendo che non ci siano errori e che tutto funzioni ancora, è sufficiente ricaricare il sistema:

```
firewall-cmd --reload
```
Se ora si elencano le regole con `firewall-cmd --zone=bridge --list-all`, si dovrebbe vedere qualcosa di simile a quanto segue:

```
bridge (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces: lxdbr0
  sources:
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
Dalle regole di _iptables_ si nota che vogliamo consentire anche la nostra interfaccia locale. Anche in questo caso, non mi piacciono le zone incluse, quindi creare una nuova zona e utilizzare l'intervallo IP di origine per l'interfaccia locale per assicurarsi di avere accesso:

```
firewall-cmd --new-zone=local --permanent
firewall-cmd --reload
```
Quindi è sufficiente aggiungere gli IP di origine per l'interfaccia locale, cambiare il target in "ACCEPT" e anche in questo caso abbiamo finito:

```
firewall-cmd --zone=local --add-source=127.0.0.1/8 --permanent
firewall-cmd --zone=local --set-target=ACCEPT --permanent
firewall-cmd --reload
```
Procedere con l'elenco della zona "locale" per assicurarsi che le regole siano presenti con `firewall-cmd --zone=local --list all` che dovrebbe mostrare qualcosa di simile:

```
local (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 127.0.0.1/8
  services:
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

Poi vogliamo consentire SSH dalla nostra rete fidata. Utilizzeremo qui gli IP di origine, proprio come nell'esempio di _iptables_, e la zona "trusted" incorporata. L'obiettivo di questa zona è già "ACCEPT" per impostazione predefinita.

```
firewall-cmd --zone=trusted --add-source=192.168.1.0/24
```
Quindi aggiungere il servizio alla zona:

```
firewall-cmd --zone=trusted --add-service=ssh
```
Se tutto funziona, spostare le regole in modo permanente e ricaricarle:

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
```
L'elenco delle zone "trusted" dovrebbe ora mostrare qualcosa di simile:

```
trusted (active)
  target: ACCEPT
  icmp-block-inversion: no
  interfaces:
  sources: 192.168.1.0/24
  services: ssh
  ports:
  protocols:
  forward: no
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```
Per impostazione predefinita, la zona "pubblica" è abilitata e consente l'uso di SSH. Non vogliamo questo. Assicurarsi che le zone siano corrette e che l'accesso al server avvenga tramite uno degli IP della LAN (nel nostro esempio) e che sia consentito l'SSH. Se non lo si verifica prima di continuare, si rischia di rimanere esclusi dal server. Dopo essersi assicurati di avere accesso dall'interfaccia corretta, rimuovere SSH dalla zona "pubblica":

```
firewall-cmd --zone=public --remove-service=ssh
```
Verificate l'accesso e assicuratevi di non essere bloccati. In caso contrario, spostare le regole su permanenti, ricaricare ed elencare la zona "public" per essere sicuri che SSH sia stato rimosso:

```
firewall-cmd --runtime-to-permanent
firewall-cmd --reload
firewall-cmd --zone=public --list-all
```
Potrebbero esserci altre interfacce da considerare sul vostro server. È possibile utilizzare le zone integrate, se necessario, ma se i nomi non piacciono (non sembrano logici, ecc.), è possibile aggiungere zone. Ricordate che se non ci sono servizi o protocolli che dovete consentire o rifiutare in modo specifico, dovrete modificare il target di zona. Se è possibile utilizzare le interfacce, come abbiamo fatto con il bridge, è possibile farlo. Se avete bisogno di un accesso più granulare ai servizi, utilizzate invece gli IP di origine.

Questo completa la Parte 1. È possibile proseguire con la Parte 2 o tornare al [menu](#menu). Se state lavorando sul server snapshot, potete passare ora alla [Parte 5](#part5).

## <a name="part2"></a>Parte 2: Impostazione e Gestione delle Immagini

Per tutta la Parte 2, e da qui in avanti se non diversamente indicato, si eseguiranno i comandi come utente non privilegiato. ("lxdadmin" se state seguendo questo documento).

### <a name="listimages"></a>Elenco delle Immagini Disponibili

Una volta configurato l'ambiente del server, probabilmente non vedrete l'ora di iniziare a usare un container. Ci sono _molte_ possibilità per i sistemi operativi container. Per avere un'idea del numero di possibilità, inserite questo comando:

`lxc image list images: | more`

Premete la barra spaziatrice per scorrere l'elenco. Questo elenco di container e macchine virtuali continua a crescere. Per ora ci atteniamo ai containers.

L'ultima cosa che si vuole fare è cercare un'immagine del container da installare, soprattutto se si conosce l'immagine che si vuole creare. Modifichiamo il comando precedente per mostrare solo le opzioni di installazione di CentOS Linux:

`lxc image list immagini: | grep centos/8`

In questo modo si ottiene un elenco molto più gestibile:

```
| centos/8 (3 more)                    | 98b4dbef0c29 | yes    | Centos 8 amd64 (20210427_07:08)              | x86_64       | VIRTUAL-MACHINE | 517.44MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8 (3 more)                    | 0427669ebee4 | yes    | Centos 8 amd64 (20210427_07:08)              | x86_64       | CONTAINER       | 125.58MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream (3 more)             | 961170f8934f | yes    | Centos 8-Stream amd64 (20210427_07:08)       | x86_64       | VIRTUAL-MACHINE | 586.44MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream (3 more)             | e507fdc8935a | yes    | Centos 8-Stream amd64 (20210427_07:08)       | x86_64       | CONTAINER       | 130.33MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/arm64 (1 more)       | e5bf98409ac6 | yes    | Centos 8-Stream arm64 (20210427_10:33)       | aarch64      | CONTAINER       | 126.56MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/cloud (1 more)       | 5751ca14bf8f | yes    | Centos 8-Stream amd64 (20210427_07:08)       | x86_64       | CONTAINER       | 144.75MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/cloud (1 more)       | ccf0bb20b0ca | yes    | Centos 8-Stream amd64 (20210427_07:08)       | x86_64       | VIRTUAL-MACHINE | 593.31MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/cloud/arm64          | db3d915d12fd | yes    | Centos 8-Stream arm64 (20210427_07:08)       | aarch64      | CONTAINER       | 140.60MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/cloud/ppc64el        | 11aa2ab878b2 | yes    | Centos 8-Stream ppc64el (20210427_07:08)     | ppc64le      | CONTAINER       | 149.45MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8-Stream/ppc64el (1 more)     | a27665203e47 | yes    | Centos 8-Stream ppc64el (20210427_07:08)     | ppc64le      | CONTAINER       | 134.52MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/arm64 (1 more)              | d64396d47fa7 | yes    | Centos 8 arm64 (20210427_07:08)              | aarch64      | CONTAINER       | 121.83MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/cloud (1 more)              | 84803ca6e32d | yes    | Centos 8 amd64 (20210427_07:08)              | x86_64       | CONTAINER       | 140.42MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/cloud (1 more)              | c98196cd9eec | yes    | Centos 8 amd64 (20210427_07:08)              | x86_64       | VIRTUAL-MACHINE | 536.00MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/cloud/arm64                 | 9d06684a9a4e | yes    | Centos 8 arm64 (20210427_10:33)              | aarch64      | CONTAINER       | 136.49MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/cloud/ppc64el               | 18c13c448349 | yes    | Centos 8 ppc64el (20210427_07:08)            | ppc64le      | CONTAINER       | 144.66MB  | Apr 27, 2021 at 12:00am (UTC) |
| centos/8/ppc64el (1 more)            | 130c1c83c36c | yes    | Centos 8 ppc64el (20210427_07:08)            | ppc64le      | CONTAINER       | 129.53MB  | Apr 27, 2021 at 12:00am (UTC) |
```

### <a name="lxdimageinstall"></a>Installare, Rinominare ed Elencare le Immagini

Per il primo container, sceglieremo centos/8. Per installarlo, *si può* usare:

`lxc launch images:centos/8 centos-test`

Questo creerà un container basato su CentOS chiamato "centos-test". È possibile rinominare un container dopo che è stato creato, ma prima è necessario arrestare il container, che si avvia automaticamente quando viene lanciato.

Per avviare manualmente il container, utilizzare:

`lxc start centos-test`

Ai fini di questa guida, per ora installate un'altra immagine:

`lxc launch images:ubuntu/20.10 ubuntu-test`

Ora diamo un'occhiata a ciò che abbiamo finora, elencando le nostre immagini:

`lxc list`

che dovrebbe restituire qualcosa di simile:

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING | 10.199.182.72 (eth0)  |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

### <a name="profiles"></a>Profili LXD

Quando si installa LXD si ottiene un profilo predefinito, che non può essere rimosso o modificato. Detto questo, è possibile utilizzare il profilo predefinito per creare nuovi profili da utilizzare con i propri container.

Se si osserva l'elenco dei nostri container (sopra), si noterà che l'indirizzo IP in ogni caso è assegnato dall'interfaccia bridged. In un ambiente di produzione, si potrebbe voler usare qualcos'altro. Potrebbe trattarsi di un indirizzo assegnato via DHCP dall'interfaccia LAN o anche di un indirizzo assegnato staticamente dalla WAN.

Se si configura il server LXD con due interfacce e si assegna a ciascuna un IP sulla WAN e sulla LAN, è possibile assegnare ai container indirizzi IP in base all'interfaccia verso cui il container deve essere rivolto.

A partire dalla versione 8 di Rocky Linux (e in realtà qualsiasi copia di Red Hat Enterprise Linux, come CentOS nel nostro elenco precedente) il metodo per assegnare gli indirizzi IP in modo statico o dinamico utilizzando i profili sottostanti, è stato interrotto.

Ci sono modi per aggirare questo problema, ma è fastidioso, perché la funzione che non funziona _dovrebbe essere_ parte del kernel Linux. Questa funzione è macvlan. Macvlan consente di creare più interfacce con indirizzi Layer 2 diversi.

Per ora, sappiate che ciò che stiamo per suggerire ha degli svantaggi quando si scelgono immagini di container basate su RHEL.

#### <a name="macvlan"></a>Creazione di un Profilo macvlan e sua Assegnazione

Per creare il nostro profilo macvlan, basta usare questo comando:

`lxc profile create macvlan`

Si tenga presente che, se si dispone di una macchina con più interfacce e si desidera più di un modello macvlan in base alla rete che si desidera raggiungere, si può usare "lanmacvlan" o "wanmacvlan" o qualsiasi altro nome che si desidera usare per identificare il profilo. In altre parole, l'uso di "macvlan" nella dichiarazione di creazione del profilo dipende totalmente da voi.

Una volta creato il profilo, è necessario modificarlo per ottenere i risultati desiderati. Per prima cosa, dobbiamo assicurarci che l'editor predefinito del server sia quello che vogliamo usare. Se non si esegue questo passaggio, l'editor sarà quello predefinito. Abbiamo scelto _vim_ come editor:

`export EDITOR=/usr/bin/vim`

Ora vogliamo modificare l'interfaccia macvlan, ma prima dobbiamo sapere qual è l'interfaccia principale del nostro server LXD. Si tratta dell'interfaccia che ha un IP assegnato alla LAN (in questo caso). Per determinare di quale interfaccia si tratta, utilizzare:

`ip addr`

Quindi cercare l'interfaccia con l'assegnazione dell'IP LAN nella rete 192.168.1.0/24:

```
2: enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 40:16:7e:a9:94:85 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.106/24 brd 192.168.1.255 scope global dynamic noprefixroute enp3s0
       valid_lft 4040sec preferred_lft 4040sec
    inet6 fe80::a308:acfb:fcb3:878f/64 scope link noprefixroute
       valid_lft forever preferred_lft forever
```

In questo caso, l'interfaccia sarebbe "enp3s0".

Ora modifichiamo il profilo:

`lxc profile edit macvlan`

Questo file sarà auto-documentato all'inizio. È necessario modificare il file come segue, sotto la sezione commentata:

```
config: {}
description: ""
devices:
  eth0:
   name: eth0
   nictype: macvlan
   parent: enp3s0
   type: nic
name: macvlan
used_by: []
```

Ovviamente si possono usare i profili per molte altre cose, ma l'assegnazione di un IP statico a un container o l'uso del proprio server DHCP come fonte per un indirizzo sono esigenze molto comuni.

Per assegnare il profilo macvlan a centos-test è necessario procedere come segue:

`lxc profile assign centos-test default,macvlan`

Questo dice semplicemente che vogliamo il profilo predefinito e che vogliamo applicare anche il profilo macvlan.

#### <a name="centosmacvlan"></a> CentOS macvlan

Nell'implementazione CentOS di Network Manager, sono riusciti a interrompere la funzionalità di macvlan nel kernel, o almeno nel kernel applicato alla loro immagine LXD. È così da quando è stato rilasciato CentOS 8 e nessuno sembra preoccuparsi di trovare una soluzione.

In poche parole, se si vogliono eseguire container CentOS 8 (o qualsiasi altra release di RHEL 1-for-1, come Rocky Linux), bisogna fare i salti mortali per far funzionare macvlan. macvlan fa parte del kernel, quindi dovrebbe funzionare anche senza le correzioni seguenti, ma non è così.

##### CentOS macvlan - La Soluzione DHCP

L'assegnazione del profilo, tuttavia, non modifica la configurazione predefinita, che è impostata su DHCP.

Per verificarlo, è sufficiente eseguire la seguente operazione:

`lxc stop centos-test`

E poi:

`lxc start centos-test`

Ora elencate nuovamente i vostri container e notate che centos-test non ha più un indirizzo IP:

`lxc list`

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING |                       |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

Per dimostrare ulteriormente il problema, dobbiamo eseguire `dhclient` sul container. È possibile farlo con:

`lxc exec centos-test dhclient`

Un nuovo elenco utilizzando `lxc list` mostra ora quanto segue:

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING | 192.168.1.138 (eth0)  |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

Questo sarebbe dovuto accadere con un semplice arresto e avvio del container, ma non è così. Supponendo di voler utilizzare sempre un indirizzo IP assegnato da DHCP, si può risolvere il problema con una semplice voce di crontab. Per farlo, è necessario ottenere l'accesso al container tramite shell, inserendo:

`lxc exec centos-test bash`

Quindi, determiniamo il percorso completo di `dhclient`:

`which dhclient`

che dovrebbe restituire:

`/usr/sbin/dhclient`

Quindi, modifichiamo il crontab di root:

`crontab -e`

E aggiungere questa riga:

`@reboot    /usr/sbin/dhclient`

Il comando crontab inserito sopra utilizza _vi_, quindi per salvare le modifiche e uscire è sufficiente utilizzare:

`SHIFT:wq!`

Ora uscire dal container e arrestare centos-test:

`lxc stop centos-test`

e poi riavviarlo:

`lxc start centos-test`

Un nuovo elenco rivelerà che al container è stato assegnato l'indirizzo DHCP:

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING | 192.168.1.138 (eth0)  |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

##### CentOS macvlan - La soluzione per l'IP Statico

Per assegnare staticamente un indirizzo IP, le cose si fanno ancora più complicate. Il processo di impostazione di un indirizzo IP statico su un container CentOS avviene tramite gli script di rete, che verranno eseguiti ora. L'IP che cercheremo di assegnare è 192.168.1.200.

Per farlo, dobbiamo ottenere di nuovo l'accesso al container:

`lxc exec centos-test bash`

La prossima cosa da fare è modificare manualmente l'interfaccia denominata "eth0" e impostare il nostro indirizzo IP. Per modificare la configurazione, procedere come segue:

`vi /etc/sysconfig/network-scripts/ifcfg-eth0`

Che restituirà questo:

```
DEVICE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
HOSTNAME=centos-test
TYPE=Ethernet
MTU=
DHCP_HOSTNAME=centos-test
IPV6INIT=yes
```

Dobbiamo modificare questo file in modo che abbia il seguente aspetto:

```
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.1.200
PREFIX=24
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
HOSTNAME=centos-test
TYPE=Ethernet
MTU=
DHCP_HOSTNAME=centos-test
IPV6INIT=yes
```

Questo dice che vogliamo impostare il protocollo di avvio su nessuno (usato per le assegnazioni IP statiche), impostare l'indirizzo IP su 192.168.1.200, che questo indirizzo fa parte di una CLASSE C (PREFIX=24), che il gateway per questa rete è 192.168.1.1 e che vogliamo usare i server DNS aperti di Google per la risoluzione dei nomi.

Salvare il file`(SHIFT:wq!`).

Dobbiamo anche rimuovere il crontab per root, perché non è quello che vogliamo per un IP statico. Per farlo, è sufficiente `crontab -e` e sottolineare la riga @reboot con un "#", salvare le modifiche e uscire dal container.

Fermare il container con:

`lxc stop centos-test`

e riavviarlo:

`lxc start centos-test`

Proprio come l'indirizzo assegnato da DHCP, l'indirizzo assegnato staticamente non verrà assegnato quando si elenca il container:

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING |                       |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

Per risolvere questo problema è necessario interrompere Network Manager sul container. La seguente soluzione funziona, almeno per ora:

`lxc exec centos-test dhclient`

Poi entrate nel container:

`lxc exec centos-test bash`

Installare i vecchi script di rete:

`dnf install network-scripts`

Nuke Network Manager:

`systemctl stop NetworkManager` `systemctl disable NetworkManager`

Attivare il vecchio servizio di rete:

`systemctl enable network.service`

Uscire dal container, quindi arrestare e avviare nuovamente il container:

`lxc stop centos-test`

E poi eseguire:

`lxc start centos-test`

All'avvio del container, un nuovo elenco mostrerà l'IP staticamente assegnato corretto:

```
+-------------+---------+-----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+-----------------------+------+-----------+-----------+
| centos-test | RUNNING | 192.168.1.200 (eth0)  |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 10.199.182.236 (eth0) |      | CONTAINER | 0         |
+-------------+---------+-----------------------+------+-----------+-----------+
```

Il problema con macvlan mostrato in entrambi gli esempi è direttamente correlato ai container basati su Red Hat Enterprise Linux (Centos 8, Rocky Linux 8).

#### <a name="ubuntumacvlan"></a>Ubuntu macvlan

Fortunatamente, nell'implementazione di Ubuntu di Network Manager, lo stack macvlan NON è mancante, quindi è molto più facile da distribuire!

Per prima cosa, proprio come nel caso del container centos-test, dobbiamo assegnare il template al nostro container:

`lxc profile assign ubuntu-test default,macvlan`

Questo dovrebbe essere tutto ciò che è necessario per ottenere un indirizzo assegnato da DHCP. Per scoprirlo, fermate e riavviate il container:

`lxc stop ubuntu-test`

E poi eseguire:

`lxc start ubuntu-test`

Quindi elencare nuovamente i container:

```
+-------------+---------+----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+----------------------+------+-----------+-----------+
| centos-test | RUNNING | 192.168.1.200 (eth0) |      | CONTAINER | 0         |
+-------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 192.168.1.139 (eth0) |      | CONTAINER | 0         |
+-------------+---------+----------------------+------+-----------+-----------+
```

Riuscito!

La configurazione dell'IP statico è leggermente diversa, ma non è affatto difficile. Occorre modificare il file .yaml associato alla connessione del contenitore (/10-lxc.yaml). Per questo IP statico, utilizzeremo 192.168.1.201:

`vi /etc/netplan/10-lxc.yaml`

E cambiare quello che c'è con il seguente:

```
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

Salvare le modifiche`(SHFT:wq!`) e uscire dal container.

Ora fermate e avviate il container:

`lxc stop ubuntu-test`

E poi eseguire:

`lxc start ubuntu-test`

Quando si elencano nuovamente i container, si dovrebbe vedere il nuovo IP statico:

```
+-------------+---------+----------------------+------+-----------+-----------+
|    NAME     |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+----------------------+------+-----------+-----------+
| centos-test | RUNNING | 192.168.1.200 (eth0) |      | CONTAINER | 0         |
+-------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test | RUNNING | 192.168.1.201 (eth0) |      | CONTAINER | 0         |
+-------------+---------+----------------------+------+-----------+-----------+
```

Riuscito!

Negli esempi utilizzati nella Parte 2, abbiamo scelto intenzionalmente un container difficile da configurare e uno facile. Ci sono ovviamente molte altre versioni di Linux disponibili nell'elenco delle immagini. Se ce n'è  uno preferito, provare a installarlo, assegnando il modello macvlan e impostando gli IP.

Questo completa la Parte 2. È possibile proseguire con la Parte 3 o tornare al [menu](#menu).

## Parte 3: Opzioni di Configurazione del Container

Ci sono molte opzioni per configurare il container una volta installato. Prima di vedere come visualizzano, però, diamo un'occhiata al comando info per un container. In questo esempio, utilizzeremo il container ubuntu-test:

`lxc info ubuntu-test`

Il risultato è simile al seguente:

```
Name: ubuntu-test
Location: none
Remote: unix://
Architecture: x86_64
Created: 2021/04/26 15:14 UTC
Status: Running
Type: container
Profiles: default, macvlan
Pid: 584710
Ips:
  eth0:    inet    192.168.1.201    enp3s0
  eth0:    inet6    fe80::216:3eff:fe10:6d6d    enp3s0
  lo:    inet    127.0.0.1
  lo:    inet6    ::1
Resources:
  Processes: 13
  Disk usage:
    root: 85.30MB
  CPU usage:
    CPU usage (in seconds): 1
  Memory usage:
    Memory (current): 99.16MB
    Memory (peak): 110.90MB
  Network usage:
    eth0:
      Bytes received: 53.56kB
      Bytes sent: 2.66kB
      Packets received: 876
      Packets sent: 36
    lo:
      Bytes received: 0B
      Bytes sent: 0B
      Packets received: 0
      Packets sent: 0
```

Ci sono molte informazioni utili, dai profili applicati, alla memoria in uso, allo spazio su disco in uso e altro ancora.

#### <a name="lxdconfigopt"></a>Informazioni sulla Configurazione e su Alcune Opzioni

Per impostazione predefinita, LXD alloca al container la memoria di sistema, lo spazio su disco, i core della CPU e così via. Ma se volessimo essere più specifici? È assolutamente possibile.

Tuttavia, questo comporta degli svantaggi. Per esempio, se si alloca la memoria di sistema e il container non la usa tutta, allora l'abbiamo sottratta a un altro container che potrebbe averne bisogno. Tuttavia, può accadere anche il contrario. Se un container ha una consumo esagerato in fatto di memoria, può impedire agli altri container di averne a sufficienza, riducendo così le loro prestazioni.

Tenete presente che ogni azione compiuta per configurare un container _può_ avere effetti negativi da qualche altra parte.

Piuttosto che scorrere tutte le opzioni di configurazione, utilizzare il completamento automatico delle schede per visualizzare le opzioni disponibili:

`lxc config set ubuntu-test` e poi premere TAB.

Mostra tutte le opzioni per la configurazione di un container. Se avete domande su cosa fa una delle opzioni di configurazione, consultate la [documentazione ufficiale di LXD](https://lxd.readthedocs.io/en/stable-4.0/instances/) e fate una ricerca per il parametro di configurazione, oppure cercate su Google l'intera stringa, ad esempio "lxc config set limits.memory" e date un'occhiata ai risultati della ricerca.

Vediamo alcune delle opzioni di configurazione più utilizzate. Ad esempio, se si vuole impostare la quantità massima di memoria che un container può utilizzare:

`lxc config set ubunt-test limits.memory 2GB`

Questo dice che finché la memoria è disponibile per l'uso, in altre parole ci sono 2 GB di memoria libera, il contenitore può usare più di 2 GB se è disponibile. In altre parole, si tratta di un limite variabile.

`lxc config set ubuntu-test limits.memory.enforce 2GB`

Ciò significa che il contenitore non può mai utilizzare più di 2 GB di memoria, indipendentemente dal fatto che sia attualmente disponibile o meno. In questo caso si tratta di un limite rigido.

`lxc config set ubuntu-test limits.cpu 2`

Questo dice di limitare a 2 il numero di core della CPU che il container può utilizzare.

Ricordate quando abbiamo impostato il nostro pool di archiviazione nella sezione [Abilitazione di zfs e Impostazione del Pool](#zfssetup) di cui sopra?  Abbiamo chiamato il pool "storage", ma avremmo potuto chiamarlo in qualsiasi modo. Se vogliamo dare un'occhiata, possiamo usare questo comando:

`lxc storage show storage`

Questo mostra quanto segue:

```
config:
  source: storage
  volatile.initial_source: storage
  zfs.pool_name: storage
description: ""
name: storage
driver: zfs
used_by:
- /1.0/images/0cc65b6ca6ab61b7bc025e63ca299f912bf8341a546feb8c2f0fe4e83843f221
- /1.0/images/4f0019aee1515c109746d7da9aca6fb6203b72f252e3ee3e43d50b942cdeb411
- /1.0/images/9954953f2f5bf4047259bf20b9b4f47f64a2c92732dbc91de2be236f416c6e52
- /1.0/instances/centos-test
- /1.0/instances/ubuntu-test
- /1.0/profiles/default
status: Created
locations:
- none
```

Questo mostra che tutti i container utilizzano il pool di archiviazione zfs. Quando si usa ZFS, si può anche impostare una quota disco su un container. Per farlo, impostiamo una quota disco di 2 GB sul container ubuntu-test. Lo si fa con:

`lxc config device override ubuntu-test root size=2GB`

Come detto in precedenza, si dovrebbero usare le opzioni di configurazione con parsimonia, a meno che non si abbia un container che vuole usare molto più della sua quota di risorse. LXD, nella maggior parte dei casi, gestisce l'ambiente in modo autonomo.

Esistono naturalmente molte altre opzioni che potrebbero essere di interesse per alcuni. Dovete fare le vostre ricerche per scoprire se uno di questi elementi è utile nel vostro ambiente.

Questo completa la Parte 3. È possibile proseguire con la Parte 4 o tornare al [menu](#menu).

## Parte 4: Istantanee del Container

Le istantanee dei container, insieme a un server di istantanee (di cui parleremo più avanti), sono probabilmente l'aspetto più importante dell'esecuzione di un server LXD di produzione. Le istantanee assicurano un ripristino rapido e possono essere usate per sicurezza quando, ad esempio, si sta aggiornando il software primario che gira su un particolare container. Se durante l'aggiornamento accade qualcosa che interrompe l'applicazione, è sufficiente ripristinare l'istantanea per tornare operativi con un tempo di inattività di pochi secondi.

L'autore ha utilizzato i container LXD per i server PowerDNS rivolti al pubblico e il processo di aggiornamento di queste applicazioni è diventato molto più semplice, poiché è possibile eseguire lo snapshot del container prima di continuare.

È anche possibile eseguire l'istantanea di un container mentre è in esecuzione. Inizieremo ottenendo un'istantanea del container ubuntu-test utilizzando questo comando:

`lxc snapshot ubuntu-test ubuntu-test-1`

Qui chiamiamo l'istantanea "ubuntu-test-1", ma può essere chiamata come volete. Per assicurarsi di avere l'istantanea, eseguire un "lxc info" del contenitore:

`lxc info ubuntu-test`

Abbiamo già visto una schermata informativa, quindi se si scorre fino in fondo, si dovrebbe vedere:

```
Snapshots:
  ubuntu-test-1 (taken at 2021/04/29 15:57 UTC) (stateless)
```

Riuscito! La nostra istantanea è pronta.

Ora, entrare nel container ubuntu-test:

`lxc exec ubuntu-test bash`

E creare un file vuoto con il comando _touch_:

`touch this_file.txt`

Uscire dal container.

Prima di ripristinare il container come era prima della creazione del file, il modo più sicuro per ripristinare un container, in particolare se ci sono state molte modifiche, è quello di fermarlo prima:

`lxc stop ubuntu-test`

Quindi ripristinarlo:

`lxc restore ubuntu-test ubuntu-test-1`

Quindi riavviare il container:

`lxc start ubuntu-test`

Se si torna di nuovo nel container e si guarda, il file "this_file.txt" che abbiamo creato è sparito.

Quando non si ha più bisogno di un'istantanea, è possibile eliminarla:

`lxc delete ubuntu-test/ubuntu-test-1`

**Importante:** è necessario eliminare sempre le istantanee con il contenitore in funzione. Perché? Il comando _lxc delete_ funziona anche per eliminare l'intero container. Se avessimo accidentalmente premuto invio dopo "ubuntu-test" nel comando precedente, E, se il container fosse stato fermato, il container sarebbe stato cancellato. Non viene dato alcun avviso, fa semplicemente quello che gli si chiede.

Se il container è in esecuzione, tuttavia, viene visualizzato questo messaggio:

`Error: The instance is currently running, stop it first or pass --force`

Pertanto, eliminare sempre le istantanee con il contenitore in funzione.

Il processo di creazione automatica delle istantanee, l'impostazione della scadenza dell'istantanea in modo che scompaia dopo un certo periodo di tempo e l'aggiornamento automatico delle istantanee al server delle istantanee saranno trattati in dettaglio nella sezione dedicata al server delle istantanee.

Questo completa la Parte 4. È possibile proseguire con la Parte 5 o tornare al [menu](#menu).

## Parte 5: Il Server Snapshot

Come indicato all'inizio, il server snapshot per LXD deve essere in tutto e per tutto un mirror del server di produzione. Il motivo è che potrebbe essere necessario passare alla produzione in caso di guasto hardware, e avere non solo i backup, ma anche un modo rapido per ripristinare i container di produzione, consente di ridurre al minimo le telefonate e gli SMS di panico degli amministratori di sistema. QUESTO è SEMPRE un bene!

Quindi il processo di creazione del server snapshot è esattamente come quello del server di produzione. Per emulare completamente la nostra configurazione del server di produzione, eseguite nuovamente tutta la [Parte 1](#part1) e, una volta completata, tornate a questo punto.

Sei tornato!!! Congratulazioni, questo significa che avete completato con successo la Parte 1 per il server snapshot. Che bella notizia!!!

### Impostazione della Relazione tra Server Primario e Server Snapshot

Dobbiamo fare un po' di pulizia prima di continuare. Innanzitutto, se si opera in un ambiente di produzione, probabilmente si ha accesso a un server DNS che si può utilizzare per impostare la risoluzione IP-nome.

Nel nostro laboratorio non abbiamo questo lusso. Forse anche voi avete lo stesso scenario. Per questo motivo, aggiungeremo gli indirizzi IP e i nomi di entrambi i server al file /etc/hosts sia sul server primario che sul server snapshot. È necessario farlo come utente root (o _sudo_).

Nel nostro laboratorio, il server LXD primario è in esecuzione su 192.168.1.106 e il server LXD snapshot è in esecuzione su 192.168.1.141. Si entra in SSH in entrambi i server e si aggiunge quanto segue al file /etc/hosts:

```
192.168.1.106 lxd-primary
192.168.1.141 lxd-snapshot
```
Successivamente, è necessario consentire tutto il traffico tra i due server. Per fare ciò, si modificherà il file /etc/firewall.conf con quanto segue. Per prima cosa, sul server lxd-primario, aggiungere questa riga:

`IPTABLES -A INPUT -s 192.168.1.141 -j ACCEPT`

E sul server lxd-snapshot, aggiungere questa riga:

`IPTABLES -A INPUT -s 192.168.1.106 -j ACCEPT`

In questo modo è possibile far viaggiare il traffico bidirezionale di tutti i tipi tra i due server.

Successivamente, come utente "lxdadmin", dobbiamo impostare la relazione di fiducia tra le due macchine. Per farlo, eseguire il seguente comando su lxd-primary:

`lxc remote add lxd-snapshot`

Verrà visualizzato il certificato da accettare, quindi lo si eseguirà e verrà richiesta la password. Si tratta della "password di fiducia" impostata durante la fase di [inizializzazione di LXD](#lxdinit). Si spera che teniate traccia di tutte queste password in modo sicuro. Una volta immessa la password, si dovrebbe ricevere questo messaggio:

`Client certificate stored at server:  lxd-snapshot`

Non fa male farlo fare anche al contrario. In altre parole, impostare la relazione di fiducia sul server lxd-snapshot in modo che, se necessario, le istantanee possano essere inviate al server lxd-primary. È sufficiente ripetere i passaggi e sostituire "lxd-primary" con "lxd-snapshot"

### Migrazione della Nostra Prima Istantanea

Prima di poter migrare la prima istantanea, è necessario che su lxd-snapshot vengano creati i profili che abbiamo creato su lxd-primary. Nel nostro caso, si tratta del profilo "macvlan".

È necessario creare questo profilo per lxd-snapshot, quindi tornare a [LXD Profiles](#profiles) e creare il profilo "macvlan" su lxd-snapshot. Se i due server hanno nomi di interfacce padre identici ("enp3s0", ad esempio), è possibile copiare il profilo "macvlan" in lxd-snapshot senza ricrearlo:

`lxc profile copy macvlan lxd-snapshot`

Ora che abbiamo impostato tutte le relazioni e i profili, il passo successivo è quello di inviare effettivamente un'istantanea da lxd-primary a lxd-snapshot. Se avete seguito esattamente la procedura, probabilmente avete cancellato tutte le vostre istantanee, quindi creiamone una nuova:

`lxc snapshot centos-test centos-snap1`

Se si esegue il sottocomando "info" per lxc, si può vedere la nuova istantanea in fondo al nostro elenco:

`lxc info centos-test`

Che mostrerà qualcosa di simile in basso:

`centos-snap1 (taken at 2021/05/13 16:34 UTC) (stateless)`

Ok, incrociamo le dita! Proviamo a migrare la nostra istantanea:

`lxc copy centos-test/centos-snap1 lxd-snapshot:centos-test`

Questo comando dice che, all'interno del contenitore centos-test, vogliamo inviare l'istantanea centos-snap1 a lxd-snapshot e copiarla come centos-test.

Dopo un breve periodo di tempo, la copia sarà completa. Volete scoprirlo con certezza?  Eseguire un "lxc list" sul server lxd-snapshot. Che dovrebbe restituire quanto segue:

```
+-------------+---------+------+------+-----------+-----------+
|    NAME     |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+-------------+---------+------+------+-----------+-----------+
| centos-test | STOPPED |      |      | CONTAINER | 0         |
+-------------+---------+------+------+-----------+-----------+
```

Riuscito! Ora proviamo ad avviarlo. Poiché lo stiamo avviando sul server lxd-snapshot, dobbiamo prima fermarlo sul server lxd-primary:

`lxc stop centos-test`

E sul server lxd-snapshot:

`lxc start centos-test`

Supponendo che tutto questo funzioni senza errori, arrestare il container su lxd-snapshot e riavviarlo su lxd-primary.

### Il Server Snapshot - Impostazione di boot.autostart su Off per i Container

Le istantanee copiate su lxd-snapshot saranno disattivate durante la migrazione, ma se si verifica un evento di alimentazione o se è necessario riavviare il server snapshot a causa di aggiornamenti o altro, si verificherà un problema poiché i container tenteranno di avviarsi sul server snapshot.

Per eliminare questo problema, è necessario impostare i container migrati in modo che non vengano avviati al riavvio del server. Per il nostro container centos-test appena copiato, si procede come segue:

`lxc config set centos-test boot.autostart 0`

Eseguire questa operazione per ogni istantanea sul server lxd-snapshot.

### Automatizzazione del Processo delle Istantanee

Ok, è fantastico poter creare istantanee quando è necessario, ma a volte _è necessario_ creare manualmente un'istantanea. Si potrebbe anche copiare manualmente su lxd-snapshot. MA, una volta che le cose funzionano e che avete 25-30 container o più in esecuzione sulla vostra macchina lxd-primary, l'ultima cosa che volete fare è passare un pomeriggio a cancellare le istantanee sul server di snapshot, creare nuove istantanee e inviarle.

La prima cosa da fare è pianificare un processo per automatizzare la creazione di snapshot su lxd-primary. Questa operazione deve essere eseguita per ogni container sul server lxd-primary, ma una volta impostata, si gestirà da sola. La sintassi è la seguente. Si noti la somiglianza con una voce di crontab per il timestamp:

`lxc config set [container_name] snapshots.schedule "50 20 * * *"`

Ciò significa che bisogna eseguire un'istantanea del nome del container ogni giorno alle 20:50.

Per applicare questo al nostro contenitore centos-test:

`lxc config set centos-test snapshots.schedule "50 20 * * *"`

Vogliamo anche impostare il nome dell'istantanea in modo che sia significativo per la nostra data. LXD utilizza ovunque UTC, quindi la cosa migliore per tenere traccia delle cose è impostare il nome dell'istantanea con una data/ora in un formato più comprensibile:

`lxc config set centos-test snapshots.pattern "centos-test-{{ creation_date|date:'2006-01-02_15-04-05' }}"`

GRANDE, ma di certo non vogliamo una nuova istantanea ogni giorno senza sbarazzarci di quella vecchia, giusto?  Riempiremmo il disco di istantanee. Quindi la prossima esecuzione:

`lxc config set centos-test snapshots.expiry 1d`

### Automatizzazione del Processo di Copia di Istantanee

Anche in questo caso, il processo viene eseguito su lxd-primary. La prima cosa da fare è creare uno script che verrà eseguito da cron in /usr/local/sbin chiamato "refresh-containers" :

`sudo vi /usr/local/sbin/refreshcontainers.sh`

Lo script è piuttosto semplice:

```
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x lxd-snapshot:$x
        done

```

 Rendetelo eseguibile:

`sudo chmod +x /usr/local/sbin/refreshcontainers.sh`

Cambiare la proprietà di questo script all'utente e al gruppo lxdadmin:

`sudo chown lxdadmin.lxdadmin /usr/local/sbin/refreshcontainers.sh`

Impostare il crontab per l'utente lxdadmin per l'esecuzione di questo script, in questo caso alle 10 di sera:

`crontab -e`

La voce avrà il seguente aspetto:

`00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/lxdadmin/refreshlog 2>&1`

Salvare le modifiche e uscire.

In questo modo si creerà un registro nella home directory di lxdadmin chiamato "refreshlog" che permetterà di sapere se il processo ha funzionato o meno. Molto importante!

La procedura automatica a volte fallisce. Questo accade generalmente quando un particolare container non riesce ad aggiornarsi. È possibile rieseguire manualmente l'aggiornamento con il seguente comando (assumendo centos-test come container):

`lxc copy --refresh centos-test lxd-snapshot:centos-test`

## Conclusioni

L'installazione e l'uso efficace di LXD sono numerosi. È certamente possibile installarlo sul proprio computer portatile o sulla propria workstation senza troppi problemi, in quanto si tratta di un'ottima piattaforma di sviluppo e di test. Se si desidera un approccio più serio con l'uso di container di produzione, la scelta migliore è quella di un approccio basato su server primario e snapshot.

Anche se abbiamo toccato molte funzioni e impostazioni, abbiamo solo scalfito la superficie di ciò che si può fare con LXD. Il modo migliore per imparare questo sistema è installarlo e provarlo con le cose che si usano. Se trovate utile LXD, prendete in considerazione la possibilità di installarlo nel modo descritto in questo documento per sfruttare al meglio l'hardware per i container Linux. Rocky Linux funziona molto bene per questo!

A questo punto è possibile uscire dal documento o tornare al [menu](#menu). Se volete.
