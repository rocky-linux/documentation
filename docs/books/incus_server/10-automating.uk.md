---
title: 10 Автоматизація Snapshots
author: Steven Spencer
contributors: Ezequiel Bruni, Ganna Zhyrnova
tested_with: 9.4
tags:
  - incus
  - enterprise
  - автоматизація incus
---

У цьому розділі ви повинні бути адміністратором або вміти `sudo`, щоб стати адміністратором.

Автоматизація процесу створення знімків значно полегшує роботу.

## Автоматизація snapshot процесу

Виконайте цей процес на incus-primary. Перше, що вам потрібно зробити, це створити сценарій, який запускатиметься cron у /usr/local/sbin під назвою "refresh-containers":

```bash
sudo vi /usr/local/sbin/refreshcontainers.sh
```

Сценарій досить мінімальний:

```bash
#!/bin/bash
# This script is for doing an lxc copy --refresh against each container, copying
# and updating them to the snapshot server.

for x in $(/var/lib/snapd/snap/bin/lxc ls -c n --format csv)
        do echo "Refreshing $x"
        /var/lib/snapd/snap/bin/lxc copy --refresh $x incus-snapshot:$x
        done

```

Зробіть його виконуваним:

```bash
sudo chmod +x /usr/local/sbin/refreshcontainers.sh
```

Змініть право власності на цей сценарій на свого користувача та групу incusadmin:

```bash
sudo chown incusadmin.incusadmin /usr/local/sbin/refreshcontainers.sh
```

Налаштуйте crontab для користувача incusadmin, щоб запустити цей сценарій, у цьому випадку о 22:00:

```bash
crontab -e
```

Ваш запис виглядатиме так:

```bash
00 22 * * * /usr/local/sbin/refreshcontainers.sh > /home/incusadmin/refreshlog 2>&1
```

Збережіть зміни та вийдіть.

Це створить журнал у домашньому каталозі incusadmin під назвою «refreshlog», який дасть вам інформацію про те, чи спрацював ваш процес, чи ні. Дуже важливо!

Автоматизована процедура іноді дає збій. Зазвичай це трапляється, коли не вдається оновити певний контейнер. Ви можете вручну повторно запустити оновлення за допомогою такої команди (припускаючи, що rockylinux-test-9 тут є нашим контейнером):

```bash
lxc copy --refresh rockylinux-test-9 incus-snapshot:rockylinux-test-9
```
