---
title: Rocky Linux nach WSL oder WSL2 Import
author: Lukas Magauer
tested_with: 8.6, 9.0
tags:
  - wsl
  - wsl2
  - windows
  - Interoperabilität
---

# Rocky Linux nach WSL importieren

## Voraussetzungen

Das Windows-Subsystem für Linux muss aktiviert werden. Dies ist mit einer dieser Optionen möglich:

- Seit Kurzem gibt eine neue [ WSL Version im Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R), die vorzugsweise verwendet werden sollte.
- Öffnen Sie ein administratives Terminal (entweder PowerShell oder Eingabeaufforderung) und führen Sie `wsl --install` aus ([siehe Link](https://docs.microsoft.com/en-us/windows/wsl/install))
- Gehen Sie zu den Windows-Einstellungen und aktivieren Sie die Option `Windows-Subsystem für Linux`

Diese Funktion sollte auf jeder neuen Windows 10 und 11 Version verfügbar sein.

## Einzelne Schritte

1. Sie benötigen das Container `rootfs`. Das ist auf mehrere Arten verfügbar:

    - **Vorzugsweise:** Laden Sie das ISO-Bild vom CDN herunter:
        - 8: [Base x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-UBI.latest.aarch64.tar.xz)
        - 9: [Base x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-UBI.latest.aarch64.tar.xz)
    - Entpacken Sie das Image aus `Docker Hub` oder `Quay.io` ([siehe Link](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:9 > rocky-9-image.tar
        ```

2. (optional) Möglicherweise müssen Sie die .tar aus der .tar.xz Datei extrahieren, falls Sie nicht eine der neuesten WSL Versionen verwenden
3. Erstellen Sie das Verzeichnis, in dem das WSL seine Dateien speichert (zum Beispiel irgendwo im Benutzerprofil)
4. Schließlich importieren Sie das Image in WSL ([siehe Link](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

    - WSL:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz>
        ```

    - WSL 2:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    Eigentlich sollte (!) WSL 2 schneller sein als WSL, aber das kann sich von Anwendungsfall zu Anwendungsfall unterscheiden.

!!! tip "Windows Terminal"

    Wenn Sie `Windows Terminal` installiert haben, wird der neue WSL Distributionsname als Option im Pull-down-Menü angezeigt, das ist ziemlich praktisch, um Linux in der WSL zu starten. Sie können alles dann mit Farben, Schriftarten etc. verschlimmbessern.

!!! tip "systemd"

    Microsoft hat sich auch entschieden, `systemd` in die WSL zu integrieren. Diese Option existiert bereits in der neuesten WSL Version aus dem Microsoft Store. Sie sollten nur die Zeile `systemd=true` im ini-Abschnitt `boot` der Datei `/etc/wsl.conf` hinzufügen! ([ref.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))

!!! tip "Microsoft Store"

    Derzeit gibt es kein Bild im Microsoft Store, wenn Sie helfen wollen, es dorthin zu bringen, besuchen Sie uns im Mattermost SIG/Containers Channel! Es gab vor langer Zeit [einige Anstrengungen](https://github.com/rocky-linux/WSL-DistroLauncher), die wieder aufgegriffen werden können.
