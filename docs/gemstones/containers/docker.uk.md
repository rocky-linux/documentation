---
title: Docker - Інсталяція
author: Wale Soyinka
contributors: Neel Chauhan, Srinivas Nishant Viswanadha, Stein Arne Storslett, Ganna Zhyrnova, Steven Spencer
date: 2021-08-04
tags:
  - docker
---

# Вступ

Механізм Docker можна використовувати для виконання робочих навантажень контейнерів у стилі Docker на серверах Rocky Linux. Іноді це краще, ніж запустити повне середовище Docker Desktop.

## Додавання docker репозиторію

Використайте утиліту `dnf`, щоб додати репозиторій Docker до вашого сервера Rocky Linux. Впишіть:

```bash
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
```

## Встановлення необхідних пакетів

Установіть останню версію Docker Engine, `container` і Docker Compose, виконавши:

```bash
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Запустіть і ввімкніть Docker (`dockerd`)

Використовуйте `systemctl` для налаштування Docker на автоматичний запуск після перезавантаження та одночасного запуску зараз. Впишіть:

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

Щоб призначити нову групу, потрібно вийти та знову увійти. Перевірте за допомогою команди `id`, чи групу додано.

### Примітки

```docker
docker-ce               : Цей пакунок надає базову технологію для створення та запуску контейнерів докерів (dockerd) 
docker-ce-cli           : Надає інтерфейс командного рядка (CLI) клієнтський інструмент докера (докер)
containerd.io           : Забезпечує середовище виконання контейнера (runc)
docker-buildx-plugin    : Плагін Docker Buildx для Docker CLI
docker-compose-plugin   : Плагін, який надає підкоманду 'docker compose' 
```
