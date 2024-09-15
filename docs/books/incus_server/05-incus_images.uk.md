---
title: 5 Налаштування та керування зображеннями
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - incus images
---

У цій главі ви повинні запускати команди як непривілейований користувач ("incusadmin", якщо ви читали цю книгу з самого початку).

## Список доступних зображень

Можливо, вам кортить почати роботу з контейнером. Є багато можливостей контейнерної операційної системи. Щоб зрозуміти, скільки існує можливостей, введіть цю команду:

```bash
incus image list images: | more
```

Щоб переглянути список, натисніть пробіл. Цей список контейнерів і віртуальних машин продовжує зростати.

**Останнє**, що вам потрібно зробити, це пошукати образ контейнера для встановлення, головним чином якщо ви знаєте образ, який хочете створити. Змініть команду, щоб відображати лише параметри встановлення Rocky Linux:

```bash
incus image list images: | grep rocky
```

Це відкриває набагато більш керований список:

```bash
| rockylinux/8 (3 more)                    | dede6169bb45 | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | VIRTUAL-MACHINE | 850.75MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/arm64 (1 more)              | b749bad83e60 | yes    | Rockylinux 8 arm64 (20240903_04:40)        | aarch64      | CONTAINER       | 125.51MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud (1 more)              | 4fefd464d25d | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | VIRTUAL-MACHINE | 869.95MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud (1 more)              | 729891475172 | yes    | Rockylinux 8 amd64 (20240903_05:18)        | x86_64       | CONTAINER       | 148.81MiB  | 2024/09/02 19:00 CDT |
| rockylinux/8/cloud/arm64                 | 3642ec9652fc | yes    | Rockylinux 8 arm64 (20240903_04:52)        | aarch64      | CONTAINER       | 144.84MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9 (3 more)                    | 9e5e4469e660 | yes    | Rockylinux 9 amd64 (20240903_03:29)        | x86_64       | VIRTUAL-MACHINE | 728.60MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9 (3 more)                    | fff1706d5834 | yes    | Rockylinux 9 amd64 (20240903_03:29)        | x86_64       | CONTAINER       | 111.25MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/arm64 (1 more)              | d3a44df90d69 | yes    | Rockylinux 9 arm64 (20240903_04:49)        | aarch64      | CONTAINER       | 107.18MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud (1 more)              | 4329a67099ba | yes    | Rockylinux 9 amd64 (20240903_03:28)        | x86_64       | VIRTUAL-MACHINE | 749.29MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud (1 more)              | bc30d585b9f0 | yes    | Rockylinux 9 amd64 (20240903_03:28)        | x86_64       | CONTAINER       | 127.16MiB  | 2024/09/02 19:00 CDT |
| rockylinux/9/cloud/arm64                 | 5c38ddd506bd | yes    | Rockylinux 9 arm64 (20240903_04:38)        | aarch64      | CONTAINER       | 122.87MiB  | 2024/09/02 19:00 CDT |
```

## Встановлення, перейменування та перелік зображень

Для першого контейнера ви збираєтеся використовувати "rockylinux/8". Щоб встановити його, ви можете використовувати:

```bash
incus launch images:rockylinux/8 rockylinux-test-8
```

Це створить контейнер на основі Rocky Linux під назвою "rocky linux-test-8". Ви можете перейменувати контейнер після його створення, але спочатку потрібно зупинити контейнер, який запускається автоматично після створення.

Щоб запустити контейнер вручну, використовуйте:

```bash
incus start rockylinux-test-8
```

Щоб перейменувати зображення (ми не збираємося робити це тут, але ось як це зробити), спочатку зупиніть контейнер:

```bash
incus stop rockylinux-test-8
```

Використовуйте команду `move`, щоб змінити назву контейнера:

```bash
incus move rockylinux-test-8 rockylinux-8
```

Якщо ви все одно виконали цю інструкцію, зупиніть контейнер і поверніть його до вихідної назви, щоб продовжувати слідувати.

Для цілей цього посібника встановіть ще два зображення:

```bash
incus launch images:rockylinux/9 rockylinux-test-9
```

та

```bash
incus launch images:ubuntu/22.04 ubuntu-test
```

Перевірте, що у вас є, перерахувавши свої зображення:

```bash
incus list
```

який поверне це:

```bash
+-------------------+---------+----------------------+------+-----------+-----------+
|       NAME        |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-8 | RUNNING | 10.146.84.179 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| rockylinux-test-9 | RUNNING | 10.146.84.180 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
| ubuntu-test       | RUNNING | 10.146.84.181 (eth0) |      | CONTAINER | 0         |
+-------------------+---------+----------------------+------+-----------+-----------+
```
