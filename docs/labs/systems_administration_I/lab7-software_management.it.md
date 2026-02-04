---
author: Wale Soyinka
contributors: Steven Spencer, tianci li, Ganna Zhyrnova
tested on: 8.8
tags:
  - lab exercise
  - software management
---

# Laboratorio 7: Gestione e installazione del software

## Obiettivi

Dopo aver completato questo laboratorio, sarete in grado di

- Interrogare i pacchetti per ottenere informazioni
- Installare il software dai pacchetti binari
- Risolvere alcuni problemi di dipendenza di base
- Compilare e installare il software dal codice sorgente

Tempo stimato per completare questo laboratorio: 90 minuti

## File binari e file sorgente

Le applicazioni installate sul sistema dipendono da alcuni fattori. Il fattore principale dipende dai gruppi di pacchetti software selezionati durante l'installazione del sistema operativo. L'altro fattore dipende da cosa è stato fatto al sistema dopo il suo utilizzo.

Scoprirai che una delle tue attività di routine come amministratore di sistema è la gestione del software. Questo spesso comporta:

- installazione di un nuovo software
- disinstallazione del software
- aggiornamento del software già installato

L'installazione di software su sistemi basati su Linux utilizza diversi metodi. È possibile eseguire l'installazione dal codice sorgente o dai binari precompilati. Quest'ultimo metodo è il più semplice, ma è anche il meno personalizzabile. Quando si esegue l'installazione da binari precompilati, la maggior parte del lavoro è già stata fatta per voi. Tuttavia, è necessario conoscere il nome e sapere dove trovare il software specifico che si desidera.

Quasi tutti i software sono originariamente disponibili come file sorgente in linguaggio di programmazione C o "C++". I programmi sorgente vengono solitamente distribuiti sotto forma di archivi di file sorgente. Di solito file compressi con tar, gzip o bzip2. Ciò significa che sono compressi o disponibili in un unico pacchetto.

La maggior parte degli sviluppatori ha reso il proprio codice sorgente conforme agli standard GNU, facilitando la condivisione. Ciò significa anche che i pacchetti potranno essere compilati su qualsiasi sistema UNIX o UNIX-like (ad esempio Linux).

RPM è lo strumento di base per la gestione delle applicazioni (pacchetti) sulle distribuzioni basate su Red Hat, quali Rocky Linux, Fedora, Red Hat Enterprise Linux (RHEL), openSuSE, Mandrake e così via.

Le applicazioni utilizzate per la gestione del software nelle distribuzioni Linux sono chiamate gestori di pacchetti. Esempi:

- Il gestore di pacchetti Red Hat (`rpm`). I pacchetti hanno il suffisso " .rpm"
- Il sistema di gestione dei pacchetti Debian (`dpkg`).  I pacchetti hanno il suffisso " .deb"

Di seguito sono elencate alcune opzioni della riga di comando e sintassi popolari per il comando RPM:

### `rpm`

Uso: rpm [OPZIONE...]

**INTERROGAZIONE DEI PACCHETTI**

```bash
Query options (with -q or --query):
  -c, --configfiles                  elenca tutti i file di configurazione
  -d, --docfiles                     elenca tutti i file di documentazione
  -L, --licensefiles                 elenca tutti i file di licenza
  -A, --artifactfiles                elenca tutti i file degli artefatti
      --dump                         scaricare le informazioni di base del file
  -l, --list                         elenca i file nel pacchetto
      --queryformat=QUERYFORMAT      utilizzare il seguente formato di query
  -s, --state                        visualizza lo stato dei file elencati
```

**VERIFICA DEI PACCHETTI**

```bash
Verify options (with -V or --verify):
      --nofiledigest                 non verificare il digest dei file
      --nofiles                      non verificare i file nel pacchetto
      --nodeps                       non verificare le dipendenze dei pacchetti
      --noscript                     non eseguire gli script di verifica
```

**INSTALLAZIONE, AGGIORNAMENTO E RIMOZIONE DEI PACCHETTI**

```bash
Opzioni di installazione/aggiornamento/rimozione:
      --allfiles                     installa tutti i file, anche le configurazioni che altrimenti potrebbero essere omesse
  -e, --erase=<package>+             elimina (disinstalla) il pacchetto
      --excludedocs                  non installare la documentazione.
      --excludepath=<path>           salta i file con componente iniziale <path>
      --force                        abbreviazione per --replacepkgs --replacefiles
  -F, --freshen=<packagefile>+       aggiornare i pacchetti se già installati
  -h, --hash                         stampa gli hash durante l'installazione dei pacchetti (ottimo con -v)
      --noverify                     abbreviazione per --ignorepayload --ignoresignature
  -i, --install                      installare pacchetto/i
      --nodeps                       non verificare le dipendenze dei pacchetti
      --noscripts                    non eseguire gli scriptlet del pacchetto
      --percent                      stampa le percentuali durante l'installazione del pacchetto
      --prefix=<dir>                 spostare il pacchetto in <dir>, se spostabile
      --relocate=<old>=<new>         sposta i file dal percorso <old> a <new>
      --replacefiles                 ignora i conflitti tra i file dei pacchetti
      --replacepkgs                  reinstallare se il pacchetto è già presente.
      --test                         non installare, ma provare se funziona
  -U, --upgrade=<packagefile>+       aggiornare i pacchetti
      --reinstall=<packagefile>+     reinstallare i pacchetti
```

## Esercizio 1

### Installazione, interrogazione e disinstallazione dei pacchetti

In questo laboratorio si imparerà come utilizzare il sistema RPM e installare un'applicazione di esempio.

!!! tip "Suggerimento"

```
Sono disponibili numerose opzioni per ottenere i pacchetti Rocky Linux. È possibile scaricarli manualmente da repository affidabili [o non affidabili]. È possibile ottenerli dall'ISO della distribuzione. È possibile ottenerli da una posizione condivisa centralmente utilizzando protocolli quali nfs, git, https, ftp, smb, cifs e così via. Se siete curiosi, potete visitare il sito web ufficiale seguente e consultare il repository appropriato per i pacchetti desiderati:

https://download.rockylinux.org/pub/rocky/8.8/
```

#### Per richiedere informazioni sui pacchetti

1. Per visualizzare un elenco di tutti i pacchetti attualmente installati sul sistema locale, digitare:

   ```bash
   $ rpm -qa
   python3-gobject-base-*
   NetworkManager-*
   rocky-repos-*
   ...<OUTPUT TRUNCATED>...
   ```

   Dovresti vedere un lungo elenco.

2. Approfondiamo un po' e scopriamo qualcosa in più su uno dei pacchetti installati sul sistema. Esamineremo NetworkManager. Utilizzeremo le opzioni --query (-q) e --info (-i) con il comando `rpm`. Digitare:

   ```bash
   $ rpm -qi NetworkManager
   Name        : NetworkManager
   Epoch       : 1
   ...<OUTPUT TRUNCATED>...
   ```

   Si tratta di una grande quantità di informazioni (metadati)!

3. Supponiamo di essere interessati solo al campo Summary del comando precedente. Possiamo utilizzare l'opzione --queryformat di rpm per filtrare le informazioni che otteniamo dall'opzione query.

   Ad esempio, per visualizzare solo il campo Summary, digitare:

   ```bash
   rpm -q --queryformat '%{summary}\n' NetworkManager
   ```

   Il nome del campo non fa distinzione tra maiuscole e minuscole.

4. Per visualizzare sia il campo Version che il campo Summary del pacchetto NetworkManager installato, digitare:

   ```bash
   rpm -q --queryformat '%{version}  %{summary}\n' NetworkManager
   ```

5. Digitare il comando per visualizzare le informazioni relative al pacchetto bash installato sul sistema.

   ```bash
   rpm -qi bash
   ```

   !!! note "Nota"

   ```
    Gli esercizi precedenti riguardavano la ricerca e l'utilizzo di pacchetti già installati sul sistema. Nei seguenti esercizi inizieremo a lavorare con pacchetti che non sono ancora stati installati. Utilizzeremo l'applicazione DNF per scaricare i pacchetti che useremo nei passaggi successivi.
   ```

6. Innanzitutto, assicurarsi che l'applicazione `wget` non sia già installata sul sistema. Digitare:

   ```bash
   rpm -q wget
   package wget is not installed
   ```

   Sembra che `wget` non sia installato sul nostro sistema demo.

7. A partire da Rocky Linux 8.x, il comando `dnf download` ti consentirà di ottenere l'ultimo pacchetto `rpm` per `wget`. Digitare:

   ```bash
   dnf download wget
   ```

8. Utilizzare il comando `ls` per assicurarsi che il pacchetto sia stato scaricato nella directory corrente. Digitare:

   ```bash
   ls -lh wg*
   ```

9. Utilizzare il comando `rpm` per richiedere informazioni sul file wget-\*.rpm scaricato. Digitare:

   ```bash
   rpm -qip wget-*.rpm
   Name        : wget
   Architecture: x86_64
   Install Date: (not installed)
   Group       : Applications/Internet
   ...<TRUNCATED>...
   ```

   !!! question "Domanda"

   ```
    Dal risultato ottenuto nel passaggio precedente, che cos'è esattamente il pacchetto `wget`? Suggerimento: è possibile utilizzare l'opzione di formato query `rpm` per visualizzare il campo di descrizione del pacchetto scaricato.
   ```

10. Se siete interessati al pacchetto `wget files-.rpm`, è possibile elencare tutti i file inclusi nel pacchetto digitando:

    ```bash
    rpm -qlp wget-*.rpm | head
    /etc/wgetrc
    /usr/bin/wget
    ...<TRUNCATED>...
    /usr/share/doc/wget/AUTHORS
    /usr/share/doc/wget/COPYING
    /usr/share/doc/wget/MAILING-LIST
    /usr/share/doc/wget/NEWS
    ```

11. Visualizziamo il contenuto del file `/usr/share/doc/wget/AUTHORS` elencato come parte del pacchetto `wget`. Useremo il comando `cat`. Digitare:

    ```bash
    cat /usr/share/doc/wget/AUTHORS
    cat: /usr/share/doc/wget/AUTHORS: No such file or directory
    ```

    `wget` non è stato [ancora] installato sul nostro sistema demo! E quindi, non possiamo visualizzare il file AUTHORS che è incluso nel pacchetto!

12. Visualizzare l'elenco dei file inclusi in un altro pacchetto (curl) che è _già_ installato sul sistema. Digitare:

    ```bash
    $ rpm -ql curl
    /usr/bin/curl
    /usr/lib/.build-id
    /usr/lib/.build-id/fc
    ...<>...
    ```

    !!! note "Nota"

    ```
    Si noterà che nel comando precedente non è stato necessario fare riferimento al nome completo del pacchetto `curl`. Questo perché `curl` è già installato.
    ```

#### Maggiori informazioni sul nome del pacchetto

- **Nome completo del pacchetto**: quando si scarica un pacchetto da una fonte attendibile (ad esempio, il sito web del fornitore o il repository dello sviluppatore), il nome del file scaricato è il nome completo del pacchetto, ad esempio -- htop-3.2.1-1.el8.x86_64.rpm. Quando si utilizza il comando `rpm` per installare/aggiornare questo pacchetto, l'oggetto gestito dal comando deve essere il nome completo (o un carattere jolly equivalente) del pacchetto, ad esempio:

  ```bash
  rpm -ivh htop-3.2.1-1.el8.x86_64.rpm
  ```

  ```bash
  rpm -Uvh htop-3.2.1-1.*.rpm
  ```

  ```bash
  rpm -qip htop-3.*.rpm
  ```

  ```bash
  rpm -qlp wget-1.19.5-11.el8.x86_64.rpm
  ```

  Il nome completo del pacchetto segue una convenzione di denominazione simile a questa —— `[Package_Name]-[Version]-[Release].[OS].[Arch].rpm` o `[Package_Name]-[Version]-[Release].[OS].[Arch].src.rpm`

- **Nome del pacchetto**: poiché RPM utilizza un database per gestire il software, una volta completata l'installazione del pacchetto, il database conterrà i record corrispondenti. In questo momento, per usare il comando `rpm` basta solo scrivere il nome del pacchetto. come ad esempio:

  ```bash
  rpm -qi bash
  ```

  ```bash
  rpm -q systemd
  ```

  ```bash
  rpm -ql chrony
  ```

## Esercizio 2

### Integrità del pacchetto

1. È possibile scaricare o ritrovarsi con un file danneggiato o contaminato. Per verificare l'integrità del pacchetto `wget` che avete scaricato. Digitare:

   ```bash
   rpm -K  wget-*.rpm
   wget-1.19.5-10.el8.x86_64.rpm: digests signatures OK
   ```

   Il messaggio "digests signatures OK" nell'output indica che il pacchetto è corretto.

2. Siamo maliziosi e modifichiamo deliberatamente il pacchetto scaricato. Questo può essere fatto aggiungendo o rimuovendo qualcosa dal pacchetto originale. Qualsiasi modifica al pacchetto che non sia stata prevista dai creatori originali danneggerà il pacchetto. Modificheremo il file utilizzando il comando `echo` per aggiungere la stringa "haha" al pacchetto. Digitare:

   ```bash
   echo haha >> wget-1.19.5-10.el8.x86_64.rpm 
   ```

3. Provate ora a verificare nuovamente l'integrità del pacchetto utilizzando l'opzione -K di rpm.

   ```bash
   $ rpm -K  wget-*.rpm
   wget-1.19.5-10.el8.x86_64.rpm: DIGESTS SIGNATURES NOT OK
   ```

   Ora il messaggio è molto diverso. Il messaggio "DIGESTS SIGNATURES NOT OK" avverte chiaramente che non si dovrebbe provare a utilizzare o installare il pacchetto. Non ci si dovrebbe più fidare.

4. Utilizzare il comando `rm` per eliminare il file del pacchetto `wget` danneggiato e scaricare una nuova copia utilizzando `dnf`. Digitare:

   ```bash
   rm wget-*.rpm  && dnf download wget
   ```

   Verificare nuovamente che il pacchetto appena scaricato superi i controlli di integrità RPM.

## Esercizio 3

### Installazione dei pacchetti

Durante l'installazione del software sul sistema, ci si potrebbe imbattere in problemi di “dipendenze non soddisfatte”. Questo è particolarmente comune quando si utilizza l'utilità RPM di basso livello per gestire manualmente le applicazioni su un sistema.

Ad esempio, se si prova ad installare il pacchetto "abc.rpm", il programma di installazione RPM potrebbe segnalare alcune dipendenze non soddisfatte. Potrebbe indicarvi che il pacchetto “abc.rpm” richiede l'installazione preliminare di un altro pacchetto, “xyz.rpm”. Il problema delle dipendenze sorge perché le applicazioni software dipendono quasi sempre da un altro software o da una libreria. Se un programma o una libreria condivisa richiesti non sono già presenti nel sistema, tale prerequisito deve essere soddisfatto prima di installare l'applicazione di destinazione.

L'utilità RPM di basso livello spesso conosce le interdipendenze tra le applicazioni. Ma di solito non sa come o dove ottenere l'applicazione o la libreria necessaria per risolvere il problema. In altre parole, RPM conosce il _cosa_ e il _come_, ma non ha la capacità intrinseca di rispondere alla domanda _dove_. È qui che strumenti come `dnf`, `yum` e così via danno il meglio di sé.

#### Installazione dei pacchetti

In questo esercizio si proverà ad installare il pacchetto `wget` (wget-\*.rpm).

1. Provare ad installare l'applicazione `wget`. Utilizzare le opzioni della riga di comando -ivh di RPM. Digitare:

   ```bash
   rpm -ivh wget-*.rpm
   error: Failed dependencies:
       libmetalink.so.3()(64bit) is needed by wget-*
   ```

   Subito - un problema di dipendenza! L'output di esempio mostra che `wget` necessita di un file di libreria denominato "libmetalink.so.3"

   !!! note "Nota"

   ```
    In base al risultato del test sopra riportato, il pacchetto wget-*.rpm richiede l'installazione del pacchetto libmetalink-*.rpm. In altre parole, libmetalink è un prerequisito per l'installazione di wget-*.rpm. È possibile installare forzatamente il pacchetto wget-*.rpm utilizzando l'opzione "nodeps" se si è assolutamente certi di ciò che si sta facendo, ma in genere questa è una pratica SCONSIGLIATA.
   ```

2. RPM ci ha gentilmente fornito un indizio su ciò che manca. Ricorderete che `rpm` conosce il cosa e il come, ma non necessariamente il dove. Utilizziamo l'utilità `dnf` per cercare di capire il nome del pacchetto che fornisce la libreria mancante. Digitare:

   ```bash
   $ dnf whatprovides libmetalink.so.3
   ...<TRUNCATED>...
   libmetalink-* : Metalink library written in C
   Repo        : baseos
   Matched from:
   Provide    : libmetalink.so.3
   ```

3. Dal risultato ottenuto, è necessario scaricare il pacchetto `libmetalink` che fornisce la libreria mancante. In particolare, desideriamo la versione a 64 bit della libreria. Richiediamo l'aiuto di un'utilità separata (`dnf`) per trovare e scaricare il pacchetto per la nostra architettura demo a 64 bit (x86_64). Digitare:

   ```bash
   dnf download --arch x86_64  libmetalink
   ```

4. Ora si dovrebbero avere almeno 2 pacchetti rpm nella directory di lavoro. Utilizzare il comando `ls` per verificarlo.

5. Installare la dipendenza mancante `libmetalink`. Digitare:

   ```bash
   sudo rpm -ivh libmetalink-*.rpm
   ```

6. Ora che la dipendenza è stata installata, possiamo tornare al nostro obiettivo iniziale, ovvero installare il pacchetto `wget`. Digitare:

   ```bash
   sudo rpm -ivh wget-*.rpm
   ```

   !!! note "Nota"

   ````
    RPM supporta le transazioni. Negli esercizi precedenti, avremmo potuto eseguire una singola transazione rpm che includesse il pacchetto originale che volevamo installare e tutti i pacchetti e le librerie da cui dipendeva. Sarebbe stato sufficiente un singolo comando come quello riportato di seguito:

        ```bash
        rpm -Uvh  wget-*.rpm  libmetalink-*.rpm
        ```
   ````

7. È arrivato il momento della verità. Provare ad eseguire il programma `wget` senza alcuna opzione per verificare se è installato. Digitare:

   ```bash
   wget
   ```

8. Vediamo `wget` in azione. Utilizzare `wget` per scaricare un file da Internet dalla riga di comando. Digitare:

   ```bash
   wget  https://kernel.org
   ```

   Questo scaricherà il file index.html predefinito dal sito web kernel.org!

9. Utilizzare `rpm` per visualizzare un elenco di tutti i file inclusi nell'applicazione `wget`.

10. Utilizzare `rpm` per visualizzare la documentazione inclusa nel pacchetto `wget`.

11. Utilizzare `rpm` per visualizzare l'elenco di tutti i file binari installati con il pacchetto `wget`.

12. È necessario installare il pacchetto `libmetalink` per installare `wget`. Prova a eseguire o lanciare `libmetalink` dalla riga di comando. Digitare:

    ```bash
    libmetalink
    -bash: libmetalink: command not found
    ```

    !!! attention "Attenzione"

    ```
    Che succede? Perché non si riescs ad eseguire `libmetalink`?
    ```

#### Importazione di una chiave pubblica tramite `rpm`

!!! tip "Suggerimento"

```
Le chiavi GPG utilizzate per firmare i pacchetti utilizzati nel progetto Rocky Linux possono essere ottenute da varie fonti, quali il sito web del progetto, il sito ftp, i supporti di distribuzione, la fonte locale e così via. Nel caso in cui la chiave corretta non fosse presente nel portachiavi del sistema RL, è possibile utilizzare l'opzione `--import` di `rpm` per importare la chiave pubblica di Rocky Linux dal sistema RL locale eseguendo: `sudo  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial`
```

!!! question "Domanda"

```
Quando si installano i pacchetti, qual è la differenza tra `rpm -Uvh` e `rpm -ivh`? Consultare la pagina man di `rpm`.
```

## Esercizio 4

### Disinstallazione dei pacchetti

La disinstallazione dei pacchetti è facile come l'installazione con il gestore di pacchetti Red Hat (RPM).

In questo esercizio si proverà ad utilizzare `rpm` per disinstallare alcuni pacchetti dal sistema.

#### Per disinstallare i pacchetti

1. Disinstallare il pacchetto `libmetalink` dal sistema. Digitare:

   ```bash
   sudo rpm -e libmetalink
   ```

   !!! question "Domanda"

   ```
    Spiegate perché non è stato possibile rimuovere il pacchetto?
   ```

2. Il modo corretto e pulito per rimuovere i pacchetti utilizzando RPM è quello di rimuovere i pacchetti insieme alle loro dipendenze. Per rimuovere il pacchetto `libmetalink` dovremo rimuovere anche il pacchetto `wget` che dipende da esso. Digitare:

   ```bash
   sudo rpm -e libmetalink wget
   ```

   !!! note "Nota"

   ```
    Se si desidera disinstallare il pacchetto che dipende da libmetalink e rimuovere *forzatamente* il pacchetto dal sistema, è possibile utilizzare l'opzione `--nodeps` di rpm come segue: `$ sudo rpm  -e  --nodeps  libmetalink`.

    **i.** L'opzione "nodeps" significa Nessuna dipendenza. Ovvero, ignora tutte le dipendenze.
    **ii.** Quanto sopra illustra come rimuovere forzatamente un pacchetto dal sistema. A volte è necessario farlo, ma in genere *non è una buona pratica*.
    **iii.** La rimozione forzata di un pacchetto "xyz" da cui dipende un altro pacchetto installato "abc" rende di fatto il pacchetto "abc" inutilizzabile o in qualche modo danneggiato.
   ```

## Esercizio 5

### DNF - gestore di pacchetti

DNF è un gestore di pacchetti per distribuzioni Linux basate su RPM. È il successore della popolare utility YUM. DNF mantiene la compatibilità con YUM ed entrambe le utility condividono opzioni e sintassi della riga di comando molto simili. Entrambe le utility condividono opzioni e sintassi simili nella riga di comando.

DNF è uno dei tanti strumenti per la gestione di software basati su RPM come Rocky Linux. Rispetto a `rpm`, questi strumenti di livello superiore aiutano a semplificare l'installazione, la disinstallazione e la ricerca dei pacchetti. È importante notare che questi strumenti utilizzano il framework sottostante fornito dal sistema RPM. Ecco perché è utile capire come utilizzare RPM.

DNF (e altri strumenti simili) opera come una sorta di involucro attorno a RPM e fornisce funzionalità aggiuntive non offerte da RPM. DNF sa come gestire le dipendenze dei pacchetti e delle librerie e sa anche come utilizzare i repository configurati per risolvere automaticamente la maggior parte dei problemi.

Le opzioni comunemente utilizzate con l'utilità `dnf` sono:

```bash
    uso: dnf [opzioni] COMANDO

    Elenco dei comandi principali:

    alias                     Elenca o crea alias di comandi
    autoremove               rimuove tutti i pacchetti non necessari che sono stati originariamente installati come dipendenze
    check                    verifica la presenza di problemi nel file packagedb
    check-update             verifica la disponibilità di aggiornamenti dei pacchetti
    clean                     rimuove i dati memorizzati nella cache
    deplist                   [deprecato, usare repoquery --deplist] Elenca le dipendenze del pacchetto e quali pacchetti le forniscono
    distro-sync               sincronizza i pacchetti installati alle ultime versioni disponibili
    downgrade                 Declassare un pacchetto
    group                     visualizza o utilizza le informazioni sui gruppi
    help                      visualizza un utile messaggio d'uso
    history                   visualizza o utilizza la cronologia delle transazioni
    info                      visualizza i dettagli di un pacchetto o di un gruppo di pacchetti
    install                   installare uno o più pacchetti sul sistema
    list                     elenca uno o più pacchetti
    makecache                genera la cache dei metadati
    mark                      marcare o deselezionare i pacchetti installati come installati dall'utente.
    module                    Interagire con i moduli.
    provides                  trova quale pacchetto fornisce il valore dato
    reinstall                 reinstallare un pacchetto
    remove                    rimuovere uno o più pacchetti dal sistema
    repolist                  visualizza i repository del software configurati
    repoquery                 ricerca i pacchetti che corrispondono a una parola chiave
    repository-packages       esegue comandi su tutti i pacchetti presenti in un determinato repository
    search                    ricerca i dettagli dei pacchetti per la stringa data
    shell                     esegue una shell DNF interattiva
    swap                      esegue una mod DNF interattiva per rimuovere e installare una specifica
    updateinfo                visualizza avvisi sui pacchetti
    upgrade                  aggiorna uno o più pacchetti sul sistema
    upgrade-minimal           aggiornamento, ma solo la corrispondenza del pacchetto più "recente" che risolve un problema che riguarda il vostro sistema

```

#### Uso di `dnf` per l'installazione dei pacchetti

Assumendo che sia già stata disinstallata l'utilità `wget` da un esercizio, utilizzeremo DNF per installare il pacchetto nei seguenti passaggi. Il processo in 2-3 passaggi necessario in precedenza quando abbiamo installato `wget` tramite `rpm` è diventato ora un processo in un unico passaggio utilizzando `dnf`. `dnf` risolverà silenziosamente qualsiasi dipendenza.

1. Per prima cosa, assicurarsi che `wget` e `libmetalink` siano stati disinstallati dal sistema. Digitare:

   ```bash
   sudo rpm -e wget libmetalink
   ```

   Dopo la rimozione, se si prova a eseguire `wget` dalla CLI, viene visualizzato un messaggio simile a _wget: command not found_

2. Ora usare `dnf` per installare `wget`. Digitare:

   ```bash
   sudo dnf -y install wget
   Dependencies resolved.
   ...<TRUNCATED>...
   Installed:
   libmetalink-*           wget-*
   Complete!
   ```

   !!! tip "Suggerimento"

   ```
    L'opzione "-y" utilizzata nel comando precedente sopprime il prompt "[y/N]" che richiede di confermare l'azione che `dnf` sta per eseguire. Ciò significa che tutte le azioni di conferma (o risposte interattive) saranno "sì" (y).
   ```

3. DNF offre un'opzione "Environment Group" che semplifica l'aggiunta di un nuovo set di funzionalità a un sistema. Per aggiungere la funzionalità, in genere è necessario installare alcuni pacchetti singolarmente, ma utilizzando `dnf`, è sufficiente conoscere il nome o la descrizione della funzionalità desiderata. Utilizzare `dnf` per visualizzare un elenco dei gruppi disponibili. Digitare:

   ```bash
   dnf group list
   ```

4. Il nostro interesse è rivolto al gruppo/funzionalità “ Development Tools”. Cerchiamo di ottenere maggiori informazioni su quel gruppo. Digitare:

   ```bash
   dnf group info "Development Tools"
   ```

5. Successivamente, avremo bisogno di alcuni programmi del gruppo "Development Tools". Installare il gruppo “Development Tools” utilizzando `dnf` eseguendo:

   ```bash
   sudo dnf -y group install "Development Tools"
   ```

#### Uso di `dnf` per disinstallare i pacchetti

1. Per utilizzare `dnf` per disinstallare il pacchetto `wget`, digitare:

   ```bash
   sudo dnf -y remove wget
   ```

2. Utilizzare `dnf` per assicurarsi che il pacchetto sia stato effettivamente rimosso dal sistema. Digitare:

   ```bash
   sudo dnf -y remove wget
   ```

3. Provare ad utilizzare/eseguire `wget`. Digitare:

   ```bash
   wget
   ```

#### Uso di `dnf` per l'aggiornamento dei pacchetti

DNF può verificare e installare l'ultima versione dei singoli pacchetti disponibili nei repository. Può anche essere utilizzato per installare versioni specifiche dei pacchetti.

1. Utilizzare l'opzione list con `dnf` per visualizzare le versioni disponibili del programma `wget` sul sistema. Digitare:

   ```bash
   dnf list wget
   ```

2. Se si vuole solo verificare se siano disponibili versioni aggiornate per un pacchetto, utilizzare l'opzione check-update con `dnf`. Ad esempio, per il pacchetto `wget`, digitare:

   ```bash
   dnf check-update wget
   ```

3. Ora, elencare tutte le versioni disponibili per il pacchetto kernel del sistema. Digitare:

   ```bash
   sudo dnf list kernel
   ```

4. Successivamente, verificare se sono disponibili pacchetti aggiornati per il pacchetto kernel installato. Digitare:

   ```bash
   dnf check-update kernel
   ```

5. Gli aggiornamenti dei pacchetti possono essere dovuti a correzioni di bug, nuove funzionalità o patch di sicurezza. Per verificare se sono disponibili aggiornamenti relativi alla sicurezza per il pacchetto kernel, digitare:

   ```bash
   dnf  --security check-update kernel
   ```

#### Uso di `dnf` per gli aggiornamenti del sistema

DNF può essere utilizzato per verificare e installare le versioni più recenti di tutti i pacchetti installati su un sistema. Il controllo periodico della disponibilità di aggiornamenti è un aspetto importante dell'amministrazione di sistema.

1. Per verificare se sono disponibili aggiornamenti per i pacchetti attualmente installati sul sistema, digitare:

   ```bash
   dnf check-update
   ```

2. Per verificare se sono disponibili aggiornamenti relativi alla sicurezza per tutti i pacchetti installati sul sistema, digitare:

   ```bash
   dnf --security check-update
   ```

3. Per aggiornare tutti i pacchetti installati sul sistema alle versioni più recenti disponibili per la tua distribuzione, eseguire:

   ```bash
   dnf -y check-update
   ```

## Esercizio 6

### Costruzione del software dai sorgenti

Tutti i software/applicazioni/pacchetti provengono da semplici file di testo leggibili dall'uomo. I file sono denominati nel loro insieme codice sorgente. I pacchetti RPM che vengono installati sulle distribuzioni Linux nascono dal codice sorgente.

In questo esercizio si scaricherà, compilerà e installerà un programma di esempio dai relativi file sorgente. Per comodità, i file sorgente vengono solitamente distribuiti come un unico file compresso chiamato tar-ball (pronunciato tar-dot-gee-zee).

I seguenti esercizi saranno basati sul venerabile codice sorgente del progetto Hello. `hello` è una semplice applicazione a riga di comando scritta in C++, che non fa altro che stampare "hello" sul terminale. Per ulteriori informazioni sul progetto, consultare [il sito qui](http://www.gnu.org/software/hello/hello.html)

#### Download del file sorgente

1. Utilizzare `curl` per scaricare il codice sorgente più recente dell'applicazione `hello`. Scaricare e salvare il file nella cartella Download.

   https://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz

#### Decomprimere il file

1. Passare alla directory sul computer locale dove è stato scaricato il codice sorgente hello.

2. Decomprimere (un-tar) il tarball utilizzando il programma `tar`. Digitare:

   ```bash
   tar -xvzf hello-2.12.tar.gz
   ```

   OUTPUT:

   ```bash
   $ tar -xvzf hello-2.12.tar.gz
   hello-2.12/
   hello-2.12/NEWS
   hello-2.12/AUTHORS
   hello-2.12/hello.1
   hello-2.12/THANKS
   ...<TRUNCATED>...
   ```

3. Utilizzare il comando `ls` per visualizzare il contenuto della directory corrente.

   Durante la decompressione dovrebbe essere stata creata una nuova directory denominata  hello-2.12.

4. Passare a quella directory ed elencarne il suo contenuto. Digitare:

   ```bash
   cd hello-2.12 ; ls
   ```

5. È sempre buona norma consultare eventuali istruzioni di installazione speciali fornite insieme al codice sorgente. Questi file hanno solitamente nomi come: INSTALL, README e così via.

   Utilizzare un pager per aprire il file INSTALL e leggerlo. Digitare:

   ```bash
   less INSTALL
   ```

   Uscire dal pager quando si è finito di esaminare il file.

#### Configurazione del pacchetto

La maggior parte delle applicazioni dispone di funzioni che possono essere attivate o disattivate dall'utente. Questo è uno dei vantaggi di avere accesso al codice sorgente e di installarlo da lì. Avete il controllo sulle funzionalità configurabili dell'applicazione. Questo è in contrasto con l'accettazione di tutto ciò che un gestore di pacchetti installa dai binari precompilati.

Lo script che solitamente consente di configurare il software è denominato, in modo appropriato, "configure"

!!! tip "Suggerimento"

````
Assicurarsi di aver installato il pacchetto "Development Tools" prima di provare a completare i seguenti esercizi.

```bash
sudo dnf -y group install "Development Tools"
```
````

1. Utilizzare nuovamente il comando `ls` per assicurarti che nella directory corrente sia effettivamente presente un file denominato _configure_.

2. Per visualizzare tutte le opzioni che si possono attivare o disattivare nel programma `hello`, digitare:

   ```bash
   ./configure --help
   ```

   !!! question "Domanda"

   ```
   Dall'output del comando, cosa fa l'opzione "--prefix"?
   ```

3. Se si è soddisfatti delle opzioni predefinite offerte dallo script di configurazione. Digitare:

   ```bash
   ./configure
   ```

   !!! note "Nota"

   ```
    Si spera che la fase di configurazione sia andata liscia e che si possa passare alla fase di compilazione.

    Se durante la fase di configurazione vengono visualizzati degli errori, è necessario esaminare attentamente la parte finale dell'output per individuare la causa dell'errore. Gli errori sono *talvolta* intuitivi e facili da correggere. Ad esempio, potrebbe essere visualizzato un errore simile al seguente:

    configure: error: no acceptable C compiler found in $PATH

    L'errore sopra riportato significa semplicemente che non hai un compilatore C (ad esempio, `gcc`) installato sul sistema o che il compilatore è installato in una posizione che non è inclusa nella variabile PATH.
   ```

#### Compilazione del pacchetto

Nei passaggi seguenti si costruirà l'applicazione hello. È qui che tornano utili alcuni dei programmi inclusi nel gruppo Development Tools installati in precedenza utilizzando DNF.

1. Utilizzare il comando make per compilare il pacchetto dopo aver eseguito lo script "configure". Digitare:

   ```bash
   make
   ```

   OUTPUT:

   ```bash
   $ make
   ...<OUTPUT TRUNCATED>...
   gcc  -g -O2   -o hello src/hello.o  ./lib/libhello.a
   make[2]: Leaving directory '/home/rocky/hello-2.12'
   make[1]: Leaving directory '/home/rocky/hello-2.12'
   ```

   Se tutto è andato bene, questo importante passaggio “make” è il passo che contribuirà a generare il binario finale dell’applicazione “hello”.

2. Elencare nuovamente i file nella directory di lavoro corrente. Si dovrebbero visualizzare alcuni file appena creati, incluso il programma `hello`.

#### Installazione dell'applicazione

Oltre ad altre attività di manutenzione, la fase finale dell'installazione prevede anche la copia di tutti i file binari e le librerie dell'applicazione nelle cartelle appropriate.

1. Per installare l'applicazione hello, eseguire il comando make install. Digitare:

   ```bash
   sudo make install
   ```

   Questo installerà il pacchetto nella posizione specificata dall'argomento predefinito prefisso (--prefix) che è stato utilizzato in precedenza con lo script “configure”. Se non è stato impostato alcun --prefix, verrà utilizzato il prefisso predefinito `/usr/local/`.

#### Esecuzione del programma hello

1. Utilizzare il comando `whereis` per vedere dove si trova il programma `hello` nel sistema. Digitare:

   ```bash
   whereis hello
   ```

2. Provare a eseguire l'applicazione `hello` per verificarne il funzionamento. Digitare:

   ```bash
   hello
   ```

3. Eseguire nuovamente `hello` con l'opzione `--help` per vedere le altre funzioni disponibili.

4. Ora, utilizzando `sudo`, eseguire nuovamente `hello` come superutente. Digitare:

   ```bash
   sudo hello
   ```

   OUTPUT:

   ```bash
   sudo: hello: comando non trovato
   ```

   !!! question "Domanda"

   ```
    Individua la causa dell'errore che si verifica quando provi a eseguire `hello` con `sudo`. Risolvi il problema e assicurati che il programma `hello` possa essere utilizzato con `sudo`.
   ```

   !!! tip "Suggerimento"

   ```
    È buona norma testare un programma come utente normale per assicurarsi che gli utenti normali possano effettivamente utilizzarlo. È possibile che i permessi sul file binario siano impostati in modo errato, consentendo solo al superutente di utilizzare i programmi. Questo ovviamente presuppone che si desideri effettivamente che gli utenti normali possano utilizzare il programma.
   ```

5. Ecco fatto. Questo esercizio è terminato!

## Esercizio 7

### Verifica dell'integrità dei file dopo l'installazione del pacchetto

Dopo aver installato i pacchetti pertinenti, in alcuni casi è necessario verificare se i file associati sono stati modificati per impedire modifiche dannose da parte di altri.

#### Verifica dei file

Utilizzando l'opzione "-V" del comando `rpm`.

Prendiamo come esempio il programma di sincronizzazione dell'ora `chrony` per illustrare il significato dei suoi output.

1. Per dimostrare come funziona la verifica del pacchetto `rpm`, apportare una modifica al file di configurazione di chrony - `/etc/chrony.conf`. (It is assumed that you have installed chrony). Aggiungiamo 2 innocui simboli di commento `##` alla fine del file. Digitare:

   ```bash
   echo -e "##"  | sudo tee -a /etc/chrony.conf
   ```

2. Ora eseguire il comando `rpm` con l'opzione `--verify`. Digitare:

   ```bash
   rpm -V chrony
   ```

   OUTPUT:

   ```bash
   S.5....T.  c  /etc/chrony.conf
   ```

   Il risultato è suddiviso in 3 colonne separate.

   - **Prima colonna (S.5.... T.)**

     Utilizza 9 campi per rappresentare le informazioni valide del file dopo l'installazione del pacchetto software RPM. Qualsiasi campo o caratteristica che ha superato un determinato controllo/test è indicato da un “.”.

     Di seguito sono descritti questi 9 differenti campi o controlli:

     - S: Se è stata modificata la dimensione del file.
     - M: Se il tipo di file o i permessi del file (rwx) sono stati modificati.
     - 5: Se il checksum MD5 del file è stato modificato.
     - D: Se il numero del dispositivo è stato modificato.
     - L: Se il percorso del file è stato modificato.
     - U: Se il proprietario del file è stato modificato.
     - G: Se il gruppo a cui appartiene il file è stato modificato.
     - T: Se l'ora di modifica (mTime) del file è stata modificata.
     - P: Se la funzione del programma è stata modificata.

   - **Seconda colonna (c)**

     **c** indica le modifiche apportate al file di configurazione. Può anche assumere i seguenti valori:

     - d: file di documentazione
     - g: file ghost. Se ne vedono pochissimi
     - l: file di licenza
     - r: file readme

   - **Terza colonna (/etc/chrony.conf)**

     - **/etc/chrony.conf**: Rappresenta il percorso del file modificato.
