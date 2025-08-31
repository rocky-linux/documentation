---
title: Rocky Linux nach WSL oder WSL2 Import
author: Lukas Magauer
tested_with: 8.10, 9.6, 10.0
tags:
  - wsl
  - wsl2
  - windows
  - Interoperabilität
---

!!! note "Images für andere Versionen"

    Wenn Sie nach WSL-Anweisungen für eine andere Version von Rocky Linux suchen, wählen Sie die gewünschte Version aus dem oberen Menü aus und lesen Sie dann die WSL-Anweisungen unter „Interoperabilität“.

## Voraussetzungen

Sie müssen die Funktion `Windows-Subsystem für Linux` aktivieren. Das ist mit einer dieser Optionen möglich:

- [Eine neuere WSL-Version mit zusätzlichen Funktionen ist im Microsoft Store verfügbar](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R). Verwenden Sie nach Möglichkeit diese neuere Version.
- Öffnen Sie ein administratives Terminal (entweder PowerShell oder Eingabeaufforderung) und führen Sie `wsl --install` aus ([siehe Link](https://docs.microsoft.com/en-us/windows/wsl/install))
- Gehen Sie zu den Windows-Einstellungen und aktivieren Sie die Option `Windows-Subsystem für Linux`

Diese Funktion sollte derzeit in jeder unterstützten Version von Windows 10 und 11 verfügbar sein.

!!! tip "WSL-Version"

    Stellen Sie sicher, dass Ihre `WSL`-Version auf dem neuesten Stand ist, da einige Funktionen erst in neueren Versionen eingeführt wurden. Wenn Sie sich nicht sicher sind, führen Sie `wsl --update` aus.

## Einzelne Schritte

### Installierbare WSL-Images (vorzugsweise)

1. Laden Sie das WSL-Image vom CDN oder einem anderen Mirror in Ihrer Nähe herunter:

    - 10: [x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-WSL-Base.latest.x86_64.wsl) oder [aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-WSL-Base.latest.aarch64.wsl)

2. Es gibt mehrere Optionen zum Installieren eines `.wsl`-Images:

    - Doppelklicken Sie auf das Image und es wird mit dem Standardnamen des Bildes installiert
    - Installieren Sie das Image über die Befehlszeile:

        ```sh
        wsl --install --from-file <path-to/Rocky-10-WSL-Base.latest.x86_64.wsl> --name <machine-name>
        ```

### Herkömmliche Container-Images

1. Sie benötigen den Container `rootfs`. Das ist auf mehrere Arten möglich:

    - Laden Sie das Image vom CDN herunter:
        - 10: [Base x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-UBI.latest.aarch64.tar.xz)
    - Entpacken Sie das Image aus `Docker Hub` oder `Quay.io` ([siehe Link](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:10 > rocky-10-image.tar
        ```

2. (optional) Sie müssen die `.tar`-Datei aus der `.tar.xz`-Datei extrahieren, wenn Sie eine der neuesten WSL-Versionen verwenden
3. Erstellen Sie das Verzeichnis, in dem das WSL seine Dateien speichert (normalerweise irgendwo im Benutzerprofil)
4. Importieren Sie abschließend das Image in WSL ([Ref.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

    - WSL:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-10-image.tar.xz> --version 1
        ```

    - WSL 2:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-10-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    Generell sollte WSL 2 schneller sein als WSL, dies kann jedoch je nach Anwendungsfall variieren.

!!! tip "Windows Terminal"

    Wenn Sie `Windows Terminal` installiert haben, wird der neue WSL-Distributionsname als Option im Pull-down-Menü angezeigt, was für zukünftige Starts sehr praktisch ist. Sie können alles dann mit Farben, Schriftarten etc. verschlimmbessern.

!!! tip "systemd"

    Das WSL-Image ist standardmäßig `systemd`-fähig. Wenn Sie Container-Images verwenden oder eigene erstellen möchten, fügen Sie einfach `systemd=true` zum Abschnitt `boot` in der Datei `/etc/wsl.conf` hinzu. ([ref.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))
