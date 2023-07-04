---
Title: Installazione di Rocky Linux 9
author: Wale Soyinka
contributors: Steven Spencer, Franco Colussi
---

# Installazione di Rocky Linux 9

Questa è una guida dettagliata per l'installazione di una versione a 64 bit della distribuzione Rocky Linux su un sistema standalone. Verrà eseguita un'installazione di classe server. Nelle sezioni seguenti verranno illustrate le fasi di installazione e personalizzazione.

## Prerequisiti per l'installazione del Sistema Operativo

Scaricare la ISO da utilizzare per questa installazione di Rocky Linux.  
È possibile scaricare l'ultima immagine ISO della versione di Rocky Linux per questa installazione qui:

```
https://www.rockylinux.org/download/
```

Per scaricare l'ISO direttamente dalla riga di comando su un sistema Linux esistente, utilizzare il comando `wget`:

```
wget https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.2-x86_64-minimal.iso
```

Le ISO di Rocky Linux seguono questa convenzione di denominazione:

```
Rocky-<MAJOR#>.<MINOR#>-<ARCH>-<VARIANT>.iso
```

Ad esempio, `Rocky-9.2-x86_64-minimal.iso`

!!! Note "Nota"

    La pagina web del progetto Rocky contiene un elenco di diversi mirror situati in tutto il mondo. Se possibile, scegliete il mirror geograficamente più vicino a voi. L'elenco dei mirror ufficiali è disponibile [qui] (https://mirrors.rockylinux.org/mirrormanager/mirrors).

## Verifica del file ISO del Programma di Installazione

Se avete scaricato le ISO di Rocky Linux su una distribuzione Linux esistente, potete usare l'utility `sha256sum` per verificare che i file scaricati non siano corrotti. Mostreremo un esempio di come verificare il file `Rocky-9.2-x86_64-minimal.iso` controllando il suo checksum.

1. Scaricate il file che contiene le checksum ufficiali delle ISO disponibili.

1. Mentre vi trovate ancora nella cartella che contiene l'ISO di Rocky Linux scaricata, scaricare il file di checksum dell'ISO, digitando:

    ```
    wget -O CHECKSUM https://download.rockylinux.org/pub/rocky/9.2/isos/x86_64/CHECKSUM
    ```

1. Utilizzare l'utilità `sha256sum` per verificare l'integrità del file ISO contro la corruzione o la manomissione.

    ```
    sha256sum -c CHECKSUM --ignore-missing
    ```

    Controlla l'integrità del file ISO scaricato in precedenza, a condizione che si trovi nella stessa directory. L'output dovrebbe mostrare:

    ```
    Rocky-9.2-x86_64-minimal.iso: OK
    ```

## L'installazione

!!! Tip "Suggerimento"

    Prima di iniziare l'installazione vera e propria, la Unified Extensible Firmware Interface (UEFI) o il Basic Input/Output System (BIOS) del sistema devono essere preconfigurati per l'avvio dal supporto corretto.

Se il computer è impostato per l'avvio dal supporto che contiene il file ISO, possiamo iniziare il processo di installazione.

1. Inserire e avviare il supporto di installazione (disco ottico, unità flash USB e così via).

1. Una volta avviato il computer, viene visualizzata la schermata di benvenuto di Rocky Linux 9.

    ![Schermata di avvio dell'installazione Rocky Linux](images/installation_9.2_F01.png)

1. Se non si preme alcun tasto, il programma di installazione avvia un conto alla rovescia, al termine del quale il processo di installazione esegue automaticamente l'opzione predefinita, evidenziata:

    `Test this media & install Rocky Linux 9.2`

    È anche possibile premere <kbd>Invio</kbd> in qualsiasi momento per avviare immediatamente il processo.

1. Viene eseguita una rapida fase di verifica dei supporti.  
   Questa fase di verifica del supporto può evitare di avviare l'installazione per poi scoprire a metà strada che il programma di installazione deve essere interrotto a causa di un supporto di installazione difettoso.

1. Dopo che la verifica del supporto è stata completata e il supporto è stato verificato come utilizzabile, il programma di installazione passa automaticamente alla schermata successiva.

1. In questa schermata è possibile selezionare la lingua che si desidera utilizzare per eseguire l'installazione. Per questa guida, selezioniamo l'*inglese (Stati Uniti)*. Quindi fare clic sul pulsante <kbd>Continue</kbd>.

## Riepilogo dell'installazione

La schermata *Installation Summary* è un'area completa in cui si prendono le decisioni importanti sul sistema da installare.

La schermata è suddivisa grossomodo nelle seguenti sezioni:

- *LOCALIZATION*
- *SOFTWARE*
- *SYSTEM*
- *USER SETTINGS*

In seguito approfondiremo ciascuna di queste sezioni e apporteremo le modifiche necessarie.

### Sezione Localizzazione

Questa sezione è utilizzata per personalizzare le voci relative alla località geografica del sistema. Tra questi: tastiera, supporto della lingua, ora e data.

#### Tastiera

Nel nostro sistema demo di questa guida, accettiamo il valore predefinito*(English US*) e non apportiamo alcuna modifica.

Tuttavia, se è necessario apportare delle modifiche, dalla schermata *Installation Summary*, facendo clic sull'opzione <kbd>Keyboard</kbd> si specifica il layout della tastiera del sistema. Con il pulsante <kbd>+</kbd> è possibile aggiungere altri layout di tastiera, se necessario, nella schermata successiva, specificando anche l'ordine preferito.

Al termine di questa schermata, fare clic su <kbd>Done</kbd>.

#### Supporto linguistico

L'opzione <kbd>Language Support</kbd> nella schermata *Installation Summary* consente di specificare il supporto per altre lingue.

Accetteremo il valore predefinito - **English (United States)** e non apporteremo alcuna modifica; fare clic su <kbd>Done</kbd>.

#### Data & Ora;

Fare clic sull'opzione <kbd>Time & Date</kbd> nella schermata principale di *Installation Summary* per visualizzare un'altra schermata che consente di selezionare il fuso orario in cui si trova la macchina. Scorrete l'elenco delle regioni e delle città e selezionate l'area più vicina a voi.

A seconda della fonte di installazione, l'opzione *Network Time* può essere impostata di default su *ON* o *OFF*. Accettare l'impostazione predefinita *ON*; ciò consente al sistema di impostare automaticamente l'ora corretta utilizzando il Network Time Protocol (NTP).

Fare clic su <kbd>Done</kbd> dopo aver apportato le modifiche.

### Sezione software

Nella sezione *Software* della schermata *Installation Summary*, è possibile selezionare o modificare l'origine dell'installazione e i pacchetti aggiuntivi (applicazioni) che vengono installati.

#### Fonte dell'installazione

Poiché l'installazione utilizza un'immagine ISO di Rocky Linux 9, si noterà che il *Local Media* è specificato automaticamente nella sezione Origine dell'installazione della schermata principale di *Installation Summary*. È possibile accettare le impostazioni predefinite.

!!! Tip "Suggerimento"

    Nell'area installation Source è possibile scegliere di eseguire un'installazione basata sulla rete (ad esempio se si utilizza la ISO di avvio di Rocky Linux - Rocky-9.2-x86_64-boot.iso). Per un'installazione basata sulla rete, è necessario innanzitutto assicurarsi che una scheda di rete sul sistema di destinazione sia configurata correttamente e sia in grado di raggiungere Internet. Per eseguire un'installazione dalla rete, fare clic su `Installation Source` e selezionare il pulsante di opzione `On the network`. Una volta selezionato, scegliete `https' come protocollo e digitate il seguente URL nel campo di testo `download.rockylinux.org/pub/rocky/9/BaseOS/x86_64/os`. Fare clic su "Done".

#### Selezione del software

Facendo clic sull'opzione <kbd>Software Selection</kbd> nella schermata principale di *Installation Summary*, si accede alla sezione dell'installazione in cui è possibile scegliere i pacchetti software esatti da installare sul sistema. L'area di selezione del software è suddivisa in :

- **Base Environment**: Installazione minima e sistema operativo personalizzato
- **Additional software for Selected Environment**: la selezione di un ambiente di base sul lato sinistro presenta una serie di software aggiuntivi da installare per l'ambiente in questione sul lato destro. Si noti che questo è applicabile solo se si sta installando da un DVD completo di Rocky Linux 9.2 o se sono stati configurati repository aggiuntivi.

Selezionare l'opzione *Minimal Install* (funzionalità di base).

Cliccate su <kbd>Done</kbd> nella parte superiore della schermata.

### Sezione Sistema

La sezione System della schermata *Installation Summary* viene utilizzata per personalizzare e apportare modifiche all'hardware sottostante del sistema di destinazione. Qui si creano le partizioni o i volumi del disco rigido, si specifica il file system, la configurazione di rete, si attiva o disattiva KDUMP o si seleziona un profilo di sicurezza.

#### Destinazione dell'installazione

Dalla schermata *Installation Summary*, fare clic sull'opzione <kbd>Installation Destination</kbd>. Si accede così all'area operativa corrispondente.

Verrà visualizzata una schermata con tutte le unità disco candidate disponibili sul sistema di destinazione. Se nel sistema è presente una sola unità disco, come nel nostro sistema campione, l'unità viene elencata sotto *Local Standard Disks* con un segno di spunta accanto. Facendo clic sull'icona del disco si attiva o disattiva il segno di spunta della selezione del disco. Mantenere la spunta per selezionare il disco.

Nella sezione *Storage Configuration*:

1. Selezionare il pulsante di opzione <kbd>Automatic</kbd>.

2. Cliccate su <kbd>Done</kbd> nella parte superiore della schermata.

3. Una volta accertato che il disco è utilizzabile, il programma di installazione torna alla schermata di *Installation Summary*.

### Network & Nome host

Il prossimo compito importante della procedura di installazione nell'area Sistema riguarda la configurazione di rete, dove è possibile configurare o modificare le impostazioni relative alla rete del sistema.

!!! Note "Nota"

    Dopo aver fatto clic sull'opzione <kbd>Network & Hostname</kbd>, tutto l'hardware dell'interfaccia di rete correttamente rilevato (come schede di rete Ethernet, wireless e così via) sarà elencato nel riquadro sinistro della schermata di configurazione della rete. A seconda della configurazione hardware specifica, i dispositivi Ethernet in Linux hanno nomi simili a `eth0`, `eth1`, `ens3`, `ens4`, `em1`, `em2`, `p1p1`, `enp0s3` e così via. 
    Per ogni interfaccia è possibile configurarla utilizzando il DHCP o impostando manualmente l'indirizzo IP. 
    Se si sceglie di configurare manualmente, assicurarsi di avere pronte tutte le informazioni necessarie, come l'indirizzo IP, la netmask e così via.

Facendo clic sul pulsante <kbd>Network & Hostname</kbd> nella schermata principale di *Installation Summary*, si apre la schermata di configurazione corrispondente. Tra le altre cose, è possibile configurare l'hostname del sistema.

!!! Note "Nota"

    È possibile modificare facilmente l'hostname del sistema in un secondo momento, dopo l'installazione del sistema operativo.

La prossima importante operazione di configurazione riguarda le interfacce di rete del sistema.

1. Verificare che nel riquadro di sinistra sia elencata una scheda Ethernet (o qualsiasi altra scheda di rete)
2. Fare clic su uno dei dispositivi di rete rilevati nel riquadro sinistro per selezionarlo.  
   Le proprietà configurabili dell'adattatore di rete selezionato appaiono nel riquadro destro della schermata.

!!! Note "Nota"

    Nel nostro sistema campione, abbiamo due dispositivi Ethernet (`ens3` e `ens4`), tutti in stato di connessione. Il tipo, il nome, la quantità e lo stato dei dispositivi di rete presenti nel sistema potrebbero variare rispetto a quelli presenti nel nostro sistema demo.

Verify the switch of the device you want to configure is flipped to the `ON` (blue) position in the right pane. In questa sezione verranno accettate tutte le impostazioni predefinite.

Fare clic su <kbd>Done</kbd> per tornare alla schermata principale di *Installation Summary*.

!!! Warning "Attenzione"

    Prestare attenzione all'indirizzo IP del server in questa sezione del programma di installazione. Se non si dispone di un accesso fisico o facile alla console del sistema, queste informazioni saranno utili in seguito, quando sarà necessario collegarsi al server per continuare a lavorarci dopo il completamento dell'installazione del sistema operativo.

### Sezione Impostazioni utente

Questa sezione può essere utilizzata per creare una password per l'account utente `root` e anche per creare nuovi account amministrativi o non amministrativi.

#### Password Root

1. Fare clic sul campo *Root Password* in *User Settings* per avviare la schermata dell'attività *Root Password*.

    !!! Warning "Attenzione"
   
        Il superutente root è l'account più privilegiato del sistema. Pertanto, se si sceglie di utilizzarlo o di abilitarlo, è fondamentale proteggere questo account con una password forte.

1. Nella casella di testo *Root Password*, impostare una password forte per l'utente root.

1. Immettere nuovamente la stessa password nella casella di testo *Confirm*.

1. Fare clic su <kbd>Done</kbd>.


#### Creazione dell'utente

Per creare un utente:

1. Fare clic sul campo *User Creation* in *User Settings* per avviare la schermata dell'attività *Create User*.  
   Quest'area operativa consente di creare un account utente privilegiato o non privilegiato (non amministrativo) sul sistema.

    !!! Info "Informazione"
   
        La creazione e l'uso di un account non privilegiato per le attività quotidiane di un sistema è una buona pratica di amministrazione del sistema.

    Creeremo un utente normale che può invocare i poteri di superutente (amministratore) quando necessario.

1. Completate i campi della schermata *Create User* con le seguenti informazioni:

    - **Full name**: `rockstar`
    - **Username**: `rockstar`
    - **Make this user administrator**: Checked
    - **Require a password to use this account**: Checked
    - **Password**: `04302021`
    - **Confirm password**: `04302021`

1. Fare clic su <kbd>Done</kbd>.

## Fase di Installazione

Una volta soddisfatti delle scelte effettuate per le varie attività di installazione, la fase successiva del processo di installazione darà inizio all'installazione vera e propria.


### Avviare l'installazione

Una volta soddisfatti delle scelte effettuate per le varie attività di installazione, fare clic sul pulsante <kbd>Begin Installation</kbd> nella schermata principale di *Installation Summary*.

L'installazione avrà inizio e il programma di installazione mostrerà l'avanzamento dell'installazione. Dopo l'inizio dell'installazione, inizieranno ad essere eseguite varie attività in background, come il partizionamento del disco, la formattazione delle partizioni o dei volumi LVM, la verifica e la risoluzione delle dipendenze software, la scrittura del sistema operativo sul disco e così via.

!!! Note "Nota"

    Se non si desidera continuare dopo aver fatto clic sul pulsante Inizia l'installazione, si può comunque uscire dall'installazione senza perdere i dati. Per uscire dal programma di installazione, è sufficiente resettare il sistema facendo clic sul pulsante Quit, premendo ctrl-alt-del sulla tastiera o premendo l'interruttore di reset o di alimentazione.

### Completare l'installazione

Al termine del programma di installazione, viene visualizzata una schermata finale di avanzamento dell'installazione con un messaggio di completamento.

Infine, completare l'intera procedura facendo clic sul pulsante <kbd>Reboot System</kbd>. Il sistema si riavvia.

### Accedi

Il sistema è ora impostato e pronto per l'uso. Verrà visualizzata la console Rocky Linux.

![Schermata di benvenuto di Rocky Linux](images/installation_9_F02.png)

Per accedere al sistema:

1. Digitare `rockstar` al prompt di login e premere <kbd>Invio</kbd>.

1. Al prompt della password, digitate `04302021` (la password di Rockstar) e premete <kbd>Invio</kbd> (la password  ***non verrà*** visualizzata sullo schermo, è normale).

1. Eseguire il comando `whoami` dopo il login.  
   Questo comando mostra il nome dell'utente attualmente connesso.

![Schermata di accesso](images/installation_9.0_F03.png)
