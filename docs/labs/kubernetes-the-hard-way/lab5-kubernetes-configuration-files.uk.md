---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - лабораторна вправа
---

# Лабораторна робота 5: Створення файлів конфігурації Kubernetes для автентифікації

!!! info

    Це гілка розгалуження від оригінальної ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), Келсі Хайтауера (GitHub: kelseyhightower). На відміну від оригіналу, який базується на дистрибутивах, подібних до Debian, для архітектури ARM64, ця гілка націлена на дистрибутиви Enterprise Linux, такі як Rocky Linux, який працює на архітектурі x86_64.

У цій лабораторній роботі ви створите [файли конфігурації клієнта Kubernetes](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/), які зазвичай називаються kubeconfigs. Ці файли налаштовують клієнти Kubernetes для підключення та автентифікації за допомогою серверів API Kubernetes.

## Конфігурації автентифікації клієнта

У цьому розділі ви створите файли kubeconfig для користувачів `kubelet` і `admin`.

### Файл конфігурації kubelet Kubernetes

Під час генерації файлів kubeconfig для Kubelets ви повинні зіставити сертифікат клієнта з назвою вузла Kubelet. Це забезпечить належну авторизацію Kubelets Kubernetes [Node Authorizer](https://kubernetes.io/docs/admin/authorization/node/).

> Наступні команди потрібно виконати в тому самому каталозі, який використовується для створення сертифікатів SSL під час лабораторної роботи [Створення сертифікатів TLS](lab4-certificate-authority.md).

Згенеруйте файл kubeconfig для робочих вузлів node-0 і node-1:

```bash
for host in node-0 node-1; do
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443 \
    --kubeconfig=${host}.kubeconfig

  kubectl config set-credentials system:node:${host} \
    --client-certificate=${host}.crt \
    --client-key=${host}.key \
    --embed-certs=true \
    --kubeconfig=${host}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:node:${host} \
    --kubeconfig=${host}.kubeconfig

  kubectl config use-context default \
    --kubeconfig=${host}.kubeconfig
done
```

Результати:

```text
node-0.kubeconfig
node-1.kubeconfig
```

### Файл конфігурації kube-proxy Kubernetes

Згенеруйте файл kubeconfig для служби `kube-proxy`:

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443 \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.crt \
    --client-key=kube-proxy.key \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default \
    --kubeconfig=kube-proxy.kubeconfig
```

Результати:

```text
kube-proxy.kubeconfig
```

### Файл конфігурації kube-controller-manager Kubernetes

Згенеруйте файл kubeconfig для служби `kube-controller-manager`:

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.crt \
    --client-key=kube-controller-manager.key \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default \
    --kubeconfig=kube-controller-manager.kubeconfig
```

Результати:

```text
kube-controller-manager.kubeconfig
```

### Файл конфігурації kube-scheduler Kubernetes

Згенеруйте файл kubeconfig для служби `kube-scheduler`:

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://server.kubernetes.local:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.crt \
    --client-key=kube-scheduler.key \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default \
    --kubeconfig=kube-scheduler.kubeconfig
```

Результати:

```text
kube-scheduler.kubeconfig
```

### Файл конфігурації Kubernetes адміністратора

Створіть файл kubeconfig для користувача `admin`:

```bash
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.crt \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate=admin.crt \
    --client-key=admin.key \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default \
    --kubeconfig=admin.kubeconfig
```

Результати:

```text
admin.kubeconfig
```

## Поширюйте файли конфігурації Kubernetes

Скопіюйте файли kubeconfig `kubelet` і `kube-proxy` до екземплярів `node-0` і `node-1`:

```bash
for host in node-0 node-1; do
  ssh root@$host "mkdir /var/lib/{kube-proxy,kubelet}"
  
  scp kube-proxy.kubeconfig \
    root@$host:/var/lib/kube-proxy/kubeconfig \
  
  scp ${host}.kubeconfig \
    root@$host:/var/lib/kubelet/kubeconfig
done
```

Скопіюйте файли kubeconfig `kube-controller-manager` і `kube-scheduler` до примірника контролера:

```bash
scp admin.kubeconfig \
  kube-controller-manager.kubeconfig \
  kube-scheduler.kubeconfig \
  root@server:~/
```

Далі: [Створення конфігурації та ключа шифрування даних](lab6-data-encryption-keys.md)
