---
title: Gestione dei compiti
---

# Gestione dei compiti

In questo capitolo si spiega come gestire le attività pianificate.

****

**Obiettivi** : In questo capitolo, futuri amministratori Linux impareranno come:

:heavy_check_mark: Linux si occupa dello scheduling dei task;  
:heavy_check_mark: limitare l'uso di **`cron`** a determinati utenti;  
:heavy_check_mark: pianificare le attività.

:checkered_flag: **crontab**, **crond**, **pianificazione**, **linux**

**Conoscenza**: :star: :star:  
**Complessità**: :star: :star:

**Tempo di lettura**: 15 minuti

****

## Generalità

La pianificazione delle attività è gestita con l'utilità `cron`. Essa permette l'esecuzione periodica dei compiti.

È riservato agli amministratori per eseguire le attività di sistema, ma può essere utilizzato anche dai normali utenti per le attività o gli script a cui hanno accesso. Per accedere all'utilità `cron`, usiamo: `crontab`.

Il servizio `cron` è usato per:

* Operazioni di amministrazione ripetitive;
* Backups;
* Monitoraggio dell'attività del sistema;
* Esecuzione di un programma.

`crontab` è un'abbreviazione per **cron table**, ma può essere pensato come una tabella di programmazione attività.

!!! Warning "Attenzione"

    Per impostare una pianificazione, il sistema deve avere l'ora locale impostata correttamente.

## Come funziona il servizio

Un demone `crond` presente esegue il servizio `cron` in memoria.

Per verificare il suo stato:

```bash
[root] # systemctl status crond
```

!!! Tip "Suggerimento"

    Se il demone `crond` non è in esecuzione, dovrai inizializzarlo manualmente e/o automaticamente all'avvio. Infatti, anche se i compiti sono pianificati, non saranno lanciati.

Inizializzazione manuale del demone `crond`:

```bash
[root]# systemctl {status|start|restart|stop} crond
```

Initializzazione del demone `crond` all'avvio del sistema:

```bash
[root]# systemctl enable crond
```

## Sicurezza

Per implementare una pianificazione, un utente deve avere i permessi per utilizzare il servizio `cron`.

Questa autorizzazione varia in base alle informazioni contenute nei file seguenti:

* `/etc/cron.allow`
* `/etc/cron.deny`

!!! Warning "Attenzione"

    Se nessuno dei file è presente, tutti gli utenti possono usare `cron`.

### I files `cron.allow` and `cron.deny`

File `/etc/cron.allow`

Solo gli utenti contenuti in questo file sono autorizzati a utilizzare `cron`.

Se esiste ed è vuoto, nessun utente può usare `cron`.

!!! Warning "Attenzione"

    Se `cron.allow` è presente, `cron.deny` è **ignorato**.

File `/etc/cron.deny`

Gli utenti di questo file non sono autorizzati a utilizzare `cron`.

Se è vuoto, tutti gli utenti possono usare `cron`.

Per impostazione predefinita, `/etc/cron.deny` esiste ed è vuoto e `/etc/cron.allow` non esiste. Quando esistono due file contemporaneamente, il sistema utilizza solo il contenuto di `cron.allow` come base di giudizio e ignora completamente l'esistenza del file `cron.deny.`.

### Consentire ad un utente

Solo **user1** sarà in grado di utilizzare`cron`.

```bash
[root]# vi /etc/cron.allow
user1
```

### Proibire ad un utente

Solo l'**utente2** non potrà usare `cron`. Si noti che il file `/etc/cron.allow` non deve esistere.

```bash
[root]# vi /etc/cron.deny
user2
```

Se lo stesso utente esiste contemporaneamente in `/etc/cron.deny` e `/etc/cron.allow`, l'utente può usare cron normalmente.

## Pianificazione delle attività

Quando un utente pianifica un'attività, viene creato un file con il suo nome in `/var/spool/cron/`.

Questo file contiene tutte le informazioni che il `crond` deve conoscere sui compiti creati da questo utente, compresi i comandi o i programmi da eseguire e la pianificazione dell'esecuzione (ora, minuto, giorno, ecc.). Si noti che l'unità di tempo minima che `crond` può riconoscere è 1 minuto. Esistono attività di pianificazione simili in RDBMS (come MySQL), dove le attività di pianificazione basate sul tempo sono denominate "Event Scheduler". L'unità di tempo minima che è in grado di riconoscere è 1 secondo e le attività di pianificazione basate su eventi sono denominate "Trigger".

![Cron tree](images/tasks-001.png)

### Il comando `crontab`

Il comando `crontab` viene utilizzato per gestire il file di pianificazione.

```bash
crontab [-u user] [-e | -l | -r]
```

Esempio:

```bash
[root]# crontab -u user1 -e
```

| Opzione | Descrizione                                                                              |
| ------- | ---------------------------------------------------------------------------------------- |
| `-e`    | Modifica il file di pianificazione con VI                                                |
| `-l`    | Visualizza il contenuto del file di pianificazione                                       |
| `-u`    | Imposta il nome dell'utente di cui si vuole manipolare il file di programma previsionale |
| `-r`    | Cancella il file di pianificazione                                                       |

!!! Warning "Attenzione"

    `crontab` senza opzioni cancella il vecchio file di pianificazione e attende che l'utente inserisca nuove righe. Per uscire da questa modalità di modifica è necessario premere <kbd>ctrl</kbd> + <kbd>d</kbd>.
    
    Solo `root' può usare l'opzione `-u user' per gestire il file di pianificazione di un altro utente.
    
    L'esempio precedente consente a root di pianificare un'attività per l'user1.

### Usi di `crontab`

Gli usi di `crontab` sono molti e includono:

* Modifiche ai file `crontab` presi in considerazione immediatamente;
* Nessun bisogno di riavviare.

D'altra parte, devono essere presi in considerazione i seguenti punti:

* Il programma deve essere autonomo;
* Fornire reindirizzamenti (stdin, stdout, stderr);
* Non è rilevante per eseguire comandi che utilizzano richieste di ingresso/uscita su un terminale.

!!! Note "Nota"

    È importante capire che lo scopo della programmazione è quello di eseguire i compiti automaticamente, senza la necessità di un intervento esterno.

## Il file  `crontab`

Il file `crontab` è strutturato in base alle seguenti regole.

* Ogni riga di questo file corrisponde a una pianificazione;
* Ogni linea ha sei campi, 5 per il tempo e 1 per l'ordine;
* Uno spazio o una tabulazione separano ogni campo;
* Ogni linea termina con un ritorno a capo;
* Un `#` all'inizio della linea la commenta.

```bash
[root]# crontab –e
10 4 1 * * /root/scripts/backup.sh
1  2 3 4 5       6
```

| Campo | Descrizione               | Dettaglio                 |
| ----- | ------------------------- | ------------------------- |
| 1     | Minuto(i)                 | Da 0 a 59                 |
| 2     | Ora(e)                    | Da 0 a 23                 |
| 3     | Giorno(i) del mese        | Da 1 a 31                 |
| 4     | Mese dell'anno            | Da 1 a 12                 |
| 5     | Giorno(i) della settimana | Da 0 a 7 (0=7=Domenica)   |
| 6     | Compito da eseguire       | Comando completo o script |

!!! Warning "Attenzione"

    I task da eseguire devono utilizzare percorsi assoluti e, se possibile, usare i reindirizzamenti.

Per semplificare la notazione della definizione di tempo, è consigliabile utilizzare simboli speciali.

| Wildcards | Descrizione                               |
| --------- | ----------------------------------------- |
| `*`       | Indica tutti i possibili valori del campo |
| `-`       | Indica una gamma di valori                |
| `,`       | Indica un elenco di valori                |
| `/`       | Definisce un passo                        |

Esempi:

Script eseguito il 15 Aprile alle 10:25am:

```bash
25 10 15 04 * /root/scripts/script > /log/…
```

Ogni giorno alle 11.00 e alle 16.00:

```bash
00 11,16 * * * /root/scripts/script > /log/…
```

Esegui ogni ora dalle 11.00 alle 16.00 tutti i giorni:

```bash
00 11-16 * * * /root/scripts/script > /log/…
```

Esegui ogni 10 minuti durante l'orario di lavoro:

```bash
*/10 8-17 * * 1-5 /root/scripts/script > /log/…
```

Per l'utente root, `crontab` ha anche alcune impostazioni speciali del tempo:

| Impostazioni | Descrizione                                                       |
| ------------ | ----------------------------------------------------------------- |
| @reboot      | Esegue un comando al riavvio del sistema                          |
| @hourly      | Esegue un comando ogni ora                                        |
| @daily       | Esegui giornalmente dopo la mezzanotte                            |
| @weekly      | Esegui il comando ogni domenica dopo la mezzanotte                |
| @monthly     | Esegui il comando il primo giorno del mese subito dopo mezzanotte |
| @annually    | Esegui il 1 gennaio subito dopo mezzanotte                        |

### Processo di esecuzione dell'attività

Un utente, rockstar, vuole modificare il suo file `crontab`:

1. `crond` controlla se è autorizzato (`/etc/cron.allow` e `/etc/cron.deny`).

2. Se lo è, accede al suo file `crontab` (`/var/spool/cron/rockstar`).

    Ogni minuto `crond` legge i file di pianificazione.

3. Esegue le attività programmate.

4. I rapporti sono riportati sistematicamente in un file di log (`/var/log/cron`).
