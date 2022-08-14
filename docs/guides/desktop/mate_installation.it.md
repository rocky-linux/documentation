---
title: Desktop MATE
author: lillolollo
contributors: Steven Spencer, Franco Colussi
tested with: 8.5
tags:
  - mate
  - desktop
---

# Ambiente desktop MATE

L'ambiente desktop MATE è stato creato come fork e continuazione di GNOME2, sulla scia dell'accoglienza negativa ricevuta da GNOME3 al momento della sua introduzione. MATE ha un gruppo fedele di utenti che lo installano da subito sul loro sistema operativo preferito. MATE può essere installato su molte versioni di Linux, tra cui Rocky Linux.

Questa procedura è stata ideata per farvi iniziare a lavorare con Rocky Linux 8 utilizzando MATE.

## Prerequisiti

* Un computer con schermo e tutto il resto, preferibilmente con Rocky Linux già installato.

## Installare Rocky Linux Minimal

Durante l'installazione di Rocky Linux, abbiamo utilizzato i seguenti pacchetti:

* Minimal
* Standard

## Abilitazione dei repository

Sono necessari anche i repository Powertools e EPEL. Procedere con l'abilitazione di questi elementi:

`sudo dnf config-manager --set-enabled powertools`

`sudo dnf install epel-release`

E rispondere "Y" per installare l'EPEL.

Eseguire `dnf update` per assicurarsi che tutti i repository abilitati siano letti dal sistema.

## Installazione dei pacchetti

La prossima cosa di cui abbiamo bisogno sono un sacco di pacchetti. È possibile installarli semplicemente copiando e incollando quanto segue nella riga di comando del computer:

`sudo dnf install NetworkManager-adsl NetworkManager-bluetooth NetworkManager-libreswan-gnome NetworkManager-openvpn-gnome NetworkManager-ovs NetworkManager-ppp NetworkManager-team NetworkManager-wifi NetworkManager-wwan abrt-desktop abrt-java-connector adwaita-gtk2-theme alsa-plugins-pulseaudio atril atril-caja atril-thumbnailer caja caja-actions caja-image-converter caja-open-terminal caja-sendto caja-wallpaper caja-xattr-tags dconf-editor engrampa eom firewall-config gnome-disk-utility gnome-epub-thumbnailer gstreamer1-plugins-ugly-free gtk2-engines gucharmap gvfs-afc gvfs-afp gvfs-archive gvfs-fuse gvfs-gphoto2 gvfs-mtp gvfs-smb initial-setup-gui libmatekbd libmatemixer libmateweather libsecret lm_sensors marco mate-applets mate-backgrounds mate-calc mate-control-center mate-desktop mate-dictionary mate-disk-usage-analyzer mate-icon-theme mate-media mate-menus mate-menus-preferences-category-menu mate-notification-daemon mate-panel mate-polkit mate-power-manager mate-screensaver mate-screenshot mate-search-tool mate-session-manager mate-settings-daemon mate-system-log mate-system-monitor mate-terminal mate-themes mate-user-admin mate-user-guide mozo network-manager-applet nm-connection-editor p7zip p7zip-plugins pluma seahorse seahorse-caja xdg-user-dirs-gtk`

Questo installerà i pacchetti necessari e tutte le dipendenze.

Procediamo con l'installazione di lightdm-settings e lightdm:

`sudo dnf install lightdm-settings lightdm`

## Fasi finali

Ora che abbiamo installato tutto ciò che ci serve, la prossima cosa da fare è impostare l'installazione minima in modo che si avvii nell'interfaccia grafica utente (GUI). Possiamo farlo inserendo:

`sudo systemctl set-default graphical.target`

Ora basta incrociare le dita e riavviare:

`sudo reboot`

Successivamente, cliccate sul vostro nome utente sullo schermo, ma prima di inserire la password e di effettuare il login, cliccate sull'icona dell'ingranaggio a sinistra dell'opzione "Accedi". Selezionare "MATE" tra le opzioni disponibili per il desktop, quindi inserire la password e accedere. I futuri accessi ricorderanno la selezione effettuata.

## Conclusione

Alcune persone non sono soddisfatte delle nuove implementazioni di GNOME o semplicemente preferiscono l'aspetto di MATE GNOME 2. Per queste persone, l'installazione di MATE in Rocky Linux fornirà un'alternativa piacevole e stabile.
