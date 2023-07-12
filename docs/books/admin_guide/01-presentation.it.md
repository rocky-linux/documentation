---
title: Introduzione a Linux
---

# Introduzione al Sistema Operativo Linux

In questo capitolo imparerete a conoscere le distribuzioni GNU/Linux.

****

**Obiettivi**: In questo capitolo imparerai a:

:heavy_check_mark: Descrivere le caratteristiche e le possibili architetture di un sistema operativo..   
:heavy_check_mark: Raccontare la storia di UNIX e GNU/Linux.   
:heavy_check_mark: Scegliete la distribuzione Linux più adatta alle vostre esigenze.   
:heavy_check_mark: Spiegare la filosofia del software libero e open-source.   
:heavy_check_mark: Scoprite l'utilità della shell.

:checkered_flag: **generalità**, **linux**, **distribuzioni**

**Conoscenza**: :star:    
**Complessità**: :star:

**Tempo di lettura**: 10 minuti

****

## Che cos'è un sistema operativo?

Linux, UNIX, BSD, Windows e MacOS sono tutti **sistemi operativi**.

!!! abstract "Astratto"

    Un sistema operativo è un **insieme di programmi che gestisce le risorse disponibili di un computer**.

Nell'ambito di questa gestione delle risorse, il sistema operativo deve:

* Gestire la memoria **fisica** o **virtuale**.
    * La **memoria fisica** è costituita dalle memorie RAM e dalla memoria cache del processore, utilizzate per l'esecuzione dei programmi.
    * La **memoria virtuale** è una posizione sul disco rigido (la partizione **swap**) che consente di svuotare la memoria fisica e di salvare lo stato attuale del sistema durante lo spegnimento elettrico del computer.
* Intercettare **l'accesso alle periferiche**. Raramente il software può accedere direttamente all'hardware (ad eccezione delle schede grafiche per esigenze molto specifiche).
* Fornire alle applicazioni una corretta **gestione delle attività**. Il sistema operativo è responsabile della pianificazione dei processi che occupano il processore.
* **Proteggere i file** da accessi non autorizzati.
* **Raccogliere informazioni** sui programmi in uso o in svolgimento.

![Funzionamento di un sistema operativo](images/operating_system.png)

## Generalità UNIX - GNU/Linux

### Storia

#### UNIX

* **1964 - 1968**: MULTICS (MULTiplexed Information and Computing Service) è stato sviluppato per il MIT, i Bell Labs (AT&T) e General Electric.

* **1969 — 1971**: Dopo il ritiro di Bell (1969) e poi di General Electric dal progetto, due sviluppatori, Ken Thompson e Dennis Ritchie (a cui si aggiunge in seguito Brian Kernighan), giudicando MULTICS troppo complesso, iniziano lo sviluppo di UNIX (UNiplexed Information and Computing Service). Sebbene sia stato originariamente creato in linguaggio Assembly, i creatori di UNIX svilupparono alla fine il linguaggio B e poi il linguaggio C (1971) e riscrissero completamente UNIX. Poiché è stato sviluppato nel 1970, la data di riferimento (epoch) per l'inizio del periodo di tempo dei sistemi UNIX/Linux è fissata al 01 gennaio 1970.

Il linguaggio C è ancora oggi uno dei linguaggi di programmazione più diffusi. Un linguaggio di basso livello, a contatto con l'hardware, che permette di adattare il sistema operativo a qualsiasi architettura di macchina dotata di un compilatore C.

UNIX è un sistema operativo aperto e in continua evoluzione che ha svolto un ruolo fondamentale nella storia dell'informatica. Costituisce la base di molti altri sistemi come Linux, BSD, MacOS e altri ancora.

UNIX è ancora rilevante oggi (HP-UX, AIX, Solaris, etc.)

#### Progetto GNU

* **1984**: Richard Matthew Stallman ha lanciato il progetto GNU (GNU's Not Unix), che si propone di creare un sistema Unix **libero** e **aperto**, in cui gli strumenti più importanti sono: il compilatore gcc, la shell bash, l'editor Emacs e così via. GNU è un sistema operativo simile ad Unix. Lo sviluppo di GNU, iniziato nel Gennaio 1984, è noto come Progetto GNU. Molti dei programmi presenti in GNU sono rilasciati sotto l'egida del Progetto GNU; questi vengono chiamati pacchetti GNU.

* **1990**: Il kernel di GNU, GNU Hurd, è stato creato nel 1990 (prima della nascita di Linux).

#### MINIX

* **1987**: Andrew S. Tanenbaum sviluppa MINIX, un UNIX semplificato, per insegnare i sistemi operativi in modo semplice. Il signor Tanenbaum rende disponibile il codice sorgente del suo sistema operativo.

#### Linux

* **1991**: Uno studente finlandese, **Linus Torvalds**, crea un sistema operativo che gira sul suo computer personale e lo chiama Linux. Pubblica la sua prima versione 0.02, sul forum di discussione Usenet e altri sviluppatori iniziano a contribuire al miglioramento del suo sistema. Il termine Linux è un gioco di parole tra il nome del fondatore, Linus, e UNIX.

* **1993**: Viene creata la distribuzione Debian. Debian è una distribuzione non commerciale, basata sulla comunità. Sviluppato originariamente per l'uso sui server, è molto indicato per questo ruolo; tuttavia è un sistema universale, utilizzabile anche su un personal computer. Debian costituisce la base per molte altre distribuzioni, come Mint o Ubuntu.

* **1994**: la distribuzione commerciale Red Hat viene creata dalla società Red Hat, che oggi è il principale distributore del sistema operativo GNU/Linux. Red Hat supporta la versione comunitaria Fedora e, fino a poco tempo fa, la distribuzione gratuita CentOS.

* **1997**: Viene creato l'ambiente desktop KDE. Si basa sulla libreria di componenti Qt e sul linguaggio di sviluppo C++.

* **1999**: Viene creato l'ambiente desktop GNOME. Basato sulla libreria di componenti GTK+.

* **2002**: Viene creata la distribuzione Arch. Il suo tratto distintivo è che offre una rolling release (aggiornamento continuo).

* **2004**: Ubuntu viene creato dalla società Canonical (Mark Shuttleworth). È basato su Debian ma include software libero e proprietario.

* **2021**: Viene creato Rocky Linux, basato sulla distribuzione Red Hat.

!!! info "Informazione"

    Disputa sul nome: anche se le persone sono abituate a chiamare il sistema operativo Linux verbalmente, Linux è propriamente il kernel. Non dobbiamo dimenticare lo sviluppo e il contributo del progetto GNU alla causa open source, quindi! Preferisco chiamarlo il sistema operativo GNU/Linux.

### Quota di mercato

<!--
TODO: graphics with market share for servers and pc.
-->

Nonostante la sua diffusione, Linux rimane relativamente sconosciuto al grande pubblico. Linux infatti è nascosto in **smartphone**, **televisori**, **internet box**, ecc. Quasi il **70% delle pagine web** servite nel mondo sono servite da un server Linux o UNIX!

Linux equipaggia poco più del **3% dei personal computer** ma più dell'**82% degli smartphone**. Il sistema operativo **Android**, ad esempio, utilizza un kernel Linux.

<!-- TODO: review those stats -->

Linux equipaggia il 100% dei 500 supercomputer dal 2018. Un supercomputer è un computer progettato per ottenere le massime prestazioni possibili con le tecniche conosciute al momento della sua progettazione, soprattutto per quanto riguarda la velocità di calcolo.

### Progettazione dell'architettura

* Il **kernel** è il primo componente software.
    * È il cuore del sistema Linux.
    * Gestisce le risorse hardware del sistema.
    * Gli altri componenti software devono passarvi attraverso per accedere all'hardware.
* La **shell** è un'utilità che interpreta i comandi dell'utente e ne garantisce l'esecuzione.
    * Shell principali: shell Bourne, shell C, shell Korn e shell Bourne-Again (bash).
* **Applicazioni** sono programmi utente inclusi, ma non limitati a:
    * Browser Internet
    * Elaboratore di testi
    * Fogli di calcolo

#### Multi-task

Linux appartiene alla famiglia dei sistemi operativi con condivisione del tempo. Divide il tempo di elaborazione tra diversi programmi, passando da uno all'altro in modo trasparente per l'utente. Questo implica:

* Esecuzione simultanea di più programmi.
* Distribuzione del tempo di CPU da parte dello scheduler.
* Riduzione dei problemi causati da un'applicazione interrotta.
* Prestazioni ridotte quando ci sono troppi programmi in esecuzione.

#### Multiutente

Lo scopo di MULTICS era quello di consentire a più utenti di lavorare su più terminali (schermo e tastiera) da un unico computer (all'epoca molto costoso). Linux, ispirandosi a questo sistema operativo, ha mantenuto la capacità di lavorare con più utenti contemporaneamente e in modo indipendente, ognuno dei quali dispone di un proprio account utente con spazio di memoria e diritti di accesso a file e software.

#### Multiprocessore

Linux è in grado di lavorare con computer multiprocessore o con processori multi-core.

#### Multipiattaforma

Linux è scritto in un linguaggio di alto livello che può essere adattato a diversi tipi di piattaforme durante la compilazione. Questo permette di funzionare su:

* Computer di casa (PC o laptop)
* Server (dati, applicazioni,...)
* Computer portatili (smartphone o tablet)
* Sistemi integrati (computer per auto)
* Elementi di rete attivi (router, switch)
* Elettrodomestici (TV, frigoriferi,...)

#### Aperto

Linux si basa su standard riconosciuti come [POSIX](http://en.wikipedia.org/wiki/POSIX), [TCP/IP](https://en.wikipedia.org/wiki/Internet_protocol_suite), [NFS](https://en.wikipedia.org/wiki/Network_File_System) e [Samba](https://en.wikipedia.org/wiki/Samba_(software)), che gli consentono di condividere dati e servizi con altri sistemi operativi.

### La filosofia UNIX/Linux

* Trattare tutto come un file.
* Portabilità del valore.
* Fai solo una cosa e falla bene.
* KISS: Mantienilo semplice stupido (Keep It Simple Stupid).
* "UNIX è fondamentalmente un sistema operativo semplice, Ma devi essere un genio per capirne la semplicità." (__Dennis Ritchie__)
* "Unix è facile da usare. Solamente che non è chiaro con quali utenti sia amichevole." (__Steven King__)

## Le distribuzioni GNU/Linux

Una distribuzione Linux è un **insieme coerente di software** assemblato attorno al kernel Linux e pronto per essere installato insieme ai componenti necessari per gestire questo software (installazione, rimozione, configurazione). Ci sono distribuzioni **associative** o **comunitarie** (Debian, Rocky) o **commerciali** (RedHat, Ubuntu).

Ogni distribuzione offre uno o più **ambienti desktop**, fornisce un set di software preinstallato e una libreria di software aggiuntivo. Le opzioni di configurazione (ad esempio le opzioni del kernel o dei servizi) sono specifiche per ogni distribuzione.

Questo principio permette alle distribuzioni di essere orientate ai **principianti** (Ubuntu, Linux Mint...) o completamente personalizzabili per gli **utenti avanzati** (Gentoo, Arch); le distribuzioni possono anche essere più adatte ai **server** (Debian, Red Hat) o alle **workstation** (Fedora).

### Ambienti desktop

Ci sono molti ambienti grafici: **GNOME**, **KDE**, **LXDE**, **XFCE**, etc. Ce n'è per tutti i gusti e l'**ergonomia** è all'altezza dei sistemi Microsoft o Apple.

Allora perché c'è così poco entusiasmo per Linux, quando questo sistema è praticamente **privo di virus**? Forse perché molti editori (Adobe) e produttori (Nvidia) non fanno il gioco della libertà e non forniscono una versione del loro software o __driver__ per GNU/Linux? Forse è la paura del cambiamento, o la difficoltà di trovare dove acquistare un computer Linux, o ancora i pochi giochi distribuiti sotto Linux. Almeno quest'ultima scusa non dovrebbe essere vera a lungo, con l'avvento del motore di gioco Steam per Linux.

![Desktop GNOME](images/01-presentation-gnome.png)

L'ambiente desktop di **GNOME 3** non utilizza più il concetto di desktop ma quello di GNOME Shell (da non confondere con la shell a riga di comando). Serve come desktop, come dashboard, area di notifica e selettore di finestre. L'ambiente desktop GNOME si basa sulla libreria di componenti GTK+.

![Desktop KDE](images/01-presentation-kde.png)

L'ambiente desktop **KDE** si basa sulla libreria di componenti **Qt**. È tradizionalmente consigliato agli utenti che hanno familiarità con l'ambiente Windows.

![Tux - La mascotte di Linux](images/tux.png)

### Libero / Open source

Un utente di un sistema operativo Microsoft o Mac deve acquistare una licenza per utilizzare il sistema operativo. Questa licenza ha un costo, anche se di solito è trasparente (il prezzo della licenza è incluso nel prezzo del computer).

Nel mondo **GNU/Linux**, il movimento del Software Libero fornisce principalmente distribuzioni gratuite.

**Libero** non significa gratuito!

**Open source**: i codici sorgente sono disponibili, quindi è possibile consultare e modificarli a determinate condizioni.

Un software libero è necessariamente open-source, ma non è vero il contrario, poiché il software open-source si distingue per la libertà offerta dalla licenza GPL.

#### GNU GPL (Licenza pubblica generale GNU)

La **GPL** garantisce all'autore di un software la sua proprietà intellettuale, ma consente modifiche, redistribuzione o rivendita di software da parte di terzi, a condizione che il codice sorgente sia incluso nel software. La GPL è la licenza dalla quale esce il progetto **GNU** (GNU is Not UNIX), che è stato strumentale nella creazione di Linux.

Questo implica:

* La libertà di eseguire il programma, per qualsiasi scopo.
* La libertà di studiare il funzionamento del programma e di adattarlo alle proprie esigenze.
* La libertà di ridistribuire le copie.
* La libertà di migliorare il programma e di pubblicare tali miglioramenti a beneficio dell'intera comunità.

D'altra parte, anche i prodotti concessi sotto licenza GPL possono avere un costo. Non si tratta del prodotto in sé, ma della **garanzia che un team di sviluppatori continuerà a lavorarci per farlo evolvere e per risolvere gli errori, o anche per fornire assistenza agli utenti**.

## Aree di utilizzo

Una distribuzione Linux eccelle per:

* **Server**: HTTP, e-mail, groupware, condivisione di file, ecc.
* **Sicurezza**: Gateway, firewall, router, proxy, ecc.
* **Computer centrali**: Banche, assicurazioni, industria, ecc.
* **Sistemi integrati**: Router, Internet box, SmartTV, ecc.

Linux è una scelta adatta per l'hosting di database o siti Web, o per mail server, DNS o firewall. In breve, Linux può fare qualsiasi cosa, il che spiega la quantità di distribuzioni specifiche.

## Shell

### Generalità

La **shell**, conosciuta anche come _command interface_, consente agli utenti di inviare comandi al sistema operativo. Oggi è meno visibile dopo l'implementazione delle interfacce grafiche, ma rimane un mezzo privilegiato sui sistemi Linux che non dispongono tutti di interfacce grafiche e i cui servizi non sempre hanno un'interfaccia di impostazione.

Offre un vero e proprio linguaggio di programmazione che include strutture classiche (cicli, alternative) e componenti comuni (variabili, passaggio di parametri e sottoprogrammi). Alcuni esempi sono:

Sono disponibili diversi tipi di shell, configurabili su una piattaforma o in base alle preferenze dell'utente. Alcuni esempi sono:

* sh, la shell standard POSIX
* csh, shell orientata ai comandi in C
* bash, Bourne-Again Shell, shell di Linux

### Funzionalità

* Esecuzione del comando (verifica il comando dato e lo esegue).
* Reindirizzamento di Input/Output (restituisce i dati a un file invece di scriverli sullo schermo).
* Processo di connessione (gestisce la connessione dell'utente).
* Linguaggio di programmazione interpretato (che consente la creazione di script).
* Variabili d'ambiente (accesso a informazioni specifiche del sistema durante il funzionamento).

### Principio

![Principio di funzionamento della SHELL](images/shell-principle.png)

## Verificare le proprie Conoscenze

:heavy_check_mark: Un sistema operativo è un insieme di programmi per la gestione delle risorse disponibili di un computer:

- [ ] Vero
- [ ] Falso

:heavy_check_mark: Il sistema operativo è necessario per:

- [ ] Gestire la memoria fisica e virtuale
- [ ] Consentire l'accesso diretto alle periferiche
- [ ] Affidare la gestione dei compiti all'elaboratore
- [ ] Raccogliere informazioni sui programmi utilizzati o in uso

:heavy_check_mark: Tra queste personalità, quali hanno partecipato allo sviluppo di UNIX?

- [ ] Linus Torvalds
- [ ] Ken Thompson
- [ ] Lionel Richie
- [ ] Brian Kernighan
- [ ] Andrew Stuart Tanenbaum

:heavy_check_mark: La nazionalità originaria di Linus Torvalds, creatore del kernel Linux, è:

- [ ] Svedese
- [ ] Finlandese
- [ ] Norvegese
- [ ] Fiamminga
- [ ] Francese

:heavy_check_mark: Quale delle seguenti distribuzioni è la più vecchia:

- [ ] Debian
- [ ] Slackware
- [ ] RedHat
- [ ] Arch

:heavy_check_mark: Lo è il kernel di Linux:

- [ ] Multitasking
- [ ] Multiutente
- [ ] Multiprocessore
- [ ] Multi-core
- [ ] Multipiattaforma
- [ ] Aperto

:heavy_check_mark: Il software libero è necessariamente open-source?

- [ ] Vero
- [ ] Falso

:heavy_check_mark: Il software Open-Source è necessariamente gratuito?

- [ ] Vero
- [ ] Falso

:heavy_check_mark: Quale delle seguenti non è una shell:

- [ ] Jason
- [ ] Jason-Bourne shell (jbsh)
- [ ] Bourne-Again shell (bash)
- [ ] C shell (csh)
- [ ] Korn shell (ksh)   
