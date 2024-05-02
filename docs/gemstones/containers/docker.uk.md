---
title: Docker - Інсталяція
author: wale soyinka
contributors: neelchauhan, nishaaaaaant, sastorsl
date: 2021-08-04
tags:
  - docker
---

# Вступ

Механізм Docker можна використовувати для виконання робочих навантажень контейнерів у стилі Docker на серверах Rocky Linux. Іноді це краще, ніж запустити повне середовище Docker Desktop.

## Додавання docker репозиторію

Використовуйте утиліту `dnf`, щоб додати репозиторій Docker до вашого сервера Rocky Linux. Впишіть:

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## Встановлення необхідних пакетів

Установіть останню версію Docker Engine, `container` і Docker Compose, виконавши:

```bash
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Запустіть і ввімкніть Docker (`dockerd`)

Використовуйте `systemctl`, щоб налаштувати Docker на автоматичний запуск після перезавантаження та одночасного запуску зараз. Впишіть:

```bash
sudo systemctl --now enable docker
```

## Необов’язково можна дозволити не-root користувачеві керувати докером

Додайте користувача без root до групи `docker`, щоб користувач міг керувати `docker` без `sudo`.

Це необов’язковий крок, але він може бути зручним, якщо ви є основним користувачем системи або якщо ви хочете дозволити кільком користувачам керувати докером, але не хочете надавати їм дозволи `sudo`.

Впишіть:

```bash
# Add the current user
sudo usermod -a -G docker $(whoami)

# Add a specific user
sudo usermod -a -G docker custom-user
```

Щоб призначити нову групу, потрібно вийти та знову увійти. Перевірте за допомогою команди `id`, щоб переконатися, що групу додано.

### Примітки

```docker
docker-ce: цей пакет надає основну технологію для створення та запуску docker контейнерів (dockerd)
docker-ce-cli: надає інтерфейс командного рядка (CLI) клієнтський інструмент докера (докер)
containerd.io: забезпечує середовище виконання контейнера (runc)
docker-compose-plugin: плагін, який надає підкоманду «docker compose». 
```
