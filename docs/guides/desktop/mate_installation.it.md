---
title: Desktop MATE
author: lillolollo
contributors: Steven Spencer, Ganna Zhyrnova
tested_with: 8.5, 8.6, 9.0
tags:
  - mate
  - desktop
---

# Ambiente desktop MATE

Creato come fork e continuazione di GNOME2 sulla scia dell'accoglienza piuttosto negativa di GNOME3, è nato l'ambiente desktop MATE. MATE ha dei fedeli utilizzatori, che di solito lo installano immediatamente sul loro sistema operativo preferito. L'installazione di MATE è possibile su molte versioni di Linux, tra cui Rocky Linux.

Questa procedura vi permetterà di utilizzare MATE su Rocky Linux.

## Prerequisiti

* Un computer (portatile o workstation) con schermo e tutto il resto.
* Il desiderio di eseguire il desktop MATE invece di quello predefinito di GNOME.

=== "9"

    ## 9: Introduzione 
    
    Il team di sviluppo di Rocky Linux 9 ha reso semplice l'installazione di MATE e di altri ambienti desktop popolari, includendo immagini live. Per chi non lo sapesse, un'immagine live è un'immagine avviabile che carica il sistema operativo senza installazione. Una volta caricato, è possibile installarlo nell'unità disco del computer e utilizzarlo. Oltre alle istruzioni per l'immagine live, abbiamo incluso le istruzioni per coloro che vogliono installare MATE dopo l'installazione del sistema operativo.
    
    ## 9: MATE dall'immagine live
    
    ### 9: Ottenere, verificare e scrivere l'immagine live di MATE
    
    Prima dell'installazione, il primo passo è scaricare l'immagine live e scriverla su un DVD o una chiavetta USB. Come detto in precedenza, l'immagine sarà avviabile, proprio come qualsiasi altro supporto di installazione per Linux. È possibile trovare l'ultima immagine MATE nella sezione download di Rocky Linux 9 [immagini live](https://dl.rockylinux.org/pub/rocky/9.4/live/x86_64/). Si noti che questo particolare collegamento presuppone che l'architettura sia x86_64 e, al momento in cui scriviamo, questa è l'unica immagine live disponibile. Scaricare sia l'immagine live che i file di checksum. 
    
    Verificare l'immagine con il file CHECKSUM nel modo seguente 
    (si noti che questo è un esempio! Assicurarsi che il nome dell'immagine e i file CHECKSUM corrispondano):

    ```
    sha256sum -c CHECKSUM --ignore-missing Rocky-9.4-MATE-x86_64-20221124.0.iso.CHECKSUM
    ```


    Se tutto va bene, riceverete questo messaggio:

    ```
    Rocky-9.4-MATE-x86_64-20221124.0.iso: OK
    ```


    Se il checksum per il file restituisce OK, ora sei pronto a scrivere la tua immagine ISO sul tuo supporto. Questa procedura varia a seconda del sistema operativo in uso, del supporto e degli strumenti. Si presuppone che sappiate come scrivere l'immagine sul vostro supporto.
    
    ### 9: Avvio
    
    Anche in questo caso la procedura è diversa a seconda della macchina, del BIOS, del sistema operativo e così via. È necessario assicurarsi che la macchina sia impostata per l'avvio su qualsiasi supporto (DVD o USB) come primo dispositivo di avvio. Se l'operazione è riuscita, verrà visualizzata questa schermata: 
    
    ![mate_boot](images/mate_boot.png)
    
    Se è così, siete sulla buona strada! Se si desidera testare il supporto, selezionare prima questa opzione, oppure immettere **S** per **Avviare Rocky Linux Mate 9.0**.
    
    Ricordate che si tratta di un'immagine dal vivo. L'avvio della prima schermata richiederà un po' di tempo. Non fatevi prendere dal panico, aspettate! Quando l'immagine live si avvia, viene visualizzata questa schermata:
    
    ![mate-live](images/mate_live.png)
    
    ### 9: Installazione di MATE
    
    A questo punto, si può usare l'ambiente MATE e vedere se ci piace. Una volta deciso di utilizzarlo in modo permanente, fare doppio clic sull'opzione **Install to Hard Drive**.
    
    Si avvia così un processo di installazione abbastanza familiare per chi ha già installato Rocky Linux. Nella schermata seguente sono evidenziate le cose che *potreste* voler modificare.
    
    ![mate_install](images/mate_install.png)

    1. **Tastiera** Assicuratevi che corrisponda al layout della tastiera che utilizzate.
    2. **Ora e data** - Assicurarsi che corrisponda al proprio fuso orario.
    3. **Destinazione di installazione** - È necessario fare clic su questa opzione, anche solo per accettare ciò che è già presente.
    4. **Rete e Nome host** - Verificare che sia presente ciò che si desidera. Se la rete è abilitata, è sempre possibile modificarla in seguito, se necessario.
    5. **Password di root** - Impostare una password di root. Ricordate di salvarlo in un luogo sicuro (gestore di password).
    6. **Creazione di un utente** - Creare almeno un utente. Se si desidera che l'utente abbia diritti amministrativi, impostare questa opzione al momento della creazione dell'utente.
    7. **Iniziare l'installazione** - Quando tutte le impostazioni sono state impostate o verificate, fare clic su questa opzione.

    Una volta eseguito il passo 7, il processo di installazione inizierà a installare i pacchetti, come in questa schermata:

    ![mate_install_2](images/mate_install_2.png)

    Al termine dell'installazione sul disco rigido, verrà visualizzata la seguente schermata:

    ![mate_install_final](images/mate_install_final.png)

    Cliccare su **Termina installazione**.

    A questo punto il sistema operativo si riavvia. Rimuovere il supporto di avvio e quando il sistema operativo viene avviato per la prima volta, viene visualizzata una schermata con il contratto di licenza:

    ![eula](images/eula.png)

    Cliccare sulla casella di controllo **Accetto il contratto di licenza** e fare clic su **Fatto**. In questo modo si arriva alla schermata finale dell'installazione. In questa schermata, fare clic su **Fine della configurazione**.

    ![mate_finish](images/mate_finish.png)

    Si aprirà quindi una schermata di accesso con l'utente creato. Immettere la password per accedere al desktop MATE:

    ![mate_desktop](images/mate_desktop.png)


    ## 9: MATE dopo l'installazione del sistema operativo

    È anche possibile installare MATE dopo l'installazione del sistema operativo. Questo procedimento richiede qualche passo in più, ma non è difficile. Basta seguire queste istruzioni.


    ### 9: Abilitare i Repository

    Hai bisogno del repository CRB e del repository EPEL. Abilitateli subito:

    ```
    sudo dnf config-manager --set-enabled crb
    sudo dnf install epel-release
    ```

    Eseguire `dnf upgrade` per assicurarsi che tutti i repository abilitati vengano letti dal sistema.


    ### 9: Installazione dei Pacchetti

    La prossima cosa di cui abbiamo bisogno sono un sacco di pacchetti. È possibile installarli copiando e incollando quanto segue nella riga di comando del computer:

    ```
    sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk
    ```

    Questo installerà i pacchetti necessari e tutte le dipendenze.

    Procediamo con l'installazione di lightdm-settings e lightdm:

    ```
    sudo dnf install lightdm-settings lightdm
    ```


    ### 9: Passi Finali

    Se il sistema aveva installato Gnome o un altro desktop prima dell'installazione di MATE, a questo punto dovrebbe essere pronto per il riavvio. Se non esiste un'installazione desktop, è necessario utilizzare il seguente comando per impostare il target grafico:

    ```
    sudo systemctl set-default graphical.target
    ```

    Quindi riavviare

    ```
    sudo reboot
    ```

    Al riavvio del sistema, fare clic sul proprio nome utente, ma prima di inserire la password, fare clic sull'icona dell'ingranaggio in basso a destra e selezionare MATE dall'elenco dei desktop. Effettuate il login e dovreste avere un desktop MATE completamente funzionante. I futuri accessi dovrebbero ricordare la selezione effettuata.

=== "8"

    ## 8: Installare Rocky Linux Minimal
    
    Per l'installazione di Rocky Linux abbiamo utilizzato i seguenti pacchetti:

    * Minimal
    * Standard


    ## 8: Abilitazione dei Repository

    È necessario disporre del repository Powertools e del repository EPEL. Abilitateli subito:

    ```
    sudo dnf config-manager --set-enabled powertools
    sudo dnf install epel-release
    ```

    E rispondere 'Y' per installare il repository EPEL.

    Eseguire `dnf update` per assicurarsi che tutti i repository abilitati siano letti dal sistema.


    ## 8: Installazione dei Pacchetti

    La prossima cosa di cui avete bisogno sono numerosi pacchetti. È possibile installarli copiando e incollando quanto segue nella riga di comando del computer:

    ```
    sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan abrt-desktop abrt-java-connector adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk
    ```

    Questo installerà i pacchetti necessari e tutte le dipendenze.

    Installare anche lightdm-settings e lightdm:

    ```
    sudo dnf install lightdm-settings lightdm
    ```


    ## 8: Final Steps

    Ora che è stato installato tutto il necessario, è necessario impostare l'installazione minima per l'avvio dell'interfaccia grafica utente (GUI). Possiamo farlo inserendo:

    ```
    sudo systemctl set-default graphical.target
    ```

    Ora basta incrociare le dita e riavviare:

    ```
    sudo reboot
    ```

    Successivamente, cliccate sul vostro nome utente sullo schermo, ma prima di inserire la password e di effettuare il login, cliccate sull'icona dell'ingranaggio a sinistra dell'opzione "Accedi". Selezionare "MATE" tra le opzioni disponibili per il desktop, quindi inserire la password ed effettuare il login. I futuri accessi ricorderanno la selezione effettuata.

## Conclusione

Alcune persone non sono soddisfatte delle nuove implementazioni di GNOME o semplicemente preferiscono il vecchio aspetto di MATE GNOME 2. L'installazione di MATE in Rocky Linux fornirà un'alternativa stabile e gradevole. Per Rocky Linux 9.0, gli sviluppatori hanno reso l'intero processo molto semplice grazie all'immagine live disponibile.
