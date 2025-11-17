---
title: Importazione di Rocky Linux in WSL o WSL2
author: Lukas Magauer
tested_with: 8.10, 9.6, 10.0
tags:
  - wsl
  - wsl2
  - windows
  - interoperability
---

!!! note NOTA "Imagini per altre versioni"

    If you are looking for WSL instructions for another version of Rocky Linux, select the version you want from the top menu and then refer to the WSL instructions under "Interoperability."

## Prerequisiti

You must enable the Windows-Subsystem for Linux feature. Do this with one of these options:

- [Una versione più recente di WSL con funzioni aggiuntive è disponibile nel Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R). Utilizzare questa versione più recente ogni volta che è possibile.
- Aprire un terminale amministrativo (PowerShell o Command-Prompt) ed eseguite `wsl --install` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/install))
- Andate nelle impostazioni grafiche di Windows e attivate la funzione opzionale `Windows-Subsystem for Linux`.

Questa funzione dovrebbe essere disponibile su tutte le versioni di Windows 10 e 11 supportate.

!!! tip “Versione WSL”

    Assicurarsi che la propria versione di WSL sia aggiornata, poiché alcune funzionalità sono state introdotte solo nelle ultime versioni. Se non si è sicuri eseguire `wsl --update`.

## Passi

### Immagini WSL installabili (preferibile)

1. Scaricare l'immagine WSL dal CDN o da un altro mirror più vicino:

    - 10: [x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-WSL-Base.latest.x86_64.wsl) oppure [aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-WSL-Base.latest.aarch64.wsl)

2. Esistono diverse opzioni per installare un'immagine `.wsl`:

    - Facendo doppio clic sull'immagine, questa verrà installata con il nome predefinito dell'immagine.
    - Installare l'immagine tramite riga di comando:

        ```sh
        wsl --install --from-file <path-to/Rocky-10-WSL-Base.latest.x86_64.wsl> --name <machine-name>
        ```

### Immagini di contaner convenzionali

1. Ottenere il rootfs del container. Questo è possibile in diversi modi:

    - Scaricare l'immagine dal CDN:
        - 10: [Base x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-UBI.latest.aarch64.tar.xz)
    - Estrarre l'immagine da Docker Hub o da Quay.io ([ rif.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:10 > rocky-10-image.tar
        ```

2. (opzionale) È necessario estrarre il file .tar dal file .tar.xz se non si utilizza una delle ultime versioni di WSL
3. Creare la directory in cui il WSL memorizzerà i suoi file (per lo più da qualche parte nel profilo utente)
4. Infine, importare l'immagine in WSL ([ rif.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

    - WSL:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-10-image.tar.xz> --version 1
        ```

    - WSL 2:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-10-image.tar.xz> --version 2
        ```

!!! tip CURIOSITA' "WSL vs. WSL 2"

    In generale, WSL 2 dovrebbe essere più veloce di WSL, anche se questo può variare a seconda del caso d'uso.

!!! tip "Terminale di Windows"

    Se si è installato Windows Terminal, il nome della nuova distribuzione WSL apparirà come opzione nel menu a tendina, il che è molto utile per l'avvio in futuro. È quindi possibile personalizzarlo con colori, caratteri e altri elementi.

!!! tip "systemd"

    L'immagine WSL è abilitata per systemd da impostazione predefinita. Se si desidera utilizzare le immagini di container o crearne di personalizzate, si dovrà solo aggiungere `systemd=true` alla sezione `boot` nel file `/etc/wsl.conf`. ([ref.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))
