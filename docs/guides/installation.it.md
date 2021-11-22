---
title: Installazione di Rocky Linux
---

# Installazione di Rocky Linux

Questa guida illustra i passaggi dettagliati per installare una versione a 64 bit della distribuzione Rocky Linux su un sistema stand-alone.

****
In questa guida eseguiremo un'installazione di classe server utilizzando un'immagine del programma di installazione del sistema operativo scaricata dal sito Web del progetto Rocky Linux. Esamineremo i passaggi di installazione e personalizzazione nelle sezioni seguenti.
****

!!! Note "Nota"  
    Ovunque ci sia un comando che viene eseguito dal prompt dei comandi, si presume che tu abbia effettuato l'accesso come utente standard (non come superutente). Il comando da digitare non mostrerà il prompt dei comandi che potrebbe essere diverso a seconda del sistema e del sistema operativo che si sta utilizzando.

## Prerequisiti di installazione del SO

Innanzitutto, è necessario scaricare l'ISO da utilizzare per questa installazione di Rocky Linux.

L'ultima versione dell'immagine ISO di Rocky Linux che useremo per questa installazione può essere scaricata da qui:

```bash
https://www.rockylinux.org/download/
```

Per scaricare l'ISO direttamente dalla riga di comando utilizza il comando 'wget':

```bash
wget https://download.rockylinux.org/pub/rocky/8.5/isos/x86_64/Rocky-8.5-x86_64-minimal.iso
```

Le ISO di Rocky Linux sono denominate seguendo questa convenzione:

```bash
Rocky-<MAJOR#>.<MINOR#>-<ARCH>-<VARIANT>.iso
```

Per esempio, `Rocky-8.5-x86_64-minimal.iso`

!!! Note "Nota"  
    La pagina web del progetto Rocky ha un elenco di diversi mirror situati in tutto il mondo. Quando possibile, dovresti scegliere il mirror geograficamente più vicino a te. L'elenco dei mirror ufficiali può essere trovato [quì](https://mirrors.rockylinux.org/mirrormanager/mirrors).

## Verifica del file ISO del programma di installazione

Se hai scaricato la ISO di Rocky Linux su una distribuzione Linux esistente, puoi utilizzare l'utilità `sha256sum` per verificare che i file scaricati non siano corrotti. Mostreremo un esempio di come verificare il file `Rocky-8.5-x86_64-minimal.iso` controllandone il checksum.

Per prima cosa scarica il file che contiene i checksum ufficiali per le ISO disponibili. Mentre sei ancora nella cartella che contiene la ISO di Rocky Linux scaricata, scarica il file di checksum per la ISO, digita:

```bash
wget https://download.rockylinux.org/pub/rocky/8.5/isos/x86_64/CHECKSUM
```

Utilizza l'utilità `sha256sum` per verificare l'integrità del file ISO contro la corruzione e/o la manomissione.

```bash
sha256sum -c CHECKSUM --ignore-missing  Rocky-8.5-x86_64-minimal.iso
```

L'output dovrebbe mostrare:

```bash
Rocky-8.5-x86_64-minimal.iso: OK
```

## L'installazione

!!! Tip "Suggerimento"
    Per iniziare correttamente l'installazione, l'interfaccia UEFI (Unified Extensible Firmware Interface) o il BIOS (Basic Input/Output System) del sistema devono essere preconfigurati per l'avvio dal supporto corretto.

Se il computer è configurato per l'avvio dal supporto che ha il file ISO, possiamo iniziare il processo di installazione.

Inserire e avviare dal supporto di installazione (disco ottico, unità flash USB e così via).

Una volta avviato il computer, ti verrà presentata la schermata iniziale di benvenuto di Rocky Linux 8.

![Rocky Linux installation splash screen](images/installation-F01.png)

Se non si preme alcun tasto, il programma di installazione inizierà un conto alla rovescia, dopodiché il processo di installazione eseguirà automaticamente l'opzione predefinita, evidenziata:

`Test this media & install Rocky Linux 8`

È inoltre possibile premere <kbd>invio</kbd> in qualsiasi momento per avviare immediatamente il processo.

Verrà eseguita una rapida fase di verifica dei supporti. Questo passaggio di verifica dei supporti può farti risparmiare la fatica di avviare l'installazione solo per scoprire a metà strada che il programma di installazione deve interrompere a causa di un cattivo supporto di installazione.

Dopo che il controllo del supporto è stato completato e il supporto è stato verificato come corretto per essere utilizzato, il programma di installazione continuerà automaticamente alla schermata successiva.

Selezionare la lingua che si desidera utilizzare per eseguire l'installazione in questa schermata. Per questo esempio, selezioniamo _Italiano (Italia)_. Quindi fare clic sul pulsante <kbd>Continua</kbd>.

## Riepilogo installazione

La schermata _Riepilogo installazione_ è un'area all-in-one in cui si prendono le decisioni importanti sul sistema operativo da installare.

Lo schermo è approssimativamente diviso nelle seguenti sezioni:

- _Localizzazione_: (tastiera, supporto linguistico e data & ora)
- _Software_: (Origine installazione e Selezione software)
- _Sistema_: (Destinazione di installazione e Rete & Hostname)

Approfondiremo ciascuna di queste sezioni e apporteremo modifiche ove necessario.

### Sezione Localizzazione

Questa sezione viene utilizzata per personalizzare gli elementi correlati alle impostazioni locali del sistema. Ciò include: Tastiera, Supporto Linguistico, Ora & Data.

#### Tastiera

Sul nostro sistema demo in questa guida, selezioniamo la tastiera italiana (_Italiano (Italia)_) e clicchiamo su <kbd>Continua</kbd>.

Tuttavia, se è necessario apportare modifiche, dalla schermata _Riepilogo installazione_, clicca sull'opzione <kbd>Tastiera</kbd> per specificare il layout della tastiera del sistema. È possibile aggiungere ulteriori layout di tastiera se necessario nella schermata successiva e specificarne il loro ordine.

Clicca su <kbd>Fatto</kbd> quando hai finito con questa schermata.

#### Supporto linguistico

L'opzione <kbd>Supporto linguistico</kbd> nella schermata _Riepilogo installazione_ consente di specificare il supporto per altre lingue che potrebbero essere necessarie nel sistema installato.

Accetteremo il valore predefinito (__Italiano (Italia)__) e non apporteremo alcuna modifica, facendo clic su <kbd>Fatto</kbd>.

#### Ora & data

Clicca sull'opzione <kbd>Ora & data</kbd> nella schermata principale _Riepilogo installazione_ per visualizzare un'altra schermata che consente di selezionare il fuso orario in cui si trova la macchina. Scorri l'elenco delle regioni e delle città e seleziona l'area più vicina a te.

A seconda della sorgente di installazione, l'opzione _Network Time_ può essere  per impostazione predefinita impostata su _ON_ o _OFF_. Accettate l'impostazione _ON_ di default o commutatela se _OFF_; ciò consente al sistema di impostare automaticamente l'ora corretta utilizzando il Network Time Protocol (NTP). Clicca su <kbd>Fatto</kbd> dopo aver apportato le modifiche.

### Sezione Software

Nella sezione _Software_ della schermata _Riepilogo installazione_, è possibile selezionare l'origine dell'installazione e i pacchetti aggiuntivi (applicazioni) che verranno installati.

#### Installation source

Poiché stiamo eseguendo la nostra installazione utilizzando un'immagine completa di Rocky 8, noterai che _Media Locale_ viene automaticamente specificato nella sezione _Installation source_ della schermata principale del _Riepilogo installazione_. Accetteremo le impostazioni predefinite preimpostate.

#### Selezione software

Facendo clic sull'opzione <kbd>Selezione software</kbd> nella schermata principale _Riepilogo installazione_ viene presentata la sezione dell'installazione in cui è possibile scegliere i pacchetti software esatti che vengono installati sul sistema. L'area di selezione del software è suddivisa in:

- _Ambiente di base_ : Server, Installazione Minima, Sistema Operativo Personalizzato.
- _Additional software for Selected Enviroment_ : La selezione di un Ambiente di base sul lato sinistro presenta una varietà di software aggiuntivi correlati che possono essere installati per l'ambiente selezionato sul lato destro.

Selezionare invece l'opzione _Installazione Minima_ (Funzione di base).

Fai clic su <kbd>Fatto</kbd> nella parte superiore dello schermo.

### Sezione Sistema

La sezione Sistema della schermata _Riepilogo installazione_ viene utilizzata per personalizzare e apportare modifiche all'hardware del sistema di destinazione. Qui è dove si creano le partizioni o i volumi del disco rigido, si specifica il file system da utilizzare e si specifica la configurazione di rete.

#### Destinazione installazione

Nella schermata _Riepilogo installazione_, fai clic sull'opzione <kbd>Destinazione installazione</kbd>. Questo ti porta all'area di attività corrispondente.

Verrà visualizzata una schermata che mostra tutte le unità disco candidate disponibili sul sistema di destinazione. Se si dispone di una sola unità disco sul sistema, come sul nostro sistema di esempio, verrà visualizzata l'unità elencata in _Dischi locali standard_ con un segno di spunta accanto ad essa. Facendo clic sull'icona del disco verrà attivato o disattivato il segno di spunta di selezione del disco. Vogliamo che quì sia selezionato/controllato.

Nella sezione _Configurazione di archiviazione_ selezionare il pulsante di opzione <kbd>Automatic</kbd>.

Quindi clicca su <kbd>Fatto</kbd> nella parte superiore dello schermo.

Una volta che il programma di installazione determina che si dispone di un disco utilizzabile, si tornerà alla schermata _Riepilogo installazione_.

### Network & Hostname

L'attività finale della procedura di installazione riguarda la configurazione di rete, in cui è possibile configurare o modificare le impostazioni relative alla rete per il sistema.

!!! Note "Nota"
    Dopo aver cliccato sull'opzione <kbd>Network & nome host</kbd>, tutto l'hardware dell'interfaccia di rete correttamente rilevato (ad esempio Ethernet, schede di rete wireless e così via) verrà elencato nel riquadro sinistro della schermata di configurazione della rete. A seconda della distribuzione Linux e della configurazione hardware specifica, i dispositivi Ethernet in Linux hanno nomi simili a `eth0`, `eth1`, `ens3`, `ens4`, `em1`, `em2`, `p1p1`, `enp0s3` e così via.

Per ogni interfaccia, è possibile configurarla utilizzando DHCP o impostarndo manualmente l'indirizzo IP. Se si sceglie di configurare manualmente, assicurarsi di avere tutte le informazioni pertinenti pronte, ad esempio l'indirizzo IP, la netmask e così via.

Facendo clic sul pulsante <kbd>Network & Hostname</kbd> nella schermata principale _Riepilogo installazione_ si apre la schermata di configurazione corrispondente. Tra le altre cose, hai la possibilità di configurare il nome host del sistema (il nome predefinito è `localhost.localdomain`).

!!! Note "Nota"
    È possibile modificare facilmente questo nome in un secondo momento dopo l'installazione del sistema operativo. Per ora, accettare il valore predefinito fornito per il nome host.

La successiva importante attività di configurazione è relativa alle interfacce di rete sul sistema. Innanzitutto, verificare che una scheda Ethernet (o qualsiasi scheda di rete) sia elencata nel riquadro di sinistra. Cliccate su uno dei dispositivi di rete rilevati nel riquadro sinistro per selezionarlo. Le proprietà configurabili della scheda di rete selezionata verranno visualizzate nel riquadro destro dello schermo.

!!! Note "Nota"
    Sul nostro server di esempio, abbiamo quattro dispositivi Ethernet (`ens3`, `ens4`, `ens5` e `ens6`), tutti in uno stato connesso. Il tipo, il nome, la quantità e lo stato dei dispositivi di rete sul sistema possono variare da quelli del nostro sistema di esempio.

Assicurati che l'interruttore del dispositivo che desideri configurare sia posizionato su "ON" nel riquadro di destra.
Accetteremo tutte le impostazioni predefinite in questa sezione.

Cliccate su <kbd>Fatto</kbd> per tornare alla schermata principale _Riepilogo installazione_.

!!! Warning "Avvertimento"
    Prestare attenzione all'indirizzo IP del server in questa sezione del programma di installazione. Se non si dispone di un accesso fisico alla console del sistema, queste informazioni saranno utili in seguito quando sarà necessario connettersi al server per continuare a lavorarci.

## Fase di installazione

Una volta che sei soddisfatto delle tue scelte per le varie attività di installazione, inizierà la fase successiva del processo di installazione.

### Sezione Impostazioni Utente

Questa sezione può essere utilizzata per la creazione di una password per l'account utente `root` e anche per la creazione di nuovi account amministrativi o non amministrativi.

### Impostare la Password di Root

Cliccate sul campo _Password di Root_ sotto _Impostazioni Utente_ per avviare la schermata delle attività _Password di Root_. Nella casella di testo _Password di root_ impostare una password complessa per l'utente root.

!!! Warning "Avvertimento"
    Il superutente root è l'account con più privilegi sul sistema. Pertanto, se si sceglie di utilizzarlo o abilitarlo, è fondamentale proteggere questo account con una password complessa.

Immettere nuovamente la stessa password nella casella di testo _Conferma_.

Clicca su <kbd>Fatto</kbd>.

### Creare un Account Utente

Quindi cliccate sul campo _Creazione Utente_ sotto _Impostazioni Utente_ per avviare la schermata delle attività _Create User_. Questa area di attività consente di creare un account utente privilegiato o non privilegiato (non amministrativo) nel sistema.

!!! Info "Informazione"
    La creazione e l'utilizzo di un account senza privilegi per le attività quotidiane su un sistema è una buona pratica di amministrazione del sistema.

Creeremo un utente normale in grado di invocare i poteri di superutente (amministratore), gli stessi dell'utente root, quando necessario.

Completare i campi nella schermata _Crea Utente_ con le seguenti informazioni e quindi fare clic su <kbd>Fatto</kbd>:

_Nome completo_:
`rockstar`

_Nome utente_:
`rockstar`

_Imposta questo utente come amministratore_:
Selezionato

_Richiedi una password per usare questo account_:
Selezionato

_Password_:
`04302021`

_Conferma password_:
`04302021`

### Avviare l'Installazione

Una volta soddisfatte le scelte fatte per le varie attività di installazione, clicca sul pulsante _Avvia Installazione_ nella schermata principale _Riepilogo installazione_. L'installazione inizierà e il programma di installazione mostrerà l'avanzamento dell'installazione.

!!! Note "Nota"
    Se non si desidera continuare dopo aver fatto clic sul pulsante Inizia installazione, è comunque possibile uscire in modo sicuro dall'installazione senza alcuna perdita di dati. Per uscire dal programma di installazione, è sufficiente ripristinare il sistema facendo clic sul pulsante Termina, premendo ctrl-alt-canc sulla tastiera o premendo l'interruttore di ripristino o di accensione.

All'inizio dell'installazione, varie attività inizieranno ad essere eseguite in background, come il partizionamento del disco, la formattazione delle partizioni o dei volumi LVM, il controllo e la risoluzione delle dipendenze software, la scrittura del sistema operativo sul disco e così via.

### Completare l'installazione

Dopo aver completato tutte le sottoattività obbligatorie e aver eseguito il programma di installazione, verrà presentata una schermata di avanzamento dell'installazione finale con un messaggio completato.

Infine, per completare l'intera procedura cliccando
 sul pulsante <kbd>Reboot System</kbd>. Il sistema verrà riavviato.

### Accedi

Il sistema è ora configurato e pronto per l'uso. Vedrai la console Rocky Linux.

![Rocky Linux Welcome Screen](images/installation-F04.png)

Per accedere al sistema, digita `rockstar` al prompt di accesso e premi <kbd>Invio</kbd>.

Al prompt password, digita `04302021` (la password di rockstar) e premi <kbd>Invio</kbd> (la password ***non*** verrà visualizzata sullo schermo, questo è normale).

Eseguiremo il comando `whoami` dopo il login, questo comando mostra il nome dell'utente attualmente connesso.

![Login Screen](images/installation-F06.png)
