---
title: Docker - Інсталяція
author: wale soyinka
contributors:
date: 2021-08-04
tags:
  - docker
---

# Вступ

Механізм Docker можна використовувати для виконання робочих навантажень контейнерів у стилі Docker на серверах Rocky Linux. Іноді це краще, ніж запустити повне середовище Docker Desktop.

## Додавання docker репозиторію

Використовуйте утиліту `dnf`, щоб додати docker репозиторій до вашого сервера Rocky Linux. Впишіть:

```
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## Встановлення необхідних пакетів

Встановіть останню версію Docker Engine, containerd та Docker Compose, виконавши:

```
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

## Запуск і включення служби systemd docker (dockerd)

Використовуйте утиліту `systemctl`, щоб налаштувати демон dockerd на автоматичний запуск під час наступного перезавантаження системи та одночасного запуску для поточного сеансу. Впишіть:

```
sudo systemctl --now enable docker
```


### Примітки

```
docker-ce: цей пакет надає основну технологію для створення та запуску docker контейнерів (dockerd)
docker-ce-cli: надає інтерфейс командного рядка (CLI) клієнтський інструмент докера (докер)
containerd.io: забезпечує середовище виконання контейнера (runc)
docker-compose-plugin: плагін, який надає підкоманду «docker compose». 

```



