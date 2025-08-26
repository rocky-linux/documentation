---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - лабораторна вправа
---

# Лабораторна робота 7: Завантаження кластера `etcd`

!!! info

    Це гілка розгалуження від оригінальної ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), Келсі Хайтауера (GitHub: kelseyhightower). На відміну від оригіналу, який базується на дистрибутивах, подібних до Debian, для архітектури ARM64, ця гілка націлена на дистрибутиви Enterprise Linux, такі як Rocky Linux, який працює на архітектурі x86_64.

Компоненти Kubernetes не мають стану та зберігають стан кластера в [etcd](https://github.com/etcd-io/etcd). У цій лабораторній роботі ви завантажите тривузловий кластер `etcd` і налаштуєте його для високої доступності та безпечного віддаленого доступу.

## Передумови

Скопіюйте двійкові файли `etcd` і файли модуля `systemd` до примірника `server`:

```bash
scp \
  downloads/etcd-v3.4.36-linux-amd64.tar.gz \
  units/etcd.service \
  root@server:~/
```

Виконайте команди в наступних розділах цієї лабораторної роботи на машині `server`. Увійдіть на машину `server` за допомогою команди `ssh`. Приклад:

```bash
ssh root@server
```

## Завантаження кластера etcd

### Встановіть бінарні файли etcd

Якщо у вас його ще не встановлено, спочатку встановіть утиліту `tar` з `dnf`. Потім розпакуйте та встановіть сервер `etcd` і утиліту командного рядка `etcdctl`:

```bash
  dnf -y install tar
  tar -xvf etcd-v3.4.36-linux-amd64.tar.gz
  mv etcd-v3.4.36-linux-amd64/etcd* /usr/local/bin/
```

### Налаштуйте сервер etcd

```bash
  mkdir -p /etc/etcd /var/lib/etcd
  chmod 700 /var/lib/etcd
  cp ca.crt kube-api-server.key kube-api-server.crt \
    /etc/etcd/
```

Кожен член `etcd` повинен мати унікальне ім’я в кластері `etcd`. Встановіть назву `etcd` так, щоб вона збігалася з назвою хоста поточного екземпляра обчислення:

Створіть файл блоку `etcd.service` `systemd`:

```bash
mv etcd.service /etc/systemd/system/
chmod 644 /etc/systemd/system/etcd.service
```

!!! Note "Примітка"

    ```
    Хоча це вважається поганою формою безпеки, вам, можливо, доведеться тимчасово або назавжди вимкнути SELinux, якщо у вас виникнуть проблеми із запуском служби `etcd` `systemd`. Правильним виправленням є дослідження та створення необхідних файлів політики за допомогою таких інструментів, як `ausearch`, `audit2allow` та інших.  
    
    Команди усувають SELinux і вимикають його, виконавши наступне:
    ```

  ```bash
  sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
  setenforce 0
  ```

### Запустіть сервер `etcd`

```bash
  systemctl daemon-reload
  systemctl enable etcd
  systemctl start etcd
```

## Верифікація

Перелічіть членів кластера `etcd`:

```bash
etcdctl member list
```

```text
6702b0a34e2cfd39, started, controller, http://127.0.0.1:2380, http://127.0.0.1:2379, false
```

Далі: [Завантаження площини керування Kubernetes](lab8-bootstrapping-kubernetes-controllers.md)
