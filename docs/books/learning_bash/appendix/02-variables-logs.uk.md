---
title: Змінні - використання з журналами
author: Steven Spencer
contributors: Antoine Le Morvan
tested with: 8.5
tags:
  - сценарій bash
  - bash
  - приклад змінних
---

# Використання змінних – практичне застосування з журналами

## Вступ

У другому уроці «Bash — використання змінних» ви побачили кілька способів використання змінних і дізналися багато нового про те, для чого можна використовувати змінні. Це лише один практичний приклад використання змінних у сценаріях bash.

## Інформація

Коли системному адміністратору доводиться мати справу з файлами журналів, іноді в гру вступають різні формати. Скажімо, ви хочете отримати певну інформацію з `dnf.log` (`/var/log/dnf.log`). Давайте швидко поглянемо на те, як виглядає цей файл журналу за допомогою `tail /var/log/dnf.log`:


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

Тут ми бачимо, що два файли журналу, `dnf.log` і `messages`, відображають дату абсолютно різними способами. Якби ми хотіли отримати інформацію з журналу `messages` у сценарії bash за допомогою `date`, ми могли б зробити це без особливих проблем, але отримати ту саму інформацію з ` dnf.log` потребує певних зусиль. Скажімо, як системному адміністратору вам потрібно щодня переглядати `dnf.log`, щоб переконатися, що в систему не було внесено нічого, про що ви не знали або могло б спричинити проблеми. Ви хочете, щоб ця інформація отримувалася з файлу `dnf.log` за датою та надсилалася вам електронною поштою щодня. Ви будете використовувати завдання `cron`, щоб автоматизувати це, але спочатку нам потрібно отримати сценарій, який буде робити те, що ми хочемо.

## Сценарій

Щоб виконати те, що ми хочемо, ми збираємося використати змінну в нашому сценарії під назвою «today», яка форматуватиме дату відповідно до дати, що відображається в `dnf.log`.  Щоб отримати правильний формат `дати`, ми використовуємо `+%F`, що дасть нам потрібний формат рррр-мм-дд. Оскільки нас цікавить тільки день, а не час чи будь-яка інша інформація, це все, що нам знадобиться, щоб отримати правильну інформацію з `dnf.log`. Спробуйте лише таку частину сценарію:

```
#!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
echo $today
```

Тут ми використовуємо команду `echo`, щоб перевірити, чи вдалося нам форматувати дату. Коли ви запускаєте сценарій, ви маєте отримати результат із сьогоднішньою датою, яка виглядає приблизно так:

```
2022-05-04
```

Якщо так, то чудово, ми можемо видалити наш рядок «debug» і продовжити. Давайте додамо іншу змінну під назвою «logfile», яку ми встановимо як `/var/log/dnf.log`, а потім подивимося, чи зможемо ми `grep` це за допомогою нашої змінної «today». Наразі давайте просто запустимо стандартний вихід:

```
!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
logfile=/var/log/dnf.log

/bin/grep $today $logfile
```

У `dnf.log` щодня міститься багато інформації, тому ми не виводимо її на екран, але ви маєте побачити вихідні дані, які містять лише поточні дані. Спробуйте сценарій, і якщо він спрацює, ми зможемо перейти до наступного кроку. Після того, як ми перевірили вихідні дані, наступним кроком є те, що ми хочемо виконати перенаправлення каналу, щоб надіслати інформацію електронною поштою.

!!! Підказка

    Щоб виконати наступний крок, вам потрібно встановити `mailx` і поштову службу, наприклад `postfix`. Існує також певна конфігурація, яка *ймовірно* знадобиться для отримання електронної пошти з вашого сервера на електронну адресу вашої компанії. Не турбуйтеся про ці кроки на даний момент, оскільки ви можете перевірити `maillog`, щоб побачити, чи була зроблена спроба, а потім працювати звідти, щоб отримати електронну пошту з вашого сервера на вашу електронну адресу. Цей документ не стосується цього. Наразі зробіть:

    ```
    dnf install mailx postfix
    systemctl enable --now postfix
    ```

```
#!/usr/bin/env bash
# script to grab dnf.log data and send it to administrator daily

today=`date +%F`
logfile=/var/log/dnf.log

/bin/grep $today $logfile | /bin/mail -s "DNF logfile data for $today" systemadministrator@domain.ext
```

Давайте подивимося на доповнення до сценарію тут. Ми додали pipe `|` для перенаправлення виводу на `/bin/mail`, встановили тему електронного листа (`-s`) із тим, що в подвійні лапки та встановіть одержувачем "systemadministrator@domain.ext". Замініть цей останній біт своєю адресою електронної пошти, а потім спробуйте знову запустити сценарій.

Як зазначалося, ви, ймовірно, не отримаєте електронний лист без деяких змін у налаштуваннях пошти Postfix, але ви повинні побачити спробу в `/var/log/maillog`.

## Наступні кроки

Наступне, що вам потрібно зробити, це налаштувати надсилання електронної пошти з вашого сервера. Ви можете переглянути [Postfix для звітування](../../../guides/email/postfix_reporting.md), щоб почати роботу з цього. Нам також потрібно автоматизувати цей сценарій для щоденного виконання, для цього ми використаємо `cron`. Тут є кілька посилань: [cron](../../../guides/automation/cron_jobs_howto.md), [anacron](../../../guides /automation/anacron.md) і [cronie](../../../guides/automation/cronie.md). Щоб дізнатися більше про форматування дати, перегляньте `man date` або [це посилання](https://man7.org/linux/man-pages/man1/date.1.html).
