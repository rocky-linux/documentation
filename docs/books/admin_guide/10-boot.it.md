---
title: Avvio del sistema
---

# Avvio del sistema

In questo capitolo verrà illustrato come si avvia il sistema.

****
**Obiettivi** : In questo capitolo, i futuri amministratori Linux apprenderanno:

:heavy_check_mark: Le diverse fasi del processo di avvio;  
:heavy_check_mark: Come Rocky Linux supporta questo avvio tramite Grub2 e `systemd`;  
:heavy_check_mark: Come proteggere Grub2 da un attacco;  
:heavy_check_mark: Come gestire i servizi;  
:heavy_check_mark: Come accedere ai registri di log con `journald`.

:checkered_flag: **utenti**

**Conoscenza**: :star: :star:  
**Complessità**: :star: :star: :star:

**Tempo di lettura**: 20 minuti
****

## Il processo di avvio

È importante capire il processo di boot di Linux per risolvere problemi nel caso si verifichino.

Il processo di avvio include:

### L'avvio del BIOS

Il **BIOS** (Basic Input/Output System) esegue il **POST** (power on self test) per rilevare, testare e inizializzare i componenti hardware di sistema.

Quindi carica il **MBR** (Master Boot Record).

### Il Master boot record (MBR)

Il Master Boot Record sono i primi 512 byte del disco di avvio. Il MBR trova il dispositivo di boot e carica il bootloader **GRUB2** in memoria passando il controllo quest'ultimo.

I successivi 64 byte contengono la tabella delle partizioni del disco.

### Il bootloader Grub2

Il bootloader predefinito per la distribuzione Rocky 8 è **GRUB2** (GRand Unified Bootloader). GRUB2 sostituisce il vecchio. GRUB bootloader (chiamato anche GRUB legacy).

Il file di configurazione di GRUB 2 si trova in `/boot/grub2/grub.cfg` ma questo file non dovrebbe mai essere modificato direttamente.

Le impostazioni di configurazione del menu di GRUB2 si trovano in `/etc/default/grub`.  Il comando `grub2-mkdconfig` li utilizza per generare il file `grub.cfg`.

```bash
# cat /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="rd.lvm.lv=rhel/swap crashkernel=auto rd.lvm.lv=rhel/root rhgb quiet net.ifnames=0"
GRUB_DISABLE_RECOVERY="true"
```

Se si modifica uno o più di questi parametri, deve essere eseguito il comando `grub2-mkconfig` per ri-generare il file `/boot/grub2/grub.cfg`.

```bash
[root] # grub2-mkconfig –o /boot/grub2/grub.cfg
```

* GRUB2 cerca l'immagine del kernel compresso (il file `vmlinuz`) nella cartella `/boot`.
* GRUB2 carica l'immagine del kernel in memoria ed estrae il contenuto del file immagine `initramfs` in una cartella temporanea in memoria usando il file system `tmpfs`.

### Il kernel

Il kernel inizia il processo `systemd` con PID 1.

```bash
root          1      0  0 02:10 ?        00:00:02 /usr/lib/systemd/systemd --switched-root --system --deserialize 23
```

### `systemd`

`systemd` è il genitore di tutti i processi di sistema. Legge il target del link `/etc/systemd/system/default.target` (es. `/usr/lib/systemd/system/multi-user.target`) per determinare l'obiettivo predefinito del sistema. Il file indica i servizi da avviare.

`systemd` pone quindi il sistema nello stato definito dall'obiettivo eseguendo le seguenti operazioni di inizializzazione:

1. Imposta il nome della macchina
2. Inizializza la rete
3. Inizializza SELinux
4. Mostra il banner di benvenuto
5. Inizializza l'hardware in base agli argomenti forniti al kernel al momento dell'avvio
6. Monta i file system, inclusi i file system virtuali come /proc
7. Pulisce le directory in /var
8. Avvia la memoria virtuale (swap)

## Protezione del bootloader GRUB2

Perché proteggere il bootloader con una password?

1. Prevenire l'accesso in *Single user mode* - Se un utente malintenzionato può avviare in single user mode, diventa l'utente root.
2. Impedire l'accesso alla console di GRUB - Se un utente malintenzionato riesce a utilizzare la console GRUB, potrebbe modificare la sua configurazione o raccogliere informazioni di sistema con il comando `cat`.
3. Impedire l'accesso ai sistemi operativi insicuri. Se il sistema è configurato con dual boot, un utente malintenzionato putrebbe selezionare un sistema operativo come DOS che in fase di boot ignora controlli d'accesso e autorizzazioni dei file.

Per proteggere con password il bootloader GRUB2:

1. Accedere al sistema operativo come utente root ed eseguire il comando `grub2-mkpasswd-pbkdf2`. L'output del comando è il seguente:

    ```bash
    Enter password:
    Reenter password:
    PBKDF2 hash of your password is grub.pbkdf2.sha512.10000.D0182EDB28164C19454FA94421D1ECD6309F076F1135A2E5BFE91A5088BD9EC87687FE14794BE7194F67EA39A8565E868A41C639572F6156900C81C08C1E8413.40F6981C22F1F81B32E45EC915F2AB6E2635D9A62C0BA67105A9B900D9F365860E84F1B92B2EF3AA0F83CECC68E13BA9F4174922877910F026DED961F6592BB7
    ```

    È necessario inserire la password. Il ciphertext della password è la long string “grub.pbkdf2.sha512...”.

2. Incollare il ciphertext della password nell'ultima riga del file <strong x-id=“1”>/etc/grub.d/00_header</strong>. Il formato del testo incollato è il seguente:

    ```bash
    cat <<EOF
    set superusers='frank'
    password_obkdf2 frank grub.pbkdf2.sha512.10000.D0182EDB28164C19454FA94421D1ECD6309F076F1135A2E5BFE91A5088BD9EC87687FE14794BE7194F67EA39A8565E868A41C639572F6156900C81C08C1E8413.40F6981C22F1F81B32E45EC915F2AB6E2635D9A62C0BA67105A9B900D9F365860E84F1B92B2EF3AA0F83CECC68E13BA9F4174922877910F026DED961F6592BB7
    EOF
    ```

    È possibile sostituire l'utente 'frank' con un qualsiasi utente.

    È anche possibile impostare una password in chiaro, ad esempio:

    ```bash
    cat <<EOF
    set superusers='frank'
    password frank rockylinux8.x
    EOF
    ```

3. Il passo finale consiste nell'eseguire il comando `grub2-mkconfig -o /boot/grub2/grub.cfg` per aggiornare le impostazioni di GRUB2.

4. Riavviare il sistema operativo per verificare la crittografia di GRUB2. Selezionare la prima voce del menu di avvio, digitare il tasto ++"e"++, quindi inserire l'utente e la password corrispondenti.

    ```bash
    Enter username:
    frank
    Enter password:

    ```

    Dopo l'esito positivo della verifica, digitare ++ctrl+"x"++ per avviare il sistema operativo.

A volte, in alcuni documenti, si può notare che il comando `grub2-set-password` (`grub2-setpassword`) viene usato per proteggere il bootloader di GRUB2:

| comando                 | Funzione di base                              | Metodo per modificare il file di configurazione | automatismo |
| ----------------------- | --------------------------------------------- | ----------------------------------------------- | ----------- |
| `grub2-set-password`    | Imposta password e aggiorna la configurazione | Completamento automatico                        | Elevato     |
| `grub2-mkpasswd-pbkdf2` | Genera solo valori hash encrypted             | Richiede intervento manuale                     | basso       |

Accedere al sistema operativo come utente root ed eseguire il comando `gurb2-set-password` come segue:

```bash
# grub2-setpassword
```

Dopo l'esecuzione del comando `grub2-set-password`, il file **/boot/grub2/user.cfg** verrà generato automaticamente.

Selezionare la prima voce del menu di avvio e digitare il tasto ++"e"++ , quindi inserire l'utente e la password corrispondenti:

```bash
Questo comando supporta solo le configurazioni con un singolo utente root.

```

## Systemd

*Systemd* è un gestore di servizi per i sistemi operativi Linux.

È sviluppato per:

* rimanere compatibile con gli script di inizializzazione del vecchio SysV,
* fornire molte funzionalità, come l'avvio parallelo dei servizi di sistema all'avvio del sistema, l'attivazione su richiesta dei demoni, il supporto per le istantanee o la gestione delle dipendenze tra i servizi.

!!! Note "Nota"

    Systemd è il sistema di inizializzazione predefinito da RedHat/CentOS 7.

Systemd introduce il concetto di file di unità, noti anche come unità di systemd.

| Tipo                  | Estensione del file | Funzionalità                                        |
| --------------------- | ------------------- | --------------------------------------------------- |
| Unità di servizio     | `.service`          | Servizio di sistema                                 |
| Unità di destinazione | `.target`           | Un gruppo di unità systemd                          |
| Mount unit            | `.automount`        | Un punto di montaggio automatico per il file system |

!!! Note "Nota"

    Ci sono molti tipi di unità: Device unit, Mount unit, Path unit, Scope unit, Slice unit, Snapshot unit, Socket unit, Swap unit, Timer unit.

* `Systemd` supporta le istantanee dello stato del sistema e il ripristino.

* Mount points possono essere configurati come target di `systemd`.

* All'avvio, `systemd` crea socket di ascolto per tutti i servizi di sistema che supportano questo tipo di attivazione e passa questi socket ai relativi servizi non appena vengono avviati. Ciò consente di riavviare un servizio senza perdere un singolo messaggio inviato dalla rete durante la sua indisponibilità. Il socket corrispondente rimane accessibile e tutti i messaggi vengono accodati.

* I servizi di sistema che utilizzano D-BUS per le comunicazioni tra processi possono essere avviati su richiesta la prima volta che vengono utilizzati da un client.

* `Systemd` arresta o riavvia solo i servizi in esecuzione. Le versioni precedenti (prima di RHEL7) tentavano di arrestare direttamente i servizi senza controllarne lo stato corrente.

* I servizi di sistema non ereditano alcun contesto (come le variabili di ambiente HOME e PATH). Ogni servizio opera nel proprio contesto di esecuzione.

Tutte le operazioni delle unità di servizio sono soggette a un timeout predefinito di 5 minuti per evitare che un servizio malfunzionante blocchi il sistema.

Per motivi di spazio, questo documento non fornirà un'introduzione dettagliata a `systemd`. Se si è interessati a esplorare ulteriormente `systemd` , c'è un'introduzione molto dettagliata in <a href=“./16-about-sytemd.md”>questo documento</a>.

### Gestione dei servizi di sistema

Le unità di servizio terminano con l'estensione di file `.service` e hanno uno scopo simile a quello degli script di init. Il comando `systemctl` viene utilizzato per `visualizzare`, `avviare`, `fermare`, `riavviare` un servizio di sistema: A parte in rari casi, la riga di comando `systemctl` lavora generalmente su una o piu' unita' (non si limita solo al tipo di unità “.service”.). È possibile visionarlo attraverso il sistema help.

| systemctl                                 | Descrizione                                   |
| ----------------------------------------- | --------------------------------------------- |
| systemctl start *name*.service            | Avviare un servizio                           |
| systemctl stop *name*.service             | Arrestare un servizio                         |
| systemctl restart *name*.service          | Riavviare un servizio                         |
| systemctl reload *name*.service           | Ricaricare una configurazione                 |
| systemctl status *name*.service           | Controllare se un servizio è in esecuzione    |
| systemctl try-restart *name*.service      | Riavviare un servizio solo se è in esecuzione |
| systemctl list-units --type service --all | Visualizzare lo stato di tutti i servizi      |

Il comando `systemctl` viene utilizzato anche per `enable` o `disable` un servizio di sistema e la visualizzazione dei servizi associati:

| systemctl                                | Descrizione                                                    |
| ---------------------------------------- | -------------------------------------------------------------- |
| systemctl enable *name*.service          | Attivare un servizio                                           |
| systemctl disable *name*.service         | Disabilitare un servizio                                       |
| systemctl list-unit-files --type service | Elencare tutti i servizi e i controlli se sono in esecuzione   |
| systemctl list-dependencies --after      | Elencare i servizi che si avviano prima dell'unità specificata |
| systemctl list-dependencies --before     | Elencare i servizi che si avviano dopo l'unità specificata     |

Esempi:

```bash
systemctl stop nfs-server.service
# or
systemctl stop nfs-server
```

Per elencare tutte le unità attualmente caricate:

```bash
systemctl list-units --type service
```

Per elencare tutte le unità e per verificare se sono attivate:

```bash
systemctl list-unit-files --type service
```

```bash
systemctl enable httpd.service
systemctl disable bluetooth.service
```

### Esempio di un file .service per il servizio postfix

```bash
postfix.service Unit File
What follows is the content of the /usr/lib/systemd/system/postfix.service unit file as currently provided by the postfix package:

[Unit]
Description=Postfix Mail Transport Agent
After=syslog.target network.target
Conflicts=sendmail.service exim.service

[Service]
Type=forking
PIDFile=/var/spool/postfix/pid/master.pid
EnvironmentFile=-/etc/sysconfig/network
ExecStartPre=-/usr/libexec/postfix/aliasesdb
ExecStartPre=-/usr/libexec/postfix/chroot-update
ExecStart=/usr/sbin/postfix start
ExecReload=/usr/sbin/postfix reload
ExecStop=/usr/sbin/postfix stop

[Install]
WantedBy=multi-user.target
```

### Utilizzo degli obiettivi di sistema

I target `di systemd` sostituiscono il concetto di livelli di esecuzione su SysV o Upstart.

La rappresentazione dei target di `systemd` è per unità di destinazione. Le unità di destinazione terminano con l'estenzione `.target` e il loro unico scopo è di raggruppare altre unità `systemd` in una catena di dipendenze.

Ad esempio, l'unità `graphical.target` che avvia una sessione grafica avvia servizi di sistema come il **display manager di GNOME** (`gdm.service`) o il **servizio account** (`accounts-daemon.service`) e attiva anche l'unità `multi-user.target.`. Per visualizzare le dipendenze di un determinato "target", eseguire il comando `systemctl list-dependencies`. (Ad esempio, `systemctl list-dependencies multi-user.target`).

`sysinit.target` e `basic.target` sono punti di controllo durante il processo di avvio. Sebbene uno degli obiettivi di `systemd` sia quello di avviare i servizi di sistema in parallelo, è necessario avviare i "target" di alcuni servizi e funzionalità prima di avviare altri servizi e "target". Qualsiasi errore in `sysinit.target` o in `basic target` farà fallire l'inizializzazione di `systemd`. In questo momento, il terminale potrebbe essere entrato in "modalità di emergenza"`(emergency.target`).

| Unità di destinazione. | Descrizione                                             |
| ---------------------- | ------------------------------------------------------- |
| poweroff.target        | Chiude il sistema e lo spegne                           |
| rescue.target          | Attiva una shell di salvataggio                         |
| multi-user.target      | Attiva un sistema multiutente senza interfaccia grafica |
| graphical.target       | Attiva un sistema multiutente con interfaccia grafica   |
| reboot.target          | Spegne e riavvia il sistema                             |

#### La destinazione predefinita

Per determinare quale obiettivo viene utilizzato per impostazione predefinita:

```bash
systemctl get-default
```

Questo comando cerca l'obiettivo del collegamento simbolico situato in `/etc/systemd/system/default.target` e visualizza il risultato.

```bash
$ systemctl get-default
graphical.target
```

Il comando `systemctl` può anche fornire un elenco di obiettivi disponibili:

```bash
systemctl list-units --type target
UNIT                   LOAD   ACTIVE SUB    DESCRIPTION
basic.target           loaded active active Basic System
bluetooth.target       loaded active active Bluetooth
cryptsetup.target      loaded active active Encrypted Volumes
getty.target           loaded active active Login Prompts
graphical.target       loaded active active Graphical Interface
local-fs-pre.target    loaded active active Local File Systems (Pre)
local-fs.target        loaded active active Local File Systems
multi-user.target      loaded active active Multi-User System
network-online.target  loaded active active Network is Online
network.target         loaded active active Network
nss-user-lookup.target loaded active active User and Group Name Lookups
paths.target           loaded active active Paths
remote-fs.target       loaded active active Remote File Systems
slices.target          loaded active active Slices
sockets.target         loaded active active Sockets
sound.target           loaded active active Sound Card
swap.target            loaded active active Swap
sysinit.target         loaded active active System Initialization
timers.target          loaded active active Timers
```

Per configurare il sistema all'utilizzo di un diverso target predefinito:

```bash
systemctl set-default name.target
```

Esempio:

```bash
# systemctl set-default multi-user.target
rm '/etc/systemd/system/default.target'
ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
```

Per passare a un'unità di destinazione diversa nella sessione corrente:

```bash
systemctl isolate name.target
```

La **Modalità di ripristino** fornisce un ambiente semplice per riparare il sistema nei casi in cui è impossibile eseguire un normale processo di avvio.

In `rescue mode`, il sistema tenta di montare tutti i file system locali e di avviare diversi servizi di sistema importanti, ma non abilita un'interfaccia di rete né consente ad altri utenti di connettersi al sistema contemporaneamente.

Su Rocky 8, la `rescue mode` è equivalente al vecchio `single user mode` e richiede la password di root.

Per modificare la destinazione corrente immettere `rescue mode` nella sessione corrente:

```bash
systemctl rescue
```

**Modalità di emergenza** fornisce l'ambiente più minimalista possibile e consente di riparare il sistema anche in situazioni in cui il sistema non è in grado di inserire la modalità di salvataggio. In modalità di emergenza, il sistema operativo monta il file system root con l'opzione di sola lettura. Non tenterà di montare qualsiasi altro file system locale, non attiverà alcuna interfaccia di rete e inizializzerà alcuni servizi essenziali.

Per modificare il target corrente e immettere la modalità di emergenza nella sessione corrente:

```bash
systemctl emergency
```

#### Arresto, sospensione e ibernazione

Il comando `systemctl` sostituisce alcuni dei comandi di gestione dell'alimentazione utilizzati nelle versioni precedenti:

| Vecchio comando     | Nuovo comando            | Descrizione                        |
| ------------------- | ------------------------ | ---------------------------------- |
| `halt`              | `systemctl halt`         | Spegne il sistema.                 |
| `poweroff`          | `systemctl poweroff`     | Arresta elettricamente il sistema. |
| `reboot`            | `systemctl reboot`       | Riavvia il sistema.                |
| `pm-suspend`        | `systemctl suspend`      | Sospende il sistema.               |
| `pm-hibernate`      | `systemctl hibernate`    | Iberna il sistema.                 |
| `pm-suspend-hybrid` | `systemctl hybrid-sleep` | Iberna e sospende il sistema.      |

### Il processo `journald`

I file di registro possono, oltre a `rsyslogd`, essere gestiti anche dal demone `journald` che è un componente di `systemd`.

Il demone `journald` è responsabile dell'acquisizione dei seguenti tipi di messaggi di log:

* Messaggi Syslog
* Messaggi di log del kernel
* Initramfs e i registri di avvio del sistema
* Informazioni sull'uscita standard (stdout) e sull'uscita standard di errore (stderr) di tutti i servizi

Dopo l'acquisizione, `journald` indicizzerà questi registri e li fornirà agli utenti attraverso un meccanismo di archiviazione strutturato Questo meccanismo archivia i registri in formato binario, supporta il tracciamento degli eventi in ordine cronologico e fornisce funzionalità flessibili di filtraggio, ricerca e output in diversi formati (come testo/JSON).

### comando `journalctl`

Il comando `journalctl` viene utilizzato per elaborare i registri, ad esempio per visualizzare i file di registro, filtrare i registri e controllare le voci di output.

```bash
journalctl
```

Il comando elenca tutti i file di registro generati sul sistema. La struttura di questo output è simile a quella utilizzata in `/var/log/messages/` ma offre alcuni miglioramenti:

* mostra che la priorità delle voci è segnalata visivamente
* mostra la conversione dei timestamp nel fuso orario locale del sistema
* vengono visualizzati tutti i dati registrati, compresi i registri a rotazione
* l'inizio di un avvio è contrassegnato da una linea speciale.

#### Uso del display continuo

Con il display continuo, i messaggi di registro vengono visualizzati in tempo reale.

```bash
journalctl -f
```

Questo comando restituisce un elenco delle dieci linee di registro più recenti. L'utilità continua quindi a funzionare e attende che avvengano nuove modifiche per visualizzarle immediatamente.

#### Filtrare i Messaggi

È possibile utilizzare diversi metodi di filtraggio per estrarre informazioni che si adattano a diverse esigenze. I messaggi di registro vengono spesso utilizzati per monitorare il comportamento errato del sistema. Per visualizzare le voci con una priorità selezionata o superiore:

```bash
journalctl -p priority
```

È necessario sostituire la priorità con una delle seguenti parole chiave (o un numero):

* debug (7),
* info (6),
* notice (5),
* warning (4),
* err (3),
* crit (2),
* alert (1),
* and emerg (0).
