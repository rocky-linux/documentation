---
title: Створення власного ISO Rocky Linux
author: Howard Van Der Wal
contributors: Steven Spencer, Ganna Zhyrnova
tested with: 9
tags:
  - create
  - custom
  - ISO
  - kickstart
  - linux
  - mkksiso
  - rocky
---

**Знання**: :star: :star:
**Час читання**: 10 хвилин

## Вступ

Існує багато причин для створення ISO-образу. Можливо, ви хочете змінити процес завантаження, додати певні пакети під час встановлення або оновити певні файли конфігурації.

У цьому посібнику ви дізнаєтесь, як створити власний ISO-образ Rocky Linux.

## Передумови

- Мінімальний ISO-образ Rocky Linux (образ DVD не потрібен).
- Файл `kickstart` для застосування до ISO.
- Прочитайте документацію [Lorax Quickstart](https://weldr.io/lorax/lorax.html#quickstart) та [mkksiso](https://weldr.io/lorax/mkksiso.html), щоб ознайомитися зі створенням ISO-образу.

## Встановлення та налаштування пакета

- Встановлення пакету `lorax`:

```bash
dnf install -y lorax
```

## Створення ISO за допомогою файлу kickstart

- Виконайте команду `mkksiso`, щоб додати файл `kickstart`, а потім створіть новий ISO. Зверніть увагу, що вам потрібно виконати команду від імені користувача `root` або користувача з привілеями `sudo`:

```bash
mkksiso --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO> <PATH_TO_NEW_ISO>
```

## Додавання репозиторію з його пакетами до образу ISO

- Переконайтеся, що репозиторій, який ви хочете додати, має всередині каталог `repodata`. Якщо ні, ви можете створити його за допомогою команди `createrepo_c` та встановити за допомогою `dnf install -y createrepo_c`
- Додайте репозиторій до свого файлу `kickstart`, використовуючи такий синтаксис:

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/<REPOSITORY>/
```

- Додайте свій репозиторій за допомогою прапорця `--add` за допомогою інструмента `mkksiso`:

```bash
mkksiso --add <LINK_TO_REPOSITORY> --ks <PATH_TO_KICKSTART_FILE> <PATH_TO_ISO> <PATH_TO_NEW_ISO>
```

- Ви можете побачити додаткові деталі цього процесу, використовуючи репозиторій `baseos` у прикладі нижче.
- Репозиторій `baseos` буде завантажено локально разом з усіма його пакетами:

```bash
dnf reposync -p ~ --download-metadata --repo=baseos
```

- Потім додайте репозиторій до вашого файлу `kickstart`:

```bash
repo --name=extra-repo --baseurl=file:///run/install/repo/baseos/
```

- Потім введіть команду `mkksiso` безпосередньо до каталогу сховища та створіть ISO:

```bash
mkksiso --add ~/baseos --ks <PATH_TO_KICKSTART_FILE> ~/<PATH_TO_ISO> ~/<PATH_TO_NEW_ISO>
```

## Висновок

Після того, як ваш ISO-образ буде зібрано за допомогою файлу Kickstart, розгортати сотні машин з одного образу стає набагато простіше, не налаштовуючи кожну машину окремо. Щоб дізнатися більше про файли `kickstart`, а також кілька прикладів, будь ласка, перегляньте [посібник з файлів Kickstart та Rocky Linux](../../automatization/kickstart-rocky/).
