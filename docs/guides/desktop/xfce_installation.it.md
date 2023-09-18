- - -
title: XFCE Desktop author: Gerard Arthus, Steven Spencer contributors: Steven Spencer, Antoine Le Morvan, K.Prasad, Ganna Zhyrnova tested_with: 8.5, 8.6, 9.0 tags:
  - xfce
  - desktop
- - -

# Ambiente desktop XFCE

L'ambiente desktop XFCE, creato come fork del Common Desktop Environment (CDE), incarna la tradizionale filosofia Unix di modularità e riutilizzabilità. È possibile installare XFCE su quasi tutte le versioni di Linux, compresa Rocky Linux.

È anche uno degli ambienti desktop più facili da combinare con gestori di finestre alternativi, come Awesome o i3. Questa procedura, tuttavia, vi permetterà di essere operativi con Rocky Linux e un'installazione XFCE tradizionale.

## Prerequisiti

* Una Workstation o un notebook
* Desiderio di eseguire XFCE come desktop invece del desktop predefinito GNOME

=== "9"

    ## 9: Introduzione
    
    Il team di sviluppo di Rocky Linux 9 ha reso semplice l'installazione di XFCE e di altri ambienti desktop popolari, includendo immagini live. Per chi non lo sapesse, un'immagine live è un'immagine avviabile che carica il sistema operativo senza installazione. Una volta caricato, è possibile installarlo nell'unità disco del computer e utilizzarlo.
    
    ## 9: Ottenere, verificare e scrivere l'immagine live di XFCE
    
    Prima dell'installazione, il primo passo è scaricare l'immagine live e scriverla su un DVD o una chiavetta USB. Come detto in precedenza, l'immagine sarà avviabile, proprio come qualsiasi altro supporto di installazione per Linux. È possibile trovare l'ultima immagine di XFCE nella sezione download di Rocky Linux 9 [immagini live](https://dl.rockylinux.org/pub/rocky/9.2/live/x86_64/). Si noti che questo particolare collegamento presuppone che x86_64 sia l'architettura del vostro processore. 
    
    Al momento è possibile utilizzare architetture x86_64 o aarch64 per questa immagine live. Scaricare l'immagine live e i file di checksum. 
    
    Verificare l'immagine con il file CHECKSUM come segue
    
    (si noti che questo è un esempio! Assicurarsi che il nome dell'immagine e i file CHECKSUM corrispondano):

    ```
    sha256sum -c CHECKSUM --ignore-missing Rocky-9-XFCE-x86_64-latest.iso.CHECKSUM
    ```


    Se tutto è andato bene, verrà visualizzato questo messaggio:

    ```
    Rocky-9-XFCE-x86_64-latest.iso: OK
    ```


    Se il checksum per il file restituisce OK, ora sei pronto a scrivere la tua immagine ISO sul tuo supporto. Questa procedura varia a seconda del sistema operativo, del supporto e degli strumenti. Si presuppone che sappiate come scrivere l'immagine sul vostro supporto.
    
    ## 9: Avvio
    
    Anche in questo caso la procedura è diversa a seconda della macchina, del BIOS, del sistema operativo e così via. È necessario assicurarsi che la macchina sia impostata per l'avvio dal vostro supporto (DVD o USB) come primo dispositivo di avvio. Questa schermata mostrerà se l'operazione è riuscita:
    
    ![xfce_boot](images/xfce_boot.png)
    
    In caso affermativo, siete sulla buona strada! Se si vuole testare il supporto, si può inserire prima questa opzione, oppure si può inserire **S** per **Avviare Rocky Linux XFCE 9.0**.
    
    Ricordate che si tratta di un'immagine live. L'avvio della prima schermata richiederà un po' di tempo. Non fatevi prendere dal panico, aspettate! Quando si avvia l'immagine live, viene visualizzata questa schermata:
    
    
    ![xfce_install](images/xfce_install.png)
    
    ## 9: Installazione di XFCE
    
    A questo punto, è possibile utilizzare l'ambiente XFCE. Quando si decide di utilizzarlo in modo permanente, fare doppio clic sull'opzione Installa nel Disco Rigido.
    
    Si avvia così un processo di installazione abbastanza familiare per chi ha già installato Rocky Linux. La prima schermata consente di selezionare la lingua predefinita:
    
    ![xfce_language](images/xfce_language.png)
    
    La schermata successiva contiene alcuni elementi da verificare o modificare. Le opzioni sono numerate per riferimento:
    
    ![xfce_install2](images/xfce_install_2.png)

    1. **Tastiera** - Assicurarsi che corrisponda al layout della tastiera in uso.
    2. **Ora e Data** - Assicurarsi che corrisponda al proprio fuso orario.
    3. **Destinazione di installazione** - È necessario fare clic su questa opzione, anche solo per accettare ciò che è già presente.
    4. **Rete e Nome Host** - Verificare che sia presente ciò che si desidera. Se la rete è abilitata, è sempre possibile modificarla in seguito, se necessario.
    5. **Password di Root** - Imposta una password di root. Ricordate di salvarla in un luogo sicuro (gestore di password).
    6. **Creazione di un Utente** - Creare almeno un utente. Se si desidera che l'utente abbia diritti amministrativi, impostare questa opzione al momento della creazione dell'utente.
    7. **Iniziare Installazione** - Una volta completata e verificata, fare clic su questa opzione.

    Una volta eseguito il passo 7, il processo di installazione inizierà a installare i pacchetti, come mostrato in questa schermata:

    ![xfce_install3](images/xfce_install_3.png)

    Al termine dell'installazione sul disco rigido, verrà visualizzata la seguente schermata:

    ![xfce_install_final](images/xfce_install_final.png)

    Fare clic su **Fine Installazione**.

    Dopo aver fatto ciò, si tornerà alla schermata dell'immagine live. Riavviare il computer e rimuovere il supporto di avvio utilizzato per l'installazione di XFCE.

    Si aprirà quindi una schermata di accesso con l'utente creato in precedenza. Immettere la password per accedere al desktop XFCE:

    ![xfce_desktop](images/xfce_desktop.png)

=== "8"

    ## 8: Installare Rocky Linux minimale
    
    !!! note
    
        In questa sezione, è necessario essere l'utente root o essere in grado di eseguire `sudo` per elevare i propri privilegi.
    
    Durante l'installazione di Rocky Linux, abbiamo utilizzato i seguenti pacchetti:

    * Minimal
    * Standard


    ## 8: Eseguire l'aggiornamento del sistema

    Per prima cosa, eseguire il comando di aggiornamento del server. Il sistema ricostruirà la cache del repository. In questo modo, la piattaforma di sistema riconosce i pacchetti disponibili.

    ```
    dnf update
    ```


    ## 8: Abilitazione dei repository

    È necessario il repository non ufficiale di XFCE del repository EPEL, per poter funzionare sulle versioni Rocky 8.x.

    Abilitare questo repository inserendo:

    ```
    dnf install epel-release
    ```

    Rispondere "Y" per installarlo.

    Sono necessari anche i repository Powertools e lightdm. Abilitateli subito:

    ```
    dnf config-manager --set-enabled powertools
    dnf copr enable stenstorp/lightdm
    ```

    !!! Warning "Attenzione"

        Il sistema di compilazione `copr` crea un repository che è noto per funzionare per l'installazione di `lightdm`, ma non è mantenuto dalla comunità Rocky Linux. Utilizzare a proprio rischio e pericolo!

    Anche in questo caso, verrà presentato un messaggio di avvertimento sul repository. Rispondete pure `Y` alla domanda.


    ## 8: Controllare gli ambienti e gli strumenti disponibili nel gruppo

    Ora che i repository sono abilitati, eseguire i seguenti comandi per verificare il tutto.

    Per prima cosa, controllare l'elenco dei repository con:

    ```
    dnf repolist
    ```

    Si dovrebbe ottenere il seguente risultato che mostra tutti i repository abilitati:

    ```bash
    appstream                                                        Rocky Linux 8 - AppStream
    baseos                                                           Rocky Linux 8 - BaseOS
    copr:copr.fedorainfracloud.org:stenstorp:lightdm                 Copr repo for lightdm owned by stenstorp
    epel                                                             Extra Packages for Enterprise Linux 8 - x86_64
    epel-modular                                                     Extra Packages for Enterprise Linux Modular 8 - x86_64
    extras                                                           Rocky Linux 8 - Extras
    powertools                                                       Rocky Linux 8 - PowerTools
    ```

    Eseguire il seguente comando per verificare la presenza di XFCE:

    ```
    dnf grouplist
    ```

    Dovreste vedere "Xfce" in fondo all'elenco.

    Eseguire ancora una volta `dnf update` per assicurarsi che tutti i repository abilitati vengano letti dal sistema.


    ## 8: Installazione dei pacchetti

    Per installare XFCE, eseguire:

    ```
    dnf groupinstall "xfce"
    ```

    Installare anche lightdm:

    ```
    dnf install lightdm
    ```


    ## 8: Fasi finali

    È necessario disabilitare `gdm`, che viene installato e abilitato durante *dnf groupinstall "xfce"*:

    ```
    systemctl disable gdm
    ```

    Ora è possibile abilitare *lightdm*:

    ```
    systemctl enable lightdm
    ```

    È necessario indicare al sistema, dopo l'avvio, di utilizzare solo l'interfaccia grafica. Impostare il sistema di destinazione predefinito sull'interfaccia GUI:

    ```
    systemctl set-default graphical.target
    ```

    Quindi riavviare:

    ```
    reboot
    ```

    Dovrebbe apparire un prompt di login nella GUI di XFCE e, una volta effettuato il login, si avrà a disposizione tutto l'ambiente XFCE.

## Conclusioni

XFCE è un ambiente leggero con un'interfaccia semplice. È un'alternativa al desktop GNOME predefinito su Rocky Linux. Se si utilizza Rocky Linux 9, gli sviluppatori hanno creato una pratica immagine live che velocizza il processo di installazione.
