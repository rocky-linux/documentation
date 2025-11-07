---
title: 3 Ініціалізація LXD і налаштування користувача
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - ініціалізація lxd
  - налаштування lxd
---

# Розділ 3: Ініціалізація LXD і налаштування користувача

У цьому розділі вам потрібно мати права root або вміти викорисовувати `sudo`, щоб стати root. Крім того, припускається, що ви налаштували пул сховищ ZFS, описаний у [Розділі 2] (02-zfs_setup.md). Ви можете використовувати інший пул зберігання, якщо ви вирішили не використовувати ZFS, але вам потрібно буде внести зміни до запитань і відповідей щодо ініціалізації.

## Ініціалізація LXD

Серверне середовище налаштовано. Ви готові ініціалізувати LXD. Це автоматизований сценарій, який задає низку запитань, щоб запустити ваш екземпляр LXD:

```bash
lxd init
```

Ось запитання та наші відповіді щодо сценарію з невеликими поясненнями, де це необхідно:

```text
Would you like to use LXD clustering? (yes/no) [default=no]:
```

Якщо вас цікавить кластеризація, проведіть додаткові дослідження щодо цього [тут](https://documentation.ubuntu.com/lxd/en/latest/clustering/)

```text
Do you want to configure a new storage pool? (yes/no) [default=yes]:
```

Це здається неінтуїтивним. Ви вже створили свій пул ZFS, але це стане зрозумілим у наступному питанні. Прийняти значення за замовчуванням.

```text
Ім’я нового пулу сховищ [default=default]: storage
```

Можна залишити це значення «за замовчуванням», але для ясності краще використовувати ту саму назву, яку ви дали нашому пулу ZFS.

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
What should the new bridge be called? [default=lxdbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

Якщо ви хочете використовувати IPv6 у своїх контейнерах LXD, ви можете ввімкнути цю опцію. Це залежить від вас.

```text
Would you like the LXD server to be available over the network? (yes/no) [default=no]: yes
```

Це необхідно для створення snapshot сервера.

```text
Address to bind LXD to (not including port) [default=all]:
Port to bind LXD to [default=8443]:
Trust password for new clients:
Again:
```

Цей пароль довіри означає, як ви підключатиметеся до snapshot сервера або повертатиметеся із snapshot сервера. Встановіть це з тим, що має сенс у вашому оточенні. Збережіть цей запис у безпечному місці, наприклад у менеджері паролів.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

## Налаштування прав користувача

Перш ніж продовжити, нам потрібно створити нашого користувача "lxdadmin" і переконатися, що він має необхідні привілеї. Вам потрібно, щоб користувач "lxdadmin" мав можливість отримати root-права за допомогою `sudo`, і щоб він був членом групи lxd. Щоб додати користувача та переконатися, що він є членом обох груп, виконайте:

```bash
useradd -G wheel,lxd lxdadmin
```

Потім встановіть пароль:

```bash
passwd lxdadmin
```

Як і інші паролі, збережіть цей пароль у безпечному місці.
