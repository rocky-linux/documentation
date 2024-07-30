---
title: Podman
author: Neel Chauhan, Antoine Le Morvan
contributors: Steven Spencer, Ganna Zhyrnova, Christian Steinert
date: 2024-03-07
tags:
  - docker
  - podman
---

## Вступ

!!! note "Примітка"

```
Цей документ представляє розширений вміст із [батьківського документа](../../gemstones/containers/podman.md). Якщо вам потрібна коротка інструкція, цього батьківського документа може бути достатньо. 
```

[Podman](https://podman.io/) (Pod Manager) — це інструмент керування контейнерами та зображеннями, сумісний з [OCI](https://opencontainers.org/) (Ініціатива відкритого контейнера).

Podman:

- працює без демона (може запускати контейнери як службу systemd)
- дозволяє вам керувати контейнерами як непривілейований користувач (не обов’язково бути root)
- включені, на відміну від докерів, у сховища Rocky Linux

Це робить Podman не лише сумісним із докерами альтернативним середовищем виконання контейнерів, але й набагато більше.

## Встановлення Podman

Використовуйте утиліту `dnf` для встановлення Podman:

```bash
dnf install podman
```

Ви можете отримати список доступних підкоманд podman за допомогою наступної команди:

```bash
$ podman --help

Manage pods, containers and images

Usage:
  podman [options] [command]

Available Commands:
  attach      Attach to a running container
  auto-update Auto update containers according to their auto-update policy
...
```

Ось неповний список підкоманд, які найчастіше використовуються:

| Підкоманда  | Опис                                                                      |
| ----------- | ------------------------------------------------------------------------- |
| `build`     | Створює зображення, використовуючи інструкції з Containerfiles            |
| `commit`    | Створює нове зображення на основі зміненого контейнера                    |
| `container` | Керує контейнерами                                                        |
| `cp`        | Копіює файли/папки між контейнером і локальною файловою системою          |
| `create`    | Створює, але не запускає контейнер                                        |
| `exec`      | Запускає процес у запущеному контейнері                                   |
| `image`     | Керує зображеннями                                                        |
| `images`    | Перераховує зображення в локальному сховищі                               |
| `info`      | Відображає інформацію про систему Podman                                  |
| `init`      | Ініціалізує один або кілька контейнерів                                   |
| `inspect`   | Відображає конфігурацію об'єкта, позначеного ID                           |
| `kill`      | Вбиває один або кілька запущених контейнерів за допомогою певного сигналу |
| `login`     | Вхід до реєстру контейнерів                                               |
| `logs`      | Отримує журнали одного або кількох контейнерів                            |
| `network`   | Керує мережами                                                            |
| `pause`     | Призупиняє всі процеси в одному або кількох контейнерах                   |
| `ps`        | Перераховує контейнери                                                    |
| `pull`      | Витягує образ із реєстру                                                  |
| `push`      | Надсилає зображення до вказаного пункту призначення                       |
| `restart`   | Перезапускає один або кілька контейнерів                                  |
| `rm`        | Видаляє один або кілька контейнерів                                       |
| `rmi`       | Вилучає одне або кілька зображень із локального сховища                   |
| `run`       | Виконує команду в новому контейнері                                       |
| `start`     | Запускає один або декілька контейнерів                                    |
| `stats`     | Відображає прямий потік статистики використання ресурсів контейнера       |
| `stop`      | Зупиняє один або декілька контейнерів                                     |
| `system`    | Керує podman                                                              |
| `top`       | Відображає запущені процеси контейнера                                    |
| `unpause`   | Відновлює процеси в одному або кількох контейнерах                        |
| `volume`    | Керує обсягами                                                            |

!!! note "Примітка"

```
Podman може запускати майже будь-яку команду Docker завдяки подібному інтерфейсу CLI.
```

Якщо вам потрібно використовувати файл створення, не забудьте встановити пакет `podman-compose`:

```bash
dnf install podman-compose
```

## Додавання контейнера

Запустіть [Nextcloud](https://nextcloud.com/) автономну хмарну платформу як на прикладі:

```bash
podman run -d -p 8080:80 nextcloud
```

Ви отримаєте підказку вибрати реєстр контейнерів для завантаження. У нашому прикладі ви будете використовувати `docker.io/library/nextcloud:latest`.

Коли ви завантажите образ Nextcloud, він запуститься.

Введіть **ip_address:8080** у своєму веб-браузері (за умови, що ви відкрили порт у `firewalld`) і налаштуйте Nextcloud:

![Nextcloud in container](../../gemstones/images/podman_nextcloud.png)

!!! tip "Підказка"

```
Щоб стежити за виведенням журналу останнього створеного контейнера, використовуйте `podman logs -lf`. `-l` вказує на використання останнього створеного контейнера, тоді як `-f` вказує на відстеження журналів у міру їх створення. Натисніть Ctrl+C, щоб зупинити виведення журналу.
```

## Запуск контейнерів як служб systemd

### Використання `quadlet`

Починаючи з версії 4.4 Podman постачається з [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) – генератором systemd. Його можна використовувати для генерації файлів модулів для безкорінних і кореневих системних служб.

Розмістіть файли Quadlet для кореневих служб у:

- `/etc/containers/systemd/`
- `/usr/share/containers/systemd/`

Розмістіть безкореневі файли в будь-якому з:

- `$XDG_CONFIG_HOME/containers/systemd/` або `~/.config/containers/systemd/`
- `/etc/containers/systemd/users/$(UID)`
- `/etc/containers/systemd/users/`

Окрім окремих контейнерів, підтримуються файли pod, image, network, volume і kube. Давайте зосередимося на нашому прикладі Nextcloud. Створіть новий файл ~/.config/containers/systemd/nextcloud.cotainer із таким вмістом:

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

Podman додатково надає підкоманду `generate systemd`. Використовуйте цю підкоманду для створення службових файлів `systemd`.

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

## Containerfiles

Containerfile — це файл, який використовується Podman для створення зображень контейнерів. Containerfiles використовують той самий синтаксис, що й файли Docker, тож ви можете створювати зображення контейнерів за допомогою Podman так само, як і за допомогою Docker.

### Веб-сервер із Containerfile

Ви створите сервер `http` на основі RockyLinux 9.

Створіть папку, присвячену нашому зображенню:

```bash
mkdir myrocky && cd myrocky
```

Створіть файл `index.html`, який працюватиме на нашому веб-сервері:

```bash
echo "Welcome to Rocky" > index.html
```

Створіть файл `Containerfile` з таким вмістом:

```text
# Use the latest rockylinux image as a start
FROM rockylinux:9

# Make it uptodate
RUN dnf -y update
# Install and enable httpd
RUN dnf -y install httpd
RUN systemctl enable httpd
# Copy the local index.html file into our image
COPY index.html /var/www/html/

# Expose the port 80 to the outside
EXPOSE 80

# Start the services
CMD [ "/sbin/init" ]
```

Ви готові створити наш образ під назвою `myrockywebserver`:

```bash
$ podman build -t myrockywebserver .

STEP 1/7: FROM rockylinux:9
Resolved "rockylinux" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
Trying to pull docker.io/library/rockylinux:9...
Getting image source signatures
Copying blob 489e1be6ce56 skipped: already exists
Copying config b72d2d9150 done
Writing manifest to image destination
STEP 2/7: RUN dnf -y update
Rocky Linux 9 - BaseOS                          406 kB/s | 2.2 MB     00:05    
Rocky Linux 9 - AppStream                       9.9 MB/s | 7.4 MB     00:00    
Rocky Linux 9 - Extras                           35 kB/s |  14 kB     00:00    
Dependencies resolved.
================================================================================
 Package                   Arch      Version                 Repository    Size
================================================================================
Upgrading:
 basesystem                noarch    11-13.el9.0.1           baseos       6.4 k
 binutils                  x86_64    2.35.2-42.el9_3.1       baseos       4.5 M
...
Complete!
--> 2e8b93d30f31
STEP 3/7: RUN dnf -y install httpd
Last metadata expiration check: 0:00:34 ago on Wed Apr  3 07:29:56 2024.
Dependencies resolved.
================================================================================
 Package                Arch       Version                  Repository     Size
================================================================================
Installing:
 httpd                  x86_64     2.4.57-5.el9             appstream      46 k
...
Complete!
--> 71db5cabef1e
STEP 4/7: RUN systemctl enable httpd
Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
--> 423d45a3cb2d
STEP 5/7: COPY index.html /var/www/html/
--> dfaf9236ebae
STEP 6/7: EXPOSE 80
--> 439bc5aee524
STEP 7/7: CMD [ "/sbin/init" ]
COMMIT myrockywebserver
--> 7fcf202d3c8d
Successfully tagged localhost/myrockywebserver:latest
7fcf202d3c8d059837cc4e7bc083a526966874f978cd4ab18690efb0f893d583
```

Ви можете запустити образ Podman і підтвердити, що він запущений:

```bash
$ podman run -d --name rockywebserver -p 8080:80 localhost/myrockywebserver
282c09eecf845c7d9390f6878f9340a802cc2e13d654da197d6c08111905f1bd

$ podman ps
CONTAINER ID  IMAGE                              COMMAND     CREATED         STATUS         PORTS                 NAMES
282c09eecf84  localhost/myrockywebserver:latest  /sbin/init  16 seconds ago  Up 16 seconds  0.0.0.0:8080->80/tcp  rockywebserver
```

Ви запустили образ Podman у режимі демона (`-d`) і назвали його `rockywebserver` (параметр `--name`).

Ви перенаправили порт 80 (захищений) на порт 8080 за допомогою параметра `-p`. Перевірте, чи прослуховує порт:

```bash
ss -tuna | grep "*:8080"
tcp   LISTEN    0      4096                *:8080             *:*
```

Переконайтеся, що файл `index.html` доступний:

```bash
$ curl http://localhost:8080
Welcome to Rocky
```

Вітаємо! Тепер ви можете зупинити та знищити своє запущене зображення, вказавши назву, яку ви вказали під час створення:

```bash
podman stop rockywebserver && podman rm rockywebserver
```

!!! tip "Підказка"

```
Ви можете додати перемикач `--rm`, щоб автоматично видалити контейнер після його зупинки.
```

Якщо ви перезапустите процес збирання, `podman` використовуватиме кеш на кожному кроці збирання:

```bash
$ podman build -t myrockywebserver .

STEP 1/7: FROM rockylinux:9
STEP 2/7: RUN dnf -y update
--> Using cache 2e8b93d30f3104d77827a888fdf1d6350d203af18e16ae528b9ca612b850f844
--> 2e8b93d30f31
STEP 3/7: RUN dnf -y install httpd
--> Using cache 71db5cabef1e033c0d7416bc341848fbf4dfcfa25cd43758a8b264ac0cfcf461
--> 71db5cabef1e
STEP 4/7: RUN systemctl enable httpd
--> Using cache 423d45a3cb2d9f5ef0af474e4f16721f4c84c1b80aa486925a3ae2b563ba3968
--> 423d45a3cb2d
STEP 5/7: COPY index.html /var/www/html/
--> Using cache dfaf9236ebaecf835ecb9049c657723bd9ec37190679dd3532e7d75c0ca80331
--> dfaf9236ebae
STEP 6/7: EXPOSE 80
--> Using cache 439bc5aee524338a416ae5080afbbea258a3c5e5cd910b2485559b4a908f81a3
--> 439bc5aee524
STEP 7/7: CMD [ "/sbin/init" ]
--> Using cache 7fcf202d3c8d059837cc4e7bc083a526966874f978cd4ab18690efb0f893d583
COMMIT myrockywebserver
--> 7fcf202d3c8d
Successfully tagged localhost/myrockywebserver:latest
7fcf202d3c8d059837cc4e7bc083a526966874f978cd4ab18690efb0f893d583
```

Ви можете очистити цей кеш за допомогою підкоманди `prune`:

```bash
podman system prune -a -f
```

| Опції       | Опис                                                              |
| ----------- | ----------------------------------------------------------------- |
| `-a`        | Видаляє всі невикористовувані дані, а не лише зовнішні для Podman |
| `-f`        | Немає запиту на підтвердження                                     |
| `--volumes` | Prune volumes                                                     |

## Pods

Pods — це спосіб групувати контейнери разом. Контейнери в модулі мають спільні параметри, наприклад монтування, розподіл ресурсів або зіставлення портів.

У Podman ви керуєте контейнерами за допомогою підкоманди `podman pod`, подібної до багатьох команд Podman:

| Команда | Опис                                                                                                                   |
| ------- | ---------------------------------------------------------------------------------------------------------------------- |
| clone   | Створює копію існуючого модуля.                                                                        |
| create  | Створює новий пакет.                                                                                   |
| exists  | Перевіряє наявність пакета в локальному сховищі.                                                       |
| inspect | Відображає інформацію, що описує контейнер.                                                            |
| kill    | Вбиває основний процес кожного контейнера в одному або кількох контейнерах.                            |
| logs    | Відображає журнали для модуля з одним або кількома контейнерами.                                       |
| pause   | Призупиняє один або кілька модулів.                                                                    |
| prune   | Видаляє всі зупинені стручки та їхні контейнери.                                                       |
| ps      | Роздруковує інформацію про pods.                                                                       |
| restart | Перезапускає один або кілька модулів.                                                                  |
| rm      | Видаляє одну або кілька зупинених коробок і контейнерів.                                               |
| start   | Запускає один або кілька контейнерів.                                                                  |
| stats   | Відображає прямий потік статистики використання ресурсів для контейнерів в одному або кількох пакетах. |
| stop    | Зупиняє один або кілька контейнерів.                                                                   |
| top     | Відображає запущені процеси контейнерів у модулі.                                                      |
| unpause | Відновлює паузу одного або кількох модулів.                                                            |

Контейнери, згруповані в pod, можуть отримувати доступ один до одного за допомогою localhost. Це корисно, наприклад, під час налаштування Nextcloud із спеціальною базою даних, наприклад Postgres. Nextcloud може отримати доступ до бази даних, але база даних не обов’язково має бути доступна поза контейнерами.

Щоб створити пакет, що містить Nextcloud і виділену базу даних, виконайте наступне:

```bash
# Create the pod with a port mapping
podman pod create --name nextcloud -p 8080:80

# Add a Nextcloud container to the pod – the port mapping must not be specified again!
podman create --pod nextcloud --name nextcloud-app nextcloud

# Add a Postgres database. This container has a postgres specific environment variable set.
podman create --pod nextcloud --name nextcloud-db -e POSTGRES_HOST_AUTH_METHOD=trust postgres
```

Щоб запустити щойно створений модуль, виконайте:

```bash
podman pod start nextcloud
```

Тепер ви можете налаштувати Nextcloud за допомогою локальної бази даних:

![Nextcloud setting up a database](img/podman_nextcloud_db_setup.png)
