---
title: Podman
author: Neel Chauhan
contributors: Steven Spencer, Ganna Zhyrnova, Christian Steinert
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

### Використання `quadlet`

Починаючи з версії 4.4, Podman постачається з [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html), генератором systemd, який може генерувати файли модулів rootless та rootful systemd.

Можна розміщувати файли квадлетів для кореневих служб в

- `/etc/containers/systemd/`
- `/usr/share/containers/systemd/`

тоді як безкореневі файли можна розмістити в будь-якому з

- `$XDG_CONFIG_HOME/containers/systemd/` або `~/.config/containers/systemd/`
- `/etc/containers/systemd/users/$(UID)`
- `/etc/containers/systemd/users/`

Хоча окремі контейнери, модулі, зображення, мережі, томи та файли kube підтримуються, давайте зосередимося на нашому прикладі Nextcloud. Створіть новий файл ~/.config/containers/systemd/nextcloud.cotainer із таким вмістом:

```systemd
[Container]
Image=nextcloud
PublishPort=8080:80
```

Доступно [багато інших варіантів](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#container-units-container).

Щоб запустити генератор і повідомити systemd про запуск нової служби:

```bash
systemctl --user daemon-reload
```

Щоб запустити службу, виконайте такі дії:

```bash
systemctl --user start nextcloud.service
```

!!! note "Примітка"

```
Якщо ви створили файл в одному з каталогів для кореневих служб, опустіть позначку `--user`.
```

Щоб автоматично запускати контейнер після запуску системи або входу користувача, ви можете додати ще один розділ до свого файлу `nextcloud.container`:

```systemd
[Install]
WantedBy=default.target
```

Потім знову запустіть генератор і ввімкніть службу:

```bash
systemctl --user daemon-reload;
systemctl --user enable nextcloud.service;
```

Підтримуються інші типи файлів: pod, том, мережа, зображення та kube. [Pods](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#pod-units-pod), наприклад, можна використовувати для групування контейнерів – згенерованого systemd служби та їхні залежності (створити pod перед контейнерами) автоматично керуються systemd.

### Використання `podman generate systemd`

Podman додатково надає підкоманду `generate systemd`. Його можна використовувати для створення службових файлів `systemd`.

!!! warning "Важливо"

```
`generate systemd` не підтримується і не матиме подальших функцій. Рекомендовано використовувати Quadlet.
```

Давайте тепер зробимо це за допомогою Nextcloud. Запустіть:

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
