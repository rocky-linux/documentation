---
author: Wale Soyinka
contributors: Steven Spencer
tags:
  - kubernetes
  - k8s
  - лабораторна вправа
  - runc
  - containerd
  - etcd
  - kubectl
---

# Лабораторна робота 10: Налаштування `kubectl` для віддаленого доступу

> Це вітка оригінального ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), яку спочатку створив Келсі Хайтауер (GitHub: kelseyhightower). На відміну від оригіналу, який базується на дистрибутивах, подібних до Debian, для архітектури ARM64, ця гілка націлена на дистрибутиви Enterprise Linux, такі як Rocky Linux, що працюють на архітектурі x86_64.

У цій лабораторній роботі ви створите файл kubeconfig для утиліти командного рядка `kubectl` на основі облікових даних користувача `admin`.

> Виконайте команди в цій лабораторії з машини `jumpbox`.

## Файл конфігурації Kubernetes адміністратора

Для підключення кожного kubeconfig потрібен сервер Kubernetes API.

На основі DNS-запису `/etc/hosts` з попередньої лабораторії ви повинні мати можливість перевірити ping` server.kubernetes.local`.

```bash
curl -k --cacert ca.crt \
  https://server.kubernetes.local:6443/version
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

Згенеруйте файл kubeconfig, придатний для автентифікації користувача адміністратора:

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443

  kubectl config set-credentials admin \
    --client-certificate=admin.crt \
    --client-key=admin.key

  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin

  kubectl config use-context kubernetes-the-hard-way
```

Результати виконання наведеної вище команди мають створити файл kubeconfig у типовому розташуванні `~/.kube/config`, яке використовується інструментом командного рядка `kubectl`. Це також означає, що ви можете запустити команду `kubectl` без вказівки конфігурації.

## Верифікація

Перевірте версію віддаленого кластера Kubernetes:

```bash
kubectl version
```

```text
Client Version: v1.32.0
Kustomize Version: v5.5.0
Server Version: v1.32.0
```

Перелічіть вузли у віддаленому кластері Kubernetes:

```bash
kubectl get nodes
```

```text
NAME     STATUS   ROLES    AGE   VERSION
node-0   Ready    <none>   30m   v1.31.2
node-1   Ready    <none>   35m   v1.31.2
```

Далі: [Надання мережевих маршрутів Pod](lab11-pod-network-routes.md)
