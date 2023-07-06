---
title: Moduli di autenticazione PAM
author: Antoine Le Morvan
contributors: Steven Spencer, Ezequiel Bruni, Franco Colussi
tested_with: 8.5, 8.6
tags:
  - security
  - pam
---

# Moduli di autenticazione PAM

## Prerequisiti e Presupposti

* Un PC Rocky Linux, server o VM non critico
* Accesso root
* Alcune conoscenze esistenti su Linux (aiuterebbero molto)
* Un desiderio di imparare sull'autenticazione utente e app su Linux
* La capacità di accettare le conseguenze delle proprie azioni

## Instroduzione

PAM (**Pluggable Authentication Modules**) è il sistema sotto GNU/Linux che consente a molte applicazioni o servizi di autenticare gli utenti in modo centralizzato. Per dirla in altro modo:

> PAM è una suite di librerie che consente all'amministratore di sistema Linux di configurare i metodi di autenticazione degli utenti. Fornisce un modo flessibile e centralizzato per cambiare i metodi di autenticazione per le applicazioni protette, utilizzando file di configurazione invece di modificare il codice dell'applicazione. \- [Wikipedia](https://en.wikipedia.org/wiki/Linux_PAM)

Questo documento *non è* stato concepito per insegnarvi esattamente come rinforzare la vostra macchina, ok? È più che altro una guida di riferimento per mostrare cosa *può* fare PAM e non cosa *si deve* fare.

## Generalità

L'autenticazione è la fase in cui si verifica che l'utente sia la persona che dichiara di essere. L'esempio più comune è la password, ma esistono altre forme di autenticazione.

![Generalità PAM](images/pam-001.png)

L'implementazione di un nuovo metodo di autenticazione non dovrebbe richiedere modifiche alla configurazione o al codice sorgente di un programma o di un servizio. Per questo motivo le applicazioni si affidano a PAM, che fornisce loro le primitive* necessarie per autenticare gli utenti.

Tutte le applicazioni di un sistema possono quindi implementare funzionalità complesse come **SSO** (Single Sign On), **OTP** (One Time Password) o **Kerberos** in modo completamente trasparente. L'amministratore di sistema può scegliere esattamente il criterio di autenticazione da utilizzare per una singola applicazione (ad esempio per rendere più sicuro il servizio SSH) indipendentemente dall'applicazione stessa.

Ogni applicazione o servizio che supporta PAM avrà un file di configurazione corrispondente nella directory `/etc/pam.d/`. Ad esempio, il processo `login` assegna il nome `/etc/pam.d/login` al suo file di configurazione.

\* Le primitive sono letteralmente gli elementi più semplici di un programma o di un linguaggio e permettono di costruire cose più sofisticate e complesse.

!!! WARNING "Attenzione"

    Un'istanza di PAM mal configurata può compromettere la sicurezza dell'intero sistema. Se PAM è vulnerabile, allora l'intero sistema è vulnerabile. Apportare le modifiche con cautela.

## Direttive

Una direttiva viene utilizzata per impostare un'applicazione da utilizzare con PAM. Le direttive seguiranno questo formato:

```
mechanism [control] path-to-module [argument]
```

Una **direttiva** (una riga completa) è composta da un **mechanism**(`auth`, `account`, `password` o `session`), un **success check**(`include`, `optional`, `required`, ...), il **percorso del modulo** ed eventualmente degli **arguments** (come ad esempio `revoke` ).

Ogni file di configurazione PAM contiene una serie di direttive. Le direttive di interfaccia del modulo possono essere impilate o sovrapposte. Infatti, **l'ordine in cui sono elencati i moduli è molto importante per il processo di autenticazione.**

Ad esempio, ecco il file di configurazione `/etc/pam.d/sudo`:

```
#%PAM-1.0
auth       include      system-auth
account    include      system-auth
password   include      system-auth
session    include      system-auth
```

## Mechanisms

### `auth` - Autenticazione

Questo gestisce l'autenticazione del richiedente e stabilisce i diritti dell'account:

* Di solito si autentica con una password confrontandola con un valore memorizzato in un database o affidandosi a un server di autenticazione,

* Stabilisce le impostazioni dell'account: uid, gid, gruppi e limiti delle risorse.

### `account` - Gestione account

Verifica che l'account richiesto sia disponibile:

* Si riferisce alla disponibilità dell'account per motivi diversi dall'autenticazione (ad esempio, per restrizioni temporali).

### `session` - Gestione sessione

Riguarda l'impostazione e la chiusura della sessione:

* Esegue le attività associate all'impostazione della sessione (ad esempio, la registrazione),
* Esegue le attività associate alla chiusura della sessione.

### `password` - Gestione delle password

Utilizzato per modificare il token di autenticazione associato a un account (scadenza o modifica):

* Modifica il token di autenticazione ed eventualmente verifica che sia sufficientemente robusto o che non sia già stato utilizzato.

## Indicatori di Controllo

I meccanismi PAM (`auth`, `account`, `session` e `password`) indicano il `successo` o il `fallimento`. Le flag di controllo (`required`, `requisite`, `sufficient`, `optional`) indicano a PAM come gestire questo risultato.

### `required`

È necessario completare con successo tutti i moduli `required`.

* **Se il modulo passa:** Il resto della catena viene eseguito. La richiesta è consentita a meno che altri moduli non falliscano.

* **Se il modulo fallisce:** Il resto della catena viene eseguito. Alla fine la richiesta viene respinta.

Il modulo deve essere verificato con successo affinché l'autenticazione possa continuare. Se la verifica di un modulo contrassegnato come `required` fallisce, l'utente non viene avvisato finché non sono stati verificati tutti i moduli associati a quell'interfaccia.

### `requisite`

È necessario completare con successo tutti i `moduli` richiesti.

* **Se il modulo passa:** Il resto della catena viene eseguito. La richiesta è consentita a meno che altri moduli non falliscano.

* **Se il modulo fallisce:** La richiesta viene immediatamente respinta.

Il modulo deve essere verificato con successo perché l'autenticazione possa continuare. Tuttavia, se la verifica di un `requisite`-marked fallisce, l'utente è immediatamente informato da un messaggio che indica il fallimento del primo modulo `required` o `requisite`.

### `sufficient`

Moduli marcati `sufficient` può essere utilizzato per far entrare un utente "in anticipo" in determinate condizioni:

* **Se il modulo ha successo:** La richiesta di autenticazione è immediatamente consentita se nessuno dei moduli precedenti ha fallito.

* **Se il modulo fallisce:** Il modulo viene ignorato. Il resto della catena viene eseguito.

Tuttavia, se un controllo del modulo contrassegnato `sufficient` è riuscito, ma i moduli marcati `required` o `requisite` non hanno superato i loro controlli, il successo del modulo `sufficient` viene ignorato e la richiesta fallisce.

### `optional`

Il modulo viene eseguito ma il risultato della richiesta viene ignorato. Se tutti i moduli della catena fossero contrassegnati `optional`, tutte le richieste sarebbero sempre accettate.

### Conclusione

![Schermata di avvio dell'installazione Rocky Linux](images/pam-002.png)

## Moduli PAM

Ci sono molti moduli per PAM. Ecco i più comuni:

* pam_unix
* pam_ldap
* pam_wheel
* pam_cracklib
* pam_console
* pam_tally
* pam_securetty
* pam_nologina
* pam_limits
* pam_time
* pam_access

### `pam_unix`

Il modulo `pam_unix` consente di gestire la politica globale di autenticazione.

In `/etc/pam.d/system-auth` puoi aggiungere:

```
password sufficient pam_unix.so sha512 nullok
```

Sono possibili argomenti per questo modulo:

* `nullok`: nel meccanismo `auth` consente una password di accesso vuota.
* `sha512`: nel meccanismo della password, definisce l'algoritmo di crittografia.
* `debug`: invia informazioni a `syslog`.
* `remember=n`: Usa thid per ricordare le ultime password di `n` utilizzate (funziona insieme al file `/etc/security/opasswd` , che deve essere creato dall'amministratore).

### `pam_cracklib`

Il modulo `pam_cracklib` consente di testare le password.

In `/etc/pam.d/password-auth` aggiungere:

```
password sufficient pam_cracklib.so retry=2
```

Questo modulo utilizza la libreria `cracklib` per controllare la forza di una nuova password. Può anche controllare che la nuova password non sia costruita da quella vecchia.  Questo influisce*solo* sul meccanismo della password.

Per impostazione predefinita, questo modulo controlla i seguenti aspetti e rifiuta se è il caso:

* La nuova password è dal dizionario?
* La nuova password è un palindromo di quella vecchia (ad esempio: azerty <> ytreza)?
* L'utente ha cambiato solo le maiuscole della password? (es.: azerty <>AzErTy)?

Possibili argomenti per questo modulo:

* `retry=n`: impone `n` richieste (1` per impostazione predefinita) per la nuova password.
* `difok=n`: impone almeno `n` caratteri (`10` per impostazione predefinita), diversi dalla vecchia password. Se la metà dei caratteri della nuova password è diversa da quella vecchia, la nuova password viene convalidata.
* `minlen=n`: impone una password di `n+1` caratteri minimi. Non è possibile assegnare un minimo inferiore a 6 caratteri (il modulo è compilato in questo modo).

Altri argomenti possibili:

* `dcredit=-n`: impone una password contenente almeno `n` cifre,
* `ucredit=-n`: impone una password contenente almeno `n` lettere maiuscole,
* `credit=-n`: impone una password contenente almeno `n` lettere minuscole,
* `ocredit=-n`: impone una password contenente almeno `n` caratteri speciali.

### `pam_tally`

Il modulo `pam_tally` consente di bloccare un account basato su un numero di tentativi di accesso non riusciti.

Il file di configurazione predefinito per questo modulo potrebbe assomigliare: `/etc/pam.d/system-auth`:

```
auth required /lib/security/pam_tally.so onerr=fail no_magic_root
account required /lib/security/pam_tally.so deny=3 reset no_magic_root
```

Il meccanismo `auth` accetta o nega l'autenticazione e reimposta il contatore.

Il meccanismo `account` incrementa il contatore.

Alcuni argomenti del modulo pam_tally includono:

* `onerr=fail`: incrementa il contatore.
* `deny=n`: una volta superato il numero `n` dei tentativi non riusciti, l'account è bloccato.
* `no_magic_root`: può essere usato per negare l'accesso ai servizi di root-level lanciati dai demoni.
    * ad esempio, non usare questo per `su`.
* `reset`: resettare il contatore a 0 se l'autenticazione è convalidata.
* `lock_time=nsec`: l'account è bloccato per `n` secondi.

Questo modulo funziona insieme al file predefinito per tentativi non riusciti `/var/log/faillog` (che può essere sostituito da un altro file con l'argomento `file=xxxx`), e il comando associato `faillog`.

Sintassi del comando faillog:

```
faillog[-m n] |-u login][-r]
```

Opzioni:

* `m`: per definire, nella visualizzazione dei comandi, il numero massimo di tentativi non riusciti,
* `u`: per specificare un utente,
* `r`: per sbloccare un utente.

### `pam_time`

Il modulo `pam_time` consente di limitare i tempi di accesso ai servizi gestiti da PAM.

Per attivarlo, modificare `/etc/pam.d/system-auth` e aggiungere:

```
account required /lib/security/pam_time.so
```

La configurazione è fatta nel file `/etc/security/time.conf`:

```
login ; * ; users ;MoTuWeThFr0800-2000
http ; * ; users ;Al0000-2400
```

La sintassi di una direttiva è la seguente:

```
services; ttys; users; times
```

Nelle seguenti definizioni, la lista logica utilizza:

* `&`: è la logica "and" .
* `<unk>`: è la logica "or".
* `!`: significa negazione, o "tutto eccetto".
* `*`: è il carattere jolly.

Le colonne corrispondono a:

* `services`: un elenco logico di servizi gestiti da PAM che devono essere gestiti anche da questa regola
* `ttys`: un elenco logico di dispositivi correlati
* `users`: elenco logico degli utenti gestiti dalla regola
* `times`: un elenco logico di fasce orarie autorizzate

Come gestire gli intervalli tempo:

* Giorni: `Mo`, `Tu`, `We`, `Th`, `Fr,` `Sa`, `Su`, `Wk`, (dal lunedì al venerdì), `Wd` (Sabato e Domenica), e `Al` (Lunedi a Domenica)
* La gamma oraria: `HHMM-HHMM`
* Una ripetizione annulla l'effetto: `WkMo` = tutti i giorni della settimana (M-F), meno lunedì (ripetuto).

Esempi:

* Bob, può accedere tramite un terminale tutti i giorni tra le 07:00 e le 09:00, tranne il mercoledì:

```
login; tty*; bob; alth0700-0900
```

Nessun accesso, da terminale o da remoto, tranne che per root, ogni giorno della settimana tra le 17:30 e le 7:45 del giorno successivo:

```
login; tty* | pts/*; !root; !wk1730-0745
```

### `pam_nologin`

Il modulo `pam_nologin` disabilita tutti gli account tranne root:

In `/etc/pam.d/login` si mette:

```
auth required pam_nologin.so
```

Se il file `/etc/nologin` esiste solo root può connettersi.

### `pam_wheel`

Il modulo `pam_wheel` consente di limitare l'accesso al comando `su` ai membri del gruppo `wheel`.

In `/etc/pam.d/su` si mette:

```
auth required pam_wheel.so
```

L'argomento `group=my_group` limita l'uso del comando `su` ai membri del gruppo `my_group`

!!! NOTE "Nota"

    Se il gruppo `my_group` è vuoto, il comando `su` non è più disponibile sul sistema, il che obbliga a usare il comando sudo.

### `pam_mount`

Il modulo `pam_mount` consente di montare un volume per una sessione utente.

In `/etc/pam.d/system-auth` si mette:

```
auth optional pam_mount.so
password optional pam_mount.so
session optional pam_mount.so
```

I punti di montaggio sono configurati nel file `/etc/security/pam_mount.conf`:

```
<volume fstype="nfs" server="srv" path="/home/%(USER)" mountpoint="~" />
<volume user="bob" fstype="smbfs" server="filesrv" path="public" mountpoint="/public" />
```

## Conclusione

A questo punto si dovrebbe avere un'idea più precisa di cosa può fare PAM e di come apportare le modifiche necessarie. Tuttavia, dobbiamo ribadire l'importanza di essere molto, *molto* attenti con qualsiasi modifica apportata ai moduli PAM. Potreste chiudervi fuori dal vostro sistema o, peggio, far entrare tutti gli altri.

Si consiglia vivamente di testare tutte le modifiche in un ambiente che possa essere facilmente riportato a una configurazione precedente. Detto questo, divertitevi!
