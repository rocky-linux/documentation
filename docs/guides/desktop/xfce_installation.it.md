- - -
title: XFCE Desktop Environment author: Gerard Arthus contributors: Steven Spencer, Antoine Le Morvan, K.Prasad tags:
  - xfce
  - desktop
- - -

# Ambiente desktop XFCE

L'ambiente desktop XFCE è stato creato come fork del Common Desktop Environment (CDE). XFCE incarna la tradizionale filosofia Unix di modularità e riutilizzabilità. XFCE può essere installato su quasi tutte le versioni di Linux, compresa Rocky Linux.

È anche uno degli ambienti desktop più facili da combinare con gestori di finestre alternativi, come awesome o i3. Questa procedura, tuttavia, è stata pensata per farvi iniziare a lavorare con Rocky Linux utilizzando una tipica installazione XFCE.

## Prerequisiti

* Una workstation o un computer portatile
* Desiderio di eseguire XFCE come desktop invece del desktop predefinito di GNOME

=== "9"

    ## 9: Introduzione
    
    Il team di sviluppo di Rocky Linux 9 ha reso semplice l'installazione di XFCE e di altri ambienti desktop popolari, includendo immagini live. Un'immagine live, per chi non lo sapesse, è un'immagine avviabile che carica il sistema operativo senza installazione. Una volta caricato, è possibile installarlo nell'unità disco del computer e utilizzarlo.
    
    ## 9: Ottenere, verificare e scrivere l'immagine live di XFCE
    
    Prima dell'installazione, il primo passo è scaricare l'immagine live e scriverla su un DVD o una chiavetta USB. Come detto in precedenza, l'immagine sarà avviabile, proprio come qualsiasi altro supporto di installazione per Linux. È possibile trovare l'ultima immagine di XFCE nella sezione download di Rocky Linux 9 [immagini live](https://dl.rockylinux.org/pub/rocky/9.2/live/x86_64/). 
    Si noti che questo particolare collegamento presuppone che x86_64 sia l'architettura del vostro processore. 
    
    A partire da questo momento, è possibile utilizzare architetture x86_64 o aarch64 per questa immagine live. Scaricare sia l'immagine live che i file di checksum. 
    
    Ora verificare l'immagine con il file CHECKSUM utilizzando il seguente metodo
    (si noti che questo è un esempio! Assicurarsi che il nome dell'immagine e i file CHECKSUM corrispondano):

    ```
    sha256sum -c CHECKSUM --ignore-missing Rocky-9-XFCE-x86_64-latest.iso.CHECKSUM
    ```


    Se tutto va bene, si dovrebbe vedere questo messaggio:

    ```
    Rocky-9-XFCE-x86_64-latest.iso: OK
    ```


    Se il checksum per il file restituisce OK, ora sei pronto a scrivere la tua immagine ISO sul tuo supporto. Questa procedura varia a seconda del sistema operativo in uso, del supporto e degli strumenti. Si presuppone che sappiate come scrivere l'immagine sul vostro supporto.
    
    ## 9: Avvio
    
    Anche in questo caso la procedura varia a seconda della macchina, del BIOS, del sistema operativo e così via.  È necessario assicurarsi che la macchina sia impostata per l'avvio da qualsiasi supporto (DVD o USB) come primo dispositivo di avvio. In caso di successo, dovrebbe apparire questa schermata:
    
    ![xfce_boot](images/xfce_boot.png)
    
    Se è così, siete sulla buona strada! Se si desidera testare il supporto, si può selezionare prima questa opzione, oppure si può semplicemente digitare **S** per **Avviare Rocky Linux XFCE 9.0**.
    
    Ricordate che si tratta di un'immagine live, quindi ci vorrà un po' di tempo per avviare la prima schermata. Non fatevi prendere dal panico, aspettate! Una volta avviata l'immagine live, si dovrebbe vedere questa schermata:
    
    ![xfce_install](images/xfce_install.png)
    
    ## 9: Installazione di XFCE
    
    A questo punto, si può usare l'ambiente XFCE e vedere se ci piace. Una volta deciso di utilizzarlo in modo permanente, fate doppio clic sull'opzione Install to Hard Drive.
    
    Si avvia così un processo di installazione abbastanza familiare per chi ha già installato Rocky Linux. La prima schermata sarà quella di selezione della lingua predefinita:
    
    ![xfce_language](images/xfce_language.png)
    
    La schermata successiva contiene una serie di elementi da verificare o modificare. Le opzioni sono numerate per riferimento:
    
    ![xfce_install2](images/xfce_install_2.png)

    1. **Tastiera** - Date un'occhiata a questa opzione e assicuratevi che corrisponda al layout della tastiera che utilizzate.
    2. **Ora & Data** - Assicurati che questo corrisponda al tuo fuso orario.
    3. **Destinazione di installazione** - È necessario fare clic su questa opzione, anche solo per accettare ciò che è già presente.
    4. **Rete e Nome host** - Verificare che sia presente ciò che si desidera. Finché la rete è abilitata, è sempre possibile modificare questo punto in seguito se è necessario.
    5. **Password di root** - Procedere con l'impostazione di una password di root. Ricordate di salvarla in un luogo sicuro (gestore di password), soprattutto se non la utilizzate spesso.
    6. **Creazione di un utente** - Crea sicuramente almeno un utente. Se si desidera che l'utente abbia diritti amministrativi, ricordarsi di impostare questa opzione al momento della creazione dell'utente.
    7. **Iniziare l'installazione** - Una volta impostate o verificate tutte le impostazioni, fare clic su questa opzione.

    Una volta eseguito il passo 7, il processo di installazione dovrebbe iniziare a installare i pacchetti, come nella schermata seguente:

    ![xfce_install3](images/xfce_install_3.png)

    Al termine dell'installazione sul disco rigido, verrà visualizzata la seguente schermata:

    ![xfce_install_final](images/xfce_install_final.png)

    Procedere e fare clic su **Fine dell'installazione**.

    Dopo aver fatto questo, si tornerà alla schermata dell'immagine live. Riavviare il computer e rimuovere il supporto di avvio utilizzato per l'installazione di XFCE.

    Si aprirà quindi una schermata di accesso con l'utente creato in precedenza. Inserite la vostra password e accederete al desktop XFCE:

    ![xfce_desktop](images/xfce_desktop.png)

=== "8"

    ## 8.6: Installare Rocky Linux Minimal
    
    !!! note "Nota"
    
        In questa sezione è necessario essere l'utente root o essere in grado di eseguire sudo per elevare i propri privilegi.
    
    Durante l'installazione di Rocky Linux, abbiamo utilizzato i seguenti pacchetti:

    * Minimal
    * Standard


    ## 8: Eseguire l'aggiornamento del sistema

    Per prima cosa, eseguire il comando di aggiornamento del server per consentire al sistema di ricostruire la cache del repository, in modo da riconoscere i pacchetti disponibili.

    ```
    dnf update
    ```


    ## 8.6: Abilitazione dei Repository

    Abbiamo bisogno del repository non ufficiale per XFCE nel repository EPEL, per funzionare sulle versioni Rocky 8.x.

    Abilitare questo repository inserendo:

    ```
    dnf install epel-release
    ```

    E rispondi 'Y' per installarlo.

    Sono necessari anche i repository Powertools e lightdm. Procedere con l'abilitazione di questi elementi:

    ```
    dnf config-manager --set-enabled powertools
    dnf copr enable stenstorp/lightdm
    ```

    !!! Warning "Attenzione"

        Il sistema di compilazione `copr` crea un repository che è noto per funzionare per l'installazione di `lightdm`, ma non è mantenuto dalla comunità Rocky Linux. Utilizzare a proprio rischio e pericolo!

    Anche in questo caso, verrà presentato un messaggio di avvertimento sul repository. Rispondete pure `Y` alla domanda.


    ## 8.6: Controllare gli ambienti e gli strumenti disponibili nel gruppo

    Ora che i repository sono abilitati, eseguire i seguenti comandi per verificare tutto.

    Per prima cosa, controllare l'elenco dei repository con:

    ```
    dnf repolist
    ```

    Dovresti ottenere il seguente risultato che mostra tutti i repository abilitati:

    ```bash
    appstream                                                        Rocky Linux 8 - AppStream
    baseos                                                           Rocky Linux 8 - BaseOS
    copr:copr.fedorainfracloud.org:stenstorp:lightdm                 Copr repo for lightdm owned by stenstorp
    epel                                                             Extra Packages for Enterprise Linux 8 - x86_64
    epel-modular                                                     Extra Packages for Enterprise Linux Modular 8 - x86_64
    extras                                                           Rocky Linux 8 - Extras
    powertools                                                       Rocky Linux 8 - PowerTools
    ```

    Eseguire quindi il seguente comando per verificare la presenza di XFCE:

    ```
    dnf grouplist
    ```

    Dovreste vedere "Xfce" in fondo all'elenco.

    Eseguire `dnf update` un'altra volta per assicurarsi che tutti i repository abilitati siano letti nel sistema.


    ## 8.6: Installazione dei Pacchetti

    Per installare XFCE, eseguire:

    ```
    dnf groupinstall "xfce"
    ```

    Installare anche lightdm:

    ```
    dnf install lightdm
    ```


    ## 8: Fasi conclusive

    Dobbiamo disabilitare `gdm`, che viene aggiunto e abilitato durante *dnf groupinstall "xfce"*:

    ```
    systemctl disable gdm
    ```

    Ora possiamo abilitare *lightdm*:

    ```
    systemctl enable lightdm
    ```

    Dobbiamo dire al sistema, dopo l'avvio, di usare solo l'interfaccia grafica, quindi dobbiamo impostare il sistema di destinazione predefinito sull'interfaccia GUI:

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
