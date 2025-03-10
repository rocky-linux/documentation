---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - лабораторна вправа
---

# Лабораторна робота 6: Створення конфігурації та ключа шифрування даних

!!! info

    Це гілка розгалуження від оригінальної ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), Келсі Хайтауера (GitHub: kelseyhightower). На відміну від оригіналу, який базується на дистрибутивах, подібних до Debian, для архітектури ARM64, ця гілка націлена на дистрибутиви Enterprise Linux, такі як Rocky Linux, який працює на архітектурі x86_64.

Kubernetes зберігає різні дані, включаючи стан кластера, конфігурації програм і секрети. Kubernetes дозволяє [шифрувати](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data) дані кластера в стані спокою.

У цій лабораторній роботі ви згенеруєте ключ шифрування та [конфігурацію шифрування](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/#understanding-the-encryption-at-rest-configuration), придатну для шифрування секретів Kubernetes.

## Ключ шифрування

Згенеруйте ключ шифрування:

```bash
export ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
```

## Файл конфігурації шифрування

Створіть файл конфігурації шифрування `encryption-config.yaml`:

```bash
envsubst < configs/encryption-config.yaml \
  > encryption-config.yaml
```

Скопіюйте файл конфігурації шифрування `encryption-config.yaml` до кожного екземпляра контролера:

```bash
scp encryption-config.yaml root@server:~/
```

Далі: [Завантаження кластера etcd](lab7-bootstrapping-etcd.md)
