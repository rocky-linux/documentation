---
title: 3 Ініціалізація Incus і налаштування користувача
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - ініціалізація incus
  - налаштування incus
---

У цьому розділі ви повинні бути адміністратором або вміти `sudo`, щоб стати адміністратором. Крім того, передбачається, що ви налаштували пул зберігання даних ZFS, як описано в [главі 2](02-zfs_setup.md). Якщо ви вирішили не використовувати ZFS, ви можете використовувати інший пул зберігання, але вам потрібно буде налаштувати запитання та відповіді щодо ініціалізації.

## Ініціалізація Incus

Ваше серверне середовище налаштовано. Ви готові ініціалізувати Incus. Це автоматизований сценарій, який задає низку запитань, щоб запустити ваш екземпляр Incus:

```bash
incus admin init
```

Ось запитання та наші відповіді щодо сценарію з невеликими поясненнями, де це необхідно:

```text
Would you like to use clustering? (yes/no) [default=no]:
```

Якщо вас цікавить кластеризація, проведіть додаткові дослідження [тут](https://linuxcontainers.org/incus/docs/main/explanation/clustering/)

```text
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

Це здається нелогічним. Ви вже створили свій пул ZFS, але це буде зрозуміло в наступному питанні. Прийміть значення за замовчуванням.

```text
Ім’я нового пулу сховищ [default=default]: storage
```

Залишити це значення за замовчуванням можна, але для ясності краще використовувати ту саму назву, яку ви дали нашому пулу ZFS.

```text
Назва серверної частини сховища для використання (btrfs, dir, lvm, zfs, ceph) [default=zfs]:
```

Ви хочете прийняти значення за замовчуванням.

```text
Create a new ZFS pool? (yes/no) [default=yes]: no
```

Тут вступає в дію вирішення попереднього питання про створення пулу зберігання.

```text
Name of the existing ZFS pool or dataset: storage
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Metal As A Service (MAAS) виходить за рамки цього документа.

```text
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

Ви можете ввімкнути цю опцію, щоб використовувати IPv6 у своїх контейнерах Incus.

```text
Would you like the Incus server to be available over the network? (yes/no) [default=no]: yes
```

Це необхідно для створення snapshot сервера.

```text
Address to bind Incus to (not including port) [default=all]:
Port to bind Incus to [default=8443]:
Trust password for new clients:
Again:
```

Цей пароль довіри означає, як ви будете підключатися до сервера знімків або повертатися з нього. Встановіть його з чимось, що має сенс у вашому оточенні. Збережіть цей запис у безпечному місці, наприклад у менеджері паролів.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "incus admin init" preseed to be printed? (yes/no) [default=no]:
```

## Налаштування прав користувача

Перш ніж продовжити, вам потрібно створити користувача "incusadmin" і переконатися, що він має необхідні права. Вам потрібен користувач «incusadmin», щоб мати можливість використовувати `sudo` для рутування, і вам потрібно, щоб він був членом групи `incus-admin`. Щоб додати користувача та переконатися, що він є членом обох груп, виконайте такі дії:

```bash
useradd -G wheel,incus-admin incusadmin
```

Потім встановіть пароль:

```bash
passwd incusadmin
```

Як і інші паролі, збережіть цей пароль у безпечному місці.

## Встановлення значень `subuid` і `subgid` для `root`

Ви повинні встановити як значення `subuid`, так і `subgid` кореневого користувача (діапазон ідентифікаторів підлеглих користувачів і груп). Це значення має бути:

```bash
root:1000000:1000000000
```

Для цього відредагуйте `/etc/subuid` і додайте цей рядок. Після завершення ваш файл матиме такий вигляд:

```bash
root:1000000:1000000000
```

Відредагуйте файл `/etc/subgid` і додайте цей рядок. Після завершення ваш файл матиме такий вигляд:

```bash
incusadmin:100000:65536
root:1000000:1000000000
```

Перш ніж продовжити, перезавантажте сервер.
