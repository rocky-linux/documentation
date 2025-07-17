---
title: Gestione del log
author: tianci li
contributors: Ganna Zhyrnova, Steven Spencer
tags:
  - rsyslog
  - journald
---

## Panoramica di base

In questo capitolo si spiega come gestire i registri nel sistema operativo.

**Q: Che cos'è un registro?**

**Log**：Registra tutti gli eventi e i messaggi che si verificano dall'avvio del sistema operativo, compresi i registri di avvio, i registri di inizializzazione del kernel, i registri di inizializzazione di `systemd` e i registri di avvio o esecuzione delle applicazioni. Il registro è una delle funzioni più importanti del sistema operativo. Gli amministratori possono interrogare i registri per risolvere problemi esistenti o futuri.

In RHEL 8.x e RHEL 9.x, la raccolta dei log è completata principalmente dai due programmi seguenti:

- **rsyslog** - Un programma che raccoglie ed elabora rapidamente i log. È una versione aggiornata di `syslog`. [Questo è il suo sito ufficiale](https://www.rsyslog.com/)
- **journald** - Uno dei componenti di `systemd`

## rsyslog

In Rocky Linux 8.x o 9.x, ci sono vari file di log nella directory **/var/log/**. Impariamo a conoscerli:

- `/var/log/boot.log` - Registra gli eventi che si verificano durante l'avvio del sistema operativo. Il contenuto del file è testo normale.
- `/var/log/btmp` - Registra il log degli errori di accesso. Per visualizzare questo file binario, utilizzare il comando `lastb`.
- `/var/log/cron` - Registra i log relativi alle attività pianificate del sistema. Il contenuto del file è testo normale.
- `/var/log/dmegs` - Registra il log dell'autoverifica del kernel dopo l'avvio. Il contenuto del file è testo normale. È anche possibile utilizzare il comando `dmegs` per visualizzare.
- `/var/log/lastlog` - Registra l'orario dell'ultimo accesso di tutti gli utenti del sistema operativo. Per visualizzare questo binario è necessario utilizzare il comando `lastlog`.
- `/var/log/maillog` - Registra i log relativi alla posta elettronica.
- `/var/log/messages` - Il file di log a livello di sistema registra il cuore del sistema operativo. Il contenuto del file è testo normale. Quando si verificano alcuni errori nel sistema operativo, è necessario innanzitutto visualizzare il file di registro.
- `/var/log/secure` - Registra i log relativi all'identità dell'utente, come il login dell'utente, il passaggio a `su`, l'aggiunta di un nuovo utente, la modifica della password dell'utente e così via.
- `/var/log/wtmp` - Registra gli eventi di login e logout degli utenti e gli eventi di avvio, spegnimento e riavvio del sistema operativo. Per visualizzare questo file binario, utilizzare il comando `last`.

Per i file di testo semplice, il formato è solitamente:

1. Data in cui si è verificato l'evento
2. Su quale macchina si è verificato l'evento
3. Il nome del servizio o del programma che ha generato l'evento.
4. Descrizione e spiegazione specifiche dell'evento
5. Informazioni sull'utente e sul terminale
6. Alcune parole chiave (come error, fail, info, ecc.)

Il formato dei registri per scopi diversi varia notevolmente, pertanto la descrizione del formato sopra riportata non può rappresentare tutti i registri.

Se `rsyslog` non è presente nel sistema operativo, eseguire il seguente comando:

```bash
Shell > dnf install -y rsyslog
```

### File di configurazione

- `/etc/rsyslog.conf` - File di configurazione principale
- `/etc/rsyslog.d/` - Directory di archiviazione dei file di configurazione aggiuntivi

\`/etc/rsyslog.conf' è composto principalmente da diverse parti:

1. Load module
2. Direttive globali
3. Regole - L'autore le illustra in dettaglio.

Dopo decenni di sviluppo, `rsyslog` supporta attualmente tre diversi formati di configurazione:

1. basic (sysklogd) - Questo formato è adatto a rappresentare la configurazione di base in una singola riga.

    ```
    mail.info /var/log/mail.log
    mail.err @@server.example.net
    ```

2. advanced (RainerScript) - Formato di configurazione altamente flessibile e preciso.

    ```
    mail.err action(type="omfwd" protocol="tcp" queue.type="linkedList")
    ```

3. obsolete legacy (legacy) - Questo formato è stato deprecato. Non continuate a usarlo.

#### Regole

Il contenuto predefinito di questa sezione è il seguente:

```
*.info;mail.none;authpriv.none;cron.none                /var/log/messages

authpriv.*                                              /var/log/secure

mail.*                                                  -/var/log/maillog

cron.*                                                  /var/log/cron

*.emerg                                                 :omusrmsg:*

uucp,news.crit                                          /var/log/spooler

local7.*                                                /var/log/boot.log
```

Ogni linea di regole è composta da due parti:

1. campo selettore - Composto da strutture e priorità
2. campo d'azione - Come si desidera gestire questi messaggi di corrispondenza

I campi sono separati tra loro da uno o più spazi.

| Struttura                                                            | Descrizione                                                                                                                                                                                   |
| -------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `auth`                                                               | Registra gli eventi relativi alla sicurezza del sistema, all'autenticazione degli utenti e alla gestione delle autorizzazioni                                                                 |
| `authpriv`                                                           | Registra gli eventi di sicurezza più sensibili (come le operazioni `sudo`). "priv" equivale a privato                                                      |
| `cron`                                                               | Registra gli eventi relativi alle attività pianificate                                                                                                                                        |
| `daemon`                                                             | Registra il log di funzionamento del demone di sistema, che comprende l'avvio del servizio, lo stato di funzionamento e le informazioni sugli errori                                          |
| `ftp`                                                                | Registra i log delle operazioni relative ai servizi FTP (come `vsftpd` e `proftpd`), comprese le informazioni sulla connessione, sul trasferimento dei file e sugli errori |
| `kern`                                                               | Registra il log generato durante l'esecuzione del kernel Linux, coprendo gli eventi principali come i driver hardware, i moduli del kernel e le eccezioni di sistema                          |
| `lpr`                                                                | Registra il log di funzionamento del servizio di stampa, che comprende l'invio delle attività di stampa, la gestione delle code e le informazioni sugli errori                                |
| `mail`                                                               | Registra le informazioni di log dei servizi di posta (come Postfix e Sendmail), compresi l'invio, la ricezione, l'elaborazione delle code e gli eventi di errore           |
| `news`                                                               | Utilizzato raramente                                                                                                                                                                          |
| `security`                                                           | come `auth`                                                                                                                                                                                   |
| `syslog`                                                             | Registra i log generati dal servizio `syslog`                                                                                                                                                 |
| `user`                                                               | Registra le informazioni generate dalle applicazioni dello spazio utente o dagli utenti                                                                                                       |
| `uucp`                                                               | Registra i log delle operazioni relative al protocollo di copia da Unix a Unix (UUCP), compresi il trasferimento di file, l'esecuzione di comandi remoti e altri scenari   |
| `local0`                                                             | Riservato                                                                                                                                                                                     |
| `local1`                                                             | Riservato                                                                                                                                                                                     |
| .... | Riservato                                                                                                                                                                                     |
| `local7`                                                             | Riservato                                                                                                                                                                                     |

`*` rappresenta tutte le strutture. Si possono anche usare `,` e `;` per combinare le strutture in una configurazione a riga singola. `,` rappresenta l'or logico; `;` rappresenta il delimitatore della regola.

```bash
auth,authpriv.*  /var/log/auth.log

# Equivalent to

auth.*   /var/log/auth.log
authpriv.*  /var/log/auth.log
```

```bash
kern.err;mail.alert  /var/log/critical.log
```

| Connettore | Descrizione                                                                                                                                                                                 |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `.`        | Registra i log con una priorità maggiore rispetto alle parole chiave. Per esempio, `cron.info` significa che registrerà in `cron` la cui priorità di log è maggiore di info |
| `.=`       | Registra solo la priorità della parola chiave corrispondente. Ad esempio, `*.=emerg` indica che registrerà i registri con priorità pari a `emerg` in tutte le applicazioni  |
| `.!`       | Significa escluso o non uguale a                                                                                                                                                            |

Le priorità sono ordinate dal basso all'alto:

| Nome      | Descrizione                                                                                                                      |
| --------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `debug`   | Informazioni generali sul debug                                                                                                  |
| `info`    | Informazioni di base sulla notifica                                                                                              |
| `notice`  | Informazioni generali di una certa importanza                                                                                    |
| `warning` | Messaggio di avviso, questo tipo di informazione non può influire sul normale funzionamento del sistema operativo o del servizio |
| `err`     | Messaggi di errore che possono compromettere il normale funzionamento del sistema operativo e dei servizi                        |
| `crit`    | Uno stato critico più grave di "err"                                                                                             |
| `alert`   | Lo stato di allerta è più grave di "crit" e l'amministratore di sistema deve occuparsene immediatamente                          |
| `emerg`   | Uno stato di emergenza in cui il sistema operativo è normalmente inutilizzabile                                                  |

`*` rappresenta tutte le priorità del registro.

Più bassa è la priorità del registro, più dettagliato è il contenuto registrato e più bassa è la gravità. Più alta è la priorità del registro, meno contenuti vengono registrati e più grave è il problema.

"azione" si riferisce a dove salvare o inviare il registro:

- `/var/log/secure` - Salva il log in un file locale
- `@192.168.100.20:22` - Macchina remota
- `:omusrmsg:root,frank,jack` - Specifica l'elenco degli utenti online. `*` rappresenta tutti gli utenti. "omusrmsg" si riferisce al "modulo di uscita per i messaggi dell'utente".
- `/dev/tty12` - Dispositivi terminali specifici
- `-` - Disabilita il meccanismo di buffering durante la scrittura su file

### Rotazione del registro

**Rotazione dei log** - La rotazione dei log risolve i problemi di occupazione dello spazio di archiviazione e di degrado delle prestazioni causati dalla continua crescita dei file di log. Le funzioni specifiche sono:

- **Rotazione** - Archivia automaticamente il file di registro corrente in base a regole specifiche (come il tempo o la dimensione del file) e crea un nuovo file di registro vuoto per la registrazione per evitare che il file di registro sia troppo grande.
- **Compressione** - Comprime i vecchi registri archiviati per risparmiare spazio su disco.
- **Elimina** - Conserva i file di registro pertinenti ed elimina quelli vecchi e scaduti in base alle politiche pertinenti.

Spesso si usa lo strumento `logrotate` per ruotare i log.

Regole di denominazione per i file di registro durante la rotazione:

- Parametro `dateext` - Utilizza la data come suffisso del file per la rotazione dei registri. Ad esempio, durante la prima rotazione dei log, il vecchio file di log "secure" cambierà in "secure-20250424" e `logrotate` creerà un nuovo file "secure"
- Nessun parametro `dateetx` - Utilizza i numeri di rotazione come suffisso del file dopo la rotazione del registro. Ad esempio, quando si verifica la prima rotazione dei registri, il vecchio file di registro "secure" cambia in "secure.1" e `logrotate` crea un nuovo file "secure"

#### /etc/logrotate.conf and /etc/logrotate.d/

```bash
Shell > grep -v -E "^#|^$" /etc/logrotate.conf
weekly
rotate 4
create
dateext
include /etc/logrotate.d

Shell > ls -l /etc/logrotate.d/
-rw-r--r--  1 root root 130 Feb  7  2023 btmp
-rw-r--r--. 1 root root 160 Dec  5  2023 chrony
-rw-r--r--. 1 root root  88 Apr 12  2021 dnf
-rw-r--r--  1 root root  93 Mar 11 17:29 firewalld
-rw-r--r--. 1 root root 162 Apr 16 19:49 kvm_stat
-rw-r--r--  1 root root 289 Dec 18 01:38 sssd
-rw-r--r--  1 root root 226 Nov  5 15:43 syslog
-rw-r--r--  1 root root 145 Feb 19  2018 wtmp
```

**/etc/logrotate.conf** - Profilo globale per la rotazione dei registri. Se le voci di configurazione o i parametri si sovrappongono, prevarranno le voci di configurazione o i parametri letti per ultimi. Ordine di lettura:

1. Leggere il contenuto del file **/etc/logrotate.conf** da cima a fondo
2. File inclusi utilizzando la parola chiave "include"

Le voci o i parametri di configurazione più comuni sono:

| items                           | descrizione                                                                                                                                      |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `daily`                         | Definisce il ciclo di rotazione dei registri in giorni                                                                                           |
| `weekly`                        | Definisce il ciclo di rotazione dei log in settimane                                                                                             |
| `monthly`                       | Definisce il ciclo di rotazione dei log in mesi                                                                                                  |
| `rotate <NUMBER>`               | Il numero di file salvati dopo la rotazione dei registri                                                                                         |
| `compress`                      | La compressione dei vecchi registri avviene dopo la rotazione dei registri                                                                       |
| `create <MODE> <OWNER> <GROUP>` | Dopo la rotazione dei log, definire il proprietario, il gruppo e le autorizzazioni del nuovo file di log                                         |
| `mail <E-MAIL ADDRESS>`         | Dopo la rotazione dei log, inviare il contenuto dell'output via e-mail all'indirizzo di posta elettronica specificato                            |
| `missingok`                     | Se il file di log non esiste, vengono ignorate le informazioni di avviso nel log                                                                 |
| `notifempty`                    | Se il contenuto del file di registro è vuoto, non si verifica alcuna rotazione del registro                                                      |
| `minsize <SIZE>`                | La condizione di dimensione del file per la rotazione dei registri, cioè la rotazione dei registri avviene solo quando soddisfa questa condizion |
| `dateext`                       | Utilizza la data come suffisso del file per la rotazione dei log                                                                                 |

Se si installa il pacchetto software dal repository, il manutentore del pacchetto software definisce la rotazione dei log dell'applicazione e gli utenti di solito non devono modificare le regole di rotazione dei log. Se si installa l'applicazione compilando il codice sorgente, è necessario considerare e configurare manualmente la rotazione dei log.

#### comando \`logrotate

L'uso è `logrotate [OPTION...] <configfile>`

- `-v` - Visualizza il processo di rotazione dei registri
- `-f` - L'applicazione della rotazione dei registri avviene indipendentemente dal fatto che le condizioni per la rotazione dei registri siano soddisfatte o meno

```bash
Shell > logrotate -v /etc/logrotate.conf
reading config file /etc/logrotate.conf
including /etc/logrotate.d
reading config file btmp
reading config file chrony
reading config file dnf
reading config file firewalld
reading config file kvm_stat
reading config file sssd
reading config file syslog
reading config file wtmp
Reading state from file: /var/lib/logrotate/logrotate.status
Allocating hash table for state file, size 64 entries
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state
Creating new state

Handling 8 logs

rotating pattern: /var/log/btmp  monthly (1 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/btmp
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-04 12:08
  log does not need rotating (log has been rotated at 2025-4-4 12:8, that is not month ago yet)

rotating pattern: /var/log/chrony/*.log  weekly (4 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/chrony/*.log
  log /var/log/chrony/*.log does not exist -- skipping
not running postrotate script, since no logs were rotated

rotating pattern: /var/log/hawkey.log  weekly (4 rotations)
empty log files are not rotated, old logs are removed
considering log /var/log/hawkey.log
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)

rotating pattern: /var/log/firewalld  weekly (4 rotations)
empty log files are rotated, only log files >= 1048576 bytes are rotated, old logs are removed
considering log /var/log/firewalld
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-20 13:00
  log does not need rotating ('minsize' directive is used and the log size is smaller than the minsize value)

rotating pattern: /var/log/kvm_stat.csv  10485760 bytes (5 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/kvm_stat.csv
  log /var/log/kvm_stat.csv does not exist -- skipping

rotating pattern: /var/log/sssd/*.log  weekly (2 rotations)
empty log files are not rotated, old logs are removed
considering log /var/log/sssd/sssd_implicit_files.log
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-26 12:42
  log does not need rotating (log is empty)
considering log /var/log/sssd/sssd_kcm.log
  Now: 2025-04-24 12:35
  Last rotated at 2025-02-08 13:49
  log does not need rotating (log is empty)
considering log /var/log/sssd/sssd.log
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-26 12:42
  log does not need rotating (log is empty)
considering log /var/log/sssd/sssd_nss.log
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-26 12:42
  log does not need rotating (log is empty)
not running postrotate script, since no logs were rotated

rotating pattern: /var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
 weekly (4 rotations)
empty log files are rotated, old logs are removed
considering log /var/log/cron
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/maillog
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/messages
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/secure
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
considering log /var/log/spooler
  Now: 2025-04-24 12:35
  Last rotated at 2025-04-19 09:11
  log does not need rotating (log has been rotated at 2025-4-19 9:11, that is not week ago yet)
not running postrotate script, since no logs were rotated

rotating pattern: /var/log/wtmp  monthly (1 rotations)
empty log files are rotated, only log files >= 1048576 bytes are rotated, old logs are removed
considering log /var/log/wtmp
  Now: 2025-04-24 12:35
  Last rotated at 2024-05-20 13:00
  log does not need rotating ('minsize' directive is used and the log size is smaller than the minsize value)
```

## journald

`systemd` è un'applicazione utilizzata per l'inizializzazione e si occupa di molti componenti del sistema. Usare `journald` in `systemd` per rilevare il contenuto del log.

`journald` è il demone di `systemd` che si occupa dei registri. È necessario utilizzare il comando `journalctl` per leggere i log.

Si noti che `journald` non abilita la persistenza dei registri per impostazione predefinita, il che significa che conserva e registra solo tutti i registri dall'avvio. Dopo il riavvio del sistema operativo, si verifica l'eliminazione dei registri storici. Tutti i file di registro salvati temporaneamente si trovano per impostazione predefinita nella directory **/run/log/journal/**.

```bash
Shell > tree -hugp /run/log/journal/638c6d5d2b674f77be56174469099106/
/run/log/journal/638c6d5d2b674f77be56174469099106/
└── [-rw-r----- root     systemd-journal  8.0M]  system.journal

0 directories, 1 file
```

Questo file temporaneo è binario. È necessario utilizzare il comando `journalctl` per analizzarlo.

`journald` può registrare:

- boot log
- kernel log
- application log

`journald` contrassegna i registri in base a **priorità** e **struttura**:

- **priorità** - L'importanza della marcatura dei registri. Come per `rsyslog`, più alta è la priorità, meno informazioni vengono registrate e più grave è il problema. Più bassa è la priorità, più informazioni vengono registrate e più leggero è il problema. Ordinato per priorità, da bassa a alta:

  | Codice numerico | priorità      | parole chiave |
  | :-------------- | :------------ | :------------ |
  | 7               | Debug         | `debug`       |
  | 6               | Informational | `info`        |
  | 5               | Notice        | `notice`      |
  | 4               | Warning       | `warning`     |
  | 3               | Errore        | `err`         |
  | 2               | Critical      | `crit`        |
  | 1               | Alert         | `alert`       |
  | 0               | Emergency     | `emerg`       |

- **struttura** - Questa tabella mostra la struttura:

  | Codice numerico | struttura  |
  | :-------------- | :--------- |
  | 0               | `kern`     |
  | 1               | `user`     |
  | 2               | `mail`     |
  | 3               | `daemon`   |
  | 4               | `auth`     |
  | 5               | `syslog`   |
  | 6               | `lpr`      |
  | 7               | `news`     |
  | 8               | `uucp`     |
  | 9               |            |
  | 10              | `authpriv` |
  | 11              | `ftp`      |
  | 12              |            |
  | 13              |            |
  | 14              |            |
  | 15              | `cron`     |
  | 16              | `local0`   |
  | 17              | `local1`   |
  | 18              | `local2`   |
  | 19              | `local3`   |
  | 20              | `local4`   |
  | 21              | `local5`   |
  | 22              | `local6`   |
  | 23              | `local7`   |

### comando `journalctl`

L'uso è `journalctl [OPTIONS...] [MATCHES...]`.

Ecco un elenco delle opzioni in un elenco non ordinato:

- `-u` - Specifica l''unità'; si può usare più volte in un comando a riga singola. Per esempio, `journalctl -u crond.service -u sshd.service`
- `--system` - Mostra i messaggi dei servizi di sistema e del kernel
- `--user` - Mostra i messaggi del servizio dell'utente corrente
- `-k` - Mostra il registro dei messaggi del kernel dall'avvio corrente
- `--since=DATA` o `-S` - Mostra le voci che non sono più vecchie della data specificata. Il formato della data è "AAAA-MM-GG HH:MM:SS". Per esempio `journalctl --since="2025-04-24 14:00:30`
- `--until=DATA` o `-U` - Mostra le voci che non sono più recenti della data specificata. Il formato della data è "AAAA-MM-GG HH:MM:SS". Ad esempio `journalctl --since="2025-04-01 05:00:10" --until="2025-04-05 18:00:30"`
- `--list-boots` - Mostra informazioni sintetiche sugli avvii registrati
- `-n N` - Controlla il numero di voci emesse. Se non viene specificato "N", il valore predefinito è 10
- `-p PRIORITY` - Specifica la priorità o l'intervallo di priorità. Se si specifica una singola parola chiave di priorità del registro, verrà visualizzata questa priorità e le voci superiori a questa priorità. Ad esempio, `journalctl -p 3` o `journalctl -p err` Equivalente a `journalctl -p 0..3` o `journalctl -p emerg..err`
- `-b` - Interroga il registro dall'inizio dell'ID di avvio corrente. Non confondere l'ID di avvio con il numero di indice dell'avvio del kernel.
- `-f` - Log dinamico delle query, simile al comando `tail -f`
- `-x` - Aggiunge le spiegazioni dei messaggi, se disponibili
- `-e` - Salta alla pagina finale del log, spesso usato con l'opzione `-x`
- `-r` - Registro inverso.
- `--disk-usage` - Visualizza lo spazio su disco occupato dai file di log
- `--rotate` - Richiede la rotazione immediata dei journal file
- `--vacuum-size=BYTES` - Riduce il file di log alla dimensione specificata. Elimina gradualmente il contenuto del vecchio registro fino a raggiungere la dimensione del file specificata. I suffissi di dimensione supportati sono K, M, G, T
- `--vacuum-time=TIME` - È possibile eliminare i vecchi record di log specificando un punto temporale, cioè cancellerà i record di log precedenti. I suffissi temporali supportati sono s, m, h, giorni, mesi, settimane, anni
- `--vacuum-files=INT` - Indica quanti file di log riservare
- `-N` - Elenca tutti i nomi dei campi attualmente utilizzati. Gli utenti possono utilizzare il metodo "FIELD=VALUE" per abbinare i contenuti correlati. Ad esempio, `journalctl _SYSTEMD_UNIT=sshd.service`.
- `-g` o `-grep=PATTERN` - Corrisponde al contenuto del registro attraverso uno schema e supporta le espressioni regolari. Se PATTERN è tutto minuscolo, il contenuto del registro non è sensibile alle maiuscole per impostazione predefinita. È possibile regolare la sensibilità alle maiuscole attraverso l'opzione `--case-sensitive`
- `--case-sensitive=[BOOLEAN]` - Regola la sensibilità alle maiuscole.
- `-o` o `--output=STRING` - Cambia la modalità di output di `journalctl`. Una STRING può essere short, short-precise, short-iso, short-iso-precise, short-full, short-monotonic, short-unix, verbose, export, json, json-pretty, json-sse, cat, e with-unit
- `-q` o `--quiet` - Output silenzioso
- `--sync` - Sincronizza i messaggi del journal non scritti su disco

### /etc/systemd/journald.conf

```bash
Shell > cat /etc/systemd/journald.conf
[Journal]
#Storage=auto
#Compress=yes
#Seal=yes
#SplitMode=uid
#SyncIntervalSec=5m
#RateLimitIntervalSec=30s
#RateLimitBurst=10000
#SystemMaxUse=
#SystemKeepFree=
#SystemMaxFileSize=
#SystemMaxFiles=100
#RuntimeMaxUse=
#RuntimeKeepFree=
#RuntimeMaxFileSize=
#RuntimeMaxFiles=100
#MaxRetentionSec=
#MaxFileSec=1month
#ForwardToSyslog=no
#ForwardToKMsg=no
#ForwardToConsole=no
#ForwardToWall=yes
#TTYPath=/dev/console
#MaxLevelStore=debug
#MaxLevelSyslog=debug
#MaxLevelKMsg=notice
#MaxLevelConsole=info
#MaxLevelWall=emerg
#LineMax=48K
```

Utilizzare "[ ]" per contenere il titolo, come per i file di configurazione di altri componenti di `systemd`, e sotto il titolo ci sono coppie chiave-valore specifiche. Nella coppia chiave-valore non ci sono **spazi su entrambi i lati del segno di uguale**. Per la pagina completa del manuale di configurazione, vedere `man 5 journald.conf`

- `Storage=` - Controlla la posizione dell'archivio dati di `journald`. Il valore predefinito è auto.

  - volatile - Memorizza i dati di registro in memoria, cioè nel file temporaneo situato nella directory **/run/log/journal/**.
  - persistent - Memorizza i dati di log nella directory **/var/log/journal/**. È necessario crearla manualmente. Se questa directory non è scrivibile, i dati di log verranno scritti nella directory **/run/log/journal/**.
  - auto - Simile a persistent
  - none - Non salva alcun registro, ma non influisce sui registri inoltrati ad altri "targets"

- `Compress=` - Se abilitare la funzione di compressione. Il valore predefinito è yes.

- `Seal=` - Se usare FSS (Forward Secure Sealing) per proteggere le voci di registro da manomissioni dolose. Il valore predefinito è yes.

- `SplitMode=` - Definisce la base per la suddivisione dei file di log. La precondizione (Storage=persistent) deve essere soddisfatta prima che abbia effetto. Il valore predefinito è uid.

- `SyncIntervalSec=` - Definisce l'intervallo di tempo per la sincronizzazione dei dati di registro in memoria con il disco. Attenzione! Questo avviene solo per le priorità dei log err, warning, notice, info e debug. Le altre priorità di registro vengono immediatamente sincronizzate su disco. Il valore predefinito è 5m.

- `RateLimitIntervalSec=` - Definisce l'intervallo di tempo per la frequenza di generazione dei registri. Il valore predefinito è 30s.

- `RateLimitBurst=` - Il numero massimo di voci che il log genera in un determinato intervallo di tempo. Il valore predefinito è 10000. Se le voci di registro sono superiori a 10000 in un determinato intervallo di tempo, vengono eliminati i registri ridondanti e non vengono create nuove voci di registro fino all'intervallo di tempo successivo.

- `SystemMaxUse=` - Controlla la dimensione totale di tutti i file di log nella directory **/var/log/journal/**.

- `SystemKeepFree=` - Controlla quanto spazio su disco riservare alla directory **/var/log/journal/**. In base a 1024, i suffissi includono K, M, G, T, P, E

- `SystemMaxFileSize=` - Limita la dimensione di un singolo file nella directory **/var/log/journal/**. Se la dimensione supera quella specificata, si verificherà una rotazione del registro

- `SystemMaxFiles=` - Specifica quanti file mantenere nella directory **/var/log/journal/**. Quando supera il numero definito, cancella il registro più vecchio.

- `RuntimeMaxUse=` - Controlla la dimensione totale dei dati di log nella directory **/run/log/journal/**.

- `RuntimeKeepFree=` - Controlla quanto spazio riservare nella directory **/run/log/journal/**.

- `RuntimeMaxFileSize=` - Controlla la dimensione di un singolo file di log nella directory **/run/log/journal/**. Quando il registro raggiunge la dimensione specificata, si verifica la rotazione del registro.

- `RuntimeMaxFiles=` - Quanti file di log devono essere conservati nella directory **/run/log/journal/**.

- `MaxRetentionSec=` - Definisce il tempo di conservazione dei file di log; se supera il tempo definito, cancella i vecchi file di log. Il valore 0 indica che la funzione è disattivata. Il suffisso del valore è anno, mese, settimana, giorno, h, m

- `MaxFileSec=` - Rotazione del registro basata sul tempo. Poiché il polling basato sulle dimensioni dei file (`SystemMaxFileSize` e `RuntimeMaxFileSize`) esiste già, il polling dei registri basato sul tempo è solitamente inutile. Impostare su 0 per disabilitare questa funzione.

- `ForwardToSyslog=` - Se inoltrare i messaggi di log raccolti al demone tradizionale `syslog`. Il valore predefinito è no.

- `ForwardToKMsg=` - Se inoltrare il messaggio di log ricevuto a kmsg. Il valore predefinito è no.

- `ForwardToConsole=` - Se inoltrare i messaggi di log ricevuti alla console di sistema. Il valore predefinito è no. Se è impostato su yes, è necessario configurare anche `TTYPath`

- `ForwardToWall=` - Se inviare il messaggio di log ricevuto come avviso a tutti gli utenti connessi. Il valore predefinito è yes.

- `TTYPath=` - Specifica il percorso della console. Richiede `ForwardToConsole=yes`. Il valore predefinito è /dev/console

- `MaxLevelStore=` - Imposta il livello massimo di log registrato nel file di log. Il valore predefinito è debug

- `MaxLevelSyslog=` - Imposta il livello massimo di log inoltrati al demone tradizionale `syslog`. Il valore predefinito è debug

- `MaxLevelKMsg=` - Imposta il livello massimo di log inviato a kmsg. Il valore predefinito è notice

- `MaxLevelConsole=` - Imposta il livello massimo di log inoltrato alla console di sistema. Il valore predefinito è info

- `MaxLevelWall=` - Imposta il livello massimo di log inviato a tutti gli utenti connessi. Il valore predefinito è `emerg`

- `LineMax=` - La lunghezza massima consentita (byte) di ciascun record di log quando si converte il flusso di log in record di log. Con 1024 come base, il suffisso può essere K, M, G o T. Il valore predefinito è 48K

## Altre istruzioni

Se non si modifica alcuna configurazione in **/etc/systemd/journald.conf**, `rsyslog` e `journald` possono coesistere senza influenzarsi a vicenda.

```bash
Shell > cat /etc/rsyslog.conf
...
#### MODULES ####

module(load="imuxsock"    # provides support for local system logging (e.g. via logger command)
       SysSock.Use="off") # Turn off message reception via local log socket;
                          # local messages are retrieved through imjournal now.
module(load="imjournal"             # provides access to the systemd journal
       UsePid="system" # PID nummber is retrieved as the ID of the process the journal entry originates from
       StateFile="imjournal.state") # File to store the position in the journal
#module(load="imklog") # reads kernel messages (the same are read from journald)
#module(load="immark") # provides --MARK-- message capability
...
```

`journald` inoltrerà i dati di log ottenuti al socket `/run/systemd/journal/syslog` per facilitare l'uso dei servizi di log tradizionali (rsyslog, syslog-ng). Tuttavia, dal file di configurazione si apprende che `rsyslog` non raccoglie i log da `journald` tramite socket, ma si integra attraverso il modulo di input (imjournal).

**Q: Il sistema operativo non può usare `journald` per la registrazione**

Sì. Per impostazione predefinita, `rsyslog` e `journald` possono coesistere nel sistema operativo senza influenzarsi a vicenda. La coesistenza non è la scelta migliore per alcuni scenari di utilizzo orientati alle prestazioni (come il throughput dei dati e il consumo di memoria). Si può fare in modo che `rsyslog` venga eseguito solo in modalità socket, il che aiuta a migliorare le prestazioni e a registrare tutti i log in testo normale. Tuttavia, se avete bisogno di registri strutturati, questa modifica non è adatta. Le fasi rilevanti sono le seguenti:

```bash
Shell > vim /etc/rsyslog.config
...
module(load="imuxsock"
      SysSock.Use="on")
# module(load="imjournal" 
# UsePid="system" 
# StateFile="imjournal.state")
module(load="imklog")
...

Shell > vim /etc/systemd/journald.conf
[Journal]
Storage=none
...
ForwardToSyslog=yes
...

Shell > reboot
```
