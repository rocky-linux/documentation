---
title: Додаток А – Налаштування робочої станції
author: Steven Spencer
contributors: Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - робоча станція
---

# Додаток А - налаштування робочої станції

Хоча ця процедура не є частиною розділів для сервера Incus, ця процедура допоможе тим, хто хоче мати лабораторне середовище або напівпостійну ОС і програму, що працює на робочій станції або ноутбуці Rocky Linux.

## Передумови

- вам зручно працювати в командному рядку
- здатний вільно використовувати редактор командного рядка, наприклад `vi` або `nano`
- потреба в стабільному середовищі тестування, яке використовується щодня або за потреби
- може стати root або мати привілеї `sudo`

## Встановлення

З командного рядка встановіть репозиторій EPEL:

```bash
sudo dnf install epel-release -y
```

Коли встановлення завершиться, виконайте оновлення:

```bash
sudo dnf upgrade
```

Встановіть інші репозиторії:

```bash
sudo dnf config-manager --enable crb
sudo dnf copr enable neil/incus
```

Встановіть кілька необхідних пакетів:

```bash
sudo dnf install dkms vim kernel-devel bash-completion
```

Встановіть і ввімкніть Incus:

```bash
sudo dnf install incus incus-tools
sudo systemctl enable incus
```

Перш ніж продовжити, перезавантажте ноутбук або робочу станцію.

## Ініціалізація Incus

Якщо ви переглянули розділи про робочий сервер, це майже ідентично процедурі ініціалізації робочого сервера.

```bash
sudo incus admin init
```

Відкриється діалогове вікно запитань і відповідей.

Ось запитання та наші відповіді щодо сценарію з невеликими поясненнями, де це необхідно:

```text
Would you like to use clustering? (yes/no) [default=no]: no
Do you want to configure a new storage pool? (yes/no) [default=yes]: yes
Name of the new storage pool [default=default]: storage
```

За бажанням ви можете прийняти значення default.

```text
Ім’я сховища для використання (btrfs, dir, lvm, ceph) [default=btrfs]: dir
```

Зауважте, що `dir` дещо повільніший за `zfs`. Якщо ви залишите диск порожнім, ви можете використовувати цей пристрій (приклад: /dev/sdb) для пристрою `zfs`, а потім вибрати `zfs`.

```text
Would you like to connect to a MAAS server? (yes/no) [default=no]:
```

Metal As A Service (MAAS) виходить за рамки цього документа.

```text
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
```

Ви можете ввімкнути цю опцію, якщо хочете використовувати IPv6 у своїх контейнерах Incus. Це залежить від вас.

```text
Would you like the Incus server to be available over the network? (yes/no) [default=no]: yes
```

Це необхідно для створення snapshot робочої станції. Тут дайте відповідь "yes".

```text
Address to bind Incus to (not including port) [default=all]:
Port to bind Incus to [default=8443]:
Trust password for new clients:
Again:
```

Цей пароль довіри означає, як ви підключатиметеся до snapshot сервера або повертатиметеся із snapshot сервера. Встановіть це з тим, що має сенс у вашому оточенні. Збережіть цей запис у безпечному місці, наприклад у менеджері паролів.

```text
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]
Would you like a YAML "incus admin init" preseed to be printed? (yes/no) [default=no]:
```

## Права користувача

Наступне, що вам потрібно зробити, це додати свого користувача до групи `incus-admin`. Знову ж таки, для цього вам потрібно буде використовувати `sudo` або мати права користувача root:

```text
sudo usermod -a -G incus-admin [username]
```

де [username] — ваш користувач у системі.

## Встановлення значень `subuid` і `subgid` для `root`

Ви повинні встановити як значення `subuid`, так і `subgid` кореневого користувача (діапазон ідентифікаторів підлеглих користувачів і груп). Це значення має бути:

```bash
root:1000000:1000000000
```

Для цього відредагуйте `/etc/subuid` і додайте цей рядок. Після завершення ваш файл матиме такий вигляд:

```bash
root:1000000:1000000000
```

Знову додайте цей рядок до файлу `/etc/subgid`. Ваш файл виглядатиме приблизно так:

```bash
incusadmin:100000:65536
root:1000000:1000000000
```

На цьому етапі ви внесли багато змін. Перш ніж йти далі, перезавантажте машину.

## Перевірка інсталяції

Щоб переконатися, що `incus` запущено та що ваш користувач має привілеї, з підказки оболонки виконайте:

```text
incus list
```

Зауважте, що ви не використали тут `sudo`. Ваш користувач має можливість вводити ці команди. Ви побачите щось на зразок цього:

```bash
+------------+---------+----------------------+------+-----------+-----------+
|    NAME    |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------------+---------+----------------------+------+-----------+-----------+
```

Якщо так, то виглядаєте добре!

## Решта

З цього моменту ви можете використовувати розділи з нашого «Incus Production Server», щоб продовжити. Однак у налаштуванні робочої станції є деякі речі, на які нам потрібно звертати менше уваги. Ось рекомендовані розділи, які вам допоможуть:

- [Розділ 5. Налаштування та керування зображеннями](05-incus_images.md)
- [Розділ 6 - Профілі](06-profiles.md)
- [Розділ 8 - Знімки контейнера](08-snapshots.md)

## Додатково

- [Офіційний огляд і документація Incus](https://linuxcontainers.org/incus/docs/main/)

## Висновок

Incus — це потужний інструмент, який підвищує продуктивність на робочих станціях або серверах. На робочій станції він чудово підходить для лабораторних тестів, але також може зберігати напівпостійні екземпляри операційних систем і програм у їхньому приватному просторі.
