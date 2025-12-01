---
title: XFCE Desktop
author: Gerard Arthus, Steven Spencer, Emre Camalan
contributors: Steven Spencer, Antoine Le Morvan, K.Prasad, Ganna Zhyrnova
tested_with: 8.9, 9.5
tags:
  - xfce
  - desktop
---

# XFCE desktop environment

The XFCE desktop environment, created as a fork of the Common Desktop Environment (CDE), embodies the traditional Unix philosophy of modularity and re-usability. You can install XFCE on almost any version of Linux, including Rocky Linux.

It is also one of the most accessible desktop environments to combine with alternate window managers, such as Awesome or i3. This procedure, however, will get you up and running with Rocky Linux and a more typical XFCE installation.

## Prerequisites

- A workstation or notebook
- A desire to run XFCE as your desktop instead of the default GNOME desktop
- Per le procedure per la 9 minimal e la 8, la possibilità di utilizzare `sudo` per elevare i privilegi

\=== "9"

    ````
    ## 9: Introduzione
    
    Il team di sviluppo di Rocky Linux 9 ha semplificato l'installazione di XFCE e di altri ambienti desktop popolari includendo immagini live. Per chi non sapesse di cosa si tratta, un'immagine live è un'immagine avviabile che carica il sistema operativo senza installarlo. Una volta caricata, è possibile installarla sul disco rigido del computer e utilizzarla.
    
    ## 9: Ottienere, verificare e scrivere l'immagine live di XFCE
    
    Prima dell'installazione, il primo passo è scaricare l'immagine live e masterizzarla su un DVD o una chiavetta USB. Come detto in precedenza, l'immagine sarà avviabile, proprio come qualsiasi altro supporto di installazione per Linux. È possibile trovare l'ultima immagine XFCE nella sezione download per Rocky Linux 9 [immagini live](https://dl.rockylinux.org/pub/rocky/9.6/live/x86_64/). Si noti che questo particolare link presuppone che l'architettura del processore sia x86_64. 
    
    Al momento della stesura di questo articolo, è possibile utilizzare le architetture x86_64 o aarch64 per questa immagine live. Scaricare l'immagine live e i file di checksum. 
    
    Verificare l'immagine con il file CHECKSUM utilizzando il seguente comando 
    
    (nota: questo è solo un esempio! Assicurarsi che il nome dell'immagine e i file CHECKSUM corrispondano): 
    
    ```
    sha256sum -c CHECKSUM --ignore-missing Rocky-9-XFCE-x86_64-latest.iso.CHECKSUM
    ```
    
    Se tutto va bene, verrà visualizzato questo messaggio:
    
    ```
    Rocky-9-XFCE-x86_64-latest.iso: OK
    ```
    
    Se il checksum del file restituisce OK, ora site pronti per scrivere l'immagine ISO sul supporto. Questa procedura varia a seconda del sistema operativo, del supporto e degli strumenti utilizzati. Qui diamo per scontato che si sappia come scrivere l'immagine sul supporto.
    
    ## 9: Booting
    
    Anche in questo caso, le impostazioni variano a seconda del computer, del BIOS, del sistema operativo e così via. È necessario assicurarsi che il computer sia impostato per avviarsi dal supporto scelto (DVD o USB) come primo dispositivo di avvio. Se l'operazione è stata eseguita correttamente, verrà visualizzata questa schermata:
    
    ![xfce_boot](images/xfce_boot.png)
    
    Se sì, siete sulla buona strada! Se desiderate testare il supporto, potete selezionare prima tale opzione oppure digitare **S** per **avviare Rocky Linux XFCE 9.0**.
    
    Ricordarsi che questa è un'immagine live. Ci vorrà un po' di tempo prima che si avvii la prima schermata. Non preoccupatevi, aspettate! Quando l'immagine live si avvia, si vedrà questa schermata:
    
    
    ![xfce_install](images/xfce_install.png)
    
    ## 9: Installazione di XFCE
    
    A questo punto, è possibile utilizzare l'ambiente XFCE. Quando si decide di utilizzarlo in modo permanente, fare doppio clic sull'opzione Installa su disco rigido.
    
    Questo avvierà un processo di installazione piuttosto familiare per chi ha già installato Rocky Linux in precedenza. La prima schermata consentirà di selezionare la lingua predefinita:
    
    ![xfce_language](images/xfce_language.png)
    
    La schermata successiva conterrà alcune informazioni che si dovrà verificare o modificare. Le opzioni sono numerate per comodità:
    
    ![xfce_install2](images/xfce_install_2.png)
    
    1. **Keyboard** - Assicurarsi che corrisponda alla disposizione della tastiera che utilizzate.
    2. **Time & Date** - Assicurarsi che corrisponda al vostro fuso orario.
    3. **Installation Destination** - Dovrete cliccare su questa opzione, anche se solo per accettare ciò che è già presente.
    4. **Network & Host Name** - Verificare di avere ciò che desiderate qui. Se la rete è abilitata, potete sempre modificare questa impostazione in un secondo momento, se necessario.
    5. **Root Password** - Impostare una password root. Ricordatevi di salvarla in un luogo sicuro (password manager).
    6. **User Creation** - Creare almeno un utente. Se desiderate che l'utente disponga dei diritti amministrativi, impostate questa opzione durante la creazione dell'utente.
    7. **Begin Installation** - Una volta completato e verificato, cliccare su questa opzione.
    
    Quando eseguite il passaggio 7, il processo di installazione inizierà a installare i pacchetti, come mostrato in questa schermata:
    
    ![xfce_install3](images/xfce_install_3.png)
    
    Una volta completata l'installazione sul disco rigido, verrà visualizzata la seguente schermata:
    
    ![xfce_install_final](images/xfce_install_final.png)
    
    Fare clic su **Fine installazione**.
    
    Una volta fatto ciò, tornerete alla schermata dell'immagine live. Riavviate il computer e rimuovete il supporto di avvio utilizzato per l'installazione di XFCE.
    
    Successivamente verrà visualizzata una schermata di accesso con l'utente creato in precedenza. Inserite la password per accedere al desktop XFCE:
    
    ![xfce_desktop](images/xfce_desktop.png)
    ````

\=== "9-minimal"

    ````
    ## 9 minimal: Introduzione
    
    Se avete installato Rocky Linux 9.x e successivamente decidete di installare XFCE, questa procedura vi permetterà di farlo. Questa procedura presuppone l'installazione di `Rocky-9.4-x86_64-minimal.iso`.
    
    ### Aggiornare il sistema
    
    Per prima cosa, assicuratevi che il vostro sistema sia aggiornato:
    
    ```bash
    sudo dnf update -y && dnf upgrade -y
    ```
    
    
    ![9_min1](images/xfce_9_min_1.png)
    
    In secondo luogo, eseguite il comando seguente per installare il repo epel-release, che contiene tutti i pacchetti da installare per il Desktop Xfce.
    
    ```bash
    sudo dnf install epel-release -y
    ```
    
    
    ![9_min2](images/xfce_9_min_2.png)
    
    ### Installare il desktop XFCE
    
    Installare XFCE con questo comando:
    
    ```bash
    sudo dnf groupinstall xfce -y
    ```
    
    
    ![9_min3](images/xfce_9_min_3.png)
    
    ### Avvio del desktop XFCE
    
    È possibile avviare il desktop XFCE dalla riga di comando se viene visualizzato il messaggio "Complete!" nell'output del comando e se non ci sono errori.
    
    ```bash
    sudo systemctl isolate graphical.target
    ```
    
    
    ### Abilitare il desktop XFCE all'avvio
    
    A questo punto avete installato il desktop XFCE sul sistema e vi siete assicurati che funzioni eseguendolo dalla riga di comando. Se si desidera che il sistema si avvii sempre con XFCE invece che con la riga di comando, è necessario eseguire il seguente comando. È necessario aprire prima il terminale XFCE dall'icona dei 9 punti:
    
    ```bash
    sudo systemctl set-default graphical.target
    ```
    
    
    ![9_min5](images/xfce_9_min_5.png)
    
    **NOTA:** È possibile accedere con il nome utente e la password di root.
    
    ![9_min6](images/xfce_9_min_6.png)
    
    Ora è possibile testarlo. Riavviare il sistema con il comando `sudo reboot`. Il sistema si aprirà con la schermata di accesso al desktop XFCE.
    
    ![9_min7](images/xfce_9_min_7.png)
    ````

\=== "8"

    ````
    ## 8: Installare Rocky Linux minimale
    
    !!! note "Nota"
    
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
    ````

## Conclusion

XFCE is a light environment with a simplistic interface. It is an alternative to the default GNOME desktop on Rocky Linux. Se si utilizza Rocky Linux 9, gli sviluppatori hanno creato una pratica immagine live che velocizza il processo di installazione.
