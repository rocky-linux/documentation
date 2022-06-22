---
title: Costruire e installare kernel Linux personalizzati
author: wale soyinka
contributors: Steven Spencer, Franco Colussi
update: 07-Feb-2022
---

# Sommario
In questa guida, passeremo attraverso il processo di acquisizione di un albero sorgente del kernel, configurandolo, compilandolo, e, infine, installando e avviando il kernel.


## Il Kernel

Molto spesso, quando le persone dicono _Linux_, di solito si riferiscono a una "_distribuzione Linux_" —per esempio, Rocky Linux e Debian sono tipi di distribuzione Linux. Una distribuzione comprende tutto il necessario per far sì che Linux esista come sistema operativo funzionale. Le distribuzioni fanno uso di codice da vari progetti open source che sono indipendenti da Linux.

Linux è il kernel. Il kernel si trova letteralmente al centro della questione [del sistema operativo].

L'unica cosa più fondamentale del kernel è l'hardware del sistema stesso. Anche se il kernel è una piccola parte di una distribuzione Linux completa, è di gran lunga l'elemento più critico. Se il kernel fallisce o si blocca, il resto del sistema si blocca con esso.


## Il Codice Sorgente Del Kernel

La distribuzione Rocky Linux ha a disposizione, in una forma o nell'altra, il codice sorgente per la versione specifica del kernel che supporta. Questi possono essere sotto forma di un binario compilato *(.src.rpm), un RPM sorgente (.srpm)* o simili.

Se hai bisogno di scaricare una versione diversa (forse più recente) rispetto a quella fornita dalla tua specifica distribuzione Rocky Linux, il primo posto per cercare il codice sorgente è nel sito web ufficiale del kernel:

[www.kernel.org](https://www.kernel.org)

Questo sito mantiene un elenco di siti web con i mirror dei sorgenti del kernel, oltre a tonnellate di altro software open source, distribuzioni e utilità generiche.

L'elenco dei mirrors è mantenuto su:

[mirrors.kernel.org](http://mirrors.kernel.org)


!!! TIP "Suggerimento"

    La maggior parte delle operazioni di download, configurazione e compilazione del kernel Linux descritte nelle sezioni seguenti possono/devono essere eseguite da utenti non privilegiati, ma le fasi finali che richiedono l'installazione o la modifica dei file di sistema e dei file binari devono essere eseguite con privilegi elevati.
    
    Saremo in grado di svolgere la maggior parte del lavoro come utente non privilegiato perché useremo una speciale opzione di compilazione del kernel, che ci permette di specificare una directory di lavoro o di output personalizzata. In particolare, useremo l'opzione `O=~/build/kernel` per tutte le invocazioni di make.
    
    Dove `~/build/kernel` è equivalente a `/home/$USER/build/kernel` o  `$HOME/build/kernel`

## Versioni del kernel e convenzioni di denominazione

L'elenco del sito web dei kernel disponibili conterrà cartelle per v1.0, v2.5, v2.6, v3.0, v3.x, v4.x, v5.x, v6.x e così via. Prima di seguire la vostra naturale inclinazione a prendere l'ultima versione, assicuratevi di aver capito come funziona il sistema di versioni del kernel Linux.

La convenzione attuale è quella di chiamare e numerare le nuove versioni principali del kernel come "Linux 5.x" (chiamate anche kernel vanilla o mainline). Pertanto, la prima di questa serie sarà la versione 5.0 di Linux (uguale alla 5.0.0), la successiva sarà la versione 5.1 di Linux (uguale alla 5.1.0), seguita dalla versione 5.2 e così via.

Eventuali modifiche o aggiornamenti minori all'interno di ciascuna versione della major release si rifletteranno con incrementi alla terza cifra. Questi vengono comunemente chiamati rilasci di punti stabili. Pertanto, la prossima release stabile per il kernel della serie 5.0.0 sarà la versione 5.0.1 di Linux, seguita dalla versione 5.0.2 e così via. Un altro modo per affermare ciò è dire, ad esempio, che la versione 5.0.4 di Linux è la quarta release stabile basata sulla serie 5.0.0 di Linux.

## Installare gli strumenti e le librerie richieste

Una fonte comune di fallimento riscontrata durante il processo di creazione del kernel può essere causata dalla mancanza di tutto il software necessario per la compilazione e la creazione del kernel Linux mainline.  Gli strumenti e le librerie mancanti possono essere installate utilizzando il gestore di pacchetti DNF su una distro Rocky Linux. Ci occuperemo di questo in questa sezione.

1. Su una distribuzione Rocky Linux, è possibile ottenere rapidamente la maggior parte degli strumenti di sviluppo necessari installati eseguendo questo comando:

    ```
    > sudo dnf -y groupinstall 'C Development Tools and Libraries'
    ```

2. Alcune altre librerie, file di intestazione e applicazioni di cui si potrebbe aver bisogno possono essere ottenute installando i seguenti pacchetti. Digita:

    ```
    > sudo dnf -y install \
    ncurses-devel openssl-devel elfutils-libelf-devel python3
    ```

3. Successivamente, abbiamo bisogno di altre utilità che sono disponibili solo in alcuni archivi di terze parti supportati. Uno di queste repository è il repo di Powertools. Abilitiamo questo repo sul nostro sistema Rocky. Digita:

    ```
    > sudo dnf config-manager --set-enabled powertools
    ```

4. Infine, installiamo uno dei pacchetti necessari dal repo Powertool. Digita:

    ```
    > sudo  dnf -y install dwarves
    ```

Questo è tutto per quanto riguarda i pacchetti richiesti necessari per la costruzione del Kernel!

## Scaricare e decomprimere il kernel Linux

La versione del kernel che stiamo per costruire nella sezione seguente è la versione 5.16.9, disponibile all'indirizzo:

[www.kernel.org/pub/linux/kernel/v5.x/linux-5.16.9.tar.xz](https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.16.9.tar.xz)

Iniziamo il processo.

1. Innanzitutto, utilizzare il seguente comando curl per scaricare il sorgente del kernel necessario nella directory di lavoro corrente. Digita:

    ```
    curl -L -o linux-5.16.9.tar.xz \
    https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.16.9.tar.xz
    ```

2. Il sorgente del kernel che scaricherai da Internet è un file che è stato compresso con tar. Pertanto, per utilizzare i sorgenti, è necessario decomprimere e fare l'untar del file sorgente.

    Assicurarsi di essere nella directory in cui si è scaricato il tarball del Kernel. Utilizzare il comando tar per scompattare e decomprimere il file, eseguendo:

    ```
    tar xvJf linux-5.*.tar.xz
    ```

## Costruire il Kernel

In questa sezione, esamineremo il processo di configurazione e costruzione di un kernel. Questo è in contrasto con macOS o sistemi operativi basati su Windows, che vengono preconfigurati e quindi contengono supporto per molte funzioni che potresti non volere.

La filosofia di progettazione di Linux consente all'individuo di decidere le parti importanti del kernel. Questa progettazione personalizzata ha l'importante vantaggio di consentire di ridurre l'elenco delle funzionalità in modo che Linux possa funzionare nel modo più efficiente possibile.

Questo è anche uno dei motivi per cui è possibile personalizzare Linux per farlo funzionare in diverse configurazioni hardware, dai sistemi di fascia bassa, ai sistemi embedded, ai sistemi di fascia alta.

Due passi principali sono necessari per costruire un kernel:

- configurazione
- compilazione

Il primo passo nella costruzione del kernel è la configurazione delle sue funzionalità. Di solito, la lista di funzionalità desiderata sarà basata su qualsiasi hardware è necessario supportare. Questo, naturalmente, significa che avrete bisogno di un elenco di quell'hardware.

Su un sistema che esegue già Linux, è possibile eseguire comandi come lspci, lshw e così via per visualizzare informazioni dettagliate sull'esatta configurazione hardware del sistema. Nelle distro basate su RPM queste utilità sono fornite dai pacchetti *pciutils.rpm e lshw.rpm*.

Una migliore comprensione di ciò che costituisce l'hardware sottostante può aiutare a determinare meglio ciò di cui si ha bisogno nel kernel personalizzato. Sei pronto per iniziare a configurare il kernel.

### Sanificazione dell'ambiente di compilazione

Con un'idea approssimativa dei tipi di hardware e delle caratteristiche che il nostro nuovo kernel ha bisogno di supportare, possiamo iniziare la configurazione reale. Ma prima, alcune informazioni di base.

L'albero dei sorgenti del kernel Linux contiene diversi file denominati Makefile (un makefile è semplicemente un file di testo con delle direttive e descrive anche le relazioni tra i file di un programma).

Questi makefile aiutano a incollare insieme le migliaia di altri file che compongono il sorgente del kernel. Ciò che è più importante per noi è che i makefile contengono anche obiettivi. Gli obiettivi sono i comandi, o direttive, che vengono eseguiti dal programma make.


!!! Caution "Attenzione: Evitare Inutili Aggiornamenti Kernel"

    Tenete presente che se avete un sistema funzionante, stabile e ben funzionante, non c'è motivo di aggiornare il kernel, a meno che non si verifichi una di queste condizioni:

    - Un bug fix o di sicurezza influisce sul sistema e deve essere applicato
    - Hai bisogno di una nuova funzione specifica in un rilascio stabile

    Nel caso di una correzione di sicurezza, decidete se il rischio vi riguarda davvero: ad esempio, se il problema di sicurezza è stato riscontrato in un driver di periferica che non utilizzate, potrebbe non esserci motivo di aggiornare. Nel caso di un rilascio con correzione di bug, leggete attentamente le note di rilascio e decidete se i bug vi riguardano davvero: se avete un sistema stabile, aggiornare il kernel con patch che non usate mai potrebbe essere inutile.

    Sui sistemi di produzione, il kernel non dovrebbe essere semplicemente aggiornato solo per avere “il kernel più recente”; si dovrebbe avere una ragione davvero convincente per aggiornarlo.

Il Makefile nella radice dell'albero dei sorgenti del kernel contiene obiettivi specifici che possono essere usati per preparare l'ambiente di compilazione del kernel, configurare il kernel, compilare il kernel, installare il kernel e così via. Alcuni degli obiettivi sono discussi in dettaglio qui:

- **make mrproper** Questo obiettivo ripulisce l'ambiente di compilazione da tutti i file e le dipendenze obsolete che potrebbero essere rimaste da una precedente compilazione del kernel. Tutte le configurazioni del kernel precedenti verranno pulite (eliminate) dall'ambiente di compilazione.
- **make clean** Questo obiettivo non svolge un lavoro così approfondito come l'obiettivo mrproper. Elimina solo la maggior parte dei file generati. Non elimina il file di configurazione del kernel (.config).
- **make menuconfig** Questo obiettivo richiama un'interfaccia di editor basata sul testo con menu, elenchi di opzioni e finestre di dialogo basate sul testo per la configurazione del kernel.
- **make xconfig** Si tratta di uno strumento/obiettivo di configurazione del kernel basato su interfaccia grafica che si basa sulle librerie di sviluppo grafico Qt. Queste librerie sono usate da applicazioni basate su KDE/Plasma.
- **make gconfig** Anche questo è uno strumento/obiettivo di configurazione del kernel basato su GUI, ma si basa sul toolkit GTK+. Questo toolkit GTK è usato pesantemente nel mondo del desktop GNOME.
- **make olddefconfig** Questo obiettivo utilizza il file .config esistente nella directory di lavoro corrente, aggiorna le dipendenze e imposta automaticamente i nuovi simboli ai valori predefiniti.
- **make help** Questo obiettivo mostra tutti gli altri possibili obiettivi di creazione e funge anche da rapido sistema di guida in linea.

Per configurare il kernel in questa sezione, utilizzeremo solo uno degli obiettivi. In particolare, useremo il comando make menuconfig. L'editor di configurazione del kernel menuconfig è una semplice e popolare utilità di configurazione basata sul testo che consiste di menu, elenchi di pulsanti radio e dialoghi.

Ha un'interfaccia semplice e pulita che può essere facilmente navigata con la tastiera ed è abbastanza intuitivo da usare.

Dobbiamo cambiare (cd) nella directory dei sorgenti del kernel, dopodiché possiamo iniziare la configurazione del kernel. Ma prima di iniziare la configurazione reale del kernel, è necessario pulire (preparare) l'ambiente di generazione del kernel utilizzando il comando make mrproper:

```
> cd linux-5.*
> make  O=~/build/kernel mrproper
```

### Configurazione del Kernel

Successivamente, verrà illustrato il processo di configurazione di un kernel Linux serie 5.*. Per esplorare alcuni dei meccanismi interni di questo processo, abiliteremo il supporto di una funzione specifica che fingeremo essere una caratteristica indispensabile del sistema. Una volta capito come funziona, si può applicare la stessa procedura per aggiungere il supporto a qualsiasi altra nuova funzione del kernel che si desidera. In particolare, attiveremo il supporto per il file system NTFS nel nostro kernel personalizzato.

La maggior parte delle moderne distro Linux viene fornita con un file di configurazione del kernel in esecuzione, disponibile sul file system locale come file compresso o normale. Nel nostro sistema Rocky di esempio, questo file risiede nella directory /boot e di solito ha un nome come config-4.*.

Il file di configurazione contiene un elenco delle opzioni e delle caratteristiche abilitate per il particolare kernel che rappresenta. Un file di configurazione simile a questo è quello che si vuole creare durante il processo di configurazione del kernel. L'unica differenza tra il file che creeremo e quello già pronto è che al nostro aggiungeremo ulteriori piccole personalizzazioni.


!!! TIP "Suggerimento"

    L'utilizzo di un file di configurazione noto e preesistente come quadro di riferimento per la creazione del nostro file personalizzato ci permette di non perdere troppo tempo a duplicare gli sforzi che altre persone hanno già fatto per trovare ciò che funziona e ciò che non funziona!

I passi seguenti spiegano come configurare il kernel. Utilizzeremo un'utilità di configurazione del kernel basata sul testo, che vi consentirà di seguire la procedura nel vostro terminale, indipendentemente dal fatto che utilizziate o meno un ambiente desktop con interfaccia grafica.

1. Per iniziare, copiamo e rinominiamo il file di configurazione preesistente dalla directory /boot nel nostro ambiente di creazione del kernel:
    ```
    > cp /boot/config-`uname -r` ~/build/kernel/.config
    ```
    Qui si usa `uname -r` per ottenere il file di configurazione del kernel in esecuzione. Il comando uname -r stampa la release del kernel in esecuzione. L'utilizzo di questa funzione ci consente di assicurarci di ottenere la versione esatta che desideriamo, nel caso in cui siano presenti altre versioni.

    !!! NOTE "Nota"

     L'editor di configurazione del kernel Linux inizia a cercare, e finisce per generare, un file chiamato .config (pronunciato "dot config") nella radice dell'albero dei sorgenti del kernel. Questo file è nascosto.

2. Avviare l'utilità di configurazione del kernel grafico:

    ```       
    > make O=~/build/kernel menuconfig
    ```

    Apparirà una schermata simile a questa:

![Schermata Principale di Configurazione del Kernel](images/Il01-kernel.png)

    La schermata di configurazione del kernel che appare è divisa approssimativamente in tre aree.
    La parte superiore mostra varie informazioni utili, scorciatoie da tastiera e legende che possono aiutare a navigare nell'applicazione.
    Il corpo principale della schermata mostra un elenco espandibile a struttura ad albero delle opzioni del kernel complessivamente configurabili. È possibile approfondire le voci con le frecce di controllo per visualizzare e/o configurare le voci dei sottomenu (o figli). Infine, nella parte inferiore dello schermo vengono visualizzate le azioni/opzioni che l'utente può scegliere.

3. Successivamente, a scopo dimostrativo, aggiungeremo il supporto per NTFS nel nostro kernel personalizzato.

    Nella schermata della configurazione principale, utilizzare i tasti freccia per spostarsi ed evidenziare la voce File systems. Una volta selezionato File systems, premere invio per visualizzare il menu secondario o le voci secondarie di File systems.

    Nella sezione File Systems utilizzare i tasti freccia per spostarsi su DOS/FAT/NT Filesystems. Premete invio per visualizzare le voci secondarie per i file system DOS/FAT/NT.

4. Nella sezione Filesystem DOS/FAT/NT, passare al supporto del file system NTFS.

    Digitare M (maiuscolo) per abilitare il supporto del file system NTFS tramite moduli.

    Utilizzare i tasti freccia per spostarsi verso il basso fino a NTFS debugging support NTFS (NEW) e premere y per includerlo.

    Utilizzare i tasti freccia per spostarsi verso il basso fino a NTFS write support e premere y per includerlo. Al termine, accanto a ogni opzione dovrebbe comparire la lettera M o il simbolo dell'asterisco (*), come quelli mostrati qui:

    ![Schermata Configurazione File Systems del Kernel](images/Il02-kernel.png)

    !!! TIP "Suggerimento"
   
        Per ciascuna delle opzioni configurabili, nell'utilità di configurazione del kernel, le parentesi angolari vuote, <>, indicano che la funzione in questione è disabilitata. La lettera M tra parentesi angolari, <M>, indica che la funzione deve essere compilata come modulo.

    Il simbolo dell'asterisco tra parentesi angolari, <*>, indica che il supporto per la funzione sarà integrato direttamente nel kernel. Di solito è possibile scorrere tutte le opzioni possibili utilizzando la barra spaziatrice della tastiera.

5. Tornare alla schermata principale dei File Systems premendo due volte il tasto esc sulla tastiera nella schermata DOS/FAT/NT Filesystems. Tornare alla schermata principale di configurazione del kernel premendo nuovamente due volte esc sulla tastiera.

6. Infine, salvare le modifiche nel file .config nella radice dell'albero dei sorgenti del kernel e uscire dall'applicazione di configurazione del kernel dopo aver salvato il file premendo di nuovo esc due volte sulla tastiera.

7. Apparirà una finestra di dialogo che ti chiederà di salvare la tua nuova configurazione. Assicurarsi che Yes sia selezionato e quindi premere Invio.

8. Dopo l'uscita dall'utilità di configurazione del kernel, si tornerà alla shell all'interno dell'albero dei sorgenti del kernel!

9. Dobbiamo completare alcune personalizzazioni sulla nostra distro Rocky. Digita:

    ```
    sed -ri '/CONFIG_SYSTEM_TRUSTED_KEYS/s/=.+/=""/g' ~/build/kernel/.config
    ```

    !!! TIP "Suggerimento"

     Per visualizzare i risultati di alcune delle modifiche apportate con lo strumento menuconfig, usare l'utilità grep per visualizzare direttamente il file .config salvato. Ad esempio, per visualizzare l'effetto del supporto del file system NTFS attivato in precedenza, digitate quanto segue:
        ```
        > grep NTFS ~/build/kernel/.config
        CONFIG_NTFS_FS=m
        CONFIG_NTFS_DEBUG=y
        CONFIG_NTFS_RW=y
        ```
    !!! NOTE "Una Breve Nota sui Moduli del Kernel"

     Il supporto per i moduli caricabili è una caratteristica del kernel Linux che consente il caricamento (o la rimozione) dinamica dei moduli del kernel.
    
     I moduli del kernel sono pezzi di codice compilato che possono essere inseriti dinamicamente nel kernel in esecuzione, anziché essere integrati in modo permanente nel kernel. Le funzioni non utilizzate di frequente possono quindi essere abilitate, ma non occuperanno spazio nella memoria quando non vengono utilizzate.
    
     Fortunatamente, il kernel Linux è in grado di determinare automaticamente cosa caricare e quando. Naturalmente, non tutte le funzioni possono essere compilate come moduli. Il kernel deve sapere alcune cose prima di poter caricare e scaricare i moduli, ad esempio come accedere al disco rigido e analizzare il file system in cui sono memorizzati i moduli caricabili. Alcuni moduli del kernel vengono comunemente chiamati anche driver.

### Compilazione del Kernel

Nella sezione precedente abbiamo illustrato il processo di creazione di un file di configurazione per il kernel personalizzato che vogliamo costruire. In questa sezione, eseguiremo la costruzione effettiva del kernel. Ma prima di fare questo, aggiungeremo una semplice personalizzazione all'intero processo.

La personalizzazione finale consisterà nell'aggiungere un'informazione supplementare utilizzata nel nome finale del nostro kernel. Questo ci aiuterà a distinguere questo kernel da qualsiasi altro kernel con lo stesso numero di versione. Aggiungeremo il tag "custom" alle informazioni sulla versione del kernel. Questo può essere fatto modificando il Makefile principale e aggiungendo il tag desiderato alla variabile EXTRAVERSION.

La fase di compilazione del processo di creazione del kernel è di gran lunga la più semplice, ma richiede anche più tempo. A questo punto è sufficiente eseguire il comando make, che genererà automaticamente e si occuperà di eventuali problemi di dipendenza, compilerà il kernel stesso e compilerà tutte le funzionalità (o i driver) che sono state abilitate come moduli caricabili.

A causa della quantità di codice che deve essere compilato, preparatevi ad aspettare almeno qualche minuto, a seconda della potenza di elaborazione del vostro sistema. Analizziamo i passi specifici necessari per compilare il nuovo kernel.

1. Per prima cosa aggiungeremo un pezzo in più alla stringa di identificazione del kernel che stiamo per costruire. Mentre siamo ancora nella radice dell'albero dei sorgenti del kernel, useremo l'utilità sed per modificare il Makefile. La variabile che vogliamo cambiare è vicina alla parte superiore del file. Vogliamo cambiare la riga nel file che assomiglia a questa:

    ```
    EXTRAVERSION =
    ```

    In questa:

    ```
    EXTRAVERSION = -custom
    ```

    Usa il seguente comando `sed` per effettuare la modifica. Digita:

    ```
    sed  -i 's/^EXTRAVERSION.*/EXTRAVERSION = -custom/'  Makefile
    ```

    Naturalmente è possibile utilizzare qualsiasi editor di testo con cui si ha dimestichezza per apportare le modifiche. Basta ricordarsi di salvare le modifiche al file!

2. Passare il target kernelversion al comando make per visualizzare la versione completa del kernel appena personalizzato:

    ```
    > make O=~/build/kernel kernelversion
    ```

    !!! Tip "Suggerimento"

     È possibile sfruttare tutta la potenza di elaborazione extra (CPU, core e così via) sulla maggior parte dei sistemi moderni e accelerare notevolmente le operazioni ad alta intensità di CPU come la compilazione del kernel. A tale scopo, è possibile passare un parametro al comando make che specifichi il numero di lavori da eseguire simultaneamente. Il numero di lavori specificato viene quindi distribuito ed eseguito simultaneamente su ciascun core della CPU. La sintassi del comando è:

    ```
    > make -j N
    ```
    dove N è il numero di lavori da eseguire contemporaneamente. Ad esempio, se si dispone di una CPU con capacità octa (8) core, è possibile digitare:

    ```
    > make -j 8
    ```

3. L'unico comando necessario per compilare il kernel è il comando make:

    ```
    > make  O=~/build/kernel**
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

    ```
    ~/build/kernel/arch/x86/boot/bzImage
    ```

5. Poiché abbiamo compilato parti del kernel come moduli (ad esempio, il modulo NTFS), dobbiamo installare i moduli. Digitare quanto segue:

    ```
    > sudo make O=~/build/kernel modules_install
    ```

    Sul nostro sistema Rocky, questo comando installerà tutti i moduli compilati del kernel nella cartella /lib/modules/<new_kernel-version> . In questo esempio, il percorso si tradurrà in /lib/modules/5.16.9-custom/. È il percorso dal quale il kernel caricherà tutti i moduli caricabili, se necessario.

    !!! TIP "Suggerimento"

     Il footprint (dimensione) dei moduli del kernel installati tramite "make modules_install" può diventare piuttosto grande perché i moduli includono simboli di debug. Di conseguenza, si potrebbe facilmente ritrovarsi con una cartella `/lib/modules/5.16.9-custom/` di dimensioni prossime ai 5 Gb!
    
     Per questa guida evitiamo queste dimensioni elevate includendo l'opzione INSTALL_MOD_STRIP=1 nell'invocazione di make modules_install. È possibile ridurre la dimensione totale in ordini di grandezza (ad esempio, meno di 200 MB!) eliminando questi simboli di debug.  
    
     Questo può essere fatto includendo l'opzione `INSTALL_MOD_STRIP=1` al comando `make modules_install`.

## Installazione del Kernel

Supponendo che tu abbia un PC e stia lavorando fuori dalla directory `~/build/kernel/`, il kernel compilato creato nell'esercizio precedente si troverà in questo percorso - `<kernel-build-dir>/arch/x86/boot/bzImage` oppure, per essere precisi, nel nostro esempio  `~/build/kernel/arch/x86/boot/bzImage`.

Il file di mappa corrispondente per questo si trova in ~/build/kernel/System.map. Avrete bisogno di entrambi i file per la fase di installazione.

Il file System.map è utile quando il kernel si comporta erroneamente e genera messaggi “Oops”. Un "Oops" viene generato su alcuni errori del kernel a causa di bug del kernel o di hardware difettoso.

Questo errore è simile al Blue Screen of Death (BSOD) di Microsoft Windows. Questi messaggi includono molti dettagli sullo stato attuale del sistema, compresi diversi numeri esadecimali.

System.map dà a Linux la possibilità di trasformare i numeri esadecimali in nomi leggibili, facilitando il debug. Sebbene sia principalmente a beneficio degli sviluppatori, può essere utile quando si segnala un problema.

Esaminiamo i passaggi necessari per installare la nuova immagine del kernel.

1. Nella radice della directory di creazione del kernel, copiare e rinominare il file bzImage nella directory /boot:

    ```
    > **sudo cp ~/build/kernel/arch/x86/boot/bzImage  \
    /boot/vmlinuz-<kernel-version>**
    ```

    Qui, kernel-version è il numero di versione del kernel. Per il kernel di esempio che stiamo usando in questa guida, il nome del file sarà vmlinuz-5.16.9-custom. Ecco il comando esatto per questo esempio:

    ```
    > sudo cp ~/build/kernel/arch/x86/boot/bzImage  \
    /boot/vmlinuz-5.16.9-custom
    ```

    !!! Note "Nota"

     La decisione di chiamare l'immagine del kernel vmlinuz-5.16.9-custom è in qualche modo arbitraria. È comodo, perché le immagini del kernel sono comunemente chiamate vmlinuz e il suffisso del numero di versione è utile quando si hanno a disposizione più kernel o kernel che forniscono funzionalità specifiche (per esempio vmlinuz-6.50.0-ws).

2. Ora che l'immagine del kernel è pronta, copiare e rinominare il file System.map corrispondente nella directory /boot utilizzando la stessa convenzione di denominazione:

    ```
    > sudo cp -v  ~/build/kernel/System.map \
    /boot/System.map-5.16.9-custom
    ```

3. Con il kernel a posto, il file System.map a posto e i moduli a posto, siamo pronti per il passo finale. La sintassi del comando necessario è:

    ```
    > kernel-install add   <kernel-version>  <kernel-image>
    ```

    Qui, <kernel-version> è il numero di versione (e il nome) del kernel. E <kernel-image> è il percorso all'immagine del kernel appena compilata.

    Per il nostro esempio, digitare:

    ```
    > sudo kernel-install \
    add  5.16.9-custom /boot/vmlinuz-5.16.9-custom
    ```

Il comando kernel-install utilizzato qui è un piccolo script di shell. Forse non è disponibile in tutte le distribuzioni Linux, ma lo è nelle più recenti Fedora, RHEL e CentOS. Questo strumento automatizza molte delle ultime operazioni manuali che normalmente dovremmo fare per configurare il sistema per l'avvio del nuovo kernel appena creato.

In particolare, lo strumento fa quanto segue:

- Crea l'immagine iniziale del file system RAM (l'immagine initramfs, cioè l'/boot/initramfs-<kernel-version>.img file). Per eseguire questa operazione manualmente sui sistemi in cui kernel-install non è disponibile, utilizzare il comando mkinitramfs.
- Esegue il comando depmod (che crea un elenco delle dipendenze dei moduli).
- Aggiorna la configurazione del boot loader.

Per i sistemi che eseguono le versioni più recenti di GRUB2, il file sarà `/boot/grub2/grub.cfg`. Per i sistemi EFI /boot/efi/<distro>/fedora/grub.cfg viene anche aggiornato.

E per i sistemi che eseguono le versioni legacy di GRUB, questo sarà il file /boot/grub/grub.conf o /boot/grub/menu.lst. Per le nuove distro che hanno implementato le nuove Boot Loader Specification (BLS), verrà aggiunta una nuova voce del boot loader alla directory /boot/loader/entries/ o a qualsiasi directory indicata dalla variabile "blsdir".

Sul nostro server demo Rocky basato su EFI che esegue GRUB 2 utilizzando BLS, viene creata una nuova voce di avvio nel file del boot loader che si trova qui: `/boot/loader/entries/6fa25ca775f64accb0d3e53f0e4e6e92-5.16.9-custom.conf`

```
> sudo cat  /boot/loader/entries/6fa25ca775f64accb0d3e53f0e4e6e92-5.16.9-custom.conf
title Rocky Linux (5.16.9-custom) 8.5 (Green Obsidian)
version 5.16.9-custom
linux /vmlinuz-5.16.9-custom
initrd /initramfs-5.16.9-custom.img $tuned_initrd
options $kernelopts $tuned_params
id rocky-20220212013135-5.16.9-custom
grub_users $grub_users
grub_arg --unrestricted
grub_class kernel
```

!!! Note "Nota"

    La maggior parte delle distro ha a disposizione diverse utility grub2-* che possono essere utilizzate per eseguire varie operazioni di manutenzione di GRUB2 e del boot loader. Ad esempio, si può usare il comando grub2-set-default per modificare o impostare il kernel predefinito da avviare all'avvio del sistema.

## Avviare il Kernel personalizzato
La fase successiva è quella di testare il nuovo kernel per assicurarsi che il sistema possa effettivamente avviarsi con esso.

1. Supponendo di aver eseguito tutto nel modo esatto prescritto dal medico e che tutto abbia funzionato esattamente come indicato dal medico, si può tranquillamente riavviare il sistema e selezionare il nuovo kernel dal menu del boot loader durante l'avvio del sistema:

    ```
    >  sudo reboot
    ```

2. Dopo l'avvio del sistema, è possibile utilizzare il comando uname per scoprire il nome del kernel corrente:

    ```
    >  uname -r
    5.16.9-custom
    ```

3. Si ricorderà che una delle caratteristiche aggiunte al nuovo kernel è la capacità di supportare il file system NTFS. Assicurarsi che il nuovo kernel abbia effettivamente il supporto per NTFS visualizzando le informazioni sul modulo NTFS:

    ```
    [rockstar ~]$ modinfo ntfs
    filename:       /lib/modules/5.16.9-custom/kernel/fs/ntfs/ntfs.ko
    license:        GPL
    version:        2.1.32
    description:    NTFS 1.2/3.x driver - Copyright …..
    ...<OUTPUT TRUNCATED>...
    ```

E questo è tutto!
