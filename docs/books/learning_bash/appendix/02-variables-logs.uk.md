---
title: Змінні - використання з журналами
author: Steven Spencer
contributors: Antoine Le Morvan, Ganna Zhyrnova
tested_with: 8.5
tags:
  - сценарій bash
  - bash
  - приклад змінних
---

# Використання змінних – практичне застосування з журналами

## Вступ

У другому уроці «Bash — використання змінних» ви побачили кілька способів використання змінних і дізналися багато нового про те, для чого можна використовувати змінні. Це лише один практичний приклад використання змінних у сценаріях bash.

## Інформація

Коли системному адміністратору доводиться мати справу з файлами журналів, іноді в гру вступають різні формати. Припустимо, що ви хочете отримати певну інформацію з `dnf.log` (`/var/log/dnf.log`). Давайте коротко розглянемо, як виглядає цей файл журналу за допомогою `tail /var/log/dnf.log`:

```
2022-05-04T09:02:18-0400 DEBUG extras: using metadata from Thu 28 Apr 2022 04:25:35 PM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: powertools
2022-05-04T09:02:18-0400 DEBUG powertools: using metadata from Thu 28 Apr 2022 04:25:36 PM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: epel
2022-05-04T09:02:18-0400 DEBUG epel: using metadata from Tue 03 May 2022 11:55:16 AM EDT.
2022-05-04T09:02:18-0400 DEBUG repo: using cache for: epel-modular
2022-05-04T09:02:18-0400 DEBUG epel-modular: using metadata from Sun 17 Apr 2022 07:09:16 PM EDT.
2022-05-04T09:02:18-0400 INFO Last metadata expiration check: 3:07:06 ago on Wed 04 May 2022 05:55:12 AM EDT.
2022-05-04T09:02:18-0400 DDEBUG timer: sack setup: 512 ms
2022-05-04T09:02:18-0400 DDEBUG Cleaning up.
```

Тепер подивіться на файл журналу `messages` `tail /var/log/messages`:

```
May  4 08:47:19 localhost systemd[1]: Starting dnf makecache...
May  4 08:47:19 localhost dnf[108937]: Metadata cache refreshed recently.
May  4 08:47:19 localhost systemd[1]: dnf-makecache.service: Succeeded.
May  4 08:47:19 localhost systemd[1]: Started dnf makecache.
May  4 08:51:59 localhost NetworkManager[981]: <info>  [1651668719.5310] dhcp4 (eno1): state changed extended -> extended, address=192.168.1.141
May  4 08:51:59 localhost dbus-daemon[843]: [system] Activating via systemd: service name='org.freedesktop.nm_dispatcher' unit='dbus-org.freedesktop.nm-dispatcher.service' requested by ':1.10' (uid=0 pid=981 comm="/usr/sbin/NetworkManager --no-daemon " label="system_u:system_r:NetworkManager_t:s0")
May  4 08:51:59 localhost systemd[1]: Starting Network Manager Script Dispatcher Service...
May  4 08:51:59 localhost dbus-daemon[843]: [system] Successfully activated service 'org.freedesktop.nm_dispatcher'
May  4 08:51:59 localhost systemd[1]: Started Network Manager Script Dispatcher Service.
May  4 08:52:09 localhost systemd[1]: NetworkManager-dispatcher.service: Succeeded.
```

І, нарешті, давайте подивимося на результат команди `date`:

```
Wed May  4 09:47:00 EDT 2022
```

## Висновки та цілі

Тут ми бачимо, що два файли журналу, `dnf.log` та `messages`, відображають дату зовсім по-різному. Якби ми хотіли отримати інформацію з журналу `messages` у bash-скрипті за допомогою `date`, ми могли б зробити це без особливих проблем, але отримання тієї ж інформації з `dnf.log` вимагало б певних зусиль. Припустимо, що як системний адміністратор, вам потрібно щодня переглядати файл `dnf.log`, щоб переконатися, що в систему не було внесено нічого, про що ви не знали або що могло б спричинити проблеми. Ви хочете, щоб ця інформація збиралася з файлу `dnf.log` за датою, а потім щодня надсилалася вам електронною поштою. Ви будете використовувати завдання `cron` для автоматизації цього, але спочатку нам потрібно отримати скрипт, який виконуватиме те, що ми хочемо.

## Сценарій

Щоб досягти бажаного результату, ми використовуватимемо змінну в нашому скрипті під назвою "today", яка форматуватиме дату відповідно до дати, що відображається у файлі `dnf.log`.  Щоб отримати правильний формат `date`, ми використовуємо `+%F`, який надасть нам потрібний нам формат yyyy-mm-dd. Оскільки нас цікавить лише день, а не час чи будь-яка інша інформація, це все, що нам потрібно, щоб отримати правильну інформацію з `dnf.log`. Спробуйте лише таку частину сценарію:

```
#!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
echo $today
```

Тут ми використовуємо команду `echo`, щоб перевірити, чи нам вдалося відформатувати дату. Коли ви запускаєте сценарій, ви маєте отримати результат із сьогоднішньою датою, яка виглядає приблизно так:

```
2022-05-04
```

Якщо так, то чудово, ми можемо видалити наш рядок «debug» і продовжити. Додамо ще одну змінну під назвою "logfile", якій ми встановимо значення `/var/log/dnf.log`, а потім подивимося, чи можемо ми отримати її за допомогою `grep`, використовуючи нашу змінну "today". Наразі давайте просто запустимо стандартний вихід:

```
!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
logfile=/var/log/dnf.log

/bin/grep $today $logfile
```

Файл `dnf.log` щодня містить багато інформації, тому ми не будемо виводити її на екран, але ви повинні побачити вивід, який містить лише сьогоднішні дані. Спробуйте сценарій, і якщо він спрацює, ми зможемо перейти до наступного кроку. Після того, як ми перевірили вихідні дані, наступним кроком є те, що ми хочемо виконати перенаправлення каналу, щоб надіслати інформацію електронною поштою.

!!! tip

    Щоб виконати наступний крок, вам потрібно встановити `mailx` і поштову службу, наприклад `postfix`. Існує також певна конфігурація, яка _ймовірно_ знадобиться для отримання електронної пошти з вашого сервера на електронну адресу вашої компанії. Не турбуйтеся про ці кроки на даний момент, оскільки ви можете перевірити `maillog`, щоб побачити, чи була зроблена спроба, а потім працювати звідти, щоб отримати електронну пошту з вашого сервера на вашу електронну адресу. Цей документ не стосується цього. Наразі зробіть:
    
    `     dnf install mailx postfix     systemctl enable --now postfix     `

```
#!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
logfile=/var/log/dnf.log

/bin/grep $today $logfile | /bin/mail -s "DNF logfile data for $today" systemadministrator@domain.ext
```

Давайте подивимося на доповнення до сценарію тут. Ми додали конвеєр `|` для перенаправлення виводу на `/bin/mail`, встановили тему електронного листа (`-s`) у подвійних лапках та встановили одержувача як "systemadministrator@domain.ext". Замініть цей останній біт своєю адресою електронної пошти, а потім спробуйте знову запустити сценарій.

Як зазначалося, ви, ймовірно, не отримаєте електронний лист без деяких змін у налаштуваннях пошти Postfix, але ви повинні побачити спробу в `/var/log/maillog`.

## Наступні кроки

Наступне, що вам потрібно зробити, це налаштувати надсилання електронної пошти з вашого сервера. Ви можете переглянути [Postfix для звітності](../../../guides/email/postfix_reporting.md), щоб розпочати роботу з цього питання. Нам також потрібно автоматизувати цей скрипт для щоденного запуску, для цього ми використовуватимемо `cron`. Тут є кілька посилань: [cron](../../../guides/automation/cron_jobs_howto.md), [anacron](../../../guides/automation/anacron.md) та [cronie](../../../guides/automation/cronie.md). Щоб отримати докладнішу інформацію про форматування дати, перегляньте `man date` або [це посилання](https://man7.org/linux/man-pages/man1/date.1.html).
