---
title: Importar Rocky Linux en WSL o WSL2
author: Lukas Magauer
tested_with: 8.6, 9.0
tags:
  - wsl
  - wsl2
  - ventanas
  - interoperabilidad
---

# Importar Rocky Linux a WSL

## Requisitos previos

El subsistema de Windows para Linux tiene que ser habilitado. Esto es posible con cualquiera de estas opciones:

- Abra una terminal administrativa (ya sea PowerShell o Comando-Prompt) y ejecute `wsl --install` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/install))
- Abra una terminal administrativa (ya sea PowerShell o Comando-Prompt) y<br>ejecute `wsl --install` ([ref.](https://docs.microsoft.com/en-us/windows/wsl/install)).
- Vaya a la configuración gráfica de Windows y habilite la función opcional `Windows-Subsystem para Linux`.

Esta característica debería estar disponible en este momento en todas las versiones compatibles con Windows 10 y 11.

## Pasos

1. Obtener el contenedor con el rootfs. Esto es posible de varias maneras:

    - **Preferido:** Descargar la imagen del CDN:
        - 8: [Base x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-UBI.latest.x86_64.tar.xz),<br>[Base aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-UBI.latest.aarch64.tar.xz)
        - 9: [Base x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-UBI.latest.x86_64.tar.xz),<br>[Base aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-UBI.latest.aarch64.tar.xz)
    - Extraiga la imagen de Docker Hub o Quay.io ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:9 > rocky-9-image.tar
        ```

2. (opcional) Tendrá que extraer el archivo .tar del archivo .tar.xz si no está utilizando una de las últimas versiones de WSL
3. Cree el directorio donde WSL almacenará sus archivos (principalmente en algún lugar de su perfil de usuario)
4. Finalmente, importe la imagen en WSL ([ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

    - WSL:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz>
        ```

    - WSL 2:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    Por lo general, WSL 2 debería ser más rápido que WSL, pero eso puede diferir de caso de uso e caso de uso.

!!! tip "Terminal de Windows "

    Si tiene el Terminal de Windows instalado, el nuevo nombre de la distro WSL aparecerá como una opción en el menú desplegable, que es muy útil para lanzarlo en el futuro. Puede personalizarlo con colores, fuentes, etc.

!!! tip "systemd"

    Finalmente, Microsoft decidió introducir systemd en WSL. Esta función está en la nueva versión de WSL de Microsoft Store. ¡Sólo tiene que añadir `systemd=true` a la sección `boot` ini` del fichero `/etc/wsl.conf`! ([ref.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))

!!! tip "Microsoft Store"

    Actualmente no hay ninguna imagen en Microsoft Store, si quiere ayudar a llevarlo allí únase a la conversación en el canal Mattermost SIG/Containers! Ha habido [algún esfuerzo](https://github.com/rocky-linux/WSL-DistroLauncher) hace mucho tiempo, que puede ser usado de nuevo.
