---
title: Importer Rocky Linux vers WSL ou WSL2
author: Lukas Magauer
tested_with: 8.6, 9.0
tags:
  - wsl
  - wsl2
  - windows
  - interopérabilité
---

# Importer Rocky Linux vers WSL

## Prérequis

La fonctionnalité Windows-Subsystem pour Linux doit être activée. Ceci est possible avec l'une de ces options :

- Depuis très peu de temps, il existe désormais [une nouvelle version WSL disponible dans le Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R), qui possède plus de fonctionnalités, utilisez-la si possible
- Ouvrez un terminal d'administration (PowerShell ou invite de commande) et exécutez la commande suivante :<br/>`wsl --install` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/install))
- Accédez aux paramètres graphiques de Windows et activez la fonctionnalité facultative `Windows-Subsystem for Linux`

Cette fonctionnalité devrait être disponible sur toutes les versions Windows 10 et 11 prises en charge actuellement (février 2025).

## Marche à suivre

1. Récupérez `rootfs` du conteneur. Ceci est possible de plusieurs manières :

    - **Préférable :** Téléchargez l'image depuis le CDN :
        - 8: [Base x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-UBI.latest.aarch64.tar.xz)
        - 9: [Base x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-UBI.latest.aarch64.tar.xz)
    - Extraire l'image à partir de `Docker Hub` ou de `Quay.io` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:9 > rocky-9-image.tar
        ```

2. (facultatif) Vous devrez extraire le fichier .tar du fichier .tar.xz si vous n'utilisez pas l'une des dernières versions de WSL
3. Créer le répertoire où le WSL stockera ses fichiers (par exemple quelque part dans le profil utilisateur)
4. Enfin, importer l'image dans WSL ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)) :

    - WSL :

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz>
        ```

    - WSL 2:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    En général, le WSL 2 devrait être plus rapide que le WSL, mais cela peut différer d'un cas d'utilisation à l'autre.

!!! tip "Terminal Windows"

    Si `Windows Terminal` est installé, le nouveau nom de la distribution WSL apparaîtra comme une option dans le menu déroulant ce qui est assez pratique pour le lancement de Linux. Vous pouvez ensuite personnaliser le système 
     avec des couleurs, des polices, etc.

!!! tip "systemd"

    Microsoft a finalement décidé d’intégrer `systemd` dans le WSL. Cette fonctionnalité fait partie de la nouvelle version WSL dans Microsoft Store. Il vous suffit d'ajouter `systemd=true` à la section ini `boot` dans le fichier `/etc/wsl.conf` ! ([ref.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))

!!! tip "Microsoft Store"

    Il n'y a actuellement aucune image dans le Microsoft Store, si vous voulez aider à l'y amener, rejoignez la conversation dans le canal Mattermost SIG/Containers ! Les [quelques efforts](https://github.com/rocky-linux/WSL-DistroLauncher) fournis il y a longtemps, peuvent être utiles maintenant.
