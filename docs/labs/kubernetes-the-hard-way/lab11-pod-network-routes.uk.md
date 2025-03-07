---
author: Wale Soyinka
contributors: Steven Spencer, Ganna Zhyrnova
tags:
  - kubernetes
  - k8s
  - лабораторна вправа
  - runc
  - containerd
  - etcd
  - kubectl
---

# Лабораторна робота 11: Надання мережевих маршрутів Pod

!!! info

    Це гілка розгалуження від оригінальної ["Kubernetes the hard way"](https://github.com/kelseyhightower/kubernetes-the-hard-way), Келсі Хайтауера (GitHub: kelseyhightower). На відміну від оригіналу, який базується на дистрибутивах, подібних до Debian, для архітектури ARM64, ця гілка націлена на дистрибутиви Enterprise Linux, такі як Rocky Linux, який працює на архітектурі x86_64.

Поди, заплановані на вузол, отримують IP-адресу з діапазону CIDR модуля вузла. Наразі модулі не можуть обмінюватися даними з іншими модулями, що працюють на різних вузлах, через відсутність мережевих [маршрутів](https://cloud.google.com/compute/docs/vpc/routes).

У цій лабораторній роботі ви створите маршрут для кожного робочого вузла, який зіставляє діапазон CIDR Pod вузла з внутрішньою IP-адресою вузла.

> Існують [інші способи](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this) реалізації моделі мережі Kubernetes.

## Таблиця маршрутизації

У цьому розділі ви зберете інформацію, необхідну для створення маршрутів у мережі VPC `kubernetes-the-hard-way`.

Надрукуйте внутрішню IP-адресу та діапазон CIDR Pod для кожного робочого екземпляра:

```bash
{
  SERVER_IP=$(grep server machines.txt | cut -d " " -f 1)
  NODE_0_IP=$(grep node-0 machines.txt | cut -d " " -f 1)
  NODE_0_SUBNET=$(grep node-0 machines.txt | cut -d " " -f 5)
  NODE_1_IP=$(grep node-1 machines.txt | cut -d " " -f 1)
  NODE_1_SUBNET=$(grep node-1 machines.txt | cut -d " " -f 5)
}
```

```bash
ssh root@server <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
```

```bash
ssh root@node-0 <<EOF
  ip route add ${NODE_1_SUBNET} via ${NODE_1_IP}
EOF
```

```bash
ssh root@node-1 <<EOF
  ip route add ${NODE_0_SUBNET} via ${NODE_0_IP}
EOF
```

## Верифікація

```bash
ssh root@server ip route
```

```text
default via XXX.XXX.XXX.XXX dev ens160 
10.200.0.0/24 via XXX.XXX.XXX.XXX dev ens160 
10.200.1.0/24 via XXX.XXX.XXX.XXX dev ens160 
XXX.XXX.XXX.0/24 dev ens160 proto kernel scope link src XXX.XXX.XXX.XXX 
```

```bash
ssh root@node-0 ip route
```

```text
default via XXX.XXX.XXX.XXX dev ens160 
10.200.1.0/24 via XXX.XXX.XXX.XXX dev ens160 
XXX.XXX.XXX.0/24 dev ens160 proto kernel scope link src XXX.XXX.XXX.XXX 
```

```bash
ssh root@node-1 ip route
```

```text
default via XXX.XXX.XXX.XXX dev ens160 
10.200.0.0/24 via XXX.XXX.XXX.XXX dev ens160 
XXX.XXX.XXX.0/24 dev ens160 proto kernel scope link src XXX.XXX.XXX.XXX 
```

Далі: [Smoke Test](lab12-smoke-test.md)
