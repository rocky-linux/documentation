---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - лабораторна вправа
  - kubectl
  - etcd
  - runc
---

# Лабораторна робота 8: Запуск Kubernetes Control Plane

!!! info

    Це гілка розгалуження від оригінальної ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), Келсі Хайтауера (GitHub: kelseyhightower). На відміну від оригіналу, який базується на дистрибутивах, подібних до Debian, для архітектури ARM64, ця гілка націлена на дистрибутиви Enterprise Linux, такі як Rocky Linux, який працює на архітектурі x86_64.

У цій лабораторній роботі ви завантажите площину керування Kubernetes. Ви встановите такі компоненти на контролері: сервер Kubernetes API, планувальник і диспетчер контролера.

## Передумови

Підключіться до `jumpbox` і скопіюйте двійкові файли Kubernetes і файли модуля `systemd` до примірника `server`:

```bash
scp \
  downloads/kube-apiserver \
  downloads/kube-controller-manager \
  downloads/kube-scheduler \
  downloads/kubectl \
  units/kube-apiserver.service \
  units/kube-controller-manager.service \
  units/kube-scheduler.service \
  configs/kube-scheduler.yaml \
  configs/kube-apiserver-to-kubelet.yaml \
  root@server:~/
```

Ви повинні запустити команди в наступних розділах цієї лабораторної роботи на машині `сервера`. Увійдіть до примірника контролера за допомогою команди `ssh`. Приклад:

```bash
ssh root@server
```

## Надання площини керування Kubernetes

Створіть каталог конфігурації Kubernetes:

```bash
mkdir -p /etc/kubernetes/config
```

### Встановіть двійкові файли контролера Kubernetes

Встановіть двійкові файли Kubernetes:

```bash
  chmod +x kube-apiserver \
    kube-controller-manager \
    kube-scheduler kubectl
    
  mv kube-apiserver \
    kube-controller-manager \
    kube-scheduler kubectl \
    /usr/local/bin/
```

### Налаштуйте сервер API Kubernetes

```bash
  mkdir -p /var/lib/kubernetes/

  mv ca.crt ca.key \
    kube-api-server.key kube-api-server.crt \
    service-accounts.key service-accounts.crt \
    encryption-config.yaml \
    /var/lib/kubernetes/
```

Створіть одиничний файл `kube-apiserver.service` `systemd`:

```bash
mv kube-apiserver.service /etc/systemd/system/kube-apiserver.service
```

### Налаштуйте менеджер контролера Kubernetes

Перемістіть kubeconfig `kube-controller-manager` на місце:

```bash
mv kube-controller-manager.kubeconfig /var/lib/kubernetes/
```

Створіть файл модуля `kube-controller-manager.service` `systemd`:

```bash
mv kube-controller-manager.service /etc/systemd/system/
```

### Налаштуйте планувальник Kubernetes

Перемістіть `kube-scheduler` kubeconfig на місце:

```bash
mv kube-scheduler.kubeconfig /var/lib/kubernetes/
```

Створіть файл конфігурації `kube-scheduler.yaml`:

```bash
mv kube-scheduler.yaml /etc/kubernetes/config/
```

Створіть системний файл блоку `kube-scheduler.service`:

```bash
mv kube-scheduler.service /etc/systemd/system/
```

### Запустіть служби контролера

```bash
  systemctl daemon-reload
  
  systemctl enable kube-apiserver \
    kube-controller-manager kube-scheduler
    
  systemctl start kube-apiserver \
    kube-controller-manager kube-scheduler
```

> Зачекайте до 10 секунд для повної ініціалізації сервера Kubernetes API.

### Верифікація

```bash
kubectl cluster-info   --kubeconfig admin.kubeconfig
```

```text
Kubernetes control plane is running at https://127.0.0.1:6443
```

## RBAC для авторизації Kubelet

У цьому розділі ви налаштуєте дозволи RBAC, щоб дозволити серверу API Kubernetes отримувати доступ до API Kubelet на кожному робочому вузлі. Доступ до Kubelet API потрібен для отримання показників і журналів, а також для виконання команд у модулях.

> Цей підручник встановлює прапор Kubelet `--authorization-mode` на `Webhook`. Режим `Webhook` використовує [SubjectAccessReview](https://kubernetes.io/docs/reference/kubernetes-api/authorization-resources/subject-access-review-v1/) API для визначення авторизації.

Виконайте команди в цьому розділі на вузлі контролера, впливаючи на весь кластер.

```bash
ssh root@server
```

Створіть `system:kube-apiserver-to-kubelet` [ClusterRole](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole) із дозволами на доступ до API Kubelet і виконання найпоширеніших завдань, пов’язаних із керуванням пакетами:

```bash
kubectl apply -f kube-apiserver-to-kubelet.yaml \
  --kubeconfig admin.kubeconfig
```

### Перевірка RBAC

На даний момент площина керування Kubernetes запущена та працює. Виконайте наступні команди з машини `jumpbox`, щоб переконатися, що вона працює:

Зробіть HTTP-запит на інформацію про версію Kubernetes:

```bash
curl -k --cacert ca.crt https://server.kubernetes.local:6443/version
```

```text
{
  "major": "1",
  "minor": "32",
  "gitVersion": "v1.32.0",
  "gitCommit": "70d3cc986aa8221cd1dfb1121852688902d3bf53",
  "gitTreeState": "clean",
  "buildDate": "2024-12-11T17:59:15Z",
  "goVersion": "go1.23.3",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

Далі: [Завантаження робочих вузлів Kubernetes](lab9-bootstrapping-kubernetes-workers.md)
