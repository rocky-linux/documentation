---
title: Імпорт Rocky Linux до WSL або WSL2
author: Lukas Magauer
tested_with: 8.10, 9.6, 10.0
tags:
  - wsl
  - wsl2
  - windows
  - сумісність
---

# Імпорт Rocky Linux до WSL

## Передумови

Необхідно ввімкнути функцію Windows-Subsystem для Linux. Це можливо за допомогою одного з цих варіантів:

- [Новіша версія WSL із додатковими функціями доступна в Microsoft Store](https://apps.microsoft.com/store/detail/windows-subsystem-for-linux/9P9TQF7MRM4R). Використовуйте цю новішу версію, коли це можливо.
- Відкрийте адміністративний термінал (PowerShell або Command-Prompt) і запустіть `wsl --install` ([посил.](https://docs.microsoft.com/en-us/windows/wsl/install))
- Перейдіть до графічних налаштувань Windows і ввімкніть додаткову функцію `Підсистема Windows для Linux`

Тепер ця функція має бути доступна в усіх підтримуваних версіях Windows 10 і 11.

!!! tip "Версія WSL"

   Переконайтеся, що ваша версія WSL оновлена, оскільки деякі функції були представлені лише в пізніших версіях. Якщо ви не впевнені, виконайте команду `wsl --update`.

## Кроки

### Встановлювані образи WSL (бажано)

1. Завантажте образ WSL з CDN або іншого дзеркала, ближчого до вас:

    - 9: [x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-WSL-Base.latest.x86_64.wsl) або [aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-WSL-Base.latest.aarch64.wsl)
    - 10: [x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-WSL-Base.latest.x86_64.wsl) або [aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-WSL-Base.latest.aarch64.wsl)

2. Існує кілька варіантів встановлення образу `.wsl`:

    - Двічі клацніть на зображенні, і воно буде встановлено з ім'ям зображення за замовчуванням
    - Встановіть образ через командний рядок:

        ```sh
        wsl --install --from-file <path-to/Rocky-10-WSL-Base.latest.x86_64.wsl> <machine-name>
        ```

### Зображення звичайних контейнерів

1. Отримайте контейнер rootfs. Це можливо кількома способами:

    - Завантажте зображення з CDN:
        - 8: [Base x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/8/images/aarch64/Rocky-8-Container-UBI.latest.aarch64.tar.xz)
        - 9: [Base x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/9/images/aarch64/Rocky-9-Container-UBI.latest.aarch64.tar.xz)
        - 10: [Base x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-Base.latest.x86_64.tar.xz), [Minimal x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-Minimal.latest.x86_64.tar.xz), [UBI x86_64](https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-Container-UBI.latest.x86_64.tar.xz), [Base aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-Base.latest.aarch64.tar.xz), [Minimal aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-Minimal.latest.aarch64.tar.xz), [UBI aarch64](https://dl.rockylinux.org/pub/rocky/10/images/aarch64/Rocky-10-Container-UBI.latest.aarch64.tar.xz)
    - Витягніть образ з Docker Hub або Quay.io ([посилання.](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#export-the-tar-from-a-container))

        ```sh
        <podman/docker> export rockylinux:10 > rocky-10-image.tar
        ```

2. (необов’язково) Вам доведеться розпакувати файл .tar із файлу .tar.xz, якщо ви не використовуєте одну з останніх версій WSL
3. Створіть каталог, де WSL зберігатиме свої файли (переважно десь у профілі користувача)
4. Нарешті імпортуйте зображення до WSL ([ посилання](https://docs.microsoft.com/en-us/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl)):

    - WSL:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-10-image.tar.xz> --version 1
        ```

    - WSL 2:

        ```sh
        wsl --import <machine-name> <path-to-vm-dir> <path-to/rocky-10-image.tar.xz> --version 2
        ```

!!! tip "WSL vs. WSL 2"

    Загалом кажучи, WSL 2 має бути швидшим за WSL, хоча це може відрізнятися залежно від випадку використання.

!!! tip "Термінал Windows"

    Якщо у вас встановлено термінал Windows, нова назва дистрибутива WSL з’явиться як опція у випадаючому меню, що досить зручно для запуску в майбутньому. Потім ви можете налаштувати його за допомогою кольорів, шрифтів та інших елементів.

!!! tip "systemd"

    Образ WSL за замовчуванням увімкнено для systemd. Якщо ви хочете використовувати образи контейнерів або створити свій власний, вам потрібно лише додати `systemd=true` до розділу `boot` у файлі `/etc/wsl.conf`. ([ref.](https://devblogs.microsoft.com/commandline/systemd-support-is-now-available-in-wsl/#set-the-systemd-flag-set-in-your-wsl-distro-settings))
