- - -
title: Gestione e installazione del software (Laboratorio 7) author: Wale Soyinka contributors: Steven Spencer, tianci li tested on: 8.8 tags:
  - lab exercise
  - software management
- - -

# Laboratorio 7: Gestione e installazione del software

## Obiettivi

Dopo aver completato questo laboratorio, potrai

- Interrogare i pacchetti per ottenere informazioni
- Installare software da pacchetti binari
- Risolvere alcuni problemi di dipendenza di base
- Compilare e installare il software dai sorgenti

Tempo stimato per completare questo laboratorio: 90 minuti

## File binari e file sorgente

Le applicazioni attualmente installate sul sistema dipendono da alcuni fattori. Il fattore principale dipende dai gruppi di pacchetti software selezionati durante l'installazione del sistema operativo. L'altro fattore dipende da ciò che è stato fatto al sistema dal suo utilizzo.

Uno dei compiti di routine di un amministratore di sistema è la gestione del software. Questo spesso comporta:

- installazione di un nuovo software
- disinstallazione del software
- aggiornamento del software già installato

Il software può essere installato su sistemi basati su Linux utilizzando diversi metodi. È possibile installare dai sorgenti o dai binari precompilati. Quest'ultimo metodo è il più semplice, ma anche il meno personalizzabile. Quando si installa da binari precompilati, la maggior parte del lavoro è già stato fatto per voi, ma anche in questo caso è necessario conoscere il nome e la posizione del software desiderato.

Quasi tutti i software vengono originariamente forniti come file sorgente del linguaggio di programmazione C o C++. I programmi sorgente sono solitamente distribuiti come archivi di file sorgente. Di solito file tar o gzip o bzip2. Ciò significa che sono disponibili compressi o in un unico pacchetto.

La maggior parte degli sviluppatori ha reso il proprio codice sorgente conforme agli standard GNU, rendendolo più facile da condividere. Significa anche che i pacchetti verranno compilati su qualsiasi sistema UNIX o UNIX-like (ad esempio, Linux).

RPM è lo strumento di base per la gestione delle applicazioni (pacchetti) sulle distribuzioni basate su Red Hat come Rocky Linux, Fedora, Red Hat Enterprise Linux (RHEL), openSuSE, Mandrake e così via.

Le applicazioni utilizzate per la gestione del software sulle distribuzioni Linux sono chiamate gestori di pacchetti. Esempi sono:

- Il gestore di pacchetti Red Hat (`rpm`). I pacchetti hanno il suffisso " .rpm"
- Il sistema di gestione dei pacchetti Debian (`dpkg`).  I pacchetti hanno il suffisso " .deb"

Di seguito sono elencate alcune opzioni della riga di comando e la sintassi del comando RPM:

**rpm**

Uso: rpm [OPZIONE...]

**INTERROGARE I PACCHETTI**

```
Opzioni di interrogazione (con -q o --query):
  -c, --configfiles elenca tutti i file di configurazione
  -d, --docfiles elenca tutti i file di documentazione
  -L, --licensefiles elenca tutti i file di licenza
  -A, --artifactfiles elenca tutti i file degli artefatti
      --dump elenca le informazioni di base sui file
  -l, --list elenca i file del pacchetto
      --queryformat=QUERYFORMAT utilizza il seguente formato di query
  -s, --state visualizza gli stati dei file elencati
```

**VERIFICA DEI PACCHETTI**

```
Opzioni di verifica (con -V o --verify):
      --nofiledigest non verifica il digest dei file
      --nofiles non verifica i file del pacchetto
      --nodeps non verifica le dipendenze del pacchetto
      --noscript non esegue gli script di verifica
```

**INSTALLARE, AGGIORNARE E RIMUOVERE I PACCHETTI**

```
Opzioni di installazione/aggiornamento/cancellazione:
      --allfiles installa tutti i file, anche le configurazioni che altrimenti potrebbero essere saltate
  -e, --erase=<package>+ cancella (disinstalla) il pacchetto
      --excludedocs non installa la documentazione
      --excludepath=<path> salta i file con il componente principale <path>
      --forza abbreviazione di --replacepkgs --replacefiles
  -F, --freshen=<packagefile>+ aggiorna i pacchetti se già installati
  -h, --hash stampa i segni di hash durante l'installazione dei pacchetti (ottimo con -v)
      --noverify abbreviazione di --ignorepayload --ignoresignature
  -i, --install installa i pacchetti
      --nodeps non verifica le dipendenze dei pacchetti
      --noscripts non esegue gli scriptlet dei pacchetti
      --percent stampa le percentuali durante l'installazione del pacchetto
      --prefix=<dir> ricolloca il pacchetto in <dir>, se ricollocabile
      --relocate=<old>=<new> ricollocare i file dal percorso <old> a <new>
      --replacefiles ignora i conflitti di file tra i pacchetti
      --replacepkgs reinstalla se il pacchetto è già presente
      --test non installa, ma dice se funzionerebbe o meno
  -U, --upgrade=<packagefile>+ aggiorna i pacchetti
      --reinstall=<packagefile>+ reinstallare il/i pacchetto/i
```

## Esercizio 1

### Installazione, interrogazione e disinstallazione dei pacchetti

In questo laboratorio imparerete a usare il sistema RPM e installerete un'applicazione di esempio sul vostro sistema.

!!! tip "Suggerimento"

    Avete molte opzioni per ottenere i pacchetti Rocky Linux. È possibile scaricarli manualmente da repository affidabili [o non affidabili]. È possibile ottenerli dalla ISO di distribuzione. È possibile ottenerli da una posizione condivisa a livello centrale utilizzando protocolli come nfs, git, https, ftp, smb, cifs e così via. Se siete curiosi, potete consultare il seguente sito web ufficiale e sfogliare il repository applicabile per i pacchetti desiderati:
    
    https://download.rockylinux.org/pub/rocky/8.8/

#### Per interrogare i pacchetti per ottenere informazioni.

1. Per visualizzare un elenco di tutti i pacchetti attualmente installati sul sistema locale, digitate:

    ```
    $ rpm -qa
    python3-gobject-base-*
    NetworkManager-*
    rocky-repos-*
    ...<OUTPUT TRUNCATED>...
    ```

    Dovrebbe apparire un lungo elenco.

2. Approfondiamo un po' la questione e scopriamo di più su uno dei pacchetti installati nel sistema. Esamineremo NetworkManager. Utilizzeremo le opzioni --query (-q) e --info (-i) con il comando `rpm`. Digitate:

    ```
    $ rpm -qi NetworkManager
    Name        : NetworkManager
    Epoch       : 1
    ...<OUTPUT TRUNCATED>...
    ```

   Si tratta di una grande quantità di informazioni (metadati)!

3. Supponiamo di essere interessati solo al campo Riepilogo del comando precedente. Si può usare l'opzione --queryformat di rpm per filtrare le informazioni ottenute dall'opzione query.

    Ad esempio, per visualizzare solo il campo Riepilogo, digitare:

    ```
    $ rpm -q --queryformat '%{summary}\n' NetworkManager
    ```

    Il nome del campo è insensibile alle maiuscole e alle minuscole.

4. Per visualizzare i campi Versione e Riepilogo del tipo di pacchetto NetworkManager installato:

    ```
    $ rpm -q --queryformat '%{version}  %{summary}\n' NetworkManager 
    ```

5. Digitare il comando per visualizzare le informazioni sul pacchetto bash installato nel sistema.

    ```
    $ rpm -qi bash
    ```

    !!! note "Nota" 

     Gli esercizi precedenti consistevano nell'interrogare e lavorare con i pacchetti già installati nel sistema. Nei prossimi esercizi inizieremo a lavorare con i pacchetti non ancora installati. Utilizzeremo l'applicazione DNF per scaricare i pacchetti che utilizzeremo nei passi successivi.

6. Innanzitutto assicuratevi che l'applicazione `wget` non sia già installata sul sistema. Digita:

    ```
    $ rpm -q wget
    package wget is not installed
    ```

    Sembra che `wget` non sia installato sul nostro sistema demo.

7. A partire da Rocky Linux 8.x, il comando `dnf download` consente di ottenere l'ultimo pacchetto `rpm` per `wget`. Digita:

    ```
    dnf download wget
    ```

8. Usate il comando `ls` per assicurarvi che il pacchetto sia stato scaricato nella vostra directory corrente. Digita:

    ```
    $ ls -lh wg*
    ```

9. Usare il comando `rpm` per cercare informazioni sul file wget-*.rpm scaricato. Digita:

    ```
    $ rpm -qip wget-*.rpm
    Name        : wget
    Architecture: x86_64
    Install Date: (not installed)
    Group       : Applications/Internet
    ...<TRUNCATED>...
    ```

10. Dal risultato del passo precedente, qual'è esattamente il pacchetto `wget`? Suggerimento: è possibile utilizzare l'opzione di formato della query rpm per visualizzare il campo della descrizione del pacchetto scaricato.

11.  Se siete interessati al pacchetto `wget files-.rpm`, potete elencare tutti i file inclusi nel pacchetto digitando:

    ```
    $ rpm -qlp wget-*.rpm | head
    /etc/wgetrc
    /usr/bin/wget
    ...<TRUNCATED>...
    /usr/share/doc/wget/AUTHORS
    /usr/share/doc/wget/COPYING
    /usr/share/doc/wget/MAILING-LIST
    /usr/share/doc/wget/NEWS
    ```

12. Vediamo il contenuto del file `/usr/share/doc/wget/AUTHORS` che è elencato come parte del pacchetto `wget`. Utilizzeremo il comando `cat`. Digita:

    ```
    $ cat /usr/share/doc/wget/AUTHORS
    cat: /usr/share/doc/wget/AUTHORS: No such file or directory
    ```

    `wget` non è [ancora] installato sul nostro sistema demo! E quindi non è possibile visualizzare il file AUTHORS che viene fornito con esso!

13. Visualizza l'elenco dei file forniti con un altro pacchetto (curl) *già* installato nel sistema. Digita:

    ```
    $ rpm -ql curl
    /usr/bin/curl
    /usr/lib/.build-id
    /usr/lib/.build-id/fc
    ...<>...
    ```

    !!! note "Nota"

     Si noterà che nel comando precedente non è stato necessario fare riferimento al nome completo del pacchetto `curl`. Questo perché `curl` è già installato.

#### Conoscenza estesa sul nome del pacchetto

* **Nome completo del pacchetto**: quando si scarica un pacchetto da una fonte affidabile (ad esempio, il sito web del fornitore, il repository dello sviluppatore), il nome del file scaricato è il nome completo del pacchetto, ad esempio -- htop-3.2.1-1.el8.x86_64.rpm. Quando si usa il comando `rpm` per installare/aggiornare questo pacchetto, l'oggetto gestito dal comando deve essere il nome completo (o l'equivalente del carattere jolly) del pacchetto, come ad esempio:

    ```
    $ rpm -ivh htop-3.2.1-1.el8.x86_64.rpm
    ```

    ```
    $ rpm -Uvh htop-3.2.1-1.*.rpm
    ```

    ```
    $ rpm -qip htop-3.*.rpm
    ```

    ```
    $ rpm -qlp wget-1.19.5-11.el8.x86_64.rpm
    ```


    Il nome completo del pacchetto segue una convenzione di denominazione simile a questa —— `[Package_Name]-[Version]-[Release].[OS].[Arch].rpm` or `[Package_Name]-[Version]-[Release].[OS].[Arch].src.rpm`

* **Nome del pacchetto**: Poiché RPM utilizza un database per gestire il software, una volta completata l'installazione del pacchetto, il database avrà i record corrispondenti. A questo punto, l'oggetto operativo del comando `rpm` deve solo digitare il nome del pacchetto. come ad esempio:

    ```
    $ rpm -qi bash
    ```

    ```
    $ rpm -q systemd
    ```

    ```
    $ rpm -ql chrony
    ```



## Esercizio 2

### Integrità del pacchetto

1. È possibile scaricare o ritrovarsi con un file corrotto o contaminato. Verificare l'integrità del pacchetto `wget` scaricato. Digita:

    ```
    $ rpm -K  wget-*.rpm
    wget-1.19.5-10.el8.x86_64.rpm: digests signatures OK
    ```

    Il messaggio "digests signatures OK" nell'output mostra che il pacchetto è a posto.

2. Facciamo finta di essere malintenzionati e alteriamo deliberatamente il pacchetto scaricato. Questo può essere fatto aggiungendo o togliendo qualcosa al pacchetto originale.  Qualsiasi cosa che modifichi il pacchetto in un modo che non era nelle intenzioni di chi lo ha confezionato originariamente, corromperà il pacchetto stesso. Modificheremo il file utilizzando il comando echo per aggiungere la stringa "haha" al pacchetto. Digita:

    ```
    $ echo haha >> wget-1.19.5-10.el8.x86_64.rpm 
    ```

3. Ora provate a verificare nuovamente l'integrità del pacchetto usando l'opzione -K di rpm.

    ```
    $ rpm -K  wget-*.rpm
    wget-1.19.5-10.el8.x86_64.rpm: DIGESTS SIGNATURES NOT OK
    ```

    Ora il messaggio è molto diverso. L'output "DIGESTS SIGNATURES NOT OK" avverte chiaramente che non si deve provare a usare o installare il pacchetto. Non ci si deve più fidare.

4. Usare il comando `rm` per eliminare il file danneggiato del pacchetto `wget` e scaricarne una nuova copia usando `dnf`. Digitare:

    ```
    $ rm wget-*.rpm  && dnf download wget
    ```

    Verificare ancora una volta che il pacchetto appena scaricato superi i controlli di integrità di RPM.

## Esercizio 3

### Installazione dei Pacchetti

Mentre si cerca di installare un software sul sistema, può capitare di imbattersi in problemi di "dipendenze fallite". Questo è particolarmente comune quando si usa l'utilità di basso livello RPM per gestire manualmente le applicazioni su un sistema.

Ad esempio, se si tenta di installare il pacchetto "abc.rpm", il programma di installazione RPM potrebbe lamentarsi di alcune dipendenze non riuscite. Potrebbe dirvi che il pacchetto "abc.rpm" richiede l'installazione di un altro pacchetto "xyz.rpm". Il problema delle dipendenze si pone perché le applicazioni software dipendono quasi sempre da un altro software o da un'altra libreria. Se un programma richiesto o una libreria condivisa non è già presente sul sistema, tale prerequisito deve essere soddisfatto prima di installare l'applicazione di destinazione.

L'utilità RPM di basso livello spesso conosce le interdipendenze tra le applicazioni. Ma di solito non sa come o dove ottenere l'applicazione o la libreria necessaria per risolvere il problema. In altre parole, l'RPM conosce il *cosa* e il *come*, ma non ha la capacità di rispondere alla domanda sul *dove*. È qui che si distinguono strumenti come `dnf`, `yum` e così via.

#### Per installare i pacchetti

In questo esercizio si cercherà di installare il pacchetto `wget` (wget-*.rpm).

1. Provare a installare l'applicazione `wget`. Utilizzare le opzioni della riga di comando -ivh di RPM. Digitare:

    ```
    $ rpm -ivh wget-*.rpm
    error: Failed dependencies:
        libmetalink.so.3()(64bit) is needed by wget-*
    ```

    Subito - un problema di dipendenza! L'output di esempio mostra che `wget` ha bisogno di un qualche file di libreria chiamato "libmetalink.so.3"

    !!! note "Nota"

     Secondo l'esito del test precedente, il pacchetto wget-*.rpm richiede l'installazione del pacchetto libmetalink-*.rpm. In altre parole, libmetalink è un prerequisito per installare wget-*.rpm. È possibile installare forzatamente il pacchetto wget-*.rpm utilizzando l'opzione "nodeps" se si sa assolutamente cosa si sta facendo, ma questa è generalmente una CATTIVA pratica.

2. RPM ci ha dato un suggerimento su ciò che manca. Si ricorderà che gli rpm conoscono il cosa e il come, ma non necessariamente il dove. Utilizziamo l'utilità `dnf` per cercare di capire il nome del pacchetto che fornisce la libreria mancante. Digitare:

    ```
    $ dnf whatprovides libmetalink.so.3
    ...<TRUNCATED>...
    libmetalink-* : Metalink library written in C
    Repo        : baseos
    Matched from:
    Provide    : libmetalink.so.3
    ```

3. Dall'output, dobbiamo scaricare il pacchetto `libmetalink` che fornisce la libreria mancante. In particolare, vogliamo la versione a 64 bit della libreria. Utilizziamo un'utilità separata (`dnf`) per trovare e scaricare il pacchetto per la nostra architettura demo a 64 bit (x86_64). Digitate:

    ```
    dnf download --arch x86_64  libmetalink
    ```

4. A questo punto si dovrebbero avere almeno 2 pacchetti rpm nella directory di lavoro. Per confermarlo, utilizzare il comando `ls`.

5. Installare la dipendenza mancante di `libmetalink`. Digitare:

    ```
    $ sudo rpm -ivh libmetalink-*.rpm
    ```

6. Con la dipendenza ora installata, possiamo tornare al nostro obiettivo iniziale di installare il pacchetto `wget`. Digitare:

    ```
    $ sudo rpm -ivh wget-*.rpm
    ```

    !!! note "Nota"

     RPM supporta le transazioni. Negli esercizi precedenti, avremmo potuto eseguire una singola transazione rpm che includeva il pacchetto originale che volevamo installare e tutti i pacchetti e le librerie da cui dipendeva. Sarebbe stato sufficiente un singolo comando come quello riportato di seguito:

            ```
            $  rpm -Uvh  wget-*.rpm  libmetalink-*.rpm
            ```

7. È il momento della verità. Provare a eseguire il programma `wget` senza alcuna opzione per verificare se è installato. Digitare:

    ```
    $ wget
    ```

8. Vediamo `wget` in azione. Usate `wget` per scaricare un file da Internet dalla riga di comando. Digitare:

    ```
    wget  https://kernel.org
    ```

    Questo scaricherà l'index.html predefinito dal sito web kernel.org!

9. Utilizzare `rpm` per visualizzare un elenco di tutti i file forniti con l'applicazione `wget`.

10. Utilizzate `rpm` per visualizzare la documentazione fornita con `wget`.

11. Utilizzate `rpm` per visualizzare l'elenco di tutti i binari installati con il pacchetto `wget`.

12. È stato necessario installare il pacchetto `libmetalink` per poter installare `wget`. Provate a eseguire `libmetalink` dalla riga di comando. Digitare:

    ```
    $ libmetalink
    -bash: libmetalink: command not found
    ```

    !!! attention "Attenzione"

     Cosa succede? Perché non è possibile eseguire `libmetalink`?


#### Per importare una chiave pubblica tramite rpm

!!! tip "Suggerimento" 

    Le chiavi GPG utilizzate per firmare i pacchetti del progetto Rocky Linux possono essere ottenute da varie fonti, come il sito web del progetto, il sito ftp, i supporti di distribuzione, le fonti locali e così via. Nel caso in cui la chiave corretta non sia presente nel portachiavi del vostro sistema RL, potete usare l'opzione `--import` di `rpm` per importare la chiave pubblica di Rocky Linux dal vostro sistema RL locale, eseguendo: `sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial`

!!! question "Domanda"

    Quando si installano i pacchetti, qual è la differenza tra `rpm -Uvh` e `rpm -ivh`. 
    Consultare la pagina man di `rpm`.

## Esercizio 4

### Disinstallazione dei pacchetti

Disinstallare i pacchetti è altrettanto facile che installarli, grazie al gestore di pacchetti di Red Hat (RPM).

 In questo esercizio si cercherà di usare `rpm` per disinstallare alcuni pacchetti dal sistema.

#### Per disinstallare i pacchetti

1. Disinstallare il pacchetto `libmetalink` dal sistema. Digitare:

    ```
    $ sudo rpm -e libmetalink
    ```

    !!! question "Domanda"

     Spiegare perché non è stato possibile rimuovere il pacchetto?


2. Il modo pulito e corretto di rimuovere i pacchetti utilizzando RPM è quello di rimuovere i pacchetti insieme alle loro dipendenze. Per rimuovere il pacchetto `libmetalink` dobbiamo rimuovere anche il pacchetto `wget` che dipende da esso. Digitare:

    ```
    $ sudo rpm -e libmetalink wget
    ```

    !!! note "Nota"

     Se si vuole interrompere il pacchetto che si basa su libmetalink e rimuovere *forzatamente* il pacchetto dal sistema, si può usare l'opzione `--nodeps` di rpm in questo modo: `$ sudo rpm -e --nodeps libmetalink`.
    
     L'opzione "nodeps" significa Nessuna dipendenza. Cioè, ignorare tutte le dipendenze.  
     **ii.** Quanto sopra serve solo a mostrare come rimuovere un pacchetto dal sistema in modo forzato. A volte è necessario farlo, ma in genere *non è una buona pratica*.   
     **iii.** La rimozione forzata di un pacchetto "xyz" su cui si basa un altro pacchetto installato "abc" rende di fatto il pacchetto "abc" inutilizzabile o in qualche modo danneggiato.

## Esercizio 5

### DNF - Gestore di pacchetti

DNF è un gestore di pacchetti per distribuzioni Linux basate su RPM. È il successore della popolare utility YUM. DNF mantiene la compatibilità con YUM ed entrambe le utility condividono opzioni e sintassi della riga di comando molto simili.

DNF è uno dei tanti strumenti per la gestione del software basato su RPM, come Rocky Linux. Rispetto a `rpm`, questi strumenti di livello superiore aiutano a semplificare l'installazione, la disinstallazione e l'interrogazione dei pacchetti. È importante notare che questi strumenti utilizzano la struttura sottostante fornita dal sistema RPM. Per questo motivo è utile capire come utilizzare RPM.

DNF (e altri strumenti simili) agisce come una sorta di involucro attorno a RPM e fornisce funzionalità aggiuntive non offerte da RPM. DNF sa come gestire le dipendenze di pacchetti e librerie e sa anche come utilizzare i repository configurati per risolvere automaticamente la maggior parte dei problemi.

Le opzioni più comuni utilizzate con l'utilità `dnf` sono:

```
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

#### Per utilizzare `dnf` per l'installazione dei pacchetti

Supponendo che abbiate già disinstallato l'utilità `wget` da un esercizio, nei passi seguenti useremo DNF per installare il pacchetto. Il processo di 2-3 passi che abbiamo richiesto in precedenza quando abbiamo installato `wget` tramite `rpm` dovrebbe essere ridotto a un solo passo utilizzando `dnf`. `dnf` risolverà tranquillamente qualsiasi dipendenza.

1. Per prima cosa, assicuriamoci che `wget` e `libmetalink` siano disinstallati dal sistema. Digitare:

    ```
    $ sudo rpm -e wget libmetalink
    ```

    Dopo la rimozione, se si prova a eseguire `wget` dalla CLI, viene visualizzato un messaggio come *wget: command not found*

2. Ora usate dnf per installare `wget`. Digitare:

    ```
    $ sudo dnf -y install wget
    Dependencies resolved.
    ...<TRUNCATED>...
    Installed:
    libmetalink-*           wget-*
    Complete!
    ```

    !!! tip "Suggerimento"

     L'opzione "-y" usata nel comando precedente sopprime il prompt "[y/N]" per confermare l'azione che `dnf` sta per eseguire. Ciò significa che tutte le azioni di conferma (o le risposte interattive) saranno "sì" (y).


3. DNF offre un'opzione " Environment Group" che semplifica l'aggiunta di un nuovo set di funzioni a un sistema. Per aggiungere la funzionalità, in genere si dovrebbero installare alcuni pacchetti singolarmente, ma usando `dnf`, tutto ciò che occorre sapere è il nome o la descrizione della funzionalità desiderata. Usare `dnf` per visualizzare un elenco di tutti i gruppi disponibili. Digitare:

    ```
    $ dnf group list
    ```

4. Siamo interessati al gruppo/caratteristica "Development Tools". Cerchiamo di ottenere maggiori informazioni su questo gruppo. Digitare:

    ```
   $ dnf group info "Development Tools"
   ```

5. In seguito, avremo bisogno di alcuni programmi del gruppo " Development Tools". Installare il gruppo "Development Tools" utilizzando `dnf`:

    ```
    $ sudo dnf -y group install "Development Tools"
    ```

#### Per usare `dnf` per disinstallare i pacchetti


1. Per usare `dnf` per disinstallare il pacchetto `wget`, digitare:

    ```
    $ sudo dnf -y remove wget
    ```

2. Usate `dnf` per assicurarsi che il pacchetto sia stato effettivamente rimosso dal sistema. Digitare:

    ```
    $ sudo dnf -y remove wget
    ```

3. Provare a utilizzare/eseguire `wget`. Digitare:

    ```
    $ wget
    ```

#### Per utilizzare `dnf` per l'aggiornamento dei pacchetti

DNF può verificare e installare l'ultima versione dei singoli pacchetti disponibili nei repository. Può anche essere usato per installare versioni specifiche di pacchetti.

1. Usate l'opzione list con `dnf` per visualizzare tutte le versioni del programma `wget` disponibili per il vostro sistema. Digita

    ```
    $ dnf list wget
    ```

2. Se si vuole solo vedere se sono disponibili versioni aggiornate di un pacchetto, si può usare l'opzione check-update di `dnf`. Ad esempio, per il tipo di pacchetto `wget`:

    ```
    $ dnf check-update wget
    ```

3. Ora elenca tutte le versioni disponibili del pacchetto kernel per il vostro sistema. Digitare:

    ```
    $ sudo dnf list kernel
    ```

4. Ora controllate se sono disponibili pacchetti aggiornati per il pacchetto kernel installato. Digitare:

    ```
    $ dnf  check-update kernel
    ```

5. Gli aggiornamenti dei pacchetti possono essere dovuti a correzioni di bug, nuove funzionalità o patch di sicurezza. Per vedere se ci sono aggiornamenti relativi alla sicurezza per il pacchetto kernel, digitate:

    ```
    $ dnf  --security check-update kernel
    ```

#### Per utilizzare `dnf` per gli aggiornamenti del sistema

DNF può essere usato per verificare e installare le ultime versioni di tutti i pacchetti installati su un sistema. Il controllo periodico dell'installazione degli aggiornamenti è un aspetto importante dell'amministrazione del sistema.

1. Per verificare la presenza di aggiornamenti per i pacchetti attualmente installati sul sistema, digitate:

    ```
    $ dnf check-update
    ```

2. Per verificare la presenza di aggiornamenti di sicurezza per tutti i pacchetti installati sul sistema, digitate:

    ```
    $ dnf --security check-update
    ```

3. Per aggiornare tutti i pacchetti installati sul sistema alle versioni più aggiornate disponibili per la vostra distribuzione, eseguite:

    ```
    $ dnf -y check-update
    ```

## Esercizio 6

### Costruire il software dai sorgenti

Tutti i software/applicazioni/pacchetti provengono da semplici file di testo leggibili dall'uomo. I file sono conosciuti collettivamente come codice sorgente. I pacchetti RPM che vengono installati sulle distribuzioni Linux nascono dal codice sorgente.

In questo esercizio scaricherete, compilerete e installerete un programma di esempio dai suoi file sorgente originali. Per comodità, i file sorgenti sono solitamente distribuiti come un singolo file compresso chiamato tar-ball (pronuncia tar-dot-gee-zee).

I seguenti esercizi si basano sul codice sorgente del venerabile progetto Hello. `hello` è una semplice applicazione a riga di comando scritta in C++, che non fa altro che stampare "hello" sul terminale. Per saperne di più sul [progetto, cliccate qui](http://www.gnu.org/software/hello/hello.html)

#### Per scaricare il file sorgente

1. Usare `curl` per scaricare l'ultimo codice sorgente dell'applicazione `hello`. Scarichiamo e salviamo il file nella cartella Download.

    https://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz

#### Per decomprimere il file

1. Passare alla cartella del computer locale in cui è stato scaricato il codice sorgente di hello.

2. Decomprimere (un-tar) il tarball usando il programma `tar`. Digitare:

    ```
    $ tar -xvzf hello-2.12.tar.gz
    hello-2.12/
    hello-2.12/NEWS
    hello-2.12/AUTHORS
    hello-2.12/hello.1
    hello-2.12/THANKS
    ...<TRUNCATED>...
    ```

3. Usate il comando `ls` per visualizzare il contenuto della vostra pwd.

    Una nuova cartella denominata hello-2.12 dovrebbe essere stata creata durante la decompressione.

4. Passate a quella directory ed elencatene il contenuto. Digitare:

    ```
    $ cd hello-2.12 ; ls
    ```

5. È sempre buona norma esaminare tutte le istruzioni di installazione speciali che possono essere fornite con il codice sorgente. Questi file hanno solitamente nomi come: INSTALL, README e così via.

    Utilizzare un pager per aprire il file INSTALL e leggerlo. Digitare:

    ```
    $ less INSTALL
    ```

    Uscire dal pager quando si è finito di esaminare il file.

#### Per configurare il pacchetto

La maggior parte delle applicazioni ha funzioni che possono essere attivate o disattivate dall'utente. Questo è uno dei vantaggi dell'accesso al codice sorgente e dell'installazione dallo stesso. L'utente ha il controllo sulle caratteristiche configurabili dell'applicazione; questo è in contrasto con l'accettazione di tutto ciò che un gestore di pacchetti installa da binari precompilati.

Lo script che di solito permette di configurare il software si chiama "configure"

1. Usate di nuovo il comando `ls` per assicurarvi di avere un file chiamato *configure* nella vostra pwd.

2. Per visualizzare tutte le opzioni, è possibile attivare o disattivare il tipo di programma `hello`:

    ```
    $ ./configure --help
    ```

    !!! question "Domanda"

     Dall'output del comando, cosa fa l'opzione "--prefix"?

3. Se si è soddisfatti delle opzioni predefinite offerte dallo script di configurazione. Digitare:

    ```
    $ ./configure
    ```

    !!! note "Nota"

     Si spera che la fase di configurazione sia andata bene e che si possa passare alla fase di compilazione.

    Se si sono verificati degli errori durante la fase di configurazione, è necessario esaminare attentamente la coda dell'output per individuare la fonte dell'errore. Gli errori sono *talvolta* autoesplicativi e facili da risolvere. Ad esempio, potrebbe essere visualizzato un errore del tipo:

    configure: error: no acceptable C compiler found in $PATH

    L'errore di cui sopra significa semplicemente che non avete un compilatore C (ad esempio, gcc) installato sul sistema o che il compilatore è installato da qualche parte che non è nella vostra variabile PATH.

#### Per compilare il pacchetto

L'applicazione hello verrà realizzata nei seguenti passaggi. A questo punto sono utili alcuni dei programmi del gruppo Development Tools installati in precedenza con DNF.

1. Usate il comando make per compilare il pacchetto dopo aver eseguito lo script "configure". Digitate:

    ```
    $ make
    ...<OUTPUT TRUNCATED>...
    gcc  -g -O2   -o hello src/hello.o  ./lib/libhello.a
    make[2]: Leaving directory '/home/rocky/hello-2.12'
    make[1]: Leaving directory '/home/rocky/hello-2.12'
    ```

    Se tutto va bene, questo importante passo di `creazione` è quello che aiuterà a generare il binario finale dell'applicazione `hello`.

2. Elencare nuovamente i file nella directory di lavoro corrente. Dovreste vedere alcuni file appena creati, tra cui il programma `hello`.

#### Per installare l'applicazione

Tra le altre operazioni di pulizia, la fase finale dell'installazione prevede anche la copia dei file binari e delle librerie delle applicazioni nelle cartelle corrette.

1. Per installare l'applicazione hello, eseguire il comando make install. Digitare:

    ```
    $ sudo make install
    ```

    Questo installerà il pacchetto nel percorso specificato dall'argomento predefinito del prefisso (--prefix), eventualmente usato con lo script "configure" precedente. Se non è stato impostato alcun --prefisso, verrà usato il prefisso predefinito di `/usr/local/`.

#### Per eseguire il programma hello

1. Usate il comando `whereis` per vedere dove si trova il programma `hello` sul vostro sistema. Digitare:

    ```
    $ whereis hello
    ```

2. Provate a eseguire l'applicazione `hello` per vedere cosa fa. Digitare:

    ```
    $ hello
    ```

3. Eseguite di nuovo `hello` con l'opzione `--help` per vedere le altre cose che può fare.

4. Utilizzando `sudo`, eseguire nuovamente `hello` come superutente. Digitare:

    ```
    $ sudo hello
    ```

    !!! tip "Suggerimento"

     È buona norma testare un programma come utente ordinario per assicurarsi che gli utenti ordinari possano effettivamente utilizzare il programma. È possibile che i permessi sul binario siano impostati in modo errato, in modo che solo il superutente possa utilizzare i programmi. Questo ovviamente presuppone che si voglia effettivamente che gli utenti ordinari possano utilizzare il programma.

5. Questo è quanto. Questo laboratorio è completo!

## Esercizio 7

### Verifica dell'integrità dei file dopo l'installazione del pacchetto

Dopo l'installazione di pacchetti rilevanti, in alcuni casi è necessario determinare se i file associati sono stati modificati per evitare modifiche dannose da parte di altri.

#### Verifica del file

Utilizzando l'opzione "-V" del comando `rpm`.

Prendiamo come esempio il programma di sincronizzazione temporale chrony per illustrare il significato del suo output. Si presume che sia stato installato chrony e che sia stato modificato il file di configurazione (/etc/chrony.conf)

```
$ rpm -V chrony
S.5....T.  c /etc/chrony.conf
```

* **S.5....T.**: Indica 9 informazioni utili nel contenuto del file di validazione e quelle non modificate sono rappresentate da ".". Le 9 informazioni utili sono:
  * S: Se è stata modificata la dimensione del file.
  * M: Se il tipo di file o i permessi del file (rwx) sono stati modificati.
  * 5: Se la somma di controllo MD5 del file è stata modificata.
  * D: Se il numero del dispositivo è stato modificato.
  * L: Se il percorso del file è stato modificato.
  * U: Se il proprietario del file è stato modificato.
  * G: Se il gruppo a cui appartiene il file è stato modificato.
  * T: Se il tempo mTime (tempo di modifica) del file è stato modificato.
  * P: Se la funzione del programma è stata modificata.

* **c**: Indica le modifiche apportate al file di configurazione. Può anche essere il seguente valore:
  * d: file di documentazione.
  * g: file fantasma. Se ne vedono pochissimi.
  * l: file di licenza.
  * r: file readme.

* **/etc/chrony.conf**: Rappresenta il percorso del file modificato.
