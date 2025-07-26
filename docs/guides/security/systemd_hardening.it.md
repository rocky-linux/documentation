---
title: Hardening delle unità Systemd
author: Julian Patocki
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - security
  - systemd
  - capabilities
---

## Prerequisiti

- Familiarità con gli strumenti a riga di comando
- Conoscenza di base di `systemd` e dei permessi dei file
- Capacità di leggere le pagine man

## Introduzione

Molti servizi vengono eseguiti con privilegi di cui non hanno bisogno per funzionare correttamente. `systemd` dispone di molti strumenti che aiutano a minimizzare il rischio di compromissione di un processo, applicando misure di sicurezza e limitando i permessi.

## Obiettivi

- Migliorare la sicurezza delle unità di `systemd`

## Dichiarazione di non responsabilità

Questa guida spiega i meccanismi di protezione delle unità `systemd` e non tratta la corretta configurazione di una particolare unità. Alcuni concetti sono eccessivamente semplificati. La comprensione di questi e di alcuni comandi utilizzati richiede un approfondimento dell'argomento.

## Risorse

- [`SYSTEMD.EXEC(5)` man page](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html)
- [`Capabilities(7)` man page](https://man7.org/linux/man-pages/man7/capabilities.7.html)

## Analisi

`systemd` include un ottimo strumento che fornisce una rapida panoramica della configurazione complessiva della sicurezza di un'unità `systemd`.
`systemd-analyze security` fornisce una rapida panoramica della configurazione di sicurezza di un'unità `systemd`. Ecco il punteggio di un `httpd` appena installato:

```bash
[user@rocky-vm ~]$ systemd-analyze security httpd
  NAME                                  DESCRIPTION                                                              EXPOSURE
✗ RootDirectory=/RootImage=             Service runs within the host's root directory                            0.1
  SupplementaryGroups=                  Service runs as root, option does not matter
  RemoveIPC=                            Service runs as root, option does not apply
✗ User=/DynamicUser=                    Service runs as root user                                                0.4
✗ CapabilityBoundingSet=~CAP_SYS_TIME   Service processes may change the system clock                            0.2
✗ NoNewPrivileges=                      Service processes may acquire new privileges                             0.2
...
...
...
✓ NotifyAccess=                         Service child processes cannot alter service state
✓ PrivateMounts=                        Service cannot install system mounts
✗ UMask=                                Files created by service are world-readable by default                   0.1

→ Overall exposure level for httpd.service: 9.2 UNSAFE 😨
```

## Capabilities

Il concetto di capacità può risultare piuttosto confuso. Comprenderlo è fondamentale per migliorare la sicurezza delle unità `systemd`. Ecco un estratto dalla pagina man di `Capabilities(7)`:

```text
Per eseguire i controlli dei permessi, le implementazioni UNIX tradizionali distinguono due categorie di processi: i processi privilegiati (il cui ID utente effettivo è 0, chiamato superuser o root) e i processi non privilegiati (il cui UID effettivo è diverso da zero).  I processi privilegiati bypassano tutti i controlli dei permessi del kernel, mentre i processi non privilegiati sono soggetti a un controllo completo dei permessi basato sulle credenziali del processo (di solito: UID effettivo, GID effettivo ed elenco supplementare dei gruppi).

A partire da Linux 2.2, Linux divide i privilegi tradizionalmente associati al superutente in unità distinte, note come capacità, che possono essere abilitate e disabilitate in modo indipendente. Le capacità sono un attributo per thread.
```

Ciò significa fondamentalmente che le capacità possono concedere alcuni privilegi di `root` a processi non privilegiati, ma anche limitare i privilegi dei processi eseguiti da `root`.

Attualmente sono disponibili 41 funzionalità. Significa che i privilegi dell'utente \`root' hanno 41 serie di privilegi. Ecco qui alcuni esempi:

- **CAP_CHOWN**: Apporta modifiche arbitrarie agli UID e ai GID dei file
- **CAP_KILL**: Bypassa i controlli di autorizzazione per l'invio di segnali
- **CAP_NET_BIND_SERVICE**: Lega un socket alle porte privilegiate del dominio Internet (numeri di porta inferiori a 1024)

La pagina man `Capabilities(7)` contiene l'elenco completo.

Esistono due tipi di capacità:

- Funzionalità dei file
- Funzionalità del thread

## Funzionalità dei file

Le funzionalità dei file consentono di associare privilegi a un eseguibile, in modo simile a `suid`. Includono tre set memorizzati in un attributo esteso: `Permitted`, `Inheritable`, e `Effective`.

Per una spiegazione completa, consultare la pagina man `Capabilities(7)`.

Le capacità dei file non possono influire sul livello di esposizione complessivo di un'unità e sono quindi solo marginalmente rilevanti ai fini della presente guida. Comprenderli, però, può essere utile. Pertanto, una rapida dimostrazione:

Proviamo a eseguire `httpd` sulla porta 80 di default (privilegiata) come utente non privilegiato:

```bash
[user@rocky-vm ~]$ sudo -u apache /usr/sbin/httpd
(13)Permission denied: AH00072: make_sock: could not bind to address 0.0.0.0:80
no listening sockets available, shutting down
```

Come previsto, l'operazione fallisce. Dotiamo il binario `httpd` dei privilegi **CAP_NET_BIND_SERVICE** e **CAP_DAC_OVERRIDE** menzionati in precedenza (per ignorare i controlli dei permessi sui file di log e pid ai fini di questo esercizio) e riproviamo:

```bash
[user@rocky-vm ~]$ sudo setcap "cap_net_bind_service=+ep cap_dac_override=+ep" /usr/sbin/httpd
[user@rocky-vm ~]$ sudo -u apache /usr/sbin/httpd
[user@rocky-vm ~]$ curl --head localhost
HTTP/1.1 403 Forbidden
...
```

Come previsto, il server web è stato avviato con successo.

## Funzionalità del thread

Le funzionalità dei thread si applicano a un processo e ai suoi figli. Sono disponibili cinque set di funzionalità thread:

- Permitted
- Inheritable
- Effective
- Bounding
- Ambient

Per una spiegazione completa, consultare la pagina man di `Capabilities(7)`.

Si è già stabilito che `httpd` non ha bisogno di tutti i privilegi disponibili per l'utente `root`. Rimuoviamo le capacità precedentemente concesse dal binario `httpd`, avviamo il demone `httpd` e controlliamo i suoi privilegi:

```bash
[user@rocky-vm ~]$ sudo setcap -r /usr/sbin/httpd
[user@rocky-vm ~]$ sudo systemctl start httpd
[user@rocky-vm ~]$ grep Cap /proc/$(pgrep --uid 0 httpd)/status
CapInh: 0000000000000000
CapPrm: 000001ffffffffff
CapEff: 000001ffffffffff
CapBnd: 000001ffffffffff
CapAmb: 0000000000000000
[user@rocky-vm ~]$ capsh --decode=000001ffffffffff
0x000001ffffffffff=cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,cap_audit_read,cap_perfmon,cap_bpf,cap_checkpoint_restore
```

Il processo principale `httpd` viene eseguito con tutte le funzionalità disponibili, anche se molte non sono necessarie.

## Limitazione delle capacità

`systemd` riduce gli insiemi di capacità a quanto segue:

- **CapabilityBoundingSet**: limita le capacità acquisite durante `execve`
- **AmbientCapabilities**: utile se si vuole eseguire un processo come utente non privilegiato ma si vuole comunque dargli alcune capacità

Per conservare la configurazione durante gli aggiornamenti dei pacchetti, creare un file `override.conf` all'interno della cartella `/lib/systemd/system/httpd.service.d/`.

Sapendo che il servizio deve accedere a una porta privilegiata e che viene avviato come `root`, ma che i suoi thread vengono forkati come `apache`, è necessario specificare le seguenti capacità nella sezione `[Service]` del file `/lib/systemd/system/httpd.service.d/override.conf`:

```bash
[Service]
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_SETUID CAP_SETGID
```

È possibile ridurre il livello di esposizione complessivo da `UNSAFE` a `MEDIUM`.

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 7.1 MEDIUM 😐
```

Tuttavia, questo processo viene ancora eseguito come `root`. È possibile ridurre ulteriormente il livello di esposizione eseguendolo esclusivamente come `apache`.

Oltre ad accedere alla porta 80, il processo deve scrivere nei log situati in `/etc/httpd/logs/` ed essere in grado di creare `/run/httpd/` e scrivervi. Per ottenere questo risultato, nel primo caso è necessario cambiare i permessi con `chown` e nel secondo utilizzare l'utilità `systemd-tmpfiles`. È possibile utilizzarlo con l'opzione `--create` per creare il file senza riavviare, ma d'ora in poi verrà creato automaticamente a ogni avvio del sistema.

```bash
[user@rocky-vm ~]$ sudo chown -R apache:apache /etc/httpd/logs/
[user@rocky-vm ~]$ echo 'd /run/httpd 0755 apache apache -' | sudo tee /etc/tmpfiles.d/httpd.conf
d /run/httpd 0755 apache apache -
[user@rocky-vm ~]$ sudo systemd-tmpfiles --create /etc/tmpfiles.d/httpd.conf
[user@rocky-vm ~]$ ls -ld /run/httpd/
drwxr-xr-x. 2 apache apache 40 Jun 30 08:29 /run/httpd/
```

È necessario modificare la configurazione in `/lib/systemd/system/httpd.service.d/override.conf`. È necessario assegnare le nuove funzionalità con **AmbientCapabilities**. Se `httpd` è abilitato all'avvio, è necessario espandere le dipendenze nella sezione `[Unit]` affinché il servizio possa avviarsi dopo la creazione del file temporaneo.

```bash
[Unit]
After=systemd-tmpfiles-setup.service

[Service]
User=apache
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
```

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ grep Cap /proc/$(pgrep httpd | head -1)/status
CapInh: 0000000000000400
CapPrm: 0000000000000400
CapEff: 0000000000000400
CapBnd: 0000000000000400
CapAmb: 0000000000000400
[user@rocky-vm ~]$ capsh --decode=0000000000000400
0x0000000000000400=cap_net_bind_service
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 6.5 MEDIUM 😐
```

## Restrizioni del file system

Il controllo dei permessi sui file creati dal processo si effettua impostando la `UMask`.
Il parametro `UMask` modifica i permessi predefiniti dei file eseguendo operazioni bitwise. Questo imposta i permessi predefiniti a `0644` ottale (`-rw-r--r--`) e la `UMask` predefinita è `0022`. Ciò significa che la `UMask` non modifica l'impostazione predefinita:

```bash
[user@rocky-vm ~]$ printf "%o\n" $(echo $(( 00644 &  ~00022 )))
644
```

Assumendo che il set di permessi desiderato per i file creati dal demone sia `0640` (`-rw-r-----`), è possibile impostare la `UMask` a `7137`. Raggiunge l'obiettivo anche se i permessi predefiniti sono impostati su `7777`:

```bash
[user@rocky-vm ~]$ printf "%o\n" $(echo $(( 07777 &  ~07137  )))
640
```

Inoltre:

- `ProtectSystem=`: _"Se impostato su "`strict`", l'intera gerarchia del file system è montata in sola lettura, a eccezione dei sottoalberi del file system API `/dev/`, `/proc/` e `/sys/` (proteggere queste directory usando `PrivateDevices=`, `ProtectKernelTunables=`, `ProtectControlGroups=`)."_
- `ReadWritePaths=`: rende nuovamente scrivibili determinati percorsi
- `ProtectHome=`: rende inaccessibili `/home/`, `/root` e `/run/user`
- `PrivateDevices=`: disattiva l'accesso ai dispositivi fisici, consentendo l'accesso solo a pseudo dispositivi come `/dev/null`, `/dev/zero`, `/dev/random`
- `ProtectKernelTunables=`: rende `/proc/` e `/sys/` di sola lettura
- `ProtectControlGroups=`: rende `cgroups` accessibile in sola lettura
- `ProtectKernelModules=`: nega il caricamento esplicito dei moduli
- `ProtectKernelLogs=`: limita l'accesso al buffer dei log del kernel
- `ProtectProc=`: \*"Se impostato su "invisible", i processi di proprietà di altri utenti vengono nascosti in /proc/"
- `ProcSubset=`: _"Se “pid”, tutti i file e le directory non direttamente associati alla gestione dei processi e all'introspezione vengono resi invisibili nel file system /proc/ configurato per i processi dell'unità."_

È possibile anche limitare i percorsi degli eseguibili. Il demone deve solo eseguire i suoi binari e le sue librerie. L'utilità `ldd` può dirci quali librerie utilizza un binario:

```bash
[user@rocky-vm ~]$ ldd /usr/sbin/httpd
        linux-vdso.so.1 (0x00007ffc0e823000)
        libpcre.so.1 => /lib64/libpcre.so.1 (0x00007fa360d61000)
        libselinux.so.1 => /lib64/libselinux.so.1 (0x00007fa360d34000)
        libaprutil-1.so.0 => /lib64/libaprutil-1.so.0 (0x00007fa360d05000)
        libcrypt.so.2 => /lib64/libcrypt.so.2 (0x00007fa360ccb000)
        libexpat.so.1 => /lib64/libexpat.so.1 (0x00007fa360c9a000)
        libapr-1.so.0 => /lib64/libapr-1.so.0 (0x00007fa360c5a000)
        libc.so.6 => /lib64/libc.so.6 (0x00007fa360a00000)
        libpcre2-8.so.0 => /lib64/libpcre2-8.so.0 (0x00007fa360964000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fa360e70000)
        libuuid.so.1 => /lib64/libuuid.so.1 (0x00007fa360c4e000)
        libm.so.6 => /lib64/libm.so.6 (0x00007fa360889000)
```

Le righe seguenti saranno aggiunte alla sezione `[Service]` del file `override.conf`:

```bash
UMask=7177
ProtectSystem=strict
ReadWritePaths=/run/httpd /etc/httpd/logs

ProtectHome=true
PrivateDevices=true
ProtectKernelTunables=true
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelLogs=true
ProtectProc=invisible
ProcSubset=pid

NoExecPaths=/
ExecPaths=/usr/sbin/httpd /lib64
```

Ricarichiamo la configurazione e verifichiamo l'impatto sul risultato:

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 4.9 OK 🙂
```

## Restrizioni del sistema

Vari parametri possono limitare le operazioni del sistema per migliorare la sicurezza:

- `NoNewPrivileges=`: assicura che il processo non possa ottenere nuovi privilegi attraverso i bit `setuid`, `setgid` e le capacità del filesystem
- `ProtectClock=`: nega la scrittura sugli orologi del sistema e dell'hardware
- `SystemCallArchitectures=`: se impostato su `native`, i processi possono effettuare solo `syscalls` native (nella maggior parte dei casi `x86-64`)
- `RestrictNamespaces=`: gli spazi dei nomi sono per lo più rilevanti per i contenitori, quindi possono essere limitati per questa unità
- `RestrictSUIDSGID=`: impedisce al processo di impostare i bit `setuid` e `setgid` sui file
- `LockPersonality=`: impedisce di modificare il dominio di esecuzione, il che potrebbe essere utile solo per l'esecuzione di applicazioni legacy o di software progettato per altri sistemi Unix-like
- `RestrictRealtime=`: la programmazione in tempo reale è rilevante solo per le applicazioni che richiedono rigorose garanzie di temporizzazione, come i sistemi di controllo industriale, l'elaborazione audio/video e le simulazioni scientifiche
- `RestrictAddressFamilies=`: limita le famiglie di indirizzi socket disponibili; può essere impostato su `AF_(INET|INET6)` per consentire solo i socket IPv4 e IPv6; alcuni servizi avranno bisogno di `AF_UNIX` per la comunicazione interna e la registrazione
- `MemoryDenyWriteExecute=`: assicura che il processo non possa allocare nuove regioni di memoria che siano sia scrivibili che eseguibili, prevenendo alcuni tipi di attacchi in cui il codice dannoso viene iniettato nella memoria scrivibile e poi eseguito; può causare il fallimento dei compilatori JIT utilizzati da JavaScript, Java o .NET
- `ProtectHostname=`: impedisce al processo di utilizzare le chiamate `syscalls` `sethostname()`, `setdomainname()`

Aggiungiamo quanto segue al file `override.conf`, ricarichiamo la configurazione e verifichiamo l'impatto sul risultato:

```bash
NoNewPrivileges=true
ProtectClock=true
SystemCallArchitectures=native
RestrictNamespaces=true
RestrictSUIDSGID=true
LockPersonality=true
RestrictRealtime=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
MemoryDenyWriteExecute=true
ProtectHostname=true
```

```bash
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 3.0 OK 🙂
```

## Filtraggio delle chiamate di sistema

Limitare le chiamate di sistema può non essere facile. È difficile stabilire quali chiamate di sistema debbano essere effettuate da alcuni demoni per funzionare correttamente.

L'utilità `strace` può aiutare a determinare quali syscall vengono create. L'opzione `-f` specifica di seguire i processi biforcati e `-o` salva l'output nel file chiamato `httpd.strace`.

```bash
[user@rocky-vm ~]$ sudo strace -f -o httpd.strace /usr/sbin/httpd
```

Dopo aver eseguito il processo per un po' di tempo e aver interagito con esso, interrompere l'esecuzione per esaminare l'output:

```bash
[user@rocky-vm ~]$ awk '{print $2}' httpd.strace | cut -d '(' -f 1 | sort | uniq | sed '/^[^a-zA-Z0-9]*$/d' | wc -l
79
```

Il programma ha effettuato 79 chiamate univoche di sistema durante la sua esecuzione.
È possibile impostare l'elenco delle chiamate di sistema consentite con il seguente comando:

```bash
[user@rocky-vm ~]$ echo SystemCallFilter=$(awk '{print $2}' httpd.strace | cut -d '(' -f 1 | sort | uniq | sed '/^[^a-zA-Z0-9]*$/d' | tr "\n" " ") | sudo tee -a /lib/systemd/system/httpd.service.d/override.conf
...
...
...
[user@rocky-vm ~]$ sudo systemctl daemon-reload
[user@rocky-vm ~]$ sudo systemctl restart httpd
[user@rocky-vm ~]$ systemd-analyze security --no-pager httpd | grep Overall
→ Overall exposure level for httpd.service: 1.5 OK 🙂
[user@rocky-vm ~]$ curl --head localhost
HTTP/1.1 403 Forbidden
```

Il server web è ancora in funzione e l'esposizione è stata notevolmente ridotta.

L'approccio precedente è esatto. Se una chiamata di sistema è stata omessa, il programma potrebbe bloccarsi. `systemd` raggruppa le chiamate di sistema in insiemi predefiniti. Per facilitare la limitazione delle chiamate di sistema, invece di impostare una singola chiamata di sistema nell'elenco dei permessi o dei non permessi, è possibile impostare un intero gruppo nell'elenco dei permessi o dei non permessi. Per consultare gli elenchi:

```bash
[user@rocky-vm ~]$ systemd-analyze syscall-filter
@default
    # System calls that are always permitted
    arch_prctl
    brk
    cacheflush
    clock_getres
...
...
...
```

Le chiamate di sistema all'interno dei gruppi possono sovrapporsi, soprattutto per alcuni gruppi che includono altri gruppi. Pertanto, singole chiamate o gruppi possono essere disabilitati specificandoli con il simbolo `~`. Le seguenti direttive nel file `override.conf` dovrebbero funzionare per questa unità:

```bash
SystemCallFilter=@system-service
SystemCallFilter=~@privileged @resources @mount @swap @reboot
```

## Conclusioni

La configurazione di sicurezza predefinita della maggior parte delle unità `systemd` è poco rigorosa. L'hardening può richiedere un po' di tempo, ma ne vale la pena, soprattutto negli ambienti più grandi esposti a Internet. Se un aggressore sfrutta una vulnerabilità o una configurazione errata, un'unità protetta può impedirgli di prendere il controllo del sistema.
