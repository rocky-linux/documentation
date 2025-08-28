---
title: Importer Rocky Linux vers WSL ou WSL2
author: Lukas Magauer
tested_with: 8.10, 9.6, 10.0
tags:
  - wsl
  - wsl2
  - windows
  - interopérabilité
---

# Importer Rocky Linux vers WSL

## Prérequis

La fonctionnalité `Windows-Subsystem for Linux` doit être activée. Ceci est possible avec l'une de ces options :

- [Une version WSL plus récente avec des fonctionnalités supplémentaires est disponible dans Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R). Utilisez la nouvelle version tant que possible.
- Ouvrez un terminal d'administration (PowerShell ou invite de commande) et exécutez la commande suivante :<br/>`wsl --install` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/install))
- Accédez aux paramètres graphiques de Windows et activez la fonctionnalité facultative `Windows-Subsystem for Linux`

Cette fonctionnalité devrait être disponible sur toutes les versions actuellement prises en charge de Windows 10 et 11.

!!! tip "Version WSL"

    Assurez-vous que votre version WSL est à jour, car certaines fonctionnalités ont seulement été introduites dans les versions récentes. If you are unsure, run `wsl --update`.

## Marche à suivre

### Images WSL installables (de préférence)

1. Téléchargez l'image WSL à partir du CDN ou d'un autre miroir à proximité :

    - </a>9 : [x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-WSL-Base.latest.x86_64.wsl) ou [aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-WSL-Base.latest.aarch64.wsl)
    - 10 : [x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-WSL-Base.latest.x86_64.wsl) ou [aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-WSL-Base.latest.aarch64.wsl)

2. Il existe plusieurs options pour installer une image `.wsl` :

    - Un double-clic sur l'image l'installera avec le nom d'image par défaut
    - Installez l'image à l'aide de la ligne de commande :

        ```sh
        wsl --install --from-file <path-to/Rocky-10-WSL-Base.latest.x86_64.wsl> --name <machine-name>
        ```

### Images de conteneurs classiques

1. Récupérez `rootfs` du conteneur. Cela est possible de plusieurs manières :

    - Téléchargez l'image depuis le CDN :
        - 8: [Base x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-UBI.latest.aarch64.tar.xz)
        - 9: [Base x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-UBI.latest.aarch64.tar.xz)
        - 10: [Base x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-UBI.latest.aarch64.tar.xz)
    - Extraction de l'image à partir de `Docker Hub` ou de `Quay.io` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:10 > rocky-10-image.tar
        ```

2. (facultatif) Vous devrez extraire le fichier `.tar` du fichier `.tar.xz` si vous utilisez l'une des dernières versions de WSL
3. Créez le répertoire dans lequel le WSL stockera ses fichiers (normalement quelque part dans le profil utilisateur)
4. Enfin, importez l'image dans WSL ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)) :

    - WSL :

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-10-image.tar.xz> --version 1
        ```

    - WSL 2 :

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-10-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    En général, WSL 2 devrait être plus rapide que WSL, bien que cela puisse varier selon le cas d'utilisation.

!!! tip "Windows Terminal"

    Si vous avez installé Windows Terminal, le nom de votre nouvelle distribution WSL apparaîtra comme une option dans le menu déroulant, ce qui est très utile pour la lancer par la suite. Vous pouvez ensuite le personnaliser avec des couleurs, des polices et d'autres éléments.

!!! tip "systemd"

    L'image WSL est activée par défaut pour systemd. Si vous souhaitez utiliser les images de conteneur ou créer les vôtres, il vous suffira d'ajouter `systemd=true` à la section `boot` dans le fichier `/etc/wsl.conf`. ([ref.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))
