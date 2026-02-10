---
title: Створення власного ISO Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9.5
tags:
  - create
  - custom
  - ISO
---

## Вступ

Вам може знадобитися створити власний ISO з багатьох причин. Можливо, ви хочете змінити процес завантаження, додати певні пакети або оновити файл конфігурації.

Цей посібник проінструктує вас від початку до кінця про те, як створити свій власний Rocky Linux ISO.

## Передумови

- 64-розрядна машина під керуванням Rocky Linux 9
- ISO-образ DVD Rocky Linux 9.
- Файл `kickstart` для застосування до ISO.
- Прочитайте документацію Lorax [Quickstart](https://weldr.io/lorax/lorax.html#quickstart) і [mkksiso](https://weldr.io/lorax/mkksiso.html), щоб ознайомитися зі створенням `boot.iso` `Anaconda`.

## Встановлення та налаштування пакета

- Встановлення пакету `lorax`:

```bash
sudo dnf install -y lorax
```

## Створення ISO за допомогою файлу kickstart

- Виконайте команду `mkksiso`, щоб додати файл `kickstart`, а потім створіть новий ISO:

```bash
mkksiso --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO_TO_MODIFY> <OUTPUT_PATH_FOR_BUILT_ISO>
```

- Нижче наведено приклад файлу `kickstart` `example-ks.cfg`, який налаштовує середовище Rocky Linux 9.5 `Server With GUI`:

```bash
lang en_GB
keyboard --xlayouts='us'
timezone Asia/Tokyo --utc
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp
firstboot --disable
selinux --enforcing
firewall --enabled
%packages
@^server-product-environment
%end
```

## Додавання репозиторію з його пакетами до образу ISO

- Переконайтеся, що репозиторій, який ви хочете додати, має всередині каталог `repodata`. Якщо ні, ви можете створити це за допомогою команди `createrepo_c` і встановити за допомогою `sudo dnf install -y createrepo_c`
- Додайте репозиторій до свого файлу `kickstart`, використовуючи такий синтаксис:

```bash

repo --name=extra-repo --baseurl=file:///run/install/repo/<YOUR_REPOSITORY>/
```

- Додайте свій репозиторій за допомогою прапорця `--add` за допомогою інструмента `mkksiso`:

```bash
mkksiso --add <LINK_TO_YOUR_REPOSITORY> --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO_TO_MODIFY> <OUTPUT_PATH_FOR_BUILT_ISO>
```

- Ви можете побачити додаткові деталі цього процесу за допомогою репозиторію `baseos` у прикладі нижче
- Репозиторій `base os` буде завантажено локально разом із усіма його пакетами:

```bash
dnf reposync -p ~ --download-metadata --repo=baseos
```

- Потім додайте репозиторій до файлу `kickstart`:

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
```

- Файл `kickstart` виглядатиме так:

```bash
lang en_GB
keyboard --xlayouts='us'
timezone Asia/Tokyo --utc
reboot
cdrom
bootloader --append="rhgb quiet crashkernel=1G-4G:192M,4G-64G:256M,64G-:512M"
zerombr
clearpart --all --initlabel
autopart
network --bootproto=dhcp
firstboot --disable
selinux --enforcing
firewall --enabled
%packages
@^server-product-environment
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
%end
```

- Потім введіть команду `mkksiso` безпосередньо до каталогу сховища та створіть ISO:

```bash
mkksiso --add ~/baseos --ks example-ks.cfg ~/Rocky-9.5-x86_64-dvd.iso ~/Rocky-9.5-x86_64-dvd-new.iso
```

## Висновок

Тут обговорювалося лише кілька варіантів налаштування та створення власного ISO Rocky Linux. Для подальших способів, включаючи зміну аргументів командного рядка ядра, автор наполегливо рекомендує ознайомитися з документацією [mkksiso](https://weldr.io/lorax/mkksiso.html) більш детально.
