---
title: Creazione e Installazione di Kernel Linux personalizzati
author: Wale Soyinka
contributors: Steven Spencer, Louis Abel, Ganna Zhyrnova
tags:
  - custom kernel
  - kernel
---

# Panoramica

In questa guida si illustra il processo di acquisizione di un albero dei sorgenti del kernel, la sua configurazione, la compilazione, l'installazione e l'avvio.

!!! warning "Le ricostruzioni del kernel non sono consigliate né supportate per Rocky Linux. Prima di tentare di creare un kernel personalizzato, considerare quanto segue:"

    * La funzionalità richiesta è disponibile installando un modulo del kernel da [elrepo](https://elrepo.org)?
    * La funzionalità richiesta è disponibile come modulo separato dal kernel stesso?
    * Rocky Linux e la maggior parte degli altri derivati di EL sono stati progettati per funzionare come un ambiente completo. La sostituzione dei componenti critici può influire sul funzionamento del sistema.
    * La maggior parte degli utenti non ha più bisogno di creare il proprio kernel. Potrebbe essere necessario un modulo/driver del kernel o forse costruire il proprio modulo del kernel (kmod/dkms)

    Come avvertimento finale: Se rompete il kernel, siete responsabili della risoluzione dei problemi che ne derivano sul vostro sistema.

## Il Kernel

Il più delle volte, quando si parla di _Linux_, si fa riferimento a una_"distribuzione Linux_": ad esempio, Rocky Linux e Debian sono tipi di distribuzione Linux. Una distribuzione comprende tutto ciò che è necessario per far esistere Linux come sistema operativo funzionale. Le distribuzioni utilizzano il codice di vari progetti open-source indipendenti da Linux.

Linux è il kernel. Il kernel si trova letteralmente al centro della questione [del sistema operativo].

L'unica cosa più fondamentale del kernel è l'hardware del sistema stesso. Sebbene il kernel sia una piccola parte di una distribuzione Linux completa, è di gran lunga l'elemento più critico. Se il kernel si guasta o si blocca, il resto del sistema lo segue.

## Il Codice Sorgente del Kernel

La distribuzione Rocky Linux ha a disposizione, in una forma o nell'altra, il codice sorgente per la versione specifica del kernel che supporta. Questi possono essere sotto forma di un binario compilato`(*.src.rpm`), un RPM sorgente`(*.srpm`) e così via.

Se avete bisogno di scaricare una versione diversa (possibilmente più recente) rispetto a quella fornita dalla vostra specifica distribuzione Rocky Linux, il primo posto dove cercare il codice sorgente è il sito web ufficiale del kernel:

[www.kernel.org](https://www.kernel.org)

Questo sito contiene un elenco di siti web che ospitano il codice sorgente del kernel e tantissimi altri software open source, distribuzioni e utilità generiche.

L'elenco dei mirror mantenuti è disponibile all'indirizzo:

[mirrors.kernel.org](http://mirrors.kernel.org)

!!! TIP "Suggerimento"

    La maggior parte delle operazioni di download, configurazione e compilazione del kernel Linux descritte nelle sezioni seguenti possono/devono essere eseguite come utenti non privilegiati. Tuttavia, i passaggi finali che richiedono l'installazione o la modifica dei file di sistema e dei file binari devono essere eseguiti con privilegi elevati.
    
    È possibile eseguire la maggior parte del lavoro come utente non privilegiato perché si utilizzerà un'opzione speciale di creazione del kernel, che consente di specificare una directory di lavoro o di output personalizzata. In particolare, si userà l'opzione `O=~/build/kernel` per tutte le invocazioni di make.
    
    Dove `~/build/kernel` è equivalente a `/home/$USER/build/kernel` o `$HOME/build/kernel`

## Versioni del kernel e convenzioni di denominazione

L'elenco dei kernel disponibili sul sito web conterrà cartelle per v1.0, v2.5, v2.6, v3.0, v3.x, v4.x, v5.x, v6.x e così via. Prima di seguire la vostra naturale inclinazione a prendere l'ultima versione, assicuratevi di aver capito come funziona il sistema di versioni del kernel Linux.

La convenzione attuale è quella di chiamare e numerare le nuove versioni principali del kernel come "Linux 5.x" (chiamate anche kernel vanilla o mainline). Pertanto, la prima di questa serie sarà la versione 5.0 di Linux (uguale alla 5.0.0), la successiva sarà la versione 5.1 di Linux (uguale alla 5.1.0), seguita dalla versione 5.2 e così via.

La terza cifra rappresenta le modifiche o gli aggiornamenti minori all'interno di ogni versione principale. Questi vengono comunemente chiamati rilasci di punti stabili. Pertanto, la prossima release stabile per il kernel della serie 5.0.0 sarà la versione 5.0.1 di Linux, seguita dalla versione 5.0.2 e così via. Un altro modo per affermare ciò è dire, ad esempio, che la versione 5.0.4 di Linux è la quarta release stabile basata sulla serie 5.0.0 di Linux.

## Installare gli strumenti e le librerie richieste

Non avere a disposizione tutto il software necessario per la compilazione e la costruzione del kernel Linux mainline è una fonte comune di fallimento riscontrata durante il processo di creazione del kernel. È possibile installare gli strumenti e le librerie mancanti con il gestore di pacchetti DNF su una distribuzione Rocky Linux. Potete occuparvene qui.

1. Su una distribuzione Rocky Linux, è possibile installare rapidamente la maggior parte degli strumenti di sviluppo necessari eseguendo questo comando:

    ```bash
    sudo dnf -y groupinstall 'Development Tools'
    ```

2. Installando i seguenti pacchetti, si otterranno le altre librerie, i file header e le applicazioni necessarie. Digitare:

    ```bash
    sudo dnf -y install ncurses-devel openssl-devel elfutils-libelf-devel python3
    ```

3. Sono necessarie altre utility disponibili solo in repository speciali. Uno di questi è il repository CRB (Code Ready Builder). Abilitare il repository sul nostro sistema Rocky con:

    ```bash
    sudo dnf config-manager --set-enabled crb
    ```

4. Infine, installare uno dei pacchetti necessari dal repository CRB con:

    ```bash
    sudo  dnf -y install dwarves
    ```

Questo è tutto per quanto riguarda i pacchetti di prerequisiti necessari per la creazione del kernel.

## Scaricare e scompattare il kernel Linux

La versione del kernel che si costruirà nella sezione seguente è la versione **6.5.7**, disponibile all'indirizzo:

[www.kernel.org/pub/linux/kernel/v6.x/linux-6.5.7.tar.xz](https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.5.7.tar.xz)

Iniziamo il processo.

1. Per prima cosa, scaricare i sorgenti del kernel nella directory di lavoro corrente usando il seguente comando `curl`. Digitare:

    ```bash
    curl -L -o linux-6.5.7.tar.xz \
    https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.5.7.tar.xz
    ```

2. Il sorgente del kernel scaricata da Internet è un file compresso, tar file. Pertanto, per utilizzare il file sorgente è necessario decomprimerlo ed estrarlo.

    Assicurarsi di trovarsi nella directory contenente il download del tarball del kernel. Utilizzare il comando `tar` per decomprimere il file, eseguendo:

    ```bash
    tar xvJf linux-6.*.tar.xz
    ```

## Compilare il Kernel

In questa sezione si analizzerà il processo di configurazione e compilazione di un kernel. Ciò è in contrasto con i sistemi operativi basati su macOS o Windows, che vengono forniti preconfigurati e quindi contengono il supporto per molte funzioni che si possono o meno desiderare.

La filosofia di progettazione di Linux permette all'individuo di decidere le parti importanti del kernel. Questa progettazione personalizzata ha l'importante vantaggio di permettere di ridurre l'elenco delle funzionalità in modo che Linux possa funzionare nel modo più efficiente possibile.

Questo è anche uno dei motivi per cui è possibile personalizzare Linux per farlo funzionare in diverse configurazioni hardware, dai sistemi di fascia bassa, ai sistemi embedded, ai sistemi di fascia alta.

La creazione del kernel richiede due fasi principali:

- configurazione
- compilazione

Il primo passo nella costruzione del kernel è la configurazione delle sue caratteristiche. Di solito, l'elenco delle funzionalità si basa sull'hardware da supportare. Ciò significa che è necessario un elenco dell'hardware.

Su un sistema che esegue già Linux, è possibile eseguire comandi come – `lspci`, `lshw`, e così via, per visualizzare informazioni dettagliate sull'esatta configurazione hardware del sistema. Queste utilità provengono dai pacchetti `pciutils*.rpm` e `lshw*.rpm` sulle distribuzioni basate su RPM.

Una migliore comprensione di ciò che costituisce l'hardware sottostante può aiutare a determinare meglio ciò di cui si ha bisogno nel kernel personalizzato. Si è pronti per iniziare a configurare il kernel.

### Sanificazione dell'ambiente di compilazione

È possibile iniziare la configurazione vera e propria con un'idea approssimativa dei tipi di hardware e delle caratteristiche che il nuovo kernel deve supportare. Ma prima, alcune informazioni di base.

L'albero dei sorgenti del kernel Linux contiene diversi file denominati **Makefile** (un makefile è semplicemente un file di testo con delle direttive e descrive anche le relazioni tra i file di un programma).

Questi file make aiutano a incollare insieme le migliaia di altri file che compongono il sorgente del kernel. Ciò che è più importante per noi è che i file make contengono anche i target. I target sono i comandi, o direttive, che vengono eseguiti dal programma make.

!!! warning "Avviso: Evitare inutili aggiornamenti del Kernel"

    Tenete presente che se avete un sistema funzionante, stabile e ben funzionante, non c'è motivo di aggiornare il kernel, a meno che non si verifichi una di queste condizioni:

    - Una correzione di sicurezza o di un bug riguarda il vostro sistema e deve essere applicata
    - Avete bisogno di una nuova funzionalità specifica in una release stabile

    Nel caso di una correzione di sicurezza, decidete se il rischio vi riguarda davvero: ad esempio, se il problema di sicurezza è stato riscontrato in un driver di periferica che non utilizzate, potrebbe non esserci motivo di aggiornare. Nel caso di un rilascio con correzione di bug, leggete attentamente le note di rilascio e decidete se i bug vi riguardano davvero: se avete un sistema stabile, aggiornare il kernel con patch che non usate mai potrebbe essere inutile.

    Sui sistemi di produzione, il kernel non dovrebbe essere aggiornato solo per avere "l'ultimo kernel"; si dovrebbe avere un motivo veramente convincente per aggiornarlo.

Il Makefile nella radice dell'albero dei sorgenti del kernel contiene obiettivi specifici utilizzati per preparare l'ambiente di compilazione del kernel, configurare il kernel, compilare il kernel, installare il kernel e così via. Alcuni dettagli aggiuntivi su questi obiettivi sono:

`make mrproper`
:

Questo obiettivo ripulisce l'ambiente di compilazione da tutti i file e le dipendenze obsolete che potrebbero essere rimaste da una precedente compilazione del kernel. Pulisce (cancella) tutte le configurazioni precedenti del kernel dall'ambiente di creazione.

`make clean`
:

Questo obiettivo non svolge un lavoro così approfondito come l'obiettivo mrproper. Elimina solo la maggior parte dei file generati. Non cancella il file di configurazione del kernel (`.config`).

`make menuconfig`
:

Questo obiettivo richiama un'interfaccia di editor basata sul testo con menu, elenchi di opzioni e finestre di dialogo basate sul testo per la configurazione del kernel.

`make xconfig`
:

Questo strumento/target di configurazione del kernel basato su interfaccia grafica si basa sulle librerie di sviluppo grafico Qt. Le applicazioni basate su KDE/Plasma utilizzano queste librerie.

`make gconfig`
:

Anche questo è uno strumento/target di configurazione del kernel basato su GUI, ma si basa sul toolkit GTK+. Questo toolkit GTK+ è molto utilizzato nel mondo desktop GNOME.

`make olddefconfig`
:

Questo obiettivo utilizza il file .config esistente nella directory di lavoro corrente, aggiorna le dipendenze e imposta automaticamente i nuovi simboli ai valori predefiniti.

`make help`
:

Questo obiettivo mostrerà tutti i possibili obiettivi e servirà come un rapido sistema di aiuto online.

In questa sezione si utilizzerà solo uno dei target per configurare il kernel. In particolare, si utilizzerà il comando make `menuconfig`. L'editor di configurazione del kernel `menuconfig` è una semplice e popolare utility di configurazione basata sul testo e composta da menu, elenchi di pulsanti e finestre di dialogo.

Ha un'interfaccia semplice e pulita che può essere facilmente navigata con la tastiera ed è abbastanza intuitiva da usare.

È necessario cambiare(`cd`) nella directory dei sorgenti del kernel e poi si può iniziare la configurazione del kernel. Prima di iniziare la configurazione effettiva del kernel, è necessario pulire (preparare) l'ambiente di compilazione del kernel usando il comando `make mrproper`:

```bash
cd linux-6.*/
make  O=~/build/kernel mrproper
```

### Configurazione del Kernel

Successivamente, si inizierà a configurare un kernel Linux della serie 6.*. Per esplorare alcuni aspetti interni di questo processo, si abilita il supporto di una funzione specifica che si finge sia una caratteristica indispensabile per il sistema. Una volta capito come funziona, si può applicare la stessa procedura per aggiungere il supporto a qualsiasi nuova funzionalità del kernel. In particolare, dovrete abilitare il supporto per il file system NTFS nel nostro kernel personalizzato.

La maggior parte delle moderne distribuzioni di Linux contiene un file di configurazione del kernel in esecuzione, disponibile sul file system locale come file compresso o normale. Nel sistema Rocky di esempio, questo file risiede nella directory `/boot` e di solito ha un nome simile a `config-*`.

The configuration file contains a list of the options and features enabled for the particular kernel it represents. L'obiettivo è creare un file di configurazione simile a questo attraverso il processo di configurazione del kernel. L'unica differenza tra il file che creerete e quello già pronto è che aggiungerete ulteriori piccole personalizzazioni al vostro.

!!! TIP

    L'uso di un file di configurazione noto e preesistente come quadro di riferimento per la creazione del proprio file personalizzato aiuta a non perdere troppo tempo a duplicare gli sforzi che altri hanno già fatto per trovare ciò che funziona e ciò che non funziona.

I passi seguenti spiegano come configurare il kernel. Si utilizzerà un'utilità di configurazione del kernel basata su testo. È possibile seguire la procedura nel terminale, indipendentemente dal fatto che si utilizzi o meno un ambiente desktop con interfaccia grafica.

1. Per iniziare, si copierà e rinominerà il file di configurazione preesistente dalla directory `/boot` nell'ambiente di creazione del kernel:

    ```bash
    cp /boot/config-`uname -r` ~/build/kernel/.config
    ```

    Utilizziamo `uname -r` per ottenere il file di configurazione del kernel in esecuzione. Il comando `uname -r` stampa la release del kernel in esecuzione. L'utilizzo di questa funzione consente di assicurarsi di ottenere la versione esatta desiderata, nel caso in cui siano presenti altre versioni.

    !!! NOTE

     L'editor di configurazione del kernel Linux inizia a cercare e generare esplicitamente un file chiamato `.config` (pronunciato "dot config") alla radice dell'albero dei sorgenti del kernel. Questo file è nascosto.

2. Avviare l'utilità di configurazione grafica del kernel:

    ```bash
    make O=~/build/kernel menuconfig
    ```

    Verrà visualizzata una schermata simile a questa:

    ![Main Kernel Configuration screen](images/Il01-kernel.png)

    Nella schermata di configurazione del kernel vengono visualizzate circa tre aree. La parte superiore mostra informazioni utili, scorciatoie da tastiera e legende che aiutano a navigare nell'applicazione. Il corpo principale della schermata mostra un elenco espandibile a struttura ad albero delle opzioni del kernel complessivamente configurabili. È possibile approfondire le voci con le frecce nel genitore per visualizzare o configurare le voci dei sottomenu (o figli). Infine, nella parte inferiore della schermata vengono visualizzate le azioni o le opzioni che l'utente può selezionare.

3. Successivamente, si aggiungerà il supporto per NTFS in questo kernel personalizzato a scopo dimostrativo.

    Nella schermata di configurazione principale, utilizzare i tasti freccia per spostarsi ed evidenziare la voce File system. Una volta selezionato File system, premere Invio per visualizzare il menu secondario o le voci secondarie di File system.

    Nella sezione File Systems, utilizzare i tasti freccia per spostarsi su Filesystems DOS/FAT/NT. Premete Invio per visualizzare le voci secondarie per i file system DOS/FAT/NT.

4. Nella sezione Filesystem DOS/FAT/NT, passare al supporto del file system NTFS.

    Digitare ++“M ”++ (maiuscolo) per abilitare i moduli al supporto del file system NTFS.

    Utilizzare i tasti freccia per spostarsi verso il basso fino al supporto del debug NTFS (NUOVO) e premere y per includerlo.

    Utilizzate i tasti freccia per spostarvi verso il basso fino al supporto di scrittura NTFS e premete ++y++ per includerlo. Al termine, accanto a ogni opzione dovrebbe comparire la lettera `M` o il simbolo dell'asterisco (`*`), come quelli mostrati qui:

    ![Kernel Configuration File Systems screen](images/Il02-kernel.png)

    !!! TIP "Suggerimento"
   
        Per ciascuna delle opzioni configurabili, nell'utilità di configurazione del kernel, le parentesi angolari vuote, <>, indicano che la funzione in questione è disabilitata. La lettera `M' tra parentesi angolari, <M>, indica che la funzione deve essere compilata come modulo.
       
        Il simbolo dell'asterisco tra parentesi angolari, <*>, indica che il supporto per la funzione sarà integrato direttamente nel kernel. Di solito è possibile scorrere tutte le opzioni possibili utilizzando la barra spaziatrice della tastiera.

5. Per tornare alla schermata principale dei File Systems, premere due volte il tasto ++esc++ sulla tastiera nella schermata dei File Systems DOS/FAT/NT. Tornare alla schermata principale di configurazione del kernel premendo nuovamente due volte ++esc++ sulla tastiera.

6. Infine, salvare le modifiche nel file `.config` nella radice dell'albero dei sorgenti del kernel e uscire dall'applicazione di configurazione del kernel dopo aver salvato il file premendo di nuovo due volte ++esc++ sulla tastiera.

7. Viene visualizzata una finestra di dialogo che richiede di salvare la nuova configurazione. Assicurarsi che la selezione sia "Yes" e premere invio.

8. Dopo l'uscita dall'utilità di configurazione del kernel, si tornerà alla propria shell, all'interno dell'albero dei sorgenti del kernel. Siete quasi pronti a costruire il vostro kernel.

9. È necessario completare alcune personalizzazioni sulla nostra distribuzione Rocky. Digitare:

    ```bash
    sed -ri '/CONFIG_SYSTEM_TRUSTED_KEYS/s/=.+/=""/g' ~/build/kernel/.config
    ```

    !!! TIP "Suggerimento"

     Per visualizzare i risultati di alcune delle modifiche apportate con lo strumento menuconfig, usare l'utilità grep per visualizzare il file `.config` salvato direttamente. Ad esempio, per visualizzare l'effetto del supporto del file system NTFS precedentemente attivato, digitate quanto segue:
        ```
        $ grep NTFS ~/build/kernel/.config
        CONFIG_NTFS_FS=m
        CONFIG_NTFS_DEBUG=y
        CONFIG_NTFS_RW=y
        ```

    !!! NOTE "Una nota veloce sui Moduli del kernel"

     Il supporto dei moduli caricabili è una caratteristica del kernel Linux che consente il caricamento (o la rimozione) dinamica dei moduli del kernel.    
    
     I moduli del kernel sono pezzi di codice compilato che possono essere inseriti dinamicamente nel kernel in esecuzione, anziché essere integrati in modo permanente nel kernel. In questo modo è possibile attivare le funzioni non utilizzate di frequente, che non occuperanno spazio nella memoria quando non vengono utilizzate.
    
     Fortunatamente, il Kernel Linux è in grado di determinare automaticamente cosa caricare e quando. Naturalmente, non tutte le funzioni possono essere compilate come moduli. Il kernel deve sapere alcune cose prima di poter caricare e scaricare i moduli, ad esempio come accedere al disco rigido e analizzare il file system in cui sono memorizzati i moduli caricabili. Alcuni moduli del kernel vengono comunemente chiamati anche driver.

### Compilazione del Kernel

In the preceding section, you walked through the process of creating a configuration file for the custom kernel that you want to build. In questa sezione si eseguirà la compilazione vera e propria del kernel. Ma prima di fare questo, aggiungerete una semplice personalizzazione all'intero processo.

La personalizzazione finale consisterà nell'aggiungere un'informazione supplementare utilizzata nel nome finale del nostro kernel. Questo ci aiuterà a distinguere questo kernel da qualsiasi altro kernel con lo stesso numero di versione. Si aggiungerà il tag "custom" alle informazioni sulla versione del kernel. Per farlo, modificate il Makefile principale e aggiungete il tag desiderato alla variabile EXTRAVERSION.

La fase di compilazione del processo di creazione del kernel è di gran lunga la più semplice, ma richiede anche più tempo. È sufficiente eseguire il comando `make`, che genererà automaticamente e si occuperà di qualsiasi problema di dipendenza, compilerà il kernel stesso e compilerà qualsiasi funzionalità (o driver) abilitata come modulo caricabile.

A causa della quantità di codice da compilare, preparatevi ad aspettare almeno qualche minuto, a seconda della potenza di elaborazione del vostro sistema. Analizziamo i passaggi specifici necessari per compilare il nuovo kernel.

1. Per prima cosa, aggiungeremo un pezzo in più alla stringa di identificazione del kernel che stiamo per costruire. Mentre siamo ancora nella root dell'albero dei sorgenti del kernel, useremo l'utilità `sed` per modificare il Makefile sul posto. La variabile che si desidera modificare si trova all'inizio del file. Si vuole modificare la riga del file che assomiglia a questa:

    ```bash
    EXTRAVERSION =
    ```

    A questo:

    ```bash
    EXTRAVERSION = -custom
    ```

    Utilizzate il seguente comando `sed` per effettuare la modifica. Digitare:

    ```bash
    sed  -i 's/^EXTRAVERSION.*/EXTRAVERSION = -custom/'  Makefile
    ```

    Si può anche utilizzare un qualsiasi editor di testo con cui si ha dimestichezza per effettuare la modifica. Ricordatevi di salvare le modifiche apportate al file.

2. Passare il target kernelversion al comando make per visualizzare la versione completa del kernel appena personalizzato:

    ```bash
    make O=~/build/kernel kernelversion
    ```

    !!! Tip

     È possibile sfruttare tutta la potenza di elaborazione extra (CPU, core e così via) sulla maggior parte dei sistemi moderni e accelerare notevolmente le operazioni ad alta intensità di CPU come la compilazione del kernel. A tale scopo, è possibile passare un parametro al comando make che specifichi il numero di lavori da eseguire simultaneamente. Il numero di lavori specificato viene quindi distribuito ed eseguito simultaneamente su ciascun core della CPU. La sintassi del comando è:

            ```bash
            make -j N
            ```


         dove N è il numero di lavori da eseguire contemporaneamente. Ad esempio, se si dispone di una CPU con capacità octa (8) core, è possibile digitare:

            ```bash
            make -j 8
            ```

3. L'unico comando necessario per compilare il kernel è il comando `make`:

    ```bash
    $ make  O=~/build/kernel
    make[1]: Entering directory '/home/super/build/kernel'
    SYNC    include/config/auto.conf.cmd
    GEN     Makefile
    HOSTCC  scripts/kconfig/conf.o
    HOSTLD  scripts/kconfig/conf
    GEN     Makefile
    ...<OUTPUT TRUNCATED>…
    LD [M]  sound/usb/usx2y/snd-usb-usx2y.ko
    LD [M]  sound/x86/snd-hdmi-lpe-audio.ko
    LD [M]  sound/xen/snd_xen_front.ko
    LD [M]  virt/lib/irqbypass.ko
    make[1]: Leaving directory '/home/super/build/kernel'
    ```

4. Il prodotto finale di questo comando (cioè il kernel) è in attesa nel percorso:

    ```bash
    ~/build/kernel/arch/x86/boot/bzImage
    ```

5. È necessario installare i moduli perché sono state compilate parti del kernel come moduli (ad esempio, il modulo NTFS). Digitare quanto segue:

    ```bash
    sudo make O=~/build/kernel modules_install
    ```

    Sul nostro sistema Rocky, questo comando installerà tutti i moduli del kernel compilati nella directory `/lib/modules/<new_kernel-version>`. Questo percorso si tradurrà in `/lib/modules/6.5.7-custom/` in questo esempio. È il percorso dal quale il kernel caricherà tutti i moduli caricabili, se necessario.

    !!! TIP "Suggerimento"

     Il footprint  (dimensione) dei moduli del kernel installati tramite `make modules_install` può diventare piuttosto significativo perché i moduli includono simboli di debug. Di conseguenza, si potrebbe facilmente ritrovarsi con una cartella <code>/lib/modules/6.5.7-custom/ di dimensioni prossime ai 5 Gb!
    
     Per questa guida evitiamo queste dimensioni elevate includendo l'opzione `INSTALL_MOD_STRIP=1` nell'invocazione di `make modules_install`. È possibile ridurre la dimensione totale di ordini di grandezza (ad esempio, meno di 200 MB) eliminando questi simboli di debug.
    
     Questo può essere fatto includendo l'opzione INSTALL_MOD_STRIP=1 al comando make modules_install.
    </code>

## Installazione del Kernel

Supponendo di avere un PC e di lavorare dalla directory `~/build/kernel/`, il kernel compilato creato nell'ultimo esercizio si troverà in questo percorso - `<kernel-build-dir>/arch/x86/boot/bzImage` o, per essere precisi, nel nostro esempio `~/build/kernel/arch/x86/boot/bzImage`.

Il file di mappa corrispondente si trova in `~/build/kernel/System.map`. Per la fase di installazione sono necessari entrambi i file.

Il file `System.map` è utile quando il kernel si comporta male e genera messaggi "Oops". I messaggi "Oops" vengono generati su alcuni errori del kernel a causa di bug del kernel o di hardware difettoso.

Questo errore è simile alla schermata blu della morte (BSOD) di Microsoft Windows. Questi messaggi includono molti dettagli sullo stato attuale del sistema, compresi diversi numeri esadecimali.

`System.map` consente a Linux di trasformare i numeri esadecimali in nomi leggibili, facilitando il debug. Sebbene sia principalmente a beneficio degli sviluppatori, può essere utile quando si segnala un problema.

Esaminiamo i passaggi necessari per installare la nuova immagine del kernel.

1. Nella radice della directory di creazione del kernel, copiare e rinominare il file `bzImage` nella directory `/boot`:

    ```bash
    sudo cp ~/build/kernel/arch/x86/boot/bzImage \
    /boot/vmlinuz-<kernel-version>
    ```

    Qui, `<kernel-version>` è il numero di versione del kernel. Il nome del file del kernel di esempio utilizzato in questa guida è `vmlinuz-6.5.7-custom`. Ecco il comando esatto per questo esempio:

    ```bash
    sudo cp ~/build/kernel/arch/x86/boot/bzImage \
    /boot/vmlinuz-6.5.7-custom
    ```

    !!! Note

     La decisione di chiamare l'immagine del kernel `vmlinuz-6.5.7-custom` è in qualche modo arbitraria. È comodo, perché le immagini del kernel sono comunemente indicate come vmlinuz e il suffisso del numero di versione è utile quando si hanno a disposizione più kernel o kernel che forniscono funzionalità specifiche (per esempio `vmlinuz-6.50.0-ws`).

2. Ora che l'immagine del kernel è pronta, copiare e rinominare il file `System.map` corrispondente nella directory `/boot` utilizzando la stessa convenzione di denominazione:

    ```bash
    sudo cp -v  ~/build/kernel/System.map \
    /boot/System.map-6.5.7-custom
    ```

3. Con il kernel al suo posto, il file `System.map` al suo posto e i moduli al suo posto, siamo pronti per il passo finale. La sintassi del comando necessario è:

    ```bash
    kernel-install add <kernel-version> <kernel-image>
    ```

    Qui, `<kernel-version>` è il numero di versione (e il nome) del kernel. E `<kernel-image>` è il percorso dell'immagine del kernel appena compilata.

    Nel nostro esempio, digitate:

    ```bash
    sudo kernel-install \
    add  6.5.7-custom /boot/vmlinuz-6.5.7-custom
    ```

Il comando `kernel-install` è uno script di shell molto utile. Potrebbe non essere disponibile in tutte le distribuzioni Linux, ma è disponibile nelle distribuzioni più recenti Fedora, RHEL e CentOS. Questo strumento automatizza molte delle ultime operazioni manuali che normalmente si dovrebbero fare per impostare il sistema per l'avvio del nuovo kernel appena creato.

In particolare, lo strumento esegue le seguenti operazioni:

- Crea l'immagine iniziale del file system RAM appropriata (l'immagine initramfs, cioè il file `/boot/initramfs-<kernel-version>.img`). Per farlo manualmente sui sistemi in cui `kernel-install` non è disponibile, usare il comando `mkinitramfs`.
- Esegue il comando `depmod` (che crea un elenco di dipendenze dei moduli).
- Aggiorna la configurazione del boot loader.

Per i sistemi che eseguono le versioni più recenti di GRUB2, il file sarà `/boot/grub2/grub.cfg`. Per i sistemi basati su EFI viene aggiornato anche `/boot/efi/<distro>/fedora/grub.cfg`.

Per i sistemi che eseguono le versioni precedenti di GRUB, questo sarà il file `/boot/grub/grub.conf` o `/boot/grub/menu.lst` Per le nuove distro che hanno implementato le nuove specifiche del caricatore di avvio (BLS), una nuova voce del caricatore di avvio verrà aggiunta alla directory `/boot/loader/entries/`, o a qualsiasi directory indicata dalla variabile `blsdir`.

Sul server demo Rocky basato su EFI che esegue GRUB2 utilizzando BLS, la creazione di una nuova voce di avvio avviene nel file del boot loader situato qui: `/boot/loader/entries/6fa25ca775f64accb0d3e53f0e4e6e92-6.5.7-custom.conf`

```bash
$ sudo cat  /boot/loader/entries/6fa25ca775f64accb0d3e53f0e4e6e92-6.5.7-custom.conf
title Rocky Linux (6.5.7-custom) 8.5 (Green Obsidian)
version 6.5.7-custom
linux /vmlinuz-6.5.7-custom
initrd /initramfs-6.5.7-custom.img $tuned_initrd
options $kernelopts $tuned_params
id rocky-20220212013135-6.5.7-custom
grub_users $grub_users
grub_arg --unrestricted
grub_class kernel
```

!!! Note

    La maggior parte delle distro ha a disposizione diverse utility `grub2-*` che possono essere utilizzate per eseguire varie operazioni di pulizia di GRUB2 e del boot loader. Per esempio, si può usare il comando `grub2-set-default` per cambiare o impostare il kernel predefinito all'avvio del sistema.

## Avvio del Kernel personalizzato

La fase successiva consiste nel testare il kernel per assicurarsi che il sistema possa avviarsi con esso.

1. Supponendo di aver eseguito tutto nel modo esatto prescritto dal medico e che tutto abbia funzionato esattamente come indicato dal medico, si può tranquillamente riavviare il sistema e selezionare il nuovo kernel dal menu del boot loader durante l'avvio del sistema:

    ```bash
    sudo reboot
    ```

2. Dopo l'avvio del sistema, è possibile utilizzare il comando `uname` per scoprire il nome del kernel corrente:

    ```bash
    $ uname -r
    6.5.7-custom
    ```

3. Si ricorderà che una delle caratteristiche aggiunte al nuovo kernel è la capacità di supportare il file system NTFS. Assicurarsi che il nuovo kernel abbia effettivamente il supporto per NTFS visualizzando le informazioni sul modulo NTFS:

    ```bash
    [rockstar ~]$ modinfo ntfs
    filename:       /lib/modules/6.5.7-custom/kernel/fs/ntfs/ntfs.ko
    license:        GPL
    version:        2.1.32
    description:    NTFS 1.2/3.x driver - Copyright …..
    ...OUTPUT TRUNCATED...
    ```

Non c'è altro.
