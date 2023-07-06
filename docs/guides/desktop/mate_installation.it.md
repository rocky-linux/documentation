---
title: Desktop MATE
author: lillolollo
contributors: Steven Spencer, Serge, Franco Colussi
tested_with: 8.5, 8.6, 9.0
tags:
  - mate
  - desktop
---

# Ambiente desktop MATE

L'ambiente desktop MATE è stato creato come fork e continuazione di GNOME2, sulla scia dell'accoglienza negativa ricevuta da GNOME3 al momento della sua introduzione. MATE ha un gruppo fedele di utenti che lo installano da subito sul loro sistema operativo preferito. MATE può essere installato su molte versioni di Linux, tra cui Rocky Linux.

Questa procedura è stata ideata per farvi iniziare a lavorare con Rocky Linux utilizzando MATE.

## Prerequisiti

* Un computer (portatile o workstation) con schermo e tutto il resto.
* Il desiderio di eseguire il desktop MATE invece di quello predefinito di GNOME.

=== "9"

    ## 9: Introduzione 
    
    Il team di sviluppo di Rocky Linux 9 ha reso semplice l'installazione di MATE e di altri ambienti desktop popolari, includendo immagini live. Un'immagine live, per chi non lo sapesse, è un'immagine avviabile che carica il sistema operativo senza installazione. Una volta caricato, è possibile installarlo nell'unità disco del computer e utilizzarlo. Oltre alle istruzioni per l'immagine live, abbiamo incluso le istruzioni per l'installazione per coloro che vogliono installare MATE dopo che il sistema operativo è già stato installato.
    
    ## 9: MATE dall'immagine live
    
    ### 9: Ottenere, verificare e scrivere l'immagine live di MATE
    
    Prima dell'installazione, il primo passo è scaricare l'immagine live e scriverla su un DVD o una chiavetta USB. Come detto in precedenza, l'immagine sarà avviabile, proprio come qualsiasi altro supporto di installazione per Linux. È possibile trovare l'ultima immagine MATE nella sezione download di Rocky Linux 9 [immagini live](https://dl.rockylinux.org/pub/rocky/9.2/live/x86_64/). Si noti che questo particolare link presuppone che l'architettura sia x86_64 e, al momento in cui scriviamo, questa è l'unica architettura per cui è disponibile questa particolare immagine live. Scaricare sia l'immagine live che i file di checksum. 
    
    Ora verificare l'immagine con il file CHECKSUM utilizzando il seguente metodo
    (si noti che questo è un esempio! Assicurarsi che il nome dell'immagine e i file CHECKSUM corrispondano):

    ```
    sha256sum -c CHECKSUM --ignore-missing Rocky-9.1-MATE-x86_64-20221124.0.iso.CHECKSUM
    ```


    Se tutto va bene, dovreste ricevere questo messaggio:

    ```
    Rocky-9.1-MATE-x86_64-20221124.0.iso: OK
    ```


    Se il checksum per il file restituisce OK, ora sei pronto a scrivere la tua immagine ISO sul tuo supporto. Questa procedura varia a seconda del sistema operativo in uso, del supporto e degli strumenti. Si presuppone che sappiate come scrivere l'immagine sul vostro supporto.
    
    ### 9: Avvio
    
    Anche in questo caso la procedura varia a seconda della macchina, del BIOS, del sistema operativo e così via.  È necessario assicurarsi che la macchina sia impostata per l'avvio da qualsiasi supporto (DVD o USB) come primo dispositivo di avvio. In caso di successo, dovrebbe essere visualizzata questa schermata
    
    ![mate_boot](images/mate_boot.png)
    
    Se è così, siete sulla buona strada! Se si desidera testare il supporto, si può selezionare prima questa opzione, oppure si può semplicemente digitare **S** per **Avviare Rocky Linux Mate 9.0**.
    
    Ricordate che si tratta di un'immagine live, quindi ci vorrà un po' di tempo per avviare la prima schermata. Non fatevi prendere dal panico, aspettate! Una volta avviata l'immagine live, si dovrebbe vedere questa schermata:
    
    ![mate-live](images/mate_live.png)
    
    ### 9: Installazione di MATE
    
    A questo punto, si può usare l'ambiente MATE e vedere se ci piace. Una volta deciso di utilizzarlo in modo permanente, fare doppio clic sull'opzione **Installa sul disco rigido**.
    
    Si avvia così un processo di installazione abbastanza familiare per chi ha già installato Rocky Linux. Nella schermata seguente, abbiamo evidenziato le cose che *potreste* voler modificare.
    
    ![mate_install](images/mate_install.png)

    1. **Tastiera** - Date un'occhiata a questa opzione e assicuratevi che corrisponda al layout della tastiera che utilizzate.
    2. **Ora e data** - Assicurarsi che corrisponda al proprio fuso orario.
    3. **Destinazione di installazione** - È necessario fare clic su questa opzione, anche solo per accettare ciò che è già presente.
    4. **Rete e Nome host** - Verificare che sia presente ciò che si desidera. Finché la rete è abilitata, è sempre possibile modificare questo punto in seguito se è necessario.
    5. **Password di root** - Procedere con l'impostazione di una password di root. Ricordate di salvarla in un luogo sicuro (gestore di password), soprattutto se non la utilizzate spesso.
    6. **Creazione di un utente** - Crea sicuramente almeno un utente. Se si desidera che l'utente abbia diritti amministrativi, ricordarsi di impostare questa opzione al momento della creazione dell'utente.
    7. **Iniziare l'installazione** - Una volta impostate o verificate tutte le impostazioni, fare clic su questa opzione.

    Una volta eseguito il passo 7, il processo di installazione dovrebbe iniziare a installare i pacchetti, come nella schermata seguente:

    ![mate_install_2](images/mate_install_2.png)

    Al termine dell'installazione sul disco rigido, verrà visualizzata la seguente schermata:

    ![mate_install_final](images/mate_install_final.png)

    Procedere e fare clic su **Fine dell'installazione**.

    A questo punto è necessario riavviare il sistema operativo e rimuovere il supporto di avvio. Quando il sistema operativo viene avviato per la prima volta, viene visualizzata la schermata del contratto di licenza:

    ![eula](images/eula.png)

    Fare clic sulla casella di controllo **Accetto il contratto di licenza** e quindi su **Fine**. In questo modo si arriva alla schermata finale dell'installazione. In questa schermata, fare clic su **Fine della configurazione**.

    ![mate_finish](images/mate_finish.png)

    Si aprirà quindi una schermata di accesso con l'utente creato in precedenza. Inserite la vostra password e accederete al desktop MATE:

    ![mate_desktop](images/mate_desktop.png)


    ## 9: MATE dopo l'installazione del sistema operativo

    MATE può essere installato anche dopo l'installazione del sistema operativo. Questo procedimento richiede qualche passo in più, ma non è difficile. Basta seguire queste istruzioni.


    ### 9: Abilitare i Repository

    Hai bisogno del repository CRB e del repository EPEL. Procedere con l'abilitazione di questi elementi:

    ```
    sudo dnf config-manager --set-enabled crb
    sudo dnf install epel-release
    ```

    Eseguire `dnf upgrade` per assicurarsi che tutti i repository abilitati siano letti nel sistema.


    ### 9: Installazione dei Pacchetti

    La prossima cosa di cui abbiamo bisogno sono un sacco di pacchetti. È possibile installarli semplicemente copiando e incollando quanto segue nella riga di comando del computer:

    ```
    sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk
    ```

    Questo installerà i pacchetti necessari e tutte le dipendenze.

    Procediamo con l'installazione di lightdm-settings e lightdm:

    ```
    sudo dnf install lightdm-settings lightdm
    ```


    ### 9: Passi Finali

    Se il sistema aveva installato Gnome o un altro desktop prima dell'installazione di MATE, a questo punto si dovrebbe essere pronti a riavviare. Se non è stato installato alcun desktop, è necessario usare il seguente comando per impostare il target grafico:

    ```
    sudo systemctl set-default graphical.target
    ```

    Quindi riavviare

    ```
    sudo reboot
    ```

    Al riavvio del sistema, fare clic sul proprio nome utente, ma prima di inserire la password, fare clic sull'icona dell'ingranaggio in basso a destra e selezionare MATE dall'elenco dei desktop. Quindi effettuare il login e si dovrebbe avere un desktop MATE completamente funzionante. I futuri accessi dovrebbero ricordare la selezione effettuata.

=== "8"

    ## 8: Installare Rocky Linux Minimal
    
    Per l'installazione di Rocky Linux abbiamo utilizzato i seguenti pacchetti:

    * Minimal
    * Standard


    ## 8: Abilitazione dei Repository

    È necessario disporre del repository Powertools e del repository EPEL. Procedere con l'abilitazione di questi elementi:

    ```
    sudo dnf config-manager --set-enabled powertools
    sudo dnf install epel-release
    ```

    E rispondere 'Y' per installare il repository EPEL.

    Eseguire `dnf update` per assicurarsi che tutti i repository abilitati siano letti dal sistema.


    ## 8: Installazione dei Pacchetti

    La prossima cosa di cui abbiamo bisogno sono un sacco di pacchetti. È possibile installarli semplicemente copiando e incollando quanto segue nella riga di comando del computer:

    ```
    sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan abrt-desktop abrt-java-connector adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk
    ```

    Questo installerà i pacchetti necessari e tutte le dipendenze.

    Procediamo con l'installazione di lightdm-settings e lightdm:

    ```
    sudo dnf install lightdm-settings lightdm
    ```


    ## 8: Final Steps

    Ora che abbiamo installato tutto ciò che ci serve, la prossima cosa da fare è impostare l'installazione minima in modo che si avvii nell'interfaccia grafica utente (GUI). Possiamo farlo inserendo:

    ```
    sudo systemctl set-default graphical.target
    ```

    Ora basta incrociare le dita e riavviare:

    ```
    sudo reboot
    ```

    Successivamente, cliccate sul vostro nome utente sullo schermo, ma prima di inserire la password e di effettuare il login, cliccate sull'icona dell'ingranaggio a sinistra dell'opzione "Accedi". Selezionare "MATE" tra le opzioni disponibili per il desktop, quindi inserire la password e accedere. I futuri accessi ricorderanno la selezione effettuata.

## Conclusione

Alcune persone non sono soddisfatte delle nuove implementazioni di GNOME o semplicemente preferiscono l'aspetto di MATE GNOME 2. Per queste persone, l'installazione di MATE in Rocky Linux fornirà un'alternativa piacevole e stabile. Per Rocky Linux 9.0, gli sviluppatori hanno reso l'intero processo molto semplice grazie all'immagine live disponibile.
