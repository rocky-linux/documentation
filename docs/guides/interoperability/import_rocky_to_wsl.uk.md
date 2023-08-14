---
title: Імпорт Rocky Linux до WSL або WSL2
author: Lukas Magauer
tested_with: 8.6, 9.0
tags:
  - wsl
  - wsl2
  - windows
  - сумісність
---

# Імпорт Rocky Linux до WSL

## Передумови

Необхідно ввімкнути функцію Windows-Subsystem для Linux. Це можливо за допомогою одного з цих варіантів:

- Оскільки незабаром [нова версія WSL доступна в Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R), який має більше функцій, використовуйте це, якщо можливо
- Відкрийте адміністративний термінал (PowerShell або Command-Prompt) і<br>запустіть `wsl --install` ([посил.](https://docs.microsoft.com/en-us/windows/ wsl/install))
- Перейдіть до графічних налаштувань Windows і ввімкніть додаткову функцію `Windows-Subsystem for Linux`

Тепер ця функція має бути доступна в усіх підтримуваних версіях Windows 10 і 11.

## Кроки

1. Отримайте контейнер rootfs. Це можливо кількома способами:

    - **Бажаний спосіб:** Завантажте зображення з CDN:
        - 8: [Base x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-UBI.latest.x86_64.tar.xz),<br>[Base aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-UBI.latest.aarch64.tar.xz)
        - 9: [Base x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-UBI.latest.x86_64.tar.xz),<br>[Base aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-UBI.latest.aarch64.tar.xz)
    - Видобудьте зображення з Docker Hub або Quay.io ([посил.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a -container))

        ```sh
        <podman/docker> export rockylinux:9 > rocky-9-image.tar
        ```

2. (необов’язково) Вам доведеться розпакувати файл .tar із файлу .tar.xz, якщо ви не використовуєте одну з останніх версій WSL
3. Створіть каталог, де WSL зберігатиме свої файли (переважно десь у профілі користувача)
4. Нарешті імпортуйте зображення до WSL ([ посилання](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

    - WSL:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz>
        ```

    - WSL 2:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-9-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    Взагалі кажучи, WSL 2 має бути швидшим за WSL, але це може відрізнятися від випадку використання до випадку використання.

!!! tip "Термінал Windows"

    Якщо у вас встановлено термінал Windows, нова назва дистрибутива WSL з’явиться як опція в спадному меню, що дуже зручно для майбутніх запусків. Потім ви можете налаштувати його за допомогою кольорів, шрифтів тощо.

!!! tip "systemd"

    Microsoft нарешті вирішила ввести systemd у WSL. Ця функція доступна в новій версії WSL із Microsoft Store. Вам потрібно лише додати `systemd=true` до розділу `boot` ini у файлі `/etc/wsl.conf`! ([ref.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))

!!! tip "Microsoft Store"

    Немає зображення в Microsoft Store; якщо ви хочете допомогти це зробити, приєднуйтесь до розмови на каналі Mattermost SIG/Containers! Було [деяких зусиль](https://github.com/rocky-linux/WSL-DistroLauncher) давно, які можуть бути підхоплені знову.
