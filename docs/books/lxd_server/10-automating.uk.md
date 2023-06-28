---
title: 10 Автоматизація Snapshots
author: Steven Spencer
contributors: Ezequiel Bruni
tested_with: 8.8, 9.2
tags:
  - lxd
  - enterprise
  - автоматизація lxd
---

# Розділ 10: автоматизація snapshots

У цьому розділі вам потрібно мати права root або вміти викорисовувати `sudo`, щоб стати root.

Автоматизація процесу створення знімків значно полегшує роботу.

## Автоматизація snapshot процесу


Виконайте цей процес на lxd-primary. Перше, що вам потрібно зробити, це створити сценарій, який запускатиметься cron у /usr/local/sbin під назвою "refresh-containers":

```
sudo vi /usr/local/sbin/refreshcontainers.sh
```

Сценарій досить мінімальний:

```
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x lxd-snapshot:$x
        done

```

 Зробіть його виконуваним:

```
sudo chmod +x /usr/local/sbin/refreshcontainers.sh
```

Змініть право власності на цей сценарій на свого користувача та групу lxdadmin:

```
sudo chown lxdadmin.lxdadmin /usr/local/sbin/refreshcontainers.sh
```

Налаштуйте crontab для користувача lxdadmin, щоб запустити цей сценарій, у цьому випадку о 22:00:

```
crontab -e
```

Ваш запис виглядатиме так:

```
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/lxdadmin/refreshlog 2>&1
```

Збережіть зміни та вийдіть.

Це створить журнал у домашньому каталозі lxdadmin під назвою «refreshlog», який дасть вам інформацію про те, чи працював ваш процес, чи ні. Дуже важливо!

Автоматизована процедура іноді дає збій. Зазвичай це трапляється, коли не вдається оновити певний контейнер. Ви можете вручну повторно запустити оновлення за допомогою такої команди (припускаючи, що rockylinux-test-9 тут є нашим контейнером):

```
lxc copy --refresh rockylinux-test-9 lxd-snapshot:rockylinux-test-9
```
