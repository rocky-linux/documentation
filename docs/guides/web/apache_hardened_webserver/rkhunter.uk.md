---
title: Rootkit Hunter
author: Steven Spencer
contributors: Ezequiel Bruni, Andrew Thiesen, Ganna Zhyrnova
tested_with: 8.8, 9.2
tags:
  - сервер
  - безпека
  - rkhunter
---

# Rootkit hunter

## Вступ

Rootkit hunter (`rkhunter`) — добре відомий інструмент для перевірки вразливостей, руткітів, бекдорів і можливих локальних експлойтів на сервері. Його можна використовувати на _будь-якому_ сервері, який використовується з _будь-якою_ метою. Після налаштування та автоматизації він може повідомляти про будь-яку підозрілу активність системному адміністратору. У цій процедурі описано встановлення, налаштування та використання rootkit hunter.

`rkhunter` — це лише одна з можливих частин надійного налаштування сервера. Використовуйте його окремо або з іншими інструментами для максимального захисту.

## Передумови

* Вміння працювати з редактором командного рядка (у цьому прикладі використовується `vi`)
* Рівень комфорту з видачею команд із командного рядка, переглядом журналів та іншими загальними обов’язками системного адміністратора
* Корисним є розуміння того, що може викликати відповідь на змінені файли у файловій системі (наприклад, оновлення пакетів)
* Виконання всіх команд від імені root або звичайного користувача за допомогою `sudo`

Цей документ був спочатку написаний разом із захищеними програмами веб-сервера Apache, але однаково добре працює на сервері, на якому запущено будь-яке програмне забезпечення.

## Загальні кроки

1. встановлення `rkhunter`
2. налаштування `rkhunter`
3. налаштування електронної пошти та також необхідно переконатися, що вона працює правильно
4. запуск `rkhunter` вручну, для створення списку попереджень для перевірки ваших налаштувань електронної пошти (`rkhunter --check`)
5. запуск `rkhunter --propupd`, для створення чистого файлу `rkhunter.dat`, який `rkhunter` використовуватиме з цього моменту як базовий для подальших перевірок.

## Встановлення `rkhunter`

Для `rkhunter` потрібен репозиторій EPEL (Extra Packages for Enterprise Linux). Встановіть цей репозиторій, якщо він у вас ще не встановлений:

```bash
dnf install epel-release
```

Встановіть `rkhunter`:

```bash
dnf install rkhunter
```

## Налаштування `rkhunter`

Єдині параметри конфігурації, які вам _потрібно_ встановити, стосуються надсилання звітів адміністратору.

!!! warning "Важливо"

    Модифікація _будь-якого_ файлу конфігурації в Linux несе ризик. Перш ніж змінювати **будь-який** файл конфігурації в Linux, рекомендується створити резервну копію _оригінального_ файлу.

Щоб змінити файл конфігурації, виконайте:

```bash
vi /etc/rkhunter.conf
```

Знайдіть:

```bash
#MAIL-ON-WARNING=me@mydomain   root@mydomain
```

Видаліть зауваження тут і змініть `me@mydomain.com`, щоб відображати вашу електронну адресу.

Змініть `root@mydomain` на `root@whatever_the_server_name_is`.

Ймовірно, ви також захочете видалити зауваження (і відредагувати рядок відповідно до ваших потреб) із рядка `MAIL-CMD`:

```bash
MAIL_CMD=mail -s "[rkhunter] Warnings found for ${HOST_NAME}"
```

Вам також може знадобитися налаштувати [Postfix Email for Reporting](../../email/postfix_reporting.md), щоб розділ електронної пошти працював правильно.

## Запуск `rkhunter`

Запустіть `rkhunter` вручну, ввівши його в командному рядку. Завдання cron піклується про автоматичний запуск `rkhunter` у `/etc/cron.daily`. Якщо ви хочете автоматизувати процедуру за іншим розкладом, перегляньте [Посібник із автоматизації завдань cron](../../automation/cron_jobs_howto.md).

Вам також потрібно буде перемістити сценарій кудись, крім `/etc/cron.daily/`, наприклад `/usr/local/sbin/`, і викликати його з вашого спеціального cron робота. Найпростіший спосіб — залишити стандартні налаштування `cron.daily` без змін.

Якщо ви хочете перевірити `rkhunter` перед початком роботи, включаючи всі функції електронної пошти, запустіть `rkhunter --check` з командного рядка. Якщо встановлено та функціонує належним чином, ви маєте отримати подібний до наступного результату:

```bash
[root@sol admin]# rkhunter --check
[Rootkit Hunter version 1.4.6]

Checking system commands...

Performing 'strings' command checks
- Checking 'strings' command                               [OK]

Performing 'shared libraries' checks
- Checking for preloading variables                        [None found]
- Checking for preloaded libraries                         [None found]
- Checking LD_LIBRARY_PATH variable                        [Not found]

Performing file properties checks
- Checking for prerequisites                               [Warning]
- /usr/bin/awk                                             [OK]
- /usr/bin/basename                                        [OK]
- /usr/bin/bash                                            [OK]
- /usr/bin/cat                                             [OK]
- /usr/bin/chattr                                          [OK]
- /usr/bin/chmod                                           [OK]
- /usr/bin/chown                                           [OK]
- /usr/bin/cp                                              [OK]
- /usr/bin/curl                                            [OK]
- /usr/bin/cut                                             [OK]
- /usr/bin/date                                            [OK]
- /usr/bin/df                                              [OK]
- /usr/bin/diff                                            [OK]
- /usr/bin/dirname                                         [OK]
- /usr/bin/dmesg                                           [OK]
- /usr/bin/du                                              [OK]
- /usr/bin/echo                                            [OK]
- /usr/bin/ed                                              [OK]
- /usr/bin/egrep                                           [Warning]
- /usr/bin/env                                             [OK]
- /usr/bin/fgrep                                           [Warning]
- /usr/bin/file                                            [OK]
- /usr/bin/find                                            [OK]
- /usr/bin/GET                                             [OK]
- /usr/bin/grep                                            [OK]
- /usr/bin/groups                                          [OK]
- /usr/bin/head                                            [OK]
- /usr/bin/id                                              [OK]
- /usr/bin/ipcs                                            [OK]
- /usr/bin/kill                                            [OK]
- /usr/bin/killall                                         [OK]
- /usr/bin/last                                            [OK]
- /usr/bin/lastlog                                         [OK]
- /usr/bin/ldd                                             [OK]
- /usr/bin/less                                            [OK]
- /usr/bin/locate                                          [OK]
- /usr/bin/logger                                          [OK]
- /usr/bin/login                                           [OK]
- /usr/bin/ls                                              [OK]
- /usr/bin/lsattr                                          [OK]
- /usr/bin/lsof                                            [OK]
- /usr/bin/mail                                            [OK]
- /usr/bin/md5sum                                          [OK]
- /usr/bin/mktemp                                          [OK]
- /usr/bin/more                                            [OK]
- /usr/bin/mount                                           [OK]
- /usr/bin/mv                                              [OK]
- /usr/bin/netstat                                         [OK]
- /usr/bin/newgrp                                          [OK]
- /usr/bin/passwd                                          [OK]
- /usr/bin/perl                                            [OK]
- /usr/bin/pgrep                                           [OK]
- /usr/bin/ping                                            [OK]
- /usr/bin/pkill                                           [OK]
- /usr/bin/ps                                              [OK]
- /usr/bin/pstree                                          [OK]
- /usr/bin/pwd                                             [OK]
- /usr/bin/readlink                                        [OK]
- /usr/bin/rkhunter                                        [OK]
- /usr/bin/rpm                                             [OK]
- /usr/bin/runcon                                          [OK]
- /usr/bin/sed                                             [OK]
- /usr/bin/sestatus                                        [OK]
- /usr/bin/sh                                              [OK]
- /usr/bin/sha1sum                                         [OK]
- /usr/bin/sha224sum                                       [OK]
- /usr/bin/sha256sum                                       [OK]
- /usr/bin/sha384sum                                       [OK]
- /usr/bin/sha512sum                                       [OK]
- /usr/bin/size                                            [OK]
- /usr/bin/sort                                            [OK]
- /usr/bin/ssh                                             [OK]
- /usr/bin/stat                                            [OK]
- /usr/bin/strace                                          [OK]
- /usr/bin/strings                                         [OK]
- /usr/bin/su                                              [OK]
- /usr/bin/sudo                                            [OK]
- /usr/bin/tail                                            [OK]
- /usr/bin/test                                            [OK]
- /usr/bin/top                                             [OK]
- /usr/bin/touch                                           [OK]
- /usr/bin/tr                                              [OK]
- /usr/bin/uname                                           [OK]
- /usr/bin/uniq                                            [OK]
- /usr/bin/users                                           [OK]
- /usr/bin/vmstat                                          [OK]
- /usr/bin/w                                               [OK]
- /usr/bin/watch                                           [OK]
- /usr/bin/wc                                              [OK]
- /usr/bin/wget                                            [OK]
- /usr/bin/whatis                                          [OK]
- /usr/bin/whereis                                         [OK]
- /usr/bin/which                                           [OK]
- /usr/bin/who                                             [OK]
- /usr/bin/whoami                                          [OK]
- /usr/bin/numfmt                                          [OK]
- /usr/bin/gawk                                            [OK]
- /usr/bin/s-nail                                          [OK]
- /usr/bin/whatis.man-db                                   [OK]
- /usr/bin/kmod                                            [OK]
- /usr/bin/systemctl                                       [OK]
- /usr/sbin/adduser                                        [OK]
- /usr/sbin/chroot                                         [OK]
- /usr/sbin/depmod                                         [OK]
- /usr/sbin/fsck                                           [OK]
- /usr/sbin/fuser                                          [OK]
- /usr/sbin/groupadd                                       [OK]
- /usr/sbin/groupdel                                       [OK]
- /usr/sbin/groupmod                                       [OK]
- /usr/sbin/grpck                                          [OK]
- /usr/sbin/ifconfig                                       [OK]
- /usr/sbin/init                                           [OK]
- /usr/sbin/insmod                                         [OK]
- /usr/sbin/ip                                             [OK]
- /usr/sbin/lsmod                                          [OK]
- /usr/sbin/modinfo                                        [OK]
- /usr/sbin/modprobe                                       [OK]
- /usr/sbin/nologin                                        [OK]
- /usr/sbin/ping                                           [OK]
- /usr/sbin/pwck                                           [OK]
- /usr/sbin/rmmod                                          [OK]
- /usr/sbin/route                                          [OK]
- /usr/sbin/rsyslogd                                       [OK]
- /usr/sbin/runlevel                                       [OK]
- /usr/sbin/sestatus                                       [OK]
- /usr/sbin/sshd                                           [OK]
- /usr/sbin/sulogin                                        [OK]
- /usr/sbin/sysctl                                         [OK]
- /usr/sbin/useradd                                        [OK]
- /usr/sbin/userdel                                        [OK]
- /usr/sbin/usermod                                        [OK]
- /usr/sbin/vipw                                           [OK]
- /usr/libexec/gawk                                        [OK]
- /usr/lib/systemd/systemd                                 [OK]

[Press <ENTER> to continue]
```

Відкладіть виконання решти кроків, якщо виникають проблеми з налаштуванням електронної пошти. Коли підтвердження електронної пошти працює, але перед тим, як дозволити `rkhunter` запускатися автоматично, знову запустіть команду вручну з прапорцем «--propupd», щоб створити файл `rkhunter.dat`. Це забезпечує розпізнавання вашого середовища та конфігурації:

```bash
rkhunter --propupd
```

## Висновок

`rkhunter` є частиною надійної серверної стратегії, яка може допомогти контролювати файлову систему та повідомляти про будь-які проблеми адміністратору. Можливо, це один із найпростіших інструментів захисту, який можна встановити, налаштувати та запустити.
