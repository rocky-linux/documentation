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

!!! note "Images for other versions"

    If you are looking for WSL instructions for another version of Rocky Linux, select the version you want from the top menu and then refer to the WSL instructions under "Interoperability."

## Prerequisiti

You must enable the Windows-Subsystem for Linux feature. Do this with one of these options:

- [A newer WSL version with extra features is available in the Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R). Utilizzare questa versione più recente ogni volta che è possibile.
- Open an administrative Terminal (either PowerShell or Command-Prompt) and
  run `wsl --install` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/install))
- Go to the graphical Windows Settings and enable the optional feature `Windows-Subsystem for Linux`

Questa funzione dovrebbe essere disponibile su tutte le versioni di Windows 10 e 11 supportate.

!!! tip "WSL version"

    Assicurasi che la versione di WSL sia aggiornata, poiché alcune funzionalità sono state introdotte solo nelle ultime versioni. Se non si è sicuri, eseguire `wsl --update`.

## Passi

### Immagini WSL installabili (preferibile)

1. Scaricare l'immagine WSL dal CDN o da un altro mirror più vicino:

   - 9: [x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-WSL-Base.latest.x86_64.wsl) oppure [aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-WSL-Base.latest.aarch64.wsl)

2. Esistono diverse opzioni per l'installazione di un'immagine `.wsl`:

   - Doppio clic sull'immagine per installarla con il nome predefinito dell'immagine.
   - Installare l'immagine tramite riga di comando:

        ```sh
        wsl --install --from-file <path-to/Rocky-9-WSL-Base.latest.x86_64.wsl> --name <machine-name>
        ```

### Immagini container convenzionali

1. Ottenere il rootfs del container. Questo è possibile in diversi modi:

   - Scaricare l'immagine dal CDN:
     - 9: [Base x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-UBI.latest.x86_64.tar.xz),<br>[Base aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-UBI.latest.aarch64.tar.xz)
   - Extract the image from either Docker Hub or Quay.io ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:10 > rocky-10-image.tar
        ```

2. (optional) You will have to extract the .tar file from the `.tar.xz` file if you are using one of the latest WSL versions

3. Creare la directory in cui il WSL memorizzerà i suoi file (per lo più da qualche parte nel profilo utente)

4. Finally, import the image into WSL ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

   - WSL:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz> --version 1
        ```

   - WSL 2:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    In generale, WSL 2 dovrebbe essere più veloce di WSL, anche se questo può variare a seconda del caso d'uso.

!!! tip "Windows Terminal"

    If you have Windows Terminal installed, the new WSL distro name will appear as an option on the pull-down menu, which is quite handy for launching in the future. You can then customize it with colors, fonts, and other elements.

!!! tip "systemd"

    The WSL image is systemd-enabled by default. If you want to use the container images or build your own, you will only need to add `systemd=true` to the `boot` section in the `/etc/wsl.conf` file. ([ref.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))
