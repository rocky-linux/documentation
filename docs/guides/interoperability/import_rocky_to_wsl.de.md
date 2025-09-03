---
title: Rocky Linux 8 nach WSL oder WSL2 Importieren
author: Lukas Magauer
tested_with: "8.6"
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

- [A newer WSL version with extra features is available in the Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R). Verwenden Sie nach Möglichkeit diese neuere Version.
- Öffnen Sie ein administratives Terminal (entweder PowerShell oder Eingabeaufforderung) und führen Sie `wsl --install` aus ([siehe Link](https://docs.microsoft.com/en-us/windows/wsl/install))
- Gehen Sie zu den Windows-Einstellungen und aktivieren Sie die Option `Windows-Subsystem for Linux`

Diese Funktion sollte derzeit in jeder unterstützten Version von Windows 10 und 11 verfügbar sein.

!!! tip "WSL-Version"

    Stellen Sie sicher, dass Ihre WSL-Version auf dem neuesten Stand ist, da einige Funktionen erst in späteren Versionen eingeführt wurden. Wenn Sie sich nicht sicher sind, führen Sie `wsl --update` aus.

## Einzelne Schritte

### Herkömmliche Container-Images

1. Sie benötigen den Container `rootfs`. Das ist auf mehrere Arten möglich:

   - Laden Sie das Image vom CDN herunter:
     - 8: [Base x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-UBI.latest.aarch64.tar.xz)
   - Entpacken Sie das Image aus `Docker Hub` oder `Quay.io` ([siehe Link](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:8 > rocky-8-image.tar
        ```

2. (optional) Sie müssen die `.tar`-Datei aus der `.tar.xz`-Datei extrahieren, wenn Sie eine der neuesten WSL-Versionen verwenden

3. Erstellen Sie das Verzeichnis, in dem das WSL seine Dateien speichert (normalerweise irgendwo im Benutzerprofil)

4. Schließlich importieren Sie das Image in WSL ([siehe Link](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

   - WSL:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-8-image.tar.xz> --version 1
        ```

   - WSL 2:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-8-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    Generell sollte WSL 2 schneller sein als WSL, dies kann jedoch je nach Anwendungsfall variieren.

!!! tip "Windows Terminal"

    Wenn Sie `Windows Terminal` installiert haben, wird der neue WSL Distributionsname als Option im Pull-down-Menü angezeigt, das ist ziemlich praktisch, um Linux in der WSL zu starten. Sie können alles dann mit Farben, Schriftarten etc. verschlimmbessern.

!!! tip "systemd"

    L'image WSL est compatible avec `systemd` par défaut. Si vous voulez utiliser les images conteneurs ou créer les vôtres, il vous suffit d'ajouter `systemd=true` à la section « boot » du fichier `/etc/wsl.conf`. ([réf.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))
