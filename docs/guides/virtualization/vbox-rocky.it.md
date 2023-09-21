---
title: Rocky su VirtualBox
author: Steven Spencer
contributors: Trevor Cooper, Ezequiel Bruni, Ganna Zhyrnova
tested on: 8.4, 8.5
tags:
  - virtualbox
  - virtualization
---

# Rocky su VirtualBox&reg;

## Introduzione

VirtualBox&reg; è un potente prodotto di virtualizzazione sia per uso aziendale che domestico. Di tanto in tanto, qualcuno scrive che ha problemi a far funzionare Rocky Linux in VirtualBox&reg;. Testando ed eseguendo VirtualBox&reg; tornando alla release candidate, funziona bene. I problemi che la gente riferisce di solito riguardano spesso il video.

Questo documento è un tentativo di dare una serie di istruzioni passo dopo passo per avere Rocky Linux in funzione su VirtualBox&reg;. La macchina utilizzata per creare questa documentazione è Linux, ma è possibile utilizzare uno qualsiasi dei sistemi operativi supportati.

## Prerequisiti

* Una macchina (Windows, Mac, Linux, Solaris) con memoria disponibile e spazio su disco rigido per costruire ed eseguire l'istanza di VirtualBox&reg;.
* VirtualBox&reg; installato sulla vostra macchina. Potete trovarlo [qui](https://www.virtualbox.org/wiki/Downloads).
* Una copia del [DVD ISO](https://rockylinux.org/download) di Rocky Linux per la tua architettura. (x86_64 o ARM64).
* Assicurarsi che il sistema operativo sia a 64 bit e che la virtualizzazione hardware sia attiva nel BIOS.

!!! Note "Nota"

    La virtualizzazione dell'hardware è necessaria al 100% per installare un sistema operativo a 64 bit. Se la schermata di configurazione mostra solo opzioni a 32 bit, è necessario fermarsi e risolvere il problema prima di continuare.

## Preparazione della configurazione di VirtualBox&reg;

Una volta che avete VirtualBox&reg; installato, il passo successivo è quello di avviarlo. Senza immagini installate otterrete una schermata che assomiglia a questa:

 ![Installazione Fresh VirtualBox](../images/vbox-01.png)

 Per prima cosa, è necessario indicare a VirtualBox&reg; quale sarà il vostro sistema operativo:

 * Clicca su "New" (icona a forma di dente di sega).
 * Digita un nome. Esempio: "Rocky Linux 8.5".
 * Lasciare la cartella della macchina come riempita automaticamente.
 * Cambia il tipo in "Linux".
 * E scegli "Red Hat (64-bit)".
 * Clicca "Next".

 ![Nome e Sistema Operativo](../images/vbox-02.png)

Successivamente, è necessario allocare un po' di RAM per questa macchina. Per default, VirtualBox&reg; riempirà automaticamente questo con 1024 MB. Questo non sarà ottimale per nessun sistema operativo moderno, incluso Rocky Linux. Se avete memoria a disposizione, assegnate da 2 a 4 GB (2048 MB o 4096 MB) — o più. VirtualBox&reg utilizzerà questa memoria solo durante il funzionamento della macchina virtuale.

Non c'è una schermata per questo, basta modificare il valore in base alla memoria disponibile. Usate il vostro buonsenso.

È necessario impostare le dimensioni del disco rigido. Per impostazione predefinita, VirtualBox&reg; riempirà automaticamente il pulsante radio "Create a virtual hard disk now".

![Disco Rigido](../images/vbox-03.png)

* Cliccare su "Create"

Si aprirà una finestra di dialogo per la creazione di vari tipi di disco rigido virtuale. Sono presenti diversi tipi di disco rigido. Per [ulteriori informazioni](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vdidetails.html) sulla selezione dei tipi di disco rigido virtuale, consultare la documentazione di Oracle VirtualBox. Per questo documento, mantenere il valore predefinito (VDI):

![Tipo di File del Disco Rigido](../images/vbox-04.png)

* Clicca Su "Next"

La prossima schermata riguarda la memorizzazione sul disco rigido fisico. Esistono due opzioni. La " Fixed Size" sarà più lenta da creare, più veloce da usare, ma meno flessibile in termini di spazio (se si ha bisogno di più spazio, non si può crescere oltre quello creato).

L'opzione predefinita, " Dynamically Allocated", è più veloce da creare e più lenta da utilizzare, ma consente di crescere se lo spazio su disco deve cambiare.

![Memorizzazione su Disco Rigido Fisico](../images/vbox-05.png)

* Clicca Su "Next"

VirtualBox&reg; offre ora la possibilità di specificare dove si desidera che si trovi il file del disco rigido virtuale. È presente anche un'opzione per espandere lo spazio predefinito di 8 GB del disco rigido virtuale. Questa opzione è utile, perché 8 GB di spazio sul disco rigido non sono sufficienti per installare le opzioni di installazione dell'interfaccia grafica, tanto meno per utilizzarle. Impostate questo valore a 20 GB (o più), a seconda dell'uso che volete fare della macchina virtuale e dello spazio disponibile su disco:

![Posizione e Dimensione del File](../images/vbox-06.png)

* Cliccare su "Create"

La configurazione di base è terminata. Si otterrà una schermata che assomiglia a questa:

![Configurazione Di Base Completata](../images/vbox-07.png)

## Collegare l'immagine ISO

Il passo successivo consiste nel collegare l'immagine ISO scaricata come dispositivo CD ROM virtuale. Cliccate su "Settings" (icona a forma di ingranaggio) e otterrete la seguente schermata:

![Impostazioni](../images/vbox-08.png)

* Fare clic sulla voce "Storage" nel menu di sinistra.
* Sotto "Storage Devices" nella sezione centrale, clicca sull'icona del CD che dice "Empty".
* Alla voce "Attributes" sul lato destro, fare clic sull'icona del CD.
* Selezionate "Choose/Create a Virtual Optical Disk".
* Fare clic sul pulsante "Add " (icona con il segno più) e navigare fino al punto in cui si trova l'immagine ISO di Rocky Linux.
* Selezionate la ISO e cliccate su "Open".

Ora dovreste avere la ISO aggiunta ai dispositivi disponibili in questo modo:

![Immagine ISO Aggiunta](../images/vbox-09.png)

* Evidenzia l'immagine ISO e poi clicca su "Choose".

L'immagine ISO di Rocky Linux appare ora selezionata sotto "Controller:IDE" nella sezione centrale:

![Immagine ISO Selezionata](../images/vbox-10.png)

* Clicca "OK"

### Memoria video per installazioni grafiche

VirtualBox&reg; imposta 16 MB di memoria da utilizzare per il video. Questo va bene se si intende eseguire un server bare-bones senza interfaccia grafica, ma non appena si aggiunge la grafica non è sufficiente. Gli utenti che mantengono questa impostazione spesso vedono una schermata di avvio sospesa che non finisce mai, o altri errori.

Se si utilizza Rocky Linux con un'interfaccia grafica, assegnare una quantità di memoria sufficiente a far funzionare la grafica. Se il vostro computer è un po' a corto di memoria, regolate questo valore verso l'alto a 16 MB fino a quando le cose funzionano senza problemi. La risoluzione video della vostra macchina host è anche un fattore che dovete considerare.

Pensate attentamente a ciò che volete che la vostra macchina virtuale Rocky Linux faccia, e cercate di allocare una memoria video che sia compatibile con la vostra macchina host e le vostre altre esigenze. Puoi trovare maggiori informazioni sulle impostazioni di visualizzazione nella [documentazione ufficiale di Oracle](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/settings-display.html).

Se si dispone di molta memoria, è possibile impostare questo valore al massimo a 128 MB. Per risolvere questo problema prima di avviare la macchina virtuale, fate clic su "Settings" (icona a forma di ingranaggio) e dovreste ottenere la stessa schermata di impostazioni che avete ottenuto quando avete allegato la nostra immagine ISO (sopra).

Questa volta:

* Fare clic su "Display" sul lato sinistro.
* Nella scheda "Screen" sul lato destro, si noterà l'opzione "Video Memory" con l'impostazione predefinita di 16 MB.
* Cambiatelo con il valore che volete. Potete regolarlo verso l'alto tornando a questa schermata in qualsiasi momento. In questo esempio, è di 128 MB.

!!! Tip "Suggerimento"

    Ci sono modi per impostare la memoria video fino a 256 MB. Se avete bisogno di più, controllate [questo documento](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-modifyvm.html) dalla documentazione ufficiale di Oracle.

Lo schermo dovrebbe avere un aspetto simile a questo:

![Impostazioni Video](../images/vbox-12.png)

* Clicca "OK"

## Avvio dell'installazione

Avete impostato tutto in modo da poter avviare l'installazione. Si noti che non esistono particolari differenze nell'installazione di Rocky Linux su una macchina VirtualBox&reg; rispetto all'hardware indipendente. I passi dell'installazione sono gli stessi.

Ora che avete preparato tutto per l'installazione, dovete fare clic su "Start" (icona verde con la freccia a destra) per avviare l'installazione di Rocky. Una volta terminata la schermata di selezione della lingua, la schermata successiva è la "Installation Summary." È necessario impostare tutti gli elementi che vi riguardano, ma i seguenti sono necessari:

* Data & Ora
* Selezione del software (se vuoi qualcosa oltre al "Server con GUI" di default)
* Destinazione Installazione
* Rete & Nome Host
* Impostazioni dell'Utente

Se non si è sicuri di queste impostazioni, consultare il documento [Installazione di Rocky](../installation.md).

Una volta terminata l'installazione, dovreste avere un'istanza di VirtualBox&reg; di Rocky Linux in esecuzione.

Dopo l'installazione e il riavvio, viene visualizzata una schermata del contratto di licenza EULA che è necessario accettare. Dopo aver fatto clic su "Finish Configuration", si dovrebbe ottenere un login grafico (se si è scelta l'opzione GUI) o da riga di comando. L'autore ha scelto l'opzione predefinita "Server with GUI" a scopo dimostrativo:

![Una macchina Rocky VirtualBox in esecuzione](../images/vbox-11.png)

## Altre informazioni

Questo documento non intende rendere l'utente un esperto di tutte le funzionalità offerte da VirtualBox&reg;. Per informazioni su come fare cose specifiche, controlla la [documentazione ufficiale](https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/).

!!! tip "Suggerimento avanzato"

    VirtualBox&reg; offre ampie opzioni dalla riga di comando usando `VBoxManage`. Mentre questo documento non copre l'uso di `VBoxManage`, la documentazione ufficiale di Oracle fornisce [molti dettagli] (https://docs.oracle.com/en/virtualization/virtualbox/6.0/user/vboxmanage-intro.html) se volete fare ulteriori ricerche.

## Conclusione

È facile creare, installare ed eseguire una macchina Rocky Linux su VirtualBox&reg;. Anche se non si tratta di una guida esaustiva, seguire i passi di cui sopra dovrebbe permettervi di installare Rocky Linux. Se utilizzate VirtualBox&reg; e avete una configurazione specifica che volete condividere, l'autore vi invita a inviare nuove sezioni a questo documento.
