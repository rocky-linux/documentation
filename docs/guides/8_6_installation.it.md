---
Title: Installazione Di Rocky Linux 8
author: wale soyinka
contributors: tianci li, Steven Spencer, Ganna Zhyrnova
---

# Installazione Di Rocky Linux 8

Questa guida mostra nel dettaglio i passaggi per installare una versione a 64 bit della distribuzione Rocky Linux su un sistema stand-alone.  Effettueremo un'installazione di categoria server utilizzando un'immagine di installazione del sistema operativo scaricata dal sito web del progetto Rocky Linux. Passeremo attraverso i passaggi di installazione e personalizzazione nelle sezioni seguenti.


## Prerequisiti per Installazione SO

Innanzitutto, è necessario scaricare la ISO da utilizzare per questa installazione di Rocky Linux.

L'ultima immagine ISO per la versione di Rocky Linux che utilizzeremo per questa installazione può essere scaricata da qui:

```
https://www.rockylinux.org/download/
```

Per scaricare l'ISO direttamente dalla riga di comando utilizzare il comando `wget`:

```
wget https://download.rockylinux.org/pub/rocky/8.9/isos/x86_64/Rocky-8.9-x86_64-minimal.iso
```

Le ISO di Rocky Linux sono denominate seguendo questa convenzione:

```
Rocky-<MAJOR#>.<MINOR#>-<ARCH>-<VARIANT>.iso
```

Ad esempio, `Rocky-8.9-x86_64-minimal.iso`

!!! Note "Nota"

    La pagina web del progetto Rocky elenca diversi mirror, situati in tutto il mondo. Scegliete il mirror geograficamente più vicino a voi. La lista dei mirror ufficiali può essere trovata [quì](https://mirrors.rockylinux.org/mirrormanager/mirrors).

## Verifica del file ISO dell'installazione

Se hai scaricato le ISO di Rocky Linux su una distribuzione Linux esistente, è possibile utilizzare l'utilità `sha256sum` per verificare che i file scaricati non siano corrotti. Mostreremo un esempio di come verificare il file `Rocky-8.5-x86_64-minimal.iso` controllandone il checksum.

In primo luogo scaricare il file che contiene i checksum ufficiali per le ISO disponibili. Mentre siete ancora nella cartella che contiene la ISO scaricata di Rocky Linux scaricate il file di checksum per la ISO, digitando:

```
wget https://download.rockylinux.org/pub/rocky/8.9/isos/x86_64/CHECKSUM
```

Utilizzare l'utilità `sha256sum` per verificare l'integrità del file ISO contro la corruzione e/o la manomissione.

```
sha256sum -c CHECKSUM --ignore-missing
```

Questo controllerà l'integrità del file ISO scaricato in precedenza, a condizione che si trovi nella stessa directory. L'output dovrebbe mostrare:

```
Rocky-8.9-x86_64-minimal.iso: OK
```

## L'Installazione

!!! Tip "Suggerimento"

    Prima dell'installazione, la Unified Extensible Firmware Interface (UEFI) o il Basic Input/Output System (BIOS) del sistema devono essere preconfigurati per l'avvio dal supporto corretto.

È possibile iniziare il processo di installazione se il computer è impostato per l'avvio dal supporto che contiene il file ISO.

Inserire e avviare dal supporto di installazione (disco ottico, unità flash USB, e così via).

Una volta che il computer si è avviato, vi verrà presentata la schermata di benvenuto di Rocky Linux 8.

![Schermata di avvio dell'installazione Rocky Linux](images/install_8_9_01.png)

Se non si preme alcun tasto il programma di installazione inizierà un conto alla rovescia, dopo il quale il processo di installazione eseguirà automaticamente l'opzione predefinita, evidenziata:

`Test this media & install Rocky Linux 8`

Puoi anche premere <kbd>Invio</kbd> in qualsiasi momento per avviare il processo immediatamente.

Si procederà ad una rapida verifica dei media. Questo passo di verifica del supporto può salvare dal problema di avviare l'installazione solo per scoprire a metà strada che l'installatore deve interrompere a causa di supporti di installazione difettosi.

Dopo che il controllo del supporto viene completato e il supporto viene verificato come corretto per essere utilizzato, il programma di installazione continuerà automaticamente alla schermata successiva.

Selezionare la lingua che si desidera utilizzare per l'installazione in questa schermata. Per questa guida, selezioniamo *English (United States)*. Quindi clicca sul pulsante <kbd>Continue</kbd>.

## Riepilogo Installazione

La schermata _Riepilogo Installazione_ è un'area all-in-one in cui si prendono le decisioni importanti sul sistema operativo da installare.

Lo schermo è approssimativamente diviso nelle seguenti sezioni:

- _Localizzazione_: (Supporto linguistico, e Tempo & Data)
- _Software_: (Installazione Sorgente e Selezione Software)
- _Sistema_: (Destinazione installazione e Rete & Nome Host)

Ci soffermeremo su ciascuna di queste sezioni e apporteremo modifiche ove necessario.

### Sezione Localizzazione

Questa sezione è utilizzata per personalizzare le voci relative al locale del sistema. Questo include – tastiera, supporto linguistico, tempo e data.

#### Tastiera

Sul nostro sistema demo in questa guida, modifichiamo il valore predefinito e selezioniamo (_Italiano (Italiana)_) e salviamo le modifiche.

Tuttavia, se è necessario apportare modifiche qui, dalla schermata _Installation Summary_, clicca sull'opzione <kbd>Keyboard</kbd> per specificare il layout della tastiera del sistema. È possibile aggiungere ulteriori layout della tastiera se è necessario nella successiva schermata e specificare il loro ordine.

Clicca <kbd>Fatto</kbd> quando hai finito con questa schermata.

#### Supporto Lingue

L'opzione <kbd>Supporto Linguistico</kbd> nella schermata _Riepilogo Installazione_ consente di specificare il supporto per le lingue aggiuntive di cui potresti aver bisogno sul sistema finito.

Accetteremo il valore predefinito (__Italiano – Italia__) e non apporteremo alcuna modifica, fare clic su <kbd>Fatto</kbd>.

#### Data & Ora

Fai clic sull'opzione <kbd>Ora e data</kbd> nella schermata principale _Riepilogo Installazione_ per far apparire un'altra schermata che ti permetterà di selezionare il fuso orario in cui si trova la macchina. Scorri l'elenco delle regioni e delle città e seleziona l'area più vicina a te.

A seconda della fonte di installazione, l'opzione _Ora da rete_ potrebbe essere impostata su _ON_ o _OFF_ per impostazione predefinita. Accetta l'impostazione predefinita _ON_; questo permette al sistema di impostare automaticamente il tempo corretto utilizzando il Network Time Protocol (NTP). Fare clic su <kbd>Fatto</kbd> dopo aver apportato eventuali modifiche.

### Sezione Software

Nella sezione _Software_ della schermata _Riepilogo Installazione_, è possibile selezionare la sorgente di installazione e i pacchetti aggiuntivi (applicazioni) che verranno installati.

#### Sorgente Installazione

Dal momento che stiamo eseguendo la nostra installazione utilizzando un'immagine completa Rocky 8, noterai che _Media Locale_ è automaticamente specificato nella sezione Installation Source della schermata principale _Riepilogo Installazione_. Accetteremo i valori preimpostati.

!!! Tip "Suggerimento"

    L'area Installation Source è dove è possibile scegliere di eseguire un'installazione basata sulla rete. Per un'installazione basata sulla rete, è necessario innanzitutto assicurarsi che una scheda di rete sul sistema di destinazione sia configurata correttamente e possa raggiungere Internet. Per eseguire un'installazione basata sulla rete, clicca su `Installation Source` e quindi seleziona il pulsante radio `On the network`. Una volta selezionato, scegli il protocollo `https` e digita il seguente URL nel campo di testo `download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os`. Clicca su `Fatto`.

#### Selezione Software

Facendo clic sull'opzione <kbd>Selezione Software</kbd> nella schermata principale _Riepilogo Installazione_ ti viene presentata la sezione dell'installazione dove puoi scegliere i pacchetti software esatti che vengono installati sul sistema. L'area di selezione del software è suddivisa in:

- _Base Environment_: Server, Installazione minima, Sistema operativo personalizzato
- _Additional software for Selected Environment area_: Selezionando un Base Environment sul lato sinistro si presenta una varietà di software aggiuntivi correlati che possono essere installati per l'ambiente specificato sul lato destro.

Seleziona invece l'opzione _Installazione minima_ (Funzionalità di base).

Clicca su <kbd>Fatto</kbd> nella parte superiore dello schermo.

### Sezione Sistema

La sezione Sistema della schermata _Riepilogo Installazione_ viene utilizzata per personalizzare e apportare modifiche all'hardware sottostante al sistema di destinazione. Qui è dove si creano le partizioni o i volumi del disco rigido, si specifica il file system da utilizzare e si specifica la configurazione di rete.

#### Destinazione Installazione

Dalla schermata _Riepilogo Installazione_, clicca sull'opzione <kbd>Destinazione Installazione</kbd>. Questo ti porta alla corrispondente area di attività.

Verrà visualizzata una schermata che mostra tutte le unità disco candidate disponibili sul sistema di destinazione. Se avete un solo disco sul sistema, come sul nostro sistema di esempio, vedrai l'unità elencata sotto _Dischi locali standard_ con un segno di spunta accanto ad essa. Facendo clic sull'icona del disco si attiverà o disattiverà il segno di spunta per la selezione del disco. Vogliamo che sia selezionato/spuntato qui.

Sotto la sezione Opzioni _Configurazione di archiviazione_, selezionare il pulsante radio <kbd>Automatic</kbd>.

Quindi clicca su <kbd>Fatto</kbd> nella parte superiore dello schermo.

Una volta che il programma di installazione determina che si dispone di un disco utilizzabile, verrete reindirizzati alla schermata _Riepilogo Installazione_.

### Rete & Nome Host

L'attività finale della procedura d'installazione riguarda la configurazione della rete, dove è possibile configurare o modificare le impostazioni relative alla rete per il sistema.

!!! Note "Nota"

    Dopo aver fatto clic sull'opzione <kbd>Network & Nome Host</kbd>, tutto l'hardware dell'interfaccia di rete correttamente rilevato (come Ethernet, le schede di rete wireless, e così via) saranno elencate nel riquadro sinistro della schermata di configurazione di rete. A seconda della distribuzione Linux e della specifica configurazione hardware, i dispositivi Ethernet in Linux hanno nomi simili a `eth0`, `eth1`, `ens3`, `ens4`, `em1`, `em2`, `p1p1`, `enp0s3`, e così via.

È possibile configurare ogni interfaccia tramite DHCP o impostare manualmente l'indirizzo IP. Se si sceglie di configurare manualmente, assicurarsi di avere tutte le informazioni pertinenti pronte, come l'indirizzo IP, maschera di rete, e così via.

Facendo clic sul pulsante <kbd>Network & Nome Host</kbd> nella schermata principale _Riepilogo Installazione_ si apre la corrispondente schermata di configurazione. Tra le altre cose, è possibile configurare il nome host del sistema (il nome predefinito è `localhost.localdomain`).

!!! Note "Nota"

    È possibile modificare facilmente questo nome in seguito dopo che il sistema operativo è stato installato. Per ora, accetta il valore predefinito fornito per il nome host.

Il prossimo importante compito di configurazione è relativo alle interfacce di rete del sistema. In primo luogo, verificare che una scheda Ethernet (o qualsiasi scheda di rete) sia elencata nel riquadro a sinistra. Fare clic su uno dei dispositivi di rete rilevati nel riquadro a sinistra per selezionarlo. Le proprietà configurabili della scheda di rete selezionata appariranno nel riquadro destro dello schermo.

!!! Note "Nota"

    Sul nostro sistema di esempio abbiamo due dispositivi Ethernet (`ens3` e `ens4`), tutti in uno stato connesso. Il tipo, il nome, la quantità e lo stato dei dispositivi di rete sul vostro sistema possono variare da quelli sul nostro sistema di esempio.

Assicurarsi che l'interruttore del dispositivo che si desidera configurare sia capovolto nella posizione `ON` nel riquadro destro. Accetteremo tutti i valori predefiniti in questa sezione.

Clicca <kbd>Fatto</kbd> per tornare alla schermata principale _Riepilogo Installazione_.

!!! Warning "Attenzione"

    Prestare attenzione all'indirizzo IP del server in questa sezione del programma d'installazione. Se non si dispone di un accesso fisico o facile alla console del sistema, queste informazioni saranno utili in seguito quando è necessario connettersi al server per continuare a lavorare.

## Fase di Installazione

Una volta che siete soddisfatti delle vostre scelte per le varie attività dell'installazione, la fase successiva del processo d'installazione inizierà l'installazione vera e propria.

### Sezione Impostazioni Utente

Questa sezione può essere utilizzata per creare una password per l'account utente `root` e anche per creare nuovi account amministrativi o non amministrativi.

### Impostare la password di root

Clicca sul campo _Password di root_ sotto _Impostazioni Utente_ per avviare la schermata _Password di Root_. Nella casella di testo _Password di root_, imposta una password forte per l'utente root.

!!! Warning "Attenzione"

    Il superutente root è l'account con più privilegi nel sistema. Pertanto, se si sceglie di usarlo o abilitarlo, è fondamentale proteggere questo account con una password forte.

Inserire nuovamente la stessa password nella casella di testo _Conferma_.

Clicca su <kbd>Fatto</kbd>.


### Creare un account utente

Poi clicca sul campo _Creazione utente_ sotto _Impostazioni Utente_ per avviare la schermata _Crea utente_. Questa area di attività consente di creare un account utente privilegiato o non privilegiato (non amministrativo) sul sistema.

!!! Info

    Creare e utilizzare un account non privilegiato per i compiti quotidiani di un sistema è una buona pratica di amministrazione del sistema.

Creeremo un utente normale che può invocare i poteri di superutente (amministratore), lo stesso utente root, quando necessario.

Completare i campi nella schermata _Crea utente_ con le seguenti informazioni e quindi fare clic su <kbd>Fatto</kbd>:

_Nome completo_: `rockstar`

_Nome utente_: `rockstar`

_Imposta questo utente come amministratore_: Spuntato

_Richiedi una password per utilizzare questo account_: Spuntato

_Password_: `04302021`

_Conferma password_: `04302021`

### Avviare l'installazione

Una volta che siete soddisfatti delle vostre scelte per le varie attività dell'installazione, fate clic sul pulsante Avvia installazione nella schermata principale _Riepilogo Installazione_. L'installazione inizierà, e l'installatore mostrerà i progressi dell'installazione. Quando inizia l'installazione, varie attività inizieranno ad essere eseguite in background, come il partizionamento del disco, la formattazione delle partizioni o i volumi di LVM, controllare e risolvere le dipendenze del software, scrivere il sistema operativo sul disco e così via.

!!! Note "Nota"

    Se non si desidera continuare dopo aver fatto clic sul pulsante Avvia Installazione, si può ancora tranquillamente tornare fuori dall'installazione senza alcuna perdita di dati. Per uscire dall'installatore, è sufficiente ripristinare il sistema facendo clic sul pulsante Esci, premendo ctrl-alt-del sulla tastiera, o spingendo l'interruttore di reset o di alimentazione.

### Completare l'installazione

Dopo aver completato tutte le sotto-attività obbligatorie, e l'installatore ha eseguito il suo corso, ti verrà presentata una schermata di avanzamento dell'installazione finale con un messaggio di completamento.

Infine, completare la procedura facendo clic sul pulsante <kbd>Reboot System</kbd>. Il sistema verrà riavviato.

### Accesso

Il sistema è ora configurato e pronto per l'uso. Vedrete la console Rocky Linux.

![Rocky Linux Schermata Di Benvenuto](images/installation_8_F02.png)

Per accedere al sistema, digita `rockstar` al prompt di accesso e premi <kbd>Invio</kbd>.

Al prompt della Password, digita `04302021` (la password di rockstar) e premi <kbd>Invio</kbd> (la password ***non*** sarà visualizzata sullo schermo, questo è normale).

Eseguiremo il comando `whoami` dopo l'accesso, questo comando mostra il nome dell'utente attualmente connesso.

![Schermata di Login](images/installation-F06.png)
