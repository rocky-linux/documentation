---
title: Podman
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova
date: 2024-03-07
tags:
  - docker
  - podman
---

# Вступ

[Podman](https://podman.io/) — це альтернативне середовище виконання контейнерів, сумісне з Docker, яке, на відміну від Docker, включено до репозиторіїв Rocky Linux і може запускати контейнери як службу systemd.

## Встановлення Podman

Використовуйте утиліту `dnf` для встановлення Podman:

```bash
dnf install podman
```

## Додавання контейнера

Запустимо для прикладу автономну хмарну платформу [Nextcloud](https://nextcloud.com/):

```bash
podman run -d -p 8080:80 nextcloud
```

Ви отримаєте підказку вибрати реєстр контейнерів для завантаження. У нашому прикладі ми будемо використовувати `docker.io/library/nextcloud:latest`

Щойно ви завантажите контейнер Nextcloud, він запуститься.

Введіть **ip_address:8080** у своєму веб-браузері (за умови, що ви відкрили порт у `firewalld`) і налаштуйте Nextcloud:

![Nextcloud in container](../images/podman_nextcloud.png)

## Запуск контейнерів як служб systemd

Як згадувалося, ви можете запускати контейнери Podman як служби `systemd`. Давайте тепер зробимо це за допомогою Nextcloud. Запустіть:

```bash
podman ps
```

Ви отримаєте список запущених контейнерів:

```bash
04f7553f431a  docker.io/library/nextcloud:latest  apache2-foregroun...  5 minutes ago  Up 5 minutes  0.0.0.0:8080->80/tcp  compassionate_meninsky
```

Як видно вище, ім’я нашого контейнера – `compassionate_meninsky`.

Щоб створити контейнер `systemd` і ввімкнути його під час перезавантаження, виконайте наступне:

```bash
podman generate systemd --name compassionate_meninsky > /usr/lib/systemd/system/nextcloud.service
systemctl enable nextcloud
```

Замініть `compassionate_meninsky` на назву вашого контейнера.

Коли ваша система перезавантажиться, Nextcloud перезапуститься в Podman.
