---
title: Importer Rocky Linux 10 vers WSL ou bien WSL2
author: Lukas Magauer
tested_with: 8.10, 9.6, 10.0
tags:
  - wsl
  - wsl2
  - windows
  - interopérabilité
---

!!! note "Images pour d'autres versions"

    Si vous recherchez des instructions WSL pour une autre version de Rocky Linux, sélectionnez la version souhaitée dans le menu du haut, puis reportez-vous aux instructions WSL sous « Interopérabilité ».

## Prérequis

Vous devez activer la fonctionnalité Sous-système Windows pour Linux. Ceci est possible avec l'une des options suivantes :

- [A newer WSL version with extra features is available in the Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R). Utilisez la nouvelle version tant que possible.
- Open an administrative Terminal (either PowerShell or Command-Prompt) and
  run `wsl --install` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/install))
- Go to the graphical Windows Settings and enable the optional feature `Windows-Subsystem for Linux`

Cette fonctionnalité devrait être disponible sur toutes les versions actuellement prises en charge de Windows 10 et 11.

!!! tip "Version de WSL"

    Assurez-vous que votre version de WSL est à jour, car certaines fonctionnalités n'ont été introduites que dans les versions ultérieures. En cas de doute, exécutez `wsl --update`.

## Marche à suivre

### Images WSL installables (de préférence)

1. Téléchargez l'image WSL à partir du CDN ou d'un autre miroir à proximité :

   - 9: [x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-WSL-Base.latest.x86_64.wsl) or [aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-WSL-Base.latest.aarch64.wsl)

2. Il existe plusieurs options pour installer une image <code>.wsl</code> :

   - Un double-clic sur l'image l'installera avec le nom d'image par défaut
   - Installez l'image à l'aide de la ligne de commande :

        ```sh
        wsl --install --from-file <path-to/Rocky-9-WSL-Base.latest.x86_64.wsl> --name <machine-name>
        ```

### Images de conteneurs classiques

1. Récupérez `rootfs` du conteneur. Cela est possible de plusieurs manières :

   - Téléchargez l'image depuis le CDN :
     - 9: [Base x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-UBI.latest.aarch64.tar.xz)
   - Extract the image from either Docker Hub or Quay.io ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:9 > rocky-9-image.tar
        ```

2. (facultatif) Vous devrez extraire le fichier `.tar` du fichier `.tar.xz` si vous utilisez l'une des dernières versions de WSL

3. Créez le répertoire dans lequel le WSL stockera ses fichiers (normalement quelque part dans le profil utilisateur)

4. Finally, import the image into WSL ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

   - WSL :

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz> --version 1
        ```

   - WSL 2 :

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    En général, WSL 2 devrait être plus rapide que WSL, bien que cela puisse varier selon le cas d'utilisation.

!!! tip "Windows Terminal"

    If you have Windows Terminal installed, the new WSL distro name will appear as an option on the pull-down menu, which is quite handy for launching in the future. You can then customize it with colors, fonts, and other elements.

!!! tip "systemd"

    The WSL image is systemd-enabled by default. If you want to use the container images or build your own, you will only need to add `systemd=true` to the `boot` section in the `/etc/wsl.conf` file. ([ref.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))
