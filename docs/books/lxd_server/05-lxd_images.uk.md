---
title: 5 Налаштування та керування зображеннями
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.5, 8.6, 9.0
tags:
  - lxd
  - enterprise
  - lxd зображення
---

# Розділ 5: Налаштування та керування зображеннями

У цій главі вам потрібно буде виконувати команди як непривілейований користувач ("lxdadmin", якщо ви читаєте цю книгу з самого початку).

## Список доступних зображень

Можливо, вам кортить почати роботу з контейнером. Є багато можливостей контейнерної операційної системи. Щоб зрозуміти, скільки існує можливостей, введіть цю команду:

```
lxc image list images: | more
```

Щоб переглянути список, натисніть пробіл. Цей список контейнерів і віртуальних машин продовжує зростати.

**Останнє**, що ви хочете зробити, це переглянути сторінку в пошуках образу контейнера для встановлення, особливо якщо ви знаєте образ, який хочете створити. Змініть команду, щоб відображати лише параметри встановлення Rocky Linux:

```
lxc image list images: | grep rocky
```

Це відкриває набагато більш керований список:

```
| rockylinux/8 (3 more)                    | 0ed2f148f7c6 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 128.68MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8 (3 more)                    | 6411a033fdf1 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 643.15MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/arm64 (1 more)              | e677777306cf | yes    | Rockylinux 8 arm64 (20220805_02:29)          | aarch64      | CONTAINER       | 124.06MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud (1 more)              | 3d2fe303afd3 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 147.04MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud (1 more)              | 7b37619bf333 | yes    | Rockylinux 8 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 659.58MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/8/cloud/arm64                 | 21c930b2ce7d | yes    | Rockylinux 8 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 143.17MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9 (3 more)                    | 61b0171b7eca | yes    | Rockylinux 9 amd64 (20220805_02:07)          | x86_64       | VIRTUAL-MACHINE | 526.38MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9 (3 more)                    | e7738a0e2923 | yes    | Rockylinux 9 amd64 (20220805_02:07)          | x86_64       | CONTAINER       | 107.80MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/arm64 (1 more)              | 917b92a54032 | yes    | Rockylinux 9 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 103.81MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud (1 more)              | 16d3f18f2abb | yes    | Rockylinux 9 amd64 (20220805_02:06)          | x86_64       | CONTAINER       | 123.52MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud (1 more)              | 605eadf1c512 | yes    | Rockylinux 9 amd64 (20220805_02:06)          | x86_64       | VIRTUAL-MACHINE | 547.39MB  | Aug 5, 2022 at 12:00am (UTC)  |
| rockylinux/9/cloud/arm64                 | db3ce70718e3 | yes    | Rockylinux 9 arm64 (20220805_02:06)          | aarch64      | CONTAINER       | 119.27MB  | Aug 5, 2022 at 12:00am (UTC)  |
```

## Встановлення, перейменування та перелік зображень

Для першого контейнера ви збираєтеся використовувати "rockylinux/8". Щоб його встановити, ми *можемо* використати:

```
lxc launch images:rockylinux/8 rockylinux-test-8
```

Це створить контейнер на основі Rocky Linux під назвою "rocky linux-test-8". Ви можете перейменувати контейнер після його створення, але спочатку потрібно зупинити контейнер, який запускається автоматично після створення.

Щоб запустити контейнер вручну, використовуйте:

```
lxc start rockylinux-test-8
```

Щоб перейменувати зображення (ми не збираємося робити це тут, але ось як це зробити), спочатку зупиніть контейнер:

```
lxc stop rockylinux-test-8
```

Використовуйте команду `move`, щоб змінити назву контейнера:

```
lxc move rockylinux-test-8 rockylinux-8
```

Якщо ви все одно виконали цю інструкцію, зупиніть контейнер і поверніть його до вихідної назви, щоб продовжувати слідувати.

Для цілей цього посібника встановіть ще два зображення:

```
lxc launch images:rockylinux/9 rockylinux-test-9
```

та

```
lxc launch images:ubuntu/22.04 ubuntu-test
```

Перевірте, що у вас є, перерахувавши свої зображення:

```
lxc list
```

який поверне це:

```
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

