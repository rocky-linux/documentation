---
title: Importazione di Rocky Linux in WSL o WSL2
author: Lukas Magauer
tested_with: 8.6, 9.0
tags:
  - wsl
  - wsl2
  - windows
  - interoperability
---

# Importare Rocky Linux in WSL

## Prerequisiti

La funzione Windows-Subsystem for Linux deve essere abilitata. Questo è possibile con una delle seguenti opzioni:

- Da pochissimo tempo è [disponibile una nuova versione di WSL nel Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R), che ha più funzioni
- Aprire un terminale amministrativo (PowerShell o Command-Prompt) e <br>eseguire `wsl --install` ([ rif.](https://docs.microsoft.com/en-us/windows/wsl/install))
- Andate nelle impostazioni grafiche di Windows e attivate la funzione opzionale `Windows-Subsystem for Linux`

Questa funzione dovrebbe essere disponibile su tutte le versioni di Windows 10 e 11 supportate.

## Passi

1. Ottenere il rootfs del contenitore. Questo è possibile in diversi modi:

    - **Preferito:** Scaricare l'immagine dal CDN:
        - 8: [Base x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-UBI.latest.x86_64.tar.xz),<br>[Base aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-UBI.latest.aarch64.tar.xz)
        - 9: [Base x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-UBI.latest.x86_64.tar.xz),<br>[Base aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-UBI.latest.aarch64.tar.xz)
    - Estrarre l'immagine da Docker Hub o da Quay.io ([ rif.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:9 > rocky-9-image.tar
        ```

2. (opzionale) È necessario estrarre il file .tar dal file .tar.xz se non si utilizza una delle ultime versioni di WSL
3. Creare la directory in cui il WSL memorizzerà i suoi file (per lo più da qualche parte nel profilo utente)
4. Infine, importare l'immagine in WSL ([ rif.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

    - WSL:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz>
        ```

    - WSL 2:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    In linea di massima WSL 2 dovrebbe essere più veloce di WSL, ma questo potrebbe variare da caso a caso.

!!! tip "Terminale Windows"

    Se avete installato Windows Terminal, il nome della nuova distro WSL apparirà come opzione nel menu a discesa, il che è molto utile per lanciarla in futuro. È quindi possibile personalizzarlo con colori, caratteri, ecc.

!!! tip "systemd"

    Microsoft ha finalmente deciso di portare systemd nella WSL. Questa funzione è presente nella nuova versione di WSL del Microsoft Store. È sufficiente aggiungere `systemd=true` alla sezione `boot` ini del file `/etc/wsl.conf`! ([rif.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))

!!! tip "Microsoft Store"

    Al momento non c'è alcuna immagine nel Microsoft Store, se volete contribuire a portarla lì unitevi alla conversazione nel canale Mattermost SIG/Containers! Ci sono stati [alcuni sforzi](https://github.com/rocky-linux/WSL-DistroLauncher) molto tempo fa, che possono essere ripresi.
