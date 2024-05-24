---
title: Informazioni su systemd
author: tianci li
contributors: Spencer Steven
tags:
  - init software
  - systemd
  - Upstart
  - System V
---

# Panoramica di base

**`systemd`**, noto anche come **daemon di sistema**, è un software di inizializzazione del sistema operativo GNU/Linux.

Obiettivo dello sviluppo:

- per fornire un quadro migliore di rappresentazione delle dipendenze tra i servizi
- implementare l'avvio parallelo dei servizi all'inizializzazione del sistema
- ridurre il carico di lavoro della shell e sostituire l'init in stile SysV

**`systemd`** fornisce una serie di componenti di sistema per il sistema operativo GNU/Linux per unificare la configurazione e il comportamento dei servizi tra le varie distribuzioni GNU/Linux ed eliminare le differenze nel loro utilizzo.

Dal 2015, la maggior parte delle distribuzioni GNU/Linux ha adottato `systemd` per sostituire i programmi di inizializzazione tradizionali come SysV. Vale la pena notare che molti dei concetti e del design di \`systemd' sono ispirati a **launchd** di Apple Mac OS.

![init-compare](./images/16-init-compare.jpg)

La comparsa di `systemd` ha causato un'enorme controversia nella comunità open source.

Voci di elogio:

- Sviluppatori e utenti hanno lodato `systemd` per aver eliminato le differenze d'uso tra GNU/Linux e per aver fornito una soluzione più stabile e veloce.

Voci critiche:

- `systemd` si occupa di troppi componenti del sistema operativo, violando il principio KISS (**K**eep **I**t **S**imple, **S**tupid) di UNIX.
- Dal punto di vista del codice, `systemd` è troppo complesso e ingombrante, con oltre un milione di righe di codice, riducendo così la manutenibilità e aumentando la possibilità di attacco.

Sito ufficiale - [https://systemd.io/](https://systemd.io/)\
Il repository GitHub - [https://github.com/systemd/systemd](https://github.com/systemd/systemd)

## Storia dello sviluppo

Nel 2010, due ingegneri software di Red Hat, Lennart Poettering e Kay Sievers, hanno sviluppato la prima versione di `systemd` per sostituire il tradizionale SysV.

![Lennart Poettering](./images/16-Lennart-Poettering.jpg)

![Kay Sievers](./images/16-Kay-Sievers.jpg)

Nel maggio 2011, Fedora 15 è stata la prima distribuzione GNU/Linux ad abilitare `systemd` per impostazione predefinita, con la motivazione fornita all'epoca:

> systemd fornisce capacità di parallelizzazione aggressive, utilizza l'attivazione di socket e D-Bus per l'avvio dei servizi, offre l'avvio on-demand dei demoni, tiene traccia dei processi utilizzando i cgroup di Linux, supporta lo snapshotting e il ripristino dello stato del sistema, mantiene i punti di mount e automount e implementa una potente logica di controllo dei servizi basata sulle dipendenze transazionali. Può funzionare come sostituto di sysvinit.

Nell'ottobre 2012, Arch Linux è stato avviato con `systemd` per impostazione predefinita.

Da ottobre 2013 a febbraio 2014, il Comitato Tecnico Debian ha discusso a lungo sulla mailing list Debian, concentrandosi su "quale init dovrebbe essere usato da Debian 8 Jessie come sistema predefinito" e alla fine ha deciso di usare `systemd`.

Nel febbraio 2014, Ubuntu ha adottato `systemd` come init e ha abbandonato il proprio Upstart.

Nell'agosto 2015, `systemd` ha iniziato a fornire shell di login richiamabili tramite `machinectl`.

Nel 2016, `systemd` ha scoperto una vulnerabilità di sicurezza che consente a qualsiasi utente non privilegiato di eseguire un "denial of service attack" su `systemd`.

Nel 2017, `systemd` ha scoperto un'altra vulnerabilità di sicurezza - **CVE-2017-9445**. Gli aggressori remoti possono attivare una vulnerabilità di overflow del buffer ed eseguire codice dannoso attraverso risposte DNS malevole.

!!! info "Informazione"

```
**Buffer overflow**: È un difetto di progettazione del programma che scrive nel buffer di input di un programma fino a farlo esaurire (di solito più dati della quantità massima di dati che possono essere memorizzati nel buffer), interrompendo così il funzionamento del programma, sfruttando l'occasione dell'interruzione per ottenere il controllo del programma o addirittura del sistema.
```

## Progettazione dell'architettura

In questo caso, l'autore ha scelto come esempio di `systemd` quello usato da Tizen di Samsung per illustrare la sua architettura.

![Tizen-systemd](./images/16-tizen-systemd.png)

!!! info "Informazione"

```
**Tizen** - Sistema operativo mobile basato sul kernel Linux, supportato dalla Linux Foundation, sviluppato e utilizzato principalmente da Samsung.
```

!!! info "Informazione"

```
Alcuni "target" di `systemd` non appartengono ai componenti di `systemd`, come `telephony`, `bootmode`, `dlog`, `tizen service`, ma appartengono a Tizen.
```

`systemd` utilizza un design modulare. In fase di compilazione esistono molte opzioni di configurazione che determinano cosa verrà costruito o meno, in modo simile alla struttura modulare del kernel Linux. Una volta compilato, `systemd` può avere fino a 69 eseguibili binari che eseguono i seguenti compiti, inclusi:

- `systemd` viene eseguito con PID 1 e provvede all'avvio del maggior numero possibile di servizi in parallelo. Questo gestisce anche la sequenza di arresto.
- Il programma `systemctl` fornisce un'interfaccia utente per la gestione dei servizi.
- Per garantire la compatibilità, viene fornito anche il supporto per gli script SysV e LSB.
- Rispetto a SysV, la gestione dei servizi e la reportistica di `systemd` possono fornire informazioni più dettagliate.
- Montando e smontando i file system a strati, `systemd` può montare i file system a cascata in modo più sicuro.
- `systemd` fornisce la gestione della configurazione di base dei componenti, tra cui il nome dell'host, la data e l'ora, il locale, il registro e così via.
- Fornisce la gestione dei socket.
- I timer di `systemd` forniscono funzioni simili alle attività programmate di cron.
- Supporto per la creazione e la gestione dei file temporanei, compresa l'eliminazione.
- L'interfaccia D-Bus consente di eseguire script quando un dispositivo viene inserito o rimosso. In questo modo, tutti i dispositivi, collegabili o meno, possono essere considerati come dispositivi plug-and-play, semplificando notevolmente la gestione dei dispositivi.
- Lo strumento di analisi della sequenza di avvio può essere utilizzato per individuare il servizio che richiede più tempo.
- La gestione dei log e dei log di servizio.

**`systemd` non è solo un programma di inizializzazione, ma una vasta suite di software che si occupa di molti componenti del sistema.**

## `systemd` come PID 1

Il mount di `systemd` viene determinato utilizzando il contenuto del file **/etc/fstab**, includendo la partizione di swap.

La configurazione predefinita del "target" è determinata da **/etc/systemd/system/default.target**.

In precedenza, con l'inizializzazione di SysV, esisteva il concetto di **runlevel**. Con `systemd`, c'è anche una tabella di confronto di compatibilità come mostrato di seguito (Elenco in ordine decrescente per numero di dipendenze):

| systemd targets                   | SystemV runlevel | target alias (soft link) | descrizione                                                                                                                                                                                                                                                                                                                                                                                                         |
| :-------------------------------- | :--------------- | :------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| default.target    |                  |                                             | Questo "target" è sempre un collegamento soft a "multi-user.target" o "graphical.target". `systemd` usa sempre "default.target" per avviare il sistema. Attenzione prego! Non può essere un collegamento soft a "halt.target", "poweroff.target" o "reboot.target". |
| graphical.target  | 5                | runlevel5.target            | Ambiente GUI.                                                                                                                                                                                                                                                                                                                                                                                       |
|                                   | 4                | runlevel4.target            | Riservato e non utilizzato. Nel programma di inizializzazione di SysV, il runlevel4 è uguale al runlevel3. Nel programma di inizializzazione `systemd`, gli utenti possono creare e personalizzare questo "target" per avviare i servizi locali senza modificare il "multi-user.target" predefinito.                                                |
| multi-user.target | 3                | runlevel3.target            | Modalità completa multiutente da riga di comando.                                                                                                                                                                                                                                                                                                                                                   |
|                                   | 2                |                                             | In SystemV, si riferisce alla modalità multiutente a riga di comando che non include il servizio NFS.                                                                                                                                                                                                                                                                                               |
| rescue.target     | 1                | runlevel1.target            | In SystemV è chiamata **single-user mode**, una modalità che avvia i servizi minimi e non avvia altri programmi o driver aggiuntivi. Viene utilizzato principalmente per riparare il sistema operativo. È simile alla modalità di sicurezza del sistema operativo Windows.                                                                                          |
| emergency.target  |                  |                                             | Sostanzialmente equivalente a "rescue.target".                                                                                                                                                                                                                                                                                                                                      |
| reboot.target     | 6                | runlevel6.target            | riavvio.                                                                                                                                                                                                                                                                                                                                                                                            |
| poweroff.target   | 0                | runlevel0.target            | Arrestare il sistema operativo e spegnerlo.                                                                                                                                                                                                                                                                                                                                                         |

```bash
Shell > find  / -iname  runlevel?\.target -a -type l -exec ls -l {} \;
lrwxrwxrwx 1 root root 17 8月  23 03:05 /usr/lib/systemd/system/runlevel4.target -> multi-user.target
lrwxrwxrwx 1 root root 17 8月  23 03:05 /usr/lib/systemd/system/runlevel3.target -> multi-user.target
lrwxrwxrwx 1 root root 13 8月  23 03:05 /usr/lib/systemd/system/runlevel6.target -> reboot.target
lrwxrwxrwx 1 root root 13 8月  23 03:05 /usr/lib/systemd/system/runlevel1.target -> rescue.target
lrwxrwxrwx 1 root root 16 8月  23 03:05 /usr/lib/systemd/system/runlevel5.target -> graphical.target
lrwxrwxrwx 1 root root 15 8月  23 03:05 /usr/lib/systemd/system/runlevel0.target -> poweroff.target
lrwxrwxrwx 1 root root 17 8月  23 03:05 /usr/lib/systemd/system/runlevel2.target -> multi-user.target

Shell > ls -l /etc/systemd/system/default.target
lrwxrwxrwx. 1 root root 41 12月 23 2022 /etc/systemd/system/default.target -> /usr/lib/systemd/system/multi-user.target
```

Ogni "target" ha un insieme di dipendenze descritte nel suo file di configurazione, che sono i servizi necessari per eseguire l'host GNU/Linux a uno specifico livello di esecuzione. Più funzioni si hanno, più dipendenze richiede il "target". Ad esempio, l'ambiente GUI richiede più servizi rispetto alla modalità a riga di comando.

Dalla pagina man (`man 7 bootup`), possiamo consultare il diagramma di avvio di `systemd`:

```text
 local-fs-pre.target
                    |
                    v
           (various mounts and   (various swap   (various cryptsetup
            fsck services...)     devices...)        devices...)       (various low-level   (various low-level
                    |                  |                  |             services: udevd,     API VFS mounts:
                    v                  v                  v             tmpfiles, random     mqueue, configfs,
             local-fs.target      swap.target     cryptsetup.target    seed, sysctl, ...)      debugfs, ...)
                    |                  |                  |                    |                    |
                    \__________________|_________________ | ___________________|____________________/
                                                         \|/
                                                          v
                                                   sysinit.target
                                                          |
                     ____________________________________/|\________________________________________
                    /                  |                  |                    |                    \
                    |                  |                  |                    |                    |
                    v                  v                  |                    v                    v
                (various           (various               |                (various          rescue.service
               timers...)          paths...)              |               sockets...)               |
                    |                  |                  |                    |                    v
                    v                  v                  |                    v              rescue.target
              timers.target      paths.target             |             sockets.target
                    |                  |                  |                    |
                    v                  \_________________ | ___________________/
                                                         \|/
                                                          v
                                                    basic.target
                                                          |
                     ____________________________________/|                                 emergency.service
                    /                  |                  |                                         |
                    |                  |                  |                                         v
                    v                  v                  v                                 emergency.target
                display-        (various system    (various system
            manager.service         services           services)
                    |             required for            |
                    |            graphical UIs)           v
                    |                  |           multi-user.target
                    |                  |                  |
                    \_________________ | _________________/
                                      \|/
                                       v
                             graphical.target
```

- "sysinit.target" e "basic.target" sono punti di controllo durante il processo di avvio. Sebbene uno degli obiettivi di `systemd` sia quello di avviare i servizi di sistema in parallelo, è necessario avviare i "target" di alcuni servizi e funzionalità prima di avviare altri servizi e "target"
- Una volta completate le "units" da cui dipende "sysinit.target", l'avvio passerà alla fase "sysinit.target". Queste "units" possono essere avviate in parallelo, tra cui:
  - Montare il file system
  - Impostare il file di swap
  - Avviare udev
  - Impostare il seme del generatore casuale
  - Avviare i servizi di basso livello
  - Impostare i servizi di crittografia
- "sysinit.target" avvierà tutti i servizi di basso livello e le "units" necessarie per le funzioni essenziali del sistema operativo, che sono necessarie prima di entrare nella fase "basic.target".
- Dopo aver completato la fase "sysinit.target", `systemd` avvia tutte le "units" necessarie per completare il "target" successivo (cioè "basic.target"). Il target offre ulteriori funzioni, tra cui:
  - Impostare i percorsi delle directory per i vari file eseguibili.
  - socket di comunicazione
  - timers
- Infine, viene eseguita l'inizializzazione per il "target" a livello di utente ("multiuser.target" o "graphical.target"). `systemd` deve arrivare a "multi-user.target" prima di accedere a "graphical.target".

È possibile eseguire il seguente comando per visualizzare le dipendenze necessarie per l'avvio completo:

```bash
Shell > systemctl list-dependencies multi-user.target
multi-user.target
● ├─auditd.service
● ├─chronyd.service
● ├─crond.service
● ├─dbus.service
● ├─irqbalance.service
● ├─kdump.service
● ├─NetworkManager.service
● ├─sshd.service
● ├─sssd.service
● ├─systemd-ask-password-wall.path
● ├─systemd-logind.service
● ├─systemd-update-utmp-runlevel.service
● ├─systemd-user-sessions.service
● ├─tuned.service
● ├─basic.target
● │ ├─-.mount
● │ ├─microcode.service
● │ ├─paths.target
● │ ├─slices.target
● │ │ ├─-.slice
● │ │ └─system.slice
● │ ├─sockets.target
● │ │ ├─dbus.socket
● │ │ ├─sssd-kcm.socket
● │ │ ├─systemd-coredump.socket
● │ │ ├─systemd-initctl.socket
● │ │ ├─systemd-journald-dev-log.socket
● │ │ ├─systemd-journald.socket
● │ │ ├─systemd-udevd-control.socket
● │ │ └─systemd-udevd-kernel.socket
● │ ├─sysinit.target
● │ │ ├─dev-hugepages.mount
● │ │ ├─dev-mqueue.mount
● │ │ ├─dracut-shutdown.service
● │ │ ├─import-state.service
● │ │ ├─kmod-static-nodes.service
● │ │ ├─ldconfig.service
● │ │ ├─loadmodules.service
● │ │ ├─nis-domainname.service
● │ │ ├─proc-sys-fs-binfmt_misc.automount
● │ │ ├─selinux-autorelabel-mark.service
● │ │ ├─sys-fs-fuse-connections.mount
● │ │ ├─sys-kernel-config.mount
● │ │ ├─sys-kernel-debug.mount
● │ │ ├─systemd-ask-password-console.path
● │ │ ├─systemd-binfmt.service
● │ │ ├─systemd-firstboot.service
● │ │ ├─systemd-hwdb-update.service
● │ │ ├─systemd-journal-catalog-update.service
● │ │ ├─systemd-journal-flush.service
● │ │ ├─systemd-journald.service
● │ │ ├─systemd-machine-id-commit.service
● │ │ ├─systemd-modules-load.service
● │ │ ├─systemd-random-seed.service
● │ │ ├─systemd-sysctl.service
● │ │ ├─systemd-sysusers.service
● │ │ ├─systemd-tmpfiles-setup-dev.service
● │ │ ├─systemd-tmpfiles-setup.service
● │ │ ├─systemd-udev-trigger.service
● │ │ ├─systemd-udevd.service
● │ │ ├─systemd-update-done.service
● │ │ ├─systemd-update-utmp.service
● │ │ ├─cryptsetup.target
● │ │ ├─local-fs.target
● │ │ │ ├─-.mount
● │ │ │ ├─boot.mount
● │ │ │ ├─systemd-fsck-root.service
● │ │ │ └─systemd-remount-fs.service
● │ │ └─swap.target
● │ │   └─dev-disk-by\x2duuid-76e2324e\x2dccdc\x2d4b75\x2dbc71\x2d64cd0edb2ebc.swap
● │ └─timers.target
● │   ├─dnf-makecache.timer
● │   ├─mlocate-updatedb.timer
● │   ├─systemd-tmpfiles-clean.timer
● │   └─unbound-anchor.timer
● ├─getty.target
● │ └─getty@tty1.service
● └─remote-fs.target
```

Si può anche usare l'opzione `--all` per espandere tutte le "units".

## Usare `systemd`

### Tipi di Unit

Il comando `systemctl` è lo strumento principale per gestire `systemd`, ed è una combinazione dei precedenti comandi `service` e `chkconfig`.

`systemd` gestisce le cosiddette "units", che sono rappresentazioni delle risorse e dei servizi del sistema. L'elenco seguente mostra i tipi di "unit" che `systemd` può gestire:

- **service** - Un servizio del sistema, comprese le istruzioni per l'avvio, il riavvio e l'arresto del servizio. Vedere `man 5 systemd.service`.
- **socket** - Un socket di rete associato a un servizio. Vedere `man 5 systemd.socket`.
- **device** - Un dispositivo gestito specificamente con `systemd`. Vedere `man 5 systemd.device`.
- **mount** - Un punto di montaggio gestito con `systemd`. Vedere `man 5 systemd.mount`.
- **automount** - Un punto di montaggio montato automaticamente all'avvio. Vedere `man 5 systemd.automount`.
- **swap** - Spazio di swap sul sistema. Vedere `man 5 systemd.swap`.
- **target** - Un punto di sincronizzazione per altre units. Di solito si usa per avviare i servizi abilitati all'avvio. Vedere `man 5 systemd.target`.
- **path** - Un percorso per l'attivazione basata sul percorso. Ad esempio, è possibile avviare i servizi in base allo stato di un determinato percorso, ad esempio se esista o meno. Vedere `man 5 systemd.path`.
- **timer** - Un timer per programmare l'attivazione di un'altra unit. Vedere `man 5 systemd.timer`.
- **snapshot** - Un'istantanea dello stato attuale di `systemd`. Di solito si usa per fare il rollback dopo aver apportato modifiche temporanee a `systemd`.
- **slice** - Limitazione delle risorse attraverso i nodi del gruppo di controllo Linux (cgroups). Vedere `man 5 systemd.slice`.
- **scope** - Informazioni dalle interfacce bus di `systemd`. Di solito viene utilizzato per gestire i processi di sistema esterni. Vedere `man 5 systemd.scope`.

### "units" operative

L'uso del comando `systemictl` è - `systemctl [OPZIONI...] COMANDO [UNIT...]`.

Il COMANDO può essere suddiviso in:

- Comandi della Unit
- Comandi del file della Unit
- Comandi macchina
- Comandi di lavoro
- Comandi ambiente
- Comandi del ciclo di vita del gestore
- Comandi di sistema

È possibile utilizzare `systemctl --help` per scoprire i dettagli.

Ecco alcuni comuni comandi operativi dimostrativi:

```bash
# Avviare il servizio
Shell > systemctl start sshd.service

# Arrestare il servizio
Shell > systemctl stop sshd.service

# Ricaricare il servizio
Shell > systemctl reload sshd.service

# Riavviare il servizio
Shell > systemctl restart sshd.service

# Visualizzare lo stato del servizio
Shell > systemctl status sshd.service

# Il servizio si avvia automaticamente dopo l'avvio del sistema
Shell > systemctl enable sshd.service

# Il servizio si arresta automaticamente dopo l'avvio del sistema
Shell > systemctl disable sshd.service

# Controllare se il servizio si avvia automaticamente dopo l'avvio
Shell > systemctl is-enabled sshd.service

# Mascherare una unit
Shell > systemctl mask sshd.service

# Smascherare un'unità
Shell > systemctl unmask sshd.service

# Visualizzare il contenuto dei file della unit
Shell > systemctl cat sshd.service

# Modificare il contenuto del file unit e salvarlo nella cartella /etc/systemd/system/ dopo la modifica
Shell > systemctl edit sshd.service

# Visualizzare le proprietà complete della unit
Shell > systemctl show sshd.service
```

!!! info "Informazione"

```
 È possibile operare su una o più unit in un'unica riga di comando per le operazioni di cui sopra. Le operazioni di cui sopra non sono limitate a ".service".
```

Informazioni sulle "unit":

```bash
# Elenca tutte le unità attualmente in funzione.
Shell > systemctl
## o
Shell > systemctl list-units
## Si può anche aggiungere "--type=TYPE" per il filtraggio del tipo
Shell > systemctl --type=target

# Elenca tutti i file delle unità. Si può anche filtrare usando "--type=TYPE".
Shell > systemctl list-unit-files
```

Informazioni sui "target":

```bash
# Interrogare le informazioni correnti sul "target" ("runlevel")
Shell > systemctl get-default
multi-user.target

# Passare a "target"（"runlevel"）. Per esempio, è necessario passare all'ambiente GUI
Shell > systemctl isolate graphical.target

# Definire il "target" predefinito ("runlevel")
Shell > systemctl set-default graphical.target
```

### Directory importanti

Esistono tre directory principali, disposte in ordine crescente di priorità:

- **/usr/lib/systemd/system/** - File delle unit Systemd distribuiti con i pacchetti RPM installati. Simile alla directory /etc/init.d/ di Centos 6.
- **/run/systemd/system/** - File di unit Systemd creati in fase di esecuzione.
- **/etc/systemd/system/** - File di unit Systemd creati da `systemctl enable` e file di unit aggiunti per estendere un servizio.

### File di configurazione di `systemd`

`man 5 systemd-system.conf`:

> Quando viene eseguito come istanza di sistema, systemd interpreta il file di configurazione "system.conf" e i file nelle directory "system.conf.d"; quando viene eseguito come istanza utente, interpreta il file di configurazione user.conf (o nella home directory dell'utente o, se non viene trovato, in "/etc/systemd/") e i file nelle directory "user.conf.d". Questi file di configurazione contengono alcune impostazioni che controllano le operazioni di base del gestore.

Nel sistema operativo Rocky Linux 8.x, i file di configurazione rilevanti sono:

- **/etc/systemd/system.conf** - Modificare il file per cambiare le impostazioni. L'eliminazione del file ripristina le impostazioni predefinite. Vedere `man 5 systemd-system.conf`
- **/etc/systemd/user.conf** - È possibile sovrascrivere le direttive di questo file creando dei file in "/etc/systemd/user.conf.d/\*.conf". Vedere `man 5 systemd-user.conf`

### Descrizione del contenuto del file delle unit di `systemd`

Prendiamo come esempio il file sshd.service:

```bash
Shell > systemctl cat sshd.service
[Unit]
Description=OpenSSH server daemon
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target sshd-keygen.target
Wants=sshd-keygen.target

[Service]
Type=notify
EnvironmentFile=-/etc/crypto-policies/back-ends/opensshserver.config
EnvironmentFile=-/etc/sysconfig/sshd
ExecStart=/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
```

Come si vede, il contenuto del file dell'unità ha lo stesso stile del file di configurazione della scheda di rete RL 9. Utilizza ++open-bracket++ e ++close-bracket++ per includere il titolo e, sotto il titolo, le coppie chiave-valore pertinenti.

```bash
# RL 9
Shell > cat /etc/NetworkManager/system-connections/ens160.nmconnection
[connection]
id=ens160
uuid=5903ac99-e03f-46a8-8806-0a7a8424497e
type=ethernet
interface-name=ens160
timestamp=1670056998

[ethernet]
mac-address=00:0C:29:47:68:D0

[ipv4]
address1=192.168.100.4/24,192.168.100.1
dns=8.8.8.8;114.114.114.114;
method=manual

[ipv6]
addr-gen-mode=default
method=disabled

[proxy]
```

Di solito esistono tre intitolazioni per le unit di tipo ".service":

- **Unit**
- **Service**
- **Install**

1. Intitolazione della unit

   Sono utilizzabili le seguenti coppie chiave-valore:

   - `Description=OpenSSH server daemon`. La stringa viene utilizzata per descrivere la "unit".
   - `Documentation=man:sshd(8) man:sshd_config(5)`.  Un elenco separato da spazi di URI che fanno riferimento alla documentazione di questa "unit" o della sua configurazione. Sono accettati solo URI del tipo "http://", "https://", "file:", "info:", "man:".
   - `After=network.target sshd-keygen.target`. Definisce la relazione della sequenza di avvio con altre "unit". In questo esempio, "network.target" e "sshd-keygen.target" si avviano per primi e "sshd.service" per ultimo.
   - `Before=`. Definisce la relazione della sequenza di avvio con le altre "unit".
   - `Requires=`. Configura le dipendenze da altre "unit" I valori possono essere più unit separate da spazi. Se la '"unit" corrente è attivata, si attiveranno anche i valori qui elencati. Se almeno uno dei valori elencati di "unit" non si attiva correttamente, `systemd` non avvia la "unit" corrente.
   - `Wants=sshd-keygen.target`. Simile alla chiave `Requires`. La differenza consiste nel fatto che se la unit dipendente non si avvia, ciò non influisce sul normale funzionamento della "unit" corrente.
   - `BindsTo=`. Simile alla chiave `Requires`. La differenza è data dal fatto che se una qualsiasi "unit" dipendente non si avvia, l'unità corrente viene arrestata in aggiunta alla "unit" che arresta la dipendenza.
   - `PartOf=`. Simile alla chiave `Requires`. La differenza consiste nel fatto che se una qualsiasi "unit" dipendente non si avvia, oltre all'arresto e al riavvio delle unit dipendenti, viene arrestata e riavviata anche la "unit" corrente.
   - `Conflicts=`. Il suo valore è un elenco di "unit" separate da spazi. Se la "unit" elencata dal valore è in funzione, la "unit" corrente non può essere eseguita.
   - `OnFailure=`. Quando la "unit" corrente viene interrotta, la "unit" o le "unit" (separate da spazi) presenti nel valore si attivano.

   Per ulteriori informazioni, vedere `man 5 systemd.unit`.

2. Intitolazione del Servizio

   Sono utilizzabili le seguenti coppie chiave-valore:

   - `Type=notify`. Configurare il tipo di unit ".service", che può essere uno dei seguenti:
     - `simple` - Il servizio si avvia come processo principale. Questa è l'impostazione predefinita.
     - `forking` - Il servizio richiama processi biforcati e viene eseguito come parte del daemon principale.
     - `exec` - Simile a `semplice`. Il gestore del servizio avvierà questa unit subito dopo aver eseguito il binario del servizio principale. Le altre unit successive devono rimanere bloccate fino a questo punto prima di poter proseguire l'avvio.
     - `oneshot` - Simile a `simple`, ma il processo deve uscire prima che `systemd` avvii i servizi di follow-up.
     - `dbus` - Simile a `simple`, tranne per il fatto che il daemon acquisisce il nome del bus D-Bus.
     - `notify` - Simile a `simple`, tranne per il fatto che il daemon invia un messaggio di notifica usando `sd_notify` o una chiamata equivalente dopo l'avvio.
     - `idle` - Simile a `simple`, tranne per il fatto che l'esecuzione del servizio viene ritardata fino a quando tutti i lavori attivi non vengono distribuiti.
   - `RemainAfterExit=`. Se il servizio corrente deve essere considerato attivo quando tutti i processi del servizio terminano. L'impostazione predefinita è no.
   - `GuessMainPID=`. Il valore è di tipo booleano ed è predefinito a yes. In assenza di una posizione definita per il processo principale del servizio, `systemd` deve indovinare il PID del processo principale (che potrebbe non essere corretto). Se si imposta `Type=forking` e non si imposta `PIDFile`, questa coppia di valori chiave diventerà effettiva. Altrimenti, verrà ignorata la coppia chiave-valore.
   - `PIDFile=`. Specificare il percorso del file (percorso assoluto) del PID del servizio. Per i servizi `Type=forking`, si raccomanda di usare questa coppia chiave-valore. `systemd` legge il PID del processo principale del daemon dopo l'avvio del servizio.
   - `BusName=`. Un nome del bus D-Bus per raggiungere questo servizio. Questa opzione è obbligatoria per i servizi dove viene utilizzato `Type=dbus`.
   - `ExecStart=/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY`. I comandi e gli argomenti eseguiti all'avvio del servizio.
   - `ExecStartPre=`. Altri comandi che vengono eseguiti prima dei comandi in `ExecStart`.
   - `ExecStartPost=`. Gli altri comandi che verranno eseguiti dopo i comandi in `ExecStart`.
   - `ExecReload=/bin/kill -HUP $MAINPID`. I comandi e gli argomenti vengono eseguiti quando il servizio viene ricaricato.
   - `ExecStop=`. I comandi e gli argomenti che verranno eseguiti all'arresto del servizio.
   - `ExecStopPost=`. Comandi aggiuntivi da eseguire dopo l'arresto del servizio.
   - `RestartSec=42s`. Il tempo in secondi di sospensione prima di riavviare un servizio.
   - `TimeoutStartSec=`. Il tempo in secondi di attesa per l'avvio del servizio.
   - `TimeoutStopSec=`. Il tempo in secondi di attesa per l'arresto del servizio.
   - `TimeoutSec=`. Un'abbreviazione per configurare contemporaneamente `TimeoutStartSec` e `TimeoutStopSec`.
   - `RuntimeMaxSec=`. Tempo massimo in secondi per l'esecuzione del servizio. Passando \`infinity' (il valore predefinito) non si configura alcun limite di tempo di esecuzione.
   - `Restart=on-failure`. Configura se riavviare il servizio quando il processo del servizio esce, viene terminato o raggiunge un timeout:
     - `no` - Il servizio non verrà riavviato. Questa è l'impostazione predefinita.
     - `on-success` - Si riavvia solo quando il processo di servizio esce in modo pulito (codice di uscita 0).
     - `on-failure` - Si riavvia solo quando il processo di servizio non esce in modo pulito (codice di uscita non-zero).
     - `on-abnormal` - Si riavvia se il processo termina con un segnale o quando si verifica un timeout.
     - `on-abort` - Si riavvia se il processo esce a causa di un segnale imprevisto non specificato come condizione di uscita pulita.
     - `on-watchdog` -  Se impostato su `on-watchdog`, il servizio si riavvia solo se il timeout del watchdog scade.
     - `always` - Si riavvia sempre.

   Le condizioni di uscita e l'effetto delle impostazioni di `Restart=` su di esse:

   ![effect](./images/16-effect.png)

   - `KillMode=process`. Specifica il modo in cui i processi di questa unit devono essere arrestati. Il suo valore può essere uno dei seguenti:
     - `control-group` - Valore predefinito. Se impostato su `control-group`, tutti i processi rimanenti nel gruppo di controllo di questa unit vengono arrestati all'arresto della stessa.
     - `process` - Viene arrestato solo il processo principale.
     - `mixed` - Il segnale SIGTERM viene inviato al processo principale, mentre il successivo segnale SIGKILL viene inviato a tutti i processi rimanenti del gruppo di controllo della unit.
     - `none` - Non arresta alcun processo.
   - `PrivateTmp=`. Utilizzare o meno una directory tmp privata. In base a determinate condizioni di sicurezza, si consiglia di impostare il valore su yes.
   - `ProtectHome=`. Proteggere o meno la home directory. Il suo valore può essere uno dei seguenti:
     - `yes` - Le tre directory (/root/, /home/, /run/user/) non sono visibili alla unit.
     - `no` - Le tre directory sono visibili alla unit.
     - `read-only` - Le tre directory sono di sola lettura per la unit.
     - `tmpfs` - Il file system temporaneo verrà montato in modalità di sola lettura su queste tre directory.
   - `ProtectSystem=`. La directory utilizzata per proteggere il sistema dalla modifica da parte del servizio. Il valore può essere:
     - `yes` - Indica che il processo chiamato dalla unit sarà montato in sola lettura sulle directory /usr/ e /boot/.
     - `no` - Valore predefinito
     - `full` - Indica che le directory /usr/, /boot/, /etc/ sono montate in sola lettura.
     - `strict` - Tutti i file system sono montati in sola lettura (escluse le directory dei file system virtuali come /dev/, /proc/ e /sys/).
   - `EnvironmentFile=-/etc/crypto-policies/back-ends/opensshserver.config`. Legge le variabili d'ambiente da un file di testo. "-" significa che se il file non esiste, non verrà letto e non verranno registrati errori o avvisi.

   Per ulteriori informazioni, vedere `man 5 systemd.service`.

3. Intitolazione Install

   - `Alias=`. Un elenco di nomi aggiuntivi separati da spazi. Attenzione prego! Il nome aggiuntivo deve avere lo stesso tipo (suffisso) della unit corrente.

   - `RequiredBy=` o `WantedBy=multi-user.target`. Definisce la unit dell'operazione corrente come dipendenza della unit nel valore. Una volta completata la definizione, i file pertinenti si trovano nella directory /etc/systemd/systemd/. Per esempio:

     ```bash
     Shell > systemctl is-enabled chronyd.service
     enabled

     Shell > systemctl cat chronyd.service
     ...
     [Install]
     WantedBy=multi-user.target

     Shell > ls -l /etc/systemd/system/multi-user.target.wants/
     total 0
     lrwxrwxrwx. 1 root root 38 Sep 25 14:03 auditd.service -> /usr/lib/systemd/system/auditd.service
     lrwxrwxrwx. 1 root root 39 Sep 25 14:03 chronyd.service -> /usr/lib/systemd/system/chronyd.service  ←←
     lrwxrwxrwx. 1 root root 37 Sep 25 14:03 crond.service -> /usr/lib/systemd/system/crond.service
     lrwxrwxrwx. 1 root root 42 Sep 25 14:03 irqbalance.service -> /usr/lib/systemd/system/irqbalance.service
     lrwxrwxrwx. 1 root root 37 Sep 25 14:03 kdump.service -> /usr/lib/systemd/system/kdump.service
     lrwxrwxrwx. 1 root root 46 Sep 25 14:03 NetworkManager.service -> /usr/lib/systemd/system/NetworkManager.service
     lrwxrwxrwx. 1 root root 40 Sep 25 14:03 remote-fs.target -> /usr/lib/systemd/system/remote-fs.target
     lrwxrwxrwx. 1 root root 36 Sep 25 14:03 sshd.service -> /usr/lib/systemd/system/sshd.service
     lrwxrwxrwx. 1 root root 36 Sep 25 14:03 sssd.service -> /usr/lib/systemd/system/sssd.service
     lrwxrwxrwx. 1 root root 37 Sep 25 14:03 tuned.service -> /usr/lib/systemd/system/tuned.service
     ```

   - `Also=`. Altre unit da installare o disinstallare durante l'installazione o la disinstallazione di questa unit.

     Oltre alle pagine di manuale sopra menzionate, è possibile digitare `man 5 systemd.exec` o `man 5 systemd.kill` per accedere ad altre informazioni.

## Comando relativo ad altri componenti

- `timedatactl` - Interroga o modifica le impostazioni di data e ora del sistema.
- `hostnamectl` - Interroga o modifica l'hostname del sistema.
- `localectl` - Interroga o modifica le impostazioni del locale e della tastiera del sistema.
- `systemd-analyze` - Profilo `systemd`, mostra le dipendenze delle unit, controlla i file delle unit.
- `journalctl` - Visualizza i registri di sistema o di servizio. Il comando \`journalctl' è così importante che in seguito verrà dedicata una sezione separata che ne spiegherà l'uso e i comportamenti da tenere.
- `loginctl` - Gestione delle sessioni degli utenti che effettuano il login.
